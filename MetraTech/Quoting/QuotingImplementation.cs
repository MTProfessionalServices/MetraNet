using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTBillingReRun;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Pipeline;
using MetraTech.UsageServer;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using BillingReRunClient = MetraTech.Pipeline.ReRun;

namespace MetraTech.Quoting
{
  public interface IQuotingImplementation
  {
    int StartQuote(QuoteRequest quoteRequest);
    void AddRecurringChargesToQuote();
    void AddNonRecurringChargesToQuote();
    QuoteResponse FinalizeQuote();

    IQuotingRepository QuotingRepository { get; }
  }

  public class QuotingImplementation : IQuotingImplementation
  {
    protected QuotingConfiguration Configuration { get; set; }
    private Auditor quotingAuditor = new Auditor();
    private static Logger mLogger = new Logger("[QuotingImplementation]");

    private const string QUOTING_QUERY_FOLDER = "Queries\\Quoting";

    private int UsageIntervalForQuote { get; set; }

    private readonly List<MTSubscription> createdSubsciptions;
    private readonly List<IMTGroupSubscription> createdGroupSubsciptions;

    private Dictionary<string, Interop.MeterRowset.MeterRowset> metters =
      new Dictionary<string, Interop.MeterRowset.MeterRowset>();

    private Dictionary<string, string> batchIds = new Dictionary<string, string>();

    protected readonly IQuotingRepository quotingRepository;

    public IQuotingRepository QuotingRepository
    {
      get { return quotingRepository; }
    }

    public QuotingImplementation(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext,
                                 IQuotingRepository quotingRepository)
    {
      createdSubsciptions = new List<MTSubscription>();
      createdGroupSubsciptions = new List<IMTGroupSubscription>();

      Configuration = configuration;
      SessionContext = sessionContext;
      this.quotingRepository = quotingRepository;
    }

    public QuotingImplementation(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext)
    {
      createdSubsciptions = new List<MTSubscription>();
      createdGroupSubsciptions = new List<IMTGroupSubscription>();

      Configuration = configuration;
      SessionContext = sessionContext;

      quotingRepository = new QuotingRepository();
    }

    public QuotingImplementation(QuotingConfiguration configuration)
    {
      createdSubsciptions = new List<MTSubscription>();
      createdGroupSubsciptions = new List<IMTGroupSubscription>();

      Configuration = configuration;
      quotingRepository = new QuotingRepository();
    }

    public QuotingImplementation()
    {
      createdSubsciptions = new List<MTSubscription>();
      createdGroupSubsciptions = new List<IMTGroupSubscription>();

      Configuration = QuotingConfigurationManager.LoadConfigurationFromFile(
        Path.Combine(SystemConfig.GetRmpDir(), "config", "Quoting", "QuotingConfiguration.xml"));
      quotingRepository = new QuotingRepository();
    }

    #region Public

    protected QuoteRequest currentRequest;

    public QuoteRequest CurrentRequest
    {
      get { return currentRequest; }
    }

    //Prototype
    public QuoteResponse CurrentResponse { get; set; } //Prototype


    /// <summary>
    /// Validate request and prepare data for metering
    /// </summary>
    /// <param name="quoteRequest">Parameters of the quote</param>
    public int StartQuote(QuoteRequest quoteRequest)
    {
      //TODO: Should we add check that pipeline/inetinfo/activityservices are running before starting quote. We think nice to have and maybe configurable
      using (new MetraTech.Debug.Diagnostics.HighResolutionTimer("StartQuote"))
      {
        CurrentResponse = new QuoteResponse();
        CurrentResponse.MessageLog = new List<QuoteLogRecord>();

        createdSubsciptions.Clear();
        createdGroupSubsciptions.Clear();

        ValidateRequest(quoteRequest);

        currentRequest = quoteRequest;

        try
        {
          //Add this quote into repository and get a new quote id
          CurrentResponse.idQuote = QuotingRepository.CreateQuote(quoteRequest, SessionContext);

          StartQuoteInternal();
        }
        catch (Exception ex)
        {
          RecordExceptionAndCleanup(ex);
          throw;
        }

        return CurrentResponse.idQuote;
      }
    }

    /// <summary>
    /// Generate and rate recurring charge events for this quote, including UDRCs    
    /// </summary>
    public void AddRecurringChargesToQuote()
    {
      using (new Debug.Diagnostics.HighResolutionTimer("AddRecurringChargesToQuote"))
      {
        VerifyCurrentQuoteIsInProgress();

        Log("Preparing Recurring Charges");

        var countMeteredRecords = 0;

        // call stored procedure to generate charges
        using (var conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
        {
          using (var stmt = conn.CreateCallableStatement(Configuration.RecurringChargeStoredProcedureQueryTag))
          {
            stmt.AddParam("v_id_interval", MTParameterType.Integer, UsageIntervalForQuote);
            stmt.AddParam("v_id_billgroup", MTParameterType.Integer, 0); //reserved for future
            stmt.AddParam("v_id_run", MTParameterType.Integer, 0); //reserved for future
            stmt.AddParam("v_id_accounts", MTParameterType.String, string.Join(",", CurrentRequest.Accounts));
            stmt.AddParam("v_id_batch", MTParameterType.String, batchIds["RC"]);
            stmt.AddParam("v_n_batch_size", MTParameterType.Integer, Configuration.MeteringSessionSetSize);
            stmt.AddParam("v_run_date", MTParameterType.DateTime, MetraTime.Now);
            //todo: Clarify parameter sense
            stmt.AddOutputParam("p_count", MTParameterType.Integer);
            var res = stmt.ExecuteNonQuery();
            countMeteredRecords = (int) stmt.GetOutputValue("p_count");
          }
        }

        if (countMeteredRecords > 0)
        {
          Log("Metered {0} records to Recurring Charge with Batch ID={1} and waiting for pipeline to process",
              countMeteredRecords, batchIds["RC"]);

          try
          {
            metters["RC"].WaitForCommit(countMeteredRecords, 120);
          }
          catch (Exception ex)
          {
            RecordExceptionAndCleanup(ex);
            throw;
          }

          // Check for error during pipeline processing
          if (metters["RC"].CommittedErrorCount > 0)
          {
            string errorMessage =
              String.Format("{0} Recurring Charge sessions failed during pipeline processing.",
                            metters["RC"].CommittedErrorCount);
            string pipelineErrorDetails = RetrievePipelineErrorDetailsMessage(this.batchIds["RC"]);
            errorMessage += Environment.NewLine + "Pipeline Errors:" + System.Environment.NewLine +
                            pipelineErrorDetails;

            RecordErrorAndCleanup(errorMessage);
            throw new ApplicationException(errorMessage);
          }
        }
        else
        {
          Log("No Recurring Charges for this quote");
        }

        Log("Done Preparing Recurring Charges");
      }

    }

    /// <summary>
    /// Helper method to retrieve detailed error messages for any failures
    /// that occured in the pipeline
    /// </summary>
    /// <param name="batchIdEncoded">metered batch id to retrieve errors for</param>
    /// <returns></returns>
    private string RetrievePipelineErrorDetailsMessage(string batchIdEncoded)
    {
      //select tx_StageName, tx_Plugin, tx_ErrorMessage from t_failed_transaction where tx_Batch_Encoded = 'Csj8TlVRaiFpU0YM/f93+w=='

      MTStringBuilder sb = new MTStringBuilder();

      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement(QUOTING_QUERY_FOLDER,
                                                                 "__GET_PIPELINE_ERRORS_FOR_BATCH__"))
        {
          stmt.AddParam("%%STRING_BATCH_ID%%", batchIdEncoded);

          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            while (reader.Read())
            {
              sb.Append(string.Format("Stage[{0}] Plugin[{1}] Error[{2}]" + System.Environment.NewLine,
                                      reader.GetString("tx_StageName"),
                                      reader.GetString("tx_Plugin"),
                                      reader.GetString("tx_ErrorMessage")));
            }
          }
        }
      }

      return sb.ToString();
    }

    /// <summary>
    /// Generate and rate non-recurring charge events for this quote 
    /// </summary>
    public void AddNonRecurringChargesToQuote()
    {
      using (new Debug.Diagnostics.HighResolutionTimer("AddNonRecurringChargesToQuote"))
      {

        VerifyCurrentQuoteIsInProgress();

        Log("Preparing Non-Recurring Subscription Start Charges");

        int countMeteredRecords;
        using (var conn = ConnectionManager.CreateConnection())
        {
          using (
            var stmt = conn.CreateCallableStatement(Configuration.NonRecurringChargeStoredProcedureQueryTag))
          {
            //ToDo: Get start and end date according to billing cycle
            var dateTime = MetraTime.Now;
            var firstDayOfTheMonth = new DateTime(dateTime.Year, dateTime.Month, 1);
            var firstDayOfTheNextMonth = firstDayOfTheMonth.AddMonths(1);

            stmt.AddParam("dt_start", MTParameterType.DateTime, firstDayOfTheMonth);
            stmt.AddParam("dt_end", MTParameterType.DateTime, firstDayOfTheNextMonth);
            stmt.AddParam("v_id_interval", MTParameterType.Integer, UsageIntervalForQuote);
            stmt.AddParam("v_id_accounts", MTParameterType.String, string.Join(",", CurrentRequest.Accounts));
            stmt.AddParam("v_id_batch", MTParameterType.String, batchIds["NRC"]);
            stmt.AddParam("v_n_batch_size", MTParameterType.Integer, Configuration.MeteringSessionSetSize);
            stmt.AddParam("v_run_date", MTParameterType.DateTime, dateTime);
            stmt.AddParam("v_is_group_sub", MTParameterType.Integer,
                          Convert.ToInt32(CurrentRequest.SubscriptionParameters.IsGroupSubscription));
            stmt.AddOutputParam("p_count", MTParameterType.Integer);
            var res = stmt.ExecuteNonQuery();
            countMeteredRecords = (int) stmt.GetOutputValue("p_count");
          }
        }

        if (countMeteredRecords > 0)
        {
          Log(
            "Metered {0} records to Non-Recurring Charge with Batch ID={1} and waiting for pipeline to process",
            countMeteredRecords, batchIds["NRC"]);

          try
          {
            metters["NRC"].WaitForCommit(countMeteredRecords, 120);
          }
          catch (Exception ex)
          {
            RecordExceptionAndCleanup(ex);
            throw;
          }

          // Check for error during pipeline processing
          if (metters["NRC"].CommittedErrorCount > 0)
          {
            string errorMessage =
              String.Format("{0} Non-Recurring Charge sessions failed during pipeline processing.",
                            metters["NRC"].CommittedErrorCount);
            RecordErrorAndCleanup(errorMessage);
            throw new ApplicationException(errorMessage);
          }

        }
        else
        {
          Log("No Non-Recurring Subscription Start Charges for this quote");
        }

        Log("Done Preparing Non-Recurring Subscription Start Charges");
      }
    }

    /// <summary>
    /// Complete quote, generate reports and summaries and clean up
    /// </summary>
    /// <returns></returns>
    public QuoteResponse FinalizeQuote()
    {
      using (new Debug.Diagnostics.HighResolutionTimer("FinalizeQuote"))
      {
        try
        {

          VerifyCurrentQuoteIsInProgress();

          FinalizeQuoteInternal();

          if (CurrentRequest.ReportParameters.PDFReport)
          {
            GeneratePDFForCurrentQuote();
          }

          //todo: Save or update data about quote in DB
          CurrentResponse = QuotingRepository.UpdateQuoteWithResponse(CurrentResponse);
          QuotingRepository.SaveQuoteLog(CurrentResponse.MessageLog);

          Cleanup();

        }
        catch (Exception ex)
        {
          RecordExceptionAndCleanup(ex);
          throw;
        }

        return CurrentResponse;
      }
    }

    #endregion

    #region Internal

    /// <summary>
    /// Method that validates/sanity checks the request and throws exceptions if there are errors
    /// </summary>
    /// <param name="request">QuoteRequest to be checked</param>
    /// <exception cref="ArgumentException"></exception>
    protected void ValidateRequest(QuoteRequest request)
    {

      if (request.IcbPrices == null)
            request.IcbPrices = new List<QuoteIndividualPrice>();

      if (request.SubscriptionParameters.IsGroupSubscription && request.IcbPrices.Count > 0)
      {
        throw new Exception("Current limitation of quoting: ICBs are applied only for individual subscriptions");
      }


      DateTime currentDate = MetraTime.Now.Date;
      if (request.EffectiveDate.Date < currentDate)
      {
        string propertyName = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveDate);
        throw new ArgumentException(
          String.Format("'{0}'='{1}' can't be less than current time '{2}'", propertyName,
                        request.EffectiveDate.Date, currentDate), propertyName);
      }



      //EffectiveDate must be set
      if (request.EffectiveDate == null || request.EffectiveDate == DateTime.MinValue)
      {
        string propertyName = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveDate);
        throw new ArgumentException(String.Format("'{0}' must be specified", propertyName), propertyName);
      }

      if (request.EffectiveEndDate < request.EffectiveDate)
      {
        string propertyStartDate = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveDate);
        string propertyEndDate = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveEndDate);
        throw new ArgumentException(
          String.Format("The Start date can not be greater than End date. Start date '{0}'='{1}' > End date '{2}'='{3}'"
                        , propertyStartDate, request.EffectiveDate
                        , propertyEndDate, request.EffectiveEndDate)
          , propertyEndDate);
      }

      //At least one account must be specified
      if (!(request.Accounts.Count > 0))
      {
        throw new ArgumentException("At least one account must be specified for the quote"
                                    , PropertyName<QuoteRequest>.GetPropertyName(p => p.Accounts));
      }

      //todo check for the same usage cycle for all accounts
      //if (!(request.Accounts.Count > 0)) { throw new ArgumentException("At least one account must be specified for the quote", "Accounts"); }

      //At least one po must be specified since we only do RCs and NRCs currently; in the future this won't be a restriction
      if (!(request.ProductOfferings.Count > 0))
      {
        throw new ArgumentException(
          "At least one product offering must be specified for the quote as quoting currently only quotes for RCs and NRC"
          , PropertyName<QuoteRequest>.GetPropertyName(p => p.ProductOfferings));
      }

      // Ensure that all accounts are in the same billing cycle
      var first = GetAccountBillingCycle(request.Accounts.First());
      if (!(request.Accounts.All(e => GetAccountBillingCycle(e) == first)))
      {
        throw new ArgumentException("All accounts must be in the same billing cycle"
                                    , PropertyName<QuoteRequest>.GetPropertyName(p => p.Accounts));
      }

      // Ensure that all payers are in the quote request
      var idPayers = request.Accounts.Select(e => GetAccountPayer(e));
      if (!idPayers.All(e => request.Accounts.Contains(e)))
      {
        throw new ArgumentException("All account payers must be included in the quote request"
                                    , PropertyName<QuoteRequest>.GetPropertyName(p => p.Accounts));
      }     
    }

    protected int GetAccountBillingCycle(int idAccount)
    {
      using (var conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (
          var stmt = conn.CreateAdapterStatement(QUOTING_QUERY_FOLDER, Configuration.GetAccountBillingCycleQueryTag))
        {
          stmt.AddParam("%%ACCOUNT_ID%%", idAccount);
          using (var rowset = stmt.ExecuteReader())
          {
            if (!rowset.Read())
              throw new ApplicationException(string.Format("The account {0} has no billing cycle", idAccount));

            return rowset.GetInt32("AccountCycleType");
          }
        }
      }
    }

    protected int GetAccountPayer(int idAccount)
    {
      int payer;

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement(QUOTING_QUERY_FOLDER,
                                                                 Configuration.GetAccountPayerQueryTag))
        {
          stmt.AddParam("%%ACCOUNT_ID%%", idAccount);
          using (IMTDataReader rowset = stmt.ExecuteReader())
          {
            rowset.Read();
            payer = rowset.GetInt32("AccountPayer");
          }
        }
      }

      return payer;
    }

    protected void VerifyCurrentQuoteIsInProgress()
    {
      if (CurrentResponse == null)
      {
        throw new ApplicationException("Quote has not been started. Call StartQuote to create a new quote.");
      }

      if (CurrentResponse.Status != QuoteStatus.InProgress)
      {
        switch (CurrentResponse.Status)
        {
          case QuoteStatus.Failed:
            throw new ApplicationException(
              "Current quote has failed and can no longer be worked with. Check CurrentResponse.Status and CurrentResponse.FailedMessage.");
          case QuoteStatus.Complete:
            throw new ApplicationException("Current quote has completed and can no longer be worked with.");
          default:
            throw new ArgumentOutOfRangeException();
        }
      }
    }

    protected void StartQuoteInternal()
    {
      //Initialize metering and create new batch id to use when metering for this quote
      InitMetering();

      //Create the needed subscriptions for this quote
      CreateNeededSubscriptions();

      //Determine Usage Interval to use when quoting
      UsageIntervalForQuote = GetUsageIntervalForQuote(CurrentRequest.EffectiveDate, CurrentRequest.Accounts[0]);
    }

    protected void FinalizeQuoteInternal()
    {
      //If we need here, here is the place for things that need to be generated, totaled, etc. before we
      //generate PDF and return results
      CalculateQuoteTotal();
    }

    protected void GeneratePDFForCurrentQuote()
    {
      using (new Debug.Diagnostics.HighResolutionTimer("GeneratePDFForCurrentQuote"))
      {
        try
        {

          //TODO: Eventually cache/only load configuration as needed
          var quoteReportingConfiguration = QuoteReportingConfigurationManager.LoadConfiguration(this.Configuration);
          var quotePDFReport = new QuotePDFReport(quoteReportingConfiguration);

          //If request does not specify a template to use, then use the configured default
          if (string.IsNullOrEmpty(CurrentRequest.ReportParameters.ReportTemplateName))
          {
            CurrentRequest.ReportParameters.ReportTemplateName = this.Configuration.ReportDefaultTemplateName;
          }

          CurrentResponse.ReportLink = quotePDFReport.CreatePDFReport(CurrentResponse.idQuote,
                                                                      CurrentRequest.Accounts[0],
                                                                      CurrentRequest.ReportParameters.ReportTemplateName,
                                                                      GetLanguageCodeIdForCurrentRequest());
        }
        catch (Exception ex)
        {
          RecordExceptionAndCleanup(ex);
          throw;
        }
      }
    }

    protected int GetLanguageCodeIdForCurrentRequest()
    {
      //TODO: Sort out using cultures for real and match them against either enum or database

      string temp = currentRequest.Localization;
      if (string.IsNullOrEmpty(temp))
      {
        //Not specified, default to "en-US"
        //temp = "en-US";
        return 840;
      }

      //Step 1: Try if this is int, then must have passed language id itself
      int possibleLanguageCodeId;
      if (int.TryParse(temp, out possibleLanguageCodeId))
      {
        return possibleLanguageCodeId;
      }

      //Step 2: Convert/lookup culture to database id (i.e. "en-US" = 840)
      //For now, until we have time, hard code the existing list but won't be extensible
      //Can't believe I've been reduced to this kind of code; feel dirty with the only solice that a 
      //story is in the backlog to be prioritized
      switch (temp.ToLower())
      {
        case "en-us":
          return 840;
        case "de-de":
          return 276;
        case "fr":
          return 250;
        case "it":
          return 380;
        case "ja":
          return 392;
        case "es":
          return 724;
        case "en-gb":
          return 826;
        case "ex-mx":
          return 2058;
        case "pt-br":
          return 1046;
        case "da":
          return 2059;
      }

      mLogger.LogWarning(
        "Unable to convert culture of {0} to MetraTech language code database id; using 840 for 'en-US'", temp);

      return 840;

    }

    /// <summary>
    /// Initialize the metering rowset to use for this quote and create a new batch id to use for metering
    /// </summary>
    protected void InitMetering()
    {
      metters.Add("RC", new Interop.MeterRowset.MeterRowsetClass());
      metters["RC"].InitSDK(Configuration.RecurringChargeServerToMeterTo);
      metters.Add("NRC", new Interop.MeterRowset.MeterRowsetClass());
      metters["NRC"].InitSDK(Configuration.RecurringChargeServerToMeterTo);
      batchIds.Add("RC", metters["RC"].GenerateBatchID());
      batchIds.Add("NRC", metters["NRC"].GenerateBatchID());
    }

    protected int GetPrimaryAccountId()
    {
      //For now, assume that the first account specified for the quote is the 'primary'
      //In the future, may pass a specific parameter
      if (CurrentRequest == null || CurrentRequest.Accounts.Count == 0)
        throw new ArgumentException("Must specify accounts");

      return CurrentRequest.Accounts[0];
    }

    public string GetQueryToUpdateInstantRCConfigurationValue(bool value)
    {
      IMTQueryAdapter qa = new MTQueryAdapterClass();
      qa.Init(@"Queries\ProductCatalog");

      qa.SetQueryTag("__SET_INSTANTRC_VALUE__");
      qa.AddParam("%%INSTANT_RC_ENABLED%%", value.ToString().ToLower());

      return qa.GetQuery().Trim();
    }

    private static readonly object _obj = new object();


    protected void CreateNeededSubscriptions()
    {
      //TODO: Determine if this lock is necessary and if so, give it a better/more descriptive name and comment
      lock (_obj)
      {
        #region Check and turn off InstantRCs if needed

        bool instantRCsEnabled = true;
        //Check and turn off InstantRCs
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (var stmt = conn.CreateAdapterStatement(@"Queries\ProductCatalog", "__GET_INSTANTRC_VALUE__"))
          {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              if (reader.Read())
              {
                instantRCsEnabled = reader.GetBoolean("InstantRCValue");
              }
              else
              {
                string errorMessage = "Unable to retrieve InstantRC setting";
                RecordErrorAndCleanup(errorMessage);
                throw new ApplicationException(errorMessage);
              }
            }
          }

          if (instantRCsEnabled)
          {
            using (IMTStatement stmt = conn.CreateStatement(GetQueryToUpdateInstantRCConfigurationValue(false)))
            {
              stmt.ExecuteNonQuery();
            }
          }
        }

        #endregion

        var transactionOption = new TransactionOptions();
        transactionOption.IsolationLevel = IsolationLevel.ReadUncommitted;
        using (var scope = new TransactionScope(TransactionScopeOption.RequiresNew,
                                                transactionOption,
                                                EnterpriseServicesInteropOption.Full))
        {
          if (!CurrentRequest.SubscriptionParameters.IsGroupSubscription)
            foreach (var idAccount in CurrentRequest.Accounts)
            {
              var acc = CurrentProductCatalog.GetAccount(idAccount);
              foreach (int po in CurrentRequest.ProductOfferings)
              {
                CreateIndividualSubscriptionForQuote(acc, po, idAccount);
              }
            }
          else
            foreach (var offerId in CurrentRequest.ProductOfferings)
            {
              CreateGroupSubscriptionForQuote(offerId,
                                              CurrentRequest.SubscriptionParameters.CorporateAccountId,
                                              CurrentRequest.Accounts);
            }
          scope.Complete();
        }


        #region Turn InstantRCs back on

        if (instantRCsEnabled)
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (
              IMTStatement stmt = conn.CreateStatement(GetQueryToUpdateInstantRCConfigurationValue(instantRCsEnabled)))
            {
              stmt.ExecuteNonQuery();
            }
          }
        }

        #endregion
      }
    }

    /// <summary>
    /// Create Group Subscription and add its ID into createdGroupSubsciptions
    /// </summary>
    /// <param name="offerId"></param>
    /// <param name="corporateAccountId"></param>
    /// <param name="accountList"></param>
    /// /// <remarks>Should be run in one transaction with the same call for all POs in QuoteRequest</remarks>
    private void CreateGroupSubscriptionForQuote(int offerId, int corporateAccountId, IEnumerable<int> accountList)
    {
      var effectiveDate = new MTPCTimeSpanClass
        {
          StartDate = CurrentRequest.EffectiveDate,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE,
          EndDate = CurrentRequest.EffectiveEndDate,
          EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };

      //TODO: Figure out correct cycle for group sub or if it should be passed
      var groupSubscriptionCycle = new MTPCCycle
        {
          CycleTypeID = 1,
          EndDayOfMonth = 31
        };

      IMTGroupSubscription mtGroupSubscription = CurrentProductCatalog.CreateGroupSubscription();
      mtGroupSubscription.EffectiveDate = effectiveDate;
      mtGroupSubscription.ProductOfferingID = offerId;
      mtGroupSubscription.ProportionalDistribution = true; //Part of request?
      //if (!groupSubscription.ProportionalDistribution)
      //{
      //  mtGroupSubscription.DistributionAccount = groupSubscription.DiscountAccountId.Value;
      //}
      mtGroupSubscription.Name = string.Format("TempQuoteGSForPO_{0}Quote_{1}", offerId,
                                               CurrentResponse.idQuote);
      mtGroupSubscription.Description = "Group subscription for Quoting. ProductOffering: " + offerId;
      mtGroupSubscription.SupportGroupOps = true; // Part of request?
      mtGroupSubscription.CorporateAccount = corporateAccountId;
      mtGroupSubscription.Cycle = groupSubscriptionCycle;

      foreach (MTPriceableItem pi in CurrentProductCatalog.GetProductOffering(offerId).GetPriceableItems())
      {
        switch (pi.Kind)
        {
          case MTPCEntityType.PCENTITY_TYPE_RECURRING:
            mtGroupSubscription.SetChargeAccount(pi.ID, corporateAccountId,
                                                 CurrentRequest.EffectiveDate, CurrentRequest.EffectiveEndDate);
            break;
          case MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
            mtGroupSubscription.SetChargeAccount(pi.ID, corporateAccountId,
                                                 CurrentRequest.EffectiveDate, CurrentRequest.EffectiveEndDate);
            try
            {
              if (CurrentRequest.SubscriptionParameters.UDRCValues.ContainsKey(offerId.ToString()))
              {
                foreach (var udrcInstanceValue in CurrentRequest.SubscriptionParameters.UDRCValues[offerId.ToString()])
                {
                  mtGroupSubscription.SetRecurringChargeUnitValue(udrcInstanceValue.UDRC_Id,
                                                                  udrcInstanceValue.Value,
                                                                  udrcInstanceValue.StartDate,
                                                                  udrcInstanceValue.EndDate);
                }
              }
            }
            catch (COMException come)
            {
              if (come.Message.Contains("not found in database"))
              {
                LogError(come.Message);
                throw new ArgumentException("Subscription failed with message: " + come.Message +
                                            "\nUDRC ID added to SubscriptionParameters does not exist");
              }
              throw;
            }
            break;
        }
      }

      mtGroupSubscription.Save();
      createdGroupSubsciptions.Add(mtGroupSubscription);
      foreach (var mtGsubMember in accountList.Select(id => GetSubMember(id, CurrentRequest)))
      {
        mtGroupSubscription.AddAccount(mtGsubMember);
      }
      mtGroupSubscription.Save();
      createdGroupSubsciptions.Add(mtGroupSubscription);
    }

    private static MTGSubMember GetSubMember(int accountId, QuoteRequest quoteRequest)
    {
      return new MTGSubMember
        {
          AccountID = accountId,
          StartDate = quoteRequest.EffectiveDate,
          EndDate = quoteRequest.EffectiveEndDate
        };
    }

    /// <summary>
    /// Create Individual Subscription, apply ICBs and add its ID into CreatedSubscription
    /// </summary>
    /// <param name="acc"></param>
    /// <param name="po"></param>
    /// <param name="idAccount"></param>
    /// <remarks>Should be run in one transaction with the same call for all accounts and POs in QuoteRequest</remarks>
    private void CreateIndividualSubscriptionForQuote(MTPCAccount acc, int po, int idAccount)
    {
      var effDate = new MTPCTimeSpanClass
        {
          StartDate = CurrentRequest.EffectiveDate,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };

      object modifiedDate = MetraTime.Now;
      var subscription = acc.Subscribe(po, effDate, out modifiedDate);

      try
      {
        if (CurrentRequest.SubscriptionParameters.UDRCValues.ContainsKey(po.ToString()))
        {
          foreach (
            var udrcInstanceValue in
              CurrentRequest.SubscriptionParameters.UDRCValues[po.ToString()])
          {
            subscription.SetRecurringChargeUnitValue(udrcInstanceValue.UDRC_Id,
                                                     udrcInstanceValue.Value,
                                                     udrcInstanceValue.StartDate,
                                                     udrcInstanceValue.EndDate);
          }
        }
      }
      catch (COMException come)
      {
        if (come.Message.Contains("not found in database"))
        {
          LogError(come.Message);
          throw new ArgumentException("Subscription failed with message: " + come.Message +
                                      "\nUDRC ID added to SubscriptionParameters does not exist");
        }

        throw;
      }

      subscription.Save();

      ApplyIcbPricesToSubscription(subscription.ProductOfferingID, subscription.ID, idAccount);

      createdSubsciptions.Add(subscription);
    }

    private void ApplyIcbPricesToSubscription(int productOfferingId, int subscriptionId, int accountId)
    {
      if (currentRequest.IcbPrices == null) return;

      var icbPrices = currentRequest.IcbPrices.Where(ip => ip.ProductOfferingId == productOfferingId && ip.AccountId == accountId);
      foreach (var price in icbPrices)
        Application.ProductManagement.PriceListService.SaveRateSchedulesForSubscription(
          subscriptionId,
          new PCIdentifier(price.PriceableItemInstanceId),
          new PCIdentifier(price.ParameterTableId),
          price.RateSchedules,
          mLogger,
          SessionContext);
    }

    private string GetBatchIdsForQuery()
    {
      string sqlTemplate = "cast(N'' as xml).value('xs:base64Binary(\"{0}\")', 'binary(16)' ),";

      var res = batchIds.Values.Aggregate("", (current, value) => current + String.Format(sqlTemplate, value));

      return res.Substring(0, res.Length - 1);
    }

    private decimal GetDecimalProperty(IMTDataReader rowset, string property)
    {
      try
      {
        return rowset.GetDecimal(property);
      }
      catch (InvalidOperationException)
      {
        return 0M;
      }
      catch (SqlNullValueException)
      {
        return 0M;
      }
    }

    private string GetStringProperty(IMTDataReader rowset, string property)
    {
      try
      {
        return rowset.GetString(property);
      }
      catch (InvalidOperationException)
      {
        return "";
      }
      catch (SqlNullValueException)
      {
        return "";
      }
    }

    protected void CalculateQuoteTotal()
    {
      using (var conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QUOTING_QUERY_FOLDER,
                                                                      Configuration.CalculateQuoteTotalAmountQueryTag))
        {
          stmt.AddParam("%%USAGE_INTERVAL%%", UsageIntervalForQuote);
          stmt.AddParam("%%ACCOUNTS%%", string.Join(",", CurrentRequest.Accounts));
          stmt.AddParam("%%BATCHIDS%%", GetBatchIdsForQuery(), true);
          using (IMTDataReader rowset = stmt.ExecuteReader())
          {
            rowset.Read();

            CurrentResponse.TotalAmount = GetDecimalProperty(rowset, "Amount");
            CurrentResponse.TotalTax = GetDecimalProperty(rowset, "TaxTotal");
            CurrentResponse.Currency = GetStringProperty(rowset, "Currency");

            var totalMessage = string.Format("Total amount: {0} {1}, Total Tax: {2}",
                                             CurrentResponse.TotalAmount.ToString("N2"), CurrentResponse.Currency,
                                             CurrentResponse.TotalTax);

            Log("CalculateQuoteTotal: {0}", totalMessage);

            //TODO: Error check if we didn't find anything but we expected something (i.e. rowset.Read failed but we expected results
            //TODO: Nice to have to add the count(*) of records which could be useful for error checking; adding to query doesn't cost anything
          }
        }
      }
    }


    /// <summary>
    /// Method to lookup the usage interval to use for this quote
    /// </summary>
    /// <param name="effectiveDate"></param>
    /// <param name="idAccount"></param>
    /// <returns></returns>
    public Int32 GetUsageIntervalForQuote(DateTime effectiveDate, int idAccount)
    {
      Int32 idUsageInterval;

      using (var conn = ConnectionManager.CreateConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement(QUOTING_QUERY_FOLDER,
                                                                 Configuration.GetUsageIntervalIdForQuotingQueryTag))
        {
          stmt.AddParam("%%EFFECTIVE_DATE%%", effectiveDate);
          stmt.AddParam("%%ACCOUNT_ID%%", idAccount);

          using (IMTDataReader rowset = stmt.ExecuteReader())
          {
            if (rowset.Read())
            {
              idUsageInterval = rowset.GetInt32("UsageIntervalId");
              string usageIntervalState = rowset.GetString("UsageIntervalState");
              DateTime usageIntervalStart = rowset.GetDateTime("UsageIntervalStart");
              DateTime usageIntervalEnd = rowset.GetDateTime("UsageIntervalEnd");

              //Perhaps in the future this can be resolved by obtaining the next open interval and using that for the quote
              if (string.Compare(usageIntervalState, "O", true) != 0)
              {
                throw new Exception(
                  string.Format(
                    "The interval {0} running from {1} to {2}, currently has a state of '{3}' and cannot be used for quoting. Please select an effective date other than {4}",
                    idUsageInterval, usageIntervalStart, usageIntervalEnd, usageIntervalState, effectiveDate));
              }

              //Hopefully this limitation can be removed or automatically resolved in the future
              if (rowset.IsDBNull("NextUsageIntervalId"))
              {
                throw new Exception(
                  string.Format(
                    "It is a current limitation of quoting recurring charge generation that the 'next' usage interval exists. For the interval {0} running from {1} to {2}, no usage interval exists for the next cycle starting {3}. Please create this usage interval.",
                    idUsageInterval, usageIntervalStart, usageIntervalEnd, usageIntervalEnd.AddSeconds(1)));
              }

            }
            else
            {
              throw new Exception(
                string.Format(
                  "Usage interval to use for quoting not found for effective date of {0} and account {1}. Please create this usage interval or use a different effective date.",
                  effectiveDate, idAccount));
            }

          }
        }
      }

      return idUsageInterval;
    }

    protected void RecordExceptionAndCleanup(Exception ex)
    {
      RecordErrorAndCleanup(ex.ToString());
    }

    protected void RecordErrorAndCleanup(string error)
    {
      CurrentResponse.Status = QuoteStatus.Failed;
      CurrentResponse.FailedMessage = error;

      LogError("Current quote failed and being cleaned up: {0}", error);

      //TODO: Track/Handle/Return error during cleanup
      Cleanup();

      CurrentResponse = QuotingRepository.UpdateQuoteWithErrorResponse(CurrentResponse.idQuote, CurrentResponse, error);

    }

    protected void Cleanup()
    {
      //If needed, cleanup should be completed here.
      //Happens when quote is finalized, pdf generated and returned
      //or if an error happens during processing

      CleanupSubscriptionsCreated();

      //Cleanup the usage data and an failed transactions
      if (CurrentRequest.DebugDoNotCleanupUsage && !Configuration.CurrentSystemIsProductionSystem)
      {
        //For debugging purposes, leave the usage data
        Log("WARNING: Not cleaning up usage data for quote run");
      }
      else
      {
          if (batchIds.Count > 0)
          {
              //Cleanup the usage data
              var batches = new ArrayList();
              if (batchIds.ContainsKey("RC"))
                  batches.Add(batchIds["RC"]);
              if (batchIds.ContainsKey("NRC"))
                  batches.Add(batchIds["NRC"]);
              CleanupBackoutUsageData(batches);
          }
      }

    }

    protected void CleanupSubscriptionsCreated()
    {
      // Remove individual subscriptions
      foreach (var subscription in createdSubsciptions)
      {
        try
        {
          var account = CurrentProductCatalog.GetAccount(subscription.AccountID);
          CleanupUDRCMetricValues(subscription.ID);
          account.RemoveSubscription(subscription.ID);
        }
        catch (Exception ex)
        {
          Log("Problem with clean up subscription {0}: {1}", subscription.ID, ex);
        }
      }

      // Remove group subscriptions
      foreach (var subscription in createdGroupSubsciptions)
      {
          try
          {
              // Unsubscribe members
              foreach (var idAccount in CurrentRequest.Accounts)
              {
                  IMTGSubMember gsmember = new MTGSubMemberClass();
                  gsmember.AccountID = idAccount;

                  if (subscription.FindMember(idAccount, CurrentRequest.EffectiveDate) != null)
                  {
                      subscription.UnsubscribeMember((MTGSubMember) gsmember);
                  }
              }

              using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
              {
                  using (IMTCallableStatement stmt = conn.CreateCallableStatement("RemoveGroupSubscription_Quoting"))
                  {
                      int status = 0;
                      stmt.AddParam("p_id_sub", MTParameterType.Integer, subscription.ID);
                      stmt.AddParam("p_systemdate", MTParameterType.DateTime, CurrentRequest.EffectiveDate);
                      stmt.AddParam("p_status", MTParameterType.Integer, status);
                      stmt.ExecuteNonQuery();
                  }
              }

              CleanupUDRCMetricValues(subscription.ID);
          }
          catch (Exception ex)
          {
              Log("Problem with clean up subscription {0}: {1}", subscription.ID, ex);
          }

      }
    }

    protected void CleanupUDRCMetricValues(int idSubscription)
    {
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement(QUOTING_QUERY_FOLDER,
                                                                 Configuration.RemoveRCMetricValuesQueryTag))
        {
          stmt.AddParam("%%ID_SUB%%", idSubscription);
          stmt.ExecuteNonQuery();
        }
      }
    }

    protected void CleanupBackoutUsageData(ArrayList batches)
    {
      Log("Reversing {0} batch(es) associated with this quote", batches.Count);

      IMTBillingReRun rerun = new BillingReRunClient.Client();
      var sessionContext = AdapterManager.GetSuperUserContext(); // log in as super user
      rerun.Login((Interop.MTBillingReRun.IMTSessionContext) sessionContext);
      var comment = String.Format("Quoting functionality; Reversing work associated with QuoteId {0}",
                                  CurrentResponse.idQuote);
      rerun.Setup(comment);

      var pipeline = new PipelineManager();
      try
      {
        // pauses all pipelines so identify isn't chasing a moving target
        pipeline.PauseAllProcessing();

        // identify all batches (ideally we could do this in one call to Identify)
        // instead of doing individual billing reruns per batch (CR12581)
        foreach (string batchID in batches)
        {
          Log("Backingout batch with id {0} associated with this quote", batchID);

          IMTIdentificationFilter filter = rerun.CreateFilter();
          filter.BatchID = batchID;

          // filters on the billing group ID if the billing group ID is set on the context
          // NOTE: it won't be set for scheduled or EOP interval-only adapters)

          // filters on the interval ID if the interval ID is set on the context
          // NOTE: it won't be set for scheduled adapters).  This is important for
          // performance when partitioning is enabled.

          filter.IsIdentifySuspendedTransactions = true;
          filter.IsIdentifyPendingTransactions = true;
          filter.SuspendedInterval = 0;

          rerun.Identify(filter, comment);
        }

        rerun.Analyze(comment);
        rerun.BackoutDelete(comment);
        rerun.Abandon(comment);
      }
      finally
      {
        // always resume processing no matter what!
        pipeline.ResumeAllProcessing();
      }

      Log("Completed backing out batches associated with this quote");

    }

    //public void WriteQuoteAsXML()
    //{

    //}

    protected void Log(string formatString, params object[] args)
    {
      string suppliedMessage = string.Format(formatString, args);

      mLogger.LogDebug("Quote[{0}]: [{1}]", CurrentResponse.idQuote, suppliedMessage);

      var logRecord = new QuoteLogRecord
        {
          QuoteIdentifier = CurrentRequest.QuoteIdentifier,
          DateAdded = MetraTime.Now,
          Message = suppliedMessage
        };

      CurrentResponse.MessageLog.Add(logRecord);

    }

    protected void LogError(string formatString, params object[] args)
    {
      string suppliedMessage = string.Format(formatString, args);

      mLogger.LogError("Quote[{0}]: [{1}]", CurrentResponse.idQuote, suppliedMessage);

      var logRecord = new QuoteLogRecord
        {
          QuoteIdentifier = CurrentRequest.QuoteIdentifier,
          DateAdded = MetraTime.Now,
          Message = suppliedMessage
        };

      CurrentResponse.MessageLog.Add(logRecord);
    }

    #endregion

    #region ProductCatalogHelpers

    private IMTProductCatalog mProductCatalog;

    protected IMTProductCatalog CurrentProductCatalog
    {
      get
      {
        //TODO: Cache this and return pre-initialized one
        Interop.MTProductCatalog.IMTSessionContext sessionContext = GetSessionContextForProductCatalog();

        mProductCatalog = new MTProductCatalogClass();
        mProductCatalog.SetSessionContext(sessionContext);

        return mProductCatalog;
      }
    }

    protected Interop.MTProductCatalog.IMTSessionContext GetSessionContextForProductCatalog()
    {
      //Todo: Fix to read from server access file if we decide to use SuperUser as opposed to user generating quote
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContextClass();
      //ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      //sa.Initialize();
      //ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      const string suName = "su";
      const string suPassword = "su123";
      try
      {
        return (Interop.MTProductCatalog.IMTSessionContext) loginContext.Login(suName, "system_user", suPassword);
      }
      catch (Exception ex)
      {
        throw new Exception("GetSessionContextForProductCatalog: Login failed:" + ex.Message, ex);
      }

    }

    #endregion

    #region Authorization

    public Auth.IMTSessionContext SessionContext { get; set; }

    protected bool UserHasRequiredCapability(string requiredCapabilityName)
    {
      Auth.IMTSecurity security = new Auth.MTSecurity();
      Auth.IMTCompositeCapability requiredCapability =
        security.GetCapabilityTypeByName(requiredCapabilityName).CreateInstance();
      return SessionContext.SecurityContext.CoarseHasAccess(requiredCapability);
    }

    protected void VerifySessionContextIsSet()
    {
      if (SessionContext == null)
      {
        throw new Exception("SessionContext must be set. Unable to authorize user.");
      }
    }

    #endregion
  }
}
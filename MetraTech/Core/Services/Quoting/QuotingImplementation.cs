using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.ServiceModel;
using System.ServiceModel.Security;
using System.Text;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.Core.Services.Quoting.Charge;
using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Debug.Diagnostics;
// TODO: Add auditor to Quote
// using MetraTech.Interop.MTAuditEvents;

namespace MetraTech.Core.Services.Quoting
{
  public class QuotingImplementation : IQuotingImplementation
  {
    public QuotingConfiguration Configuration { get; private set; }
    public QuoteReportingConfiguration ReportingConfiguration { get; private set; }
    // TODO: Add auditor to Quote
    //private Auditor quotingAuditor = new Auditor();
    private static ILogger _log;
    private IChargeMetering _chargeMetering;

    private const string MetratechComFlatrecurringcharge = "metratech.com/flatrecurringcharge";
    private const string MetratechComUdrctapered = "metratech.com/udrctapered";
    private const string MetratechComNonrecurringcharge = "metratech.com/nonrecurringcharge";
    private const string MetratechComUdrctiered = "metratech.com/udrctiered";

    private MTParamTableDefinition parameterTableFlatRc;
    private MTParamTableDefinition parameterTableNonRc;
    private MTParamTableDefinition parameterTableUdrcTapered;
    private MTParamTableDefinition parameterTableUdrcTiered;

    #region Constructors

    public delegate void LoadAccountDelegate(
      AccountIdentifier acct, DateTime timeStamp, out Account account);

    public QuotingImplementation(QuotingConfiguration configuration, Interop.MTAuth.IMTSessionContext sessionContext,
                                 IQuotingRepository quotingRepository, IChargeMetering chargeMetering, ILogger log)
    {
      Init(configuration, sessionContext, quotingRepository, chargeMetering, log);
    }

    private void Init(QuotingConfiguration configuration, Interop.MTAuth.IMTSessionContext sessionContext,
                      IQuotingRepository quotingRepository, IChargeMetering chargeMetering, ILogger log)
    {
      Configuration = configuration;
      ReportingConfiguration = QuoteReportingConfigurationManager.LoadConfiguration(Configuration, false);
      SessionContext = sessionContext;
      QuotingRepository = quotingRepository;
      _chargeMetering = chargeMetering;
      _log = log;
    }

    public QuotingImplementation(QuotingConfiguration configuration, Interop.MTAuth.IMTSessionContext sessionContext,
                                 IQuotingRepository quotingRepository, IChargeMetering chargeMetering)
      : this(
        configuration, sessionContext, quotingRepository, chargeMetering,
        new Logger(String.Format("[{0}]", typeof(QuotingImplementation))))
    {
    }

    private IChargeMetering InitDefaultChragesMetering()
    {
      return new ChargeMetering(Configuration
                                , new List<ICharge>
                                  {
                                    new ReccurringCharge(Configuration, _log),
                                    new NonReccuringCharge(Configuration, _log)
                                  }
                                , _log);
    }

    public QuotingImplementation(QuotingConfiguration configuration, Interop.MTAuth.IMTSessionContext sessionContext,
                                 IQuotingRepository quotingRepository)
    {
      Init(configuration, sessionContext, quotingRepository, null,
           new Logger(String.Format("[{0}]", typeof(QuotingImplementation))));

      _chargeMetering = InitDefaultChragesMetering();
    }

    public QuotingImplementation(QuotingConfiguration configuration, Interop.MTAuth.IMTSessionContext sessionContext) :
      this(configuration, sessionContext, new QuotingRepository())
    {
    }

    public QuotingImplementation(QuotingConfiguration configuration) :
      this(configuration, null)
    {
    }

    public QuotingImplementation() :
      this(QuotingConfigurationManager.LoadConfigurationFromFile(
        Path.Combine(SystemConfig.GetRmpDir(), "config", "Quoting", "QuotingConfiguration.xml")), null)
    {
    }

    #endregion Constructors

    #region Public

    public IQuotingRepository QuotingRepository { get; private set; }

    /// <summary>
    /// Validate request, prepare data for metering and finaly creats quote
    /// </summary>
    /// <param name="quoteRequest"></param>
    /// <returns>QuoteResponse</returns>
    public QuoteResponse CreateQuote(QuoteRequest quoteRequest)
    {
      //TODO: Should we add check that pipeline/inetinfo/activityservices are running before starting quote. We think nice to have and maybe configurable
      using (new HighResolutionTimer(MethodInfo.GetCurrentMethod().Name))
      {
        QuoteResponse response = null;
        try
        {
          try
          {
            response = new QuoteResponse(quoteRequest);

            response.MessageLog = SetNewQuoteLogFormater(response.Artefacts);

            ValidateRequest(quoteRequest);
            response.Status = QuoteStatus.InProgress;

            //Add this quote into repository and gets a newly creatd quote id
            response.IdQuote = QuotingRepository.CreateQuote(quoteRequest, SessionContext, Configuration);

            //If we need here, here is the place for things that need to be generated, totaled, etc. before we
            //generate PDF and return results
            CreateAndCalculateQuote(quoteRequest, response);

            QuotePDFReport quotePDFReport = null;
            if (quoteRequest.ReportParameters.PDFReport)
            {
              quotePDFReport = new QuotePDFReport(QuoteReportingConfigurationManager.LoadConfiguration(Configuration));
              response.ReportLink = quotePDFReport.GetPdfReportLink(response.IdQuote, quoteRequest.Accounts.First());
            }

            response.Status = QuoteStatus.Complete;
            response = QuotingRepository.UpdateQuoteWithResponse(response);
            QuotingRepository.SaveQuoteLog(response.MessageLog);

            if (quoteRequest.ReportParameters.PDFReport)
            {
              AsyncGeneratePDFForCurrentQuote asynCall = GeneratePdfForCurrentQuote;
              asynCall.BeginInvoke(quoteRequest, response, quotePDFReport, null, null);
            }
          }
          finally
          {
            if (response == null)
              response = new QuoteResponse();
          }
        }
        catch (Exception ex)
        {
          if (ex is AddChargeMeteringException)
          {
            // always saves chrages in case exception was occured
            response.Artefacts.ChargesCollection.AddRange(((AddChargeMeteringException)ex).ChargeDataCollection);
          }

          response.Status = QuoteStatus.Failed;
          response.FailedMessage = ex.GetaAllMessages();

          if (response.IsInitialized())
          {
            _log.LogError("Current quote failed and being cleaned up: {0}", ex);
            response = QuotingRepository.UpdateQuoteWithErrorResponse(response.IdQuote, response,
                                                                      ex.Message);
          }

          throw new QuoteException(response, ex.Message, ex);
        }
        finally
        {
          if (response.IsInitialized())
          {
            if (Configuration.IsCleanupQuoteAutomaticaly)
            {
              Cleanup(response.Artefacts);
            }
            else
            {
              _log.LogWarning("Not cleaning up subsciption (includes group) and usage data for quote");
            }
          }

          _log.ClearFormatter();
        }

        if (quoteRequest.ShowQuoteArtefacts == false)
          response.Artefacts = null;

        return response;
      }
    }

    private List<QuoteLogRecord> SetNewQuoteLogFormater(QuoteResponseArtefacts quoteArtefacts)
    {
      List<QuoteLogRecord> messageLog = new List<QuoteLogRecord>();

      _log.SetFormatter((message, args) =>
        {
          string newFormater
            = String.Format("Quote[{0}]: [{1}]", quoteArtefacts.IdQuote, String.Format(message, args));

          messageLog.Add(new QuoteLogRecord
            {
              QuoteIdentifier = quoteArtefacts.QuoteIdentifier,
              DateAdded = MetraTime.Now,
              Message = message
            });

          return newFormater;
        });

      return messageLog;
    }

    #endregion

    #region Internal

    #region Validation

    /// <summary>
    /// Method that validates/sanity checks the request and throws exceptions if there are errors
    /// </summary>
    /// <param name="request">QuoteRequest to be checked</param>
    /// <exception cref="ArgumentException"></exception>
    protected void ValidateRequest(QuoteRequest request)
    {
      //TODO: Simple validation should be moved to QuoteRequest class
      using (new Debug.Diagnostics.HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        if (request.SubscriptionParameters.IsGroupSubscription && request.IcbPrices.Count > 0)
        {
          throw new ArgumentException("Current limitation of quoting: ICBs are applied only for individual subscriptions");
        }

        FirstMajorValidation(request);

        ValidateEffectiveDate(request);

        ValidateAccount(request);

        ValidateProducOffering(request);

        ValidateICBs(request);
      }
    }

    private static void FirstMajorValidation(QuoteRequest request)
    {
      //At least one po must be specified since we only do RCs and NRCs currently; in the future this won't be a restriction
      if (request.ProductOfferings == null
          || request.ProductOfferings.Count == 0)
        throw new ArgumentException(
          "At least one product offering must be specified for the quote as quoting currently only quotes for RCs and NRC"
          , PropertyName<QuoteRequest>.GetPropertyName(p => p.ProductOfferings));


      if (request.SubscriptionParameters == null)
        throw new ArgumentException(
          "Subcriptions should be set for Quoting");

      if (request.Accounts == null)
        // Accounts can be null in case creates Quoting with Group subscription
        request.Accounts = new List<int>();

      if (request.IcbPrices == null)
        request.IcbPrices = new List<IndividualPrice>();

    }

    private void ValidateAccount(QuoteRequest request)
    {
      //0 values Request validation
      if (request.Accounts.Contains(0))
      {
        throw new ArgumentException("Accounts with id = 0 is invalid");
      }

      //At least one account must be specified
      if (request.SubscriptionParameters.IsGroupSubscription == false
          && request.Accounts.Count == 0)
      {
        throw new ArgumentException("At least one account must be specified for the quote"
                                    , PropertyName<QuoteRequest>.GetPropertyName(p => p.Accounts));
      }

      if (request.SubscriptionParameters.IsGroupSubscription)
      {
        if (request.SubscriptionParameters.CorporateAccountId <= 0)
          throw new ArgumentException(
            "Corporate Account does not set for Group Subscription. Corporate Account is mandatory for Group subscription");
        if (!request.Accounts.Contains(request.SubscriptionParameters.CorporateAccountId))
          throw new ArgumentException("Corporate Account should be in set of accounts to quote for.");
      }
      else
      {
        // Ensure that all accounts are in the same billing cycle
        var first = GetAccountBillingCycle(request.Accounts.First());
        if (!(request.Accounts.All(e => GetAccountBillingCycle(e) == first)))
        {
          throw new ArgumentException("All accounts must be in the same billing cycle"
                                      , PropertyName<QuoteRequest>.GetPropertyName(p => p.Accounts));
        }
      }

      // Ensure that all payers are in the quote request
      var idPayers = request.Accounts.Select(e => GetAccountPayer(e));
      if (!idPayers.All(e => request.Accounts.Contains(e)))
      {
        throw new ArgumentException("All account payers must be included in the quote request"
                                    , PropertyName<QuoteRequest>.GetPropertyName(p => p.Accounts));
      }
    }

    private void ValidateProducOffering(QuoteRequest request)
    {

      if (request.ProductOfferings.Contains(0))
      {
        throw new ArgumentException("PO with id = 0 is invalid");
      }

      foreach (var po in request.ProductOfferings)
        ValidateUDRCMetrics(request.SubscriptionParameters.UDRCValues, po);
    }

    private static void ValidateEffectiveDate(QuoteRequest request)
    {
      // Sets time 00:00:00 for Start date
      request.EffectiveDate = new DateTime(
        request.EffectiveDate.Year,
        request.EffectiveDate.Month,
        request.EffectiveDate.Day,
        0, 0, 0);

      // Sets time 23:59:59 for End date
      request.EffectiveEndDate = new DateTime(
        request.EffectiveEndDate.Year,
        request.EffectiveEndDate.Month,
        request.EffectiveEndDate.Day,
        23, 59, 59);


      DateTime currentDate = MetraTime.Now.Date;
      if (request.EffectiveDate.Date < currentDate)
      {
        string propertyName = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveDate);
        throw new ArgumentException(
          String.Format("'{0}'='{1}' can't be less than current time '{2}'", propertyName,
                        request.EffectiveDate, currentDate), propertyName);
      }

      //EffectiveDate must be set
      if (request.EffectiveDate == DateTime.MinValue)
      {
        string propertyName = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveDate);
        throw new ArgumentException(String.Format("'{0}' must be specified", propertyName), propertyName);
      }

      if (request.EffectiveEndDate < request.EffectiveDate)
      {
        string propertyStartDate = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveDate);
        string propertyEndDate = PropertyName<QuoteRequest>.GetPropertyName(p => p.EffectiveEndDate);
        throw new ArgumentException(
          String.Format(
            "The Start date can not be greater than End date. Start date '{0}'='{1}' > End date '{2}'='{3}'"
            , propertyStartDate, request.EffectiveDate
            , propertyEndDate, request.EffectiveEndDate)
          , propertyEndDate);
      }
    }

    private static void ValidateICBs(QuoteRequest request)
    {
      if (request.SubscriptionParameters.UDRCValues.Any(i => i.Key == ""))
      {
        throw new ArgumentException("Invalid UDRC metrics");
      }


      foreach (var icb in request.IcbPrices)
      {
        switch (icb.CurrentChargeType)
        {
          case ChargeType.UDRCTapered:
            if ((icb.ChargesRates.First().UnitAmount == 0) &&
                (icb.ChargesRates.First().UnitValue == 0))
              throw new ArgumentException("Invalid ICBs");
            break;
          case ChargeType.UDRCTiered:
            if ((icb.ChargesRates.First().UnitAmount == 0) &&
                (icb.ChargesRates.First().UnitValue == 0) &&
                (icb.ChargesRates.First().BaseAmount == 0))
              throw new ArgumentException("Invalid ICBs");
            break;
          default:
            if (icb.ChargesRates.First().Price == 0)
              throw new ArgumentException("Invalid ICBs");
            break;
        }
      }
    }

    private void ValidateUDRCMetrics(Dictionary<string, List<UDRCInstanceValueBase>> udrcMetrics, int poId)
    {
      var po = CurrentProductCatalog.GetProductOffering(poId);
      IMTCollection pis = po.GetPriceableItems();
      foreach (IMTPriceableItem pi in pis)
      {
        if (pi.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
        {
          List<UDRCInstanceValueBase> udrcMetricsForPo;
          if (udrcMetrics.TryGetValue(poId.ToString(), out udrcMetricsForPo))
            if (udrcMetricsForPo.All(udrcMetric => udrcMetric.UDRC_Id != pi.ID))
            {
              throw new ArgumentException(String.Format("UDRC metrics not specified properly for PI {0}", pi.ID));
            }
        }
      }
    }

    #endregion Validation

    protected int GetAccountPayer(int idAccount)
    {
      int payer;

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement(Configuration.QuotingQueryFolder,
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

    private delegate void AsyncGeneratePDFForCurrentQuote(QuoteRequest request, QuoteResponse response, QuotePDFReport quotePdfReport);

    protected void GeneratePdfForCurrentQuote(QuoteRequest request, QuoteResponse response, QuotePDFReport quotePdfReport = null)
    {
      using (new HighResolutionTimer("GeneratePDFForCurrentQuote"))
      {
        if (quotePdfReport == null)
          quotePdfReport = new QuotePDFReport(ReportingConfiguration);

        //If request does not specify a template to use, then use the configured default
        if (string.IsNullOrEmpty(request.ReportParameters.ReportTemplateName))
        {
          request.ReportParameters.ReportTemplateName = this.Configuration.ReportDefaultTemplateName;
        }

        QuotingRepository.UpdateStatus(response.IdQuote, ActionStatus.StatusReport, QuoteStatus.InProgress);

        try
        {
          response.ReportLink = quotePdfReport.CreatePdfReport(response.IdQuote,
                                                             request.Accounts[0],
                                                             request.ReportParameters.ReportTemplateName,
                                                             GetLanguageCodeIdForCurrentRequest(request));
          QuotingRepository.UpdateStatus(response.IdQuote, ActionStatus.StatusReport, QuoteStatus.Complete);
        }
        catch
        {
          QuotingRepository.UpdateStatus(response.IdQuote, ActionStatus.StatusReport, QuoteStatus.Failed);   
          throw;
        }
      }
    }

    protected int GetLanguageCodeIdForCurrentRequest(QuoteRequest request)
    {
      //Not specified, default to "en-US"
      //temp = "en-US";
      int langCode = 840;
      //TODO: Sort out using cultures for real and match them against either enum or database
      if (!string.IsNullOrEmpty(request.Localization))
      {
        //Step 1: Try if this is int, then must have passed language id itself
        if (int.TryParse(request.Localization, out langCode))
        {
          return langCode;
        }

        //Step 2: Convert/lookup culture to database id (i.e. "en-US" = 840)
        //For now, until we have time, hard code the existing list but won't be extensible
        //Can't believe I've been reduced to this kind of code; feel dirty with the only solice that a 
        //story is in the backlog to be prioritized
        switch (request.Localization.ToLower())
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
      }

      _log.LogWarning(
        "Unable to convert culture of {0} to MetraTech language code database id; using 840 for 'en-US'",
        request.Localization);

      return langCode;

    }

    protected int GetPrimaryAccountId(QuoteRequest requset)
    {
      //For now, assume that the first account specified for the quote is the 'primary'
      //In the future, may pass a specific parameter
      if (requset.Accounts.Count == 0)
        throw new ArgumentException("Must specify accounts");

      return requset.Accounts[0];
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

    //TODO: Should be refacored. It should be in seperate class
    protected void CreateNeededSubscriptions(QuoteRequest request, QuoteResponse response)
    {
      #region Check and turn off InstantRCs if needed

      bool instantRCsEnabled;
      //Check and turn off InstantRCs
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateAdapterStatement(@"Queries\ProductCatalog", "__GET_INSTANTRC_VALUE__"))
        using (var reader = stmt.ExecuteReader())
        {
          if (reader.Read())
          {
            instantRCsEnabled = reader.GetBoolean("InstantRCValue");
          }
          else
          {
            throw new ApplicationException("Unable to retrieve InstantRC setting");
          }
        }

        if (instantRCsEnabled)
          using (var stmt = conn.CreateStatement(GetQueryToUpdateInstantRCConfigurationValue(false)))
            stmt.ExecuteNonQuery();
      }

      #endregion

      GetParamTables(request);

      if (Configuration.IsAllowedUseActivityService)
      {
        if (request.SubscriptionParameters.IsGroupSubscription)
          CreateAllGroupSubscriptionForQuoteByService(request, response);
        else
          CreateAllSubscriptionForQuoteByService(request, response);
      }
      else
        using (var scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                EnterpriseServicesInteropOption.Full))
        {
          if (request.SubscriptionParameters.IsGroupSubscription)
            CreateGroupSubscriptionForQuote(request, response);
          else
            CreateAllSubscriptionForQuote(request, response);
          scope.Complete();
        }

      #region Turn InstantRCs back on

      if (!instantRCsEnabled) return;

      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateStatement(GetQueryToUpdateInstantRCConfigurationValue(instantRCsEnabled)))
        stmt.ExecuteNonQuery();

      #endregion
    }

    private void GetParamTables(QuoteRequest request)
    {
      if (request.IcbPrices != null && request.IcbPrices.Count > 0)
      {
        parameterTableFlatRc = CurrentProductCatalog.GetParamTableDefinitionByName(MetratechComFlatrecurringcharge);
        parameterTableNonRc = CurrentProductCatalog.GetParamTableDefinitionByName(MetratechComNonrecurringcharge);
        parameterTableUdrcTapered = CurrentProductCatalog.GetParamTableDefinitionByName(MetratechComUdrctapered);
        parameterTableUdrcTiered = CurrentProductCatalog.GetParamTableDefinitionByName(MetratechComUdrctiered);
      }
    }

    /// <summary>
    /// Create Group Subscription and add its ID into createdGroupSubsciptions
    /// </summary>
    /// <param name="request"><see cref="QuoteRequest"/></param>
    /// <param name="response"><see cref="QuoteResponse"/></param>
    /// /// <remarks>Should be run in one transaction with the same call for all POs in QuoteRequest</remarks>
    private void CreateGroupSubscriptionForQuote(QuoteRequest request, QuoteResponse response)
    {
      var effectiveDate = new MTPCTimeSpanClass
        {
          StartDate = request.EffectiveDate,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE,
          EndDate = request.EffectiveEndDate,
          EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };

      foreach (var offerId in request.ProductOfferings)
      {
        IMTGroupSubscription mtGroupSubscription = CurrentProductCatalog.CreateGroupSubscription();
        mtGroupSubscription.EffectiveDate = effectiveDate;
        mtGroupSubscription.ProductOfferingID = offerId;
        mtGroupSubscription.ProportionalDistribution = true; //Part of request?
        //if (!groupSubscription.ProportionalDistribution)
        //{
        //  mtGroupSubscription.DistributionAccount = groupSubscription.DiscountAccountId.Value;
        //}
        mtGroupSubscription.Name = string.Format("TempQuoteGSForPO_{0}Quote_{1}", offerId,
                                                 response.IdQuote);
        mtGroupSubscription.Description = "Group subscription for Quoting. ProductOffering: " + offerId;
        mtGroupSubscription.SupportGroupOps = true; // Part of request?
        mtGroupSubscription.CorporateAccount = request.SubscriptionParameters.CorporateAccountId;
        mtGroupSubscription.Cycle = GetAccountBillingCycleAllData(request.SubscriptionParameters.CorporateAccountId);

        foreach (MTPriceableItem pi in CurrentProductCatalog.GetProductOffering(offerId).GetPriceableItems())
        {
          switch (pi.Kind)
          {
            case MTPCEntityType.PCENTITY_TYPE_RECURRING:
              mtGroupSubscription.SetChargeAccount(pi.ID, request.SubscriptionParameters.CorporateAccountId,
                                                   request.EffectiveDate, request.EffectiveEndDate);
              break;
            case MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
              mtGroupSubscription.SetChargeAccount(pi.ID, request.SubscriptionParameters.CorporateAccountId,
                                                   request.EffectiveDate, request.EffectiveEndDate);
              try
              {
                if (request.SubscriptionParameters.UDRCValues.ContainsKey(offerId.ToString()))
                {
                  foreach (var udrcInstanceValue in request.SubscriptionParameters.UDRCValues[offerId.ToString()])
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
                  _log.LogError(come.Message);
                  throw new ArgumentException("Subscription failed with message: " + come.Message +
                                              "\nUDRC ID added to SubscriptionParameters does not exist");
                }
                throw;
              }
              break;
          }
        }

        mtGroupSubscription.Save();
        List<int> accountIds = new List<int>();

        // add subscription to Quote Artefact
        response.Artefacts.Subscription.AddSubscriptions(mtGroupSubscription.GroupID, accountIds);

        foreach (var mtGsubMember in request.Accounts.Select(id => GetSubMember(id, request)))
        {
          mtGroupSubscription.AddAccount(mtGsubMember);
          accountIds.Add(mtGsubMember.AccountID);
        }
        mtGroupSubscription.Save();
      }
    }

    #region Account Billing Cycle

    private delegate T AdditionalMethod<T>(MTUsageCycleType cyclyType, IMTDataReader rowset);

    private T GetAccountBillingCycle<T>(int idAccount, AdditionalMethod<T> additionalMethod)
    {
      using (var conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (
          var stmt = conn.CreateAdapterStatement(Configuration.QuotingQueryFolder,
                                                 Configuration.GetAccountBillingCycleQueryTag))
        {
          stmt.AddParam("%%ACCOUNT_ID%%", idAccount);
          using (var rowset = stmt.ExecuteReader())
          {
            if (!rowset.Read() || rowset.IsDBNull("AccountCycleType"))
              throw new SqlNullValueException(string.Format("The account {0} has no billing cycle", idAccount));

            MTUsageCycleType cyclyType = (MTUsageCycleType)Enum.ToObject(typeof(MTUsageCycleType)
                                                                          , rowset.GetInt32("AccountCycleType"));

            return additionalMethod(cyclyType, rowset);
          }
        }
      }
    }

    protected MTUsageCycleType GetAccountBillingCycle(int idAccount)
    {
      return GetAccountBillingCycle(idAccount, (cyclyType, rowset) => { return cyclyType; });
    }

    /// <summary>
    /// Creates <see cref="MTPCCycle"/> for group subscription by Corporate account.
    /// The basic scenarios were taken from <see cref="MetraTech.DomainModel.Validators.AccountValidator.ValidateUsageCycle"/>
    /// </summary>
    /// <param name="idAccount"></param>
    /// <returns></returns>
    protected MTPCCycle GetAccountBillingCycleAllData(int idAccount)
    {
      AdditionalMethod<MTPCCycle> additionalMethod = (cyclyType, rowset) =>
        {
          MTPCCycle result = new MTPCCycleClass();

          result.CycleTypeID = (int)cyclyType;
          result.EndDayOfMonth = rowset.IsDBNull("DayOfMonth") ? 0 : rowset.GetInt32("DayOfMonth");
          result.EndDayOfMonth2 = rowset.IsDBNull("SecondDayOfMonth") ? 0 : rowset.GetInt32("SecondDayOfMonth");
          result.EndDayOfWeek = rowset.IsDBNull("DayOfWeek") ? 0 : rowset.GetInt32("DayOfWeek");
          result.StartDay = rowset.IsDBNull("StartDay") ? 0 : rowset.GetInt32("StartDay");
          result.StartMonth = rowset.IsDBNull("StartMonth") ? 0 : rowset.GetInt32("StartMonth");
          result.StartYear = rowset.IsDBNull("StartYear") ? 0 : rowset.GetInt32("StartYear");

          if (MTUsageCycleType.SEMIMONTHLY_CYCLE == cyclyType)
            result.EndDayOfMonth = rowset.IsDBNull("FirstDayOfMonth") ? 0 : rowset.GetInt32("FirstDayOfMonth");

          _log.LogDebug(
            "Retrived Cycle from account={0}: CycleTypeID={1}; EndDayOfMonth={2}; EndDayOfMonth2={3}; EndDayOfWeek={4}; StartDay={5}; StartMonth={6}; StartYear={7}",
            idAccount, cyclyType, result.EndDayOfMonth, result.EndDayOfMonth2, result.EndDayOfWeek, result.StartDay,
            result.StartMonth, result.StartYear);

          return result;
        };

      return GetAccountBillingCycle(idAccount, additionalMethod);
    }

    /// <summary>
    /// Creates <see cref="MTPCCycle"/> for group subscription by Corporate account.
    /// The basic scenarios were taken from <see cref="MetraTech.DomainModel.Validators.AccountValidator.ValidateUsageCycle"/>
    /// </summary>
    /// <param name="idAccount"></param>
    /// <returns></returns>
    protected Cycle CreateCycleByAccount(int idAccount)
    {
      AdditionalMethod<Cycle> additionalMethod = (cyclyType, rowset) =>
        {
          Cycle result = new Cycle();

          result.CycleType = ConvertMTUsageCycleToUsageCycle(cyclyType);

          if (!rowset.IsDBNull("DayOfMonth"))
            result.DayOfMonth = rowset.GetInt32("DayOfMonth");

          if (!rowset.IsDBNull("FirstDayOfMonth"))
            result.FirstDayOfMonth = rowset.GetInt32("FirstDayOfMonth");

          if (!rowset.IsDBNull("SecondDayOfMonth"))
            result.SecondDayOfMonth = rowset.GetInt32("SecondDayOfMonth");

          if (!rowset.IsDBNull("DayOfWeek"))
            result.DayOfWeek = (DayOfTheWeek)Enum.ToObject(typeof(DayOfTheWeek), rowset.GetInt32("DayOfWeek"));

          if (!rowset.IsDBNull("StartDay"))
            result.StartDay = rowset.GetInt32("StartDay");

          if (!rowset.IsDBNull("StartMonth"))
            result.StartMonth = (MonthOfTheYear)Enum.ToObject(typeof(MonthOfTheYear), rowset.GetInt32("StartMonth"));

          if (!rowset.IsDBNull("StartYear"))
            result.StartYear = rowset.GetInt32("StartYear");

          if (MTUsageCycleType.SEMIMONTHLY_CYCLE == cyclyType)
            result.FirstDayOfMonth = rowset.IsDBNull("FirstDayOfMonth") ? 0 : rowset.GetInt32("FirstDayOfMonth");

          _log.LogDebug(@"Retrived Cycle from account={0}: CycleTypeID={1}; DayOfMonth={2}; FirstDayOfMonth={3}; SecondDayOfMonth={4} DayOfWeek={5}; StartDay={6}; StartMonth={7}; StartYear={8}",
                        idAccount, cyclyType, result.DayOfMonth, result.FirstDayOfMonth, result.SecondDayOfMonth, result.DayOfWeek, result.StartDay, result.StartMonth, result.StartYear);

          return result;
        };

      return GetAccountBillingCycle(idAccount, additionalMethod);
    }

    private UsageCycleType ConvertMTUsageCycleToUsageCycle(MTUsageCycleType mtCycle)
    {
      switch (mtCycle)
      {
        case MTUsageCycleType.MONTHLY_CYCLE:
          return UsageCycleType.Monthly;

        case MTUsageCycleType.DAILY_CYCLE:
          return UsageCycleType.Daily;

        case MTUsageCycleType.WEEKLY_CYCLE:
          return UsageCycleType.Weekly;

        case MTUsageCycleType.BIWEEKLY_CYCLE:
          return UsageCycleType.Bi_weekly;

        case MTUsageCycleType.SEMIMONTHLY_CYCLE:
          return UsageCycleType.Semi_monthly;

        case MTUsageCycleType.QUARTERLY_CYCLE:
          return UsageCycleType.Quarterly;

        case MTUsageCycleType.ANNUALLY_CYCLE:
          return UsageCycleType.Annually;

        case MTUsageCycleType.SEMIANNUALLY_CYCLE:
          return UsageCycleType.Semi_Annually;

        default:
          throw new NotSupportedException(
            String.Format("Cna't convert enum {0} with value {1} to {2}, because {2} does not hvae equal variant."
                          , typeof(MTUsageCycleType), mtCycle, typeof(UsageCycleType)));
      }
    }

    #endregion Account Billing Cycle

    private static MTGSubMember GetSubMember(int accountId, QuoteRequest quoteRequest)
    {
      return new MTGSubMember
        {
          AccountID = accountId,
          StartDate = quoteRequest.EffectiveDate,
          EndDate = quoteRequest.EffectiveEndDate
        };
    }

    private Dictionary<string, List<UDRCInstanceValue>> ConvertUDRCCollection(IEnumerable<UDRCInstanceValueBase> value)
    {
      var res = new Dictionary<string, List<UDRCInstanceValue>>(0);
      foreach (var item in value)
      {
        if (!res.ContainsKey(item.UDRC_Id.ToString()))
        {
          var list = new List<UDRCInstanceValue>(0)
            {
              new UDRCInstanceValue
                {
                  EndDate = item.EndDate,
                  ExtensionData = item.ExtensionData,
                  StartDate = item.StartDate,
                  UDRC_Id = item.UDRC_Id,
                  Value = item.Value
                }
            };
          res.Add(item.UDRC_Id.ToString(), list);
        }
        else
          res[item.UDRC_Id.ToString()].Add(
            new UDRCInstanceValue
              {
                EndDate = item.EndDate,
                ExtensionData = item.ExtensionData,
                StartDate = item.StartDate,
                UDRC_Id = item.UDRC_Id,
                Value = item.Value
              });
      }
      return res;
    }

    #region Using MAS for subscription

    private WSHttpBinding GetBinding()
    {
      var binding = new WSHttpBinding()
        {
          Security =
            {
              Mode = SecurityMode.Message,
              Message =
                {
                  ClientCredentialType = MessageCredentialType.UserName,
                  NegotiateServiceCredential = true,
                  EstablishSecurityContext = true,
                  AlgorithmSuite = SecurityAlgorithmSuite.Default
                }
            },
          BypassProxyOnLocal = false,
          TransactionFlow = false,
          HostNameComparisonMode = HostNameComparisonMode.StrongWildcard,
          MessageEncoding = WSMessageEncoding.Text,
          TextEncoding = Encoding.UTF8,
          UseDefaultWebProxy = true,
          AllowCookies = false,
          OpenTimeout = new TimeSpan(0, 3, 0),
          CloseTimeout = new TimeSpan(0, 3, 0),
          SendTimeout = new TimeSpan(0, 3, 0),
          ReceiveTimeout = new TimeSpan(0, 10, 0),
          MaxReceivedMessageSize = int.MaxValue
        };
      return binding;
    }

    private EndpointAddress GetEndpoint(string gateway, int port, string serviceName)
    {
      var uri = new Uri(String.Format(CultureInfo.InvariantCulture,
                                      @"http://{0}:{1}/{2}"
                                      , gateway
                                      , port
                                      , serviceName));
      DnsEndpointIdentity identity = new DnsEndpointIdentity("ActivityServicesCert");
      var endpoint = new EndpointAddress(uri, identity);
      return endpoint;
    }

    /// <summary>
    /// Create Individual Subscription, apply ICBs and add its ID into CreatedSubscription
    /// </summary>
    /// <param name="response"></param>
    /// <param name="request"></param>
    /// <remarks>Should be run in one transaction with the same call for all accounts and POs in QuoteRequest</remarks>
    /// <returns>newly created id subscription</returns>
    private void CreateAllSubscriptionForQuoteByService(QuoteRequest request, QuoteResponse response)
    {
      var subService = new SubscriptionService(SessionContext);

      var productTimeSpan = new ProdCatTimeSpan
        {
          StartDate = request.EffectiveDate,
          StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
          EndDate = request.EffectiveEndDate,
          EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
        };

      foreach (var idAccount in request.Accounts)
      {

        foreach (int po in request.ProductOfferings)
        {
          var sub = new Subscription { ProductOfferingId = po, SubscriptionSpan = productTimeSpan };

          if (request.SubscriptionParameters.UDRCValues.ContainsKey(po.ToString(CultureInfo.InvariantCulture)))
          {
            sub.UDRCValues =
              ConvertUDRCCollection(
                request.SubscriptionParameters.UDRCValues[po.ToString(CultureInfo.InvariantCulture)]);
          }

          subService.AddSubscription(new AccountIdentifier(idAccount), ref sub);

          if (sub.SubscriptionId != null)
          {
            response.Artefacts.Subscription.AddSubscriptions((int)sub.SubscriptionId,
                                                             new List<int> { idAccount });

            ApplyIcbPricesToSubscription(request, sub.ProductOfferingId, (int)sub.SubscriptionId);
          }
        }
      }
    }

    /// <summary>
    /// Create Group Subscription for all products, WITHOUT applying ICBs (Currently is NOT supported) 
    /// </summary> 
    /// <param name="response"></param>
    /// <param name="request"></param>
    /// <remarks>Should be run in one transaction with the same call for all accounts and POs in QuoteRequest</remarks>
    private void CreateAllGroupSubscriptionForQuoteByService(QuoteRequest request, QuoteResponse response)
    {
      var groupSubService = new GroupSubscriptionService(SessionContext);
      var subService = new SubscriptionService(SessionContext);

      var subscriptionSpan = new ProdCatTimeSpan
        {
          StartDate = request.EffectiveDate,
          StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
          EndDate = request.EffectiveEndDate,
          EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
        };

      foreach (var offerId in request.ProductOfferings)
      {
        var grpSub = new GroupSubscription
          {
            SubscriptionSpan = subscriptionSpan,
            ProductOfferingId = offerId,
            ProportionalDistribution = true,
            Name = string.Format("TempQuoteGSForPO_{0}Quote_{1}", offerId, response.IdQuote),
            Description = "Group subscription for Quoting. ProductOffering: " + offerId,
            SupportsGroupOperations = true,
            CorporateAccountId = request.SubscriptionParameters.CorporateAccountId,
            Cycle = CreateCycleByAccount(request.SubscriptionParameters.CorporateAccountId)
          };

        #region Create UDRCInstanceValue's

        List<UDRCInstance> udrcInstances;
        subService.GetUDRCInstancesForPO(offerId, out udrcInstances);

        foreach (var udrcInstance in udrcInstances.Where(udrcInstance => !udrcInstance.ChargePerParticipant))
        {
          udrcInstance.ChargeAccountId = grpSub.CorporateAccountId;
          udrcInstance.ChargeAccountSpan = subscriptionSpan;
        }

        // Set the UDRCValues and UDRCInstances
        if (request.SubscriptionParameters.UDRCValues.Count > 0
            &&
            request.SubscriptionParameters.UDRCValues.ContainsKey(offerId.ToString(CultureInfo.InvariantCulture)))
        {
          grpSub.UDRCValues =
            ConvertUDRCCollection(
              request.SubscriptionParameters.UDRCValues[offerId.ToString(CultureInfo.InvariantCulture)]);
        }
        grpSub.UDRCInstances = udrcInstances;

        #endregion

        #region Set Flat Rate Recurring Charge Accounts

        List<FlatRateRecurringChargeInstance> flatRateRecurringChargeInstances;
        groupSubService.GetFlatRateRecurringChargeInstancesForPO(offerId, out flatRateRecurringChargeInstances);


        foreach (
          var flatRateRC in
            flatRateRecurringChargeInstances.Where(flatRateRC => !flatRateRC.ChargePerParticipant))
        {
          flatRateRC.ChargeAccountId = grpSub.CorporateAccountId;
          flatRateRC.ChargeAccountSpan = subscriptionSpan;
        }

        grpSub.FlatRateRecurringChargeInstances = flatRateRecurringChargeInstances;

        #endregion

        grpSub.Members = new MTList<GroupSubscriptionMember>();

        groupSubService.AddGroupSubscription(ref grpSub);
        // add subscription to Quote Artefact
        if (!grpSub.GroupId.HasValue)
          throw new NullReferenceException(
            String.Format("The GroupSubacription was created(Name={0}), but GroupId is null.",
                          grpSub.Name));

        response.Artefacts.Subscription.AddSubscriptions(grpSub.GroupId.Value, request.Accounts);
        var accountIds = new List<int>();
        foreach (var accountId in request.Accounts)
        {
          var gSubMember = new GroupSubscriptionMember
          {
            AccountId = accountId,
            MembershipSpan = subscriptionSpan
          };
          //grpSub.Members.Items.Add(gSubMember);
          groupSubService.AddMembersToGroupSubscription(grpSub.GroupId.Value, new List<GroupSubscriptionMember>() { gSubMember });
          accountIds.Add(accountId);
        }
      }
    }


    #endregion Using MAS for subscription

    /// <summary>
    /// Create Individual Subscription, apply ICBs and add its ID into CreatedSubscription
    /// </summary>
    /// <param name="response"><see cref="QuoteRequest"/></param>
    /// <param name="request"><see cref="QuoteResponse"/></param>
    /// <remarks>Should be run in one transaction with the same call for all accounts and POs in QuoteRequest</remarks>
    /// <returns>newly created id subscription</returns>
    private void CreateAllSubscriptionForQuote(QuoteRequest request, QuoteResponse response)
    {
      var effDate = new MTPCTimeSpanClass
        {
          StartDate = request.EffectiveDate,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE,
          EndDate = request.EffectiveEndDate,
          EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };

      object modifiedDate = null;

      foreach (var idAccount in request.Accounts)
      {
        var acc = CurrentProductCatalog.GetAccount(idAccount);
        foreach (int po in request.ProductOfferings)
        {
          var subscription = acc.Subscribe(po, effDate, out modifiedDate);

          response.Artefacts.Subscription.AddSubscriptions(subscription.ID, new List<int> { acc.AccountID });

          try
          {
            if (request.SubscriptionParameters.UDRCValues.ContainsKey(po.ToString()))
            {
              foreach (
                var udrcInstanceValue in
                  request.SubscriptionParameters.UDRCValues[po.ToString()])
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
              _log.LogError(come.Message);
              throw new ArgumentException("Subscription failed with message: " + come.Message +
                                          "\nUDRC ID added to SubscriptionParameters does not exist");
            }

            throw;
          }

          subscription.Save();

          ApplyIcbPricesToSubscription(request, subscription.ProductOfferingID, subscription.ID);

        }
      }
    }

    /// <summary>
    /// Converts <see cref="MTPCEntityType"/> to <see cref="ChargeType"/>
    /// </summary>
    /// <param name="entityType"><see cref="MTPCEntityType"/></param>
    /// <returns>converted type. If reurns<see cref="ChargeType.None"/>that means that egual were not found </returns>
    private static ChargeType ConvertEtityTypeToChargeType(MTPCEntityType entityType)
    {
      switch (entityType)
      {
        case MTPCEntityType.PCENTITY_TYPE_RECURRING:
          return ChargeType.RecurringCharge;

        case MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
          return ChargeType.UDRCTapered;

        case MTPCEntityType.PCENTITY_TYPE_NON_RECURRING:
          return ChargeType.NonRecurringCharge;

        default:
          return ChargeType.None;
      }
    }

    private void ApplyIcbPricesToSubscription(QuoteRequest request, int productOfferingId, int subscriptionId)
    {
      if (request.IcbPrices.Count == 0) return;

      var po = CurrentProductCatalog.GetProductOffering(productOfferingId);
      IMTCollection pis = po.GetPriceableItems();

      foreach (IMTPriceableItem pi in pis)
      {
        var icbPrices = GetIcbPrices(request, productOfferingId, ConvertEtityTypeToChargeType(pi.Kind), null);
        var icbPricesWithPI = GetIcbPrices(request, productOfferingId, ConvertEtityTypeToChargeType(pi.Kind), pi.ID);

        //Can't sorted out that UDRCs is Tiered or Tappered
        List<BaseRateSchedule> rs;
        int ptId = 0;
        try
        {
          rs = GetRateSchedules(icbPrices, ref ptId);
          rs.AddRange(GetRateSchedules(icbPricesWithPI, ref ptId));

          Application.ProductManagement.PriceListService.SaveRateSchedulesForSubscription(
            subscriptionId,
            new PCIdentifier(pi.ID),
            new PCIdentifier(ptId),
            rs,
            _log,
            SessionContext);

        }
        catch (Exception)
        {
          if (pi.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
          {
            icbPrices = GetIcbPrices(request, productOfferingId, ChargeType.UDRCTiered, null);
            icbPricesWithPI = GetIcbPrices(request, productOfferingId, ChargeType.UDRCTiered, pi.ID);

            rs = GetRateSchedules(icbPrices, ref ptId);
            rs.AddRange(GetRateSchedules(icbPricesWithPI, ref ptId));

            Application.ProductManagement.PriceListService.SaveRateSchedulesForSubscription(
              subscriptionId,
              new PCIdentifier(pi.ID),
              new PCIdentifier(ptId),
              rs,
              _log,
              SessionContext);

          }
          else
          {
            throw;
          }
        }

      }
    }

    private List<IndividualPrice> GetIcbPrices(QuoteRequest request, int productOfferingId, ChargeType chargeType,
                                               int? priceableItemId)
    {
      IEnumerable<IndividualPrice> result = request.IcbPrices.Where(
        i =>
        i.ProductOfferingId == productOfferingId && i.CurrentChargeType == chargeType &&
        i.PriceableItemId == priceableItemId);

      return new List<IndividualPrice>(result);
    }

    private List<BaseRateSchedule> GetRateSchedules(List<IndividualPrice> icbPrices, ref int ptId)
    {
      var rs = new List<BaseRateSchedule>();

      foreach (var icbPrice in icbPrices)
      {
        switch (icbPrice.CurrentChargeType)
        {
          case ChargeType.RecurringCharge:
            ptId = parameterTableFlatRc.ID;
            rs.AddRange(
              icbPrice.ChargesRates.Select(chargesRate => GetFlatRcRateSchedule(chargesRate.Price)));
            return rs;
          case ChargeType.NonRecurringCharge:
            ptId = parameterTableNonRc.ID;
            rs.AddRange(icbPrice.ChargesRates.Select(chargesRate => GetNonRcRateSchedule(chargesRate.Price)));
            return rs;
          case ChargeType.UDRCTapered:
            ptId = parameterTableUdrcTapered.ID;
            rs.Add(GetTaperedUdrcRateSchedule(icbPrice.ChargesRates));
            return rs;
          case ChargeType.UDRCTiered:
            ptId = parameterTableUdrcTiered.ID;
            rs.AddRange(
              icbPrice.ChargesRates.Select(
                chargesRate =>
                GetTieredUdrcRateSchedule(chargesRate.UnitValue, chargesRate.UnitAmount,
                                          chargesRate.BaseAmount)));
            return rs;
        }
      }

      return rs;
    }

    public static BaseRateSchedule GetFlatRcRateSchedule(decimal price, DateTime? startDate = null,
                                                         DateTime? endDate = null)
    {
      startDate = startDate ?? DateTime.Parse("1/1/2000");
      endDate = endDate ?? DateTime.Parse("1/1/2038");

      return new RateSchedule
        <Metratech_com_FlatRecurringChargeRateEntry, Metratech_com_FlatRecurringChargeDefaultRateEntry>
        {
          EffectiveDate = new ProdCatTimeSpan
            {
              StartDate = startDate,
              StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
              EndDate = endDate,
              EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
            },
          RateEntries = new List<Metratech_com_FlatRecurringChargeRateEntry>
            {
              new Metratech_com_FlatRecurringChargeRateEntry {RCAmount = price}
            }
        };
    }

    public static BaseRateSchedule GetNonRcRateSchedule(decimal price)
    {
      return new RateSchedule
        <Metratech_com_NonRecurringChargeRateEntry, Metratech_com_NonRecurringChargeDefaultRateEntry>
        {
          EffectiveDate = new ProdCatTimeSpan
            {
              StartDate = DateTime.Parse("1/1/2000"),
              StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
              EndDate = DateTime.Parse("1/1/2038"),
              EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
            },
          RateEntries = new List<Metratech_com_NonRecurringChargeRateEntry>
            {
              new Metratech_com_NonRecurringChargeRateEntry {NRCAmount = price}
            }
        };
    }

    public static BaseRateSchedule GetTaperedUdrcRateSchedule(List<ChargesRate> caChargesRate)
    {
      var rates = new List<Metratech_com_UDRCTaperedRateEntry>();
      var i = 0;
      foreach (var val in caChargesRate)
      {
        rates.Add(new Metratech_com_UDRCTaperedRateEntry
          {
            Index = i,
            UnitValue = val.UnitValue,
            UnitAmount = val.UnitAmount
          });
        i++;
      }

      return new RateSchedule<Metratech_com_UDRCTaperedRateEntry, Metratech_com_UDRCTaperedDefaultRateEntry>
        {
          EffectiveDate = new ProdCatTimeSpan
            {
              StartDate = DateTime.Parse("1/1/2000"),
              StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
              EndDate = DateTime.Parse("1/1/2038"),
              EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
            },
          RateEntries = rates
        };
    }

    public static BaseRateSchedule GetTieredUdrcRateSchedule(decimal unitValue, decimal unitAmount, decimal baseAmount)
    {
      var rates = new List<Metratech_com_UDRCTieredRateEntry>();
      var i = 0;
      rates.Add(new Metratech_com_UDRCTieredRateEntry
        {
          Index = i,
          UnitValue = unitValue,
          UnitAmount = unitAmount,
          BaseAmount = baseAmount
        });

      return new RateSchedule<Metratech_com_UDRCTieredRateEntry, Metratech_com_UDRCTieredDefaultRateEntry>
        {
          EffectiveDate = new ProdCatTimeSpan
            {
              StartDate = DateTime.Parse("1/1/2000"),
              StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute,
              EndDate = DateTime.Parse("1/1/2038"),
              EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute
            },
          RateEntries = rates
        };
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
      catch (InvalidCastException)
      {
        return 0M;
      }
      catch (SqlNullValueException)
      {
        return 0M;
      }
    }

    private string GetStringProperty(IMTDataReader rowset, string property, string defaultValue = null)
    {
      try
      {
        return rowset.GetString(property);
      }
      catch (InvalidOperationException)
      {
        return defaultValue ?? "";
      }
      catch (InvalidCastException)
      {
        return defaultValue ?? "";
      }
      catch (SqlNullValueException)
      {
        return defaultValue ?? "";
      }
    }

    protected void CreateAndCalculateQuote(QuoteRequest request, QuoteResponse response)
    {
      // Create the TransactionScope to execute the commands, guaranteeing
      // that spread of commands can commit or roll back as a single unit of work.
      //TODO: need to be using TransactionScope
      //using (TransactionScope scope = new TransactionScope())
      //{
      using (new HighResolutionTimer(MethodBase.GetCurrentMethod().Name))
      {
        using (var conn = ConnectionManager.CreateConnection())
        {

          //Create the needed subscriptions for this quote
          CreateNeededSubscriptions(request, response);

          response.Artefacts.ChargesCollection.AddRange(_chargeMetering.AddCharges(request));

          //Determine Usage Interval to use when quoting
          response.Artefacts.IdUsageInterval = _chargeMetering.GetUsageInterval(request);

          //backup t_acc_usage data
          using (var conn1 = ConnectionManager.CreateConnection())
          {
            using (var stmt = conn1.CreateAdapterStatement(Configuration.QuotingQueryFolder,
                                                           Configuration.BackupQuoteUsagesQueryTag))
            {
              stmt.AddParam("%%USAGE_INTERVAL%%", response.Artefacts.IdUsageInterval);
              stmt.AddParam("%%ACCOUNTS%%", string.Join(",", request.Accounts));
              stmt.AddParam("%%POS%%", string.Join(",", request.ProductOfferings));
              stmt.AddParam("%%QUOTE_ID%%", response.IdQuote);
              stmt.ExecuteReader();
            }
          }

          // calculate Total
          using (var stmt = conn.CreateAdapterStatement(Configuration.QuotingQueryFolder,
                                                        Configuration.CalculateQuoteTotalAmountQueryTag))
          {
            stmt.AddParam("%%QUOTE_ID%%", response.IdQuote);
            using (IMTDataReader rowset = stmt.ExecuteReader())
            {
              rowset.Read();

              response.TotalAmount = GetDecimalProperty(rowset, "Amount");
              response.TotalTax = GetDecimalProperty(rowset, "TaxTotal");
              response.Currency = GetStringProperty(rowset, "Currency");

              var totalMessage = string.Format("Total amount: {0} {1}, Total Tax: {2}",
                                               response.TotalAmount.ToString("N2"), response.Currency,
                                               response.TotalTax);

              _log.LogDebug("CreateAndCalculateQuote: {0}", totalMessage);

              //TODO: Error check if we didn't find anything but we expected something (i.e. rowset.Read failed but we expected results            
            }
          }
        }
      }
      // The Complete method commits the transaction. If an exception has been thrown,
      // Complete is not  called and the transaction is rolled back.
      //scope.Complete();
      //}
    }

    private delegate void AsyncCleanupBackoutUsageData(int idQuote, IEnumerable<ChargeData> charges, IQuotingRepository quotingRepository);
    /// <summary>
    /// CleanUp quoters artifacts in case IsCleanupQuoteAutomaticaly = fales in 
    /// </summary>
    /// <param name="quoteArtefact">Sents data for cleaning up Quote Artefacts</param>
    public List<QuoteLogRecord> Cleanup(QuoteResponseArtefacts quoteArtefact)
    {
      QuotingRepository.UpdateStatus(quoteArtefact.IdQuote, ActionStatus.StatusCleanup, QuoteStatus.InProgress);
      using (new HighResolutionTimer(MethodInfo.GetCurrentMethod().Name))
      {

        if (quoteArtefact.Subscription == null)
        {
          QuotingRepository.UpdateStatus(quoteArtefact.IdQuote, ActionStatus.StatusCleanup, QuoteStatus.Failed);
          throw new ArgumentNullException(
            String.Format("The {0} does not contain Subscription for cleanuping", typeof (QuoteResponseArtefacts)));
        }

        if (quoteArtefact.ChargesCollection == null)
        {
          QuotingRepository.UpdateStatus(quoteArtefact.IdQuote, ActionStatus.StatusCleanup, QuoteStatus.Failed);
          throw new ArgumentNullException(
            String.Format("The {0} does not contain Chrages for cleanuping", typeof (QuoteResponseArtefacts)));
        }

        try
        {
          var result = SetNewQuoteLogFormater(quoteArtefact);
          //If needed, cleanup should be completed here.
          //Happens when quote is finalized, pdf generated and returned
          //or if an error happens during processing
          CleanupSubscriptionsCreated(quoteArtefact);

          AsyncCleanupBackoutUsageData asynCall = _chargeMetering.CleanupUsageData;
          asynCall.BeginInvoke(quoteArtefact.IdQuote, quoteArtefact.ChargesCollection, QuotingRepository, null, null);
          //_chargeMetering.CleanupUsageData(quoteArtefact.IdQuote, quoteArtefact.ChargesCollection);
          return result;
        }
        finally
        {
          _log.ClearFormatter();
        }
      }
    }

    protected void CleanupSubscriptionsCreated(QuoteResponseArtefacts quoteArtefact)
    {
      if (quoteArtefact.Subscription.IsGroupSubcription)
      {
        CleanupAllGroupSubscriptions(quoteArtefact);
      }
      else
      {
        CleanupAllSubscriptions(quoteArtefact);
      }
    }

    private void CleanupAllGroupSubscriptions(QuoteResponseArtefacts quoteArtefact)
    {
      // Remove group subscriptions
      foreach (var subscription in quoteArtefact.Subscription.Collection)
      {
        if (subscription.Value == null)
          throw new ArgumentNullException(
            String.Format(
              "The Group subsciption with id = {0} does not contains any Account ID. Verify Quote Artefacts.",
              subscription.Key));

        IMTGroupSubscription groupSubscription = null;

        try
        {
          groupSubscription = CurrentProductCatalog.GetGroupSubscriptionByID(subscription.Key);

          // Unsubscribe members
          foreach (var idSubscribedAcc in subscription.Value)
          {
            IMTGSubMember gsmember = new MTGSubMemberClass();
            gsmember.AccountID = idSubscribedAcc;

            if (groupSubscription.FindMember(idSubscribedAcc, quoteArtefact.EffectiveDate) != null)
            {
              groupSubscription.UnsubscribeMember((MTGSubMember)gsmember);
            }
          }

          using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
          {
            using (
              IMTCallableStatement stmt =
                conn.CreateCallableStatement("REMOVEGSUBS_QUOTING"))
            {
              int status = 0;
              stmt.AddParam("p_id_sub", MTParameterType.Integer, groupSubscription.ID);
              stmt.AddParam("p_systemdate", MTParameterType.DateTime, quoteArtefact.EffectiveDate);
              stmt.AddParam("p_status", MTParameterType.Integer, status);
              stmt.ExecuteNonQuery();
            }
          }

          CleanupUDRCMetricValues(groupSubscription.ID);
        }
        catch (Exception ex)
        {
          _log.LogException(
            String.Format("Problem with clean up group subscription {0} (subscription ID = {1})."
                          , subscription.Key
                          , groupSubscription != null ? groupSubscription.GroupID : -1)
            , ex);
        }
      }
    }

    private void CleanupAllSubscriptions(QuoteResponseArtefacts quoteArtefact)
    {
      var subService = new SubscriptionService(SessionContext);

      // Remove group subscriptions
      foreach (var subscription in quoteArtefact.Subscription.Collection)
      {
        try
        {
          subService.DeleteSubscription(new AccountIdentifier(subscription.Value[0]), subscription.Key);
          CleanupUDRCMetricValues(subscription.Key);
        }
        catch (Exception ex)
        {
          _log.LogException(String.Format("Problem with clean up subscription {0}.", subscription.Key), ex);
        }
      }
    }

    protected void CleanupUDRCMetricValues(int idSubscription)
    {
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement(Configuration.QuotingQueryFolder,
                                                                 Configuration.RemoveRCMetricValuesQueryTag))
        {
          stmt.AddParam("%%ID_SUB%%", idSubscription);
          stmt.ExecuteNonQuery();
        }
      }
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

    protected IMTSessionContext GetSessionContextForProductCatalog()
    {
      //Todo: Fix to read from server access file if we decide to use SuperUser as opposed to user generating quote
      Interop.MTAuth.IMTLoginContext loginContext = new Interop.MTAuth.MTLoginContextClass();
      //ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      //sa.Initialize();
      //ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      const string suName = "su";
      const string suPassword = "su123";
      try
      {
        return (Interop.MTProductCatalog.IMTSessionContext)loginContext.Login(suName, "system_user", suPassword);
      }
      catch (Exception ex)
      {
        throw new Exception("GetSessionContextForProductCatalog: Login failed:" + ex.Message, ex);
      }

    }

    #endregion

    public Interop.MTAuth.IMTSessionContext SessionContext { get; private set; }
  }
}
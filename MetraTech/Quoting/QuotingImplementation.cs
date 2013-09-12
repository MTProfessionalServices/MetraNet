using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;
// TODO: Add auditor to Quote
// using MetraTech.Interop.MTAuditEvents;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTBillingReRun;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Pipeline;
using MetraTech.Quoting.Charge;
using MetraTech.UsageServer;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using BillingReRunClient = MetraTech.Pipeline.ReRun;
using IMTCollection = MetraTech.Interop.MTProductCatalog.IMTCollection;

namespace MetraTech.Quoting
{
    public class QuotingImplementation : IQuotingImplementation
    {
        public QuotingConfiguration Configuration { get; private set; }
        // TODO: Add auditor to Quote
        //private Auditor quotingAuditor = new Auditor();
        private static ILogger _log;
        private IChargeMetering _chargeMetering;

        private int UsageIntervalForQuote { get; set; }

        private readonly List<MTSubscription> createdSubsciptions = new List<MTSubscription>();
        private readonly List<IMTGroupSubscription> createdGroupSubsciptions = new List<IMTGroupSubscription>();

        private const string MetratechComFlatrecurringcharge = "metratech.com/flatrecurringcharge";
        private const string MetratechComUdrctapered = "metratech.com/udrctapered";
        private const string MetratechComNonrecurringcharge = "metratech.com/nonrecurringcharge";
        private const string MetratechComUdrctiered = "metratech.com/udrctiered";

        private MTParamTableDefinition parameterTableFlatRc;
        private MTParamTableDefinition parameterTableNonRc;
        private MTParamTableDefinition parameterTableUdrcTapered;
        private MTParamTableDefinition parameterTableUdrcTiered;

        #region Constructors

        public QuotingImplementation(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext,
                                        IQuotingRepository quotingRepository, IChargeMetering chargeMetering, ILogger log)
        {
            Init(configuration, sessionContext, quotingRepository, chargeMetering, log);
        }

        private void Init(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext,
                          IQuotingRepository quotingRepository, IChargeMetering chargeMetering, ILogger log)
        {
            Configuration = configuration;
            SessionContext = sessionContext;
            QuotingRepository = quotingRepository;
            _chargeMetering = chargeMetering;
            _log = log;
        }

        public QuotingImplementation(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext,
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

        public QuotingImplementation(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext,
                                      IQuotingRepository quotingRepository)
        {
            Init(configuration, sessionContext, quotingRepository, null,
                new Logger(String.Format("[{0}]", typeof(QuotingImplementation))));

            _chargeMetering = InitDefaultChragesMetering();
        }

        public QuotingImplementation(QuotingConfiguration configuration, Auth.IMTSessionContext sessionContext) :
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

        public QuoteRequest CurrentRequest { get; private set; }

        public QuoteResponse CurrentResponse { get; private set; }


        /// <summary>
        /// Validate request, prepare data for metering and finaly creats quote
        /// </summary>
        /// <param name="quoteRequest"></param>
        /// <returns>QuoteResponse</returns>
        public QuoteResponse CreateQuote(QuoteRequest quoteRequest)
        {
            //TODO: Should we add check that pipeline/inetinfo/activityservices are running before starting quote. We think nice to have and maybe configurable
            using (new MetraTech.Debug.Diagnostics.HighResolutionTimer(MethodInfo.GetCurrentMethod().Name))
            {
                CurrentResponse = new QuoteResponse();

                SetNewQuoteLogFormater(quoteRequest, CurrentResponse);

                createdSubsciptions.Clear();
                createdGroupSubsciptions.Clear();

                try
                {
                    ValidateRequest(quoteRequest);
                }
                catch (Exception ex)
                {
                    CurrentResponse.Status = QuoteStatus.Failed;
                    CurrentResponse.FailedMessage = ex.GetaAllMessages();
                    return CurrentResponse;
                }


                try
                {
                    CurrentResponse.Status = QuoteStatus.InProgress;

                    CurrentRequest = quoteRequest;

                    //Add this quote into repository and gets a newly creatd quote id
                    CurrentResponse.IdQuote = QuotingRepository.CreateQuote(quoteRequest, SessionContext);

                    StartQuoteInternal(CurrentResponse);

                    //If we need here, here is the place for things that need to be generated, totaled, etc. before we
                    //generate PDF and return results
                    CalculateQuoteTotal(CurrentResponse);
                    CurrentResponse.Status = QuoteStatus.Complete;

                    if (CurrentRequest.ReportParameters.PDFReport)
                    {
                        GeneratePDFForCurrentQuote();
                    }

                    //todo: Save or update data about quote in DB
                    CurrentResponse = QuotingRepository.UpdateQuoteWithResponse(CurrentResponse);
                    QuotingRepository.SaveQuoteLog(CurrentResponse.MessageLog);

                }
                catch (Exception ex)
                {
                    _log.LogError("Current quote failed and being cleaned up: {0}", ex);

                    CurrentResponse.Status = QuoteStatus.Failed;
                    CurrentResponse.FailedMessage = ex.GetaAllMessages();

                    CurrentResponse = QuotingRepository.UpdateQuoteWithErrorResponse(CurrentResponse.IdQuote, CurrentResponse,
                                                                                     ex.Message);
                    throw;
                }
                finally
                {
                    if (Configuration.IsCleanupQuoteAutomaticaly)
                    {
                        Cleanup(CurrentResponse.Artefacts);
                    }
                    else
                    {
                        _log.LogWarning("Not cleaning up subsciption (includes group) and usage data for quote");
                    }
                }

                if (CurrentRequest.ShowQuoteArtefacts == false)
                    CurrentResponse.Artefacts = null;

                return CurrentResponse;
            }
        }

        private void SetNewQuoteLogFormater(QuoteRequest quoteRequest, QuoteResponse currentResponse)
        {
            _log.SetFormatter((message, args) =>
            {
                string newFormater
                    = String.Format("Quote[{0}]: [{1}]", currentResponse.IdQuote, String.Format(message, args));

                CurrentResponse.MessageLog.Add(new QuoteLogRecord
                {
                    QuoteIdentifier = quoteRequest.QuoteIdentifier,
                    DateAdded = MetraTime.Now,
                    Message = message
                });

                return newFormater;
            });
        }

        #endregion

        #region Internal

        private void ValidateICBs(IEnumerable<IndividualPrice> icbs)
        {
            foreach (var icb in icbs)
            {
                switch (icb.CurrentChargeType)
                {                                      
                    case ChargeType.UDRCTapered:
                        if ((icb.ChargesRates.First().UnitAmount == 0)&&
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

        /// <summary>
        /// Method that validates/sanity checks the request and throws exceptions if there are errors
        /// </summary>
        /// <param name="request">QuoteRequest to be checked</param>
        /// <exception cref="ArgumentException"></exception>
        protected void ValidateRequest(QuoteRequest request)
        {

            if (request.IcbPrices == null)
                request.IcbPrices = new List<IndividualPrice>();

            if (request.SubscriptionParameters.IsGroupSubscription && request.IcbPrices.Count > 0)
            {
                throw new Exception("Current limitation of quoting: ICBs are applied only for individual subscriptions");
            }

            //0 values Request validation
            if (request.Accounts.Contains(0))
            {
                throw new ArgumentException("Accounts with id = 0 is invalid");
            }
            if (request.ProductOfferings.Contains(0))
            {
                throw new ArgumentException("PO with id = 0 is invalid");
            }

            ValidateICBs(request.IcbPrices);

            if (request.SubscriptionParameters.UDRCValues.Any(i => i.Key == ""))
            {
                throw new ArgumentException("Invalid UDRC metrics");
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
                  var stmt = conn.CreateAdapterStatement(Configuration.QuotingQueryFolder, Configuration.GetAccountBillingCycleQueryTag))
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

        protected void StartQuoteInternal(QuoteResponse quoteResponse)
        {
            //Create the needed subscriptions for this quote
            CreateNeededSubscriptions();

            using (var conn = ConnectionManager.CreateConnection())
            {
                quoteResponse.Artefacts.ChargesCollection.AddRange(_chargeMetering.AddCharges(conn, CurrentRequest));
            }

            //Determine Usage Interval to use when quoting
            quoteResponse.Artefacts.IdUsageInterval = _chargeMetering.GetUsageInterval(CurrentRequest);
        }

        protected void GeneratePDFForCurrentQuote()
        {
            using (new Debug.Diagnostics.HighResolutionTimer("GeneratePDFForCurrentQuote"))
            {
                //TODO: Eventually cache/only load configuration as needed
                var quoteReportingConfiguration = QuoteReportingConfigurationManager.LoadConfiguration(this.Configuration);
                var quotePDFReport = new QuotePDFReport(quoteReportingConfiguration);

                //If request does not specify a template to use, then use the configured default
                if (string.IsNullOrEmpty(CurrentRequest.ReportParameters.ReportTemplateName))
                {
                    CurrentRequest.ReportParameters.ReportTemplateName = this.Configuration.ReportDefaultTemplateName;
                }

                CurrentResponse.ReportLink = quotePDFReport.CreatePDFReport(CurrentResponse.IdQuote,
                                                                            CurrentRequest.Accounts[0],
                                                                            CurrentRequest.ReportParameters.ReportTemplateName,
                                                                            GetLanguageCodeIdForCurrentRequest());
            }
        }

        protected int GetLanguageCodeIdForCurrentRequest()
        {
            //TODO: Sort out using cultures for real and match them against either enum or database

            string temp = CurrentRequest.Localization;
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

            _log.LogWarning(
              "Unable to convert culture of {0} to MetraTech language code database id; using 840 for 'en-US'", temp);

            return 840;

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

        //TODO: Should be refacored. It should be in seperate class
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

                GetParamTables();

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

        private void GetParamTables()
        {
            if (CurrentRequest.IcbPrices.Count > 0)
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
                                                     CurrentResponse.IdQuote);
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
                    _log.LogError(come.Message);
                    throw new ArgumentException("Subscription failed with message: " + come.Message +
                                                "\nUDRC ID added to SubscriptionParameters does not exist");
                }

                throw;
            }

            subscription.Save();

            ApplyIcbPricesToSubscription(subscription.ProductOfferingID, subscription.ID);

            createdSubsciptions.Add(subscription);
        }

        private void ApplyIcbPricesToSubscription(int productOfferingId, int subscriptionId)
        {
            if (CurrentRequest.IcbPrices.Count == 0) return;

            var po = CurrentProductCatalog.GetProductOffering(productOfferingId);
            IMTCollection pis = po.GetPriceableItems();
            int ptId;
            List<BaseRateSchedule> rs = new List<BaseRateSchedule>();

            foreach (IMTPriceableItem pi in pis)
            {
                var icbPrices = new List<IndividualPrice>();
                switch (pi.Kind)
                {
                    case MTPCEntityType.PCENTITY_TYPE_RECURRING:
                        icbPrices =
                            CurrentRequest.IcbPrices.Where(i => i.CurrentChargeType == ChargeType.RecurringCharge).ToList();
                        break;
                    case MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
                        icbPrices =
                            CurrentRequest.IcbPrices.Where(i => i.CurrentChargeType == ChargeType.UDRCTapered).ToList();
                        break;
                    case MTPCEntityType.PCENTITY_TYPE_NON_RECURRING:
                        icbPrices =
                            CurrentRequest.IcbPrices.Where(i => i.CurrentChargeType == ChargeType.NonRecurringCharge).ToList();
                        break;
                }

                //Can't sorted out that UDRCs is Tiered or Tappered
                try
                {
                    rs = GetRateSchedules(icbPrices, out ptId);

                    Application.ProductManagement.PriceListService.SaveRateSchedulesForSubscription(
                            subscriptionId,
                            new PCIdentifier(pi.ID),
                            new PCIdentifier(ptId),
                            rs,
                            _log,
                            SessionContext);
                }
                catch (Exception ex)
                {
                    if (pi.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
                    {
                        icbPrices = CurrentRequest.IcbPrices.Where(i => i.CurrentChargeType == ChargeType.UDRCTiered).ToList();

                        rs = GetRateSchedules(icbPrices, out ptId);

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
                        throw ex;
                    }
                }

            }
        }

        private List<BaseRateSchedule> GetRateSchedules(List<IndividualPrice> icbPrices, out int ptId)
        {

            ptId = 0;

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

        public static BaseRateSchedule GetFlatRcRateSchedule(decimal price, DateTime? startDate = null, DateTime? endDate = null)
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
            return new RateSchedule<Metratech_com_NonRecurringChargeRateEntry, Metratech_com_NonRecurringChargeDefaultRateEntry>
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
              new Metratech_com_NonRecurringChargeRateEntry { NRCAmount = price }
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

        private string GetBatchIdsForQuery(IEnumerable<ChargeData> charges)
        {
            string sqlTemplate = "cast(N'' as xml).value('xs:base64Binary(\"{0}\")', 'binary(16)' ),";

            var res = charges.Aggregate("", (current, charge) => current + String.Format(sqlTemplate, charge.IdBatch));

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

        protected void CalculateQuoteTotal(QuoteResponse quoteResponse)
        {
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(Configuration.QuotingQueryFolder,
                                                                            Configuration.CalculateQuoteTotalAmountQueryTag))
                {
                    stmt.AddParam("%%USAGE_INTERVAL%%", quoteResponse.Artefacts.IdUsageInterval);
                    stmt.AddParam("%%ACCOUNTS%%", string.Join(",", CurrentRequest.Accounts));
                    stmt.AddParam("%%BATCHIDS%%", GetBatchIdsForQuery(quoteResponse.Artefacts.ChargesCollection), true);
                    using (IMTDataReader rowset = stmt.ExecuteReader())
                    {
                        rowset.Read();

                        CurrentResponse.TotalAmount = GetDecimalProperty(rowset, "Amount");
                        CurrentResponse.TotalTax = GetDecimalProperty(rowset, "TaxTotal");
                        CurrentResponse.Currency = GetStringProperty(rowset, "Currency");

                        var totalMessage = string.Format("Total amount: {0} {1}, Total Tax: {2}",
                                                         CurrentResponse.TotalAmount.ToString("N2"), CurrentResponse.Currency,
                                                         CurrentResponse.TotalTax);

                        _log.LogDebug("CalculateQuoteTotal: {0}", totalMessage);

                        //TODO: Error check if we didn't find anything but we expected something (i.e. rowset.Read failed but we expected results
                        //TODO: Nice to have to add the count(*) of records which could be useful for error checking; adding to query doesn't cost anything
                    }
                }
            }
        }


        /// <summary>
        /// CleanUp quoters artifacts in case IsCleanupQuoteAutomaticaly = fales in 
        /// </summary>
        /// <param name="quoteArtefact">Sents data for cleaning up Quote Artefacts</param>
        public void Cleanup(QuoteResponseArtefacts quoteArtefact)
        {
            //If needed, cleanup should be completed here.
            //Happens when quote is finalized, pdf generated and returned
            //or if an error happens during processing

            CleanupSubscriptionsCreated(quoteArtefact.Subscription);

            _chargeMetering.CleanupUsageData(quoteArtefact.IdQuote, quoteArtefact.ChargesCollection);
        }

        protected void CleanupSubscriptionsCreated(SubscriptionResponseData subscriptionResponse)
        {
            // TODO: Should use SubscriptionResponseData instead of saved response!
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
                    _log.LogException(String.Format("Problem with clean up subscription {0}.", subscription.ID), ex);
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
                            subscription.UnsubscribeMember((MTGSubMember)gsmember);
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
                    _log.LogException(String.Format("Problem with clean up subscription {0}.", subscription.ID), ex);
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
                return (Interop.MTProductCatalog.IMTSessionContext)loginContext.Login(suName, "system_user", suPassword);
            }
            catch (Exception ex)
            {
                throw new Exception("GetSessionContextForProductCatalog: Login failed:" + ex.Message, ex);
            }

        }

        #endregion

        public Auth.IMTSessionContext SessionContext { get; private set; }
    }
}
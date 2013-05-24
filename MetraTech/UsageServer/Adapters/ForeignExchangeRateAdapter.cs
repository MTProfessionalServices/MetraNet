using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using System.Reflection;
using System.Xml;
using MetraTech.ForeignExchange;
using MetraTech.Interop.MTAuth;

namespace MetraTech.UsageServer.Adapters
{
    /// <summary>
    /// Exchange Rate Adapter itself
    /// </summary>
    public class ForeignExchangeRateAdapter : IRecurringEventAdapter2
    {
        // Member Variables
        private const string MAdapterName = @"ForeignExchangeRateAdapter";

        private readonly Dictionary<string, BaseCurrencyFilter> _currencyFilters =
            new Dictionary<string, BaseCurrencyFilter>();

        private readonly List<IForeignExchangeRateProvider> _providers = new List<IForeignExchangeRateProvider>();

        private bool _addCalculatedRates;
        private bool _addCrossRates;
        private bool _addIdentityRates;
        private bool _addInverseRates;
        private bool _calculateInverseRates;
        private string _categoryColumn;
        private string _crossCurrencyColumn;
        private string _crossRateColumn;

        private int _idCsr;
        private Logger _logger;
        private string _nmLogin;
        private string _nmPricelist;
        private string _nmPt;
        private string _nmSpace;
        private string _providerColumn;
        private string _rateColumn;
        private string _srcCurrencyColumn;
        private string _systemCurrency;
        private string _tgtCurrencyColumn;

        #region IRecurringEventAdapter2 Members

        /// <summary>
        /// Does this adapter support running in scheduled mode
        /// </summary>
        public bool SupportsScheduledEvents
        {
            get { return true; }
        }

        /// <summary>
        /// Does this adapter support running in end-of-period mode
        /// </summary>
        public bool SupportsEndOfPeriodEvents
        {
            get { return true; }
        }

        /// <summary>
        /// Can this adapter be reversed
        /// </summary>
        public ReverseMode Reversibility
        {
            get { return ReverseMode.Custom; }
        }

        /// <summary>
        /// Can this adapter run multiple instances
        /// </summary>
        public bool AllowMultipleInstances
        {
            get { return false; }
        }

        /// <summary>
        /// Specifies whether the adapter can process billing groups as a group
        /// of accounts, as individual accounts or if it
        /// cannot process billing groups at all.
        /// This setting is only valid for end-of-period adapters.
        /// </summary>
        /// <returns>BillingGroupSupportType</returns>
        public BillingGroupSupportType BillingGroupSupport
        {
            get { return BillingGroupSupportType.Interval; }
        }

        /// <summary>
        /// Specifies whether this adapter has special constraints on the membership
        /// of a billing group.
        /// This setting is only valid for adapters that support billing groups.
        /// </summary>
        /// <returns>True if constraints exist, false otherwise</returns>
        public bool HasBillingGroupConstraints
        {
            get { return false; }
        }

        /// <summary>
        /// Perform any one time or start up initialization, including reading our config file
        /// for instance specific information
        /// </summary>
        /// <param name="eventName"></param>
        /// <param name="configFile"></param>
        /// <param name="context"></param>
        /// <param name="limitedInit"></param>
        [SuppressMessage("Microsoft.Reliability", "CA2000:Dispose objects before losing scope"),
         SuppressMessage("Microsoft.Globalization", "CA1303:Do not pass literals as localized parameters",
             MessageId = "NLog.Logger.Debug(System.String,System.String)"),
         SuppressMessage("Microsoft.Naming", "CA2204:Literals should be spelled correctly",
             MessageId = "XsltFileName")]
        public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
        {
            if (limitedInit)
            {
                _logger = new Logger("[ForeignExchangeRateAdapter]");
                _logger.LogDebug(string.Format("Intializing {0} (limited)", MAdapterName));
            }
            else
            {
                if (_logger == null)
                {
                    _logger = new Logger("[ForeignExchangeRateAdapter]");
                }

                Debug.Assert(context != null);

                _idCsr = context.AccountID;

                //Load the custom adapter settings from the given config file

                _logger.LogDebug(string.Format("Read configuration for {0} from {1}", MAdapterName, configFile));

                _nmPt = "t_pt_currencyexchangerates";
                _srcCurrencyColumn = "c_SourceCurrency";
                _tgtCurrencyColumn = "c_TargetCurrency";
                _rateColumn = "c_ExchangeRates";

                using (
                    var reader = XmlReader.Create(configFile,
                                                        new XmlReaderSettings
                                                            {IgnoreComments = true, IgnoreWhitespace = true}))
                {
                    while (reader.Read() && reader.NodeType == XmlNodeType.XmlDeclaration)
                    {
                    }
                    if (!(reader.Name.Equals("xmlconfig") && reader.NodeType == XmlNodeType.Element))
                    {
                        throw new Exception("Failed to read xmlconfig element");
                    }
                    if (reader.IsEmptyElement || !reader.Read())
                    {
                        throw new Exception("xmlconfig can not be empty");
                    }
                    while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("xmlconfig")))
                    {
                        if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("SystemCurrency"))
                        {
                            _systemCurrency = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("ParamTableName"))
                        {
                            _nmPt = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("SourceCurrencyColumn"))
                        {
                            _srcCurrencyColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("TargetCurrencyColumn"))
                        {
                            _tgtCurrencyColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("CrossCurrencyColumn"))
                        {
                            _crossCurrencyColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("RateColumn"))
                        {
                            _rateColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("CrossRateColumn"))
                        {
                            _crossRateColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("ProviderColumn"))
                        {
                            _providerColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("CategoryColumn"))
                        {
                            _categoryColumn = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("PricelistName"))
                        {
                            _nmPricelist = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("PricelistLogin"))
                        {
                            _nmLogin = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("PricelistLoginSpace"))
                        {
                            _nmSpace = reader.ReadElementContentAsString();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("CalculateInverseRates"))
                        {
                            _calculateInverseRates = reader.ReadElementContentAsBoolean();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("AddInverseRates"))
                        {
                            _addInverseRates = reader.ReadElementContentAsBoolean();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("AddIdentityRates"))
                        {
                            _addIdentityRates = reader.ReadElementContentAsBoolean();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("AddCalculatedRates"))
                        {
                            _addCalculatedRates = reader.ReadElementContentAsBoolean();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("AddCrossRates"))
                        {
                            _addCrossRates = reader.ReadElementContentAsBoolean();
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Provider"))
                        {
                            if (reader.IsEmptyElement)
                            {
                                if (!reader.Read())
                                {
                                    throw new Exception("Failed to read Provider element");
                                }
                                continue;
                            }
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read Provider element");
                            }
                            var assemblyName = string.Empty;
                            var className = string.Empty;
                            while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("Provider")))
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("AssemblyName"))
                                {
                                    assemblyName = reader.ReadElementContentAsString();
                                }
                                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("ClassName"))
                                {
                                    className = reader.ReadElementContentAsString();
                                }
                                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("ProviderConfig"))
                                {
                                    IForeignExchangeRateProvider provider;
                                    if (string.IsNullOrEmpty(assemblyName))
                                    {
                                        throw new Exception("Must set AssemblyName for Provider");
                                    }
                                    if (string.IsNullOrEmpty(className))
                                    {
                                        throw new Exception("Must set ClassName for Provider");
                                    }
                                    try
                                    {
                                        var t = Type.GetType(className + ", " + assemblyName, true);
                                        var c = t.GetConstructor(new Type[] {});
                                        if (c == null)
                                        {
                                            throw new Exception("No constructor found");
                                        }
                                        provider =
                                            c.Invoke(
                                                null) as IForeignExchangeRateProvider;
                                    }
                                    catch (Exception ex)
                                    {
                                        _logger.LogException("Unable to instantiate provider", ex);
                                        throw new Exception("Unable to instantiate provider", ex);
                                    }
                                    if (provider == null)
                                    {
                                        throw new Exception("Provider not created");
                                    }
                                    provider.Init(reader);
                                    _providers.Add(provider);
                                    if (
                                        !(reader.NodeType == XmlNodeType.EndElement &&
                                          reader.Name.Equals("ProviderConfig")))
                                    {
                                        throw new Exception("Provider did not leave reader on ProviderConfig EndElement");
                                    }
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Failed to read Provider element");
                                    }
                                }
                                else
                                {
                                    _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} {1}", reader.Name,
                                                                     reader.NodeType));
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Failed to read Provider element");
                                    }
                                }
                            }
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read Provider element");
                            }
                        }
                        else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("CurrencyFilter"))
                        {
                            if (reader.IsEmptyElement)
                            {
                                if (!reader.Read())
                                {
                                    throw new Exception("Failed to read Provider element");
                                }
                                continue;
                            }
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read Provider element");
                            }
                            string baseCurrency = string.Empty;
                            var currencies = new List<string>();
                            while (!(reader.NodeType == XmlNodeType.EndElement && reader.Name.Equals("CurrencyFilter")))
                            {
                                if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("BaseCurrency"))
                                {
                                    baseCurrency = reader.ReadElementContentAsString();
                                }
                                else if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Currency"))
                                {
                                    currencies.Add(reader.ReadElementContentAsString());
                                }
                                else
                                {
                                    _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} {1}", reader.Name,
                                                                     reader.NodeType));
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Failed to read CurrencyFilter element");
                                    }
                                }
                            }
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read CurrencyFilter element");
                            }
                            var filter = new BaseCurrencyFilter {BaseCurrency = baseCurrency};
                            if (currencies.Count > 0)
                            {
                                filter.CurrencyList = currencies;
                            }
                            _currencyFilters[baseCurrency] = filter;
                        }
                        else
                        {
                            _logger.LogWarning(string.Format("Ignoring unknown XML node: {0} {1}", reader.Name,
                                                             reader.NodeType));
                            Console.WriteLine("Ignoring unknown XML node: {0} {1}", reader.Name,
                                              reader.NodeType);
                            if (!reader.Read())
                            {
                                throw new Exception("Failed to read xmlconfig element");
                            }
                        }
                    }
                }

                if (string.IsNullOrEmpty(_nmPt))
                {
                    throw new Exception("ParamTableName must be set in configuration");
                }
                if (string.IsNullOrEmpty(_srcCurrencyColumn))
                {
                    throw new Exception("SourceCurrencyColumn must be set in configuration");
                }
                if (string.IsNullOrEmpty(_tgtCurrencyColumn))
                {
                    throw new Exception("TargetCurrencyColumn must be set in configuration");
                }
                if (string.IsNullOrEmpty(_rateColumn))
                {
                    throw new Exception("RateColumn must be set in configuration");
                }
                if (string.IsNullOrEmpty(_systemCurrency))
                {
                    throw new Exception("SystemCurrency must be set in configuration");
                }
                if (_addCrossRates && _addCalculatedRates)
                {
                    throw new Exception("Can not have both AddCrossRates and AddCalculatedRates set to true");
                }
                if (_providers.Count <= 0)
                {
                    throw new Exception("Providers must be set");
                }
                if (string.IsNullOrEmpty(_crossCurrencyColumn))
                {
                    if (!string.IsNullOrEmpty(_crossRateColumn))
                    {
                        throw new Exception("CrossCurrencyColumn must be configured if CrossRateColumn is set");
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(_crossRateColumn))
                    {
                        throw new Exception("CrossRateColumn must be configured if CrossCurrencyColumn is set");
                    }
                }
                if (!string.IsNullOrEmpty(_nmLogin))
                {
                    if (!string.IsNullOrEmpty(_nmPricelist))
                    {
                        throw new Exception("PricelistName can not be set if PricelistLogin is set");
                    }
                    if (string.IsNullOrEmpty(_nmSpace))
                    {
                        throw new Exception("PricelistLoginSpace must be set if PricelistLogin is set");
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(_nmSpace))
                    {
                        throw new Exception("PricelistLogin must be set if PricelistLoginSpace is set");
                    }
                    if (string.IsNullOrEmpty(_nmPricelist))
                    {
                        throw new Exception(
                            "PricelistName, or PricelistLogin must be set, in order to identify which pricelist to use");
                    }
                }
            }
        }

        /// <summary>
        /// Perform the actual work of the adapter
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public string Execute(IRecurringEventRunContext context)
        {
            if (context == null)
            {
                throw new ArgumentNullException("context");
            }
            string info = string.Format(CultureInfo.InvariantCulture, "Executing {0} in context: {1}", MAdapterName,
                                        context);
            _logger.LogInfo(info);
            if (context.RunID != 0)
            {
                context.RecordInfo(info);
            }

            if (_addCalculatedRates)
            {
                const string warning = "Calculated rates are turned on.";
                if (context.RunID != 0)
                {
                    context.RecordWarning(warning);
                }
                _logger.LogWarning(warning);
            }


            if (context.EventType == RecurringEventType.EndOfPeriod)
            {
                var intervalId = context.UsageIntervalID;

                info = string.Format(CultureInfo.InvariantCulture,
                                     "Executing in EOP mode for Interval {0} and Billing Group {1}", intervalId,
                                     context.BillingGroupID);
                _logger.LogInfo(info);
            }
            else
            {
                info = string.Format(CultureInfo.InvariantCulture,
                                     "Executing in Scheduled mode for Start Date {0} and End Date {1}",
                                     context.StartDate, context.EndDate);
                _logger.LogInfo(info);
            }

            var date = context.StartDate;

            // Common (EOP/Scheduled) Execute code here...

            try
            {
                var idPt = ForeignExchangeRateManager.GetIdParamtableByName(_nmPt);
                ForeignExchangeRateManager.ValidateParameterTable(_nmPt, _srcCurrencyColumn, _tgtCurrencyColumn,
                                                                  _rateColumn,
                                                                  _crossCurrencyColumn, _crossRateColumn,
                                                                  _providerColumn,
                                                                  _categoryColumn);

                var idPricelist = string.IsNullOrEmpty(_nmPricelist)
                                      ? ForeignExchangeRateManager.GetIdPricelistByAccount(_nmSpace, _nmLogin)
                                      : ForeignExchangeRateManager.GetIdPricelistByName(_nmPricelist);
                var idPiTemplate = ForeignExchangeRateManager.GetIdPiTemplate(idPricelist, idPt, _nmPt);

                var baseCurrencies = new List<string>();
                var rates = new List<ExchangeRateDetails>();
                foreach (var provider in _providers)
                {
                    List<string> currencies;
                    var newRates = provider.GetExchangeRates(date, context, out currencies);
                    rates.AddRange(newRates);
                    if (context.RunID != 0)
                    {
                        context.RecordInfo(string.Format("Retrieved {0} exchange rates for provider: {1}",
                                                         newRates.Count, provider.Name));
                    }
                    foreach (var currency in currencies)
                    {
                        if (!baseCurrencies.Contains(currency))
                        {
                            baseCurrencies.Add(currency);
                        }
                    }
                }

                if (context.RunID != 0)
                {
                    context.RecordInfo(string.Format("Retrieved {0} exchange rates from providers", rates.Count));
                }

                if (_calculateInverseRates)
                {
                    if (context.RunID != 0)
                    {
                        context.RecordInfo("Calculating unset inverse rates");
                    }
                    ForeignExchangeRateManager.CalculateInverseRates(rates);
                }
                if (_addInverseRates)
                {
                    if (context.RunID != 0)
                    {
                        context.RecordInfo("Adding inverse rates");
                    }
                    ForeignExchangeRateManager.AddInverseRates(rates, baseCurrencies);
                }
                if (_addIdentityRates)
                {
                    if (context.RunID != 0)
                    {
                        context.RecordInfo("Adding identity rates");
                    }
                    ForeignExchangeRateManager.AddIdentityRates(rates, baseCurrencies);
                }
                if (_addCrossRates)
                {
                    if (context.RunID != 0)
                    {
                        context.RecordInfo("Calculating two-step cross rates");
                    }
                    ForeignExchangeRateManager.AddCrossRates(rates, baseCurrencies, _systemCurrency);
                }
                else if (_addCalculatedRates)
                {
                    if (context.RunID != 0)
                    {
                        context.RecordInfo("Calculating single-step cross rates");
                    }
                    ForeignExchangeRateManager.AddCalculatedRates(rates, baseCurrencies, _systemCurrency);
                }
                if (_currencyFilters.Count > 0)
                {
                    if (context.RunID != 0)
                    {
                        context.RecordInfo("Filtering rates");
                    }
                    ForeignExchangeRateManager.FilterRates(rates, _currencyFilters);
                }
                if (context.RunID != 0)
                {
                    context.RecordInfo("Validating rates");
                }
                ForeignExchangeRateManager.ValidateRates(rates);
                if (context.RunID != 0)
                {
                    context.RecordInfo(string.Format(
                        "Working with {0} exchange rates after calculations and filtering", rates.Count));
                }
                var idSched = ForeignExchangeRateManager.GetIdSched(_idCsr, idPricelist, _nmPt, idPt, idPiTemplate,
                                                                    date);
                if (context.RunID != 0)
                {
                    context.RecordInfo(string.Format("Writing rates to schedule: {0}", idSched));
                }
                ForeignExchangeRateManager.WriteRates(_idCsr, idSched, idPt, _nmPt, rates, _srcCurrencyColumn,
                                                      _tgtCurrencyColumn, _rateColumn, _crossCurrencyColumn,
                                                      _crossRateColumn, _providerColumn, _categoryColumn);

                info = "Success";
                _logger.LogInfo(info);
                if (context.RunID != 0)
                {
                    context.RecordInfo(info);
                }
                return info;
            }
            catch (Exception ex)
            {
                _logger.LogException("Error loading exchange rates", ex);
                if (context.RunID != 0)
                {
                    context.RecordWarning(ex.Message);
                }
                throw;
            }
        }

        /// <summary>
        /// Undo or reverse any work done by the adapter during the call to Execute for the same interval or period
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public string Reverse(IRecurringEventRunContext context)
        {
            if (context == null)
            {
                throw new ArgumentNullException("context");
            }

            string info;
            if (context.EventType == RecurringEventType.EndOfPeriod)
            {
                info = string.Format(CultureInfo.InvariantCulture,
                                     "Reversing in EOP mode for Interval {0} and Billing Group {1}",
                                     context.UsageIntervalID, context.BillingGroupID);
                // EOP Adapter code here...
            }
            else
            {
                info = string.Format(CultureInfo.InvariantCulture,
                                     "Reversing in Scheduled mode for Start Date {0} and End Date {1}",
                                     context.StartDate, context.EndDate);
                // Scheduled Adapter code here...
            }

            // Common (EOP/Scheduled) Reverse/Undo code here...

            _logger.LogInfo(info);
            context.RecordInfo(info);

            info = "Success";
            _logger.LogInfo(info);
            context.RecordInfo(info);
            return info;
        }


        /// <summary>
        /// Used to create constraints for adapters that require certain accounts to be in the same
        /// billing group. For example, if the adapter implements logic that should execute on
        /// complete corporate accounts, then all the child accounts should be in the same
        /// billing group.
        /// </summary>
        /// <param name="intervalId">The interval that is being closed</param>
        /// <param name="materializationId">The ID of the materialization that defined the billing group</param>
        public void CreateBillingGroupConstraints(int intervalId, int materializationId)
        {
            throw new InvalidOperationException(string.Concat(MAdapterName,
                                                              ". Create Billing Group Constraints should not have been called: billing group constraints are not enforced by this adapter - check the Has Billing Group Constraints property."));
        }

        /// <summary>
        /// Not implemented
        /// </summary>
        /// <param name="parentRunId">Not implemented</param>
        /// <param name="parentBillingGroupId">Not implemented</param>
        /// <param name="childRunId">Not implemented</param>
        /// <param name="childBillingGroupId">Not implemented</param>
        public void SplitReverseState(int parentRunId, int parentBillingGroupId, int childRunId, int childBillingGroupId)
        {
            //throw new InvalidOperationException(string.Concat(MAdapterName,". Split Reverse State should not have been called: reverse is not needed for this adapter - check the Reversibility property."));
            _logger.LogDebug("Splitting reverse state of ForeignExchangeRateAdapter");
        }

        /// <summary>
        /// Used at the end of the adapter execution to release appropriate resources
        /// </summary>
        public void Shutdown()
        {
            _logger.LogDebug("Shutdown");
        }

        #endregion
    }
}
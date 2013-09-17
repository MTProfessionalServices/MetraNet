using System;
using System.Collections.Generic;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.UsageServer;

namespace MetraTech.ForeignExchange
{
    /// <summary>
    /// Interface for Exchange Rate providers to implement
    /// </summary>
    public interface IForeignExchangeRateProvider
    {
        /// <summary>
        /// Retrieve the base exchange rates
        /// </summary>
        /// <param name="date">The date to fetch for</param>
        /// <param name="context">The run context</param>
        /// <param name="baseCurrencies">The set of base currencies loaded</param>
        /// <returns>The exchange rates</returns>
        List<ExchangeRateDetails> GetExchangeRates(DateTime date, IRecurringEventRunContext context,
                                                   out List<string> baseCurrencies);

        /// <summary>
        /// Initializes the provider with the provided reader.
        /// The reader will be positioned on the ProviderConfig Element, and should be returned with it positioned on the ProviderConfig EndElement
        /// </summary>
        /// <param name="reader">The reader positoned at the ProviderConfig Element</param>
        void Init(XmlReader reader);

        /// <summary>
        /// The name of this provider
        /// </summary>
        string Name { get; }
    }

    /// <summary>
    /// Manages exchange rates
    /// </summary>
    public static class ForeignExchangeRateManager
    {
        /// <summary>
        /// private data members
        /// </summary>
        private static readonly Logger Logger = new Logger("[FXRates]");
		private static int countBatch=2000;

        /// <summary>
        /// Add the inverse rates as rate entries (except for base currencies)
        /// </summary>
        /// <param name="rates">The rate list to use</param>
        /// <param name="baseCurrencies">The set of base currencies</param>
        public static void AddInverseRates(List<ExchangeRateDetails> rates, List<string> baseCurrencies)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            if (baseCurrencies == null)
            {
                throw new ArgumentNullException("baseCurrencies");
            }
            var tmp = new List<ExchangeRateDetails>();
            // 1) loop through all of the rates
            foreach (var rate in rates)
            {
                // 2) add any inverse rates that are not themselves base rates
                if (!(baseCurrencies.Contains(rate.Currency)))
                {
                    if (rate.InverseRate.HasValue && rate.Rate.HasValue && rate.Rate.Value > 0)
                    {
                        tmp.Add(new ExchangeRateDetails
                                    {
                                        BaseCurrency = rate.Currency,
                                        Currency = rate.BaseCurrency,
                                        InverseRate = rate.Rate.Value,
                                        Rate = rate.InverseRate.Value,
                                        Source = rate.Source,
                                        Type = "Inverse"
                                    });
                    }
                }
            }
            rates.AddRange(tmp);
        }

        /// <summary>
        /// If inverse rates are not set, calculate them from the base rates
        /// </summary>
        /// <param name="rates">The rate list to use</param>
        public static void CalculateInverseRates(List<ExchangeRateDetails> rates)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            var cache = new Dictionary<string, Dictionary<string, ExchangeRateDetails>>();
            // 1) loop through all of the rates
            foreach (var rate in rates)
            {
                // 2) build up cache
                if (!cache.ContainsKey(rate.BaseCurrency))
                {
                    cache[rate.BaseCurrency] = new Dictionary<string, ExchangeRateDetails>();
                }
                cache[rate.BaseCurrency][rate.Currency] = rate;
            }
            // 3) loop through all of the rates again
            foreach (var rate in rates)
            {
                // 2) add inverse rates if they are otherwise missing
                if (!(rate.InverseRate.HasValue))
                {
                    if (cache.ContainsKey(rate.Currency) && cache[rate.Currency].ContainsKey(rate.BaseCurrency))
                    {
                        // add inverse base rate if available
                        rate.InverseRate = cache[rate.Currency][rate.BaseCurrency].Rate;
                        Logger.LogDebug(
                            string.Format("Adding inverse rate using corresponding base rate from {0} to {1} of {2}",
                                          rate.BaseCurrency, rate.Currency, rate.InverseRate));
                    }
                    else if (rate.Rate.HasValue && rate.Rate.Value != 0)
                    {
                        // calculate inverse rate otherwise
                        rate.InverseRate = Math.Round(1.0m / rate.Rate.Value, 10);
                        Logger.LogDebug(string.Format(
                            "Adding inverse rate using calculated rate from {0} to {1} of {2}", rate.BaseCurrency,
                            rate.Currency, rate.InverseRate));
                    }
                    else
                    {
                        Logger.LogDebug(string.Format("Unable to add inverse rate for {0} to {1}", rate.BaseCurrency,
                                                      rate.Currency));
                    }
                }
            }
        }

        /// <summary>
        /// Add identity rates for non-base currencies (a 1.0 exchange rate from a currency to itself)
        /// </summary>
        /// <param name="rates">The rate list to use</param>
        /// <param name="baseCurrencies">The base currencies</param>
        public static void AddIdentityRates(List<ExchangeRateDetails> rates, List<string> baseCurrencies)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            if (baseCurrencies == null)
            {
                throw new ArgumentNullException("baseCurrencies");
            }
            var tmp = new List<ExchangeRateDetails>();
            var currencies = new List<string>();
            // 1) loop through all of the rates
            foreach (var rate in rates)
            {
                // 2) add the identity rates (assume base currency rows already exist).  Only add each currency once.
                if (!(baseCurrencies.Contains(rate.Currency) || currencies.Contains(rate.Currency)))
                {
                    currencies.Add(rate.Currency);
                    tmp.Add(new ExchangeRateDetails
                                {
                                    BaseCurrency = rate.Currency,
                                    Currency = rate.Currency,
                                    InverseRate = 1.0m,
                                    Rate = 1.0m,
                                    Source = rate.Source,
                                    Type = "Identity"
                                });
                }
            }
            rates.AddRange(tmp);
        }

        /// <summary>
        /// Calculates cross-rates based on the system currency.
        /// A cross-rate is a conversion between two currencies that goes through a third currency (the system currency)
        /// </summary>
        /// <param name="rates">The rate list to use</param>
        /// <param name="baseCurrencies">The set of base currencies</param>
        /// <param name="systemCurrency">The system currency</param>
        public static void AddCalculatedRates(List<ExchangeRateDetails> rates, List<string> baseCurrencies,
                                              string systemCurrency)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            if (baseCurrencies == null)
            {
                throw new ArgumentNullException("baseCurrencies");
            }
            if (string.IsNullOrEmpty(systemCurrency))
            {
                throw new ArgumentNullException("systemCurrency");
            }
            var tmp = new List<ExchangeRateDetails>();
            var cache = new Dictionary<string, ExchangeRateDetails>();
            // 1) loop through all of the rates
            foreach (ExchangeRateDetails rate in rates)
            {
                // 2) build cache of the system rates (that are not base currencies)
                if (rate.BaseCurrency.Equals(systemCurrency) && !baseCurrencies.Contains(rate.Currency))
                {
                    cache[rate.Currency] = rate;
                }
            }
            // 3) loop through all of the currencies (new base (source) currency)
            foreach (var currency in cache.Keys)
            {
                // 4) loop through all of the currencies again (new target currency)
                foreach (var other in cache.Keys)
                {
                    // 5) if it is not an identity, then add the calculated rate using system currency
                    if (!other.Equals(currency))
                    {
                        var one = cache[currency];
                        var two = cache[other];
                        if (one.Rate.HasValue && one.InverseRate.HasValue && two.Rate.HasValue &&
                            two.InverseRate.HasValue)
                        {
                            var rate1 = Math.Round(two.Rate.Value * one.InverseRate.Value, 10);
                            var inverse1 = Math.Round(two.InverseRate.Value * one.Rate.Value, 10);
                            tmp.Add(new ExchangeRateDetails
                                        {
                                            BaseCurrency = currency,
                                            Currency = other,
                                            InverseRate = inverse1,
                                            Rate = rate1,
                                            Source = one.Source,
                                            Type = "Calculated"
                                        });
                            Logger.LogDebug(string.Format("Adding calculated rate from {0} to {1} via {2} of: {3}",
                                                          other,
                                                          currency, systemCurrency, rate1));
                        }
                    }
                }
            }
            rates.AddRange(tmp);
        }

        /// <summary>
        /// Adds cross-rates using the system currency.
        /// A cross-rate is a conversion between two currencies that goes through a third currency (the system currency)
        /// </summary>
        /// <param name="rates">The rate list to use</param>
        /// <param name="baseCurrencies">The set of base currencies</param>
        /// <param name="systemCurrency">The system currency</param>
        public static void AddCrossRates(List<ExchangeRateDetails> rates, List<string> baseCurrencies,
                                         string systemCurrency)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            if (baseCurrencies == null)
            {
                throw new ArgumentNullException("baseCurrencies");
            }
            if (string.IsNullOrEmpty(systemCurrency))
            {
                throw new ArgumentNullException("systemCurrency");
            }
            var tmp = new List<ExchangeRateDetails>();
            var cache = new Dictionary<string, ExchangeRateDetails>();
            // 1) loop through all of the rates
            foreach (var rate in rates)
            {
                // 2) build cache of the system rates (that are not base currencies)
                if (rate.BaseCurrency.Equals(systemCurrency) && !baseCurrencies.Contains(rate.Currency))
                {
                    cache[rate.Currency] = rate;
                }
            }
            // 3) loop through all of the currencies (new base (source) currency)
            foreach (var currency in cache.Keys)
            {
                // 4) loop through all of the currencies again (new target currency)
                foreach (var other in cache.Keys)
                {
                    // 5) if it is not an identity, then add the cross rate using system currency
                    if (!other.Equals(currency))
                    {
                        var one = cache[currency];
                        var two = cache[other];
                        tmp.Add(new ExchangeRateDetails
                                    {
                                        BaseCurrency = currency,
                                        Currency = other,
                                        CrossCurrency = systemCurrency,
                                        Rate = one.InverseRate,
                                        CrossRate = two.Rate,
                                        Source = one.Source,
                                        Type = "Cross"
                                    });
                    }
                }
            }
            rates.AddRange(tmp);
        }

        /// <summary>
        /// Validate exchange rates for consistency
        /// </summary>
        /// <param name="rates"></param>
        public static void ValidateRates(List<ExchangeRateDetails> rates)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            // 1) loop through all of the rates
            foreach (ExchangeRateDetails rate in rates)
            {
                // 2) ensure rate amounts are valid
                if ((!rate.Rate.HasValue) || rate.Rate.Value <= 0.0m)
                {
                    throw new Exception(string.Format("Invalid exchange rate for {0} to {1}: rate is null or zero",
                                                      rate.Currency, rate.BaseCurrency));
                }
                if ((!rate.InverseRate.HasValue))
                {
                    Logger.LogWarning("Inverse rate is not set, skipping inverse validations");
                    continue;
                }
                if (rate.InverseRate <= 0.0m)
                {
                    throw new Exception(
                        string.Format("Invalid inverse exchange rate for {0} from {1}: rate is not greater than zero",
                                      rate.Currency, rate.BaseCurrency));
                }
            }
        }

        /// <summary>
        /// Filters out rates that do not match the filter
        /// </summary>
        /// <param name="rates">the rates to filter</param>
        /// <param name="filters">the filter to use</param>
        public static void FilterRates(List<ExchangeRateDetails> rates, Dictionary<string, BaseCurrencyFilter> filters)
        {
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            if (filters == null || filters.Count <= 0)
            {
                return;
            }
            var tmp = new List<ExchangeRateDetails>();
            // 1) loop through all of the rates
            foreach (var rate in rates)
            {
                // 2) if the filter does not contain the base rate, then mark it for removal
                if (!filters.ContainsKey(rate.BaseCurrency))
                {
                    tmp.Add(rate);
                }
                else
                {
                    // 3) if the filter for this base currency is set, then ensure the currency is in the currency list, otherwise mark it for removal
                    var currencies = filters[rate.BaseCurrency].CurrencyList;
                    if (currencies != null && currencies.Count > 0 && !currencies.Contains(rate.Currency))
                    {
                        tmp.Add(rate);
                    }
                }
            }
            // 4) loop through all of the tmp rates for removal
            foreach (var rate in tmp)
            {
                // 5) remove the rate
                rates.Remove(rate);
            }
        }

        /// <summary>
        /// Get the id_pricelist for a name
        /// </summary>
        /// <param name="nmPricelist">The pricelist name</param>
        /// <returns>The pricelist id</returns>
        public static int GetIdPricelistByName(string nmPricelist)
        {
            if (string.IsNullOrEmpty(nmPricelist))
            {
                throw new ArgumentNullException("nmPricelist");
            }
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug(string.Format("Retrieving pricelist for: {0}", nmPricelist));
                using (
                    var stmt =
                        conn.CreateAdapterStatement(
                            "SELECT A.id_pricelist FROM T_PRICELIST A INNER JOIN T_BASE_PROPS B ON A.id_pricelist = B.id_prop AND UPPER(B.nm_name) = UPPER('%%NM_NAME%%') AND B.n_kind = 150")
                    )
                {
                    stmt.AddParam("%%NM_NAME%%", nmPricelist);
                    using (var cursor = stmt.ExecuteReader())
                    {
                        var found = false;
                        var idPricelist = -1;
                        while (cursor.Read())
                        {
                            if (found)
                            {
                                throw new Exception(
                                    string.Format("Found multiple pricelists that match pricelist name: {0}",
                                                  nmPricelist));
                            }
                            found = true;
                            if (cursor.IsDBNull(0))
                            {
                                throw new Exception(
                                    string.Format("Could not find pricelist for name: {0} id_pricelist is null",
                                                  nmPricelist));
                            }
                            idPricelist = cursor.GetInt32(0);
                        }
                        if (!found)
                        {
                            throw new Exception(string.Format("Could not find pricelist for name: {0}", nmPricelist));
                        }
                        return idPricelist;
                    }
                }
            }
        }

        /// <summary>
        /// Get the pricelist for an account
        /// </summary>
        /// <param name="nmSpace">The account login namespace</param>
        /// <param name="nmLogin">The account login</param>
        /// <returns>The pricelist id</returns>
        public static int GetIdPricelistByAccount(string nmSpace, string nmLogin)
        {
            if (string.IsNullOrEmpty(nmSpace))
            {
                throw new ArgumentNullException("nmSpace");
            }
            if (string.IsNullOrEmpty(nmLogin))
            {
                throw new ArgumentNullException("nmLogin");
            }
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug(string.Format("Retrieving pricelist for account: {0} in namespace: {1}", nmLogin,
                                              nmSpace));
                using (
                    var stmt =
                        conn.CreateAdapterStatement(
                            "SELECT B.c_pricelist FROM T_ACCOUNT_MAPPER A INNER JOIN T_AV_INTERNAL B ON A.id_acc = B.id_acc AND UPPER(A.nm_space) = UPPER('%%NM_SPACE%%') AND UPPER(A.nm_login) = UPPER('%%NM_LOGIN%%')")
                    )
                {
                    stmt.AddParam("%%NM_SPACE%%", nmSpace);
                    stmt.AddParam("%%NM_LOGIN%%", nmLogin);
                    using (var cursor = stmt.ExecuteReader())
                    {
                        var found = false;
                        var idPricelist = -1;
                        while (cursor.Read())
                        {
                            if (found)
                            {
                                throw new Exception(
                                    string.Format("Found multiple accounts that match login name: {0}/{1}", nmSpace,
                                                  nmLogin));
                            }
                            found = true;
                            if (cursor.IsDBNull(0))
                            {
                                throw new Exception(
                                    string.Format(
                                        "Could not find pricelist for login name: {0}/{1} (c_pricelist is null)",
                                        nmSpace, nmLogin));
                            }
                            idPricelist = cursor.GetInt32(0);
                        }
                        if (!found)
                        {
                            throw new Exception(string.Format("Could not find pricelist for name: {0}/{1}", nmSpace,
                                                              nmLogin));
                        }
                        return idPricelist;
                    }
                }
            }
        }

        /// <summary>
        /// Get the parameter table id for a given name
        /// </summary>
        /// <param name="nmPt">The parameter table name</param>
        /// <returns>The parameter table ID</returns>
        public static int GetIdParamtableByName(string nmPt)
        {
            if (string.IsNullOrEmpty(nmPt))
            {
                throw new ArgumentNullException("nmPt");
            }
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug(string.Format("Retrieving parameter table: {0}", nmPt));
                using (
                    var stmt =
                        conn.CreateAdapterStatement(
                            "SELECT A.id_paramtable FROM T_RULESETDEFINITION A WHERE UPPER(A.nm_instance_tablename) = UPPER('%%NM_PT%%')")
                    )
                {
                    stmt.AddParam("%%NM_PT%%", nmPt);
                    using (var cursor = stmt.ExecuteReader())
                    {
                        var found = false;
                        var idPt = -1;
                        while (cursor.Read())
                        {
                            if (found)
                            {
                                throw new Exception(
                                    string.Format("Found multiple parameter tables that match name: {0}", nmPt));
                            }
                            found = true;
                            if (cursor.IsDBNull(0))
                            {
                                throw new Exception(
                                    string.Format(
                                        "Could not find parameter table for name: {0} id_paramtable is null", nmPt));
                            }
                            idPt = cursor.GetInt32(0);
                        }
                        if (!found)
                        {
                            throw new Exception(string.Format("Could not find parameter table for name: {0}", nmPt));
                        }
                        return idPt;
                    }
                }
            }
        }

        /// <summary>
        /// Retrieve the schedule id
        /// </summary>
        /// <param name="idCsr">The CSR id to use (for auditing)</param>
        /// <param name="idPricelist">The pricelist id</param>
        /// <param name="nmPt">The parameter table name</param>
        /// <param name="idPt">The parameter table id</param>
        /// <param name="idPiTemplate">The Priceable Item Template ID</param>
        /// <param name="date">The effective date</param>
        /// <returns>The schedule id</returns>
        public static int GetIdSched(int idCsr, int idPricelist, string nmPt, int idPt, int idPiTemplate,
                                     DateTime date)
        {
            var dtStart = date;
            var dtEnd = dtStart.AddDays(1).AddSeconds(-1);

            var idSched = -1;
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug("Looking for existing schedule");
                using (
                    var stmt =
                        conn.CreateAdapterStatement(
                            "SELECT A.id_sched FROM T_RSCHED A INNER JOIN T_EFFECTIVEDATE B ON A.id_eff_date = B.id_eff_date WHERE A.id_pricelist = %%ID_PRICELIST%% AND A.id_pt = %%ID_PT%% AND A.id_pi_template = %%ID_PI_TEMPLATE%% AND B.n_begintype = 1 AND B.n_endtype = 1 AND B.dt_start = %%DT_START%% AND B.dt_end = %%DT_END%%")
                    )
                {
                    stmt.AddParam("%%ID_PRICELIST%%", idPricelist);
                    stmt.AddParam("%%ID_PT%%", idPt);
                    stmt.AddParam("%%ID_PI_TEMPLATE%%", idPiTemplate);
                    stmt.AddParam("%%DT_START%%", dtStart);
                    stmt.AddParam("%%DT_END%%", dtEnd);
                    using (var cursor = stmt.ExecuteReader())
                    {
                        var found = false;
                        while (cursor.Read())
                        {
                            if (found)
                            {
                                throw new Exception(string.Format("Found multiple schedules that match date: {0}",
                                                                  date));
                            }
                            found = true;
                            if (cursor.IsDBNull(0))
                            {
                                throw new Exception(
                                    string.Format("Could not find schedule for date: {0} id_sched is null", date));
                            }
                            idSched = cursor.GetInt32(0);
                        }
                        if (found)
                        {
                            Logger.LogInfo(string.Format("Found existing schedule (id_sched={0})", idSched));
                            return idSched;
                        }
                    }
                }
                Logger.LogDebug("No schedule found, creating a new one");
                // if no schedule found, need to create one
                // this involves both a schedule row, and an effective date row
                // both of those each require a t_base_props row
                // 1) insert the t_base_props for schedule
                try
                {
                    using (var stmt = conn.CreateCallableStatement("InsertBasePropsV2"))
                    {
                        stmt.AddParam("id_lang_code", MTParameterType.Integer, 840);
                        stmt.AddParam("a_kind", MTParameterType.Integer, 130);
                        stmt.AddParam("a_approved", MTParameterType.WideString, "N");
                        stmt.AddParam("a_archive", MTParameterType.WideString, "N");
                        stmt.AddParam("a_nm_name", MTParameterType.WideString, null);
                        stmt.AddParam("a_nm_desc", MTParameterType.WideString, null);
                        stmt.AddParam("a_nm_display_name", MTParameterType.WideString, null);
                        stmt.AddOutputParam("a_id_prop", MTParameterType.Integer);
                        stmt.ExecuteNonQuery();
                        idSched = (int)stmt.GetOutputValue("a_id_prop");
                    }
                }
                catch (Exception ex)
                {
                    Logger.LogException("Error inserting property for rate schedule", ex);
                    throw new Exception(string.Format("Error inserting property for rate schedule: {0}", ex.Message), ex);
                }

                int idDate;
                // 2) insert the t_base_props for schedule
                try
                {
                    using (var stmt = conn.CreateCallableStatement("InsertBasePropsV2"))
                    {
                        stmt.AddParam("id_lang_code", MTParameterType.Integer, 840);
                        stmt.AddParam("a_kind", MTParameterType.Integer, 160);
                        stmt.AddParam("a_approved", MTParameterType.WideString, "N");
                        stmt.AddParam("a_archive", MTParameterType.WideString, "N");
                        stmt.AddParam("a_nm_name", MTParameterType.WideString, null);
                        stmt.AddParam("a_nm_desc", MTParameterType.WideString, null);
                        stmt.AddParam("a_nm_display_name", MTParameterType.WideString, null);
                        stmt.AddOutputParam("a_id_prop", MTParameterType.Integer);
                        stmt.ExecuteNonQuery();
                        idDate = (int)stmt.GetOutputValue("a_id_prop");
                    }
                }
                catch (Exception ex)
                {
                    Logger.LogException("Error inserting property for effective date", ex);
                    throw new Exception(string.Format("Error inserting property for effective date: {0}", ex.Message), ex);
                }

                // 3) get id_audit
                var handler = new AuditEventHandler();
                var auditEvent = new AuditEvent
                                     {
                                         EventId = 1400,
                                         UserId = idCsr,
                                         EntityTypeId = 2,
                                         EntityId = idSched,
                                         Details =
                                             string.Format("Adding schedule for pt: {0} Rate Schedule Id: {1}", nmPt,
                                                           idSched),
                                         Success = true
                                     };

                handler.HandleEvent(auditEvent);

                // 4) insert effective date
                using (var stmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_EFF_DATE__"))
                {
                    stmt.AddParam("%%ID_EFF_DATE%%", idDate);
                    stmt.AddParam("%%START_DATE%%", dtStart);
                    stmt.AddParam("%%END_DATE%%", dtEnd);

                    stmt.AddParam("%%BEGIN_TYPE%%", 1);
                    stmt.AddParam("%%BEGIN_OFFSET%%", 0);
                    stmt.AddParam("%%END_TYPE%%", 1);
                    stmt.AddParam("%%END_OFFSET%%", 0);

                    var res = stmt.ExecuteNonQuery();
                    if (res != 1)
                    {
                        throw new Exception(string.Format("INSERT INTO T_EFFECTIVEDATE failed: {0}", res));
                    }
                }

                // 5) insert schedule
                using (var stmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_RSCHED_PCWS__"))
                {
                    stmt.AddParam("%%ID_SCHED%%", idSched);
                    stmt.AddParam("%%ID_PT%%", idPt);
                    stmt.AddParam("%%ID_EFFDATE%%", idDate);
                    stmt.AddParam("%%PRICELIST_ID%%", idPricelist);
                    stmt.AddParam("%%ID_TMPL%%", idPiTemplate);
                    stmt.AddParam("%%SYS_DATE%%", MetraTime.Now);

                    var res = stmt.ExecuteNonQuery();
                    if (res != 1)
                    {
                        throw new Exception(string.Format("INSERT INTO T_EFFECTIVEDATE failed: {0}", res));
                    }
                }
                Logger.LogInfo(string.Format("Added new schedule (id_sched={0})", idSched));
            }
            return idSched;
        }

        /// <summary>
        /// Get the Priceable Item Template ID
        /// </summary>
        /// <param name="idPricelist">The pricelist id to use</param>
        /// <param name="idPt">The parameter table id to use</param>
        /// <param name="nmPt">The parameter table name to use</param>
        /// <returns>The Priceable Item Template ID</returns>
        public static int GetIdPiTemplate(int idPricelist, int idPt, string nmPt)
        {
            if (string.IsNullOrEmpty(nmPt))
            {
                throw new ArgumentNullException("nmPt");
            }
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug(string.Format("Retrieving id_pi_template for: {0}", nmPt));
                using (
                    var stmt =
                        conn.CreateAdapterStatement(
                            "SELECT DISTINCT id_pi_template FROM T_RSCHED A WHERE A.id_pt = %%ID_PT%% AND A.id_pricelist = %%ID_PRICELIST%%")
                    )
                {
                    stmt.AddParam("%%ID_PT%%", idPt);
                    stmt.AddParam("%%ID_PRICELIST%%", idPricelist);
                    using (var cursor = stmt.ExecuteReader())
                    {
                        var found = false;
                        var idPiTemplate = -1;
                        while (cursor.Read())
                        {
                            if (found)
                            {
                                throw new Exception(
                                    string.Format("Found multiple PI templates that match paramtable name: {0}",
                                                  nmPt));
                            }
                            found = true;
                            if (cursor.IsDBNull(0))
                            {
                                throw new Exception(
                                    string.Format(
                                        "Could not find PI Template for parameter table name: {0} id_pi_template is null",
                                        nmPt));
                            }
                            idPiTemplate = cursor.GetInt32(0);
                        }
                        if (!found)
                        {
                            throw new Exception(
                                string.Format("Could not find PI Template for parameter table name: {0}", nmPt));
                        }
                        return idPiTemplate;
                    }
                }
            }
        }

        /// <summary>
        /// Validates the columns on a parameter table
        /// </summary>
        /// <param name="nmPt">The parameter table name</param>
        /// <param name="srcCurrencyColumn">Name of the column to store the source currency</param>
        /// <param name="tgtCurrencyColumn">Name of the column to store the target currency</param>
        /// <param name="rateColumn">Name of the column to store the rate</param>
        /// <param name="crossCurrencyColumn">Name of the column to store the cross currency</param>
        /// <param name="crossRateColumn">Name of the column to store the cross rate</param>
        /// <param name="providerColumn">Name of the column to store the source/provider of the rates</param>
        /// <param name="categoryColumn">Name of the column to store the rate category</param>
        public static void ValidateParameterTable(string nmPt, string srcCurrencyColumn, string tgtCurrencyColumn,
                                                  string rateColumn,
                                                  string crossCurrencyColumn = null, string crossRateColumn = null,
                                                  string providerColumn = null, string categoryColumn = null)
        {
            if (string.IsNullOrEmpty(nmPt))
            {
                throw new ArgumentNullException("nmPt");
            }
            var columns = new List<string>();
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug(string.Format("Retrieving parameter table columns: {0}", nmPt));
                using (
                    var stmt =
                        conn.CreateAdapterStatement(
                            "select b.nm_column_name from t_rulesetdefinition a inner join t_param_table_prop b on a.id_paramtable = b.id_param_table where UPPER(A.nm_instance_tablename) = UPPER('%%NM_PT%%')")
                    )
                {
                    stmt.AddParam("%%NM_PT%%", nmPt);
                    using (var cursor = stmt.ExecuteReader())
                    {
                        while (cursor.Read())
                        {
                            if (cursor.IsDBNull(0))
                            {
                                throw new Exception(
                                    string.Format(
                                        "Could not find parameter table column name: {0} nm_column_name is null",
                                        nmPt));
                            }
                            columns.Add(cursor.GetString(0).ToUpper());
                        }
                    }
                }
            }
            if (!columns.Contains(srcCurrencyColumn.ToUpper()))
            {
                throw new Exception(string.Format(
                    "SourceCurrency column ({0}) does not exist in parameter table ({1})", srcCurrencyColumn, nmPt));
            }
            if (!columns.Contains(tgtCurrencyColumn.ToUpper()))
            {
                throw new Exception(string.Format(
                    "TargetCurrency column ({0}) does not exist in parameter table ({1})", tgtCurrencyColumn, nmPt));
            }
            if (!columns.Contains(rateColumn.ToUpper()))
            {
                throw new Exception(string.Format("Rate column ({0}) does not exist in parameter table ({1})",
                                                  rateColumn, nmPt));
            }
            if (!(string.IsNullOrEmpty(crossCurrencyColumn) || columns.Contains(crossCurrencyColumn.ToUpper())))
            {
                throw new Exception(string.Format("CrossCurrency column ({0}) does not exist in parameter table ({1})",
                                                  crossCurrencyColumn, nmPt));
            }
            if (!(string.IsNullOrEmpty(crossRateColumn) || columns.Contains(crossRateColumn.ToUpper())))
            {
                throw new Exception(string.Format("CrossRate column ({0}) does not exist in parameter table ({1})",
                                                  crossRateColumn, nmPt));
            }
            if (!(string.IsNullOrEmpty(providerColumn) || columns.Contains(providerColumn.ToUpper())))
            {
                throw new Exception(string.Format("Provider column ({0}) does not exist in parameter table ({1})",
                                                  providerColumn, nmPt));
            }
            if (!(string.IsNullOrEmpty(categoryColumn) || columns.Contains(categoryColumn.ToUpper())))
            {
                throw new Exception(string.Format("Category column ({0}) does not exist in parameter table ({1})",
                                                  categoryColumn, nmPt));
            }
        }

        /// <summary>
        /// Write the rates to the DB
        /// </summary>
        /// <param name="idCsr">The CSR id to use (for audit)</param>
        /// <param name="idSched">The rate schedule id</param>
        /// <param name="idPt">The parameter table id</param>
        /// <param name="nmPt">The parameter table name</param>
        /// <param name="rates">The rates</param>
        /// <param name="srcCurrencyColumn">Name of the column to store the source currency</param>
        /// <param name="tgtCurrencyColumn">Name of the column to store the target currency</param>
        /// <param name="rateColumn">Name of the column to store the rate</param>
        /// <param name="crossCurrencyColumn">Name of the column to store the cross currency</param>
        /// <param name="crossRateColumn">Name of the column to store the cross rate</param>
        /// <param name="providerColumn">Name of the column to store the source/provider of the rates</param>
        /// <param name="categoryColumn">Name of the column to store the rate category</param>
        public static void WriteRates(int idCsr, int idSched, int idPt, string nmPt, List<ExchangeRateDetails> rates,
                                      string srcCurrencyColumn, string tgtCurrencyColumn, string rateColumn,
                                      string crossCurrencyColumn = null, string crossRateColumn = null,
                                      string providerColumn = null, string categoryColumn = null)
        {
            if (string.IsNullOrEmpty(nmPt))
            {
                throw new ArgumentNullException("nmPt");
            }
            if (rates == null)
            {
                throw new ArgumentNullException("rates");
            }
            var now = MetraTime.Now;
            // 1) end old rates
            using (var conn = ConnectionManager.CreateConnection())
            {
                Logger.LogDebug("Ending old rates...");
                try
                {
                    using (
                        var stmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                               "__SET_ENDDATE_FOR_CURRENT_RATES_PCWS__"))
                    {
                        stmt.AddParam("%%TABLE_NAME%%", nmPt);
                        stmt.AddParam("%%ID_SCHED%%", idSched);
                        stmt.AddParam("%%TT_START%%", now);

                        var rc = stmt.ExecuteNonQuery();
                        Logger.LogInfo(string.Format("End dated {0} rows for {1} with id_sched = {2}", rc, nmPt,
                                                     idSched));
                    }
                }
                catch (Exception ex)
                {
                    Logger.LogException("Error ceasing rate entries", ex);
                    throw new Exception(string.Format("Error ceasing rate entries: {0}", ex.Message), ex);
                }

                // 2) add audit row
                var handler = new AuditEventHandler();
                var auditEvent = new AuditEvent
                                     {
                                         EventId = 1402,
                                         UserId = idCsr,
                                         EntityTypeId = 2,
                                         EntityId = idSched,
                                         Details =
                                             string.Format("Updating rules for param table: {0} Rate Schedule Id: {1}",
                                                           nmPt,
                                                           idSched),
                                         Success = true
                                     };

                handler.HandleEvent(auditEvent);

                var idAudit = auditEvent.AuditId;

                // 3) insert new rates
                if (rates.Count > 0)
                {
                    var count = 0;
					var j = 0;
                    Logger.LogDebug("Inserting new rates...");
                    var insert =
                        string.Format("INSERT INTO {0} (id_sched, id_audit, n_order, tt_start, tt_end, {1}, {2}, {3}",
                                      nmPt, srcCurrencyColumn, tgtCurrencyColumn, rateColumn);
                    var values =
                        ") VALUES(%%ID_SCHED%%, %%ID_AUDIT%%, %%N_ORDER%%, %%TT_START%%, %%TT_END%%, %%SRC_CURRENCY%%, %%TGT_CURRENCY%%, %%RATE%%";
                    if (!string.IsNullOrEmpty(crossCurrencyColumn))
                    {
                        insert = insert + ", " + crossCurrencyColumn;
                        values = values + ", %%CROSS_CURRENCY%%";
                    }
                    if (!string.IsNullOrEmpty(crossRateColumn))
                    {
                        insert = insert + ", " + crossRateColumn;
                        values = values + ", %%CROSS_RATE%%";
                    }
                    if (!string.IsNullOrEmpty(providerColumn))
                    {
                        insert = insert + ", " + providerColumn;
                        values = values + ", %%PROVIDER%%";
                    }
                    if (!string.IsNullOrEmpty(categoryColumn))
                    {
                        insert = insert + ", " + categoryColumn;
                        values = values + ", %%CATEGORY%%";
                    }
                    const string end = ")";
                    var queryBatch = "BEGIN\n";
                    // 3a) build up query batch
					Logger.LogInfo("Count rates:" + rates.Count.ToString());
                    foreach (var rate in rates)
                    {
                        if (rate.BaseCurrencyEnum.HasValue && rate.CurrencyEnum.HasValue && rate.Rate.HasValue)
                        {
                            using (var stmt = conn.CreateAdapterStatement(insert + values + end))
                            {
                                stmt.AddParam("%%ID_SCHED%%", idSched);
                                stmt.AddParam("%%ID_AUDIT%%", idAudit);
                                stmt.AddParam("%%N_ORDER%%", j * countBatch + count);
                                stmt.AddParam("%%TT_START%%", now);
                                stmt.AddParam("%%TT_END%%", MetraTime.Max);
                                stmt.AddParam("%%SRC_CURRENCY%%",
                                              string.Format("{0}",
                                                            EnumHelper.GetDbValueByEnum(rate.BaseCurrencyEnum.Value)));
                                stmt.AddParam("%%TGT_CURRENCY%%",
                                              string.Format("{0}", EnumHelper.GetDbValueByEnum(rate.CurrencyEnum.Value)));
                                stmt.AddParam("%%RATE%%", rate.Rate.Value);
                                if (!string.IsNullOrEmpty(crossCurrencyColumn))
                                {
                                    if (!rate.CrossCurrencyEnum.HasValue)
                                    {
                                        stmt.OmitParam("%%CROSS_CURRENCY%%");
                                    }
                                    else
                                    {
                                        stmt.AddParam("%%CROSS_CURRENCY%%", rate.CrossCurrencyEnum.Value);
                                    }
                                }
                                if (!string.IsNullOrEmpty(crossRateColumn))
                                {
                                    if (!rate.CrossRate.HasValue)
                                    {
                                        stmt.OmitParam("%%CROSS_RATE%%");
                                    }
                                    else
                                    {
                                        stmt.AddParam("%%CROSS_RATE%%", rate.CrossRate.Value);
                                    }
                                }
                                if (!string.IsNullOrEmpty(providerColumn))
                                {
                                    if (string.IsNullOrEmpty(rate.Source))
                                    {
                                        stmt.OmitParam("%%PROVIDER%%");
                                    }
                                    else
                                    {
                                        stmt.AddParam("%%PROVIDER%%", rate.Source);
                                    }
                                }
                                if (!string.IsNullOrEmpty(categoryColumn))
                                {
                                    if (string.IsNullOrEmpty(rate.Type))
                                    {
                                        stmt.OmitParam("%%CATEGORY%%");
                                    }
                                    else
                                    {
                                        stmt.AddParam("%%CATEGORY%%", rate.Type);
                                    }
                                }
                                Logger.LogInfo(stmt.Query);
                                queryBatch += string.Format("{0};\n", stmt.Query);
                                count++;
                            }

                            if (count == countBatch || j * countBatch + count >= rates.Count)
                            {
                                queryBatch += "\nEND;";
                                // 3b) execute query batch
                                try
                                {
                                    using (var stmt = conn.CreateStatement(queryBatch))
                                    {
                                        stmt.ExecuteNonQuery();
                                    }
                                }
                                catch (Exception ex)
                                {
                                    Logger.LogException("Error inserting rate entries", ex);
                                    throw new Exception(string.Format("Error inserting rate entries: {0}", ex.Message), ex);
                                }
                                Logger.LogInfo(string.Format("Added {0} row[s] to {1} ({3}) with id_sched = {2}", count, nmPt,
                                                        idSched, idPt));
                                queryBatch = "BEGIN\n";
                                count = 0;
                                j++;
                            }
                        }
                    }		 
                }
                else
                {
                    Logger.LogWarning("No rates to insert.");
                }
            }
        }
    }

    /// <summary>
    /// Simple class to hold exchange rate details
    /// </summary>
    public class ExchangeRateDetails
    {
        /// <summary>
        /// This is the base currency (aka, source currency)
        /// </summary>
        public string BaseCurrency
        {
            get
            {
                return BaseCurrencyEnum.HasValue ? BaseCurrencyEnum.Value.ToString() : null;
            }
            set
            {
                var x = EnumHelper.GetGeneratedEnumByEntry(typeof(SystemCurrencies), value);
                if (x == null)
                {
                    throw new Exception(string.Format("Unknown currency: {0}", value));
                }
                BaseCurrencyEnum = (SystemCurrencies)x;
            }
        }

        /// <summary>
        /// The BaseCurrency as an enum
        /// </summary>
        public SystemCurrencies? BaseCurrencyEnum { get; set; }

        /// <summary>
        /// This is the cross currency (aka, system currency)
        /// </summary>
        public string CrossCurrency
        {
            get
            {
                return CrossCurrencyEnum.HasValue ? CrossCurrencyEnum.Value.ToString() : null;
            }
            set
            {
                var x = EnumHelper.GetGeneratedEnumByEntry(typeof(SystemCurrencies), value);
                if (x == null)
                {
                    throw new Exception(string.Format("Unknown currency: {0}", value));
                }
                CrossCurrencyEnum = (SystemCurrencies)x;
            }
        }

        /// <summary>
        /// The CrossCurrency as an enum
        /// </summary>
        public SystemCurrencies? CrossCurrencyEnum { get; set; }

        /// <summary>
        /// This is the target currency
        /// </summary>
        public string Currency
        {
            get
            {
                return CurrencyEnum.HasValue ? CurrencyEnum.Value.ToString() : null;
            }
            set
            {
                var x = EnumHelper.GetGeneratedEnumByEntry(typeof(SystemCurrencies), value);
                if (x == null)
                {
                    throw new Exception(string.Format("Unknown currency: {0}", value));
                }
                CurrencyEnum = (SystemCurrencies)x;
            }
        }

        /// <summary>
        /// The Currency as an enum
        /// </summary>
        public SystemCurrencies? CurrencyEnum { get; set; }

        /// <summary>
        /// This is the exchange rate for converting Currency into BaseCurrency
        /// </summary>
        public decimal? Rate { get; set; }

        /// <summary>
        /// This is the second exchange rate to be used for cross rates
        /// </summary>
        public decimal? CrossRate { get; set; }

        /// <summary>
        /// This is the inverse exchange rate for converting BaseCurrency back into Currency
        /// </summary>
        public decimal? InverseRate { get; set; }

        /// <summary>
        /// This is the type of exchange rate:
        /// - Base - a base exchange rate
        /// - Identity - 1.0, e.g., USD -> USD is 1.0 exchange rate
        /// - Inverse - This is a copy of the inverse rate
        /// - Calculated - A blended rate of Source -> SystemCurrency -> Target
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// Which system did this exchange rate originate from
        /// </summary>
        public string Source { get; set; }

        public bool ValidCurrency(string currency)
        {
            var x = EnumHelper.GetGeneratedEnumByEntry(typeof(SystemCurrencies), currency);
            return x != null;
        }
    }

    /// <summary>
    /// Simple class to store currency filters
    /// if the BaseCurrency to Currency does not exist (unless CurrencyList is null) then it will be removed
    /// </summary>
    public class BaseCurrencyFilter
    {
        /// <summary>
        /// The valid list of target currencies (or null for all)
        /// </summary>
        public List<string> CurrencyList { get; set; }

        /// <summary>
        /// The base currency
        /// </summary>
        public string BaseCurrency { get; set; }

        /// <summary>
        /// add a target currency
        /// </summary>
        /// <param name="currency"></param>
        public void AddCurrency(string currency)
        {
            if (CurrencyList == null)
            {
                CurrencyList = new List<string>();
            }
            CurrencyList.Add(currency);
        }
    }
}
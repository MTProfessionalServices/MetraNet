using System;
using System.Collections.Generic;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;

namespace MetraTech.Tax.Framework.MetraTax
{
    /// <summary>
    /// This class knows the details of the MetraTax parametertables t_pt_taxBand and t_pt_taxRate.
    /// </summary>
    class TaxRateScheduleManager
    {
        // Logger
        static private readonly Logger mLogger = new Logger("[MetraTax]");

        // A dictionary of holding rates schedules for t_pt_taxBand.
        // Index is the rate schedule ID.
        private readonly MultiValueDictionary<int, TaxBandRateScheduleRow> m_taxBandRateScheduleDict;

        // A dictionary of holding rates schedules for t_pt_taxRate.
        // Index is the rate schedule ID.
        private readonly MultiValueDictionary<int, TaxRateRateScheduleRow> m_taxRateRateScheduleDict;

        /// <summary>
        /// Constructor
        /// </summary>
        public TaxRateScheduleManager()
        {
            m_taxBandRateScheduleDict = new MultiValueDictionary<int, TaxBandRateScheduleRow>();
            m_taxRateRateScheduleDict = new MultiValueDictionary<int, TaxRateRateScheduleRow>();
        }

        /// <summary>
        /// Given the rate schedule to use for parameter table taxBand, find the tax band
        /// associated with productCode and country.  Throws an exception if not found.
        /// </summary>
        /// <param name="scheduleId">id for rate schedule</param>
        /// <param name="productCode">the product code -- should match product code in taxBand param table</param>
        /// <param name="countryCode">a country code (may or maynot be the global MetraTech country code)</param>
        /// <param name="auditID">identifies the particular edited version of the rate schedule</param>
        /// <returns>an enum of type MetraTax/Tax Band </returns>
        public TaxBand GetTaxBand(int scheduleId, string productCode, int countryCode, out int auditID)
        {
            LoadTaxBandRateSchedule(scheduleId); // If not already there, load schedule in dictionary.

            HashSet<TaxBandRateScheduleRow> hashSet = m_taxBandRateScheduleDict.GetValues(scheduleId, true);

            if (hashSet.Count <= 0)
            {
                string errMsg = "Unable to find the tax band using rate schedule ID " + scheduleId +
                                " because there are no rows stored in the database for the rate schedule.";
                mLogger.LogError(errMsg);
                throw new TaxException(errMsg);
            }

            // we will match the product code regardless of upper/lowercase
            productCode = productCode.ToLower();

            // iterate through the rows until we find one matching the produceCode and country.
            foreach (var taxBandRateScheduleRow in hashSet)
            {
                if (taxBandRateScheduleRow.CountryCode == countryCode &&
                    (taxBandRateScheduleRow.ProductCode.Equals(productCode) || taxBandRateScheduleRow.ProductCode.Length <= 0))
                {
                    auditID = taxBandRateScheduleRow.AuditId;
                    mLogger.LogDebug("Using tax band: " + taxBandRateScheduleRow.TaxBand + " " +
                                     "for product " + productCode + " country: " + countryCode + " auditID: " + auditID);

                    // If we matched due to no product code, log this to aid in debugging.
                    if (taxBandRateScheduleRow.ProductCode.Length <= 0)
                        mLogger.LogDebug("This matched because the product code in the parameter table was empty.");

                    return taxBandRateScheduleRow.TaxBand;
                }
            }


            string errMsg2 = "Unable to find the tax band for a product/country.  " + 
                             "Examine the TaxBand parameter table.  Product: " + productCode +
                             " country: " + countryCode + 
                             " rate Schedule: " + scheduleId;
       
            mLogger.LogError(errMsg2);
            throw new TaxException(errMsg2);
        }

        /// <summary>
        /// Given the rate schedule to use for parameter table taxRate, find the tax rate
        /// associated with country, country tax zone, and tax band.  Throws an exception if not found.
        /// </summary>
        /// <param name="scheduleId"></param>
        /// <param name="zone">an enum of type MetraTax/Tax Zone </param>
        /// <param name="taxBand">an enum of type MetraTax/Tax Band </param>
        /// <param name="countryCode">may or may not be global MetraTech country code</param>
        /// <param name="taxName">An output giving the name of the selected tax band for
        ///                       the rate.  This comes from the configured value in the PT TaxRate.
        ///                       If exempt, the tax name is "Exempt".</param>
        /// <param name="auditID">identifies the particular edited version of the rate schedule</param>
        /// <returns>decimal tax rate (.25 = 25%)</returns>
        public decimal GetTaxRate(int scheduleId, int countryCode, TaxZone zone, TaxBand taxBand, out string taxName, out int auditID)
        {
            mLogger.LogDebug("Looking for the tax rate for tax band: " + taxBand + " " +
                             "country: " + countryCode + " zone: " + zone);

            // If the taxBand is exempt, the tax rate if fixed at 0.
            // We do NOT look that up.
            if (taxBand == TaxBand.Exempt) 
            {
                mLogger.LogDebug("The tax rate 0.0 since this is exempt.");
                taxName = "Exempt";
                auditID = 0;
                return 0.0m;
            }

            LoadTaxRateRateSchedule(scheduleId); // If not already there, load schedule in dictionary.

            HashSet<TaxRateRateScheduleRow> hashSet = m_taxRateRateScheduleDict.GetValues(scheduleId, true);

            if (hashSet.Count <= 0)
            {
                string errMsg = "Unable to find the tax rate using rate schedule ID " + scheduleId +
                                " because there are no rows stored in the database for the rate schedule.";
                mLogger.LogError(errMsg);
                throw new TaxException(errMsg);
            }

            // iterate through the rows until we find one matching the produceCode and country.
            foreach (var taxRateRateScheduleRow in hashSet)
            {
                if (taxRateRateScheduleRow.CountryCode == countryCode &&
                    taxRateRateScheduleRow.TaxZone == zone &&
                    taxRateRateScheduleRow.TaxBand == taxBand)
                {
                    auditID = taxRateRateScheduleRow.AuditId;
                    mLogger.LogDebug("Using tax rate: " + taxRateRateScheduleRow.TaxRate + 
                                     " for tax band: " + taxBand + " " +
                                     " country: " + countryCode + " " +
                                     " zone: " + zone + 
                                     " name: " + taxRateRateScheduleRow.TaxName +
                                     " auditID: " + auditID);
                    taxName = taxRateRateScheduleRow.TaxName;
                    return taxRateRateScheduleRow.TaxRate;
                }
            }

            string errMsg2 = "Unable to find the tax rate for a given TaxBand/Country/Zone. " +
                             "Examine the TaxRate parameter table. " + 
                             "Tax Band: " + taxBand + " " + 
                             "Country: " + countryCode + " " + 
                             "Zone: " + zone + " " +
                             "Rate Schedule: " + scheduleId;

            mLogger.LogError(errMsg2);
            throw new TaxException(errMsg2);
        }

        /// <summary>
        /// Load the given rate schedule into our dictionary of taxBand rate schedules.
        /// </summary>
        /// <param name="rateScheduleId"></param>
        public void LoadTaxBandRateSchedule(int rateScheduleId)
        {
            IMTConnection dbConnection = null;

            // Maybe we already have the rate schedule
            if (m_taxBandRateScheduleDict.ContainsKey(rateScheduleId))
            {
                return;
            }

            mLogger.LogDebug("Loading taxBand rate schedule " + rateScheduleId + " into memory.");
 
            try
            {
                // Set up the connection and the query
                dbConnection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = dbConnection.CreateAdapterStatement(@"Queries\Tax\MetraTax", "__GET_TAX_BAND_RATE_SCHEDULE__");
                statement.AddParam("%%ID_SCHED%%", rateScheduleId);

                //pendingRequest.CreditCardType = (MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)EnumHelper.GetCSharpEnum(rdr.GetInt32("id_creditcard_type"));

                // Execute the query and read the results
                IMTDataReader reader = statement.ExecuteReader();
                while (reader.Read())
                {
                    TaxBandRateScheduleRow scheduleRow = new TaxBandRateScheduleRow();
                    scheduleRow.Id = rateScheduleId;
                    scheduleRow.CountryCode = reader.GetInt32("c_Country");

                    // A null product code is acceptable. Means matches all products.
                    if (reader.IsDBNull("c_ProductCode"))
                    {
                        scheduleRow.ProductCode = "";
                    }
                    else
                    {
                        scheduleRow.ProductCode = reader.GetString("c_ProductCode");
                    }

                    scheduleRow.TaxBand = (TaxBand)EnumHelper.GetCSharpEnum(reader.GetInt32("c_TaxBand"));
                    scheduleRow.AuditId = reader.GetInt32("id_audit");

                    mLogger.LogDebug("Loaded taxBand entry: country: " + scheduleRow.CountryCode + " product code: " + scheduleRow.ProductCode + " Tax Band: " + scheduleRow.TaxBand +
                                     " ID Audit: " + scheduleRow.AuditId);

                    // Store the scheduleRow in the dictionary
                    m_taxBandRateScheduleDict.Add(scheduleRow.Id, scheduleRow);

                }
            }
            catch (Exception e)
            {
                mLogger.LogError("An error occurred attempting to read taxBand rate schedule: " + e.Message);
                throw new TaxException(e.Message);
            }

            // Silently, close the database connection
            finally
            {
                try
                {
                    if (dbConnection != null)
                        dbConnection.Close();
                }
                catch (Exception)
                {
                }
            }
        }

        /// <summary>
        /// Load the given taxRate schedule into our dictionary of taxBand rate schedules.
        /// </summary>
        /// <param name="rateScheduleId"></param>
        public void LoadTaxRateRateSchedule(int rateScheduleId)
        {
            IMTConnection dbConnection = null;

            // Maybe we already have the rate schedule
            if (m_taxRateRateScheduleDict.ContainsKey(rateScheduleId))
            {
                return;
            }

            mLogger.LogDebug("Loading taxRate rate schedule " + rateScheduleId + " into memory.");

            try
            {
                // Set up the connection and the query
                dbConnection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = dbConnection.CreateAdapterStatement(@"Queries\Tax\MetraTax",
                                                                                "__GET_TAX_RATE_RATE_SCHEDULE__");
                statement.AddParam("%%ID_SCHED%%", rateScheduleId);

                // Execute the query and read the results
                IMTDataReader reader = statement.ExecuteReader();
                while (reader.Read())
                {
                    TaxRateRateScheduleRow scheduleRow = new TaxRateRateScheduleRow();
                    scheduleRow.Id = rateScheduleId;
                    scheduleRow.CountryCode = reader.GetInt32("c_Country");
                    scheduleRow.TaxZone = (TaxZone) EnumHelper.GetCSharpEnum(reader.GetInt32("c_TaxZone"));
                    scheduleRow.TaxRate = reader.GetDecimal("c_TaxRate");
                    scheduleRow.TaxBand = (TaxBand) EnumHelper.GetCSharpEnum(reader.GetInt32("c_TaxBand"));
                    scheduleRow.TaxName = reader.GetString("c_TaxName");
                    scheduleRow.AuditId = reader.GetInt32("id_audit");

                    mLogger.LogDebug("Loaded taxRate entry: country: " + scheduleRow.CountryCode + " tax zone: " + scheduleRow.TaxZone +
                                     " Tax Band: " + scheduleRow.TaxBand + " Tax Rate: " + scheduleRow.TaxRate + " Tax Name: " + scheduleRow.TaxName +
                                     " AuditID: " + scheduleRow.AuditId);
 
                    // Store the scheduleRow in the dictionary
                    m_taxRateRateScheduleDict.Add(scheduleRow.Id, scheduleRow);
                }
            }
            catch (Exception e)
            {
                mLogger.LogException("An error occurred attempting to read taxRate rate schedule: " , e);
                throw new TaxException("Error Loading Tax Rate Schedule",e);
            }

                // Silently, close the database connection
            finally
            {
                try
                {
                    if (dbConnection != null)
                        dbConnection.Close();
                }
                catch (Exception)
                {
                }
            }
        }

    }
}

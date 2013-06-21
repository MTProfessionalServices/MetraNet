using System;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DataAccess;

namespace MetraTech.Tax.Framework.MetraTax
{
    /// <summary>
    /// Given an account ID, retrieves values
    /// from the account about taxes.  These values
    /// are coming from the internal account view.
    /// This class caches the last account read.
    /// By caching one account, if process all the tax
    /// records for an account sequently, we don't have
    /// to reread from the database.
    /// </summary>
    public class TaxAccountViewReader
    {
        // Logger
        private static readonly Logger mLogger = new Logger("[MetraTax]");

        // What is the account are we holding in cache
        private TaxAccountView m_lastReadTaxAccountView;

        // Constructor
        public TaxAccountViewReader()
        {
            // We're currently not holding anything in cache.
            m_lastReadTaxAccountView.AccountId = -1;
        }

        /// <summary>
        /// Retrieve tax information for the given account.
        /// Used cached tax information if possible.
        /// </summary>
        /// <param name="accountId">the account we are interested in</param>
        /// <returns></returns>
        public TaxAccountView GetView(int accountId)
        {
            // Maybe we are already holding this tax account view.
            if (accountId == m_lastReadTaxAccountView.AccountId)
            {
                mLogger.LogDebug("Using cached tax account view: " +
                                 " Vendor: " + m_lastReadTaxAccountView.Vendor +
                                 " Country: " + m_lastReadTaxAccountView.MetraTaxCountryCode +
                                 " Zone: " + m_lastReadTaxAccountView.MetraTaxCountryZone +
                                 " Has Override: " + m_lastReadTaxAccountView.HasMetraTaxOverride +
                                 " OverrideTaxBand: " + m_lastReadTaxAccountView.MetraTaxOverrideTaxBand +
                                 " Use Standard Implied Tax Algorithm: " + m_lastReadTaxAccountView.UseStandardImpliedTaxAlgorithm);
                return m_lastReadTaxAccountView;
            }


            // We need to get the tax account view from the database.
            mLogger.LogDebug("Retrieving tax account view for account " + accountId + " from the database.");
            IMTConnection dbConnection = null;
            TaxAccountView result = new TaxAccountView();

            try
            {
                // Set up the connection and the query
                dbConnection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = dbConnection.CreateAdapterStatement(@"Queries\Tax\MetraTax",
                                                                "__GET_TAX_ACCOUNT_VIEW__");
                statement.AddParam("%%ID_ACC%%", accountId);

                // Execute the query and read the results
                IMTDataReader reader = statement.ExecuteReader();
                if (reader.Read())
                {
                    result.AccountId = accountId;

                    result.IsNullHasMetraTaxOverride = true;
                    result.IsNullMetraTaxCountry = true;
                    result.IsNullMetraTaxCountryZone = true;
                    result.IsNullMetraTaxOverrideTaxBand = true;
                    result.IsNullVendor = true;
                    result.IsNullUseStandardImpliedTaxAlgorithm = true;

                    if (!reader.IsDBNull("c_MetraTaxHasOverrideBand"))
                    {
                        result.IsNullHasMetraTaxOverride = false;
                        result.HasMetraTaxOverride = (reader.GetString("c_MetraTaxHasOverrideBand") == "1");
                    }

                    if (!reader.IsDBNull("c_MetraTaxCountryEligibility"))
                    {
                        result.IsNullMetraTaxCountry = false;
                        result.MetraTaxCountryCode = reader.GetInt32("c_MetraTaxCountryEligibility");
                    }
                    if (!reader.IsDBNull("c_MetraTaxCountryZone"))
                    {
                        result.IsNullMetraTaxCountryZone = false;
                        result.MetraTaxCountryZone =
                            (TaxZone)EnumHelper.GetCSharpEnum(reader.GetInt32("c_MetraTaxCountryZone"));
                    }
                    if (!reader.IsDBNull("c_MetraTaxOverrideBand"))
                    {
                        result.IsNullMetraTaxOverrideTaxBand = false;
                        result.MetraTaxOverrideTaxBand =
                            (TaxBand)EnumHelper.GetCSharpEnum(reader.GetInt32("c_MetraTaxOverrideBand"));
                    }
                    if (!reader.IsDBNull("c_TaxVendor"))
                    {
                        result.IsNullVendor = false;
                        result.Vendor = (TaxVendor)EnumHelper.GetCSharpEnum(reader.GetInt32("c_TaxVendor"));
                    }
                    if (!reader.IsDBNull("c_UseStdImpliedTaxAlg"))
                    {
                        result.IsNullUseStandardImpliedTaxAlgorithm = false;
                        result.UseStandardImpliedTaxAlgorithm = (reader.GetString("c_UseStdImpliedTaxAlg") == "1");
                    }

                    mLogger.LogDebug("Retrieved tax account view: " +
                                     " Vendor: " + result.Vendor + " (" + result.IsNullVendor + ")" +
                                     " Country: " + result.MetraTaxCountryCode + " (" + result.IsNullMetraTaxCountry + ")" +
                                     " Zone: " + result.MetraTaxCountryZone + " (" + result.IsNullMetraTaxCountryZone + ")" +
                                     " Has Override: " + result.HasMetraTaxOverride + " (" + result.IsNullHasMetraTaxOverride + ")" +
                                     " OverrideTaxBand: " + result.MetraTaxOverrideTaxBand +
                                     " Use Standard Implied Tax Algorithm: " + result.UseStandardImpliedTaxAlgorithm);
                }
                else
                {
                    string err = "Unable to find tax properties for account " + accountId + ". Not in t_av_internal.";
                    mLogger.LogError(err);
                    throw new TaxException(err);
                }
            }
            catch (Exception e)
            {
                mLogger.LogError("An error occurred attempting to read account " + accountId + " from t_av_internal. " + e.Message, e);
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

            m_lastReadTaxAccountView = result;

            return result;
        }

        /// <summary>
        /// Sets the account view held in cache.  This method exists solely for testing.
        /// In a test program, you can use this method to manipulate the settings for
        /// an account.
        /// </summary>
        /// <param name="view"></param>
        public void SetAccountHeldInCache(TaxAccountView view)
        {
            m_lastReadTaxAccountView = view;
        }
    }
}

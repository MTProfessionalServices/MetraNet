using System;
using System.Data;
using System.Runtime.InteropServices;

using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;

namespace MetraTech.Utils
{
    [Guid("CC31A7B4-6578-44B7-B3D1-CF34590D45AA")]
    public interface IMTCurrencyConverter
    {
        decimal GetConversionRate(string sourceCurrency, string targetCurrency, DateTime conversionTime);
        decimal ConvertCurrency(string sourceCurrency, decimal sourceAmount, string targetCurrency, DateTime conversionTime);
    }

    [Guid("4EA781F3-AADD-48FC-AF25-74D301716CB3")]
    [ClassInterface(ClassInterfaceType.None)]
    public class MTCurrencyConverter : IMTCurrencyConverter
    {
        #region Constants
        private const string QUERY_PATH = @"Queries\Database";
        #endregion

        #region IMTCurrencyConverter Interface Methods
        public decimal GetConversionRate(string sourceCurrency, string targetCurrency, DateTime conversionTime)
        {
            decimal? conversionRate = null;

            try
            {
                using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                {
                    queryAdapter.Item = new MTQueryAdapter();
                    queryAdapter.Item.Init(QUERY_PATH);

                    using (IMTConnection conn = ConnectionManager.CreateConnection(QUERY_PATH))
                    {
                        queryAdapter.Item.SetQueryTag("__GET_CURRENCY_CONVERSION_RATE__");

                        using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            prepStmt.AddParam("srcCurrency", MTParameterType.String, sourceCurrency);
                            prepStmt.AddParam("tgtCurrency", MTParameterType.String, targetCurrency);
                            prepStmt.AddParam("conversionDate", MTParameterType.DateTime, conversionTime);

                            using (IMTDataReader rdr = prepStmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    if (!conversionRate.HasValue)
                                    {
                                        conversionRate = rdr.GetDecimal(0);
                                    }
                                    else
                                    {
                                        throw new COMException(string.Format("More than one conversion rate found from {0} to {1} on {2}", 
                                            sourceCurrency,
                                            targetCurrency,
                                            conversionTime));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (COMException )
            {
                throw;
            }
            catch (Exception )
            {
            }

            if (conversionRate.HasValue)
            {
                return conversionRate.Value;
            }
            else
            {
                throw new COMException(string.Format("Unable to locate conversion rate from {0} to {1} on {2}",
                                            sourceCurrency,
                                            targetCurrency,
                                            conversionTime));
            }
        }

        public decimal ConvertCurrency(string sourceCurrency, decimal sourceAmount, string targetCurrency, DateTime conversionTime)
        {
            decimal convertedAmount = 0;

            decimal conversionRate = GetConversionRate(sourceCurrency, targetCurrency, conversionTime);

            convertedAmount = sourceAmount * conversionRate;

            return convertedAmount;
        }
        #endregion

    }
}
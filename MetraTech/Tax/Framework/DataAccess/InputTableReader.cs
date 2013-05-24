#region

using System;
using System.Collections.Generic;
using System.ComponentModel;

using MetraTech.DataAccess;
using MetraTech.Interop.Rowset;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;

#endregion

namespace MetraTech.Tax.Framework.DataAccess
{
    /// <summary>
    /// This class is for accessing the t_tax_input_.... table.
    /// It knows what to expect in the table by reading t_tax_vendor_params.
    /// If a column is missing from t_tax_input_..., sets the value to
    /// the default value specified in t_tax_vendor_params.
    /// </summary>
    public class TaxManagerVendorInputTableReader
    {
        private const string mQueryPathConst = @"Queries\Tax";
        private static Logger mLogger = new Logger("[Tax]");

        // Reader for the tax input table.
        private IMTDataReader mTaxInputTableReader;
        private IMTAdapterStatement mInputTblStatement;
        private int mRunId = -1;
        private TaxVendor mVendorId;
        private bool m_isReverse = false;

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="vendorId"></param>
        /// <param name="run_id"></param>
        /// <param name="isReverse">True if we are attempting to reverse a previous tax run</param>
        public TaxManagerVendorInputTableReader(TaxVendor vendorId, int run_id, bool isReverse)
        {
            mVendorId = vendorId;
            if (run_id < 1) throw new TaxException("zero or negative run id ( " + run_id + ") for tax table creation");

            mRunId = run_id;
            m_isReverse = isReverse;

            try
            {
                ReadTaxInputTable();
            }
            catch (Exception e)
            {
                throw new TaxException(e.Message);
            }
        }

        /// <summary>
        /// Returns the next available tax transaction from t_tax_input...
        /// Returns null if there are no more tax transactions.
        /// Throws an exception if the tax transaction is missing an expected
        /// column (according to t_tax_vendor_params) and there
        /// was not a default value defined for the column.
        /// </summary>
        /// <returns></returns>
        private static readonly object m_lock = new object();
        public TaxableTransaction GetNextTaxableTransaction()
        {
            // For ever entry in the ParamTable, there is a column in the InputTable
            // Iterate through the ParamTable entries for every entry
            // in the InputTable
            TaxableTransaction taxableTransaction;
            lock (m_lock)
            {
                taxableTransaction = mTaxInputTableReader.Read() ? ReadNextTaxableTransaction(mTaxInputTableReader) : null;
            }

            return taxableTransaction;
        }

        /// <summary>
        /// IMPORTANT: This method should be invoked when the client of this class is finished
        /// reading tax transactions from the input table.  It performs the necessary cleanup.
        /// </summary>
        public void Close()
        {
            if (!mTaxInputTableReader.IsClosed)
            {
                mTaxInputTableReader.Close();
            }
        }


        public static Int64 CountRowsOnTable(string table)
        {
            if (String.IsNullOrEmpty(table)) throw new ArgumentNullException("table name parameter is null or empty");

            using (var conn = ConnectionManager.CreateConnection())
            using (var stmt = conn.CreateAdapterStatement(mQueryPathConst, "__GET_TABLE_ROW_COUNT__"))
            {
                stmt.AddParam("%%TABLENAME%%", table);
                using (var reader = stmt.ExecuteReader())
                {
                    if (reader.Read()) return reader.GetInt32("count");

                }
            }
            return 0;
        }

        #region Table Population Methods


        private void ReadTaxInputTable()
        {
            mLogger.LogDebug("Reading the tax input table.");
            IMTConnection connection;
            try
            {
                // Use a Statement and Reader to allow for incremental access.
                connection = ConnectionManager.CreateConnection();
                if (!m_isReverse)
                {
                    mInputTblStatement = connection.CreateAdapterStatement(mQueryPathConst, "__GET_INPUT_TABLE_DATA__");
                }
                else
                {
                    mInputTblStatement = connection.CreateAdapterStatement(mQueryPathConst, "__GET_REVERSE_INPUT_TABLE_DATA__");
                }
                mInputTblStatement.AddParam("%%RUN_ID%%", mRunId);

                mLogger.LogDebug("Issuing query: " + mInputTblStatement.Query);
                mTaxInputTableReader = mInputTblStatement.ExecuteReader();
            }
            catch (Exception e)
            {
                // Log the source and exception, then throw upstack.
                mLogger.LogException("unable to read table t_tax_input_" + mRunId, e);
                throw e;
            }
        }

        #endregion

        #region Type Parsing For User Defined Columns

        /// <summary>
        /// Return a taxable transaction from the t_tax_input table.
        /// </summary>
        /// <param name="reader"></param>
        /// <returns></returns>
        private TaxableTransaction ReadNextTaxableTransaction(IMTDataReader reader)
        {
            var taxableTransaction = new TaxableTransaction(mVendorId);

            // We get a list of the parameters supported by this vendor from the TaxManagerDefaultManager.
            // Then, we check if the t_tax_input_* contains a value for each parameter.  If t_tax_input_*
            // does not contain a value for a parameter, we use the default value.
            foreach (var defaultPair in TaxParameterDefaultManager.Instance.GetDefaultsForVendor(mVendorId))
            {
                try
                {
                    // Read the parameterValue and parameterType from t_tax_input_*
                    var parameterValue = reader.GetValue(defaultPair.Value.ParameterName);
                    var parameterType = reader.GetType(defaultPair.Value.ParameterName);
                    var taxParameter = new TaxParameter(defaultPair.Value.ParameterName, defaultPair.Value.Description,
                        parameterType, parameterValue);
                    

                    // If the parameterValue read from the t_tax_input_table is null,
                    // then use the default value instead. (Note: this might be null also)
                    if (DBNull.Value == taxParameter.ParameterValue)
                    {
                        mLogger.LogDebug("No/Null value in t_tax_input, so adding default parameter: {0}", defaultPair.Value.ToString());
                        taxableTransaction.StoreTaxParameter(defaultPair.Value);
                    }
                    else
                    {
                        mLogger.LogDebug("Adding value from t_tax_input: {0}", taxParameter.ToString());
                        taxableTransaction.StoreTaxParameter(taxParameter);
                    }
                }
                catch
                {
                    mLogger.LogDebug(
                        String.Format("Field '{0}' does not exist in t_tax_input table, using default instead",
                                      defaultPair.Value.ParameterName));
                }
            }

            return taxableTransaction;
        }


        #endregion
    }
}

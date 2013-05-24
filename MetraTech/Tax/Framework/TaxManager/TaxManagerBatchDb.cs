#region

using System;
using MetraTech.DataAccess;

#endregion

namespace MetraTech.Tax.Framework
{
    /// <summary>
    /// Provides a way of submitting a batch of charges specified
    /// in a database table to a tax vendor for the calculation
    /// of taxes.
    /// </summary>
    public abstract class TaxManagerBatchDb
    {
        // Logger
        private static readonly Logger mLogger = new Logger("[Tax]");

        // If true, the third party tax vendor will store audit information.
        protected bool mIsAuditingNeeded = true;

        // If true, the detailed tax results (one line per tax) will be stored in t_tax_details table.
        protected bool mTaxDetailsNeeded;

        // Identifies a unqiue tax run.  This ID is used in the name of the input and
        // output tables, and is referenced in the tax detail table.
        protected int mTaxRunId;

        // This uniqueId is assigned for each run of the adapter.
        // The value must be unique each time a client invokes
        // CalculateTaxes() or ReverseTaxRun().
        protected int mAdapterUniqueRunId;

        // Reports the status of how the processing of taxes is proceeding.
        protected ITaxManagerStatusReporter mStatusReporter = null;

        // Last time that a status report was issued;
        private DateTime mTimeOfLastStatusReport = new DateTime(1970, 1, 1);

        // The number of minutes between issued status reports.
        private const int NUMBER_OR_MINUTES_BETWEEN_REPORTS = 5;

        // The number of transactions processed so far;
        private int mNumberOfTransactionsProcessed = 0;

        /// <summary>
        /// Identifies a particular set of tax calcutions being performed.
        /// It is expected that after creating a TaxManager, the set()
        /// method is used to set the tax run ID.
        /// </summary>
        public int TaxRunId
        {
            get
            {
                return mTaxRunId;
            }
            set { mTaxRunId = value; }
        }

        /// <summary>
        /// Unique identifier assigned by the adapter before invoking
        /// CalculateTaxes() or ReverseTaxRun().
        /// </summary>
        public int AdapterUniqueRunId
        {
            get
            {
                return mAdapterUniqueRunId;
            }
            set { mAdapterUniqueRunId = value; }
        }

        /// <summary>
        /// If set to true, the 3rd party will write financial audit
        /// logs for the taxes.  Set this to false if you are calculating
        /// estimated taxes and you don't want auditing to be done.
        /// </summary>
        public bool IsAuditingNeeded
        {
            get { return mIsAuditingNeeded; }
            set { mIsAuditingNeeded = value; }
        }

        /// <summary>
        /// If true, the detailed tax results (one line per tax) will be stored in t_tax_details table.
        /// </summary>
        public bool TaxDetailsNeeded
        {
            get { return mTaxDetailsNeeded; }
            set { mTaxDetailsNeeded = value; }
        }

        /// <summary>
        /// The maximum number of errors (inclusively) that can occur before tax calculations
        /// are halted.  In the number of errors exceed this number, then tax calculations 
        /// should stop. 
        /// </summary>
        public int MaximumNumberOfErrors { get; set; }

        /// <summary>
        /// Returns a unique tax run ID.  This tax run ID is used by clients
        /// of the tax framework to keep track of a particular tax run.
        /// One example use: the TaxAdapterAssistant uses this ID to generate the 
        /// names of the database tax input and output tables: t_tax_input_[id].
        /// </summary>
        /// <returns></returns>
        public int GenerateUniqueTaxRunID()
        {
            IIdGenerator2 g = new IdGenerator("id_tax_run", 1);
            int id_tax_run = g.NextId;
            return id_tax_run;
        }

        /// <summary>
        /// Returns a unique tax charge ID that can be associated with a transaction
        /// that is being processed by a tax pipeline plug-in.  The calculated tax is
        /// ultimately stored in the tax details table (if configured so) and this
        /// tax charge ID is associated with tax run ID 0.  Tax run ID 0 is reserved for
        /// pipeline tax calculations.
        /// </summary>
        /// <returns></returns>
        public long GenerateUniqueTaxChargeIdForPipeline()
        {
            LongIdGenerator g = new LongIdGenerator("id_tax_charge_pipe", 1);
            long id = g.NextId;
            return id;
        }

        /// <summary>
        /// This method can be called after taxes have been calculated
        /// to throw away any third party auditing and to delete
        /// the tax output table.
        /// 
        /// Implementation details for specific vendors:
        ///     In case of billsoft - delete audit file. 
        ///     In case of TWE call rollback for every audit record.
        ///     In some cases can be making every call with negative amount.
        /// </summary>
        public void ReverseTaxRun()
        {
            RollbackVendorAudit();

            if (mStatusReporter != null)
                mStatusReporter.ReportInfo("Dropping tax output table.");
            DropOutputTable();

            if (mStatusReporter != null)
                mStatusReporter.ReportInfo("Deleting tax details records.");

            DeleteTaxDetailRecords();
        }


        /// <summary>
        /// Get the expected name for the input tax table for the tax run.
        /// </summary>
        /// <returns></returns>
        public string GetInputTaxTableName()
        {
            return string.Format("t_tax_input_{0}", TaxRunId);
        }

        /// <summary>
        /// Get the name of the Tax Detail Table.
        /// </summary>
        /// <returns></returns>
        public string GetTaxDetailTableName()
        {
            return string.Format("t_tax_details");
        }

        /// <summary>
        /// Get the expected name of the output tax table for the tax run.
        /// </summary>
        /// <returns></returns>
        public string GetOutputTaxTableName()
        {
            return string.Format("t_tax_output_{0}", TaxRunId);
        }

        /// <summary>
        /// Get the size to use when doing a bulk insert
        /// (to either the Tax Details Table or Tax Output Table). 
        /// </summary>
        /// <returns></returns>
        public int GetBulkInsertSize()
        {
            return 1000;
        }

        /// <summary>
        /// Drop/Truncate the table with tax results
        /// </summary>
        protected void DropOutputTable()
        {
            DropTable(GetOutputTaxTableName());
        }

        /// <summary>
        /// Drop the give table.
        /// </summary>
        /// <param name="tableName"></param>
        public void DropTable(string tableName)
        {
            IMTConnection dbConnection = null;

            mLogger.LogDebug("Dropping table: " + tableName);

            try
            {
                // Set up the connection and the query
                dbConnection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = dbConnection.CreateAdapterStatement(@"Queries\Tax", "__DROP_TABLE_TAX__");
                statement.AddParam("%%TABLE_NAME%%", tableName);

                // Execute the query
                statement.ExecuteReader();
            }
            catch (Exception e)
            {
                mLogger.LogError("An error occurred attempting to drop table " + tableName +
                                 " Error: " + e.Message + " Inner exception: " + e.InnerException);
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
        /// Drop/Truncate the table with tax inputs
        /// </summary>
        public void DropInputTable()
        {
            DropTable(GetInputTaxTableName());
        }

        /// <summary>
        /// All records in the tax details table that reference
        /// the tax run ID (mTaxRunID).
        /// </summary>
        public void DeleteTaxDetailRecords()
        {
            IMTConnection dbConnection = null;

            mLogger.LogDebug("Deleting tax run ID " + mTaxRunId + " from t_tax_details.");

            try
            {
                // Set up the connection and the query
                dbConnection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = dbConnection.CreateAdapterStatement(@"Queries\Tax",
                                                                                    "__DROP_T_TAX_DETAILS_ROWS__");
                statement.AddParam("%%RUN_ID%%", mTaxRunId);

                // Execute the query
                statement.ExecuteReader();
            }
            catch (Exception e)
            {
                mLogger.LogError("An error occurred attempting to delete rows from t_tax_details " +
                                 "for tax run " + mTaxRunId + " " + " Error: " + e.Message);
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


            if (mStatusReporter != null)
                mStatusReporter.ReportInfo("Deleted tax details records for this tax run.");
        }

        /// <summary>
        /// Set the status report that will be used to report information on
        /// how the tax calculations are proceeding.
        /// </summary>
        /// <param name="reporter"></param>
        public void SetStatusReporter(ITaxManagerStatusReporter reporter)
        {
            mStatusReporter = reporter;
        }

        /// <summary>
        /// Report an information message about the status of the tax calculations.
        /// </summary>
        /// <param name="s"></param>
        protected void ReportInfo(string s)
        {
            mLogger.LogInfo("Tax Calculation Status Report: " + s);
            if (mStatusReporter != null)
                mStatusReporter.ReportInfo(s);
        }

        /// <summary>
        /// Periodically reports the number of transactions processed.
        /// </summary>
        /// <param name="nTransactionsProcessed">number of tax transactions so far</param>
        protected void ReportProgress(int nTransactionsProcessed)
        {
            // Only report if we've never reported before or enough time has passed since last reporting
            if (mNumberOfTransactionsProcessed <= 0 ||
                DateTime.Now.Subtract(mTimeOfLastStatusReport).Seconds > (NUMBER_OR_MINUTES_BETWEEN_REPORTS * 60))
            {
                mTimeOfLastStatusReport = DateTime.Now;
                mNumberOfTransactionsProcessed = nTransactionsProcessed;
                string msg = "Processed " + nTransactionsProcessed + " tax transactions so far.";
                ReportInfo(msg);
            }
        }

        /// <summary>
        /// Report a warning message about the status of the tax calculations.
        /// </summary>
        /// <param name="s"></param>
        protected void ReportWarning(string s)
        {
            mLogger.LogWarning("Tax Calculation Status Report: " + s);

            if (mStatusReporter != null)
                mStatusReporter.ReportWarning(s);
        }

        /// <summary>
        /// This method is called to clean up vendor audit and leave no trace of this tax run.
        /// It is expected to be called only after the tax calculations have completed.
        /// It may be called even after CommitVendorAudit() has been applied, but in this
        /// case an exception may be thrown if the vendor does not support the reversing
        /// of committed audit information.
        /// 
        /// Implementation details:
        ///     In case of billsoft - delete audit file. 
        ///     In case of TWE call rollback for every audit record.
        ///     In some cases can be making every call with negative amount.
        /// </summary>
        protected abstract void RollbackVendorAudit();
    }
}

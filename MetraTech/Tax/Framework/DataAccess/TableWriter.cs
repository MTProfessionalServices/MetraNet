#region

using System;
using System.Collections.Generic;
using MetraTech.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.DataAccess
{
    public class TaxManagerBatchDbTableWriter
    {
        private Logger mLogger;
        private int mNumBulkInsertBatch = 1000;
        private List<TaxManagerPersistenceObject> mRows;
        private string mTablename;
        private object mLock = new object();

        public TaxManagerBatchDbTableWriter(string tablename, int numBulkInsertBatch)
        {
            mLogger = new Logger("[Tax]");
            mTablename = tablename;
            if (numBulkInsertBatch > 0)
                mNumBulkInsertBatch = numBulkInsertBatch;

            mRows = new List<TaxManagerPersistenceObject>();
        }

        public void Add(TaxManagerPersistenceObject addMe)
        {
            lock (mLock)
            {
                mRows.Add(addMe);
                TryPartialCommit();
            }
        }

        public void Add(List<TaxManagerPersistenceObject> additions)
        {
            lock (mLock)
            {
                mRows.AddRange(additions);
                TryPartialCommit();
            }
        }

        public void Add(TaxManagerPersistenceObject[] additions)
        {
            lock (mLock)
            {
                mRows.AddRange(additions);
                TryPartialCommit();
            }
        }

        /// <summary>
        /// Create the table in the database.  Throws an exception if the
        /// table already exists.
        /// </summary>
        /// <returns></returns>
        public static void CreateOutputTable(string outputTableName)
        {
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            using (var stmt = conn.CreateAdapterStatement(@"Queries\Tax", "__CREATE_T_TAX_OUTPUT__"))
            {
                stmt.AddParam("%%TABLE_NAME%%", outputTableName);
                var reader = stmt.ExecuteReader();
            }
        }

        /// <summary>
        /// For performance and memory reasons, this method will do a partial commit
        /// each time the batch passes the Number to Insert Per Batch
        /// </summary>
        private void TryPartialCommit()
        {
            if (mRows.Count < mNumBulkInsertBatch) return;

            Commit();
            mRows.Clear();
        }

        /// <summary>
        /// Writes to the output table all the rows currently stored in memory
        /// by the Add() method.  Throws an exception if not successful.
        /// </summary>
        public void Commit()
        {
            // Determine the type of database being used
            ConnectionInfo info = new ConnectionInfo("NetMeter");

            switch (info.DatabaseType)
            {
                case DBType.SQLServer:
                    CommitSQLServer();
                    break;

                case DBType.Oracle:
                    CommitOracle();
                    break;

                default:
                    String err = "Attempt to use unsupported database type: " + info.DatabaseType.ToString();
                    mLogger.LogError(err);
                    throw new TaxException(err);
            }
        }

        /// <summary>
        /// SQLServer: Writes to the output table all the rows currently stored in memory
        /// by the Add() method.  Throws an exception if not successful.
        /// </summary>
        private void CommitSQLServer()
        {
            mLogger.LogDebug("Committing SQLServer table using BCPBulkInsert.");
            if (mRows.Count < 1) return; // Nothing to do...

            var bcpObj = new BCPBulkInsert();
            try
            {
                var ci = new ConnectionInfo("NetMeter");
                bcpObj.Connect(ci);
                bcpObj.PrepareForInsert(mTablename, mNumBulkInsertBatch);
                int nRecordCount = 0;

                foreach (var row in mRows)
                {
                    row.Persist(ref bcpObj);

                    bcpObj.AddBatch();

                    if (++nRecordCount % mNumBulkInsertBatch != 0) continue;
                    mLogger.LogDebug("Executing the BulkInsert batch #{0}", (nRecordCount / mNumBulkInsertBatch));
                    bcpObj.ExecuteBatch();
                }
                if (++nRecordCount % mNumBulkInsertBatch != 0)
                {
                    mLogger.LogDebug("Executing the BulkInsert for final batch");
                    bcpObj.ExecuteBatch();
                }
            }
            catch (Exception e)
            {
                throw new TaxException("Failed during commit of data: " + e.Message +
                                       ". InnerException: " + e.Message + "StackTrace: " +
                                       e.StackTrace);
            }
            finally
            {
                bcpObj.Dispose();
            }
        }

        /// <summary>
        /// Oracle: Writes to the output table all the rows currently stored in memory
        /// by the Add() method.  Throws an exception if not successful.
        /// </summary>
        public void CommitOracle()
        {
            mLogger.LogDebug("Committing SQLServer table using ArrayBulkInsert.");
            if (mRows.Count < 1) return; // Nothing to do...

            var arrayBulkInsert = new ArrayBulkInsert();
            try
            {
                var ci = new ConnectionInfo("NetMeter");
                arrayBulkInsert.Connect(ci);
                arrayBulkInsert.PrepareForInsert(mTablename, mNumBulkInsertBatch);
                int nRecordCount = 0;

                foreach (var row in mRows)
                {
                    row.Persist(ref arrayBulkInsert);

                    arrayBulkInsert.AddBatch();

                    if (++nRecordCount % mNumBulkInsertBatch != 0) continue;
                    mLogger.LogDebug("Executing the BulkInsert batch #{0}", (nRecordCount / mNumBulkInsertBatch));
                    arrayBulkInsert.ExecuteBatch();
                }
                if (++nRecordCount % mNumBulkInsertBatch != 0)
                {
                    mLogger.LogDebug("Executing the BulkInsert for final batch");
                    arrayBulkInsert.ExecuteBatch();
                }
            }
            catch (Exception e)
            {
                throw new TaxException("Failed during commit of data: " + e.Message +
                                       ". InnerException: " + e.Message + "StackTrace: " +
                                       e.StackTrace);
            }
            finally
            {
                arrayBulkInsert.Dispose();
            }
          }

        public void RemoveRow(long idTaxCharge)
        {
            lock (mLock)
            {
                using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                using (var stmt = conn.CreateAdapterStatement(@"Queries\Tax", "__REMOVE_ROW_FROM_T_TAX_OUTPUT__"))
                {
                    stmt.AddParam("%%TABLE_NAME%%", mTablename);
                    stmt.AddParam("%%ID_TAX_CHARGE%%", idTaxCharge);
                    var reader = stmt.ExecuteReader();
                }
            }
        }
    }
}

using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

using Framework.TaxManager.VertexQ;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.Tax.Framework.DataAccess;

namespace MetraTech.Tax.Framework.VertexQ
{
    /// <summary>
    /// This class interacts with the VertexQ software to compute taxes.
    /// </summary>
    public class VertexQSyncTaxManagerDBBatch : SyncTaxManagerBatchDb
    {
        private static readonly Logger m_Logger = new Logger("[VertexQ]");
        private readonly VertexQConfiguration m_VertexQConfiguration;
        private SocketClient m_socketClient;
        private int m_numOfTransactionsToProcess = 0;
        private int m_numOfReturnedResults = 0;

        /// <summary>
        /// Provides thread safe access to t_tax_input_*
        /// </summary>
        private TaxManagerVendorInputTableReader m_reader;

        /// <summary>
        /// Provides thread safe access to t_tax_output_*
        /// </summary>
        private TaxManagerBatchDbTableWriter m_writer;

        /// <summary>
        /// Provides thread safe access to t_tax_details
        /// </summary>
        private TaxManagerBatchDbTableWriter m_detailWriter;

        /// <summary>
        /// Constructor
        /// </summary>
        public VertexQSyncTaxManagerDBBatch()
        {
            m_Logger.LogDebug(System.Reflection.MethodBase.GetCurrentMethod().Name);
            m_VertexQConfiguration = new VertexQConfiguration();
        }

        /// <summary>
        /// Calculate taxes for a SINGLE transaction.  Before calling this, make sure
        /// you have set: (1) TaxRunID, (2) IsAuditingNeeded, (3) TaxDetailsNeeded,
        /// (4) have filled the taxableTransaction.
        /// </summary>
        /// <param name="taxableTransaction">Contains the name-value pairs needed by the specified tax vendor to compute taxes</param>
        /// <param name="transactionSummary">OUTPUT will contain the tax results summed up for each jurisdiction</param>
        /// <param name="transactionDetails">OUTPUT will contain the individual tax results</param>
        public override void CalculateTaxes(TaxableTransaction taxableTransaction,
                                            out TransactionTaxSummary transactionSummary,
                                            out List<TransactionIndividualTax> transactionDetails)
        {
            m_Logger.LogDebug("CalculateTaxes: taxableTransaction={0}", taxableTransaction.ToString());
            try
            {
                ++m_numOfTransactionsToProcess;

                // Create Sockets
                // TODO : Single this is a single transaction we don't need to create multiple client sockets           
                CreateAndInitializeSockets();

                PerformTaxTransaction(taxableTransaction, out transactionSummary, out transactionDetails);

                if (TaxDetailsNeeded)
                {
                    // Write the resulting transactionDetails to the t_tax_details table
                    foreach (TransactionIndividualTax row in transactionDetails)
                    {
                        m_detailWriter.Add(row);
                    }
                }
            }
            catch (Exception e)
            {
                // Assume this exception is lethal.
                // So, rethrow it.
                string msg = String.Format("{0}: caught {1} while processing taxableTransaction {2}",
                    System.Reflection.MethodBase.GetCurrentMethod().Name,
                    e.ToString(), taxableTransaction.ToString());
                m_Logger.LogError(msg);
                m_Logger.LogException(msg, e);
                throw;
            }

        }

        /// <summary>
        /// Creates the and initialize sockets.
        /// </summary>
        /// <returns></returns>
        /// <remarks></remarks>
        private void CreateAndInitializeSockets()
        {
            HostFinder hostFinder = new HostFinder();
            const int opsToPreAlloc = 2;

            // Create one object with a lot of settings, to pass to SocketClient.
            SocketClientSettings socketClientSettings = new SocketClientSettings(
              hostFinder.GetValidHost(m_VertexQConfiguration.m_ServerAddress, m_VertexQConfiguration.m_Port),
              m_VertexQConfiguration.m_NumClientSockets,
              m_VertexQConfiguration.m_MaxSimultaneousConnectOps,
              m_VertexQConfiguration.m_MaxNumOfSimultaneousClientConnections,
              m_VertexQConfiguration.m_BufferSize,
              opsToPreAlloc);


            // Create the object that will do most of the work.
            m_socketClient = new SocketClient(socketClientSettings);
            m_Logger.LogDebug("CreateAndInitializeSockets: finished");
        }

        /// Calculate taxes.  Before calling this, make sure you have set
        /// the TaxRunId.
        /// There are 3 steps: 
        /// (1) read the input table containing the tax parameters,
        /// (2) computes the taxes,
        /// (3) store the results in the output table
        /// </summary>
        public override void CalculateTaxes()
        {
            // Keep track of the number of errors that have occurred
            int numErrors = 0;

            // Keep track of the number of rows in t_tax_input_* that have been processed.
            int numRowsProcessed = 0;

            // Create a reader for the input table.
            m_Logger.LogDebug("Reading {0}", GetInputTaxTableName());
            m_reader = new TaxManagerVendorInputTableReader(
              TaxVendor.VertexQ, TaxRunId,
              false // This is NOT an attempt to reverse the audit
              );

            // Create output table.
            ReportInfo("Creating tax output table.");
            TaxManagerBatchDbTableWriter.CreateOutputTable(GetOutputTaxTableName());

            // Create the writer for t_tax_output_*
           m_writer = new TaxManagerBatchDbTableWriter(
              GetOutputTaxTableName(), GetBulkInsertSize());

            // Create the writer for the tax details table.
            m_detailWriter = new TaxManagerBatchDbTableWriter(
              GetTaxDetailTableName(), GetBulkInsertSize());

            try
            {
                //
                // Loop through all of the potential taxable transactions
                //
                TaxableTransaction taxableTransaction;
                while (null != (taxableTransaction = m_reader.GetNextTaxableTransaction()))
                {
                    try
                    {
                        ++m_numOfTransactionsToProcess; // can we reuse numRowsProcesses ???

                        TransactionTaxSummary transactionSummary;
                        List<TransactionIndividualTax> transactionDetails;

                        // Perform transaction with VertexQ to populate the transactionSummary and taxDetailRows
                        PerformTaxTransaction(taxableTransaction, out transactionSummary, out transactionDetails);

                        // Write the resulting output row to the t_tax_output_* table
                        m_writer.Add(transactionSummary);

                        if (TaxDetailsNeeded)
                        {
                            // Write the resulting transactionDetails to the t_tax_details table
                            foreach (TransactionIndividualTax row in transactionDetails)
                            {
                               m_detailWriter.Add(row);
                            }
                        }

                        // Report on the progess on this input_table
                        numRowsProcessed++;
                        ReportProgress(numRowsProcessed);
                    }
                    catch (TaxException e)
                    {
                        string msg = String.Format("{0}: caught {1} while processing row {2}",
                                                 System.Reflection.MethodBase.GetCurrentMethod().Name,
                                                 e.Message, numRowsProcessed);

                        m_Logger.LogError(msg);
                        numErrors++;

                        // If we exceed the maximum number of errors, we throw the
                        // exception and stop.  Otherwise, we keep going.
                        if (numErrors > MaximumNumberOfErrors)
                        {
                            m_Logger.LogError("{0}: exceeded {1} errors, so rethrowing",
                                          System.Reflection.MethodBase.GetCurrentMethod().Name,
                                          MaximumNumberOfErrors);
                            throw new TaxException(msg);
                        }

                        ReportWarning(msg + ". Execution continuing since under the maximum number of errors.");
                    }
                    catch (Exception e)
                    {
                        // Assume this exception is lethal.
                        // So, rethrow it.
                        string msg = String.Format("{0}: caught {1} while processing row {2}",
                                                 System.Reflection.MethodBase.GetCurrentMethod().Name,
                                                 e.Message, numRowsProcessed);
                        m_Logger.LogError(msg);
                        throw;
                    }
                }

                // Commit the changes to the DB
                m_writer.Commit();
                m_detailWriter.Commit();

                ReportInfo("Completed VertexQ calculations. " + numRowsProcessed +
                     " tax transactions processed.");
                m_reader.Close();
            }
            catch (Exception e)
            {
                m_Logger.LogError("{0}: caught {1} while processing row {2}, rethrowing",
                  System.Reflection.MethodBase.GetCurrentMethod().Name,
                  e.Message, numRowsProcessed);

                // Commit the changes to the DB
                m_writer.Commit();
                m_detailWriter.Commit();

                m_reader.Close();
                throw;
            }
        }

        /// <summary>
        /// Loops through the previously completed transactions and reverses
        /// each transaction.  After each reversal transaction is complete, 
        /// the corresponding row in the output table is removed for book keeping.
        /// </summary>
        protected override void RollbackVendorAudit()
        {
            throw new TaxException("RollbackVendorAudit NOT IMPLEMENTED");
        }

        /// <summary>
        /// VERTEXQ stuff goes here
        /// </summary>
        /// <param name="taxableTransaction"></param>
        /// <param name="transactionSummary"></param>
        /// <param name="transactionDetails"></param>
        private void PerformTaxTransaction(TaxableTransaction taxableTransaction,
                            out TransactionTaxSummary transactionSummary, out List<TransactionIndividualTax> transactionDetails)
        {
            long idTaxCharge = 0;
            transactionSummary = new TransactionTaxSummary();

            if (taxableTransaction.GetInt64("id_tax_charge").HasValue)
            {
                idTaxCharge = taxableTransaction.GetInt64("id_tax_charge").GetValueOrDefault();
            }

            VertexParamsXML vertexParamsXML = new VertexParamsXML();
            string vertexParamsXMLString = vertexParamsXML.ReadAndPopulateAllVertexParameters(taxableTransaction);
            m_Logger.LogDebug("sending tax transaction to vertex: {0}", vertexParamsXMLString);
            string[] stringArray = new[] { vertexParamsXMLString };
            OutgoingMessageHolder outgoingMessageHolder = new OutgoingMessageHolder(stringArray);

            //outgoingMessageHolder.vertexTaxParamsXMLArray = new[] { vertexParamsXMLString };
            m_socketClient.outgoingQueue.Enqueue(outgoingMessageHolder);

            int numSleeps = 0;
            int sleepDurationMs = 100;
            int maxWaitDurationMs = 1000;
            while (m_socketClient.incomingQueue.Count() <= 0)
            {
                if ((numSleeps * sleepDurationMs) >= maxWaitDurationMs)
                {
                    m_Logger.LogError("Exceeded maxWaitDurationMs {0}, while waiting for response from this request: {1}",
                        maxWaitDurationMs, vertexParamsXMLString);
                    throw new TaxException(string.Format("Exceeded maxWaitDurationMs {0}, while waiting for response from this request: {1}", 
                        maxWaitDurationMs, vertexParamsXMLString));
                }
                // Wait for output result to be written to the output queue
                // This can be alleviated using TPL (Task Parallel Library)
                Thread.Sleep(sleepDurationMs);
                numSleeps++;
                m_Logger.LogDebug("XXXXX slept {0} milliseconds", sleepDurationMs*numSleeps);
            }


            m_Logger.LogDebug("XXXXX m_socketClient.incomingQueue.Count()={0}", m_socketClient.incomingQueue.Count());

            RoundingAlgorithm roundingAlgorithm = Rounding.GetAlgorithm(taxableTransaction.GetString("round_alg"));
            int roundingDigits = taxableTransaction.GetInt32("round_digits").GetValueOrDefault();

            transactionDetails = new List<TransactionIndividualTax>();
            // We have something in the Incoming queue as a computed tax result.
            // Parse the TaxResult and write to t_tax_output and t_tax_details

            m_Logger.LogDebug("XXXXX m_numOfReturnedResults={0}", m_numOfReturnedResults);
            m_Logger.LogDebug("XXXXX m_numOfTransactionsToProcess={0}", m_numOfTransactionsToProcess);

            while (m_numOfReturnedResults != m_numOfTransactionsToProcess)
            {
                string taxResultXML = m_socketClient.incomingQueue.Dequeue();

                // Convert the calculateDocumentResponse object into an "transactionSummary" that is
                // suitable for the tax_output_* table and add the row to the DB.


                transactionSummary = vertexParamsXML.ParseVertexTaxResultsToTransactionTaxSummary(idTaxCharge, taxResultXML,
                                                                                                  roundingAlgorithm,
                                                                                                  roundingDigits);

                m_Logger.LogInfo("TaxDetailsNeeded : {0}", TaxDetailsNeeded);


                // Create the detail information.  It may or may not be stored in the DB.
                transactionDetails = null;
                {
                    Boolean isImpliedTax = taxableTransaction.GetBool("is_implied_tax").GetValueOrDefault();

                    int idAcc = taxableTransaction.GetInt32("id_acc").GetValueOrDefault();
                    int idUsageInterval = taxableTransaction.GetInt32("id_usage_interval").GetValueOrDefault();

                    // transactionDetails = vertexParamsXML.ParseVertexTaxResultToTransactionDetails(
                    //    taxResultXML, idTaxCharge, isImpliedTax, idAcc, idUsageInterval);
                    transactionDetails = vertexParamsXML.ParseVertexTaxResultsToTransactionDetails(
                      idTaxCharge, isImpliedTax, idAcc, TaxRunId, idUsageInterval, taxResultXML);

                    m_Logger.LogDebug("transactionDetails.Count={0}", transactionDetails.Count);
                    foreach (var transactionDetail in transactionDetails)
                    {
                        m_Logger.LogDebug(transactionDetail.ToString());
                    }

                    ++m_numOfReturnedResults;
                }
            }

            // TODO : combine transactionsummary and transactiondetails builter into into method call
        }
    }
}

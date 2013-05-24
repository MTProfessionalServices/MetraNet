using System;
using System.ComponentModel;
using System.Globalization;
using System.Collections.Generic;
using System.ServiceModel;
using System.Security;
using System.Xml;
using Framework.TaxCalculationManagerService;
using MetraTech.Tax.Framework.DataAccess;
using System.Threading;

using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DomainModel.Enums;


namespace MetraTech.Tax.Framework.Taxware
{
    /// <summary>
    /// This class interacts with the TWE server to perform tax calculations
    /// on transactions in the tax_input_table and stores the results in the
    /// tax_output_table and the tax_output_detail_table.
    /// </summary>
    public class TaxwareSyncTaxManagerDBBatch : Framework.SyncTaxManagerBatchDb
    {
        private static Logger m_Logger = new Logger("[Taxware]");

        /// <summary>
        /// Provides access to taxware specific configuration values
        /// </summary>
        private readonly TaxwareConfiguration m_configuration;

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
        /// List of worker threads.  Each thread performs the following tasks:
        ///   read a row from the input table
        ///   convert the row into a calculateDocumentRequest
        ///   perform transaction with TWE
        ///   convert the calculateDocumentResponse into an output row and one or more output detail rows
        /// </summary>
        private List<Thread> m_threads = new List<Thread>();

        /// <summary>
        /// Keep track of the number of errors that have occurred on all threads
        /// </summary>
        private int m_numErrors = 0;

        /// <summary>
        /// Keep track of the number of rows in t_tax_input_* that have been processed.
        /// </summary>
        private int m_numRowsProcessed = 0;

        /// <summary>
        /// Threads use this lock when they need to access a member that is shared by all of the threads.
        /// </summary>
        static readonly object m_lock = new object();

        /// <summary>
        /// When the number of errors has exceeded MaximumNumberOfErrors, this member is set to
        /// true so that all other threads will stop.
        /// </summary>
        private bool m_stopAllThreads = false;

        /// <summary>
        /// Constructor
        /// </summary>
        public TaxwareSyncTaxManagerDBBatch()
        {
            m_Logger.LogDebug(System.Reflection.MethodBase.GetCurrentMethod().Name);

            // read configuration info from files and store the config info in
            // member variables.
            m_configuration = new TaxwareConfiguration();
        }

        /// <summary>
        /// Calculate taxes for a single transaction.  Before calling this, make sure
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
            try
            {
                // Populate the binding info needed by the client
                BasicHttpBinding taxServiceBinding = createAndPopulateBinding();

                // Populate the endpoint info needed by the client
                EndpointAddress taxServiceAddress = createAndPopulateEndpointAddress();

                // Provides access to the TWE server
                TaxCalculationManagerServiceInterface taxService =
                    new TaxCalculationManagerServiceInterfaceClient(taxServiceBinding, taxServiceAddress);

                // Perform transaction with taxware to populate the transactionSummary and transactionDetails
                PerformTaxTransaction(taxService,
                    false,  // isReversal
                    taxableTransaction, out transactionSummary, out transactionDetails);

                if (TaxDetailsNeeded)
                {
                    // Create the writer for the tax details table.
                    TaxManagerBatchDbTableWriter detailWriter = new TaxManagerBatchDbTableWriter(
                        GetTaxDetailTableName(), GetBulkInsertSize());

                    // Write the resulting transactionDetails to the t_tax_details table
                    foreach (TransactionIndividualTax row in transactionDetails)
                    {
                        detailWriter.Add(row);
                    }

                    detailWriter.Commit();
                }
            }
            catch (FaultException<TweFault> e)
            {
                // This is an exception caused by the TWE service,
                // so retrieve the details
                string msg = String.Format("{0}: caught {1} while processing taxableTransaction {2}",
                    System.Reflection.MethodBase.GetCurrentMethod().Name,
                    e.ToString(), taxableTransaction.ToString());
                m_Logger.LogError(msg);
                msg = String.Format(
                    "{0}: caught tweFltCd={1}, tweFltExcTp={2}, tweFltMsg='{3}' while processing row {4}",
                    System.Reflection.MethodBase.GetCurrentMethod().Name,
                    e.Detail.tweFltCd, e.Detail.tweFltExcTp, e.Detail.tweFltMsg,
                    m_numRowsProcessed);

                m_Logger.LogException(msg, e);
                throw;
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
        /// Calculate taxes.  Before calling this, make sure you have set
        /// the TaxRunId.
        /// There are 3 steps: 
        /// (1) read the input table containing the tax parameters,
        /// (2) computes the taxes,
        /// (3) store the results in the output table
        /// </summary>
        public override void CalculateTaxes()
        {
            // Create a reader for the input table.
            m_Logger.LogDebug("Reading {0}", GetInputTaxTableName());
            m_reader = new TaxManagerVendorInputTableReader(
              TaxVendor.Taxware, TaxRunId,
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
                // Create the worker threads and start them up.
                // Each worker thread will perform the following steps:
                //    read a row from the input table
                //    convert the row into a calculateDocumentRequest
                //    perform transaction with TWE
                //    convert the calculateDocumentResponse into an output row and one or more output detail rows
                StartWorkerThreads(false);

                // Wait for all of the threads to finish
                WaitForWorkerThreadsToFinish();

                // Commit the changes to the DB
                m_writer.Commit();
                m_detailWriter.Commit();

                // If m_stopAllThreads is true, report an error
                if (m_stopAllThreads)
                {
                    ReportWarning("Exceeded MaxNumErrors while performing Taxware calculations. " + m_numRowsProcessed +
                      " tax transactions processed.");
                }
                else
                {
                    ReportInfo("Completed Taxware calculations. " + m_numRowsProcessed +
                         " tax transactions processed.");
                }
                m_reader.Close();
            }
            catch (Exception e)
            {
                m_Logger.LogError("{0}: caught {1} while processing row {2}, rethrowing",
                  System.Reflection.MethodBase.GetCurrentMethod().Name,
                  e.Message, m_numRowsProcessed);

                // Commit the changes to the DB
                m_writer.Commit();
                m_detailWriter.Commit();

                m_reader.Close();
                throw;
            }
        }

        /// <summary>
        /// Loops through the previously completed transactions and reverses
        /// each transaction by sending a negative amount to TWE.  After each
        /// reversal transaction is complete, the corresponding row in the output
        /// table is removed for book keeping.
        /// </summary>
        protected override void RollbackVendorAudit()
        {
            m_Logger.LogTrace(System.Reflection.MethodBase.GetCurrentMethod().Name);

            // Read the input table.
            m_Logger.LogDebug("Reading {0}", GetInputTaxTableName());
            m_reader = new TaxManagerVendorInputTableReader(
              TaxVendor.Taxware, TaxRunId,
              true // Tell the InputTableReader we are attempting to rollback the audit info
              );

            // gain access to the output table.
            m_writer = new TaxManagerBatchDbTableWriter(
              GetOutputTaxTableName(), GetBulkInsertSize());

            try
            {
                // Create the worker threads and start them up.
                // Each worker thread will perform the following steps:
                //    read a row from the input table
                //    convert the row into a calculateDocumentRequest
                //    perform transaction with TWE
                //    remove the associated row from the output table
                StartWorkerThreads(true);

                // Wait for all of the threads to finish
                WaitForWorkerThreadsToFinish();

                // Commit the changes to the DB
                m_writer.Commit();

                // If m_stopAllThreads is true, report an error
                if (m_stopAllThreads)
                {
                    ReportWarning("Exceeded MaxNumErrors while performing Taxware rollback. " + m_numRowsProcessed +
                      " tax transactions processed.");
                }
                else
                {
                    ReportInfo("Completed Taxware rollback. " + m_numRowsProcessed +
                         " tax transactions processed.");
                }
                m_reader.Close();
            }
            catch (Exception e)
            {
                m_Logger.LogError("{0}: caught {1} while processing row {2}, rethrowing",
                  System.Reflection.MethodBase.GetCurrentMethod().Name,
                  e.Message, m_numRowsProcessed);

                // Commit the changes to the DB
                m_writer.Commit();
                m_detailWriter.Commit();

                m_reader.Close();
                throw;
            }
        }

        /// Populate the binding info needed by the client.
        /// This code mimics the population of the binding info
        /// found in the app.config file
        ///<basicHttpBinding>
        ///  <binding name="TaxCalculationManagerServiceSoapBinding" closeTimeout="00:01:00"
        ///    openTimeout="00:01:00" receiveTimeout="00:10:00" sendTimeout="00:01:00"
        //    allowCookies="false" bypassProxyOnLocal="false" hostNameComparisonMode="StrongWildcard"
        ///    maxBufferSize="65536" maxBufferPoolSize="524288" maxReceivedMessageSize="65536"
        ///    messageEncoding="Text" textEncoding="utf-8" transferMode="Buffered"
        ///    useDefaultWebProxy="true">
        ///    <readerQuotas maxDepth="32" maxStringContentLength="8192" maxArrayLength="16384"
        ///      maxBytesPerRead="4096" maxNameTableCharCount="16384" />
        ///    <security mode="None">
        ///      <transport clientCredentialType="None" proxyCredentialType="None"
        ///        realm="" />
        ///      <message clientCredentialType="UserName" algorithmSuite="Default" />
        ///    </security>
        ///  </binding>
        ///</basicHttpBinding>
        private BasicHttpBinding createAndPopulateBinding()
        {
            BasicHttpBinding serviceBinding = new BasicHttpBinding();
            serviceBinding.Name = "TaxCalculationManagerServiceSoapBinding";
            serviceBinding.CloseTimeout = new TimeSpan(0, 1, 0);
            serviceBinding.OpenTimeout = new TimeSpan(0, 1, 0);
            serviceBinding.ReceiveTimeout = new TimeSpan(0, 10, 0);
            serviceBinding.SendTimeout = new TimeSpan(0, 1, 0);
            serviceBinding.AllowCookies = false;
            serviceBinding.BypassProxyOnLocal = false;
            serviceBinding.HostNameComparisonMode = HostNameComparisonMode.StrongWildcard;
            serviceBinding.MaxBufferSize = 65536;
            serviceBinding.MaxBufferPoolSize = 524288;
            serviceBinding.MaxReceivedMessageSize = 65536;
            serviceBinding.MessageEncoding = WSMessageEncoding.Text;
            serviceBinding.TextEncoding = System.Text.Encoding.UTF8;
            serviceBinding.TransferMode = TransferMode.Buffered;
            serviceBinding.UseDefaultWebProxy = true;
            serviceBinding.ReaderQuotas = new XmlDictionaryReaderQuotas();
            serviceBinding.ReaderQuotas.MaxDepth = 32;
            serviceBinding.ReaderQuotas.MaxStringContentLength = 8192;
            serviceBinding.ReaderQuotas.MaxArrayLength = 16384;
            serviceBinding.ReaderQuotas.MaxBytesPerRead = 4096;
            serviceBinding.ReaderQuotas.MaxNameTableCharCount = 16384;
            serviceBinding.Security = new BasicHttpSecurity();
            serviceBinding.Security.Mode = BasicHttpSecurityMode.None;
            serviceBinding.Security.Transport = new HttpTransportSecurity();
            serviceBinding.Security.Transport.ClientCredentialType = HttpClientCredentialType.None;
            serviceBinding.Security.Transport.ProxyCredentialType = HttpProxyCredentialType.None;
            serviceBinding.Security.Transport.Realm = "";
            serviceBinding.Security.Message = new BasicHttpMessageSecurity();
            serviceBinding.Security.Message.ClientCredentialType = BasicHttpMessageCredentialType.UserName;
            serviceBinding.Security.Message.AlgorithmSuite = System.ServiceModel.Security.SecurityAlgorithmSuite.Default;

            return serviceBinding;
        }


        /// <summary>
        /// Populate the endpoint info needed by the client
        /// </summary>
        private EndpointAddress createAndPopulateEndpointAddress()
        {
            EndpointAddress endpoint = new EndpointAddress(m_configuration.Address);
            m_Logger.LogDebug("address={0}", endpoint.Uri);
            return endpoint;
        }

        /// <summary>
        /// This method creates and populates a calculateDocumentRequest using information
        /// from the inputs and member variables.  The resulting calculateDocumentRequest 
        /// is suitable to be sent to TWE.
        /// </summary>
        /// <param name="taxableTransaction">input row from the t_tax_input_* table</param>
        /// <param name="isReversal">True if client invoked RollbackVendorAudit(), false otherwise</param>
        /// <returns>calculateDocumentRequest object that is suitable to send to TWE server</returns>
        private calculateDocumentRequest TaxableTransactionToCalculateDocumentRequest(TaxableTransaction taxableTransaction,
          bool isReversal)
        {
            calculateDocumentRequest cdRequest = new calculateDocumentRequest();
            cdRequest.calculateDocumentRequest1 = new CalculationRequest();
            cdRequest.calculateDocumentRequest1.doc = new Doc();

            // Let TWE store/commit the audit info each time we submit the
            // calculate document request.
            cdRequest.calculateDocumentRequest1.isAudit = IsAuditingNeeded;

            // This is the tax calculation type.
            // The code that identifies the tax calculation type.
            // 0 = Organizational Default
            // 1 = Regular
            // 2 = Back Tax Calculation
            // 3 = Vending Regular
            // 4 = Vending Back Tax Calculation
            //
            // Currently using 1 for regular tax calculations, 2 for
            // implied tax calculations ("back calculations")
            Boolean isImpliedTax = taxableTransaction.GetBool("is_implied_tax").GetValueOrDefault();
            m_Logger.LogDebug("isImpliedTax={0}", isImpliedTax);
            if (!isImpliedTax)
            {
                cdRequest.calculateDocumentRequest1.doc.txCalcTp = 1;
            }
            else
            {
                cdRequest.calculateDocumentRequest1.doc.txCalcTp = 2;
            }

            // Transactions include username/password which come from
            // the taxware configuration files
            cdRequest.calculateDocumentRequest1.secrtySbj = new SecrtySbj();
            cdRequest.calculateDocumentRequest1.secrtySbj.usrname = m_configuration.UserName;
            cdRequest.calculateDocumentRequest1.secrtySbj.pswrd = m_configuration.Password;


            cdRequest.calculateDocumentRequest1.doc.lnItms = new LnItms();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm = new LnItm[1];
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0] = new LnItm();

            cdRequest.calculateDocumentRequest1.doc.docDt = taxableTransaction.GetDateTime("invoice_date").GetValueOrDefault();
            cdRequest.calculateDocumentRequest1.doc.docDtSpecified = true;

            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].accntDt = taxableTransaction.GetDateTime("invoice_date").GetValueOrDefault();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].accntDtSpecified = true;
#if false
      cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].origTrnDt = taxableTransaction.GetDateTime("invoice_date").GetValueOrDefault();
      cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].origTrnDtSpecified = true;
      cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].srvcPerfDt = taxableTransaction.GetDateTime("invoice_date").GetValueOrDefault();
      cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].srvcPerfDtSpecified = true;
#endif

            double amountToTax = (double)(taxableTransaction.GetDecimal("amount").GetValueOrDefault());
            if (isReversal)
            {
                // Change the sign of the amount on reversals.  This will
                // cause TWE to update the audit information correctly
                amountToTax = -1.0 * amountToTax;
            }
            m_Logger.LogDebug("amountToTax={0}", amountToTax);
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].grossAmt = amountToTax;

            // We always assume the quantity of items in the request is 1
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].qnty = 1;

            // The field on the transaction record that identifies the type of
            // transaction. The following transactions types are utilized:
            // 1 = Sale
            // 2 = Purchase
            // 3 = Rental, Option to Own (A/R)
            // 4 = Rental, Option to Own (A/P)
            // 5 = Rental, No option to Own (A/R)
            // 1 = Sale
            // 2 = Purchase
            // 3 = Rental, Option to Own (A/R)
            // 4 = Rental, Option to Own (A/P)
            // 5 = Rental, No option to Own (A/R)
            // 6 = Rental, No Option to Own (A/P)
            // 7 = Consignment Sale
            // 8 = Consignment Purchase
            // 9 = Installation Sale
            // 10 = Installation Purchase
            // 11 = Continuous Supply (A/R)
            // 12 = Continuous Supply (A/P)
            // 13 = Promotional Sale
            // 14 = Return (A/R)
            // 15 = Return (A/P)
            // 16 = Self-Supply (A/R)
            // 17 = Self-Supply (A/P)
            // 18 = Evaluated Receipts Payment (A/P)
            //
            // For now, we always use "Sale"
            //
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].trnTp = 1;

            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custrVend = new Bsns();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custrVend.name = taxableTransaction.GetString("customer_name");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custrVend.code = taxableTransaction.GetString("customer_code");

            // The organization code that is sending this transaction
            // (Note: The default value for organization_code is ROOT.  If you have this value,
            // TWE will compute generic taxes based on all of the other parameters.  However, if you
            // specify a real organization code (e.g. ConcurFrance), TWE might have customer specific rules
            // for computing the taxes (e.g. Only tax transactions where the "shipToCountry" is France).
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].org = new Bsns();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].org.code = taxableTransaction.GetString("organization_code");

            // Location where the bill is sent
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.addrs.streetNameNum = taxableTransaction.GetString("bill_to_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.addrs.city = taxableTransaction.GetString("bill_to_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.addrs.statePrv = taxableTransaction.GetString("bill_to_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.addrs.postCd = taxableTransaction.GetString("bill_to_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.addrs.cntry = taxableTransaction.GetString("bill_to_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.locCd = taxableTransaction.GetString("bill_to_location_code");
            int geoCode = taxableTransaction.GetInt32("bill_to_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].billTo.geoCd = geoCode;
            }

            // Location of order approval
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.addrs.streetNameNum = taxableTransaction.GetString("loa_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.addrs.city = taxableTransaction.GetString("loa_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.addrs.statePrv = taxableTransaction.GetString("loa_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.addrs.postCd = taxableTransaction.GetString("loa_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.addrs.cntry = taxableTransaction.GetString("loa_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.locCd = taxableTransaction.GetString("loa_location_code");
            geoCode = taxableTransaction.GetInt32("loa_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOA.geoCd = geoCode;
            }

            // Location at which an order is recorded
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.addrs.streetNameNum = taxableTransaction.GetString("lor_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.addrs.city = taxableTransaction.GetString("lor_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.addrs.statePrv = taxableTransaction.GetString("lor_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.addrs.postCd = taxableTransaction.GetString("lor_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.addrs.cntry = taxableTransaction.GetString("lor_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.locCd = taxableTransaction.GetString("lor_location_code");
            geoCode = taxableTransaction.GetInt32("lor_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lOR.geoCd = geoCode;
            }

            // Location at which service is performed
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.addrs.streetNameNum = taxableTransaction.GetString("lsp_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.addrs.city = taxableTransaction.GetString("lsp_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.addrs.statePrv = taxableTransaction.GetString("lsp_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.addrs.postCd = taxableTransaction.GetString("lsp_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.addrs.cntry = taxableTransaction.GetString("lsp_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.locCd = taxableTransaction.GetString("lsp_location_code");
            geoCode = taxableTransaction.GetInt32("lsp_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lSP.geoCd = geoCode;
            }

            // Location at which good/service is used
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.addrs.streetNameNum = taxableTransaction.GetString("lu_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.addrs.city = taxableTransaction.GetString("lu_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.addrs.statePrv = taxableTransaction.GetString("lu_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.addrs.postCd = taxableTransaction.GetString("lu_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.addrs.cntry = taxableTransaction.GetString("lu_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.locCd = taxableTransaction.GetString("lu_location_code");
            geoCode = taxableTransaction.GetInt32("lu_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].lU.geoCd = geoCode;
            }

            // Location from which goods are shipped
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.addrs.streetNameNum = taxableTransaction.GetString("ship_from_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.addrs.city = taxableTransaction.GetString("ship_from_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.addrs.statePrv = taxableTransaction.GetString("ship_from_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.addrs.postCd = taxableTransaction.GetString("ship_from_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.addrs.cntry = taxableTransaction.GetString("ship_from_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.locCd = taxableTransaction.GetString("ship_from_location_code");
            geoCode = taxableTransaction.GetInt32("ship_from_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipFrom.geoCd = geoCode;
            }

            // Location into which goods are shipped
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo = new Loc();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.addrs = new Addrs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.addrs.streetNameNum = taxableTransaction.GetString("ship_to_address");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.addrs.city = taxableTransaction.GetString("ship_to_city");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.addrs.statePrv = taxableTransaction.GetString("ship_to_state_province");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.addrs.postCd = taxableTransaction.GetString("ship_to_postal_code");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.addrs.cntry = taxableTransaction.GetString("ship_to_country");
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.locCd = taxableTransaction.GetString("ship_to_location_code");
            geoCode = taxableTransaction.GetInt32("ship_to_geo_code").GetValueOrDefault();
            if (geoCode != 0)
            {
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].shipTo.geoCd = geoCode;
            }

            // good or service code.  This is a TWE specific identifier associated with the
            // current item being taxed.  e.g. 
            //  2040216 - Coffee or tea
            //  2043097 - Liquid iced coffee, unsweetened...
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].goodSrv = new GoodSrv();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].goodSrv.myCd = taxableTransaction.GetString("good_or_service_code");

            // We can supply customer attributes if we want them to be in the audit trail
            // TBD VALIDATE IN AUDIT TRAIL
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custAttrbs = new CustAttrbs();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custAttrbs.custAttrb = new CustAttrb[1];
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custAttrbs.custAttrb[0] = new CustAttrb();
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custAttrbs.custAttrb[0].attrbName = "sku";
            cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].custAttrbs.custAttrb[0].attrbVl = taxableTransaction.GetString("sku");

            cdRequest.calculateDocumentRequest1.doc.currn = taxableTransaction.GetString("currency");

            // Create a uniqueTransactionId using taxRunId, id_tax_charge, and adapterUniqueId
            string uniqueTransactionId = String.Format(
                                   "{0}_{1}_{2}{3}_{4}",
                                   TaxRunId.ToString(), taxableTransaction.GetInt64("id_tax_charge").ToString(),
                                   (isReversal) ? "_rev" : "", AdapterUniqueRunId,
                                   DateTime.Now.ToString("yyyyMMddHHmmss", DateTimeFormatInfo.InvariantInfo));
            m_Logger.LogDebug("uniqueTransactionId={0}", uniqueTransactionId);
            cdRequest.calculateDocumentRequest1.doc.trnDocNm = uniqueTransactionId;
            cdRequest.calculateDocumentRequest1.trnId = uniqueTransactionId;

            // determines the verbosity of the calculateDocumentResponse
            cdRequest.calculateDocumentRequest1.rsltLvl = 1;

            return cdRequest;
        }

        /// <summary>
        /// Use input parameters to create and populate a row in the t_output_* table.
        /// </summary>
        /// <param name="cdResponse">calculateDocumentResponse object that was received from TWE server</param>
        /// <param name="idTaxCharge">identifier shared by t_tax_input_* and t_tax_output_* for this row</param>
        /// <param name="roundingAlgorithm">Determines which rounding algorithm should be used</param>
        /// <param name="roundingDigits">The number of digits after the decimal point after rounding</param>
        /// <returns>TaxManagerBatchDbVendorOutputRow object that can be written to t_tax_output_* table</returns>
        private TransactionTaxSummary CdResponseToTransactionSummary(ref calculateDocumentResponse cdResponse,
          long idTaxCharge, RoundingAlgorithm roundingAlgorithm, int roundingDigits)
        {
            TransactionTaxSummary transactionSummary = new TransactionTaxSummary();

            // initialize the transactionSummary
            // TBD seems odd, but required to eliminate crash
            transactionSummary.IdTaxCharge = 0;
            transactionSummary.TaxFedAmount = 0;
            transactionSummary.TaxFedRounded = 0;
            transactionSummary.TaxFedName = "";
            transactionSummary.TaxCountyAmount = 0;
            transactionSummary.TaxCountyName = "";
            transactionSummary.TaxCountyRounded = 0;
            transactionSummary.TaxLocalAmount = 0;
            transactionSummary.TaxLocalName = "";
            transactionSummary.TaxLocalRounded = 0;
            transactionSummary.TaxOtherAmount = 0;
            transactionSummary.TaxOtherName = "";
            transactionSummary.TaxOtherRounded = 0;
            transactionSummary.TaxStateAmount = 0;
            transactionSummary.TaxStateName = "";
            transactionSummary.TaxStateRounded = 0;
            transactionSummary.IdTaxCharge = idTaxCharge;

            if ((cdResponse.calculateDocumentResponse1 == null) ||
              (cdResponse.calculateDocumentResponse1.txDocRslt == null) ||
              (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts == null) ||
              (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt == null))
            {
                const string err = "Unexpected null in cdResponse";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<LnRslt> results = new List<LnRslt>(
              cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt);

            // We only expect one result, because we only sent one line item in the request
            if (results.Count != 1)
            {
                string err = "Received " + results.Count.ToString() +
                  "  results when we only expected 1";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<JurRslt> jurisdictionResults;
            if (results[0].jurRslts != null)
            {
                jurisdictionResults = new List<JurRslt>(results[0].jurRslts.jurRslt);
            }
            else
            {
                jurisdictionResults = new List<JurRslt>();
            }

            // If the tax vendor returns multiple tax charges for each category 
            // (e.g. multiple federal tax amounts), we want to store the name
            // of the tax with the greatest amount.  For example:
            //
            //    stateTaxAmount1 = 1.00
            //    stateTaxAmountName1 = "CA State Tax"
            //
            //    stateTaxAmount1 = 2.75
            //    stateTaxAmountName1 = "CA State Special Tax"
            //
            // Then we want
            //
            //    transactionSummary.TaxStateAmount = 3.75
            //    transactionSummary.TaxStateName = "CA State Special Tax"
            //
            double maxTaxFedAmount = 0;
            string maxTaxFedAmountName = "";
            double maxTaxStateAmount = 0;
            string maxTaxStateAmountName = "";
            double maxTaxCountyAmount = 0;
            string maxTaxCountyAmountName = "";
            double maxTaxLocalAmount = 0;
            string maxTaxLocalAmountName = "";

            // jurTp = Indicates the jurisdiction type with values 1,2,3,4,5,6.
            // 1=Country, 2=State, 3=County, 4=City, 5=District, 6=District2
            foreach (var jurisdictionResult in jurisdictionResults)
            {
                if (jurisdictionResult.txJurUID.jurTp == 1)
                {
                    // Federal
                    transactionSummary.TaxFedAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxFedAmount)
                    {
                        maxTaxFedAmount = jurisdictionResult.txAmt;
                        maxTaxFedAmountName = jurisdictionResult.txName;
                    }
                }
                else if (jurisdictionResult.txJurUID.jurTp == 2)
                {
                    // State
                    transactionSummary.TaxStateAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxStateAmount)
                    {
                        maxTaxStateAmount = jurisdictionResult.txAmt;
                        maxTaxStateAmountName = jurisdictionResult.txName;
                    }
                }
                else if (jurisdictionResult.txJurUID.jurTp == 3)
                {
                    // County
                    transactionSummary.TaxCountyAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxCountyAmount)
                    {
                        maxTaxCountyAmount = jurisdictionResult.txAmt;
                        maxTaxCountyAmountName = jurisdictionResult.txName;
                    }
                }
                else
                {
                    // Local
                    transactionSummary.TaxLocalAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxLocalAmount)
                    {
                        maxTaxLocalAmount = jurisdictionResult.txAmt;
                        maxTaxLocalAmountName = jurisdictionResult.txName;
                    }
                }

            }

            // Perform the appropriate rounding
            transactionSummary.TaxFedRounded = Rounding.Round(transactionSummary.TaxFedAmount.GetValueOrDefault(),
              roundingAlgorithm, roundingDigits);
            transactionSummary.TaxStateRounded = Rounding.Round(transactionSummary.TaxStateAmount.GetValueOrDefault(),
              roundingAlgorithm, roundingDigits);
            transactionSummary.TaxCountyRounded = Rounding.Round(transactionSummary.TaxCountyAmount.GetValueOrDefault(),
              roundingAlgorithm, roundingDigits);
            transactionSummary.TaxLocalRounded = Rounding.Round(transactionSummary.TaxLocalAmount.GetValueOrDefault(),
              roundingAlgorithm, roundingDigits);

            transactionSummary.TaxFedName = maxTaxFedAmountName;
            transactionSummary.TaxStateName = maxTaxStateAmountName;
            transactionSummary.TaxCountyName = maxTaxCountyAmountName;
            transactionSummary.TaxLocalName = maxTaxLocalAmountName;

            m_Logger.LogDebug(transactionSummary.ToString());

            return transactionSummary;
        }

        /// <summary>
        /// Converts the supplied calculateDocumentResponse object into 0 or more rows in the t_tax_details table
        /// </summary>
        /// <param name="cdResponse">calculateDocumentResponse object that was received from TWE server</param>
        /// <param name="taxRunId">The suffix on the t_tax_input_* and t_tax_output_* tables used during this run</param>
        /// <param name="idTaxCharge">identifier shared by t_tax_input_* and t_tax_output_* for this row</param>
        /// <param name="isImpliedTaxCalculation">True if this tax calculation was implied.  
        /// This means that the amount passed to TWE contained the item cost and the taxes.</param>
        /// <param name="idAcc">identifies the account</param>
        /// <param name="idUsageInterval">identifies the usage interval</param>
        /// <returns>List of TaxManagerBatchDbDetailRow to be added to the t_tax_details table.</returns>
        private List<TransactionIndividualTax> CdResponseToTransactionDetails(
          calculateDocumentResponse cdResponse, long idTaxCharge, bool isImpliedTaxCalculation,
          int idAcc, int idUsageInterval)
        {
            if ((cdResponse.calculateDocumentResponse1 == null) ||
              (cdResponse.calculateDocumentResponse1.txDocRslt == null) ||
              (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts == null) ||
              (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt == null))
            {
                const string err = "Unexpected null in cdResponse";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<LnRslt> results = new List<LnRslt>(
              cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt);

            // We only expect one result, because we only sent one line item in the request
            if (results.Count != 1)
            {
                string err = "Received " + results.Count.ToString() +
                  "  results when we only expected 1";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<TransactionIndividualTax> transactionDetails = new List<TransactionIndividualTax>();


            if ((results[0].jurRslts == null) ||
              (results[0].jurRslts.jurRslt == null))
            {
                // There are no details to return
                m_Logger.LogDebug("There are zero detailed results");
                return transactionDetails;
            }

            List<JurRslt> jurisdictionResults = new List<JurRslt>(
              results[0].jurRslts.jurRslt);

            DateTime now = DateTime.Now;

            // jurTp = Indicates the jurisdiction type with values 1,2,3,4,5,6.
            // 1=Country, 2=State, 3=County, 4=City, 5=District, 6=District2
            int idTaxDetailCounter = 1;
            foreach (var jurisdictionResult in jurisdictionResults)
            {
                TransactionIndividualTax transactionDetail = new TransactionIndividualTax();

                transactionDetail.IdTaxDetail = idTaxDetailCounter++;
                transactionDetail.TaxAmount = (decimal)jurisdictionResult.txAmt;
                transactionDetail.DateOfCalc = now;
                transactionDetail.IdTaxCharge = idTaxCharge;
                transactionDetail.IdTaxRun = TaxRunId;
                transactionDetail.IsImplied = isImpliedTaxCalculation;
                transactionDetail.IdAcc = idAcc;
                transactionDetail.IdUsageInterval = idUsageInterval;
                transactionDetail.Rate = (decimal)jurisdictionResult.txRate;
                transactionDetail.Notes = "";
                transactionDetail.TaxJurName = jurisdictionResult.txName;
                transactionDetail.TaxType = (int)(jurisdictionResult.txNameID);
                transactionDetail.TaxTypeName = jurisdictionResult.txName;

                // jurTp = Indicates the jurisdiction type with values 1,2,3,4,5,6.
                // 1=Country, 2=State, 3=County, 4=City, 5=District, 6=District2
                //
                // MT TaxJurLevel
                // 0-Federal, 1-State, 2,-County, 3-Local, 4-other
                transactionDetail.TaxJurLevel =
                  (jurisdictionResult.txJurUID.jurTp < 4) ? (jurisdictionResult.txJurUID.jurTp - 1) : 3;

                transactionDetails.Add(transactionDetail);
            }

            return transactionDetails;
        }

        /// <summary>
        /// Each worker thread performs the following steps
        /// While the input table is not empty:
        ///   * read a line from the input table
        ///   * convert this line into a calculateDocumentRequest
        ///   * Send the calculateDocumentRequest to TWE and retrieve the response
        ///   * Convert the response into a tax output table row
        ///   * Convert the response into one or more tax detail rows
        /// </summary>
        private void CalculateTaxesWorker()
        {
            try
            {
                // Populate the binding info needed by the client
                BasicHttpBinding taxServiceBinding = createAndPopulateBinding();

                // Populate the endpoint info needed by the client
                EndpointAddress taxServiceAddress = createAndPopulateEndpointAddress();

                // Provides access to the TWE server
                TaxCalculationManagerServiceInterface taxService =
                    new TaxCalculationManagerServiceInterfaceClient(taxServiceBinding, taxServiceAddress);

                // Represents a row in the TaxInputTable
                TaxableTransaction taxableTransaction;

                // Represents a row in the TaxOutputTable
                TransactionTaxSummary transactionSummary;

                // Represents a list of tax detail rows associated with a single tax transaction
                List<TransactionIndividualTax> transactionDetails;

                //
                // Loop through all of the potential taxable transactions
                //
                while ((m_stopAllThreads == false) && (null != (taxableTransaction = m_reader.GetNextTaxableTransaction())))
                {
                    try
                    {
                        // Perform transaction with taxware to populate the transactionSummary and taxDetailRows
                        PerformTaxTransaction(taxService,
                            false,  // isReversal
                            taxableTransaction,
                            out transactionSummary, out transactionDetails);

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
                        incrementRowsProcessed();
                    }
                    catch (FaultException<TweFault> e)
                    {
                        // This is an exception caused by the TWE service,
                        // so retrieve the details
                        string msg = String.Format(
                            "{0}: caught tweFltCd={1}, tweFltExcTp={2}, tweFltMsg='{3}' while processing row {4}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name,
                            e.Detail.tweFltCd, e.Detail.tweFltExcTp, e.Detail.tweFltMsg,
                            m_numRowsProcessed);

                        m_Logger.LogError(msg);
                        m_numErrors++;

                        // If we exceed the maximum number of errors, we throw the
                        // exception and stop.  Otherwise, we keep going.
                        if (m_numErrors > MaximumNumberOfErrors)
                        {
                            m_Logger.LogError("{0}: exceeded {1} errors, so rethrowing",
                                System.Reflection.MethodBase.GetCurrentMethod().Name,
                                MaximumNumberOfErrors);
                            throw new TaxException(msg);
                        }
                        ReportWarning(msg + ". Execution continuing since under the maximum number of errors.");
                    }
                    catch (TaxException e)
                    {
                        string msg = String.Format("{0}: caught {1} while processing row {2}",
                                                 System.Reflection.MethodBase.GetCurrentMethod().Name,
                                                 e.Message, m_numRowsProcessed);

                        m_Logger.LogError(msg);
                        m_numErrors++;

                        // If we exceed the maximum number of errors, we throw the
                        // exception and stop.  Otherwise, we keep going.
                        if (m_numErrors > MaximumNumberOfErrors)
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
                                                 e.Message, m_numRowsProcessed);
                        m_Logger.LogError(msg);
                        throw;
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogError("{0}: caught {1} while processing row {2}, rethrowing",
                       System.Reflection.MethodBase.GetCurrentMethod().Name,
                       e.Message, m_numRowsProcessed);
                m_stopAllThreads = true;
                throw;
            }
        }

        /// <summary>
        /// Each worker thread performs the following steps
        /// While the input table is not empty:
        ///   * read a line from the input table
        ///   * convert this line into a calculateDocumentRequest
        ///   * Send the calculateDocumentRequest to TWE and retrieve the response
        ///   * Remove the associated row from t_tax_output_*
        /// </summary>
        private void RollbackTaxesWorker()
        {
            try
            {
                // Populate the binding info needed by the client
                BasicHttpBinding taxServiceBinding = createAndPopulateBinding();

                // Populate the endpoint info needed by the client
                EndpointAddress taxServiceAddress = createAndPopulateEndpointAddress();

                // Provides access to the TWE server
                TaxCalculationManagerServiceInterface taxService =
                  new TaxCalculationManagerServiceInterfaceClient(taxServiceBinding, taxServiceAddress);

                // Represents a row in the TaxInputTable
                TaxableTransaction taxableTransaction;

                // Represents a row in the TaxOutputTable
                TransactionTaxSummary transactionSummary;

                // Represents a list of tax detail rows associated with a single tax transaction
                List<TransactionIndividualTax> transactionDetails;

                //
                // Loop through all of the potential taxable transactions
                //
                while (null != (taxableTransaction = m_reader.GetNextTaxableTransaction()))
                {
                    try
                    {
                        // Perform transaction with taxware to populate the transactionSummary and taxDetailRows
                        PerformTaxTransaction(taxService,
                            true,  // isReversal
                            taxableTransaction, out transactionSummary, out transactionDetails);

                        // If the "reverse" of this transaction is successful, we remove the 
                        // associated row from t_tax_output_*.  This insures that we won't
                        // reverse that row again.
                        //
                        // After RollbackVendorAudit is finished, t_tax_output_* will contain
                        // "reverse" transactions that have failed.  Therefore, this table should
                        // be empty after RollbackVendorAudit is finished.
                        m_writer.RemoveRow(transactionSummary.IdTaxCharge);
                    }
                    catch (FaultException<TweFault> e)
                    {
                        // This is an exception caused by the TWE service,
                        // so retrieve the details
                        string msg = String.Format(
                            "{0}: caught tweFltCd={1}, tweFltExcTp={2}, tweFltMsg='{3}' while processing row {4}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name,
                            e.Detail.tweFltCd, e.Detail.tweFltExcTp, e.Detail.tweFltMsg,
                            m_numRowsProcessed);

                        m_Logger.LogError(msg);
                        m_numErrors++;

                        // If we exceed the maximum number of errors, we throw the
                        // exception and stop.  Otherwise, we keep going.
                        if (m_numErrors > MaximumNumberOfErrors)
                        {
                            m_Logger.LogError("{0}: exceeded {1} errors, so rethrowing",
                                            System.Reflection.MethodBase.GetCurrentMethod().Name,
                                            MaximumNumberOfErrors);
                            throw new TaxException(msg);
                        }
                        ReportWarning(msg + ". Execution continuing since under the maximum number of errors.");
                    }
                    catch (TaxException e)
                    {
                        string msg = String.Format("{0}: caught {1} while processing row {2}",
                                                 System.Reflection.MethodBase.GetCurrentMethod().Name,
                                                 e.Message, m_numRowsProcessed);

                        m_Logger.LogError(msg);
                        m_numErrors++;

                        // If we exceed the maximum number of errors, we throw the
                        // exception and stop.  Otherwise, we keep going.
                        if (m_numErrors > MaximumNumberOfErrors)
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
                                                 e.Message, m_numRowsProcessed);
                        m_Logger.LogError(msg);
                        throw;
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogError("{0}: caught {1} while processing row {2}, rethrowing",
                                  System.Reflection.MethodBase.GetCurrentMethod().Name,
                                  e.Message, m_numRowsProcessed);
                throw;
            }
        }

        /// <summary>
        /// Threadsafe incrementing of m_numRowsProcessed
        /// </summary>
        private void incrementRowsProcessed()
        {
            lock (m_lock)
            {
                m_numRowsProcessed++;
                // Report on the progess on this input_table
                ReportProgress(m_numRowsProcessed);
            }
        }


        /// <summary>
        /// Create the worker threads and start them up.
        /// Each worker thread will perform the following steps:
        ///    read a row from the input table
        ///    convert the row into a calculateDocumentRequest
        ///    perform transaction with TWE
        ///    convert the calculateDocumentResponse into an output row and one or more output detail rows
        /// <param name="isRollback">True if the worker threads should perform rollback operations</param>
        /// </summary>
        private void StartWorkerThreads(bool isRollback)
        {
            for (int i = 0; i < m_configuration.NumWorkerThreads; i++)
            {
                Thread thread;
                if (isRollback)
                {
                    thread = new Thread(RollbackTaxesWorker);
                }
                else
                {
                    thread = new Thread(CalculateTaxesWorker);
                }
                thread.Name = String.Format("Taxware-{0}", i);
                thread.Start();
                m_threads.Add(thread);
            }
        }

        /// <summary>
        /// Wait for all of the threads to finish
        /// </summary>
        private void WaitForWorkerThreadsToFinish()
        {
            foreach (Thread thread in m_threads)
            {
                thread.Join();
            }
        }

        private void PerformTaxTransaction(
            TaxCalculationManagerServiceInterface taxService,
            bool isReversal,
            TaxableTransaction taxableTransaction,
            out TransactionTaxSummary transactionSummary,
            out List<TransactionIndividualTax> transactionDetails)
        {
            long idTaxCharge = 0;
            if (taxableTransaction.GetInt64("id_tax_charge").HasValue)
            {
                idTaxCharge = taxableTransaction.GetInt64("id_tax_charge").Value;
            }

            // Convert the input table row into a Taxware calculateDocumentRequest object.
            // This method will construct a BatchTaxCalculationRequest object and
            // populate that object with info from the "taxableTransaction".
            calculateDocumentRequest cdRequest = TaxableTransactionToCalculateDocumentRequest(
                taxableTransaction,
                isReversal
                );

            // Send the request to taxware and parse the response into a 
            // calculateDocumentResponse object.  Note: the audit info within
            // taxware will be committed.
            m_Logger.LogDebug("Invoking calculateDocument with grossAmt={0}",
                cdRequest.calculateDocumentRequest1.doc.lnItms.lnItm[0].grossAmt);

            calculateDocumentResponse cdResponse = taxService.calculateDocument(
                cdRequest);

            m_Logger.LogDebug("cdResponse.calculateDocumentResponse1.txDocRslt.txAmt={0}",
                cdResponse.calculateDocumentResponse1.txDocRslt.txAmt);
            m_Logger.LogDebug("txwTrnDocId={0}", cdResponse.calculateDocumentResponse1.txDocRslt.txwTrnDocId);
            m_Logger.LogDebug("txwTrnDocNm={0}", cdResponse.calculateDocumentResponse1.txDocRslt.trnDocNm);

            // Convert the calculateDocumentResponse object into an "transactionSummary" that is
            // suitable for the tax_output_* table and add the row to the DB.
            RoundingAlgorithm roundingAlgorithm = Rounding.GetAlgorithm(taxableTransaction.GetString("round_alg"));
            int roundingDigits = taxableTransaction.GetInt32("round_digits").GetValueOrDefault();
            transactionSummary = CdResponseToTransactionSummary(
                ref cdResponse, idTaxCharge,
                roundingAlgorithm, roundingDigits);

            m_Logger.LogInfo("TaxDetailsNeeded : {0}", TaxDetailsNeeded);

            // Create the detail information.  It may or may not be stored in the DB.
            transactionDetails = null;
            {
                Boolean isImpliedTax = taxableTransaction.GetBool("is_implied_tax").GetValueOrDefault();

                int idAcc = taxableTransaction.GetInt32("id_acc").GetValueOrDefault();
                int idUsageInterval = taxableTransaction.GetInt32("id_usage_interval").GetValueOrDefault();

                transactionDetails = CdResponseToTransactionDetails(
                    cdResponse, idTaxCharge, isImpliedTax, idAcc, idUsageInterval);

                m_Logger.LogDebug("transactionDetails.Count={0}", transactionDetails.Count);
                foreach (var transactionDetail in transactionDetails)
                {
                    m_Logger.LogDebug(transactionDetail.ToString());
                }
            }
        }
    }
}

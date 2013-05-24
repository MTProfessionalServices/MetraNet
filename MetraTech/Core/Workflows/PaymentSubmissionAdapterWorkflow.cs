using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech.Core.Activities;
using MetraTech.DataAccess;
using MetraTech.DomainModel.MetraPay;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using MetraTech.Interop.RCD;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTServerAccess;
using System.Threading;
using System.ServiceModel;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.COMMeter;
using System.Xml;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using System.Linq;
using System.Linq.Expressions;
using System.Transactions;

namespace MetraTech.Core.Workflows
{
  public class PaymentSubmissionAdapterWorkflow : MTAdapterWorkflowBase
  {
    #region Members
    [NonSerialized]
    public List<PendingPaymentRequest> m_PendingRequests = new List<PendingPaymentRequest>();
    [NonSerialized]
    public List<PendingPaymentRequest> m_SuccessfulRequests = new List<PendingPaymentRequest>();
    [NonSerialized]
    public List<PendingPaymentRequest> m_FailedRequests = new List<PendingPaymentRequest>();

    [NonSerialized]
    public PaymentSubmissionAdapterConfig m_ConfigSection;

    [NonSerialized]
    public Logger m_Logger = new Logger("[PaymentSubmissionAdapterWorkflow]");

    [NonSerialized]
    protected bool clientFaulted = false;
    #endregion

    public PaymentSubmissionAdapterWorkflow()
    {
    }

    #region Workflow Methods
    public void LoadConfiguration_ExecuteCode(object sender, EventArgs e)
    {
      IMTRcd rcd = new MTRcdClass();

      string configFileName = (Path.IsPathRooted(ConfigFile) ? ConfigFile : Path.Combine(rcd.ExtensionDir, ConfigFile));

      m_ConfigSection = new PaymentSubmissionAdapterConfig(configFileName);
    }

    public void GetPendingPayments_ExecuteCode(object sender, EventArgs e)
    {
      PendingPaymentRequest pendingRequest;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          string queryTag = null;

          if (ExecutionContext.EventType == MetraTech.UsageServer.RecurringEventType.EndOfPeriod)
          {
              queryTag = "__GET_PENDING_PAYMENT_REQUESTS__";
          } 
          else if (ExecutionContext.EventType == MetraTech.UsageServer.RecurringEventType.Scheduled)
          {
              queryTag = "__GET_SCHEDULED_PAYMENT_REQUESTS__";
          }

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\PaymentSubmissionAdapter", queryTag))
          {
              if (ExecutionContext.EventType == MetraTech.UsageServer.RecurringEventType.EndOfPeriod)
              {
              stmt.AddParam("%%INTERVAL_ID%%", this.ExecutionContext.UsageIntervalID, true);
              stmt.AddParam("%%BILLGROUP_ID%%", this.ExecutionContext.BillingGroupID, true);
              }
              else if(ExecutionContext.EventType == MetraTech.UsageServer.RecurringEventType.Scheduled)
              {
                  stmt.AddParam("%%DT_START%%", this.ExecutionContext.StartDate);
                  stmt.AddParam("%%DT_END%%", this.ExecutionContext.EndDate);
              }

              IMTDataReader rdr = stmt.ExecuteReader();

              Dictionary<int, PendingPaymentRequest> dicPendRequests = new Dictionary<int, PendingPaymentRequest>();

              while (rdr.Read())
              {
                  if (dicPendRequests.ContainsKey(rdr.GetInt32("id_pending_payment")))
                  {
                      if (!rdr.IsDBNull("id_detail"))
                      {
                          pendingRequest = dicPendRequests[rdr.GetInt32("id_pending_payment")];

                          if (pendingRequest.PaymentInfo.MetraPaymentInvoices == null)
                              pendingRequest.PaymentInfo.MetraPaymentInvoices = new List<MetraPaymentInvoice>();


                          MetraPaymentInvoice invoice = new MetraPaymentInvoice();
                          if (!rdr.IsDBNull("dt_invoice"))
                          {
                              invoice.InvoiceDate = rdr.GetDateTime("dt_invoice");
                          }
                          invoice.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                          invoice.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");
                          invoice.AmountToPay = rdr.GetDecimal("n_invoice_amount");

                          pendingRequest.PaymentInfo.MetraPaymentInvoices.Add(invoice);
                      }
                  }

                  else
                  {
                      pendingRequest = new PendingPaymentRequest();
                      pendingRequest.PendingPaymentID = rdr.GetInt32("id_pending_payment");
                      pendingRequest.AccountID = rdr.GetInt32("id_acc");
                      pendingRequest.PaymentInstrumentID = new Guid(rdr.GetString("id_payment_instrument"));
                      pendingRequest.TryDunning = (rdr.GetString("b_try_dunning") == "1");

                      if (!rdr.IsDBNull("id_authorization"))
                      {
                          pendingRequest.AuthorizationID = new Guid(rdr.GetString("id_authorization"));
                      }

                      pendingRequest.PaymentInfo = GetPaymentInfo(rdr);


                      pendingRequest.PaymentInfo.Description = (!rdr.IsDBNull("nm_description") ? rdr.GetString("nm_description") : "");
                      pendingRequest.PaymentInfo.Currency = rdr.GetString("nm_currency");
                      pendingRequest.PaymentInfo.Amount = rdr.GetDecimal("n_amount");

                      pendingRequest.MethodType = (PaymentType)EnumHelper.GetCSharpEnum(rdr.GetInt32("n_payment_method_type"));

                      if (!rdr.IsDBNull("id_creditcard_type"))
                      {
                          pendingRequest.CreditCardType = (MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)EnumHelper.GetCSharpEnum(rdr.GetInt32("id_creditcard_type"));
                      }

                      pendingRequest.AccountNumber = rdr.GetString("nm_truncd_acct_num");

                      if (!rdr.IsDBNull("id_detail"))
                      {
                          if (pendingRequest.PaymentInfo.MetraPaymentInvoices == null)
                              pendingRequest.PaymentInfo.MetraPaymentInvoices = new List<MetraPaymentInvoice>();

                          MetraPaymentInvoice invoice = new MetraPaymentInvoice();
                          if (!rdr.IsDBNull("dt_invoice"))
                          {
                              invoice.InvoiceDate = rdr.GetDateTime("dt_invoice");
                          }

                          invoice.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                          invoice.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");
                          invoice.AmountToPay = rdr.GetDecimal("n_invoice_amount");

                          pendingRequest.PaymentInfo.MetraPaymentInvoices.Add(invoice);


                          dicPendRequests.Add(pendingRequest.PendingPaymentID, pendingRequest);
                      }
                  }

                  
              }

              if (dicPendRequests.Count > 0)
                m_PendingRequests = dicPendRequests.Values.ToList();
              
              //m_PendingRequests.Add(pendingRequest);

              m_Logger.LogDebug("Found {0} payments to process", m_PendingRequests.Count);
          }
      }
    }

    public void ExecutePayments_ExecuteCode(object sender, EventArgs e)
    {
      if (m_PendingRequests.Count > 0)
      {
        try
        {
          // create collection store active threads and number of processing buckets
          List<Thread> activeThreads = new List<Thread>();
          int numBuckets = m_ConfigSection.MaxConcurrentRequests;

          // quick way to spread out data into buckets
          int bucketSize = (m_PendingRequests.Count / numBuckets) + 1;

          // starting position of the current bucket
          int start = 0;

          int remainingRequests = m_PendingRequests.Count;
          m_Logger.LogDebug("There are currently {0} requests that will be processed in {1} threads", remainingRequests, numBuckets);
          // only create buckets if we still have additional records to process
          for (int i = 0; i < numBuckets; i++)
          {
            if (remainingRequests > 0)
            {
              List<PendingPaymentRequest> bucket = null;
              // select a range of requests and put it into the bucket for processing
              if (numBuckets == (i + 1))
                bucket = m_PendingRequests.GetRange(start, remainingRequests);
              else
              {
                if (bucketSize > remainingRequests)
                  bucket = m_PendingRequests.GetRange(start, remainingRequests);
                else
                  bucket = m_PendingRequests.GetRange(start, bucketSize);
              }

              // set the start index for the next batch
              start += bucketSize;

              // decrement the number of remaining requests
              remainingRequests = remainingRequests - bucketSize;

              // fire up the threads, start them and add them to active threads collection 
              Thread process = new Thread(new ParameterizedThreadStart(ProcessBucket));
              process.Start(bucket);
              activeThreads.Add(process);
            }
            else
              break;
          }
          // wait for threads to finish up
          foreach (Thread t in activeThreads)
          {
            t.Join();
          }

          m_Logger.LogDebug("Finished processing all pending payment requests.");
        }
        catch (Exception ex)
        {
          m_Logger.LogException("Exception caught in ExecutePayments", ex);
          base.ExecutionContext.RecordWarning(string.Format("Exception caught in ExecutePayments: {0}", ex.Message));
          throw;
        }
      }
      else
      {
        m_Logger.LogInfo("There are no pending requests to process");
      }
    }

    public void UpdatePendingPayments_ExecuteCode(object sender, EventArgs e)
    {
      List<PendingPaymentRequest> updates = new List<PendingPaymentRequest>(m_SuccessfulRequests);
      updates.AddRange(m_FailedRequests);

      if (updates.Count > 0)
      {
        IMTQueryAdapter qa = new MTQueryAdapterClass();
        qa.Init(@"Queries\UsageServer\Adapters\PaymentSubmissionAdapter");

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          string updateQueries = "BEGIN\n";

          for (int i = 0; i < updates.Count; i++)
          {
            qa.SetQueryTag("__UPDATE_PENDING_PAYMENT__");

            qa.AddParam("%%PENDING_PAYMENT_ID%%", updates[i].PendingPaymentID, true);

            updateQueries += qa.GetQuery().Trim() + ";\n";

            m_Logger.LogDebug("Update set size: {0}", m_ConfigSection.UpdateSetSize);

            if ((i + 1) % m_ConfigSection.UpdateSetSize == 0)
            {
                try
                {
                    updateQueries += "END;";
                    m_Logger.LogDebug("Executing {0}", updateQueries);
                    using (IMTStatement stmt = conn.CreateStatement(updateQueries))
                    {

                        stmt.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    m_Logger.LogException("Exception updating successful entries", ex);
                    m_Logger.LogError("Exception when running following updates:\n{0}", updateQueries);
                }

              updateQueries = "BEGIN\n";
            }
          }

          if (updateQueries.Length > 0)
          {
              try
              {
                  updateQueries += "END;";

                  using (IMTStatement stmt = conn.CreateStatement(updateQueries))
                  {

                      stmt.ExecuteNonQuery();
                  }
              }
              catch (Exception ex)
              {
                  m_Logger.LogException("Exception updating successful entries", ex);
                  m_Logger.LogError("Exception when running following updates:\n{0}", updateQueries);
              }

            updateQueries = "";
          }
        }
      }
    }

    /* **** COMMENTED OUT, Meter payment has been moved to ElectronicPaymentService.
    public void MeterPayments_ExecuteCode(object sender, EventArgs e)
    {
      if (m_SuccessfulRequests.Count > 0)
      {
        string msg = string.Format("{0} payment transactions were processed successfully", m_SuccessfulRequests.Count);
        m_Logger.LogInfo(msg);
        ExecutionContext.RecordInfo(msg);

        Meter meterSDK = new MeterClass();
        meterSDK.Startup();

        MTServerAccessDataSet sads = new MTServerAccessDataSetClass();
        sads.Initialize();
        MTServerAccessData svr = sads.FindAndReturnObject("AdjustmentsServer");

        meterSDK.AddServer(svr.Priority, svr.ServerName, (svr.Secure != 0 ? PortNumber.DEFAULT_HTTPS_PORT : PortNumber.DEFAULT_HTTP_PORT), svr.Secure, svr.UserName, svr.Password);

        SessionSet sessionSet = meterSDK.CreateSessionSet();

        for (int i = 0; i < m_SuccessfulRequests.Count; i++)
        {
          Session s = sessionSet.CreateSession("metratech.com/Payment");

          s.InitProperty("_AccountID", m_SuccessfulRequests[i].AccountID);
          m_Logger.LogDebug("Metering amount {0} for account {1}", -1 * m_SuccessfulRequests[i].PaymentInfo.Amount, m_SuccessfulRequests[i].AccountID);
          s.InitProperty("_Amount", -1 * m_SuccessfulRequests[i].PaymentInfo.Amount);
          s.InitProperty("Description", m_SuccessfulRequests[i].PaymentInfo.Description);
          s.InitProperty("EventDate", MetraTime.Now);
          s.InitProperty("Source", "MT");

          switch (m_SuccessfulRequests[i].MethodType)
          {
            case PaymentType.Credit_Card:
              s.InitProperty("PaymentMethod", "Credit Card");
              break;
            case PaymentType.ACH:
              s.InitProperty("PaymentMethod", "ACH");
              break;
          }

          s.InitProperty("CCType", (string)EnumHelper.GetEnumEntryName(m_SuccessfulRequests[i].CreditCardType));
          s.InitProperty("CheckOrCardNumber", m_SuccessfulRequests[i].AccountNumber.Substring(m_SuccessfulRequests[i].AccountNumber.Length - 4));

          if (i % m_ConfigSection.SessionSetSize == 0)
          {
            sessionSet.Close();

            sessionSet = meterSDK.CreateSessionSet();
          }
        }

        if (sessionSet.GetSessions().Count > 0)
        {
          sessionSet.Close();
        }

        meterSDK.Shutdown();
      }
    }
    */
    public void ProcessFailures_ExecuteCode(object sender, EventArgs e)
    {
      string msg = string.Format("{0} payment transactions were failed by the payment processor", m_FailedRequests.Count);
      m_Logger.LogInfo(msg);
      ExecutionContext.RecordInfo(msg);

      if (m_FailedRequests.Count > 0)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          foreach (PendingPaymentRequest request in m_FailedRequests)
          {
              if (request.TryDunning)
              {
              try
              {
                  using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.None))
                  {
                      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\PaymentSubmissionAdapter", "__INSERT_FAILED_PAYMENT__"))
                      {

                          stmt.AddParam("%%INTERVAL_ID%%", ExecutionContext.UsageIntervalID, true);
                          stmt.AddParam("%%ACCOUNT_ID%%", request.AccountID, true);
                          stmt.AddParam("%%PI_ID%%", request.PaymentInstrumentID.ToString("D"), true);
                          stmt.AddParam("%%DT_ORIG%%", MetraTime.Now, true);
                          stmt.AddParam("%%DESC%%", request.PaymentInfo.Description, true);
                          stmt.AddParam("%%CURRENCY%%", request.PaymentInfo.Currency, true);
                          stmt.AddParam("%%AMOUNT%%", request.PaymentInfo.Amount, true);

                          AddCustomFailedPaymentParams(stmt, request);

                          stmt.ExecuteNonQuery();
                          stmt.ClearQuery();
                      }

                      if (request.PaymentInfo.MetraPaymentInvoices != null && request.PaymentInfo.MetraPaymentInvoices.Count > 0)
                      {
                          foreach (MetraPaymentInvoice invoice in request.PaymentInfo.MetraPaymentInvoices)
                          {
                              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\PaymentSubmissionAdapter", "__INSERT_FAILED_PAYMENT_DETAILS__"))
                              {
                                  stmt.AddParam("%%INTERVAL_ID%%", ExecutionContext.UsageIntervalID, true);
                                  stmt.AddParam("%%ACCOUNT_ID%%", request.AccountID, true);
                                  stmt.AddParam("%%PI_ID%%", request.PaymentInstrumentID.ToString("D"), true);
                                  stmt.AddParam("%%INVOICE_NUM%%", invoice.InvoiceNum, true);
                                  stmt.AddParam("%%DT_INVOICE%%", invoice.InvoiceDate.Value, true);
                                  stmt.AddParam("%%PO_NUM%%", invoice.PONum, true);
                                  stmt.AddParam("%%AMOUNT%%", invoice.AmountToPay, true);
                                  stmt.ExecuteNonQuery();
                                  stmt.ClearQuery();
                              }
                          }
                      }

                      scope.Complete();

                  }
              }
              catch (Exception ex)
              {
                  msg = string.Format("Exception caught writing failed payment record for account {0} and payment instrument {1}", request.AccountID, request.PaymentInstrumentID);
                  m_Logger.LogException(msg, ex);

                  ExecutionContext.RecordWarning(msg);
              }
          }
        }
      }
    }
    }

    #endregion

    #region Helper Methods
    private void ProcessBucket(object items)
    {
        RecurringPaymentsServiceClient client = null;
        PendingPaymentRequest pendingRequest = new PendingPaymentRequest();

        try
        {
            List<PendingPaymentRequest> bucket = (List<PendingPaymentRequest>)items;

            if (bucket.Count > 0)
            {
                string configFilePath = m_ConfigSection.WCFConfigFile;

                if (!Path.IsPathRooted(configFilePath))
                {
                    IMTRcd rcd = new MTRcdClass();
                    configFilePath = Path.Combine(rcd.ExtensionDir, configFilePath);
                }

                // Payment Processing Logic
                // will create and open client
                client = CreateClient(configFilePath);

                for (int i = 0; i < bucket.Count; i++)
                {
                    try
                    {
                        pendingRequest = bucket[i];
                        if (pendingRequest.AuthorizationID.HasValue)
                        {
                          client.CapturePreauthorizedChargeV2(pendingRequest.AuthorizationID.Value, pendingRequest.PaymentInstrumentID, ref pendingRequest.PaymentInfo, m_ConfigSection.Timeout, "");
                        }
                        else if (pendingRequest.PaymentInfo.Amount > 0)
                        {
                            client.DebitPaymentMethodV2(pendingRequest.PaymentInstrumentID, ref pendingRequest.PaymentInfo, m_ConfigSection.Timeout, "");
                        }
                        else if (pendingRequest.PaymentInfo.Amount < 0)
                        {
                            client.CreditPaymentMethodV2(pendingRequest.PaymentInstrumentID, ref pendingRequest.PaymentInfo, m_ConfigSection.Timeout, "");
                        }
                        AddSuccessfulRequest(pendingRequest);
                    }

                    catch (FaultException<PaymentProcessorFaultDetail> fe)
                    {
                        m_Logger.LogException(string.Format("Error occurred at payment processor in Capture request for account {0} with payment instrument {1}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID), fe);
                        foreach (string err in fe.Detail.ErrorMessages)
                        {
                            m_Logger.LogError("Error was: {0}", err);
                        }

                        pendingRequest.ProcessorFaultDetail = fe.Detail;
                        AddFailedRequest(pendingRequest);
                    }
                    catch (FaultException<MASBasicFaultDetail> fe)
                    {
                        m_Logger.LogException(string.Format("MASBasicException in Capture request for account {0} with payment instrument {1}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID), fe);
                        foreach (string err in fe.Detail.ErrorMessages)
                        {
                            m_Logger.LogError("Error was: {0}", err);
                        }

                        ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Capture for account {0} with payment instrument '{1}'.  Error message was: {2}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID, fe.Message));
                    }
                    catch (Exception e)
                    {
                        m_Logger.LogException(string.Format("Exception in Capture request for account {0} with payment instrument {1}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID), e);
                        ExecutionContext.RecordWarning(string.Format("Unknown error caught during Capture for account {0} with payment instrument '{1}'.  Error message was: {2}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID, e.Message));
                            try 
                            { 
                                client.Close(); 
                                client = null;
                            }
                            catch
                            {
                                if (null != client) 
                                {
                        client.Abort();
                                } 
                            }
                        client = CreateClient(configFilePath);
                    }
                }
                    if (null != client) 
                    {
                        try
                        {    
                client.Close();
                            client = null;
            }
                        catch
                        {
                            if (null != client)
                            {
                                client.Abort();
                            }
                        }
                    }
                }
            else
            {
                m_Logger.LogDebug("No requests to process.");
            }
        }
        catch (Exception e)
        {
            // get rid of client if there is an exception
            m_Logger.LogException("Aborting payment processing execution.  An unknown error has occurred.  Please review system logs.", e);
            ExecutionContext.RecordWarning(string.Format("Unknown error caught processing payments.  Error was: {0}", e.Message));
            if (client != null)
            {
                client.Abort();
            }
        }
    }

    private void AddFailedRequest(PendingPaymentRequest request)
    {
      lock (m_FailedRequests)
      {
        m_FailedRequests.Add(request);
      }
    }

    private void AddSuccessfulRequest(PendingPaymentRequest request)
    {
      lock (m_SuccessfulRequests)
      {
        m_SuccessfulRequests.Add(request);
      }
    }

    private RecurringPaymentsServiceClient CreateClient(string configFilePath)
    {
      IMTServerAccessDataSet serverAccessSet = new MTServerAccessDataSetClass();
      IMTServerAccessData superUser = serverAccessSet.FindAndReturnObjectIfExists("SuperUser");

      RecurringPaymentsServiceClient client = MASClientClassFactory.CreateClient<RecurringPaymentsServiceClient>(configFilePath, m_ConfigSection.EPSEndpoint);      
      client.ClientCredentials.UserName.UserName = superUser.UserName;
      client.ClientCredentials.UserName.Password = superUser.Password;

      client.Open();
      return client;
    }

    #endregion

    #region Callback Methods
    //public void CaptureCallback(IAsyncResult state)
    //{
    //  PendingPaymentRequest request = (PendingPaymentRequest)state.AsyncState;

    //  try
    //  {
    //    request.Client.EndCapturePreauthorizedCharge(state);

    //    m_SuccessfulRequests.Add(request);
    //  }
    //  catch (FaultException<PaymentProcessorFaultDetail> fe)
    //  {
    //    m_Logger.LogException(string.Format("Error occurred at payment processor in Capture request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), fe);
    //    foreach (string err in fe.Detail.ErrorMessages)
    //    {
    //      m_Logger.LogError("Error was: {0}", err);
    //    }

    //    request.ProcessorFaultDetail = fe.Detail;
    //    m_FailedRequests.Add(request);
    //  }
    //  catch (FaultException<MASBasicFaultDetail> fe)
    //  {
    //    m_Logger.LogException(string.Format("MASBasicException in Capture request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), fe);
    //    foreach (string err in fe.Detail.ErrorMessages)
    //    {
    //      m_Logger.LogError("Error was: {0}", err);
    //    }

    //    ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Capture for account {0} with payment instrument '{1}'.  Error message was: {2}", request.AccountID, request.PaymentInstrumentID, fe.Message));
    //  }
    //  catch (Exception e)
    //  {
    //    m_Logger.LogException(string.Format("Exception in Capture request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), e);

    //    ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Capture for account {0} with payment instrument '{1}'.  Error message was: {2}", request.AccountID, request.PaymentInstrumentID, e.Message));

    //    clientFaulted = true;
    //  }
    //}

    //public void DebitCallback(IAsyncResult state)
    //{
    //  PendingPaymentRequest request = (PendingPaymentRequest)state.AsyncState;

    //  try
    //  {
    //    request.Client.EndDebitPaymentMethod(state);

    //    m_SuccessfulRequests.Add(request);
    //  }
    //  catch (FaultException<PaymentProcessorFaultDetail> fe)
    //  {
    //    m_Logger.LogException(string.Format("Error occurred at payment processor in Debit request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), fe);
    //    foreach (string err in fe.Detail.ErrorMessages)
    //    {
    //      m_Logger.LogError("Error was: {0}", err);
    //    }

    //    request.ProcessorFaultDetail = fe.Detail;
    //    m_FailedRequests.Add(request);
    //  }
    //  catch (FaultException<MASBasicFaultDetail> fe)
    //  {
    //    m_Logger.LogException(string.Format("MASBasicException in Debit request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), fe);
    //    foreach (string err in fe.Detail.ErrorMessages)
    //    {
    //      m_Logger.LogError("Error was: {0}", err);
    //    }

    //    ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", request.AccountID, request.PaymentInstrumentID, fe.Message));
    //  }
    //  catch (Exception e)
    //  {
    //    m_Logger.LogException(string.Format("Exception in Debit request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), e);

    //    ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", request.AccountID, request.PaymentInstrumentID, e.Message));

    //    clientFaulted = true;
    //  }
    //}

    //public void CreditCallback(IAsyncResult state)
    //{
    //  PendingPaymentRequest request = (PendingPaymentRequest)state.AsyncState;

    //  try
    //  {
    //    request.Client.EndCreditPaymentMethod(state);

    //    m_SuccessfulRequests.Add(request);
    //  }
    //  catch (FaultException<PaymentProcessorFaultDetail> fe)
    //  {
    //    m_Logger.LogException(string.Format("Error occurred at payment processor in Capture request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), fe);
    //    foreach (string err in fe.Detail.ErrorMessages)
    //    {
    //      m_Logger.LogError("Error was: {0}", err);
    //    }

    //    request.ProcessorFaultDetail = fe.Detail;
    //    m_FailedRequests.Add(request);
    //  }
    //  catch (FaultException<MASBasicFaultDetail> fe)
    //  {
    //    m_Logger.LogException(string.Format("MASBasicException in Capture request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), fe);
    //    foreach (string err in fe.Detail.ErrorMessages)
    //    {
    //      m_Logger.LogError("Error was: {0}", err);
    //    }

    //    ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Capture for account {0} with payment instrument '{1}'.  Error message was: {2}", request.AccountID, request.PaymentInstrumentID, fe.Message));
    //  }
    //  catch (Exception e)
    //  {
    //    m_Logger.LogException(string.Format("Exception in Capture request for account {0} with payment instrument {1}", request.AccountID, request.PaymentInstrumentID), e);

    //    ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Capture for account {0} with payment instrument '{1}'.  Error message was: {2}", request.AccountID, request.PaymentInstrumentID, e.Message));

    //    clientFaulted = true;
    //  }
    //}
    #endregion

    #region Virtual Methods
    public virtual MetraPaymentInfo GetPaymentInfo(IMTDataReader dataReader)
    {
      MetraPaymentInfo paymentInfo = new MetraPaymentInfo();

      return paymentInfo;
    }

    public virtual void AddCustomFailedPaymentParams(IMTAdapterStatement stmt, PendingPaymentRequest failedPaymentRequest)
    {
    }
    #endregion
  }

  public struct PendingPaymentRequest
  {
    public int PendingPaymentID;
    public int AccountID;
    public Guid PaymentInstrumentID;
    public MetraPaymentInfo PaymentInfo;
    public Guid? AuthorizationID;

    public bool TryDunning;

    public PaymentType MethodType;
    public Nullable<MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType> CreditCardType;
    public string AccountNumber;

    public RecurringPaymentsServiceClient Client;

    public PaymentProcessorFaultDetail ProcessorFaultDetail;
  }

  public class PaymentSubmissionAdapterConfig
  {
    #region Members
    private string m_WCFConfigFile;
    private string m_EPSEndpoint;
    private int m_MaxConcurrentRequests;
    private int m_SessionSetSize;
    private int m_UpdateSetSize;
    private double m_timeout;
    #endregion

    public PaymentSubmissionAdapterConfig(string configFilePath)
    {
      XmlDocument configFile = new XmlDocument();
      configFile.Load(configFilePath);

      XmlNode root = configFile.SelectSingleNode("//PaymentSubmissionAdapter");

      foreach (XmlNode childNode in root.ChildNodes)
      {
        switch (childNode.Name)
        {
          case "WCFConfigFile":
            m_WCFConfigFile = childNode.InnerText;
            break;

          case "EPSEndpoint":
            m_EPSEndpoint = childNode.InnerText;
            break;

          case "MaxConcurrentRequests":
            m_MaxConcurrentRequests = int.Parse(childNode.InnerText);
            break;

          case "SessionSetSize":
            m_SessionSetSize = int.Parse(childNode.InnerText);
            break;

          case "UpdateSetSize":
            m_UpdateSetSize = int.Parse(childNode.InnerText);
            break;

          case "PaymentServerTimeout":
            m_timeout = double.Parse(childNode.InnerText);
            break;
        }
      }
    }

    #region Properties
    public string WCFConfigFile
    {
      get { return m_WCFConfigFile; }
    }

    public string EPSEndpoint
    {
      get { return m_EPSEndpoint; }
    }

    public int MaxConcurrentRequests
    {
      get { return m_MaxConcurrentRequests; }
    }

    public int SessionSetSize
    {
      get { return m_SessionSetSize; }
    }

    public int UpdateSetSize
    {
      get { return m_UpdateSetSize; }
    }

    public double Timeout
    {
        get { return m_timeout; }
    }
    #endregion
  }  
}

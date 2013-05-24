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
using MetraTech.ActivityServices.Activities;
using MetraTech.Core.Activities;
using System.Xml;
using MetraTech.Interop.RCD;
using System.IO;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using System.Collections.Generic;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Interop.MTServerAccess;
using MetraTech.ActivityServices.Common;
using System.Threading;
using System.ServiceModel;
using MetraTech.Interop.COMMeter;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.MTLocaleConfig;
using System.Linq;
using System.Linq.Expressions;

namespace MetraTech.Core.Workflows
{
  public class CreditCardDunningAdapterWorkflow : MTAdapterWorkflowBase
  {
    #region Members
    [NonSerialized]
    public List<FailedPaymentRequest> m_PendingRequests = new List<FailedPaymentRequest>();
    [NonSerialized]
    public List<FailedPaymentRequest> m_CompletedRequests = new List<FailedPaymentRequest>();

    [NonSerialized]
    public List<FailedPaymentRequest>.Enumerator m_CompletedRequestsIter;

    [NonSerialized]
    public CCDunningAdapterConfig m_ConfigSection;

    [NonSerialized]
    public Dictionary<string, string> m_Replacements;

    [NonSerialized]
    public Logger m_Logger = new Logger("[PaymentSubmissionAdapterWorkflow]");
    #endregion

    #region Static Members
    //[NonSerialized]
    //private static Meter m_MeterSDK = null;
    [NonSerialized]
    private static MTServerAccessData m_SuperUser = null;
    [NonSerialized]
    private static object lockObject = new object();
    #endregion

    private static MTServerAccessData SuperUser
    {
        get
        {
            if (m_SuperUser != null)
                return m_SuperUser;

            if (m_SuperUser == null)
            {
                lock (lockObject)
                {
                    if (m_SuperUser == null)
                    {
                        IMTServerAccessDataSet serverAccessSet = new MTServerAccessDataSet();
                        serverAccessSet.Initialize();
                        m_SuperUser = serverAccessSet.FindAndReturnObjectIfExists("SuperUser");
                    }
                }
            }
            return m_SuperUser;
        }
    }

    /*
    private static Meter MeterSDK
    {
        get
        {
            if (m_MeterSDK == null)
            {
                IMTServerAccessDataSet sa = new MTServerAccessDataSet();
                sa.Initialize();
                m_SuperUser = sa.FindAndReturnObject("SuperUser");
                MTServerAccessData svr = sa.FindAndReturnObject("AdjustmentsServer");

                m_MeterSDK = new MeterClass();
                m_MeterSDK.Startup();

                m_MeterSDK.AddServer(svr.Priority, svr.ServerName, (svr.Secure != 0 ? PortNumber.DEFAULT_HTTPS_PORT : PortNumber.DEFAULT_HTTP_PORT), svr.Secure, svr.UserName, svr.Password);
            }

            return m_MeterSDK;
        }
    }
    */

    #region Workflow Methods
    public void LoadConfiguration_ExecuteCode(object sender, EventArgs e)
    {
      IMTRcd rcd = new MTRcdClass();

      string configFileName = (Path.IsPathRooted(ConfigFile) ? ConfigFile : Path.Combine(rcd.ExtensionDir, ConfigFile));

      m_ConfigSection = new CCDunningAdapterConfig(configFileName);
    }

    public void LoadFailedPayments_ExecuteCode(object sender, EventArgs e)
    {
      FailedPaymentRequest pendingRequest;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\CreditCardDunningAdapter", "__GET_FAILED_PAYMENTS__"))
          {
              stmt.AddParam("%%SYSDATE%%", MetraTime.Now);
              stmt.AddParam("%%RETRY_DAYS%%", m_ConfigSection.RetryDays);
              stmt.AddParam("%%MAX_RETRIES%%", m_ConfigSection.MaxRetries);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                  Dictionary<string, FailedPaymentRequest> dicPendingRequest = new Dictionary<string, FailedPaymentRequest>();

                  int intervalID = -1;
                  int acctID = -1;
                  string paymentInstrumentID = string.Empty;

                  while (rdr.Read())
                  {
                      intervalID = rdr.GetInt32("id_interval");
                      acctID = rdr.GetInt32("id_acc");
                      paymentInstrumentID = rdr.GetString("id_payment_instrument");

                      if (dicPendingRequest.ContainsKey(string.Format("{0}-{1}-{2}", intervalID, acctID, paymentInstrumentID)))
                      {
                        List<MetraPaymentInvoice> invoices = dicPendingRequest[string.Format("{0}-{1}-{2}", intervalID, acctID, paymentInstrumentID)].PaymentInfo.MetraPaymentInvoices;
                        if (invoices == null)
                          invoices = new List<MetraPaymentInvoice>();

                        MetraPaymentInvoice invoice = new MetraPaymentInvoice();

                        if (!rdr.IsDBNull("dt_invoice"))
                        {
                          invoice.InvoiceDate = rdr.GetDateTime("dt_invoice");
                        }
                        invoice.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                        invoice.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");
                        invoice.AmountToPay = rdr.GetDecimal("n_invoice_amount");
                        invoices.Add(invoice);
                      }
                      else
                      {
                          pendingRequest = new FailedPaymentRequest();

                          pendingRequest.IntervalID = intervalID;
                          pendingRequest.AccountID = acctID;
                          pendingRequest.PaymentInstrumentID = new Guid(paymentInstrumentID);
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

                          if (!rdr.IsDBNull("n_retrycount"))
                          {
                              pendingRequest.RetryCount = rdr.GetInt32("n_retrycount");
                          }
                          else
                          {
                              pendingRequest.RetryCount = m_ConfigSection.MaxRetries;
                          }

                          pendingRequest.Language = (LanguageCode)EnumHelper.GetCSharpEnum(rdr.GetInt32("c_Language"));

                          if (!rdr.IsDBNull("c_Email"))
                          {
                              pendingRequest.EmailAddress = rdr.GetString("c_Email");
                          }

                          if (!rdr.IsDBNull("c_FirstName"))
                          {
                              pendingRequest.FirstName = rdr.GetString("c_FirstName");
                          }

                          if (!rdr.IsDBNull("c_LastName"))
                          {
                              pendingRequest.LastName = rdr.GetString("c_LastName");
                          }

                          if (pendingRequest.PaymentInfo.MetraPaymentInvoices == null)
                          {
                            pendingRequest.PaymentInfo.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                          }

                          MetraPaymentInvoice invoice = new MetraPaymentInvoice();

                          if (!rdr.IsDBNull("dt_invoice"))
                          {
                            invoice.InvoiceDate = rdr.GetDateTime("dt_invoice");
                          }


                          invoice.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                          invoice.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");
                          invoice.AmountToPay = rdr.GetDecimal("n_invoice_amount");

                          pendingRequest.PaymentInfo.MetraPaymentInvoices.Add(invoice);

                          dicPendingRequest.Add(string.Format("{0}-{1}-{2}", intervalID, acctID, paymentInstrumentID), pendingRequest);
                      }

                      m_PendingRequests = dicPendingRequest.Values.ToList();
                  }
              }
          }
      }
    }

    public void SubmitPaymentRequests_ExecuteCode(object sender, EventArgs e)
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
                            List<FailedPaymentRequest> bucket = null;
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

                    m_Logger.LogDebug("Finished processing all pending failed payment requests.");
            }
                catch (Exception ex)
              {
                    m_Logger.LogException("Exception caught in SubmitPaymentRequests", ex);
                    base.ExecutionContext.RecordWarning(string.Format("Exception caught in SubmitPaymentRequests: {0}", ex.Message));
                    throw;
              }
            }
            else
            {
                m_Logger.LogInfo("There are no pending failed requests to process");
            }

            m_CompletedRequestsIter = m_CompletedRequests.GetEnumerator();
          }

        //public void SubmitPaymentRequests_ExecuteCode(object sender, EventArgs e)
        //{
        //    if (m_PendingRequests.Count > 0)
        //    {

        //        string configFilePath = m_ConfigSection.WCFConfigFile;

        //        if (!Path.IsPathRooted(configFilePath))
        //        {
        //            IMTRcd rcd = new MTRcdClass();

        //            configFilePath = Path.Combine(rcd.ExtensionDir, configFilePath);
        //        }

        //        RecurringPaymentsServiceClient client = MASClientClassFactory.CreateClient<RecurringPaymentsServiceClient>(configFilePath, m_ConfigSection.EPSEndpoint);
        //        client.ClientCredentials.UserName.UserName = m_SuperUser.UserName;
        //        client.ClientCredentials.UserName.Password = m_SuperUser.Password;
        //        client.Open();

        //        int i = 0;
        //        int numToProcess = Math.Min(m_PendingRequests.Count, Math.Min(m_ConfigSection.MaxConcurrentRequests, 64));

        //        FailedPaymentRequest[] inProgressRequests = new FailedPaymentRequest[numToProcess];
        //        IAsyncResult[] syncHandles = new IAsyncResult[numToProcess];
        //        WaitHandle[] waitHandles = new WaitHandle[numToProcess];

        //        for (i = 0; i < numToProcess; i++)
        //        {
        //            inProgressRequests[i] = m_PendingRequests[i];
        //            syncHandles[i] = client.BeginDebitPaymentMethod(inProgressRequests[i].PaymentInstrumentID, ref inProgressRequests[i].PaymentInfo, null, null);
        //            waitHandles[i] = syncHandles[i].AsyncWaitHandle;
        //        }

        //        while (i < m_PendingRequests.Count)
        //        {
        //            int finished = WaitHandle.WaitAny(waitHandles);

        //            FailedPaymentRequest reqData = inProgressRequests[finished];
        //            --reqData.RetryCount;

        //            try
        //            {

        //                client.EndDebitPaymentMethod(ref inProgressRequests[finished].PaymentInfo, syncHandles[finished]);

        //                reqData.Succeeded = true;
        //                m_CompletedRequests.Add(reqData);
        //            }
        //            catch (FaultException<PaymentProcessorFaultDetail> fe)
        //            {
        //                m_Logger.LogException(string.Format("Error occurred at payment processor in Debit request for account {0} with payment instrument {1}", reqData.AccountID, reqData.PaymentInstrumentID), fe);
        //                foreach (string err in fe.Detail.ErrorMessages)
        //                {
        //                    m_Logger.LogError("Error was: {0}", err);
        //                }

        //                reqData.Succeeded = false;
        //                reqData.ProcessorFaultDetail = fe.Detail;
        //                m_CompletedRequests.Add(reqData);
        //            }
        //            catch (FaultException<MASBasicFaultDetail> fe)
        //            {
        //                m_Logger.LogException(string.Format("MASBasicException in Debit request for account {0} with payment instrument {1}", reqData.AccountID, reqData.PaymentInstrumentID), fe);
        //                foreach (string err in fe.Detail.ErrorMessages)
        //                {
        //                    m_Logger.LogError("Error was: {0}", err);
        //                }

        //                ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", reqData.AccountID, reqData.PaymentInstrumentID, fe.Message));
        //            }
        //            catch (Exception ex)
        //            {
        //                m_Logger.LogException(string.Format("Exception in Debit request for account {0} with payment instrument {1}", reqData.AccountID, reqData.PaymentInstrumentID), ex);

        //                ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", reqData.AccountID, reqData.PaymentInstrumentID, ex.Message));
        //            }

        //            inProgressRequests[finished] = m_PendingRequests[i];
        //            syncHandles[finished] = client.BeginDebitPaymentMethod(inProgressRequests[finished].PaymentInstrumentID, ref inProgressRequests[finished].PaymentInfo, null, null);
        //            waitHandles[finished] = syncHandles[finished].AsyncWaitHandle;
        //            ++i;
        //        }

        //        WaitHandle.WaitAll(waitHandles);

        //        for (int j = 0; j < numToProcess; j++)
        //        {
        //            FailedPaymentRequest reqData = inProgressRequests[j];
        //            --reqData.RetryCount;

        //            try
        //            {
        //                client.EndDebitPaymentMethod(ref inProgressRequests[j].PaymentInfo, syncHandles[j]);

        //                reqData.Succeeded = true;
        //                m_CompletedRequests.Add(reqData);
        //            }
        //            catch (FaultException<PaymentProcessorFaultDetail> fe)
        //            {
        //                m_Logger.LogException(string.Format("Error occurred at payment processor in Debit request for account {0} with payment instrument {1}", reqData.AccountID, reqData.PaymentInstrumentID), fe);
        //                foreach (string err in fe.Detail.ErrorMessages)
        //                {
        //                    m_Logger.LogError("Error was: {0}", err);
        //                }

        //                reqData.Succeeded = false;
        //                reqData.ProcessorFaultDetail = fe.Detail;
        //                m_CompletedRequests.Add(reqData);
        //            }
        //            catch (FaultException<MASBasicFaultDetail> fe)
        //            {
        //                m_Logger.LogException(string.Format("MASBasicException in Debit request for account {0} with payment instrument {1}", reqData.AccountID, reqData.PaymentInstrumentID), fe);
        //                foreach (string err in fe.Detail.ErrorMessages)
        //                {
        //                    m_Logger.LogError("Error was: {0}", err);
        //                }

        //                ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", reqData.AccountID, reqData.PaymentInstrumentID, fe.Message));
        //            }
        //            catch (Exception ex)
        //            {
        //                m_Logger.LogException(string.Format("Exception in Debit request for account {0} with payment instrument {1}", reqData.AccountID, reqData.PaymentInstrumentID), ex);

        //                ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", reqData.AccountID, reqData.PaymentInstrumentID, ex.Message));
        //            }
        //        }

        //        client.Close();
        //    }
        //    else
        //    {
        //        m_Logger.LogInfo("There are no pending requests to process");
        //    }

        //    m_CompletedRequestsIter = m_CompletedRequests.GetEnumerator();
        //}

    public void ForEachRequestResult_Condition(object sender, ConditionalEventArgs e)
    {
      e.Result = m_CompletedRequestsIter.MoveNext();
    }

    public void MarkFailedPaymentRecordSuccessful_ExecuteCode(object sender, EventArgs e)
    {
      FailedPaymentRequest pendingRequest = m_CompletedRequestsIter.Current;

      try
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\CreditCardDunningAdapter", "__DELETE_FAILED_PAYMENT__"))
              {
                  stmt.AddParam("%%INTERVAL_ID%%", pendingRequest.IntervalID);
                  stmt.AddParam("%%ACCOUNT_ID%%", pendingRequest.AccountID);
                  stmt.AddParam("%%PI_ID%%", pendingRequest.PaymentInstrumentID.ToString());

                  stmt.ExecuteNonQuery();
              }
          }
      }
      catch (Exception ex)
      {
        m_Logger.LogException("Exception deleting failed payment record", ex);

        ExecutionContext.RecordWarning(string.Format("Failed to delete failed payment record for interval {0}, account {1}, Payment instrument {2}", pendingRequest.IntervalID, pendingRequest.AccountID, pendingRequest.PaymentInstrumentID));
      }
    }

    public void IsEmailSet_Condition(object sender, ConditionalEventArgs e)
    {
      e.Result = !string.IsNullOrEmpty(m_CompletedRequestsIter.Current.EmailAddress);
    }

    public void SendFailureNotification_ExecuteCode(object sender, EventArgs e)
    {
      FailedPaymentRequest request = m_CompletedRequestsIter.Current;

      if (!string.IsNullOrEmpty(request.EmailAddress))
      {
        try
        {
          string configFilePath = m_ConfigSection.WCFConfigFile;

          if (!Path.IsPathRooted(configFilePath))
          {
            IMTRcd rcd = new MTRcdClass();

            configFilePath = Path.Combine(rcd.ExtensionDir, configFilePath);
          }

          NotificationServiceClient client = MASClientClassFactory.CreateClient<NotificationServiceClient>(configFilePath, m_ConfigSection.NotificationEndpoint);
          client.ClientCredentials.UserName.UserName = SuperUser.UserName;
          client.ClientCredentials.UserName.Password = SuperUser.Password;

          ILocaleConfig localeConfig = new LocaleConfigClass();
          
          m_Replacements = new Dictionary<string, string>();
          m_Replacements.Add("%%FIRSTNAME%%", request.FirstName);
          m_Replacements.Add("%%LASTNAME%%", request.LastName);

          if (request.PaymentInfo.MetraPaymentInvoices != null && request.PaymentInfo.MetraPaymentInvoices.Count > 0)
          {
              MTStringBuilder invoiceNumbers = new MTStringBuilder();
              MTStringBuilder invoiceDates = new MTStringBuilder();
              MTStringBuilder poNumbers = new MTStringBuilder(); 

              request.PaymentInfo.MetraPaymentInvoices.ForEach(invoice => {
                  invoiceNumbers.Append(invoice.InvoiceNum + ",");
                  invoiceDates.Append((invoice.InvoiceDate.HasValue ? invoice.InvoiceDate.Value.ToShortDateString() : "") + ",");
                  poNumbers.Append(invoice.PONum + ",");
              });

              m_Replacements.Add("%%INVOICENUM%%", invoiceNumbers.ToString());
              m_Replacements.Add("%%INVOICEDT%%", invoiceDates.ToString());
              m_Replacements.Add("%%PONUM%%", poNumbers.ToString());
          }
          m_Replacements.Add("%%CURRENCY%%", request.PaymentInfo.Currency);
          m_Replacements.Add("%%AMOUNT%%", request.PaymentInfo.Amount.ToString("F2"));
          m_Replacements.Add("%%METHODTYPE%%", localeConfig.GetLocalizedString(EnumHelper.GetFQN(request.MethodType), request.Language.ToString()));
          m_Replacements.Add("%%CCTYPE%%", localeConfig.GetLocalizedString(EnumHelper.GetFQN(request.CreditCardType), request.Language.ToString()));
          m_Replacements.Add("%%ACCTNUM%%", request.AccountNumber);

          client.SendEmailNotification(m_ConfigSection.FailedPaymentEmailTemplate, request.Language, request.EmailAddress, m_Replacements);
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          m_Logger.LogException("Exception sending failure email notification", fe);
          foreach (string err in fe.Detail.ErrorMessages)
          {
            m_Logger.LogError("Error: {0}", err);
          }

          ExecutionContext.RecordWarning(string.Format("Error sending failure email notification: {0}", fe.Detail.ErrorMessages[0]));
        }
        catch (Exception ex)
        {
          m_Logger.LogException("Exception sending email notification", ex);

          ExecutionContext.RecordWarning(string.Format("Error sending failure email notification: {0} for account {1}", ex.Message, request.AccountID));
        }
      }
      else
      {
        ExecutionContext.RecordWarning(string.Format("Cannot send failure notice to {0} since there is no email address on record", request.AccountID));
      }
    }

    public void SendFinalNotification_ExecuteCode(object sender, EventArgs e)
    {
      FailedPaymentRequest request = m_CompletedRequestsIter.Current;

      if (!string.IsNullOrEmpty(request.EmailAddress))
      {
        try
        {
          string configFilePath = m_ConfigSection.WCFConfigFile;

          if (!Path.IsPathRooted(configFilePath))
          {
            IMTRcd rcd = new MTRcdClass();

            configFilePath = Path.Combine(rcd.ExtensionDir, configFilePath);
          }

          NotificationServiceClient client = MASClientClassFactory.CreateClient<NotificationServiceClient>(configFilePath, m_ConfigSection.NotificationEndpoint);
          client.ClientCredentials.UserName.UserName = SuperUser.UserName;
          client.ClientCredentials.UserName.Password = SuperUser.Password;

          ILocaleConfig localeConfig = new LocaleConfigClass();

          m_Replacements = new Dictionary<string, string>();
          m_Replacements.Add("%%FIRSTNAME%%", request.FirstName);
          m_Replacements.Add("%%LASTNAME%%", request.LastName);

          if (request.PaymentInfo.MetraPaymentInvoices != null && request.PaymentInfo.MetraPaymentInvoices.Count > 0)
          {
              MTStringBuilder invoiceNumbers = new MTStringBuilder();
              MTStringBuilder invoiceDates = new MTStringBuilder();
              MTStringBuilder poNumbers = new MTStringBuilder();

              request.PaymentInfo.MetraPaymentInvoices.ForEach(invoice =>
              {
                  invoiceNumbers.Append(invoice.InvoiceNum + ",");
                  invoiceDates.Append((invoice.InvoiceDate.HasValue ? invoice.InvoiceDate.Value.ToShortDateString() : "") + ",");
                  poNumbers.Append(invoice.PONum + ",");
              });

              m_Replacements.Add("%%INVOICENUM%%", invoiceNumbers.ToString());
              m_Replacements.Add("%%INVOICEDT%%", invoiceDates.ToString());
              m_Replacements.Add("%%PONUM%%", poNumbers.ToString());
          }

          m_Replacements.Add("%%CURRENCY%%", request.PaymentInfo.Currency);
          m_Replacements.Add("%%AMOUNT%%", request.PaymentInfo.Amount.ToString("F2"));
          m_Replacements.Add("%%METHODTYPE%%", localeConfig.GetLocalizedString(EnumHelper.GetFQN(request.MethodType), request.Language.ToString()));
          m_Replacements.Add("%%CCTYPE%%", localeConfig.GetLocalizedString(EnumHelper.GetFQN(request.CreditCardType), request.Language.ToString()));
          m_Replacements.Add("%%ACCTNUM%%", request.AccountNumber);
          

          client.SendEmailNotification(m_ConfigSection.FinalFailureEmailTemplate, request.Language, request.EmailAddress, m_Replacements);
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          m_Logger.LogException("Exception sending final failure email notification", fe);
          foreach (string err in fe.Detail.ErrorMessages)
          {
            m_Logger.LogError("Error: {0}", err);
          }

          ExecutionContext.RecordWarning(string.Format("Error sending final failure email notification: {0}", fe.Detail.ErrorMessages[0]));
        }
        catch (Exception ex)
        {
          m_Logger.LogException("Exception sending email notification", ex);

          ExecutionContext.RecordWarning(string.Format("Error sending final failure email notification: {0} for account {1}", ex.Message, request.AccountID));
        }
      }
      else
      {
        ExecutionContext.RecordWarning(string.Format("Cannot send final failure notice to {0} since there is no email address on record", request.AccountID));
      }
    }

    public void UpdateFailedPaymentRecord_ExecuteCode(object sender, EventArgs e)
    {
      FailedPaymentRequest pendingRequest = m_CompletedRequestsIter.Current;

      try
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\CreditCardDunningAdapter", "__UPDATE_FAILED_PAYMENT__"))
              {
                  stmt.AddParam("%%RETRYCOUNT%%", pendingRequest.RetryCount);
                  stmt.AddParam("%%SYSDATE%%", MetraTime.Now);
                  stmt.AddParam("%%INTERVAL_ID%%", pendingRequest.IntervalID);
                  stmt.AddParam("%%ACCOUNT_ID%%", pendingRequest.AccountID);
                  stmt.AddParam("%%PI_ID%%", pendingRequest.PaymentInstrumentID.ToString());

                  AddCustomFailedPaymentParams(stmt, pendingRequest);

                  stmt.ExecuteNonQuery();
              }
          }
      }
      catch (Exception ex)
      {
        m_Logger.LogException("Exception deleting failed payment record", ex);

        ExecutionContext.RecordWarning(
          string.Format(
            "Failed to update failed payment record for interval {0}, account {1}, Payment instrument {2}, retry count {3}, retry date {4}", 
            pendingRequest.IntervalID, 
            pendingRequest.AccountID, 
            pendingRequest.PaymentInstrumentID, 
            pendingRequest.RetryCount, 
            MetraTime.Now));
      }
    }

    public void DisableSubscription_ExecuteCode(object sender, EventArgs e)
    {

    }
    #endregion

        #region Helper Methods
        private void ProcessBucket(object items)
        {
            RecurringPaymentsServiceClient client = null;
            FailedPaymentRequest pendingRequest = new FailedPaymentRequest();

            try
            {
                List<FailedPaymentRequest> bucket = (List<FailedPaymentRequest>)items;

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
                    client = MASClientClassFactory.CreateClient<RecurringPaymentsServiceClient>(configFilePath, m_ConfigSection.EPSEndpoint);
                    client.ClientCredentials.UserName.UserName = SuperUser.UserName;
                    client.ClientCredentials.UserName.Password = SuperUser.Password;
                    client.Open();

                    for (int i = 0; i < bucket.Count; i++)
                    {
                        try
                        {
                            pendingRequest = bucket[i];

                            client.DebitPaymentMethodV2(pendingRequest.PaymentInstrumentID, ref pendingRequest.PaymentInfo, m_ConfigSection.Timeout, "");

                            pendingRequest.Succeeded = true;
                            m_CompletedRequests.Add(pendingRequest);
                        }
                        catch (FaultException<PaymentProcessorFaultDetail> fe)
                        {
                            m_Logger.LogException(string.Format("Error occurred at payment processor in Debit request for account {0} with payment instrument {1}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID), fe);
                            foreach (string err in fe.Detail.ErrorMessages)
                            {
                                m_Logger.LogError("Error was: {0}", err);
                            }

                            --pendingRequest.RetryCount;

                            pendingRequest.Succeeded = false;
                            pendingRequest.ProcessorFaultDetail = fe.Detail;
                            m_CompletedRequests.Add(pendingRequest);
                        }
                        catch (FaultException<MASBasicFaultDetail> fe)
                        {
                            m_Logger.LogException(string.Format("MASBasicException in Debit request for account {0} with payment instrument {1}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID), fe);
                            foreach (string err in fe.Detail.ErrorMessages)
                            {
                                m_Logger.LogError("Error was: {0}", err);
                            }

                            ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID, fe.Message));
                        }
                        catch (Exception ex)
                        {
                            m_Logger.LogException(string.Format("Exception in Debit request for account {0} with payment instrument {1}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID), ex);

                            ExecutionContext.RecordWarning(string.Format("Non-processing error caught during Debit for account {0} with payment instrument '{1}'.  Error message was: {2}", pendingRequest.AccountID, pendingRequest.PaymentInstrumentID, ex.Message));
                        }

                    }
                    // done with the client
                    client.Close();
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

        #endregion

    #region Virtual Methods
    public virtual MetraPaymentInfo GetPaymentInfo(IMTDataReader dataReader)
    {
      MetraPaymentInfo paymentInfo = new MetraPaymentInfo();

      return paymentInfo;
    }

    public virtual void AddCustomFailedPaymentParams(IMTAdapterStatement stmt, FailedPaymentRequest failedPaymentRequest)
    {
    }
    #endregion

  }

  public struct FailedPaymentRequest
  {
    public int IntervalID;
    public int AccountID;
    public Guid PaymentInstrumentID;
    public MetraPaymentInfo PaymentInfo;

    public int RetryCount;

    public PaymentType MethodType;
    public Nullable<MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType> CreditCardType;
    public string AccountNumber;

    public string FirstName;
    public string LastName;
    public string EmailAddress;
    public LanguageCode Language;

    public bool Succeeded;
    public PaymentProcessorFaultDetail ProcessorFaultDetail;
  }

  public class CCDunningAdapterConfig
  {
    #region Members
    private string m_WCFConfigFile;
    private string m_EPSEndpoint;
    private string m_NotificationEndpoint;

    private int m_RetryDays;
    private int m_MaxRetries;

    private string m_FailedPaymentEmailTemplate;
    private string m_FinalFailureEmailTemplate;

    private int m_MaxConcurrentRequests;
    private int m_SessionSetSize;
    private int m_UpdateSetSize;
    private double m_Timeout;

    #endregion

    public CCDunningAdapterConfig(string configFilePath)
    {
      XmlDocument configFile = new XmlDocument();
      configFile.Load(configFilePath);

      XmlNode root = configFile.SelectSingleNode("//CreditCardDunningAdapter");

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

          case "NotificationEndpoint":
            m_NotificationEndpoint = childNode.InnerText;
            break;
            
          case "RetryDelayDays":
            m_RetryDays = int.Parse(childNode.InnerText);
            break;

          case "MaxRetries":
            m_MaxRetries = int.Parse(childNode.InnerText);
            break;

          case "FailedPaymentEmailTemplate":
            m_FailedPaymentEmailTemplate = childNode.InnerText;
            break;

          case "FinalRetryFailureEmailTemplate":
            m_FinalFailureEmailTemplate = childNode.InnerText;
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
            m_Timeout = double.Parse(childNode.InnerText);
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

    public string NotificationEndpoint
    {
      get { return m_NotificationEndpoint; }
    }

    public int RetryDays
    {
      get { return m_RetryDays; }
    }

    public int MaxRetries
    {
      get { return m_MaxRetries; }
    }

    public string FailedPaymentEmailTemplate
    {
      get { return m_FailedPaymentEmailTemplate; }
    }

    public string FinalFailureEmailTemplate
    {
      get { return m_FinalFailureEmailTemplate; }
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
          get { return m_Timeout; }
      }
    #endregion
  }
}
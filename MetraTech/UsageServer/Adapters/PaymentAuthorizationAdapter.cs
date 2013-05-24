using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.ServiceModel;
using System.Threading;
using System.Xml;
using System.Linq;
using System.Linq.Expressions;

using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.Dataflow;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.MetraPay;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.RCD;
using MetraTech.UsageServer;
using MetraTech.Xml;
using System.Text;


namespace MetraTech.UsageServer.Adapters
{
  /// <summary>
  /// This adapter will determine the set of credit cards  that will be hit during the interval close, 
  /// and will submit an authorization request to the payment processor for each one.   The adapter 
  /// will store the results of the requests in the NetMeter database.  This adapter will be reversible, 
  /// but reversal will not submit anything to the payment gateway.   Rerunning the adapter would 
  /// cause the adapter to resubmit any pending invoice that has not already been 
  /// successfully authorized 
  /// 
  /// </summary>
  public class PaymentAuthorizationAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    //adapter capabilities
    public bool SupportsScheduledEvents { get { return false; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
    public bool AllowMultipleInstances { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; } }

    private Logger mLogger = new Logger("[PaymentAuthorizationAdapter]");

    // configuration tags
    private string mTag;
    private int mNumThreads;
    private string m_WCFConfigFile = "";
    private string m_EndpointName = "";
    
    private bool m_SubmitPreAuth = true;
    private bool m_SchedulePayments = false;
    private int m_NumDays = 7;
    private bool m_TryDunning = true;

    // db and Staging db name
    private IMTServerAccessData mNetMeter;
    private IMTServerAccessData mStageDB;

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      mLogger.LogDebug("Initializing {0}", mTag);
      if (limitedInit)
        mLogger.LogDebug("Limited initialization requested");
      else
        mLogger.LogDebug("Full initialization requested");

      ReadConfig(configFile);

      // Num Threads maxed at 64
      if (mNumThreads > 64)
      {
        mNumThreads = 64;
        mLogger.LogWarning("Maximum number of configurable threads is 64.");
      }
      else
      { 
        mLogger.LogInfo(String.Format("Adapter configured to run with {0}", mNumThreads.ToString()));
      }

      return;
    }


    public string Execute(IRecurringEventRunContext param)
    {
      mLogger.LogDebug("Executing {0}", mTag);

      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
      sa.Initialize();
      mStageDB = sa.FindAndReturnObject("NetMeterStage");
      mNetMeter = sa.FindAndReturnObject("NetMeter");

      IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      RunMetraFlow(param);
      MTList<PreAuthRequestData> syncResults = GetPendingPayments(param);
      MTList<PreAuthRequestData> successfulAuths = new MTList<PreAuthRequestData>();
      int numRequests = syncResults.Items.Count;

      if (m_SubmitPreAuth && numRequests > 0)
      {
        // create client with appropriate credentials and begin processing
          RecurringPaymentsServiceClient client = null;
          try
          {
            client = MASClientClassFactory.CreateClient<RecurringPaymentsServiceClient>(m_WCFConfigFile, m_EndpointName);
            client.ClientCredentials.UserName.UserName = accessData.UserName;
            client.ClientCredentials.UserName.Password = accessData.Password;
            client.Open();

            int i = 0;
            int numToProcess = Math.Min(numRequests, mNumThreads);

            // Array of Pre-Auth requests that are currently out
            PreAuthRequestData[] inProgressAuthReqs = new PreAuthRequestData[numToProcess];
            WaitHandle[] waitHandles = new WaitHandle[numToProcess];

            // Fire off request and enqueue it in the array for the results we r waiting for
            for (i = 0; i < numToProcess; i++)
            {
              PreAuthRequestData preAuthReq = syncResults.Items[i];
              MetraPaymentInfo payInfo = preAuthReq.PaymentInfo;
              preAuthReq.AsyncResult = client.BeginPreAuthorizeChargeV2(preAuthReq.PaymentInstrumentId, ref payInfo, 0, "", null, null);
              waitHandles[i] = preAuthReq.AsyncResult.AsyncWaitHandle;
              inProgressAuthReqs[i] = preAuthReq;
            }

            // while we have requests to process
            while (i < numRequests)
            {
              // wait for a request to finish
              int finished = WaitHandle.WaitAny(waitHandles);

              // get a handle to the PreAuthReq that has been procesed
              PreAuthRequestData reqData = inProgressAuthReqs[finished];
              MetraPaymentInfo payInfo = reqData.PaymentInfo;

              // set the auth token for requests that have completed
              try
              {
                Guid authToken;
                client.EndPreAuthorizeChargeV2(ref payInfo, out authToken, reqData.AsyncResult);

                // set the authToken in our in progress requests for bookeeping and store it in the successful auths
                inProgressAuthReqs[finished].AuthToken = authToken;
                successfulAuths.Items.Add(reqData);
              }
              catch (FaultException<MASBasicFaultDetail> fe)
              {
                param.RecordWarning(String.Format("Failed to authorize payment for Invoice Number {0}.", GetInvoiceNumbers(reqData.PaymentInfo)));
                foreach (string msg in fe.Detail.ErrorMessages)
                {
                  param.RecordWarning("Error: " + msg);
                }
              }
              catch (FaultException<PaymentProcessorFaultDetail> fe)
              {
                param.RecordWarning(String.Format("Failed to authorize payment for Invoice Number {0}.", GetInvoiceNumbers(reqData.PaymentInfo)));
                foreach (string msg in fe.Detail.ErrorMessages)
                {
                  param.RecordWarning("Error: " + msg);
                }
              }
              catch (Exception e)
              {
                throw e;
              }

              // once finished grab a new req from the array, then kick off a new request
              PreAuthRequestData preAuthReq = syncResults.Items[i];
              payInfo = preAuthReq.PaymentInfo;
              preAuthReq.AsyncResult = client.BeginPreAuthorizeChargeV2(preAuthReq.PaymentInstrumentId, ref payInfo, 0, "", null, null);

              // Fire off numTo and enqueue it in the array for the results we r waiting for
              waitHandles[finished] = preAuthReq.AsyncResult.AsyncWaitHandle;

              // Put the newly fired Preauth request into the arrays where the finished index was
              inProgressAuthReqs[finished] = preAuthReq;
              i++;
            }

            // Wait for everything to finish
            WaitHandle.WaitAll(waitHandles);

            // Finish the rest of them off . . . 
            for (int j = 0; j < numToProcess; j++)
            {
              // Need to call the End PreAuthorize charge on the pre-auths in progress
              PreAuthRequestData reqData = inProgressAuthReqs[j];
              MetraPaymentInfo payInfo = reqData.PaymentInfo;
              // set the auth token for requests that have completed
              try
              {
                Guid authToken;

                // end the call, store the authToken, and enque it into the successful auths
                client.EndPreAuthorizeChargeV2(ref payInfo, out authToken, reqData.AsyncResult);
                reqData.AuthToken = authToken;
                successfulAuths.Items.Add(reqData);
              }
              catch (FaultException<MASBasicFaultDetail> fe)
              {
                param.RecordWarning(String.Format("Failed to authorize payment for Invoice Number {0}.", GetInvoiceNumbers(reqData.PaymentInfo)));
                foreach (string msg in fe.Detail.ErrorMessages)
                {
                  param.RecordWarning("Error: " + msg);
                }
              }
              catch (FaultException<PaymentProcessorFaultDetail> fe)
              {
                param.RecordWarning(String.Format("Failed to authorize payment for Invoice Number {0}.", GetInvoiceNumbers(reqData.PaymentInfo)));
                foreach (string msg in fe.Detail.ErrorMessages)
                {
                  param.RecordWarning("Error: " + msg);
                }
              }
              catch (Exception e)
              {
                throw e;
              }
            }
            client.Close();
          }
          catch (Exception e)
          {
            mLogger.LogException("An unexpected error occurred", e);
            client.Abort();
            throw;
          }

        // Store the results
        StorePendingPaymentsRequests(successfulAuths);
      }
      return "Adapter Execution Succeeded.";

    }
    /// <summary>
    /// The PaymentAuthorizationAdapter will support reversals.  When the adapter is reversed, 
    /// it will set the amount value of all the records for the current interval to zero.  Any record 
    /// that has an amount of zero will be ignored by subsequent adapters.  If the adapter is re-run, 
    /// the execution of the database query that creates the pending payment records will
    /// update these records with the new amount or new payment instrument (or other updated info
    /// </summary>
    /// <param name="param"></param>
    /// <returns></returns>
    public string Reverse(IRecurringEventRunContext param)
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter"))
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter", "__REVERSE_PENDING_AUTHORIZATION_REQUESTS__"))
            {
                stmt.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID);
                stmt.ExecuteNonQuery();
                stmt.ClearQuery();
            }
        }
      param.RecordInfo("Reset the amounts for this Interval to 0.");
      return "Adapter Reversal Succeeded.";
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down PaymentAuthorizationAdapter Adapter");
      return;
    }

    public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of PaymentBilling Adapter");
    }

    public MTList<PreAuthRequestData> GetPendingPayments(IRecurringEventRunContext param)
    {
      MTList<PreAuthRequestData> requests = new MTList<PreAuthRequestData>();
      // get pending authorization requests
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter"))
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter", "__GET_PENDING_AUTHORIZATION_REQUESTS__"))
          {
              mLogger.LogDebug(String.Format("Interval {0}", param.UsageIntervalID));
              mLogger.LogDebug(String.Format("BG {0}", param.BillingGroupID));

              stmt.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID);
              stmt.AddParam("%%BILLGROUP_ID%%", param.BillingGroupID);

              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                  Dictionary<int, PreAuthRequestData> dicRequests = new Dictionary<int, PreAuthRequestData>();

                  while (dataReader.Read())
                  {
                      if (dicRequests.ContainsKey(dataReader.GetInt32("PendingPaymentId")))
                      {
                          MetraPaymentInfo info = dicRequests[dataReader.GetInt32("PendingPaymentId")].PaymentInfo;

                          if (info.MetraPaymentInvoices == null)
                              info.MetraPaymentInvoices = new List<MetraPaymentInvoice>();

                          MetraPaymentInvoice invoice = new MetraPaymentInvoice();
                          invoice.InvoiceNum = dataReader.GetString("NM_INVOICENUM");
                          invoice.PONum = (!dataReader.IsDBNull("NM_PONUM") ? dataReader.GetString("NM_PONUM") : "");
                          if (!dataReader.IsDBNull("DT_INV_DATE"))
                          {
                            invoice.InvoiceDate = dataReader.GetDateTime("DT_INV_DATE");
                          }

                          invoice.AmountToPay = dataReader.GetDecimal("AMOUNTTOPAY");


                          info.MetraPaymentInvoices.Add(invoice);

                      }
                      else
                      {
                          MetraPaymentInfo info = GetPaymentInfo(dataReader);

                          int pendingPaymentId = dataReader.GetInt32("PendingPaymentId");
                          int intervalId = dataReader.GetInt32("IntervalId");
                          int accountId = dataReader.GetInt32("AccountId");
                          Guid key = new Guid(dataReader.GetString("N_PaymentInstrument"));

                          //info.InvoiceNum = dataReader.GetString("NM_INVOICENUM");
                          //info.PONum = (!dataReader.IsDBNull("NM_PONUM") ? dataReader.GetString("NM_PONUM") : "");
                          info.Description = (!dataReader.IsDBNull("NM_DESCRIPTION") ? dataReader.GetString("NM_DESCRIPTION") : "");
                          //info.InvoiceDate = dataReader.GetDateTime("DT_INV_DATE");
                          info.Currency = dataReader.GetString("NM_CURRENCY");
                          info.Amount = dataReader.GetDecimal("N_AMOUNT");

                          if (info.MetraPaymentInvoices == null)
                            info.MetraPaymentInvoices = new List<MetraPaymentInvoice>();

                          MetraPaymentInvoice invoice = new MetraPaymentInvoice();
                          invoice.InvoiceNum = dataReader.GetString("NM_INVOICENUM");
                          invoice.PONum = (!dataReader.IsDBNull("NM_PONUM") ? dataReader.GetString("NM_PONUM") : "");
                          if (!dataReader.IsDBNull("DT_INV_DATE"))
                          {
                            invoice.InvoiceDate = dataReader.GetDateTime("DT_INV_DATE");
                          }

                          invoice.AmountToPay = dataReader.GetDecimal("AMOUNTTOPAY");


                          info.MetraPaymentInvoices.Add(invoice);

                          PreAuthRequestData req = new PreAuthRequestData(pendingPaymentId, key, info, intervalId, accountId);
                          dicRequests.Add(pendingPaymentId, req);
                          //requests.Items.Add(req);
                      }
                  }

                  if (dicRequests.Count > 0)
                  {
                      dicRequests.Values.ToList().ForEach(preauthReqData => { requests.Items.Add(preauthReqData); });
                  }
                      
              }
          }
      }
      return requests;
    }

    public virtual MetraPaymentInfo GetPaymentInfo(IMTDataReader dataReader)
    {
      MetraPaymentInfo paymentInfo = new MetraPaymentInfo();

      return paymentInfo;
    }

    #region private methods
    private void ReadConfig(string configFile)
    {
      // TODO: Need to confirm if we still use MTXMLDocument??
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mTag = doc.GetNodeValueAsString("/xmlconfig/tag", "PaymentAuthorizationAdapter");
      mNumThreads = doc.GetNodeValueAsInt("/xmlconfig/NumThreads");
      m_WCFConfigFile = doc.GetNodeValueAsString("/xmlconfig/ConfigFile");

      // Get the endpoint name etc from the config file
      Configuration config;
      ExeConfigurationFileMap map = new ExeConfigurationFileMap();
      MTRcd rcd = new MTRcdClass();
      map.ExeConfigFilename = Path.Combine(rcd.ExtensionDir, m_WCFConfigFile);

      config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

      if (!Path.IsPathRooted(m_WCFConfigFile))
      {      
        m_WCFConfigFile = Path.Combine(rcd.ExtensionDir, m_WCFConfigFile);
      }

      mLogger.LogDebug(m_WCFConfigFile);

      m_EndpointName = doc.GetNodeValueAsString("/xmlconfig/EndPoint");

      m_SubmitPreAuth = doc.GetNodeValueAsBool("/xmlconfig/SubmitPreAuth");
      m_SchedulePayments = doc.GetNodeValueAsBool("/xmlconfig/SchedulePayments");
      m_NumDays = doc.GetNodeValueAsInt("/xmlconfig/NumDays");
      m_TryDunning = doc.GetNodeValueAsBool("/xmlconfig/TryDunning");
    }

    // TODO: not the most efficient way to do this, maybe use dataset . . .
    private void StorePendingPaymentsRequests(MTList<PreAuthRequestData> requests)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter"))
      {
          for (int i = 0; i < requests.Items.Count; i++)
          {
              PreAuthRequestData req = requests.Items[i];
              MetraPaymentInfo mpi = req.PaymentInfo;
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter", "__UPDATE_T_PENDING_TRXS__"))
              {

                  // This only handles the credit card case
                  stmt.AddParam("%%PENDING_PAYMENT_ID%%", req.PendingPaymentId);
                  stmt.AddParam("%%ID_AUTH%%", req.AuthToken.ToString());

                  stmt.ExecuteNonQuery();
                  stmt.ClearQuery();
              }
          }      
      }      
    }

    private void RunMetraFlow(IRecurringEventRunContext param)
    {
      DataSet inputs = new DataSet();
      DataSet outputs = new DataSet();

      String errTable = System.Guid.NewGuid().ToString();
      DataTable table = new DataTable(errTable);
      table.Columns.Add(new DataColumn("failed_acc", typeof(int)));
      table.Columns.Add(new DataColumn("totalCharged", typeof(decimal)));
      table.Columns.Add(new DataColumn("invoiceBalance", typeof(decimal)));

      outputs.Tables.Add(table);

      IMTQueryAdapter queryAdapter = new MTQueryAdapter();
      queryAdapter.Init("Queries\\UsageServer\\Adapters\\PaymentAuthorizationAdapter");

      queryAdapter.SetQueryTag("__SELECT_FOR_GENERATE_PENDING_PAYMENTS__");
      queryAdapter.AddParamIfFound("%%ID_INTERVAL%%", param.UsageIntervalID, true);
      queryAdapter.AddParamIfFound("%%ID_BILLGROUP%%", param.BillingGroupID, true);

      mLogger.LogDebug("Got Query query for generating Pending payments.");
      string selectStatement = queryAdapter.GetQuery();

      queryAdapter.SetQueryTag("__UPSERT_FOR_GENERATE_PENDING_PAYMENTS__");
      queryAdapter.AddParamIfFound("%%NETMETER%%", mNetMeter.DatabaseName, true);
      queryAdapter.AddParamIfFound("%%STAGINGDB%%", mStageDB.DatabaseName, true);
      queryAdapter.AddParamIfFound("%%B_SCHEDULED%%", (m_SchedulePayments ? 1 : 0), true);
      queryAdapter.AddParamIfFound("%%DT_EXECUTE%%", (m_SchedulePayments ? MetraTime.Now.AddDays(m_NumDays).Date : MetraTime.Now.Date), true);
      queryAdapter.AddParamIfFound("%%B_TRYDUNNING%%", (m_TryDunning ? 1 : 0), true);
      queryAdapter.AddParamIfFound("%%DT_CREATE%%", MetraTime.Now, true);

      string upsertStatement = queryAdapter.GetQuery();

      queryAdapter.SetQueryTag("__GENERATE_PENDING_PAYMENTS__");
      queryAdapter.AddParamIfFound("%%ERROR_QUEUE%%", errTable, true);
      queryAdapter.AddParam("%%SELECT_STATEMENT%%", selectStatement, true);
      queryAdapter.AddParam("%%UPSERT_STATEMENT%%", upsertStatement, true);
      queryAdapter.AddParamIfFound("%%STAGINGDB%%", (mNetMeter.DatabaseType == "{Sql Server}" ? mStageDB.DatabaseName + "." : mStageDB.DatabaseName), true);
      String programText = queryAdapter.GetQuery();

      mLogger.LogDebug("About to execute MetraFlow program . . .");
      MetraFlowProgram p = new MetraFlowProgram(programText, inputs, outputs);
      p.Run();

      if (outputs.Tables[errTable].Rows.Count > 0)
      {
        foreach (DataRow r in outputs.Tables[errTable].Rows)
        {
          param.RecordWarning(String.Format("Account {0} could not pay ${1}.  Could only cover ${2}.", r["failed_acc"], r["invoiceBalance"], r["totalCharged"]));
        }
      }

      // clean-up
      table.Clear();
      inputs.Clear();
      outputs.Clear();

      table.Dispose();
      inputs.Dispose();
      outputs.Dispose();

      param.RecordInfo("Completed Execution of MetraFlow Program.");
      mLogger.LogDebug("Completed Execution of MetraFlow Program.");
    }

    
    private string GetInvoiceNumbers(MetraPaymentInfo paymentInfo)
    {
        try
        {
            StringBuilder invoiceNos = new StringBuilder();

            if (paymentInfo.MetraPaymentInvoices != null && paymentInfo.MetraPaymentInvoices.Count > 0)
            {
                paymentInfo.MetraPaymentInvoices.ForEach(invoice => { invoiceNos.AppendFormat("{0},", invoice.InvoiceNum); });
            }
            return invoiceNos.ToString();
        }
        catch (Exception e)
        {
            mLogger.LogException("cannot extract invoice numbers from MetraPaymentInfo", e);
            return "";
        }
    }
    #endregion

    private object BlankIfNull(object input)
    {
      if ((input == null) || (input == DBNull.Value))
      {
        return string.Empty;
      }
      return input;
    }
  }
}

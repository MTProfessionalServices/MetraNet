using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Transactions;
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
using System.Text;


namespace MetraTech.Core.Workflows
{
  public class ACHInquiryAdapterWorkflow : MTAdapterWorkflowBase
	{
    #region Members
    [NonSerialized]
    public ACHInquiryAdapterConfig m_ConfigSection;

    [NonSerialized]
    public Logger m_Logger = new Logger("[ACHInquiryAdapter]");

    [NonSerialized]
    public List<PendingACHRequest> m_PendingRequests = new List<PendingACHRequest>();

    [NonSerialized]
    public MetraTech.Core.Services.EPSConfig m_EPSConfig;

    [NonSerialized]
    public MetraTech.Core.Services.IARPaymentIntegration mArPaymentIntegrationImpl; 

    #endregion

    public ACHInquiryAdapterWorkflow()
    {

    }

#region private methods

    private void NotifyARPaymentSucceeded(string requestID)
    {
        if (mArPaymentIntegrationImpl != null && !string.IsNullOrEmpty(requestID))
        {
            //  mArPaymentIntegrationImpl.PaymentSucceed(requestID);
        }
    }

    private void NotifyARPaymentFailed(string requestID)
    {
        if (mArPaymentIntegrationImpl != null && !string.IsNullOrEmpty(requestID))
        {
            // mArPaymentIntegrationImpl.PaymentFailed(requestID);
        }
    }

    private Configuration LoadConfigurationFile(string configFile)
    {
        IMTRcd rcd = new MTRcd();
        //rcd.Init();

        string configPath = configFile;

        if (!Path.IsPathRooted(configPath))
        {
            MTRcdFileList fileList = rcd.RunQueryInAlternateFolder(configPath, true, rcd.ConfigDir);

            if (fileList.Count > 0)
            {
                configPath = (string)fileList[0];
            }
            else
            {
                throw new ArgumentException(string.Format("Configuration file {0} could not be located", configPath), "configFile");
            }
        }

        ExeConfigurationFileMap map = new ExeConfigurationFileMap();
        map.ExeConfigFilename = configPath;
        Configuration config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

        return config;
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
            m_Logger.LogException("cannot extract invoice numbers from MetraPaymentInfo", e);
            return "";
        }
    }
#endregion

    #region Workflow Methods

    public void LoadConfiguration_ExecuteCode(object sender, EventArgs e)
    {
      IMTRcd rcd = new MTRcdClass();
      string configFileName = (Path.IsPathRooted(ConfigFile) ? ConfigFile : Path.Combine(rcd.ExtensionDir, ConfigFile));
      m_ConfigSection = new ACHInquiryAdapterConfig(configFileName);
    }

    public void GetPendingACHTrans_ExecuteCode(object sender, EventArgs e)
    {
      PendingACHRequest pendingRequest;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\UsageServer\Adapters\ACHInquiryAdapter", "__GET_PENDING_ACH_TRANS__"))
          {
              stmt.AddParam("%%MAX_DAYS%%", m_ConfigSection.MaxProcessingDays);

              IMTDataReader rdr = stmt.ExecuteReader();

              Dictionary<string, PendingACHRequest> dicPendRequests = new Dictionary<string, PendingACHRequest>();

              while (rdr.Read())
              {
                  if (dicPendRequests.ContainsKey(rdr.GetString("id_payment_transaction")))
                  {
                      pendingRequest = dicPendRequests[rdr.GetString("id_payment_transaction")];

                      if (pendingRequest.PaymentInfo.MetraPaymentInvoices == null)
                          pendingRequest.PaymentInfo.MetraPaymentInvoices = new List<MetraPaymentInvoice>();

                      MetraPaymentInvoice invoice = new MetraPaymentInvoice();
                      invoice.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                      if (!rdr.IsDBNull("dt_invoice"))
                      {
                        invoice.InvoiceDate = rdr.GetDateTime("dt_invoice");
                      }

                      invoice.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");
                      invoice.AmountToPay = rdr.GetDecimal("n_invoice_amount");

                      pendingRequest.PaymentInfo.MetraPaymentInvoices.Add(invoice);
                  }
                  else
                  {
                      pendingRequest = new PendingACHRequest();
                      pendingRequest.TransactionID = rdr.GetString("id_payment_transaction");
                      pendingRequest.DaysUnsettled = rdr.GetInt32("n_days");

                      pendingRequest.AccountID = rdr.GetInt32("id_acc");
                      pendingRequest.PaymentInstrumentID = new Guid(rdr.GetString("id_payment_instrument"));

                      pendingRequest.PaymentInfo = GetPaymentInfo(rdr);
                      //pendingRequest.PaymentInfo.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                      //pendingRequest.PaymentInfo.InvoiceDate = rdr.GetDateTime("dt_invoice");
                      //pendingRequest.PaymentInfo.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");
                      pendingRequest.PaymentInfo.Description = (!rdr.IsDBNull("nm_description") ? rdr.GetString("nm_description") : "");
                      //pendingRequest.PaymentInfo.Currency = rdr.GetString("nm_currency");
                      pendingRequest.PaymentInfo.Amount = rdr.GetDecimal("n_amount");

                      pendingRequest.AccountNumber = rdr.GetString("nm_truncd_acct_num");

                      pendingRequest.Processed = false;
                      if (pendingRequest.PaymentInfo.MetraPaymentInvoices == null)
                      {
                        pendingRequest.PaymentInfo.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                      }

                      MetraPaymentInvoice invoice = new MetraPaymentInvoice();
                      invoice.InvoiceNum = (!rdr.IsDBNull("nm_invoice_num") ? rdr.GetString("nm_invoice_num") : "");
                      if (!rdr.IsDBNull("dt_invoice"))
                      {
                        invoice.InvoiceDate = rdr.GetDateTime("dt_invoice");
                      }

                      invoice.AmountToPay = rdr.GetDecimal("n_invoice_amount");
                      invoice.PONum = (!rdr.IsDBNull("nm_po_number") ? rdr.GetString("nm_po_number") : "");

                      pendingRequest.PaymentInfo.MetraPaymentInvoices.Add(invoice);

                      pendingRequest.ArRequestId = rdr.GetString("nm_ar_request_id");
                      dicPendRequests.Add(pendingRequest.TransactionID, pendingRequest);
                  }
              }

              if (dicPendRequests.Count > 0)
                  m_PendingRequests = dicPendRequests.Values.ToList();

              m_Logger.LogDebug("Found {0} pending ACH transactions", m_PendingRequests.Count);
          }
      }
    }

    public void DownloadReports_ExecuteCode(object sender, EventArgs e)
    {
      if (m_PendingRequests.Count > 0)
      {
        string configFilePath = m_ConfigSection.WCFConfigFile;

        if (!Path.IsPathRooted(configFilePath))
        {
          IMTRcd rcd = new MTRcdClass();

          configFilePath = Path.Combine(rcd.ExtensionDir, configFilePath);
        }

        // TODO: We are serially checking here, should we use the Callback paradigm?
        RecurringPaymentsServiceClient client = MASClientClassFactory.CreateClient<RecurringPaymentsServiceClient>(configFilePath, m_ConfigSection.EPSEndpoint);

        IMTServerAccessDataSet serverAccessSet = new MTServerAccessDataSetClass();
        IMTServerAccessData superUser = serverAccessSet.FindAndReturnObjectIfExists("SuperUser");

        client.ClientCredentials.UserName.UserName = superUser.UserName;
        client.ClientCredentials.UserName.Password = superUser.Password;

        client.DownloadACHTransactionsReport(m_ConfigSection.ReportURL);

        for (int i = 0; i < m_PendingRequests.Count; i++)
        {
          PendingACHRequest req = m_PendingRequests[i];
          m_Logger.LogDebug(String.Format("Looking up transaction id {0}", req.TransactionID));
          client.GetACHTransactionStatus(req.TransactionID, out req.Processed);
          m_PendingRequests[i] = req;
        }

        // TODO: We need to clear the report from memory
        // client.ClearReport();
      }
      else
      {
        m_Logger.LogDebug("There are no pending ach transactions to be processed.");
      }
    }

    public void ProcessACHTrans_ExecuteCode(object sender, EventArgs e)
    {

        // Reading in EPS Config related . . .
        Configuration config = LoadConfigurationFile(@"ElectronicPaymentServices\EPSHost.xml");

        MetraTech.Core.Services.EPSConfig epsConfig = config.GetSection("EPSConfig") as MetraTech.Core.Services.EPSConfig;
        m_EPSConfig = epsConfig;
        try
        {
            m_Logger.LogInfo("ArImplementation Assembly Name :" + m_EPSConfig.ArPayImplementation.Type);
            if (!string.IsNullOrEmpty(m_EPSConfig.ArPmtImplType))
            {
                mArPaymentIntegrationImpl = Activator.CreateInstance(Type.GetType(m_EPSConfig.ArPmtImplType)) as MetraTech.Core.Services.IARPaymentIntegration;
            }
        }
        catch (Exception excp)
        {
            m_Logger.LogException("Error while instantiating ARPaymentIntegration. ", excp);
        }

      if (m_PendingRequests.Count > 0)
      {
        IMTQueryAdapter processReq = new MTQueryAdapterClass();
        processReq.Init(@"Queries\UsageServer\Adapters\ACHInquiryAdapter");

          var lstArProcessedPayments = new List<string>();


          var updateQueries = new MTStringBuilder();
            updateQueries.Append("BEGIN\n");
  
          for (int i = 0; i < m_PendingRequests.Count; i++)
          {
              
            if (m_PendingRequests[i].Processed)
            {
              processReq.SetQueryTag("__DELETE_PROCESSED_ACH_TRANS__");
              processReq.AddParam("%%PAYMENT_TX_ID%%", m_PendingRequests[i].TransactionID, true);
              updateQueries.Append((processReq.GetQuery().Trim() + ";\n"));
 
              lstArProcessedPayments.Add(m_PendingRequests[i].ArRequestId);

              if ((i + 1) % m_ConfigSection.DeleteSetSize == 0)
              {
                  try
                  {
                      updateQueries.Append("END;");
                      m_Logger.LogDebug("Executing {0}", updateQueries.ToString());


                          using (IMTConnection conn = ConnectionManager.CreateConnection())
                          {
                              using (IMTStatement stmt = conn.CreateStatement(updateQueries.ToString()))
                              {
                                  stmt.ExecuteNonQuery();
                              }

                              lstArProcessedPayments.ForEach(arRequestId =>
                              {
                                  try
                                  {
                                      NotifyARPaymentSucceeded(arRequestId);
                                  }
                                  catch (Exception excp)
                                  {

                                      m_Logger.LogException(string.Format("Error while executing AR Notification failed message for AR Request ID : {0}", arRequestId), excp);
                                      if (m_EPSConfig != null && m_EPSConfig.ArPayImplementation != null && m_EPSConfig.ArPayImplementation.RaiseError)
                                      {
                                          throw new ArNotificationProcessorException(excp.Message);
                                      }
                                  }
                              });
                          }


                  }
                  catch (Exception ex)
                  {
                      m_Logger.LogException("Exception deleteing successful entries", ex);
                      m_Logger.LogError("Exception when running following deletes:\n{0}", updateQueries);
                  }

                lstArProcessedPayments.Clear();
                updateQueries.Clear();
                updateQueries.Append("BEGIN\n");
              }
            }
            else
            {
              processReq.SetQueryTag("__UPDATE_PENDING_ACH_TRANS__");
              processReq.AddParam("%%PAYMENT_TX_ID%%", m_PendingRequests[i].TransactionID, true);

              updateQueries.Append(processReq.GetQuery().Trim() + ";\n");

              if ((i + 1) % m_ConfigSection.DeleteSetSize == 0)
              {
                  try
                  {
                      updateQueries.Append("END;");
                      m_Logger.LogDebug("Executing {0}", updateQueries);
                      using (IMTConnection conn = ConnectionManager.CreateConnection())
                      {
                          using (IMTStatement stmt = conn.CreateStatement(updateQueries.ToString()))
                          {

                              stmt.ExecuteNonQuery();
                          }
                      }
                  }
                  catch (Exception ex)
                  {
                      m_Logger.LogException("Exception updating successful entries", ex);
                      m_Logger.LogError("Exception when running following updates:\n{0}", updateQueries.ToString());
                  }

                  updateQueries.Clear();
                updateQueries.Append("BEGIN\n");
              }
            }
          }
          if (updateQueries.Length > 0)
          {
              try
              {
                  updateQueries.Append("END;");
                  using (IMTConnection conn = ConnectionManager.CreateConnection())
                  {
                      using (IMTStatement stmt = conn.CreateStatement(updateQueries.ToString()))
                      {
                          stmt.ExecuteNonQuery();
                      }
                  }
              }
              catch (Exception ex)
              {
                  m_Logger.LogException("Exception updating successful entries", ex);
                  m_Logger.LogError("Exception when running following updates:\n{0}", updateQueries.ToString());
              }

            updateQueries.Clear();
          }
        
      }
    }

    public void MeterPayments_ExecuteCode(object sender, EventArgs e)
    {
      if (m_PendingRequests.Count > 0)
      {
        Meter meterSDK = new MeterClass();
        meterSDK.Startup();

        MTServerAccessDataSet sads = new MTServerAccessDataSetClass();
        sads.Initialize();
        MTServerAccessData svr = sads.FindAndReturnObject("AdjustmentsServer");
        meterSDK.AddServer(svr.Priority, svr.ServerName, (svr.Secure != 0 ? PortNumber.DEFAULT_HTTPS_PORT : PortNumber.DEFAULT_HTTP_PORT), svr.Secure, svr.UserName, svr.Password);

        SessionSet sessionSet = meterSDK.CreateSessionSet();

        for (int i = 0; i < m_PendingRequests.Count; i++)
        {
          if (m_PendingRequests[i].Processed)
          {
            Session s = sessionSet.CreateSession("metratech.com/Payment");

            s.InitProperty("_AccountID", m_PendingRequests[i].AccountID);
            m_Logger.LogDebug("Metering amount {0} for account {1}", -1 * m_PendingRequests[i].PaymentInfo.Amount, m_PendingRequests[i].AccountID);
            s.InitProperty("_Amount", -1 * m_PendingRequests[i].PaymentInfo.Amount);
            s.InitProperty("Description", m_PendingRequests[i].PaymentInfo.Description);
            s.InitProperty("EventDate", MetraTime.Now);
            s.InitProperty("Source", "MT");
            s.InitProperty("PaymentMethod", "ACH");
            s.InitProperty("CheckOrCardNumber", m_PendingRequests[i].AccountNumber.Substring(m_PendingRequests[i].AccountNumber.Length - 4));

            if (m_PendingRequests[i].PaymentInfo != null && m_PendingRequests[i].PaymentInfo.MetraPaymentInvoices != null)
            {

              foreach (MetraPaymentInvoice invoice in m_PendingRequests[i].PaymentInfo.MetraPaymentInvoices)
              {
                m_Logger.LogDebug(string.Format("adding child session in Ach Inquiry Adapter for metering.. invoice num -> : {0}", invoice.InvoiceNum ?? "empty"));
                Session cs = s.CreateChildSession("metratech.com/PaymentDetails");

                cs.InitProperty("_AccountID", m_PendingRequests[i].AccountID);

                cs.InitProperty("InvoiceNum", invoice.InvoiceNum ?? "");
                cs.InitProperty("PONumber", invoice.PONum ?? "");
                m_Logger.LogDebug(string.Format("invoice date : {0} ", invoice.InvoiceDate.HasValue ? invoice.InvoiceDate.Value.ToLongDateString() : ""));
                if (invoice.InvoiceDate.HasValue)
                {
                  cs.InitProperty("InvoiceDate", invoice.InvoiceDate.Value);
                }
                m_Logger.LogDebug(string.Format("invoice amount --> {0} ", invoice.AmountToPay));

                cs.InitProperty("_Amount", invoice.AmountToPay);
              }
            }

            if (i % m_ConfigSection.SessionSetSize == 0)
            {
              sessionSet.Close();
              sessionSet = meterSDK.CreateSessionSet();
            }
          }
        }

        if (sessionSet.GetSessions().Count > 0)
        {
          sessionSet.Close();
        }

        meterSDK.Shutdown();
      }
    }

    // TODO: Need to decide how we want to handle failures.  Log a warning on the worst case
    public void ProcessFailures_ExecuteCode(object sender, EventArgs e)
    {
      LogACHWarnings();
    }

    #endregion

    #region Virtual Methods
    public virtual MetraPaymentInfo GetPaymentInfo(IMTDataReader dataReader)
    {
      MetraPaymentInfo paymentInfo = new MetraPaymentInfo();

      return paymentInfo;
    }

    public virtual XmlNodeList GetACHTxReport(string url, string elementName)
    {
      XmlTextReader reportReader = new XmlTextReader(url);
      XmlDocument report = new XmlDocument();
      report.Load(reportReader);
      XmlNodeList checks = report.GetElementsByTagName("Check");

      return checks;
    }

    public virtual void LogACHWarnings()
    {
      foreach (PendingACHRequest req in m_PendingRequests)
      {
        // log this so operator can see this info in the details and operator knows there are issues
        if (req.DaysUnsettled == m_ConfigSection.MaxProcessingDays - 1)
        {
          string msg = String.Format("Invoices - {0} has been unsettled for the maximum number of allowed days.", GetInvoiceNumbers(req.PaymentInfo));
          ExecutionContext.RecordWarning(msg);

          try
          {
              NotifyARPaymentFailed(req.ArRequestId);
          }
          catch (Exception excp)
          {
              m_Logger.LogException(string.Format("Error while executing AR Notification failed message for AR Request ID : {0}", req.ArRequestId), excp);

              if (m_EPSConfig != null && m_EPSConfig.ArPayImplementation != null && m_EPSConfig.ArPayImplementation.RaiseError)
              {
                  throw new ArNotificationProcessorException(excp.Message);
              }
          }

        }
      }
    }
    #endregion

  }

  public struct PendingACHRequest
  {
    public int AccountID;
    public Guid PaymentInstrumentID;
    public MetraPaymentInfo PaymentInfo;
    public Guid? AuthorizationID;

    public PaymentType MethodType;
    public string AccountNumber;
    public string RoutingNumber;
    public string TransactionID;
    public bool Processed;
    public int DaysUnsettled;
    public string RequestParams;
    public string ArRequestId;
  }

  public class ACHInquiryAdapterConfig
  {
    #region Members
    private string m_WCFConfigFile;
    private string m_EPSEndpoint;
    private string m_ReportURL;
    private int m_MaxConcurrentRequests;
    private int m_SessionSetSize;
    private int m_DeleteSetSize;
    private int m_MaxProcessingDays;
    #endregion

    public ACHInquiryAdapterConfig(string configFilePath)
    {
      XmlDocument configFile = new XmlDocument();
      configFile.Load(configFilePath);

      XmlNode root = configFile.SelectSingleNode("//ACHInquiryAdapter");

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

          case "ReportURL":
            m_ReportURL = childNode.InnerText;
            break;

          case "MaxConcurrentRequests":
            m_MaxConcurrentRequests = int.Parse(childNode.InnerText);
            break;

          case "SessionSetSize":
            m_SessionSetSize = int.Parse(childNode.InnerText);
            break;

          case "DeleteSetSize":
            m_DeleteSetSize = int.Parse(childNode.InnerText);
            break;

          case "MaxProcessingDays":
            m_MaxProcessingDays = int.Parse(childNode.InnerText);
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

    public string ReportURL
    {
      get { return m_ReportURL; }
    }
    public int MaxConcurrentRequests
    {
      get { return m_MaxConcurrentRequests; }
    }

    public int SessionSetSize
    {
      get { return m_SessionSetSize; }
    }

    public int DeleteSetSize
    {
      get { return m_DeleteSetSize; }
    }

    public int MaxProcessingDays
    {
      get { return m_MaxProcessingDays; }
    }
    #endregion
  }
}

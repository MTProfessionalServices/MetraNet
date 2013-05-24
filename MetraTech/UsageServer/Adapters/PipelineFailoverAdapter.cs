using System;
using System.Xml;
using System.Diagnostics;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.Pipeline.ReRun;
using PipelineControl = MetraTech.Interop.PipelineControl;
using MetraTech.Interop.Rowset;
using BillingReRun = MetraTech.Interop.MTBillingReRun;
using BillingReRunClient = MetraTech.Pipeline.ReRun;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.GenericCollection;


// <xmlconfig>
//	<StoredProcs>
//		<CalculateInvoice>mtsp_InsertInvoice</CalculateInvoice>
//		<GenInvoiceNumbers>mtsp_GenerateInvoiceNumbers</GenInvoiceNumbers>
//	</StoredProcs>
//	<IsSample>N</IsSample>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]  //ask

namespace MetraTech.UsageServer.Adapters
{
  /// <summary>
  /// Pipeline Failover Adapter, schedueled transactions that failed due to network or db server failover.
  /// Takes the records from t_failed_transactions that have specific error messages and resubmits them.
  /// </summary>
  public class PipelineFailoverAdapter : MetraTech.UsageServer.IRecurringEventAdapter
  {
    // data
    private Logger mLogger = new Logger("[PipelineFailoverAdapter]");
    private string mConfigFile;

    private FailedTxnManager failedTxnManager = new FailedTxnManager();

    //private long mDelayDeletionDays;
    //private TimeSpan mDelayPeriod = TimeSpan.FromDays(0);
    //private long mDelayDeleteSuccessfulResubmitsDays = -1;

    //adapter capabilities
    public bool SupportsScheduledEvents { get { return true; } }
    public bool SupportsEndOfPeriodEvents { get { return false; } }
    public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
    public bool AllowMultipleInstances { get { return false; } }

    public PipelineFailoverAdapter()
    {
    }

    public void Initialize(string eventName, string configFile, MTAuth.IMTSessionContext context, bool limitedInit)
    {
      bool status;

      mLogger.LogDebug("Initializing Failed Transaction Adapter");
      mLogger.LogDebug("Using config file: {0}", configFile);
      mConfigFile = configFile;
      mLogger.LogDebug(mConfigFile);
      if (limitedInit)
        mLogger.LogDebug("Limited initialization requested");
      else
        mLogger.LogDebug("Full initialization requested");

      status = ReadConfigFile(configFile);
      if (status)
        mLogger.LogDebug("Initialize successful");
      else
        mLogger.LogError("Initialize failed, Could not read config file");
    }

    public string Execute(IRecurringEventRunContext context)
    {
      string detail;

      int failureCount = failedTxnManager.FindAndResubmit();

      // record details about this resubmission
      if (failureCount > 0)
      {
        detail = String.Format("Resubmitted {0} failed transactions total", failureCount);
      }
      else
      {
        detail = String.Format("Nothing to resubmit");
      }

      foreach (string ErrorMessage in failedTxnManager.ErrorCountByErrorMessage.Keys)
      {
        string msg = string.Format("Resubmitted {0} transaction(s) with error message: {1}", 
          failedTxnManager.ErrorCountByErrorMessage[ErrorMessage], 
          ErrorMessage);
        context.RecordInfo(msg);
        mLogger.LogDebug(msg);
      }
//      context.RecordInfo(detail);
      mLogger.LogDebug(detail);

      return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string detail;

      detail = string.Format("Reverse Not Needed/Not Implemented");
      return detail;
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down Pipeline Failover Adapter");
    }

    private bool ReadConfigFile(string configFile)
    {
      return failedTxnManager.ReadConfigFile(configFile);
    }

    /// <summary>
    /// Conveniently log in as su.
    /// </summary>
    internal static IMTSessionContext GetSuperUserContext()
    {
      IMTLoginContext loginCtx = new MTLoginContextClass();

      ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      sa.Initialize();
      ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      string suName = accessData.UserName;
      string suPassword = accessData.Password;

      return loginCtx.Login(suName, "system_user", suPassword);
    }
  }

  public class FailedTxnManager
  {

    private class FailedTxn
    {
      public string state;
      public string tx_FailureCompoundID_encoded;
      public string tx_ErrorMessage;

      public void Load(IMTDataReader rdr)
      {
        if (!rdr.IsDBNull("State"))
          state = rdr.GetString("State");
        if (!rdr.IsDBNull("tx_FailureCompoundID_encoded"))
          tx_FailureCompoundID_encoded = rdr.GetString("tx_FailureCompoundID_encoded");
        if (!rdr.IsDBNull("tx_ErrorMessage"))
          tx_ErrorMessage = rdr.GetString("tx_ErrorMessage");
      }
    }

    public System.Collections.Generic.Dictionary<string, int> ErrorCountByErrorMessage = new System.Collections.Generic.Dictionary<string, int>();

    private string mRawQuery;
    private int mMaxTxnCount;
    private bool mIsOracle;
    private Logger mLogger = new Logger("[FailedTxnManager]");

    public FailedTxnManager()
    {
      ConnectionInfo aConnInfo;
      aConnInfo = new ConnectionInfo("NetMeter");
      mIsOracle = (aConnInfo.DatabaseType == DBType.Oracle);
    }


    public bool ReadConfigFile(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      if (mIsOracle)
        mRawQuery = doc.GetNodeValueAsString("/xmlconfig/Oraclequery");
      else
        mRawQuery = doc.GetNodeValueAsString("/xmlconfig/SQLServerquery");

      // limit the number of transactions to be resubmitted
      mMaxTxnCount = doc.GetNodeValueAsInt("/xmlconfig/MaxTxnCount");


      //mDelayDeletionDays = doc.GetNodeValueAsInt("/xmlconfig/DelayDeletionDays");
      //mDelayPeriod = TimeSpan.FromDays(mDelayDeletionDays);

      //// Optional configuration parameter.
      //if (doc.SingleNodeExists("/xmlconfig/DeleteSuccessfulResubmitsAfter") != null)
      //  mDelayDeleteSuccessfulResubmitsDays = doc.GetNodeValueAsInt("/xmlconfig/DeleteSuccessfulResubmitsAfter");

      return true;
    }

    public int FindAndResubmit()
    {
      int failureCount = 0;

      try
      {
        MetraTech.Interop.PipelineControl.IMTCollection failureCollection;
        failureCollection = ReadErrors();
        failureCount = failureCollection.Count;
        if (failureCollection.Count > 0)
        {
          MetraTech.Pipeline.ReRun.BulkFailedTransactions bft = new BulkFailedTransactions();
          bft.ResubmitCollection(failureCollection, null);
        }
      }
      catch (Exception e)
      {
        string msg = "Unable to resubmit failed transactions.";
        mLogger.LogException(msg, e);
        throw new Exception(msg, e);
      }
      return failureCount;
    }


    private PipelineControl.IMTCollection ReadErrors()
    {
      MetraTech.Interop.PipelineControl.IMTCollection failureCollection =
        (MetraTech.Interop.PipelineControl.IMTCollection)new MTCollection();

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTStatement stmt = conn.CreateStatement(mRawQuery))
        {
          //stmt.AddParam("%%ID_INTERVAL%%", UsageIntervalId);
          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            int i = 0;
            while (rdr.Read())
            {
              if (++i > mMaxTxnCount) break; // don't resubmit more than max allowed at a time.
              FailedTxn failedTxn = new FailedTxn();
              failedTxn.Load(rdr);
              if (failedTxn.state == "N")
              {
                string mFailureUID = failedTxn.tx_FailureCompoundID_encoded;
                failureCollection.Add(mFailureUID);

                // keep failed txn count by error message
                if (ErrorCountByErrorMessage.ContainsKey(failedTxn.tx_ErrorMessage))
                  ErrorCountByErrorMessage[failedTxn.tx_ErrorMessage] = ErrorCountByErrorMessage[failedTxn.tx_ErrorMessage] + 1;
                else
                  ErrorCountByErrorMessage.Add(failedTxn.tx_ErrorMessage, 1);

              }
              else
              {
                //Txn in state other than open received. Log angry warning message.
                mLogger.LogWarning("Failed transaction in State other than Opened was ignored. Correct SQL statement in the adapter config to return only open transactions (State = 'N')");
              }
            }
          }
        }
        return failureCollection;
      } // using
    } //Read Errors

  }
}

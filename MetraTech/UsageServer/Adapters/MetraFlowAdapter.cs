using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;



// <xmlconfig>
//	<Program>
//  MetraFlowScript goes here
//	</Program>
//  <Parameter>Valid parameters are ID_INTERVAL, ID_BILLGROUP, ID_BATCH, DT_START, DT_END</Parameters>
//	<MetraFlow>
//  <Hostname>A list of hostnames for configuring cluster execution</Hostname>
//  </MetraFlow>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]  //ask

namespace MetraTech.UsageServer.Adapters
{
	/// <summary>
	/// MetraFlow Adapter, used to execute an arbitrary MetraFlow program.
	/// </summary>
	public class MetraFlowAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
    private Logger mLogger = new Logger ("[MetraFlowAdapter]");
    private MetraFlowScript mScript;
    private string mProgram;
    private MetraFlowConfig mMetraFlowConfig;
    private System.Collections.Generic.List<string> mParameters;
    private bool mSyncOnBatch;
    private int mCommitTimeout;
    private string mConfigFile;

    private bool mSupportsScheduledEvents;
    private bool mSupportsEndOfPeriodEvents;
    private bool mSupportsBillgroups;
		
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return mSupportsScheduledEvents; }}
		public bool SupportsEndOfPeriodEvents { get { return mSupportsEndOfPeriodEvents; }}
		public ReverseMode Reversibility {get { return ReverseMode.Auto; }}
		public bool AllowMultipleInstances { get { return false; }}
    public BillingGroupSupportType BillingGroupSupport { get	{ return mSupportsBillgroups ? BillingGroupSupportType.Account : BillingGroupSupportType.Interval; } }
    public bool HasBillingGroupConstraints { get { return false; }}
		
		public MetraFlowAdapter()
		{
      mMetraFlowConfig = null;
      mScript = null;
      // Should the adapter block until the batch is processed by the pipeline?
      mSyncOnBatch = false;
      mCommitTimeout = 3600;
      mParameters = new System.Collections.Generic.List<string>();
      mSupportsScheduledEvents = true;
      mSupportsEndOfPeriodEvents = true;
      mSupportsBillgroups = true;
		}

	    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			bool status;

			mLogger.LogDebug("Initializing MetraFlow Adapter");
			mLogger.LogDebug("Using config file: {0}", configFile);
			mConfigFile = configFile;
			mLogger.LogDebug (mConfigFile);
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

		public string Execute(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Executing MetraFlow Adapter");

			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", param.BillingGroupID);
			
			param.RecordInfo("Invoking MetraFlow program ... ");
			
      MetraTech.Interop.MeterRowset.MeterRowset meterrs = new MetraTech.Interop.MeterRowset.MeterRowsetClass();
      meterrs.InitSDK("DiscountServer");
      string batchid="";
      if (param != null)
      {
        MetraTech.Interop.MeterRowset.IBatch batch = meterrs.CreateAdapterBatch(param.RunID,
                                                                                "MetraFlowAdapter",
                                                                                "MetraFlowAdapter");
        batchid = batch.UID;
      }
      else
      {
        batchid = meterrs.GenerateBatchID();
      }

      if (null != mScript)
      {
        foreach(string p in mParameters)
        {
          if (p == "ID_INTERVAL")
          {
            mScript.SetInt32("ID_INTERVAL", param.UsageIntervalID);
          }
          else if (p == "ID_BILLGROUP")
          {
            mScript.SetInt32("ID_BILLGROUP", param.BillingGroupID);
          }
          else if (p == "ID_RUN")
          {
            mScript.SetInt32("ID_RUN", param.RunID);
          }
          else if (p == "ID_BATCH")
          {
            mScript.SetBinary("ID_BATCH", batchid);
          }
          else if (p == "DT_START")
          {
            mScript.SetDateTime("DT_START", param.StartDate);
          }
          else if (p == "DT_END")
          {
            mScript.SetDateTime("DT_END", param.EndDate);
          }
        }

        mScript.Run("[MetraFlowAdapter]", param, mMetraFlowConfig);
      }
      else
      {
        foreach(string p in mParameters)
        {
          if (p == "ID_INTERVAL")
          {
            mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
          }
          else if (p == "ID_BILLGROUP")
          {
            mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
          }
          else if (p == "ID_RUN")
          {
            mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, "%%ID_RUN%%", param.RunID.ToString());
          }
          else if (p == "ID_BATCH")
          {
            // This comes back UUENCODED, MF expects it as a hex literal 0x......
            // so we have unencode and convert.  Luckily we have a method to do that.
            string usethis = MetraTech.Utils.MSIXUtils.DecodeUIDAsString(batchid);
            usethis = "0x" + usethis;
            mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, "%%ID_BATCH%%", usethis);
          }
          else if (p == "DT_START")
          {
            mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, "%%DT_START%%", param.StartDate.ToString("yyyy-MM-dd HH:mm:ss"));
          }
          else if (p == "DT_END")
          {
            mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, "%%DT_END%%", param.EndDate.ToString("yyyy-MM-dd HH:mm:ss"));
          }
        }

        MetraFlowRun r = new MetraFlowRun();
        int ret = r.Run(mProgram, "[MetraFlowAdapter]", mMetraFlowConfig);
        if (ret != 0)
        {
          return "MetraFlow adapter failed.  Check log for details.";
        }
      }
      
      if (mSyncOnBatch)
      {
        using (MetraTech.DataAccess.IMTConnection conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
        {
          //
          // Find out how many records we metered.
          //
          int meteredRecords=0;
          using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog",
                                                                                      "__GET_AGGREGATE_METERING_COUNT__"))
          {
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      if (reader.IsDBNull("cnt"))
                          meteredRecords = 0;
                      else
                          meteredRecords = reader.GetInt32("cnt");
                  }
              }
          }
          //
          // waits until all sessions commit
          //
          param.RecordInfo(string.Format("Waiting for sessions to commit (timeout = {0} seconds)", mCommitTimeout));
          meterrs.WaitForCommit(meteredRecords, mCommitTimeout);
          //
          // check for error during pipeline processing
          //
          if (meterrs.CommittedErrorCount > 0)
          {
            throw new ApplicationException(String.Format("{0} sessions failed during pipeline processing.", meterrs.CommittedErrorCount));
          }
        }
      }
			
			return "";
		}

		public string Reverse(IRecurringEventRunContext param)
		{
      // We are auto reverse so don't bother implementing
      return "";
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down MetraFlow Adapter");
		}
	
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
	
    public void SplitReverseState(int parentRunID, 
                                  int parentBillingGroupID,
                                  int childRunID, 
                                  int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of MetraFlow Adapter");
    }

		private bool ReadConfigFile(string configFile)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);  
      System.Xml.XmlNode n = doc.SingleNodeExists("/xmlconfig/Script");
      if (n != null)
      {
        string scriptName = doc.GetNodeValueAsString("/xmlconfig/Script/Name");
        string scriptExtension = doc.GetNodeValueAsString("/xmlconfig/Script/Extension");
        mScript = MetraFlowScript.GetExtensionScript(scriptExtension, scriptName);
      }
      else
      {
        mProgram = doc.GetNodeValueAsString("/xmlconfig/Program");
      }
      foreach(System.Xml.XmlNode node in doc.SelectNodes("/xmlconfig/Parameter"))
      {
        if (node.InnerText != "ID_INTERVAL" &&
          node.InnerText != "ID_BILLGROUP" &&
          node.InnerText != "ID_RUN" &&
          node.InnerText != "ID_BATCH" &&
          node.InnerText != "DT_START" &&
          node.InnerText != "DT_END")
        {
          string msg = string.Format("Unsupported parameter '{0}' in MetraFlow adapter", node.InnerText);
          mLogger.LogWarning(msg);
          throw new ApplicationException(msg);
        }

        /** 
         See JIRA CORE-1857 for details on why we are hard-coding
         support of EOP, Schedule, and billing group to true.
         **/

        if (node.InnerText == "ID_INTERVAL")
        {
          //mSupportsEndOfPeriodEvents = true;
        }
        else if(node.InnerText == "DT_START" || node.InnerText == "DT_END")
        {
          //mSupportsScheduledEvents = true;
        }
        else if (node.InnerText == "ID_BILLGROUP")
        {
          //mSupportsEndOfPeriodEvents = true;
          //mSupportsBillgroups = true;
        }

        // TODO: We should support either ID_INTERVAL or DT_START/DT_END.
        mParameters.Add(node.InnerText);
      }

      if (mSupportsEndOfPeriodEvents && mSupportsScheduledEvents)
      {
        string msg = "MetraFlow adapter cannot have parameters ID_INTERVAL and DT_START/DT_END set simultaneously";
        mLogger.LogWarning(msg);
        throw new ApplicationException(msg);
      }

      mSyncOnBatch = doc.GetNodeValueAsBool("xmlconfig/SyncOnBatch", false);
      mCommitTimeout = doc.GetNodeValueAsInt("xmlconfig/CommitTimeout", 3600);
      mMetraFlowConfig = new MetraFlowConfig();
			mMetraFlowConfig.Load(configFile);
			return (true);
		}
		
	}

}

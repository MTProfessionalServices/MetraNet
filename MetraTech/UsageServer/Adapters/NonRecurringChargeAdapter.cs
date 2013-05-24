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
	public class NonRecurringChargeAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
    private Logger mLogger = new Logger ("[NonRecurringChargeAdapter]");
    private string mTempDir;
    private MetraFlowConfig mMetraFlowConfig;
    private int mCommitTimeout;
    private string mConfigFile;
		
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return true; }}
		public bool SupportsEndOfPeriodEvents { get { return false; }}
		public ReverseMode Reversibility {get { return ReverseMode.Auto; }}
		public bool AllowMultipleInstances { get { return false; }}
    public BillingGroupSupportType BillingGroupSupport { get	{ return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; }}
		
		public NonRecurringChargeAdapter()
		{
      mMetraFlowConfig = null;
      mCommitTimeout = 3600;
		}

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			bool status;

			mLogger.LogDebug("Initializing NonRecurringCharge Adapter");
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
			mLogger.LogDebug("Executing NonRecurringCharge Adapter");

			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Start Date = {0}", param.StartDate);
      mLogger.LogDebug("End Date = {0}", param.EndDate);
			
			param.RecordInfo("Invoking charge generation program ... ");
      MetraTech.Xml.MTXmlDocument doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\NonRecurringChargeGenerateEvents.xml");
      string generateChargesProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      generateChargesProgram = System.Text.RegularExpressions.Regex.Replace(generateChargesProgram, "%%TEMP_DIR%%", mTempDir);
      generateChargesProgram = System.Text.RegularExpressions.Regex.Replace(generateChargesProgram, "%%ID_RUN%%", param.RunID.ToString());
      generateChargesProgram = System.Text.RegularExpressions.Regex.Replace(generateChargesProgram, "%%DT_START%%", param.StartDate.ToString("yyyy-MM-dd HH:mm:ss"));
      generateChargesProgram = System.Text.RegularExpressions.Regex.Replace(generateChargesProgram, "%%DT_END%%", param.EndDate.ToString("yyyy-MM-dd HH:mm:ss"));
      MetraFlowRun r = new MetraFlowRun();
      int ret = r.Run(generateChargesProgram, "[NonRecurringChargeAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Nonrecurring charge adapter charge generation failed.  Check log for details.");
      }

      // We support both rating through a pipeline and rating with MetraFlow.
      // In all cases we need a batch id for the adapter.
      MetraTech.Interop.MeterRowset.MeterRowset meterrs = new MetraTech.Interop.MeterRowset.MeterRowsetClass();
      meterrs.InitSDK("DiscountServer");
      string batchid="";
      if (param != null)
      {
        MetraTech.Interop.MeterRowset.IBatch batch = meterrs.CreateAdapterBatch(param.RunID,
                                                                                "NonRecurringChargeAdapter",
                                                                                "NonRecurringChargeAdapter");
        batchid = batch.UID;
      }
      else
      {
        batchid = meterrs.GenerateBatchID();
      }

      // Meter here for things destined for the pipeline.
      if (true)
      {
        doc = new MetraTech.Xml.MTXmlDocument();
        doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\NonRecurringChargeMeterEvents.xml");
        string meterToPipelineProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
        meterToPipelineProgram = System.Text.RegularExpressions.Regex.Replace(meterToPipelineProgram, "%%TEMP_DIR%%", mTempDir);
        // This comes back UUENCODED, MF expects it as a hex literal 0x......
        // so we have unencode and convert.  Luckily we have a method to do that.
        string usethis = MetraTech.Utils.MSIXUtils.DecodeUIDAsString(batchid);
        usethis = "0x" + usethis;
        meterToPipelineProgram = System.Text.RegularExpressions.Regex.Replace(meterToPipelineProgram, "%%ID_BATCH%%", usethis);

        r = new MetraFlowRun();
        ret = r.Run(meterToPipelineProgram, "[NonRecurringChargeAdapter]", mMetraFlowConfig);
        if (ret != 0)
        {
          throw new ApplicationException("Nonrecurring charge adapter metering failed.  Check log for details.");
        }

        // Wait for pipelines to finish.
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
// 			mExtractProgram = doc.GetNodeValueAsString("/xmlconfig/Extract");
// 			mGenerateProgram = doc.GetNodeValueAsString("/xmlconfig/Generate");
			mTempDir = doc.GetNodeValueAsString("/xmlconfig/TempDir");
      mCommitTimeout = doc.GetNodeValueAsInt("xmlconfig/CommitTimeout", 3600);
      mMetraFlowConfig = new MetraFlowConfig();
			mMetraFlowConfig.Load(configFile);
			return (true);
		}
		
	}

}

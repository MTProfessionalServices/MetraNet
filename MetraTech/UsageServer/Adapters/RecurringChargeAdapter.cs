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
	public class RecurringChargeAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
    private Logger mLogger = new Logger ("[RecurringChargeAdapter]");
    private string mTempDir;
    private string mSortDir;
    private MetraFlowConfig mMetraFlowConfig;
    private int mCommitTimeout;
    private string mConfigFile;
    private System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<MetraFlowScript> > mRatingMetraFlowScripts;
		
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return false; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Auto; }}
		public bool AllowMultipleInstances { get { return false; }}
    public BillingGroupSupportType BillingGroupSupport { get	{ return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; }}
		
		internal static MetraTech.Interop.MTAuth.IMTSessionContext GetSuperUserContext()
		{
			MetraTech.Interop.MTAuth.IMTLoginContext loginCtx = new MetraTech.Interop.MTAuth.MTLoginContextClass();
			
			MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();
			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;			
			return loginCtx.Login(suName, "system_user", suPassword);
		}

		public RecurringChargeAdapter()
		{
      mMetraFlowConfig = null;
      mCommitTimeout = 3600;
      mRatingMetraFlowScripts = new System.Collections.Generic.Dictionary<string, 
      System.Collections.Generic.List<MetraFlowScript> > ();
      
		}

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			bool status;

			mLogger.LogDebug("Initializing RecurringCharge Adapter");
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

		public string Execute(IRecurringEventRunContext context)
		{
			mLogger.LogDebug("Executing RecurringCharge Adapter");

			mLogger.LogDebug("Event type = {0}", context.EventType);
			mLogger.LogDebug("Run ID = {0}", context.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

      // Examine the configured recurring charge pi types.  Some of these will go through pipelines and some
      // through MetraFlow scripts.
      MetraTech.Interop.MTProductCatalog.IMTProductCatalog pc = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
			pc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)GetSuperUserContext());
      MetraTech.Interop.MTProductCatalog.IMTCollection piTypes = pc.GetPriceableItemTypes(null);

      string ratingSwitch=@"rating_switch:switch[program=""CREATE FUNCTION f (@_PriceableItemTypeID INTEGER) RETURNS INTEGER
AS
RETURN CASE @_PriceableItemTypeID {0} END""];
final_filter -> rating_switch;
";
      System.Text.StringBuilder ratingSwitchClauses = new System.Text.StringBuilder();

      string outputSwitch=@"output_{0}:sequential_file_write[filename=""{1}\rc_ready_to_rate_{0}_%1%.mfd""];
rating_switch({2}) -> output_{0};
";
      System.Text.StringBuilder outputs = new System.Text.StringBuilder();

      int output = 0;
      foreach(MetraTech.Interop.MTProductCatalog.IMTPriceableItemType pitype in piTypes)
      {
        if (pitype.Kind == MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_RECURRING || 
            pitype.Kind == MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
        {
          // Scripts for MetraFlow will be landed to their own file from event generation
          // and later picked up for rating on their own.
          ratingSwitchClauses.AppendFormat(" WHEN {0} THEN {1}", pitype.ID, output);
          outputs.AppendFormat(outputSwitch, pitype.ID, mTempDir, output);
          output += 1;
        }
      }
			
			context.RecordInfo("Invoking payer extract program ... ");
      MetraTech.Xml.MTXmlDocument doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\RecurringChargePayerExtract.xml");
     string payerExtractProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      payerExtractProgram = System.Text.RegularExpressions.Regex.Replace(payerExtractProgram, "%%TEMP_DIR%%", mTempDir);
      payerExtractProgram = System.Text.RegularExpressions.Regex.Replace(payerExtractProgram, "%%SORT_DIR%%", mSortDir);
      payerExtractProgram = System.Text.RegularExpressions.Regex.Replace(payerExtractProgram, "%%ID_BILLGROUP%%", context.BillingGroupID.ToString());

      MetraFlowRun r = new MetraFlowRun();
      int ret = r.Run(payerExtractProgram, "[RecurringChargeAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Recurring charge adapter extract failed.  Check log for details.");
      }

      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\RecurringChargeReferenceDataExtract.xml");
      string extractProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      extractProgram = System.Text.RegularExpressions.Regex.Replace(extractProgram, "%%TEMP_DIR%%", mTempDir);

      r = new MetraFlowRun();
      ret = r.Run(extractProgram, "[RecurringChargeAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Recurring charge adapter extract failed.  Check log for details.");
      }

			context.RecordInfo("Invoking charge generation program ... ");
      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\RecurringChargeGenerateChargeIntervals.xml");
      string generateIntervalsProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      generateIntervalsProgram = System.Text.RegularExpressions.Regex.Replace(generateIntervalsProgram, "%%TEMP_DIR%%", mTempDir);
      generateIntervalsProgram = System.Text.RegularExpressions.Regex.Replace(generateIntervalsProgram, "%%ID_INTERVAL%%", context.UsageIntervalID.ToString());
      generateIntervalsProgram = System.Text.RegularExpressions.Regex.Replace(generateIntervalsProgram, "%%MINIMUM_TIME%%", MetraTime.Now.AddYears(-2).ToString("yyyy-MM-dd HH:mm:ss"));
      r = new MetraFlowRun();
      ret = r.Run(generateIntervalsProgram, "[RecurringChargeAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Recurring charge adapter charge generation failed.  Check log for details.");
      }

			context.RecordInfo("Invoking unit value program ... ");
      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\RecurringChargeGenerateChargeEvents.xml");
      string generateUnitValuesProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      generateUnitValuesProgram = System.Text.RegularExpressions.Regex.Replace(generateUnitValuesProgram, "%%TEMP_DIR%%", mTempDir);
      generateUnitValuesProgram = System.Text.RegularExpressions.Regex.Replace(generateUnitValuesProgram, "%%ID_INTERVAL%%", context.UsageIntervalID.ToString());
      generateUnitValuesProgram = generateUnitValuesProgram + string.Format(ratingSwitch, ratingSwitchClauses.ToString()) + outputs.ToString();
      r = new MetraFlowRun();
      ret = r.Run(generateUnitValuesProgram, "[RecurringChargeAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Recurring charge adapter charge generation failed.  Check log for details.");
      }

      // We support both rating through a pipeline and rating with MetraFlow.
      // In all cases we need a batch id for the adapter.
      MetraTech.Interop.MeterRowset.MeterRowset meterrs = new MetraTech.Interop.MeterRowset.MeterRowsetClass();
      meterrs.InitSDK("DiscountServer");
      string batchid="";
      if (context != null)
      {
        MetraTech.Interop.MeterRowset.IBatch batch = meterrs.CreateAdapterBatch(context.RunID,
                                                                                "RecurringChargeAdapter",
                                                                                "RecurringChargeAdapter");
        batchid = batch.UID;
      }
      else
      {
        batchid = meterrs.GenerateBatchID();
      }

      foreach(MetraTech.Interop.MTProductCatalog.IMTPriceableItemType pitype in piTypes)
      {
        if (pitype.Kind == MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_RECURRING || 
            pitype.Kind == MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
        {
          if(mRatingMetraFlowScripts.ContainsKey(pitype.Name))
          {
            foreach(MetraFlowScript mfs in mRatingMetraFlowScripts[pitype.Name])
            {
              mfs.SetString("TEMP_DIR", mTempDir).SetString("SORT_DIR", mSortDir).SetInt32("ID_PI", pitype.ID).SetInt32("ID_BILLGROUP", context.BillingGroupID);
              mfs.Run("[RecurringChargeAdapter]", context, mMetraFlowConfig);
            }
            string loader = MetraTech.Dataflow.UsageLoader.GetLoaderScript(string.Format(@"{0}\rc_load_{1}_%1%.mfd", mTempDir, pitype.ID.ToString()),
                                                                           pitype.ProductView,
                                                                           50000,
                                                                           50000,
                                                                           false);
            r = new MetraFlowRun();
            ret = r.Run(loader, "[RecurringChargeAdapter]", mMetraFlowConfig);
            if (ret != 0)
            {
              throw new ApplicationException("Recurring charge adapter charge generation failed.  Check log for details.");
            }            
          }
          else
          {
            doc = new MetraTech.Xml.MTXmlDocument();
            doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\RecurringChargeMeterEvents.xml");
            string meterToPipelineProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
            meterToPipelineProgram = System.Text.RegularExpressions.Regex.Replace(meterToPipelineProgram, "%%TEMP_DIR%%", mTempDir);
            // This comes back UUENCODED, MF expects it as a hex literal 0x......
            // so we have unencode and convert.  Luckily we have a method to do that.
            string usethis = MetraTech.Utils.MSIXUtils.DecodeUIDAsString(batchid);
            usethis = "0x" + usethis;
            meterToPipelineProgram = System.Text.RegularExpressions.Regex.Replace(meterToPipelineProgram, "%%ID_BATCH%%", usethis);
            meterToPipelineProgram = System.Text.RegularExpressions.Regex.Replace(meterToPipelineProgram, "%%ID_PI%%", pitype.ID.ToString());
            meterToPipelineProgram = System.Text.RegularExpressions.Regex.Replace(meterToPipelineProgram, "%%PRODUCT_VIEW_NAME%%", pitype.ProductView);

            r = new MetraFlowRun();
            ret = r.Run(meterToPipelineProgram, "[RecurringChargeAdapter]", mMetraFlowConfig);
            if (ret != 0)
            {
              throw new ApplicationException("Recurring charge adapter charge cleanup failed.  Check log for details.");
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
              context.RecordInfo(string.Format("Waiting for sessions to commit (timeout = {0} seconds)", mCommitTimeout));
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
        }
      }

			context.RecordInfo("Invoking cleanup program ... ");
      string cleanupProgram = @"d1:sequential_file_delete[filename=""%%TEMP_DIR%%\flatrecurringcharge_load_%1%.mfd""];
      d2:sequential_file_delete[filename=""%%TEMP_DIR%%\rc_temp_%1%.mfd""];
      d3:sequential_file_delete[filename=""%%TEMP_DIR%%\rc_billing_intervals_%1%.mfd""];
      d4:sequential_file_delete[filename=""%%TEMP_DIR%%\rc_all_charges_%1%.mfd""];
      d5:sequential_file_delete[filename=""%%TEMP_DIR%%\rc_ready_to_rate_%1%.mfd""];";
      cleanupProgram = System.Text.RegularExpressions.Regex.Replace(cleanupProgram, "%%TEMP_DIR%%", mTempDir);
      
      r = new MetraFlowRun();
      ret = r.Run(cleanupProgram, "[RecurringChargeAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Recurring charge adapter charge cleanup failed.  Check log for details.");
      }

// 			context.RecordInfo("Invoking loader program ... ");
//       string loader = MetraTech.Dataflow.UsageLoader.GetLoaderScript(
//         mTempDir + "\\flatrecurringcharge_load_%1%.mfd", 
//         "metratech.com/flatrecurringcharge",
//         50000,
//         50000,
//         false);

//       r = new MetraFlowRun();
//       ret = r.Run(loader, "[RecurringChargeAdapter]", mMetraFlowConfig);
//       if (ret != 0)
//       {
//         throw new ApplicationException("Recurring charge adapter charge loader failed.  Check log for details.");
//       }

						
			return "";
		}

		public string Reverse(IRecurringEventRunContext context)
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
      if (null != doc.SingleNodeExists("/xmlconfig/TempDir"))
      {
        mTempDir = doc.GetNodeValueAsString("/xmlconfig/TempDir");
      }
      else
      {
        mTempDir = System.Environment.GetEnvironmentVariable("TEMP");
      }
      if (null != doc.SingleNodeExists("/xmlconfig/SortDir"))
      {
        mSortDir = doc.GetNodeValueAsString("/xmlconfig/SortDir");
      }
      else
      {
        mSortDir = System.Environment.GetEnvironmentVariable("TEMP");
      }
      mCommitTimeout = doc.GetNodeValueAsInt("xmlconfig/CommitTimeout", 3600);
      XmlNodeList nodeList = doc.SelectNodes("/xmlconfig/Rating");
      foreach (XmlNode templateNode in nodeList)
      {
        string piType = MTXmlDocument.GetNodeValueAsString(templateNode, "PriceableItemType");
        mRatingMetraFlowScripts.Add(piType, new System.Collections.Generic.List<MetraFlowScript> ());
        foreach(XmlNode scriptNode in templateNode.SelectNodes("Script"))
        {
          string name = MTXmlDocument.GetNodeValueAsString(scriptNode, "Name");
          string extension = MTXmlDocument.GetNodeValueAsString(scriptNode, "Extension");
          mRatingMetraFlowScripts[piType].Add(MetraFlowScript.GetExtensionScript(extension, name));
        }
      }
      
      mMetraFlowConfig = new MetraFlowConfig();
			mMetraFlowConfig.Load(configFile);
			return (true);
		}		
	}
}

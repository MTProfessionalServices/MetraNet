using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;



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
	/// Invoice Adapter, used to generate invoices at EOP.
	/// </summary>
	public class MetraFlowInvoiceAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
			private Logger mLogger = new Logger ("[InvoiceAdapter]");
      private string mTempDir;
      private MetraFlowConfig mMetraFlowConfig;
			private string mIsSample;
			private bool mConfigSample;
			private string mConfigFile;
		
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return false; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}
    public BillingGroupSupportType BillingGroupSupport { get	{ return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; }}
		
		public MetraFlowInvoiceAdapter()
		{
		}

	    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			bool status;

			mLogger.LogDebug("Initializing Invoice Adapter");
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
			mLogger.LogDebug("Executing Invoice Adapter");

			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", param.BillingGroupID);
			
			param.RecordInfo("Generating Invoice summaries ... ");

      // In the case of SQL check for the partitioning state.  We have generally seen
      // that we are best off forcing a table scan in SQL server.  To get the table
      // hint to work, we also have to specify the partition and avoid the view.
      // Really this kind of logic needs to be put into an operator that understands
      // partitioned tables.  Note that we need a generalization that can do the same for multiple
      // partitions (one at a time).
      string tableHint = "";
      string partitionPrefix = "";
      if(new ConnectionInfo("NetMeter").IsSqlServer)
      {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
          using(IMTStatement stmt = 
                conn.CreateStatement(string.Format("select partition_name from t_partition where id_interval_start <= {0} and id_interval_end >= {0}", param.UsageIntervalID)))
          {
            using(IMTDataReader reader = stmt.ExecuteReader())
            {
              if (reader.Read())
              {
                partitionPrefix = reader.GetString("partition_name");
                partitionPrefix += "..";
                tableHint = "with(index(pk_t_acc_usage))";
              }
            }
          }
        }
      }

      int ret = -1;

      MetraTech.Xml.MTXmlDocument doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoiceExtractAccUsage.xml");
      string extractProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      extractProgram = System.Text.RegularExpressions.Regex.Replace(extractProgram, "%%TEMP_DIR%%", mTempDir);
      extractProgram = System.Text.RegularExpressions.Regex.Replace(extractProgram, "%%SORT_DIR%%", mTempDir);
      extractProgram = System.Text.RegularExpressions.Regex.Replace(extractProgram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      extractProgram = System.Text.RegularExpressions.Regex.Replace(extractProgram, "%%PARTITION_PREFIX%%", partitionPrefix);
      extractProgram = System.Text.RegularExpressions.Regex.Replace(extractProgram, "%%USAGE_TABLE_HINT%%", tableHint);
      MetraFlowRun r = new MetraFlowRun();
      ret = r.Run(extractProgram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during usage extraction.  Check log for details.");
      }

      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoiceSummarizeContributions.xml");
      string summarizeProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      summarizeProgram = System.Text.RegularExpressions.Regex.Replace(summarizeProgram, "%%TEMP_DIR%%", mTempDir);
      summarizeProgram = System.Text.RegularExpressions.Regex.Replace(summarizeProgram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      summarizeProgram = System.Text.RegularExpressions.Regex.Replace(summarizeProgram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(summarizeProgram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during summary calculation.  Check log for details.");
      }

			param.RecordInfo("Generating Invoice records ... ");

      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoiceAccountInternal.xml");
      string myprogram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%TEMP_DIR%%", mTempDir);
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(myprogram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during invoice creation.  Check log for details.");
      }

      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoiceAccountUsageInterval.xml");
      myprogram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%TEMP_DIR%%", mTempDir);
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(myprogram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during invoice creation.  Check log for details.");
      }
      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoiceAccountMapper.xml");
      myprogram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%TEMP_DIR%%", mTempDir);
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(myprogram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during invoice creation.  Check log for details.");
      }
      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoicePaymentRedirection.xml");
      myprogram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%TEMP_DIR%%", mTempDir);
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      myprogram = System.Text.RegularExpressions.Regex.Replace(myprogram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(myprogram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during invoice creation.  Check log for details.");
      }

      doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile("MetraFlow\\ProductCatalog\\Scripts\\InvoiceCreateInvoiceRecords.xml");
      string createProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      createProgram = System.Text.RegularExpressions.Regex.Replace(createProgram, "%%TEMP_DIR%%", mTempDir);
      createProgram = System.Text.RegularExpressions.Regex.Replace(createProgram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      createProgram = System.Text.RegularExpressions.Regex.Replace(createProgram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(createProgram, "[InvoiceAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during invoice creation.  Check log for details.");
      }

      return "";
		}

        public string Reverse(IRecurringEventRunContext param)
        {
            string detail;

            mLogger.LogDebug("Reversing Involice Adapter");
            mLogger.LogDebug("Event type = {0}", param.EventType);
            mLogger.LogDebug("Run ID = {0}", param.RunID);
            mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
            mLogger.LogDebug("Billing Group ID = {0}", param.BillingGroupID);

            // need to execute the mtsp_BackoutInvoices stored procedure
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                //call the stored procedure used to delete invoices generated for
                //a particular interval
                mLogger.LogDebug("Calling Stored Procedure: mtsp_BackoutInvoices");
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("mtsp_BackoutInvoices"))
                {
                    stmt.AddParam("@id_billgroup", MTParameterType.Integer, param.BillingGroupID);
                    stmt.AddParam("@id_run", MTParameterType.Integer, param.RunID);
                    stmt.AddOutputParam("@num_invoices", MTParameterType.Integer);
                    stmt.AddOutputParam("@info_string", MTParameterType.WideString, 500);
                    stmt.AddOutputParam("@return_code", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    int returncode, num_invoices;
                    string info_string, msg;

                    returncode = (int)stmt.GetOutputValue("@return_code");
                    num_invoices = (int)stmt.GetOutputValue("@num_invoices");
                    info_string = DBUtil.IsNull(stmt.GetOutputValue("@info_string"), "");

                    if (info_string != "")
                        param.RecordWarning(info_string);

                    msg = String.Format(" '{0}' Invoices backed out.", num_invoices);
                    detail = msg;

                    if (-1 == returncode)
                        throw new Exception("Invoice Adapter backout failed!");
                }
            }

            return detail;
        }

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down Invoice Adapter");

		}
	
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
	
    public void SplitReverseState(int parentRunID, 
                                  int parentBillingGroupID,
                                  int childRunID, 
                                  int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of Invoice Adapter");
    }

		private bool ReadConfigFile(string configFile)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);  
			mTempDir = doc.GetNodeValueAsString("/xmlconfig/TempDir");
			mConfigSample = doc.GetNodeValueAsBool("/xmlconfig/IsSample");
			if (mConfigSample)
				mIsSample = "Y";
			else
				mIsSample = "N";
			mLogger.LogDebug("Is Sample: {0}", mIsSample);
      if (mConfigSample)
        throw new ApplicationException("MetraFlowInvoiceAdapter doesn't support sample invoices yet");
      mMetraFlowConfig = new MetraFlowConfig();
			mMetraFlowConfig.Load(configFile);
			return (true);
		}
		
	}

}

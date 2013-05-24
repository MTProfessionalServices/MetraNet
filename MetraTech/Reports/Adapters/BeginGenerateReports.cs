using System.Reflection;
using System.Runtime.InteropServices;

[assembly: GuidAttribute ("8d41e6db-1b12-4405-b35e-e8c3e3721fec")]

namespace MetraTech.Reports.Adapters
{
	using MetraTech.UsageServer;
	using MetraTech.DataAccess;
	using MetraTech;
	using MetraTech.Reports;
	using MetraTech.Xml;
	using MetraTech.Interop.MTAuth;
	using System.Diagnostics;
	using System;
	using System.Collections;
	using System.Data;
	using System.Net;
	using System.Text;
	using MetraTech.Interop.MTServerAccess;

	/// <summary>
	/// 
	/// </summary>
	public class BeginGenerateReports : IRecurringEventAdapter2
	{
		private Logger mLogger = new Logger(@"logging\Reporting", "[BeginGenerateReportsAdapter]");
		private string mEvent;
		private string mConfigFile;
		private string mGroupName;
		private string mCompleteAdapterName;
		private string mInitiatorAdapterName;
		private bool mbSampleMode;
		private bool mbCreateNewDatabaseEachTime;
		private BillingGroupSupportType mReportType;
		private bool mIsOracle;

		public BeginGenerateReports()
		{
			ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
			mIsOracle = (connInfo.DatabaseType == DBType.Oracle) ? true : false;
		}

		public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
		public bool HasBillingGroupConstraints { get { return false; } }
		public BillingGroupSupportType BillingGroupSupport { get { return mReportType; } }

		public void SplitReverseState(int parentRunID, 
									  int parentBillingGroupID,
									  int childRunID, 
									  int childBillingGroupID)
		{
			mLogger.LogDebug("Splitting reverse state of BeginGenerateReports Adapter");

			// Check if the initiator adapter has started but the completion adapter is not completed.
			// May not split while report processing is going on for current instance.
			Client client = new Client();
			if (!client.HasEventSucceeded(mCompleteAdapterName, parentBillingGroupID))
			{
				string error = string.Format("'{0}' adapter has started generating reports and may not be split until '{1}' adapter completes.",
											 mInitiatorAdapterName, mCompleteAdapterName);
				throw new ReportingException(error);
			}
			
			// The actual split will be done by the CompleteGenerateReport adapter.
		}

		public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			mEvent = eventName;
			mConfigFile = configFile;
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(mConfigFile);  
			mbSampleMode = doc.GetNodeValueAsBool("//SampleMode"); 
			mGroupName = doc.GetNodeValueAsString("//ReportGroupName"); 
			mCompleteAdapterName = doc.GetNodeValueAsString("//CompleteAdapterName"); 
			mInitiatorAdapterName = doc.GetNodeValueAsString("//InitiatorAdapterName"); 

			string ReportType = doc.GetNodeValueAsString("//ReportType");
			ReportType = ReportType.ToUpper();
			if (ReportType == "ACCOUNT")
				mReportType = BillingGroupSupportType.Account;
			else if (ReportType == "BILLINGGROUP")
				mReportType = BillingGroupSupportType.BillingGroup;
			else if (ReportType == "INTERVAL")
				mReportType = BillingGroupSupportType.Interval;
			else
				// Probably configured as a scheduled adapter.
				mReportType = BillingGroupSupportType.Interval;
		}

		private IReportManager mMgr = null;
		public string Execute(IRecurringEventRunContext aContext)
		{
			bool bAtLeastOneReport = false;
			mbCreateNewDatabaseEachTime = ReportConfiguration.GetInstance().GenerateDBEveryTime;

			if ((aContext.EventType == RecurringEventType.Scheduled) && mbCreateNewDatabaseEachTime)
			{
				aContext.RecordWarning("Unsupported configuration.  Cannot run this adapter in scheduled mode with the configuration setting of GenerateDBEveryTime");
				UnsupportedConfigurationException e = new UnsupportedConfigurationException("Scheduled mode with the configuration setting of GenerateDBEveryTime is not supported");
				throw e;
			}

			ArrayList expectedrecords = new ArrayList();
			int IntervalID = aContext.UsageIntervalID;
			int BillgroupID = aContext.BillingGroupID;
			int RunID = aContext.RunID;
			string detail = string.Format("Execute of adapter '{0}' succeeded.", mEvent);

			MTServerAccessDataSet serveraccess = new MTServerAccessDataSetClass();
			serveraccess.Initialize();
			MTServerAccessData db = serveraccess.FindAndReturnObject("ReportingDBServer");
			
			string apsname = ReportConfiguration.GetInstance().APSName;
			string apsuser = ReportConfiguration.GetInstance().APSUser;
			string apspassword = ReportConfiguration.GetInstance().APSPassword;
            // g. cieplik 8/25/2009 CORE-1472 
            string apsdatabasename = ReportConfiguration.GetInstance().APSDatabaseName;

			// Note that for Oracle it is important that the dbname is case sensitive
			// and is in upper case.
			string dbname = ReportConfiguration.GetInstance().GenerateDatabaseName(aContext).ToUpper();
			string dbservername = db.ServerName;

            // For Oracle the username and password are set to table space name.
            // If we are not generating a database each time we need to use the
            // configured username and password for oracle.
            // g. cieplik CR15147 when creating a new database use the password (db.Password) configured for "ReportingDBServer"
            string dbuser;
            string dbpassword;
            if (mIsOracle && mbCreateNewDatabaseEachTime == true)
            {
                dbuser = dbname;
                dbpassword = db.Password;
            }
            else
            {
                dbuser = db.UserName;
                dbpassword = db.Password;
            }

			IEnumerable reportdefs = ReportConfiguration.GetInstance().GetReportDefinitionListForGroup(aContext.EventType, mGroupName);
			
			//get provider specific Report Manager object
			using(IReportManager mgr = ReportConfiguration.GetInstance().GetReportManager())
			{
				mgr.LoggerObject = mLogger;
				mgr.RecurringEventRunContext = aContext;

				string mode = "Production";
				if (mbSampleMode)
					mode = "Sample";

				aContext.RecordInfo(string.Format("Adapter {0} is executing in {1} mode", mEvent, mode));

				// Login into reporting server
				mgr.LoginToReportingServer(apsname, apsuser, apspassword);

				// Set reporting database parameters
				// first we need to resolve an entry in case it was localhost or 127.0.0.1
				if(	string.Compare(dbservername, "localhost", true) == 0 ||
					string.Compare(dbservername, "127.0.0.1") == 0)
				{
					try
					{
						IPHostEntry hostentry = Dns.GetHostEntry(dbservername);
						dbservername = hostentry.HostName;
						aContext.RecordInfo(string.Format("ReportingDBServer server name was specified as localhost and was resolved to '{0}'", dbservername));
					}
					catch(Exception e)
					{
						aContext.RecordInfo(string.Format
							("ReportingDBServer server name was specified as localhost, but the system failed to resolve it: '{0}'", e.Message));
						throw e;
					}
				}

				// Set reporting database parameters
				aContext.RecordInfo(string.Format
					("Setting reporting database parameter: Server: {0}; Database Name: {1}.", dbservername, dbname));
			
				mgr.SetReportingDatabase(dbservername, dbname,
										 mIsOracle ? null : "dbo",	dbuser,	dbpassword);
										 // TODO: is db owner always dbo?

				// Iterate through report definition and execute InputQueries
				foreach(IReportDefinition def in reportdefs)
				{
					// Below parameters are same for ALL instances of a particular template
					string TemplateName =  def.UniqueName;
					string InputQuery = mbSampleMode ? def.SampleModeInputQuery : def.InputQuery;
					bool bOverwriteDestination = def.OverwriteReportTemplateDestination;
					bool bOverwriteFormat = def.OverwriteReportTemplateFormat;
					bool bOverwriteReportOriginalDataSource = def.OverwriteReportOriginalDataSource;
					int iExpectedInstances = 0;

					// Log
					string timeperiod = string.Empty;
					string adaptermode = string.Empty;
					if (aContext.EventType == RecurringEventType.EndOfPeriod)
					{
						adaptermode = "End Of Period";
						timeperiod = string.Format("Interval ID: {0}; BillingGroup ID: {1}", IntervalID, BillgroupID);
					}
					else
					{
						adaptermode = "Scheduled";
						timeperiod = string.Format("Start Date: {0}; End Date: {1}", aContext.StartDate, aContext.EndDate);
					}

					string msg = string.Format
						(@"Processing report template: '{0}'; Sample Mode: {1}; Report Group Name: {2}; USM execution mode: {3} ({4}); Run ID: {5}", 
						TemplateName, mbSampleMode, mGroupName, adaptermode, timeperiod, RunID);
					mLogger.LogInfo(msg);
					mLogger.LogInfo("Recording instance specific information:");
					mLogger.LogInfo("****************************************");
				
					using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
					{
						using(IMTAdapterStatement stmt = conn.CreateAdapterStatement(InputQuery))
                        {
						if (aContext.EventType == RecurringEventType.EndOfPeriod)
						{
							if (mReportType == BillingGroupSupportType.Account ||
								mReportType == BillingGroupSupportType.BillingGroup)
								stmt.AddParamIfFound("%%ID_BILLGROUP%%", aContext.BillingGroupID);
							else
								stmt.AddParamIfFound("%%ID_INTERVAL%%", IntervalID);
						}
						else
						{
							stmt.AddParamIfFound("%%STARTDATE%%", aContext.StartDate);
							stmt.AddParamIfFound("%%ENDDATE%%", aContext.EndDate);
						}

                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            // Initialize column metadata
                            Hashtable columns = CreateColumnMetaData(reader.GetSchema());
                            
                            while (reader.Read())
                            {
                                bAtLeastOneReport = true;

                                // Results of InputQuery execution constitute parameters
                                // that vary for every instance.
                                string InstanceFileName = string.Empty;
                                string InstanceRecordSelectionFormula = string.Empty;
                                string InstanceGroupSelectionFormula = string.Empty;
                                int AccountID = -1;

                                string columnname = string.Empty;
                                ArrayList ReservedColumnOrdinals = new ArrayList();
                                Hashtable InstanceParameters = new Hashtable();

                                if (mReportType == BillingGroupSupportType.Account)
                                {
                                    columnname = "AccountID".ToUpper();
                                    if (columns.Contains(columnname))
                                    {
                                        ReservedColumnOrdinals.Add(((Column)columns[columnname]).Ordinal);
                                        if (reader.IsDBNull(columnname) == false)
                                            AccountID = reader.GetInt32(columnname);
                                    }

                                    // Account ID must exist for Account level granularity.
                                    if (AccountID == -1)
                                        throw new ReportingException(string.Format(@"InputQuery execution result is missing AccountID column value."));
                                }
                                else if (mReportType == BillingGroupSupportType.BillingGroup &&
                                         BillgroupID == -1)
                                    throw new ReportingException(string.Format(@"Billing Group ID is not specified."));

                                columnname = "RecordSelectionFormula".ToUpper();
                                if (columns.Contains(columnname))
                                {
                                    ReservedColumnOrdinals.Add(((Column)columns[columnname]).Ordinal);
                                    if (reader.IsDBNull(columnname) == false)
                                        InstanceRecordSelectionFormula = reader.GetString(columnname);
                                }
                                columnname = "GroupSelectionFormula".ToUpper();
                                if (columns.Contains(columnname))
                                {
                                    ReservedColumnOrdinals.Add(((Column)columns[columnname]).Ordinal);

                                    if (reader.IsDBNull(columnname) == false)
                                        InstanceRecordSelectionFormula = reader.GetString(columnname);
                                }
                                columnname = "InstanceFileName".ToUpper();
                                string error = string.Format(@"'OverwriteReportTemplateDestination' flag is set to true, but " +
                                    "'InstanceFileName' column either does not exist or it is null.");

                                if (columns.Contains(columnname) == false)
                                {
                                    if (bOverwriteDestination)
                                    {
                                        throw new ReportingException(error);
                                    }
                                }
                                else
                                {
                                    if (bOverwriteDestination)
                                    {
                                        if (reader.IsDBNull(columnname) == true)
                                            throw new ReportingException(error);
                                    }
                                    else
                                    {
                                        mLogger.LogDebug(string.Format(@"Report {0} has 'OverwriteDestination'" +
                                            " flag set to false, 'InstanceFileName' will be ignored", TemplateName));
                                    }

                                    ReservedColumnOrdinals.Add(((Column)columns[columnname]).Ordinal);
                                    InstanceFileName = reader.GetString(columnname);

                                    // Prepend physical path for the virtual directory
                                    // or leave intact if this was a full path
                                    InstanceFileName = ReportConfiguration.GetInstance().GetReportInstanceFullPath(InstanceFileName);
                                }

                                //initialize report parameter collection. Report parameter is any column
                                //that comes back from InputQuery execution with name other than "RecordSelectionFormula",
                                //"GroupSelectionFormula", or "InstanceFileName"
                                foreach (Column column in columns.Values)
                                {
                                    string ColumnName = column.Name;
                                    if (ReservedColumnOrdinals.Contains(column.Ordinal) == false)
                                    {
                                        if (reader.IsDBNull(ColumnName) == false)
                                        {
                                            string up = ColumnName.ToUpper();
                                            InstanceParameters.Add(up, reader.GetValue(ColumnName));
                                        }
                                    }
                                }

                                // g. cieplik 8/25/2009 CORE-1472 add apsdatabasename which is overloaded with the SI_NAME
                                mgr.AddReportForProcessing
                                   (TemplateName,
                                    RunID,
                                    BillgroupID,
                                    AccountID,
                                    InstanceRecordSelectionFormula,
                                    InstanceGroupSelectionFormula,
                                    InstanceParameters,
                                    InstanceFileName,
                                    bOverwriteDestination,
                                    bOverwriteFormat,
                                    bOverwriteReportOriginalDataSource,
                                    apsdatabasename);

                                string detailmsg = string.Empty;
                                iExpectedInstances++;
                                detailmsg = string.Format(@"Instance {0}: Record Selection Formula: '{1}'; " +
                                    "Group Selection Formula: '{2}'; Instance Parameters: '{3}'; Instance File Name: '{4}';",
                                    iExpectedInstances, InstanceRecordSelectionFormula, InstanceGroupSelectionFormula,
                                    GenerateParameterString(InstanceParameters), InstanceFileName);
                                mLogger.LogInfo(detailmsg);

                                if (iExpectedInstances % 100 == 0)
                                    //System.Diagnostics.CounterSample c = new CounterSample(
                                    Console.Out.WriteLine(iExpectedInstances);

                            }//while Read()
                        }
							mLogger.LogInfo
								(string.Format("Number of expected instances of {0} template is {1}",TemplateName, iExpectedInstances));
							mLogger.LogInfo("****************************************");
                            
                            string log = string.Empty;
							if (iExpectedInstances == 0)
							{
								log = string.Format
									("Input query for template {0} returned no rows. No instances of template {0} will be generated!", TemplateName);
								aContext.RecordWarning(log);
							}
							else
							{
								log = string.Format
									("Registered {0} instances  of '{1}' template with report provider for processing.", iExpectedInstances, TemplateName);
								aContext.RecordInfo(log);
							}
						}

						//CR 11654: Do not insert a record if we don't expect any instances
						if (iExpectedInstances > 0)
						{
							expectedrecords.Add(new InsertRecord(RunID, BillgroupID, TemplateName, mEvent, iExpectedInstances));
						}
					}
				}//foreach reportdef
			
				//CR 11707: only call GenerateReports if there was at least one report
				if (bAtLeastOneReport)
				{
					string msg = string.Format
						("Signalling to report provider to start instance generation.");
					aContext.RecordInfo(msg);
					Console.Out.WriteLine(msg);
			
					mgr.GenerateReports(false);
					msg = "Done.";
					aContext.RecordInfo(msg);
					Console.Out.WriteLine(msg);
			
					InsertExpectedRecords(expectedrecords);
					mLogger.LogDebug(detail);
					aContext.RecordInfo("Finished scheduling reports.");
				}
				else
				{
					aContext.RecordInfo("No reports were found to be scheduled. Check report definition input queries.");
				}
				mgr.Disconnect();
			}//using
			
			return detail;
		}
		
		public string Reverse(IRecurringEventRunContext aContext)
		{
			string detail;
			int BillgroupID = aContext.BillingGroupID;

			string apsname = ReportConfiguration.GetInstance().APSName;
			string apsuser = ReportConfiguration.GetInstance().APSUser;
			string apspassword = ReportConfiguration.GetInstance().APSPassword;

			// Get provider specific Report Manager object
			mMgr = ReportConfiguration.GetInstance().GetReportManager();

			mMgr.LoggerObject = mLogger;
			mMgr.RecurringEventRunContext = aContext;

			string mode = "Production";
			if (mbSampleMode)
				mode = "Sample";

			aContext.RecordInfo(string.Format("Adapter is executing in {0} mode", mode));

			//login into reporting server
			aContext.RecordInfo(string.Format("Logging into reporting provider server. Provider: {0}, Machine: {1}, User: {2}.", mMgr.ProviderName, apsname, apsuser));
			mMgr.LoginToReportingServer(apsname, apsuser, apspassword);

            // Check if there is anything to revese. If t_report_instance_gen table is missing chances are
            // we are reversing because BeginGenerateReport failed to execute.
            if (DoesReportInstanceTableExist() == false)
            {
                detail = "There is nothing to reverse; t_report_instance_gen table is missing. Most likely cause is BeginGenerateReport failed.";
                mLogger.LogDebug(detail);
                aContext.RecordInfo(detail);
                return string.Format("Successfully reversed adapter.");
            }

			// Use the parent runid when running with Account type report.
			int ReportBillGroupID = BillgroupID;
			int RunToReverse = (mReportType == BillingGroupSupportType.Account)
							 ? GetReportRunID(aContext.RunIDToReverse, BillgroupID, out ReportBillGroupID)
							 : aContext.RunIDToReverse;

			//First get all the instances of all the templates based on RunID, which we are reversing and delete them.
			//Note: Some of them could be still in process or outstanding. 
			//TODO: Do we need to pause them first?
			ArrayList reports = GetRecordsForRun(aContext);
			foreach (ReportRecord rpt in reports)
			{
				string log = (mReportType == BillingGroupSupportType.Account)
						   ? string.Format("Deleting instances of '{0}' template, Account ID {1}", rpt.TemplateName, rpt.AccountID)
						   : string.Format("Deleting instances of '{0}' template", rpt.TemplateName);

				mLogger.LogDebug(log);
				aContext.RecordInfo(log);
				mMgr.DeleteReportInstances(rpt.TemplateName, RunToReverse, ReportBillGroupID, rpt.AccountID, InstanceExecutionStatus.All);
			}

			detail = string.Format("Deleting report instance generation table records for RunID {0}", RunToReverse);
			mLogger.LogDebug(detail);
			aContext.RecordInfo(detail);
			DeleteRecordsForRun(aContext.RunIDToReverse, BillgroupID);
			aContext.RecordInfo("Done.");
			detail = string.Format("Successfully reversed adapter.");
			return detail;
		}

		public void Shutdown()
		{
			if (mMgr != null)
			{
				mLogger.LogDebug(string.Format("Disconnecting from Reporting Provider {0}", mMgr.ProviderName));
				mMgr.Disconnect();
				mLogger.LogDebug(string.Format("Done."));
			}
		}
		
		public bool SupportsScheduledEvents
		{
			get
			{ return true; }
		}

		public bool SupportsEndOfPeriodEvents
		{
			get
			{ return true; }
		}

		public ReverseMode Reversibility
		{
			get
			{ return ReverseMode.Custom; }
		}

		public bool AllowMultipleInstances
		{
			get
			{ return true; }
		}

		private Hashtable CreateColumnMetaData(DataTable aDatatable)
		{
			Hashtable md = new Hashtable();
			foreach (DataRow row in aDatatable.Rows)
			{
				string columnName = (string) row["ColumnName"];
				int ordinal = (int) row["ColumnOrdinal"];
				System.Type dataType = (System.Type) row["DataType"];
				md.Add(columnName.ToUpper(), new Column(columnName, dataType, ordinal));
				
			}
			return md;
		}

		private void InsertExpectedRecords(IEnumerable aRecords)
		{
			CreateTableIfNeeded();
			IBulkInsert bulkInsert = new MetraTech.DataAccess.ArrayBulkInsert();

			ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
			bulkInsert.Connect(connInfo);
			using (bulkInsert)
			{
				bulkInsert.PrepareForInsert("t_report_instance_gen", 100);
				foreach(InsertRecord row in aRecords)
				{
					//n_initiator_adapter_runid; different on reverse split.
					bulkInsert.SetValue(1, MTParameterType.Integer, row.RunID);
					// n_initiator_adapter_billgrpid; different on reverse split.
					bulkInsert.SetValue(2, MTParameterType.Integer, row.BillingGroupID);
					//n_report_runid
					bulkInsert.SetValue(3, MTParameterType.Integer, row.RunID);
					//n_report_billgroupid
					bulkInsert.SetValue(4, MTParameterType.Integer, row.BillingGroupID);
					//tx_initiator_adapter_name
					bulkInsert.SetValue(5, MTParameterType.String, row.AdapterName);
					//tx_rpt_template_unique_name
					bulkInsert.SetValue(6, MTParameterType.String, row.TemplateName);
					//n_expected_instances
					bulkInsert.SetValue(7, MTParameterType.Integer, row.ExpectedInstances);
					//tx_status
					bulkInsert.SetValue(8, MTParameterType.String, "New");
					bulkInsert.AddBatch();
				}

				//TODO: handle more than 100 templates?
				bulkInsert.ExecuteBatch();
			}
		}

		private void CreateTableIfNeeded()
		{
			//__CREATE_T_REPORT_INSTANCE_GEN_IF_NEEDED__
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__CREATE_T_REPORT_INSTANCE_GEN_IF_NEEDED__"))
                {
                    stmt.ExecuteNonQuery();
                }
            }
		}

		private bool DoesReportInstanceTableExist()
		{
			//__CHECK_REPORT_INSTANCE_GEN_TABLE__
            bool bResult = false;
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__CHECK_REPORT_INSTANCE_GEN_TABLE__"))
                {
                    //stmt.ExecuteNonQuery(); -- TRW: Not sure why this was in here...
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int nValue = reader.GetInt32("TableFound");
                            bResult = nValue > 0 ? true : false;
                        }
                    }
                }
			}
            return bResult;
		}

        private void DeleteRecordsForRun(int aRunID, int aBillgroupID)
		{
			//__DELETE_EXPECTED_INSTANCES_RECORDS_FOR_RUN__
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__DELETE_EXPECTED_INSTANCES_RECORDS_FOR_RUN__"))
                {

                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillgroupID);
                    stmt.ExecuteNonQuery();
                }
            }
		}

		private int GetReportRunID(int aRunID, int aBillgroupID, out int aReportBillGroupID)
		{
			aReportBillGroupID = aBillgroupID;

			//__GET_REPORT_RUN_ID__
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__GET_REPORT_RUN_ID__"))
                {

                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillgroupID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader.IsDBNull("ParentBillGroupID") == false)
                                aReportBillGroupID = reader.GetInt32("ParentBillGroupID");

                            if (reader.IsDBNull("ParentRunID") == false)
                                return reader.GetInt32("ParentRunID");
                        }
                        else
                        {
                            return aBillgroupID;
                        }
                    }
                }
			}

			// Account ID must exist for Account level granularity.
			throw new ReportingException(string.Format(@"Failed to find parent run id for RunID: {0} BillGroup ID: {1}", aRunID, aBillgroupID));
		}

		private ArrayList GetRecordsForRun(IRecurringEventRunContext aContext)
		{
			ArrayList reports = new ArrayList();
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                if (mReportType == BillingGroupSupportType.Account)
                {
                    IEnumerable reportdefs = ReportConfiguration.GetInstance().GetReportDefinitionListForGroup
                        (aContext.EventType, mGroupName);

                    foreach (IReportDefinition def in reportdefs)
                    {
                        // Below parameters are same for ALL instances of a particular template
                        string sTemplateName = def.UniqueName;
                        string InputQuery = mbSampleMode ? def.SampleModeInputQuery : def.InputQuery;
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(InputQuery))
                        {
                            stmt.AddParamIfFound("%%ID_BILLGROUP%%", aContext.BillingGroupID);

                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    int AccountID = -1;
                                    if (reader.IsDBNull("AccountID") == false)
                                        AccountID = reader.GetInt32("AccountID");

                                    // Account ID must exist for Account level granularity.
                                    if (AccountID == -1)
                                        throw new ReportingException(string.Format(@"InputQuery execution result is missing AccountID column value."));

                                    reports.Add(new ReportRecord(AccountID, sTemplateName));
                                }
                            }
                        }
                    }
                }
                else
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                        (@"queries\ReportGenerationAdapters", "__GET_SCHEDULED_TEMPLATES__"))
                    {
                        stmt.AddParamIfFound("%%ID_BILLGROUP%%", aContext.BillingGroupID);
                        stmt.AddParamIfFound("%%ID_RUN%%", aContext.RunIDToReverse);

                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string sTemplateName = reader.GetString("TemplateName");
                                reports.Add(new ReportRecord(-1, sTemplateName));
                            }
                        }
                    }
                }
			}

			return reports;
		}

		private string GenerateParameterString(Hashtable aParams)
		{
			StringBuilder ret = new StringBuilder();
			foreach(object param in aParams.Keys)
			{
				ret.Append(string.Format("Name: {0}; Value: {1}; ", param, aParams[param]));
			}

			return ret.ToString();
		}
	}

	internal struct Column
	{
		public Column(string aName, Type aType, int aOrdinal)
		{
			mName = aName;
			mOrdinal = aOrdinal;
			mType = aType;
		}

		private string mName;
		public string Name { get{return mName;} set {mName = value;}}

		private int mOrdinal;
		public int Ordinal { get{return mOrdinal;} set {mOrdinal = value;}}

		private Type mType;
		public Type DataType { get{return mType;} set {mType = value;}}
	}

	internal struct InsertRecord
	{
		public InsertRecord(int aRunID, int aBillingGroupID, string aTemplateName, string aAdapterName, int aExpectedInstances)
		{
			mName = aTemplateName;
			mExpectedInstances = aExpectedInstances;
			mRunID = aRunID;
			mBillingGroupID = aBillingGroupID;
			mAdapterName = aAdapterName;
		}

		private string mName;
		public string TemplateName { get{return mName;} set {mName = value;}}

		private string mAdapterName;
		public string AdapterName { get{return mAdapterName;} set {mAdapterName = value;}}

		private int mExpectedInstances;
		public int ExpectedInstances { get{return mExpectedInstances;} set {mExpectedInstances = value;}}

		private int mRunID;
		public int RunID { get{return mRunID;} set {mRunID = value;}}

		private int mBillingGroupID;
		public int BillingGroupID { get{return mBillingGroupID;} set {mBillingGroupID = value;}}
	}

	internal struct ReportRecord
	{
		public ReportRecord(int aAccountID, string aTemplateName)
		{
			mAccountID = aAccountID;
			mTemplateName = aTemplateName;
		}

		private int mAccountID;
		public int AccountID { get{return mAccountID;} set {mAccountID = value;}}

		private string mTemplateName;
		public string TemplateName { get{return mTemplateName;} set {mTemplateName = value;}}
	}
}

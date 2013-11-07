namespace MetraTech.Reports.Adapters
{
	using MetraTech.UsageServer;
	using MetraTech.DataAccess;
	using MetraTech;
	using MetraTech.Reports;
	using MetraTech.Xml;
	using MetraTech.Interop.MTAuth;
	using RS = MetraTech.Interop.Rowset ;
	using System.Diagnostics;
	using System;
	using System.Threading;
	using System.Collections;
	using System.Reflection;
	using System.Data;
	using MetraTech.Interop.MTServerAccess;
	using System.Runtime.Remoting.Messaging;
	using System.Text;

	/// <summary>
	/// 
	/// </summary>
	public class CompleteGenerateReports : IRecurringEventAdapter2
	{
		private Logger mLogger = new Logger(@"logging\Reporting", "[CompleteGenerateReportsAdapter]");
		private string mEvent;
		private string mConfigFile;
		private int mbPeriodInSeconds;
		private int mbTimeoutInSeconds;
		private bool mbSampleMode;
		private Hashtable mExecutionResults;
		private string mGroupName;
		private string mInitiatorAdapterName;
		private BillingGroupSupportType mReportType;

		public CompleteGenerateReports()
		{
		}

		public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
		public bool HasBillingGroupConstraints { get { return false; } }
		public BillingGroupSupportType BillingGroupSupport { get { return mReportType; } }

		public void SplitReverseState(int parentRunID, 
									  int parentBillingGroupID,
									  int childRunID, 
									  int childBillingGroupID)
		{
			mLogger.LogDebug("Splitting reverse state of CompleteGenerateReports Adapter");
			
			//
			IEnumerable reportdefs = ReportConfiguration.GetInstance().GetReportDefinitionListForGroup
				(RecurringEventType.EndOfPeriod, mGroupName);

			//__SPLIT_BILLING_GROUP__
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                foreach (IReportDefinition def in reportdefs)
                {
                    // Determine the new expected number of instances.
                    int iExpectedInstances = 0;
                    using (IMTAdapterStatement stmtInput = conn.CreateAdapterStatement(mbSampleMode ? def.SampleModeInputQuery : def.InputQuery))
                    {
                        stmtInput.AddParamIfFound("%%ID_BILLGROUP%%", childBillingGroupID);
                        using (IMTDataReader reader = stmtInput.ExecuteReader())
                        {
                            // Initialize column metadata
                            while (reader.Read())
                                iExpectedInstances++;
                        }
                    }

                    // Update t_report_instance_gen table with split info.
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                        (@"queries\ReportGenerationAdapters", "__SPLIT_BILLING_GROUP__"))
                    {
                        stmt.AddParam("%%ID_RUN_PARENT%%", parentRunID);
                        stmt.AddParam("%%ID_BILLGROUP_PARENT%%", parentBillingGroupID);
                        stmt.AddParam("%%ID_RUN_CHILD%%", childRunID);
                        stmt.AddParam("%%ID_BILLGROUP_CHILD%%", childBillingGroupID);
                        stmt.AddParam("%%TEMPLATE_NAME%%", def.UniqueName);
                        stmt.AddParam("%%EXPECTED_INSTANCES%%", iExpectedInstances);
                        stmt.ExecuteNonQuery();
                    }
                }
			}
		}

		public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			mEvent = eventName;
			mConfigFile = configFile;
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(mConfigFile);  
			mGroupName = doc.GetNodeValueAsString("//ReportGroupName"); 
			mbSampleMode = doc.GetNodeValueAsBool("//SampleMode"); 
			mbPeriodInSeconds = doc.GetNodeValueAsInt("//PeriodInSeconds"); 
			mbTimeoutInSeconds = doc.GetNodeValueAsInt("//TimeoutInSeconds"); 
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
			if ((aContext.EventType == RecurringEventType.Scheduled) && ReportConfiguration.GetInstance().GenerateDBEveryTime)
			{
				aContext.RecordWarning("Unsupported configuration.  Cannot run this adapter in scheduled mode with the configuration setting of GenerateDBEveryTime");
				UnsupportedConfigurationException e = new UnsupportedConfigurationException("Scheduled mode with the configuration setting of GenerateDBEveryTime is not supported");
				throw (e);
			}

			mExecutionResults = new Hashtable();
			int NumTemplates = 0;
			
			StringBuilder detail = new StringBuilder();
			int BillgroupID = aContext.BillingGroupID;

			string apsname = ReportConfiguration.GetInstance().APSName;
			string apsuser = ReportConfiguration.GetInstance().APSUser;
			string apspassword = ReportConfiguration.GetInstance().APSPassword;
			string apsdatasource = ReportConfiguration.GetInstance().APSDataSource;

			//get provider specific Report Manager object
			IReportManager mMgr = ReportConfiguration.GetInstance().GetReportManager();

			//set our logger
			mMgr.LoggerObject = mLogger;
			mMgr.RecurringEventRunContext = aContext;

			string mode = "Production";
			if (mbSampleMode)
				mode = "Sample";

			aContext.RecordInfo(string.Format("Adapter '{0}' is executing in {1} mode", mEvent, mode));

            // Check if there is anything to revese. If t_report_instance_gen table is missing chances are
            // we are reversing because BeginGenerateReport failed to execute.
            if (DoesReportInstanceTableExist() == false)
            {
                string detail2 = "There is nothing wait for; t_report_instance_gen table is missing. Found 0 scheduled reports to wait for.";
                mLogger.LogDebug(detail2);
                aContext.RecordInfo(detail2);
                return detail2;
            }

			//login into reporting server
			mMgr.LoginToReportingServer(apsname, apsuser, apspassword, apsdatasource);

			aContext.RecordInfo(string.Format("Checking for new reports scheduled by '{0}' adapter", mInitiatorAdapterName));

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                string QueryTag = (mReportType == BillingGroupSupportType.Account ||
                                   mReportType == BillingGroupSupportType.BillingGroup)
                    ? "__GET_NEWLY_SCHEDULED_TEMPLATES_BY_BILLGROUP__"
                    : "__GET_NEWLY_SCHEDULED_TEMPLATES__";

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", QueryTag))
                {
                    stmt.AddParam("%%INITIATOR_NAME%%", mInitiatorAdapterName);

                    if (mReportType == BillingGroupSupportType.Account ||
                        mReportType == BillingGroupSupportType.BillingGroup)
                        stmt.AddParamIfFound("%%ID_BILLGROUP%%", BillgroupID);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int RunID = reader.GetInt32("RunID");
                            ReportGenerationResults temp = null;
                            string aTemplateName = reader.GetString("TemplateName");
                            int ExpectedInstances = reader.GetInt32("ExpectedInstances");

                            ReportGenerationWaiterDelegate worker = new ReportGenerationWaiterDelegate(DoReportGenerationWork);
                            IAsyncResult result = worker.BeginInvoke
                               (RunID,
                                BillgroupID,
                                mReportType,
                                aTemplateName,
                                ExpectedInstances,
                                ReportConfiguration.GetInstance().ReportFailureThreshold,
                                mbPeriodInSeconds,
                                mbTimeoutInSeconds,
                                mLogger,
                                mMgr,
                                ref temp,
                                new AsyncCallback(ReportGenerationResultsCallback),
                                DateTime.Now);

                            NumTemplates++;
                        }
                    }
                }
            }
			
			aContext.RecordInfo(string.Format
				("Found {0} scheduled reports to wait for.", NumTemplates));
			
			//now wait until the number of rows inserted into mExecutionResults
			//hash table is equal to the number of templates
			//TODO: Configurable SleepInterval?
			//TODO: Handle ThreadInterruptedException/ThreadAbortException?
			aContext.RecordInfo("Waiting for all workers to finish waiting for report generation completion.");
			
			int iterations = 0;
			while(mExecutionResults.Count != NumTemplates)
			{
				if(iterations++ % 10 == 0)
				{
					mLogger.LogInfo
						(string.Format("Waiting for all reporting templates to finish execution: Completed so far: {0}, Expected: {1}", mExecutionResults.Count, NumTemplates));
				}
				//wait 5 seconds
				Thread.Sleep(5000);
			}
			aContext.RecordInfo("All reports are completed.");
			mLogger.LogInfo("All reports are completed.");
			bool bAtLeastOneFailed = false;
				
			// Update records in RPC table to Completed
			UpdateRecordsToCompleted(mExecutionResults.Values, aContext.RunID, BillgroupID);

			foreach(ReportGenerationResults results in mExecutionResults.Values)
			{
				if(results.Succeeded == false)
				{
					detail.Append("\n");
					detail.Append(GenerateSummaryErrorMessage(results));
					bAtLeastOneFailed = true;
					if (results.FailureMessages != null)
					{
						aContext.RecordInfo(GenerateDetailsInfoHeader(results));
						RecordInfoBatch(aContext, (MetraTech.Interop.Rowset.IMTRowSet)results.FailureMessages);
					}
                    else if (results.ThrownException != null)
                    {
                        aContext.RecordInfo(GenerateDetailsInfoHeader(results));
                        string error = "Failed to wait for Crystal to complete: " + results.ThrownException.Message;
                        string LogError = "Failed to wait for Crystal to complete: " + results.ThrownException.ToString();
                        aContext.RecordInfo(error);
                        mLogger.LogDebug(LogError);
                    }
				}
			}

			if(bAtLeastOneFailed == false)
			{
				detail.Append(GenerateSummarySuccessMessage(mExecutionResults.Values));
				mLogger.LogDebug(detail.ToString());
				RecordInfoBatch(aContext, GenerateDetailSuccessMessages(mExecutionResults.Values));
				return detail.ToString();
			}
			else throw new ReportingException(detail.ToString());
		}

        private bool DoesReportInstanceTableExist()
        {
            //__CHECK_REPORT_INSTANCE_GEN_TABLE__
            bool bResult = false;
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__CHECK_REPORT_INSTANCE_GEN_TABLE__"))
                {
                    stmt.ExecuteNonQuery();
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

		private const int NVARCHAR_MAX = 4000;
		private void RecordInfoBatch(IRecurringEventRunContext ctx, 
									 MetraTech.Interop.Rowset.IMTRowSet aDetails)
		{
			if(aDetails.RecordCount > 0)
			{
				aDetails.MoveFirst();
				while(!Convert.ToBoolean(aDetails.EOF))
				{
					string details = (string) aDetails.get_Value(0);

					// truncates detail string if it is too long
					if (details.Length > NVARCHAR_MAX)
						details = details.Substring(0, NVARCHAR_MAX);
					ctx.RecordInfo(details);
					aDetails.MoveNext();
				}
			}
		}

		public string Reverse(IRecurringEventRunContext aContext)
		{
			int RunToReverse = aContext.RunIDToReverse;
			int BillgroupID = aContext.BillingGroupID;

			string sBillgroupInfo = string.Empty;
			if (mReportType != BillingGroupSupportType.Interval)
				sBillgroupInfo = string.Format(", BillingGroupID {0}", BillgroupID);

			string detail = string.Format("Reverse of adapter '{0}' succeeded for Run ID {1}{2}",
										  mEvent, RunToReverse, sBillgroupInfo);

			aContext.RecordInfo(string.Format("Reversing all the records for Run ID {0}{1} previousy marked as 'Completed' back to 'New'.",
								RunToReverse, sBillgroupInfo));

            // Check if there is anything to revese. If t_report_instance_gen table is missing chances are
            // we are reversing because BeginGenerateReport failed to execute.
            if (DoesReportInstanceTableExist() == false)
            {
                detail = "There is nothing wait for; t_report_instance_gen table is missing. Found 0 scheduled reports to wait for.";
                mLogger.LogDebug(detail);
                aContext.RecordInfo(detail);
            }
            else
            {
                MarkRecordsAsNew(RunToReverse, BillgroupID);
                aContext.RecordInfo("Done.");
            }
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
			{ return false; }
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

		private string GenerateSummaryErrorMessage(ReportGenerationResults results)
		{
			StringBuilder ret = new StringBuilder();
			ret.AppendFormat("Error summary for report '{0}': ", results.TemplateUniqueName);
			if(results.NoInstancesToWaitFor)
				ret.AppendFormat
					(@"There were no instances of {0} template and {1} run id found. " +
					"(Were they manually deleted from reporting server?)", 
					results.TemplateUniqueName, results.RunID); 
			else if(results.GaveUpDueToReachedTimeout)
				ret.AppendFormat("Timeout of {0} seconds has been reached waiting for report generation.", mbTimeoutInSeconds); 
			else if(results.FailedReportThresholdReached)
				ret.AppendFormat("Threshold of {0} instances has been reached, outstanding instances were paused.", results.FailedReportThreshold); 
			else if(results.ExpectedTotalInstancesNoMatch)
			{
				ret.AppendFormat(	"The number of expected instances in MetraNet does not match the number of total instances on Reporting server. "+
													"(MetraNet: {0}, Reporting Server: {1})", results.ExpectedInstances, results.TotalInstances); 
			}
			else 
			{
				Debug.Assert(results.ExpectedInstances == results.SucceededInstances + results.AtLeastFailedInstances);
				ret.AppendFormat("{0} instances out of {1} expected failed.", results.AtLeastFailedInstances, results.ExpectedInstances); 
			}
			ret.Append("\n");

			return ret.ToString();
		}

		private string GenerateSummarySuccessMessage(ICollection results)
		{
			StringBuilder ret = new StringBuilder();
			ret.AppendFormat("Adapter Execution Succeeded, {0} report templates processed.", results.Count);
			return ret.ToString();
		}

		private MetraTech.Interop.Rowset.IMTRowSet GenerateDetailSuccessMessages(ICollection resultcoll)
		{
			MetraTech.Interop.Rowset.IMTSQLRowset errorRs =
				(MetraTech.Interop.Rowset.IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();
			errorRs.InitDisconnected();
			errorRs.AddColumnDefinition("message","char",256);
			errorRs.OpenDisconnected();
			foreach(ReportGenerationResults results in resultcoll)
			{
				string msg = string.Format("'{0}': {1} out of {2} instances succeeded", 
					results.TemplateUniqueName, results.SucceededInstances, results.ExpectedInstances);
				errorRs.AddRow();
				errorRs.AddColumnData("message", msg);
			}

			return errorRs;
		}

		private string GenerateDetailsInfoHeader(ReportGenerationResults results)
		{
			return string.Format("Failure Details for '{0}':", results.TemplateUniqueName);
		}
		
		private delegate void ReportGenerationWaiterDelegate(
			int RunID,
			int BillgroupID,
			BillingGroupSupportType ReportType,
			string aTemplateUniqueName,
			int aExpectedInstances, 
			int aFailedReportThreshold, 
			int aPollingPeriodInSeconds,
			int aPollingTimeout, 
			Logger aLoggerObject,
			IReportManager aReportManagerObject, 
			ref ReportGenerationResults aExecutionResults);

		//[OneWayAttribute()]
		private void ReportGenerationResultsCallback(IAsyncResult ar)
		{
			string ExecutionStatus = string.Empty;
            bool bThreadResultSet = false;
			try
			{
				ReportGenerationWaiterDelegate waiter = (ReportGenerationWaiterDelegate)((AsyncResult)ar).AsyncDelegate;
				ReportGenerationResults results = null;
				Object state = new Object();
				waiter.EndInvoke(ref results, ar);
				mExecutionResults[results.TemplateUniqueName + results.RunID.ToString()] = results;
                bThreadResultSet = true;

				string ExtendedStatus = string.Empty;
				if (results.BillingGroupID != -1)
					ExtendedStatus = string.Format(", billing group id {0}", results.BillingGroupID);

				ExecutionStatus  = 
					string.Format(@"Execution of {0} template for run id {1}{2} completed: Total instances: {3}, " +
					"Succeeded Instances {4}, Failed Instances {5}",
					results.TemplateUniqueName, results.RunID, ExtendedStatus, results.ExpectedInstances, results.SucceededInstances,
					results.AtLeastFailedInstances);
				mLogger.LogDebug(ExecutionStatus);
			}
			catch(Exception e)
			{
                mLogger.LogError("ReportGenerationResultsCallback failed: " + e.ToString());
                if (!bThreadResultSet)
                    mLogger.LogError("Thread execution result not set.");
				throw;
			}
		}

		private void UpdateRecordsToCompleted(IEnumerable aResults, int aRunID, int BillgroupID)
		{
			//__UPDATE_RECORDS_TO_COMPLETED_FOR_ADAPTER__
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__UPDATE_RECORDS_TO_COMPLETED_FOR_ADAPTER__"))
                {
                    foreach (ReportGenerationResults results in aResults)
                    {
                        int iSucceededInstances = results.SucceededInstances;
                        int iFailedInstances = results.AtLeastFailedInstances;
                        string TemlateName = results.TemplateUniqueName;
                        bool ThresholdReached = results.FailedReportThresholdReached;
                        bool TimeoutReached = results.FailedReportThresholdReached;
                        stmt.AddParam("%%COMPLETOR_NAME%%", mEvent);
                        stmt.AddParam("%%COMPLETOR_ID_RUN%%", aRunID);
                        stmt.AddParam("%%NUM_SUCCEEDED_INSTANCES%%", iSucceededInstances);
                        stmt.AddParam("%%NUM_FAILED_INSTANCES%%", iFailedInstances);
                        stmt.AddParam("%%FAILED_THRESHOLD_REACHED%%", ThresholdReached ? "1" : "0");
                        stmt.AddParam("%%TIMEOUT_REACHED%%", TimeoutReached ? "1" : "0");
                        //where clause
                        stmt.AddParam("%%INITIATOR_NAME%%", mInitiatorAdapterName);
                        stmt.AddParam("%%TEMPLATE_NAME%%", TemlateName);
                        stmt.AddParam("%%ID_BILLGROUP%%", BillgroupID);
                        stmt.ExecuteNonQuery();
                        stmt.ClearQuery();
                        stmt.QueryTag = "__UPDATE_RECORDS_TO_COMPLETED_FOR_ADAPTER__";
                    }
                }
            }
		}

		private void DoReportGenerationWork(
						int RunID,
						int BillgroupID,
						BillingGroupSupportType ReportType,
						string aTemplateUniqueName,
						int aExpectedInstances, 
						int aFailedReportThreshold, 
						int aPollingPeriodInSeconds,
						int aPollingTimeout, 
						Logger aLoggerObject,
						IReportManager aReportManagerObject, 
						ref ReportGenerationResults aResults)
		{
            // Failed polling attempts counter.
            int nFailedCounter = 0;

			//some local variables to ensure interthread safety when incrementing
			//TotalSecondsWaited counter
            int TotalSecondsWaited = 0;
            int TempSecondsWaited, NextIncrementSecondsWaited;

			//Get report manager object. It's already OK. Adapter
			//logged in before
			//TODO: Do I need to check if logon hasn't expired?
			IReportManager mgr = aReportManagerObject;
			int FailedInstances = 0;
			int SucceededInstances = 0;
			int TotalInstances = 0;
			int OutstandingInstances = 0;

			//use this to fire off a progress
			//message every 10 waiting periods
			int iWaitedPeriods = 0;

			// Use the parent runid and billgroupid when running with Account type report.
			int ReportBillGroupID = BillgroupID;
			int ReportRunID = (ReportType == BillingGroupSupportType.Account) ? GetReportRunID(RunID, BillgroupID, out ReportBillGroupID) : RunID;

            //Poll for instance progress and then sleep for aPollingPeriodInSeconds
            //unless following conditions are met
            //1. aExpectedInstances = NumFailedInstances + NumSucceededInstances
            //2. NumFailedInstances = aFailedReportThreshold
            //3. aPollingTimeout is reached
            do
            {
                try
                {
                    TempSecondsWaited = TotalSecondsWaited;
                    NextIncrementSecondsWaited = TempSecondsWaited + aPollingPeriodInSeconds;

                    mgr.GetExecutionResults
                       (aTemplateUniqueName,
                        ReportRunID,
                        ReportBillGroupID,
                        out TotalInstances,
                        out FailedInstances,
                        out SucceededInstances,
                        out OutstandingInstances);

                    if (iWaitedPeriods % 10 == 0)
                    {
                        string progressmsg = string.Empty;
                        progressmsg = string.Format(@"'{0}' report generation progress: " +
                            "total expected instances: {1}; succeeded so far: {2}; failed so far: {3}; still outstanding: {4}.",
                            aTemplateUniqueName, TotalInstances, SucceededInstances, FailedInstances, OutstandingInstances);
                        mLogger.LogInfo(progressmsg);
                        mgr.RecurringEventRunContext.RecordInfo(progressmsg);
                    }

                    //CR11627: we don't want to wait until timeout is hit
                    //if someone manually deleted instances from APS box.
                    //This is a sub-case of CR 13286 fix below.
                    if (TotalInstances == 0)
                    {
                        aResults = new ReportGenerationResults
                            (aTemplateUniqueName, RunID, BillgroupID, aExpectedInstances,
                             aFailedReportThreshold,
                             FailedInstances, SucceededInstances,
                             true, false, false, false, TotalInstances, null, null);

                        return;
                    }

                    //CR 13286: If the number of expected instances (in t_report_instance_gen)
                    //does not match the number of total instances on the reporting server (someone manually tempered with Crystal Server)
                    //error out early
                    if (TotalInstances != aExpectedInstances)
                    {
                        aResults = new ReportGenerationResults
                            (aTemplateUniqueName, RunID, BillgroupID, aExpectedInstances,
                            aFailedReportThreshold,
                            FailedInstances, SucceededInstances,
                            false, false, false, true, TotalInstances, null, null);

                        return;
                    }

                    if (TotalInstances == FailedInstances + SucceededInstances)
                    {
                        RS.IMTRowSet errors = mgr.GetErrors(aTemplateUniqueName, ReportRunID, ReportBillGroupID);

                        aResults = new ReportGenerationResults
                            (aTemplateUniqueName, RunID, BillgroupID, aExpectedInstances,
                             aFailedReportThreshold,
                             FailedInstances, SucceededInstances,
                             false, false, false, false, TotalInstances, errors, null);

                        return;
                    }
                    else if (FailedInstances == aFailedReportThreshold)
                    {
                        RS.IMTRowSet errors = mgr.GetErrors(aTemplateUniqueName, ReportRunID, ReportBillGroupID);
                        mgr.ProcessReachedFailedReportThreshold(ReportRunID, ReportBillGroupID);

                        aResults = new ReportGenerationResults
                            (aTemplateUniqueName, RunID, BillgroupID, aExpectedInstances,
                             aFailedReportThreshold,
                             FailedInstances, SucceededInstances,
                             false, false, true, false, TotalInstances, errors, null);

                        return;
                    }
                    else
                    {
                        Thread.Sleep(1000 * aPollingPeriodInSeconds);
                        iWaitedPeriods++;

                        if (Interlocked.CompareExchange(ref TotalSecondsWaited, NextIncrementSecondsWaited, TempSecondsWaited) >= aPollingTimeout)
                        {
                            RS.IMTRowSet errors = mgr.GetErrors(aTemplateUniqueName, ReportRunID, ReportBillGroupID);

                            aResults = new ReportGenerationResults
                                (aTemplateUniqueName, RunID, BillgroupID, aExpectedInstances, aFailedReportThreshold,
                                 FailedInstances, SucceededInstances,
                                 false, true, false, false, TotalInstances, errors, null);

                            return;
                        }
                    }

                    // Reset the failed counter, since it looks like we connected.
                    nFailedCounter = 0;
                }
                catch (Exception ex)
                {
                    if (nFailedCounter == 0)
                    {
                        // Thread failed, must exit gracefully because main thread checks
                        // mExecutionResults.Count, which is update when thread exists gracefully.
                        aResults = new ReportGenerationResults
                            (aTemplateUniqueName, RunID, BillgroupID, aExpectedInstances, aFailedReportThreshold,
                             FailedInstances, SucceededInstances,
                             false, false, false, true, TotalInstances, null, ex);
                    }

                    // This may be due to a temporary loss of connectivity, try again...
                    // Example: hr == 0x80042A70, Error occurred while attempting to reconnect to APS,
                    //                            Unable to connect to cluster. Logon can not continue.
                    // Catch will retry upto 3 times with a 5 polling intervals wait in between.
                    Thread.Sleep(5 * 1000 * aPollingPeriodInSeconds);
                    if (++nFailedCounter > 3)
                    {
                        mLogger.LogError("Unable to reconnect with APS server after 3 attempts.");
                        return;
                    }
                    else
                        mLogger.LogWarning("Failed to poll APS server; trying again, attempt {0}", nFailedCounter);
                    // continue...
                }
            }
            while (true);
		}

		internal class ReportGenerationResults
		{
			internal ReportGenerationResults(
				string aTemplateUniqueName,
				int aUsageServerRunID,
				int aBillgroupID,	// -1 if not specified
				int aExpectedInstances, 
				int aThreshold, 
				int aAtLeastFailedInstances, 
				int aSucceededInstances, 
				bool aNoInstancesToWaitFor,
				bool aGaveUpDueToTimeout,
				bool aFailedReportThresholdReached,
				bool aExpectedAndTotalInstancesDontMatch,
				/* Below param is just for loggin purposes in case aExpectedAndTotalInstancesDontMatch == true*/
				int aTotalInstances,
				RS.IMTRowSet aFailureMessages,
                Exception aThrownException)
			{
				mTemplateUniqueName = aTemplateUniqueName;
				mRunID = aUsageServerRunID;
				mBillgroupID = aBillgroupID;
				mExpectedInstances = aExpectedInstances;
				mAtLeastFailedInstances = aAtLeastFailedInstances;
				mSucceededInstances = aSucceededInstances;
				mTimeoutReached = aGaveUpDueToTimeout;
				mThresholdReached = aFailedReportThresholdReached;
				mFailureMessages = aFailureMessages;
				mThreshold = aThreshold;
				mNoInstancesToWaitFor = aNoInstancesToWaitFor;
				mTotalInstances = aTotalInstances;
				mExpectedTotalInstancesNoMatch = aExpectedAndTotalInstancesDontMatch;
                mThrownException = aThrownException;
			}
			private string mTemplateUniqueName;
			internal string TemplateUniqueName {get {return mTemplateUniqueName;} set {mTemplateUniqueName = value;}}

			private int mRunID;
			internal int RunID {get {return mRunID;} set {mRunID = value;}}

			private int mExpectedInstances;
			internal int ExpectedInstances {get {return mExpectedInstances;} set {mExpectedInstances = value;}}

			private int mTotalInstances;
			internal int TotalInstances {get {return mTotalInstances;} set {mTotalInstances = value;}}

			private int mThreshold;
			internal int FailedReportThreshold {get {return mThreshold;} set {mThreshold = value;}}

			private int mAtLeastFailedInstances;
			internal int AtLeastFailedInstances {get {return mAtLeastFailedInstances;} set {mAtLeastFailedInstances = value;}}

			private int mSucceededInstances;
			internal int SucceededInstances {get {return mSucceededInstances;} set {mSucceededInstances = value;}}

			private RS.IMTRowSet mFailureMessages;
			internal RS.IMTRowSet FailureMessages {get {return mFailureMessages;} set {mFailureMessages = value;}}

			private bool mTimeoutReached;
			internal bool GaveUpDueToReachedTimeout {get {return mTimeoutReached;} set {mTimeoutReached = value;}}

			private bool mThresholdReached;
			internal bool FailedReportThresholdReached {get {return mThresholdReached;} set {mThresholdReached = value;}}

			private bool mNoInstancesToWaitFor;
			internal bool NoInstancesToWaitFor {get {return mNoInstancesToWaitFor;} set {mNoInstancesToWaitFor = value;}}

			private bool mExpectedTotalInstancesNoMatch;
			internal bool ExpectedTotalInstancesNoMatch {get {return mExpectedTotalInstancesNoMatch;} set {mExpectedTotalInstancesNoMatch = value;}}

            private Exception mThrownException;
            internal Exception ThrownException { get { return mThrownException; } set { mThrownException = value; } }

			internal bool Succeeded 
			{
				get 
				{
					return !NoInstancesToWaitFor && (mExpectedInstances == mSucceededInstances) && !ExpectedTotalInstancesNoMatch;
				}
			}

			private int mBillgroupID;
			internal int BillingGroupID {get {return mBillgroupID;} set {mBillgroupID = value;}}
		}

		private void MarkRecordsAsNew(int aRunID, int aBillgroupID)
		{
			//__MARK_RECORDS_AS_NEW__
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__MARK_RECORDS_AS_NEW__"))
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
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\ReportGenerationAdapters", "__GET_REPORT_RUN_ID__"))
                {

                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillgroupID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (reader.IsDBNull("ParentBillGroupID") == false)
                                aReportBillGroupID = reader.GetInt32("ParentBillGroupID");

                            if (reader.IsDBNull("ParentRunID") == false)
                                return reader.GetInt32("ParentRunID");
                        }
                    }
                }
            }

			// Account ID must exist for Account level granularity.
			throw new ReportingException(string.Format(@"Failed to find parent run id for RunID: {0} BillGroup ID: {1}", aRunID, aBillgroupID));
		}
	}
}

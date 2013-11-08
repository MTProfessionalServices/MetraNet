using System;
using System.Diagnostics;
using System.Collections;
using System.Threading;
using System.Runtime.InteropServices;
using MetraTech.Interop.Rowset;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using System.Net;

[assembly: GuidAttribute ("10db4d82-f401-4f8c-ac55-f9cd2a4999d6")]

namespace MetraTech.Reports.CrystalEnterprise
{
	using MetraTech.Reports;
	using MetraTech;
	using System.Diagnostics;

	using CrystalDecisions.Enterprise.Desktop;
	using CrystalDecisions.Enterprise;
	using CrystalDecisions.Enterprise.Dest;
	
	
	/// <summary>
	/// Provides Crystal Enterprise specific implementation of IReportManager interface
	/// </summary>
	[Guid("04452b1e-7ab3-4b70-9d48-9f64a4822b85")]
	[ClassInterface(ClassInterfaceType.None)]
	public class CEReportManager : IReportManager, IDisposable
	{
		public string ProviderName
		{
			get {return "Crystal Enterprise";}
		}
		//need to store EnterpriseSession and SessionManager objects as instance variables
		//because I need to call Dispose() on all of them in order to release the license.
		//There is no simple Logout() method
		private SessionMgr mMgr = null;
		private EnterpriseSession mES = null;
		private InfoStore mIS;
		private string mUserName = string.Empty;
		private string mPassword = string.Empty;
        private string mDataSource = string.Empty;

		private static string mToken = string.Empty;
		public void LoginToReportingServer(string aServerName, string aUserName, string aPassword, string aDataSource)
		{
			Debug.Assert(mLogger != null);
			mUserName = aUserName;
			mPassword = aPassword;
			mDataSource = aDataSource;
			RecordAndLogInfo
				(string.Format("Logging into reporting provider server. Provider: {0}, Machine: {1}, User: {2}.", ProviderName, aServerName, aUserName, aDataSource));

			try
			{
				if(mES != null)
				{
					RecordAndLogInfo
						("Attempting to re-use previous logon session.");
					InternalInit();
					RecordAndLogInfo
						("Previous logon session can be used again.");
				}
				else
				{
					RecordAndLogInfo
						("Creating new logon session.");
					InternalLogon(aServerName, aUserName, aPassword, aDataSource);
					RecordAndLogInfo
						("Successfully created new logon session.");
				}

			}
			catch(Exception)
			{
				DisposeOfCrystalObjects();
				GC.Collect();
				RecordAndLogInfo
					("Creating new logon session.");
				InternalLogon(aServerName, aUserName, aPassword, aDataSource);
				RecordAndLogInfo
					("Successfully created new logon session.");
			}
			
			//NOTE: We CAN NOT initialize InfoObjects collections for all templates at this time.
			//We have to have a collection with only one template for each template in order to schedule
			//them correctly. Available operations on InfoObjects collections are very limited.
			//In order to overcome Crystal API limitations, I maintain a hashtable mReportTemplates, where the key
			//is template name and the value is InfoObjects collection with only one object. This way if we schedule
			//1 template to run 100000 times, we don't need to query infostore every time.
			/*
			string query = @"Select * From CI_INFOOBJECTS Where " +
				"SI_PROGID = 'CrystalEnterprise.Report' "+
				"AND SI_INSTANCE=0 AND SI_PARENT_FOLDER = '" + GetMetraNetFolderID().ToString() + "'";

			mReportTemplateCollection = mIS.Query(query);
			*/
		}

		public void SetReportingDatabase(string aServerName, 
			string aDatabaseName, 
			string aDatabaseOwner,
			string aDatabaseUserName,
			string aDatabasePassword
			)
		{
			mReportingDatabaseServer = aServerName;
			mReportingDatabaseName = aDatabaseName;
			mReportingDatabaseOwner = aDatabaseOwner;
			mReportingDatabaseUserName = aDatabaseUserName;
			mReportingDatabasePassword = aDatabasePassword;
		}
		
		public void AddReportForProcessing(
			string aTemplateName,
			int aRunID,
			int aBillGroupID,
			int AccountID,
			string aRecordSelectionFormula, 
			string aGroupSelectionFormula, 
			IDictionary aReportParameters, 
			string aInstanceFileName,
			bool aOverwriteTemplateDestination, 
			bool aOverwriteTemplateFormat,
			bool aOverwriteTemplateOriginalDataSource,
            string apsdatabasename)
		{
			//see if this template is known to APS
			InfoObject CurrentReportTemplate = null;
            // g. cieplik CORE-1472 8/25/2009 apsdatabasename is overloaded with the si_name
            string mSINAME = apsdatabasename;
            InfoObjects coll = this.GetCollectionWithOneTemplate(aTemplateName,mSINAME);
			CurrentReportTemplate = coll[1];
			
			Debug.Assert(CurrentReportTemplate != null);
			Report ClonedReport = new Report(CurrentReportTemplate.PluginInterface);

			//Set database info
			SetReportDatabase(ClonedReport, aOverwriteTemplateOriginalDataSource);
			
			//set run id user defined property
			ClonedReport.Properties.Add("USAGE_SERVER_RUN_ID", aRunID);

			// Set billing group id; -1 if billing group id was not specified.
			ClonedReport.Properties.Add("USAGE_SERVER_BILLGROUP_ID", aBillGroupID);

			// Set account id; -1 if account id was not specified.
			ClonedReport.Properties.Add("USAGE_SERVER_ACCOUNT_ID", AccountID);
			
			//always run once and run right now
			SetRunOnceRightNow(ClonedReport);
			//set destination to unmanaged disk (if desired)
			
			if(aOverwriteTemplateDestination)
				this.SetDiskUnmanagedDestination(ClonedReport, aInstanceFileName);

			//set format to PDF (if desired)
			if(aOverwriteTemplateFormat)
				this.SetPDFFormat(ClonedReport);

			//set RecordSelectionFormula (if it's not empty)
			if(aRecordSelectionFormula.Length > 0)
				ClonedReport.RecordFormula = aRecordSelectionFormula;

			//set GroupSelectionFormula (if it's not empty)
			if(aGroupSelectionFormula.Length > 0)
				ClonedReport.GroupFormula = aGroupSelectionFormula;

			//set parameters
			SetReportParameters(ClonedReport, aReportParameters);
			
			//mAllInstances.Add(coll.Copy(coll[1], CeCopyObject.ceCopyNewObjectNewFiles));
			mIS.Schedule(coll);
			return;
		}
		public void GenerateReports(bool aSync)
		{
			ResumePausedInstances();
			return;
		}

		public void GetExecutionResults
			(string aTemplateName, int aRunID, int aBillGroupID, out int aNumTotalInstances, out int aNumFailedInstances, out int aNumSucceededInstances, out int aNumOutstandingInstances)
		{
			aNumFailedInstances = 0;
			aNumSucceededInstances = 0;
			aNumTotalInstances = 0;
			aNumOutstandingInstances = 0;
			
			Properties props = null;
			Property aggrcount = null;
			Properties props1 = null;
			Property siid = null;
			InfoObject countio = null;

			InfoObjects AllInstances = null;
			InfoObjects SucceededInstances = null;
			InfoObjects FailedInstances = null;
			InfoObjects PendingInstances = null;
			
			/*
			CeScheduleOutcome (SI_SCHEDULEINFO.SI_OUTCOME)
									Indicates the result of a job after it has finished processing.Constant  Value  Description  
									ceOutcomePending 0 The job has not yet returned from the Job Server.
									ceOutcomeSuccess 1 The job was scheduled successfully.
									ceOutcomeFailJobServerPlugin 2 An error occurred in the Job Server Plugin.
									ceOutcomeFailJobServer 3 An error occurred while processing a job on a job server.
									ceOutcomeFailSecurity 4 The user does not have enough rights to processes the job.
									ceOutcomeFailEndTime 5 The job's specified end time was exceeded.
									ceOutcomeFailSchedule 6 The scheduler caused the job to fail.
									ceOutcomeFailJobServerChild 7 The Job Server's child process is unresponsive.
			CeScheduleStatus (SI_SCHEDULE_STATUS)
									ceStatusRunning 0 The job is currently being processed by the job server.
									ceStatusSuccess 1 The job completed successfully.
									ceStatusFailure 3 The job failed. Use error message or outcome to get more information.
									ceStatusPaused  8 The job is paused. Even if all dependencies are satisfied, it will not run.
									ceStatusPending 9 The job has not started because dependencies are not satisfied. Dependencies include time constraints and events.
			CeScheduleFlags (SI_SCHEDULEINFO.SI_SCHEDULE_FLAGS)
								Used to change the status of an instance. 
								
									ceScheduleFlagResume 0 Instance processing is resumed.
									ceScheduleFlagPause  1 Instance processing is paused.
									
			SI_SCHEDULEINFO.SI_STATUSINFO - Error Message
			
			Example on how to get error message:
			Used to access the property from a query result:
			QueryResult.Item(Index).SchedulingInfo.ErrorMessage
			Remarks	
				You must query for both SI_STATUSINFO and 
				SI_OUTCOME Property before you can access the ErrorMessage property from the query result.

			SI_SCHEDULEINFO.SI_PROGRESS
			
			0 New
			1 Outstanding
			2 Running
			3 Complete
			
			SELECT 
			SI_STATUSINFO,
			SI_SCHEDULEINFO.SI_PROGRESS,
			SI_SCHEDULEINFO.SI_OUTCOME,
			SI_SCHEDULE_STATUS,
			SI_SCHEDULEINFO.SI_SCHEDULE_FLAGS
			FROM 
			CI_INFOOBJECTS 
			WHERE SI_NAME = 'Invoice Report' AND SI_INSTANCE = 1
			
			
			SI_OUTCOME:
			
			ceOutcomePending 0 The job has not yet returned from the Job Server.
 
			ceOutcomeSuccess 1 The job was scheduled successfully.
 
			ceOutcomeFailJobServerPlugin 2 An error occurred in the Job Server Plugin.
 
			ceOutcomeFailJobServer 3 An error occurred while processing a job on a job server.
 
			ceOutcomeFailSecurity 4 The user does not have enough rights to processes the job.

			ceOutcomeFailEndTime 5 The job's specified end time was exceeded.
 
			ceOutcomeFailSchedule 6 The scheduler caused the job to fail.
 
			ceOutcomeFailJobServerChild 7 The Job Server's child process is unresponsive
			*/
			try
			{
				string totalcountq = string.Empty;
				string failedcountq = string.Empty;
				string successcountq = string.Empty;
				string pendingcountq = string.Empty;

                using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                        (@"queries\CrystalEnterprise", "__GET_TOTAL_INSTANCE_COUNT__"))
                    {
                        stmt.AddParam("%%SI_NAME%%", aTemplateName);
                        stmt.AddParam("%%ID_RUN%%", aRunID);
                        stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);

                        totalcountq = stmt.Query;

                        stmt.ClearQuery();
                        stmt.QueryTag = "__GET_FAILED_INSTANCE_COUNT__";
                        stmt.AddParam("%%SI_NAME%%", aTemplateName);
                        stmt.AddParam("%%ID_RUN%%", aRunID);
                        stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                        failedcountq = stmt.Query;

                        stmt.ClearQuery();
                        stmt.QueryTag = "__GET_SUCCEDED_INSTANCE_COUNT__";
                        stmt.AddParam("%%SI_NAME%%", aTemplateName);
                        stmt.AddParam("%%ID_RUN%%", aRunID);
                        stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                        successcountq = stmt.Query;

                        stmt.ClearQuery();
                        stmt.QueryTag = "__GET_PENDING_INSTANCE_COUNT__";
                        stmt.AddParam("%%SI_NAME%%", aTemplateName);
                        stmt.AddParam("%%ID_RUN%%", aRunID);
                        stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                        pendingcountq = stmt.Query;
                    }
                }

				AllInstances = mIS.Query(totalcountq);
				SucceededInstances = mIS.Query(successcountq);
				FailedInstances = mIS.Query(failedcountq);
				PendingInstances = mIS.Query(pendingcountq);
			
				//Get the count of All instances.
				//If someone tempered with APS box, and deleted instances
				//manually, then there is nothing to wait for
				countio = AllInstances[1];
			
				props = countio.Properties;
				aggrcount = props["SI_AGGREGATE_COUNT"];
				props1 = aggrcount.Properties;
				siid = props1["SI_ID"];
			
				aNumTotalInstances = (int)siid.Value;
			
				if(aNumTotalInstances == 0)
				{
					//someone must have deleted instances from APS box manually
					return;
				}

				//Get the count of Succeeded instances.
			
				countio = SucceededInstances[1];
			
				props = countio.Properties;
				aggrcount = props["SI_AGGREGATE_COUNT"];
				props1 = aggrcount.Properties;
				siid = props1["SI_ID"];

				aNumSucceededInstances = (int)siid.Value;

				//Get the count of Succeeded instances.
			
				countio = FailedInstances[1];
			
				props = countio.Properties;
				aggrcount = props["SI_AGGREGATE_COUNT"];
				props1 = aggrcount.Properties;
				siid = props1["SI_ID"];

				aNumFailedInstances = (int)siid.Value;

			
				//Get the count of Pending instances.
				//this is done for logging purposes, 
				//and to also track the progress. If the number
				//of pending instances doesn't change for a long time
				//then something is wrong, and we need to gracefully
				//fail as opposed to timing out.

				countio = PendingInstances[1];
			
				props = countio.Properties;
				aggrcount = props["SI_AGGREGATE_COUNT"];
				props1 = aggrcount.Properties;
				siid = props1["SI_ID"];

				aNumOutstandingInstances = (int)siid.Value;
			}
			finally
			{
				if(props != null)
				{
					props.Dispose();
					props = null;
				}
				if(aggrcount != null)
				{
					aggrcount.Dispose();
					aggrcount = null;
				}
				if(props1 != null)
				{
					props1.Dispose();
					props1 = null;
				}
				if(siid != null)
				{
					siid.Dispose();
					siid = null;
				}
				if(countio != null)
				{
					countio.Dispose();
					countio = null;
				}
				if(AllInstances != null)
				{
					AllInstances.Dispose();
					AllInstances = null;
				}
				if(SucceededInstances != null)
				{
					SucceededInstances.Dispose();
					SucceededInstances = null;
				}
				if(FailedInstances != null)
				{
					FailedInstances.Dispose();
					FailedInstances = null;
				}
				if(PendingInstances != null)
				{
					PendingInstances.Dispose();
					PendingInstances = null;
				}
			}
			
			return;
		}

		public IMTRowSet GetErrors(string aTemplateName, int aRunID, int aBillGroupID)
		{
			string query = string.Empty;

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\CrystalEnterprise", "__GET_FAILED_INSTANCES__"))
                {
                    stmt.AddParam("%%SI_NAME%%", aTemplateName);
                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                    query = stmt.Query;
                }
            }

			InfoObjects FailedInstances = mIS.Query(query);
			IMTSQLRowset errorRs =
				(IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

			errorRs.InitDisconnected();
			errorRs.AddColumnDefinition("message","char",256);
			errorRs.OpenDisconnected();
			foreach(InfoObject io in FailedInstances)
			{
				string errmsg = io.SchedulingInfo.ErrorMessage;
				errorRs.AddRow();
				errorRs.AddColumnData("message", errmsg);
			}

			return errorRs;
		}

		public void DeleteReportInstances(string aTemplateName, int aRunID, int aBillGroupID, int aAccountID,
										  InstanceExecutionStatus aWhichOnesToDelete)
		{
			//pause them first
			if(ReportConfiguration.GetInstance().PauseReportsBeforeDelete == true)
			{
				PauseReportInstances(aTemplateName, aRunID, aBillGroupID, aAccountID);
			}

			//Get all the instances by template name and run id and delete them
			string query = string.Empty;
			bool bDestKnown = false;
			bool bDestUnmanagedDisk = false;

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\CrystalEnterprise", "__GET_ALL_INSTANCES__"))
                {
                    stmt.AddParam("%%SI_NAME%%", aTemplateName);
                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                    stmt.AddParam("%%ID_ACCOUNT%%", aAccountID);
                    query = stmt.Query;
                }
            }
			this.RecordAndLogInfo
				(string.Format("Retrieving all outstanding and completed report instances of Run ID: {0}, BillGroup ID: {1}, Account ID: {2}", aRunID, aBillGroupID, aAccountID));
			int runnningcount = 0;
			int curcount = 0;
			int totalcount = 0;
			bool first = true;
			ArrayList files = new ArrayList();
			do
			{
				InfoObjects AllInstances = mIS.Query(query);
				curcount = AllInstances.Count;
				runnningcount += curcount;
				totalcount = AllInstances.ResultCount;
				if(first)
				{
					this.RecordAndLogInfo
						(string.Format("{0} report instances will be deleted.", totalcount));
					first = false;
				}
				foreach(InfoObject io in AllInstances)
				{
					
					SchedulingInfo si = io.SchedulingInfo;
					Destination dest = si.Destination;
					if(bDestKnown == false)
					{
						if(!dest.Empty && string.Compare(dest.Name, "CrystalEnterprise.DiskUnmanaged",true) == 0)
							bDestUnmanagedDisk = true;
						else
							bDestUnmanagedDisk = false;
					}
					if(bDestUnmanagedDisk)
					{
						DiskUnmanaged du = new DiskUnmanaged(GetDiskUnmanagedPluginInfo().PluginInterface);
						dest.CopyToPlugin(du);
						DiskUnmanagedOptions duo = new DiskUnmanagedOptions(du.ScheduleOptions);
						foreach(object destfile in duo.DestinationFiles)
						{
							files.Add((string)destfile);
						}
					}
					AllInstances.Delete(string.Format("#{0}", io.ID));
				}
				mIS.Commit(AllInstances);
				this.RecordAndLogInfo
					(string.Format("Deleted {0} instances, {1} left.", 
					runnningcount, totalcount - curcount));
			}
			while(curcount < totalcount);
			RemoteReportOperations.DeleteUnmanagedDiskFiles(files, mContext);
		}

		public void PauseReportInstances(string aTemplateName, int aRunID, int aBillGroupID, int aAccountID)
		{
			//Get all the instances by template name and run id and delete them
			string query = string.Empty;

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\CrystalEnterprise", "__GET_NONPAUSED_INSTANCES__"))
                {
                    stmt.AddParam("%%SI_NAME%%", aTemplateName);
                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                    stmt.AddParam("%%ID_ACCOUNT%%", aAccountID);
                    query = stmt.Query;
                }
            }
			int runnningcount = 0;
			int curcount = 0;
			int totalcount = 0;
			bool first = true;
			do
			{
				InfoObjects AllInstances = mIS.Query(query);
				curcount = AllInstances.Count;
				runnningcount += curcount;
				totalcount = AllInstances.ResultCount;
				if(first)
				{
					this.RecordAndLogInfo
						(string.Format("{0} report instances will be paused.", totalcount));
					first = false;
				}
				
				foreach(InfoObject io in AllInstances)
				{
					SchedulingInfo si = io.SchedulingInfo;
					si.Flags = CeScheduleFlags.ceScheduleFlagPause;
					//si.Status = CeScheduleStatus.ceStatusPaused;
				}
				mIS.Commit(AllInstances);
				this.RecordAndLogInfo
					(string.Format("Paused {0} instances, {1} left.", 
					runnningcount, totalcount - curcount));
				
			}
			while(curcount < totalcount);
		}

		public void ProcessReachedFailedReportThreshold(int aRunID, int aBillGroupID)
		{
			int runnningcount = 0;
			int curcount = 0;
			int totalcount = 0;
			bool first = true;
			do
			{
				InfoObjects OutstandingInstances = GetOutstandingInstances(aRunID, aBillGroupID);
				curcount = OutstandingInstances.Count;
				runnningcount += curcount;
				totalcount = OutstandingInstances.ResultCount;
				if(first)
				{
					this.RecordAndLogInfo
						(string.Format("{0} outstanding report instances will be paused.", totalcount));
					first = false;
				}
				foreach(InfoObject io in OutstandingInstances)
				{
					io.SchedulingInfo.Flags = CeScheduleFlags.ceScheduleFlagPause;
				}

				mIS.Commit(OutstandingInstances);
				this.RecordAndLogInfo
					(string.Format("Paused {0} instances, {1} left.", 
					runnningcount, totalcount - curcount));
			}
			while(curcount < totalcount);
		
			return;
		}

		private void ResumePausedInstances()
		{
			int pause = ReportConfiguration.GetInstance().TriggerReportGenerationEventPause;
			Thread.Sleep(pause * 1000);
			InfoObjects events = GetUserEvents();
			Event userevent = new Event(events[1].PluginInterface);
			userevent.UserEvent.Trigger();
			mIS.Commit(events);
			return;
		}

		private InfoObjects GetOutstandingInstances(int aRunID, int aBillGroupID)
		{
			//Get the instances that are still outstanding and pause them
			string query = string.Empty;

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\CrystalEnterprise", "__GET_OUTSTANDING_OR_NEW_INSTANCES__"))
                {
                    stmt.AddParam("%%ID_RUN%%", aRunID);
                    stmt.AddParam("%%ID_BILLGROUP%%", aBillGroupID);
                    query = stmt.Query;
                }
            }

			return mIS.Query(query);
		}

		private InfoObjects GetUserEvents()
		{
			InfoObjects UserEvents = null;
		
			string query = string.Empty;

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                    (@"queries\CrystalEnterprise", "__GET_USEREVENT__"))
                {
                    query = stmt.Query;
                }
            }

			UserEvents = mIS.Query(query);
			
			if(UserEvents.Count == 0)
				throw new CrystalEnterpriseProviderException("'TriggerReportGeneration' user event object not found on Crystal Enterprise report server. Has reporting deployment hook been run?");

			if(UserEvents.Count > 1)
				throw new CrystalEnterpriseProviderException("There is more than 1 'TriggerReportGeneration' user event object found on Crystal Enterprise report server.");

			return UserEvents;
		}

		private int mUserEventID = -1;
		private int GetUserEventID()
		{
			if(mUserEventID < 0)
			{
				mUserEventID = GetUserEvents()[1].ID;
			}

			return mUserEventID;
		}



		
		public void Disconnect()
		{
			this.Dispose();
		}
		public void Dispose()
		{
			//DisposeOfCrystalObjects();
		}

		private void DisposeOfCrystalObjects()
		{
			if(mIS != null)
			{
				mIS.Dispose();
				mIS = null;
			}
			if(mES != null)
			{
				mES.Dispose();
				mES = null;
			}
			if(mMgr != null)
				mMgr.Dispose();

			GC.Collect();
			GC.Collect();
		}

		
		public ILogger LoggerObject
		{
			get{return mLogger;}
			set{mLogger = value;}
		}

		public IRecurringEventRunContext RecurringEventRunContext
		{
			get{return mContext;}
			set{mContext = value;}
		}

		private static int mMetraNetFolderID = -1;
        private int GetMetraNetFolderID(string mSIName)
		{
			if(mMetraNetFolderID < 0)
			{
				using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
				{
					IMTAdapterStatement stmt = conn.CreateAdapterStatement
						(@"queries\CrystalEnterprise", "__GET_METRANET_FOLDER_ID__");
                    // g. cieplik CORE-1472 8/25/2009 add a parameter for "si_name" 
                    stmt.AddParam("%%SI_NAME%%", mSIName);
					InfoObjects coll = mIS.Query(stmt.Query);
					if(coll.Count == 0)
                        throw new CrystalEnterpriseProviderException
                        (string.Format(" '{0}' folder not found on Crystal Enterprise report server. Has reporting deployment hook been run?", mSIName));                    
					mMetraNetFolderID =  coll[1].ID;
				}
			}
			return mMetraNetFolderID;
		}

		private Hashtable mReportTemplates = new Hashtable();
		private InfoObjects GetCollectionWithOneTemplate(string aTemplateName,string mSINAME)
		{
			string key = aTemplateName.ToUpper();
			if(mReportTemplates.ContainsKey(key) == true)
			{
				//CR 11618 fix: make sure that this object is still kosher
				//and underline COM object didn't get destroyed yet.
				try
				{
					InfoObject CurrentReportTemplate = ((InfoObjects)mReportTemplates[key])[1];
					Report rpt = new Report(CurrentReportTemplate.PluginInterface);
				}
				catch(Exception)
				{
					mReportTemplates.Remove(key);
				}
			}
			else
			{
                using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                        (@"queries\CrystalEnterprise", "__GET_REPORT_TEMPLATE__"))
                    {
                        // g. cieplik CORE-1472  8/25/2009 pass in the mSINAME to pull the template from the CrystalReport Repository 
                        stmt.AddParam("%%METRANET_FOLDER_ID%%", GetMetraNetFolderID(mSINAME).ToString());
                        stmt.AddParam("%%REPORT_TEMPLATE_NAME%%", aTemplateName);
                        InfoObjects coll = mIS.Query(stmt.Query);
                        if (coll.Count == 0)
                            throw new CrystalEnterpriseProviderException
                                (string.Format("Report template '{0}' not found on Crystal Enterprise report server. Has reporting deployment hook been run?", aTemplateName));
                        if (coll.Count > 1)
                            throw new CrystalEnterpriseProviderException
                                (string.Format("More than one report template with name '{0}' found on Crystal Enterprise report server.", aTemplateName));
                        mReportTemplates.Add(key, coll);
                    }
                }
			}
			return (InfoObjects)mReportTemplates[key];
		}

		private void SetReportDatabase(Report report, bool bOverwriteDefaultDataSource)
		{
			foreach(ReportLogon rptlogon in report.ReportLogons)
			{
				if(bOverwriteDefaultDataSource == false)
				{
					rptlogon.UseOriginalDataSource = true;
					rptlogon.UserName = mReportingDatabaseUserName;
					rptlogon.Password = mReportingDatabasePassword;
				}
				else
				{
					rptlogon.UseOriginalDataSource = false;

					//This approach doesn't work. Crystal is supposed to
					//send us workaround.
					//Worked after the patch was applied on a CE box.
					rptlogon.CustomServerName = mReportingDatabaseServer;
                    // g. cieplik CR15147; don't override "CustomDatabaseDLLName, it should already be set properly by crystal; "crdb_ado" for sql server / "crdb_oracle" for Oracle 
                    // rptlogon.CustomDatabaseDLLName = "crdb_ado.dll";
					rptlogon.CustomUserName = mReportingDatabaseUserName;
					rptlogon.CustomPassword = mReportingDatabasePassword;

					// Hack: We must not set CustomDatabaseName for Oracle. It so happens that
					// mReportingDatabaseOwner is either null or empty for Oracle.
					if (mReportingDatabaseOwner != null && mReportingDatabaseOwner.Length > 0)
						rptlogon.CustomDatabaseName = mReportingDatabaseName;

					foreach(TablePrefix prefix in rptlogon.TableLocationPrefixes)
					{
						if (mReportingDatabaseOwner != null && mReportingDatabaseOwner.Length > 0)
							prefix.MappedTablePrefix = string.Format("{0}.{1}.", mReportingDatabaseName, mReportingDatabaseOwner);
						else
							prefix.MappedTablePrefix = string.Format("{0}.", mReportingDatabaseName);
						
						prefix.UseMappedTablePrefix = true;
					}
				}
			}
		}

		private void SetDiskUnmanagedDestination(Report report, string aInstanceFileName)
		{
			SchedulingInfo si = report.SchedulingInfo;
			//set destination to unmanaged disk
			si.Destination.SetFromPlugin(CreateDiskDestination(aInstanceFileName));
		}
		
		private DiskUnmanaged CreateDiskDestination(string aFileName)
		{
			DiskUnmanaged disk = new DiskUnmanaged(GetDiskUnmanagedPluginInfo().PluginInterface);
			DiskUnmanagedOptions duo = new DiskUnmanagedOptions(disk.ScheduleOptions);

			foreach(string file in duo.DestinationFiles)
			{
				duo.DestinationFiles.Delete(file);
			}
			duo.DestinationFiles.Add(aFileName);

			//set user and password to logon to remote file system
			duo.UserName = mUserName;
			duo.Password = mPassword;
			
			return (DiskUnmanaged)disk;
		}

		private InfoObject GetDiskUnmanagedPluginInfo()
		{
			//TODO: Do I really need to run this query every time?
			//The issue with Crystal is open - seems like it's a bug on
			//the Crystal side. They are tracking it but it is very unlikely
			//that this will be fixed in 3.7 timeframe. So execute the damn query
			//every time
			InfoObjects plinfos = mIS.Query
				(string.Format("Select * From CI_SYSTEMOBJECTS Where SI_ID = {0}", GetDiskUnmanagedPluginInfoID()));
			//mDiskUnmanagedPluginInfo = plinfos[1];
			if(plinfos.Count == 0)
				//shouldn't really happen, but it's better to explain where we failed
				//than return a generic "Item 1 not found".
				throw new CrystalEnterpriseProviderException
					(@"'CrystalEnterprise.DiskUnmanaged' object either does not exist in CI_SYSTEMOBJECTS or it has SI_PARENTID other than 29." +
					"Something must be seriously wrong with Crystal Enterprise server installation. Refer to Crystal Enterprise installation notes.");
			return plinfos[1];
		}

		private int mDiskUnmanagedID = -1;
		private int GetDiskUnmanagedPluginInfoID()
		{
			//TODO: Do I really need to run this query every time?
			//The issue with Crystal is open - seems like it's a bug on
			//the Crystal side. They are tracking it but it is very unlikely
			//that this will be fixed in 3.7 timeframe. So execute the damn query
			//every time
			if(mDiskUnmanagedID < 0)
			{
				InfoObjects plinfos = mIS.Query
					("Select SI_ID From CI_SYSTEMOBJECTS Where SI_PARENTID=29 and SI_NAME='CrystalEnterprise.DiskUnmanaged'");
				//mDiskUnmanagedPluginInfo = plinfos[1];
				if(plinfos.Count == 0)
					//shouldn't really happen, but it's better to explain where we failed
					//than return a generic "Item 1 not found".
					throw new CrystalEnterpriseProviderException
						(@"'CrystalEnterprise.DiskUnmanaged' object either does not exist in CI_SYSTEMOBJECTS or it has SI_PARENTID other than 29." +
						"Something must be seriously wrong with Crystal Enterprise server installation. Refer to Crystal Enterprise installation notes.");
				PluginInterface plinter = plinfos[1].PluginInterface;
				mDiskUnmanagedID = plinfos[1].ID;
			}
			return mDiskUnmanagedID;
		}



		private void SetPDFFormat(Report report)
		{
			SchedulingInfo si = report.SchedulingInfo;
			ReportFormatOptions fo = report.ReportFormatOptions;
			fo.Format = CeReportFormat.ceFormatPDF;
		}

		private void SetRunOnceRightNow(Report report)
		{
				SchedulingInfo si = report.SchedulingInfo;
				si.Flags = CeScheduleFlags.ceScheduleFlagResume;
				si.RightNow = true;
				if(si.Dependencies.Count == 0)
					si.Dependencies.Add(GetUserEventID());            
				si.Type = CeScheduleType.ceScheduleTypeOnce;
		}
		private void SetReportParameters(Report report, IDictionary aParams)
		{
			//todo: do some validation based on ceReportVariableValueType (param.ValueType)
			foreach(ReportParameter param in report.ReportParameters)
			{
				string paramname = param.ParameterName.ToUpper();
				if(aParams.Contains(paramname))
				{
					CeReportVariableValueType valtype = param.ValueType;
					if(param.SupportsRangeValues)
					{
						//TODO: return error
					}
					param.CurrentValues.Clear();
					ReportParameterSingleValue sv = param.CreateSingleValue();
					sv.Value = ConvertType(valtype, aParams[paramname]);
					param.CurrentValues.Add(sv);
				}
				else
				{
					//TODO: set default value
				}
			}
		}

		private string ConvertType(CeReportVariableValueType aCrystalType, object aValue)
		{
			try
			{
				switch(aCrystalType)
				{
					//for boolean use MTXml for conversion
					case CeReportVariableValueType.ceRVBoolean:
					{
						return System.Convert.ToBoolean(MTXmlDocument.ToBool(aValue)).ToString();
					}
					case CeReportVariableValueType.ceRVString:
						return aValue.ToString();
					case CeReportVariableValueType.ceRVNumber:
						return System.Convert.ToDecimal(aValue).ToString();
					default:
					{
						mLogger.LogWarning(string.Format(@"MetraNet Crystal Enterprise Engine: Parameters of type '{0}'"+
															" are not supported", aCrystalType.ToString()));
						return string.Empty;
					}
				}
			}
			catch(Exception e)
			{
				mLogger.LogError(string.Format(@"MetraNet Crystal Enterprise Engine: Parameter specified in InputQuery"+
					" could not be converted to the corresponding Crystal Type '{0}': {1}", aCrystalType.ToString(), e.Message));
				throw;
			}
		}
		private void RecordAndLogInfo(string message)
		{
			if(mLogger != null)
				mLogger.LogInfo(message);
			if(mContext != null)
				mContext.RecordInfo(message);
		}

		private void RecordAndLogWarning(string message)
		{
			if(mLogger != null)
				mLogger.LogWarning(message);
			if(mContext != null)
				mContext.RecordWarning(message);
		}

		private void InternalLogon(string aServerName, string aUserName, string aPassword, string aDataSource)
		{
			mMgr = new SessionMgr();
			//APS runs at port 6400
			if(mToken.Length == 0)
			{
				mES = mMgr.Logon(aUserName, aPassword, aServerName, aDataSource);
				mToken = mES.LogonTokenMgr.CreateLogonTokenEx(Dns.GetHostName(),/*local machine*/
					60/*valid for 1 hour*/,
					100/*max logons*/);
			}
			else
			{
				try
				{
					mES = mMgr.LogonWithToken(mToken);
				}
				catch(Exception e)
				{
					mLogger.LogDebug
						(string.Format("Could not logon to Crystal provider using logon token: '{0}', attempting regular logon.", e.Message));
					try
					{
						mES = mMgr.Logon(aUserName, aPassword, aServerName, aDataSource);
					}
					catch(Exception)
					{
						GC.Collect();
						mES = mMgr.Logon(aUserName, aPassword, aServerName, aDataSource);
					}
				}
			}
			InternalInit();
		}

		private void InternalInit()
		{
			//ATTENTION!!!! GetService call would block forever if InfoStore object was already created and cached.
			//TODO: For now check for null... but how long can we keep InfoStore service around?
			if(mIS == null)
			{
				EnterpriseService eser = mES.GetService("", "InfoStore");
				mIS = (InfoStore)eser;
			}
			//test the fact that InfoStore is still usable
			InfoObjects test = mIS.Query("SELECT COUNT(SI_ID) FROM CI_INFOOBJECTS WHERE SI_INSTANCE = 0 AND SI_NAME = 'Invoice Report'");
		}
		
		private ILogger mLogger = null;
		private IRecurringEventRunContext mContext = null;

		private string mReportingDatabaseServer;
		private string mReportingDatabaseName;
		private string mReportingDatabaseOwner;
		private string mReportingDatabaseUserName;
		private string mReportingDatabasePassword;
	}
}
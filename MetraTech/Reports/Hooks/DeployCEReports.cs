using System;
using System.Threading;
using System.Collections;
using System.Xml;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.Interop.MTHooklib;
using MetraTech.Interop.RCD;
using MetraTech.Reports;
using MetraTech.DataAccess;
using MetraTech.Interop.MTServerAccess;

//crystal namespaces
using CrystalDecisions.Enterprise.Desktop;
using CrystalDecisions.Enterprise.Admin;
using CrystalDecisions.Enterprise;
using CrystalDecisions.Enterprise.Dest;

 [assembly: GuidAttribute ("150c9f5c-f3be-4f88-be60-b4496ba160dc")]

namespace MetraTech.Reports.Hooks
{
	/// <summary>
	/// Summary description for DeployCEReportsHook.
	/// </summary>
	/// 
	[Guid("c70e1a29-4396-4ee4-9ded-279e08cbb755")]
	[ClassInterface(ClassInterfaceType.None)]
	public class DeployCEReports : IMTHook
	{
		public DeployCEReports()
		{
			mLog = new Logger("[DeployCEReportsHook]");
			mRcd = new MTRcdClass();
			mRcd.Init();
		}


		
		SessionMgr mgr = null;
		EnterpriseSession es = null;
		InfoStore instore = null;
		EnterpriseService eser = null;
		InfoObjects coll = null;
		Properties properties = null;
		InfoObjects events = null;
        // g. cieplik CORE-1472 use to set the title of the CrystalReport Repository 
        private string mSIName;
	
		public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
		{
			try
			{
				//1.Get APS logon parameters from servers.xml
				MTServerAccessDataSet serveraccess = new MTServerAccessDataSetClass();
				serveraccess.Initialize();
				MTServerAccessData Aps = serveraccess.FindAndReturnObjectIfExists("APSServer");
				if(Aps == null)
				{
					mLog.LogInfo("'APSServer' data access set is not found. Reporting hook will not be run.");
					return;
				}

				string apsname = Aps.ServerName;
				string apsuser = Aps.UserName;
				string apspassword = Aps.Password;
                // g. cieplik CORE-1472 get the apsDatabaseName, its overloaded with the SINAME
                mSIName = Aps.DatabaseName;

				try
				{
					mgr = new SessionMgr();
				}
				catch(Exception e)
				{
					string msg = 
						string.Format
						("\nFailed trying to create CrystalEnterprise provider objects: '{0}'"+
						"\nTwo most common reasons are:"+
						"\n1. A user chose to install reporting extension without first installing Crystal Enterprise SDK (please read installation notes)."+
						"\n2. A user doesn't want reporting extension to be installed, but the system found 'APSServer' entry in one of the servers.xml files, possibly left "+
						"from previous installations.", e.Message);
					throw new ReportingException(msg);
				}
				//using(SessionMgr mgr = new SessionMgr())
				//{
					mLog.LogInfo
						(string.Format("Logging into reporting provider server. Machine: {0}, User: {1}.", apsname, apsuser));
					
				
					//APS runs at port 6400
					try
					{
						es = mgr.Logon(apsuser, apspassword, apsname, "secWindowsNT");
						//es = mgr.Logon("administrator", "", apsname, "secEnterprise");
					}
					catch(Exception)
					{
						try
						{
							GC.Collect();
							es = mgr.Logon(apsuser, apspassword, apsname, "secWindowsNT");
						}
						catch(Exception e)
						{
              string msg = string.Format(@"Failed to log into Crystal APS server using specified connection parameters. "+
								"Is Crystal Enterprise installed? Internal Exception: <{0}>; DeployCEReportsHook will now exit.", e.Message);
							mLog.LogError(msg);
							Thread.Sleep(1000);
							throw new ReportingException(msg);
						}
					}
				//}
				eser = es.GetService("", "InfoStore");
				instore = (InfoStore)eser;

				//TriggerEvent(instore);
				//see if MetraNet folder already exists
				
				//Looking for top level folder called MetraNet
				string folderquery = string.Empty;
				string eventquery = string.Empty;
                using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
                        (@"queries\CrystalEnterprise", "__GET_METRANET_FOLDER__"))
                    {
                        // g. cieplik CORE-1472 8/25/2009 add a parameter for "si_name" 
                        stmt.AddParam("%%SI_NAME%%", mSIName);
                        folderquery = stmt.Query;
                        stmt.ClearQuery();
                        stmt.QueryTag = "__GET_USEREVENT__";
                        eventquery = stmt.Query;
                    }
                }
				//see if TriggerReportGeneration event is already there
				events = instore.Query(eventquery);
				if(events.Count == 0)
				{
					CreateUserReportGenerationEvent();
				}
				coll = instore.Query(folderquery);

				if(coll.Count == 0)
				{
					CreateReportObjects();
				}
				else
				{
					InfoObject temp = coll[1];
					properties = temp.Properties;
					Property property = properties["SI_ID"];
					int i = (int)property.Value;
					UpdateReportObjects(i);
					temp.Dispose();
					temp = null;
					property.Dispose();
					property = null;
				}
			}
			catch(System.Exception ex)	
			{
				mLog.LogError(ex.ToString());
				throw;
			}
			finally
			{
				if(events != null)
				{
					events.Dispose();
					events = null;
				}

				if(properties != null)
				{
					properties.Dispose();
					properties = null;
				}

				if(mgr != null)
				{
					mgr.Dispose();
					mgr = null;
				}

				if(coll != null) 
				{
					coll.Dispose();
					coll = null;
				}
				
				if(es != null) 
				{
					es.Dispose();
					es = null;
				}
				
				if(instore != null) 
				{
					instore.Dispose();
					instore = null;
				}
				

				GC.Collect();
				//GC.WaitForPendingFinalizers();
			
			}
		}

		private void CreateUserReportGenerationEvent()
		{
			Event userevent = null;
			InfoObjects events = null;
			Event obj = null;
			PluginManager pm = null;
			PluginInfo pi = null;
			try
			{
				mLog.LogDebug("Creating TriggerReportGeneration User Event");
				events = instore.NewInfoObjectCollection();
				pm = instore.PluginManager;
				pi = pm.GetPluginInfo("CrystalEnterprise.Event");

				obj = (Event)events.Add(pi);
				//obj = new Event(pi.PluginInterface);

				//Event userevent = (Event)events.Add(pi);
				obj.Title = "TriggerReportGeneration";
				obj.Description = "Signal to APS to start report generation. Used by BeginGenerateReports adapter";
				obj.EventType = CeEventType.ceUser;
				instore.Commit(events);
				mLog.LogDebug("Done Creating User Event.");
			}
			finally
			{
				if(userevent != null)
				{
					userevent.Dispose();
					userevent = null;
				}
				if(events != null)
				{
					events.Dispose();
					events = null;
				}
				if(obj != null)
				{
					obj.Dispose();
					obj = null;
				}
				if(pi != null)
				{
					pi.Dispose();
					pi = null;
				}
				if(pm != null)
				{
					pm.Dispose();
					pm = null;
				}

			}
		}

		
		private void CreateReportObjects()
		{
			//Create top level MetraNet folder
			mLog.LogDebug("Creating top level MetraNet folder in APS InfoStore");
			PluginManager pm = instore.PluginManager;
			PluginInfo pi = pm.GetPluginInfo("CrystalEnterprise.Folder");

			//1. Create MetraNet folder
			InfoObjects folders = instore.NewInfoObjectCollection();
			folders.Add(pi);
			Folder mtfolder = (Folder)folders[1];
            // g. cieplik CORE-1472 set the title of the CrystalReport Repository 
            mtfolder.Title = mSIName;
			mtfolder.Description = "MetraNet Info Objects Collection";
			//Do not commit collection until everything else succeeds;
			

			//get all EOP and scheduled reports and install them under MetraNet folder
			IEnumerable eopreports = ReportConfiguration.GetInstance().AllEOPReports;
			IEnumerable scheduledreports = ReportConfiguration.GetInstance().AllScheduledReports;
			

			int count = 0;
			InfoObjects rptcoll = instore.NewInfoObjectCollection();
			foreach(IReportDefinition rptdef in eopreports)
			{
				count++;
				PluginInfo rptpi = pm.GetPluginInfo("CrystalEnterprise.Report");
				Report rpt = (Report)rptcoll.Add(rptpi);
				string srcFileName = string.Format(@"{0}\{1}", mRcd.ExtensionDir, rptdef.SourceFile);
				rpt.Files.Add(srcFileName);
				rpt.Description = rptdef.DisplayName;
				rpt.Properties.Add ("SI_PARENTID", mtfolder.ID);
				rpt.Properties.Add ("SI_NAME", rptdef.UniqueName);
				//TODO; stick local file name somewhere so that ie appears in APS and doesn't confuse an SI

			}
			mLog.LogDebug(string.Format("Added {0} EOP reports to APS InfoStore", count));
			
			count = 0;
			foreach(IReportDefinition rptdef in scheduledreports)
			{
				count++;
				PluginInfo rptpi = pm.GetPluginInfo("CrystalEnterprise.Report");
				Report rpt = (Report)rptcoll.Add(rptpi);
				string srcFileName = string.Format(@"{0}\{1}", mRcd.ExtensionDir, rptdef.SourceFile);
				rpt.Files.Add(srcFileName);
				rpt.Description = rptdef.DisplayName;
				rpt.Properties.Add ("SI_PARENTID", mtfolder.ID);
				rpt.Properties.Add ("SI_NAME", rptdef.UniqueName);
				//TODO; stick local file name somewhere so that ie appears in APS and doesn't confuse an SI

			}
			mLog.LogDebug(string.Format("Added {0} scheduled reports to APS InfoStore", count));


			instore.Commit(folders);
			instore.Commit(rptcoll);

		}

		private void UpdateReportObjects(int aParentFolderID)
		{
			//build a quick hashtable or report definition objects, so that's it's easier to look them up
			//there can't be too many of them. maybe 10
			IEnumerable eopreports = ReportConfiguration.GetInstance().AllEOPReports;
			IEnumerable scheduledreports = ReportConfiguration.GetInstance().AllScheduledReports;
			
			Hashtable rptht = new Hashtable();
			foreach(IReportDefinition rdef in eopreports)
			{
				rptht.Add(rdef.UniqueName.ToUpper(), rdef);
			}
			foreach(IReportDefinition rdef in scheduledreports)
			{
				rptht.Add(rdef.UniqueName.ToUpper(), rdef);
			}
			//Get me all non-instance reports (templates), that live under
			//MetraNet folder
			string query = @"Select * From CI_INFOOBJECTS Where " +
				"SI_PROGID = 'CrystalEnterprise.Report' "+
				"AND SI_INSTANCE=0 AND SI_PARENT_FOLDER = '" + aParentFolderID.ToString() + "'";
			DeleteOldReports(aParentFolderID, rptht, query);
			AddNewReports(aParentFolderID, rptht, query);
		}

		private void DeleteOldReports(int aParentFolderID, Hashtable rptht, string aQuery)
		{
			
			Files files = null;
			Report report = null;
			Properties properties = null;
			Property property = null;
			InfoObjects rptcoll = null;
      ArrayList IDsToDelete = new ArrayList();
			
			try
			{
				
				rptcoll = instore.Query(aQuery);
				int count = rptcoll.Count;
				foreach(InfoObject io in rptcoll)
				{
					File file = null;
					report = (Report)io;
					
					
					string sTemplateName = (string)report.Properties["SI_NAME"].Value;
					if(rptht.ContainsKey(sTemplateName.ToUpper()))
					{
						IReportDefinition rdef = (IReportDefinition)rptht[sTemplateName.ToUpper()];
						string srcFileName = string.Format(@"{0}\{1}", mRcd.ExtensionDir, rdef.SourceFile);
						//TODO: IMPORTANT
						//Next line will leak Crystal licenses.
						files = report.Files;
						file = files[1];
						file.Overwrite(srcFileName);
						report.RefreshProperties();
						properties = report.Properties;
						properties.Add("SI_DESCRIPTION", rdef.DisplayName);
						properties.Add("SI_NAME",rdef.UniqueName);
					}
					else
					{
						//delete the template and all its instances as it does not exist anymore.
            IDsToDelete.Add("#" + io.ID);
					}

					if(file != null) 
					{
						file.Dispose();
						file = null;
					}
					if(files != null) 
					{
						files.Dispose();
						files = null;
					}
					if(report != null) 
					{
						report.Dispose();
						report = null;
					}
				}

        // need to do the delete outside the above loops since deleting
        // re-indexes the collection
        foreach (string rptId in IDsToDelete)
        {
          rptcoll.Delete(rptId);
        }

				instore.Commit(rptcoll);
				
			}
			
			finally
			{
				if(files != null) 
				{
					files.Dispose();
					files = null;
				}
			
				if(report != null) 
				{
					report.Dispose();
					report = null;
				}
				if(property != null) 
				{
					property.Dispose();
					property = null;
				}
				if(properties != null) 
				{
					properties.Dispose();
					properties = null;
				}
				if(rptcoll != null) 
				{
					rptcoll.Dispose();
					rptcoll = null;
				}

				GC.Collect();
			}

		}

		private void AddNewReports(int aParentFolderID, Hashtable rptht, string aQuery)
		{
			Files files = null;
			Report report = null;
			Properties properties = null;
			Property property = null;
			InfoObjects rptcoll = null;

			try
			{
				rptcoll = instore.Query(aQuery);
				//foreach(InfoObject io in rptcoll)
				// if there are any templates in the hash table that are not in the MetraNet folder, add them
				IDictionaryEnumerator myEnumerator = rptht.GetEnumerator();
				while (myEnumerator.MoveNext())
				{
					string sReportName = (string)myEnumerator.Key;
					bool found = false;
					int count = rptcoll.Count;
					for(int i = 1; i<= count; i++)
					{
						InfoObject io = rptcoll[i];
						report = (Report)io;
						properties = report.Properties;
						
						property = properties["SI_NAME"];
						string sTemplateName = (string)property.Value;
						sTemplateName = sTemplateName.ToUpper();
						if (sTemplateName == sReportName)
							found = true;
						io.Dispose();
						io = null;
					}

					if (!found) //we need to add this
					{
						IReportDefinition rptdef =  (IReportDefinition) myEnumerator.Value;
						Report myrpt = (Report)rptcoll.Add("CrystalEnterprise.Report");
						string srcFileName = string.Format(@"{0}\{1}", mRcd.ExtensionDir, rptdef.SourceFile);
						files = myrpt.Files;
						files.Add(srcFileName);
						myrpt.Description = rptdef.DisplayName;
						myrpt.Properties.Add ("SI_PARENTID", aParentFolderID);
						myrpt.Properties.Add ("SI_NAME", rptdef.UniqueName);
						found = true;
					}

				}
				instore.Commit(rptcoll);
			}
			
			finally
			{
				if(files != null) 
				{
					files.Dispose();
					files = null;
				}
				if(report != null) 
				{
					report.Dispose();
					report = null;
				}
				if(property != null) 
				{
					property.Dispose();
					property = null;
				}
				if(properties != null) 
				{
					properties.Dispose();
					properties = null;
				}
				if(rptcoll != null) 
				{
					rptcoll.Dispose();
					rptcoll = null;
				}

				GC.Collect();
			}

		}
		
		



		private MetraTech.Logger mLog;
		private IMTRcd mRcd;
	}
}

using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Xml;

using MetraTech;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;

using System.Runtime.InteropServices;

namespace MetraTech.DataExportFramework.Adapters.QueueScheduledReportsAdapter
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	public class QueueScheduledReportsAdapter : MetraTech.UsageServer.IRecurringEventAdapter
	{
		private bool mbInitialized = false;
		private bool mbSupportsScheduledEvents = false;
		private bool mbSupportsEndOfPeriodEvents = true;
		private ReverseMode mEnReversibility = ReverseMode.Custom;
		private bool mbAllowMultipleInstances = false;
		private Logger moLogger;

		private string msQueueTag;
		private string msReverseQueueTag;
		private string msQueryPath;
		
		public QueueScheduledReportsAdapter()
		{	
			moLogger = new Logger("[QUEUESCHEDULEDREPORTSADAPTER]");
			mbInitialized = false;
			mbSupportsEndOfPeriodEvents = false;
			mbSupportsScheduledEvents = true;
		}

		private ArrayList moReportsList = new ArrayList();

		/// <summary>
		/// Returns a bool with information about scheduled event support.
		/// This information is gathered in the Initialize method from the config XML file.
		/// This Attribute has to be queried only after the "Initialize" method has been called.
		/// </summary>
		public bool SupportsScheduledEvents
		{
			get { return mbSupportsScheduledEvents; }
		}

		/// <summary>
		/// Returns a bool with information about EOP event support.
		/// This information is gathered in the Initialize method from the config XML file.
		/// This Attribute has to be queried only after the "Initialize" method has been called.
		/// </summary>
		public bool SupportsEndOfPeriodEvents
		{
			get { return mbSupportsEndOfPeriodEvents; }
		}

		/// <summary>
		/// Returns the Reversibility configuration of the adapter.
		/// Value is set after the Initialize method is executed from the config XML file.
		/// Defaults to ReverseMove.NotNeeded is no value is set.
		/// </summary>
		public ReverseMode Reversibility
		{
			get { return mEnReversibility; }
		}

		/// <summary>
		/// Returns the AllowMultipleInstances configuration of the adapter.
		/// This information is gathered in the Initialize method from the config XML file.
		/// This Attribute has to be queried only after the "Initialize" method has been called.
		/// </summary>
		public bool AllowMultipleInstances
		{
			get { return mbAllowMultipleInstances; }
		}

		/// <summary>
		/// Initialization will check on limitedinit and call readConfig.
		/// If there is an overriden ReadConfig, that will get called first,
		/// where the base Class' ReadConfig call is first made and then
		/// Inherited class specific ReadConfig is done.
		/// </summary>
		/// <param name="sEventName"></param>
		/// <param name="sConfigFile"></param>
		/// <param name="oContext"></param>
		/// <param name="bLimitedInit"></param>
		public virtual void Initialize(string sEventName, string sConfigFile, IMTSessionContext oContext, bool bLimitedInit)
		{
			try
			{
				moLogger.LogDebug("Starting initialization...");
				if(!bLimitedInit)
				{
					ReadConfig(sConfigFile);
				}

				mbInitialized = true;
				moLogger.LogDebug("Initialization completed.");
			}
			catch(System.Exception e)
			{
				moLogger.LogError("An error occurred during initialization: " + e.Message + "  Inner Exception: " + e.InnerException.Message);
				throw (e);
			}
		}

		private void ReadConfig(string sConfigFile)
		{
			XmlDocument oDoc = new XmlDocument();
			oDoc.Load(sConfigFile);

			try
			{
				msQueryPath = oDoc.SelectSingleNode("xmlconfig/schreports/query/path").InnerText;
				msQueueTag = oDoc.SelectSingleNode("xmlconfig/schreports/query/queuetag").InnerText;
				msReverseQueueTag = oDoc.SelectSingleNode("xmlconfig/schreports/query/reversetag").InnerText;
			}
			catch (Exception ex) 
			{
				throw new Exception("ReadConfig error!", ex);
			}
		}

		public string Execute(MetraTech.UsageServer.IRecurringEventRunContext oContext)
		{
			IMTConnection _cn = null;
			try 
			{
				moLogger.LogDebug("Executing...");
				if (mbInitialized)
				{
					_cn = ConnectionManager.CreateConnection();
					IMTAdapterStatement _selectst = _cn.CreateAdapterStatement(msQueryPath, msQueueTag);
					_selectst.AddParam("%%ID_RUN%%", oContext.RunID);
					_selectst.AddParam("%%METRATIME%%", MetraTime.Now.ToLocalTime()); 
					int rows = _selectst.ExecuteNonQuery();
					oContext.RecordInfo(rows.ToString() + " Scheduled Reports were successfully Queued to the WorkQueue for execution");
					return("Executed successfully");
				}
				else
					return ("Adapter not initialized");
			}
			catch (Exception ex)
			{
				throw (ex);
			}
			finally
			{
				if (_cn != null)
				{	
					_cn.Dispose();
					_cn.Close();
				}
			}
		}

		public string Reverse(MetraTech.UsageServer.IRecurringEventRunContext oContext)
		{
			IMTConnection _cn = null;
			try 
			{
				moLogger.LogDebug("Executing...");
				if (mbInitialized)
				{
					_cn = ConnectionManager.CreateConnection();
					IMTAdapterStatement _selectst = _cn.CreateAdapterStatement(msQueryPath, msReverseQueueTag);
					_selectst.AddParam("%%ID_RUN%%", oContext.RunIDToReverse, true);
					int rows = _selectst.ExecuteNonQuery();
					oContext.RecordInfo(rows.ToString() + " Scheduled Reports were successfully Removed from the WorkQueue");
					oContext.RecordWarning("If the reversed number is less than the Queued number, some reports have already picked up for execution by the Reporting Framework.");
					return("Reversed successfully");
				}
				else
					return ("Adapter not initialized");
			}
			catch (Exception ex)
			{
				throw (ex);
			}
			finally
			{
				if (_cn != null)
				{	
					_cn.Dispose();
					_cn.Close();
				}
			}		
		}
	
		public void Shutdown()
		{
			//Nothing to do here.
		}
	}

	
}

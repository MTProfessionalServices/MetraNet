using System;
using System.Diagnostics;
using System.IO;
using System.Xml;
using System.Threading;

using MetraTech.DataAccess;
using MetraTech.DataExportFramework.Common;
using MetraTech.Interop.Rowset;
using MetraTech.DataExportFramework.Components.DataExporter;

namespace MetraTech.DataExportService
{
	public class DataExportManager : System.ServiceProcess.ServiceBase
	{
		
		private System.Timers.Timer __timer;
		private DateTime __timeStopCalled = DateTime.Now.AddYears(1);
		private const int ONE_MINUTE = 1000 * 60; //in milliseconds

		/// <summary> 
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		/// <summary>
		/// Keeps a count of reports that have been attempted to process. If a particular report that was initially found on 
		/// the queue when scanned, but now is no longer is on the queue, this counter gets regardless incremented.
		/// This counter is important to notify the completion of reports execution process to the calling program.
		/// </summary>
		private int __currentProcessCount = 0;


		/// <summary>
		/// An instance of the Mutex object to enable thread synchronization when executing the Callback
		/// </summary>
		private static Mutex __mutex = new Mutex();
		private static Mutex __executeMutex = new Mutex();

		/// <summary>
		/// Class level connection instance that will be used by all Callback executions
		/// This instance is initialized when the Execute Process starts and cleaned up when all report executions are complete.
		/// Since Callbacks are asynchronously called, it makes sense not to open a new connection everytime it is executed.
		/// We keep this instance alive until all callbacks are processed.
		/// Use of Mutex makes sure the connection object is not inadvertently used by another callback execution
		/// </summary>
		private IMTConnection __auditConnection = null;

    	private readonly IConfiguration _config = Configuration.Instance;

		// The main entry point for the process
		static void Main()
		{
			System.ServiceProcess.ServiceBase[] ServicesToRun;
	
			// More than one user Service may run within the same process. To add
			// another service to this process, change the following line to
			// create a second service object. For example,
			//
			//   ServicesToRun = new System.ServiceProcess.ServiceBase[] {new XRepManager(), new MySecondUserService()};
			//
			ServicesToRun = new System.ServiceProcess.ServiceBase[] { new DataExportManager() };

			System.ServiceProcess.ServiceBase.Run(ServicesToRun);
		}

		/// <summary> 
		/// Required method for Designer support - do not modify 
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			components = new System.ComponentModel.Container();
			this.ServiceName = "DataExportService";
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		/// <summary>
		/// Set things in motion so your service can do its work.
		/// </summary>
		protected override void OnStart(string[] args)
		{
			DefLog.MakeLogEntry("**********************************************************", "info");
			DefLog.MakeLogEntry("*****************Starting DataExportService*******************", "info");
			DefLog.MakeLogEntry("**********************************************************", "info");


            DefLog.MakeLogEntry("DataExport Framework found the extension location as ..." + _config.PathToExtensionDir);
		  
            DefLog.MakeLogEntry("Reports Config File: " + _config.PathToReportConfigFile);
      
            DefLog.MakeLogEntry("Reports working folder: " + _config.WorkingFolder);
      
            DefLog.MakeLogEntry("Processing Server : " + _config.ProcessingServer);
		  
            try
            {
                //initialize the audit connection
                //this connection will be active as long as the service is active.
                __auditConnection = ConnectionManager.CreateConnection();
                this.__timer = new System.Timers.Timer();
                
                this.__timer.Interval = ONE_MINUTE * Convert.ToDouble(_config.ScanInterval);
                //__timer.Elapsed += new ElapsedEventHandler(__timer_Elapsed);
                __timer.Elapsed += new System.Timers.ElapsedEventHandler(__timer_Elapsed);
                __timer.AutoReset = true;
                __timer.Enabled = true;
                __timer.Start();

                Check4Zombies();
                
                DefLog.MakeLogEntry("Successfully Started DataExportService.\n Reports Queue will start getting processed in "
                    + Convert.ToString(ONE_MINUTE * Convert.ToDouble(_config.ScanInterval)));
            }
            catch (Exception ex)
            {
                DefLog.MakeLogEntry("DataExportService Start up exception\n" + ex, "fatal");
                throw;
            }
        }

        private string Check4Zombies()
        {
            DefLog.MakeLogEntry("Checking for Zombie Reports");

            IMTDataReader reader = null;
            try
            {
              IMTAdapterStatement _selectst = __auditConnection.CreateAdapterStatement(_config.PathToServiceQueryDir, "__AUDIT_REPORT_ZOMBIES__");
                if(__auditConnection.ConnectionInfo.IsOracle)
                {
                    _selectst.ExecuteNonQuery();
                    _selectst = __auditConnection.CreateAdapterStatement(_config.PathToServiceQueryDir, "__SELECT_ZOMBIES_ID__");
                }
                reader = _selectst.ExecuteReader();
                while (reader.Read())
                {
                    DefLog.MakeLogEntry("Report with ID_WORK_QUEUE " + Convert.ToString(reader.GetValue("id_work_queue")) + " was detected as a zombie and removed from the work queue");
                }
            }
            catch (Exception ex)
            {
                DefLog.MakeLogEntry("Error Encountered While Checking for Zombie Reports");
                throw new Exception("Error Encountered While Checking for Zombie Reports: ", ex);
            }
            finally
            {
                if (reader != null)
                {
                    reader.Close();
                    reader.Dispose();
                }
            }
            return "COMPLETED";
        }

		/// <summary>
		/// Stop this service.
		/// </summary>
		protected override void OnStop()
		{
			int _imax = 0, _icomplete = 0, _iavail = 0;
			ThreadPool.GetMaxThreads(out _imax, out _icomplete);			
			ThreadPool.GetAvailableThreads(out _iavail, out _icomplete);
			while (_iavail < _imax-1)
			{
				string _msg = "A Stop has been initiated on the DataExportService.\n"
					+ "Unable to stop DataExport - Report generation still in progress.\n"
					+ "DataExportService will wait for completion of these reports before shutting down";
				DefLog.MakeLogEntry(_msg, "warning");
				this.EventLog.WriteEntry(_msg, EventLogEntryType.Warning);
				Thread.Sleep(new TimeSpan(0, 1, 0));
			}
			if (this.__auditConnection != null)
			{
				this.__auditConnection.Close();
				this.__auditConnection.Dispose();
			}
			DefLog.MakeLogEntry("DataExportService has been shut down", "info");
			this.EventLog.WriteEntry("DataExportService has been shut down", EventLogEntryType.Warning);
		}

		private void __timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
		{
			try 
			{
				//check to see if the timer had already called this event at the time stop was called...
				//in case stop was already called, we bypass this event.
				if (DateTime.Compare(e.SignalTime, __timeStopCalled) > 0)
				{
					DefLog.MakeLogEntry("A stop has been recieved on the service, exiting...", "info");
					return;
				}
				ReportThreadPoolStatus();
				this.Execute();
				ReportThreadPoolStatus();
			}
			catch (Exception ex)
			{
				DefLog.MakeLogEntry(ex.ToString());
			}
		}

		#region DataExport Custom Code
		/// <summary>
		/// Service Constructor - customized to initialize XRep.
		/// </summary>
		public DataExportManager()
		{
			// This call is required by the Windows.Forms Component Designer.
			InitializeComponent();
		}

		/// <summary>
		/// Begin processing the reports.
		/// - Scan the queue and retrieve the all the report instances on the queue
		/// - Execute each instance
		/// </summary>
		public void Execute()
		{
			__executeMutex.WaitOne();
			IMTConnection _cn = null;
			try 
			{
				IMTSQLRowset _reportsRowset = new MTSQLRowsetClass();
				__currentProcessCount = 0;
				//Read the database and get a list of all reports
        _reportsRowset.Init(_config.PathToServiceQueryDir);
				_reportsRowset.SetQueryTag("__GET_REPORT_INSTANCES__");
				_reportsRowset.ExecuteDisconnected();
				//__reportsCount = _reportsRowset.RecordCount;
				if (_reportsRowset.RecordCount == 0)
				{
					//__executeMutex.ReleaseMutex();
					return;
				}
				

				//_reportsRowset.MoveFirst();
				//__bProcessStarted = true;
				try 
				{
					_cn = ConnectionManager.CreateConnection();
				}
				catch (Exception)
				{
					throw;
				}
				while (Convert.ToInt16(_reportsRowset.EOF) >= 0)
				{
					Guid guid;
					if (__auditConnection.ConnectionInfo.IsOracle)
					{
						var paramFromQ = _reportsRowset.get_Value("id_work_queue") as byte[];
						if (paramFromQ == null)
						{
							throw new NullReferenceException("Unable to retrieve byte[] object from 'id_work_queue' reader value");
						}
            string hex = BitConverter.ToString(paramFromQ);
            string guidStr = hex.Replace("-", "");
            guid = new Guid(guidStr);
					}
					else
					{
						guid = new Guid(Convert.ToString(_reportsRowset.get_Value("id_work_queue")));
					}
				
					//LogWriter.LogDebug("MainReportsEntry", "Begin process for Report Instance "+_reportsRowset.get_Value("id_rep_instance_id").ToString());
					this.ExecuteNextReportInLine(guid , _cn);
				
					_reportsRowset.MoveNext();
				}

        _reportsRowset.Init(_config.PathToServiceQueryDir);
			}
			catch (Exception ex)
			{
				//__bProcessStarted = false;
				DefLog.MakeLogEntry ("Fatal Error in MainEntry Execute. No Reports were generated!\n"+ex.ToString(), "fatal");
				throw (ex);
			}
			finally
			{
				if (_cn != null)
				{
					_cn.Close();
					_cn.Dispose();
				}
				__executeMutex.ReleaseMutex();
			}
		}

		private void ReportThreadPoolStatus()
		{
			DefLog.MakeLogEntry("+++++++++ThreadPool Status++++++++++++++++++++");
			int _imax = 0, _icomplete = 0, _iavail = 0;
            //ThreadPool.SetMaxThreads(2, 2);
			ThreadPool.GetMaxThreads(out _imax, out _icomplete);			
			ThreadPool.GetAvailableThreads(out _iavail, out _icomplete);

			DefLog.MakeLogEntry("Max Threads : " + _imax.ToString());
			DefLog.MakeLogEntry("Available Threads : " + _iavail.ToString());
			DefLog.MakeLogEntry("++++++++++++++++++++++++++++++++++++++++++++++");
		}

		/// <summary>
		///		Executes the next report instance that was found on the scanned reports queue.
		///		A report instance may no longer be on the queue for the following reasons
		///			- A REVERSE operation may have removed it from the queue
		///			- Another isntance of the Reporting Framework service on a different server may have picked it up for processing
		///		If a report instance that was picked up during the scan is no longer available the processed reports count is incremented
		///		and processing moves on to the next instance on the queue.
		///		If a report instance did not complete the constructor phase due to incomplete or incorrect data, processed reports count is incremented
		///		and processing moves on to the next instance on the queue.
		/// </summary>
		/// <param name="workQId">GUID - Id for the report instance on the work queue</param>
		/// <param name="connection">IMTConnection - Connection object Instance</param>
		private void ExecuteNextReportInLine(Guid workQId, IMTConnection connection)
		{
			IMTDataReader _rdr = null;
			try 
			{
			  IMTCallableStatement _queuedReport;
        _queuedReport = connection.CreateCallableStatement("export_GetQueuedReportInstancs");
        if(__auditConnection.ConnectionInfo.IsOracle)
        {
          _queuedReport.AddParam("workQId", MTParameterType.String, workQId.ToString());
        }
        else
        {
          _queuedReport.AddParam("workQId", MTParameterType.Guid, workQId);
        }
        _queuedReport.AddParam("servername", MTParameterType.String, _config.ProcessingServer);
				_rdr = _queuedReport.ExecuteReader();
				if (_rdr.Read())
				{
					try
					{
            //TODO: Check can we do "_rdr.GetValue("id_work_queue") as byte[]" on SQL
					  string guidStr;
            if (__auditConnection.ConnectionInfo.IsOracle)
            {
					    var paramFromQ = _rdr.GetValue("id_work_queue") as byte[];
					    if (paramFromQ == null)
              {
                throw new NullReferenceException("Unable to retrieve byte[] object from 'id_work_queue' reader value");
              }
              string hex = BitConverter.ToString(paramFromQ);
              guidStr = hex.Replace("-", "");
            }
            else
            {
              guidStr = Convert.ToString(_rdr.GetValue("id_work_queue"));
            }

			guidStr = new Guid(guidStr).ToString();

            ReportGenerator rG = new ReportGenerator(guidStr, 
					                                             Convert.ToInt32(_rdr.GetValue("id_rep")),
					                                             Convert.ToInt32(_rdr.GetValue("id_rep_instance_id")), 
					                                             Convert.ToInt32(_rdr.GetValue("id_schedule")), 
					                                             Convert.ToString(_rdr.GetValue("c_sch_type")), 
					                                             Convert.ToString(_rdr.GetValue("c_rep_type")),
					                                             Convert.ToString(_rdr.GetValue("c_rep_title")));
					    rG.WorkQId = workQId.ToString();
              rG.ReportCompletedEvent += new ReportExecutionCompleteHandler(rG_ReportCompletedEvent);
					    ThreadPool.QueueUserWorkItem(new WaitCallback(rG.Execute), rG);
					    ReportThreadPoolStatus();
					}
					/*catch (ReportExecutionAlreadyInProgressException)
					{
						//Nothing to do here... 
					}
					catch (ReportExecutionAlreadyCompleteException)
					{
						//Nothing to do here... 
					}*/
					catch (ReportInstanceInitializationException riEx)
					{
						this.AuditExecuteStatus(riEx);
						/*this instance did not complete the constructor phase - get the next instance.*/
						//this.__reportsCount--;
						/* Decrement the __reportsCount value to indicate one instance that got bypassed
						 * and thus should not get counted during the IsComplete Check.*/
					}
					catch (Exception ex)
					{
						//this.__reportsCount--;
						DefLog.MakeLogEntry("Unknown Error during initialization of the report instance\n" + ex.ToString(), "error");
					}
				}
				else
				{
					/*this instance has been picked up by another server - bypass the execute
					 * and get the next instance.*/
					//this.__reportsCount--;
					/* Decrement the __reportsCount value to indicate one instance that got bypassed
					 * and thus should not get counted during the IsComplete Check.*/
					return;
				}
			}
			catch (Exception ex)
			{
				throw (ex);
			}
			finally
			{
				if (_rdr != null)
				{
					_rdr.Close();
					_rdr.Dispose();
				}
			}
		}

		private string FieldFileUsedForReport(string fieldDefFile)
		{
			if (System.IO.File.Exists(fieldDefFile))
				return new System.IO.FileInfo(fieldDefFile).Name;
			else
				return "NONE USED";
		}

		/// <summary>
		/// Creates an Audit Log Entry for a report instance execution that was setup for execution on a thread successfully
		/// The Execute Status information is retrieved from ReportExecutionCompleteEventArgs parameter.
		/// Success and Failure information is retrieved from ReportExecutionCompleteEventArgs
		/// </summary>
		/// <param name="rE">ReportExecutionCompleteEventArgs</param>
		private void AuditExecuteStatus(ReportExecutionCompleteEventArgs rE)
		{
            IMTConnection __auditConnection1 = null;
            try
            {
                __auditConnection1 = ConnectionManager.CreateConnection();

                IMTAdapterStatement _selectst = __auditConnection1.CreateAdapterStatement(_config.PathToServiceQueryDir, "__AUDIT_REPORT_EXECUTE_STATUS__");
                _selectst.AddParam("%%WORK_QUEUE_ID%%", "'" + rE.WorkQId + "'", true);
                _selectst.AddParam("%%EXECUTE_STATUS%%", "'" + rE.CompletionStatus.ToString() + "'", true);
                _selectst.AddParam("%%EXECUTE_START_DATE_TIME%%", rE.ExecuteStartTime, true);
                _selectst.AddParam("%%EXECUTE_COMPLETE_DATE_TIME%%", rE.DateTimeCompleted, true);
                string _descr = rE.Description;
                _descr = _descr.Replace("%", "*");
                _descr = _descr.Replace("'", "");
                _descr = _descr.Replace("\"", "");
                _selectst.AddParam("%%DESCR%%", "'" + _descr + "'", true);
                string _paramvals = rE.ExecuteParamValues;
                _paramvals = _paramvals.Replace("%", "*");
                _paramvals = _paramvals.Replace("'", "");
                _paramvals = _paramvals.Replace("\"", "");
                _selectst.AddParam("%%EXECUTE_PARAM_VALUES%%", "'" + _paramvals + "'", true);                
                DefLog.MakeLogEntry(_selectst.Query, "debug");
                _selectst.ExecuteNonQuery();

                if ((rE.ScheduleType.ToLower() == "daily" || rE.ScheduleType.ToLower() == "weekly" || rE.ScheduleType.ToLower() == "monthly") && rE.CompletionStatus == ReportExecuteStatus.SUCCESS)
                {
                    DefLog.MakeLogEntry("SetNextRunDate For Report:Instance" + rE.ReportInstanceID.ToString(), "debug");
                    SetNextRunDate(rE);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Exception in Report Complete Audit", ex);
            }
            finally
            {
                if (__auditConnection1 != null)
                {
                    __auditConnection1.Close();
                    __auditConnection1.Dispose();
                }
            }
		}

		/// <summary>
		/// Creates an Audit Log Entry for a report instance execution that failed during setup of for execution on a thread
		/// The "ReportInstanceInitializationException" exception holds information about instance that failed and reasons for the failure
		/// </summary>
		/// <param name="riEx">ReportInstanceInitializationException</param>
		private void AuditExecuteStatus(ReportInstanceInitializationException riEx)
		{
			__mutex.WaitOne();
            IMTConnection __auditConnection1 = null;

            try
			{
        IMTAdapterStatement _selectst = __auditConnection1.CreateAdapterStatement(_config.PathToServiceQueryDir, "__AUDIT_REPORT_EXECUTE_STATUS__");
				_selectst.AddParam("%%WORK_QUEUE_ID%%", "'"+riEx.WorkQId+"'", true);
				_selectst.AddParam("%%EXECUTE_STATUS%%", "'" + riEx.CompletionStatus.ToString() + "'", true);
				_selectst.AddParam("%%EXECUTE_START_DATE_TIME%%", riEx.ExecuteStartTime, true);
				_selectst.AddParam("%%EXECUTE_COMPLETE_DATE_TIME%%", riEx.ExecuteEndTime, true);
				string _descr = riEx.Descr;
				_descr = _descr.Replace("%", "*");
				_descr = _descr.Replace("'", "");
				_descr = _descr.Replace("\"", "");
				_selectst.AddParam("%%DESCR%%", "'" + _descr + "'", true);
				string _paramvals = riEx.ExecuteParamValues;
				_paramvals = _paramvals.Replace("%", "*");
				_paramvals = _paramvals.Replace("'", "");
				_paramvals = _paramvals.Replace("\"", "");
				_selectst.AddParam("%%EXECUTE_PARAM_VALUES%%", "'" + _paramvals + "'", true);				
				_selectst.ExecuteNonQuery();

			}
			catch (Exception ex)
			{
				DefLog.MakeLogEntry("Exception in Report Execute Audit \n"+ex, "error");
			}
			finally 
			{
                if (__auditConnection1 != null)
                {
                    __auditConnection1.Close();
                    __auditConnection1.Dispose();
                }
                __mutex.ReleaseMutex();
			}
		}

		/// <summary>
		/// Sets the Next Run Date Time for Scheduled report instances that were successfully executed
		/// </summary>
		/// <param name="rE"></param>
		private void SetNextRunDate(ReportExecutionCompleteEventArgs rE)
		{
			IMTConnection _cn = null;
			try 
			{
				_cn = ConnectionManager.CreateConnection();
        IMTAdapterStatement _selectst = _cn.CreateAdapterStatement(_config.PathToServiceQueryDir, "__SET_REPORT_INSTANCE_NEXT_RUN_DATE__");
				_selectst.AddParam("%%REPORT_INSTANCE_ID%%", rE.ReportInstanceID, true);
				_selectst.AddParam("%%SCHEDULE_ID%%", rE.ScheduleID, true);
				_selectst.AddParam("%%SCHEDULE_TYPE%%", "'"+rE.ScheduleType+"'", true);
				_selectst.AddParam("%%DT_NOW%%", rE.ReportSetToBeExecutedAt, true);
				_selectst.AddParam("%%START_DATE%%", rE.ReportSetToBeExecutedAt, true);
				DefLog.MakeLogEntry("SETNEXTRUNDATE Query\n"+_selectst.Query, "debug");
				_selectst.ExecuteNonQuery();
			}
			catch (Exception ex)
			{
				DefLog.MakeLogEntry("Unable to set next run date for ReportInstance:"
					+rE.ReportInstanceID+", with "+ rE.ScheduleType +" schedule:"
					+rE.ScheduleID+"\n"+ex, "error");
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

		private void rG_ReportCompletedEvent(object sender, ReportExecutionCompleteEventArgs e)
		{
			__mutex.WaitOne();
			try 
			{
				__currentProcessCount++;
				AuditExecuteStatus (e);
			}
			catch (Exception ex)
			{
				DefLog.MakeLogEntry("Exception in ReportGenerator Completed Callback\n"+ex, "error");
			}
			finally
			{
				__mutex.ReleaseMutex();
			}
		}
		#endregion

	}
}









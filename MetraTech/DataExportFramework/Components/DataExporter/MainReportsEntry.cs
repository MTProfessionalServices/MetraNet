using System;
using System.IO;
using System.Xml;
using System.Threading;
using MetraTech.DataAccess;
using MetraTech.DataExportFramework.Common;
using MetraTech.Interop.Rowset;

namespace MetraTech.DataExportFramework.Components.DataExporter
{

	/// <summary>
	/// MainReportsEntry:
	///		This is the single point of entry into the ReportingFramework
	///		Instance of this class will - Connect to the database, scan the Work Queue table (t_rp_workqueue),
	///		load and setup a report execution request on it's own thread, attach a callback to
	///		each report execution instance object and executes the report instance.
	///		Execution is delegated to the Operating System ThreadPool which manages the scheduling the resources 
	///		for the thread and doing the callback once the execution completes.
	/// </summary>
	public class MainReportsEntry
	{
        
		/// <summary>
		/// Keeps a count of reports that were found on the Reports Queue when first scanned
		/// </summary>
		private int __reportsCount = 0;

		/// <summary>
		/// Keeps a count of reports that have been attempted to process. If a particular report that was initially found on 
		/// the queue when scanned, but now is no longer is on the queue, this counter gets regardless incremented.
		/// This counter is important to notify the completion of reports execution process to the calling program.
		/// </summary>
		private int __currentProcessCount = 0;

		/// <summary>
		/// A flag to indicate the ReportingFramework execution is being currently in progress.
		/// </summary>
		private bool __bProcessStarted = false;

		/// <summary>
		/// An instance of the Mutex object to enable thread synchronization when executing the Callback
		/// </summary>
		private static Mutex __mutex = new Mutex();

		/// <summary>
		/// Class level connection instance that will be used by all Callback executions
		/// This instance is initialized when the Execute Process starts and cleaned up when all report executions are complete.
		/// Since Callbacks are asynchronously called, it makes sense not to open a new connection everytime it is executed.
		/// We keep this instance alive until all callbacks are processed.
		/// Use of Mutex makes sure the connection object is not inadvertently used by another callback execution
		/// </summary>
		private IMTConnection __auditConnection = null;

		/// <summary>
		/// GET/SET 
		///		- TRUE indicates the Report Execution process has already
		///		- FALSE indicates an process not yet started
		///		This helps in indicating to the calling program to wait until a FALSE gets returned before 
		///		terminating the Reporting Framework instance
		/// </summary>
		public bool ProcessStarted { get { return __bProcessStarted; } }
		
		/// <summary>
		/// GET/SET
		///		- TRUE indicates all Report Execution instances are complete.
		///			Also cleans up the connection instance used by the Callback method if the execution process is complete.
		///		- FALSE indicates otherwise
		/// </summary>
		public bool IsComplete 
		{
			get
			{
				if (__bProcessStarted)
				{
					if (__currentProcessCount < __reportsCount)
						return false;
					else
					{
						if (__auditConnection != null)
						{
							__auditConnection.Close();
							__auditConnection.Dispose();
						}
						return true;
					}
				}
				else
					return false;
			} 
		}

    private readonly IConfiguration _config = Configuration.Instance;

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
                IMTAdapterStatement _queuedReport = connection.CreateAdapterStatement(_config.PathToServiceQueryDir, "__GET_THIS_QUEUED_INSTANCE__");
				_queuedReport.AddParam("%%WORK_QUEUE_ID%%", "'"+workQId.ToString()+"'", true);
        _queuedReport.AddParam("%%PROCESSING_SERVER%%", "'" + _config.ProcessingServer + "'", true);
				_rdr = _queuedReport.ExecuteReader();
				if (_rdr.Read())
				{
					try 
					{
						ReportGenerator rG = new ReportGenerator(new Guid(Convert.ToString(_rdr.GetValue("id_work_queue"))).ToString(), 
							Convert.ToInt32(_rdr.GetValue("id_rep")),
							Convert.ToInt32(_rdr.GetValue("id_rep_instance_id")), 
							Convert.ToInt32(_rdr.GetValue("id_schedule")), 
							Convert.ToString(_rdr.GetValue("c_sch_type")), 
							Convert.ToString(_rdr.GetValue("c_rep_type")),
							Convert.ToString(_rdr.GetValue("c_rep_title")));
						
            rG.WorkQId = workQId.ToString();

						rG.ReportCompletedEvent += new ReportExecutionCompleteHandler(rG_ReportCompletedEvent);
						ThreadPool.QueueUserWorkItem(new WaitCallback(rG.Execute), rG);
					}
					catch (ReportInstanceInitializationException riEx)
					{
						this.AuditExecuteStatus(riEx);
						/*this instance did not complete the constructor phase - get the next instance.*/
						this.__reportsCount--;
						/* Decrement the __reportsCount value to indicate one instance that got bypassed
						 * and thus should not get counted during the IsComplete Check.*/
					}
					catch (Exception ex)
					{
						this.__reportsCount--;
                        DefLog.MakeLogEntry("Unknown Error during initialization of the report instance\n" + ex.ToString(), "fatal");
					}
				}
				else
				{
					/*this instance has been picked up by another server - bypass the execute
					 * and get the next instance.*/
					 this.__reportsCount--;
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

		/// <summary>
		/// Begin processing the reports.
		/// - Scan the queue and retrieve the all the report instances on the queue
		/// - Execute each instance
		/// </summary>
		public void Execute()
		{
			IMTConnection _cn = null;
			try 
			{
				try 
				{
					__auditConnection = ConnectionManager.CreateConnection();
				}
				catch (Exception)
				{
					throw;
				}
				IMTSQLRowset _reportsRowset = new MTSQLRowsetClass();
				__currentProcessCount = 0;
				//Read the database and get a list of all reports
                _reportsRowset.Init(_config.PathToServiceQueryDir);
				_reportsRowset.SetQueryTag("__GET_REPORT_INSTANCES__");
				_reportsRowset.ExecuteDisconnected();
				__reportsCount = _reportsRowset.RecordCount;
				

				//_reportsRowset.MoveFirst();
				__bProcessStarted = true;
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
					//LogWriter.LogDebug("MainReportsEntry", "Begin process for Report Instance "+_reportsRowset.get_Value("id_rep_instance_id").ToString());
					this.ExecuteNextReportInLine(new Guid(Convert.ToString(_reportsRowset.get_Value("id_work_queue"))), _cn);
				
					_reportsRowset.MoveNext();
				}

        _reportsRowset.Init(_config.PathToServiceQueryDir);
			}
			catch (Exception ex)
			{
				__bProcessStarted = false;
                DefLog.MakeLogEntry("Fatal Error in MainEntry Execute. No Reports were generated!\n" + ex.ToString(), "fatal");
				throw;
			}
			finally
			{
				if (_cn != null)
				{
					_cn.Close();
					_cn.Dispose();
				}
			}
		}
	
		#region Single Threaded Execute Methods
		/// <summary>
		/// Single threaded ExecuteNextInLine for testing purposes 
		///		- This method does not schedule the instance execution on a separate thread
		///		- The aynschronous callbacks are not attached and do not get executed in this case since all execution is synchronous
		/// </summary>
		/// <param name="workQId"></param>
		/// <param name="connection"></param>
		private void SingleThreadedExecuteNextInLine(Guid workQId, IMTConnection connection)
		{
			IMTDataReader _rdr = null;
			try 
			{
        IMTAdapterStatement _queuedReport = connection.CreateAdapterStatement(_config.PathToServiceQueryDir, "__GET_THIS_QUEUED_INSTANCE__");
				_queuedReport.AddParam("%%WORK_QUEUE_ID%%", "'"+workQId.ToString()+"'", true);
				_queuedReport.AddParam("%%PROCESSING_SERVER%%", "'"+_config.ProcessingServer+"'", true);
				_rdr = _queuedReport.ExecuteReader();
				if (_rdr.Read())
				{
					ReportGenerator rG = new ReportGenerator(new Guid(Convert.ToString(_rdr.GetValue("id_work_queue"))).ToString(), 
						Convert.ToInt32(_rdr.GetValue("id_rep")),
						Convert.ToInt32(_rdr.GetValue("id_rep_instance_id")), 
						Convert.ToInt32(_rdr.GetValue("id_schedule")), 
						Convert.ToString(_rdr.GetValue("c_sch_type")), 
						Convert.ToString(_rdr.GetValue("c_rep_type")),
						Convert.ToString(_rdr.GetValue("c_rep_title")));
					
					rG.WorkQId = workQId.ToString();
					rG.SingleThreadedExecute();
					
				}
				else
				{
					/*this instance has been picked up by another server - bypass the execute
					 * and get the next instance.*/
					__reportsCount--;
					/* Decrement the __reportsCount value to indicate one instance that got bypassed
					 * and thus should not get counted during the IsComplete Check.*/
					return;
				}
			}
			catch (Exception)
			{
				throw;
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

		/// <summary>
		/// Single threaded Execute provided for testing purposes
		/// </summary>
		public void SingleThreadedExecute()
		{
			IMTConnection _cn = null;
			try 
			{
				IMTSQLRowset _reportsRowset = new MTSQLRowsetClass();
				__currentProcessCount = 0;
				//Read the database and get a list of all reports
        _reportsRowset.Init(_config.PathToServiceQueryDir);
				_reportsRowset.SetQueryTag("__GET_REPORT_INSTANCES__");
				_reportsRowset.ExecuteDisconnected();
				__reportsCount = _reportsRowset.RecordCount;

				_reportsRowset.MoveFirst();
				__bProcessStarted = true;
				_cn = ConnectionManager.CreateConnection();
				while (Convert.ToInt16(_reportsRowset.EOF) >= 0)
				{
					try 
					{
						this.SingleThreadedExecuteNextInLine(new Guid(Convert.ToString(_reportsRowset.get_Value("id_work_queue"))), _cn);
					}
					catch 
					{
						//nothing to do...
					}
				
					_reportsRowset.MoveNext();
				}

				_reportsRowset.Clear();
				_reportsRowset.ClearQuery();
			}
			catch (Exception ex)
			{
                DefLog.MakeLogEntry(ex.ToString(), "fatal");
			}
			finally 
			{
				if (_cn != null)
				{
					_cn.Close();
					_cn.Dispose();
				}
			}
		}
		#endregion

		/// <summary>
		/// Call back method for the report instances
		/// ReportExecutionCompleteEventArgs instance holds information on the status and results of the report execution
		/// </summary>
		/// <param name="sender">Object</param>
		/// <param name="e">ReportExecutionCompleteEventArgs object instance</param>
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
                DefLog.MakeLogEntry("Exception in ReportGenerator Completed Callback\n" + ex.ToString(), "fatal");
			}
			finally
			{
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
                DefLog.MakeLogEntry("SETNEXTRUNDATE Query\n" + _selectst.Query, "debug");
				_selectst.ExecuteNonQuery();
			}
			catch (Exception ex)
			{
                DefLog.MakeLogEntry("Unable to set next run date for ReportInstance:"
					+rE.ReportInstanceID+", with "+ rE.ScheduleType +" schedule:"
					+rE.ScheduleID+"\n"+ex.ToString(), "error");
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

		/// <summary>
		/// Creates an Audit Log Entry for a report instance execution that failed during setup of for execution on a thread
		/// The "ReportInstanceInitializationException" exception holds information about instance that failed and reasons for the failure
		/// </summary>
		/// <param name="riEx">ReportInstanceInitializationException</param>
		private void AuditExecuteStatus(ReportInstanceInitializationException riEx)
		{
			__mutex.WaitOne();
			try
			{
        IMTAdapterStatement _selectst = __auditConnection.CreateAdapterStatement(_config.PathToServiceQueryDir, "__AUDIT_REPORT_EXECUTE_STATUS__");
				_selectst.AddParam("%%WORK_QUEUE_ID%%", "'"+riEx.WorkQId+"'", true);
				_selectst.AddParam("%%EXECUTE_STATUS%%", "'" + riEx.CompletionStatus.ToString() + "'", true);
				_selectst.AddParam("%%EXECUTE_START_DATE_TIME%%", riEx.ExecuteStartTime, true);
				_selectst.AddParam("%%EXECUTE_COMPLETE_DATE_TIME%%", riEx.ExecuteEndTime, true);
				string _descr = riEx.Descr;
				_descr = _descr.Replace("%", "*");
				_descr = _descr.Replace("'", "");
				_descr = _descr.Replace("\"", "");
				_selectst.AddParam("%%DESCR%%", "'" + _descr + "'", true);
				_selectst.AddParam("%%EXECUTE_PARAM_VALUES%%", "'N/A'", true);
				_selectst.ExecuteNonQuery();

			}
			catch (Exception ex)
			{
                DefLog.MakeLogEntry("Exception in Report Execute Audit \n" + ex.ToString(), "fatal");
			}
			finally 
			{
				__mutex.ReleaseMutex();
			}
		}

		/// <summary>
		/// Creates an Audit Log Entry for a report instance execution that was setup for execution on a thread successfully
		/// The Execute Status information is retrieved from ReportExecutionCompleteEventArgs parameter.
		/// Success and Failure information is retrieved from ReportExecutionCompleteEventArgs
		/// </summary>
		/// <param name="rE">ReportExecutionCompleteEventArgs</param>
		private void AuditExecuteStatus(ReportExecutionCompleteEventArgs rE)
		{
			try
			{
        IMTAdapterStatement _selectst = __auditConnection.CreateAdapterStatement(_config.PathToServiceQueryDir, "__AUDIT_REPORT_EXECUTE_STATUS__");
				_selectst.AddParam("%%WORK_QUEUE_ID%%", "'"+rE.WorkQId+"'", true);
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

				if (rE.ScheduleType.ToLower() == "daily" || rE.ScheduleType.ToLower() == "weekly" || rE.ScheduleType.ToLower() == "monthly"
					&& rE.CompletionStatus == ReportExecuteStatus.SUCCESS)
				{
                    DefLog.MakeLogEntry("SetNextRunDate For Report:Instance" + rE.ReportInstanceID.ToString(), "debug");
					SetNextRunDate(rE);
				}
			}
			catch (Exception ex)
			{
				throw new Exception( "Exception in Report Complete Audit", ex);
			}
		}
	}

	/// <summary>
	/// Exception class that will hold information about a Report Instance that failed during initialization.
	/// </summary>
  /// TODO: this class and <see cref="ReportExecutionCompleteEventArgs"/> has very similar properties whci can be merged to one class
  /// TODO: It will aloow to merge to methods MainReportsEntry.AuditExecuteStatus(ReportInstanceInitializationException riEx) and 
  /// TODO: MainReportsEntry.AuditExecuteStatus(ReportExecutionCompleteEventArgs rE) to one generic method
	public class ReportInstanceInitializationException : System.Exception
	{
		/// <summary>
		/// standard base message
		/// </summary>
		private const string STANDARD_MESSAGE = "THE REPORT INSTANCE FAILED INITIALIZATION. ";

		/// <summary>
		/// QueueId for the report that was being initialized
		/// </summary>
		private string __workdQId;

		/// <summary>
		/// GET/SET
		///		- QueueId for the report that was being initialized
		/// </summary>
		public string WorkQId { get { return this.__workdQId; } set { this.__workdQId = value; } }

		/// <summary>
		/// Enum holding the Report Execution Status
		/// </summary>
		private ReportExecuteStatus __completionStatus;
		
		/// <summary>
		/// GET/SET
		///		- Enum holding the Report Execution Status
		/// </summary>
		public ReportExecuteStatus CompletionStatus { get { return this.__completionStatus; } set { this.__completionStatus = value; } }

		/// <summary>
		/// Exception detail string
		/// </summary>
		private string __descr;
		
		/// <summary>
		/// GET/SET 
		///		Exception detail string
		/// </summary>
		public string Descr 
    { 
      get 
        {
          return this.__descr.Length > ReportExecutionCompleteEventArgs.DescriptionLength
                    ? this.__descr.Substring(0, ReportExecutionCompleteEventArgs.DescriptionLength)
                    : this.__descr; 
        } 
    }

		/// <summary>
		/// Start Date Time of execution for this report instance that failed
		/// </summary>
		private DateTime __executeStartTime;

		/// <summary>
		/// GET/SET
		///		- Start Date Time of execution for this report instance that failed
		/// </summary>
		public DateTime ExecuteStartTime { get { return this.__executeStartTime; } set { this.__executeStartTime = value; } }

		/// <summary>
		/// Date time when the failure happened (useful to record report execution period)
		/// </summary>
		private DateTime __executeEndTime;
		/// <summary>
		/// GET/SET 
		///		- Date time when the failure happened 
		/// </summary>
		public DateTime ExecuteEndTime { get { return this.__executeEndTime; } set { this.__executeEndTime = value; } }

		private string __paramNameValues; 

		public string ExecuteParamValues { get { return this.__paramNameValues; } set { this.__paramNameValues = value; } }

		/// <summary>
		/// CONSTRUCTOR
		/// </summary>
		/// <param name="message">String - Exception Message</param>
		/// <param name="innerException">Exception</param>
		public ReportInstanceInitializationException (string message, Exception innerException) : base (message + STANDARD_MESSAGE, innerException) 
		{ 
			this.__descr = message + "\n" + innerException.ToString();
		}

		/// <summary>
		/// CONSTRUCTOR
		/// </summary>
		/// <param name="message">String</param>
		public ReportInstanceInitializationException (string message) : base (message + STANDARD_MESSAGE) { }

		/// <summary>
		/// NULL CONSTRUCTOR
		/// </summary>
		public ReportInstanceInitializationException () : base () { }
	}
}

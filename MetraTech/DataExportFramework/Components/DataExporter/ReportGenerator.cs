using System;
using System.Collections;
using System.IO;
using MetraTech.Interop.Rowset;
using System.Data;
using System.Data.SqlClient;
using System.Xml;
using MetraTech.Interop.RCD;

namespace MetraTech.DataExportFramework.Components.DataExporter
{

	/// <summary>
	/// Enumeration that is used to indicate a report instance execution status.
	/// </summary>
	public enum ReportExecuteStatus
	{
		/// <summary>
		/// Value indicates a failure
		/// </summary>
		FAILED,
		/// <summary>
		/// Value indicates a success
		/// </summary>
		SUCCESS
	}

	/// <summary>
	/// Internal non-exposed EventArgs class that carries the Report Instance information when the callback is made
	/// </summary>
	public class ReportExecutionCompleteEventArgs : EventArgs 
	{
		/// <summary>
		/// Date time of when the execution was complete
		/// </summary>
		private DateTime __dtCompleted;
		/// <summary>
		/// GET/SET
		///	<value>Date time of when the execution was complete</value>
		/// </summary>
		public DateTime DateTimeCompleted { get { return __dtCompleted; } set { __dtCompleted = value; } }
		
		/// <summary>
		/// Status result of execution
		/// </summary>
		private ReportExecuteStatus __status;
		
		/// <summary>
		/// GET/SET
		///		<value>Status result of execution</value>
		/// </summary>
		public ReportExecuteStatus CompletionStatus { get { return __status; } set { __status = value; } }
		
		/// <summary>
		/// Report Instance Id
		/// </summary>
		private int __reportInstanceId;

		/// <summary>
		/// GET/SET
		///		<value>Report Instance Id</value>
		/// </summary>
		public int ReportInstanceID { get { return __reportInstanceId; } set { __reportInstanceId = value; } }

		/// <summary>
		/// Id that identifies the schedule for this report instance, if the report instance is a scheduled report type
		/// </summary>
		private int __scheduleId;
		
		/// <summary>
		/// GET/SET
		///		<value>Id that identifies the schedule for this report instance, if the report instance is a scheduled report type
		///		</value>
		/// </summary>
		public int ScheduleID { get { return __scheduleId; } set { __scheduleId = value; } }

		/// <summary>
		/// Identifies the type of schedule - daily/weekly/monthly
		/// </summary>
		private string __scheduleType;

		/// <summary>
		/// GET/SET
		///		<value>Identifies the type of schedule - daily/weekly/monthly</value>
		/// </summary>
		public string ScheduleType { get { return __scheduleType; } set { __scheduleType = value; } }
		
		/// <summary>
		/// Description of the execution result - holds the result of the execution.
		/// Will hold the full exception stack trace in case of failure
		/// </summary>
		private string __description;
		/// <summary>
		/// GET/SET
		///		<value>Description of the execution result - holds the result of the execution.
		///		Will hold the full exception stack trace in case of failure</value>
		/// </summary>
		public string Description { get { return __description; } set { __description = value; } }

		/// <summary>
		/// A comma seperated list of param "name=value" pairs that was passed to the report instance
		/// </summary>
		private string __executionParamValues;

		/// <summary>
		/// GET/SET
		///		<value>A comma seperated list of param "name=value" pairs that was passed to the report instance</value>
		/// </summary>
		public string ExecuteParamValues { get { return __executionParamValues; } set { __executionParamValues = value; } }

		/// <summary>
		/// Start Date Time when the report started to execute
		/// </summary>
		private DateTime __executeStartTime;

		/// <summary>
		/// GET/SET
		///		<value>Start Date Time when the report started to execute</value>
		/// </summary>
		public DateTime ExecuteStartTime { get { return __executeStartTime; } set { __executeStartTime = value; } }

		/// <summary>
		/// Actual execute time that was set for execution if this is a scheduled report instance 
		/// </summary>
		private DateTime __repToBeExecutedAt;

		/// <summary>
		/// GET/SET
		///		<value>Actual execute time that was set for execution if this is a scheduled report instance </value>
		/// </summary>
		public DateTime ReportSetToBeExecutedAt { get { return __repToBeExecutedAt; } set { __repToBeExecutedAt = value; } }

		/// <summary>
		/// This report instance's id on the work queue
		/// </summary>
		private string __workQId;

		/// <summary>
		/// Report instance's field Def File
		/// </summary>
		private string __fieldDefFileUsed = "NONE USED";
		public string FieldDefFileUsed { get { return __fieldDefFileUsed; } set { __fieldDefFileUsed = value; } }

		/// <summary>
		/// GET/SET
		///		<value>This report instance's id on the work queue</value>
		/// </summary>
		public string WorkQId { get { return __workQId; } set { __workQId = value; } }

		/// <summary>
		/// NULL CONSTRUCTOR
		/// </summary>
		public ReportExecutionCompleteEventArgs() : base () { }

		/// <summary>
		///		CONSTRUCTOR
		/// </summary>
		/// <param name="ctime">DateTime when the report execution completed and callback is made</param>
		/// <param name="status">ReportExecuteStatus - SUCCESS or FAILURE</param>
		public ReportExecutionCompleteEventArgs(DateTime ctime, ReportExecuteStatus status)
		{
			this.__dtCompleted = ctime;
			this.__status = status;
		}
	}

	/// <summary>
	/// Delegate for handling the Report Execution complete Callback
	/// </summary>
	public delegate void ReportExecutionCompleteHandler(object sender, ReportExecutionCompleteEventArgs e);

	/// <summary>
	/// Internal class that does all the mapping between the different types of report instances and creates the 
	/// appropriate instance of IReportInstance to execute the report request.
	/// This also handles the callback on completion of the report instance execute
	/// </summary>
	public class ReportGenerator
	{
		/// <summary>
		/// Callback Event definition
		/// </summary>
		public event ReportExecutionCompleteHandler ReportCompletedEvent;

		/// <summary>
		/// XML DOM instance that holds the reference to the Reporting Framework config XML file
		/// </summary>
		private XmlDocument __doc;

		/// <summary>
		/// GET/SET
		///		<value>XML DOM instance that holds the reference to the Reporting Framework config XML file</value>
		/// </summary>
		public XmlDocument ConfigXML { get { return __doc; } set { __doc = value; } }

		/// <summary>
		/// IReportInstance that will be initialized and executed based on the report instance type found in the work queue
		/// </summary>
		/// <remarks>This is a private variable and not exposed as a property</remarks>
		private IReportInstance __reportInstance;
		
		/// <summary>
		/// ID that identifies the report instance
		/// </summary>
		private int __reportInstanceId;

		/// <summary>
		/// GET/SET
		///	<value>ID that identifies the report instance</value>
		/// </summary>
		public int ReportInstanceID { get { return __reportInstanceId; } set { __reportInstanceId = value; } }
		
		/// <summary>
		/// ID that identifies the Report Definition
		/// </summary>
		private int __reportId;

		/// <summary>
		/// GET/SET
		/// <value>ID that identifies the Report Definition</value>
		/// </summary>
		public int ReportID { get { return __reportId; } set { __reportId = value; } }
		
		/// <summary>
		/// ID that identifies the execution schedule for this report instance, if this is a scheduled report
		/// </summary>
		private int __scheduleId;
		
		/// <summary>
		/// GET/SET
		/// <value>ID that identifies the execution schedule for this report instance, if this is a scheduled report</value>
		/// </summary>
		public int ScheduleID { get { return __scheduleId; } set { __scheduleId = value; } }
		
		/// <summary>
		/// Identifies the schedule type (daily/weekly/monthly)
		/// combination of idSchedule and scheduletype helps retrieve the schedule information
		/// </summary>
		private string __scheduleType;

		/// <summary>
		/// GET/SET
		/// <value>Identifies the schedule type (daily/weekly/monthly)
		/// combination of idSchedule and scheduletype helps retrieve the schedule information</value>
		/// </summary>
		public string Scheduletype { get { return __scheduleType; } set { __scheduleType = value; } }
		
		/// <summary>
		/// Identifies the type of Report (query/crystal/perl/vbscript/datafeed)
		/// </summary>
		private string __reportType;

		/// <summary>
		/// GET/SET
		///	<value>Identifies the type of Report (query/crystal/perl/vbscript/datafeed)</value>
		/// </summary>
		public string Reporttype { get { return __reportType; } set { __reportType = value; } }

		/// <summary>
		/// temporary working folder for all report executions
		/// reports are created as .tmp files in this folder before getting delivered to the specified destination
		/// </summary>
		private string __reportsWorkingFolder;

		/// <summary>
		/// GET/SET
		/// <value>temporary working folder for all report executions
		/// reports are created as .tmp files in this folder before getting delivered to the specified destination</value>
		/// </summary>
		public string ReportsWorkingFolder { get { return __reportsWorkingFolder; } set { __reportsWorkingFolder = value; } }


		/// <summary>
		/// Start Date Time when the report started to execute
		/// </summary>
		private DateTime __executeStartTime;

		/// <summary>
		/// GET/SET
		/// <value>Start Date Time when the report started to execute</value>
		/// </summary>
		public DateTime ExecuteStartTime { get { return __executeStartTime; } set { __executeStartTime = value; } }

		/// <summary>
		/// This report instance's id on the work queue
		/// </summary>
		private string __workQId;

	  private IConfiguration _config = ConfigurationSimple.Instance;
		/// <summary>
		/// GET/SET
		/// <value>This report instance's id on the work queue</value>
		/// </summary>
		public string WorkQId { get { return __workQId; } set { __workQId = value; } }

		/// <summary>
		/// CONSTRUCTOR
		///		Initializes the Report Generator with information about the report instance that needs to be executed.
		/// </summary>
		/// <param name="workQID">GUID - This report instance's id on the work queue</param>
		/// <param name="ReportId">INT - ID that identifies the Report Definition</param>
		/// <param name="ReportInstanceId">INT - ID that identifies the Report Instance</param>
		/// <param name="ScheduleId">INT - ID that identifies the execution schedule for this report instance, if this is a scheduled report</param>
		/// <param name="Scheduletype">STRING - Identifies the schedule type (daily/weekly/monthly)
		/// combination of idSchedule and scheduletype helps retrieve the schedule information</param>
		/// <param name="ReportType">STRING - Identifies the type of Report (query/crystal/perl/vbscript/datafeed)</param>
		/// <param name="ReportTitle">STRING - Title of the Report Definition</param>
		/// <remarks>this.__reportInstance is assigned an instance of a derived class of BaseReportInstance 
		///		based on the report type
		///		If an exception is thrown in the constructor call of the corresponding IReportInstance, this is captured
		///		and a ReportInstanceInitializationException is thrown with error information set to this object
		///		</remarks>
		public ReportGenerator(string workQID, int ReportId, int ReportInstanceId, int ScheduleId, string Scheduletype, string ReportType, string ReportTitle)
		{
			this.__workQId = workQID;
			this.__reportId = ReportId;
			this.__reportInstanceId = ReportInstanceId;
			this.__scheduleId = ScheduleId;
			this.__scheduleType = Scheduletype;
			this.__reportType = ReportType;
            //System.Threading.Thread t = System.Threading.Thread.CurrentThread.ManagedThreadId.ToString();
            //logerr.logt.ManagedThreadId
            //string t = System.Threading.Thread.CurrentThread.ManagedThreadId.ToString();
            //Common.MakeLogEntry("ReportGeneratorTrackingStart: workQId=" + workQID + " ThreadID=" + t, "error");
			try 
			{
				switch (this.__reportType.ToLower())
				{
					case "query":
						this.__reportInstance = new QueryReportInstance(this.__workQId, this.__reportId, this.__reportInstanceId, this.__scheduleId, this.__scheduleType, ReportTitle);
						break;
					//case "crystal":
					//	this.__reportInstance = new CrystalReportInstance(this.__workQId, this.__reportId, this.__reportInstanceId, this.__scheduleId, this.__scheduleType, ReportTitle);
					//	break;
					//case "perl":
					//	this.__reportInstance = new PerlReportInstance(this.__workQId, this.__reportId, this.__reportInstanceId, this.__scheduleId, this.__scheduleType, ReportTitle);
					//	break;
						/*case "datafeed":
							this.__reportInstance = new DataFeedReportInstance(this.__workQId, this.__reportId, this.__reportInstanceId, this.__scheduleId, this.__scheduleType, ReportTitle);
							break;*/
					//case "vbscript":
					//	this.__reportInstance = new VBScriptReportInstance(this.__workQId, this.__reportId, this.__reportInstanceId, this.__scheduleId, this.__scheduleType, ReportTitle);
					//	break;
				}
			}
			catch (ReportExecutionAlreadyInProgressException rEx)
			{
				throw (rEx);
			}
			catch (ReportExecutionAlreadyCompleteException rEx)
			{
				throw (rEx);
			}
			catch (Exception ex)
			{
				Common.MakeLogEntry("Constructor Exception for Report Instance-"+this.__reportInstanceId.ToString(), "error");
				ReportInstanceInitializationException _rIEx = new ReportInstanceInitializationException("", ex);
				_rIEx.WorkQId = this.__workQId;
				_rIEx.CompletionStatus = ReportExecuteStatus.FAILED;
				_rIEx.ExecuteStartTime = DateTime.Now;
				_rIEx.ExecuteEndTime = DateTime.Now;
                try
                {
                    _rIEx.ExecuteParamValues = this.__reportInstance.ExecutionParameters;
                }
                catch
                {
                    //A bad parm must have been passed in - to give the user some idea what went wrong - we will pass the workqueue values through here via the execute audit SP.    
                    _rIEx.ExecuteParamValues = "Bad Parms passed - see MTLOG: ";
                }
				throw (_rIEx);
			}
			this.__executeStartTime = this.__reportInstance.ExecuteStartDatetime;
		}

		/// <summary>
		/// SINGLE THREADED CALLS TO START OFF REPORT GENERATION. 
		/// </summary>
		#region Single Threaded Execute
		public void SingleThreadedExecute()
		{
			this.__reportInstance.ReportsWorkingFolder = __reportsWorkingFolder;
			this.__reportInstance.ConfigXML = __doc;
			
			try 
			{
				this.__reportInstance.Execute();
			}
			catch (Exception ex)
			{
				Common.MakeLogEntry("Report Exection Exception:\n"+ex.ToString(), "error");
			}
		}
		#endregion

		/// <summary>
		/// Starts off the execute on the initialized IReportInstance.
		/// </summary>
		/// <param name="stateinfo">calling object instance</param>
		public void Execute(object stateinfo)
		{
			ReportExecutionCompleteEventArgs _rE = new ReportExecutionCompleteEventArgs();
			_rE.ExecuteStartTime = this.__reportInstance.ExecuteStartDatetime;
			_rE.ReportSetToBeExecutedAt = this.__reportInstance.ThisReportSetTobeExecutedAt;
			this.__reportInstance.ReportsWorkingFolder = __reportsWorkingFolder;
			this.__reportInstance.ConfigXML = __doc;

			_rE.ReportInstanceID = this.__reportInstanceId;
			_rE.ScheduleID = this.__scheduleId;
			_rE.ScheduleType = this.__scheduleType;
			_rE.ExecuteParamValues = this.__reportInstance.ExecutionParameters;
			_rE.WorkQId = this.__workQId;
            //bool exceptionOccurred = false;
            //string t = System.Threading.Thread.CurrentThread.ManagedThreadId.ToString();
            //Common.MakeLogEntry("ReportGeneratorTrackingCallback: workQId=" + this.__workQId + " ThreadID=" + t, "error");
            try
            {
                //LogWriter.LogDebug("ReportGenerator", "Begin Execute ReportInstance, type" + this.__reportInstance.GetType().ToString() );
                this.__reportInstance.Execute();
                _rE.Description = "Successfully completed. " + this.__reportInstance.ExecuteDescription;
                _rE.CompletionStatus = ReportExecuteStatus.SUCCESS;
                _rE.FieldDefFileUsed = FieldDefFile(this.__reportInstance.Title, this.__reportInstanceId);
            }
            catch (Exception ex)
            {
                //exceptionOccurred = true;
                _rE.Description = ex.ToString().Replace("%", "");
                _rE.CompletionStatus = ReportExecuteStatus.FAILED;
                Common.MakeLogEntry("Report Exection Exception:\n" + ex.ToString(), "error");
            }
            finally
            {
                //fire the completed event
                _rE.DateTimeCompleted = DateTime.Now;
                ReportCompletedEvent(this, _rE);
            }
		}

		private string FieldDefFile(string reportTitle, int reportInstanceId)
		{
		  string fielDef = Path.Combine(_config.GetFieldDefDir(), String.Format("{0}.xml", reportTitle));
      if (!System.IO.File.Exists(fielDef))
      {
        fielDef = Path.Combine(_config.GetFieldDefDir(), String.Format("{0}_{1}.xml", reportTitle, reportInstanceId));
      }
      else if (!System.IO.File.Exists(fielDef))
      {
        fielDef = "NONE USED"; 
      }
			
      return fielDef; 
		}
	}


	public class FieldDefConfigFileLoadException : System.Exception
	{
		public FieldDefConfigFileLoadException (string message, Exception innerException) : base (message, innerException)  {  }
		public FieldDefConfigFileLoadException (string message) : base (message) { }
		public FieldDefConfigFileLoadException () : base () { }
	}

	public class ReportExecutionAlreadyInProgressException : System.Exception
	{
		public ReportExecutionAlreadyInProgressException (string message, Exception innerException) : base (message, innerException)  {  }
		public ReportExecutionAlreadyInProgressException (string message) : base (message) { }
		public ReportExecutionAlreadyInProgressException () : base () { }
	}

	public class ReportExecutionAlreadyCompleteException : System.Exception
	{
		public ReportExecutionAlreadyCompleteException  (string message, Exception innerException) : base (message, innerException)  {  }
		public ReportExecutionAlreadyCompleteException  (string message) : base (message) { }
		public ReportExecutionAlreadyCompleteException  () : base () { }
	}
	
	public class CrystalReportExecutionThrewOutOfLicenseTimeoutException : System.Exception
	{
		private const string __MESSAGE_ = "Multiple OutofLicense exception were thrown by the Cystal Reports Engine.";
		public CrystalReportExecutionThrewOutOfLicenseTimeoutException (string message, Exception innerException) : base (__MESSAGE_+message, innerException)  {  }
		public CrystalReportExecutionThrewOutOfLicenseTimeoutException (string message) : base (__MESSAGE_+message) { }
		public CrystalReportExecutionThrewOutOfLicenseTimeoutException () : base () { }
	}

}

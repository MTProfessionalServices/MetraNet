using System;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;

namespace MetraTech.DataExportFramework.Adapters.QueueScheduledReportsAdapter
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	public class QueueScheduledReportsAdapter : IRecurringEventAdapter
	{
    private bool _mbInitialized;
    private readonly bool _mbSupportsScheduledEvents;
    private readonly bool _mbSupportsEndOfPeriodEvents = true;
    private const ReverseMode MEnReversibility = ReverseMode.Custom;
    private const bool MbAllowMultipleInstances = false;
		private readonly Logger _moLogger;
	  private const string MName = "QueueScheduledReportsAdapter";

	  private string _msQueueTag;
		private string _msReverseQueueTag;
		private string _msQueryPath;
    private string _msSplitReverseQueueTag;

		public QueueScheduledReportsAdapter()
		{	
			_moLogger = new Logger("[QUEUESCHEDULEDREPORTSADAPTER]");
			_mbInitialized = false;
			_mbSupportsEndOfPeriodEvents = false;
			_mbSupportsScheduledEvents = true;
		}

		/// <summary>
		/// Returns a bool with information about scheduled event support.
		/// This information is gathered in the Initialize method from the config XML file.
		/// This Attribute has to be queried only after the "Initialize" method has been called.
		/// </summary>
		public bool SupportsScheduledEvents
		{
			get { return _mbSupportsScheduledEvents; }
		}

		/// <summary>
		/// Returns a bool with information about EOP event support.
		/// This information is gathered in the Initialize method from the config XML file.
		/// This Attribute has to be queried only after the "Initialize" method has been called.
		/// </summary>
		public bool SupportsEndOfPeriodEvents
		{
			get { return _mbSupportsEndOfPeriodEvents; }
		}

		/// <summary>
		/// Returns the Reversibility configuration of the adapter.
		/// Value is set after the Initialize method is executed from the config XML file.
		/// Defaults to ReverseMove.NotNeeded is no value is set.
		/// </summary>
		public ReverseMode Reversibility
		{
			get { return MEnReversibility; }
		}

		/// <summary>
		/// Returns the AllowMultipleInstances configuration of the adapter.
		/// This information is gathered in the Initialize method from the config XML file.
		/// This Attribute has to be queried only after the "Initialize" method has been called.
		/// </summary>
		public bool AllowMultipleInstances
		{
			get { return MbAllowMultipleInstances; }
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
				_moLogger.LogDebug("Starting initialization...");
				if(!bLimitedInit)
				{
					ReadConfig(sConfigFile);
				}

				_mbInitialized = true;
				_moLogger.LogDebug("Initialization completed.");
			}
			catch(Exception e)
			{
				_moLogger.LogError("An error occurred during initialization: " + e.Message + "  Inner Exception: " + e.InnerException.Message);
				throw;
			}
		}

		private void ReadConfig(string sConfigFile)
		{
			var oDoc = new XmlDocument();
			oDoc.Load(sConfigFile);

		  try
		  {
		    _msQueryPath = oDoc.SelectSingleNode("xmlconfig/schreports/query/path").InnerText;
		    _msQueueTag = oDoc.SelectSingleNode("xmlconfig/schreports/query/queuetag").InnerText;
		    _msReverseQueueTag = oDoc.SelectSingleNode("xmlconfig/schreports/query/reversetag").InnerText;
		    try
		    {
		      _msSplitReverseQueueTag = oDoc.SelectSingleNode("xmlconfig/schreports/query/pulllisttag").InnerText;
		    }
		    catch
		    {
		      _msSplitReverseQueueTag = String.Empty;
		    }
		  }
		  catch (Exception ex)
		  {
		    throw new Exception("ReadConfig error!", ex);
		  }
		}

	  public string Execute(IRecurringEventRunContext oContext)
	  {
	    _moLogger.LogDebug("Executing...");
	    if (!_mbInitialized)
	      return ("Adapter not initialized");
	    
	    using(var cn = ConnectionManager.CreateConnection())
	    using(var selectst = cn.CreateAdapterStatement(_msQueryPath, _msQueueTag))
	    {
	      // Values used in the query today
	      selectst.AddParamIfFound("%%ID_RUN%%", oContext.RunID);
	      selectst.AddParamIfFound("%%METRATIME%%", MetraTime.Now.ToLocalTime());

	      // Expansion values, so we never have to recompile to change the query...
	      selectst.AddParamIfFound("%%ID_BILLGROUP%%", oContext.BillingGroupID);
	      selectst.AddParamIfFound("%%ID_INTERVAL%%", oContext.UsageIntervalID);
	      selectst.AddParamIfFound("%%START_DATE%%", oContext.StartDate);
	      selectst.AddParamIfFound("%%END_DATE%%", oContext.EndDate);

	      var rows = selectst.ExecuteNonQuery();
	      oContext.RecordInfo(rows + " Scheduled Reports were successfully Queued to the WorkQueue for execution");
	      return ("Executed successfully");
	    }
	  }

	  public void CreateBillingGroupConstraints(int intervalID, int materializationID)
    {
      _moLogger.LogDebug(string.Concat(MName, ". CreateBillingGroupConstraints  nothing to do."));
    }

	  public void SplitReverseState(int parentRunId, int parentBillingGroupId, int childRunId, int childBillingGroupId)
	  {
	    _moLogger.LogDebug("Executing...");
	    if (!_mbInitialized)
	    {
	      _moLogger.LogInfo(String.Concat(MName, " is not initialized, can not create pull list."));
	      return;
	    }

	    if (String.IsNullOrEmpty(_msSplitReverseQueueTag) ||
	        String.IsNullOrWhiteSpace(_msSplitReverseQueueTag.Trim()))
	      return;

	    using(var cn = ConnectionManager.CreateConnection())
	    using (var selectst = cn.CreateAdapterStatement(_msQueryPath, _msSplitReverseQueueTag))
	    {
	      // Values used in the query today
	      selectst.AddParamIfFound("%%PARENT_ID_RUN%%", parentRunId);
	      selectst.AddParamIfFound("%%PARENT_ID_BILLGROUP%%", parentBillingGroupId);
	      selectst.AddParamIfFound("%%CHILD_ID_RUN%%", childRunId);
	      selectst.AddParamIfFound("%%CHILD_ID_BILLGROUP%%", childBillingGroupId);
	      selectst.AddParamIfFound("%%METRATIME%%", MetraTime.Now.ToLocalTime());
	      selectst.ExecuteNonQuery();
	    }
	  }

	  public string Reverse(IRecurringEventRunContext oContext)
	  {
	    _moLogger.LogDebug("Executing...");
	    if (!_mbInitialized) 
        return ("Adapter not initialized");
	    
      using(var cn = ConnectionManager.CreateConnection())
      using (var selectst = cn.CreateAdapterStatement(_msQueryPath, _msReverseQueueTag))
	    {
	      selectst.AddParam("%%ID_RUN%%", oContext.RunIDToReverse, true);
        // Expansion values, so we never have to recompile to change the query...
	      selectst.AddParamIfFound("%%METRATIME%%", MetraTime.Now.ToLocalTime());
	      selectst.AddParamIfFound("%%ID_BILLGROUP%%", oContext.BillingGroupID);
	      selectst.AddParamIfFound("%%ID_INTERVAL%%", oContext.UsageIntervalID);
	      selectst.AddParamIfFound("%%START_DATE%%", oContext.StartDate);
	      selectst.AddParamIfFound("%%END_DATE%%", oContext.EndDate);

	      var rows = selectst.ExecuteNonQuery();
	      oContext.RecordInfo(rows + " Scheduled Reports were successfully Removed from the WorkQueue");
	      oContext.RecordWarning(
	        "If the reversed number is less than the Queued number, some reports have already picked up for execution by the Reporting Framework.");
	      return ("Reversed successfully");
	    }
	  }

	  public void Shutdown()
		{
			//Nothing to do here.
		}
	}
}

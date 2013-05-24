using System;
using MetraTech.DataAccess;

namespace MetraTech.Test.Common
{
  public class MetraNetBillingEvent
  {
    private DateTime mMetraTime;
    public DateTime MetraTime { get { return mMetraTime; } }
    protected MetraNetBillingEvent(DateTime metraTime)
    {
      mMetraTime = metraTime;
    }
  };

  /// An event of this type represents a request to advance
  /// MetraTime to the appropriate point. 
  public class MetraTimeEvent : MetraNetBillingEvent
  {
    public MetraTimeEvent(DateTime metraTime)
    :
    base(metraTime)
    {
    }
  }

  // An event of this type represents a request to run an interval adapter
  public class IntervalAdapterEvent : MetraNetBillingEvent
  {
    private int mIntervalID;

    public int IntervalID { get { return mIntervalID; } }
    
    private string mAdapterName;

    public string AdapterName { get { return mAdapterName; } }

    public IntervalAdapterEvent(DateTime metraTime, string cycleType, DateTime intervalEnd, string adapterName)
    :
    base(metraTime)
    {
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            mIntervalID = -1;
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "select ui.id_interval from t_usage_interval ui " +
              "inner join t_usage_cycle uc on uc.id_usage_cycle=ui.id_usage_cycle " +
              "inner join t_usage_cycle_type uct on uct.id_cycle_type=uc.id_cycle_type " +
              "where uct.tx_desc=? and ui.dt_end=?"))
            {

                stmt.AddParam(MTParameterType.String, cycleType);
                stmt.AddParam(MTParameterType.DateTime, intervalEnd);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    mIntervalID = reader.GetInt32("id_interval");
                }
            }
        }
      if (mIntervalID == -1)
        throw new ApplicationException(string.Format("Couldn't find interval with cycleType={0} and end date={1}. Do you need to run usm create?",
                                                     cycleType, intervalEnd));
      mAdapterName = adapterName;
    }
  }

  // An event of this type represents a request to run a scheduled adapter
  public class ScheduledAdapterEvent : MetraNetBillingEvent
  {
    private DateTime mRunEndDate;

    public DateTime RunEndDate { get { return mRunEndDate; } }
    
    private string mAdapterName;
    public string AdapterName { get { return mAdapterName; } }

    public ScheduledAdapterEvent(DateTime metraTime, DateTime runEndDate, string adapterName)
    :
    base(metraTime)
    {
      mRunEndDate = runEndDate;
      mAdapterName = adapterName;
    }
    public ScheduledAdapterEvent(DateTime metraTime, string adapterName)
    :
    base(metraTime)
    {
      mRunEndDate = DateTime.Parse("2038-01-01");
      mAdapterName = adapterName;
    }
  }

  class IntervalLogRecord
  {
    private int mIntervalID;
    private bool mMaterializedBillgroups;
    public bool MaterializedBillgroups
    {
      get { return mMaterializedBillgroups; }
      set { mMaterializedBillgroups = value; }
    }

    private bool mSoftClosedInterval;
    public bool SoftClosedInterval
    {
      get { return mSoftClosedInterval; }
      set { mSoftClosedInterval = value; }
    }
    private System.Collections.Generic.List<string> mAdapters;
    public bool IsAdapterRun(string adapter)
    {
      return mAdapters.Contains(adapter);
    }
    public void RunAdapter(string adapter)
    {
      mAdapters.Add(adapter);
    }

    public IntervalLogRecord(int intervalID)
    {
      mIntervalID = intervalID;
      mMaterializedBillgroups = false;
      mSoftClosedInterval = false;
      mAdapters = new System.Collections.Generic.List<string>();
    }
  };

  class ScheduledLogRecord
  {
    private string mEventName;
    private DateTime mLastRun;
    public DateTime LastRun { get { return mLastRun; } }

    public void RunAdapter(DateTime lastRun)
    {
      mLastRun = lastRun;
    }

    public ScheduledLogRecord(string eventName)
    {
      mEventName = eventName;
      mLastRun = DateTime.Parse("1970-01-01");
    }
  }

  public class MetraNetBillingTestScheduler
  {
    private System.Collections.Generic.List<System.Collections.Generic.IEnumerable<MetraNetBillingEvent> > mTests;
    private MetraTech.UsageServer.Client mClient;
    private MetraTech.Interop.MetraTime.IMetraTimeControl mTimeControl;
		private MetraTech.Interop.MTAuth.IMTSessionContext mSUCtx = null;
    

    public MetraNetBillingTestScheduler()
    {
      mTests = new System.Collections.Generic.List<System.Collections.Generic.IEnumerable<MetraNetBillingEvent> >();
			mSUCtx = Utils.LoginAsSU();
      mClient = new MetraTech.UsageServer.Client();
      mClient.SessionContext = mSUCtx;
      mTimeControl = (MetraTech.Interop.MetraTime.IMetraTimeControl) new MetraTech.Interop.MetraTime.MetraTimeControl();
    }

    public void AddTest(System.Collections.Generic.IEnumerable<MetraNetBillingEvent> test)
    {
      mTests.Add(test);
    }

    public void RunIntervalAdapter(string adapterName, int intervalID)
    {
      int recurringChargeInstanceID = -1;

      // For each bill group get the list of events to submit and submit them ignoring dependencies
      using (MetraTech.DataAccess.IMTConnection conn = MetraTech.DataAccess.ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
          using (MetraTech.DataAccess.IMTStatement stmt = conn.CreateStatement(
            string.Format("select id_instance from t_recevent_inst rei where rei.id_arg_interval={0} and id_event in (select id_event from t_recevent where tx_name in ('{1}'))", intervalID, adapterName)))
          {
              using (MetraTech.DataAccess.IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      recurringChargeInstanceID = reader.GetInt32("id_instance");
                  }
              }
          }
      }

      mClient.SubmitEventForExecution(recurringChargeInstanceID, true, "UnitDependentRecurringChargeSeatChangeAccrual");
			int executions, executionFailures;
			int reversals, reversalFailures;
			mClient.ProcessEvents(out executions, out executionFailures, 
				out reversals, out reversalFailures);

    }

    public void Run()
    {
      // Initialize all tests.
      System.Collections.Generic.List<System.Collections.Generic.IEnumerator<MetraNetBillingEvent> > instances = new System.Collections.Generic.List<System.Collections.Generic.IEnumerator<MetraNetBillingEvent> >();

      // Process all test events using a sorted merge on the event timestamp.
      // Make sure that duplicate requests are not played back multiple times.
      foreach(System.Collections.Generic.IEnumerable<MetraNetBillingEvent> e in mTests)
      {
        System.Collections.Generic.IEnumerator<MetraNetBillingEvent> be = e.GetEnumerator();
        if (be.MoveNext())
        {
          instances.Add(be);
        }
      }

      DateTime currentTime = DateTime.Parse("1970-01-01");
      System.Collections.Generic.Dictionary<int, IntervalLogRecord> intervalLog = new System.Collections.Generic.Dictionary<int, IntervalLogRecord>();
      System.Collections.Generic.Dictionary<string, ScheduledLogRecord> scheduledLog = new System.Collections.Generic.Dictionary<string, ScheduledLogRecord>();
      while(instances.Count > 0)
      {
        // Inefficient.  Should use a priorty queue.  TODO: Find one.
        System.Collections.Generic.IEnumerator<MetraNetBillingEvent> nextEvent = null;
        foreach(System.Collections.Generic.IEnumerator<MetraNetBillingEvent> be in instances)
        {
          if (nextEvent == null || be.Current.MetraTime < nextEvent.Current.MetraTime)
            nextEvent = be;
        }

        // All events have a timestamp.  We move MetraTime accordingly.
        if (nextEvent.Current.MetraTime < currentTime)
        {
          throw new ApplicationException("Tests can't rewind MetraTime");
        }
        else if (nextEvent.Current.MetraTime > currentTime)
        {
          // Note that there is ambiguity here about the time, since events
          // actually take time so it is possible that if an event starts before
          // midnight and ends afterward we will make MetraTime move backward...
          mTimeControl.SetSimulatedOLETime(nextEvent.Current.MetraTime);
          currentTime = nextEvent.Current.MetraTime;
          mClient.CreateUsageIntervals();
        }

        // TODO: Architecture Issue!
        // How do we get the bird's eye view of which adapters different tests want to have run?
        // Two different tests may have non-overlapping adapters they want to run and these 
        // may have dependencies that cannot be expressing in a modular way within each test.
        // If we assume that tests submit their requests for processing adapters on the same 
        // time then we can read ahead to get all of the processing steps and apply the dependency logic
        // before executing any of the adapters.

        // If we have request to do some bill processing, do it now.
        if (nextEvent.Current is IntervalAdapterEvent)
        {
          IntervalAdapterEvent intervalAdapter = nextEvent.Current as IntervalAdapterEvent;

          // Figure out whether we need to materialize bill groups and soft close the interval.
          if (!intervalLog.ContainsKey(intervalAdapter.IntervalID))
          {
            IntervalLogRecord ilr = new IntervalLogRecord(intervalAdapter.IntervalID);
            int materializationID = mClient.MaterializeBillingGroups(intervalAdapter.IntervalID);
            ilr.MaterializedBillgroups = true;
            mClient.SoftCloseUsageInterval(intervalAdapter.IntervalID);
            ilr.SoftClosedInterval = true;
            intervalLog.Add(intervalAdapter.IntervalID, ilr);
          }
          // Note that we are not supporting reversal.
          IntervalLogRecord log = intervalLog[intervalAdapter.IntervalID];    
          if (!log.IsAdapterRun(intervalAdapter.AdapterName))
          {
            RunIntervalAdapter(intervalAdapter.AdapterName, intervalAdapter.IntervalID);
            log.RunAdapter(intervalAdapter.AdapterName);
          }
        }
        else if (nextEvent.Current is ScheduledAdapterEvent)
        {
          ScheduledAdapterEvent scheduledAdapter = nextEvent.Current as ScheduledAdapterEvent;
          if (!scheduledLog.ContainsKey(scheduledAdapter.AdapterName))
          {
            ScheduledLogRecord slr = new ScheduledLogRecord(scheduledAdapter.AdapterName);
            scheduledLog.Add(scheduledAdapter.AdapterName, slr);
          }
          ScheduledLogRecord log = scheduledLog[scheduledAdapter.AdapterName];
          if (log.LastRun < scheduledAdapter.MetraTime)
          {
            log.RunAdapter(scheduledAdapter.MetraTime);
            int accrualReportInstanceID = mClient.InstantiateScheduledEvent(mClient.GetEventByName(scheduledAdapter.AdapterName).EventID);
            mClient.SubmitEventForExecution(accrualReportInstanceID, true, "UnitDependentRecurringChargeSeatChangeAccrual");
            int executions, executionFailures;
            int reversals, reversalFailures;
            mClient.ProcessEvents(out executions, out executionFailures, 
                                  out reversals, out reversalFailures);
          }
        }

          // Yield back to the test and if the test is done remove from the scheduler.
        if (!nextEvent.MoveNext())
        {
          instances.Remove(nextEvent);
        }
      }
    }
  } 
}

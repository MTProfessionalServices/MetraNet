using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Globalization;
using System.Threading;
using System.Workflow.ComponentModel;
using System.Workflow.Runtime;
using System.Workflow.Runtime.Hosting;
using System.Transactions;

using MetraTech.DataAccess;

namespace MetraTech.ActivityServices.PersistenceService
{
  public sealed class MTWorkflowPersistenceService : WorkflowPersistenceService, IPendingWork, IDisposable
  {
    private Logger m_Logger;

    private MTWorkflowDbAccessor m_DBAccessor = null;

    private TimeSpan _ownershipDelta;
    private TimeSpan maxLoadingInterval;
    private object timerLock;
    private TimeSpan infinite;
    private bool _unloadOnIdle;
    private NameValueCollection configParameters;
    private SmartTimer loadingTimer;

    private Guid _serviceInstanceId;

    public Guid ServiceInstanceId
    {
      get { return _serviceInstanceId; }
      set { _serviceInstanceId = value; }
    }

    public DateTime OwnershipTimeout
    {
      get
      {
        if (_ownershipDelta == TimeSpan.MaxValue)
        {
          return DateTime.MaxValue;
        }
        return (DateTime.UtcNow + _ownershipDelta);
      }
    }

    private bool _enableRetries;

    public bool EnableRetries
    {
      get { return _enableRetries; }
      set
      {
        _enableRetries = value;
      }
    }

    private TimeSpan loadingInterval;

    public TimeSpan LoadingInterval
    {
      get { return loadingInterval; }
      set { loadingInterval = value; }
    }

    /// <summary>
    /// WARNING: For testing only, constructor not to be included in final release.
    /// </summary>
    public MTWorkflowPersistenceService()
      : base()
    {
      loadingInterval = TimeSpan.FromMinutes(5.0);
      _unloadOnIdle = true;
      timerLock = new object();
      infinite = new TimeSpan(-1);
      maxLoadingInterval = new TimeSpan(0x16d, 0, 0, 0, 0);

      //Used for concurrency in a web/application environment.
      _serviceInstanceId = Guid.NewGuid();
      _ownershipDelta = TimeSpan.FromMinutes(1.0);

      m_Logger = new Logger(string.Format("[MTWorkflowPersistenceService:{0}]", _serviceInstanceId.ToString()));
    }

    ~MTWorkflowPersistenceService()
    {
      Dispose();
    }

    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="unloadOnIdle"></param>
    /// <param name="instanceOwnershipDuration"></param>
    /// <param name="loadingInterval"></param>
    public MTWorkflowPersistenceService(bool unloadOnIdle,
                                        TimeSpan instanceOwnershipDuration,
                                        TimeSpan loadingInterval)
      : base()
    {
      _serviceInstanceId = Guid.Empty;
      this.loadingInterval = new TimeSpan(0, 2, 0);
      maxLoadingInterval = new TimeSpan(0x16d, 0, 0, 0, 0);
      timerLock = new object();
      infinite = new TimeSpan(-1);

      if (loadingInterval > maxLoadingInterval)
      {
        throw new ArgumentOutOfRangeException("loadingInterval", loadingInterval, "LoadingIntervalTooLarge");
      }
      if (instanceOwnershipDuration < TimeSpan.Zero)
      {
        throw new ArgumentOutOfRangeException("instanceOwnershipDuration", instanceOwnershipDuration,
                                              "InvalidOwnershipTimeoutValue");
      }

      _ownershipDelta = instanceOwnershipDuration;
      _unloadOnIdle = unloadOnIdle;
      this.loadingInterval = loadingInterval;
      _serviceInstanceId = Guid.NewGuid();

      m_Logger = new Logger(string.Format("[MTWorkflowPersistenceService:{0}]", _serviceInstanceId.ToString()));
    }

    /// <summary>
    /// parameters set various configurations in the service. e.g unloadonidle 
    /// </summary>
    /// <param name="parameters"></param>
    public MTWorkflowPersistenceService(NameValueCollection parameters)
      : base()
    {
      try
      {
        _serviceInstanceId = Guid.Empty;
        loadingInterval = new TimeSpan(0, 2, 0);
        maxLoadingInterval = new TimeSpan(0x16d, 0, 0, 0, 0);
        timerLock = new object();
        infinite = new TimeSpan(-1);

        if (parameters == null)
        {
          throw new ArgumentNullException("parameters", "MissingParameters");
        }

        _ownershipDelta = TimeSpan.MaxValue;

        if (parameters != null)
        {
          foreach (string key in parameters.Keys)
          {
            if (!key.Equals("Database", StringComparison.OrdinalIgnoreCase))
            {
              if (key.Equals("OwnershipTimeoutSeconds", StringComparison.OrdinalIgnoreCase))
              {
                int ownershipTimeoutSeconds =
                    Convert.ToInt32(parameters["OwnershipTimeoutSeconds"], CultureInfo.CurrentCulture);
                if (ownershipTimeoutSeconds < 0)
                {
                  throw new ArgumentOutOfRangeException("OwnershipTimeoutSeconds",
                                                        ownershipTimeoutSeconds,
                                                        "InvalidOwnershipTimeoutValue");
                }
                _ownershipDelta = new TimeSpan(0, 0, ownershipTimeoutSeconds);
                _serviceInstanceId = Guid.NewGuid();

                m_Logger = new Logger(string.Format("[MTWorkflowPersistenceService:{0}]", _serviceInstanceId.ToString()));
              }
              else
              {
                if (key.Equals("UnloadOnIdle", StringComparison.OrdinalIgnoreCase))
                {
                  _unloadOnIdle = bool.Parse(parameters[key]);
                  continue;
                }
                if (key.Equals("LoadIntervalSeconds", StringComparison.OrdinalIgnoreCase))
                {
                  int loadingIntervalSeconds = int.Parse(parameters[key], CultureInfo.CurrentCulture);
                  if (loadingIntervalSeconds > 0)
                  {
                    loadingInterval = new TimeSpan(0, 0, loadingIntervalSeconds);
                  }
                  else
                  {
                    loadingInterval = TimeSpan.Zero;
                  }
                  if (loadingInterval > maxLoadingInterval)
                  {
                    throw new ArgumentOutOfRangeException("LoadIntervalSeconds", LoadingInterval,
                                                          "LoadingIntervalTooLarge");
                  }
                  continue;
                }
                if (!key.Equals("EnableRetries", StringComparison.OrdinalIgnoreCase))
                {
                  throw new ArgumentException(string.Format(Thread.CurrentThread.CurrentCulture,
                                                            "UnknownConfigurationParameter",
                                                            new object[] { key }), "parameters");
                }
                _enableRetries = bool.Parse(parameters[key]);
              }
            }
          }
        }
        configParameters = parameters;
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in MTWorkflowPersistenceServiceConstructor", E);
        throw E;
      }
    }

    #region WorkflowPersistenceService Abstract Methods

    ///<summary>
    ///Saves the workflow instance state to a data store.
    ///</summary>
    ///
    ///<param name="rootActivity">The root activity of the workflow instance.</param>
    ///<param name="unlock">true if the workflow instance should not be locked; false if the workflow instance should be locked.</param>
    protected override void SaveWorkflowInstanceState(Activity rootActivity, bool unlock)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.SaveWorkflowInstanceState " + rootActivity.Name);

      try
      {
        DateTime startTime = DateTime.Now;

        PendingWorkItem workItem = new PendingWorkItem(PendingWorkItem.ItemType.Instance);
        workItem.InstanceId = WorkflowEnvironment.WorkflowInstanceId;
        workItem.StateId = (Guid)rootActivity.GetValue(Activity.ActivityContextGuidProperty);
        WorkflowStatus status = GetWorkflowStatus(rootActivity);
        workItem.Status = (int)status;

        if ((status != WorkflowStatus.Completed) && (status != WorkflowStatus.Terminated))
        {
          workItem.SerializedActivity = GetDefaultSerializedForm(rootActivity);
        }
        else
        {
          workItem.SerializedActivity = null;
        }

        workItem.Unlocked = unlock;
        workItem.Blocked = GetIsBlocked(rootActivity) ? 1 : 0;
        workItem.Info = GetSuspendOrTerminateInfo(rootActivity);
        /*
     * Setting the timer reload value which the service 
     * uses to determine what workflows to reload later from the db
     */
        TimerEventSubscription subscription =
            ((TimerEventSubscriptionCollection)
             rootActivity.GetValue(TimerEventSubscriptionCollection.TimerCollectionProperty)).Peek();
        workItem.NextTimer = (subscription == null) ? DateTime.MaxValue : subscription.ExpiresAt;

        WorkflowEnvironment.WorkBatch.Add(this, workItem);

        m_Logger.LogDebug("SaveWorkflowInstanceState took: {0}", ((TimeSpan)(DateTime.Now - startTime)).TotalMilliseconds);
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in SaveWorkflowInstanceState", E);
        throw E;
      }
    }

    ///<summary>
    ///Unlocks the workflow instance state.
    ///</summary>
    ///
    ///<param name="rootActivity">The root activity of the workflow instance.</param>
    /// 
    protected override void UnlockWorkflowInstanceState(Activity rootActivity)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.UnlockWorkflowInstanceState " + rootActivity.Name);

      try
      {
        PendingWorkItem pendingWorkItem = new PendingWorkItem(PendingWorkItem.ItemType.ActivationComplete);
        pendingWorkItem.InstanceId = WorkflowEnvironment.WorkflowInstanceId;
        WorkflowEnvironment.WorkBatch.Add(this, pendingWorkItem);
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in UnlockWorkflowInstanceState", E);
        throw E;
      }
    }

    ///<summary>
    ///Loads the specified state of the workflow instance back into memory.
    ///</summary>
    ///
    ///<returns>
    ///An <see cref="T:System.Workflow.ComponentModel.Activity"></see> that represents the root activity of the workflow instance.
    ///</returns>
    ///
    ///<param name="instanceId">The <see cref="T:System.Guid"></see> of the root activity of the workflow instance.</param>
    protected override Activity LoadWorkflowInstanceState(Guid instanceId)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.LoadWorkflowInstanceState " + instanceId.ToString());

      try
      {
        byte[] guidBuffer =
            GetMTWorkflowDbAccessor().RetrieveInstanceState(instanceId, ServiceInstanceId, OwnershipTimeout);
        Activity rootActivity = RestoreFromDefaultSerializedForm(guidBuffer, null);
        return rootActivity;
      }
      catch (Exception E)
      {
        m_Logger.LogException(string.Format("Exception in LoadWorkflowInstanceState for instance {0}", instanceId.ToString()), E);

        m_DBAccessor.Dispose();
        m_DBAccessor = null;

        throw E;
      }
    }


    ///<summary>
    ///Saves the specified completed scope to a data store.
    ///</summary>
    ///
    ///<param name="activity">An <see cref="T:System.Workflow.ComponentModel.Activity"></see> that represents the completed scope.</param>
    protected override void SaveCompletedContextActivity(Activity activity)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.SaveCompletedContextActivity " + activity.Name);

      try
      {
        //TODO: Confirm that pendingWorkItem.StateId is getting set correctly.
        PendingWorkItem pendingWorkItem = new PendingWorkItem(PendingWorkItem.ItemType.CompletedScope);
        pendingWorkItem.SerializedActivity = GetDefaultSerializedForm(activity);
        pendingWorkItem.InstanceId = WorkflowEnvironment.WorkflowInstanceId;
        pendingWorkItem.StateId = (Guid)activity.GetValue(Activity.ActivityContextGuidProperty);
        WorkflowEnvironment.WorkBatch.Add(this, pendingWorkItem);
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in SaveCompletedContextActivity", E);
        throw E;
      }
    }

    ///<summary>
    ///Loads the specified completed scope back into memory.
    ///</summary>
    ///
    ///<returns>
    ///An <see cref="T:System.Workflow.ComponentModel.Activity"></see> that represents the completed scope.
    ///</returns>
    ///
    ///<param name="scopeId">The <see cref="T:System.Guid"></see> of the completed scope.</param>
    ///<param name="outerActivity">An <see cref="T:System.Workflow.ComponentModel.Activity"></see> that represents the activity that encloses the completed scope.</param>
    protected override Activity LoadCompletedContextActivity(Guid scopeId, Activity outerActivity)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.LoadCompletedContextActivity " + scopeId.ToString());

      try
      {
        byte[] guidBuffer = GetMTWorkflowDbAccessor().RetrieveCompletedScope(scopeId);
        return RestoreFromDefaultSerializedForm(guidBuffer, null);
      }
      catch (Exception E)
      {
        m_Logger.LogException(string.Format("Exception in LoadCompletedContextActivity for scope {0}", scopeId.ToString()), E);
        
        m_DBAccessor.Dispose();
        m_DBAccessor = null;

        throw E;
      }
    }


    ///<summary>
    ///Determines whether a workflow should be unloaded when idle. 
    ///</summary>
    ///
    ///<returns>
    ///If true, the workflow runtime engine will unload the specified workflow when it becomes idle. 
    ///</returns>
    ///
    ///<param name="activity">An <see cref="T:System.Workflow.ComponentModel.Activity"></see> that represents the completed scope.</param>
    protected override bool UnloadOnIdle(Activity activity)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.UnloadOnIdle {0}: {1}", activity.Name, _unloadOnIdle.ToString());
      return _unloadOnIdle;
    }

    #endregion

    #region IPendingWork

    public void Commit(Transaction transaction, ICollection items)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.IPendingWork.Commit: thread Id");

      MTWorkflowDbAccessor dbAccessor = GetMTWorkflowDbAccessor();

      try
      {
        //A System.Transactions Transaction is enlisting this connection so no need/cant 
        //To create a DbTransaction using Enterprise Library.

        foreach (PendingWorkItem pendingWorkItem in items)
        {
          switch (pendingWorkItem.Type)
          {
            case PendingWorkItem.ItemType.Instance:
              {
                dbAccessor.InsertInstanceState(pendingWorkItem, transaction, _serviceInstanceId, OwnershipTimeout);
                continue;
              }
            case PendingWorkItem.ItemType.CompletedScope:
              {
                  dbAccessor.InsertCompletedScope(pendingWorkItem.InstanceId, transaction, pendingWorkItem.StateId,
                                                pendingWorkItem.SerializedActivity);
                continue;
              }
            case PendingWorkItem.ItemType.ActivationComplete:
              {
                  dbAccessor.ActivationComplete(pendingWorkItem.InstanceId, transaction, _serviceInstanceId);
                continue;
              }
            default:
              {
                continue;
              }
          }
        }
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in Commit", E);

        m_DBAccessor.Dispose();
        m_DBAccessor = null;

        throw E;
      }
    }

    public bool MustCommit(ICollection items)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.IPendingWork.MustCommit");
      return true;
    }

    public void Complete(bool succeeded, ICollection items)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.IPendingWork.Complete");

      if ((loadingTimer != null) && succeeded)
      {
        foreach (PendingWorkItem item1 in items)
        {
          if (item1.Type.Equals(PendingWorkItem.ItemType.Instance))
          {
            loadingTimer.Update(item1.NextTimer);
          }
        }
      }
    }

    #endregion

    /// <summary>
    /// 
    /// </summary>
    protected override void OnStarted()
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.OnStarted");

      try
      {
        if (loadingInterval > TimeSpan.Zero)
        {
          lock (timerLock)
          {
            base.OnStarted();

            loadingTimer =
                new SmartTimer(new TimerCallback(LoadWorkflowsWithExpiredTimers), null, loadingInterval,
                               loadingInterval);
          }
        }

        RecoverRunningWorkflowInstances();
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in OnStarted", E);
        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    protected override void OnStopped()
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.OnStopped");

      try
      {
        lock (timerLock)
        {
          base.OnStopped();

          if (loadingTimer != null)
          {
            loadingTimer.Dispose();
            loadingTimer = null;
          }
        }
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in OnStopped", E);
        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    private void RecoverRunningWorkflowInstances()
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.RecoverRunningWorkflowInstances");

      try
      {
        Guid nonblockingInstanceStateId;

        if (Guid.Empty == _serviceInstanceId)
        {
          IList<Guid> nonblockingInstanceStateIds =
              GetMTWorkflowDbAccessor().RetrieveNonblockingInstanceStateIds(_serviceInstanceId,
                                                                                OwnershipTimeout);

          foreach (Guid id in nonblockingInstanceStateIds)
            m_Logger.LogDebug("Recover Instance: {0}", id.ToString());

          using (
              IEnumerator<Guid> nonblockingInstanceStateIdsEnumerator =
                  nonblockingInstanceStateIds.GetEnumerator())
          {
            while (nonblockingInstanceStateIdsEnumerator.MoveNext())
            {
              nonblockingInstanceStateId = nonblockingInstanceStateIdsEnumerator.Current;

              try
              {
                Runtime.GetWorkflow(nonblockingInstanceStateId).Load();
                continue;
              }
              catch (Exception exception1)
              {
                RaiseServicesExceptionNotHandledEvent(exception1, nonblockingInstanceStateId);
                continue;
              }
            }
            return;
          }
        }

        //Reset Guid
        nonblockingInstanceStateId = default(Guid);

        while (GetMTWorkflowDbAccessor().TryRetrieveANonblockingInstanceStateId(_serviceInstanceId, OwnershipTimeout, out nonblockingInstanceStateId))
        {
          try
          {
            Runtime.GetWorkflow(nonblockingInstanceStateId).Load();
            continue;
          }
          catch (Exception notHandledException)
          {
            RaiseServicesExceptionNotHandledEvent(notHandledException, nonblockingInstanceStateId);
            continue;
          }
        }
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in RecoverRunningWorkflowInstances", E);

        m_DBAccessor.Dispose();
        m_DBAccessor = null;

        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="ignored"></param>
    private void LoadWorkflowsWithExpiredTimers(object ignored)
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.LoadWorkflowsWithExpiredTimers");

      try
      {
        lock (timerLock)
        {
          if (State == WorkflowRuntimeServiceState.Started)
          {
            IList<Guid> expiredTimerIds = null;

            try
            {
              expiredTimerIds = LoadExpiredTimerIds();
            }
            catch (Exception exception)
            {
              RaiseServicesExceptionNotHandledEvent(exception, Guid.Empty);
            }

            if (expiredTimerIds != null)
            {
              using (IEnumerator<Guid> expiredTimerIdsEnumerator = expiredTimerIds.GetEnumerator())
              {
                while (expiredTimerIdsEnumerator.MoveNext())
                {
                  Guid currentGuid = expiredTimerIdsEnumerator.Current;

                  try
                  {
                    Runtime.GetWorkflow(currentGuid).Load();
                    continue;
                  }
                  catch (WorkflowOwnershipException)
                  {
                    continue;
                  }
                  catch (ObjectDisposedException)
                  {
                    throw;
                  }
                  catch (InvalidOperationException invalidOperationException)
                  {
                    if (!invalidOperationException.Data.Contains("WorkflowNotFound"))
                    {
                      RaiseServicesExceptionNotHandledEvent(invalidOperationException, currentGuid);
                    }
                    continue;
                  }
                  catch (Exception notHandledException)
                  {
                    RaiseServicesExceptionNotHandledEvent(notHandledException, currentGuid);
                    continue;
                  }
                }
              }
            }
          }
        }
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in LoadWorkflowsWithExpiredTimers", E);
        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public IEnumerable<IDbPersistenceWorkflowInstanceDescription> GetAllWorkflows()
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.GetAllWorkflows");

      try
      {
        if (State == WorkflowRuntimeServiceState.Started)
        {
          return GetMTWorkflowDbAccessor().RetrieveAllInstanceDescriptions();
        }
        else
        {
          throw new InvalidOperationException(
              string.Format(CultureInfo.CurrentCulture, "WorkflowRuntimeNotStarted", new object[0]));
        }
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in GetAllWorkflows", E);

        m_DBAccessor.Dispose();
        m_DBAccessor = null;

        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    private IList<Guid> LoadExpiredTimerIds()
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.LoadExpiredTimerIds");

      try
      {
        return GetMTWorkflowDbAccessor().RetrieveExpiredTimerIds(_serviceInstanceId, OwnershipTimeout);
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in LoadExpiredTimerIds", E);

        m_DBAccessor.Dispose();
        m_DBAccessor = null;

        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public IList<Guid> LoadExpiredTimerWorkflowIds()
    {
      m_Logger.LogDebug("MTWorkflowPersistenceService.LoadExpiredTimerWorkflowIds");

      try
      {
        if (State != WorkflowRuntimeServiceState.Started)
        {
          throw new InvalidOperationException(
              string.Format(CultureInfo.CurrentCulture, "WorkflowRuntimeNotStarted", new object[0]));
        }
        return LoadExpiredTimerIds();
      }
      catch (Exception E)
      {
        m_Logger.LogException("Exception in LoadExpiredTimerWorkflowIds", E);
        throw E;
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    internal MTWorkflowDbAccessor GetMTWorkflowDbAccessor()
    {
      if (m_DBAccessor == null)
      {
        m_DBAccessor = new MTWorkflowDbAccessor();
      }

      return m_DBAccessor;
    }

    #region IDisposable Members

    public void Dispose()
    {
      if (m_DBAccessor != null)
      {
        m_DBAccessor.Dispose();
      }

      GC.SuppressFinalize(this);
    }

    #endregion
  }
}
namespace MetraTech.FileService
{
  using System;
  using System.ComponentModel;
  using System.Threading;
    // For access to MTList

  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region Config Change Notification Event
  public delegate void CfgChangeEvent(CfgEvtChangeArgs arg);
  #endregion

  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  public enum RegistryState
  {
    CHANGED = -1,
    UPDATING = 0,
    CURRENT = 1,
  }

  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region BME cDatabase Manager
  /// <summary>
  /// 
  /// </summary>
  public class Registry
  {
    #region Private Member Data
    private static readonly TLog m_log = new TLog("MetraTech.FileService.Registry");
    private Object m_padlock = new Object();
    private static BackgroundWorker m_worker = new BackgroundWorker();
    // Available via accessor
    private RegistryState m_state = RegistryState.UPDATING;
    private ServiceConfiguration m_serviceCfg = null;
    private HostConfiguration m_hostCfg = null;
    #endregion

    #region Public Member Data
    public TargetRegistry m_TargetRegistry = null;
    public FileRegistry m_FileRegistry = null;
    public WorkOrderRegistry m_OrderRegistry = null;
    public static readonly FlsDatabase DataBase = TSingleton<FlsDatabase>.Instance;
    public event CfgChangeEvent EventChanged = delegate { };
    #endregion

    #region Member Accessors

    public RegistryState State
    {
      get
      {
        lock (m_padlock)
        {
          return m_state;
        }
      }
    }

    public ServiceConfiguration ServiceConfiguration 
    { 
      get 
      { 
        return m_serviceCfg; 
      } 
    }

    public HostConfiguration HostConfiguration 
    { 
      get 
      { 
        return m_hostCfg; 
      } 
    }

    public TargetRegistry TargetRegistry 
    { 
      get 
      { 
        return m_TargetRegistry; 
      } 
    }

    public FileRegistry FileRegistry 
    { 
      get 
      { 
        return m_FileRegistry; 
      } 
    }

    public WorkOrderRegistry OrderRegistry
    {
      get
      {
        return m_OrderRegistry;
      }
    }

    #endregion

    #region Constructors
    /// <summary>
    /// 
    /// </summary>
    public Registry()
    {
      m_TargetRegistry = new TargetRegistry(DataBase);
      m_FileRegistry = new FileRegistry(DataBase);
      m_OrderRegistry = new WorkOrderRegistry(DataBase);
      m_serviceCfg = new ServiceConfiguration(DataBase.Access, new Core.FileLandingService.ConfigurationBE());
      m_hostCfg = new HostConfiguration(DataBase.Access, new Core.FileLandingService.ServiceHostBE());
    }

    /// <summary>
    /// 
    /// </summary>
    ~Registry()
    {
      m_hostCfg = null;
      m_serviceCfg = null;
      m_serviceCfg = null;
    } 
    #endregion

    #region Sync Thread Control

    /// <summary>
    /// Start the thread that will periodically check if configuration
    /// has changed.  We are currently not using this code because
    /// it is expensive to continually query the database about
    /// configuration changes.
    /// </summary>
    public void Start()
    {
      m_worker.DoWork += new DoWorkEventHandler(MonitorConfiguration);
      m_worker.WorkerSupportsCancellation = true;
      m_log.Info("Starting configuration monitoring.");
      m_worker.RunWorkerAsync(this);
    }

    /// <summary>
    /// Stop the configuration change.
    /// </summary>
    public void Stop()
    {
      m_worker.CancelAsync();
      m_worker.DoWork -= MonitorConfiguration;
      m_log.Info("Stopping configuration monitoring.");
      m_hostCfg.Unregister();
    } 

    /// <summary>
    /// Rather than monitor configuration changes, we
    /// just read configuration once.
    /// </summary>
    public void ReadConfiguration()
    {
      m_serviceCfg.Update();
      TargetRegistry.WasUpdated();
    }

    /// <summary>
    /// Determines if a change has occurred, and if so, 
    /// calls back the service to notify the change
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    private void MonitorConfiguration(object sender, DoWorkEventArgs e)
    {
      // Get the BackgroundWorker that raised this event.
      BackgroundWorker worker = sender as BackgroundWorker;
      m_log.Debug("Beginning Configuration Monitoring");
      m_hostCfg.Update();

      while (true)
      {
        // Allow for an out
        if (worker != null && worker.CancellationPending)
        {
          e.Cancel = true;
          return;
        }
        //Log.Debug("Refreshing Configuration");

        if (m_serviceCfg.Update())
          EventChanged(new CfgEvtChangeArgs(CfgEventArgType.ServiceChange, null));

        if (TargetRegistry.WasUpdated())
          EventChanged(new CfgEvtChangeArgs(CfgEventArgType.TargetChange, null));

        Thread.Sleep(ServiceConfiguration.DirRescanIntervalInMS);
      }
    }
    #endregion
  }
  #endregion
  //////////////////////////////////////////////////////////////////////////////////////
  #region Change Notification Helper Objects

  public enum CfgEventArgType { ServiceChange, TargetChange };

  public class CfgEvtChangeArgs : EventArgs
  {
    #region Properties
    public CfgEventArgType ChgType { get; set; }
    public Object ChgObj { get; set; }
    #endregion Properties

    #region Constructor
    public CfgEvtChangeArgs(CfgEventArgType argType, object obj)
    {
      ChgType = argType;
      ChgObj = obj;
    }
    #endregion Constructor
  }
  #endregion Change Notification Helper Objects
  //////////////////////////////////////////////////////////////////////////////////////
}

namespace MetraTech.FileService
{ 
  using System;
  using System.Collections.Generic;
  using System.Configuration;
  using System.IO;
  using System.Transactions;

  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;

  #region Default File Service cDatabase

  /// <summary>
  /// Holds the FLS configuration information.  This information
  /// is placed in the database by the FLS user interface when the
  /// user configures FLS.
  /// </summary>
  public class ServiceConfiguration : BasicEntity
  {
    private static readonly TLog m_log = new TLog("MetraTech.FileService.ServiceConfiguration");

    // True if this class has successfully read global configuration from
    // the database.
    private bool m_hasGlobalConfiguration;

    private bool m_hasMissingConfigMsgBeenReported = false;

    #region Data Accessors

    /// <summary>
    /// Returns true if global configuration was successfully read.
    /// </summary>
    /// <returns>True if global configuration was successfully read.</returns>
    public bool HasGlobalConfiguration()
    {
      return m_hasGlobalConfiguration;
    }

    /// <summary>
    /// Get the incoming file directory.  Due to historical issues, the
    /// database field "IncomingDirectory" actually contains the root
    /// of the fls directory.
    /// </summary>
    public string NewDir 
    { 
      get 
      {
        string result = (Instance as ConfigurationBE)._IncomingDirectory + "\\new"; 
        return normalizeDirName(result);
      } 
    }


    /// <summary>
    /// Get the directory were files are placed will they are being processed.
    /// </summary>
    public string InProgressDir
    {
      get
      {
        string result = (Instance as ConfigurationBE)._IncomingDirectory + "\\inprogress";
        return normalizeDirName(result);
      }
    }

    /// <summary>
    /// Get the directory were files that could not be associated
    /// with a target a placed.  This is NOT USED.
    /// </summary>
    public string FailedDir
    {
      get
      {
        string result = (Instance as ConfigurationBE)._FailedDirectory;
        return normalizeDirName(result);
      }
    }

    /// <summary>
    /// Get the directory were completed files are placed.
    /// </summary>
    public string DoneDir
    {
      get
      {
        string result = (Instance as ConfigurationBE)._IncomingDirectory + "\\done";
        return normalizeDirName(result);
      }
    }

    /// <summary>
    /// Get the maximum number of simultaneous jobs that
    /// can be run.
    /// </summary>
    public int MaxConcurrentTargets
    {
      get
      {
        return (Instance as ConfigurationBE)._MaximumActiveTargets;
      }
    }
    /// <summary>
    /// Get the maximum time in ms for which a target is allowed to execute before timeout
    /// </summary>
    public int TargetExecutionTimeout
    {
      get { return Convert.ToInt32(ConfigurationManager.AppSettings["TargetExecutionTimeout"]); }
    }

    /// <summary>
    /// For memory consumption purposes, this setting limits the number of possible 
    /// files which will be loaded before we stop queuing incoming files
    /// </summary>
    public int MaximumFilesInQueue
    {
      get { return Convert.ToInt32(ConfigurationManager.AppSettings["MaximumFilesInQueue"]); }
    }

    /// <summary>
    /// Hold age of file in minutes (time befgore file pickup from last modification, creation or access date)
    /// </summary>
    public int HoldAgeInMilliseconds
    {
        get { return Convert.ToInt32(ConfigurationManager.AppSettings["HoldAgeInMilliseconds"]); }
    }
    /// <summary>
    /// Hold age of file in minutes (time befgore file pickup from last modification, creation or access date)
    /// </summary>
    public int DirectoryScanTimeInMilliseconds
    {
        get { return Convert.ToInt32(ConfigurationManager.AppSettings["DirectoryScanTimeInMilliseconds"]); }
    }

    /// <summary>
    /// Gets the minimum number of threads waiting to process execution requests
    /// </summary>
    public int MinimumThreadsReadyToRunExecutables
    {
      get { return Convert.ToInt32(ConfigurationManager.AppSettings["MinimumThreadsReadyToRunExecutables"]); }
    }
    
    /// <summary>
    /// Gets the Maximume number of allowable executibles to run concurrently
    /// </summary>
    public int MaximumExecutablesRunningConcurrently
    {
      get { return Convert.ToInt32(ConfigurationManager.AppSettings["MaximumExecutablesRunningConcurrently"]); }
    }
    

    /// <summary>
    /// Get the directory rescan interval in MS.
    /// </summary>
    public int DirRescanIntervalInMS
    {
      get
      {
        return (Instance as ConfigurationBE)._ConfRefreshIntervalInMS;
      }
    }

    #endregion

    #region Constructors/Destructors
    /// <summary>
    /// 
    /// </summary>
    public ServiceConfiguration(IStandardRepository db, ConfigurationBE c)
      : base(db, c)
    {
      m_hasGlobalConfiguration = false;
    }

    /// <summary>
    /// 
    /// </summary>
    ~ServiceConfiguration()
    { } 
    #endregion

    /// <summary>
    /// Determines if the stored configuration is newer than the 
    /// current configuration data
    /// </summary>
    /// <returns></returns>
    public override bool IsUpToDate()
    {
      ConfigurationBE me = Instance as ConfigurationBE;
      if (null == me || me.Id == Guid.Empty)
        return false;

      ConfigurationBE cfg = DB.LoadInstance(typeof(ConfigurationBE).FullName, Instance.Id) as ConfigurationBE;
      if (null != cfg)
      {
        if (me._Version < cfg._Version)
        {
          return false;
        }
        return true;
      }
      return false;
    }

    /// <summary>
    /// Updates information from the DB, and 
    /// returns true if data was updated, false if it is current
    /// </summary>
    /// <returns>true is information was updated, false if no change</returns>
    public bool Update()
    {
      return LoadConfiguration();
    }

    /// <summary>
    ///  Load the configuration from the database.
    /// </summary>
    /// <returns>True if the configuration changed from when the configuration was originally loaded.
    ///</returns>
    private bool LoadConfiguration()
    {
      ConfigurationBE me = Instance as ConfigurationBE;
      if (IsUpToDate()) return false;

      // Load instances 
      MTList<DataObject> Cfgs = DB.LoadInstances(typeof(ConfigurationBE).FullName,
                                                 new MTList<DataObject>());
      // Is there anything in the DB?
      if (Cfgs.TotalRows == 0)
      {
        m_hasGlobalConfiguration = false;
        if (!m_hasMissingConfigMsgBeenReported)
        {
          m_log.Warn("The FileLandingService globals have not been configured. " +
                     "Please use the web interface MetraNet FileManagement/Configure Gobals and " +
                     "Configure Targets to set up configuration.  After setting configuration " +
                     "re-start the FileLandingService.");
          m_hasMissingConfigMsgBeenReported = true;
        }
      }
      else
      {
        m_hasGlobalConfiguration = true;
        m_hasMissingConfigMsgBeenReported = false;

        if (Cfgs.TotalRows > 1)
          m_log.Warn("There is more than one FLS configuration in the database, selecting first instance. Please resolve this issue.");
        else
          m_log.Debug("Loading FLS configuration from database.");

        bool b_firstCfg = true;
        foreach (ConfigurationBE scfg in Cfgs.Items)
        {
          if (!b_firstCfg) break;
          Instance = me = scfg;
          b_firstCfg = false;
        }
      }

      if (me._ConfRefreshIntervalInMS < 0)
      {
        m_log.Error("Invalid configuration item ConfRefreshIntervalInMS, setting to the default.");
        me._ConfRefreshIntervalInMS = Convert.ToInt32(ConfigurationManager.AppSettings["ConfRefreshIntervalInMS"]);
      }

      if (me._MaximumActiveTargets < 0)
      {
        m_log.Error("Invalid configuration item MaximumActiveTargets, setting to the default.");
        me._MaximumActiveTargets = Convert.ToInt32(ConfigurationManager.AppSettings["MaximumActiveTargets"]);
      }
      // TODO: update BME to have TargetExecutionTimeout - ConfigurationManager.AppSettings["TargetExecutionTimeout"]

      // Make sure the new directory exists.
      try
      {
        System.IO.Directory.CreateDirectory(NewDir);
      } 
      catch (Exception e)
      {
        m_log.Error("Unable to create new (landingzone) directory: " + NewDir +
                    "Error: " + e.Message);
      }

      // Make sure the inprogress directory exists.
      try
      {
        System.IO.Directory.CreateDirectory(InProgressDir);
      }
      catch (Exception e)
      {
        m_log.Error("Unable to create processing directory: " + InProgressDir +
                    "Error: " + e.Message);
      }

      // Make sure the done directory exists.
      try
      {
        System.IO.Directory.CreateDirectory(DoneDir);
      }
      catch (Exception e)
      {
        m_log.Error("Unable to create done directory: " + DoneDir +
                    "Error: " + e.Message);
      }

      return true;
    }

    private void InitFromAppConfig(ConfigurationBE me)
    {
      // Get started using the app.config data
      m_log.Warn("No configuration in database, using application defaults.");
      me._ActiveDirectory = ConfigurationManager.AppSettings["ActiveDirectory"];
      me._FailedDirectory = ConfigurationManager.AppSettings["FailedDirectory"];
      me._CompletedDirectory = ConfigurationManager.AppSettings["CompletedDirectory"];
      me._IncomingDirectory = ConfigurationManager.AppSettings["IncomingDirectory"];

      me._MaximumActiveTargets = Convert.ToInt32(ConfigurationManager.AppSettings["MaximumActiveTargets"]);
      me._ConfRefreshIntervalInMS = Convert.ToInt32(ConfigurationManager.AppSettings["ConfRefreshIntervalInMS"]);
      me._UseDescriptorFile = Convert.ToBoolean(ConfigurationManager.AppSettings["UseDescriptorFile"]);
      me._UseMD5 = Convert.ToBoolean(ConfigurationManager.AppSettings["UseMD5"]);
      me._UseSHA1 = Convert.ToBoolean(ConfigurationManager.AppSettings["UseSHA1"]);
      me._UseToken = Convert.ToBoolean(ConfigurationManager.AppSettings["UseToken"]);
    }

    /// <summary>
    /// Takes the given string and ensures that it ends with a slash or backslash.
    /// </summary>
    /// <param name="given"></param>
    /// <returns></returns>
    private string normalizeDirName(string given)
    {
        string result = given; 
        string lastChar = result.Substring(given.Length - 1);
        if (!lastChar.Equals("\\") && !lastChar.Equals("/"))
        {
          result = result + "\\";
        }
        return result;
    }

  } 
  #endregion
}

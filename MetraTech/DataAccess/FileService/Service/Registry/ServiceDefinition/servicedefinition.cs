#if false
namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  // MetraTech Assemblies
  using System;
  using System.IO;
  using System.Collections.Generic;
  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region Service Definition
  public class cServiceDefinition : acConfigurationEntity
  {
    private static readonly ILog m_Log = LogManager.GetLogger("MetraTech.cFileService.cServiceDefinition");

    private cFileSetRequirement m_SetRequirement = null;
    private Dictionary<string, cDirectory> m_Directories = new Dictionary<string, cDirectory>();
    private Dictionary<string, cTarget> m_TargetsByName = new Dictionary<string, cTarget>();
    private Dictionary<EEventFilterType, List<cTarget>> m_TargetsByEvent = new Dictionary<EEventFilterType,List<cTarget>>();
    private cAgent m_MyAgent = null;

    #region Accessors
    public string NameSpace
    {
      get
      {
        return (Instance as ServiceDefinitionBE)._NameSpace;
      }
    }
    public string Name
    {
      get
      {
        return (Instance as ServiceDefinitionBE)._Name;
      }
    }
    public string FullName
    {
      get
      {
        return String.Format("{0}/{1}", (Instance as ServiceDefinitionBE)._NameSpace, (Instance as ServiceDefinitionBE)._Name);
      }
    }
    public Dictionary<string, cDirectory> Directories
    {
      get
      {
        return m_Directories;
      }
    }
    public Dictionary<string, cTarget> TargetsByName
    {
      get
      {
        return m_TargetsByName;
      }
    }
    public Dictionary<EEventFilterType, List<cTarget>> TargetsByEvent
    {
      get
      {
        return m_TargetsByEvent;
      }
    }
    public cFileSetRequirement FileSetRequirement
    {
      get
      {
        return m_SetRequirement;
      }
    }
    public cAgent MyAgent
    {
      get { return m_MyAgent; }
      set
      {
        if (null == m_MyAgent)
        {
          m_MyAgent = value;
        }
        else // make sure we deregister from the agent
        {
          throw new Exception("ADD AGENT DEREG CODE HERE");
        }
      }
    }
    #endregion

    #region Constructor
    public cServiceDefinition(IStandardRepository db, ServiceDefinitionBE instance)
      : base(db, instance)
    {
      EnumerateDirectories();
      EnumerateTargets();
      EnumerateFileSetRequirements();
    } 
    #endregion

    #region Directory Enumeration
    private void EnumerateDirectories()
    {
      MTList<DataObject> dirs = DB.LoadInstancesFor(typeof(DirectoryBE).FullName,
                                                       typeof(ServiceDefinitionBE).FullName,
                                                       Instance.Id, new MTList<DataObject>());
      foreach (DirectoryBE d in dirs.Items)
      {
        cDirectory dir = m_Directories[Path.Combine(d._Path, d._Name)];
        if (null == dir)
        {
          dir = new cDirectory(DB, d);
          m_Directories.Add(dir.FullName, dir);
        }
      }
    }
    #endregion

    #region Target Enumeration
    private void EnumerateTargets()
    {
      MTList<DataObject> targets = DB.LoadInstancesFor(typeof(TargetBE).FullName,
                                                       typeof(ServiceDefinitionBE).FullName,
                                                       Instance.Id, new MTList<DataObject>());
      foreach (TargetBE e in targets.Items)
      {
        cTarget exe = m_TargetsByName[Path.Combine(e._Path, e._Name)];
        if (null == exe)
        {
          exe = new cTarget(DB, e);
          m_TargetsByName.Add(exe.FullName, exe);
        }
        foreach(cEventFilter ef in exe.EventFilters)
        {
          if (null == m_TargetsByEvent[ef.Type])
            m_TargetsByEvent[ef.Type] = new List<cTarget>();
          m_TargetsByEvent[ef.Type].Add(exe);
        }
      }
    }
    #endregion

    #region FileSet Requirement Enumeration
    private void EnumerateFileSetRequirements()
    {
      if (null == m_SetRequirement)
      {
        MTList<DataObject> reqs = DB.LoadInstancesFor(typeof(FileSetRequirementBE).FullName,
                                                      typeof(ServiceDefinitionBE).FullName,
                                                      Instance.Id, new MTList<DataObject>());
        foreach (FileSetRequirementBE fsr in reqs.Items)
        {
          // Only grab the first one...
          m_SetRequirement = new cFileSetRequirement(DB, fsr);
          break;
        }
      }
    }
    #endregion

    /// TODO: MAY WANT TO ADD THESE LATER

    private void EnumerateTargets()
    {

        Log.Debug("---------------------------------------------------");
        Log.Debug("sdef.RecordFiles.Count : " + sdef.RecordFiles.Count);
        Log.Debug("---------------------------------------------------");
        foreach (RecordFile rfile in sdef.RecordFiles)
        {
          Log.Debug("MapCfg.RecordFiles.File.Version : " + rfile._Version);
          Log.Debug("MapCfg.RecordFiles.File.Name : " + rfile.BusinessKey._Name);
          Log.Debug("MapCfg.RecordFiles.File.Type : " + rfile._Type);
          Log.Debug("---------------------------------------------------");
          Log.Debug("MapCfg.RecordFiles.File.RecordFileStates.Count : " + rfile.RecordFileStates.Count);
          Log.Debug("---------------------------------------------------");
          foreach (RecordFileState state in rfile.RecordFileStates)
          {
            Log.Debug("sdef.RecordFiles.File.State.Id: " + state.Id);
            Log.Debug("sdef.RecordFiles.File.State.Version: " + state._Version);
            Log.Debug("sdef.RecordFiles.File.State.Name: " + state._Name);
            Log.Debug("sdef.RecordFiles.File.State.State: " + state._State.ToString());
            Log.Debug("sdef.RecordFiles.File.State.Time: " + state._Time.ToString());
          }
          Log.Debug("---------------------------------------------------");
        }
        

    #region Script Enumeration
        MTList<DataObject> scripts = REPOSITORY.LoadInstancesFor(typeof(Script).FullName,
                                         typeof(ServiceDefinitionBE).FullName,
                                         sdef.Id,
                                         new MTList<DataObject>());
        foreach (Script s in scripts.Items)
        {
          sdef.Scripts.Add(s);
        }
        Log.Debug("---------------------------------------------------");
        Log.Debug("sdef.Scripts.Count : " + sdef.Scripts.Count);
        Log.Debug("---------------------------------------------------");
        foreach (Script script in sdef.Scripts)
        {
    #region Script Loading
          Log.Debug("sdef.Script.Id: " + script.Id);
          Log.Debug("sdef.Script.Version: " + script._Version);
          Log.Debug("sdef.Script.Name: " + script._Name);
          Log.Debug("sdef.Script.Path: " + script._Path);
          Log.Debug("sdef.Script.JobPartition: " + script._JobPartition);
          Log.Debug("---------------------------------------------------");
          Log.Debug("sdef.Script.SecurityTokens.Count: " + script.SecurityTokens.Count);
          Log.Debug("---------------------------------------------------");
          script._Path = Path.Combine(this.EXTDIR, script._Path);
          using (DirectoryVerifier dver = new DirectoryVerifier(script._Path))
          {
            if (!dver.Verify())
            {
              Log.Error("Script path (" + script._Path + ") does not exist!");
            }
          }
          using (FileVerifier fver = new FileVerifier(Path.Combine(script._Path, script._Name)))
          {
            if (!fver.Verify())
            {
              Log.Error("Script path (" + Path.Combine(script._Path, script._Name) + ") does not exist!");
            }
          }
          #endregion
    #region Security Tokens
          MTList<DataObject> tokens = REPOSITORY.LoadInstancesFor(typeof(SecurityToken).FullName,
                                   typeof(Script).FullName,
                                   script.Id,
                                   new MTList<DataObject>());
          foreach (SecurityToken t in tokens.Items)
          {
            script.SecurityTokens.Add(t);
          }
          foreach (SecurityToken token in script.SecurityTokens)
          {
            Log.Debug("sdef.Script.SecurityTokens.Id: " + token.Id);
            Log.Debug("sdef.Script.SecurityTokens.Type: " + token._Type);
            Log.Debug("sdef.Script.SecurityTokens.Value: " + token._Token);
          }
    #endregion
    #region Script Arguments
          MTList<DataObject> args = REPOSITORY.LoadInstancesFor(typeof(ScriptArgument).FullName,
                                           typeof(Script).FullName,
                                           script.Id,
                                           new MTList<DataObject>());
          foreach (ScriptArgument a in args.Items)
          {
            script.ScriptArguments.Add(a);
          }
          Log.Debug("---------------------------------------------------");
          Log.Debug("sdef.Script.ScriptArguments.Count: " + script.ScriptArguments.Count);
          Log.Debug("---------------------------------------------------");
          foreach (ScriptArgument arg in script.ScriptArguments)
          {
            Log.Debug("sdef.Script.ScriptArgument.Id: " + arg.Id);
            Log.Debug("sdef.Script.ScriptArgument.Type: " + arg._Type);
            Log.Debug("sdef.Script.ScriptArgument.Key: " + arg._Key);
            Log.Debug("sdef.Script.ScriptArgument.Value: " + arg._Value);
          }
          Log.Debug("---------------------------------------------------");
    #endregion
        }
        #endregion
      }
      return base.Update();
  }


  } 
  #endregion
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region Service Definition Collection
  /// <summary>
  /// 
  /// </summary>
  public class cServiceDefinitionCollection : acConfiguration
  {
    private Dictionary<string, Dictionary<string, cServiceDefinition>> m_ServiceDefinitionTable = null;


    public cServiceDefinitionCollection()
      : base()
    {
      EnumerateServiceDefinitions();
    }

    /// <summary>
    /// 
    /// </summary>
    ~cServiceDefinitionCollection()
    { }

    public Dictionary<string, Dictionary<string, cServiceDefinition>> TABLE { get { return m_ServiceDefinitionTable; } }

    private void EnumerateServiceDefinitions()
    {
      MTList<DataObject> sdefs = REPOSITORY.LoadInstances(typeof(ServiceDefinitionBE).FullName, new MTList<DataObject>());

      Log.Debug("EnumerateServiceDefinitions() got " + sdefs.TotalRows + " ServiceDefinition rows from database");
      foreach (ServiceDefinitionBE sdef in sdefs.Items)
      {
        Dictionary<string, cServiceDefinition> entry = m_ServiceDefinitionTable[sdef._NameSpace];
        if (null == entry)
        {
          entry = new Dictionary<string, cServiceDefinition>();
          m_ServiceDefinitionTable[sdef._NameSpace] = entry;
        }
        cServiceDefinition sd = entry[sdef._Name];
        if (null == sd)
        {
          sd = new cServiceDefinition(REPOSITORY, sdef);
          entry[sdef._Name] = sd;
        }
        Log.Info(String.Format("Added Service Definition '{0}'", sd.FullName));
      }
    }
    /// <summary>
    /// TODO
    /// </summary>
    /// <returns></returns>
    public override bool Update()
    {
      return false;
    }
    /// <summary>
    /// TODO
    /// </summary>
    /// <returns></returns>
    public override bool IsCurrent()
    {
      return base.IsCurrent();
    }
  } 
  #endregion
  ////////////////////////////////////////////////////////////////////////////////////// 
}
#endif
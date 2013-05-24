using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml.Serialization;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core.Exception;
using NHibernate.Util;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Persistence;

namespace MetraTech.BusinessEntity.Core.Config
{
  /// <summary>
  ///   Uses the singleton pattern specified here:
  ///   http://msdn.microsoft.com/en-us/library/ms998558.aspx
  /// </summary>
  [XmlRoot("be-config")]
  public sealed class BusinessEntityConfig
  {
    #region Public Properties
    public static BusinessEntityConfig Instance
    {
      get
      {
        if (instance == null)
        {
          lock (syncRoot)
          {
            if (instance == null)
            {
              instance = CreateBusinessEntityConfig();
              List<ErrorObject> errors = Validate(instance);
              if (errors.Count > 0)
              {
                errors.ForEach(e => logger.Error(e.Message));
                throw new BasicException(String.Format("Invalid business entity configuration file '{0}'. See log for details.", ConfigFile));
              }
            }
          }
        }

        return instance;
      }
    }

    [XmlElement(ElementName = "use-flat-schema")]
    public string UseFlatSchema { get; set; }

    [XmlElement(ElementName = "repository", Type = typeof(RepositoryConfig))]
    public RepositoryConfig[] RepositoryConfigs { get; set; }

    [XmlElement(ElementName = "metranet-entity", Type = typeof(MetraNetEntityConfig))]
    public MetraNetEntityConfig[] MetraNetEntityConfigs { get; set; }

    [XmlElement(ElementName = "copy-bme-assemblies-to", Type = typeof(AssemblyCopyDirConfig))]
    public AssemblyCopyDirConfig[] AssemblyCopyDirConfigs { get; set; }

    [XmlElement(ElementName = "synchronization-sql-file")]
    public string SynchronizationSqlFile { get; set; }

    [XmlElement(ElementName = "nhibernate-log-file")]
    public string NHibernateLogFile { get; set; }

    public RepositoryConfig DefaultRepositoryConfig
    {
      get
      {
        foreach (RepositoryConfig repositoryConfig in RepositoryConfigs)
        {
          if (repositoryConfig.IsDefault)
          {
            return repositoryConfig;
          }
        }
        return null;
      }
    }

    public static string ConfigFile { get; set; }

    #endregion

    #region Public Methods

    public string GetSynchronizationSqlFileWithPath(string databaseName)
    {
      if (String.IsNullOrEmpty(SynchronizationSqlFile))
      {
        logger.Warn(String.Format("Did not find synchronization file name in config file '{0}'. " + 
                                  "Using 'bme-sync.sql'", 
                                  SystemConfig.GetBusinessEntityConfigFile()));

        SynchronizationSqlFile = "bme-sync.sql";
      }

      string directory = Path.GetTempPath();
      if (!Directory.Exists(directory))
      {
        logger.Warn(String.Format("Cannot find temp directory '{0}'. Using RMP.", directory));
        directory = SystemConfig.GetRmpDir();
      }

      SynchronizationSqlFile = SynchronizationSqlFile.ToLower().Replace(".sql", "_" + databaseName + ".sql");
      return Path.Combine(directory, SynchronizationSqlFile);
    }

    public string GetNHibernateLogFileWithPathAndLogLevel(out LogLevel logLevel)
    {
      if (String.IsNullOrEmpty(NHibernateLogFile))
      {
        logger.Warn(String.Format("Did not find nhibernate log file name in config file '{0}'. " +
                                  "Using 'mtlog.be.txt'",
                                  SystemConfig.GetBusinessEntityConfigFile()));

        NHibernateLogFile = "mtlog.be.txt";
      }

      string directory = SystemConfig.GetLogFileDirectoryAndLogLevel(out logLevel);
      if (!Directory.Exists(directory))
      {
        logger.Warn(String.Format("Cannot find log file directory '{0}'. Using RMP.", directory));
        directory = SystemConfig.GetRmpDir();
      }

      return Path.Combine(directory, NHibernateLogFile);
    }

    public IList<string> GetAssemblyCopyDirectories()
    {
      if (AssemblyCopyDirectories != null)
      {
        return AssemblyCopyDirectories.AsReadOnly();
      }

      AssemblyCopyDirectories = new List<string>();

      if (AssemblyCopyDirConfigs == null)
      {
        return AssemblyCopyDirectories.AsReadOnly();
      }

      foreach (AssemblyCopyDirConfig assemblyCopyDirConfig in AssemblyCopyDirConfigs)
      {
        if (String.IsNullOrEmpty(assemblyCopyDirConfig.VirtualDirectoryName))
        {
          continue;
        }

        string dir = DirectoryUtil.ResolveVirtualDirectory(assemblyCopyDirConfig.VirtualDirectoryName);
        if (String.IsNullOrEmpty(dir))
        {
          logger.Warn(String.Format("Cannot resolve virtual directory '{0}'", 
                                    assemblyCopyDirConfig.VirtualDirectoryName));
          continue;
        }

        dir = Path.Combine(dir, "bin");
        if (!Directory.Exists(dir))
        {
          logger.Warn(String.Format("Cannot find bin path '{0}' for virtual directory '{1}'",
                                    dir, assemblyCopyDirConfig.VirtualDirectoryName));
          continue;
        }

        AssemblyCopyDirectories.Add(dir);
      }

      return AssemblyCopyDirectories.AsReadOnly();
    }

    public RepositoryConfig GetRepositoryConfig(string name)
    {
      RepositoryConfig repositoryConfig = null;

      foreach(RepositoryConfig repConfig in RepositoryConfigs)
      {
        if (repConfig.Name == name)
        {
          repositoryConfig = repConfig;
          break;
        }
      }

      return repositoryConfig;
    }

    public MetraNetEntityConfig GetMetranetEntityConfig(string assemblyQualifiedName)
    {
      Check.Require(!String.IsNullOrEmpty(assemblyQualifiedName), "assemblyQualifiedName cannot be null or empty", SystemConfig.CallerInfo);
      MetraNetEntityConfig metraNetEntityConfig = null;

      try
      {
        var assemblyQualifiedTypeName = TypeNameParser.Parse(assemblyQualifiedName);

        foreach (MetraNetEntityConfig config in MetraNetEntityConfigs)
        {
          if (config.TypeName == assemblyQualifiedTypeName.Type &&
              config.AssemblyName == assemblyQualifiedTypeName.Assembly)
          {
            metraNetEntityConfig = config;
            break;
          }
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot parse assembly qualified type name '{0}'", assemblyQualifiedName);
        throw new BusinessEntityException(message, e, SystemConfig.CallerInfo);
      }
      
      return metraNetEntityConfig;
    }
    #endregion

    #region Private Methods
    /// <summary>
    ///   Initialize the configuration specified in 
    ///   RMP\config\BusinessEntity\be.cfg.xml
    /// </summary>
    private static BusinessEntityConfig CreateBusinessEntityConfig()
    {
      BusinessEntityConfig businessEntityConfig = null;

      string configFile = SystemConfig.GetBusinessEntityConfigFile();
      using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
      {
        XmlSerializer serializer = new XmlSerializer(typeof(BusinessEntityConfig));
        businessEntityConfig = (BusinessEntityConfig)serializer.Deserialize(fileStream);
        ConfigFile = configFile;
        fileStream.Close();
      }

      Check.Ensure(businessEntityConfig != null, "businessEntityConfig cannot be null");
      return businessEntityConfig;

    }

    /// <summary>
    ///   Validate the configuration.
    /// </summary>
    /// <param name="businessEntityConfig"></param>
    private static List<ErrorObject> Validate(BusinessEntityConfig businessEntityConfig)
    {
      List<ErrorObject> errors = new List<ErrorObject>();

      if (businessEntityConfig == null || 
          businessEntityConfig.RepositoryConfigs == null ||
          businessEntityConfig.RepositoryConfigs.Length == 0)
      {
        errors.Add(new ErrorObject(String.Format("Business entity config file '{0}' must have atleast one <repository> element", ConfigFile)));
        return errors;
      }

      int defaultRepositoryCount = 0;
      foreach(RepositoryConfig repositoryConfig in businessEntityConfig.RepositoryConfigs)
      {
        errors.AddRange(repositoryConfig.Validate());
        if (repositoryConfig.IsDefault)
        {
          defaultRepositoryCount++;
        }
      }

      if (defaultRepositoryCount == 0)
      {
        errors.Add(new ErrorObject
                     (String.Format("Config file '{0}' must have atleast one " +
                                    "repository with a 'default' value of 'true'",
                                    ConfigFile)));
      }

      if (defaultRepositoryCount > 1)
      {
        errors.Add(new ErrorObject
                     (String.Format("Config file '{0}' has more than one " +
                                    "repository with a 'default' value of true",
                                    ConfigFile)));
      }

      return errors;
    }

    
    #endregion

    #region Private Properties
    private static List<string> AssemblyCopyDirectories { get; set; }
    #endregion

    #region Data
    private static BusinessEntityConfig instance;
    private static readonly object syncRoot = new Object();
    private static readonly ILog logger = LogManager.GetLogger("BusinessEntityConfig");
    #endregion
  }

  
  [Serializable]
  public sealed class RepositoryConfig
  {
    [XmlAttribute("name")]
    public string Name { get; set; }
    [XmlAttribute("interface")]
    public string Interface { get; set; }
    [XmlAttribute("type")]
    public string AssemblyQualifiedType { get; set; }
    [XmlAttribute("supports-dynamic-types")]
    public bool SupportsDynamicTypes { get; set; }
    [XmlAttribute("default")]
    public bool IsDefault { get; set; }

    public AssemblyQualifiedName AssemblyQualifiedName { get; set; }

    /// <summary>
    ///    Also initializes AssemblyQualifiedName
    /// </summary>
    /// <returns></returns>
    public List<ErrorObject> Validate()
    {
      List<ErrorObject> errors = new List<ErrorObject>();

      // repository must have a name
      if (String.IsNullOrEmpty(Name))
      {
        errors.Add(new ErrorObject
          (String.Format("Repository does not have a name in config file '{0}'",
                          BusinessEntityConfig.ConfigFile)));
      }

      // repository must have an interface
      if (String.IsNullOrEmpty(Interface))
      {
        errors.Add(new ErrorObject
          (String.Format("Repository '{0}' in config file '{1}' must have a valid 'interface' attribute",
                         Name,
                         BusinessEntityConfig.ConfigFile)));
      }
      // Make sure that the interface is namespace qualified
      else if (String.IsNullOrEmpty(StringHelper.Qualifier(Interface)))
      {
        errors.Add(new ErrorObject
        (String.Format("The interface '{0}' must be qualified by a namespace for the repository '{1}' in " +
                       "in config file '{2}'",
                       Interface,
                       Name,
                       BusinessEntityConfig.ConfigFile)));
      }

      // repository must have a type
      if (String.IsNullOrEmpty(AssemblyQualifiedType))
      {
        errors.Add(new ErrorObject
          (String.Format("Repository '{0}' in config file '{1}' must have a valid 'type' attribute",
                         Name,
                         BusinessEntityConfig.ConfigFile)));
      }
      else
      {
        AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(AssemblyQualifiedType);
        // repository must have an assembly qualified type name
        if (assemblyQualifiedTypeName == null ||
            String.IsNullOrEmpty(assemblyQualifiedTypeName.Type) ||
            String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly))
        {
          errors.Add(new ErrorObject
            (String.Format("Cannot parse type '{0}' for repository '{1}'" +
                           "in config file '{2}'. " +
                           "The type must be qualified with a namespace and an assembly",
                           AssemblyQualifiedType,
                           Name,
                           BusinessEntityConfig.ConfigFile)));
        }
        // Make sure that the Type is namespace qualified
        else if (String.IsNullOrEmpty(StringHelper.Qualifier(assemblyQualifiedTypeName.Type)))
        {
          errors.Add(new ErrorObject
          (String.Format("The repository type '{0}' for repository '{1}' must be namespace qualified in " +
                         "in config file '{2}'",
                         AssemblyQualifiedType,
                         Name,
                         BusinessEntityConfig.ConfigFile)));
        }
        else
        {
          AssemblyQualifiedName =
            new AssemblyQualifiedName(assemblyQualifiedTypeName.Type, assemblyQualifiedTypeName.Assembly);

          // Make sure that the Type can be loaded
          Type repositoryType = null;
          try
          {
            repositoryType = Type.GetType(AssemblyQualifiedName.AssemblyQualifiedTypeName, true);
            Check.Assert(repositoryType != null, String.Format("Cannot load type '{0}'", AssemblyQualifiedName.AssemblyQualifiedTypeName));
          }
          catch (System.Exception e)
          {
            errors.Add(new ErrorObject
            (String.Format("Cannot load repository type '{0}' for repository '{1}' in " +
                           "in config file '{2}' with error message '{3}'",
                           AssemblyQualifiedName.AssemblyQualifiedTypeName,
                           Name,
                           BusinessEntityConfig.ConfigFile,
                           e.Message)));
          }

          // Make sure that the Type implements the specified interface
          Type repositoryInterfaceType = repositoryType.GetInterface(Interface);
          if (repositoryInterfaceType == null)
          {
            errors.Add(new ErrorObject
            (String.Format("The repository type '{0}' for repository '{1}' in config file '{2}' " +
                           "does not implement the interface '{3}' in ",
                           AssemblyQualifiedName.AssemblyQualifiedTypeName,
                           Name,
                           BusinessEntityConfig.ConfigFile,
                           Interface)));
          }

          // Make sure that the Type implements IRepository:
          Type iRepository = repositoryType.GetInterface(typeof(IRepository).FullName);
          if (iRepository == null)
          {
            errors.Add(new ErrorObject
            (String.Format("The repository type '{0}' for repository '{1}' in config file '{2}' must " +
                           "implement the MetraTech.BusinessEntity.Core.Persistence.IStandardRepository interface. ",
                           AssemblyQualifiedName.AssemblyQualifiedTypeName,
                           Name,
                           BusinessEntityConfig.ConfigFile)));
          }
  
        }
      }

      return errors;
    }

    public RepositoryConfig Clone()
    {
      RepositoryConfig repositoryConfig = (RepositoryConfig)MemberwiseClone();
      return repositoryConfig;
    }
  }

  [Serializable]
  [DataContract(IsReference = true)]
  public sealed class MetraNetEntityConfig
  {
    
    [DataMember]
    public string TypeName { get; set;}

    [DataMember]
    public string AssemblyName { get; set; }

    private string assemblyQualifiedName;
    [DataMember]
    [XmlAttribute("type")] 
    public string AssemblyQualifiedName
    {
      get
      {
        return assemblyQualifiedName;
      }

      set
      {
        Check.Require(!String.IsNullOrEmpty(value), "type cannot be null or empty", SystemConfig.CallerInfo);

        try
        {
          AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(value);

          Check.Require(!String.IsNullOrEmpty(assemblyQualifiedTypeName.Type) && !String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly),
                        String.Format("Cannot parse assembly qualified type '{0}'", assemblyQualifiedTypeName),
                        SystemConfig.CallerInfo);

          TypeName = assemblyQualifiedTypeName.Type;
          AssemblyName = assemblyQualifiedTypeName.Assembly;
          assemblyQualifiedName = value;

        }
        catch (System.Exception e)
        {
          string message = String.Format("Cannot parse assembly qualified type name '{0}'", value);
          throw new BusinessEntityException(message, e, SystemConfig.CallerInfo);
        }
      }
    }
  }

  [Serializable]
  public sealed class AssemblyCopyDirConfig
  {
    [XmlAttribute("virtual-dir")]
    public string VirtualDirectoryName { get; set; }
  }
}

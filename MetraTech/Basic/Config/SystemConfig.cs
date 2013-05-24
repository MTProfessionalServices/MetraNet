using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using System.Diagnostics;
using System.Reflection;
using System.Xml.XPath;
using System.Xml;
using Microsoft.Win32;

using log4net;
using MetraTech.Basic.Exception;
using MetraTech.Interop.RCD;

namespace MetraTech.Basic.Config
{
  public static class SystemConfig
  {
    #region Methods
    public static string GetBinDir()
    {
      return GetRmpBinDir();
    }

    public static bool ExtensionExists(string extensionName)
    {
      return Directory.Exists(Path.Combine(GetExtensionsDir(), extensionName));
    }

    /// <summary>
    ///    (1) Look for environment variable $(MTRMP)
    ///    (2) Else, try to get HKEY_LOCAL_MACHINE\SOFTWARE\METRATECH\METRANET\INSTALLDIR
    ///    (3) Else, throw an exception
    /// </summary>
    /// <returns></returns>
    public static string GetRmpDir()
    {
      if (!String.IsNullOrEmpty(rmpDir))
      {
        return rmpDir;
      }

      rmpDir = Environment.GetEnvironmentVariable("MTRMP");
      if (String.IsNullOrEmpty(rmpDir))
      {
        // Attempt to get HKEY_LOCAL_MACHINE\SOFTWARE\METRATECH\METRANET\INSTALLDIR
        using (RegistryKey registryKey = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\METRATECH\METRANET"))
        {
          if (registryKey != null)
          {
            rmpDir = registryKey.GetValue("InstallDir") as string;
          }
        }
      }
      
      if (String.IsNullOrEmpty(rmpDir) || !Directory.Exists(rmpDir))
      {
        string message = "Cannot find RMP directory from registry using 'HKEY_LOCAL_MACHINE\\SOFTWARE\\METRATECH\\METRANET\\INSTALLDIR' or from Environment variable 'MTRMP'";
        throw new BasicException(message, CallerInfo);
      }
      
      if (!rmpDir.EndsWith("\\"))
      {
        rmpDir += "\\";
      }
  
      return rmpDir;
    }

    public static bool IsGraphvizInstalled()
    {
      return !String.IsNullOrEmpty(GetGraphvizDotPath());
    }

    /// <summary>
    ///   Get the path to the dot.exe program from Graphviz
    /// </summary>
    /// <returns></returns>
    public static string GetGraphvizDotPath()
    {
      return string.Empty;

      /*
      string graphvizPath = String.Empty;
      string graphvizDotPath = null;

      // Attempt to get HKEY_LOCAL_MACHINE\SOFTWARE\AT&T Research Labs\Graphviz\InstallDir
      using (RegistryKey registryKey = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\AT&T Research Labs\Graphviz"))
      {
        if (registryKey != null)
        {
          graphvizPath = registryKey.GetValue("InstallPath") as string;
        }
      }

      if (!String.IsNullOrEmpty(graphvizPath))
      {
        graphvizDotPath = Path.Combine(Path.Combine(graphvizPath, "bin"), "dot.exe");
        if (!File.Exists(graphvizDotPath))
        {
          logger.Error(String.Format("Cannot find 'dot.exe' in the 'bin' folder for Graphviz path '{0}'", graphvizPath));
          graphvizDotPath = null;
        }
      }

      return graphvizDotPath;
       */
    }

    public static string GetRmpBinDir()
    {
      string rmpBin = Environment.GetEnvironmentVariable("MTRMPBIN");
      if (String.IsNullOrEmpty(rmpBin) || !Directory.Exists(rmpBin))
      {
        rmpBin = Path.Combine(GetRmpDir(), "bin");

        if (!Directory.Exists(rmpBin))
        {
          string message = 
            String.Format("Cannot find Bin directory from Environment variable 'MTRMPBIN' " +
                          "or based on installation directory '{0}'", rmpBin);
          throw new BasicException(message, CallerInfo);
        }
      }

      return rmpBin;
    }

    public static string GetIceDir()
    {
      if (!String.IsNullOrEmpty(iceDir))
      {
        return iceDir;
      }

      iceDir = Environment.GetEnvironmentVariable("ICEDIR");

      if (String.IsNullOrEmpty(iceDir) || !Directory.Exists(iceDir))
      {
        string message = "Cannot find ICE directory using environment variable 'ICEDIR'";
        throw new BasicException(message, CallerInfo);
      }

      if (!iceDir.EndsWith("\\"))
      {
        iceDir += "\\";
      }

      return iceDir;
    }

    public static string GetIceBinDir()
    {
      iceDir = Environment.GetEnvironmentVariable("ICEBIN");

      if (String.IsNullOrEmpty(iceDir) || !Directory.Exists(iceDir))
      {
        string message = "Cannot find ICE directory using environment variable 'ICEBIN'";
        throw new BasicException(message, CallerInfo);
      }

      if (!iceDir.EndsWith("\\"))
      {
        iceDir += "\\";
      }

      return iceDir;
    }

    public static string GetConfigDir()
    {
      string configDir = Path.Combine(GetRmpDir(), "config");
      if (!Directory.Exists(configDir))
      {
        string message = String.Format("Cannot find configuration directory '{0}'", configDir);
        throw new BasicException(message, CallerInfo);
      }

      return configDir;
    }

    public static string GetExtensionsDir()
    {
      string extensionsDir = Path.Combine(GetRmpDir(), "extensions");
      if (!Directory.Exists(extensionsDir))
      {
        string message = String.Format("Cannot find extensions directory '{0}'", extensionsDir);
        throw new BasicException(message, CallerInfo);
      }

      return extensionsDir;
    }

    public static List<string> GetExtensionDirectoryNames()
    {
      return Directory.GetDirectories(GetExtensionsDir()).ToList();
    }

    public static string GetBusinessEntityConfigDir()
    {
      string configDir = Path.Combine(GetConfigDir(), "BusinessEntity");
      if (!Directory.Exists(configDir))
      {
        string message = String.Format("Cannot find configuration directory '{0}'", configDir);
        throw new BasicException(message, CallerInfo);
      }
      return configDir;
    }

    public static string GetBusinessEntityConfigFile()
    {
      string configFile = Path.Combine(GetBusinessEntityConfigDir(), "be.cfg.xml");
      Check.Require(File.Exists(configFile), String.Format("Cannot find business entity configuration file '{0}'", configFile));

      return configFile;
    }

    /// <summary>
    ///   Only the us localization files
    /// </summary>
    /// <returns></returns>
    public static List<string> GetBusinessEntityLocalizationFileNames()
    {
      var localizationFileNames = new List<string>();

      List<string> extensionDirectories = GetExtensionDirectoryNames();

      foreach (string extensionDir in extensionDirectories)
      {
        string localizationDir = 
          Path.Combine(Path.Combine(Path.Combine(extensionDir, "config"), "localization"), "businessentity");
        if (Directory.Exists(localizationDir))
        {
          localizationFileNames.AddRange(Directory.GetFiles(localizationDir, "*_us.xml").ToList());
        }
      }

      return localizationFileNames;
    }

    public static string GetBusinessEntityLocalizationDir(string extensionName)
    {
      return Path.Combine(Path.Combine(Path.Combine(Path.Combine(GetExtensionsDir(), extensionName), "config"), "Localization"), "BusinessEntity");
    }

    public static string GetCapabilityEnumFileName()
    {
      return Path.Combine(Path.Combine(Path.Combine(Path.Combine(Path.Combine(GetExtensionsDir(), "SystemConfig"), "config"), "EnumType"), "metratech.com"), "metratech.com_businessentity.xml");
    }
    /// <summary>
    ///   Create the following directory structure for business entities under the specified extension:
    ///   RMP\Extensions\extensionName
    ///                       -- BusinessEntity
    ///                              -- EntityGroup 
    ///                                     -- Entity
    ///                                     -- Rule
    ///                                    
    ///                       -- Interface
    /// 
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    public static void CreateBusinessEntityDirectories(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null", CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null", CallerInfo);

      string extensionsDir = Path.Combine(GetExtensionsDir(), extensionName);
      if (!Directory.Exists(extensionsDir))
      {
        Directory.CreateDirectory(extensionsDir);
      }

      string businessEntityDir = Path.Combine(extensionsDir, "BusinessEntity");
      if (!Directory.Exists(businessEntityDir))
      {
        Directory.CreateDirectory(businessEntityDir);
      }

      string entityGroupDir = Path.Combine(businessEntityDir, entityGroupName);
      if (!Directory.Exists(entityGroupDir))
      {
        Directory.CreateDirectory(entityGroupDir);
      }

      string entityDir = Path.Combine(entityGroupDir, "Entity");
      if (!Directory.Exists(entityDir))
      {
        Directory.CreateDirectory(entityDir);
      }

      string ruleDir = Path.Combine(entityGroupDir, "Rule");
      if (!Directory.Exists(ruleDir))
      {
        Directory.CreateDirectory(ruleDir);
      }

      string interfaceDir = Path.Combine(businessEntityDir, "Interface");
      if (!Directory.Exists(interfaceDir))
      {
        Directory.CreateDirectory(interfaceDir);
      }
    }


    


    public static string GetShadowCopyCacheDir()
    {
      string tempDir = Environment.GetEnvironmentVariable("TEMP");
      if (String.IsNullOrEmpty(tempDir))
      {
        tempDir = @"C:\Temp";
        
      }

      string dir = Path.Combine(tempDir, "MtBizEnt");
      if (!Directory.Exists(dir))
      {
        Directory.CreateDirectory(dir);
      }
      return dir;
    }

    public static void CleanShadowCopyCacheDir()
    {
      string dir = GetShadowCopyCacheDir();
      // delete directory
      try
      {
        Directory.Delete(dir, true);
      }
      catch (System.Exception e)
      {
        logger.Debug(String.Format("Cannot delete shadow copy cache directory '{0}': '{1}'", dir, e.Message));
      }
    }

    /// <summary>
    ///    If extensionName = "Core" and entityGroupName = "Common", then the rule dir is
    ///    RMP\Extensions\Core\BusinessEntity\Common\Rule
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public static string GetRuleDir(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", CallerInfo);

      string extensionDir = Path.Combine(GetExtensionsDir(), extensionName);
      string businessEntityDir = Path.Combine(extensionDir, "BusinessEntity");
      return Path.Combine(Path.Combine(businessEntityDir, entityGroupName), "Rule");
    }

    /// <summary>
    ///    If extensionName = "Core" and entityGroupName = "Common", then the computed property dir is
    ///    RMP\Extensions\Core\BusinessEntity\Common\ComputedProperty
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public static string GetComputedPropertyDir(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty", CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null or empty", CallerInfo);

      string extensionDir = Path.Combine(GetExtensionsDir(), extensionName);
      string businessEntityDir = Path.Combine(extensionDir, "BusinessEntity");
      return Path.Combine(Path.Combine(businessEntityDir, entityGroupName), "ComputedProperty");
    }

    public static string GetComputedPropertyTempDir(string extensionName, string entityGroupName)
    {
      return Path.Combine(GetComputedPropertyDir(extensionName, entityGroupName), "Temp");
    }


    

    

    
    public static string GetStarterCsProjFile()
    {
      string file = Path.Combine(GetBusinessEntityConfigDir(), "StarterBusinessEntity.csproj");
      if (!File.Exists(file))
      {
        string message = String.Format("Cannot find template csproj file '{0}'.", file);
        throw new BasicException(message, CallerInfo);
      }
      return file;
    }

    public static string GetTemplateCsProjFile()
    {
      string file = Path.Combine(GetBusinessEntityConfigDir(), "Template.csproj");
      if (!File.Exists(file))
      {
        string message = String.Format("Cannot find template csproj file '{0}'.", file);
        throw new BasicException(message, CallerInfo);
      }
      return file;
    }

    public static string GetStarterEntityInterfaceCsProjFile()
    {
      string file = Path.Combine(GetBusinessEntityConfigDir(), "StarterEntityInterface.csproj");
      if (!File.Exists(file))
      {
        string message = String.Format("Cannot find template csproj file '{0}'.", file);
        throw new BasicException(message, CallerInfo);
      }
      return file;
    }

    public static string GetLog4NetConfigFile()
    {
      return Path.Combine(GetBusinessEntityConfigDir(), "log4net.xml");
    }

    public static string GetLogFileDirectory()
    {
      LogLevel logLevel;
      return GetLogFileDirectoryAndLogLevel(out logLevel);
    }

    public static string GetLogFileDirectoryAndLogLevel(out LogLevel logLevel)
    {
      logLevel = LogLevel.Debug;

      string logFile = Path.Combine(Path.Combine(GetConfigDir(), "logging"), "logging.xml");
      if (!File.Exists(logFile))
      {
        string message = String.Format("Cannot find logging config file '{0}'.", logFile);
        throw new BasicException(message);
      }

      XDocument xmldoc = XDocument.Load(logFile);

      XElement xElement = xmldoc.XPathSelectElement("xmlconfig/logging_config/logfilename");
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <xmlconfig><logging_config><logfilename> in file '{0}'", logFile);
        throw new BasicException(message);
      }

      if (String.IsNullOrEmpty(xElement.Value) || String.IsNullOrEmpty(xElement.Value.Trim()))
      {
        string message = String.Format("Missing value for <xmlconfig><logging_config><logfilename> in file '{0}'.", logFile);
        throw new BasicException(message);
      }

      string fileName = xElement.Value.Trim();

      // Replace items enclosed in % with the corresponding value of the environment variable
      // For example, replace %temp% with C:\Temp
      // Useful site for debugging regex http://regex.larsolavtorvik.com/ 
      fileName = Regex.Replace(fileName, "%[^%](.+?)%", new MatchEvaluator(ResolveEnvironmentVariable));

      // Get the log level
      xElement = xmldoc.XPathSelectElement("xmlconfig/logging_config/loglevel");
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <xmlconfig><logging_config><loglevel> in file '{0}'", logFile);
        throw new BasicException(message);
      }

      if (String.IsNullOrEmpty(xElement.Value) || String.IsNullOrEmpty(xElement.Value.Trim()))
      {
        string message = String.Format("Missing value for <xmlconfig><logging_config><loglevel> in file '{0}'.", logFile);
        throw new BasicException(message);
      }

      int mtLogLevel;
      try
      {
         mtLogLevel = Convert.ToInt32(xElement.Value);
      }
      catch (System.Exception)
      {
        string message = String.Format("Cannot convert value '{0}' to integer for element <xmlconfig><logging_config><loglevel> in file '{1}'.",
                                       xElement.Value, logFile);
        throw new BasicException(message);
      }
      
      switch(mtLogLevel)
      {
        case 0:
          {
            logLevel = LogLevel.Off;
            break;
          }
        case 1:
          {
            logLevel = LogLevel.Fatal;
            break;
          }
        case 2:
          {
            logLevel = LogLevel.Error;
            break;
          }
        case 3:
          {
            logLevel = LogLevel.Warn;
            break;
          }
        case 4:
          {
            logLevel = LogLevel.Info;
            break;
          }
        case 5:
        case 6:
          {
            logLevel = LogLevel.Debug;
            break;
          }
        default:
          {
            logger.Warn(String.Format("Cannot interpret log level '{0}' specified in file '{1}'. Using 'DEBUG'.", mtLogLevel, logFile));
            break;
          }
      }

      return Path.GetDirectoryName(fileName);
    }

    /// <summary>
    ///    Return the contents of <logfilename> from RMP\config\logging\logging.xml
    /// </summary>
    /// <returns></returns>
    public static string GetLogFile()
    {
      // Create new file for BE's until log4net is adopted universally
      return Path.Combine(GetRmpDir(), "MTLog.Be.txt");

      /*
      string logFile = Path.Combine(Path.Combine(GetConfigDir(), "logging"), "logging.xml");
      if (!File.Exists(logFile))
      {
        string message = String.Format("Cannot find logging config file '{0}'.", logFile);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      XDocument xmldoc = XDocument.Load(logFile);

      XElement xElement = xmldoc.XPathSelectElement("xmlconfig/logging_config/logfilename");
      if (xElement == null)
      {
        string message = String.Format("Cannot find the path <xmlconfig><logging_config><logfilename> in file '{0}'", logFile);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      if (String.IsNullOrEmpty(xElement.Value) || String.IsNullOrEmpty(xElement.Value.Trim()))
      {
        string message = String.Format("Missing value for <xmlconfig><logging_config><logfilename> in file '{0}'.", logFile);
        throw new BasicException(message, SystemConfig.CallerInfo);
      }

      string fileName = xElement.Value.Trim();

      // Replace items enclosed in % with the corresponding value of the environment variable
      // For example, replace %temp% with C:\Temp
      // Useful site for debugging regex http://regex.larsolavtorvik.com/ 
      fileName = Regex.Replace(fileName, "%[^%](.+?)%", new MatchEvaluator(ResolveEnvironmentVariable));

      return fileName;
      */
    }

    public static string GetAbbreviatedExtensionEntityGroupCombination(string extensionName, string entityGroupName)
    {
      string combo = null;

      var entityGroupsByExtension = GetEntityGroupsByExtension();
      List<string> entityGroups;
      entityGroupsByExtension.TryGetValue(extensionName.ToLower(), out entityGroups);

      // Check.Require(entityGroups != null, String.Format("Cannot find extension '{0}'", extensionName));

      string extensionAbbreviation = null;
      string entityGroupAbbreviation = null;

      // Check.Require(entityGroups.Find(s => s.ToLower() == entityGroupName.ToLower()) != null, 
      //              String.Format("Cannot find entity group '{0}' for extension '{1}'", entityGroupName, extensionName));

    	string tempExtensionName = extensionName.IndexOf('.') > 0
    	                           	? extensionName.Substring(extensionName.LastIndexOf('.') + 1)
    	                           	: extensionName;

			extensionAbbreviation = tempExtensionName.Length > 3 ? tempExtensionName.Substring(0, 3).ToLower() : tempExtensionName.ToLower();
      entityGroupAbbreviation = entityGroupName.Length > 3 ? entityGroupName.Substring(0, 3).ToLower() : entityGroupName.ToLower();

      combo = extensionAbbreviation + "_" + entityGroupAbbreviation;

      entityGroupsByExtension.Remove(extensionName.ToLower());
   
      Check.Require(!String.IsNullOrEmpty(extensionAbbreviation), 
                    String.Format("Cannot create unique combination of extension name '{0}' and entity group '{1}'", extensionName, entityGroupName),
                    CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityGroupAbbreviation),
                    String.Format("Cannot create unique combination of extension name '{0}' and entity group '{1}'", extensionName, entityGroupName),
                    CallerInfo);

      // If combo is a duplicate, return truncated hash of extensionName and entityGroupName
      foreach (string extension in entityGroupsByExtension.Keys)
      {
        if (!extension.StartsWith(extensionAbbreviation)) continue;

        entityGroups = entityGroupsByExtension[extension];

        foreach(string entityGroup in entityGroups)
        {
          if (!entityGroup.StartsWith(entityGroupAbbreviation)) continue;

          combo = Math.Abs((extensionName + entityGroupName).GetHashCode()).ToString();

          if (combo.Length > 8)
          {
            combo = combo.Substring(0, 7);
          }

          break;
        }
      }

      return combo;
        
    }

    public static List<string> GetEntityGroupNames(string extensionName)
    {
      Dictionary<string, List<string>> entityGroupsByExtension = GetEntityGroupsByExtension();
      List<string> entityGroupNames;
      entityGroupsByExtension.TryGetValue(extensionName.ToLower(), out entityGroupNames);
      
      if (entityGroupNames == null)
      {
        // return empty List
        entityGroupNames = new List<string>();
      }

      return entityGroupNames;
    }

    public static Dictionary<string, List<string>> GetEntityGroupsByExtension()
    {
      var entityGroupsByExtension = new Dictionary<string, List<string>>();
      string[] extensionDirs = Directory.GetDirectories(GetExtensionsDir());
      foreach (string extensionDir in extensionDirs)
      {
        string extensionName = Path.GetFileName(extensionDir).ToLower();

        string[] businessEntityDirs = Directory.GetDirectories(extensionDir, "BusinessEntity");

        foreach (string businessEntityDir in businessEntityDirs)
        {
          string[] entityGroupDirs = Directory.GetDirectories(businessEntityDir, "*", SearchOption.TopDirectoryOnly);

          foreach(string entityGroupDir in entityGroupDirs)
          {
            string entityGroupName = Path.GetFileName(entityGroupDir).ToLower();

            if (entityGroupName == "interface" || entityGroupName == ".svn" || entityGroupName == "_svn") continue;

            List<string> entityGroupNames;
            entityGroupsByExtension.TryGetValue(extensionName, out entityGroupNames);
            if (entityGroupNames == null)
            {
              entityGroupNames = new List<string>() {entityGroupName};
              entityGroupsByExtension.Add(extensionName, entityGroupNames);
            }
            else
            {
              entityGroupNames.Add(entityGroupName);
            }
          }
        }

      }
      return entityGroupsByExtension;
    }

    private static string ResolveEnvironmentVariable(Match matchResult)
    {
      string result = matchResult.Value.Replace("%", "");
      result = Environment.GetEnvironmentVariable(result);
      if (String.IsNullOrEmpty(result))
      {
        string message = String.Format("Cannot find environment variable '{0}'", result);
        throw new BasicException(message, CallerInfo);
      }

      return result;
    }

    /// <summary>
    /// </summary>
    /// <returns></returns>
    public static string GetNhibernateConfigFile()
    {
      return Path.Combine(GetBusinessEntityConfigDir(), "NHibernate.cfg.xml");
    }

    public static string GetNhibernateQueryLogFile()
    {
      return Path.Combine(GetRmpDir(), "nhquerylog.txt");
    }

    public static string GetEntityTemplate()
    {
      string template = Path.Combine(GetBusinessEntityConfigDir(), "EntityClass.tt");
      if (!File.Exists(template))
      {
        string message = String.Format("Cannot find Entity template file '{0}'", template);
        throw new BasicException(message, CallerInfo);
      }
      return template;
    }

    public static string GetEntityInterfaceTemplate()
    {
      string template = Path.Combine(GetBusinessEntityConfigDir(), "EntityInterface.tt");
      if (!File.Exists(template))
      {
        string message = String.Format("Cannot find Entity interface template file '{0}'", template);
        throw new BasicException(message, CallerInfo);
      }
      return template;
    }

    public static string GetWindsorContainerConfigFile()
    {
      string file = Path.Combine(GetBusinessEntityConfigDir(), "Castle.WindsorContainer.cfg.xml");
      if (!File.Exists(file))
      {
        string message = String.Format("Cannot find WindsorContainer config file '{0}'", file);
        throw new BasicException(message, CallerInfo);
      }
      return file;
    }

    public static List<string> GetServersXml()
    {
        List<string> serversXml = new List<string>();

        serversXml.Add(Path.Combine(GetRmpDir(), SERVERS_XML_PATH));

        IMTRcd rcd = new MTRcd();
        IMTRcdFileList files = rcd.RunQuery(SERVERS_XML_PATH, true);

        foreach (string file in files)
        {
            serversXml.Add(file);
        }

      //string serversXml = Path.Combine(Path.Combine(GetConfigDir(), "serveraccess"), "servers.xml");
      //if (!File.Exists(serversXml))
      //{
      //  string message = String.Format("Cannot find file '{0}'", serversXml);
      //  throw new BasicException(message, CallerInfo);
      //}

      return serversXml;
    }

    public static string MakeAssemblyNameReadyForLoadFrom(string assemblyName)
    {
      return (assemblyName.IndexOf(".dll") == -1) ? assemblyName.Trim() + ".dll" : assemblyName.Trim();
    }

    public static string GetComputedPropertyTemplateFile()
    {
      string fileName = Path.Combine(GetBusinessEntityConfigDir(), "ComputedPropertyTemplate.cs.txt");
      Check.Ensure(File.Exists(fileName), String.Format("Cannot find file '{0}'", fileName));
      return fileName;
    }

    #endregion

    #region Properties
  
    /// <summary>
    ///   Return the ClassName::MethodName of the caller.
    /// </summary>
    /// <returns></returns>
    public static string CallerInfo
    {
      get
      {
        StackTrace stackTrace = new StackTrace();
        StackFrame stackFrame = stackTrace.GetFrame(1);
        MethodBase methodBase = stackFrame.GetMethod();
        return methodBase.ReflectedType.Name + "::" + methodBase.Name;
      }
    }
    #endregion

    #region Data
    private static string rmpDir;
    private static string iceDir;
    private static readonly ILog logger = LogManager.GetLogger("SystemConfig");

    private const string SERVERS_XML_PATH = @"config\ServerAccess\servers.xml";
    #endregion

  }

  #region Enums
  public enum DatabaseType
  {
    SqlServer,
    Oracle
  }

  #endregion
}

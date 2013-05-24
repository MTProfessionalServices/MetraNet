using System;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Reflection;

using log4net;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Rule;

using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  /// <summary>
  /// </summary>
  [Serializable]
  public static class AppDomainHelper
  {
    #region Public Methods

    public static AppDomain CreateAppDomain(string extensionName, string entityGroupName)
    {
      AppDomain appDomain = null;

      // Setup AppDomain
      AppDomainSetup domainSetup = new AppDomainSetup();

      string applicationName = AppDomainNamePrefix;
      if (!String.IsNullOrEmpty(extensionName) && !String.IsNullOrEmpty(entityGroupName))
      {
        applicationName = AppDomainNamePrefix + extensionName + "-" + entityGroupName + "-";
      }

      domainSetup.ApplicationName = applicationName + Guid.NewGuid().ToString().GetHashCode().ToString("x");

      // Set the base directory. 
      domainSetup.ApplicationBase = SystemConfig.GetBinDir();
      domainSetup.ShadowCopyFiles = "true";
      // domainSetup.ShadowCopyDirectories = SystemConfig.GetBinDir();
      domainSetup.CachePath = SystemConfig.GetShadowCopyCacheDir();

      // Create AppDomain
      appDomain = AppDomain.CreateDomain(domainSetup.ApplicationName, null, domainSetup);
      appDomain.AssemblyResolve += ResolveAssembly;
      appDomain.DomainUnload += new EventHandler(AppDomainUnload);

      return appDomain;
    }

    static void AppDomainUnload(object sender, EventArgs e)
    {
      // logger.Debug(String.Format("Unloading AppDomain '{0}'", ((AppDomain)sender).FriendlyName));
      logger.Debug(String.Format("Unloading AppDomain."));
    }

    public static AppDomain CreateAppDomain(ICollection<string> loadAssemblies)
    {
      AppDomain appDomain = null;

      // Setup AppDomain
      AppDomainSetup domainSetup = new AppDomainSetup();

      string applicationName = AppDomainNamePrefix; 
      domainSetup.ApplicationName = applicationName + Guid.NewGuid().ToString().GetHashCode().ToString("x");

      // Set the base directory. 
      domainSetup.ApplicationBase = SystemConfig.GetBinDir();
      domainSetup.ShadowCopyFiles = "true";
      // domainSetup.ShadowCopyDirectories = SystemConfig.GetBinDir();
      domainSetup.CachePath = SystemConfig.GetShadowCopyCacheDir();

      // Create AppDomain
      appDomain = AppDomain.CreateDomain(domainSetup.ApplicationName, null, domainSetup);
      appDomain.AssemblyResolve += ResolveAssembly;
      
      foreach(string assembly in loadAssemblies)
      {
        appDomain.Load(assembly);
      }
      
      return appDomain;
    }

    /// <summary>
    ///    Get the type name for the specified property name, classNameWithNamespace, assemblyName and tenant.
    /// </summary>
    /// <param name="assemblyName"></param>
    /// <param name="classNameWithNamespace"></param>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public static string GetPropertyTypeName(string assemblyName, string classNameWithNamespace, string propertyName)
    {
      string propertyTypeName = String.Empty;
      AppDomain appDomain = null;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain(null, null);

        string location = Assembly.GetExecutingAssembly().Location;

        TypeLoader typeLoader =
          (TypeLoader)appDomain.CreateInstanceFromAndUnwrap(location, typeof(TypeLoader).FullName);

        propertyTypeName = typeLoader.GetPropertyTypeName(assemblyName, classNameWithNamespace, propertyName);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return propertyTypeName;
    }

    public static Dictionary<CRUDEvent, List<RuleData>> GetRulesFromAssembly(string entityName, string assemblyNameWithPath)
    {
      Dictionary<CRUDEvent, List<RuleData>> rulesByEvent = null;
      AppDomain appDomain = null;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain(null, null);

        string location = Assembly.GetExecutingAssembly().Location;

        TypeLoader typeLoader =
          (TypeLoader)appDomain.CreateInstanceFromAndUnwrap(location, typeof(TypeLoader).FullName);

        rulesByEvent = typeLoader.GetRulesFromAssembly(entityName, assemblyNameWithPath);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return rulesByEvent;
    }

    public static bool ValidateComputationTypeName(string computationTypeName, out List<ErrorObject> errors)
    {
      bool isValid = false;
      AppDomain appDomain = null;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain(null, null);

        string location = Assembly.GetExecutingAssembly().Location;

        TypeLoader typeLoader =
          (TypeLoader)appDomain.CreateInstanceFromAndUnwrap(location, typeof(TypeLoader).FullName);

        isValid = typeLoader.ValidateComputationTypeName(computationTypeName, out errors);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return isValid;
    }

    public static string GetComputationTypeName(string entityName, string propertyName, string assemblyNameWithPath)
    {
      string computationTypeName = String.Empty;

      AppDomain appDomain = null;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain(null, null);

        string location = Assembly.GetExecutingAssembly().Location;

        TypeLoader typeLoader =
          (TypeLoader)appDomain.CreateInstanceFromAndUnwrap(location, typeof(TypeLoader).FullName);

        computationTypeName = typeLoader.GetComputationTypeName(entityName, propertyName, assemblyNameWithPath);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }

      return computationTypeName;
    }

    private static Assembly ResolveAssembly(object sender, ResolveEventArgs args)
    {
      AssemblyName qualifiedAssemblyName = new AssemblyName(args.Name);
      string assemblyName = Path.Combine(SystemConfig.GetBinDir(), qualifiedAssemblyName.Name + ".dll");
      logger.Debug(String.Format("Attempting to load '{0}'", qualifiedAssemblyName.Name));
      Assembly assembly = Assembly.LoadFrom(assemblyName);

      return assembly;
    }
    #endregion

    #region Internal Methods
    static AppDomainHelper()
    {
      AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(appDomain_AssemblyResolve);
    }

    static Assembly appDomain_AssemblyResolve(object sender, ResolveEventArgs args)
    {
      Assembly retval = null;
      string searchName = args.Name.Substring(0, (args.Name.IndexOf(',') == -1 ? args.Name.Length : args.Name.IndexOf(','))).ToUpper();

      if (!searchName.Contains(".DLL"))
      {
        searchName += ".DLL";
      }

      if (searchName.EndsWith(".RESOURCES.DLL"))
          return null;

      try
      {
        AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
        retval = Assembly.Load(nm);
      }
      catch (System.Exception)
      {
        try
        {
          retval = Assembly.LoadFrom(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), searchName));
        }
        catch (System.Exception)
        {
          string fileName = Path.Combine(SystemConfig.GetBinDir(), searchName);
          if (File.Exists(fileName))
          {
            retval = Assembly.LoadFrom(fileName);
          }
        }
      }

      return retval;
    }
    #endregion

    #region Properties
    public static string AppDomainNamePrefix
    {
      get
      {
        return "BEAppDomain-";
      }
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("[AppDomainProxy]");
    #endregion
  }

  
}

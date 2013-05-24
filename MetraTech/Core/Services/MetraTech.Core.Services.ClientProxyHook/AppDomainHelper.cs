using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using MetraTech.ActivityServices.Configuration;

namespace MetraTech.Core.Services.ClientProxyHook
{
  /// <summary>
  /// </summary>
  [Serializable]
  public static class AppDomainHelper
  {
    #region Public Methods

    public static void CleanShadowCopyDir()
    {
      try
      {
        if (Directory.Exists(ShadowCopyDir))
        {
          Directory.Delete(ShadowCopyDir, true);
        }
      }
      catch (Exception e)
      {
        m_logger.LogWarning(String.Format("Cannot delete shadow copy dir '{0}' because: '{1}'", ShadowCopyDir, e.Message));
      }
    }

    public static void BuildConfiguration(string assemblyName, 
                                          out Dictionary<string, List<CMASProceduralService>> svcNames)
    {
      AppDomain appDomain = null;

      try
      {
        // Create AppDomain
        appDomain = CreateAppDomain();
        string location = Assembly.GetExecutingAssembly().Location;

        BuildConfigurationProxy buildConfigurationProxy =
          (BuildConfigurationProxy)appDomain.CreateInstanceFromAndUnwrap(location, typeof(BuildConfigurationProxy).FullName);

        buildConfigurationProxy.BuildConfiguration(assemblyName, out svcNames);
      }
      finally
      {
        // Unload the AppDomain
        if (appDomain != null)
        {
          AppDomain.Unload(appDomain);
        }
      }
    }

  
    #endregion

    #region Private Methods
    private static AppDomain CreateAppDomain()
    {
      AppDomain appDomain;

      // Setup AppDomain
      var domainSetup = new AppDomainSetup();

      domainSetup.ApplicationName = AppDomainNamePrefix + Guid.NewGuid().ToString().GetHashCode().ToString("x");

      // Set the base directory. 
      domainSetup.ApplicationBase = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
      domainSetup.ShadowCopyFiles = "true";
      domainSetup.CachePath = m_shadowCopyDir;

      // Create AppDomain
      appDomain = AppDomain.CreateDomain(domainSetup.ApplicationName, null, domainSetup);

      return appDomain;
    }
    #endregion

    #region Properties
    public static string AppDomainNamePrefix
    {
      get
      {
        return "ClientProxyHookAppDomain-";
      }
    }

    public static string ShadowCopyDir
    {
      get
      {
        return m_shadowCopyDir;
      }
    }
    #endregion

    #region Data
    static Logger m_logger = new Logger("[ClientProxyHook]");
    private static readonly string m_shadowCopyDir = Path.Combine(Path.GetTempPath(), "ClientProxyHook");
    #endregion
  }

  
}

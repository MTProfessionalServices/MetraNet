using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Web.Administration;
using MetraTech.Interop.RCD;
using System.IO;
using System.Reflection;

namespace IIS7ConfigMgr
{
  class IIS7ConfigMgr
  {
    #region Private Members
    private static ServerManager m_ServerManager = new ServerManager();
    private static Site m_DefaultWebSite = null;

    private static IMTRcd m_RCD = new MTRcdClass();

    private const string LISTENER_ISAPI_DESC = "MetraTech Listener";
    private const string HTTP_COMPRESSION_ISAPI_DESC = "HTTP Compression";

    #region Default Paths
    private const string MCM_PATH = @"UI\mcm";
    private const string VALIDATION_PATH = @"Config\Validation";
    private const string CONFIG_PATH = @"Config";
    private const string ROOT_PATH = @"UI\Root";
    private const string MDM_PATH = @"UI\mdm";
    private const string MAM_PATH = @"UI\mam";
    private const string MOM_PATH = @"UI\mom";
    private const string MPTE_PATH = @"UI\mpte";

    private const string MSIX_PATH = @"Bin";
    private const string BATCH_PATH = @"WebServices\Batch";
    private const string RERUN_PATH = @"WebServices\BillingRerun";
    private const string ACCHIERARCHY_PATH = @"WebServices\AccountHierarchy";
    private const string METRANET_PATH = @"UI\MetraNet";
    private const string METRANET_HELP_PATH = @"UI\MetraNetHelp";
    private const string IMAGEHANDLER_PATH = @"UI\ImageHandler";
    private const string SUGGEST_PATH = @"UI\Suggest";
    private const string METRAVIEW_PATH = @"Extensions\MetraView\Sites\MetraView";
    private const string METRAVIEW_HELP_PATH = @"Extensions\MetraView\Sites\MetraView\MetraViewHelp";
    private const string RES_PATH = @"UI\Res";
    private const string AGREEMENTS_PATH = @"UI\Agreements";
    #endregion

    private const string CLASSIC_APP_POOL = "MetraNetClassicAppPool";
    private const string USER_APP_POOL = "MetraNetUserAppPool";

    private const int FEATURE_EXECUTE = 4;
    #endregion

    static void Main(string[] args)
    {
      Console.ForegroundColor = ConsoleColor.White;
      Console.WriteLine("Stopping Web Site... ");
      try
      {
        m_DefaultWebSite = m_ServerManager.Sites["Default Web Site"];
        if (m_DefaultWebSite == null)
        {
          Console.ForegroundColor = ConsoleColor.Red;
          Console.WriteLine("Could not find Default Web Site! It errors goes away when you recompile in x86 configuration. Will try using FirstOrDefault");
          Console.ForegroundColor = ConsoleColor.White;
          m_DefaultWebSite = m_ServerManager.Sites.FirstOrDefault();
          if (m_DefaultWebSite != null)
            Console.WriteLine("Using site {0}", m_DefaultWebSite.Name);
        }
        m_DefaultWebSite.Stop();
      }
      catch (Exception)
      {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine("Unable to stop web site.... skipping...");
        Console.ForegroundColor = ConsoleColor.White;
      }

      Console.WriteLine("Cleaning up... ");
      string[] apps = { "RMP", "Listener", "UI" };
      RemoveWebApps(apps);

      m_ServerManager.CommitChanges();
      m_DefaultWebSite = m_ServerManager.Sites["Default Web Site"];

      InstallWebApps(apps);

      m_ServerManager.CommitChanges();
      m_DefaultWebSite = m_ServerManager.Sites["Default Web Site"];

      EnableISAPIHandler("msix");

      m_ServerManager.CommitChanges();

      Console.ForegroundColor = ConsoleColor.White;
      Console.WriteLine("Starting Web Site... ");
      try
      {
        m_DefaultWebSite = m_ServerManager.Sites["Default Web Site"];
        m_DefaultWebSite.Start();
      }
      catch (Exception)
      {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine("Unable to start web site.... skipping...");
        Console.ForegroundColor = ConsoleColor.White;
      }

      Console.ResetColor();
    }

    #region Install MetraNet Web Apps
    private static void InstallWebApps(string[] appsToAdd)
    {
      foreach (string appToRemove in appsToAdd)
      {
        switch (appToRemove.ToUpper())
        {
          case "UI":
            InstallWebApp("MetraView", METRAVIEW_PATH, USER_APP_POOL, null);
            InstallWebApp("MetraViewHelp", METRAVIEW_HELP_PATH, USER_APP_POOL, null);

            InstallWebApp("mom", MOM_PATH, CLASSIC_APP_POOL, null);
            InstallWebApp("BillingRerun", RERUN_PATH, USER_APP_POOL, null);

            InstallWebApp("mcm", MCM_PATH, CLASSIC_APP_POOL, null);
            InstallWebApp("validation", VALIDATION_PATH, USER_APP_POOL, null);
            InstallWebApp("MetraCare", MAM_PATH, USER_APP_POOL, null);
            InstallWebApp("mam", MAM_PATH, CLASSIC_APP_POOL, null);

            InstallWebApp("MetraOffer", MCM_PATH, USER_APP_POOL, null);
            InstallWebApp("MetraControl", MOM_PATH, USER_APP_POOL, null);
            InstallWebApp("AccountHierarchy", ACCHIERARCHY_PATH, USER_APP_POOL, null);
            InstallWebApp("ImageHandler", IMAGEHANDLER_PATH, CLASSIC_APP_POOL, null);

            //AddImageHandlerScriptMaps("ImageHandler");
            InstallWebApp("Suggest", SUGGEST_PATH, USER_APP_POOL, null);
            InstallWebApp("MetraNet", METRANET_PATH, USER_APP_POOL, null);

            InstallWebApp("MetraNetHelp", METRANET_HELP_PATH, USER_APP_POOL, null);
            InstallWebApp("Res", RES_PATH, USER_APP_POOL, null);
            SetExpiresHeader("Res");

            InstallWebApp("mdm", MDM_PATH, CLASSIC_APP_POOL, null);
            InstallWebApp("mpte", MPTE_PATH, CLASSIC_APP_POOL, null);

            InstallWebApp("Agreements", AGREEMENTS_PATH, USER_APP_POOL, null);
            break;
          case "LISTENER":
            InstallWebApp("msix", MSIX_PATH, USER_APP_POOL, null);
            InstallWebApp("Batch", BATCH_PATH, USER_APP_POOL, null);
            break;
          case "RMP":
            CreateAppPool("MetraNetClassicAppPool", ProcessModelIdentityType.ApplicationPoolIdentity, ManagedPipelineMode.Classic);
            CreateAppPool("MetraNetUserAppPool", ProcessModelIdentityType.ApplicationPoolIdentity, ManagedPipelineMode.Integrated);
            InstallWebServiceExtensions();
            break;

          default:
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("Unable to remove unknown app: {0}", appToRemove);
            Console.ForegroundColor = ConsoleColor.White;
            break;
        }
      }
    }

    private static void SetExpiresHeader(string appName)
    {
      m_ServerManager.CommitChanges();
      m_DefaultWebSite = m_ServerManager.Sites["Default Web Site"];

      Application webApp = m_DefaultWebSite.Applications[string.Format("/{0}", appName)];
      Configuration webAppConfig = webApp.GetWebConfiguration();
      ConfigurationSection staticContentSection = webAppConfig.GetSection("system.webServer/staticContent");
      ConfigurationElement clientCacheElement = staticContentSection.GetChildElement("clientCache");
      clientCacheElement["cacheControlMode"] = @"UseMaxAge";
    }

    private static void AddImageHandlerScriptMaps(string appName)
    {
      m_ServerManager.CommitChanges();
      m_DefaultWebSite = m_ServerManager.Sites["Default Web Site"];

      Application webApp = m_DefaultWebSite.Applications[string.Format("/{0}", appName)];
      Configuration webAppConfig = webApp.GetWebConfiguration();
      ConfigurationSection handlersSection = webAppConfig.GetSection("system.webServer/handlers");
      ConfigurationElementCollection handlersCollection = handlersSection.GetCollection();
      ConfigurationElement addElement = handlersCollection.CreateElement("add");
      addElement["name"] = @"CustomGifHandler";
      addElement["path"] = @"*.gif";
      addElement["verb"] = @"GET,HEAD,POST";
      addElement["modules"] = @"IsapiModule";
      string systemRoot = Environment.GetEnvironmentVariable("SystemRoot");
      systemRoot = String.IsNullOrEmpty(systemRoot) ? @"c:\Windows\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll" : Path.Combine(systemRoot, @"\Microsoft.NET\Framework\v2.0.50727\aspnet_isapi.dll");
      addElement["scriptProcessor"] = systemRoot;
      addElement["resourceType"] = @"Either";
      try
      {
        if (!handlersCollection.Contains(addElement))
        {
          handlersCollection.AddAt(0, addElement);
        }
      }
      catch (Exception)
      {
      }
    }

    private static string GetAppPath(string appPath)
    {
      string retval = string.Empty;

      string basePath = Path.Combine(m_RCD.InstallDir, appPath);
      string sourceLocFileName = Path.Combine(basePath, "source_location.txt");

      if (!File.Exists(sourceLocFileName))
      {
        if (string.Compare(appPath, "bin", true) == 0 && !Directory.Exists(basePath))
        {
          basePath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        }

        retval = basePath;
      }
      else
      {
        using (StreamReader rdr = new StreamReader(sourceLocFileName))
        {
          string newDir = rdr.ReadLine();

          retval = Path.GetFullPath(Path.Combine(basePath, newDir));
        }
      }

      return retval;
    }

    private static void InstallWebServiceExtensions()
    {
      Configuration appHostConfig = m_ServerManager.GetApplicationHostConfiguration();

      ConfigurationSection aspSection = appHostConfig.GetSection("system.webServer/asp");
      aspSection["enableParentPaths"] = true;

      ConfigurationSection isapiCgiRestrictionSection = appHostConfig.GetSection("system.webServer/security/isapiCgiRestriction");
      ConfigurationElementCollection isapiCgiRestrictionCollection = isapiCgiRestrictionSection.GetCollection();

      #region add listener.dll
      if (!isapiCgiRestrictionCollection.Any(e => FileNamesAreEqual(e["path"].ToString(), "listener.dll")))
      {
        var element = isapiCgiRestrictionCollection.CreateElement();
        element["description"] = LISTENER_ISAPI_DESC;
        element["allowed"] = true;
        element["path"] = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "listener.dll");

        isapiCgiRestrictionCollection.Add(element);
      }
      #endregion

      #region add gzip.dll
      if (!isapiCgiRestrictionCollection.Any(e => FileNamesAreEqual(e["path"].ToString(), "gzip.dll")))
      {
        var element = isapiCgiRestrictionCollection.CreateElement();
        element["description"] = HTTP_COMPRESSION_ISAPI_DESC;
        element["allowed"] = true;
        element["path"] = Path.Combine(Environment.SystemDirectory, "gzip.dll");

        isapiCgiRestrictionCollection.Add(element);
      }
      #endregion
    }

    private static bool FileNamesAreEqual(string path, string fileName)
    {
      path = path.Trim();

      if (path.StartsWith("\""))
        path = path.Substring(1, path.IndexOf('"', 1)-1);
      else if (path.Contains(' '))
        path = path.Substring(0, path.IndexOf(' ', 1));

      string fCmp = Path.GetFileName(path);
      return fCmp.Equals(fileName, StringComparison.InvariantCultureIgnoreCase);
    }

    private static void CreateAppPool(string poolName, ProcessModelIdentityType identityType, ManagedPipelineMode managedPipelineMode)
    {
      Console.ForegroundColor = ConsoleColor.White;
      Console.Write("Creating App Pool: ");
      Console.ForegroundColor = ConsoleColor.Cyan;
      Console.WriteLine(String.Format("{0}, {1}, {2}", poolName, identityType, managedPipelineMode));
      Console.ForegroundColor = ConsoleColor.White;

      ApplicationPool appPool = m_ServerManager.ApplicationPools.Add(poolName);

      appPool.ManagedRuntimeVersion = "v4.0.30319";
      appPool.Enable32BitAppOnWin64 = true;
      appPool.Recycling.PeriodicRestart.Memory = 0;
      appPool.Recycling.PeriodicRestart.PrivateMemory = 0;
      appPool.Recycling.PeriodicRestart.Requests = 0;

      appPool.ProcessModel.IdentityType = identityType;

      appPool.ManagedPipelineMode = managedPipelineMode;
    }

    private static void InstallWebApp(string appName, string appPath, string appPool, string alias)
    {
      string path = GetAppPath(appPath);
      Console.ForegroundColor = ConsoleColor.White;
      Console.Write("Installing Web App: ");
      Console.ForegroundColor = ConsoleColor.Green;
      Console.WriteLine("{0}, {1}, {2}", appName, appPool, alias);
      Console.ForegroundColor = ConsoleColor.White;

      Application webApp = m_DefaultWebSite.Applications.Add(string.Format("/{0}", appName), path);

      webApp.ApplicationPoolName = appPool;

      if (!string.IsNullOrEmpty(alias))
      {
        // Commenting out alias support as in IIS7 this doesn't work...simply add new Web app
        // with alias name and point to same folder as original app
        //Application aliasApp = m_DefaultWebSite.Applications.Add(string.Format("/{0}", alias), path);
      }

    }

    private static void EnableISAPIHandler(string appName)
    {
      Application webApp = m_DefaultWebSite.Applications[string.Format("/{0}", appName)];
      Configuration config = webApp.GetWebConfiguration();
      ConfigurationSection handlersSection = config.GetSection("system.webServer/handlers");

      handlersSection["accessPolicy"] = (int)handlersSection["accessPolicy"] | FEATURE_EXECUTE;
    }


    #endregion

    #region Remove MetraNet Web Apps
    private static void RemoveWebApps(string[] appsToRemove)
    {
      foreach (string appToRemove in appsToRemove)
      {
        switch (appToRemove.ToUpper())
        {



          case "UI":
            RemoveWebApp("mcm");
            RemoveWebApp("MetraView");
            RemoveWebApp("MetraViewHelp");
            RemoveWebApp("mpm");
            RemoveWebApp("validation");
            RemoveWebApp("mam");
            RemoveWebApp("AccountHierarchy");
            RemoveWebApp("ImageHandler");
            RemoveWebApp("Suggest");
            RemoveWebApp("Res");
            RemoveWebApp("mom");
            RemoveWebApp("BillingRerun");
            RemoveWebApp("mdm");
            RemoveWebApp("mpte");
            RemoveWebApp("MetraNet");
            RemoveWebApp("MetraCare");
            RemoveWebApp("MetraNetHelp");
            RemoveWebApp("MetraOffer");
            RemoveWebApp("MetraControl");
            RemoveWebApp("Agreements");
            break;

          case "LISTENER":
            RemoveWebApp("msix");
            RemoveWebApp("Batch");
            break;

          case "RMP":
            DeleteAppPool("MetraNetUserAppPool");
            DeleteAppPool("MetraNetClassicAppPool");
            RemoveWebServiceExtensions();
            break;

          default:
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("Unable to remove unknown app: {0}", appToRemove);
            Console.ForegroundColor = ConsoleColor.White;
            break;
        }
      }
    }

    private static void RemoveWebServiceExtensions()
    {
      Configuration appHostConfig = m_ServerManager.GetApplicationHostConfiguration();
      ConfigurationSection isapiCgiRestrictionSection = appHostConfig.GetSection("system.webServer/security/isapiCgiRestriction");
      ConfigurationElementCollection isapiCgiRestrictionCollection = isapiCgiRestrictionSection.GetCollection();

      List<ConfigurationElement> elementsToRemove = new List<ConfigurationElement>();

      foreach (ConfigurationElement isapiElement in isapiCgiRestrictionCollection)
      {
        switch (isapiElement["description"].ToString())
        {
          case LISTENER_ISAPI_DESC:
          case HTTP_COMPRESSION_ISAPI_DESC:
            elementsToRemove.Add(isapiElement);
            break;
        }
      }

      foreach (ConfigurationElement element in elementsToRemove)
      {
        isapiCgiRestrictionCollection.Remove(element);
      }
    }

    private static void DeleteAppPool(string poolName)
    {
      ApplicationPool appPool = m_ServerManager.ApplicationPools[poolName];

      if (appPool != null)
      {
        m_ServerManager.ApplicationPools.Remove(appPool);
      }
    }

    private static void RemoveWebApp(string appName)
    {
      Application app = m_DefaultWebSite.Applications[string.Format("/{0}", appName)];

      if (app != null)
      {
        m_DefaultWebSite.Applications.Remove(app);
      }
    }
    #endregion
  }
}
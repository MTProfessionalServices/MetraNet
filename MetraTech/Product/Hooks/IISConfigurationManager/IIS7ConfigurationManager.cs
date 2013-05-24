using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Web.Administration;

namespace ICEUtils
{
  public class IIS7ConfigurationManager : IIISConfigurationManager
  {
    #region Private Members
    private ServerManager m_ServerManager = new ServerManager();
    private Site m_DefaultWebSite = null;

    private const string HTTP_COMPRESSION_ISAPI_DESC = "HTTP Compression";

    public const string METRANET_SYSTEM_APP_POOL = "MetraNetSystemAppPool";
    private const string CLASSIC_APP_POOL = "MetraNetClassicAppPool";
    public const string METRANET_USER_APP_POOL = "MetraNetUserAppPool";

    public const string DEFAULT_WEB_SITE_NAME = "Default Web Site";

    //private const int FEATURE_EXECUTE = 4;
    #endregion

    public IIS7ConfigurationManager()
    {
      this.m_DefaultWebSite = m_ServerManager.Sites[DEFAULT_WEB_SITE_NAME];

    }

    public bool WebAppExists(string appName)
    {
      return (m_DefaultWebSite.Applications[string.Format("/{0}", appName)] != null);
    }

    public void AddWebApp(string appName, string fullPath, string appPool)
    {
      Application webApp = m_DefaultWebSite.Applications.Add(string.Format("/{0}", appName), fullPath);

      webApp.ApplicationPoolName = appPool;

      this.CommitChanges();
    }

    public void RemoveWebApp(string appName)
    {
      Application app = m_DefaultWebSite.Applications[string.Format("/{0}", appName)];

      if (app != null)
      {
        m_DefaultWebSite.Applications.Remove(app);
      }
    }

    public void CreateAppPool(string poolName, ProcessModelIdentityType identityType, ManagedPipelineMode managedPipelineMode)
    {
      ApplicationPool appPool = m_ServerManager.ApplicationPools.Add(poolName);

      appPool.Enable32BitAppOnWin64 = true;
      appPool.Recycling.PeriodicRestart.Memory = 0;
      appPool.Recycling.PeriodicRestart.PrivateMemory = 0;
      appPool.Recycling.PeriodicRestart.Requests = 0;

      appPool.ProcessModel.IdentityType = identityType;

      appPool.ManagedPipelineMode = managedPipelineMode;
    }

    public void CommitChanges()
    {
      m_ServerManager.CommitChanges();
      m_DefaultWebSite = m_ServerManager.Sites[DEFAULT_WEB_SITE_NAME];
    }
  }

}

using System;
using System.Collections;
using System.Xml;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;

using MetraTech;
using MetraTech.Xml;
//using MetraTech.DataAccess;
using MetraTech.Interop.MTHooklib;
//using MetraTech.Interop.MTProductCatalog;
//using MetraTech.OnlineBill;
using Auth = MetraTech.Interop.MTAuth;
//using System.EnterpriseServices;
using MetraTech.Interop.RCD;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using Microsoft.Web.Administration;
using ICEUtils; //MetraTech.Product.Hooks.IISConfigurationManager.dll; need to relocate/change namespace

namespace MetraTech.Product.Hooks
{
  /// <summary>
  /// Summary description for DatabaseProperties
  /// </summary>
  /// 
  [Guid("92D90CCE-073A-43ba-A142-DE5E2FA5BF1F")]
  [ClassInterface(ClassInterfaceType.None)]
  public class MetraNetSiteHook : MetraTech.Interop.MTHooklib.IMTHook
  {
    private MetraTech.Logger mLog;
    private IMTRcd mRcd;

    //private bool RemoveAndAddIfVirtualDirectoryAlreadyExists = true;

    public MetraNetSiteHook()
    {
      mLog = new Logger("[MetraNetSiteHook]");
      mRcd = new MTRcdClass();
    }

    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
      try
      {
        mLog.LogDebug("Starting hook execution.");

        //Check if IIS is installed on this machine
        if (IISEnvironment.Instance.IISInstalled)
        {
          IMTRcdFileList files = (IMTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("Sites\\Site.xml");

          mLog.LogInfo("Found " + files.Count + " site configuration files");

          mLog.LogInfo("Loading site information from XML.");

          List<MetraNetSiteReference> sites = new List<MetraNetSiteReference>(files.Count);

          //Load the site information
          foreach (string file in files)
          {
            mLog.LogDebug("File:" + file);
            try
            {
              MetraNetSiteReference site = MetraNetSiteReference.CreateFromFile(file);
              mLog.LogDebug(string.Format("Site: Name='{0}' VirtualDirectory='{1}'", site.Name, site.VirtualDirectory));
              sites.Add(site);
            }
            catch (Exception ex)
            {
              mLog.LogWarning("Unable to retrieve site information from site configuration file: " + ex.Message);
              mLog.LogWarning(string.Format("Skipping site configuration file '{0}'", file));
            }
          }

          mLog.LogDebug(string.Format("Processing the {0} sites found", sites.Count));

          //Create the needed virtual directories
          IIISConfigurationManager siteManager = IISEnvironment.Instance.GetConfigurationManager();

          if (siteManager == null)
          {
            mLog.LogWarning("Unable to create/retrieve IISConfigurationManager for this version of IIS; Skipping site registration.");
          }
          else
          {
            foreach (MetraNetSiteReference site in sites)
            {
              if (!site.CreateVirtualDirectory)
                mLog.LogDebug(string.Format("Skipping site '{0}' as CreateVirtualDirectory in config file is false", site.Name));
              else
              {
                if (siteManager.WebAppExists(site.VirtualDirectory))
                {
                  mLog.LogInfo(string.Format("Virtual Directory '{0}' for site '{1}' already exists.", site.VirtualDirectory, site.Name));
                }
                else
                {
                  mLog.LogDebug(string.Format("Virtual Directory '{0}' for site '{1}' does not exist", site.VirtualDirectory, site.Name));
                  siteManager.AddWebApp(site.Name, site.Path, IIS7ConfigurationManager.METRANET_USER_APP_POOL);
                  mLog.LogInfo(string.Format("Virtual Directory '{0}' for site '{1}' created", site.VirtualDirectory, site.Name));
                }
              }
            }
          }
        }
        else
        {
          mLog.LogDebug("IIS does not appear to be installed on this machine; Skipping site registration.");
        }

        mLog.LogDebug("Ending hook execution.");
      }
      catch (System.Exception ex)
      {
        mLog.LogException("Exception executing MetraNetSiteHook", ex);
        throw ex;
      }
    }
  }

  [ComVisible(false)]
  public class MetraNetSiteReference
  {
    public string Name {get; set;}
    public string VirtualDirectory {get; set;}
    public bool CreateVirtualDirectory {get; set;}
    public string Path { get; set; }

    public static MetraNetSiteReference CreateFromFile(string filePath)
    {
      MetraNetSiteReference result = new MetraNetSiteReference();

      Regex exp = new Regex(@"(.*Sites\\)(.*)\\Config", RegexOptions.IgnoreCase);
      Match match = exp.Match(filePath);
      if (match == null || match.Groups == null || match.Groups.Count != 3)
        throw new Exception(string.Format("Unable to retrieve site name from file path name '{0}'", filePath));
      else
      {
        result.Name = match.Groups[2].Value;
        result.Path = match.Groups[1].Value + result.Name;
      }

      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(filePath);
      string virtualDirectory = doc.GetNodeValueAsString("/Site/VirtualDirectory");

      if (string.IsNullOrEmpty(virtualDirectory))
        throw new Exception(string.Format("Unable to retrieve VirtualDirectory tag from file '{0}'", filePath));
      else
        result.VirtualDirectory = virtualDirectory;

      //Wish there was a better way to get attributes
      XmlNode virtualDirectoryNode = doc.SelectOnlyNode("/Site/VirtualDirectory");
      
			XmlAttributeCollection attributes = virtualDirectoryNode.Attributes;
      string create = string.Empty;
      foreach (XmlAttribute attr in attributes)
			{
        if (string.Compare(attr.Name, "CreateDuringSynchronization", true) == 0)
				{
          create = attr.Value;
					break;
				}
			}
      if (string.IsNullOrEmpty(create) || string.Compare(create, "false", true) == 0)
        result.CreateVirtualDirectory = false;
      else
        result.CreateVirtualDirectory = true;

      return result;
    }

  }

  //[ComVisible(false)]
  //class IIS7ConfigurationManager
  //{
  //  #region Private Members
  //  private ServerManager m_ServerManager = new ServerManager();
  //  private Site m_DefaultWebSite = null;

  //  private const string HTTP_COMPRESSION_ISAPI_DESC = "HTTP Compression";

  //  public const string METRANET_SYSTEM_APP_POOL = "MetraNetSystemAppPool";
  //  private const string CLASSIC_APP_POOL = "MetraNetClassicAppPool";
  //  public const string METRANET_USER_APP_POOL = "MetraNetUserAppPool";

  //  public const string DEFAULT_WEB_SITE_NAME = "Default Web Site";

  //  //private const int FEATURE_EXECUTE = 4;
  //  #endregion

  //  public IIS7ConfigurationManager()
  //  {
  //    this.m_DefaultWebSite = m_ServerManager.Sites[DEFAULT_WEB_SITE_NAME];

  //  }

  //  public bool WebAppExists(string appName)
  //  {
  //    return (m_DefaultWebSite.Applications[string.Format("/{0}", appName)] != null);
  //  }

  //  public void AddWebApp(string appName, string fullPath, string appPool)
  //  {
  //    Application webApp = m_DefaultWebSite.Applications.Add(string.Format("/{0}", appName), fullPath);

  //    webApp.ApplicationPoolName = appPool;

  //    this.CommitChanges();
  //  }

  //  public void RemoveWebApp(string appName)
  //  {
  //    Application app = m_DefaultWebSite.Applications[string.Format("/{0}", appName)];

  //    if (app != null)
  //    {
  //      m_DefaultWebSite.Applications.Remove(app);
  //    }
  //  }

  //  public void CreateAppPool(string poolName, ProcessModelIdentityType identityType, ManagedPipelineMode managedPipelineMode)
  //  {
  //    ApplicationPool appPool = m_ServerManager.ApplicationPools.Add(poolName);

  //    appPool.Enable32BitAppOnWin64 = true;
  //    appPool.Recycling.PeriodicRestart.Memory = 0;
  //    appPool.Recycling.PeriodicRestart.PrivateMemory = 0;
  //    appPool.Recycling.PeriodicRestart.Requests = 0;

  //    appPool.ProcessModel.IdentityType = identityType;

  //    appPool.ManagedPipelineMode = managedPipelineMode;
  //  }

  //  public void CommitChanges()
  //  {
  //    m_ServerManager.CommitChanges();
  //    m_DefaultWebSite = m_ServerManager.Sites[DEFAULT_WEB_SITE_NAME];
  //  }
  //}
}

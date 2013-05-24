using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Win32;

namespace ICEUtils
{
  public class IISEnvironment
  {
    #region Constants
    public const string METRANET_SYSTEM_APP_POOL = "MetraNetSystemAppPool";
    public const string METRANET_USER_APP_POOL = "MetraNetUserAppPool";
    #endregion

    private static IISEnvironment sm_instance;
    public static IISEnvironment Instance
    {
      get
      {
        if (sm_instance == null)
          Init();
        //throw new ApplicationException("Attempt to access EnvironmentConfiguration before init");
        //TODO: Add locking around access;

        return sm_instance;
      }
    }
    public static bool IsInitialized
    {
      get { return sm_instance != null; }
    }
    public static void Init()
    {
      if (sm_instance != null)
        throw new ApplicationException("Attempt to reinit");

      sm_instance = new IISEnvironment();
    }

    private IISEnvironment()
    {
      try
      {
        iisVersion = GetIISVersion();
      }
      catch
      {
        iisVersion = new Version(0, 0);
      }
    }

    protected Version iisVersion = new Version(0,0);
    public Version IISVersion { get { return iisVersion; } }

    public bool IISInstalled
    {
      get
      {
        return (IISVersion != new Version(0, 0));
      }
    }

    public IIISConfigurationManager GetConfigurationManager()
    {

      switch (IISVersion.Major)
      {
        case 0:
          return null;
        case 6:
          return new IIS6ConfigurationManager();
        case 7:
          return new IIS7ConfigurationManager();
        default:
          return null;
      }
    }

    public Version GetIISVersion()
    {
      using (RegistryKey componentsKey =
      Registry.LocalMachine.OpenSubKey(@"Software\Microsoft\InetStp", false))
      {
        if (componentsKey != null)
        {
          int majorVersion = (int)componentsKey.GetValue("MajorVersion", -1);
          int minorVersion = (int)componentsKey.GetValue("MinorVersion", -1);
          if (majorVersion != -1 && minorVersion != -1)
          {
            return new Version(majorVersion, minorVersion);
          }
        }
        return new Version(0, 0);
      }
    }

  }
}

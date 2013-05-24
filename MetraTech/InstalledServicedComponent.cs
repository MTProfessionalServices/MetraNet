using System;
using System.Reflection;
using System.Runtime.InteropServices;
using System.EnterpriseServices;
using System.Configuration.Install;

namespace MetraTech
{
  /// <summary>
  /// MetraTech Installed Component
  /// </summary>
  /// 
  public class InstalledServicedComponent : Installer
  {
    public InstalledServicedComponent()
    {
      
    }

    public void Install()
    {
      System.Reflection.Assembly ass = Assembly.GetAssembly(GetType());
      string assname = ass.FullName;
    }
  
  }
  

}

	
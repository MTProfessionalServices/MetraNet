using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace MetraTech.ActivityServices.Service
{
  [RunInstaller(true)]
  public partial class CMASServiceInstaller : Installer
  {
    public CMASServiceInstaller()
    {
      //
      // process installer
      // 
      ServiceProcessInstaller processInstaller = new ServiceProcessInstaller();

      // runs under the system account
      processInstaller.Account = ServiceAccount.LocalSystem;
      processInstaller.Password = null;
      processInstaller.Username = null;

      ServiceInstaller dbmfInstaller = InstallMASHostService();


      Installer[] installers = { processInstaller, dbmfInstaller};
      Installers.AddRange(installers);
    }

    private ServiceInstaller InstallMASHostService()
    {
      ServiceInstaller installer = new ServiceInstaller();
      installer.ServiceName = "ActivityServices";
      installer.DisplayName = "MetraTech ActivityServices Server";
      installer.StartType = ServiceStartMode.Manual;

      return installer;
    }
  }

  static class MASHostEntryPoint
  {
    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    static void Main()
    {
      ServiceBase[] ServicesToRun;

      // More than one user Service may run within the same process. To add
      // another service to this process, change the following line to
      // create a second service object. For example,
      //
      //   ServicesToRun = new ServiceBase[] {new Service1(), new MySecondUserService()};
      //
      ServicesToRun = new ServiceBase[] { new MASService() };

      ServiceBase.Run(ServicesToRun);
    }
  }
}
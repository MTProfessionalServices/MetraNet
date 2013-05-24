using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Configuration.Install;
using System.ComponentModel;

namespace MetraTech.Messaging.MessagingService
{
  [RunInstaller(true)]
  public partial class MessagingServiceInstaller : Installer
  {
    public MessagingServiceInstaller()
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


      Installer[] installers = { processInstaller, dbmfInstaller };
      Installers.AddRange(installers);
    }

    private ServiceInstaller InstallMASHostService()
    {
      ServiceInstaller installer = new ServiceInstaller();
      installer.ServiceName = "MessagingServer";
      installer.DisplayName = "MetraTech Messaging Server";
      installer.StartType = ServiceStartMode.Manual;

      return installer;
    }
  }


  static class Program
  {
    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    static void Main()
    {
      ServiceBase[] ServicesToRun;
      ServicesToRun = new ServiceBase[] 
			{ 
				new MessagingService() 
			};
      ServiceBase.Run(ServicesToRun);
    }
  }
}

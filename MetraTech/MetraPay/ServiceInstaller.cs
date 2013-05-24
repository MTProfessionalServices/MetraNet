using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace MetraTech.MetraPay
{
    [RunInstaller(true)]
    public partial class CMetraPayServiceInstaller : Installer
    {
        public CMetraPayServiceInstaller()
        {
            //
            // process installer
            // 
            ServiceProcessInstaller processInstaller = new ServiceProcessInstaller();

            // runs under the system account
            processInstaller.Account = ServiceAccount.LocalSystem;
            processInstaller.Password = null;
            processInstaller.Username = null;

            ServiceInstaller metraPayInstaller = InstallMetraPayService();

            Installer[] installers = { processInstaller, metraPayInstaller };
            Installers.AddRange(installers);
        }

        private ServiceInstaller InstallMetraPayService()
        {
            ServiceInstaller installer = new ServiceInstaller();
            installer.ServiceName = "MetraPay";
            installer.DisplayName = "MetraTech MetraPay Server";
            installer.StartType = ServiceStartMode.Manual;

            return installer;

        }
    }
}
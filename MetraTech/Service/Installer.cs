namespace MetraTech.Service
{
	using System;
	using System.Collections;
	using System.Configuration.Install;
	using System.ServiceProcess;
	using System.ComponentModel;

	/// <summary>
	/// Installs MetraTech services
	/// </summary>
	[RunInstaller(true)]
	public class MTServiceInstaller : Installer
	{
		public MTServiceInstaller()
		{
			// 
			// process installer
			// 
			ServiceProcessInstaller processInstaller = new ServiceProcessInstaller();

			// runs under the system account
			processInstaller.Account = ServiceAccount.LocalSystem;
			processInstaller.Password = null;
			processInstaller.Username = null;

			ServiceInstaller billingServerInstaller = InstallBillingServerService();
			
			
			Installer [] installers = {processInstaller, billingServerInstaller};
			Installers.AddRange(installers);
		}

		private ServiceInstaller InstallBillingServerService()
		{
			ServiceInstaller installer = new ServiceInstaller();
			installer.ServiceName = "BillingServer";
			installer.DisplayName = "MetraTech Billing Server";
			installer.StartType = ServiceStartMode.Manual;

			return installer;
		}
	}


	/// <summary>
	/// Starts MetraTech services
	/// </summary>
	public class MTService
	{

		public static void Main()
		{
			ServiceBase[] servicesToRun;
	
			// More than one user Service may run within the same process. To add
			// another service to this process, change the following line to
			// create a second service object. For example,
			//
			//   ServicesToRun = New System.ServiceProcess.ServiceBase[] {new Service1(), new MySecondUserService()};
			//
			servicesToRun = new ServiceBase[] { new MetraTech.UsageServer.Service.Service() };

			ServiceBase.Run(servicesToRun);
		}
	}
}

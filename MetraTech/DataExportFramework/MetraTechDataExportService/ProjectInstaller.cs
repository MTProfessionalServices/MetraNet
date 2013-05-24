using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;

namespace MetraTech.DataExportService
{
	/// <summary>
	/// Summary description for ProjectInstaller.
	/// </summary>
	[RunInstaller(true)]
	public class ProjectInstaller : System.Configuration.Install.Installer
	{
        private System.ServiceProcess.ServiceProcessInstaller MetraTechDataExportServiceProcessInstaller;
        private System.ServiceProcess.ServiceInstaller MetraTechDataExportServiceInstaller;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public ProjectInstaller()
		{
			// This call is required by the Designer.
			InitializeComponent();

			// TODO: Add any initialization after the InitializeComponent call
		}

		/// <summary> 
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if(components != null)
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}


		#region Component Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
      this.MetraTechDataExportServiceProcessInstaller = new System.ServiceProcess.ServiceProcessInstaller();
      this.MetraTechDataExportServiceInstaller = new System.ServiceProcess.ServiceInstaller();
      // 
      // MetraTechDataExportServiceProcessInstaller
      // 
      this.MetraTechDataExportServiceProcessInstaller.Account = System.ServiceProcess.ServiceAccount.LocalSystem;
      this.MetraTechDataExportServiceProcessInstaller.Password = null;
      this.MetraTechDataExportServiceProcessInstaller.Username = null;
      this.MetraTechDataExportServiceProcessInstaller.AfterInstall += new System.Configuration.Install.InstallEventHandler(this.MetraTechDataExportServiceProcessInstaller_AfterInstall);
      // 
      // MetraTechDataExportServiceInstaller
      // 
      this.MetraTechDataExportServiceInstaller.DisplayName = "MetraTech Data Export Service";
      this.MetraTechDataExportServiceInstaller.ServiceName = "MetraTechDataExportService";
      this.MetraTechDataExportServiceInstaller.AfterInstall += new System.Configuration.Install.InstallEventHandler(this.MetraTechDataExportServiceInstaller_AfterInstall);
      // 
      // ProjectInstaller
      // 
      this.Installers.AddRange(new System.Configuration.Install.Installer[] {
            this.MetraTechDataExportServiceProcessInstaller,
            this.MetraTechDataExportServiceInstaller});

		}
		#endregion

    private void MetraTechDataExportServiceInstaller_AfterInstall(object sender, InstallEventArgs e)
    {

    }

    private void MetraTechDataExportServiceProcessInstaller_AfterInstall(object sender, InstallEventArgs e)
    {

    }
	}
}

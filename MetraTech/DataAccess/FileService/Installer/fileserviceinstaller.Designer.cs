namespace MetraTech.FileService
{
  partial class cFileLandingServiceInstaller
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary> 
    /// Clean up any resources being used.
    /// </summary>
    /// <param value="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null))
      {
        components.Dispose();
      }
      base.Dispose(disposing);
    }

    #region Component Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.srvProcInstaller = new System.ServiceProcess.ServiceProcessInstaller();
      this.svcInstaller = new System.ServiceProcess.ServiceInstaller();
      // 
      // srvProcInstaller
      // 
      this.srvProcInstaller.Account = System.ServiceProcess.ServiceAccount.LocalSystem;
      this.srvProcInstaller.Password = null;
      this.srvProcInstaller.Username = null;
      // 
      // svcInstaller
      // 
      this.svcInstaller.ServiceName = "MetraTech.FileService";
      this.svcInstaller.AfterInstall += new System.Configuration.Install.InstallEventHandler(this.svcInstaller_AfterInstall);
      // 
      // cFileLandingServiceInstaller
      // 
      this.Installers.AddRange(new System.Configuration.Install.Installer[] {
            this.srvProcInstaller,
            this.svcInstaller});

    }

    #endregion

    private System.ServiceProcess.ServiceProcessInstaller srvProcInstaller;
    private System.ServiceProcess.ServiceInstaller svcInstaller;


  }
}
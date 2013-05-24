using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.Reflection;
using System.EnterpriseServices;
using System.Runtime.InteropServices;

namespace MetraTech.Test.MTInstaller
{
	/// <summary>
	/// Summary description for MTInstaller.
	/// </summary>
	/// 
  [RunInstaller(true)]
	[ComVisible(false)]
	public class MTInstaller : Installer
	{
		public MTInstaller()
		{
			//
			// TODO: Add constructor logic here
			//
		}
    // Override the 'Install' method.
    public override void Install(IDictionary savedState)
    {
      System.Reflection.Assembly asmbly = Assembly.GetAssembly(GetType());
      savedState = new Hashtable();
      string app =  "MetraNet";
      string tlb = @"c:\MetraTech\Shared\MetraTech.Test.MTInstaller.tlb";
      //string tlb = @"o:\debug\include\MetraTech.Test.MTInstaller.tlb";
      try
      {
        System.Console.WriteLine(asmbly.FullName);
        System.Console.WriteLine(asmbly.Location);
        System.Console.WriteLine(asmbly.GlobalAssemblyCache);

        RegistrationHelper helper = new RegistrationHelper();
        InstallationFlags flags = 
          InstallationFlags.ExpectExistingTypeLib 
          | InstallationFlags.FindOrCreateTargetApplication
          | InstallationFlags.ReportWarningsToConsole;
        helper.InstallAssembly(asmbly.FullName,  ref app, ref tlb, flags);
        savedState.Add("AppID", app);
        savedState.Add("TypeLib", tlb);
        savedState.Add("assembly", asmbly.Location);
       base.Install(savedState);
      }
      catch(Exception ex)
      {
        System.Console.Out.WriteLine(ex.Message);
        System.Console.Out.WriteLine(ex.StackTrace);
        throw ex;
      }
     
    }
    // Override the 'Commit' method.
    public override void Commit(IDictionary savedState)
    {
      //base.Commit(savedState);
    }
    // Override the 'Rollback' method.
    public override void Rollback(IDictionary savedState)
    {
      //base.Rollback(savedState);
    }

	}
}

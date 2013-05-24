using System;
using System.Collections;
using System.ComponentModel;
using System.Web;
using System.Web.SessionState;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.RCD;
using MetraTech.SecurityFramework;
using System.IO;

namespace MetraTech.UI.Suggest 
{
	/// <summary>
	/// Summary description for Global.
	/// </summary>
	public class Global : System.Web.HttpApplication
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		public Global()
		{
			InitializeComponent();
		}	
		
		protected void Application_Start(Object sender, EventArgs e)
		{
      // Setup security framework
      Application["Security"] = new MTSecurityClass();

      using (var rcd1 = new MTComSmartPtr<IMTRcd>())
      {
        rcd1.Item = new MTRcdClass();
        rcd1.Item.Init();

        //SECENG: Change SecurityFramework version
        var path = Path.Combine(rcd1.Item.ConfigDir, @"Security\Validation\MtSfConfigurationLoader.xml");
        //var path = Path.Combine(rcd1.Item.ConfigDir, @"Security\Validation\MtSecurityFramework.properties");
        var logger = new Logger("[MetraNetApplication]");
        logger.LogDebug("Security framework path: {0}", path);
        SecurityKernel.Initialize(path);
        SecurityKernel.Start();
      }
		}
 
		protected void Session_Start(Object sender, EventArgs e)
		{

		}

		protected void Application_BeginRequest(Object sender, EventArgs e)
		{

		}

		protected void Application_EndRequest(Object sender, EventArgs e)
		{

		}

		protected void Application_AuthenticateRequest(Object sender, EventArgs e)
		{

		}

		protected void Application_Error(Object sender, EventArgs e)
		{

		}

		protected void Session_End(Object sender, EventArgs e)
		{

		}

		protected void Application_End(Object sender, EventArgs e)
		{

		}
			
		#region Web Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.components = new System.ComponentModel.Container();
		}
		#endregion
	}
}


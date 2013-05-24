using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using MetraTech.Interop.RCD;
using MetraTech.Pipeline.Batch;
using System.Runtime.InteropServices;
using MetraTech.SecurityFramework;


namespace MetraTech.Pipeline.Batch.Listener
{
	/// <summary>
	/// Summary description for Service1.
	/// </summary>

	[WebService(Namespace="http://metratech.com/webservices")]
	public class Listener : System.Web.Services.WebService
	{
		public Listener()
		{
			//CODEGEN: This call is required by the ASP.NET Web Services Designer
			InitializeComponent();

            using (var rcd1 = new MTComSmartPtr<IMTRcd>())
            {
                rcd1.Item = new MTRcdClass();
                rcd1.Item.Init();

                //SECENG: Change SecurityFramework version
                var path = System.IO.Path.Combine(rcd1.Item.ConfigDir, @"Security\Validation\MtSfConfigurationLoader.xml");
                var logger = new Logger("[BatchListener]");
                logger.LogDebug("Security framework path: {0}", path);
                SecurityKernel.Initialize(path);
                SecurityKernel.Start();
            }
        
        }

		#region Component Designer generated code
		
		//Required by the Web Services Designer 
		private IContainer components = null;
				
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if(disposing && components != null)
			{
				components.Dispose();
			}
			base.Dispose(disposing);		
		}
		
		#endregion

		private static string SafeString(string input)
		{
			if (input == null)
				return "";
			else
				return input;
		}

		[WebMethod]
		public string Create(BatchObject batchobject)
		{
			batchobject.Save();
			return batchobject.UID;
		}

		[WebMethod]
		public BatchObject LoadByName(string Name, string Namespace, string SequenceNumber)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.LoadByName(Name, Namespace, SequenceNumber);
			return batchobject;
		}

		[WebMethod]
		public BatchObject LoadByUID(string UID)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.LoadByUID(UID);
			return batchobject;
		}

		[WebMethod]
		public void MarkAsActive(string UID, string Comment)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.MarkAsActive(UID, Comment);
		}

		[WebMethod]
		public void MarkAsBackout(string UID, string Comment)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.MarkAsBackout(UID, Comment);
		}

		[WebMethod]
		public void MarkAsFailed(string UID, string Comment)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.MarkAsFailed(UID, Comment);
		}

		[WebMethod]
		public void MarkAsDismissed(string UID, string Comment)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.MarkAsDismissed(UID, Comment);
		}

		[WebMethod]
		public void MarkAsCompleted(string UID, string Comment)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.MarkAsCompleted(UID, Comment);
		}

		[WebMethod]
		public void UpdateMeteredCount(string UID, int MeteredCount)
		{
			BatchObject batchobject = new BatchObject();
			batchobject.UpdateMeteredCount(UID, MeteredCount);
		}
	}
}

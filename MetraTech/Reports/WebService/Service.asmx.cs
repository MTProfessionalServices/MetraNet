using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.IO;

using System.Runtime.InteropServices;

namespace MetraTech.Reports
{
	/// <summary>
	/// Summary description for Service1.
	/// </summary>
	
	[WebService(Namespace="http://www.metratech.com/webservices/")]
	[ WebServiceBinding(Name="LocalBinding", 
			Namespace="http://www.metratech.com/webservices/" )]

	[ComVisible(false)]
	public class Service : System.Web.Services.WebService
	{
		public Service()
		{
			//CODEGEN: This call is required by the ASP.NET Web Services Designer
			InitializeComponent();
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

		// WEB SERVICE EXAMPLE
		// The HelloWorld() example service returns the string Hello World
		// To build, uncomment the following lines then save and build the project
		// To test this web service, press F5

		[WebMethod]
		[SoapDocumentMethod(Binding="LocalBinding")]
		public void DeleteFile(string aFileName)
		{
            // SECENG: Fixing File Canonicalization issue
            if (VerifyFilePath(aFileName))
		    {
		        System.IO.File.Delete(aFileName);
		    }
            else
            {
                throw new IOException(string.Format("Unable to delete file \"{0}\". Path must be absolute.", aFileName));
            }
		}

		[WebMethod]
		[SoapDocumentMethod(Binding="LocalBinding")]
		public void DeleteFiles(ArrayList aFileNames)
		{
			foreach(string file in aFileNames)
			{
                // SECENG: Fixing File Canonicalization issue
				if(System.IO.File.Exists(file) && VerifyFilePath(file))
				{
					if((File.GetAttributes(file) & FileAttributes.Directory) 
						== FileAttributes.Directory)
					{
						if(System.IO.Directory.Exists(file))
							System.IO.Directory.Delete(file, true);
					}
					else
					{
						System.IO.File.Delete(file);
						//TODO: delete current directory if empty
					}
				}
				
			}
		}

        /// <summary>
        /// SECENG: Fixing File Canonicalization issue
        /// </summary>
        /// <param name="fileName">A file name to be checked.</param>
        /// <returns>true if the file path is absolute and doesn't contain invalid characters. Returns false otherwise.</returns>
        private bool VerifyFilePath(string fileName)
        {
            bool result;
            if (!string.IsNullOrEmpty(fileName))
            {
                result = fileName.IndexOfAny(Path.GetInvalidPathChars()) < 0 &&
                         string.Compare(Path.GetFullPath(fileName), fileName, StringComparison.InvariantCultureIgnoreCase) == 0;
            }
            else
            {
                result = false;
            }

            return result;
        }
	}
}

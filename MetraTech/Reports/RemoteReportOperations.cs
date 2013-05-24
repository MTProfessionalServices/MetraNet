using System;
using System.Web;
using Microsoft.Win32;
using System.Net;
using System.IO;
using System.Text;
using System.Xml;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.UsageServer;




namespace MetraTech.Reports
{
	/// <summary>
	/// Summary description for RemoteReportOperations.
	/// </summary>
	
	[ComVisible(false)]
	public class RemoteReportOperations
	{
		private static Logger mLogger = new Logger ("[Reports]");
		private static string mServer = ReportConfiguration.GetInstance().APSName;
		private static string mVDir = ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory;
		private static string mUser = ReportConfiguration.GetInstance().APSUser;
		private static string mPassword = ReportConfiguration.GetInstance().APSPassword;
		private static string mSecure = ReportConfiguration.GetInstance().APSSecure == 0 ? "http" : "https";
		
		public static bool DeleteUnmanagedDiskFiles(ArrayList aFiles, IRecurringEventRunContext aCtx)
		{
			//first discover if the web service already existed
			bool bServiceExisted = true;
			ReportProxy prx = null;
			try
			{
				prx = new ReportProxy(GetASMXPath());
				prx.Credentials = CreateCredentials();
				prx.Discover();
			}
			catch(Exception)
			{
				//we can only really assume that
				//exception is thrown because the service did not exist.
				//Discover() method throws a generic System.Exception
				string msg = "MetraNet reporting web service does not exist or misconfigured, attempting to deploy web service.";
				Console.Out.WriteLine(msg);
				mLogger.LogDebug(msg);
				if (aCtx != null )aCtx.RecordInfo(msg);
				bServiceExisted = false;
			}
			if(bServiceExisted == false)
			{
				DeployWebServiceWithUploadDataAndPutVerb(aCtx);
			}

			prx.DeleteFiles(aFiles);
			return true;

		}

		private static string mURI = string.Empty;
		private static string GetURI()
		{
			if(mURI.Length == 0)
				mURI =  string.Format("{0}://{1}/{2}/", mSecure, mServer, mVDir);
			return mURI;
		}
		private static string mBinURI = string.Empty;
		private static string GetBinURI()
		{
			if(mBinURI.Length == 0)
				mBinURI =  string.Format("{0}bin", GetURI());
			return mBinURI;
		}
		private static string GetASMXPath()
		{
			return string.Format("{0}{1}", GetURI(), GetASMXFileName());
		}
		private static string GetAssemblyPath()
		{
			return string.Format("{0}bin/{1}", GetURI(), GetAssemblyFileName());
		}
		private static string GetASMXFileName()
		{
			return "service.asmx";
		}
		private static string GetAssemblyFileName()
		{
			return "MetraTech.Reports.WebService.dll";
		}

		private static CredentialCache CreateCredentials()
		{
			System.Net.CredentialCache ccache = new CredentialCache();
			System.Net.NetworkCredential cred = new System.Net.NetworkCredential(mUser, mPassword); 
			string uri = GetURI();
			string binuri = GetBinURI();
			ccache.Add(new Uri(uri), "Basic", cred);
			ccache.Add(new Uri(binuri), "Basic", cred);
			return ccache;
		}
		
		private static void DeployWebServiceWithUploadDataAndPutVerb(IRecurringEventRunContext aCtx)
		{
			try
			{
				WebClient wc = new WebClient();
				wc.Credentials = CreateCredentials();
				UploadAssembly(ref wc);
				UploadASMXFile(ref wc);
			}
			catch(Exception e)
			{
				string msg = string.Format
					(	@"Failed to Deploy Remote report operations web service with following error: '{0}'. "+
						"One of the possible reasons is incorrectly configured security settings on MetraNet reporting virtual directories. "+
						"Please follow APS server installation document to either fix these issues, or deploy the web service manually. After that adapter can be reversed again. ",
						e.Message);
				RemoteReportOperations.mLogger.LogError
					(msg);
				if (aCtx != null )aCtx.RecordWarning(msg);
				throw new ReportingException(msg);
			}
			return;
		}

		private static bool UploadASMXFile(ref WebClient wc)
		{
			//'Translate: F' header will turn off default handler for ASMX
			//extension and upload asmx file as a regular text
			wc.Headers.Add("Translate: f");
			Uri RequestUri = new Uri(GetASMXPath());	
			Console.Out.WriteLine(RequestUri.AbsoluteUri);
			FileStream MyFileStream = File.OpenRead(GetASMXFileFullPath());
			int FileLength = (int)MyFileStream.Length;
			Byte[] FileData = new Byte[FileLength];
			MyFileStream.Read(FileData, 0, FileLength);
			MyFileStream.Close();
			byte[] myDataBuffer = wc.UploadData(RequestUri.AbsoluteUri,"PUT", FileData);
			string Buffer = Encoding.Default.GetString(myDataBuffer);
			return true;
		}

		private static bool UploadAssembly(ref WebClient wc)
		{
			wc.Headers.Add("Translate: f");
			string uri = GetAssemblyPath();
			Uri RequestUri = new Uri(uri);
			System.Console.Out.WriteLine(uri);
			FileStream MyFileStream = File.OpenRead(GetAssemblyLocalFullPath());
			int FileLength = (int)MyFileStream.Length;
			Byte[] FileData = new Byte[FileLength];
			MyFileStream.Read(FileData, 0, FileLength);
			MyFileStream.Close();
			byte[] myDataBuffer = wc.UploadData(RequestUri.AbsoluteUri,"PUT", FileData);
			string Buffer = Encoding.Default.GetString(myDataBuffer);
			return true;
		}


		
		private static string GetASMXFileFullPath()
		{
			string installDir = string.Empty;
			string relativeName = ReportConfiguration.GetInstance().WebServiceASMXRelativePath;
			if(relativeName.StartsWith(@"\") == false)
				relativeName = relativeName.Insert(0, @"\");
			string extensionDir = ReportConfiguration.GetInstance().GetRCDObject().ExtensionDir;
			return string.Format("{0}{1}", extensionDir, relativeName);
		}
		private static string GetAssemblyLocalFullPath()
		{
			string installDir = string.Empty;
			string relativeName = ReportConfiguration.GetInstance().WebServiceDllRelativePath;
			string extensionDir = ReportConfiguration.GetInstance().GetRCDObject().ExtensionDir;
			if(relativeName.StartsWith(@"\") == false)
				relativeName = relativeName.Insert(0, @"\");
			return string.Format("{0}{1}", extensionDir, relativeName);
		}
		
	}
}



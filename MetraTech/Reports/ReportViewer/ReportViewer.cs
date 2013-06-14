using System;
using System.Web;
using System.Collections;
using System.Net;
using System.IO;
using System.Text;
using System.Xml;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Collections.Specialized;

using MetraTech;
using RS =  MetraTech.Interop.Rowset;

[assembly: GuidAttribute ("7F2F7DB0-745C-4149-83A9-EB2EA978980F")]
namespace MetraTech.Reports
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	/// 

	[Guid("A64E0A2D-7334-4211-827B-438DD8E14766")] 
	public interface IReportViewer 
	{ 
		MetraTech.Interop.Rowset.MTInMemRowsetClass GetFileList(string subFolderPath, int accountID);
        MetraTech.Interop.Rowset.MTInMemRowsetClass GetQuoteFileList(int accountID);
		
		byte[] GetReportFile(string fileName);
        byte[] GetQuoteReportFile(string fileName);
	}

	[GuidAttribute ("D65A59F0-7BFA-4078-A52D-FA7A4A4F4981")]
	[ClassInterface(ClassInterfaceType.None)]
	public class ReportViewer : IReportViewer
	{
		private Logger mLogger = new Logger ("[ReportViewer]");
		private MetraTech.Interop.Rowset.MTInMemRowsetClass rs;
		private string mAPSServerName;
		private string mReportsVirDir;
		private string mIntervalID;
        private string mQuotesSubFolder;
		private string mAccountID;
		private string mAPSUsername;
		private string mAPSPassword;
		private int mAPSSecure;
		private int mAPSPort;
        // g. cieplik 1/23/2009 CORE-635 set the buffer size for reading, read the PDF in chunks of 64 bytes
        public const int mBufferSize = 65536; 

		public ReportViewer()
		{
			rs = new MetraTech.Interop.Rowset.MTInMemRowsetClass();
			rs.Init();
			rs.AddColumnDefinition("FileName", "string");
			rs.AddColumnDefinition("DisplayName", "string");

			mAPSServerName = ReportConfiguration.GetInstance().APSName;
			mReportsVirDir = ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory;
			mAPSUsername = ReportConfiguration.GetInstance().APSUser;
			mAPSPassword = ReportConfiguration.GetInstance().APSPassword;
			mAPSSecure = ReportConfiguration.GetInstance().APSSecure;
			mAPSPort = ReportConfiguration.GetInstance().APSPort;

            mQuotesSubFolder = ReportConfiguration.GetInstance().QuotesSubFolder;
		}

        public ReportViewer(int accountId, int intervalId)
        {
            mIntervalID = intervalId.ToString();
            mAccountID = accountId.ToString();

            rs = new MetraTech.Interop.Rowset.MTInMemRowsetClass();
            rs.Init();
            rs.AddColumnDefinition("FileName", "string");
            rs.AddColumnDefinition("DisplayName", "string");

            mAPSServerName = ReportConfiguration.GetInstance().APSName;
            mReportsVirDir = ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory;
            mAPSUsername = ReportConfiguration.GetInstance().APSUser;
            mAPSPassword = ReportConfiguration.GetInstance().APSPassword;
            mAPSSecure = ReportConfiguration.GetInstance().APSSecure;
            mAPSPort = ReportConfiguration.GetInstance().APSPort;

            mQuotesSubFolder = ReportConfiguration.GetInstance().QuotesSubFolder; ;
        }
        public ReportViewer(int accountId, string QuotesSubFolder)
        {
            mQuotesSubFolder = QuotesSubFolder;
            mAccountID = accountId.ToString();

            rs = new MetraTech.Interop.Rowset.MTInMemRowsetClass();
            rs.Init();
            rs.AddColumnDefinition("FileName", "string");
            rs.AddColumnDefinition("DisplayName", "string");

            mAPSServerName = ReportConfiguration.GetInstance().APSName;
            mReportsVirDir = ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory;
            mAPSUsername = ReportConfiguration.GetInstance().APSUser;
            mAPSPassword = ReportConfiguration.GetInstance().APSPassword;
            mAPSSecure = ReportConfiguration.GetInstance().APSSecure;
            mAPSPort = ReportConfiguration.GetInstance().APSPort;
        }

        public MetraTech.Interop.Rowset.MTInMemRowsetClass GetQuoteFileList(int accountID)
	    {
            mQuotesSubFolder = ReportConfiguration.GetInstance().QuotesSubFolder;
            mAccountID = accountID.ToString();

            return GetFileListInternal(GetURLForReportingServer(mQuotesSubFolder, accountID.ToString()));
	    }

	    public MetraTech.Interop.Rowset.MTInMemRowsetClass GetFileList(string subFolderPath, int accountID)
	    {
	        //validate IntervalID
	        int nIntervalID;

	        if (!int.TryParse(subFolderPath, out nIntervalID))
	        {
	            mLogger.LogError("Invalid Interval ID: " + subFolderPath);
	            return rs;
	        }

	        mIntervalID = subFolderPath;
	        mAccountID = accountID.ToString();

	        return GetFileListInternal(GetURLForReportingServer(subFolderPath, accountID.ToString()));
	    }

	    private MetraTech.Interop.Rowset.MTInMemRowsetClass GetFileListInternal(string url)
		{

            UriBuilder buildUri = new UriBuilder(url.ToString());
            buildUri.Port = mAPSPort;

            Uri myUri = buildUri.Uri;
			try 
			{
				System.Net.CredentialCache myCache = new CredentialCache();
				System.Net.NetworkCredential myCredential = new System.Net.NetworkCredential(mAPSUsername, mAPSPassword); 
				
				myCache.Add( myUri, "Basic", myCredential);

				WebRequest req = WebRequest.Create(myUri);
				//req.PreAuthenticate=true; (do I need this?)
				 req.Credentials = myCache;

				WebResponse resp = req.GetResponse();

				Stream recStream = resp.GetResponseStream();
				StreamReader readStream = new StreamReader (recStream, Encoding.UTF8);
				string p = readStream.ReadToEnd();
				
				//mLogger.LogInfo(p);

				readStream.Close();
				resp.Close();


				Regex theRegex = new Regex(@"<A HREF=.*?>(.*?)</A>");
				MatchCollection theMatches = theRegex.Matches(p);
				string tmpString;
				string strDisplayName;
				//the first match will be "[to parent directory]".. not a valid file name, so ignore it
				bool firstMatch = true;

				foreach (Match theMatch in theMatches)
				{
					if(!firstMatch)
					{
						tmpString = theMatch.Groups[1].ToString();
						mLogger.LogInfo(tmpString);
						rs.AddRow();
						rs.AddColumnData("FileName", tmpString);
						strDisplayName = ReportConfiguration.GetInstance().GetDisplayName(tmpString);
						if (strDisplayName == string.Empty)
							rs.AddColumnData("DisplayName", tmpString);
						else
							rs.AddColumnData("DisplayName", strDisplayName);
					}
					else
						firstMatch = false;
				}
			}
			catch (System.Net.WebException e)
			{
				if(e.Status == WebExceptionStatus.ProtocolError) 
				{
					if ( ((HttpWebResponse)e.Response).StatusCode == HttpStatusCode.NotFound)
						mLogger.LogInfo("Resource not found on the server, HTTP status 404");
					else if ( ((HttpWebResponse)e.Response).StatusCode == HttpStatusCode.Unauthorized)
						mLogger.LogError("Not authorized to access the resource, HTTP status 401");
					else
					{
						mLogger.LogError("Status Code : {0}", ((HttpWebResponse)e.Response).StatusCode);
						mLogger.LogError("Status Description : {0}", ((HttpWebResponse)e.Response).StatusDescription);

					}
				}

				else
					throw e;
			}
			return rs;
		}

	    private string GetURLForReportingServer(string subFolderPath, string accountID, string fileName = "")
	    {
            //get the aps servername, location of virtual directory to build the url
	        StringBuilder url = new StringBuilder();
	        if (mAPSSecure == 0)
	            url.Append(@"http://");
	        else
	        {
	            url.Append(@"https://");
	            mLogger.LogInfo("Using SSL, https to connect to the APS Server");
	        }
	        url.Append(mAPSServerName);
	        url.Append(@"/");
	        url.Append(mReportsVirDir);
	        url.Append(@"/");

	        if (subFolderPath.IndexOf("{AccountId}") > 0)
	        {
	            subFolderPath = subFolderPath.Replace(@"\", @"/").Replace("{AccountId}", accountID);
	            url.Append(subFolderPath);
	            url.Append(@"/");
	        }
	        else
	        {
	            url.Append(subFolderPath);
	            url.Append(@"\");
	            url.Append(accountID);
	            url.Append(@"\");
	        }

	        if (!String.IsNullOrEmpty(fileName))
            {
                url.Append(fileName);
            }

	        mLogger.LogDebug(string.Format("Using url: {0}", url));
	       
	        return url.ToString();
	    }

	    public byte[] GetReportFile(string fileName)
	    {
            return GetReportFileInteranal(GetURLForReportingServer(mIntervalID, mAccountID, fileName));
	    }

        public byte[] GetQuoteReportFile(string fileName)
        {
            return GetReportFileInteranal(GetURLForReportingServer(mQuotesSubFolder, mAccountID, fileName));
        }

	    private byte[] GetReportFileInteranal(string fileNameURL)
		{
			
			mLogger.LogDebug(string.Format("Using url: {0}", fileNameURL));
            UriBuilder buildUri = new UriBuilder(fileNameURL);
			buildUri.Port = mAPSPort;
			
			Uri myUri = buildUri.Uri;			

			try
			{
				System.Net.CredentialCache myCache = new CredentialCache();
				System.Net.NetworkCredential myCredential = new System.Net.NetworkCredential(mAPSUsername, mAPSPassword); 

				//myCache.Add(new Uri(url.ToString()), "Basic", myCredential);
				myCache.Add(myUri, "Basic", myCredential);
				System.Net.WebRequest webrequest = System.Net.WebRequest.Create(myUri);

				webrequest.Credentials = myCache;
				System.Net.WebResponse response = webrequest.GetResponse();

				System.IO.Stream stream = response.GetResponseStream();
				byte[] mybuffer = new byte[response.ContentLength];
				int numBytesToRead = (int) response.ContentLength;
				int numBytesRead = 0;
                // g. cieplik 1/23/2009 CORE-635
                int numBytesChunk = 0;
				
                mLogger.LogInfo("About to Read Streams");
				while (numBytesToRead > 0)
				{
                    // g. cieplik 1/23/2009 CORE-635, read the PDF in chunks of 64 bytes
                    mLogger.LogInfo("BytesToRead: {0}, BytesRead: {1}", numBytesToRead, numBytesRead);
                    if (numBytesToRead < mBufferSize)
                        numBytesChunk = numBytesToRead;
                    else
                        numBytesChunk = mBufferSize;
                        int n = stream.Read(mybuffer, numBytesRead, numBytesChunk);
                    mLogger.LogInfo("Read Bytes: {0}", n);
				    if (n == 0)
					    break;
				    numBytesRead += n;
				    numBytesToRead -= n;
				}
				stream.Close();
				response.Close();
				return mybuffer;		
			}
			catch (System.Net.WebException e)
			{
				if(e.Status == WebExceptionStatus.ProtocolError) 
				{
					byte[] mybuffer = new byte[1];
					mybuffer[0] = 1;
					if ( ((HttpWebResponse)e.Response).StatusCode == HttpStatusCode.NotFound)
						mLogger.LogInfo("Resource not found on the server, HTTP status 404");
					else if ( ((HttpWebResponse)e.Response).StatusCode == HttpStatusCode.Unauthorized)
						mLogger.LogError("Not authorized to access the resource, HTTP status 401");
					else
					{
						mLogger.LogError("Status Code : {0}", ((HttpWebResponse)e.Response).StatusCode);
						mLogger.LogError("Status Description : {0}", ((HttpWebResponse)e.Response).StatusDescription);
					}
					return mybuffer;
				}

				else
					throw e;
			}

		}
	}


	
}

using System;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using System.Xml;
using MetraTech.UsageServer;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.RCD;

 [assembly: GuidAttribute ("104bc2ff-03b5-43f9-83b4-bee99b13f52f")]

namespace MetraTech.Reports
{
  /// <summary>
  /// Access to Reporting configuration,
  /// cached as singleton
  /// </summary>
	[ComVisible(false)]
	public class ReportConfiguration
	{
		//data
		private static ReportConfiguration smInstance = null;

		private string mDatabasePrefix;
		private bool mGenerateDBEveryTime;
		private int mReportFailureThreshold;
		private ArrayList mAllScheduledReports;
		private ArrayList mAllEOPReports;
		private Hashtable mEOPReportsByGroup;
		private Hashtable mScheduledReportsByGroup;
		private IReportManager mReportProvider;
		private string mReportInstanceBasePhysicalPath;
		private string mReportInstanceVirtualDirectory;
		private string mWebServiceDllRelativePath;
		private string mWebServiceASMXRelativePath;
		private bool mbPauseReportsBeforeDelete;
		private int miTriggerReportGenerationEventPause;

		private string mAPSName;
		private string mAPSUser;
		private string mAPSPassword;
		private int mAPSSecure;
		private int mAPSPort;
        // g. cieplik 8/25/2009 CORE-1472 use mMPSDatabaseName to overload with SI_NAME
        private string mAPSDatabaseName;
		private IMTRcd mRcd;
		private string mProgID = string.Empty;
		private Logger logger = null;

        private string mQuotesSubFolder;

		// public functions
		public static ReportConfiguration GetInstance()
		{
			if (smInstance == null)
			{
				// use double-check locking to avoid lock
				lock (typeof(ReportConfiguration))
				{
					if( smInstance == null)
					{
						smInstance = new ReportConfiguration();
					}
				}
			}
			return smInstance;
		}

		public string DatabasePrefix										{ get { return mDatabasePrefix; }}
		public bool GenerateDBEveryTime									{ get { return mGenerateDBEveryTime; }}
		public int ReportFailureThreshold								{ get { return mReportFailureThreshold; }}
		public IEnumerable AllScheduledReports					{ get { return mAllScheduledReports; }}
		public IEnumerable AllEOPReports								{ get { return mAllEOPReports; }}
		public string ReportInstanceBasePath						{ get { return mReportInstanceBasePhysicalPath; }}
		public string ReportInstanceVirtualDirectory		{ get { return mReportInstanceVirtualDirectory; }}
		public string WebServiceDllRelativePath					{ get { return mWebServiceDllRelativePath; }} 
		public string WebServiceASMXRelativePath					{ get { return mWebServiceASMXRelativePath; }} 
		public bool PauseReportsBeforeDelete					{ get { return mbPauseReportsBeforeDelete; }} 
		public int TriggerReportGenerationEventPause					{ get { return miTriggerReportGenerationEventPause; }} 

		public string APSName			{ get { return mAPSName; }}
		public string APSUser			{ get { return mAPSUser; }}
		public string APSPassword		{ get { return mAPSPassword; }}
		public int APSSecure			{ get { return mAPSSecure; }}
		public int APSPort				{ get { return mAPSPort; }}
        // g. cieplik 8/25/2009 CORE-1472 use mMPSDatabaseName to overload with SI_NAME
        public string APSDatabaseName   { get { return mAPSDatabaseName; }}
        public string QuotesSubFolder { get { return mQuotesSubFolder; } }
		
		public IEnumerable GetScheduledReportsForGroup(string aGroupName)
		{ 
			//TODO: make not case sensitive
			if(mScheduledReportsByGroup.ContainsKey(aGroupName) == false)
			{
				throw new ReportingException
					(string.Format("Report group '{0}' was not found", aGroupName));
			}

			else
				return (IEnumerable)mScheduledReportsByGroup[aGroupName];
			
		}
		public IEnumerable GetEOPReportsForGroup(string aGroupName)
		{ 
			//TODO: make not case sensitive
			if(mEOPReportsByGroup.ContainsKey(aGroupName) == false)
				throw new ReportingException
					(string.Format("Report group '{0}' was not found", aGroupName));
			else
				return (IEnumerable)mEOPReportsByGroup[aGroupName];
			
		}
		
		

		public string GetDisplayName(string aFileName)
		{
			string sourceFile;
			string pdfFile;
			string DisplayName = string.Empty;
			int pos = 0;
			//strip the .pdf from the input file name and also the path, if there 
			pdfFile = aFileName.Replace(".pdf", "");
			pdfFile = pdfFile.ToUpper();
			foreach(IReportDefinition rd in mAllEOPReports)
			{
				//strip the .rpt from the sourcefile name and also the path
				sourceFile = rd.SourceFile;
				sourceFile = sourceFile.ToUpper();
				sourceFile = sourceFile.Replace(".RPT", "");
				pos = sourceFile.LastIndexOf('\\');
				if (pos != -1)
					sourceFile = sourceFile.Substring(pos+1);
				if(string.Compare(pdfFile, sourceFile) == 0)
				{
					DisplayName = rd.DisplayName;
				}
			}
			
			return DisplayName;
		}

		public string GenerateBillingGroupDatabaseName(int aBillgroupID)
		{
			return string.Format("{0}_B{1}", mDatabasePrefix, aBillgroupID.ToString());
		}
		public string GenerateDatabaseName(IRecurringEventRunContext aContext)
		{
			string postfix = string.Empty;
			if(mGenerateDBEveryTime == false)
			{
				return mDatabasePrefix;
			}
			else
			{
				switch(aContext.EventType)
				{
					case RecurringEventType.EndOfPeriod:
					{
						// If BillGroup ID is not provided then use Interval ID,
						// otherwise use billing group id.
						if (aContext.BillingGroupID == -1)
							postfix = string.Format("I{0}",aContext.UsageIntervalID.ToString());
						else
							postfix = string.Format("B{0}",aContext.BillingGroupID.ToString());
						break;
					}
					case RecurringEventType.Scheduled:
					{
						postfix  = aContext.EndDate.ToString();
						postfix = postfix.Replace("/", "_");
						postfix = postfix.Replace(" ", "");
						postfix = postfix.Replace(":", "");
						break;
					}
					default: 
					{
						System.Diagnostics.Debug.Assert(false);
						throw new ReportingException
							(string.Format("Unsupported Event Type: '{0}'", aContext.EventType.ToString()));
					}
				}

				return string.Format("{0}_{1}", mDatabasePrefix, postfix);
			}	
		}

		public IEnumerable GetReportDefinitionList(IRecurringEventRunContext aContext)
		{
			switch(aContext.EventType)
			{
				case RecurringEventType.EndOfPeriod:
				{
					return AllEOPReports;
				}
				case RecurringEventType.Scheduled:
				{
					return AllScheduledReports;
				}
				default: 
				{
					System.Diagnostics.Debug.Assert(false);
					throw new ReportingException
						(string.Format("Unsupported Event Type: '{0}'", aContext.EventType.ToString()));
				}
			}
		}

		public IEnumerable GetReportDefinitionListForGroup
												(RecurringEventType aEventType, string aGroupName)
		{
			switch(aEventType)
			{
				case RecurringEventType.EndOfPeriod:
				{
					return GetEOPReportsForGroup(aGroupName);
				}
				case RecurringEventType.Scheduled:
				{
					return GetScheduledReportsForGroup(aGroupName);
				}
				default: 
				{
					System.Diagnostics.Debug.Assert(false);
					throw new ReportingException
						(string.Format("Unsupported Event Type: '{0}'", aEventType.ToString()));
				}
			}
		}

		public string GetReportInstanceFullPath
			(string aFileName)
		{
			if(aFileName.StartsWith(@"\\") ||
				(aFileName[1] == ':' && (aFileName[2] == '\\' || aFileName[2] == '/')	))
				return aFileName; 
			else
				return string.Format("{0}/{1}", mReportInstanceBasePhysicalPath, aFileName);

		}

		public IMTRcd GetRCDObject()
		{
			return mRcd;
		}
		
		
    //private functions

		private ReportConfiguration()
		{
			mAllScheduledReports = new ArrayList();
			mAllEOPReports = new ArrayList();
			mEOPReportsByGroup = new Hashtable();
			mScheduledReportsByGroup = new Hashtable();
			const string Extension = "Reporting";
			const string ConfigFile = "config\\ReportConfig.xml";
			const string GroupFile = "config\\ReportListGroups.xml";

            const string QuoteConfigFile = "Quoting\\QuotingConfiguration.xml";

			logger = new Logger("[ReportConfiguration]");
			logger.LogDebug("loading Reporting config file {0}/{1}", Extension, ConfigFile);
			

			try
			{
				//load config file
				MTXmlDocument doc = new MTXmlDocument();
				MTXmlDocument groupdoc = new MTXmlDocument();
                MTXmlDocument quotedoc = new MTXmlDocument();

				mRcd = new MTRcdClass();
				mRcd.Init();
				
				doc.LoadExtensionConfigFile(Extension, ConfigFile);
				mDatabasePrefix = doc.GetNodeValueAsString("//DBName");
				mGenerateDBEveryTime = doc.GetNodeValueAsBool("//GenerateDBEveryTime");
				mReportFailureThreshold = doc.GetNodeValueAsInt("//FailedReportsThreshold");
				mReportInstanceBasePhysicalPath = doc.GetNodeValueAsString("//ReportInstanceBaseDirectory/PhysicalPath");
				mReportInstanceVirtualDirectory = doc.GetNodeValueAsString("//ReportInstanceBaseDirectory/VirtualDirectory");
				
				mProgID = doc.GetNodeValueAsString("//ReportGeneratorProgID");
				try
				{
					Type reportgenType = Type.GetType(mProgID, true);
					mReportProvider = (IReportManager) Activator.CreateInstance(reportgenType);
				}
				catch(Exception)
				{
					logger.LogError(string.Format("Failed to create report provider object with Prog ID '{0}'", mProgID));
					throw;
				}
				
				mWebServiceDllRelativePath = doc.GetNodeValueAsString("//RemoteOpWebServiceDLLName");
				mWebServiceASMXRelativePath = doc.GetNodeValueAsString("//RemoteOpWebServiceASMXName");
				mbPauseReportsBeforeDelete = doc.GetNodeValueAsBool("//PauseReportsBeforeDelete");
				miTriggerReportGenerationEventPause = doc.GetNodeValueAsInt("//TriggerReportGenerationEventPause");

			    try
			    {
			        quotedoc.LoadConfigFile(QuoteConfigFile);
			        mQuotesSubFolder = quotedoc.GetNodeValueAsString("//ReportInstancePartialPath");
			        mQuotesSubFolder = mQuotesSubFolder.Remove(mQuotesSubFolder.LastIndexOf(@"\"));
			    }
                catch (Exception ex)
                {
                    logger.LogError(string.Format("Failed to load parameter from Quoting config file. Error:  '{0}'", ex.Message));
                }

			    //read report list file
				//TODO: Modify the code to pull the files from all extensions. Use RCD?
				//TODO: Handle duplicate names
				groupdoc.LoadExtensionConfigFile(Extension, GroupFile);
				XmlNodeList groups = groupdoc.SelectNodes("//ReportListGroup");
				foreach(XmlNode group in groups)
				{
					
					string GroupName = MTXmlDocument.GetNodeValueAsString(group, "./GroupName");
					string ListFile = MTXmlDocument.GetNodeValueAsString(group, "./FileName");
					doc.LoadExtensionConfigFile(Extension, ListFile);

					XmlNodeList eopreports = doc.SelectNodes("//EndOfPeriodReports/Report");
					RecurringEventType tp = RecurringEventType.EndOfPeriod;
					foreach(XmlNode node in eopreports)
					{
						ReportDefinition rdef = new ReportDefinition();
						rdef.GroupName = GroupName;
						rdef.UniqueName = MTXmlDocument.GetNodeValueAsString(node, "./UniqueName");
						rdef.SourceFile = MTXmlDocument.GetNodeValueAsString(node, "./SourceFile");
						rdef.DisplayName = MTXmlDocument.GetNodeValueAsString(node, "./DisplayName");
						rdef.InputQuery = MTXmlDocument.GetNodeValueAsString(node, "./InputQuery");
						rdef.SampleModeInputQuery = MTXmlDocument.GetNodeValueAsString(node, "./SampleModeInputQuery");
						rdef.ReportRecurringEventType = tp;
						rdef.OverwriteReportTemplateDestination = MTXmlDocument.GetNodeValueAsBool(node, "./OverwriteReportTemplateDestination");
						rdef.OverwriteReportTemplateFormat = MTXmlDocument.GetNodeValueAsBool(node, "./OverwriteReportTemplateFormat");
						rdef.OverwriteReportOriginalDataSource = MTXmlDocument.GetNodeValueAsBool(node, "./OverwriteReportOriginalDataSource");
						mAllEOPReports.Add(rdef);
						if (mEOPReportsByGroup.ContainsKey(GroupName) == false)
						{
							ArrayList newGroup = new ArrayList();
							mEOPReportsByGroup[GroupName] = newGroup;
						}
						((ArrayList)mEOPReportsByGroup[GroupName]).Add(rdef);
					}
					XmlNodeList scheduledreports = doc.SelectNodes("//ScheduledReports/Report");
					tp = RecurringEventType.Scheduled;
					foreach(XmlNode node in scheduledreports)
					{
						ReportDefinition rdef = new ReportDefinition();
						rdef.GroupName = GroupName;
						rdef.UniqueName = MTXmlDocument.GetNodeValueAsString(node, "./UniqueName");
						rdef.SourceFile = MTXmlDocument.GetNodeValueAsString(node, "./SourceFile");
						rdef.DisplayName = MTXmlDocument.GetNodeValueAsString(node, "./DisplayName");
						rdef.InputQuery = MTXmlDocument.GetNodeValueAsString(node, "./InputQuery");
						rdef.SampleModeInputQuery = MTXmlDocument.GetNodeValueAsString(node, "./SampleModeInputQuery");
						rdef.ReportRecurringEventType = tp;
						rdef.OverwriteReportTemplateDestination = MTXmlDocument.GetNodeValueAsBool(node, "./OverwriteReportTemplateDestination");
						rdef.OverwriteReportTemplateFormat = MTXmlDocument.GetNodeValueAsBool(node, "./OverwriteReportTemplateFormat");
						rdef.OverwriteReportOriginalDataSource = MTXmlDocument.GetNodeValueAsBool(node, "./OverwriteReportOriginalDataSource");
						mAllScheduledReports.Add(rdef);
						if (mScheduledReportsByGroup.ContainsKey(GroupName) == false)
						{
							ArrayList newGroup = new ArrayList();
							mScheduledReportsByGroup[GroupName] = newGroup;
						}
						((ArrayList)mScheduledReportsByGroup[GroupName]).Add(rdef);
					}
				}
			}
			catch(Exception e)
			{
				logger.LogError(e.ToString());
				throw e;
			}
			try 
			{
				MTServerAccessDataSet serveraccess = new MTServerAccessDataSetClass();
				serveraccess.Initialize();
				MTServerAccessData Aps = serveraccess.FindAndReturnObject("APSServer");
				mAPSName = Aps.ServerName;
				mAPSUser = Aps.UserName;
				mAPSPassword = Aps.Password;
				mAPSSecure = Aps.Secure;
				mAPSPort = Aps.PortNumber;
                // g. cieplik 8/25/2009 CORE-1472 use mMPSDatabaseName to overload with SI_NAME
                mAPSDatabaseName = Aps.DatabaseName;
			}
			catch (Exception e)
			{
				logger.LogError(e.ToString());
				throw e;
			}
		}
  
		public IReportDefinition GetEOPReportDefinitionByName(string aReportDefName)
		{
			string sUpper = aReportDefName.ToUpper();
			foreach(IReportDefinition rd in mAllEOPReports)
			{
				if(string.Compare(aReportDefName, rd.UniqueName) == 0)
				{
					return rd;
				}
			}
			return null;
		}
		public IReportDefinition GetScheduledReportDefinitionByName(string aReportDefName)
		{
			string sUpper = aReportDefName.ToUpper();
			foreach(IReportDefinition rd in mAllScheduledReports)
			{
				if(string.Compare(aReportDefName, rd.UniqueName) == 0)
				{
					return rd;
				}
			}
			return null;
		}
		public IReportManager GetReportManager()
		{
			//TODO: Is it safe to cache the instance of CEReportManager?
			//Maybe I shoul recreate it every time a client asks
			return mReportProvider;
		}
			
  }

  [Guid("22eb4336-158b-4b41-b599-9b70000ad406")]
  public interface IReportConfigurationProxy
  {
		string DatabasePrefix										{ get; }
		bool GenerateDBEveryTime									{ get; }
		int ReportFailureThreshold								{ get; }
		string ReportInstanceBasePath						{ get; }
		string ReportInstanceVirtualDirectory		{ get;}
		IEnumerable ScheduledReports							{ get; }
		IEnumerable EOPReports										{ get; }
		IReportDefinition GetEOPReportDefinitionByName(string aReportDefName);
		IReportDefinition GetScheduledReportDefinitionByName(string aReportDefName);
		IReportManager GetReportManager();
		string GenerateDatabaseName(IRecurringEventRunContext aContext);
		string GenerateBillingGroupDatabaseName(int aBillGroupID);
	    string GetDisplayName(string aFileName);
		IEnumerable GetReportDefinitionList(IRecurringEventRunContext aContext);
		IEnumerable GetReportDefinitionListForGroup(RecurringEventType aEventType, string aGroupName);

		string APSName	{get;}
		string APSUser {get;}
		string APSPassword {get;}
		int APSSecure {get;}
		int APSPort {get;}
		
  };

  /// <summary>
  /// Proxy to ReportConfiguration.
  /// Needed for access through COM (a COM client cannot call static methods).
  /// </summary>
  [Guid("6880f703-e9f5-47b2-8b7d-cf4595b56a12")]
  [ClassInterface(ClassInterfaceType.None)]
  public class ReportConfigurationProxy : IReportConfigurationProxy
  {
    public ReportConfigurationProxy() {}
		public string DatabasePrefix										{ get { return ReportConfiguration.GetInstance().DatabasePrefix; }}
		public bool GenerateDBEveryTime									{ get { return ReportConfiguration.GetInstance().GenerateDBEveryTime; }}
		public int ReportFailureThreshold								{ get { return ReportConfiguration.GetInstance().ReportFailureThreshold; }}
		public string ReportInstanceBasePath						{ get { return ReportConfiguration.GetInstance().ReportInstanceBasePath; }}
		public string ReportInstanceVirtualDirectory		{ get { return ReportConfiguration.GetInstance().ReportInstanceVirtualDirectory; }}
		
		public IEnumerable ScheduledReports							{ get { return ReportConfiguration.GetInstance().AllScheduledReports; }}
		public IEnumerable EOPReports										{ get { return ReportConfiguration.GetInstance().AllEOPReports; }}
		public IReportDefinition GetEOPReportDefinitionByName(string aReportDefName) 
		{
			return ReportConfiguration.GetInstance().GetEOPReportDefinitionByName(aReportDefName);
		}
		public IReportDefinition GetScheduledReportDefinitionByName(string aReportDefName) 
		{
			return ReportConfiguration.GetInstance().GetScheduledReportDefinitionByName(aReportDefName);
		}
		public IReportManager GetReportManager() 
		{
			return ReportConfiguration.GetInstance().GetReportManager();
		}
		public string GenerateBillingGroupDatabaseName(int aBillGroupID)
		{
			return ReportConfiguration.GetInstance().GenerateBillingGroupDatabaseName(aBillGroupID);
		}
		public string GenerateDatabaseName(IRecurringEventRunContext aContext)
		{
			return ReportConfiguration.GetInstance().GenerateDatabaseName(aContext);
		}
		public string GetDisplayName(string aFileName)
		{
			return ReportConfiguration.GetInstance().GetDisplayName(aFileName);
		}
		public IEnumerable GetReportDefinitionList(IRecurringEventRunContext aContext)
		{
			return ReportConfiguration.GetInstance().GetReportDefinitionList(aContext);
		}
		public IEnumerable GetReportDefinitionListForGroup(RecurringEventType aEventType, string aGroupName)
		{
			return ReportConfiguration.GetInstance().GetReportDefinitionListForGroup(aEventType, aGroupName);
		}
		
	    public string APSName	{ get { return ReportConfiguration.GetInstance().APSName; }}
		public string APSUser	{ get { return ReportConfiguration.GetInstance().APSUser; }}
		public string APSPassword	{ get { return ReportConfiguration.GetInstance().APSPassword; }}		
		public int APSSecure { get { return ReportConfiguration.GetInstance().APSSecure; }}
		public int APSPort { get { return ReportConfiguration.GetInstance().APSPort; }}
		
    
  };
}
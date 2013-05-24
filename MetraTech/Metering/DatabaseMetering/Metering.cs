using System;
using System.Data;
using System.Data.OleDb;
using System.Xml;
using System.Xml.Schema;
using System.Collections;
using System.IO;
using MetraTech;
using MetraTech.Interop.COMMeter;
using Microsoft.Win32;

namespace MetraTech.Metering.DatabaseMetering
{
	/// <summary>
	/// This class is used to read the configuration setting, initialize the ConfigInfo object,
	/// metering the service data and releasing the resources.
	/// </summary>
	public class MeterHelper
	{
		/// <summary>
		/// Stores the configuration information for MeterHelper.
		/// </summary>
		public ConfigInfo objConfigInfo;
		private bool configured = false;

		/// <summary>
		/// Constant variable. Assigned to 1.
		/// </summary>
		private const int BOOL = 1;

		/// <summary>
		/// Constant variable. Assigned to 2.
		/// </summary>
		private const int INT = 2;

		/// <summary>
		/// Constant variable. Assigned to 3.
		/// </summary>
		private const int STRING = 3;

		/// <summary>
		/// Constant variable. Assigned to 4.
		/// </summary>
		private const int DATETIME = 4;

		/// <summary>
		/// Constant variable. Assigned to 5.
		/// </summary>
		private const int DOUBLE = 5;

		/// <summary>
		/// Caption for message box.
		/// </summary>
		private const string MSG_CAPTION = "DB Metering Program";

		/// <summary>
		/// Mode for the batch criteria timestamp
		/// </summary>
		private string strTimestampMode;

		/// <summary>
		/// Table name for the timstamp mode "DB"
		/// </summary>
		private string strTableName;

		/// <summary>
		/// Column name for the timestamp mode "DB"
		/// </summary>
		private string strColumnName;

		/// <summary>
		/// Value of the timestamp mode "File"
		/// </summary>
		const string TIMESTAMP_MODE_FILE = "FILE";

		/// <summary>
		/// Value of the timestap mode "DB"
		/// </summary>
		const string TIMESTAMP_MODE_DB = "DB";

		Log objLog = null;							//Log object used to log the debug info

		//Used to log the additional info for debugging
		public static bool verboseMode = false;

		const int MT_ERR_SERVER_BUSY = -516947930;

		private string schemafile = @"validation\DBMPConfigSchema.xsd";
		private Boolean m_success = true;

		public const string defaultns = "dbmpns";
		public const string urnname = "urn:dbmp-config-schema";
		const string METRACONNECT_KEY_PATH = @"SOFTWARE\MetraTech\MetraConnect";
		const string METRANET_KEY_PATH = @"SOFTWARE\MetraTech\MetraNet";

		const string DEFAULT_SQL_PROVIDER = "sqloledb";
		const string DEFAULT_SYBASE_PROVIDER = "Sybase ASE OLE DB Provider";

		// SC: TimeZoneInformation - replacement for ConvertTimeZone
		TimeZoneInformation timeZoneInformation;

		const string usage = "Usage: MetraConnect-DB.exe <configfile> [/batch:<batch name> /batchnamespace:<batch namespace>] [/start:CCYY-MM-DDTHH:MI:SSZ /end:CCYY-MM-DDTHH:MI:SSZ] [/verbose]";

		/// <summary>
		/// It reads the command line arguments and validates them. It reads the service list from the 
		/// configuration file, creates ServiceDef object for them and meters the services.
		/// </summary>
		/// <param name="args">list of arguments passed from the command line</param>
		public int Meter(string[] args)
		{
			ServiceDef objServiceDef;					//ServiceDef object, defines the methods to meter the services.
			//bool bMeterFileExist;						//boolean variable to check whether the file exists or not

			// Read ConfigFileName from Command Line parameters
			try
			{
				Configure(args);

				// SDK Initialization		
				objLog.LogString(Log.LogLevel.INFO, "Initializing MetraConnect-SDK");
				SDKInit();

				// meter each service definition
				objLog.LogString(Log.LogLevel.DEBUG, "Metering all service definitions");
				int iNumServices = objConfigInfo.arrCollectionServices.Count;
				for (int iCount = 0; iCount < iNumServices; iCount++)
				{
					objServiceDef = (ServiceDef)objConfigInfo.arrCollectionServices[iCount];
					objServiceDef.Meter(objConfigInfo);
				}
				objLog.LogString(Log.LogLevel.INFO, "Completed metering for all service definitions");

				//write the XML file back
				objLog.LogString(Log.LogLevel.INFO, "Performing XML Shutdown");

				if ((objConfigInfo.strBatchCriteria.ToUpper() == ConfigInfo.TIMESTAMP.ToUpper()) && !objConfigInfo.bMeteringTimePassed
					&& (strTimestampMode.ToUpper() == TIMESTAMP_MODE_DB))
				{
					UpdateTimestampInDB();
				}

				//shutdown the sdk
				objLog.LogString(Log.LogLevel.INFO, "Shutting Down MetraConnect-SDK");
				SDKShutdown();
				objLog.LogString(Log.LogLevel.INFO, "MetraConnect-SDK Shutdown Completed");
				return 0;
			}
			catch (ApplicationException aex)
			{
				Console.WriteLine("Business Exception occurred: " + aex.Message);
				if (objLog != null)
				{
					objLog.LogString(Log.LogLevel.FATAL, "Business Exception occurred: " + aex.Message);
					objLog.LogString(Log.LogLevel.FATAL, " Stacktrace: " + aex.StackTrace);
				}
				throw;
			}
			catch (Exception objEx)
			{
				Console.WriteLine("Exception occurred: " + objEx.Message);
				if (objLog != null)
				{
					objLog.LogString(Log.LogLevel.FATAL, "Exception occurred: " + objEx.Message);
					objLog.LogString(Log.LogLevel.FATAL, " Stacktrace: " + objEx.StackTrace);
				}
				throw;
			}
			finally
			{
				if (objLog != null)
				{
					objLog.LogClose();
					objLog = null;
				}
			}
		}

		public void Refresh()
		{
			configured = false;
		}

		/// <summary>
		///   
		/// </summary>
		/// <param name="args"></param>
		public void Configure(string[] args)
		{
			if (configured)
			{
				return;
			}

			if (args.Length < 1)
			{
				throw new ApplicationException(usage);
			}
			CommandLineParser parser = new CommandLineParser(args, 1, args.Length);
			parser.Parse();

			// get config file name

			if ((args[0].IndexOf(@"\") > 0) || (args[0].IndexOf("/") > 0))
				objConfigInfo.strConfigFileName = args[0];
			else
				objConfigInfo.strConfigFileName = Directory.GetCurrentDirectory() + @"\" + args[0];

			//Fix for CR#11966
			if (!objConfigInfo.strConfigFileName.ToLower().EndsWith(".xml"))
				throw new ApplicationException("File name should have .xml extension only.");

			// -batch and -batchnamespace arguments

			objConfigInfo.strBatchName = parser.GetStringOption("batch", null);
			objConfigInfo.strBatchNameSpace = parser.GetStringOption("batchnamespace", null);

			if (objConfigInfo.strBatchName != null && objConfigInfo.strBatchNameSpace != null)
			{
				objConfigInfo.bBatchInfoPassed = true;
			}
			else if (objConfigInfo.strBatchName == null && objConfigInfo.strBatchNameSpace == null)
			{
				objConfigInfo.bBatchInfoPassed = false;
			}
			else
			{
				throw new ApplicationException(usage);
			}

			// -start and -end arguments

			string start_time = parser.GetStringOption("start", null);
			string end_time = parser.GetStringOption("end", null);

			if (start_time != null && end_time != null)
			{
				objConfigInfo.dtStartMeteringTime = (DateTime)(StrDate(start_time));
				objConfigInfo.dtEndMeteringTime = (DateTime)(StrDate(end_time));

				if (objConfigInfo.dtEndMeteringTime <= objConfigInfo.dtStartMeteringTime)
				{
					throw new ApplicationException("Metering start date should not be greater than or equal to metering end date.");
				}

				objConfigInfo.bMeteringTimePassed = true;
			}
			else if (start_time == null && end_time == null)
			{
				objConfigInfo.bMeteringTimePassed = false;
			}
			else
			{
				throw new ApplicationException(usage);
			}

			// -verbose option

			verboseMode = parser.GetBooleanOption("verbose", false);

			// load config file

			XmlDocument xmldoc = new XmlDocument();
			xmldoc.Load(objConfigInfo.strConfigFileName);
			XmlElement docelement = xmldoc.DocumentElement;
			if (docelement.Attributes["xmlns"] == null)
				throw new ApplicationException("Namespace not defined.  Please edit the configuration file and change <xmlconfig> to <xmlconfig xmlns=\"urn:dbmp-config-schema\">");

			xmldoc = null;

			// find config file path

			RegistryKey reghive = Registry.LocalMachine;

			string configpath = null;

			// first look under MetraConnect key
			RegistryKey regkey = reghive.OpenSubKey(METRACONNECT_KEY_PATH);

			if (regkey != null && regkey.GetValue("ConfigDir") != null)
			{
				configpath = regkey.GetValue("ConfigDir").ToString();
			}

			if (configpath == null || configpath.Length == 0)
			{
				// not found, try MetraNet key instead
				regkey = reghive.OpenSubKey(METRANET_KEY_PATH);

				if (regkey != null && regkey.GetValue("ConfigDir") != null)
				{
					configpath = regkey.GetValue("ConfigDir").ToString();
				}
			}

			if (configpath == null || configpath.Length == 0)
			{
				throw new ApplicationException("ConfigDir value not found in registry.");
			}

			if (configpath.EndsWith(@"\"))
				schemafile = configpath + schemafile;
			else
				schemafile = configpath + @"\" + schemafile;

			XmlSchemaCollection xsc = new XmlSchemaCollection();
			xsc.Add(urnname, schemafile);
			Validate(objConfigInfo.strConfigFileName, xsc);
			if (!m_success)
			{
				throw new ApplicationException("Error while validating the config file.");
			}
			//Get the configuration settings for the system
			XmlDocument objXmlDoc = new XmlDocument();

			objXmlDoc.PreserveWhitespace = true;
			objXmlDoc.Load(objConfigInfo.strConfigFileName);

			//Construct the configinfo object
			Init(objXmlDoc);
			objLog = Log.GetInstance();

			// Create the TimeZoneInformation class
			CreateTimeZoneInformation(objConfigInfo);

			configured = true;
		}

		/// <summary>
		/// Reads the config file and initializes the global variables.
		/// Initializes the log file.
		/// </summary>
		/// <param name="xmlDoc">The xml document to be parsed for reading the Configuration parameters</param>
		void Init(XmlDocument xmlDoc)
		{
			string strLogFileName;								//Name of the log file
			int iLogLevel;												//desired log level
			int iNumMeteringServers;							//Total number of Metering servers specified in the configuration file
			int iNumServices;											//Total number of Service defined in the configuration file 				
			XmlNode objMeteringServers;
			XmlNodeList objMeteringServerList, objServiceDataList;
			XmlNode objServerData;
			MTServer objNewServer;
			// Set of Services
			XmlNode objServiceData;
			// Atributes for each service
			XmlNode objService;
			ServiceDef objServiceDef;

			try
			{
				//Adding the prefix (hard coded) for the schema. AS the XPath queries can't be executed on default
				//namespace (see msdn site)
				XmlNamespaceManager nsmgr = new XmlNamespaceManager(xmlDoc.NameTable);
				nsmgr.AddNamespace(defaultns, urnname);

				// instantiating the log object
				strLogFileName = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:loggingConfig/dbmpns:logFileName", nsmgr), MeterHelper.STRING);
				iLogLevel = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:loggingConfig/dbmpns:logLevel", nsmgr), MeterHelper.INT);

				//Start logging and set interactivity
				Log.LogInit(strLogFileName, iLogLevel, "MetraConnect-DB");
				objLog = Log.GetInstance();
				objLog.LogString(Log.LogLevel.INFO, "Starting Metering ...");

				//Set the datasource failure flag to flase. No database errors detected as of now
				objConfigInfo.bDataSourceConnectFailure = false;

				objConfigInfo.statusUpdateMode = 1; //default value
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:StatusUpdateMode", nsmgr) != null)
				{
					int updatemode = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:StatusUpdateMode", nsmgr), MeterHelper.INT);
					if (updatemode >= 1 && updatemode <= 3)
						objConfigInfo.statusUpdateMode = updatemode;
				}

				objConfigInfo.suffixforstatustable = "_Status"; //default value
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:StatusTableSuffix", nsmgr) != null)
				{
					string suffix = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:StatusTableSuffix", nsmgr), MeterHelper.STRING);
					suffix = suffix.Trim();
					if (suffix != null && suffix.Length > 0)
						objConfigInfo.suffixforstatustable = suffix;
				}
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:UpdateTableName", nsmgr) != null)
				{
					string updatetablename = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:UpdateTableName", nsmgr), MeterHelper.STRING);
					updatetablename = updatetablename.Trim();
					if (updatetablename != null && updatetablename.Length > 0)
						objConfigInfo.updatetablename = updatetablename;
				}

				if (objConfigInfo.bMeteringTimePassed)
				{
					objConfigInfo.dtLastMeteredTime = objConfigInfo.dtStartMeteringTime;
				}

				//CR #12662: Have made localtimezone tag optional. But user should specify value for this tag
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:localTimeZone", nsmgr) != null)
				{
					objConfigInfo.strLocalTimeZone = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:localTimeZone", nsmgr), MeterHelper.STRING);
					if (objConfigInfo.strLocalTimeZone.Trim().Length == 0)
						throw new ApplicationException("Value for localtimezone tag not speified in the config file");
				}
				objConfigInfo.iGraceDays = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:graceDays", nsmgr), MeterHelper.INT);

				// Read global options
				objConfigInfo.bInteractive = (bool)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:interactive", nsmgr), MeterHelper.BOOL);
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:connectivityretry", nsmgr) == null)
				{
					objConfigInfo.bConnectivityRetry = true;
				}
				else
				{
					objConfigInfo.bConnectivityRetry = (bool)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:connectivityretry", nsmgr), MeterHelper.BOOL);
				}
				// Read numberOfOutStandingThreads
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:numberOfOutStandingThreads", nsmgr) != null)
				{
					objConfigInfo.numberOfOutStandingThreads = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:numberOfOutStandingThreads", nsmgr), MeterHelper.INT);
				}
				else
				{
					objConfigInfo.numberOfOutStandingThreads = 100;
				}
				objConfigInfo.bUseDefaults = (bool)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:useDefaults", nsmgr), MeterHelper.BOOL);
				objConfigInfo.strBatchCriteria = ((string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:batchCriteria", nsmgr), MeterHelper.STRING)).ToUpper();

				if ((objConfigInfo.iGraceDays < 0) && (objConfigInfo.strBatchCriteria.ToUpper() == ConfigInfo.TIMESTAMP.ToUpper()))
				{
					throw new ApplicationException("The value of GraceDays can not be negative");
				}
				/*
				objConfigInfo.bLocalMode = !(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:LocalMode", nsmgr)== null);		
				if(objConfigInfo.bLocalMode)
				{
					objConfigInfo.strLocalModeFile = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:LocalMode/dbmpns:LocalModeFile", nsmgr),MeterHelper.STRING);
					objConfigInfo.strMeterJournalFile = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:LocalMode/dbmpns:MeterJournalFile", nsmgr),MeterHelper.STRING);
				}
				else
				{
					objConfigInfo.strLocalModeFile = "";
					objConfigInfo.strMeterJournalFile = "";
				}		
				*/
				//Read the database settings
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:DataSource", nsmgr) != null)
				{
					objConfigInfo.strDBDataSource = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:DataSource", nsmgr), MeterHelper.STRING);
				}
				objConfigInfo.strDBUsername = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:UserName", nsmgr), MeterHelper.STRING);
				objConfigInfo.strDBPassword = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:Password", nsmgr), MeterHelper.STRING);
				objConfigInfo.strDBType = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:DatabaseType", nsmgr), MeterHelper.STRING);
				objConfigInfo.strDBLockTable = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:LockTable", nsmgr), MeterHelper.STRING);
				objConfigInfo.strDBLockTable.ToUpper();
				objConfigInfo.strDBServer = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:DataServer", nsmgr).InnerText;
				objConfigInfo.strDBName = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:DataBase", nsmgr).InnerText;
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:AppendToConnectionString", nsmgr) != null)
				{
					objConfigInfo.strAppendToConnectionString =
					  xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:AppendToConnectionString", nsmgr).InnerText.Trim();
				}
				else
				{
					objConfigInfo.strAppendToConnectionString = String.Empty;
				}

				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:Provider", nsmgr) != null)
					objConfigInfo.Provider = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:Provider", nsmgr).InnerText;
				else
				{
					//CR #12099: DBMP 4.0 not backward-compatible with 3.7 configuration file format 
					switch (objConfigInfo.strDBType.ToUpper())
					{
						case "MSSQL":
							objConfigInfo.Provider = DEFAULT_SQL_PROVIDER;
							break;
						case "SYBASE":
							objConfigInfo.Provider = DEFAULT_SYBASE_PROVIDER;
							break;
						default:
							throw new ApplicationException("Wrong DBType provided. It should be either MSSQL or Sybase");

					}
				}

				//Setting whether user has specified the connected mode or disconnected.
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:ConnectedMode", nsmgr) != null)
				{
					objConfigInfo.isConnectedMode = (bool)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:ConnectedMode", nsmgr), MeterHelper.BOOL);
				}
				else
					objConfigInfo.isConnectedMode = true;

				//Set the CommandTimeout value
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:CommandTimeout", nsmgr) != null)
				{
					ConfigInfo.commandTimeout = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:DatabaseConfig/dbmpns:CommandTimeout", nsmgr), MeterHelper.INT);
				}

				/*
				if( objConfigInfo.strDBType.ToUpper().Equals( "MSSQL" ) )
				{
					if( objConfigInfo.strDBServer == null || objConfigInfo.strDBServer.Length == 0 ||
						objConfigInfo.strDBName == null || objConfigInfo.strDBName.Length == 0 )
					{
						throw new ApplicationException ("Database parameters were incorrect for database type MSSQL");
					}
				}
				*/

				if ((objConfigInfo.strDBLockTable == null) || (objConfigInfo.strDBLockTable.Length == 0))
				{
					objLog.LogString(Log.LogLevel.DEBUG, "Missing Node for LockTable - will default to FALSE");
					objConfigInfo.strDBLockTable = "FALSE";
				}

				if ((objConfigInfo.strDBLockTable.CompareTo("TRUE") != 0) && (objConfigInfo.strDBLockTable.CompareTo("FALSE") != 0))
				{
					objLog.LogString(Log.LogLevel.WARNING, "Invalid value for LockTable - will default to FALSE");
					objConfigInfo.strDBLockTable = "FALSE";
				}

				if (objConfigInfo.strDBLockTable.CompareTo("FALSE") == 0)
				{
					objLog.LogString(Log.LogLevel.WARNING, "LockTable set to FALSE - performance is impacted.");
				}
				else
				{
					objLog.LogString(Log.LogLevel.INFO, "LockTable set to TRUE - Exclusive locks will be taken.");
				}

				//If Batch criteria is set to 'Timestamp' and dates are not passed in the command line.
				if ((objConfigInfo.strBatchCriteria.ToUpper() == ConfigInfo.TIMESTAMP.ToUpper()) && !objConfigInfo.bMeteringTimePassed)
				{
					XmlNode objTimestampNode = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:Timestamp", nsmgr);
					HandleForTimestamp(objTimestampNode);
				}

				XmlNode objSessionContextNode = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:SessionContext", nsmgr);
				HandleForSessionContext(objSessionContextNode);

				objConfigInfo.strTablePrefix = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:TablePrefix", nsmgr), MeterHelper.STRING);
				objConfigInfo.strColumnPrefix = (string)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:ColumnPrefix", nsmgr), MeterHelper.STRING);

				objConfigInfo.iHttptimeout = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:httptimeout", nsmgr), MeterHelper.INT);
				objConfigInfo.iHttpretries = (int)GetPTypeValue(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:httpretries", nsmgr), MeterHelper.INT);


				//create a list of metering servers and define each server properties
				objConfigInfo.arrServerList = new ArrayList();
				objMeteringServers = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:MeteringServers", nsmgr);
				objMeteringServerList = objMeteringServers.SelectNodes("dbmpns:ServerData", nsmgr);
				iNumMeteringServers = objMeteringServerList.Count;

				//For Each eoServerData In eoMeteringServers.selectNodes("ServerData")
				for (int iCount = 0; iCount < iNumMeteringServers; iCount++)
				{
					objServerData = objMeteringServerList[iCount];
					objNewServer = new MTServer();
					objNewServer.strServeraddress = (string)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:serveraddress", nsmgr), MeterHelper.STRING);
					objNewServer.iPort = (int)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:port", nsmgr), MeterHelper.INT);
					objNewServer.iPriority = (int)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:priority", nsmgr), MeterHelper.INT);
					objNewServer.bSecure = (bool)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:secure", nsmgr), MeterHelper.BOOL);
					objNewServer.strMeterinGuid = (string)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:meteringuid", nsmgr), MeterHelper.STRING);
					objNewServer.strMeteringPwd = (string)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:meteringpwd", nsmgr), MeterHelper.STRING);
					objNewServer.iSdkdebuglevel = (int)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:sdkdebuglevel", nsmgr), MeterHelper.INT);
					objNewServer.iTransmitInterval = (int)GetPTypeValue(objServerData.SelectSingleNode("dbmpns:transmitinterval", nsmgr), MeterHelper.INT);
					objConfigInfo.arrServerList.Add(objNewServer);
				}

				// Read Service Definitions
				objServiceData = xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:Services", nsmgr);
				objServiceDataList = objServiceData.SelectNodes("dbmpns:ServiceData", nsmgr);
				iNumServices = objServiceDataList.Count;
				objConfigInfo.arrCollectionServices = new ArrayList();
				for (int iCount = 0; iCount < iNumServices; iCount++)
				{
					objService = objServiceDataList[iCount];
					objServiceDef = new ServiceDef(this);
					objServiceDef.GetServiceData(ref objService);
					objConfigInfo.arrCollectionServices.Add(objServiceDef);
				}

				if (objConfigInfo.bMeteringTimePassed)
				{
					objConfigInfo.dtNextMeteredTime = objConfigInfo.dtEndMeteringTime;
				}
				else									//Gets NextMeteredTime
				{
					DateTime dt;
					dt = DateTime.Today;				//DateTime.Today will return only the date part.
					objConfigInfo.dtNextMeteredTime = dt.AddDays(1 - objConfigInfo.iGraceDays);
				}

				objConfigInfo.errorHandlingProps = new Hashtable();
				SettingTheDefaultValuesForErrors();
				if (xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:ErrorHandling", nsmgr) != null)
				{
					HandleErrorHandlingSettings(xmlDoc.SelectSingleNode("/dbmpns:xmlconfig/dbmpns:ErrorHandling", nsmgr));
				}

				//Indicates whether a Network Error has occurred during metering
				objConfigInfo.bNetworkError = false;
			}
			catch (ApplicationException aex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the Init: " + aex.Message);
				throw;
			}
			finally
			{
				// Object destruction
				objService = null;
				objServiceData = null;
				objServerData = null;
				objMeteringServers = null;
			}
		}


		/// <summary>
		/// Handles for batch criteria ‘Timestamp’. Reads the mode, startmeteringtime and dbsettings 
		/// from the config file. If mode is ‘DB’, connects to database and retrieves the value 
		/// of lastMeteredTime.
		/// </summary>
		/// <param name="objTimestampNode">xml node representing the timestamp tag</param>
		private void HandleForTimestamp(XmlNode objTimestampNode)
		{
			DAL objDAL = null;
			XmlNamespaceManager nsmgr = null;
			try
			{
				nsmgr = new XmlNamespaceManager(objTimestampNode.OwnerDocument.NameTable);
				nsmgr.AddNamespace(defaultns, urnname);
				strTimestampMode = objTimestampNode.SelectSingleNode("dbmpns:Mode", nsmgr).InnerText.ToUpper();
				//CR #12115:No validation done for missing tags <StartMeteringTime> or <DBSettings> for Batch crtieria set to timestamp.
				switch (strTimestampMode)
				{
					case TIMESTAMP_MODE_FILE:
						if ((objTimestampNode.SelectSingleNode("dbmpns:StartMeteringTime", nsmgr) == null) || (objTimestampNode.SelectSingleNode("dbmpns:StartMeteringTime", nsmgr).InnerText.Trim().Length == 0))
							throw new ApplicationException("Mode is timestamp (file) & startmetering tag not defined or value is not set");
						objLog.LogString(Log.LogLevel.DEBUG, "Converting the StartMeteringTime to DateTime for TimeStamp mode file");
						objConfigInfo.dtLastMeteredTime = (DateTime)(GetPTypeValue(objTimestampNode.SelectSingleNode("dbmpns:StartMeteringTime", nsmgr), MeterHelper.DATETIME));
						break;
					case TIMESTAMP_MODE_DB:
						XmlNode objDBSettingsNode = objTimestampNode.SelectSingleNode("dbmpns:DBSettings", nsmgr);
						if (objDBSettingsNode == null)
							throw new ApplicationException("Mode is timestamp (db) & DBSettings tag not defined");

						if ((objDBSettingsNode.SelectSingleNode("dbmpns:TableName", nsmgr) == null) || (objDBSettingsNode.SelectSingleNode("dbmpns:ColumnName", nsmgr) == null)
							|| (objDBSettingsNode.SelectSingleNode("dbmpns:TableName", nsmgr).InnerText.Trim().Length == 0) || (objDBSettingsNode.SelectSingleNode("dbmpns:ColumnName", nsmgr).InnerText.Trim().Length == 0))
							throw new ApplicationException("Mode is timestamp (db) & either TableName or ColumnName tag not defined or their value is not set");
						strTableName = objDBSettingsNode.SelectSingleNode("dbmpns:TableName", nsmgr).InnerText;
						strColumnName = objDBSettingsNode.SelectSingleNode("dbmpns:ColumnName", nsmgr).InnerText;

						objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
							objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
						string strQuery = "SELECT " + strColumnName + " FROM " + strTableName;
						objLog.LogString(Log.LogLevel.DEBUG, "About to execute the query for retrieving startmeteringtime from DB: " + strQuery);
						OleDbDataReader objReader = null;
						//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
						// method for query to DB was replaced
						objReader = objDAL.RunGetDataReader(strQuery, null);
						//objDAL.Run(ref objReader, strQuery);
						if (objReader.Read())
						{
							objConfigInfo.dtLastMeteredTime = DateTime.Parse(objReader.GetValue(0).ToString());
						}
						else
						{
							throw new ApplicationException("Database doesn't contain the timestamp value");
						}
						if (objReader != null)
						{
							((IDisposable)objReader).Dispose();
						}
						break;
					default:
						throw new ApplicationException("Mode for Timestamp is either invalid or blank.");
				}
			}
			catch (ApplicationException aex)
			{
				objLog.LogString(Log.LogLevel.INFO, "Error in the HandleForTimestamp: " + aex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
					objDAL.Close();
			}
		}


		/// <summary>
		/// Initializes the Meter object; sets the properties of the Meter object
		/// </summary>
		void SDKInit()
		{
			try
			{
				MTServer objNewServer;
				int iSecure = 0;
				objConfigInfo.objMeter = new Meter();
				objConfigInfo.objMeter.Startup();
				objConfigInfo.objMeter.HTTPTimeout = objConfigInfo.iHttptimeout;
				objConfigInfo.objMeter.HTTPRetries = objConfigInfo.iHttpretries;
				objConfigInfo.objMeter.MeterJournal = objConfigInfo.strMeterJournalFile;
				for (int iCount = 0; iCount < objConfigInfo.arrServerList.Count; iCount++)
				{
					iSecure = 0;
					objNewServer = (MTServer)objConfigInfo.arrServerList[iCount];
					PortNumber iPortNumber = (PortNumber)objNewServer.iPort;
					if (objNewServer.bSecure)
						iSecure = 1;
					objConfigInfo.objMeter.AddServer(objNewServer.iPriority, objNewServer.strServeraddress, iPortNumber, iSecure, objNewServer.strMeterinGuid, objNewServer.strMeteringPwd);
				}
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the SDKInit: " + ex.Message);
				throw;
			}

		}


		/// <summary>
		/// Shutdown the metering object.
		/// </summary>
		void SDKShutdown()
		{
			objConfigInfo.objMeter.Shutdown();
		}


		/// <summary>
		/// If batch criteria is ‘Timestamp and mode  is set to ‘DB’, updates the value of 
		/// EndMeteringTime in the database.
		/// </summary>
		void UpdateTimestampInDB()
		{
			DAL objDAL = null;
			try
			{
				objLog = Log.GetInstance();
				objDAL = new DAL(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
					objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
				//SECENG: CORE-4823 CLONE - BSS 29005 Security - CAT .NET - SQL Injection in MetraTech Binaries (SecEx)
				// OleDbParametr's was added to query
				string strQuery = "UPDATE " + strTableName + " SET " + strColumnName + " = ?";
				MTDbParameter updParameter = new MTDbParameter(objConfigInfo.dtNextMeteredTime);
				objDAL.RunExecuteNonQuery(strQuery, new MTDbParameter[] { updParameter });
				//string strQuery = "UPDATE " + strTableName + " SET " + strColumnName + " = '" + objConfigInfo.dtNextMeteredTime.ToString() + "'";
				//objDAL.Run(strQuery);
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the UpdateTimestampInDB: " + ex.Message);
				throw;
			}
			finally
			{
				if (objDAL != null)
					objDAL.Close();
			}
		}

		/// <summary>
		/// Reads the SessionContext from the config file. If value is null, connects to the 
		/// metering server to retrieve the value of the Session context.
		/// </summary>
		/// <param name="objSessionContextNode"></param>
		private void HandleForSessionContext(XmlNode objSessionContextNode)
		{
			XmlNamespaceManager nsmgr = new XmlNamespaceManager(objSessionContextNode.OwnerDocument.NameTable);
			nsmgr.AddNamespace(defaultns, urnname);
			//Read the session context settings
			objConfigInfo.strSessionContextUserName = objSessionContextNode.SelectSingleNode("dbmpns:UserName", nsmgr).InnerText;
			objConfigInfo.strSessionContextNameSpace = objSessionContextNode.SelectSingleNode("dbmpns:NameSpace", nsmgr).InnerText;
			objConfigInfo.strSessionContextPassword = objSessionContextNode.SelectSingleNode("dbmpns:Password", nsmgr).InnerText;
			// Read the Serialized Context
			objConfigInfo.strSerializedContext = objSessionContextNode.SelectSingleNode("dbmpns:SerializedContextStr", nsmgr).InnerText;

			if ((objConfigInfo.strSessionContextUserName.Length == 0) && (objConfigInfo.strSerializedContext.Length == 0))
			{
				objConfigInfo.bSessionContextDefined = false;
			}
			else
			{
				objConfigInfo.bSessionContextDefined = true;
			}

			if (objConfigInfo.strSerializedContext.Length == 0 && objConfigInfo.bSessionContextDefined)
			{
				XmlNode objServerNode = objSessionContextNode.SelectSingleNode("dbmpns:ServerSettings", nsmgr);
				objConfigInfo.strSerializedContext = GetSessionContextFromExternalServer(objServerNode);
				if ((objConfigInfo.strSerializedContext == null) || (objConfigInfo.strSerializedContext.Length == 0))
					objLog.LogString(Log.LogLevel.WARNING, "No Serialized String in SDK config file and Couldn't retrieve from the server - Performance is impacted.");
			}

		}


		/// <summary>
		/// This function is used to retriev the SessionContext from the MetraNet servers.
		/// </summary>
		/// <param name="objServerNode"></param>
		/// <returns>string containing the value of the session context</returns>
		private string GetSessionContextFromExternalServer(XmlNode objServerNode)
		{
			string strSessionContext;
			Meter objMeter = null;
			Session objSession;
			try
			{
				XmlNamespaceManager nsmgr = new XmlNamespaceManager(objServerNode.OwnerDocument.NameTable);
				nsmgr.AddNamespace(defaultns, urnname);
				if (objServerNode == null)
					return null;
				XmlNodeList objMeteringServerList = objServerNode.SelectNodes("dbmpns:ServerData", nsmgr);
				if (objMeteringServerList.Count == 0)
					return null;

				//Create Meter object
				objMeter = new Meter();
				objMeter.Startup();
				// Read the server settings. There can be more than 1 server	

				objMeter.HTTPTimeout = objConfigInfo.iHttptimeout;
				objMeter.HTTPRetries = objConfigInfo.iHttpretries;

				int iSecure = 0, iPort, iPriority;
				string strServeraddress, strMeterinGuid, strMeteringPwd;
				bool bSecure;
				for (int iCount = 0; iCount < objMeteringServerList.Count; iCount++)
				{
					strServeraddress = (string)GetPTypeValue(objMeteringServerList[iCount].SelectSingleNode("dbmpns:serveraddress", nsmgr), MeterHelper.STRING);
					iPort = (int)GetPTypeValue(objMeteringServerList[iCount].SelectSingleNode("dbmpns:port", nsmgr), MeterHelper.INT);
					iPriority = (int)GetPTypeValue(objMeteringServerList[iCount].SelectSingleNode("dbmpns:priority", nsmgr), MeterHelper.INT);
					bSecure = (bool)GetPTypeValue(objMeteringServerList[iCount].SelectSingleNode("dbmpns:secure", nsmgr), MeterHelper.BOOL);
					strMeterinGuid = (string)GetPTypeValue(objMeteringServerList[iCount].SelectSingleNode("dbmpns:meteringuid", nsmgr), MeterHelper.STRING);
					strMeteringPwd = (string)GetPTypeValue(objMeteringServerList[iCount].SelectSingleNode("dbmpns:meteringpwd", nsmgr), MeterHelper.STRING);

					PortNumber iPortNumber = (PortNumber)iPort;
					if (bSecure)
						iSecure = 1;
					objMeter.AddServer(iPriority, strServeraddress, iPortNumber, iSecure, strMeterinGuid, strMeteringPwd);

				}
				objSession = objMeter.CreateSession("metratech.com/login");
				objSession.RequestResponse = true;

				//Initialize the Session properties
				objSession.InitProperty("username", objConfigInfo.strSessionContextUserName);
				objSession.InitProperty("namespace", objConfigInfo.strSessionContextNameSpace);
				objSession.InitProperty("password_", objConfigInfo.strSessionContextPassword);

				// close the session
				objSession.Close();

				//Retrieve the session context from the result session
				strSessionContext = objSession.ResultSession.GetProperty("sessioncontext", DataType.MTC_DT_WCHAR).ToString();
				return strSessionContext;
			}
			catch (Exception exp)
			{
				objLog.LogString(Log.LogLevel.WARNING, "Error while retrieving the Session Context: " + exp.Message);
				objLog.LogString(Log.LogLevel.WARNING, "Security context won't be set for the Metering");
				return null;
			}
			finally
			{
				if (objMeter != null)
					objMeter.Shutdown();
			}

		}



		/// <summary>
		/// Given the name of the xml node (name-value pair), gets the value of the node.
		/// </summary>
		/// <param name="objXmlNode">xml node</param>
		/// <param name="iType">type of the data stored in the xml node</param>
		/// <returns>Object- value of the given node</returns>
		private object GetPTypeValue(XmlNode objXmlNode, int iType)
		{
			object objTypeValue;
			switch (iType)
			{
				case MeterHelper.BOOL:
					objTypeValue = (objXmlNode.InnerText.Trim().ToUpper() == "Y") || (objXmlNode.InnerText.Trim().ToUpper() == "TRUE");
					break;
				case MeterHelper.INT:
					objTypeValue = Convert.ToInt32(objXmlNode.InnerText.Trim());
					break;
				case MeterHelper.DOUBLE:
					objTypeValue = Convert.ToDouble(objXmlNode.InnerText.Trim());
					break;
				case MeterHelper.DATETIME:
					objTypeValue = (DateTime)(StrDate((objXmlNode.InnerText.Trim())));
					break;
				case MeterHelper.STRING:
					objTypeValue = (string)objXmlNode.InnerText.Trim();
					break;
				default:
					objTypeValue = objXmlNode.InnerText.Trim();
					break;
			}
			return objTypeValue;

		}



		/// <summary>
		/// Function used to convert the passed string into DateTime object.
		/// </summary>
		/// <param name="strDate">date in msix firmat</param>
		/// <returns>Date in converted MM/DD/YYYY HH:MM:SS format</returns>
		private DateTime StrDate(string strDate)
		{
			try
			{
				string strNewDate;
				string sYear = new string(strDate.ToCharArray(), 0, 4);
				string sMonth = new string(strDate.ToCharArray(), 5, 2);
				string sDate = new string(strDate.ToCharArray(), 8, 2);
				string sHour = new string(strDate.ToCharArray(), 11, 2);
				string sMinute = new string(strDate.ToCharArray(), 14, 2);
				string sSecond = new string(strDate.ToCharArray(), 17, 2);

				strNewDate = sMonth + "/" + sDate + "/" + sYear + " " + sHour + ":" + sMinute + ":" + sSecond;
				return Convert.ToDateTime(strNewDate);
			}
			catch (Exception ex)
			{
				objLog.LogString(Log.LogLevel.ERROR, "Error in the StrDate (" + strDate + "): " + ex.Message);
				throw;
			}

		}

		/// <summary>
		/// This fucntion reads the settings defined for the error code (retries, sleeptime &
		/// sleep increment). Sets these values in the hashtable. 
		/// </summary>
		/// <param name="errorHandlingNode"></param>
		private void HandleErrorHandlingSettings(XmlNode errorHandlingNode)
		{
			int errorCode, noOfRetries, sleepTime, sleepInc;
			string errorMsg = "";
			XmlNamespaceManager nsmgr = new XmlNamespaceManager(errorHandlingNode.OwnerDocument.NameTable);
			nsmgr.AddNamespace(defaultns, urnname);

			XmlNodeList errorPropsNodelist = errorHandlingNode.SelectNodes("dbmpns:ErrorHandlingProps", nsmgr);
			for (int nodeCount = 0; nodeCount < errorPropsNodelist.Count; nodeCount++)
			{
				errorCode = int.Parse(errorPropsNodelist[nodeCount].SelectSingleNode("dbmpns:ErrorCode", nsmgr).InnerText);
				noOfRetries = int.Parse(errorPropsNodelist[nodeCount].SelectSingleNode("dbmpns:NoOfRetries", nsmgr).InnerText);
				sleepTime = int.Parse(errorPropsNodelist[nodeCount].SelectSingleNode("dbmpns:SleepTime", nsmgr).InnerText);
				sleepInc = int.Parse(errorPropsNodelist[nodeCount].SelectSingleNode("dbmpns:SleepIncrement", nsmgr).InnerText);
				if (noOfRetries < 0 || sleepTime < 0)
				{
					throw new ApplicationException("Invalid values for the ErrorHandling node");
				}
				//Fix for CR #11874. As ErrorMsg tag is optional, the presence of this tag should be checked
				if (errorPropsNodelist[nodeCount].SelectSingleNode("dbmpns:ErrorMsg", nsmgr) != null)
					errorMsg = errorPropsNodelist[nodeCount].SelectSingleNode("dbmpns:ErrorMsg", nsmgr).InnerText;
				ErrorCodeProps errorProps = new ErrorCodeProps(noOfRetries, sleepTime, sleepInc, errorMsg);
				if (!objConfigInfo.errorHandlingProps.ContainsKey(errorCode))
					objConfigInfo.errorHandlingProps.Add(errorCode, errorProps);
				else
				{
					objConfigInfo.errorHandlingProps[errorCode] = errorProps;
				}


			}
		}

		/// <summary>
		/// This function is called to set the default values for the error codes. Currently adding for the
		/// error code -516947930 (MT_SERVER_BUSY_ERROR)
		/// </summary>
		private void SettingTheDefaultValuesForErrors()
		{
			ErrorCodeProps errorProps = new ErrorCodeProps(30, 180, 180, "Waiting for the routinq queue to be emptied");
			if (objConfigInfo.errorHandlingProps == null)
				objConfigInfo.errorHandlingProps = new Hashtable();

			objConfigInfo.errorHandlingProps.Add(MT_ERR_SERVER_BUSY, errorProps);

		}

		/// <summary>
		/// This function is used to validate the xml file from the schema definition
		/// </summary>
		/// <param name="filename"></param>
		/// <param name="xsc"></param>
		private void Validate(String filename, XmlSchemaCollection xsc)
		{
			m_success = true;
			XmlTextReader reader = new XmlTextReader(filename);

			//Create a validating reader.
			XmlValidatingReader vreader = new XmlValidatingReader(reader);

			//Validate using the schemas stored in the schema collection.
			vreader.Schemas.Add(xsc);

			//Set the validation event handler
			vreader.ValidationEventHandler += new ValidationEventHandler(ValidationCallBack);
			//Read and validate the XML data.
			while (vreader.Read()) { }

			//Close the reader.
			vreader.Close();
		}


		/// <summary>
		/// Writing the validation errors on the console as the Log object is still
		/// not created
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="args"></param>
		private void ValidationCallBack(object sender, ValidationEventArgs args)
		{
			m_success = false;
			Console.Write("\r\n\tValidation error: " + args.Message);
		}

		private void CreateTimeZoneInformation(ConfigInfo configInfo)
		{
			System.OperatingSystem osInfo = System.Environment.OSVersion;
			if (osInfo.Platform == System.PlatformID.Win32NT)
			{
				if (osInfo.Version.Major == 5) // Windows 2000 or XP
				{
					if (osInfo.Version.Minor > 0) // Windows XP
					{
						if (configInfo.strLocalTimeZone != null &&
						   configInfo.strLocalTimeZone.Length > 0)
						{
							timeZoneInformation =
							  TimeZoneInformation.FromName(configInfo.strLocalTimeZone);
						}
					}
				}
			}
		}

		public TimeZoneInformation TimeZoneInformation
		{
			get
			{
				return timeZoneInformation;
			}
		}
	}
}

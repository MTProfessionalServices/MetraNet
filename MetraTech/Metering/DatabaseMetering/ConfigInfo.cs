using System;
using System.Data;
using System.Xml;
using System.Collections;
using MetraTech.Interop.COMMeter;


namespace MetraTech.Metering.DatabaseMetering
{
	/// <summary>
	/// This structure stores the configuration information for the DBMP.
	/// </summary>
	public struct ConfigInfo
	{
		/// <summary>
		/// Name of the configuration file.
		/// </summary>
		public string strConfigFileName;
				
		/// <summary>
		/// Stores if there was any network error while metering.
		/// </summary>
		public bool bNetworkError;

		/// <summary>
		/// Constant string. Set to "All".
		/// </summary>
		public const string ALL = "ALL";

		/// <summary>
		/// Constant string. Set to "Flag".
		/// </summary>
		public const string FLAG = "FLAG";

		/// <summary>
		/// Constant string. Set to "Timestamp".
		/// </summary>
		public const string TIMESTAMP = "TIMESTAMP";	
		
		/// <summary>
		/// Constant string. Set to "Sent".
		/// </summary>
		public const string SENT = "Sent";	

		/// <summary>
		/// Constant string. Set to "Not Sent".
		/// </summary>
		public const string NOTSENT = "Failed";		
			
		/// <summary>
		/// Object used for metering the services.
		/// </summary>
		public Meter objMeter;				
		
        /// <summary>
        /// Start time for the metering.
        /// </summary>
		public DateTime dtLastMeteredTime;	
		
		/// <summary>
		/// End time for the metering.
		/// </summary>
		public DateTime dtNextMeteredTime;
		
		/// <summary>
		/// Start time passed as the command line argument.
		/// </summary>
		public DateTime dtStartMeteringTime;		
	
		/// <summary>
		/// End time passed as the command line argument.
		/// </summary>
		public DateTime dtEndMeteringTime;				

		/// <summary>
		/// Type of the Database. Possible values are “MSSQL”, “ORACLE”, “MS EXCEL”).
		/// </summary>
		public string strDBType;
		
		public string Provider;
		/// <summary>
		/// Data Source Name.
		/// </summary>
		public string strDBDataSource;	
		
		/// <summary>
		/// Database username.
		/// </summary>
		public string strDBUsername;	
		
		/// <summary>
		/// Password for the database user.
		/// </summary>
		public string strDBPassword;		

		/// <summary>
		/// Database server.
		/// </summary>
		public string strDBServer;	
		
		/// <summary>
    ///   Append this to the connection string
    /// </summary>
    public string strAppendToConnectionString;
		
		/// <summary>
		/// Name of the database.
		/// </summary>
		public string strDBName;						
		
		/// <summary>
		/// Timeout period for the HTTP request.
		/// </summary>
		public int iHttptimeout;
		
		/// <summary>
		/// Number of HTTP retries.
		/// </summary>
		public int iHttpretries;						
		
		/// <summary>
		/// Stores the list of MetraNet servers.
		/// </summary>
		public ArrayList arrServerList;
		
		/// <summary>
		/// Stores the Local Time Zone.
		/// </summary>
		public string strLocalTimeZone;	
		
		/// <summary>
		/// Number of grace days.	
		/// </summary>
		public int iGraceDays;	
		
		/// <summary>
		/// Stores whether to meter the session using the default values.
		/// </summary>					
		public bool bUseDefaults;
		
		/// <summary>
		/// Stores whether the service is to run in an interactive mode.
		/// </summary>
		public bool bInteractive;	
		
		/// <summary>
		/// Indicates whether continue trying to connect to the server.
		/// </summary>
		public bool bConnectivityRetry;	
		
    /// <summary>
    /// Stores the number of outstanding threads.
    /// </summary>
    public int numberOfOutStandingThreads;	
		
		/// <summary>
		/// Batch criteria for the metering. Possible values are “All”, “Flag” and “Timestamp”.
		/// </summary>
		public string strBatchCriteria;	
		
		/// <summary>
		/// Stores whether to perform local mode processing on network error.
		/// </summary>
		public bool bLocalMode;							
		
		/// <summary>
		/// Local mode file name.
		/// </summary>
		public string strLocalModeFile;		
		
		/// <summary>
		/// Meter journal file name.
		/// </summary>
		public string strMeterJournalFile;				
		
		/// <summary>
		/// SessionContext settings for Auth / Auth.
		/// </summary>
		public string strSessionContextUserName;
		
		/// <summary>
		/// SessionContext settings for Auth / Auth.
		/// </summary>
		public string strSessionContextNameSpace;	
	
		/// <summary>
		/// SessionContext settings for Auth / Auth.
		/// </summary>
		public string strSessionContextPassword;		
	
		/// <summary>
		/// Prefix for the table names.
		/// </summary>
		public string strTablePrefix;	
		
		/// <summary>
		/// Prefix for the table column names.
		/// </summary>
		public string strColumnPrefix;
		
		/// <summary>
		/// SerializedContext string used for performance.
		/// </summary>
		public string strSerializedContext;	
		
		/// <summary>
		/// Stores whether SessionContext is defined.
		/// </summary>
		public bool bSessionContextDefined;				

		/// <summary>
		/// Database locking value.
		/// </summary>
		public string strDBLockTable;					
		
		/// <summary>
		/// List of services to be metered.
		/// </summary>
		public ArrayList arrCollectionServices;
		
		/// <summary>
		/// Indicates whether database connection failed.
		/// </summary>
		public bool bDataSourceConnectFailure;	
		
		/// <summary>
		/// Indicates whether metering time has been passed. 
		/// </summary>
		public bool bMeteringTimePassed;	
		
		/// <summary>
		/// Stores the ErrorHandling properties for the COM error codes returned from the
		/// MetraNet server
		/// </summary>
		public Hashtable errorHandlingProps;
		
		/// <summary>
		/// Used to set whether the data retrieval to be done in connected/disconnected mode.
		/// </summary>
		public bool isConnectedMode;
		
		/// <summary>
		/// value for the Command Timeout
		/// </summary>
		public static int commandTimeout = 600;

		public int statusUpdateMode;
		public string suffixforstatustable;
		public string updatetablename;
		
		/// <summary>
		/// Indicates whether batch information has been passed. 
		/// </summary>
		public bool bBatchInfoPassed;	

		/// <summary>
		/// Name of batch to meter
		/// </summary>
		public string strBatchName;					

		/// <summary>
		/// Namespace of batch to meter
		/// </summary>
		public string strBatchNameSpace;

    public string GetOracleConnectionString()
    {
      return "Data Source=" + strDBServer + ";User Id=" + strDBUsername + ";Password=" + strDBPassword + ";Pooling=false;";
    }
	}

	/// <summary>
	/// This structure is used to store the properties of the server.
	/// </summary>
	public struct MTServer
	{
		/// <summary>
		/// Server address.
		/// </summary>
		public string strServeraddress;	

		/// <summary>
		/// Port on which metering server listens on.
		/// </summary>
		public int iPort;
	
		/// <summary>
		/// Priority of the metering server.
		/// </summary>					
		public int iPriority;

		/// <summary>
		/// Whether it is a secure connection or not.
		/// </summary>				
		public bool bSecure;

		/// <summary>
		/// User id to connect to the metering server.
		/// </summary>			
		public string strMeterinGuid;

		/// <summary>
		/// User id to connect to the metering server.
		/// </summary>
		public string strMeteringPwd;

		/// <summary>
		/// Debug level of the SDK.
		/// </summary>
		public int iSdkdebuglevel;

		/// <summary>
		/// Transmitting interval.
		/// </summary>		
		public int iTransmitInterval;			
		
    }

	/// <summary>
	/// This structure is used to store the service properties.
	/// </summary>
	public struct PropType
	{
		/// <summary>
		/// Name of the property.
		/// </summary>
		public string strPropName;	
					
		/// <summary>
		/// Type of the property.
		/// </summary>
		public string strPropType;	
					
		/// <summary>
		/// Default value of the property.
		/// </summary>
		public string strPropDefault;

		public int propLength;
	}

	/// <summary>
	/// Structure is used to store the metring statistics (max/min/avg session sets in a batch,
	///  min/max/avg compounds in a session set, min/max/avg sessions for the compound)
	/// </summary>
	public struct SavingTheStatistics
	{
		public int totalValue;
		public int minValue;
		public int maxValue;
		public SavingTheStatistics(int totalVal, int minVal, int maxVal )
		{
			totalValue = totalVal;
			minValue = minVal;
			maxValue = maxVal;
		}
	}
	
	/// <summary>
	/// Structure is used to store the properties for the COM error codes (specified in the config file)
	/// </summary>
	public struct ErrorCodeProps
	{
		public int noOfretries;
		public int sleepTime;
		public int sleepIncrement;
		public string errorMsg;
		public ErrorCodeProps(int retries, int sleeptime, int sleepinc, string errmsg )
		{
			this.noOfretries = retries;
			this.sleepTime = sleeptime;
			this.sleepIncrement = sleepinc;
			this.errorMsg = errmsg;
		}
	}
}

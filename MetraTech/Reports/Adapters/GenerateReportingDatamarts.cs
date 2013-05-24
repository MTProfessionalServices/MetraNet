using System;
using System.Collections.Generic;
using System.Xml;
using System.Diagnostics;
using System.IO;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.DataAccess.QueryManagement.Business.Logic;
using MetraTech.Interop.MTServerAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using System.Collections;
using System.Net;
using PCExec = MetraTech.Interop.MTProductCatalogExec;

namespace MetraTech.Reports.Adapters
{
  /// <summary>
  /// Generate Reporting Datamarts Adapter, used to generate and/or populate datamarts for reporting at EOP.
  /// </summary>
  public class GenerateReportingDatamartsAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    // adapter capabilities
    public bool SupportsScheduledEvents { get { return true; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
    public bool AllowMultipleInstances { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
    public bool HasBillingGroupConstraints { get { return false; } }
    public BillingGroupSupportType BillingGroupSupport { get { return mReportType; } }

    // data
    private Logger mLogger = new Logger("[GenerateReportingDatamartsAdapter]");

    private string mConfigFile;
    private string mPopulateQueryFile;
    private System.Collections.Generic.List<MetraFlowScript> mPopulateMetraFlowScripts;
    private string mGenerateSchemaQueryFile;
    private string mReverseAdapterQueryFile;
    private string mSplitReverseAdapterQueryFile;
    private string mPopulateQueryPath;
    private string mGenerateSchemaQueryPath;
    private string mReverseAdapterQueryPath;
    private string mSplitReverseAdapterQueryPath;	
	  private bool   mUseSplitReverseClassicImpl;
    private string mDBFilePath;
    private int mDBSize;
    private BillingGroupSupportType mReportType;
    // Temporary directory to be used by MetraFlow programs
    private string mTempDir;
    // Configuration information for MetraFlow execution
    MetraFlowConfig mMetraFlowConfig;

    private ArrayList mGenerateSchemaQueryList = new ArrayList();
    private ArrayList mPopulateQueryList = new ArrayList();
    private ArrayList mReverseAdapterQueryList = new ArrayList();
    private ArrayList mSplitReverseAdapterQueryList = new ArrayList();

    private List<string> mGenerateSchemaQueryTagList = new List<string>();
    private List<string> mPopulateQueryTagList = new List<string>();
    private List<string> mReverseAdapterQueryTagList = new List<string>();
    private List<string> mSplitReverseAdapterQueryTagList = new List<string>();

    private bool mCreateNewDatabaseEachTime;
    private bool mIsOracle;
    private bool mIsQMEnabled;

    private string mDatabaseName;
    private string mProductDatabaseName;
    // g. cieplik 10/01/05 CR15925
    private string mStatement;

    public GenerateReportingDatamartsAdapter()
    {
      // Is ReportingDBServer Oracle? 
      ConnectionInfo connInfo = new ConnectionInfo("ReportingDBServer");
      mIsOracle = connInfo.IsOracle;
      mLogger.LogDebug("GenerateReportingDatamarts IsOracle: {0}", mIsOracle.ToString());

      // For now we assume that NetMeter and ReportingDBServer will be the same database type.  Let's make sure.
      connInfo = new ConnectionInfo("NetMeter");
      bool isNetMeterOracle = connInfo.IsOracle;
      if (mIsOracle != isNetMeterOracle)
      {
        throw new UnsupportedConfigurationException("Both NetMeter and the ReportingDBServer must be the same database type.");
      }
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      mLogger.LogDebug("Initializing GenerateReportingDatamarts Adapter");
      mLogger.LogDebug("Using config file: {0}", configFile);

      mConfigFile = configFile;

      mLogger.LogDebug(mConfigFile);
      if (limitedInit)
        mLogger.LogDebug("Limited initialization requested");
      else
        mLogger.LogDebug("Full initialization requested");

      MTServerAccessDataSet sa = new MTServerAccessDataSetClass();
      sa.Initialize();
      MTServerAccessData sad = sa.FindAndReturnObject("NetMeter");
      mProductDatabaseName = sad.DatabaseName;
      sa.Initialize();

      // Check Query Management Enabled or not? 
      QueryMapper qm = new QueryMapper();
      mIsQMEnabled = qm.Enabled;

      // Read reporting config (throws to adapter framework on exception)
      ReadConfigFile(configFile);

      // Get extenstion path
      string ExtensionPath;
      mConfigFile = mConfigFile.ToUpper();
      int pos = mConfigFile.IndexOf("USAGESERVER");
      ExtensionPath = mConfigFile.Substring(0, pos);

      if (mIsQMEnabled)
      {
        // Manually load query files for V2
        if (mGenerateSchemaQueryPath != String.Empty)
        {
          mGenerateSchemaQueryPath = string.Concat(ExtensionPath, mGenerateSchemaQueryPath);
          ReadBatchQueryTags(mGenerateSchemaQueryPath, ref mGenerateSchemaQueryTagList);
        }

        if (mPopulateQueryPath != String.Empty)
        {
          mPopulateQueryPath = string.Concat(ExtensionPath, mPopulateQueryPath);
          ReadBatchQueryTags(mPopulateQueryPath, ref mPopulateQueryTagList);
        }

        if (mReverseAdapterQueryPath != String.Empty)
        {
          mReverseAdapterQueryPath = string.Concat(ExtensionPath, mReverseAdapterQueryPath);
          ReadBatchQueryTags(mReverseAdapterQueryPath, ref mReverseAdapterQueryTagList);
        }

        if (mSplitReverseAdapterQueryPath != String.Empty)
        {
          mSplitReverseAdapterQueryPath = string.Concat(ExtensionPath, mSplitReverseAdapterQueryPath);
          if (File.Exists(mSplitReverseAdapterQueryPath))
          {
            mUseSplitReverseClassicImpl = false;
            ReadBatchQueryTags(mSplitReverseAdapterQueryPath, ref mSplitReverseAdapterQueryTagList);
          }
          else
          {
            mUseSplitReverseClassicImpl = true;
            mLogger.LogWarning(
              "Split reverse functionality not present, consider implementing SplitReverseAdapterQueryPath");
          }
        }
      }
      else
      {
        // Manually load query files for V1
        if (mGenerateSchemaQueryFile != String.Empty)
        {
          mGenerateSchemaQueryFile = string.Concat(ExtensionPath, mGenerateSchemaQueryFile);
          ReadQueryFile(mGenerateSchemaQueryFile, ref mGenerateSchemaQueryList);
        }

        if (mPopulateQueryFile != String.Empty)
        {
          mPopulateQueryFile = string.Concat(ExtensionPath, mPopulateQueryFile);
          ReadQueryFile(mPopulateQueryFile, ref mPopulateQueryList);
        }

        if (mReverseAdapterQueryFile != String.Empty)
        {
          mReverseAdapterQueryFile = string.Concat(ExtensionPath, mReverseAdapterQueryFile);
          ReadQueryFile(mReverseAdapterQueryFile, ref mReverseAdapterQueryList);
        }

        if (mSplitReverseAdapterQueryFile != String.Empty)
        {
          mSplitReverseAdapterQueryFile = string.Concat(ExtensionPath, mSplitReverseAdapterQueryFile);
          if (File.Exists(mSplitReverseAdapterQueryFile))
          {
            mUseSplitReverseClassicImpl = false;
            ReadQueryFile(mSplitReverseAdapterQueryFile, ref mSplitReverseAdapterQueryList);
          }
          else
          {
            mUseSplitReverseClassicImpl = true;
            mLogger.LogWarning(
              "Split reverse functionality not present, consider implementing SplitReverseAdapterQueryFile");
          }
        }
      }

      mLogger.LogDebug("Initialize successful");
    }

    public string Execute(IRecurringEventRunContext param)
    {
      bool bDatabaseCreated = false;
      string info;
      string detail;

      mLogger.LogDebug("Executing GenerateReportingDatamarts Adapter");

      mLogger.LogDebug("Event type = {0}", param.EventType);
      mLogger.LogDebug("Run ID = {0}", param.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
      mLogger.LogDebug("Billing group ID = {0}", param.BillingGroupID);

      mDatabaseName = ReportConfiguration.GetInstance().GenerateDatabaseName(param);
      mCreateNewDatabaseEachTime = ReportConfiguration.GetInstance().GenerateDBEveryTime;

      if ((param.EventType == RecurringEventType.Scheduled) &&
        mCreateNewDatabaseEachTime)
      {
        param.RecordWarning("Unsupported configuration. Cannot run this adapter in scheduled mode with the configuration setting of GenerateDBEveryTime");
        UnsupportedConfigurationException e = new UnsupportedConfigurationException("Scheduled mode with the configuration setting of GenerateDBEveryTime is not supported");
        throw (e);
      }

      param.RecordInfo("Generating Datamarts ... ");

      // Is the datamart in Netmeter?
      bool bUsingNetmeterDatabase = (mDatabaseName.ToUpper() == mProductDatabaseName.ToUpper()) ? true : false;

      // Need to execute all the queries specified in the query file
      // todo: pass in the path of a extensionized dbaccess.xml (relative to the extensions folder
      // modify the connectioninfo object to accept this file for timeout and logical server name.
      // override the server, catalog (perhaps username and password) properties of the connection info
      // object if using the option of creating new database each time the adapter is run.
      ConnectionInfo ciReportingDBServer = new ConnectionInfo("ReportingDBServer");
      if (mCreateNewDatabaseEachTime)
      {
        //create the reporting database for each interval case
        mLogger.LogDebug("Generate New Database with name: {0}", mDatabaseName);
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateReportingDB"))
            {
                stmt.AddParam("@strDBName", MTParameterType.WideString, mDatabaseName);
                if (mIsOracle)
                {
                    stmt.AddParam("@strPassword", MTParameterType.WideString, ciReportingDBServer.Password);
                }
                stmt.AddParam("@strNetmeterDBName", MTParameterType.WideString, mProductDatabaseName);
                stmt.AddParam("@strDataLogFilePath", MTParameterType.WideString, mDBFilePath);
                stmt.AddParam("@dbSize", MTParameterType.Integer, mDBSize);
                stmt.AddOutputParam("@return_code", MTParameterType.Integer);
                stmt.ExecuteNonQuery();
                int returncode = (int)stmt.GetOutputValue("@return_code");
                if (returncode == -1)
                    throw new ApplicationException("Could not create the Reporting Datamart Database");
                // the database is created by nmdbo, so nmdbo is the owner; except in Oracle
                bDatabaseCreated = true;
            }
        }

        info = String.Format("Created new database {0}", mDatabaseName);
        mLogger.LogDebug(info);
        param.RecordInfo(info); ;
      }
      else if (bUsingNetmeterDatabase == false)
      {
        // NetMeterReporting case, the database will have to be created only once
        bool bAlreadyExists = false;
        mLogger.LogDebug("Using database: {0}", mDatabaseName);
        try
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateReportingDB"))
                {
                    stmt.AddParam("@strDBName", MTParameterType.WideString, mDatabaseName);
                    if (mIsOracle)
                    {
                        stmt.AddParam("@strPassword", MTParameterType.WideString, ciReportingDBServer.Password);
                    }
                    stmt.AddParam("@strNetmeterDBName", MTParameterType.WideString, mProductDatabaseName);
                    stmt.AddParam("@strDataLogFilePath", MTParameterType.WideString, mDBFilePath);
                    stmt.AddParam("@dbSize", MTParameterType.Integer, mDBSize);
                    stmt.AddOutputParam("@return_code", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();

                    int returncode = (int)stmt.GetOutputValue("@return_code");
                    if (returncode == -1)
                        throw new ApplicationException("Could not create the Reporting Datamart Database.");
                    //the database is created by nmdbo, so nmdbo is the owner; except in Oracle
                    bDatabaseCreated = true;
                }
            }

          info = String.Format("Created reporting database the first time, {0}", mDatabaseName);
          mLogger.LogDebug(info);
          param.RecordInfo(info);
        }
        catch (System.Data.OleDb.OleDbException e)
        {
          if ((e.Errors.Count > 0) && (e.Errors[0].NativeError == 1801))
            bAlreadyExists = true;
          else
          {
            mLogger.LogError(e.ToString());
            throw e;
          }
        }
        catch (Exception e)
        {
          if (!mIsOracle ||
              (mIsOracle && e.Message.IndexOf("ORA-01543: tablespace '" + mDatabaseName.ToUpper() + "' already exists") == -1))
          {
            mLogger.LogError(e.ToString());
            throw e;
          }
          else
            bAlreadyExists = true;
        }

        if (bAlreadyExists)
        {
          mLogger.LogInfo("Reporting database has already been created");
          info = String.Format("Reporting database, {0}, already exists.", mDatabaseName);
          param.RecordInfo(info);
        }
      }
      else
      {
        // NetMeter case -- the schema generation queries should use If Exists predicate.
      }

      ConnectionInfo connInfo = GetReportingDBServerConnectionInfo(param, bUsingNetmeterDatabase);

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(connInfo))
        {
          // Call the queries to generate schema
          mLogger.LogDebug("Generating Schema in database {0}", mDatabaseName);
          // g. cieplik 10/1/2008 CR15925 log Timeout info
          mLogger.LogDebug("DatabaseTimeout {0}", conn.ConnectionInfo.Timeout);

          if (mIsQMEnabled)
          {
            foreach (string queryTag in mGenerateSchemaQueryTagList)
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
              {
                info = String.Format("Preparing to execute query tag: {0}", queryTag);
                mLogger.LogInfo(info);
                param.RecordInfo(info);

                stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", mDatabaseName);
                stmt.AddParamIfFound("%%MAIN_NETMETER_DB_NAME%%", mProductDatabaseName);
                stmt.ExecuteNonQuery();
              }
            }
          }
          else
          {
            for (int i = 0; i < mGenerateSchemaQueryList.Count; i++)
            {
              string statement = mGenerateSchemaQueryList[i].ToString();
              statement = statement.Replace("%%NETMETER_DB_NAME%%", mDatabaseName);
              statement = statement.Replace("%%MAIN_NETMETER_DB_NAME%%", mProductDatabaseName);
              // g. cieplik 10/1/2008 CR15925 get the sql statement for logging
              mStatement = statement;

              using (IMTStatement stmt = conn.CreateStatement(statement))
              {
                stmt.ExecuteNonQuery();
              }
            }
          }

          info = String.Format("Created schema successfully in  {0}", mDatabaseName);
          param.RecordInfo(info);

          // Call the queries in the mPopulateQueryList one at a time.
          mLogger.LogDebug("Populating datamart in database {0}", mDatabaseName);

          if (mIsQMEnabled)
          {
            foreach (string queryTag in mPopulateQueryTagList)
            {

              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
              {
                info = String.Format("Preparing to execute query tag: {0}", queryTag);
                mLogger.LogInfo(info);
                param.RecordInfo(info);

                stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", mProductDatabaseName);
                stmt.AddParamIfFound("%%NETMETER_REPORTING_DB_NAME%%", mDatabaseName);

                if (param.EventType == RecurringEventType.EndOfPeriod)
                {
                  if (mReportType == BillingGroupSupportType.Account ||
                      mReportType == BillingGroupSupportType.BillingGroup)
                    stmt.AddParam("%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
                  else
                    stmt.AddParam("%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
                }
                else if (param.EventType == RecurringEventType.Scheduled)
                {
                  stmt.AddParam("%%STARTDATE%%", ToDBString(param.StartDate));
                }

                stmt.AddParamIfFound("%%ID_RUN%%", param.RunID.ToString());
                stmt.ExecuteNonQuery();
              }
            }
          }
          else
          {
            for (int i = 0; i < mPopulateQueryList.Count; i++)
            {
              string statement = mPopulateQueryList[i].ToString();

              statement = statement.Replace("%%NETMETER_DB_NAME%%", mProductDatabaseName);
              statement = statement.Replace("%%NETMETER_REPORTING_DB_NAME%%", mDatabaseName);
              if (param.EventType == RecurringEventType.EndOfPeriod)
              {
                if (mReportType == BillingGroupSupportType.Account ||
                    mReportType == BillingGroupSupportType.BillingGroup)
                  statement = statement.Replace("%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
                else
                  statement = statement.Replace("%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
              }
              else if (param.EventType == RecurringEventType.Scheduled)
              {
                statement = statement.Replace("%%STARTDATE%%", ToDBString(param.StartDate));
              }

              statement = statement.Replace("%%ID_RUN%%", param.RunID.ToString());
              // g. cieplik  10/1/2008 CR15925 get the sql statement for logging
              mStatement = statement;

              using (IMTStatement stmt = conn.CreateStatement(statement))
              {
                stmt.ExecuteNonQuery();
              }
            }
          }

          // In the case of SQL check for the partitioning state.  We have generally seen
          // that we are best off forcing a table scan in SQL server.  To get the table
          // hint to work, we also have to specify the partition and avoid the view.
          // Really this kind of logic needs to be put into an operator that understands
          // partitioned tables.  Note that we need a generalization that can do the same for multiple
          // partitions (one at a time).
          string tableHint = "";
          string partitionPrefix = "";
          if (mPopulateMetraFlowScripts.Count > 0 &&
              param.EventType == RecurringEventType.EndOfPeriod)
          {
            if(new ConnectionInfo("NetMeter").IsSqlServer)
            {
              using (IMTServicedConnection netMeterConn = ConnectionManager.CreateConnection())
              {
                using(IMTStatement stmt = 
                      netMeterConn.CreateStatement(string.Format("select partition_name from t_partition where id_interval_start <= {0} and id_interval_end >= {0}", param.UsageIntervalID)))
                {
                  using(IMTDataReader reader = stmt.ExecuteReader())
                  {
                    if (reader.Read())
                    {
                      partitionPrefix = reader.GetString("partition_name");
                      partitionPrefix += "..";
                      tableHint = "with(index(pk_t_acc_usage))";
                    }
                  }
                }
              }
            }
          }
          foreach(MetraFlowScript mfs in mPopulateMetraFlowScripts)
          {
            mfs.SetString("NETMETER_DB_NAME", mProductDatabaseName);
            mfs.SetString("NETMETER_REPORTING_DB_NAME", mDatabaseName);
            mfs.SetString("PARTITION_PREFIX", partitionPrefix);
            mfs.SetString("USAGE_TABLE_HINT", tableHint);
            if (param.EventType == RecurringEventType.EndOfPeriod)
            {
              mfs.SetInt32("ID_INTERVAL", param.UsageIntervalID);
              if (mReportType == BillingGroupSupportType.Account ||
                  mReportType == BillingGroupSupportType.BillingGroup)
              {
                mfs.SetInt32("ID_BILLGROUP", param.BillingGroupID);
              }
            }
            else if (param.EventType == RecurringEventType.Scheduled)
            {
              mfs.SetDateTime("STARTDATE", param.StartDate);
            }
            mfs.SetString("TEMP_DIR", mTempDir);

            mfs.Run("[GenerateReportingDatamartsAdapter]", param, mMetraFlowConfig);
          }
          info = String.Format("Populated datamarts successfully in {0}", mDatabaseName);
          param.RecordInfo(info);
          detail = String.Format("Datamarts generation successful and complete.");
        }
      }
      catch (Exception e)
      {
        mLogger.LogWarning(e.ToString());
        mLogger.LogDebug("Sql statement throwing error {0}", mStatement);
        // For Oracle the database creation is commited, so we we need to drop on error.
        // Otherwise, this code will fail next time we run if for same interval and billgroup.
        if (bDatabaseCreated)
        {
          // Get the database name and drop it
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              try
              {
                  using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\Reporting", "__DROP_REPORTING_DB__"))
                  {

                      stmt.AddParam("%%REPORTING_DB_NAME%%", mDatabaseName);
                      stmt.AddParam("%%NETMETER_DB_NAME%%", mProductDatabaseName);
                      stmt.ExecuteNonQuery();
                      info = String.Format("Dropped database and removed from backup queue {0}", mDatabaseName);
                      param.RecordInfo(info);
                  }
              }
              catch (Exception e2)
              {
                  mLogger.LogError(e2.ToString());
              }
          }
        }

        // Rethrow exception.
        throw e;
      }
      return detail;
    }

    /// <summary>
    /// All queries now have to be run on the reporting database, so get the connection info for ReportingDBServer
    /// </summary>
    /// <param name="param"></param>
    /// <param name="bUsingNetmeterDatabase"></param>
    /// <returns></returns>
    private ConnectionInfo GetReportingDBServerConnectionInfo(IRecurringEventRunContext param, bool bUsingNetmeterDatabase)
    {
      ConnectionInfo connInfo = new ConnectionInfo("ReportingDBServer");
      connInfo.Catalog = mDatabaseName;
      string info = String.Format("Using reporting database {0}.  Using netmeter database = {1}.  IsOracle = {2}",
                                   mDatabaseName,
                                   bUsingNetmeterDatabase.ToString(),
                                   mIsOracle.ToString());
      if (param != null)
      {
        param.RecordInfo(info);
      }
      if (mIsOracle)
      {
        if (mCreateNewDatabaseEachTime || bUsingNetmeterDatabase == false)
        {
          // For Oracle the CreateReportingDB stored procedure uses databasename as username.
          connInfo.UserName = mDatabaseName;
        }
      }
      else // For MSSQL server reolve the db server name.
      {
        if (param != null)
        {
          ResolveServerNameParam(param, ref connInfo);
        }
        else
        {
          ResolveServerName(ref connInfo);
        }
      }
      // g. cieplik 10/1/2008 CR15925 get the "ReportingDBServer" timeout info for logging
      mLogger.LogDebug("GetReportingDBServerConnectionInfo.Timeout {0}", connInfo.Timeout);
      return connInfo;
    }

    private static string ToDBString(DateTime val)
    {
      // {ts 'yyyy-mm-dd hh:mm:ss'}
      return String.Format("{{ts '{0}'}}", val.ToString("yyyy-MM-dd HH:mm:ss.fff"));
    }

    public string Reverse(IRecurringEventRunContext param)
    {
      string info;
      mLogger.LogDebug("Reversing GenerateReportingDatamarts Adapter");
      mLogger.LogDebug("Event type = {0}", param.EventType);
      mLogger.LogDebug("Run ID = {0}", param.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
      mLogger.LogDebug("Billing group ID = {0}", param.BillingGroupID);

      mDatabaseName = ReportConfiguration.GetInstance().GenerateDatabaseName(param);
      mCreateNewDatabaseEachTime = ReportConfiguration.GetInstance().GenerateDBEveryTime;

      if (mCreateNewDatabaseEachTime)
      {
        // Get the database name and drop it
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            try
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\Reporting", "__DROP_REPORTING_DB__"))
                {

                    stmt.AddParam("%%REPORTING_DB_NAME%%", mDatabaseName);
                    stmt.AddParam("%%NETMETER_DB_NAME%%", mProductDatabaseName);
                    stmt.ExecuteNonQuery();
                    info = String.Format("Dropped database and removed from backup queue {0}", mDatabaseName);
                    param.RecordInfo(info);
                }
            }
            catch (System.Data.OleDb.OleDbException e)
            {
                // Check for the error that the db does not exist... in this case mark reverse successful
                if ((e.Errors.Count > 0) && (e.Errors[0].NativeError == 3701))
                {
                    mLogger.LogInfo("Reporting database did not exist, marking reverse successful");
                    info = String.Format("Reporting Database {0} did not exist, marking reverse successful",
                      mDatabaseName);
                    param.RecordInfo(info);
                }
                else
                {
                    mLogger.LogError(e.ToString());
                    throw e;
                }
            }
            catch (Exception exp)
            {
                mLogger.LogError(exp.ToString());
                throw exp;
            }
        }
      }
      else
      {
        // Is the datamart in Netmeter?
        bool bUsingNetmeterDatabase = (mDatabaseName.ToUpper() == mProductDatabaseName.ToUpper()) ? true : false;
        ConnectionInfo connInfo = GetReportingDBServerConnectionInfo(param, bUsingNetmeterDatabase);

        // Check if database exists.
        if (DoesDatabaseExist() == false)
        {
          string detail2 = "Reporting database not found, there is nothing reverse.";
          mLogger.LogDebug(detail2);
          param.RecordInfo(detail2);
          return detail2;
        }

        try
        {
          // If the reporting database does not exist.. this fails. so add a check for it.
          using (IMTConnection conn = ConnectionManager.CreateConnection(connInfo))
          {
            if (mIsQMEnabled)
            {
              // Call the queries in the mReverseAdapterQueryTagList one at a time.
              foreach (string queryTag in mReverseAdapterQueryTagList)
              {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
                {
                  info = String.Format("Preparing to execute query tag: {0}", queryTag);
                  mLogger.LogInfo(info);
                  param.RecordInfo(info);

                  stmt.AddParamIfFound("%%NETMETER_REPORTING_DB_NAME%%", mDatabaseName);
                  stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", mProductDatabaseName);

                  if (param.EventType == RecurringEventType.EndOfPeriod)
                  {
                    if (mReportType == BillingGroupSupportType.Account ||
                        mReportType == BillingGroupSupportType.BillingGroup)
                      stmt.AddParam("%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
                    else
                      stmt.AddParam("%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
                  }
                  else if (param.EventType == RecurringEventType.Scheduled)
                  {
                    stmt.AddParam("%%STARTDATE%%", ToDBString(param.StartDate));
                    stmt.AddParam("%%ENDDATE%%", ToDBString(param.EndDate));
                  }
                  stmt.AddParamIfFound("%%ID_RUN%%", param.RunID.ToString());

                  stmt.ExecuteNonQuery();
                }
              }
            }
            else
            {
              // Call the queries in the mReverseAdapterQueryList one at a time.
              for (int i = 0; i < mReverseAdapterQueryList.Count; i++)
              {
                string statement = mReverseAdapterQueryList[i].ToString();
                statement = statement.Replace("%%NETMETER_REPORTING_DB_NAME%%", mDatabaseName);
                statement = statement.Replace("%%NETMETER_DB_NAME%%", mProductDatabaseName);
                if (param.EventType == RecurringEventType.EndOfPeriod)
                {
                  if (mReportType == BillingGroupSupportType.Account ||
                      mReportType == BillingGroupSupportType.BillingGroup)
                    statement = statement.Replace("%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
                  else
                    statement = statement.Replace("%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
                }
                else if (param.EventType == RecurringEventType.Scheduled)
                {
                  statement = statement.Replace("%%STARTDATE%%", ToDBString(param.StartDate));
                  statement = statement.Replace("%%ENDDATE%%", ToDBString(param.EndDate));
                }
                statement = statement.Replace("%%ID_RUN%%", param.RunID.ToString());

                using (IMTStatement stmt = conn.CreateStatement(statement))
                {
                  stmt.ExecuteNonQuery();
                }
              }
            }
          }
        }
        catch (System.Data.OleDb.OleDbException e)
        {
          if ((e.Errors.Count > 0) && (e.Errors[0].NativeError == 4060))
          {
            mLogger.LogInfo("Reporting database was not created");
            info = String.Format("Reporting database, {0}, did not exist. Marking reverse successful", mDatabaseName);
            param.RecordInfo(info);
          }
          else
          {
            mLogger.LogError(e.ToString());
            throw e;
          }
        }
        catch (Exception exp)
        {
          mLogger.LogError(exp.ToString());
          throw exp;
        }
      }

      return "Datamarts reversed.";
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down GenerateReportingDatamarts Adapter");
    }

    public void SplitReverseState(int parentRunID,
                    int parentBillingGroupID,
                    int childRunID,
                    int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of GenerateReportingDatamarts Adapter");

      // We only need to split the generated database for Account granularity.
      if (mReportType != BillingGroupSupportType.Account)
        return;

      mLogger.LogDebug("Parent Run ID = {0}", parentRunID);
      mLogger.LogDebug("Parent Billing group ID = {0}", parentBillingGroupID);
      mLogger.LogDebug("Child Run ID = {0}", childRunID);
      mLogger.LogDebug("Child Billing group ID = {0}", childBillingGroupID);

      mCreateNewDatabaseEachTime = ReportConfiguration.GetInstance().GenerateDBEveryTime;

      if (mUseSplitReverseClassicImpl)
        SplitReverseState_v1(parentRunID, parentBillingGroupID, childRunID, childBillingGroupID);
      else
        SplitReverseState_v2(parentRunID, parentBillingGroupID, childRunID, childBillingGroupID);

      mLogger.LogDebug("Datamarts generation successful and complete.");
    }

    private void SplitReverseState_v1(int parentRunID,
                    int parentBillingGroupID,
                    int childRunID,
                    int childBillingGroupID)
    {
      string info;

      // Database to update.
        string oldDatabaseName = (true == mCreateNewDatabaseEachTime) 
            ? ReportConfiguration.GetInstance().GenerateBillingGroupDatabaseName(parentBillingGroupID)
            : ReportConfiguration.GetInstance().DatabasePrefix;

      // All queries now have to be run on the reporting database
      // Is the datamart in Netmeter?
      bool bUsingNetmeterDatabase = (oldDatabaseName.ToUpper() == mProductDatabaseName.ToUpper()) ? true : false;
      ConnectionInfo connInfo = GetReportingDBServerConnectionInfo(null, bUsingNetmeterDatabase);
      connInfo.Catalog = oldDatabaseName;
      mLogger.LogDebug(string.Format("Using database {0} for reversing.", oldDatabaseName));

      try
      {
        // Remove accounts that are part of the new billing group from 
        // the old database.
        using (IMTConnection conn = ConnectionManager.CreateConnection(connInfo))
        {
          if (mIsQMEnabled)
          {
            // Call the queries in the mReverseAdapterQueryTagList one at a time.
            foreach (string queryTag in mReverseAdapterQueryTagList)
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
              {
                info = String.Format("Preparing to execute query tag: {0}", queryTag);
                mLogger.LogInfo(info);

                stmt.AddParamIfFound("%%NETMETER_REPORTING_DB_NAME%%", oldDatabaseName);
                stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", mProductDatabaseName);
                stmt.AddParamIfFound("%%ID_BILLGROUP%%", childBillingGroupID.ToString());
                stmt.AddParamIfFound("%%ID_RUN%%", childRunID.ToString());

                stmt.ExecuteNonQuery();
              }
            }
          }
          else
          {
            // Call the queries in the mReverseAdapterQueryList one at a time.
            for (int i = 0; i < mReverseAdapterQueryList.Count; i++)
            {
              string statement = mReverseAdapterQueryList[i].ToString();
              statement = statement.Replace("%%NETMETER_REPORTING_DB_NAME%%", oldDatabaseName);
              statement = statement.Replace("%%NETMETER_DB_NAME%%", mProductDatabaseName);
              statement = statement.Replace("%%ID_BILLGROUP%%", childBillingGroupID.ToString());
              statement = statement.Replace("%%ID_RUN%%", childRunID.ToString());
              using (IMTStatement stmt = conn.CreateStatement(statement))
              {
                stmt.ExecuteNonQuery();
              }
            }
          }
        }
      }
      catch (System.Data.OleDb.OleDbException e)
      {
        // Report error
        if ((e.Errors.Count > 0) && (e.Errors[0].NativeError == 4060))
        {
          mLogger.LogInfo("Reporting database was not created");
          mLogger.LogDebug(string.Format("Reporting database, {0}, did not exist. Marking reverse successful", oldDatabaseName));
        }
        else
        {
          mLogger.LogError(e.ToString());
          throw e;
        }
      }


      string newDatabaseName = CreateDataBase(childBillingGroupID);
      GenerateSchema(connInfo, newDatabaseName);

      connInfo.Catalog = newDatabaseName;
      using (IMTConnection conn = ConnectionManager.CreateConnection(connInfo))
      {
        if (mIsQMEnabled)
        {
          // Call the queries in the mPopulateQueryTagList one at a time.
          mLogger.LogDebug("Populating datamart in database {0}", newDatabaseName);

          foreach (string queryTag in mPopulateQueryTagList)
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
            {
              info = String.Format("Preparing to execute query tag: {0}", queryTag);
              mLogger.LogInfo(info);

              stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", mProductDatabaseName);
              stmt.AddParamIfFound("%%NETMETER_REPORTING_DB_NAME%%", newDatabaseName);
              stmt.AddParamIfFound("%%ID_BILLGROUP%%", childBillingGroupID.ToString());
              stmt.AddParamIfFound("%%ID_RUN%%", childRunID.ToString());

              stmt.ExecuteNonQuery();
            }
          }
        }
        else
        {

          // Call the queries in the mPopulateQueryList one at a time.
          mLogger.LogDebug("Populating datamart in database {0}", newDatabaseName);
          for (int i = 0; i < mPopulateQueryList.Count; i++)
          {
            string statement = mPopulateQueryList[i].ToString();
            statement = statement.Replace("%%NETMETER_DB_NAME%%", mProductDatabaseName);
            statement = statement.Replace("%%NETMETER_REPORTING_DB_NAME%%", newDatabaseName);
            statement = statement.Replace("%%ID_BILLGROUP%%", childBillingGroupID.ToString());
            statement = statement.Replace("%%ID_RUN%%", childRunID.ToString());
            using (IMTStatement stmt = conn.CreateStatement(statement))
            {
              stmt.ExecuteNonQuery();
            }
          }
        }
      }

      mLogger.LogDebug("Populated datamarts successfully in {0}", newDatabaseName);
            }

    private void SplitReverseState_v2(int parentRunID,
                    int parentBillingGroupID,
                    int childRunID,
                    int childBillingGroupID)
    {
      // If we are creating a new DB every time
      //   generate new database
      //   generate new schema
      //       
      // Run split query file passing in the following query tags:
      //   %%NETMETER_DB_NAME%% 
      //   %%PARENT_DB_NAME%%
      //   %%PARENT_ID_BILLGROUP%%
      //   %%PARENT_ID_RUN%%
      //   %%CHILD_DB_NAME%%
      //   %%CHILD_ID_BILLGROUP%%
      //   %%CHILD_ID_RUN%%

      // Database to update.

      // Database to update.
        string oldDatabaseName = (true == mCreateNewDatabaseEachTime) 
            ? ReportConfiguration.GetInstance().GenerateBillingGroupDatabaseName(parentBillingGroupID)
            : ReportConfiguration.GetInstance().DatabasePrefix;

      // All queries now have to be run on the reporting database
      // Is the datamart in Netmeter?
      bool bUsingNetmeterDatabase = (oldDatabaseName.ToUpper() == mProductDatabaseName.ToUpper()) ? true : false;
      ConnectionInfo connInfo = GetReportingDBServerConnectionInfo(null, bUsingNetmeterDatabase);
      connInfo.Catalog = oldDatabaseName;
      mLogger.LogDebug(string.Format("Using database {0} for splitting reverse.", oldDatabaseName));

      string newDatabaseName = CreateDataBase(childBillingGroupID);
      GenerateSchema(connInfo, newDatabaseName);

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(connInfo))
        {

          if (mIsQMEnabled)
          {
            // Call the queries in the mSplitReverseAdapterQueryTagList one at a time.

            foreach (string queryTag in mSplitReverseAdapterQueryTagList)
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
              {
                string info = String.Format("Preparing to execute query tag: {0}", queryTag);
                mLogger.LogInfo(info);

                stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", mProductDatabaseName);
                stmt.AddParamIfFound("%%PARENT_DB_NAME%%", oldDatabaseName);
                stmt.AddParamIfFound("%%PARENT_ID_BILLGROUP%%", parentBillingGroupID.ToString());
                stmt.AddParamIfFound("%%PARENT_ID_RUN%%", parentRunID.ToString());
                stmt.AddParamIfFound("%%CHILD_DB_NAME%%", newDatabaseName);
                stmt.AddParamIfFound("%%CHILD_ID_BILLGROUP%%", childBillingGroupID.ToString());
                stmt.AddParamIfFound("%%CHILD_ID_RUN%%", childRunID.ToString());

                stmt.ExecuteNonQuery();
              }
            }
          }
          else
          {

            // Call the queries in the mSplitReverseAdapterQueryList one at a time.
            for (int i = 0; i < mSplitReverseAdapterQueryList.Count; i++)
            {
              string statement = mSplitReverseAdapterQueryList[i].ToString();
              statement = statement.Replace("%%NETMETER_DB_NAME%%", mProductDatabaseName);
              statement = statement.Replace("%%PARENT_DB_NAME%%", oldDatabaseName);
              statement = statement.Replace("%%PARENT_ID_BILLGROUP%%", parentBillingGroupID.ToString());
              statement = statement.Replace("%%PARENT_ID_RUN%%", parentRunID.ToString());
              statement = statement.Replace("%%CHILD_DB_NAME%%", newDatabaseName);
              statement = statement.Replace("%%CHILD_ID_BILLGROUP%%", childBillingGroupID.ToString());
              statement = statement.Replace("%%CHILD_ID_RUN%%", childRunID.ToString());

              using (IMTStatement stmt = conn.CreateStatement(statement))
              {
                stmt.ExecuteNonQuery();
              }
            }
          }
        }
      }
      catch (System.Data.OleDb.OleDbException e)
      {
        // Report error
        if ((e.Errors.Count > 0) && (e.Errors[0].NativeError == 4060))
        {
          mLogger.LogInfo(String.Format("Could not open database {0} or {1} while running SplitReverse Adapter Queries", oldDatabaseName, newDatabaseName));
          mLogger.LogDebug(string.Format("Reporting database, {0}, did not exist. Marking reverse successful", oldDatabaseName));
        }
        else
        {
          mLogger.LogError(e.ToString());
          throw e;
        }
      }

      mLogger.LogDebug("Populated datamarts successfully in {0}", newDatabaseName);
    }

    private void GenerateSchema(ConnectionInfo connInfo, string newDatabaseName)
    {
      // All queries now have to be run on the reporting database
      connInfo.Catalog = newDatabaseName;
        
      // If the database is not new, nothing to do...
      if (false == mCreateNewDatabaseEachTime) return;

      using (IMTConnection conn = ConnectionManager.CreateConnection(connInfo))
      {
        // Call the queries to generate schema
        mLogger.LogDebug("Generating Schema in database {0}", newDatabaseName);

        if (mIsQMEnabled)
        {
          foreach (string queryTag in mGenerateSchemaQueryTagList)
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("", queryTag))
            {
              string info = String.Format("Preparing to execute query tag: {0}", queryTag);
              mLogger.LogInfo(info);

              stmt.AddParamIfFound("%%NETMETER_DB_NAME%%", newDatabaseName);
              stmt.AddParamIfFound("%%MAIN_NETMETER_DB_NAME%%", mProductDatabaseName);

              stmt.ExecuteNonQuery();
            }
          }
        }
        else
        {
          for (int i = 0; i < mGenerateSchemaQueryList.Count; i++)
          {
            string statement = mGenerateSchemaQueryList[i].ToString();
            statement = statement.Replace("%%NETMETER_DB_NAME%%", newDatabaseName);
            statement = statement.Replace("%%MAIN_NETMETER_DB_NAME%%", mProductDatabaseName);
            if (mIsOracle)
              statement = statement.Replace("\r", "\n");

            using (IMTStatement stmt = conn.CreateStatement(statement))
            {
              stmt.ExecuteNonQuery();
            }
          }
        }

        mLogger.LogDebug("Created schema successfully in  {0}", newDatabaseName);
      }
    }

    private string CreateDataBase(int childBillingGroupID)
        {
      // Database to create or populate
        string newDatabaseName = (true == mCreateNewDatabaseEachTime)
            ? ReportConfiguration.GetInstance().GenerateBillingGroupDatabaseName(childBillingGroupID)
            : ReportConfiguration.GetInstance().DatabasePrefix;

      if (true == mCreateNewDatabaseEachTime)
            {
        mLogger.LogDebug("SplitReverseState mCreateNewDatabaseEachTime == TRUE");
        // NetMeterReporting case, the database will have to be created only once
        mLogger.LogDebug("Create database: {0}", newDatabaseName);
        try
        {
          string createquery;
          PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\DBInstall", "__EXECUTE_CREATE_DATABASE_SP__"))
          {
            stmt.AddParam("%%DB_NAME%%", newDatabaseName);
            stmt.AddParam("%%NETMETER_DB_NAME%%", mProductDatabaseName);
            stmt.AddParam("%%DATA_LOG_PATH%%", mDBFilePath);
            stmt.AddParam("%%DB_SIZE%%", mDBSize);

            createquery = stmt.Query;
            }
          writer.ExecuteStatement(createquery, @"queries\DBInstall");
          // The database is created by nmdbo, so nmdbo is the owner

          mLogger.LogDebug("Created reporting database the first time: {0}", newDatabaseName);
        }
        catch (System.Data.OleDb.OleDbException e)
        {
          if ((e.Errors.Count > 0) && (e.Errors[0].NativeError == 1801))
          {
            mLogger.LogInfo("Reporting database has already been created");
            mLogger.LogInfo("Reporting database, {0}, already exists.", newDatabaseName);
      }
          else
          {
            mLogger.LogError(e.ToString());
            throw e;
    }
        }
      }
      else
        mLogger.LogDebug("SplitReverseState mCreateNewDatabaseEachTime == FALSE");
      return newDatabaseName;
    }

    private void ReadConfigFile(string configFile)
    {
      try
      {
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(configFile);

        if (mIsQMEnabled)
        {
          mPopulateQueryPath = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V2/PopulateQueryPath");
          mGenerateSchemaQueryPath = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V2/GenerateSchemaQueryPath");
          mReverseAdapterQueryPath = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V2/ReverseAdapterQueryPath");
            try
            {
              mSplitReverseAdapterQueryPath = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V2/SplitReverseAdapterQueryPath");
            }
            catch
            {
              mUseSplitReverseClassicImpl = true;
            }
        }
        else
        {
          mPopulateQueryFile = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V1/PopulateQueryFile");
          mGenerateSchemaQueryFile = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V1/GenerateSchemaQueryFile");
          mReverseAdapterQueryFile = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V1/ReverseAdapterQueryFile");
          try
          {
            mSplitReverseAdapterQueryFile = doc.GetNodeValueAsString("/xmlconfig/SupportedVersions/V1/SplitReverseAdapterQueryFile");
          }
          catch
          {
            mUseSplitReverseClassicImpl = true;
          }
        }

        mPopulateMetraFlowScripts = new System.Collections.Generic.List<MetraFlowScript> ();
        XmlNodeList nodeList = doc.SelectNodes("/xmlconfig/PopulateMetraFlowScript");
        foreach (XmlNode templateNode in nodeList)
        {
          string name = MTXmlDocument.GetNodeValueAsString(templateNode, "Name");
          string extension = MTXmlDocument.GetNodeValueAsString(templateNode, "Extension");
          mPopulateMetraFlowScripts.Add(MetraFlowScript.GetExtensionScript(extension, name));
        }
		
        if (doc.SingleNodeExists("/xmlconfig/TempDir") != null)
            mTempDir = doc.GetNodeValueAsString("/xmlconfig/TempDir");

        mMetraFlowConfig = new MetraFlowConfig();
        mMetraFlowConfig.Load(configFile);
        
        mDBSize = doc.GetNodeValueAsInt("/xmlconfig/DataMartDB/Size");
        mDBFilePath = doc.GetNodeValueAsString("/xmlconfig/DataMartDB/FilePath");

        string ReportType = doc.GetNodeValueAsString("/xmlconfig/ReportType");
        ReportType = ReportType.ToUpper();
        if (ReportType == "ACCOUNT")
          mReportType = BillingGroupSupportType.Account;
        else if (ReportType == "BILLINGGROUP")
          mReportType = BillingGroupSupportType.BillingGroup;
        else if (ReportType == "INTERVAL")
          mReportType = BillingGroupSupportType.Interval;
        else
          // Probably configured as a scheduled adapter.
          mReportType = BillingGroupSupportType.Interval;
      }
      catch (System.Data.OleDb.OleDbException e)
      {
        mLogger.LogError(e.ToString());
        mLogger.LogError("Could not read config file {0}.", configFile);
        throw e;
      }
    }

    private bool DoesDatabaseExist()
    {
      //__DOES_DB_EXIST__
      bool bResult = false;
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
              (@"queries\ReportGenerationAdapters", "__DOES_DB_EXIST__"))
          {
              stmt.AddParam("%%REPORTING_DB_NAME%%", mDatabaseName);
              stmt.ExecuteNonQuery();
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (reader.Read())
                  {
                      int nValue = reader.GetInt32("DbFound");
                      bResult = nValue > 0 ? true : false;
                  }
              }
          }
      }
      return bResult;
    }

    private void ReadQueryFile(string FileName, ref ArrayList queryList)
    {
      XmlNodeList nodeList;
      MTXmlDocument doc = new MTXmlDocument();
      try
      {

        mLogger.LogDebug("The query file being read is: {0}.", FileName);
        doc.Load(FileName);
        nodeList = doc.SelectNodes("/queryfile/mtconfigdata/query");
        foreach (XmlNode templateNode in nodeList)
        {
          if (mIsOracle)
          {
            string strQuery = MTXmlDocument.GetNodeValueAsString(templateNode, "query_string").Replace("\r", "");
            queryList.Add(strQuery);
          }
          else
            queryList.Add(MTXmlDocument.GetNodeValueAsString(templateNode, "query_string"));
        }
      }
      catch (Exception e)
      {
        mLogger.LogError(e.ToString());
        mLogger.LogError("Unable to read query file {0}.", FileName);
        throw e;
      }
    }

   private void ReadBatchQueryTags(string orderdQueryPath, ref List<string> queryTagList)
    {
      try
      {
        mLogger.LogDebug("The list of query tag being read from: {0}.", orderdQueryPath);
        queryTagList = QueryFinder.Execute(orderdQueryPath);
      }
      catch (Exception e)
      {
        mLogger.LogError(e.ToString());
        mLogger.LogError("Unable to get query tags from {0}.", orderdQueryPath);
        throw e;
      }
    }
	
    private void ResolveServerNameParam(IRecurringEventRunContext param, ref ConnectionInfo connInfo)
    {
      try
      {
        param.RecordInfo(ResolveServerName(ref connInfo));
      }
      catch (Exception e)
      {
        param.RecordInfo(e.Message);
        throw;
      }
    }

    private string ResolveServerName(ref ConnectionInfo connInfo)
    {
      try
      {
        IPHostEntry hostentry = Dns.GetHostEntry(connInfo.Server);
        connInfo.Server = hostentry.HostName;
        return string.Format("ReportingDBServer server name was specified as localhost and was resolved to '{0}'", connInfo.Server);
      }
      catch (Exception e)
      {
        throw new Exception(string.Format
              ("ReportingDBServer server name was specified as localhost, but the system failed to resolve it: '{0}'", e.Message));
      }
    }
  }
}

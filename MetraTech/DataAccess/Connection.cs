using System;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.Diagnostics;
using System.EnterpriseServices;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.DataAccess.Oracle;
using MetraTech.Interop.SysContext;
using Oracle.DataAccess.Client;

[assembly: GuidAttribute("fa1115ec-c6f9-41c2-be33-3a57edffce5f")]
namespace MetraTech.DataAccess
{
  /// <remarks>
  /// </remarks>
  public class ConnectionBase : IDisposable
  {      
    private MetraTech.Interop.SysContext.IMTLog mLogger;
    private MetraTech.Interop.SysContext.IMTLog mQueryLogger;

    private IDbConnection mConnection;
    private ConnectionInfo mConnectionInfo;

    public IDbConnection Connection
    {
      get { return mConnection; }
    }

    internal void LogQuery(Object sender, EventArgs e)
    {
      if (sender is Statement)
      {
        if (ContextUtil.IsInTransaction)
        {
          mQueryLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_DEBUG,
              "DTC<" + ContextUtil.TransactionId + ">: " + ((Statement)sender).Command.CommandText);
        }
        else
        {
          mQueryLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_DEBUG,
              "LocalTransaction: " + ((Statement)sender).Command.CommandText);
        }
      }
    }

    public String Schema
    {
      get { return mConnection.Database; }
      set { mConnection.ChangeDatabase(value); }
    }

    protected bool InternalAutoCommit
    {
      get { return false; }
      set { }
    }

    public void Close()
    {
      mConnection.Close();
    }

    public virtual void Dispose()
    {
      try
      {
        if (mConnection.State != ConnectionState.Closed) //If opened it is, close it we should
          mConnection.Close(); //Invalid Operation exception thrown from here
        mConnection.Dispose();
      }
      catch (Exception) { } // we never want to crush finilizer thread
      finally
      {
        GC.SuppressFinalize(this);
      }
    }

    protected MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement InternalCreateAdapterStatement(String configDir, String queryTag)
    {
      IDbCommand command = mConnection.CreateCommand();
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = new MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement(command, configDir, queryTag);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }
    protected MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement InternalCreateAdapterStatement(String aQueryString)
    {
      IDbCommand command = mConnection.CreateCommand();
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = new MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement(command, aQueryString);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }

    protected FilterSortStatement InternalCreateFilterSortStatement(String configDir, String queryTag)
    {
      IDbCommand command = mConnection.CreateCommand();
      FilterSortStatement astmt = new FilterSortStatement(command, configDir, queryTag);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }
    protected FilterSortStatement InternalCreateFilterSortStatement(String aQueryString)
    {
      IDbCommand command = mConnection.CreateCommand();
      FilterSortStatement astmt = new FilterSortStatement(command, aQueryString);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }

    protected MTMultiSelectAdapterStatement InternalCreateMultiSelectStatement(String configDir, String queryTag)
    {
      IDbCommand command = mConnection.CreateCommand();
      MTMultiSelectAdapterStatement astmt = new MTMultiSelectAdapterStatement(command, configDir, queryTag);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }
    protected MTMultiSelectAdapterStatement InternalCreateMultiSelectStatement(String aQueryString)
    {
      IDbCommand command = mConnection.CreateCommand();
      MTMultiSelectAdapterStatement astmt = new MTMultiSelectAdapterStatement(command, aQueryString);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }

    protected CallableStatement InternalCreateCallableStatement(String sprocName)
    {
      IDbCommand command = mConnection.CreateCommand();
      CallableStatement astmt = command is MTOracleCommand ?
          new OracleCallableStatement(command, sprocName) : new CallableStatement(command, sprocName);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }

    protected PreparedStatement InternalCreatePreparedStatement(String queryText)
    {
      IDbCommand command = mConnection.CreateCommand();
      PreparedStatement astmt = new PreparedStatement(command, queryText);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }

    protected PreparedFilterSortStatement InternalCreatePreparedFilterSortStatement(string queryText)
    {
      IDbCommand command = mConnection.CreateCommand();
      PreparedFilterSortStatement astmt = new PreparedFilterSortStatement(command, queryText);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }
	
	 protected MetraTech.DataAccess.PreparedFilterSortStatement.PreparedFilterSortForExport InternalCreatePreparedFilterSortForExport(string queryText,string nameTable)
        {
          IDbCommand command = mConnection.CreateCommand();
          MetraTech.DataAccess.PreparedFilterSortStatement.PreparedFilterSortForExport astmt = new MetraTech.DataAccess.PreparedFilterSortStatement.PreparedFilterSortForExport(command, queryText,nameTable);
          astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
          astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
          return astmt;
        }

    protected Statement InternalCreateStatement(String queryText)
    {
      IDbCommand command = mConnection.CreateCommand();
      Statement astmt = new Statement(command, queryText);
      astmt.Command.CommandTimeout = mConnectionInfo.Timeout;
      astmt.BeforeExecute += new ExecuteEventHandler(LogQuery);
      return astmt;
    }

    public DataTable DescribeTable(string tableName)
    {
      using (IMTStatement stmt = InternalCreateStatement("select * from " + tableName))
      {
        using (IMTDataReader reader = stmt.ExecuteReader())
        {
          return reader.GetSchema();
        }
      }
    }


    protected ConnectionBase(MetraTech.DataAccess.ConnectionInfo ci, bool isServiced, bool useNative)
    {
      mLogger = new MetraTech.Interop.SysContext.MTLog();
      mLogger.Init("Logging", "[DataAccess.NET]");

      mQueryLogger = new MetraTech.Interop.SysContext.MTLog();
      mQueryLogger.Init("Logging\\QueryLog", "[Querylog]");

      // Example connection strings that are known to work!
      //"Provider= SQLOLEDB.1; Data Source=localhost;uid=sa; pwd=; Initial Catalog=NetMeter;"
      //"Provider=OraOLEDB.Oracle;Data Source=hydrogen.metratech.com;User ID=DB;Password=DB;Persist Security Info=False"

      var connection = GetDbConnection(ci, isServiced);
      mConnection = ci.DatabaseType == DBType.Oracle ?
              new MTOracleConnection((OracleConnection)connection)
            : connection as IDbConnection;

      // no real need to print out the connection string.  it contains the
      // password.
      //mLogger.LogString(
      //MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_DEBUG, 
      //  "Creating connection with connection string " + bld.ToString());

      mConnection.Open();
      mConnectionInfo = ci;
    }

    /// <summary>
    /// Return DbConnection for Database depend of connectionInfo parameters
    /// Support 3 types: SQlServer, Oracle and CSV
    /// </summary>
    /// <param name="connectionInfo"></param>
    /// <param name="isServiced"></param>
    /// <returns></returns>
    public static DbConnection GetDbConnection(ConnectionInfo connectionInfo, bool isServiced)
    {
      if (connectionInfo == null) throw new ArgumentNullException("connectionInfo");
      var stringBuilder = new StringBuilder();
      switch (connectionInfo.DatabaseType)
      {
        case DBType.SQLServer:
          {
            stringBuilder.Append("Data Source=");
            stringBuilder.Append(connectionInfo.Server);
            stringBuilder.Append(";UID=");
            stringBuilder.Append(connectionInfo.UserName);
            stringBuilder.Append(";PWD=");
            stringBuilder.Append(connectionInfo.Password);
            stringBuilder.Append(";Initial Catalog=");
            stringBuilder.Append(connectionInfo.Catalog);
            stringBuilder.Append(";MultipleActiveResultSets=True");
            return new System.Data.SqlClient.SqlConnection(stringBuilder.ToString());
          }
        case DBType.Oracle:
          {
            stringBuilder.Append("Data Source=");
            stringBuilder.Append(connectionInfo.Server);
            stringBuilder.Append(";User ID=");
            stringBuilder.Append(connectionInfo.UserName);
            stringBuilder.Append(";Password=");
            stringBuilder.Append(connectionInfo.Password);
            stringBuilder.Append(";Pooling=true");
            stringBuilder.Append(";Max Pool Size=250");
            if (!isServiced)
              stringBuilder.Append(";Enlist=false");

            return new OracleConnection(stringBuilder.ToString());
          }

        case DBType.CSV:
          {
            // "SELECT * FROM csv-read.csv"
            stringBuilder.Append("Provider=");
            stringBuilder.Append("Microsoft.Jet.OLEDB.4.0");
            stringBuilder.Append(";Data Source=");
            var fInfo = new FileInfo(connectionInfo.DataSource);
            var dirName = fInfo.DirectoryName;
            stringBuilder.Append(dirName);
            stringBuilder.Append(";Extended Properties=\"text;HDR=YES;FMT=CSVDelimited\"");
            return new OleDbConnection(stringBuilder.ToString());
          }
        default:
          return null;
      }
    }

    ~ConnectionBase()
    {
      Dispose();
    }

    public ConnectionInfo ConnectionInfo
    {
      get
      { return mConnectionInfo; }
    }
  }

  /// <remarks>
  /// This is the class that wraps the OleDb ADO.Net or ODP (Oracle Data Provider) provider connection for use with
  /// manual transaction management.  The reason
  /// for having this wrapper isn't just paranoia about not using an API
  /// directly, this API provides services on top of ADO.NET:
  /// <list>
  /// <item><description>Query Logging</description></item>
  /// <item><description>Automatic transaction enlistment for statements/commands</description></item>
  /// <item><description>Uniform exception handling classes</description></item>
  /// <item><description>Integration with Query Adapter</description></item>
  /// </list>
  /// </remarks>
  public class NonServicedConnection : ConnectionBase, IMTNonServicedConnection, IDisposable
  {
    private IDbTransaction mTransaction;
    private IsolationLevel mIsolationLevel;
    private bool mAutoCommit;

    internal void EnlistInTransaction(Object sender, EventArgs e)
    {
      if (sender is Statement && !mAutoCommit)
      {
        // Make sure a transaction has been created.
        // Make sure the statement has enlisted in the transaction.
        if (mTransaction == null)
        {
          mTransaction = Connection.BeginTransaction(mIsolationLevel);
        }

        ((Statement)sender).Command.Transaction = mTransaction;
      }
    }

    public void RollbackTransaction()
    {
      if (!mAutoCommit && mTransaction != null)
      {
        mTransaction.Rollback();
        mTransaction = null;
      }
    }

    public void CommitTransaction()
    {
      if (!mAutoCommit && mTransaction != null)
      {
        mTransaction.Commit();
        mTransaction = null;
      }
    }

    public bool AutoCommit
    {
      get { return mAutoCommit; }
      set { CommitTransaction(); mAutoCommit = value; }
    }

    public IsolationLevel IsolationLevel
    {
      get { return mIsolationLevel; }
      set { mIsolationLevel = value; }
    }

    public IMTAdapterStatement CreateAdapterStatement(String configDir, String queryTag)
    {
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = InternalCreateAdapterStatement(configDir, queryTag);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }
    public IMTAdapterStatement CreateAdapterStatement(String aQueryString)
    {
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = InternalCreateAdapterStatement(aQueryString);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }

    public IMTFilterSortStatement CreateFilterSortStatement(String configDir, String queryTag)
    {
      FilterSortStatement astmt = InternalCreateFilterSortStatement(configDir, queryTag);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }
    public IMTFilterSortStatement CreateFilterSortStatement(String aQueryString)
    {
      FilterSortStatement astmt = InternalCreateFilterSortStatement(aQueryString);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }

    public IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String configDir, String queryTag)
    {
      MTMultiSelectAdapterStatement stmt = InternalCreateMultiSelectStatement(configDir, queryTag);
      stmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return stmt;
    }
    public IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String aQueryString)
    {
      MTMultiSelectAdapterStatement stmt = InternalCreateMultiSelectStatement(aQueryString);
      stmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return stmt;
    }

    public IMTCallableStatement CreateCallableStatement(String sprocName)
    {
      CallableStatement astmt = InternalCreateCallableStatement(sprocName);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }

    public IMTPreparedStatement CreatePreparedStatement(String sqlText)
    {
      PreparedStatement astmt = InternalCreatePreparedStatement(sqlText);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }

    public IMTPreparedFilterSortStatement CreatePreparedFilterSortStatement(string sqlText)
    {
      PreparedFilterSortStatement astmt = InternalCreatePreparedFilterSortStatement(sqlText);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }

	public IMTPreparedFilterSortStatement CreatePreparedFilterSortForExport(string sqlText,string nameTable)
    {
        MetraTech.DataAccess.PreparedFilterSortStatement.PreparedFilterSortForExport astmt = InternalCreatePreparedFilterSortForExport(sqlText,nameTable);
        astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
        return astmt;
    }
	
    public IMTStatement CreateStatement(String queryText)
    {
      Statement astmt = InternalCreateStatement(queryText);
      astmt.BeforeExecute += new ExecuteEventHandler(EnlistInTransaction);
      return astmt;
    }

    public NonServicedConnection(MetraTech.DataAccess.ConnectionInfo ci)
      :
      base(ci, false, false)
    {
      mIsolationLevel = IsolationLevel.ReadCommitted;
      mAutoCommit = true;
    }

    ~NonServicedConnection()
    {
      Dispose();
    }

    public override void Dispose()
    {
      base.Dispose();

      GC.SuppressFinalize(this);
    }
  }

  /// <remarks>
  /// This is the class that wraps the OleDb ADO.Net or ODP (Oracle Data Provider) provider connection for use with
  /// COM+/serviced components.  The reason
  /// for having this wrapper isn't just paranoia about not using an API
  /// directly, this API provides services on top of ADO.NET:
  /// <list>
  /// <item><description>Query Logging</description></item>
  /// <item><description>Uniform exception handling classes</description></item>
  /// <item><description>Integration with Query Adapter</description></item>
  /// </list>
  /// </remarks>
  public class ServicedConnection : ConnectionBase, IMTServicedConnection, IDisposable
  {
    public IMTAdapterStatement CreateAdapterStatement(String configDir, String queryTag)
    {
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = InternalCreateAdapterStatement(configDir, queryTag);
      return astmt;
    }

    public IMTAdapterStatement CreateAdapterStatement(String aQueryString)
    {
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = InternalCreateAdapterStatement(aQueryString);
      return astmt;
    }

    public IMTFilterSortStatement CreateFilterSortStatement(String configDir, String queryTag)
    {
      FilterSortStatement astmt = InternalCreateFilterSortStatement(configDir, queryTag);
      return astmt;
    }

    public IMTFilterSortStatement CreateFilterSortStatement(String aQueryString)
    {
      FilterSortStatement astmt = InternalCreateFilterSortStatement(aQueryString);
      return astmt;
    }

    public IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String configDir, String queryTag)
    {
      MTMultiSelectAdapterStatement stmt = InternalCreateMultiSelectStatement(configDir, queryTag);
      return stmt;
    }
    public IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String aQueryString)
    {
      MTMultiSelectAdapterStatement stmt = InternalCreateMultiSelectStatement(aQueryString);
      return stmt;
    }

    public IMTCallableStatement CreateCallableStatement(String sprocName)
    {
      CallableStatement astmt = InternalCreateCallableStatement(sprocName);
      return astmt;
    }

    public IMTPreparedStatement CreatePreparedStatement(String sqlText)
    {
      PreparedStatement astmt = InternalCreatePreparedStatement(sqlText);
      return astmt;
    }

    public IMTPreparedFilterSortStatement CreatePreparedFilterSortStatement(String sqlText)
    {
      PreparedFilterSortStatement astmt = InternalCreatePreparedFilterSortStatement(sqlText);
      return astmt;
    }

	    public IMTPreparedFilterSortStatement CreatePreparedFilterSortForExport(String sqlText,string nameTable)
       {
           MetraTech.DataAccess.PreparedFilterSortStatement.PreparedFilterSortForExport astmt = InternalCreatePreparedFilterSortForExport(sqlText,nameTable);
           return astmt;
        }
	
    public IMTStatement CreateStatement(String queryText)
    {
      Statement astmt = InternalCreateStatement(queryText);
      return astmt;
    }

    public ServicedConnection(MetraTech.DataAccess.ConnectionInfo ci)
      :
      base(ci, true, false)
    {
    }


    public ServicedConnection(MetraTech.DataAccess.ConnectionInfo ci, bool useNative)
      :
      base(ci, true, useNative)
    {
    }

    ~ServicedConnection()
    {
      Dispose();
    }

    public override void Dispose()
    {
      base.Dispose();

      GC.SuppressFinalize(this);
    }
  }
}

namespace MetraTech.DataAccess.OleDb
{
  /// <remarks>
  //  Jet database connection
  /// </remarks>
  public class ADOOleDbJetConnection : ConnectionBase, IMTFileConnection
  {
    public IMTAdapterStatement CreateAdapterStatement(String configDir, String queryTag)
    {
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = InternalCreateAdapterStatement(configDir, queryTag);
      return astmt;
    }

    public IMTAdapterStatement CreateAdapterStatement(String aQueryString)
    {
      MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement astmt = InternalCreateAdapterStatement(aQueryString);
      return astmt;
    }

    public IMTFilterSortStatement CreateFilterSortStatement(String configDir, String queryTag)
    {
      FilterSortStatement astmt = InternalCreateFilterSortStatement(configDir, queryTag);
      return astmt;
    }

    public IMTFilterSortStatement CreateFilterSortStatement(String aQueryString)
    {
      FilterSortStatement astmt = InternalCreateFilterSortStatement(aQueryString);
      return astmt;
    }

    public IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String configDir, String queryTag)
    {
      MTMultiSelectAdapterStatement stmt = InternalCreateMultiSelectStatement(configDir, queryTag);
      return stmt;
    }
    public IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String aQueryString)
    {
      MTMultiSelectAdapterStatement stmt = InternalCreateMultiSelectStatement(aQueryString);
      return stmt;
    }
    public IMTCallableStatement CreateCallableStatement(String sprocName)
    {
      CallableStatement astmt = InternalCreateCallableStatement(sprocName);
      return astmt;
    }

    public IMTPreparedStatement CreatePreparedStatement(String sqlText)
    {
      PreparedStatement astmt = InternalCreatePreparedStatement(sqlText);
      return astmt;
    }

    public IMTPreparedFilterSortStatement CreatePreparedFilterSortStatement(String sqlText)
    {
      PreparedFilterSortStatement astmt = InternalCreatePreparedFilterSortStatement(sqlText);
      return astmt;
    }

	        public IMTPreparedFilterSortStatement CreatePreparedFilterSortForExport(String sqlText,string nameTable )
        {
          MetraTech.DataAccess.PreparedFilterSortStatement.PreparedFilterSortForExport astmt = InternalCreatePreparedFilterSortForExport(sqlText,nameTable);
          return astmt;
        }

    public IMTStatement CreateStatement(String queryText)
    {
      Statement astmt = InternalCreateStatement(queryText);
      return astmt;
    }

    public ADOOleDbJetConnection(ConnectionInfo connInfo)
      :
      base(connInfo, false, false)
    {
      Debug.Assert(connInfo.DatabaseType == DBType.CSV);
      FileInfo fInfo = new FileInfo(connInfo.DataSource);
      mName = fInfo.Name;
      mFullName = fInfo.FullName;
    }

    // filename (excludes directory name)
    public string Filename
    {
      get { return mName; }
    }

    public string FullFilename
    {
      get { return mFullName; }
    }

    private string mName;
    private string mFullName;
  }

}
namespace MetraTech.DataAccess.Oracle
{
  internal class MTOracleCommand : IDbCommand
  {
    private IDbCommand mCommand;

    internal MTOracleCommand(OracleCommand cmd)
    {
      mCommand = cmd;
    }
    ~MTOracleCommand()
    {
      Dispose();
    }
    public void Cancel()
    {
      mCommand.Cancel();
    }
    public IDbDataParameter CreateParameter()
    {
      return mCommand.CreateParameter();
    }
    public int ExecuteNonQuery()
    {
      return mCommand.ExecuteNonQuery();
    }
    public IDataReader ExecuteReader()
    {
      return mCommand.ExecuteReader();
    }
    public IDataReader ExecuteReader(CommandBehavior behavior)
    {
      return mCommand.ExecuteReader(behavior);
    }
    public object ExecuteScalar()
    {
      return mCommand.ExecuteScalar();
    }

    public void Prepare()
    {
      mCommand.Prepare();
    }

    public string CommandText
    {
      get { return mCommand.CommandText; }
      set
      {
        //Parse text to get rid of ODBC escapes
        mCommand.CommandText = ParseOutODBCEscapes(value);
      }
    }

    private string ParseOutODBCEscapes(string source)
    {
      // timestamp escapes: {ts '...' }
      Regex tsmatcher = new Regex(@"(\{ts\s[0-9\-\:\.\s\']+})");
      Match m = tsmatcher.Match(source);
      while (m.Success)
      {
        string val = m.Value;
        int start = m.Index;
        int length = m.Length;
        string todate = val.Replace("{ts ", "to_timestamp(");
        todate = todate.Replace("}", ", 'YYYY/MM/DD HH24:MI:SS.FF')");
        source = source.Replace(val, todate);
        m = m.NextMatch();
      }

      // ifnull function escapes: {fn ifnull(...)}
      // (now supports nesting)
      string pattern = @"\{\s*fn\s+ifnull\s*([^\{^\}]*)\s*\}";
      while (Regex.IsMatch(source, pattern, RegexOptions.IgnoreCase))
      {
        source = Regex.Replace(source,
            pattern,	// match: {fn ifnull(...)}
            @"nvl$1",	// replace with: nvl(...)
            RegexOptions.IgnoreCase);	// ignore case
      }

      return source;
    }


    public int CommandTimeout
    {
      get { return mCommand.CommandTimeout; }
      set { mCommand.CommandTimeout = value; }
    }

    public CommandType CommandType
    {
      get { return mCommand.CommandType; }
      set { mCommand.CommandType = value; }
    }

    public IDbConnection Connection
    {
      get { return mCommand.Connection; }
      set { mCommand.Connection = value; }
    }
    public IDataParameterCollection Parameters
    {
      get { return mCommand.Parameters; }
    }

    public IDbTransaction Transaction
    {
      get { return mCommand.Transaction; }
      set { mCommand.Transaction = value; }
    }

    public UpdateRowSource UpdatedRowSource
    {
      get { return mCommand.UpdatedRowSource; }
      set { mCommand.UpdatedRowSource = value; }
    }

    public bool BindByName
    {
      get { return ((OracleCommand)mCommand).BindByName; }
      set { ((OracleCommand)mCommand).BindByName = value; }
    }

    public void Dispose()
    {
      mCommand.Dispose();

      GC.SuppressFinalize(this);
    }

  }
  internal class MTOracleConnection : IDbConnection
  {
    private IDbConnection mConnection;

    internal MTOracleConnection(OracleConnection connection)
    {
      mConnection = connection;
    }

    ~MTOracleConnection()
    {
      Dispose();
    }

    public IDbCommand CreateCommand()
    {
      return new MTOracleCommand((OracleCommand)mConnection.CreateCommand());
    }

    public IDbTransaction BeginTransaction()
    {
      return mConnection.BeginTransaction();
    }

    public IDbTransaction BeginTransaction(System.Data.IsolationLevel isol)
    {
      return mConnection.BeginTransaction(isol);
    }

    public void Close()
    {
      mConnection.Close();
    }

    public void Open()
    {
      mConnection.Open();
    }
    public void ChangeDatabase(string aStr)
    {
      mConnection.ChangeDatabase(aStr);
    }

    public string ConnectionString
    {
      get { return mConnection.ConnectionString; }
      set { mConnection.ConnectionString = value; }
    }

    public int ConnectionTimeout
    {
      get { return mConnection.ConnectionTimeout; }
    }

    public string Database
    {
      get { throw new System.NotSupportedException(); }
    }

    public ConnectionState State
    {
      get { return mConnection.State; }
    }

    public void Dispose()
    {
      mConnection.Dispose();

      GC.SuppressFinalize(this);
    }


  }
}


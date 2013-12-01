
using System.Data.Common;
using System.Diagnostics;
using System.Collections.Specialized;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.SysContext;
using MetraTech.Xml;
using Rowset = MetraTech.Interop.Rowset;

[assembly: ComVisible(false)]

namespace MetraTech.DataAccess
{
  using System;
  using System.Data;


  /// <remarks>
  /// </remarks>
  internal delegate void ExecuteEventHandler(Object sender, EventArgs e);

  /// <summary>
  /// Empty string defined as a string with one space char. Should only be used for Oracle.
  /// </summary>
  public class MTEmptyString
  {
    MTEmptyString()
    {
    }
    static public String Value
    {
      get { return " "; }
    }
  };

  /// <remarks>
  /// </remarks>
  public enum DBType { SQLServer, Oracle, CSV };

  /// <remarks>
  /// </remarks>
  public class DataAccessException : ApplicationException
  {
    public DataAccessException(String msg)
      : base(msg)
    {
    }
  }

  /// <remarks>
  /// Information from ServerAccess.xml need to create a connection.
  /// </remarks>
  public class ConnectionInfo : ICloneable
  {
    private String mServer;
    public String Server
    {
      get { return mServer; }
      set { mServer = value; }
    }

    private String mCatalog;
    public String Catalog
    {
      get { return mCatalog; }
      set { mCatalog = value; }
    }

    private String mDataSource;
    public String DataSource
    {
      get { return mDataSource; }
      set { mDataSource = value; }
    }

    private String mDatabaseDriver;
    public String DatabaseDriver
    {
      get { return mDatabaseDriver; }
      set { mDatabaseDriver = value; }
    }

    private String mUserName;
    public String UserName
    {
      get { return mUserName; }
      set { mUserName = value; }
    }

    private String mPassword;
    public String Password
    {
      get { return mPassword; }
      set { mPassword = value; }
    }

    private int mTimeout;
    public int Timeout
    {
      get { return mTimeout; }
      set { mTimeout = value; }
    }

    private DBType mDatabaseType;
    public DBType DatabaseType
    {
      get { return mDatabaseType; }
      set { mDatabaseType = value; }
    }

    public bool IsOracle
    {
      get { return mDatabaseType == DBType.Oracle; }
    }

    public bool IsSqlServer
    {
      get { return mDatabaseType == DBType.SQLServer; }
    }

    //    override public String ToString()
    //    {
    //      System.Text.StringBuilder 
    //    }   

    private static Hashtable mConnectionInfoCache;

    static ConnectionInfo()
    {
      CacheConnectionInfo();
    }

    private static void CacheConnectionInfo()
    {
      mConnectionInfoCache = CollectionsUtil.CreateCaseInsensitiveHashtable();

      MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      sa.Initialize();

      foreach (MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData in sa)
      {
        ConnectionInfo connInfo = new ConnectionInfo();
        connInfo.Server = accessData.ServerName;
        connInfo.Catalog = accessData.DatabaseName;
        connInfo.DataSource = accessData.DataSource;
        connInfo.DatabaseDriver = accessData.DatabaseDriver;
        connInfo.UserName = accessData.UserName;
        connInfo.Password = accessData.Password;
        connInfo.Timeout = accessData.Timeout;
        String dbtype = accessData.DatabaseType;
        if (dbtype.Length == 0 || dbtype.ToUpper() == "{SQL SERVER}")
        {
          connInfo.DatabaseType = DBType.SQLServer;
        }
        else if (dbtype.ToUpper() == "{ORACLE}")
        {
          connInfo.DatabaseType = DBType.Oracle;
        }
        else
        {
          throw new DataAccessException("Unknown Database Type: " + dbtype);
        }

        string logicalName = accessData.ServerType;
        mConnectionInfoCache[logicalName] = connInfo;
      }
    }

    private ConnectionInfo()
    {
    }

    public ConnectionInfo(String logicalServerName)
    {
      ConnectionInfo template = (ConnectionInfo)mConnectionInfoCache[logicalServerName];

      if (template == null)
      {
        if (mConnectionInfoCache.Count == 0)
          throw new DataAccessException("logical server cache is empty");

        throw new DataAccessException("Unknown logical server: " + logicalServerName);
      }

      // Special case: NetMeterStage is a clone of the NetMeter entry
      // except for the catalog (database) name
      this.Catalog = template.Catalog;

      // in Oracle DB name and User name are the same
      var oraUserName = Catalog;

      if (logicalServerName.ToLowerInvariant().Equals("netmeterstage"))
      {
        // Create the NetMeter database info
        template = new ConnectionInfo("NetMeter");
      }

      this.Server = template.Server;
      this.DataSource = template.DataSource;
      this.DatabaseDriver = template.DatabaseDriver;
      this.UserName = template.IsOracle ? oraUserName : template.UserName;
      this.Password = template.Password;
      this.Timeout = template.Timeout;
      this.DatabaseType = template.DatabaseType;
    }

    public object Clone()
    {
      ConnectionInfo connInfo = new ConnectionInfo();
      connInfo.Server = this.Server;
      connInfo.Catalog = this.Catalog;
      connInfo.DataSource = this.DataSource;
      connInfo.DatabaseDriver = this.DatabaseDriver;
      connInfo.UserName = this.UserName;
      connInfo.Password = this.Password;
      connInfo.Timeout = this.Timeout;
      connInfo.DatabaseType = this.DatabaseType;

      return connInfo;
    }

    /// <summary>
    /// Returns a ConnectionInfo object based on the contents 
    /// of the DBAccess.xml file found in path
    /// </summary>
    public static ConnectionInfo CreateFromDBAccessFile(string path)
    {
      // tries the cache first
      ConnectionInfo connInfo = (ConnectionInfo)mDBAccessCache[path];
      if (connInfo != null)
        return (ConnectionInfo)connInfo.Clone();

      IMTQueryAdapter queryAdapter = new MTQueryAdapter();
      if (queryAdapter == null)
      {
        throw new DataAccessException("Unable to initialize query adapter");
      }
      queryAdapter.Init(path);
      string logicalServerName = queryAdapter.GetLogicalServerName();
      if (String.IsNullOrEmpty(logicalServerName) || String.IsNullOrWhiteSpace(logicalServerName))
      {
        throw new DataAccessException(String.Concat("Extracted LogicalServername from ", path, @"\dbaccess.xml is null or empty string!"));
      }
      connInfo = new ConnectionInfo(logicalServerName) { Timeout = queryAdapter.GetTimeout() };

      mDBAccessCache[path] = connInfo;

      return (ConnectionInfo)connInfo.Clone();
    }


    /// <summary>
    /// Returns a ConnectionInfo object based on a path to a CSV file
    /// </summary>
    public static ConnectionInfo CreateFromCSVPathname(string path)
    {
      ConnectionInfo connInfo = new ConnectionInfo();
      connInfo.DataSource = path;
      connInfo.DatabaseType = DBType.CSV;
      return connInfo;
    }


    static Hashtable mDBAccessCache = CollectionsUtil.CreateCaseInsensitiveHashtable();
  }

  /// <remarks>
  /// Factory for creating connections. Uses the server access "naming service" so,
  /// databases use logical server access names.
  /// </remarks>
  public class ConnectionManager
  {
    // TODO: Implement a cache of connection info structures
    public static DbConnection CreateDbConnection()
    {
      return ConnectionBase.GetDbConnection(ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database"), true);
    }

    public static IMTNonServicedConnection CreateNonServicedConnection()
    {
      return CreateNonServicedConnection(@"Queries\Database");
    }

    public static IMTNonServicedConnection CreateNonServicedConnection(string dbAccessPath)
    {
      return CreateNonServicedConnection(ConnectionInfo.CreateFromDBAccessFile(dbAccessPath));
    }

    public static IMTNonServicedConnection CreateNonServicedConnection(ConnectionInfo info)
    {
      return new MetraTech.DataAccess.NonServicedConnection(info);
    }

    public static IMTServicedConnection CreateConnection()
    {
      return CreateConnection(@"Queries\Database");
    }

    public static IMTServicedConnection CreateConnection(string dbAccessPath)
    {
      return CreateConnection(ConnectionInfo.CreateFromDBAccessFile(dbAccessPath));
    }

    public static IMTServicedConnection CreateConnection(ConnectionInfo info)
    {
      return new MetraTech.DataAccess.ServicedConnection(info);
    }

    public static IMTServicedConnection CreateConnection(bool useNative)
    {
      return CreateConnection(@"Queries\Database", useNative);
    }

    public static IMTServicedConnection CreateConnection(string dbAccessPath, bool useNative)
    {
      return CreateConnection(ConnectionInfo.CreateFromDBAccessFile(dbAccessPath), useNative);
    }

    public static IMTServicedConnection CreateConnection(ConnectionInfo info, bool useNative)
    {
      return new MetraTech.DataAccess.ServicedConnection(info, useNative);
    }

    public static IMTFileConnection CreateFileConnection(string filename)
    {
      ConnectionInfo connInfo = ConnectionInfo.CreateFromCSVPathname(filename);
      return new MetraTech.DataAccess.OleDb.ADOOleDbJetConnection(connInfo);
    }
  }

  /// <remarks>
  /// Connection object base behaviors
  /// management
  /// </remarks>
  public interface IMTConnection : IDisposable
  {
    String Schema
    {
      get;
      set;
    }
    void Close();
    IMTStatement CreateStatement(String queryText);
    IMTAdapterStatement CreateAdapterStatement(String configDir, String queryTag);
    IMTAdapterStatement CreateAdapterStatement(String aQueryString);
    IMTFilterSortStatement CreateFilterSortStatement(String configDir, String queryTag);
    IMTFilterSortStatement CreateFilterSortStatement(String aQueryString);
    IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String configDir, String queryTag);
    IMTMultiSelectAdapterStatement CreateMultiSelectStatement(String aQueryString);
    IMTCallableStatement CreateCallableStatement(String sprocName);
    IMTPreparedStatement CreatePreparedStatement(String queryText);
    IMTPreparedFilterSortStatement CreatePreparedFilterSortStatement(string sqlText);
    IMTPreparedFilterSortStatement CreatePreparedFilterSortForExport(string sqlText,string nameTable);
    DataTable DescribeTable(string tableName);

    ConnectionInfo ConnectionInfo
    { get; }
  }

  /// <remarks>
  /// Connection object for some that wants to do manual transaction
  /// management.  Users of these objects must call rollback or commit
  /// to decide the fate of a transaction.
  /// TODO: Add a JoinTransaction method...
  /// </remarks>
  public interface IMTNonServicedConnection : IMTConnection
  {
    void RollbackTransaction();
    void CommitTransaction();
    bool AutoCommit
    {
      get;
      set;
    }

    IsolationLevel IsolationLevel
    {
      get;
      set;
    }
  }

  /// <remarks>
  /// Connection object for someone that wants to use COM+/Automatic
  /// transactions.
  /// </remarks>
  public interface IMTServicedConnection : IMTConnection
  {
  }

  /// <remarks>
  /// Connection object for someone reading from a Jet .MDB or .CSV file.
  /// </remarks>
  public interface IMTFileConnection : IMTConnection
  {
    string Filename
    { get; }

    string FullFilename
    { get; }
  }

  /// <remarks>
  /// Statement object for executing simple non-parameterized SQL 
  /// </remarks>
  public interface IMTStatement : IDisposable
  {
    IMTDataReader ExecuteReader();
    int ExecuteNonQuery();
  }

  /// <remarks>
  /// Statement object that supports by name binding of parameters with an
  /// underlying query adapter based query.
  /// </remarks>
  public interface IMTAdapterStatement : IMTStatement, IDisposable
  {
    void AddParam(String name, Object value);
    void AddParam(String name, Object value, bool dontValidateString);
    void OmitParam(string name);

    String QueryTag
    {
      set;
    }

    String ConfigPath
    {
      set;
    }

    string Query
    {
      get;
    }

    void ClearQuery();

    //Same as AddParam, but don't return an error if
    //a parameter was not found. Return true if parameter was found
    //and false otherwise
    bool AddParamIfFound(String name, Object value);
    bool AddParamIfFound(String name, Object value, bool dontValidateString);

  }


  /// <remarks>
  /// Interface to a resultset.  Unlike System.Data.IDataRecord,
  /// this interface also provides access to field by name and index (instead
  /// of only access by index).
  /// </remarks>
  public interface IMTDataReader : IDisposable
  {
    bool IsClosed
    {
      get;
    }
    void Close();
    bool Read();

    int FieldCount
    {
      get;
    }

    int GetOrdinal(String col);

    bool GetBoolean(String col);
    DateTime GetDateTime(String col);
    Decimal GetDecimal(String col);
    int GetInt32(String col);
    long GetInt64(String col);
    String GetString(String col);
    String GetConvertedString(String col);
    byte[] GetBytes(String col);
    object GetValue(String col);
    bool IsDBNull(String col);
    Type GetType(String col);
    TypeCode GetTypeCode(String col);
    Guid GetGuid(String col);


    bool GetBoolean(int idx);
    DateTime GetDateTime(int idx);
    Decimal GetDecimal(int idx);
    int GetInt32(int idx);
    long GetInt64(int idx);
    String GetString(int idx);
    String GetConvertedString(int idx); //converts to string if needed
    byte[] GetBytes(int idx);
    object GetValue(int idx);
    String GetName(int idx);
    bool IsDBNull(int idx);
    Type GetType(int idx);
    TypeCode GetTypeCode(int idx);
    Guid GetGuid(int idx);

    /// <summary>
    /// Convert current row to XML
    /// <param name="rowTag"></param>
    /// <param name="propertyNameMapping">(optional) Dictionary of rowset field name to Xml Tag name mappings, if a mapping doesn't exist, the field name is used for the xml tag</param>
    /// <param name="xmlAppendBeforeClosingTag">(optional) xml to be inserted after row tags are written but before the row closing tag is written</param>
    /// <returns>xml string</returns>
    /// </summary>
    String ToXml(String rowTag);
    String ToXml(String rowTag, Dictionary<string, string> propertyNameMapping);
    String ToXml(String rowTag, Dictionary<string, string> propertyNameMapping, String xmlAppendBeforeClosingTag);

    /// <summary>
    /// Convert rowset to XML, reading from current position until end (or maxRows). 
    /// </summary>
    /// <param name="rootTag">tag name of root element</param>
    /// <param name="rowTag">tag name of row element</param>
    /// <param name="rowTagInner">(optional) tag name of additonal per row element, inbetween rowTag and rows</param>
    /// <param name="maxRows">(optional) max numbers of rows to read, if 0 reads until end</param>
    /// <param name="rowsRead">(optional) numbers of rows actually read</param>
    /// <param name="propertyNameMapping">(optional) Dictionary of rowset field name to Xml Tag name mappings, if a mapping doesn't exist, the field name is used for the xml tag</param>
    /// <returns>xml string</returns>
    String ReadToXml(String rootTag, String rowTag);
    String ReadToXml(String rootTag, String rowTag, int maxRows, out int rowsRead);
    String ReadToXml(String rootTag, String rowTag, String rowTagInner);
    String ReadToXml(String rootTag, String rowTag, String rowTagInner, int maxRows, out int rowsRead);
    String ReadToXml(String rootTag, String rowTag, String rowTagInner, int maxRows, out int rowsRead, Dictionary<string, string> propertyNameMapping);


    /// <summary>
    /// Return the meta data of the query
    /// </summary>
    DataTable GetSchema();

    /// <summary>
    /// Copy reader's data into data table.  Reader can be closed/disposed afterwards.
    /// </summary>
    DataTable GetDataTable();

    bool NextResult();
  }

  public enum MTParameterType { Integer, String, WideString, DateTime, Binary, Decimal, Boolean, BigInteger, Text, NText, Blob, Guid }

  /// <remarks>
  /// Stored procedure statment object that supports by name binding of parameters.
  /// </remarks>
  public interface IMTCallableStatement : IDisposable
  {
    IMTDataReader ExecuteReader();
    int ExecuteNonQuery();
    /// <summary>
    /// Adds an input parameter value to a stored procedure.
    /// </summary>
    void AddParam(String name, MTParameterType type, Object value);
    /// <summary>
    /// Deprecated, use AddOutputParam() instead
    /// </summary>
    [Obsolete("Please use AddOutputParam instead", false)]
    void AddParam(String name, MTParameterType type);
    /// <summary>
    /// Adds an output parameter.
    /// </summary>
    void AddOutputParam(String name, MTParameterType type);
    void AddOutputParam(String name, MTParameterType type, int size);
    /// <summary>
    /// Adds the return value.
    /// </summary>
    void AddReturnValue(MTParameterType type);
    /// <summary>
    /// Retrieve the output parameter from the stored procedure.
    /// </summary>
    Object GetOutputValue(String name);
    /// <summary>
    /// Retrieve the output parameter from the stored procedure
    /// as a boolean. Other types convert but not our famous
    /// boolean. Matches AddParam.
    /// </summary>
    bool GetOutputValueAsBoolean(String name);
    /// <summary>
    /// </summary>
    /// <summary>
    /// </summary>
    Object ReturnValue
    { get; }
  }

  public interface IMTNamedParamterStatement
  {
    /// <summary>
    /// Binds a value to a named parameter in the query.  SQLServer prepends name with '@'; Oracle with ':'
    /// </summary>
    /// <param name="paramName">The name of the parameter</param>
    /// <param name="type">The parameter type</param>
    /// <param name="value">The parameter value</param>
    void AddParam(string paramName, MetraTech.DataAccess.MTParameterType type, Object value);
    /// <summary>
    /// Clear all parameter bindings
    /// </summary>
    void ClearParams();
  }

  /// <remarks>
  /// Prepared statment object that supports positional binding of parameters.
  /// </remarks>
  public interface IMTPreparedStatement : IMTNamedParamterStatement, IDisposable
  {
    IMTDataReader ExecuteReader();
    int ExecuteNonQuery();
    /// <summary>
    /// Binds a parameter to a value.
    /// </summary>
    void AddParam(MTParameterType type, Object value);

    /// <summary>
    /// Binds a value to a named parameter in the query.  SQLServer prepends name with '@'; Oracle with ':'
    /// </summary>
    /// <param name="paramName">The name of the parameter</param>
    /// <param name="type">The parameter type</param>
    /// <param name="value">The parameter value</param>
    new void AddParam(string paramName, MetraTech.DataAccess.MTParameterType type, Object value);
    /// <summary>
    /// Clear all parameter bindings
    /// </summary>
    new void ClearParams();

    /// <summary>
    /// Specifies the number of result sets coming back from query
    /// </summary>
    /// <param name="count">Specifies the number of result sets</param>
    void SetResultSetCount(int count);
  }

  public interface IMTBaseFilterSortStatement : IMTStatement
  {
    void AddFilter(BaseFilterElement filter);
    void ClearFilters();

    List<SortCriteria> SortCriteria { get; set; }

    int PageSize { get; set; }
    int CurrentPage { get; set; }

    int TotalRows { get; }
  }

  public interface IMTPreparedFilterSortStatement : IMTStatement, IMTNamedParamterStatement, IMTBaseFilterSortStatement, IDisposable
  {
    /// <summary>
    /// Binds a value to a named parameter in the query.  SQLServer prepends name with '@'; Oracle with ':'
    /// </summary>
    /// <param name="paramName">The name of the parameter</param>
    /// <param name="type">The parameter type</param>
    /// <param name="value">The parameter value</param>
    new void AddParam(string paramName, MetraTech.DataAccess.MTParameterType type, Object value);
    /// <summary>
    /// Clear all parameter bindings
    /// </summary>
    new void ClearParams();

    int MaxTotalRows { get; set; }
  }

  public enum SortDirection
  {
    Ascending,
    Descending
  };

  public interface IMTFilterSortStatement : IMTAdapterStatement, IMTBaseFilterSortStatement, IDisposable
  {
  }

  public interface IMTMultiSelectAdapterStatement : IMTAdapterStatement, IDisposable
  {
    void SetResultSetCount(int count);
  }

  /// <summary>
  /// Place for static utility functions
  /// </summary>
  public class DBUtil
  {

    /// <summary>
    /// Formats a value to be used as a DB input value.
    /// DateTime values use the ODBC escape syntax.
    /// Overload this method if there are db formatting needs for other types.
    /// </summary>
    public static string ToDBString(DateTime val)
    {
      // {ts 'yyyy-mm-dd hh:mm:ss'}
      //BP: Note that for Oracle this is all monkey's job. Since ODP.NET
      //does not support ODBC escape sequences, MTOracleCommand object will replace\
      //this with TO_DATE(...) before executing
      return String.Format("{{ts '{0}'}}", val.ToString("yyyy-MM-dd HH:mm:ss"));
    }

    /// <summary>
    /// Formats a value to be used as a DB input value.
    /// This method will escape any single quote with an additional single quote.
    /// </summary>
    public static string ToDBString(string val)
    {
      return val.Replace("'", "''");
    }

    /// <summary>
    /// IsNull works like NVL in oracle and ISNULL in sql server. Overloaded for 
    /// a bunch of types.
    /// </summary>

    public static int IsNull(object o, int v)
    {
      return o is DBNull ? v : Convert.ToInt32(o);
    }

    public static long IsNull(object o, long v)
    {
      return o is DBNull ? v : Convert.ToInt64(o);
    }

    public static decimal IsNull(object o, decimal v)
    {
      return o is DBNull ? v : (decimal)o;
    }

    public static string IsNull(object o, string v)
    {
      return o is DBNull ? v : o.ToString();
    }

    public static DateTime IsNull(object o, DateTime v)
    {
      return o is DBNull ? v : (DateTime)o;
    }


    public static Rowset.IMTSQLRowset RowsetFromReader(IMTDataReader rdr)
    {
      Rowset.IMTSQLRowset rs = new Rowset.MTSQLRowset();
      bool isOracle = new ConnectionInfo("NetMeter").IsOracle;

      // get the table schema from the reader
      DataTable ddl = rdr.GetSchema();

      // define the rowset column by column
      rs.InitDisconnected();
      foreach (DataRow col in ddl.Rows)
      {
        Console.WriteLine("{0} {1} {2} {3} {4}",
          col["ColumnName"], col["DataType"], col["ColumnSize"], col["NumericPrecision"], col["NumericScale"]);

        // remove the class prefix "System." from the type string
        // convert "datetime" to "timestamp"
        string type = col["DataType"].ToString().ToLower();
        type = type.Replace("system.", "");
        type = type.Replace("datetime", "timestamp");

        int len = Convert.ToInt32(col["ColumnSize"]);
        string name = col["ColumnName"].ToString();

        rs.AddColumnDefinition(name, type, len);
      }

      // copy data into rowset
      rs.OpenDisconnected();
      while (rdr.Read())
      {
        rs.AddRow();
        for (int i = 0; i < rdr.FieldCount; i++)
          rs.AddColumnData(rdr.GetName(i), rdr.GetValue(i));
      }
      return rs;
    }
  }

}

namespace MetraTech.DataAccess.OleDb
{
  using System;
  using System.EnterpriseServices;
  using DataAccess;
  
  /// <remarks>
  /// </remarks>
  [ComVisible(true)]
  [Guid("0b5132fc-db52-4c6c-b5b6-930c248c7b6e")]
  public interface IRetrieveCalendar
  {
    String RetrieveCalendar(string calendarName);
  }

  /// <remarks>
  /// </remarks>
  [ComVisible(true)]
  [Transaction(TransactionOption.Required, Isolation = TransactionIsolationLevel.Any)]
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("9992826d-129a-4db4-a330-9fcf4b9819e0")]
  public class ServicedComponentTester : ServicedComponent, IRetrieveCalendar
  {
    [AutoComplete]
    public String RetrieveCalendar(string calendarName)
    {
      using (var conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateAdapterStatement("Queries\\ProductCatalog", "__GET_CALENDAR_BYNAME__"))
        {
          stmt.AddParam("%%CALENDAR_NAME%%", calendarName);
          stmt.AddParam("%%ID_LANG%%", 840);

          using (var reader = stmt.ExecuteReader())
          {
            reader.Read();
            var str = reader.GetString("nm_name");
            if (reader.Read()) throw new DataAccessException("Received more than two calendars");
            return str;
          }
        }
      }
    }
  }

  /// <remarks>
  /// </remarks>
  [ComVisible(true)]
  [Transaction(TransactionOption.Required, Isolation = TransactionIsolationLevel.Any)]
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("36d00a1b-91f2-4d03-83d6-1bb3416507a3")]
  public class ServicedErrorWrapper : ServicedComponent
  {
    [AutoComplete]
    public String RetrieveCalendar(bool throwError, string calendarName)
    {
      var test = new ServicedComponentTester();
      var str = test.RetrieveCalendar(calendarName);
      if (throwError)
      {
        throw new DataAccessException("Aborting transaction");
      }
      return str;
    }
  }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using MetraTech.OnlineBill;

namespace MetraTech.UI.Common
{
  /// <summary>
  /// Defines a collection of SQLField objects.  This is used to read the results of a SQL query
  /// </summary>
  public class SQLRecord
  {
    public List<SQLField> Fields = new List<SQLField>();
  }

  /// <summary>
  /// Represents a field that is read from SQL results
  /// </summary>
  public class SQLField : SQLQueryParam
  {

  }

  /// <summary>
  /// Represents a set of parameters that could be sent to a SQL query
  /// </summary>
  public class SQLQueryParam
  {
    #region Properties
    private string fieldName;

    /// <summary>
    /// Name of the parameter
    /// </summary>
    public string FieldName
    {
      get { return fieldName; }
      set { fieldName = value; }
    }

    private object fieldValue;

    /// <summary>
    /// Value of the parameter
    /// </summary>
    public object FieldValue
    {
      get { return fieldValue; }
      set { fieldValue = value; }
    }

    private Type fieldDataType;
    /// <summary>
    /// Data type of the FieldValue
    /// </summary>
    public Type FieldDataType
    {
      get { return fieldDataType; }
      set { fieldDataType = value; }
    }
    #endregion
  }

  /// <summary>
  /// Represents the information necessary to call a sql query with optional parameters
  /// Query can be represented by either QueryName and Path, or SQLString
  /// </summary>
  public class SQLQueryInfo
  {
    #region Properties
    private string sqlString;

    /// <summary>
    /// SQL query string that should be executed
    /// </summary>
    public string SQLString
    {
      get { return sqlString; }
      set { sqlString = value; }
    }

    private string queryName;
    /// <summary>
    /// Name of the stored procedure. Must have a valid QueryDir
    /// </summary>
    public string QueryName
    {
      get
      {
        return queryName;
      }
      set
      {
        queryName = value;
      }
    }

    private string queryDir;
    /// <summary>
    /// Path to the stored proc, defined by QueryName
    /// </summary>
    public string QueryDir
    {
      get{return queryDir;}
      set{queryDir = value;}
    }

    /// <summary>
    /// List of Parameters to the stored procedure
    /// </summary>
    public List<SQLQueryParam> Params = new List<SQLQueryParam>();
    #endregion

    #region Methods
    public static SQLQueryInfo Extract(string encString)
    {
      //decrypt query info
      QueryStringEncrypt qse = new QueryStringEncrypt();
      string json = qse.DecryptString(encString);

      JavaScriptSerializer jss = new JavaScriptSerializer();
      jss.RegisterConverters(new JavaScriptConverter[] { new MetraTech.UI.Tools.DateTimeConverter() });

      SQLQueryInfo qi = jss.Deserialize<SQLQueryInfo>(json);

      return qi;
    }

    public static string Compact(SQLQueryInfo qi)
    {
      string json = Tools.Converter.GetJSON(qi);

      //encrypt json
      QueryStringEncrypt qse = new QueryStringEncrypt();
      return qse.EncryptString(json);
    }
    #endregion
  }
}

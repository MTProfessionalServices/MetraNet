using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Diagnostics;
using System.Text.RegularExpressions;
using MetraTech.DataAccess.OleDb;
using MetraTech.DataAccess.Oracle;
using MetraTech.Performance;
using Oracle.DataAccess.Client;
using Oracle.DataAccess.Types;
  
namespace MetraTech.DataAccess
{
	/// <remarks>
	/// </remarks>
	public class Statement : IMTStatement, IDisposable
	{
		protected IDbCommand mCommand;
		internal IDbCommand Command
		{
			get { return mCommand; }
		}

		internal event ExecuteEventHandler BeforeExecute;

		internal event ExecuteEventHandler AfterExecute;

		protected virtual void OnBeforeExecute()
		{
			if (BeforeExecute != null)
			{
				BeforeExecute(this, null);
			}
		}

		protected virtual void OnAfterExecute()
		{
			if (AfterExecute != null)
			{
				AfterExecute(this, null);
			}
		}

		internal Statement(IDbCommand cmd)
		{
			mCommand = cmd;
		}

		internal Statement(IDbCommand cmd, string aQuery)
		{
			mCommand = cmd;
			mCommand.CommandText = aQuery;
		}

    ~Statement()
    {
      Dispose();
    }

    public virtual void Dispose()
    {
      if (mCommand != null)
      {
          // eat all the errors, don't watn finalizer thead to crush
          try
          {
              mCommand.Dispose();
          }
          catch (Exception) { }
          finally
          {
              mCommand = null;
          }
      }

      GC.SuppressFinalize(this);
    }

    protected int Convert(MetraTech.DataAccess.MTParameterType type, IDbCommand command, ref IDataParameter param)
    {
      if (mCommand is MTOracleCommand)
      {
          if (type == MTParameterType.Blob)
          {
              ((OracleParameter)param).OracleDbType = OracleDbType.Blob;
          }
          else if (type == MTParameterType.Guid)
          {
              ((OracleParameter)param).OracleDbType = OracleDbType.Raw;
          }
          else
          {
              Convert(type, ref param);
          }
      }
      else
      {
        return Convert(type, ref param);
      }

      return 0;
    }

        internal static int Convert(MetraTech.DataAccess.MTParameterType type, ref IDataParameter param)
		{
			switch(type)
			{
				case MetraTech.DataAccess.MTParameterType.Integer:
					param.DbType = DbType.Int32;
          break;
				case MetraTech.DataAccess.MTParameterType.Boolean:
				case MetraTech.DataAccess.MTParameterType.String:
					param.DbType = DbType.AnsiString;
          break;
				case MetraTech.DataAccess.MTParameterType.WideString:
					param.DbType = DbType.String;
          break;
				case MetraTech.DataAccess.MTParameterType.DateTime:
					param.DbType = DbType.DateTime;
          break;
				case MetraTech.DataAccess.MTParameterType.Binary:
        case MetraTech.DataAccess.MTParameterType.Blob:
					param.DbType = DbType.Binary;
          break;
				case MetraTech.DataAccess.MTParameterType.Decimal:
					param.DbType = DbType.Decimal;
          break;
				case MetraTech.DataAccess.MTParameterType.BigInteger:
					param.DbType = DbType.Int64;
          break;
        case MetraTech.DataAccess.MTParameterType.NText:
          param.DbType = DbType.String;
          break;
        case MetraTech.DataAccess.MTParameterType.Text:
          param.DbType = DbType.AnsiString;
          break;
        case MetraTech.DataAccess.MTParameterType.Guid:
          param.DbType = DbType.Guid;
          break;
          //if (Command is System.Data.OleDb.OleDbCommand)
          // if (param is System.Data.OleDb.OleDbParameter)
          //{
          //  ((System.Data.OleDb.OleDbParameter)(param)).OleDbType = OleDbType.LongVarChar;   
          //  // what happens to DbType when OleDbType is set to LongVarChar
          //   break;
          //}
          //else
          //{
          //  throw new DataAccessException("Text Parameter Type is not supported.");
          //}
      
				default:
					throw new DataAccessException("Unsupported Parameter Type: " + type);
			}
      return 0;
		}

		/// <summary>
		/// Used to execute statements that do not return resultsets.
		/// </summary>
		public virtual int ExecuteNonQuery()
		{
			OnBeforeExecute();
            int ret = Command.ExecuteNonQuery();
            OnAfterExecute();
            GC.KeepAlive(this);
			return ret;
		}


		/// <summary>
		/// Used to execute statements that return resultsets.
		/// </summary>
		public virtual IMTDataReader ExecuteReader()
		{
			OnBeforeExecute();
			IMTDataReader ret = null;
            IDataReader nativereader = Command.ExecuteReader();
            //TODO: do it in corresponding Command classes
			if(nativereader is OracleDataReader)
					ret = new MTOracleDataReader(nativereader);
			else //if (nativereader is OleDbDataReader)
				ret = new MTOleDbDataReader(nativereader);
			Debug.Assert(ret != null);
			OnAfterExecute();
            GC.KeepAlive(this);
			return ret;
		}
	}

    public class SortCriteria
    {
        public SortCriteria(string property, SortDirection direction)
        {
            Property = property;
            Direction = direction;
        }

        public string Property { get; set; }
        public SortDirection Direction { get; set; }
    }

    public abstract class BaseFilterElement
    {
      public abstract string FilterClause(DBType db);
    }

    public class BinaryFilterElement : BaseFilterElement
    {
        public enum BinaryOperatorType
        {
            AND = 0,
            OR = 1
        };

        public BinaryFilterElement(BaseFilterElement leftHandElement,
                                      BinaryOperatorType operatorType,
                                      BaseFilterElement rightHandElement)
        {
            m_LeftHandElement = leftHandElement;
            m_OperatorType = operatorType;
            m_RightHandElement = rightHandElement;
        }

        #region Public Properties
        public BaseFilterElement LeftHandElement { get { return m_LeftHandElement; } }
        public BinaryOperatorType OperatorType { get { return m_OperatorType; } }
        public BaseFilterElement RightHandElement { get { return m_RightHandElement; } }

        public override string FilterClause (DBType db)
        {
            return string.Format("({0} {1} {2})", m_LeftHandElement.FilterClause(db), m_OperatorType.ToString(), m_RightHandElement.FilterClause(db));
        }
        #endregion

        #region Private Members
        private BaseFilterElement m_LeftHandElement = null;
        private BinaryOperatorType m_OperatorType;
        private BaseFilterElement m_RightHandElement = null;
        #endregion
    }

  public class FilterElement : BaseFilterElement
  {
    #region Public Enums
    public enum OperationType
    {
      Like = 1,
      Like_W,
      Equal,
      NotEqual,
      Greater,
      GreaterEqual,
      Less,
      LessEqual,
      In,
      IsNull,
      IsNotNull
    };
    #endregion

    public FilterElement(string propertyName, OperationType op, object value)
    {
      m_PropertyName = propertyName;
      m_OperationType = op;
      m_Value = value;
    }

    #region Public Properties
    public string PropertyName { get { return m_PropertyName; } }
    public OperationType Operation { get { return m_OperationType; } }
    public object Value { get { return m_Value; } }

    public override string FilterClause(DBType db)
    {
      string propertyName;
      if ((m_Value.GetType().ToString() == "System.String") || (m_Value.GetType().ToString() == "System.Boolean"))
      {
        propertyName =
          db == DBType.Oracle
            ? string.Format("{0}({1})", Operation == OperationType.In ? string.Empty : "upper", m_PropertyName)
            : m_PropertyName;
      }
      else
      {
        propertyName = m_PropertyName;
      }
      string clause = string.Format("{0} {1} {2}", propertyName, FormatOperation(), FormatValue(db));

      return clause;
    }

    #endregion
    
    #region Private Methods
    private string FormatOperation()
    {
      string retval = "";

      switch (m_OperationType)
      {
        case OperationType.Like:
        case OperationType.Like_W:
          retval = "like";
          break;
        case OperationType.Equal:
          retval = "=";
          break;
        case OperationType.NotEqual:
          retval = "!=";
          break;
        case OperationType.Greater:
          retval = ">";
          break;
        case OperationType.GreaterEqual:
          retval = ">=";
          break;
        case OperationType.Less:
          retval = "<";
          break;
        case OperationType.LessEqual:
          retval = "<=";
          break;
        case OperationType.In:
          retval = "in";
          break;
        case OperationType.IsNull:
          retval = "is";
          break;
        case OperationType.IsNotNull:
          retval = "is not";
          break;
      }

      return retval;
    }

    private string FormatValue(DBType db)
    {
      string retval;
      
      // IN operator processing
      if (m_OperationType == OperationType.In)
      {
          retval = string.Format("({0})", m_Value != null ? m_Value : "null");
      }
      else if (m_Value != null) // other operators
      {
        switch (m_Value.GetType().ToString())
        {
          case "System.String":
            retval = string.Format("'{0}'", m_Value.ToString().Replace("'", "''"));
            if (db == DBType.Oracle)
            {
              retval = retval.ToLower();
            }
            break;
          case "System.Time":
          case "System.boolean":
            retval = string.Format("'{0}'", m_Value.ToString().Replace("'","''"));
            break;
          case "System.DateTime":
            if (db == DBType.Oracle)
            {
              retval = string.Format("TO_DATE('{0}', 'MM/DD/YYYY HH:MI:SS AM')", m_Value.ToString());
            }
            else
            {
              retval = string.Format("'{0}'", m_Value.ToString().Replace("'", "''"));
            }
            break;
          default:
            retval = string.Format("{0}", m_Value.ToString());
            break;
        }
      }
      else
      {
        return "null";
      }

      return retval;
    }
    #endregion

    #region Private Members
    private string m_PropertyName;
    private OperationType m_OperationType;
    private object m_Value;
    #endregion
  }

  public class FilterSortStatement : MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement, IMTFilterSortStatement, IDisposable
  {
    #region Private Members
    private List<BaseFilterElement> m_Filters = new List<BaseFilterElement>();

    private int m_PageSize = -1;
    private int m_CurrentPage = -1;

    private int m_TotalRows = 0;

    private MetraTech.Interop.QueryAdapter.IMTQueryAdapter mQueryAdapter;

    private string m_InnerQuery;
    private string m_OrderByText;

    private const string TEMP_TABLE_BASE = "QSFTemp";
    #endregion

    public FilterSortStatement(IDbCommand cmd, string configDir, string queryTag)
      : base(cmd, configDir, queryTag)
    {
      mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
      mQueryAdapter.Init(@"Queries\Database");

      this.SortCriteria = new List<SortCriteria>();
    }

    public FilterSortStatement(IDbCommand cmd, string queryText)
      : base(cmd, queryText)
    {
      mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
      mQueryAdapter.Init(@"Queries\Database");

      this.SortCriteria = new List<SortCriteria>();
    }

    void FilterSortQuery(DBType databaseType)
    {
      m_InnerQuery = base.Query;

      int startingIndex = 0;


      m_InnerQuery = Regex.Replace(m_InnerQuery, "OVER\\s*\\(", "OVER (", RegexOptions.IgnoreCase);
      m_InnerQuery = Regex.Replace(m_InnerQuery, "ORDER\\s*BY", "ORDER BY", RegexOptions.IgnoreCase);

      if (m_InnerQuery.ToUpper().Contains("OVER(") || m_InnerQuery.ToUpper().Contains("OVER ("))
      {
          startingIndex = Math.Max(m_InnerQuery.ToUpper().LastIndexOf("OVER("), m_InnerQuery.ToUpper().LastIndexOf("OVER ("));
          startingIndex = m_InnerQuery.ToUpper().IndexOf("ORDER BY", startingIndex) + 8;
      }

      //select top 10 * from (select top 10 * from t_account order by id_acc desc, id_acc_ext) a order by a.dt_crt
      //Below logic for above query will fetch the wrong order by clause . ie from Derived Query not the final Query.  
      // changing logic to use lastindexof instead of index of.

      if ( (startingIndex > 0 && m_InnerQuery.ToUpper().LastIndexOf("ORDER BY") + 8 > startingIndex) ||
           (startingIndex <= 0 &&  m_InnerQuery.ToUpper().LastIndexOf("ORDER BY") > 0 ))
      {
          int startIndex = m_InnerQuery.ToUpper().LastIndexOf("ORDER BY");

          int endIndex = m_InnerQuery.ToUpper().IndexOf(")", startIndex);

          //Do no remove order by clause if close-bracket encountered. it may be a subquery, derived table etc.
          if (endIndex == -1)
          {
              endIndex = m_InnerQuery.Length;
              m_OrderByText = m_InnerQuery.Substring(startIndex, endIndex - startIndex);
              m_InnerQuery = m_InnerQuery.Remove(startIndex, endIndex - startIndex);
          }

      }

      if (m_Filters.Count > 0 )
      {
        m_InnerQuery = string.Format("Select * from ({0}) rootQuery", m_InnerQuery);

        if (m_Filters.Count > 0)
        {
          m_InnerQuery += " WHERE " + m_Filters[0].FilterClause(databaseType);

          for (int i = 1; i < m_Filters.Count; i++)
          {
            m_InnerQuery += " AND " + m_Filters[i].FilterClause(databaseType);
          }
        }
      }

      if (SortCriteria != null && SortCriteria.Count > 0)
      {
          
          //Append Order-By from Query at the end of sort column with comma.
          string orderByText = "ORDER BY ";

          foreach (SortCriteria criteria in SortCriteria)
          {
              orderByText += string.Format("{0} {1}, ", criteria.Property,
                (criteria.Direction == SortDirection.Descending ? "DESC" : string.Empty));
          }

          m_OrderByText = string.Format("{0}{1}", orderByText.Substring(0, orderByText.Length - 2),
                    Regex.Replace(m_OrderByText ?? string.Empty, "ORDER\\s*BY", ",", RegexOptions.IgnoreCase));
      }

      base.Command.CommandText = m_InnerQuery;
      m_InnerQuery = base.Command.CommandText;
      base.Command.CommandText = "";
    }

    ~FilterSortStatement()
    {
      Dispose();
    }

    public override void Dispose()
    {
      mQueryAdapter = null;
      m_Filters.Clear();

      base.Dispose();

      GC.SuppressFinalize(this);
    }

    /// <summary>
    /// Used to execute statements that return resultsets.
    /// </summary>
    public override IMTDataReader ExecuteReader()
    {
      IMTDataReader ret = null;

      OnBeforeExecute();

      //Guid tblid = Guid.NewGuid();
        
      //string tmpTable = string.Format("{0}_{1}", TEMP_TABLE_BASE, Math.Abs(tblid.ToString("N").GetHashCode()));

      ConnectionInfo connInfo = new ConnectionInfo("NetMeterStage");

      // Parse query to generate parts
      FilterSortQuery(connInfo.DatabaseType);

      Command.CommandText = "FilterSortQuery_v3";
      Command.CommandType = CommandType.StoredProcedure;

      IDbDataParameter param = Command.CreateParameter();
      param.ParameterName = "InnerQuery";
      param.DbType = DbType.String;

      //CORE-5352 So, the conclusion - if you use the '*' as a SELECT list for all the queries in an UNION, then you cannot reference to the columns by their names in an ORDER BY clause.
      param.Value = mQueryAdapter.IsOracle() 
                      ? String.Format("SELECT * FROM ({0})", m_InnerQuery)
                      : m_InnerQuery;

      Command.Parameters.Add(param);

      param = Command.CreateParameter();
      param.ParameterName = "OrderByText";
      param.DbType = DbType.String;
      param.Value = (m_OrderByText != null ? m_OrderByText : "");
      Command.Parameters.Add(param);

      param = Command.CreateParameter();
      param.ParameterName = "StartRow";
      param.DbType = DbType.Int32;
      param.Value = ((m_CurrentPage > 0 && m_PageSize > 0) ? ((m_CurrentPage - 1) * m_PageSize) + 1 : 0);
      Command.Parameters.Add(param);

      param = Command.CreateParameter();
      param.ParameterName = "NumRows";
      param.DbType = DbType.Int32;
      param.Value = m_PageSize;
      Command.Parameters.Add(param);

      if (mQueryAdapter.IsOracle())
      {
        OracleParameter oraParam = (OracleParameter)Command.CreateParameter();
        oraParam.OracleDbType = OracleDbType.RefCursor;
        oraParam.Direction = ParameterDirection.Output;
        oraParam.ParameterName = "TotalRows";
        Command.Parameters.Add(oraParam);

        oraParam = (OracleParameter)Command.CreateParameter();
        oraParam.OracleDbType = OracleDbType.RefCursor;
        oraParam.Direction = ParameterDirection.Output;
        oraParam.ParameterName = "Rows";
        Command.Parameters.Add(oraParam);
      }

      var performanceStopWatch = new PerformanceStopWatch();
      performanceStopWatch.Start();
      IDataReader nativereader = Command.ExecuteReader();
      performanceStopWatch.Stop(Command.CommandText);

      if (nativereader.Read())
      {
        m_TotalRows = System.Convert.ToInt32(nativereader.GetValue(0));
      }

      nativereader.NextResult();

      //TODO: do it in corresponding Command classes
      if (nativereader is OracleDataReader)
        ret = new MTOracleDataReader(nativereader);
      else //if (nativereader is OleDbDataReader)
        ret = new MTOleDbDataReader(nativereader);

      Debug.Assert(ret != null);

      OnAfterExecute();
      GC.KeepAlive(this);
      return ret;
    }

    #region IMTFilterSortStatement Members

    public void AddFilter(BaseFilterElement filter)
    {
      m_Filters.Add(filter);
    }

    public void ClearFilters()
    {
      m_Filters.Clear();
    }

    public int PageSize
    {
      get
      {
        return m_PageSize;
      }
      set
      {
        m_PageSize = value;
      }
    }

    public int CurrentPage
    {
      get
      {
        return m_CurrentPage;
      }
      set
      {
        m_CurrentPage = value;
      }
    }

    public int TotalRows
    {
      get { return m_TotalRows; }
    }

    public List<SortCriteria> SortCriteria { get; set; }

    #endregion
  }

  public class MTMultiSelectAdapterStatement : MetraTech.DataAccess.PreparedFilterSortStatement.AdapterStatement, IMTMultiSelectAdapterStatement, IDisposable
  {
      #region Private Members
      private int m_SelectCount = 0;

      private MetraTech.Interop.QueryAdapter.IMTQueryAdapter mQueryAdapter;
      #endregion

      public MTMultiSelectAdapterStatement(IDbCommand cmd, string configDir, string queryTag)
          : base(cmd, configDir, queryTag)
      {
          mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
          mQueryAdapter.Init(@"Queries\Database");
      }

       public MTMultiSelectAdapterStatement(IDbCommand cmd, string queryText)
      : base(cmd, queryText)
    {
      mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
      mQueryAdapter.Init(@"Queries\Database");
    }

    ~MTMultiSelectAdapterStatement()
    {
      Dispose();
    }

    public override void Dispose()
    {
      mQueryAdapter = null;
      base.Dispose();

      GC.SuppressFinalize(this);
    }

    /// <summary>
    /// Used to execute statements that return resultsets.
    /// </summary>
    public override IMTDataReader ExecuteReader()
    {
      if (mQueryAdapter.IsOracle())
      {
          for (int i = 0; i < m_SelectCount; i++)
          {
              OracleParameter oraParam = (OracleParameter)Command.CreateParameter();
              oraParam.OracleDbType = OracleDbType.RefCursor;
              oraParam.Direction = ParameterDirection.Output;
              oraParam.ParameterName = string.Format("result{0}",i);
              Command.Parameters.Add(oraParam);
          }
      }

      return base.ExecuteReader();
    }

    #region IMTMultiSelectAdapterStatement Members

    public void SetResultSetCount(int count)
    {
        m_SelectCount = count;
    }

    #endregion
  }

	/// <remarks>
	/// A callable statement represents a stored procedure that can be executed against
	/// a database.  Stored procedures can have a number of input parameters, a number of
	/// output parameters and can return a result set.
	/// </remarks>
	public class CallableStatement : Statement, IMTCallableStatement, IDisposable
	{
		/// <summary>
		/// Use ExecuteReader to execute a stored procedure that returns a result set.
		/// HOW ARE OUTPUT PARAMETERS HANDLED?  I DON'T THINK THEY CAN BE ACCESSED UNTIL
		/// AFTER THE READER IS CLOSED.
		/// </summary>
		public override IMTDataReader ExecuteReader()
		{
			//just keep this method here for the sake of comments
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();
            var reader = base.ExecuteReader();
            performanceStopWatch.Stop(Command.CommandText);
            return reader;
		}

		/// <summary>
		/// Use ExecuteReader to execute a stored procedure that does not return a result set.  The
		/// stored procedure may have output parameters.
		/// </summary>
		public override int ExecuteNonQuery()
		{
			//just keep this method here for the sake of comments
            //var performanceStopWatch = new PerformanceStopWatch();
            //performanceStopWatch.Start();
            var returnValue = base.ExecuteNonQuery();
            //performanceStopWatch.Stop(Command.CommandText);
            return returnValue;
		}

		/// <summary>
		/// Adds an input parameter value to a stored procedure.
		/// </summary>
		public virtual void AddParam(String name, MetraTech.DataAccess.MTParameterType type, Object value)
		{
			IDataParameter param = Command.CreateParameter();
      Convert(type, Command, ref param);
			param.Direction = ParameterDirection.Input;
			param.ParameterName = name;
			
			if (value == null)
				param.Value = DBNull.Value;

			else if (type == MTParameterType.Boolean)
			{
				if ((bool) value == true)
					param.Value = "Y";
				else
					param.Value = "N";
			}

            // Oracle treats empty strings as NULL, to avoid this we assign out own empty string value
            // in place of "".
			else if (Command is MTOracleCommand &&
                     (type == MTParameterType.String ||
                      type == MTParameterType.WideString ||
                      type == MTParameterType.NText ||
                      type == MTParameterType.Text) &&
                      value.ToString() == "")
            {
                param.Value = MTEmptyString.Value;
            }
			else if (Command is MTOracleCommand &&
							(type == MTParameterType.String ||
							 type == MTParameterType.WideString ||
							 type == MTParameterType.NText ||
							 type == MTParameterType.Text) &&
							 value.ToString() != "")
			{
				param.Value = ParseOutODBCEscapes(value.ToString());
			}
			else
                param.Value = value;

			Command.Parameters.Add(param);
		}

		/// <summary>
		/// Deprecated, use AddOutputParam() instead
		/// </summary>
		public virtual void AddParam(String name, MetraTech.DataAccess.MTParameterType type)
		{
			AddOutputParam(name, type, 0);
		}

		/// <summary>
		/// Declares an output parameter of the stored procedure.
		/// </summary>
		public virtual void AddOutputParam(String name, MetraTech.DataAccess.MTParameterType type)
		{
			AddOutputParam(name, type, 0);
		}

		/// <summary>
		/// Declares an output parameter of the stored procedure. With its size
		/// </summary>
		public virtual void AddOutputParam(String name, MetraTech.DataAccess.MTParameterType type, int size)
		{
			IDbDataParameter param = Command.CreateParameter();
            IDataParameter temp = (IDataParameter)param;
			param.Size = size;
      Convert(type, Command, ref temp);
			if (type == MetraTech.DataAccess.MTParameterType.Decimal)
			{
				param.Precision = Constants.METRANET_PRECISION_MAX;
				param.Scale = Constants.METRANET_SCALE_MAX;
			}
			param.Direction = ParameterDirection.Output;
			param.ParameterName = name;
			Command.Parameters.Add(param);
		}

		/// <summary>
		/// Declare the return value of the stored procedure.
		/// </summary>
		public virtual void AddReturnValue(MetraTech.DataAccess.MTParameterType type)
		{
			Debug.Assert(Command.Parameters.Count == 0,
				"Return value must be before any other parameters");
			IDataParameter param = Command.CreateParameter();
      Convert(type, Command, ref param);
			param.Direction = ParameterDirection.ReturnValue;
			Command.Parameters.Add(param);
		}

		/// <summary>
		/// Retrieve the value of an output parameter of a stored procedure.
		/// </summary>
		public virtual Object GetOutputValue(String name)
		{
            IDataParameter param = (IDataParameter)Command.Parameters[name];
            if (Command is MTOracleCommand &&
                (param.DbType == DbType.AnsiString ||
                param.DbType == DbType.String ||
                (param is System.Data.OleDb.OleDbParameter &&
                 ((System.Data.OleDb.OleDbParameter)(param)).OleDbType == OleDbType.LongVarChar)) &&
                param.Value.ToString() == MTEmptyString.Value)
            {
                return "";
            }
            else
                return param.Value;
		}   

		/// <summary>
    /// Retrieve the value of an output parameter of a stored procedure as a boolean.
    /// Most types returned as objects can be converted to strings and to the appropriate type
    /// but not our famous booleans. As the saga continues, have added this method to match
    /// AddParam handling of 'Y' and 'N' booleans. Intentially did not add other values
    /// not handled symetrically also by AddParam
    /// </summary>
    public virtual bool GetOutputValueAsBoolean(String name)
    {
      string tempReturnValue = "";
      try
      {
        tempReturnValue = GetOutputValue(name).ToString().Trim();
        if (!String.IsNullOrEmpty(tempReturnValue) && tempReturnValue.Length == 1)
        {
          char tempReturned = tempReturnValue[0];
          if ((tempReturned == 'Y') || (tempReturned == 'y'))
            return true;
          else if ((tempReturned == 'N') || (tempReturned == 'n'))
            return false;
        }
      }
      catch (Exception ex)
      {
        throw new Exception(String.Format("GetOutputValueAsBoolean: Unable to convert the value '{0}' to a boolean. Either the value was null or not 'Y' or 'N';{1}", tempReturnValue, ex.Message), ex);
      }

      throw new Exception(String.Format("GetOutputValueAsBoolean: Unable to convert the value '{0}' to a boolean. Either the value was null or not 'Y' or 'N'.", tempReturnValue));
    }  

		/// <summary>
		/// Retrieve the value of an output parameter of a stored procedure.
		/// </summary>
		public virtual Object ReturnValue
		{
			get
			{
				Debug.Assert(((IDataParameter)Command.Parameters[0]).Direction == ParameterDirection.ReturnValue,
					"Return value not specified as a parameter");

                IDataParameter param = (IDataParameter)Command.Parameters[0];
                if (Command is MTOracleCommand && 
                    (param.DbType == DbType.AnsiString ||
                    param.DbType == DbType.String ||
                    (param is System.Data.OleDb.OleDbParameter &&
                     ((System.Data.OleDb.OleDbParameter)(param)).OleDbType == OleDbType.LongVarChar)) &&
                    param.Value.ToString() == MTEmptyString.Value)
                {
                    return "";
                }
                else
                    return param.Value;
			}
		}

		public CallableStatement(IDbCommand cmd, String sprocName)
			: 
			base(cmd)
		{
			Command.CommandText = sprocName;
			Command.CommandType = CommandType.StoredProcedure;
		}

        ~CallableStatement()
        {
            Dispose();
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
	}
	/// <remarks>
	/// A prepared statement represents a parameterized SQL statement.
	/// These statements can have any number of positional parameters
	/// </remarks>
	public class PreparedStatement : Statement, IMTPreparedStatement, IDisposable
	{
        private int m_SelectCount = 0;

		/// <summary>
		/// Adds a positional parameter.
		/// </summary>
		public virtual void AddParam(MetraTech.DataAccess.MTParameterType type, Object value)
		{           
            AddParam((Command.Parameters.Count + 1).ToString(), type, value);
		}

        public void AddParam(string paramName, MetraTech.DataAccess.MTParameterType type, Object value)
        {
            IDataParameter param = Command.CreateParameter();
      Convert(type, Command, ref param);
            param.Direction = ParameterDirection.Input;
            param.ParameterName = string.Format("{0}{1}", 
                (Command is MTOracleCommand ? ':' : '@'),
                paramName);

            if (value == null)
                param.Value = DBNull.Value;
            else
            {
                if (Command is MTOracleCommand)
                {
                    if ((type == MetraTech.DataAccess.MTParameterType.String ||
                      type == MetraTech.DataAccess.MTParameterType.WideString ||
                      type == MetraTech.DataAccess.MTParameterType.NText ||
                      type == MetraTech.DataAccess.MTParameterType.Text) &&
                     value.ToString() == "")
                        param.Value = MTEmptyString.Value;
                    else if (type == MTParameterType.Guid)
                        param.Value = ((Guid)value).ToByteArray();
                    else
                        param.Value = value;

                    ((MTOracleCommand)base.mCommand).BindByName = true;
                }
                else
                {
                    param.Value = value;
                }

            }

            Command.Parameters.Add(param);
        }

		/// <summary>
		/// Clear all parameter bindings
		/// </summary>
		public virtual void ClearParams()
		{
			Command.Parameters.Clear();
		}

		public PreparedStatement(IDbCommand cmd, String sqlText)
			: 
			base(cmd)
		{
			//BP: Note!!!
			//We are used to passing '?' as parameter place markers
			//in ADO/SQL Server. However Oracle doesn't like that and
			//it wants ':1, :2 etc' instead. Examine cmd RT here and replace
			// '?' with positions
			string text = sqlText;
            char replacementChar = '@';

            if (cmd is MTOracleCommand)
            {
                replacementChar = ':';

                text = text.Replace('@', ':');
            }

            int pos = 1;
            int idx = -1;
            while ((idx = text.IndexOf('?')) > 0 == true)
            {
                text = text.Remove(idx, 1);
                text = text.Insert(idx, string.Format("{0}{1}", replacementChar, pos++));
            }

			Command.CommandText = text;
			Command.CommandType = CommandType.Text;
		}

        ~PreparedStatement()
        {
            Dispose();
	}

        public override IMTDataReader ExecuteReader()
        {
            if (base.mCommand is MTOracleCommand)
            {
                for (int i = 0; i < m_SelectCount; i++)
                {
                    OracleParameter oraParam = (OracleParameter)Command.CreateParameter();
                    oraParam.OracleDbType = OracleDbType.RefCursor;
                    oraParam.Direction = ParameterDirection.Output;
                    oraParam.ParameterName = string.Format(":RESULT{0}", i);
                    Command.Parameters.Add(oraParam);
                }
            }
            return base.ExecuteReader();
        }

        public void SetResultSetCount(int count)
        {
            m_SelectCount = count;
        }
	}

    public class PreparedFilterSortStatement : Statement, IMTPreparedFilterSortStatement, IDisposable
    {
        #region Private Members
        private string m_Query;

        private List<BaseFilterElement> m_Filters = new List<BaseFilterElement>();

        private int m_PageSize = -1;
        private int m_CurrentPage = -1;

        private int m_TotalRows = 0;

        private MTComSmartPtr<MetraTech.Interop.QueryAdapter.IMTQueryAdapter> mQueryAdapter = new MTComSmartPtr<MetraTech.Interop.QueryAdapter.IMTQueryAdapter>();

        private string m_InnerQuery;
        private string m_OrderByText;
        #endregion

        public PreparedFilterSortStatement(IDbCommand cmd, String sqlText)
            : base(cmd)
        {
            MaxTotalRows = 0;

            //BP: Note!!!
            //We are used to passing '?' as parameter place markers
            //in ADO/SQL Server. However Oracle doesn't like that and
            //it wants ':1, :2 etc' instead. Examine cmd RT here and replace
            // '?' with positions
            string text = sqlText;
            char replacementChar = '@';

            if (cmd is MTOracleCommand)
            {
                replacementChar = ':';

                text = text.Replace('@', ':');

                ((MTOracleCommand)base.mCommand).BindByName = true;
            }

            int pos = 1;
            int idx = -1;
            while ((idx = text.IndexOf('?')) > 0 == true)
            {
                text = text.Remove(idx, 1);
                text = text.Insert(idx, string.Format("{0}{1}", replacementChar, pos++));
            }

            m_Query = text;

            mQueryAdapter.Item = new MetraTech.Interop.QueryAdapter.MTQueryAdapterClass();
            mQueryAdapter.Item.Init(@"queries\Database");

            SortCriteria = new List<DataAccess.SortCriteria>();
        }

        ~PreparedFilterSortStatement()
        {
            Dispose();
        }

        /// <summary>
        /// Used to execute statements that return resultsets.
        /// </summary>
        public override IMTDataReader ExecuteReader()
        {
            IMTDataReader ret = null;

            ConnectionInfo connInfo = new ConnectionInfo("NetMeterStage");

            // Parse query to generate parts
            FilterSortQuery(connInfo.DatabaseType);

            mQueryAdapter.Item.SetQueryTag("__FILTER_SORT_PARAM_QUERY__");
            mQueryAdapter.Item.AddParam("%%INNER_QUERY%%", m_InnerQuery, true);
            mQueryAdapter.Item.AddParamIfFound("%%ORDER_BY_TEXT%%", 
                    (string.IsNullOrEmpty(m_OrderByText) ? 
                        (!mQueryAdapter.Item.IsOracle() ? "ORDER BY (Select 1)" : "") : m_OrderByText), true);

            string topRows = "";
            if (MaxTotalRows > 0)
            {
                if (Command is MTOracleCommand)
                {
                    topRows = string.Format("where rownum <= {0}", MaxTotalRows);
                }
                else
                {
                    topRows = string.Format("top {0}", MaxTotalRows);
                }
            }

            mQueryAdapter.Item.AddParamIfFound("%%TOP_ROWS%%", topRows);

            Command.CommandText = mQueryAdapter.Item.GetQuery();
            Command.CommandType = CommandType.Text;

            IDbDataParameter param = Command.CreateParameter();
            param.ParameterName = string.Format("{0}StartRow", (!mQueryAdapter.Item.IsOracle() ? "@" : ":"));
            param.DbType = DbType.Int32;
            param.Value = ((m_CurrentPage > 0 && m_PageSize > 0) ? ((m_CurrentPage - 1) * m_PageSize) + 1 : 0);
            Command.Parameters.Add(param);

            param = Command.CreateParameter();
            param.ParameterName = string.Format("{0}EndRow", (!mQueryAdapter.Item.IsOracle() ? "@" : ":"));
            param.DbType = DbType.Int32;
            if((m_CurrentPage > 0 && m_PageSize > 0))
            {
                param.Value = (m_CurrentPage * m_PageSize);
            }
            else
            {
                param.Value = DBNull.Value;
            }
            Command.Parameters.Add(param);

            if (mQueryAdapter.Item.IsOracle())
            {
                OracleParameter oraParam = (OracleParameter)Command.CreateParameter();
                oraParam.OracleDbType = OracleDbType.RefCursor;
                oraParam.Direction = ParameterDirection.Output;
                oraParam.ParameterName = ":TotalRows";
                Command.Parameters.Add(oraParam);

                oraParam = (OracleParameter)Command.CreateParameter();
                oraParam.OracleDbType = OracleDbType.RefCursor;
                oraParam.Direction = ParameterDirection.Output;
                oraParam.ParameterName = ":Rows";
                Command.Parameters.Add(oraParam);
            }

            OnBeforeExecute();

            IDataReader nativereader = Command.ExecuteReader();

            if(nativereader.Read())
            {
                m_TotalRows = System.Convert.ToInt32(nativereader.GetValue(0));
            }

            nativereader.NextResult();

            //TODO: do it in corresponding Command classes
            if (nativereader is OracleDataReader)
                ret = new MTOracleDataReader(nativereader);
            else //if (nativereader is OleDbDataReader)
                ret = new MTOleDbDataReader(nativereader);

            Debug.Assert(ret != null);

            OnAfterExecute();
            GC.KeepAlive(this);
            return ret;
        }

        #region IMTPreparedFilterSortStatement Members

        public void AddParam(string paramName, MetraTech.DataAccess.MTParameterType type, Object value)
        {
            IDataParameter param = Command.CreateParameter();
      Convert(type, Command, ref param);
            param.Direction = ParameterDirection.Input;

            if (value == null)
                param.Value = DBNull.Value;
            else
            {
                if (Command is MTOracleCommand)
                {
                    if ((type == MetraTech.DataAccess.MTParameterType.String ||
                      type == MetraTech.DataAccess.MTParameterType.WideString ||
                      type == MetraTech.DataAccess.MTParameterType.NText ||
                      type == MetraTech.DataAccess.MTParameterType.Text) &&
                     value.ToString() == "")
                        param.Value = MTEmptyString.Value;
                    else if (type == MTParameterType.Guid)
                    {
                        param.Value = ((Guid)value).ToByteArray();
                    }
                    else
                        param.Value = value;

                    param.ParameterName = string.Format(":{0}", paramName);

                    ((MTOracleCommand)base.mCommand).BindByName = true;
                }
                else
                {
                    param.ParameterName = string.Format("@{0}", paramName);

                    param.Value = value;
                }

            }

            Command.Parameters.Add(param);
        }

        /// <summary>
        /// Clear all parameter bindings
        /// </summary>
        public virtual void ClearParams()
        {
            Command.Parameters.Clear();
        }

        public void AddFilter(BaseFilterElement filter)
        {
            m_Filters.Add(filter);
        }

        public void ClearFilters()
        {
            m_Filters.Clear();
        }

        public List<SortCriteria> SortCriteria { get; set; }

        public int PageSize
        {
            get
            {
                return m_PageSize;
            }
            set
            {
                m_PageSize = value;
            }
        }

        public int CurrentPage
        {
            get
            {
                return m_CurrentPage;
            }
            set
            {
                m_CurrentPage = value;
            }
        }

        public int TotalRows
        {
            get { return m_TotalRows; }
        }

        public int MaxTotalRows { get; set; }
        #endregion

        #region IDisposable Members

        void IDisposable.Dispose()
        {
            mQueryAdapter.Dispose();

            base.Dispose();

            GC.SuppressFinalize(this);
        }

        #endregion

        #region Protected Members
        void FilterSortQuery(DBType databaseType)
        {
            m_InnerQuery = m_Query;

            int startingIndex = 0;

            m_InnerQuery = Regex.Replace(m_InnerQuery, "OVER\\s*\\(", "OVER (", RegexOptions.IgnoreCase);
            m_InnerQuery = Regex.Replace(m_InnerQuery, "ORDER\\s*BY", "ORDER BY", RegexOptions.IgnoreCase);

            if (m_InnerQuery.ToUpper().Contains("OVER(") || m_InnerQuery.ToUpper().Contains("OVER ("))
            {
                startingIndex = Math.Max(m_InnerQuery.ToUpper().LastIndexOf("OVER("), m_InnerQuery.ToUpper().LastIndexOf("OVER ("));
                startingIndex = m_InnerQuery.ToUpper().IndexOf("ORDER BY", startingIndex) + 8;
            }

            //select top 10 * from (select top 10 * from t_account order by id_acc desc, id_acc_ext) a order by a.dt_crt
            //Below logic for above query will fetch the wrong order by clause . ie from Derived Query not the final Query.  
            // changing logic to use lastindexof instead of index of.

            if ((startingIndex > 0 && m_InnerQuery.ToUpper().LastIndexOf("ORDER BY") + 8 > startingIndex) ||
                 (startingIndex <= 0 && m_InnerQuery.ToUpper().LastIndexOf("ORDER BY") > 0))
            {
                int startIndex = m_InnerQuery.ToUpper().LastIndexOf("ORDER BY");
                int endIndex = m_InnerQuery.ToUpper().IndexOf(")", startIndex);

                //Do no remove order by clause if close-bracket encountered. it may be a subquery, derived table etc.
                if (endIndex == -1)
                {
                    endIndex = m_InnerQuery.Length;
                    m_OrderByText = m_InnerQuery.Substring(startIndex, endIndex - startIndex);
                    m_InnerQuery = m_InnerQuery.Remove(startIndex, endIndex - startIndex);
                }

            }

            if (m_Filters.Count > 0)
            {
                m_InnerQuery = string.Format("Select * from ({0}) rootQuery", m_InnerQuery);

                if (m_Filters.Count > 0)
                {
                    m_InnerQuery += " WHERE " + m_Filters[0].FilterClause(databaseType);

                    for (int i = 1; i < m_Filters.Count; i++)
                    {
                        m_InnerQuery += " AND " + m_Filters[i].FilterClause(databaseType);
                    }
                }
            }

            if (SortCriteria != null && SortCriteria.Count > 0)
            {

                //Append Order-By from Query at the end of sort column with comma.
                string orderByText = "ORDER BY ";

                foreach (SortCriteria criteria in SortCriteria)
                {
                    orderByText += string.Format("{0} {1}, ", criteria.Property,
                      (criteria.Direction == SortDirection.Descending ? "DESC" : string.Empty));
                }

                m_OrderByText = string.Format("{0}{1}", orderByText.Substring(0, orderByText.Length - 2),
                          Regex.Replace(m_OrderByText ?? string.Empty, "ORDER\\s*BY", ",", RegexOptions.IgnoreCase));
            }

            base.Command.CommandText = m_InnerQuery;
            m_InnerQuery = base.Command.CommandText;
            base.Command.CommandText = "";
        }
		#endregion
		
	public class PreparedFilterSortForExport : Statement, IMTPreparedFilterSortStatement, IDisposable
    {
      #region Private Members
      private string m_Query;

      private List<BaseFilterElement> m_Filters = new List<BaseFilterElement>();

      private int m_PageSize = -1;
      private int m_CurrentPage = -1;

      private int m_TotalRows = 0;

      private MTComSmartPtr<MetraTech.Interop.QueryAdapter.IMTQueryAdapter> mQueryAdapter = new MTComSmartPtr<MetraTech.Interop.QueryAdapter.IMTQueryAdapter>();

      private string m_InnerQuery;
      private string m_OrderByText;
      private string m_nameTable;
      #endregion

      public PreparedFilterSortForExport(IDbCommand cmd, String sqlText, string nameTable)
        : base(cmd)
      {
        MaxTotalRows = 0;
        m_nameTable = nameTable;

        //BP: Note!!!
        //We are used to passing '?' as parameter place markers
        //in ADO/SQL Server. However Oracle doesn't like that and
        //it wants ':1, :2 etc' instead. Examine cmd RT here and replace
        // '?' with positions
        string text = sqlText;
        char replacementChar = '@';

        if (cmd is MTOracleCommand)
        {
          replacementChar = ':';

          text = text.Replace('@', ':');

          ((MTOracleCommand)base.mCommand).BindByName = true;
        }

        int pos = 1;
        int idx = -1;
        while ((idx = text.IndexOf('?')) > 0 == true)
        {
          text = text.Remove(idx, 1);
          text = text.Insert(idx, string.Format("{0}{1}", replacementChar, pos++));
        }

        m_Query = text;

        mQueryAdapter.Item = new MetraTech.Interop.QueryAdapter.MTQueryAdapterClass();
        mQueryAdapter.Item.Init(@"queries\Database");

        SortCriteria = new List<DataAccess.SortCriteria>();
      }

      ~PreparedFilterSortForExport()
      {
        Dispose();
      }

      /// <summary>
      /// Used to execute statements that return resultsets.
      /// </summary>
      public override IMTDataReader ExecuteReader()
      {
        IMTDataReader ret = null;

        OnBeforeExecute();

        ConnectionInfo connInfo = new ConnectionInfo("NetMeterStage");

        // Parse query to generate parts
        FilterSortQuery(connInfo.DatabaseType);

        mQueryAdapter.Item.SetQueryTag("__FILTER_SORT_PARAM_QUERY_FOR_EXPORT__");
        mQueryAdapter.Item.AddParam("%%INNER_QUERY%%", m_InnerQuery, true);
        if (Command is MTOracleCommand)
        {
           mQueryAdapter.Item.AddParam("%%ORDER_BY_TEXT%%",
                   (string.IsNullOrEmpty(m_OrderByText) ?
                       (!mQueryAdapter.Item.IsOracle() ? "ORDER BY (Select 1)" : "") : m_OrderByText), true);
        }
        if (mQueryAdapter.Item.IsSqlServer())
        {
          mQueryAdapter.Item.AddParam("%%NAME_TEMP_TABLE%%", m_nameTable, true);
        }
        string topRows = "";
        if (MaxTotalRows > 0)
        {
          if (Command is MTOracleCommand)
          {
            topRows = string.Format("where rownum <= {0}", MaxTotalRows);
          }
          else
          {
            topRows = string.Format("top {0}", MaxTotalRows);
          }
        }
 
          mQueryAdapter.Item.AddParam("%%TOP_ROWS%%", topRows);
        

        Command.CommandText = mQueryAdapter.Item.GetQuery();
        Command.CommandType = CommandType.Text;

        IDbDataParameter param = Command.CreateParameter();
        param.ParameterName = string.Format("{0}StartRow", (!mQueryAdapter.Item.IsOracle() ? "@" : ":"));
        param.DbType = DbType.Int32;
        param.Value = ((m_CurrentPage > 0 && m_PageSize > 0) ? ((m_CurrentPage - 1) * m_PageSize) + 1 : 0);
        Command.Parameters.Add(param);

        param = Command.CreateParameter();
        param.ParameterName = string.Format("{0}EndRow", (!mQueryAdapter.Item.IsOracle() ? "@" : ":"));
        param.DbType = DbType.Int32;
        if ((m_CurrentPage > 0 && m_PageSize > 0))
        {
          param.Value = (m_CurrentPage * m_PageSize);
        }
        else
        {
          param.Value = DBNull.Value;
        }
        Command.Parameters.Add(param);


        if (mQueryAdapter.Item.IsOracle())
        {
          OracleParameter oraParam = (OracleParameter)Command.CreateParameter();
          oraParam.OracleDbType = OracleDbType.RefCursor;
          oraParam.Direction = ParameterDirection.Output;
          oraParam.ParameterName = ":TotalRows";
          Command.Parameters.Add(oraParam);

          oraParam = (OracleParameter)Command.CreateParameter();
          oraParam.OracleDbType = OracleDbType.RefCursor;
          oraParam.Direction = ParameterDirection.Output;
          oraParam.ParameterName = ":Rows";
          Command.Parameters.Add(oraParam);
        }

        IDataReader nativereader = Command.ExecuteReader();

        if (nativereader.Read())
        {
          m_TotalRows = System.Convert.ToInt32(nativereader.GetValue(0));
        }

        nativereader.NextResult();

        //TODO: do it in corresponding Command classes
        if (nativereader is OracleDataReader)
          ret = new MTOracleDataReader(nativereader);
        else //if (nativereader is OleDbDataReader)
          ret = new MTOleDbDataReader(nativereader);

        Debug.Assert(ret != null);

        OnAfterExecute();
        GC.KeepAlive(this);
        return ret;
      }

      #region IMTPreparedFilterSortForExport Members

      public void AddParam(string paramName, MetraTech.DataAccess.MTParameterType type, Object value)
      {
        IDataParameter param = Command.CreateParameter();
        Convert(type, Command, ref param);
        param.Direction = ParameterDirection.Input;

        if (value == null)
          param.Value = DBNull.Value;
        else
        {
          if (Command is MTOracleCommand)
          {
            if ((type == MetraTech.DataAccess.MTParameterType.String ||
              type == MetraTech.DataAccess.MTParameterType.WideString ||
              type == MetraTech.DataAccess.MTParameterType.NText ||
              type == MetraTech.DataAccess.MTParameterType.Text) &&
             value.ToString() == "")
              param.Value = MTEmptyString.Value;
            else if (type == MTParameterType.Guid)
            {
              param.Value = ((Guid)value).ToByteArray();
            }
            else
              param.Value = value;

            param.ParameterName = string.Format(":{0}", paramName);

            ((MTOracleCommand)base.mCommand).BindByName = true;
          }
          else
          {
            param.ParameterName = string.Format("@{0}", paramName);

            param.Value = value;
          }

        }

        Command.Parameters.Add(param);
      }

      /// <summary>
      /// Clear all parameter bindings
      /// </summary>
      public virtual void ClearParams()
      {
        Command.Parameters.Clear();
      }

      public void AddFilter(BaseFilterElement filter)
      {
        m_Filters.Add(filter);
      }

      public void ClearFilters()
      {
        m_Filters.Clear();
      }

      public List<SortCriteria> SortCriteria { get; set; }

      public int PageSize
      {
        get
        {
          return m_PageSize;
        }
        set
        {
          m_PageSize = value;
        }
      }

      public int CurrentPage
      {
        get
        {
          return m_CurrentPage;
        }
        set
        {
          m_CurrentPage = value;
        }
      }

      public int TotalRows
      {
        get { return m_TotalRows; }
      }

      public int MaxTotalRows { get; set; }
      #endregion

      #region IDisposable Members

      void IDisposable.Dispose()
      {
        mQueryAdapter.Dispose();

        base.Dispose();

        GC.SuppressFinalize(this);
      }

      #endregion

      #region Protected Members
      void FilterSortQuery(DBType databaseType)
      {
        m_InnerQuery = m_Query;

        int startingIndex = 0;

        m_InnerQuery = Regex.Replace(m_InnerQuery, "OVER\\s*\\(", "OVER (", RegexOptions.IgnoreCase);
        m_InnerQuery = Regex.Replace(m_InnerQuery, "ORDER\\s*BY", "ORDER BY", RegexOptions.IgnoreCase);

        if (m_InnerQuery.ToUpper().Contains("OVER(") || m_InnerQuery.ToUpper().Contains("OVER ("))
        {
          startingIndex = Math.Max(m_InnerQuery.ToUpper().LastIndexOf("OVER("), m_InnerQuery.ToUpper().LastIndexOf("OVER ("));
          startingIndex = m_InnerQuery.ToUpper().IndexOf("ORDER BY", startingIndex) + 8;
        }

        //select top 10 * from (select top 10 * from t_account order by id_acc desc, id_acc_ext) a order by a.dt_crt
        //Below logic for above query will fetch the wrong order by clause . ie from Derived Query not the final Query.  
        // changing logic to use lastindexof instead of index of.

        if ((startingIndex > 0 && m_InnerQuery.ToUpper().LastIndexOf("ORDER BY") + 8 > startingIndex) ||
             (startingIndex <= 0 && m_InnerQuery.ToUpper().LastIndexOf("ORDER BY") > 0))
        {
          int startIndex = m_InnerQuery.ToUpper().LastIndexOf("ORDER BY");
          int endIndex = m_InnerQuery.ToUpper().IndexOf(")", startIndex);

          //Do no remove order by clause if close-bracket encountered. it may be a subquery, derived table etc.
          if (endIndex == -1)
          {
            endIndex = m_InnerQuery.Length;
            m_OrderByText = m_InnerQuery.Substring(startIndex, endIndex - startIndex);
            m_InnerQuery = m_InnerQuery.Remove(startIndex, endIndex - startIndex);
          }

        }

        if (m_Filters.Count > 0)
        {
          m_InnerQuery = string.Format("Select * from ({0}) rootQuery", m_InnerQuery);

          if (m_Filters.Count > 0)
          {
            m_InnerQuery += " WHERE " + m_Filters[0].FilterClause(databaseType);

            for (int i = 1; i < m_Filters.Count; i++)
            {
              m_InnerQuery += " AND " + m_Filters[i].FilterClause(databaseType);
            }
          }
        }

        if (SortCriteria != null && SortCriteria.Count > 0)
        {

          //Append Order-By from Query at the end of sort column with comma.
          string orderByText = "ORDER BY ";

          foreach (SortCriteria criteria in SortCriteria)
          {
            orderByText += string.Format("{0} {1}, ", criteria.Property,
              (criteria.Direction == SortDirection.Descending ? "DESC" : string.Empty));
          }

          m_OrderByText = string.Format("{0}{1}", orderByText.Substring(0, orderByText.Length - 2),
                    Regex.Replace(m_OrderByText ?? string.Empty, "ORDER\\s*BY", ",", RegexOptions.IgnoreCase));
        }

        base.Command.CommandText = m_InnerQuery;
        m_InnerQuery = base.Command.CommandText;
        base.Command.CommandText = "";
      }
      #endregion
    }

	public class AdapterStatement : Statement, IMTAdapterStatement, IDisposable
	{
		public AdapterStatement(IDbCommand cmd, String configPath, String queryTag) : base(cmd)
		{
			mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
			mQueryAdapter.Init(configPath);
			mQueryAdapter.SetQueryTag(queryTag);
			mQueryTag = queryTag;
		}

		public AdapterStatement(IDbCommand cmd, String aQueryString) : base(cmd)
		{
			mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
			mQueryAdapter.Init(@"Queries\Database");
			mQueryAdapter.SetRawSQLQuery(aQueryString);
		}

    ~AdapterStatement()
    {
      Dispose();
    }

    public override void Dispose()
    {
      if (mQueryAdapter != null)
      {
        System.Runtime.InteropServices.Marshal.ReleaseComObject(mQueryAdapter);
        mQueryAdapter = null;
      }

      base.Dispose();

      GC.SuppressFinalize(this);
    }

		public virtual String QueryTag
		{
			set 
			{
				mQueryTag = value;
				mQueryAdapter.SetQueryTag(mQueryTag);
			}
		}

		public virtual String ConfigPath
		{
			set
			{
				mQueryAdapter.Init(value);
			}
		}

		public virtual string Query
		{
			get
			{
				return mQueryAdapter.GetQuery();
			}
		}

		public virtual void AddParam(String name, Object value)
		{
			AddParam(name, value == null ? DBNull.Value : value, false);
		}

		public virtual void AddParam(String name, Object value, bool dontValidateString)
		{
			Object dbValue;
			if (value == null)
			{
				dbValue = DBNull.Value;
			}
			else if (value.GetType().Name == "DateTime" )
			{
				dbValue = DBUtil.ToDBString((DateTime)value);
				dontValidateString = true;
			}
			else
			{
				dbValue = value;
			}

			mQueryAdapter.AddParam(name, dbValue, dontValidateString);
		}

		public virtual bool AddParamIfFound(String name, Object value)
		{
			return AddParamIfFound(name, value == null ? DBNull.Value : value, false);
		}

		public virtual bool AddParamIfFound(String name, Object value, bool dontValidateString)
		{
			Object dbValue;
			if (value == null)
			{
				dbValue = DBNull.Value;
			}
			else if (value.GetType().Name == "DateTime" )
			{
				dbValue = DBUtil.ToDBString((DateTime)value);
				dontValidateString = true;
			}
			else
			{
				dbValue = value;
			}

			return mQueryAdapter.AddParamIfFound(name, dbValue, dontValidateString);
		}

		public virtual void OmitParam(string name)
		{
			AddParam(name, "", false);
		}

		public override int ExecuteNonQuery()
		{
			// Get the query string from the adapter and ExecDirect
			Command.CommandText = mQueryAdapter.GetQuery();
			OnBeforeExecute();
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();
			int ret = Command.ExecuteNonQuery();
            performanceStopWatch.Stop(mQueryTag);
			OnAfterExecute();
            GC.KeepAlive(this);
			return ret;
		}

		public override IMTDataReader ExecuteReader()
		{
			// Get the query string from the adapter and ExecDirect
			Command.CommandText = mQueryAdapter.GetQuery();
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();
			var reader = base.ExecuteReader();
            performanceStopWatch.Stop(mQueryTag);
            return reader;
		}

		public virtual void ClearQuery()
		{
			//call clear on the underline query adapter
			//object, but preserve query tag
			mQueryAdapter.ClearQuery();
			QueryTag = mQueryTag;
			return;
		}

		private MetraTech.Interop.QueryAdapter.IMTQueryAdapter mQueryAdapter;
		private string mQueryTag;
	}
	
}

}
namespace MetraTech.DataAccess.Oracle
{
    using MetraTech.Performance;

	/// <remarks>
	/// OracleCallableStatement class is a subclass of CallableStatement for one reason:
	/// Oracle stored procedures can not return a result set unless a RefCursor parameter exist
	/// and initialized. OracleCallableStatement explicitely handles RefCursor parameter, so that the clients 
	/// didn't have to have conditional SQLServer/Oracle code and deal with ref cursors.
	/// </remarks>
    public class OracleCallableStatement : CallableStatement, IMTCallableStatement, IDisposable
	{
        public OracleCallableStatement(IDbCommand cmd, String sprocName) : base(cmd, sprocName) { }

		public override IMTDataReader ExecuteReader()
		{
			Debug.Assert(Command is MTOracleCommand);
			OracleParameter param = (OracleParameter)Command.CreateParameter();
			param.OracleDbType = OracleDbType.RefCursor;
            param.Direction = ParameterDirection.Output;
			//param.ParameterName = "res";
			Command.Parameters.Add(param);
            var performanceStopWatch = new PerformanceStopWatch();
            performanceStopWatch.Start();
			base.ExecuteNonQuery();
            performanceStopWatch.Stop(Command.CommandText);
            if (param.Value is System.DBNull)
			{
				throw new DataAccessException("OUT sys_refcursor variable found but it is not initialized.");
			}
            OracleRefCursor cur = (OracleRefCursor)param.Value;
            OracleDataReader reader = cur.GetDataReader();
            GC.KeepAlive(this);
			return new MTOracleDataReader(reader);
		}

        ~OracleCallableStatement()
        {
            Dispose();
	}

    }
}

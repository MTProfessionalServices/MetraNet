using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Threading;

using MetraTech.Dataflow;
using MetraTech.DataAccess;
using MetraTech.Pipeline;
using MetraTech.Xml;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Security.Crypto;

namespace MetraTech.ActivityServices.Services.Common
{
  public sealed class PipelineMeteringHelperCache : IDisposable
  {
    #region Static Members
    private static ServiceDefinitionCollection m_ServiceDefinitions;
    #endregion

    #region Members
    private Stack<PipelineMeteringHelper> m_Helpers = new Stack<PipelineMeteringHelper>();

    private string m_RootServiceDef;
    private string m_KeyColumnName = null;
    private Type m_KeyColumnType = null;
    private string[] m_ChildServiceDefs = null;

    #endregion

    #region Constructors
    static PipelineMeteringHelperCache()
    {
      m_ServiceDefinitions = new ServiceDefinitionCollection();
    }

    private PipelineMeteringHelperCache() { }

    public PipelineMeteringHelperCache(string rootServiceDef, 
                                       string keyColumnName = null, 
                                       Type keyColumnType = null, 
                                       params string[] childServiceDefs)
    {
      PoolSize = 50;

      m_RootServiceDef = rootServiceDef;
      m_KeyColumnName = keyColumnName;
      m_KeyColumnType = keyColumnType;
      m_ChildServiceDefs = childServiceDefs;
    }

    ~PipelineMeteringHelperCache()
    {
      Dispose();
    }
    #endregion

    #region Public Methods
    public PipelineMeteringHelper GetMeteringHelper()
    {
      lock (m_Helpers)
      {
        if (m_Helpers.Count > 0)
        {
          PipelineMeteringHelper helper = m_Helpers.Pop();
          return helper;
        }
      }

      return new PipelineMeteringHelper(m_ServiceDefinitions, m_RootServiceDef, PollingInterval, m_KeyColumnName, m_KeyColumnType, m_ChildServiceDefs);
    }

    [Obsolete("This method is deprecated in MetraNet 6.5. Use Release(helper) instead.")]
    public void ReleaseGetPaymentRecord(PipelineMeteringHelper helper)
    {
      lock (m_Helpers)
      {
        if (helper != null)
        {
          if (m_Helpers.Count < PoolSize)
          {
            helper.Reset();

            m_Helpers.Push(helper);
          }
          else
          {
            helper.Dispose();
          }
        }
      }
    }

    public void Release(PipelineMeteringHelper helper)
    {
      lock (m_Helpers)
      {
        if (helper != null)
        {
          if (m_Helpers.Count < PoolSize)
          {
            helper.Reset();

            m_Helpers.Push(helper);
          }
          else
          {
            helper.Dispose();
          }
        }
      }
    }
    #endregion

    #region Public Properties
    public int PoolSize { get; set; }
    public int PollingInterval { get; set; }
    #endregion

    #region IDisposable Members

    public void Dispose()
    {
      foreach (PipelineMeteringHelper helper in m_Helpers)
      {
        helper.Dispose();
      }

      m_Helpers.Clear();

      GC.SuppressFinalize(this);
    }

    #endregion
  }

  public sealed class PipelineMeteringHelper : IDisposable
  {
    #region Members
    private Dictionary<string, Guid> m_SvcDefToInputTableMap = new Dictionary<string, Guid>(StringComparer.CurrentCultureIgnoreCase);

    private string m_ProgramString;
    private int m_PollingInterval;
    private DataSet m_InputSet = new DataSet();
    private DataSet m_OutputSet = new DataSet();
    private string m_exportQueueName;
    private const string SERVICEBASE_QUERY_FOLDER = @"queries\ServiceBase";

    private MetraFlowPreparedProgram m_Program;

    // True if last call to Meter() was successful.
    private bool m_WasMeterSuccessful = false;
    #endregion

    #region Constructors
    private PipelineMeteringHelper() { }

    internal PipelineMeteringHelper(ServiceDefinitionCollection serviceDefinitions, 
                                    string rootServiceDef, 
                                    int? pollingInterval, 
                                    string keyColumnName = null, 
                                    Type keyColumnType = null, 
                                    params string[] childServiceDefs)
    {
      string inputOperators = "";
      string meterOperator = "meter: Meter[generateSummaryTable=false, areEnumsBeingUsed=false, ";
      string operatorLinkages = "";
      IServiceDefinition serviceDef = null;
      Guid queueName;
      DataTable inputTable = null;

      #region Process Root Service Def
      serviceDef = serviceDefinitions.GetServiceDefinition(rootServiceDef);

      queueName = Guid.NewGuid();

      // We are using an input dataset for the data being passed to the
      // metering operator.  This means that enums will arrive as datatype
      // integers rather then enums.  Thus, we set areEnumsBeingUsed to false
      // above.

      inputTable = new DataTable(queueName.ToString());
      m_InputSet.Tables.Add(inputTable);

      // Create the output dataset
      m_exportQueueName = queueName + "out";
      DataTable outputTable = new DataTable(m_exportQueueName);
      outputTable.Columns.Add(new System.Data.DataColumn("id_message",
                              System.Type.GetType("System.Int32")));
      m_OutputSet.Tables.Add(outputTable);

      m_SvcDefToInputTableMap[rootServiceDef] = queueName;

      inputOperators += string.Format("parent:import_queue[queueName=\"{0}\"];\n", queueName.ToString());

      inputOperators += string.Format("project: projection[column=\"id_message\"];\n");

      inputOperators += string.Format("export: export_queue[queueName=\"{0}\"];\n", m_exportQueueName);

      inputOperators += "rename_parent: Rename[";
      foreach (IMTPropertyMetaData propMetaData in serviceDef.Properties)
      {
        inputTable.Columns.Add(new DataColumn(propMetaData.Name, GetColumnType(propMetaData)));

        inputOperators += string.Format("from=\"{0}\", to=\"{1}\", ", propMetaData.Name, propMetaData.DBColumnName);
      }

      inputOperators = inputOperators.Substring(0, inputOperators.Length - 2) + "];\n";

      meterOperator += string.Format("isAuthorizationNeeded=true, ");
      meterOperator += string.Format(" service=\"{0}\", ", rootServiceDef);

      if (!string.IsNullOrEmpty(keyColumnName))
      {
        meterOperator += string.Format("key=\"{0}\", ", keyColumnName);

        inputTable.Columns.Add(new DataColumn(keyColumnName, keyColumnType));
      }

      // We need to create a data table and import queue for authorization
      // data.  The queue should contain a single row with string columns:
      // username, namespace, password, and serialized.  These strings
      // should not contain multibyte characters since they are ultimately
      // written to a VARCHAR field in the database.
      queueName = Guid.NewGuid();

      inputTable = new DataTable(queueName.ToString());
      m_InputSet.Tables.Add(inputTable);
      
      inputTable.Columns.Add(new DataColumn("username",  System.Type.GetType("System.String")));
      inputTable.Columns.Add(new DataColumn("namespace", System.Type.GetType("System.String")));
      inputTable.Columns.Add(new DataColumn("password",  System.Type.GetType("System.String")));
      inputTable.Columns.Add(new DataColumn("serialized",  System.Type.GetType("System.String")));
  
      m_SvcDefToInputTableMap["authorization"] = queueName;

      inputOperators += string.Format("authorization :import_queue[queueName=\"{0}\"];\n", queueName.ToString());

      operatorLinkages += "parent -> rename_parent -> meter(0) -> project -> export;\n";
      #endregion

      #region Process Child Service Defs
      int i = 1;
      foreach (string childSvcDef in childServiceDefs)
      {
        serviceDef = serviceDefinitions.GetServiceDefinition(childSvcDef);

        queueName = Guid.NewGuid();

        inputTable = new DataTable(queueName.ToString());
        m_InputSet.Tables.Add(inputTable);

        m_SvcDefToInputTableMap[childSvcDef] = queueName;

        inputOperators += string.Format("child{1}:import_queue[queueName=\"{0}\"];\n", queueName.ToString(), i);

        inputOperators += string.Format("rename_child{0}: Rename[", i);
        foreach (IMTPropertyMetaData propMetaData in serviceDef.Properties)
        {
          inputTable.Columns.Add(new DataColumn(propMetaData.Name, GetColumnType(propMetaData)));

          inputOperators += string.Format("from=\"{0}\", to=\"{1}\", ", propMetaData.Name, propMetaData.DBColumnName);
        }

        inputOperators = inputOperators.Substring(0, inputOperators.Length - 2) + "];\n";

        meterOperator += string.Format("service=\"{0}\", ", childSvcDef);

        if (!string.IsNullOrEmpty(keyColumnName))
        {
          meterOperator += string.Format("key=\"{0}\", ", keyColumnName);

          inputTable.Columns.Add(new DataColumn(keyColumnName, keyColumnType));
        }

        operatorLinkages += string.Format("child{0} -> rename_child{0} -> meter({0});\n", i);

        ++i;
      }
      #endregion

      operatorLinkages += string.Format("authorization -> meter({0});\n", 1+childServiceDefs.Count());

      meterOperator = meterOperator.Substring(0, meterOperator.Length - 2) + "];";

      m_ProgramString = string.Format("{0}\n{1}\n{2}", inputOperators, meterOperator, operatorLinkages);

      m_Program = new MetraFlowPreparedProgram(m_ProgramString, m_InputSet, m_OutputSet);

      if (pollingInterval.HasValue)
        m_PollingInterval = pollingInterval.Value;        
      else
        pollingInterval = 5000;
    }

    ~PipelineMeteringHelper()
    {
      Dispose();
    }
    #endregion

    #region Public Methods
    public DataSet Meter()
    {
      int errorCode = m_Program.RunVerbose();
      m_WasMeterSuccessful = (errorCode == 0);

      return m_OutputSet;
    }

    public DataSet Meter(string username, string nameSpace, string password)
    {
        DataRow authRow = null;

        authRow = m_InputSet.Tables[m_SvcDefToInputTableMap["authorization"].ToString()].NewRow();
        m_InputSet.Tables[m_SvcDefToInputTableMap["authorization"].ToString()].Rows.Add(authRow);

        authRow["username"] = username;
        authRow["namespace"] = nameSpace;

        CryptoManager cm = new CryptoManager();
        authRow["password"] = cm.Encrypt(CryptKeyClass.DatabasePassword, password);

        return Meter();
    }

    public DataSet Meter(MetraTech.Interop.MTAuth.IMTSessionContext sessionContext)
    {
        DataRow authRow = null;

        authRow = m_InputSet.Tables[m_SvcDefToInputTableMap["authorization"].ToString()].NewRow();
        m_InputSet.Tables[m_SvcDefToInputTableMap["authorization"].ToString()].Rows.Add(authRow);

        CryptoManager cm = new CryptoManager();
        authRow["serialized"] = cm.Encrypt(CryptKeyClass.DatabasePassword, sessionContext.ToXML());


        return Meter();
    }

    // Returns true if the last call to Meter() ran
    // successfully.
    public bool WasMeterSuccessful()
    {
        return m_WasMeterSuccessful;
    }

    public void Reset()
    {
      foreach (DataTable table in m_InputSet.Tables)
      {
        table.Clear();
      }

      foreach (DataTable oTable in m_OutputSet.Tables)
      {
        oTable.Clear();
      }
    }

    public DataRow CreateRowForServiceDef(string serviceDefName)
    {
      DataRow retval = null;

      retval = m_InputSet.Tables[m_SvcDefToInputTableMap[serviceDefName].ToString()].NewRow();
      m_InputSet.Tables[m_SvcDefToInputTableMap[serviceDefName].ToString()].Rows.Add(retval);

      return retval;
    }

    public void WaitForMessagesToComplete(DataSet messages, int maxWaitTime)
    {
      bool waitTillProcessed = false;
      bool checkOnce = false;
      bool finished = false;
      string msgIds = "";
      int msgCount = 0;
      int elapsedMilliseconds = 0;

      if (maxWaitTime == -1)
        waitTillProcessed = true;
      else if (maxWaitTime == 0)
        checkOnce = true;

      for (int i = 0; i < m_OutputSet.Tables[m_exportQueueName].Rows.Count; i++)
      {
        msgCount++;
        msgIds += m_OutputSet.Tables[m_exportQueueName].Rows[i]["id_message"] + ",";
      }

      // remove comma
      msgIds = msgIds.Remove(msgIds.Length - 1,1);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        while (!finished)
        {
          // exit if we hit the max wait time unless we are wait for all the messages to complete
          if ((elapsedMilliseconds > maxWaitTime) && (!waitTillProcessed))
          {
            break;
          }
          else
          {
            Thread.Sleep(m_PollingInterval);
            elapsedMilliseconds += m_PollingInterval;
          }

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(SERVICEBASE_QUERY_FOLDER, "__CHECK_MESSAGE_STATUSES__"))
          {
            if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
              stmt.AddParam("%%LOCK%%", "with (nolock)");
            else
              stmt.AddParam("%%LOCK%%", " ");

            stmt.AddParam("%%ID_MESSAGES%%", msgIds);
            bool meesagesComplete = false;
            using (IMTDataReader messageReader = stmt.ExecuteReader())
            {
              while (messageReader.Read())
              {                
                bool isComplete = messageReader.IsDBNull("Completed");
                // if one of the messages is not complete, then break b/c we are waiting for all of them to finish
                if (isComplete)
                {
                  break;
                }

                // if we got here that means all the messages have a dt_completed value
                meesagesComplete = true;
              }
            }
            if (meesagesComplete)
              finished = true;
          }

          if (checkOnce)
          {
            break;
          }
        }
      }
    }

    public DataTable GetMessageDetails(int? messageId)
    {
      DataTable details = null;
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      { 
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(SERVICEBASE_QUERY_FOLDER, "__GET_MESSAGE_DETAILS__"))
        {
          if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
            stmt.AddParam("%%LOCK%%", "with (nolock)");
          else
            stmt.AddParam("%%LOCK%%", " ");

          if (messageId.HasValue)
            stmt.AddParam("%%ID_MESSAGE_FILTER%%", String.Format(" = {0}", messageId.Value));
          else
          {
            string msgIds = "";
            for (int i = 0; i < m_OutputSet.Tables[m_exportQueueName].Rows.Count; i++)
            {              
              msgIds += m_OutputSet.Tables[m_exportQueueName].Rows[i]["id_message"] + ",";
            }

            if (m_OutputSet.Tables[m_exportQueueName].Rows.Count != 0)
            {// remove comma
              msgIds = msgIds.Trim(new char[] { ',' });
            }
            else
            {
              msgIds = "-1";
            }
            stmt.AddParam("%%ID_MESSAGE_FILTER%%", String.Format(" in ({0})", msgIds));
          }
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
              details = reader.GetDataTable();
          }
        }
      }
      return details;
    }
    #endregion

    #region IDisposable Members

    public void Dispose()
    {
      m_Program.Close();

      if (m_InputSet != null) { m_InputSet.Dispose(); }
      if (m_OutputSet != null) { m_OutputSet.Dispose(); }

      GC.SuppressFinalize(this);
    }

    #endregion

    #region Helper Methods
    private Type GetColumnType(IMTPropertyMetaData metaData)
    {
      Type retval = null;

      switch (metaData.DataType)
      {
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
          retval = typeof(Int32);
          break;
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
          retval = typeof(Int64);
          break;
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ASCII_STRING:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_UNICODE_STRING:
          retval = typeof(String);
          break;
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DOUBLE:
          retval = typeof(Decimal);
          break;
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
          retval = typeof(Boolean);
          break;
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_TIME:
          retval = typeof(DateTime);
          break;
        default:
          throw new ArgumentException("Unknown property data type");
      }

      return retval;
    }


    #endregion
  }
}

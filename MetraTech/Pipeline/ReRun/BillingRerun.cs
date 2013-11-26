namespace MetraTech.Pipeline.ReRun
{
  using System.Runtime.InteropServices;
  using System.Text;
  using System;
  using pc = Interop.MTProductCatalog;
  using mb = Interop.MTBillingReRun;
  using DataAccess;
  using MetraTech;
  using Xml;
  using Interop.MTAuditEvents;
  using PCExec = Interop.MTProductCatalogExec;

  class ViewServicePair
  {
    public int ViewID { get; set; }
    public string ViewName { get; set; }
    public int ServiceID { get; set; }
    public string ServiceName { get; set; }

    public ViewServicePair(int viewId, string viewName, int serviceId, string serviceName)
    {
      ViewID = viewId;
      ViewName = viewName;
      ServiceID = serviceId;
      ServiceName = serviceName;
    }
  }

  [Guid("78C816EE-3B23-4965-8E13-95CD5CC2BC63")]
  public interface IBillingRerun
  {
    int Setup(int accID, string comment);

    void Identify(mb.IMTSessionContext context, int accID, int rerunID, mb.IMTIdentificationFilter filter, string comment);

    void Analyze(mb.IMTSessionContext context, int accID, int rerunID, string comment);

    int BackoutResubmit(string strcontext, mb.IMTSessionContext context, int accID, int rerunID, string comment);

    void BackoutDelete(mb.IMTSessionContext context, int accID, int rerunID, string comment);

    int Abandon(int accID, int rerunID, string comment);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("44D17582-8604-481a-B886-CCE4FE08C867")]
  public class BillingRerun : IBillingRerun
  {
    public int Setup(int accId, string comment)
    {
      var id = -1;
      try
      {
        id = CreateSetup(accId, comment);

        //create the t_rerun_idrerun table
        //Oracle does not allow you to run DDL statements inside of DTC.

        if (id >= 1)
        {
          PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
          //ConnectionInfo connectionInfo = new ConnectionInfo("NetMeter");
          //IMTConnection conn = null;

          //if (connectionInfo.DatabaseType == DBType.Oracle)
          //{
          //  conn = ConnectionManager.CreateNonServicedConnection(@"Queries\BillingRerun");
          //}
          //else
          //{
          //  conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun");
          //}


          //using(IMTAdapterStatement stmt =
          //  conn.CreateAdapterStatement(@"Queries\BillingRerun", "__CREATE_T_RERUN_SESSIONS__"))
          // {
          //stmt.AddParam("%%TABLE_NAME%%", GetTableName(id));
          //stmt.ExecuteNonQuery();
          //}
          //using( IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__ADD_INDEX_T_RERUN_SESSIONS__")
          // {
          //stmt.AddParam("%%TABLE_NAME%%", GetTableName(id));
          //stmt.ExecuteNonQuery();
          // }

          using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
          {
            // create the t_rerun_sessions table.
            using (IMTAdapterStatement stmt1 = conn.CreateAdapterStatement("queries\\BillingRerun", "__CREATE_T_RERUN_SESSIONS__"))
            {
              stmt1.AddParam("%%TABLE_NAME%%", GetTableName(id));
              string createTableQuery = stmt1.Query;
              _logger.LogDebug("Creating rerun session table '{0}'", GetTableName(id));
              writer.ExecuteStatement(createTableQuery, @"Queries\BillingRerun");
              _logger.LogDebug("Successfully created rerun session table '{0}'", GetTableName(id));
            }

            // add index on id_sess, tx_state to this table
            using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("queries\\BillingRerun", "__ADD_INDEX_T_RERUN_SESSIONS__"))
            {
              stmt2.AddParam("%%TABLE_NAME%%", GetTableName(id));
              string addIndexQuery = stmt2.Query;
              _logger.LogDebug("Adding index to table '{0}'", GetTableName(id));
              writer.ExecuteStatement(addIndexQuery, @"Queries\BillingRerun");
              _logger.LogDebug("Successfully added index to table '{0}'", GetTableName(id));
            }
          }

          // conn.Dispose();
        }
        //EventId, UserId, EntityTypeId, EntityId, BSTR Details
        _auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_RERUNCREATE_SUCCESS,
        accId,
        (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
        id,
        "Rerun Created");
      }
      catch (Exception ex)
      {
        _logger.LogError(ex.ToString());
        _auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_RERUNCREATE_FAILED,
          accId,
          (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
          id,
          "Rerun Create Failed. " + ex.Message);
        throw;
      }
      return id;
    }

    public void Identify(mb.IMTSessionContext context, int accId, int rerunId, mb.IMTIdentificationFilter filter, string comment)
    {
      AddHistoryRow(accId, rerunId, comment, "START IDENTIFY");
      try
      {
        //remember, identify can be called multiple times for a given id_rerun
        //In such a case, the results should be cumulative, each identify
        //needs to keep adding to the table generated during setup.
        var noFilterSpecified = filter.IsNoFilterSpecified();
        var lookAtSourceData = filter.QueueMatchPossible;
        var lookAtFailedData = filter.IsFailedTransactionMatchPossible();
        var sessionIdsSpecified = filter.SessionIDs.Count > 0;

        var rerunTableName = GetTableName(rerunId);
        var sourceTableName = GetSourceTableName(rerunId);
        var uidTableName = GetUIDTableName(rerunId);

        var identifyQueryGenerator = new DBIdentify(_connInfo.IsOracle);

        if (!noFilterSpecified)
        {
          if (lookAtSourceData)
            CreateTempTable(identifyQueryGenerator, filter, sourceTableName);

          if (sessionIdsSpecified)
          {
            ITxnNotSupportedHelper helper = new TxnNotSupportedHelper();
            helper.CreateSessionIDTable(uidTableName);
          }

          // get data from t_acc_usage and t_failed_transaction
          using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
          {
            var joinClauseBuilder = new StringBuilder();
            var failedJoinClauseBuilder = new StringBuilder();
            var isPartition = DatabaseUtils.IsPartitionEnabled();

            if (lookAtSourceData)
            {
              PrepareSourceJoin(joinClauseBuilder, sourceTableName, _connInfo.IsSqlServer, isPartition);
              PrepareSourceFailedJoin(failedJoinClauseBuilder, sourceTableName);
            }

            if (sessionIdsSpecified)
            {
              PrepareSessinJoin(joinClauseBuilder, uidTableName, _connInfo.IsSqlServer, isPartition);
              PrepareSessinFailedJoin(failedJoinClauseBuilder, uidTableName);
            }

            var joinClause = joinClauseBuilder.ToString();
            var failedJoinClause = failedJoinClauseBuilder.ToString();

            _logger.LogDebug("The join clause for identifying successful sessions is: {0}", joinClause);
            _logger.LogDebug("The join clause for identifying failed sessions is: {0}", failedJoinClause);

            var databaseFilter = identifyQueryGenerator.GenerateDatabaseFilter(context, filter, uidTableName, true);
            var whereClause = databaseFilter.FilterString;

            if (whereClause != null || sessionIdsSpecified)
            {
              //identify data from t_acc_usage
              using (var stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__IDENTIFY_ACC_USAGE2__"))
              {
                stmt.AddParam("%%STATE%%", "I");
                stmt.AddParam("%%TABLE_NAME%%", rerunTableName);
                stmt.AddParam("%%JOIN_CLAUSE%%", joinClause);
                var successWhereClause = new StringBuilder();
                if (whereClause != null)
                {
                  successWhereClause.Append(" and ");
                  successWhereClause.Append(whereClause);
                }
                _logger.LogDebug("The where clause for identifying successful sessions is: {0}",
                                 successWhereClause.ToString());
                stmt.AddParam("%%WHERE_CLAUSE%%", successWhereClause.ToString(), true);
                stmt.ExecuteNonQuery();
              }
            }

            if (lookAtFailedData)
            {
              //identify data from t_failed_transaction
              //replace the au in the where clause with ft (for failed transaction)
              var dbFilter = identifyQueryGenerator.GenerateDatabaseFilterForFailedTransactions(filter, uidTableName, true);
              _logger.LogDebug("The where clause for identifying failed sessions is: {0}", dbFilter);

              if (dbFilter != "" || sessionIdsSpecified)
                using (var stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__IDENTIFY_FAILED_USAGE__"))
                {
                  stmt.AddParam("%%STATE%%", "E");
                  stmt.AddParam("%%TABLE_NAME%%", rerunTableName);
                  stmt.AddParam("%%JOIN_CLAUSE%%", failedJoinClause);
                  stmt.AddParam("%%WHERE_CLAUSE%%", dbFilter, true);
                  stmt.ExecuteNonQuery();
                }
            }

            if (filter.IsIdentifySuspendedTransactions || filter.IsIdentifyPendingTransactions)
              IdentifySuspendAndPanding(identifyQueryGenerator, filter, rerunTableName, conn);
          }
        }
        _auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_IDENTIFY_SUCCESS,
                           accId,
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                           rerunId,
                           "Rerun Identify Succeeded");
        AddHistoryRow(accId, rerunId, comment, "END IDENTIFY");
      }
      catch (Exception ex)
      {
        _logger.LogError(ex.ToString());
        _auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_IDENTIFY_FAILED,
                                  accId,
                                  (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                                  rerunId,
                                  "Rerun Identify Failed. " + ex.Message);
        throw;
      }
    }

    private static void PrepareSourceJoin(StringBuilder joinClauseBuilder, string sourceTableName, bool isSqlServer, bool isPartition)
    {
      if (isSqlServer && isPartition)
      {
        joinClauseBuilder.Append(" inner join t_uk_acc_usage_tx_uid uau on uau.id_sess = au.id_sess ");
        joinClauseBuilder.Append(" inner join ");
        joinClauseBuilder.Append(sourceTableName);
        joinClauseBuilder.Append(" src on src.id_source_sess = uau.tx_uid ");
      }
      else
      {
        joinClauseBuilder.Append(" inner join ");
        joinClauseBuilder.Append(sourceTableName);
        joinClauseBuilder.Append(" src on src.id_source_sess = au.tx_uid ");
      }
    }

    private static void PrepareSourceFailedJoin(StringBuilder failedJoinClauseBuilder, string sourceTableName)
    {
      failedJoinClauseBuilder.Append(" inner join ");
      failedJoinClauseBuilder.Append(sourceTableName);
      failedJoinClauseBuilder.Append(
        " src on (src.id_source_sess = ft.tx_FailureID or src.id_source_sess = ft.tx_failureCompoundID) ");
    }

    private static void PrepareSessinJoin(StringBuilder joinClauseBuilder, string uidTableName, bool isSqlServer, bool isPartition)
    {
      if (isSqlServer && isPartition)
      {
        joinClauseBuilder.Append(" inner join t_uk_acc_usage_tx_uid uau on uau.id_sess = au.id_sess ");
        joinClauseBuilder.Append("  inner join ");
        joinClauseBuilder.Append(uidTableName);
        joinClauseBuilder.Append(" sessionIds on sessionIds.id_source_sess = uau.tx_uid ");
      }
      else
      {
        joinClauseBuilder.Append("  inner join ");
        joinClauseBuilder.Append(uidTableName);
        joinClauseBuilder.Append(" sessionIds on sessionIds.id_source_sess = au.tx_uid ");
      }
    }

    private static void PrepareSessinFailedJoin(StringBuilder failedJoinClauseBuilder, string uidTableName)
    {
      failedJoinClauseBuilder.Append(" inner join ");
      failedJoinClauseBuilder.Append(uidTableName);
      failedJoinClauseBuilder.Append(
        " sessionIds on (sessionIds.id_source_sess = ft.tx_failureID or sessionIds.id_source_sess = ft.tx_failureCompoundID) ");
    }

    private void CreateTempTable(IDBIdentify identifyQueryGenerator,
                                 mb.IMTIdentificationFilter filter,
                                 string sourceTableName)
    {
      var sourceQuery = identifyQueryGenerator.GetSourceDataQuery(filter, sourceTableName);
      _logger.LogDebug("The source query is: {0}", sourceQuery);

      // create a temp table with just id_source_sess in them, base the name on id_rerun
      PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
      using (var conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
        //drop the source table if it exists
        using (var stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__DROP_T_RERUN_SOURCE_SESSIONS__"))
        {
          stmt.AddParam("%%TABLE_NAME%%", sourceTableName);
          var createTableQuery = stmt.Query;
          writer.ExecuteStatement(createTableQuery, @"Queries\BillingRerun");
        }

        //create the source table
        using (var stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__CREATE_T_RERUN_SOURCE_SESSIONS__"))
        {
          stmt.AddParam("%%TABLE_NAME%%", sourceTableName);
          var addIndexQuery = stmt.Query;
          writer.ExecuteStatement(addIndexQuery, @"Queries\BillingRerun");
        }

        //identify data from t_svc tables
        using (var stmt = conn.CreateStatement(sourceQuery))
        {
          stmt.ExecuteNonQuery();
        }
      }
    }

    private void IdentifySuspendAndPanding(IDBIdentify identifyQueryGenerator,
                                          mb.IMTIdentificationFilter filter,
                                          string rerunTableName,
                                          IMTConnection conn)
    {
      var whereClauseNp = identifyQueryGenerator.GenerateQueryForNotProcessedTransactions(filter);
      if (whereClauseNp == "") return;

      _logger.LogDebug(whereClauseNp);
      using (var stmt = conn.CreateAdapterStatement("queries\\BillingRerun",
                                                    "__IDENTIFY_ALL_SUSPENDED_AND_PENDING_USAGE__"))
      {
        stmt.AddParam("%%STATE%%", "NC"); //for now
        stmt.AddParam("%%TABLE_NAME%%", rerunTableName);
        stmt.AddParam("%%WHERE_CLAUSE%%", whereClauseNp, true);
        stmt.ExecuteNonQuery();
      }
    }

    public void Analyze(mb.IMTSessionContext context, int accID, int rerunID, string comment)
    {
      AddHistoryRow(accID, rerunID, comment, "START ANALYZE");
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("Analyze"))
          {
            stmt.AddParam("table_name", MTParameterType.String, GetTableName(rerunID));
            stmt.ExecuteNonQuery();
          }
        }
        // run the various analyze tasks
        foreach (string taskClass in Tasks.AnalysisTasks)
        {
          _logger.LogDebug("Running analysis task with class name/prog ID {0}", taskClass);
          IReRunTask task = Tasks.LoadTask(taskClass);
          task.Analyze(context, rerunID, GetTableName(rerunID), true);
        }

        // sleep for a second - safeguard against analyze have same start analyze and end analyze time
        System.Threading.Thread.Sleep(1000);

        _auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ANALYZE_SUCCESS,
                accID,
                (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                rerunID,
                "Rerun Analyze Succeeded");
        AddHistoryRow(accID, rerunID, comment, "END ANALYZE");
      }
      catch (Exception ex)
      {
        _logger.LogError(ex.ToString());
        _auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_ANALYZE_FAILED,
                    accID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                    rerunID,
                    "Rerun Analyze Failed. " + ex.Message);
        throw;
      }

    }



    public void BackoutDelete(mb.IMTSessionContext context, int accID, int rerunID, string comment)
    {
      AddHistoryRow(accID, rerunID, comment, "START BACKOUT/DELETE");
      try
      {
        string tableName = GetTableName(rerunID);
        bool deleteFailedRecords = true;

        //call the backout tasks here...
        foreach (string taskClass in Tasks.BackoutTasks)
        {
          _logger.LogDebug("Running backout task with class name/prog ID {0}", taskClass);
          IReRunTask task = Tasks.LoadTask(taskClass);
          task.Backout(context, rerunID, tableName, true);
        }

        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
        {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("Backout"))
          {
            stmt.AddParam("rerun_table_name", MTParameterType.String, tableName);
            stmt.AddParam("delete_failed_records", MTParameterType.Boolean, deleteFailedRecords);
            stmt.ExecuteNonQuery();
          }

          using (IMTCallableStatement stmt2 = conn.CreateCallableStatement("DeleteSourceData"))
          {
            stmt2.AddParam("rerun_table_name", MTParameterType.String, tableName);
            stmt2.AddParam("metradate", MTParameterType.String, MetraTech.MetraTime.NowWithMilliSec);
            stmt2.ExecuteNonQuery();
          }
        }
        _auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BACKOUTDELETE_SUCCESS,
                  accID,
                  (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                  rerunID,
                  "Rerun BackoutDelete Succeeded");
        AddHistoryRow(accID, rerunID, comment, "END BACKOUT/DELETE");
      }
      catch (Exception ex)
      {
        _logger.LogError(ex.ToString());
        _auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_BACKOUTDELETE_FAILED,
                    accID,
                    (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                    rerunID,
                    "Rerun BackoutDelete Failed. " + ex.Message);
        throw;
      }
    }

    public int BackoutResubmit(string strcontext, mb.IMTSessionContext context, int accID, int rerunID, string comment)
    {
      int return_code = 0;
      string tableName = GetTableName(rerunID);
      bool deleteFailedRecords = false;

      AddHistoryRow(accID, rerunID, comment, "START BACKOUT/RESUBMIT");
      try
      {

        //call the backout tasks here...
        foreach (string taskClass in Tasks.BackoutTasks)
        {
          _logger.LogDebug("Running backout task with class name/prog ID {0}", taskClass);
          IReRunTask task = Tasks.LoadTask(taskClass);
          task.Backout(context, rerunID, tableName, true);
        }
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
        {
          //if necessary, copy the information from the product view back into the service definition.
          //Each PV is marked to indicate whether or not we should perform this copy or whether we should
          //assume that there is an existing SD record (which will be the case unless archived/purged).
          //There is not logic in the C# code below for detecting which PVs need to be copied back; that is
          //all handled inside the queries since the t_prod_view table knows if the PV needs to be copied.
          //For those records that are going to be copied into the SD,
          //1) we must assign every such record a new id_source_sess and update t_rerun_sessions with the
          //new value (both id_source_sess and id_parent_source_sess).  
          //the records that are being resubmitted from product views are those with non-null
          //id_views.  we'll rely on the id identity column to generate the new id_source_sess.
          //2) select back every (id_view,id_svc) pair from identified sessions, build the appropriate IISF
          //query and execute.
          int maxIdInt = Int32.MinValue; int minIdInt = Int32.MaxValue;
          System.Collections.ArrayList viewServicePairs = new System.Collections.ArrayList();
          using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_IDENTIFIED_SERVICE_PV_PAIRS__"))
          {
            astmt.AddParam("%%TABLE_NAME%%", tableName);
            using (IMTDataReader rowset = astmt.ExecuteReader())
            {
              while (rowset.Read())
              {
                viewServicePairs.Add(new ViewServicePair(rowset.GetInt32("id_view"), rowset.GetString("nm_view"),
                                                        rowset.GetInt32("id_svc"), rowset.GetString("nm_svc")));
                if (maxIdInt < rowset.GetInt32("max_id")) maxIdInt = rowset.GetInt32("max_id");
                if (minIdInt > rowset.GetInt32("min_id")) minIdInt = rowset.GetInt32("min_id");
              }
            }
          }

          int numRatedRecords = maxIdInt == Int32.MinValue ? 0 : maxIdInt - minIdInt + 1;

          if (numRatedRecords > 0)
          {
            // We need service definitions to build queries.
            MetraTech.Pipeline.ServiceDefinitionCollection sds = new MetraTech.Pipeline.ServiceDefinitionCollection();
            MetraTech.Pipeline.ProductViewDefinitionCollection pvs = new MetraTech.Pipeline.ProductViewDefinitionCollection();

            // Allocate the range of ids and update rerun table.
            ILongIdGeneratorWrapper idSourceSessGenerator = new LongIdGeneratorWrapper();
            long idBase = idSourceSessGenerator.GetBlock("id_dbqueue", numRatedRecords);


            using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_ID_SOURCE_SESS__"))
            {
              astmt.AddParam("%%TABLE_NAME%%", tableName);
              astmt.AddParam("%%ID_BASE%%", idBase);
              astmt.ExecuteNonQuery();
            }

            using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_ID_PARENT_SOURCE_SESS__"))
            {
              astmt.AddParam("%%TABLE_NAME%%", tableName);
              astmt.AddParam("%%ID_BASE%%", idBase);
              astmt.ExecuteNonQuery();
            }

            foreach (ViewServicePair vsp in viewServicePairs)
            {
              MetraTech.Pipeline.IServiceDefinition sd = sds.GetServiceDefinition(vsp.ServiceName);
              MetraTech.Pipeline.IProductViewDefinition pv = pvs.GetProductViewDefinition(vsp.ViewName);
              StringBuilder pvprops = new StringBuilder();
              StringBuilder svcprops = new StringBuilder();

              foreach (pc.IMTPropertyMetaData prop in sd.Properties)
              {
                if (pvprops.Length > 0) pvprops.Append(", ");
                pvprops.Append("pv.");
                pvprops.Append(prop.DBColumnName);
                if (svcprops.Length > 0) svcprops.Append(", ");
                svcprops.Append("svc.");
                svcprops.Append(prop.DBColumnName);
              }

              using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__TRANSFER_PV_TO_SVC__"))
              {
                astmt.AddParam("%%RERUN_TABLE%%", tableName);
                astmt.AddParam("%%PV_COLUMNS%%", pvprops.ToString());
                astmt.AddParam("%%PV_TABLE%%", pv.TableName);
                astmt.AddParam("%%SVC_COLUMNS%%", svcprops.ToString());
                astmt.AddParam("%%SVC_TABLE%%", "t_svc_" + sd.LongTableName);
                astmt.AddParam("%%ID_VIEW%%", vsp.ViewID);
                astmt.AddParam("%%ID_SVC%%", vsp.ServiceID);
                astmt.ExecuteNonQuery();
              }
            }
          }

          //then call backout 
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("Backout"))
          {
            stmt.AddParam("rerun_table_name", MTParameterType.String, tableName);
            stmt.AddParam("delete_failed_records", MTParameterType.Boolean, deleteFailedRecords);
            stmt.ExecuteNonQuery();
          }

          //then call resubmit.
          resubmitSessions(conn, tableName, strcontext, rerunID);

        }
        _auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BACKOUTRESUBMIT_SUCCESS,
                  accID,
                  (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                  rerunID,
                  "Rerun BackoutResubmit Success");
        AddHistoryRow(accID, rerunID, comment, "END BACKOUT/RESUBMIT");
      }
      catch (System.Exception ex)
      {
        _auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_BACKOUTRESUBMIT_FAILED,
                      accID,
                      (int)MTAuditEntityType.AUDITENTITY_TYPE_BILLINGRERUN,
                      rerunID,
                      "Rerun BackoutResubmit Failed");
        _logger.LogError(ex.ToString());
        throw;
      }
      return return_code;
    }

    public void AuditFailTransChangeStatus(int accID, mb.IMTCollection failCompoundIDsEncoded, string details)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        foreach (var id in failCompoundIDsEncoded)
        {
          // Note:
          // By compount ID we always should recieve 1 our selected fail.trans. and all resubmitted transactions that binded with it.
          // By current architecture changing status of resubmitted fail.trans. is not allowed, so it is impossible that we recieve Resubmitted one to be proccesed.
          using (var stmt = conn.CreateAdapterStatement(@"Queries\FailedTransactions", "__GET_FAILED_TRANSACTION_ID_BY_COMPOUND_ID__"))
          {
            stmt.AddParam("%%FAIL_COMP_ID_ENC%%", id.ToString());
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              reader.Read();
              int failTrID;
              try
              {
                failTrID = reader.GetInt32(0);
              }
              catch
              {
                _logger.LogError(
                  "Unable to log event. Not Resubmitted Failed transaction with encoded FailureCompoundID '{0}' not exist.",
                  id);
                throw;
              }

              //todo:create (int)MTAuditEvent.AUDITEVENT__UPDATE_TRANSACTION_STATUS = 1701
              _auditor.FireEvent(1701, accID, (int)MTAuditEntityType.AUDITENTITY_TYPE_FAILEDTRANSACTION, failTrID,
                                 details);
              if (reader.Read())
              {
                _logger.LogError(
                  "More than one Not Resubmitted Failed transaction was found. Encoded FailureCompoundID = '{0}'.", id);
              }
            }
          }
        }
      }
    }

    private void resubmitSessions(IMTConnection conn, string tableName, string strcontext, int rerunID)
    {
      //read the xml file to get message size
      int msgSize = GetMessageSize();
      if (msgSize <= 0)
        throw new ApplicationException(String.Format("Invalid message size {0} found in file {1}", msgSize, "RMP\\config\\billingrerun\\billingrerun.xml"));

      PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();

      //there are numerous temp tables used for resubmit.  These are session, session_set, message, t_svc_relations
      //aggregate, aggregate_large, child_session_sets
      //the first four are per resubmit.  The latter three are per parent service def in the resubmit set.
      //In case of oracle, all temp tables are global temp tables.  So they need not be created here.
      //In case of sql server, these are local temp tables, so need to be created here.  In case of oracle,
      //we need to create sequences to insert data in the aggregate, aggregate_large and child_session_sets tables.

      if (_connInfo.IsSqlServer)
      {
        using (IMTAdapterStatement stmt1 = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_PER_RESUBMIT_TEMP_TABLES__"))
        {
          stmt1.ExecuteNonQuery();
        }
      }

      using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("Queries\\billingrerun", "__FILL_IN_SERVICE_RELATIONSHIPS__"))
      {
        stmt2.AddParam("%%RERUN_TABLE_NAME%%", tableName);
        stmt2.ExecuteNonQuery();
      }

      System.Collections.ArrayList parentSvcs = new System.Collections.ArrayList();
      using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("Queries\\billingrerun", "__READ_ALL_PARENT_SERVICES__"))
      {
        using (IMTDataReader parentSvcRowset = stmt2.ExecuteReader())
        {
          while (parentSvcRowset.Read())
          {
            parentSvcs.Add(parentSvcRowset.GetInt32("id_svc"));
          }
        }
      }

      //outer loop, for each parent service def.
      foreach (int parentSvc in parentSvcs)
      {
        // check for missing records
        var num_children_svcs = 0;
        var svcTableName = string.Empty;
        checkForMissingRecords(conn, parentSvc, tableName, ref num_children_svcs, ref svcTableName);

        int largest_compound;

        //handle tmp tables.
        //In case of sql server, we actually drop and create the tmp tables aggregate, aggregate_large and child_session_sets table 
        // For oracle, we drop and create sequences. We delete the contents of the temp tables (aggregate, aggregate_large and 
        // child_session_sets.  In case of sql server, we can execute ddl stmts inside of DTC transaction.  Not
        // so in oracle.

        if (_connInfo.IsSqlServer)
        {
          using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_PER_PARENT_SVC_TEMP_TABLES__"))
          {
            stmt.AddParamIfFound("%%RERUN_ID%%", rerunID.ToString());
            stmt.ExecuteNonQuery();
          }
        }
        else
        {
          using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_RESUBMIT_SEQUENCES__"))
          {
            stmt.AddParamIfFound("%%RERUN_ID%%", rerunID.ToString());
            var createTempTables = stmt.Query;
            writer.ExecuteStatement(createTempTables, @"Queries\BillingRerun");
          }

          using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__TRUNCATE_TEMP_TABLES__"))
          {
            stmt.ExecuteNonQuery();
          }
        }

        //populate the aggregate temp tables 
        using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("Queries\\billingrerun", "__POPULATE_AGGREGATE_TABLES__"))
        {
          stmt2.AddParam("%%ID_SVC%%", parentSvc);
          stmt2.AddParam("%%RERUN_TABLE_NAME%%", tableName);
          stmt2.AddParamIfFound("%%RERUN_ID%%", rerunID.ToString());
          stmt2.ExecuteNonQuery();
        }

        if (num_children_svcs > 0)
        {
          //find the largest compound.
          using (IMTCallableStatement callStmt = conn.CreateCallableStatement("CalculateLargestCompoundSize"))
          {
            callStmt.AddOutputParam("largest_compound", MTParameterType.Integer);
            callStmt.ExecuteNonQuery();
            largest_compound = (int)callStmt.GetOutputValue("largest_compound");
            if (largest_compound > msgSize)
            {
              _logger.LogWarning("At least one message larger than the message size specified in configuration file found .. consider increasing message size for resubmit");
            }
          }
        }
        //update the c__intervalID in the svc table, if necessary.. shouldn't I be doing this per parent service hmmm..
        //where clause should have id_svc in it..
        using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_INTERVALID__"))
        {
          stmt2.AddParam("%%RERUN_TABLE_NAME%%", tableName);
          stmt2.AddParam("%%SVC_TABLE_NAME%%", svcTableName);
          stmt2.ExecuteNonQuery();
        }

        if (num_children_svcs > 0)
        {
          //we are dealing with compounds, create large and/or regular messages as needed.
          createLargeMessages(parentSvc, conn, tableName, rerunID);
          createRegularMessages(parentSvc, conn, tableName, msgSize, num_children_svcs, rerunID);
        }
        else
        {
          //create messages for atomics.
          createAtomicMessages(parentSvc, conn, tableName, msgSize, rerunID);
        }


      } //end for loop for each parent svc

      //finally add all the messages, session sets to the real tables (copy from tmp tables to real tables)
      using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__COPY_INTO_REAL_SESSION_TABLES__"))
      {
        stmt.AddParam("%%METRADATE%%", MetraTime.Now);
        stmt.AddParam("%%CONTEXT%%", strcontext);
        stmt.ExecuteNonQuery();
      }

      //cleanup sequences that were created.. only to be done in case of oracle.  No op for sql server
      //TODO: do this only in case of oracle.
      if (_connInfo.IsOracle)
      {
        // clean up the tmp views before we exit the tx
        using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__DELETE_BR_TTT_TABLES__"))
        {
          stmt.ExecuteNonQuery();
        }

        using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CLEANUP_TEMP_RESUBMIT_TABLES__"))
        {
          stmt.AddParam("%%RERUN_ID%%", rerunID.ToString());
          string cleanupTempTables = stmt.Query;
          writer.ExecuteStatement(cleanupTempTables, @"Queries\BillingRerun");
        }
      }

      //adjust session state for all sessions resubmitted.
      using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_SESSION_STATE_ON_RESUBMIT__"))
      {
        stmt.AddParam("%%RERUN_TABLE_NAME%%", tableName);
        stmt.AddParam("%%METRADATE%%", MetraTime.Now);
        stmt.ExecuteNonQuery();
      }

      //adjust failed transaction state on resubmit.
      using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_FAILED_TRANSACTION_STATE_ON_RESUBMIT__"))
      {
        stmt.AddParam("%%RERUN_TABLE_NAME%%", tableName);
        stmt.AddParam("%%METRADATE%%", MetraTime.Now);
        stmt.ExecuteNonQuery();
      }
      //done!
    }

    private void createAtomicMessages(int parentSvc, IMTConnection conn, string tableName, int msgSize, int rerunID)
    {
      //Calculate how many atomic messages and session sets will be created.
      //reserve ids for atomic messages and session sets.
      int atomicMessageCnt, atomicSessionSetCnt, atomicMessageID, atomicSessionSetID;

      using (IMTCallableStatement callStmt = conn.CreateCallableStatement("CalculateAtomicMessages"))
      {
        callStmt.AddParam("message_size", MTParameterType.Integer, msgSize);
        callStmt.AddOutputParam("num_atomic_messages", MTParameterType.Integer);
        callStmt.ExecuteNonQuery();


        atomicMessageCnt = (int)callStmt.GetOutputValue("num_atomic_messages");
        atomicSessionSetCnt = atomicMessageCnt;
      }

      if (atomicMessageCnt > 0)
      {
        IIdGenerator2 msgIDGenerator = new IdGenerator("id_dbqueuesch", atomicMessageCnt);
        IIdGenerator2 ssIDGenerator = new IdGenerator("id_dbqueuess", atomicSessionSetCnt);

        atomicMessageID = msgIDGenerator.NextId;
        atomicSessionSetID = ssIDGenerator.NextId;

        //create stomic messages and session sets.
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_ATOMIC_MESSAGES_AND_SESSIONSETS__"))
        {
          stmt.AddParam("%%ID_SVC%%", parentSvc);
          stmt.AddParam("%%NUM_ATOMIC_MESSAGES%%", atomicMessageCnt);
          stmt.AddParam("%%ID_SESSIONSET_START%%", atomicSessionSetID);
          stmt.AddParam("%%ID_MESSAGE_START%%", atomicMessageID);
          stmt.ExecuteNonQuery();
        }
      }
    }

    private void createRegularMessages(int parentSvc, IMTConnection conn, string tableName, int msgSize, int num_children_svcs, int rerunID)
    {
      //Calculate how many regualr sized messages and session sets will be created.
      //reserve ids for regular sized messages and session sets.
      int regularMessageCnt, regularSessionSetCnt, regularMessageID, regularSessionSetID;
      using (IMTCallableStatement callStmt = conn.CreateCallableStatement("CalculateRegularMessages"))
      {
        callStmt.AddParam("message_size", MTParameterType.Integer, msgSize);
        callStmt.AddOutputParam("num_regular_messages", MTParameterType.Integer);
        callStmt.ExecuteNonQuery();


        regularMessageCnt = (int)callStmt.GetOutputValue("num_regular_messages");
      }

      //NOTE, this is the max number of sessions sets that can be created.  It may happen that we may use less than these,
      // as there may be several parents with no children of certain types.  So a small number of session set ids may remain unused. 
      regularSessionSetCnt = regularMessageCnt * (num_children_svcs + 1);
      if (regularMessageCnt > 0)
      {
        IIdGenerator2 msgIDGenerator = new IdGenerator("id_dbqueuesch", regularMessageCnt);
        IIdGenerator2 ssIDGenerator = new IdGenerator("id_dbqueuess", regularSessionSetCnt);

        regularMessageID = msgIDGenerator.NextId;
        regularSessionSetID = ssIDGenerator.NextId;

        //create regular sized messages and session sets.
        //first create parent session sets and the messages
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_REGULAR_COMPOUND_MESSAGES_AND_SESSIONSETS__"))
        {
          stmt.AddParam("%%ID_SVC%%", parentSvc);
          stmt.AddParam("%%NUM_REGULAR_MESSAGES%%", regularMessageCnt);
          stmt.AddParam("%%ID_SESSIONSET_START%%", regularSessionSetID);
          stmt.AddParam("%%ID_MESSAGE_START%%", regularMessageID);
          stmt.ExecuteNonQuery();
        }

        System.Collections.ArrayList childSvcs = new System.Collections.ArrayList();
        //find out the types of children present
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_CHILD_SERVICES__"))
        {
          stmt.AddParam("%%ID_SVC%%", parentSvc);
          using (IMTDataReader rowset = stmt.ExecuteReader())
          {
            while (rowset.Read())
            {
              childSvcs.Add(rowset.GetInt32("id_svc"));
            }
          }
        }

        int i = 1;
        foreach (int childSvc in childSvcs)
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_REGULAR_COMPOUND_CHILD_MESSAGES_AND_SESSIONSETS__"))
          {
            stmt.AddParam("%%I%%", i);
            stmt.AddParam("%%RERUN_TABLE_NAME%%", tableName);
            stmt.AddParam("%%ID_CHILD_SVC%%", childSvc);
            stmt.AddParam("%%NUM_REGULAR_MESSAGES%%", regularMessageCnt);
            stmt.AddParam("%%ID_SESSIONSET_START%%", regularSessionSetID);
            stmt.AddParam("%%ID_MESSAGE_START%%", regularMessageID);
            stmt.ExecuteNonQuery();
          }
          i++;
        }
      }
    }


    private void createLargeMessages(int parentSvc, IMTConnection conn, string tableName, int rerunID)
    {
      int num_large_messages;
      int num_large_session_sets;

      using (IMTCallableStatement callStmt = conn.CreateCallableStatement("CalculateLargeMessages"))
      {
        callStmt.AddParam("rerunID", MTParameterType.Integer, rerunID);
        callStmt.AddOutputParam("num_large_messages", MTParameterType.Integer);
        callStmt.AddOutputParam("num_large_session_sets", MTParameterType.Integer);
        callStmt.ExecuteNonQuery();

        num_large_messages = (int)callStmt.GetOutputValue("num_large_messages");
        num_large_session_sets = (int)callStmt.GetOutputValue("num_large_session_sets");
      }

      //reserve the ids for these messages and sessions sets.
      //create the large message and session sets.  What is a large message..
      //Large message is one which has compound with more than 1000 children.  The logic is to separate
      //out compounds with more than 1000 children and create a message with just one such compound.  So, one compound per message.
      if (num_large_messages > 0)
      {

        int largeMessageID, largeSessionSetID;

        IIdGenerator2 msgIDGenerator = new IdGenerator("id_dbqueuesch", num_large_messages);
        IIdGenerator2 ssIDGenerator = new IdGenerator("id_dbqueuess", num_large_session_sets);

        largeMessageID = msgIDGenerator.NextId;
        largeSessionSetID = ssIDGenerator.NextId;

        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__CREATE_LARGE_MESSAGES_AND_SESSIONSETS__"))
        {
          stmt.AddParam("%%RERUN_TABLE_NAME%%", tableName);
          stmt.AddParam("%%ID_SVC%%", parentSvc);
          stmt.AddParam("%%NUM_LARGE_MESSAGES%%", num_large_messages);
          stmt.AddParam("%%ID_SESSIONSET_START%%", largeSessionSetID - 1);
          stmt.AddParam("%%ID_MESSAGE_START%%", largeMessageID - 1);
          stmt.ExecuteNonQuery();
        }
      }
    }

    private void checkForMissingRecords(IMTConnection conn, int parentSvc, string tableName, ref int num_children_svcs, ref string svcTableName)
    {
      int num_parent_sessions, num_service_sessions;

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_SVCTABLE_NAME__"))
      {
        stmt.AddParam("%%ID_SVC%%", parentSvc);
        using (IMTDataReader rowset = stmt.ExecuteReader())
        {
          rowset.Read();
          svcTableName = rowset.GetString("nm_table_name");
        }
      }

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_NUMCHILDSVC__"))
      {
        stmt.AddParam("%%ID_SVC%%", parentSvc);
        using (IMTDataReader rowset = stmt.ExecuteReader())
        {
          rowset.Read();
          num_children_svcs = rowset.GetInt32("num_children_svcs");
        }
      }

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_TOTAL_PARENT_SESSIONS__"))
      {
        stmt.AddParam("%%RERUN_TABLE_NAME%%", tableName);
        stmt.AddParam("%%ID_SVC%%", parentSvc);
        using (IMTDataReader rowset = stmt.ExecuteReader())
        {
          rowset.Read();
          num_parent_sessions = rowset.GetInt32("num_parent_sessions");
        }
      }

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_TOTAL_SERVICE_SESSIONS__"))
      {
        stmt.AddParam("%%RERUN_TABLE_NAME%%", tableName);
        stmt.AddParam("%%SVC_TABLE_NAME%%", svcTableName);
        stmt.AddParam("%%ID_SVC%%", parentSvc);
        using (IMTDataReader rowset = stmt.ExecuteReader())
        {
          rowset.Read();
          num_service_sessions = rowset.GetInt32("num_service_sessions");
        }
      }

      if (num_service_sessions < num_parent_sessions)
      {
        throw new ApplicationException("One of more sessions identified for resubmit could not be found");
      }
    }

    public int Abandon(int accId, int rerunId, string comment)
    {
      AddHistoryRow(accId, rerunId, comment, "START ABANDON");

      // Oracle wants to asynchronously release locks on tables
      // so cleanup will fail on occasion.  We accept this behavior
      // and compensate by looking for reruns for which all abandon was
      // started but not completed.  Thus, if an abandon fails, then
      // the next one executed will take care of it.
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
        var rerunsToAbandon = new System.Collections.Generic.List<int>();
        using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__GET_PENDING_ABANDONS__"))
        using (var reader = stmt.ExecuteReader())
          while (reader.Read())
            rerunsToAbandon.Add(reader.GetInt32("id_rerun"));

        foreach (var rerunToAbandon in rerunsToAbandon)
        {
          using (var stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__ABANDON_RERUN_TABLES__"))
          {
            stmt.AddParam("%%RERUN_ID%%", rerunToAbandon.ToString());
            try
            {
              if (_connInfo.IsOracle)
              {
                PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
                var abandonTempTables = stmt.Query;
                writer.ExecuteStatement(abandonTempTables, @"Queries\BillingRerun");
              }
              else
              {
                stmt.ExecuteNonQuery();
              }
              // sleep for a second - safeguard against abandon have same start abandon and end abandon
              System.Threading.Thread.Sleep(1000);
              AddHistoryRow(accId, rerunToAbandon, comment, "END ABANDON");
            }
            catch (Exception ex)
            {
              _logger.LogWarning("Failed to abandon rerun with id = " + rerunToAbandon +
                                 ", system will retry on next billing rerun abandon operation:" + ex);
            }
          }
        }
      }

      return 0;
    }

    private static void AddHistoryRow(int accId, int rerunId, string comment, string action)
    {
      var helper = new TxnRequiresNewHelper();
      helper.AddHistoryRow(accId, rerunId, comment, action);
      helper.Dispose();
    }

    private static int CreateSetup(int accId, string comment)
    {
      var helper = new TxnRequiresNewHelper();
      var rerunId = helper.CreateSetup(accId, comment);
      helper.Dispose();
      return rerunId;
    }

    private static int GetMessageSize()
    {
      const string configFile = "billingrerun\\billingrerun.xml";
      var doc = new MTXmlDocument();
      doc.LoadConfigFile(configFile);
      return doc.GetNodeValueAsInt("/xmlconfig/defaultMessageSize");
    }

    public string GetTableName(int rerunID)
    {
      var tableName = new StringBuilder();
      tableName.Append("t_rerun_session_");
      tableName.Append(rerunID.ToString());
      return tableName.ToString();
    }

    public string GetUIDTableName(int rerunID)
    {
      var tableName = new StringBuilder();
      tableName.Append("t_UIDList_");
      tableName.Append(rerunID.ToString());
      return tableName.ToString();
    }

    public string GetSourceTableName(int rerunID)
    {
      var tableName = new StringBuilder();
      tableName.Append("t_source_rerun_session_");
      tableName.Append(rerunID.ToString());
      return tableName.ToString();
    }
    private readonly Logger _logger = new Logger("[BillingReRun]");
    private readonly Auditor _auditor = new Auditor();
    private readonly ConnectionInfo _connInfo = new ConnectionInfo("NetMeter");
   }
}


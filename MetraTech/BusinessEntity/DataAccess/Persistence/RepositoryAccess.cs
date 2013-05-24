using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Xml.Linq;
using Core.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.BusinessEntity.DataAccess.Persistence.Events;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using MetraTech.Debug.Diagnostics;
using NHibernate;
using NHibernate.Cfg;
using NHibernate.Criterion;
using NHibernate.Event;
using NHibernate.Event.Default;
using NHibernate.Tool.hbm2ddl;
using Oracle.DataAccess.Client;
using Property = MetraTech.BusinessEntity.DataAccess.Metadata.Property;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class RepositoryAccess
  {
    ParallelOptions parallelOptions = new ParallelOptions { MaxDegreeOfParallelism = 900 };

    #region Private fields
      // lists for ddl commands
    private readonly IDictionary<string, List<string>> _dropConstraintCommands = new Dictionary<string, List<string>>();
    private readonly IDictionary<string, string> _dropTableCommands = new Dictionary<string, string>();
    private readonly IDictionary<string, string> _createTableCommands = new Dictionary<string, string>();
    private readonly IDictionary<string, List<string>> _addConstraintCommands = new Dictionary<string, List<string>>();
    private readonly IDictionary<string, List<string>> _createTriggerCommands = new Dictionary<string, List<string>>();
    private readonly IDictionary<string, List<string>> _dropTriggerCommands = new Dictionary<string, List<string>>();
    private readonly List<string> _createTableDescriptionCommands = new List<string>();
    private readonly List<string> _createColumnDescriptionCommands = new List<string>();
    private readonly List<string> _unhandledCommands = new List<string>();

    private readonly List<string> _dropConstraints = new List<string>();
    private readonly List<string> _addConstraints = new List<string>();
    private readonly List<string> _createTriggers = new List<string>();
    private readonly List<string> _dropTriggers = new List<string>();


      //regex for BME tables
    // Will match [t_be_Order_cor_ord] in [alter table t_be_Order_cor_ord]
    private readonly Regex _alterTableRegex = new Regex("(?<=\\balter table\\s)(\\w+)", RegexOptions.Singleline);
    // Will match [t_be_Order_cor_ord] in [drop table t_be_Order_cor_ord]
    private readonly Regex _dropTableRegex = new Regex("(?<=\\bdrop table\\s)(\\w+)", RegexOptions.Singleline);
    // Will match [t_be_Order_cor_ord] in [create table t_be_Order_cor_ord]
    private readonly Regex _createTableRegex = new Regex("(?<=\\bcreate table\\s)(\\w+)", RegexOptions.Singleline);
    // The trigger name will be in Group(2) of the match and the table name will be in Group(4) of the match
    // for both the following candidates
    // SqlServer:
    // CREATE TRIGGER TRG_PaymentDistributionHistor ON t_be_ar_pay_paymentdistrib junk..
    // Oracle:
    // CREATE or REPLACE TRIGGER TRG_PaymentDistributionHistor AFTER INSERT OR UPDATE ON t_be_ar_pay_paymentdistrib junk...
    private readonly Regex _createTriggerRegex = new Regex(@"create\s+(or\s+replace\s+)?trigger\s+(\w+)\s+(.*)on\s+(\w+)", RegexOptions.Multiline);
    #endregion

    #region Private Properties

    private static bool Initialized { get; set; }
    private static bool InitializedForSync { get; set; }
    private static Dictionary<string, ISessionFactory> SessionFactories { get; set; }

    /// <summary>
    ///   ExtensionName -> (EntityGroupName, EntityGroup)
    /// </summary>
    private Dictionary<string, Dictionary<string, EntityGroup>> EntityGroupsByExtension { get; set; }
    #endregion

    #region Public Properties
    public static RepositoryAccess Instance
    {
        get
        {
            if (instance == null)
            {
                lock (syncRoot)
                {
                    if (instance == null)
                    {
                        instance = new RepositoryAccess();
                    }
                }
            }

            return instance;
        }
    }

    internal bool IsRunningRemotely { get; set; }

    #endregion

    #region Public Methods
    public ISession GetSession<T>() where T : DataObject
    {
      return GetSession(typeof (T).FullName);
    }

    /// <summary>
    ///   Determine the database that is associated with the given entity.
    ///   Retrieve the ISessionFactory for the database.
    ///   Create and return an ISession using the ISessionFactory.
    /// 
    ///   Note: An ISession is not thread-safe.
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public ISession GetSession(string entityName)
    {
      if (UnitOfWorkScope.Session != null)
      {
        return UnitOfWorkScope.Session;
      }

      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}'", entityName));
      Check.Require(!String.IsNullOrEmpty(entity.DatabaseName), String.Format("Cannot find database for entity '{0}'", entityName));

      ISessionFactory sessionFactory;
      SessionFactories.TryGetValue(entity.DatabaseName.ToLower(), out sessionFactory);
      Check.Require(sessionFactory != null, 
                    String.Format("Cannot finding session factory for entity '{0}' using database name '{1}'", 
                                   entityName, entity.DatabaseName));

      return sessionFactory.OpenSession();
    }

    public ISession GetSession(string entityName, FlushMode flushMode)
    {
      if (UnitOfWorkScope.Session != null)
      {
        return UnitOfWorkScope.Session;
      }

      ISession session = GetSession(entityName);
      session.FlushMode = flushMode;

      return session;
    }

    public ISession GetSessionForDb(string databaseName)
    {
      if (UnitOfWorkScope.Session != null)
      {
        return UnitOfWorkScope.Session;
      }

      ISessionFactory sessionFactory = GetSessionFactory(databaseName);
      return sessionFactory.OpenSession();
    }

    public ISession GetSessionForDb(string databaseName, FlushMode flushMode)
    {
      if (UnitOfWorkScope.Session != null)
      {
        return UnitOfWorkScope.Session;
      }

      ISession session = GetSessionForDb(databaseName);
      session.FlushMode = flushMode;

      return session;
    }

    public ISessionFactory GetSessionFactory(string databaseName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      ISessionFactory sessionFactory;
      SessionFactories.TryGetValue(databaseName.ToLower(), out sessionFactory);
      Check.Require(sessionFactory != null,
                    String.Format("Cannot finding session factory for database '{0}'", databaseName));

      return sessionFactory;
    }

    public ISessionFactory GetNetMeterSessionFactory()
    {
      ISessionFactory sessionFactory;
      SessionFactories.TryGetValue("netmeter", out sessionFactory);
      Check.Require(sessionFactory != null, String.Format("Cannot finding session factory for 'NetMeter'"));

      return sessionFactory;
    }

    public ISession GetNetMeterSession()
    {
      ISessionFactory sessionFactory = GetNetMeterSessionFactory();
      return sessionFactory.OpenSession();
    }

    public ISession GetNetMeterSession(FlushMode flushMode)
    {
      ISession session = GetNetMeterSession();
      session.FlushMode = flushMode;
      return session;
    }

    public bool IsEntityInOracle(string entityName)
    {
      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}'", entityName));
      Check.Require(!String.IsNullOrEmpty(entity.DatabaseName), String.Format("Cannot find database for entity '{0}'", entityName));

      return NHibernateConfig.IsOracle(entity.DatabaseName);
    }

    public void Initialize(bool initLocalizationData = true)
    {
      if (Initialized) 
        return;

      List<Assembly> bmeAssemblies = GetBmeAssemblies();

      //foreach (ConnectionInfo connectionInfo in NHibernateConfig.ConnectionInfoList)
      Parallel.ForEach(NHibernateConfig.ConnectionInfoList, parallelOptions, connectionInfo =>
      {
        foreach (Assembly assembly in bmeAssemblies)
        {
            connectionInfo.Configuration.AddAssembly(assembly);
        }

        #region Set the listeners
        #region Create
        connectionInfo.Configuration.EventListeners.PreInsertEventListeners =
          new IPreInsertEventListener[] 
            { 
              new PreInsertEventListener() {Configuration = connectionInfo.Configuration}
            };

        connectionInfo.Configuration.EventListeners.PostInsertEventListeners =
          new IPostInsertEventListener[] 
            { 
              new PostInsertEventListener() {Configuration = connectionInfo.Configuration}
            };
        #endregion

        #region Load
        connectionInfo.Configuration.EventListeners.PreLoadEventListeners =
          new IPreLoadEventListener[] 
            { 
              new PreLoadEventListener() {Configuration = connectionInfo.Configuration},
              new DefaultPreLoadEventListener()
            };

        connectionInfo.Configuration.EventListeners.PostLoadEventListeners =
          new IPostLoadEventListener[] 
            { 
              new PostLoadEventListener() {Configuration = connectionInfo.Configuration},
              new DefaultPostLoadEventListener()
            };
        #endregion

        #region Update
        connectionInfo.Configuration.EventListeners.PreUpdateEventListeners =
          new IPreUpdateEventListener[] 
            { 
              new PreUpdateEventListener() {Configuration = connectionInfo.Configuration}
            };

        connectionInfo.Configuration.EventListeners.PostUpdateEventListeners =
          new IPostUpdateEventListener[] 
            { 
              new PostUpdateEventListener() {Configuration = connectionInfo.Configuration}
            };
        #endregion

        #region Delete
        connectionInfo.Configuration.EventListeners.PreDeleteEventListeners =
          new IPreDeleteEventListener[] 
            { 
              new PreDeleteEventListener() {Configuration = connectionInfo.Configuration}
            };

        connectionInfo.Configuration.EventListeners.PostDeleteEventListeners =
          new IPostDeleteEventListener[] 
            { 
              new PostDeleteEventListener() {Configuration = connectionInfo.Configuration}
            };
        #endregion

        #endregion

        // Create the SessionFactory
        SessionFactories.Add(connectionInfo.ServerType.ToLower(),
                             connectionInfo.Configuration.BuildSessionFactory());
      });

      MetadataRepository.Instance.Initialize();
      Initialized = true;
    }

    public IStandardRepository GetRepository()
    {
      return StandardRepository.Instance;
    }

    public void UpdateSchema(SyncData syncData)
    {
      Check.Require(syncData != null, "extensionDataList cannot be null", SystemConfig.CallerInfo);

      if (/* businessEntityConfig.DefaultRepositoryConfig.SupportsDynamicTypes && */ !IsRunningRemotely)
      {
        RemoteRepositoryAccess remoteRepositoryAccess =
          GetRemoteRepositoryAccess("Core", "Common", true);
        remoteRepositoryAccess.UpdateSchema(syncData);

        return;
      }

      try
      {
        logger.Debug(String.Format("Updating data schema"));

        var configuration = CreateNhiberanateConfiguration(syncData);

        bool isOracle = NHibernateConfig.IsOracle(syncData.Database);

        logger.Debug(String.Format("Generating DDL statements"));
        // map table name to commands

        var export = new SchemaExport(configuration);
        // The export.Create method will generate an array of strings. Each string will be a
        // 'drop constraint', 'drop table', 'create table' or 'create constraint' command.
        // The block of code starting with [s =>] will be executed for each string.
        // It's purpose is to populate the dropConstraintCommands, dropTableCommands.. dictionaries
        // declared earlier based on the content of the string.
        #region CreateExportCommands
        export.Create
          (s =>
            {
              s = isOracle ? WrapExecDdl(s) : s;

              if (s.ToLowerInvariant().Contains("drop constraint"))
              {
                string tableName = MatchDDLCommands(_alterTableRegex, s);
                AddCommandsToDictionary(_dropConstraintCommands, _dropConstraints, tableName, s);
              }
              else if (s.ToLowerInvariant().Contains("drop table"))
              {
                  string tableName = MatchDDLCommands(_dropTableRegex, s);
                  if (!_dropTableCommands.ContainsKey(tableName))
                  {
                      _dropTableCommands.Add(tableName, isOracle ? GetDropTableDDL(tableName, true) : s);
                  }
              }

              else if (s.ToLowerInvariant().Contains("create table"))
              {
                  string tableName = MatchDDLCommands(_createTableRegex, s);
                  if (syncData.IsHistoryTable(tableName))
                  {
                      int index = s.IndexOf("not null,");
                      Check.Require(index != -1, String.Format("Cannot find 'not null,' in DDL '{0}'", s));
                      var prefix = s.Substring(0, index);
                      var suffix = s.Substring(index, s.Length - index);

                      if (isOracle)
                      {
                          // Add default SYS_GUID() to the primary key column 
                          // From: c_AccountNote_Id RAW(16) not null,
                          // To:   c_AccountNote_Id RAW(16) default sys_guid() not null,
                          s = prefix + " default sys_guid()" + suffix;

                      }
                      else
                      {
                          // Add default newsequentialid() to the primary key column 
                          // From: c_AccountNote_Id UNIQUEIDENTIFIER not null,
                          // To:   c_AccountNote_Id UNIQUEIDENTIFIER default newsequentialid() not null,
                          s = prefix + " default newsequentialid()" + suffix;
                      }
                  }

                  if (!_createTableCommands.ContainsKey(tableName))
                  {
                      _createTableCommands.Add(tableName, s);
                  }
              }
              else
                  if (s.ToLowerInvariant().Contains("add constraint"))
                  {
                      string tableName = MatchDDLCommands(_alterTableRegex, s);

                      // Add constraints for regular entities
                      // For compound entities, drop the foreign key constraints on the NetMeter table primary keys
                      Entity entity;
                      syncData.CompoundEntitiesByTableName.TryGetValue(tableName, out entity);
                      if (entity == null || !IsCompoundPropertyForeignKey(s, tableName, entity))
                      {
                          AddCommandsToDictionary(_addConstraintCommands, _addConstraints, tableName, s);
                      }

                  }
                  else
                  {
                      MatchCollection theMatches = _createTriggerRegex.Matches(s.ToLower());
                      if (theMatches.Count == 1)
                      {
                          Check.Require(theMatches[0].Groups.Count == 5, "Expected to find 5 groups in the regular expression match for trigger");
                          // It's a trigger
                          string triggerName = theMatches[0].Groups[2].Value.ToLower();
                          string tableName = theMatches[0].Groups[4].Value.ToLower();

                          // Add the trigger to createTriggerCommands
                          AddCommandsToDictionary(_createTriggerCommands, _createTriggers, tableName, s);

                          // Create the dropTrigger command if it's SQLServer
                          if (!isOracle)
                          {
                              string dropTriggerText = "IF OBJECT_ID ('" + triggerName + "','TR') IS NOT NULL DROP TRIGGER " +
                                                       triggerName;
                              AddCommandsToDictionary(_dropTriggerCommands, _dropTriggers, tableName, dropTriggerText);
                          }
                      }
                      else
                      {
                          _unhandledCommands.Add(s);
                      }
                  }
            },
            false);
        #endregion

         GenerateBmeDescription(syncData, isOracle);
        #region Update DDL

        logger.Debug(String.Format("Updating DDL statements"));

        // Remove ddl for entities that are not a part of new/modified entities/relationships because
        // they are not changing
        RemoveNotChangedEntities(syncData, isOracle);

          // Handle modified entities
        var restoreDataCommands = RestoreDataCommands(syncData, isOracle);

        // Create final DDL
        var ddl = CreateDDLCommands(syncData);

          //restore DML commands
        var restoreDmlCommands = new StringBuilder();

        restoreDataCommands.ForEach(kvp => kvp.Value.ForEach(s => restoreDmlCommands.Append(s)));

        #endregion

        #region Execute DDL

        if (IsExecutable())
        {
            ExecuteEntities(syncData, configuration, 
                restoreDataCommands.Count > 0, restoreDmlCommands, ddl, isOracle);

            ExecuteEnumAndLocalize(syncData, isOracle);
        }

          #endregion
      }
      catch (System.Exception e)
      {
        throw new MetadataException(String.Format("Failed to update schema"), e);
      }
    }


      public Dictionary<string, DbTableMetadata> GetDbMetadata(string databaseName, List<string> tableNames)
    {
      Check.Require(tableNames != null, "tableNames cannot be null");
      var tableMetadataList = new Dictionary<string, DbTableMetadata>();

      try
      {
        using (var session = GetSessionForDb(databaseName))
        using (var command = session.Connection.CreateCommand())
        {
          foreach (string tableName in tableNames)
          {
            DbTableMetadata dbTableMetadata;
            tableMetadataList.TryGetValue(tableName.ToLowerInvariant(), out dbTableMetadata);

            if (dbTableMetadata != null)
            {
              logger.Debug(String.Format("Found duplicate table name '{0}' in the tableNames argument to 'GetMetadata'", tableName));
              continue;
            }

            command.CommandText = GetTopRowSql(tableName, NHibernateConfig.IsOracle(databaseName));

            try
            {
              using (var dataReader = command.ExecuteReader())
              {
                DataTable dataTable = dataReader.GetSchemaTable();

                dbTableMetadata = new DbTableMetadata() {TableName = tableName};

                foreach (DataRow columnInfo in dataTable.Rows)
                {
                  var dbColumnMetadata = new DbColumnMetadata();
                  dbColumnMetadata.ColumnName = columnInfo["ColumnName"].ToString();
                  // dbColumnMetadata.DataType = (Type)columnInfo["DataType"];
                  //dbColumnMetadata.IsRequired = Convert.ToBoolean(columnInfo["AllowDBNull"]) ? false : true;
                  //dbColumnMetadata.IsUnique = columnInfo["IsUnique"] == DBNull.Value ? false : Convert.ToBoolean(columnInfo["IsUnique"]);

                  dbTableMetadata.ColumnMetadataList.Add(dbColumnMetadata);
                }

                tableMetadataList[tableName.ToLowerInvariant()] = dbTableMetadata;

                while(dataReader.Read())
                {
                  dbTableMetadata.HasData = true;
                  break;
                }
              }
            }
            catch (System.Exception)
            {
              logger.Debug(String.Format("Unable to retrieve metadata for table '{0}'", tableName));
            }
          }
        }
      }
      catch (System.Exception e)
      {
        var message = String.Format("Failed to get metadata for tables '{0}'", String.Join(",", tableNames.ToArray()));
        throw new DataAccessException(message, e);
      }

      return tableMetadataList;
    }

    /// <summary>
    ///   Drop all Bme tables from the specified database and extensionName
    ///   If extensionName is null or empty, drop all Bme tables for all extensions from the specified database
    /// </summary>
    /// <param name="databaseName"></param>
    /// <param name="extensionName"></param>
    public void DropTables(string databaseName, string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
     
      Check.Require(NHibernateConfig.IsBmeDatabase(databaseName),
                    String.Format("Database '{0}' is not marked as BME database", databaseName));

      if (!String.IsNullOrEmpty(extensionName))
      {
        Check.Require(SystemConfig.ExtensionExists(extensionName),
                      String.Format("Cannot find extension '{0}'", extensionName));
      }

      List<string> tableNames = MetadataRepository.Instance.GetTablesNamesInDropOrder(databaseName, extensionName);
      
      var ddl = new StringBuilder();
      bool isOracle = NHibernateConfig.IsOracle(databaseName);

      foreach(string tableName in tableNames)
      {
        ddl.Append(GetDropTableDDL(tableName, isOracle));
      }

      string execDdl = isOracle ? "begin " + ddl.ToString() + " end;" : ddl.ToString();

      using (var session = GetSessionForDb(databaseName))
      using (var tx = session.BeginTransaction())
      {
        // Write the sql
        logger.Debug(String.Format("Dropping all BME tables in the database '{0}' using the following ddl:\n '{1}'",
                                   databaseName, execDdl));
        IQuery query = session.CreateSQLQuery(execDdl);
        query.ExecuteUpdate();

        tx.Commit();
      }
    }
    #endregion

    #region Internal Methods
    
    static RepositoryAccess()
    {
      // Create one ISessionFactory for each database
      SessionFactories = new Dictionary<string, ISessionFactory>();
    }

    internal RemoteRepositoryAccess GetRemoteRepositoryAccess(string extensionName, string entityGroupName, bool refresh)
    {
      RemoteRepositoryAccess remoteRepositoryAccess;
      lock(syncRoot)
      {
        EntityGroup entityGroup = GetEntityGroup(extensionName, entityGroupName);
        remoteRepositoryAccess = entityGroup.GetRemoteRepositoryAccess(refresh);
      }

      return remoteRepositoryAccess;
    }

    internal void InitializeForSync()
    {
      if (InitializedForSync)
        return;

      foreach (ConnectionInfo connectionInfo in NHibernateConfig.ConnectionInfoList)
      { 
        if (connectionInfo.ServerType.ToLower() == "netmeter")
        {
          connectionInfo.Configuration.AddAssembly("Core.Common.Entity");
        }

        if (SessionFactories.ContainsKey(connectionInfo.ServerType.ToLower())) {
          string msg = string.Format("ConnectionInfo {0} already exists. Check all your servers.xml for duplicated entries",connectionInfo.ServerType.ToLower());
          logger.Error(msg);
          throw new System.Exception(msg);
        } 
        SessionFactories.Add(connectionInfo.ServerType.ToLower(),
                             connectionInfo.Configuration.BuildSessionFactory());
      }
     
      InitializedForSync = true;
    }
    #endregion

    #region Private Methods

    #region Descriptions for BME Tables
    private string AddTableDescriptionCommand(string tableName, string description, bool isOracle)
    {
        return isOracle ?
            WrapExecDdl(String.Format(SqlCommands.OracleTableDescription, tableName, description.Replace("'", ""))) :
            String.Format(SqlCommands.MsSqlTableDescription, description.Replace("'", ""), tableName);
    }

    private string AddColumnDescriptionCommand(string tableName, string column, string description, bool isOracle)
    {
        if (!isOracle)
        {
            if (column.StartsWith("c_"))
            {
                return String.Format(SqlCommands.MsSqlColumnDescription,description.Replace("'", ""), tableName, column);
            }
        }
        else
        {
            return WrapExecDdl(String.Format(SqlCommands.OracleColumnDescription, tableName, column, description.Replace("'", "")));
        }
       return String.Empty;
    }

    private void GenerateBmeDescription(SyncData syncData, bool isOracle)
    {
        foreach (var entity in syncData.NewAndModifiedEntitiesAndTheirConnections)
        {
          if (entity.EntityType.Equals(EntityType.Entity) && !syncData.DeletedEntities.Contains(entity))
            {
                //Add descriptions for tables
                string tableDescriptionCommand = AddTableDescriptionCommand(entity.TableName, entity.Description,
                                                                            isOracle);
                if (!string.IsNullOrEmpty(tableDescriptionCommand))
                {
                    _createTableDescriptionCommands.Add(tableDescriptionCommand);
                }

                //Add description for columns
                foreach (var property in entity.Properties)
                {
                    string columnDescriptionCommand = AddColumnDescriptionCommand(entity.TableName, property.ColumnName,
                                                                                  property.Description, isOracle);
                    if (!string.IsNullOrEmpty(columnDescriptionCommand))
                    {
                        _createColumnDescriptionCommands.Add(columnDescriptionCommand);
                    }
                }

                //Add description for columns c__Version, c_CreationDate, c_UpdateDate, c_UID

                _createColumnDescriptionCommands.Add(AddColumnDescriptionCommand(entity.TableName,
                                                                                 entity.PreDefinedProperties[0].
                                                                                     ColumnName,
                                                                                 SqlCommands.BmeVersionDescription,
                                                                                 isOracle));

                _createColumnDescriptionCommands.Add(AddColumnDescriptionCommand(entity.TableName,
                                                                                 entity.PreDefinedProperties[1].
                                                                                     ColumnName,
                                                                                 SqlCommands.BmeCreationDateDescription,
                                                                                 isOracle));
                _createColumnDescriptionCommands.Add(AddColumnDescriptionCommand(entity.TableName,
                                                                                 entity.PreDefinedProperties[2].
                                                                                     ColumnName,
                                                                                 SqlCommands.BmeUpdateDateDescription,
                                                                                 isOracle));
                _createColumnDescriptionCommands.Add(AddColumnDescriptionCommand(entity.TableName,
                                                                                     entity.PreDefinedProperties[3].
                                                                                         ColumnName,
                                                                                     SqlCommands.BmeUIDDescription,
                                                                                     isOracle));
            }
        }
    }
    #endregion

    #region UpdateSchema
    private static Configuration CreateNhiberanateConfiguration(SyncData syncData)
    {
        logger.Debug(String.Format("Building NHibernate configuration"));

        Configuration configuration = NHibernateConfig.GetNewConfiguration(syncData.Database);

        // Add assemblies to configuration
        foreach (string assemblyName in syncData.RequiredAssemblies)
        {
            Assembly assembly = Assembly.Load(assemblyName);
            Check.Require(assembly != null, String.Format("Failed to load assembly '{0}'", assemblyName));
            configuration.AddAssembly(assembly);
        }
        return configuration;
    }

    private string MatchDDLCommands(Regex regex, string command)
    {
        MatchCollection theMatches = regex.Matches(command);
        Check.Require(theMatches.Count > 0, String.Format("Cannot find table name in ddl statement '{0}'", command));
        return theMatches[0].Value.ToLowerInvariant();
    }

    private void AddCommandsToDictionary(IDictionary<string, List<string>> dictionary, List<string> commandsEvent, string tableName, string commandDDLString)
    {
        dictionary.TryGetValue(tableName, out commandsEvent);
        if (commandsEvent == null)
        {
            commandsEvent = new List<string>();
            dictionary.Add(tableName, commandsEvent);
        }
        commandsEvent.Add(commandDDLString);
    }

    private void RemoveNotChangedEntities(SyncData syncData, bool isOracle)
    {
        RemoveTables(_dropConstraintCommands, syncData.NewAndModifiedEntitiesAndTheirConnections);
        RemoveTables(_dropTableCommands, syncData.NewAndModifiedEntitiesAndTheirConnections);
        RemoveTables(_createTableCommands, syncData.NewAndModifiedEntitiesAndTheirConnections);
        RemoveTables(_addConstraintCommands, syncData.NewAndModifiedEntitiesAndTheirConnections);
        RemoveTables(_createTriggerCommands, syncData.NewAndModifiedEntitiesAndTheirConnections);
        RemoveTables(_dropTriggerCommands, syncData.NewAndModifiedEntitiesAndTheirConnections);

        // Handle deleted entities
        // Add 'drop table' ddl for deleted entities
        foreach (Entity entity in syncData.DeletedEntities)
        {
            Check.Require(!String.IsNullOrEmpty(entity.TableName),
                          String.Format("Cannot find table name for entity '{0}'", entity.FullName));

            string tableName = entity.TableName.ToLowerInvariant();
            Check.Require(!_dropTableCommands.ContainsKey(tableName),
                          String.Format("Found table '{0}' in drop list", tableName));
            _dropTableCommands.Add(tableName, GetDropTableDDL(tableName, isOracle));
        }
    }

    private Dictionary<string, string> RestoreDataCommands(SyncData syncData, bool isOracle)
    {
        var restoreDataCommands = new Dictionary<string, string>();
        foreach (EntityChangeSet entityChangeSet in syncData.EntityChangeSetList)
        {
            string tableName = entityChangeSet.TableName.ToLowerInvariant();
            Check.Require(!String.IsNullOrEmpty(tableName),
                          String.Format("Cannot find table name for entity '{0}'", entityChangeSet.EntityName));

            // Replace the original drop table ddl with:
            // - Drop backup table (if it exists)
            // - Copy table data into the backup table (created automatically) 
            // - Drop the original table
            string backupAndDropTableDDL = GetBackupAndDropTableDDL(tableName, isOracle);

            Check.Require(_dropTableCommands.ContainsKey(tableName),
                          String.Format("Expected to find table '{0}' for modified entity '{1}' in drop list",
                                        tableName, entityChangeSet.EntityName));

            _dropTableCommands[tableName] = backupAndDropTableDDL;

            if (!entityChangeSet.BackupOnly)
            {
                // Create the restore sql
                // INSERT INTO TABLE2 (COL1, COL2, COL3) SELECT COL1, COL4, COL7 FROM TABLE1
                restoreDataCommands.Add(tableName, GetRestoreSql(entityChangeSet, isOracle));
            }
        }
        return restoreDataCommands;
    }

    private StringBuilder CreateDDLCommands(SyncData syncData)
    {
        var ddl = new StringBuilder();

        _dropConstraintCommands.ForEach(kvp => kvp.Value.ForEach(s => ddl.Append(s)));

        // Sort dropTableCommands so that the relationships are dropped first
        IOrderedEnumerable<KeyValuePair<string, string>> orderedKvp =
            _dropTableCommands.OrderBy(command => command.Key, new TableDropOrder(syncData.EntityGraph));
        orderedKvp.ForEach(command => ddl.Append(command.Value));

        _createTableCommands.ForEach(command => ddl.Append(command.Value));

        _createTableDescriptionCommands.ForEach(tableDesc => ddl.Append(tableDesc));

        _createColumnDescriptionCommands.ForEach(columnDesc => ddl.Append(columnDesc));

        _addConstraintCommands.ForEach(command => command.Value.ForEach(s => ddl.Append(s)));

        _unhandledCommands.ForEach(s => ddl.Append(s));

        return ddl;
    }
    private bool IsExecutable()
    {
        // Check if there's anything to execute;
        if (_dropConstraintCommands.Count == 0 &&
            _dropTableCommands.Count == 0 &&
            _createTableCommands.Count == 0 &&
            _unhandledCommands.Count == 0 &&
            _createTriggerCommands.Count == 0)
        {
            logger.Debug("No DDL commands generated for synchronization");
            return false;
        }
        return true;
    }

    private void ExecuteEntities(SyncData syncData, Configuration configuration, bool isExistsRestoreData,
                                 StringBuilder restoreDmlCommands, StringBuilder ddl, bool isOracle)
    {
        // Setup ddl for Oracle
        var ddlCommands = ddl.ToString();
        ddlCommands = isOracle ? "begin " + ddlCommands + " end;" : ddlCommands;

        // Get the file to write the sync sql 
        string syncFile =
            BusinessEntityConfig.Instance.GetSynchronizationSqlFileWithPath(syncData.Database.ToLower());

        // Build the session factory and retrieve a session
        ISessionFactory sessionFactory = configuration.BuildSessionFactory();


        using (var session = sessionFactory.OpenSession())
        using (var tx = session.BeginTransaction())
        {
            ExecuteMainDDLCommands(session, ddlCommands, syncFile);
            if (isExistsRestoreData) ExecuteRestoreData(syncFile, session, isOracle, restoreDmlCommands);
            ExecuteTriggerDDLCommands(isOracle, syncFile, session);
            tx.Commit();
        }
    }

    private static void ExecuteMainDDLCommands(ISession session, string ddlCommands, string syncFile)
    {
        // Write the sql
        File.WriteAllText(syncFile, ddlCommands);
        logger.Debug(
            "Executing sync DDL for dropping constraints, dropping tables, creating tables and creating constraints");
        IQuery query = session.CreateSQLQuery(ddlCommands);
        query.ExecuteUpdate();
    }

    private void ExecuteTriggerDDLCommands(bool isOracle, string syncFile, ISession session)
    {
        if (_dropTriggerCommands.Count > 0)
        {
            logger.Debug("Dropping history triggers");
            foreach (KeyValuePair<string, List<string>> kvp in _dropTriggerCommands)
            {
                foreach (string dropTriggerDdl in kvp.Value)
                {
                    File.AppendAllText(syncFile, dropTriggerDdl);
                    IQuery dropTrigger = session.CreateSQLQuery(dropTriggerDdl);
                    dropTrigger.ExecuteUpdate();
                }
            }
        }

        if (_createTriggerCommands.Count > 0)
        {
            logger.Debug("Creating history triggers");
            foreach (KeyValuePair<string, List<string>> kvp in _createTriggerCommands)
            {
                foreach (string createTriggerDdl in kvp.Value)
                {
                    var triggerDdl = isOracle ? "begin " + createTriggerDdl + " end;" : createTriggerDdl;
                    File.AppendAllText(syncFile, triggerDdl);
                    IQuery createTrigger = session.CreateSQLQuery(triggerDdl);
                    createTrigger.ExecuteUpdate();
                }
            }
        }
    }

    private static void ExecuteRestoreData(string syncFile, ISession session, bool isOracle,
                                           StringBuilder restoreDmlCommands)
    {
        var restoreDml = restoreDmlCommands.ToString();
        restoreDml = isOracle ? "begin " + restoreDml + " end;" : restoreDml;

        // Write the sql
        File.AppendAllText(syncFile, restoreDml);
        logger.Debug(string.Format("Executing SQL to restore data: {0}", restoreDml));
        IQuery restoreQuery = session.CreateSQLQuery(restoreDml);
        restoreQuery.ExecuteUpdate();
    }


    private void ExecuteEnumAndLocalize(SyncData syncData, bool isOracle)
    {
        using (var session = GetNetMeterSession())
        using (var tx = session.BeginTransaction())
        {
            if (syncData.CapabilityEnumValues.Count > 0)
            {
                CreateEnumEntitiesForBME(syncData, isOracle, session, tx);
            }

            if (syncData.LocalizationEntries.Count > 0)
            {
                CreateLocalizationEntities(syncData, session, isOracle, tx);
            }

            UpdateEntitiesInSyncData(syncData, session);

            tx.Commit();
        }
    }

    private static void CreateEnumEntitiesForBME(SyncData syncData, bool isOracle, ISession session, ITransaction tx)
    {
        IDbCommand insertEnumCommand = isOracle ?
                        (IDbCommand)new OracleCommand()
                        : new SqlCommand();

        insertEnumCommand.Connection = session.Connection;

        tx.Enlist(insertEnumCommand);

        insertEnumCommand.CommandType = CommandType.StoredProcedure;
        insertEnumCommand.CommandText = "InsertEnumData";

        if (isOracle)
        {
            foreach (string enumEntry in syncData.CapabilityEnumValues)
            {
                CreateEnumEntity(insertEnumCommand, enumEntry,
                                  new OracleParameter("p_nm_enum_data", OracleDbType.NVarchar2),
                                  new OracleParameter("p_id_enum_data", OracleDbType.Int32));
            }
        }
        else
        {
            foreach (string enumEntry in syncData.CapabilityEnumValues)
            {

                CreateEnumEntity(insertEnumCommand, enumEntry,
                                 new SqlParameter("@nm_enum_data", SqlDbType.NVarChar),
                                 new SqlParameter("@id_enum_data", SqlDbType.Int));
            }
        }
    }

    private static void CreateEnumEntity(IDbCommand insertEnumCommand, string enumEntry, DbParameter dbParamVar, DbParameter dbParamInt)
    {
        // Set output parameter
        dbParamVar.Value = enumEntry;
        insertEnumCommand.Parameters.Add(dbParamVar);

        // Set output parameter
        dbParamInt.Direction = ParameterDirection.Output;
        insertEnumCommand.Parameters.Add(dbParamInt);

        // Execute the stored procedure
        logger.Debug(String.Format("Inserting enum '{0}' into the database", enumEntry));
        insertEnumCommand.ExecuteNonQuery();
        var paramIntValue = dbParamInt.Value.ToString();

        if (!String.IsNullOrEmpty(paramIntValue))
        {
            if (int.Parse(paramIntValue) == -99)// Magic number in InsertEnumData stored proc
            {
                throw new DataAccessException(String.Format("Failed to insert enum entry '{0}'", enumEntry));
            }
        }
        else
        {
            throw new DataAccessException(String.Format("Failed to insert int parameter to stored procedure {0}. Value is null or empty", insertEnumCommand.CommandText));
        }
    }

    private static void CreateLocalizationEntities(SyncData syncData, ISession session, bool isOracle, ITransaction tx)
    {
        IDbCommand insertLocaleEntriesCommand = isOracle ? (IDbCommand)new OracleCommand() : new SqlCommand();
        insertLocaleEntriesCommand.Connection = session.Connection;

        tx.Enlist(insertLocaleEntriesCommand);

        insertLocaleEntriesCommand.CommandType = CommandType.StoredProcedure;
        insertLocaleEntriesCommand.CommandText = "CreateLocalizedEntry";

        foreach (string languageCode in syncData.LocalizationEntries.Keys)
        {
            Dictionary<string, string> localeNameValues = syncData.LocalizationEntries[languageCode];

            foreach (string localizationKey in localeNameValues.Keys)
            {
                string localizedValue = localeNameValues[localizationKey];

                insertLocaleEntriesCommand.Parameters.Clear();

                if (isOracle)
                {
                    CreateVarParameter(new OracleParameter("@p_lang_code", OracleDbType.NVarchar2),
                                       insertLocaleEntriesCommand, languageCode);
                    CreateVarParameter(new OracleParameter("@p_description_key", OracleDbType.NVarchar2),
                                       insertLocaleEntriesCommand, localizationKey);
                    CreateVarParameter(new OracleParameter("@p_description", OracleDbType.NVarchar2),
                                       insertLocaleEntriesCommand, localizedValue);
                    CreateLocalizationForEntity(new OracleParameter("@p_status", OracleDbType.Int32),
                                                insertLocaleEntriesCommand, languageCode, localizationKey,
                                                localizedValue, isOracle);
                }
                else
                {
                    CreateVarParameter(new SqlParameter("p_lang_code", SqlDbType.NVarChar), insertLocaleEntriesCommand,
                                       languageCode);
                    CreateVarParameter(new SqlParameter("p_description_key", SqlDbType.NVarChar),
                                       insertLocaleEntriesCommand, localizationKey);
                    CreateVarParameter(new SqlParameter("p_description", SqlDbType.NVarChar), insertLocaleEntriesCommand,
                                       localizedValue);
                    CreateLocalizationForEntity(new SqlParameter("p_status", OracleDbType.Int32),
                                                insertLocaleEntriesCommand, languageCode, localizationKey,
                                                localizedValue, isOracle);

                }
            }
        }
    }

    private static void CreateVarParameter(DbParameter dbParamVar, IDbCommand insertLocaleEntriesCommand, string paramValue)
    {
        dbParamVar.Value = paramValue;
        insertLocaleEntriesCommand.Parameters.Add(dbParamVar);
    }

    private static void CreateLocalizationForEntity(DbParameter dbParamInt, IDbCommand insertLocaleEntriesCommand, string languageCode, string localizationKey, string localizedValue, bool isOracle)
    {

        // Set output parameter
        dbParamInt.Direction = ParameterDirection.Output;
        insertLocaleEntriesCommand.Parameters.Add(dbParamInt);

        // Execute the stored procedure
        logger.Debug(
            String.Format(
                "Inserting localization entry into the database. Language: '{0}' Key: '{1}' Value: '{2}'",
                languageCode, localizationKey, localizedValue));
        insertLocaleEntriesCommand.ExecuteNonQuery();

        bool noErrors = isOracle
                            ? ((Oracle.DataAccess.Types.OracleDecimal) dbParamInt.Value).IsZero
                            : (int) dbParamInt.Value == 0;

        if (!noErrors)
        {
            throw new DataAccessException(String.Format("Failed to insert localization data. " +
                                                        "LanguageCode: '{0}', LocalizationKey: '{1}'," +
                                                        "LocalizationValue: '{2}'",
                                                        localizedValue, localizationKey, localizedValue));
        }

    }
    
    private static void UpdateEntitiesInSyncData(SyncData syncData, ISession session)
    {
        logger.Debug("Updating entries in t_be_entity_sync_data");
        foreach (EntitySyncData entitySyncData in syncData.NewAndModifiedEntitySyncDataList)
        {
            session.SaveOrUpdate(entitySyncData);
            Entity entity = null;
            foreach (Entity tmpEntity in syncData.NewAndModifiedEntitiesAndTheirConnections)
            {
                if (tmpEntity.FullName == entitySyncData.EntityName)
                {
                    entity = tmpEntity;
                    break;
                }
            }

            Check.Require(entity != null, String.Format("Cannot find entity '{0}'", entitySyncData.EntityName));
            entity.EntitySyncData = entitySyncData;
        }

        foreach (EntitySyncData entitySyncData in syncData.DeletedEntitySyncDataList)
        {
            IList<EntitySyncData> entitySyncDataList =
                session.CreateCriteria(typeof (EntitySyncData))
                    .Add(Expression.Eq("EntityName", entitySyncData.EntityName))
                    .List<EntitySyncData>();

            entitySyncDataList.ForEach(session.Delete);
        }
    }
    #endregion

    private static List<Assembly> GetBmeAssemblies()
    {
        var assemblies = new List<Assembly>();

        List<string> assemblyNames = Name.GetEntityAssemblyNames();
        bool foundCoreCommon = false;

        foreach (string assemblyName in assemblyNames)
        {
            // This can be removed after migrating to 6.6. The assembly can be added explicitly.
            if (assemblyName.ToLower() == "core.common.entity")
            {
                foundCoreCommon = true;
            }

            // Since assemblyNames are based on the directory structure,
            // it is possible that some assemblyNames may not be mapped to a dll in the bin directory.
            // Log a warning for those assemblyNames and continue
            string assemblyFileNameWithPath = Path.Combine(SystemConfig.GetRmpBinDir(), assemblyName + ".dll");
            if (File.Exists(assemblyFileNameWithPath))
            {
                logger.Debug(String.Format("Loading assembly '{0}", assemblyFileNameWithPath));
                Assembly assembly = Assembly.Load(assemblyName);
                Check.Require(assembly != null,
                              String.Format("Cannot load assembly '{0}'", assemblyFileNameWithPath),
                              SystemConfig.CallerInfo);
                assemblies.Add(assembly);
            }
            else
            {
                assemblyFileNameWithPath = Path.Combine(SystemConfig.GetRmpBinDir(), BMEConstants.BMERootNameSpace + "." + assemblyName + ".dll");
                if (File.Exists(assemblyFileNameWithPath))
                {
                  logger.Debug(String.Format("Loading assembly '{0}", assemblyFileNameWithPath));
                  Assembly assembly = Assembly.Load(BMEConstants.BMERootNameSpace + "." +assemblyName);
                  Check.Require(assembly != null,
                                String.Format("Cannot load assembly '{0}'", assemblyFileNameWithPath),
                                SystemConfig.CallerInfo);
                  assemblies.Add(assembly);
                }
                else
                {
                  logger.Warn(String.Format("Cannot find assembly '{0}", assemblyFileNameWithPath));
                }
            }
        }

        if (!foundCoreCommon)
        {
            Assembly assembly = Assembly.Load("core.common.entity");
            Check.Require(assembly != null,
                          String.Format("Cannot load assembly '{0}'",
                                        Path.Combine(SystemConfig.GetRmpBinDir(), "core.common.entity.dll")));
            assemblies.Add(assembly);
        }

        return assemblies;
    }

    private void RemoveTables(IDictionary<string, string> commands, List<Entity> requiredEntities)
    {
        var removeCommandKeys = new List<string>();

        foreach (string tableName in commands.Keys)
        {
            // If there is no requiredEntities with tableName and it hasn't been 
            // seen already, mark it to be removed
            if (!requiredEntities.Any(e => e.TableName.ToLowerInvariant() ==
                                           tableName.ToLowerInvariant())
                && !removeCommandKeys.Contains(tableName))
            {
                removeCommandKeys.Add(tableName);
            }
        }

        foreach (string tableName in removeCommandKeys)
        {
            commands.Remove(tableName);
        }
    }

    private void RemoveTables(IDictionary<string, List<string>> commands, List<Entity> requiredEntities)
    {
      var removeCommandKeys = new List<string>();

      foreach (string tableName in commands.Keys)
      {
        // If there is no requiredEntities with tableName and it hasn't been 
        // seen already, mark it to be removed
        if (!requiredEntities.Any(e => e.TableName.ToLowerInvariant() ==
                                        tableName.ToLowerInvariant())
            && !removeCommandKeys.Contains(tableName))
        {
          removeCommandKeys.Add(tableName);
        }
      }

      foreach (string tableName in removeCommandKeys)
      {
        commands.Remove(tableName);
      }
    }

    private Dictionary<string, Dictionary<string, string>> GetLocalizationEntries(string extensionName, string entityGroupName)
    {
      var localizationEntries = new Dictionary<string, Dictionary<string, string>>();
      var Extension = extensionName.Replace("MetraTech.", string.Empty);
      string localizationDir = SystemConfig.GetBusinessEntityLocalizationDir(Extension);
      if (!Directory.Exists(localizationDir))
      {
        logger.Warn(String.Format("Cannot find localization directory '{0}'", localizationDir));
        return localizationEntries;
      }

      var files = new List<string>(Directory.GetFiles(localizationDir));

      List<Entity> entities = MetadataRepository.Instance.GetEntities(extensionName, entityGroupName, false);

      try
      {
        foreach (Entity entity in entities)
        {
          string localizationFilePrefix = Name.GetEntityLocalizationFilePrefix(entity.FullName);
          List<string> localizationFiles = files.FindAll(f => Path.GetFileName(f).StartsWith(localizationFilePrefix));

          if (localizationFiles.Count == 0) continue;

          foreach (string localizationFile in localizationFiles)
          {
            XElement root = XElement.Load(localizationFile);
            string languageCode = root.Element("language_code").Value.ToLower();

            Dictionary<string, string> localeNameValue;
            localizationEntries.TryGetValue(languageCode, out localeNameValue);
            if (localeNameValue == null)
            {
              localeNameValue = new Dictionary<string, string>();
              localizationEntries.Add(languageCode, localeNameValue);
            }

            var elements = root.Elements("locale_space").Elements("locale_entry");
            foreach (XElement localeEntry in elements)
            {
              localeNameValue.Add(localeEntry.Element("Name").Value, localeEntry.Element("Value").Value);
            }
          }
        }
      }
      catch (System.Exception e)
      {
        logger.Error(String.Format("Cannot read localization files in directory '{0}'", localizationDir), e);
        throw;
      }


      return localizationEntries;
      
    }
    /// <summary>
    ///    Get the EntityGroup specified by extensionName and entityGroupName.
    ///    Create one, if it doesn't exist.
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    private EntityGroup GetEntityGroup(string extensionName, string entityGroupName)
    {
      EntityGroup entityGroup = null;

      Dictionary<string, EntityGroup> entityGroups;
      EntityGroupsByExtension.TryGetValue(extensionName.ToLower(), out entityGroups);

      if (entityGroups != null)
      {
        entityGroups.TryGetValue(entityGroupName.ToLower(), out entityGroup);
      }

      if (entityGroup == null)
      {
        entityGroup = new EntityGroup(extensionName, entityGroupName);
        AddEntityGroup(entityGroup);
      }

      return entityGroup;
    }

    private void AddEntityGroup(EntityGroup entityGroup)
    {
      Check.Require(entityGroup != null, "entityGroup cannot be null", SystemConfig.CallerInfo);
      Check.Require(entityGroup.IsValid(), "entityGroup is not valid", SystemConfig.CallerInfo);

      Dictionary<string, EntityGroup> entityGroups;
      EntityGroupsByExtension.TryGetValue(entityGroup.ExtensionName.ToLower(), out entityGroups);

      if (entityGroups == null)
      {
        entityGroups = new Dictionary<string, EntityGroup>();
        EntityGroupsByExtension.Add(entityGroup.ExtensionName.ToLower(), entityGroups);
      }

      if (entityGroups.ContainsKey(entityGroup.Name.ToLower()))
      {
        entityGroups[entityGroup.Name.ToLower()] = entityGroup;
      }
      else
      {
        entityGroups.Add(entityGroup.Name.ToLower(), entityGroup);
      }
    }
    
    private string GetTopRowSql(string tableName, bool isOracle)
    {
      Check.Require(!String.IsNullOrEmpty(tableName), String.Format("tableName cannot be null or empty"));

      string topRowSql;

      if (isOracle)
      {
        topRowSql =
          "\n" +
          " select * from " + tableName + " where  rownum < 2" +
          "\n";
      }
      else
      {
        topRowSql =
          "\n" +
          " select top 1 * from " + tableName +
          "\n";
      }


      return topRowSql;
    
    }
    
    private string GetDropTableDDL(string tableName, bool isOracle)
    {
      Check.Require(!String.IsNullOrEmpty(tableName), String.Format("tableName cannot be null or empty"));
      
      string dropTableDDL;

      if (isOracle)
      {
        dropTableDDL =
          "\n" + 
          " if table_exists ('" + tableName + "') " +
          " then execute immediate 'drop table " + tableName + " cascade constraints'; " +
          " end if; " +
          "\n";
      }
      else
      {
        dropTableDDL =
         "\n " + 
         " if exists (select * from dbo.sysobjects where id = object_id(N'" + tableName +
         "') and OBJECTPROPERTY(id, N'IsUserTable') = 1) drop table " + tableName + "\n";
        
      }
     
      
      return dropTableDDL;
    }

    private string GetBackupAndDropTableDDL(string tableName, bool isOracle)
    {
      Check.Require(!String.IsNullOrEmpty(tableName), String.Format("tableName cannot be null or empty"));
      
      string backupAndDropTableDDL;
      string backupTableName = GetBackupTableName(tableName);

      if (isOracle)
      {
        backupAndDropTableDDL =
          "\n" +
          " if table_exists ('" + backupTableName + "') \n" +
          "   then execute immediate 'drop table " + backupTableName + " cascade constraints'; \n" +
          " end if; \n" +
          " if table_exists ('" + tableName + "') \n" +
          " then \n" +
          "   execute immediate 'create table " + backupTableName + " as select * from " + tableName + "'; \n" +
          "   execute immediate 'drop table " + tableName + " cascade constraints'; \n" +
          " end if; \n" +
          "\n";
      }
      else
      {
        backupAndDropTableDDL =
        "\n " +
        " if exists (select * from dbo.sysobjects where id = object_id(N'" + backupTableName + "') \n" +
        " and OBJECTPROPERTY(id, N'IsUserTable') = 1) \n" +
        "   drop table " + backupTableName + "\n" +
        " if exists (select * from dbo.sysobjects where id = object_id(N'" + tableName + "') \n" +
        " and OBJECTPROPERTY(id, N'IsUserTable') = 1) \n" +
        "   begin  select * into " + backupTableName + " from " + tableName + "\n" +
        "   drop table " + tableName + "\n" +
        " end; \n";
      }
  
      return backupAndDropTableDDL;
    }

    private string GetRestoreSql(EntityChangeSet entityChangeSet, bool isOracle)
    {
      // INSERT INTO NEWTABLE (COL1, COL2, COL3) SELECT COL1, COL4, COL7 FROM BACKUP_TABLE 

      string insertColumnList = StringUtil.Join(", ", entityChangeSet.InsertSelectColumnNameValues.Keys, k => k);
      string selectColumnList = StringUtil.Join(", ", entityChangeSet.InsertSelectColumnNameValues.Values, v => v);

      string backupTableName = GetBackupTableName(entityChangeSet.TableName);

      string restoreSql;
      if (isOracle)
      {
        restoreSql =
          "\n" +
          " execute immediate " +
          "' \n" +
          "  insert into " + entityChangeSet.TableName + " (" + insertColumnList + ") \n" +
          "  select " + selectColumnList + " from " + backupTableName + 
          "'; \n" +
          " execute immediate 'drop table " + backupTableName + " cascade constraints'; \n" +
          "\n";
      }
      else
      {
        restoreSql =
          "\n" +
          " begin \n" +
          " insert into " + entityChangeSet.TableName + " (" + insertColumnList + ") \n" +
          " select " + selectColumnList + " from " + backupTableName + "\n" +
          // " drop table " + backupTableName + "\n" +
          " end; \n" +
          "\n";
      }
      
 
      return restoreSql;
    }

    /// <summary>
    ///    Wrap command with exec_ddl (' command ');
    /// </summary>
    /// <param name="command"></param>
    /// <returns></returns>
    private string WrapExecDdl(string command)
    {
      return "\n execute immediate ' " + command.Replace("'","''") + " '; \n";
    }

    private string GetBackupTableName(string tableName)
    {
      return tableName + "_b";
    }

    private RepositoryAccess()
    {
      EntityGroupsByExtension = new Dictionary<string, Dictionary<string, EntityGroup>>();
    }
  
    

    /// <summary>
    ///   Replace NVARCHAR(1024) pattern with NVARCHAR(2048). Double the length.
    /// 
    ///   a) Property lengths (for string properties) in BME's are specified in terms of number of characters.
    ///   
    ///   b) The parameter (n) to the NVARCHAR data type in SQL Server NVARCHAR(n) indicates
    ///      the storage in terms of bytes. 
    /// 
    ///   c) The 'create table' commands generated by the SchemaExport tool from NHibernate
    ///      uses the property length (in characters) to specify the storage.
    ///   
    ///   d) Hence, for SQL Server, we specify the storage in bytes by doubling the number of characters.
    /// 
    ///   e) The corresponding NVARCHAR2 data type in Oracle indicates the storage in terms of characters.
    ///      Nothing to be done for Oracle.
    /// </summary>
    /// <param name="command"></param>
    /// <returns></returns>
    private static string FixNVarcharLength(string command)
    {
      // Match NVARCHAR(1024)
      var regex = new Regex(@"nvarchar\((\d+)\)");

      string output = 
        regex.Replace(command.ToLower(), delegate(Match match)
        {
          string originalValue = match.Groups[1].Value;
          string updatedValue = Convert.ToString(2 * Convert.ToInt32(originalValue));
          return match.Value.Replace(originalValue, updatedValue);
        });

      return output;
    }

    private bool IsCompoundPropertyForeignKey(string addConstraintCommand, 
                                              string tableName, 
                                              Entity entity)
    {
      Check.Require(!String.IsNullOrEmpty(addConstraintCommand), "addConstraintCommand cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(tableName), "tableName cannot be null or empty");
      Check.Require(entity != null, "entity cannot be null");

      // Only consider Compound's
      if (entity.EntityType != EntityType.Compound)
      {
        return false;
      }

      // Get the column names 
      string columnNames = addConstraintCommand.Between("foreign key (", ")");
      Check.Require(!String.IsNullOrEmpty(columnNames), 
                    String.Format("Cannot find column name between 'foreign key (' and ')' in command '{0}'", addConstraintCommand));
      
      // Multiple column names will be separated by comma
      string[] columns = columnNames.Split(new char[] {','}, StringSplitOptions.None);

      foreach (string columnName in columns)
      {
        // If the columnName corresponds to a compound property, return true
        Property property = entity.GetPropertyByColumnName(columnName.Trim());
        if (property != null && property.IsCompound)
        {
          return true;
        }
      }

      return false;
    }
    #endregion


    #region Data
    private static readonly ILog logger = LogManager.GetLogger("RepositoryAccess");
    private static RepositoryAccess instance;
    private static readonly object syncRoot = new Object();
    #endregion


    
  }

  /// <summary>
  ///    Determine the drop order of tables 
  /// </summary>
  internal class TableDropOrder : IComparer<string>
  {
    public TableDropOrder(EntityGraph entityGraph)
    {
      this.entityGraph = entityGraph;
    }

    /// <summary>
    ///   return 0 - if drop order does not matter
    ///   return -1 - if tableName1 must be dropped before tableName2
    ///   return 1 - if tableName2 must be dropped before tableName1
    /// </summary>
    /// <param name="tableName1"></param>
    /// <param name="tableName2"></param>
    /// <returns></returns>
    public int Compare(string tableName1, string tableName2)
    {
      if (tableName1.ToLowerInvariant() == tableName2.ToLowerInvariant())
      {
        return 0;
      }

      // Regex for relationship table names:
      // t_be_\w{1,3}_\w{1,3}_r_

      if (tableName1.ToLowerInvariant().Contains("_r_") &&
          !tableName2.ToLowerInvariant().Contains("_r_"))
      {
        return -1;
      }
      
      if (!tableName1.ToLowerInvariant().Contains("_r_") &&
          tableName2.ToLowerInvariant().Contains("_r_"))
      {
        return 1;
      }

      if (tableName1.ToLowerInvariant().Contains("_r_") &&
          tableName2.ToLowerInvariant().Contains("_r_"))
      {
        return 0;
      }

      return entityGraph.GetDropOrder(tableName1, tableName2);
    }

    private EntityGraph entityGraph;
  }

  /// <summary>
  ///    Sort relationship tables (containing '_r_') ahead of regular tables
  /// </summary>
  public class RelationshipTablesFirst : IComparer<string>
  {
    public int Compare(string tableName1, string tableName2)
    {
      if (tableName1.ToLowerInvariant() == tableName2.ToLowerInvariant())
      {
        return 0;
      }

      // Regex for relationship table names:
      // t_be_\w{1,3}_\w{1,3}_r_

      if (tableName1.ToLowerInvariant().Contains("_r_") &&
          !tableName2.ToLowerInvariant().Contains("_r_"))
      {
        return -1;
      }

      return 1;
    }
  }

  /// <summary>
  ///    Sort relationship tables (containing '_r_') at the end of regular tables
  /// </summary>
  public class RelationshipTablesLast : IComparer<string>
  {
    public int Compare(string tableName1, string tableName2)
    {
      if (tableName1.ToLowerInvariant() == tableName2.ToLowerInvariant())
      {
        return 0;
      }

      // Regex for relationship table names:
      // t_be_\w{1,3}_\w{1,3}_r_

      if (tableName1.ToLowerInvariant().Contains("_r_") &&
          !tableName2.ToLowerInvariant().Contains("_r_"))
      {
        return 1;
      }

      return -1;
    }
  }
  // public class TableNameSorter : IComparer<string>
  //{
  //  static TableNameSorter()
  //  {
  //    relationshipTableRegex = new Regex("t_be_[a-z0-9_]{1, 3}_[a-z0-9_]{1, 3}_r_");
  //  }

  //  public int Compare(string tableName1, string tableName2)
  //  {
  //    if (tableName1.ToLowerInvariant() == tableName2.ToLowerInvariant())
  //    {
  //      return 0;
  //    }

  //    // Match t_be_[abc]_[pqr]_r_ 
  //    // [abc] and [pqr] can have a max of 3 characters
  //    // t_be_[A-Za-z0-9_]{1, 3}_[A-Za-z0-9_]{1, 3}_r_
  //    Match tableName1Match = relationshipTableRegex.Match(tableName1.ToLowerInvariant());
  //    Match tableName2Match = relationshipTableRegex.Match(tableName2.ToLowerInvariant());
  //    if (tableName1Match.Success && !tableName2Match.Success)
  //    {
  //      return -1;
  //    }
      
  //    return 1;
  //  }

  //  static Regex relationshipTableRegex;
  //}


 
}

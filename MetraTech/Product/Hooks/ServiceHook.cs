using System;
using System.Collections.Generic;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Collections;
using System.Text;
using System.Reflection;
using System.Diagnostics;
using MetraTech;
using MetraTech.Pipeline;
using MetraTech.Interop.MTProductCatalog;
using Rowset = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Product.Hooks.DynamicTableUpdate;
using MetraTech.Product.Hooks.InsertProdProperties;


namespace MetraTech.Product.Hooks
{

    [ClassInterface(ClassInterfaceType.None)]
    [Transaction(TransactionOption.Required, Isolation = TransactionIsolationLevel.Any)]
    [Guid("4C116291-CDFC-4594-89D1-7FBF3A855C76")]
    public class ServiceDefWriter : ServicedComponent
    {

        private MetraTech.Logger mLog = new Logger("[ServiceDefWriter]");

        [AutoComplete]
        public void RemoveServiceDef(string tableName, string svcName)
        {
            ConnectionInfo netMeterInfo = new ConnectionInfo(Common.NetMeterDb);
            ConnectionInfo stageDBInfo = new ConnectionInfo(Common.NetMeterStageDb);

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    //drop the table  
                    using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__DROP_SERVICE_DEF_TABLE__"))
                    {
                        adpStmt.AddParam(Common.TableNameParam, string.Format("{0}{1}{2}", netMeterInfo.Catalog, (netMeterInfo.IsSqlServer ? ".." : "."), tableName));
                        adpStmt.ExecuteNonQuery();
                    }

                    //delete the row from t_service_def_log
                    using (IMTAdapterStatement adpStmt2 = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__DELETE_FROM_SDEF_LOG__"))
                    {
                        adpStmt2.AddParam(Common.SdfNameParam, svcName);
                        adpStmt2.ExecuteNonQuery();
                    }
                }

                // drops the staging t_svc table for sql server only
                using (IMTConnection conn = ConnectionManager.CreateConnection(stageDBInfo))
                {
                    using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__DROP_SERVICE_DEF_TABLE__"))
                    {
                        adpStmt.AddParam(Common.TableNameParam, string.Format("{0}{1}{2}", stageDBInfo.Catalog, (stageDBInfo.IsSqlServer ? ".." : "."), tableName));
                        adpStmt.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                mLog.LogException("RemoveServiceDef() method.", ex);
                throw;
            }
        }

        [AutoComplete]
        public void AddServiceDef(string query, string indexQuery, string uindexQuery, string pkConstraintQuery, string stagingQuery,
            string svcName, string chksum, string tableName, string stageTableName)
        {
            // all we need to do is execute the create table query and 
            // insert into t_service_def_log a record, for now.
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    // creates the real t_svc table
                    using (IMTAdapterStatement addDeclare = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__ADD_DECLARE__"))
                    {
                        using (IMTAdapterStatement execddl = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__EXEC_DDL__"))
                        {
                            addDeclare.AddParam("%%DDL%%", query, true);
                            addDeclare.ExecuteNonQuery();
                            addDeclare.ClearQuery();

                            if (!string.IsNullOrEmpty(uindexQuery))
                            {
                                execddl.AddParam("%%DDL%%", uindexQuery);

                                addDeclare.AddParam("%%DDL%%", execddl.Query, true);
                                addDeclare.ExecuteNonQuery();
                                execddl.ClearQuery();
                                addDeclare.ClearQuery();
                            }

                            if (!string.IsNullOrEmpty(pkConstraintQuery))
                            {
                                execddl.AddParam("%%DDL%%", pkConstraintQuery);

                                addDeclare.AddParam("%%DDL%%", execddl.Query, true);
                                addDeclare.ExecuteNonQuery();
                                execddl.ClearQuery();
                                addDeclare.ClearQuery();
                            }

                            //create an index on id_parent_sess
                            execddl.AddParam("%%DDL%%", indexQuery);
                            addDeclare.AddParam("%%DDL%%", execddl.Query, true);
                            addDeclare.ExecuteNonQuery();

                            // creates the staging table
                            // NOTE: the Listener will also attempt to create missing staging tables on startup
                            using (
                                IMTAdapterStatement drop = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                       "__DROP_SERVICE_DEF_TABLE__"))
                            {
                                drop.AddParam("%%TABLE_NAME%%", stageTableName);
                                drop.ExecuteNonQuery();
                            }
                        }
                    }
                    //add a row in t_service_def_log
                    using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__INSERT_INTO_SDEF_LOG__"))
                    {
                        adpStmt.AddParam("%%SDEF_NAME%%", svcName);
                        adpStmt.AddParam("%%SDEF_CHECKSUM%%", chksum);
                        adpStmt.AddParam("%%SDF_TABLE_NAME%%", tableName);
                        adpStmt.ExecuteNonQuery();
                    }
                }

                // for staging
                using (IMTConnection conn = ConnectionManager.CreateConnection(new ConnectionInfo(Common.NetMeterStageDb)))
                {
                    // creates the real t_svc table
                    using (IMTAdapterStatement execddl = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__ADD_DECLARE__"))
                    {
                        execddl.AddParam("%%DDL%%", stagingQuery, true);
                        execddl.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(String.Format("Error: {0}", ex));
                mLog.LogException("AddServiceDef() method.", ex);
                throw;
            }
        }

        [AutoComplete]
        public void ModifyServiceDef(string st)
        {
        }

    }

    /// <summary>
    /// Creates DDL foe Service Definitions
    /// </summary>
    [ComVisible(false)]
    public class DDLCreator
    {
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="prefix">table prefix of which will be compiled a table name</param>
        /// <param name="serviceDef"></param>
        public DDLCreator(string prefix, IServiceDefinition serviceDef)
        {
            _tablePrefix = prefix;
            _serviceDef = serviceDef;
            _logger = new Logger("[ServiceDefHook]");

            // Reserved properties are _IntervalID, _CollectionID, _TransactionCookie and _Resubmit.
            // TODO: put this in some common place for both, listener and the hook to access.
            // Initialize Reserver properties table.
            // NOTE: The order of all there column is important because they are treated specially by the dbparser.
            _reservedProperties = new Hashtable
                                 {
                                     {"c__IntervalID", _connInfoBase.IsOracle ? "number(10)" : "integer"},
                                     {"c__TransactionCookie", _connInfoBase.IsOracle ? "nvarchar2(256)" : "nvarchar(256)"},
                                     {"c__Resubmit", "char(1)"},
                                     {"c__CollectionID", _connInfoBase.IsOracle ? "raw(16)" : "binary(16)"},
                                 };
           _reservedPropertiesDescription = new List<MTPropertyMetaData>
                                              {
                                                new MTPropertyMetaData {DBColumnName = "c__IntervalID", Description = "Reserved column. Interval identifier."},
                                                new MTPropertyMetaData {DBColumnName = "c__TransactionCookie", Description = "Reserved column. Transaction Cookie."},
                                                new MTPropertyMetaData {DBColumnName = "c__Resubmit", Description = "Reserved column. Can Service Definition be resubmitted?"},
                                                new MTPropertyMetaData {DBColumnName = "c__CollectionID", Description = "Reserved column. Collection identifier."}
                                              };
        }

        /// <summary>
        /// Generates SQL-query to create columns description of table
        /// </summary>
        /// <param name="tableName">Current table name</param>
        /// <param name="property">Instance of <see cref="IMTPropertyMetaData"/></param>
        /// <returns>SQL-query</returns>
        public static string GenerateTableDescriptionQuery(string tableName, string description)
        {
            string result = String.Empty;

            if (!String.IsNullOrEmpty(description.Trim()))
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (
                        IMTAdapterStatement execddl = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                  "__EXEC_DDL__"))
                    {
                        using (
                            IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                      "__CREATE_TABLE_DESCRIPTION__"))
                        {
                            adpStmt.AddParam(Common.TableNameParam, tableName);
                            adpStmt.AddParam(Common.TableDescriptionParam, description);

                            if (conn.ConnectionInfo.IsSqlServer)
                            {
                                execddl.AddParam("%%DDL%%", adpStmt.Query, true);
                            }
                            else
                            {
                                execddl.AddParam("%%DDL%%", adpStmt.Query);
                            }
                        }
                        result = execddl.Query;
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// Generates SQL-query to create columns description of table
        /// </summary>
        /// <param name="tableName">Current table name</param>
        /// <param name="property">Instance of <see cref="IMTPropertyMetaData"/></param>
        /// <returns>SQL-query</returns>
        public static string GenerateColumnDescriptionQuery(string tableName, IMTPropertyMetaData property)
        {
            string result = String.Empty;

            if (!String.IsNullOrEmpty(property.Description.Trim()))
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (
                        IMTAdapterStatement execddl = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                  "__EXEC_DDL__"))
                    {
                        using (
                            IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                      "__CREATE_COLUMN_DESCRIPTION__"))
                        {
                            adpStmt.AddParam(Common.TableNameParam, tableName);
                            adpStmt.AddParam(Common.ColumnNameParam, property.DBColumnName);
                            adpStmt.AddParam(Common.ColumnDescriptionParam, property.Description.Trim());
                            if (conn.ConnectionInfo.IsSqlServer)
                            {
                                execddl.AddParam("%%DDL%%", adpStmt.Query, true);
                            }
                            else
                            {
                                execddl.AddParam("%%DDL%%", adpStmt.Query);
                            }
                        }
                        result = execddl.Query;
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// Generates SQL-query to create table statement for both DB name (general nad staging).
        /// Attantion! Now is creating with short table name, so for general/staging DB must be created the  specify connections (not one general connection) 
        /// </summary>
        /// <param name="staging">true - generates statemennt for staging table</param>
        /// <returns>SQL-query</returns>
        public string GenerateCreateTableStatement(bool staging)
        {
            string gueryTagName = staging
                                    ? "__CREATE_SERVICE_DEF_TABLE_STAGE__"
                                    : "__CREATE_SERVICE_DEF_TABLE__";

            StringBuilder reservedColumns = new StringBuilder();
            StringBuilder additionalColumns = new StringBuilder();
            StringBuilder columnsDescription = new StringBuilder();

            string tableName = staging
                                   ? GetShortTableName(GetFullStageTableName())
                                   : GetTableName();

            // create reserved columns
            foreach (var columnName in _reservedProperties.Keys)
            {
                reservedColumns.Append(String.Format(",\n  {0} {1}", columnName, _reservedProperties[columnName]));
            }
            
            //create description for reserved columns
            foreach (var reservedColumnDescription in _reservedPropertiesDescription)
            {
              columnsDescription.AppendLine(GenerateColumnDescriptionQuery(tableName, reservedColumnDescription));
            }

            //// for each property in the service def, add a column, take type,
            //// length, required/notrequired into account.
            foreach (IMTPropertyMetaData propMeta in _serviceDef.OrderedProperties)
            {
                additionalColumns.Append(String.Format(",\n  {0}", GetPropDDL(propMeta, staging)));
                columnsDescription.AppendLine(GenerateColumnDescriptionQuery(tableName, propMeta));
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection(staging ? _connInfoStage : _connInfoBase))
            {
                //creates the table  
                using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, gueryTagName))
                {
                    adpStmt.AddParam(Common.TableNameParam, tableName);
                    if (!staging && conn.ConnectionInfo.IsSqlServer)
                    {
                        adpStmt.AddParam(Common.IdPartitionDefaultValue, GetIdPartitionDefaultValue());
                    }
                    adpStmt.AddParam(Common.AdditionalColumnsParam, additionalColumns.ToString());
                    adpStmt.AddParam(Common.ReservedColumnsParam, reservedColumns.ToString());
                    var createTableDesciption = GenerateTableDescriptionQuery(tableName, _serviceDef.Description.Trim());
                    adpStmt.AddParam(Common.CreateTableDescriptionParam, createTableDesciption, true);
                    adpStmt.AddParam(Common.CreateColumnsDescriptionParam, columnsDescription.ToString(), true);
                    return adpStmt.Query;
                }
            }
        }

        public string GenerateCreateIndexStatement()
        {
            string nm = GetTableName();
            nm = "x_svc_" + nm.Substring(6, nm.Length - 6);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__CREATE_INDEX__"))
                {
                    adpStmt.AddParam(Common.NameSpaceParam,
                                        nm);
                    adpStmt.AddParam(Common.TableNameParam,
                                         GetTableName());

                    return adpStmt.Query;
                }
            }
        }

        public string GenerateCreateUniqueIndexStatement()
        {
            if (_connInfoBase.IsOracle)
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (
                      IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                "__CREATE_UNIQUE_INDEX__"))
                    {
                        string nm = GetTableName();
                        nm = "pk_svc_" + nm.Substring(7, nm.Length - 7);

                        adpStmt.AddParam(Common.NameSpaceParam, nm);
                        adpStmt.AddParam(Common.TableNameParam, GetTableName());

                        return adpStmt.Query;
                    }
                }
            }
            else
            {
                return string.Empty;
            }
        }

        public string GenerateCreatePrimaryKeyConstraintStatement()
        {
            if (_connInfoBase.IsOracle)
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (
                      IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                                "__ALTER_PRIMARY_KEY_CONSTRAINT__"))
                    {

                        string nm = GetTableName();
                        nm = "pk_svc_" + nm.Substring(7, nm.Length - 7);

                        adpStmt.AddParam(Common.NameSpaceParam, nm);
                        adpStmt.AddParam(Common.TableNameParam, GetTableName());

                        return adpStmt.Query;
                    }
                }
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Gets resererfer table columns name and theirs types
        /// </summary>
        /// <returns>Hashtable key - column name; value - column type</returns>
        public Hashtable GetReservedProp()
        {
            return _reservedProperties;
        }

        private string GetPropDDL(IMTPropertyMetaData prop, bool staging)
        {
            StringBuilder propDDL = new StringBuilder();
            propDDL.AppendFormat("c_{0} ", prop.Name);

            switch (prop.DataType)
            {
                case PropValType.PROP_TYPE_STRING:
                    // the listener never strictly enforced string lengths
                    // so all string columns must be the maximum product string length
                    //    - non-encrypted maximum string length is 255
                    //    - encrypted maximum string lenght is 510 (2x allowance for expansion)
                    if (prop.Name.EndsWith("_"))
                        propDDL.AppendFormat("{0}(510)", _connInfoBase.IsOracle ? "nvarchar2" : "nvarchar");
                    else
                        propDDL.AppendFormat("{0}(255)", _connInfoBase.IsOracle ? "nvarchar2" : "nvarchar");
                    break;

                case PropValType.PROP_TYPE_INTEGER:
                case PropValType.PROP_TYPE_ENUM:
                    propDDL.Append(_connInfoBase.IsOracle ? "number(10)" : "integer");
                    break;
                case PropValType.PROP_TYPE_BIGINTEGER:
                    propDDL.Append(_connInfoBase.IsOracle ? "number(20)" : "bigint");
                    break;
                case PropValType.PROP_TYPE_TIME:
                case PropValType.PROP_TYPE_DATETIME:
                    propDDL.Append(_connInfoBase.IsOracle ? "date" : "datetime");
                    break;
                case PropValType.PROP_TYPE_BOOLEAN:
                    propDDL.Append("char(1)");
                    break;
                case PropValType.PROP_TYPE_DOUBLE:
                case PropValType.PROP_TYPE_DECIMAL:
                    propDDL.Append(Constants.METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_STR);
                    break;
            }

            // staging table must not have null constraints so that
            // missing required property condition is handled correctly
            if (!staging && prop.Required)
                propDDL.Append(" not null");

            return propDDL.ToString();
        }

        private string GetShortTableName(string fullTableName)
        {
            return fullTableName.Contains(".")
                       ? fullTableName.Substring(fullTableName.LastIndexOf('.') + 1)
                       : fullTableName;
        }

        /// <summary>
        /// Gets fult table name for staging table.
        /// For Oracle: "user.table"
        /// For MSSQL: "db.owner..table"
        /// </summary>
        /// <returns>Full table name</returns>
        public string GetFullStageTableName()
        {
            // return if name is already calc'd and cached
            if (_stageTableName != null)
                return _stageTableName;

            // fully qualify the table with the database name so that this query
            // can be executed correctly in any database context (especially via the listener)
            // oracle form:   user.table
            // sqlsvr form:   db.owner..table
            //
            _stageTableName = _connInfoStage.Catalog
                                  + (_connInfoBase.IsOracle ? "." : "..")
                                  + GetTableName();

            return _stageTableName;
        }

        /// <summary>
        /// Gets short table name with prefix
        /// </summary>
        /// <returns>Short table name</returns>
        public string GetTableName()
        {
            // return if name is already calc'd and cached
            if (_tableName != null)
                return _tableName;

            /* users of the _temp suffix will have to adapt to the
             * new regime of dbnamehash
             */

            // compose the table name and hash it
            string name = _tablePrefix + _serviceDef.LongTableName;
            string shortname = new DBNameHash().GetDBNameHash(name);

            // if hashing shortened the name, report it
            if (shortname.Length < name.Length)
                _logger.LogWarning("{0} too long. Hashed name: {1}", name, shortname);

            return (_tableName = shortname);
        }

        /// <summary>
        /// Get current default value for id_partition column of service definition table.
        /// Is called when svc is not staging table.
        /// </summary>
        /// <returns></returns>
        private Int32 GetIdPartitionDefaultValue()
        {
            Int32 id_partition_default_value = 0;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath,
                                                                            "__GET_ID_PARTITION_FOR_SERVICE_DEF_TABLES__"))
                {
                    using (IMTDataReader reader = adpStmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            id_partition_default_value = reader.GetInt32(0);
                        }
                    }
                }
            }
            return id_partition_default_value;
        }

        private string _tableName = null;
        private string _stageTableName = null;
        private string _tablePrefix;
        private IServiceDefinition _serviceDef;
        private ConnectionInfo _connInfoBase = new ConnectionInfo(Common.NetMeterDb);
        private ConnectionInfo _connInfoStage = new ConnectionInfo(Common.NetMeterStageDb);
        private MetraTech.Logger _logger;
        private Hashtable _reservedProperties;
        private List<MTPropertyMetaData> _reservedPropertiesDescription;


    }

    [Guid("33076bcc-7db1-4446-9ff3-33824dd7fe2e")]
    public interface IServiceDefHook : MetraTech.Interop.MTHooklib.IMTHook
    {
        // generates a DDL string to create a t_svc staging table
        // NOTE: this method is explicitly exposed from the hook so that
        // listener can also leverage it (listener may need to create
        // missing staging tables on-demand) (CR12632)
        string GenerateStagingCreateTableStatement(string svcDefName, out string stageTableName);
    }

    /// <summary>
    /// Summary description for ServiceDefHook.
    /// </summary>
    [Guid("2E2EBA78-DA30-453a-92A0-3C945B59FF97")]
    [ClassInterface(ClassInterfaceType.None)]
    public class ServiceDefHook : IServiceDefHook
    {
        private MetraTech.Logger mLog;
        private ServiceDefinitionCollection mSvcDefCollection;
        private ArrayList mDBServiceDefs;
        private ArrayList mDBServiceTableNames;

        public ServiceDefHook()
        {
            mLog = new Logger("[ServiceDefHook]");
            mDBServiceDefs = new ArrayList();
            mDBServiceTableNames = new ArrayList();
            mSvcDefCollection = new ServiceDefinitionCollection();
        }

        private bool CheckSumMatches(string serviceName, string filechkSum)
        {
            bool chkSumSame = false;
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__SELECT_CHECKSUM_FROM_SDEF_LOG__"))
                {
                    adapstmt.AddParam(Common.SdfNameParam, serviceName);
                    using (IMTDataReader reader = adapstmt.ExecuteReader())
                    {
                        string dbchecksum = null;
                        if (reader.Read())
                            dbchecksum = reader.GetString("tx_checksum");
                        if (dbchecksum == filechkSum)
                        {
                            chkSumSame = true;
                        }
                    }
                }
            }
            return chkSumSame;
        }

        private void DeployServiceDefinitionTableUnderPartitionSchema(String tableName)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                if (conn.ConnectionInfo.IsSqlServer)
                {
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("prtn_DeployServiceDefinitionPartitionedTable"))
                    {
                        stmt.AddParam("svc_table_name", MTParameterType.String, tableName);
                        stmt.ExecuteNonQuery();
                    }
                }
            }

        }

        public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
        {
            try
            {
                mLog.LogDebug("Starting hook execution.");

                //load all the created servicedefintions
                Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
                rowset.Init(Common.ServiceDefQueryPath);
                rowset.SetQueryTag("__SELECT_FROM_SDEF_LOG__");
                rowset.Execute();

                if (rowset.RecordCount > 0)
                {
                    rowset.MoveFirst();
                    while (!Convert.ToBoolean(rowset.EOF))
                    {
                        string sdname = (string)rowset.get_Value(0);
                        mDBServiceDefs.Add(sdname);
                        mDBServiceTableNames.Add((string)rowset.get_Value(1));
                        rowset.MoveNext();
                    }
                }
                foreach (string svcDefName in mSvcDefCollection.Names)
                {
                    IServiceDefinition serviceDef = mSvcDefCollection.GetServiceDefinition(svcDefName);

                    //does this service already exist in the database?
                    //need to do a caseinsensitive check.  It would be better to use some
                    //other collections class perhaps.
                    bool found = false;

                    for (int jj = 0; jj < mDBServiceDefs.Count && !found; jj++)
                    {
                        if (string.Compare(mDBServiceDefs[jj].ToString(), svcDefName, true) == 0)
                            found = true;
                    }

                    if (found)
                    {
                        mLog.LogDebug("Service Def {0} already exists in the database", serviceDef.Name);
                        MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
                        bool ck = false;
                        string chkSum = config.ReadConfiguration(mSvcDefCollection.GetServiceDefFileName(svcDefName), out ck).Checksum;
                        mLog.LogDebug("Checksum is: {0}", chkSum);

                        DDLCreator creator = new DDLCreator(Common.ServDefPrefix, serviceDef);
                        bool checksummatches = CheckSumMatches(svcDefName, chkSum);
                        IDynamicTableUpdate update = new MetraTech.Product.Hooks.DynamicTableUpdate.DynamicTableUpdate();
                        if (!update.UpdateTable(mSvcDefCollection.GetServiceDefFileName(serviceDef.Name),
                                                            creator.GetReservedProp(), checksummatches, false))
                            throw new Exception("Synchronization of " + serviceDef.Name + " file failed.");
                    }
                    else
                    {
                        mLog.LogDebug("Creating service defintion table: {0}", serviceDef.Name);

                        //generate query to create the table.
                        DDLCreator creator = new DDLCreator(Common.ServDefPrefix, serviceDef);
                        string query = creator.GenerateCreateTableStatement(false);
                        string stagingQuery = creator.GenerateCreateTableStatement(true);
                        string indexQuery = creator.GenerateCreateIndexStatement();
                        string uindexQuery = creator.GenerateCreateUniqueIndexStatement();
                        string pkConstraintQuery = creator.GenerateCreatePrimaryKeyConstraintStatement();

                        //generate chksum.  The msixdef file is being read twice...
                        MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
                        bool ck = false;
                        string chkSum = config.ReadConfiguration(mSvcDefCollection.GetServiceDefFileName(svcDefName), out ck).Checksum;
                        mLog.LogDebug("Checksum is: {0}", chkSum);

                        //mLog.LogDebug("Staging table Create Statement for table name : {0}, Query : {1}", Common.ServDefPrefix + serviceDef, stagingQuery);

                        //finally do the database work.
                        ServiceDefWriter writer = new ServiceDefWriter();

                        writer.AddServiceDef(query, indexQuery, uindexQuery, pkConstraintQuery, stagingQuery, svcDefName,
                          chkSum, creator.GetTableName(), creator.GetFullStageTableName());

                        // if DB is partitioned and partition schema is exists and newly created svc table not under partition schema 
                        DeployServiceDefinitionTableUnderPartitionSchema(creator.GetTableName());

                        //add the properties in the t_service_def_prop table
                        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                        {
                            int servicededid = 0;

                            using (IMTAdapterStatement propstmp = conn.CreateAdapterStatement(Common.ServiceDefQueryPath, "__SELECT_SERVICE_DEF_BY_NAME__"))
                            {
                                propstmp.AddParam(Common.SdfNameParam, svcDefName);
                                using (IMTDataReader reader = propstmp.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        servicededid = reader.GetInt32("id_service_def");
                                    }
                                }
                            }

                            if (servicededid <= 0)
                                throw new Exception("Couldn't find servicedefid for " + svcDefName);
                            IInsertProdProperties insertprodprop = new MetraTech.Product.Hooks.InsertProdProperties.InsertProdProperties();
                            insertprodprop.Initialize(mSvcDefCollection.GetServiceDefFileName(svcDefName), servicededid);
                            if (insertprodprop.InsertProperties() == 0)
                            {
                                throw new Exception("Inserting service def properties failed for " + svcDefName);
                            }
                        }
                    }
                }

                //now for the tables for whom no msixdef files exist.  These need to be dropped
                for (int ii = 0; ii < mDBServiceDefs.Count; ii++)
                {
                    string name = (string)mDBServiceDefs[ii];
                    string tablename = (string)mDBServiceTableNames[ii];
                    string filename = mSvcDefCollection.GetServiceDefFileName(name);
                    if (filename == null)
                    {
                        ServiceDefWriter writer = new ServiceDefWriter();
                        mLog.LogDebug("Dropping service defintion: {0}", name);
                        writer.RemoveServiceDef(tablename, name);
                    }
                }
            }
            catch (System.Exception ex)
            {
                mLog.LogError(ex.ToString());
                throw;
            }
        }

        public string GenerateStagingCreateTableStatement(string svcDefName, out string stageTableName)
        {
            IServiceDefinition serviceDef = mSvcDefCollection.GetServiceDefinition(svcDefName);
            DDLCreator creator = new DDLCreator(Common.ServDefPrefix, serviceDef);
            stageTableName = creator.GetFullStageTableName();
            return creator.GenerateCreateTableStatement(true);
        }
    }

    //todo: to resubmit an edited failed transaction we need a supplementary table for each service def..
    //need to think about that.

    
}

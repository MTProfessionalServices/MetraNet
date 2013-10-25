using System;
using System.Collections;
using System.Linq;
using System.Xml;
using System.Text;
using System.Runtime.InteropServices;
using MetraTech.Xml;
using MetraTech.Collections;
using MetraTech.DataAccess;
using MetraTech.Product.Hooks.UIValidation;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.RCD;
using MetraTech.Pipeline;
using System.Reflection;

[assembly: GuidAttribute("943C4ABB-3259-3963-9661-F6AC7AB5EFFA")]

namespace MetraTech.Product.Hooks.DynamicTableUpdate
{
    [Guid("62bb69e2-b72b-4952-a2cd-97e5d8005e34")]
    public interface IDynamicTableUpdate
    {
        bool UpdateTable(string filename, Hashtable ReservedProperties, bool checksummatches, bool bUseNonServicedConnection);
    }

    /// <summary>
    /// Summary description for Class1.
    /// </summary>
    [Guid("2981b8ab-4e62-4e69-a970-616598bc8634")]
    [ClassInterface(ClassInterfaceType.None)]
    public class DynamicTableUpdate : IDynamicTableUpdate
    {
        private string mFilePath;
        private EntityType mEntityType;

        private int mPropFKID;
        private string mEntityName;

        // Any properties externally added to the table.
        private Hashtable mReservedProperties = null;

        const string PV_CONFIG_PATH = @"\config\productview";
        const string PT_CONFIG_PATH = @"\config\ParamTable";
        const string AV_CONFIG_PATH = @"\config\accountview";
        const string SD_CONFIG_PATH = @"\config\service";
        const string PV_TABLE_PREFIX = "t_pv_";
        const string PT_TABLE_PREFIX = "t_pt_";
        const string AV_TABLE_PREFIX = "t_av_";
        const string SD_TABLE_PREFIX = "t_svc_";
        string mCreateTableQuery = null;
        string mGroupID;
        int mViewID = 0;
        MTStringCollection mColumns = new MTStringCollection();

        string mTargetTable = null;
        MetraTech.Logger mLog;

        // Oracle or SQL server?    
        bool mIsOracle;

        // alter table add-column/drop-column have same form in sqlsvr and oracle
        const string mAddColumn = @"alter table %%tabname%% add %%colname%% %%coltype%% %%constraint%% %%cannull%%";

        const string mAddColumnDescriptionSql = @" IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '%%tabname%%' and xtype = 'U')
                                            EXEC sys.sp_addextendedproperty
                                            @name=N'MS_Description', @value='%%description%%',
                                            @level0type=N'SCHEMA',@level0name=N'dbo',
                                            @level1type=N'TABLE',@level1name='%%tabname%%',
                                            @level2type=N'COLUMN',@level2name='%%colname%%'";

        const string mExecuteImmediateStatement = @" EXECUTE IMMEDIATE q'[%%DDL%%]';";
        const string mAddColumnDescriptionOracle = @" COMMENT ON COLUMN %%tabname%%.%%colname%% IS '%%description%%'";

        // rename column 
        const string mRenameColumn = @"alter table %%tabname%% rename column %%from%% to %%to%%";

        // For SQL server we need to drop the default constraint first before altering the column.
        const string mDropDefaultConstraint = @"if exists (select * from dbo.sysobjects where id = object_id(N'dbo.DF_MT_%%tabname%%_%%colname%%'))
                                        begin
                                            ALTER TABLE %%tabname%% DROP CONSTRAINT DF_MT_%%tabname%%_%%colname%% 
                                        end";

        // If we drop the default constraint then we need to reapply it.
        const string mApplyDefaultConstraint = @"ALTER TABLE %%tabname%% ADD CONSTRAINT DF_MT_%%tabname%%_%%colname%% %%default%% FOR %%colname%%";

        // For SQL server we need to drop the default constraint first.
        // We crate the default constraint with a predictable name: DF_MT_<tablename>_<column name> 
        const string mDropColumnOra = @"alter table %%tabname%% drop column %%colname%%";
        const string mDropColumnSqlSvr = mDropDefaultConstraint + " alter table %%tabname%% drop column %%colname%%";

        // modify/alter-column stmts differ bewteen sqlsvr and oracle
        const string mAlterColSqlSvr = @"alter table %%tabname%% alter column %%colname%% %%coltype%% %%cannull%%";
        const string mAlterColOra = @"alter table %%tabname%% modify %%colname%% %%coltype%% %%cannull%%";

        // PartitionOps contains partition state
        PartitionOps mPartitionOps = new PartitionOps();

        // UniqueKeyOps handles unique key modifications
        UniqueKeyOps mUniqueKeyOps = new UniqueKeyOps();

        private string mPropTableName;
        private string mPropTablePKName;
        private string mPropTableFKName;
        private Hashtable mPropsDataType = new Hashtable();

        [Guid("efa6b992-a14a-4d0e-a815-df31448b9d3b")]
        public enum EntityType
        {
            SD, PV, PT, AV, Charge
        }

        public DynamicTableUpdate()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                mIsOracle = conn.ConnectionInfo.IsOracle;
            }
        }

        /// <summary>
        /// This function will be used to update the tables dynamically so that data doesn't get vanish
        /// pokh-24-june - The checksummatches parameter can be removed now. It was added primarily to tackle the
        /// issue of difference in the checksum value generated in C# and C++ code.
        /// The checksum for PV & PT will not be updated by this code because the code for updating it has already 
        /// in place in their hooks class. AV & SD are C# hooks, so this issue will never arise 
        /// </summary>
        /// <param name="filename"></param>
        /// <returns></returns>
        public bool UpdateTable(string filename, Hashtable ReservedProperties, bool checksummatches, bool bUseNonServicedConnection)
        {
            mReservedProperties = ReservedProperties;
            string tablePrefix = null;
            try
            {
                mLog = new Logger("[DynamicTableUpdate]");
                if (mLog == null)
                    throw new ApplicationException("Couldn't create the Logger object");
                mLog.LogDebug("File name passed was: " + filename);

                // Find the complete path of the file based on the filename (passed as a parameter)
                if (filename.IndexOf(":") <= 0)
                {
                    IMTRcd rcd = new MTRcdClass();
                    IMTRcdFileList list = rcd.RunQuery(filename, true);
                    mFilePath = list[0].ToString();
                }
                else
                    mFilePath = filename;

                // Finding the entitype (PV, SD..) based on the path
                if (mFilePath.IndexOf(PV_CONFIG_PATH) >= 0)
                {
                    mEntityType = EntityType.PV;
                    tablePrefix = PV_TABLE_PREFIX;
                    mPropTableName = "t_prod_view_prop";
                    mPropTablePKName = "id_prod_view_prop";
                    mPropTableFKName = "id_prod_view";
                }
                else if (mFilePath.IndexOf(PT_CONFIG_PATH) >= 0)
                {
                    mEntityType = EntityType.PT;
                    tablePrefix = PT_TABLE_PREFIX;
                    mPropTableName = "t_param_table_prop";
                    mPropTablePKName = "id_param_table_prop";
                    mPropTableFKName = "id_param_table";
                }
                else if (mFilePath.IndexOf(AV_CONFIG_PATH) >= 0)
                {
                    mEntityType = EntityType.AV;
                    tablePrefix = AV_TABLE_PREFIX;
                    mPropTableName = "t_account_view_prop";
                    mPropTablePKName = "id_account_view_prop";
                    mPropTableFKName = "id_account_view";
                }
                else if (mFilePath.IndexOf(SD_CONFIG_PATH) >= 0)
                {
                    mEntityType = EntityType.SD;
                    tablePrefix = SD_TABLE_PREFIX;
                    mPropTableName = "t_service_def_prop";
                    mPropTablePKName = "id_service_def_prop";
                    mPropTableFKName = "id_service_def";
                }
                else
                    throw new Exception("Wrong mFilePath passed as the parameter");

                mLog.LogDebug("Dropping staging table");
                if (mEntityType == EntityType.SD || mEntityType == EntityType.PV)
                    DropStagingTables(mFilePath, tablePrefix);

                ObjectUpdate ou = null;
                MTXmlDocument doc = null;
                if (mEntityType == EntityType.PV)
                {
                    if (doc == null)
                    {
                        doc = new MTXmlDocument();
                        doc.Load(mFilePath);
                    }

                    string servicename = doc.SelectSingleNode("/defineservice/name").InnerText;
                    using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                    {
                        InternalProductView ipv = new InternalProductView(servicename, conn);
                        bool canResubmitFrom = MTXmlDocument.GetNodeValueAsBool(doc, "/defineservice/can_resubmit_from", false);
                        if (ipv.CanResubmitFrom != canResubmitFrom)
                        {
                            ipv.CanResubmitFrom = canResubmitFrom;
                            ou = new ObjectUpdate(ipv);
                        }
                    }
                }

                //Checksum already matches so no need to go further
                if (null == ou && checksummatches)
                    return true;

                // Initalize the partition ops object
                mPartitionOps.Init(mLog);

                //Before validating the changes, we would compare the checksum to find out that whether there were any changes
                //This code has been written because C# & C++ code generates different checksum values for 
                //same file. As for PT case the checksum will always be updated by the C++ code, there is no need
                //to do extra validation
                //pokh-28-june: The code for updating checksum for PV can be removed from this class.
                //As the SD & AV hooks are in C#, we would never face this problem. And even this code can be
                //commented
                if (mEntityType == EntityType.SD || mEntityType == EntityType.PV)
                {
                    MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
                    bool ck = false;
                    string chkSum = config.ReadConfiguration(mFilePath, out ck).Checksum;
                    if (doc == null)
                    {
                        doc = new MTXmlDocument();
                        doc.Load(mFilePath);
                    }
                    string servicename = doc.SelectSingleNode("/defineservice/name").InnerText;
                    using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement("queries\\ServiceDef", "__SELECT_CHECKSUM_FROM_SDEF_LOG__"))
                        {
                            if (mEntityType == EntityType.SD)
                            {
                                adapstmt.AddParam("%%SDEF_NAME%%", servicename);
                            }
                            else if (mEntityType == EntityType.PV)
                            {
                                adapstmt.ConfigPath = "queries\\ProductView";
                                adapstmt.QueryTag = "__SELECT_FROM_PV_LOG__";
                                adapstmt.AddParam("%%PV_NAME%%", servicename);
                            }

                            using (IMTDataReader reader = adapstmt.ExecuteReader())
                            {
                                string dbchecksum = null;
                                if (reader.Read())
                                    dbchecksum = reader.GetString("tx_checksum");
                                if (dbchecksum == chkSum)
                                {
                                    mLog.LogDebug("CheckSum found same for service: " + servicename);
                                    return true;
                                }
                            }
                        }
                    }
                }

                // Initialize unique key operations
                if (mEntityType == EntityType.PV)
                    mUniqueKeyOps.Init(mLog, mFilePath);

                // First we will validate the changes. For that we can use the DBPropValidator component
                mLog.LogDebug("Validating the changes by calling the DBPropValidator component");
                if (!ValidateTheChanges(mFilePath))
                {
                    mLog.LogError("The changes cannot be applied.");
                    return false;
                }

                //Find the chnages by comparing the file properties with what stored in the DB
                string description;
                ArrayList tableModificationData = FindChanges(mFilePath, tablePrefix, out description);

                //If atleast one change is required thenn apply it
                if (tableModificationData.Count > 0 || mUniqueKeyOps.HasChanges || ou != null)
                {
                    mLog.LogDebug("No. of changes found are: " + tableModificationData.Count);
                    for (int modcount = 1; modcount <= tableModificationData.Count; modcount++)
                    {
                        TableModifications mods = (TableModifications)tableModificationData[modcount - 1];
                        mLog.LogDebug("Modification " + modcount + ": " + mods.columnName + "," + mods.action);
                    }
                    ApplyRulesInTransaction(tableModificationData, ou, mEntityType, bUseNonServicedConnection, description);
                }
                else
                {
                    mLog.LogDebug("No changes found between the table and the config file.");
                }
            }
            catch (Exception ex)
            {
                if (mLog != null)
                {
                    mLog.LogError(ex.Message);
                }
                throw;
            }
            return true;
        }

        /// <summary>
        /// This function is used to validate the changes to make ensure that update happens successfully.
        ///  It calls the DBPropValidator to does the necessary validations
        /// </summary>
        /// <param name="filename"></param>
        /// <returns></returns>
        private bool ValidateTheChanges(string filename)
        {
            mLog.LogDebug("Starting ValidateTheChanges function: FileName:" + filename);

            // Load the xml
            XmlDocument doc = new XmlDocument();
            doc.Load(filename);
            ArrayList propnames = new ArrayList();
            foreach (XmlNode ptypenode in doc.SelectNodes("/defineservice/ptype"))
            {
                string propertyname = ptypenode.SelectSingleNode("dn").InnerText;
                if (propnames.Contains(propertyname))
                {
                    mLog.LogError("Property {0} is duplicated in file {1}", propertyname, filename);
                    return false;
                }
                else
                    propnames.Add(propertyname);
            }

            foreach (XmlNode ptypenode in doc.SelectNodes("/defineservice/ptype"))
            {
                string xmlstring = ptypenode.OuterXml;
                DBPropValidator validator = new DBPropValidator();
                validator.Initialize(xmlstring, filename, true);
                if (validator.ValidateProperty() != 0)
                    return false;
            }

            mLog.LogDebug("Ending ValidateTheChanges function");
            return true;
        }

        /// <summary>
        /// This function will be used to find the changes. It does it by retrieving the properties
        /// from the db to the properties stored in the config file.
        /// </summary>
        /// <param name="filename"></param>
        /// <param name="tableprefix"></param>
        /// <param name="description">Returns the table description</param>
        /// <returns></returns>
        ArrayList FindChanges(string filename, string tableprefix, out string description)
        {
            mLog.LogDebug("Starting FindChanges function");
            MetaDataParser p = new MetaDataParser();
            PropertyMetaDataSet pset = new PropertyMetaDataSet();
            p.ReadMetaDataFromFile(pset, filename, tableprefix);

            description = pset.Description;

            if (mEntityType == EntityType.PV || mEntityType == EntityType.PT)
                mTargetTable = pset.TableName;
            if (mEntityType == EntityType.SD || mEntityType == EntityType.AV)
                mTargetTable = pset.LongTableName;

            mEntityName = pset.Name;
            ArrayList modifications = new ArrayList();

            //Load the Table Schema
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                // Retrieve the list of properties and their other settings (type, length, nullable...)
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("GetMetaDataForProps"))
                {
                    stmt.AddParam("tablename", MTParameterType.String, mTargetTable);
                    stmt.AddParam("columnname", MTParameterType.String, null);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            TableModifications mods = GetModification(reader, pset);
                            if (mods != null)
                                modifications.Add(mods);
                        }
                    }
                }
            }

            //Loop through the properties stored in the config file to find out the properties added
            //If property exist in the file but not found in the DB
            //ESR-4636 ICE: Updating a Parameter Table makes pipeline fail - changed Keys to OrderProperties
            IEnumerator ienum = pset.OrderedProperties.GetEnumerator();
            while (ienum.MoveNext())
            {
                string column = ((IMTPropertyMetaData)ienum.Current).Name;
                if (!mColumns.ContainsCaseInsensitive(column))
                {
                    TableModifications mods = new TableModifications();
                    mods.columnName = column;
                    mods.metadata = (IMTPropertyMetaData)pset[column];
                    mods.metadata.DBTableName = mTargetTable;
                    mods.action = TableModifications.ActionType.Added;
                    modifications.Add(mods);
                }
            }
            mLog.LogDebug("Ending FindChanges function");
            return modifications;
        }

        /// <summary>
        /// This function is used to compare the indvidual column properties retrieved from the DB with
        /// values stored in the config file
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="pset"></param>
        /// <returns></returns>
        private TableModifications GetModification(IMTDataReader reader, PropertyMetaDataSet pset)
        {
            mLog.LogDebug("Starting GetModification function");
            string columnname = reader.GetString("name");

            // Ignore the property if name doesn't starts with c_(for e.g id_sess) or ends with "_op" (PT property for row type operator)
            if (!columnname.ToLower().StartsWith("c_"))		//must be the primary key or Column for operator type 'row'
                return null;

            // Check reserved properties.
            if (mReservedProperties != null)
              if (mReservedProperties.Keys.Cast<object>().Any(item => String.Equals(item.ToString(), columnname, StringComparison.CurrentCultureIgnoreCase)))
                return null;

            columnname = columnname.Remove(0, 2); //removing the starting c_
            mColumns.Add(columnname);
            TableModifications mods = null;
            object propvalues = pset[columnname];

            //If DB column not found in the file=>The property has been deleted
            if (propvalues == null)
            {
                mods = new TableModifications();
                mods.columnName = columnname;
                mods.metadata = new MetraTech.Interop.MTProductCatalog.MTPropertyMetaDataClass();//creating a new blank property to set the table name
                mods.metadata.DBTableName = mTargetTable;
                mods.metadata.DBColumnName = "c_" + columnname;
                mods.metadata.Name = columnname;
                mods.action = TableModifications.ActionType.Deleted;

                if (mEntityType == EntityType.PV)
                {
                    // Deleting a property is not allowed if there is a dependent unique key
                    ArrayList dependentKeys = mUniqueKeyOps.DependentKeys(columnname);
                    foreach (UniqueKey uk in dependentKeys)
                        mLog.LogError(string.Format("Key [{0}] depends on column [{1}]", uk.name, columnname));

                    if (dependentKeys.Count > 0)
                        throw new ApplicationException(string.Format(
                            "Cannot delete column [{0}] because is has a dependent key.",
                            columnname));
                }
            }
            else
            {
                ArrayList propchanges = GetListOfModifications(reader, (IMTPropertyMetaData)propvalues);
                if ((propchanges != null) && (propchanges.Count > 0))
                {
                    mods = new TableModifications();
                    mods.columnName = columnname;
                    mods.action = TableModifications.ActionType.Modified;
                    mods.actionsdone = propchanges;
                    mods.metadata = (IMTPropertyMetaData)propvalues;
                    mods.metadata.DBTableName = mTargetTable;

                    // Checking if dependant unique keys exist.
                    if (mEntityType == EntityType.PV &&
                        // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
                        // Description changing doesn't affect keys.
                        propchanges.ToArray().Where(p => ((TableModifications.ActionName)p) != TableModifications.ActionName.DescriptionChanged).Count() > 0)
                    {
                        // Changing a property is not allowed if a dependent key is not
                        // also changed.
                        ArrayList dependentKeys = mUniqueKeyOps.DependentKeysUnchanged(columnname);
                        
                        // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
                        // Added informative error message.
                        StringBuilder sb = new StringBuilder();

                        foreach (UniqueKey uk in dependentKeys)
                        {
                            string message = string.Format("Key [{0}] depends on column [{1}] (columns: [{2}])", uk.name, columnname, uk.ColumnCNameCSV);

                            mLog.LogError(message);
                            sb.AppendLine(message);
                        }

                        if (dependentKeys.Count > 0)
                        {   
                            throw new ApplicationException(string.Format(
                                "Cannot modify column [{0}] because is has a dependent key.\n{1}", columnname, sb));
                        }
                    }
                }
            }
            mLog.LogDebug("Ending GetModification function");
            return mods;
        }

        /// <summary>
        /// This function is used to retrieve the list of modifications done for the passed property
        /// </summary>
        /// <param name="reader"></param>
        /// <param name="pdata"></param>
        /// <returns></returns>
        private ArrayList GetListOfModifications(IMTDataReader reader, IMTPropertyMetaData pdata)
        {
            ArrayList modlist = new ArrayList();

            // are the types different?
            if (pdata.DBDataType.ToUpper() != reader.GetString("type").ToUpper())
            {
                if (reader.GetString("type").ToUpper() == (mIsOracle ? "NUMBER" : "NUMERIC"))
                {
                    if (pdata.DBDataType.ToUpper() != "DECIMAL"
                        && pdata.DBDataType.ToUpper() != "FLOAT")
                        modlist.Add(TableModifications.ActionName.DataTypeChanged);
                }
                else if (reader.GetString("type").ToUpper() == "CHAR"
                         && Convert.ToInt32(reader.GetValue("length")) == 1)
                {
                    if (pdata.DBDataType.ToUpper() != "BOOLEAN")
                        modlist.Add(TableModifications.ActionName.DataTypeChanged);
                }
                else
                    modlist.Add(TableModifications.ActionName.DataTypeChanged);
            }
            // types are the same, but maybe a string length changed?
            else if (pdata.DBDataType.ToUpper() == (mIsOracle ? "NVARCHAR2" : "NVARCHAR")
                     && (mEntityType != EntityType.SD))
            {
                if (pdata.Length != Convert.ToInt32(reader.GetValue("length")))
                    modlist.Add(TableModifications.ActionName.LengthIncreased);
            }

            // required property change? null or not null
            if (pdata.Required != Convert.ToBoolean(reader.GetValue("required")))
            {
                if (pdata.Required)
                    modlist.Add(TableModifications.ActionName.NonRequiredToRequired);
                else
                    modlist.Add(TableModifications.ActionName.RequiredToNonRequired);
            }

            // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
            // checking for property description change
            if (!(string.IsNullOrEmpty(pdata.Description) && reader.IsDBNull("Description")) || reader.IsDBNull("Description") || pdata.Description != reader.GetString("Description"))
            {
                modlist.Add(TableModifications.ActionName.DescriptionChanged);
            }

            return modlist;
        }

        /// <summary>
        /// This function starts a new transaction and apply the rules
        /// </summary>
        /// <param name="modifications"></param>
        /// <param name="entity"></param>
        /// <param name="description">The description for the table</param>
        private void ApplyRulesInTransaction(ArrayList modifications, ObjectUpdate ou, EntityType entity, bool bUseNonServicedConnection, string description)
        {
            mLog.LogDebug("Starting ApplyRulesInTransaction function");
            IMTConnection conn = null;
            if (bUseNonServicedConnection)
                conn = ConnectionManager.CreateNonServicedConnection();
            else
                conn = ConnectionManager.CreateConnection();
            try
            {
                if (ou != null)
                {
                    ou.ExecuteNonQuery(conn);
                }

                if (mEntityType == EntityType.PV)
                {
                    using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement("queries\\ProductView", "__SELECT_PRODUCT_VIEW_BY_NAME__"))
                    {
                        adapstmt.AddParam("%%NM_NAME%%", mEntityName);
                        using (IMTDataReader reader = adapstmt.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                mPropFKID = Convert.ToInt32(reader.GetValue("id_prod_view"));
                                mViewID = Convert.ToInt32(reader.GetValue("id_view"));
                            }
                            else
                                throw new ApplicationException("Couldn't find the ProductView id for PV: " + mEntityName);
                        }
                    }

                    mLog.LogDebug("Product view id found was: " + mPropFKID);
                }
                else if (mEntityType == EntityType.SD)
                {
                    using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement("queries\\ServiceDef", "__SELECT_SERVICE_DEF_BY_NAME__"))
                    {
                        adapstmt.AddParam("%%SDEF_NAME%%", mEntityName);
                        using (IMTDataReader reader = adapstmt.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                mPropFKID = Convert.ToInt32(reader.GetValue("id_service_def"));
                            }
                            else
                                throw new ApplicationException("Couldn't find the ServiceDef id for SD: " + mEntityName);
                        }
                    }

                    mLog.LogDebug("Service Def id found was: " + mPropFKID);
                }
                else if (mEntityType == EntityType.PT)
                {
                    using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__SELECT_PARAM_TABLE_BY_NAME__"))
                    {
                        adapstmt.AddParam("%%NM_NAME%%", mEntityName);
                        using (IMTDataReader reader = adapstmt.ExecuteReader())
                        {
                            if (reader.Read())
                                mPropFKID = Convert.ToInt32(reader.GetValue("id_prop"));
                            else
                                throw new ApplicationException(
                                                  "Couldn't find the Parameter Table id for PV: " + mEntityName);
                        }
                    }

                    mLog.LogDebug("Param Table id found was: " + mPropFKID);
                }
                else if (mEntityType == EntityType.AV)
                {
                    using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement("queries\\AccountView", "__SELECT_ACCOUNT_VIEW_BY_NAME__"))
                    {
                        adapstmt.AddParam("%%AV_NAME%%", mEntityName);
                        using (IMTDataReader reader = adapstmt.ExecuteReader())
                        {
                            if (reader.Read())
                                mPropFKID = Convert.ToInt32(reader.GetValue("id_account_view"));
                            else
                                throw new ApplicationException(
                                                  "Couldn't find the Parameter Table id for AV: " + mEntityName);
                        }
                    }

                    mLog.LogDebug("Param Table id found was: " + mPropFKID);
                }

                // Retrieve properties datatype from database
                RetrievePropsDBDataType();

                // Drop discontinued unique keys before applying column changes.
                // Unique keys depend on columns.
                if (mEntityType == EntityType.PV)
                {
                    if (mPartitionOps.UseUkTables)
                        // If partitioning, then drop the tables
                        mPartitionOps.DropUniqueKeyTables(mUniqueKeyOps.Deleted, conn);
                    else
                        // Otherwise, just drop the constraints
                        mUniqueKeyOps.PerformDeletes(conn);

                    // Delete unique key metadata, before required property changes.
                    mUniqueKeyOps.DeleteMetadata(conn);
                }

                // Apply all property modifications.
                int ruleapplied = 1;
                foreach (TableModifications tabMod in modifications)
                {
                    mGroupID = Guid.NewGuid().ToString();

                    // Get create table query once.
                    if (mCreateTableQuery == null)
                    {
                        mCreateTableQuery = GetCreateTableDDL(tabMod.metadata.DBTableName, conn);
                        if (mCreateTableQuery == null || mCreateTableQuery.Length <= 0)
                            throw new ApplicationException("Couldn't retrieve the CREATE TABLE script. Please check the settings.");
                    }

                    mLog.LogDebug("Applying rule " + ruleapplied++);
                    IMTPropertyMetaData propdata = tabMod.metadata;
                    switch (tabMod.action)
                    {
                        case TableModifications.ActionType.Added:
                            AddProperty(propdata, conn);
                            break;
                        case TableModifications.ActionType.Modified:
                            ModifiedProperty(tabMod, conn);
                            break;
                        case TableModifications.ActionType.Deleted:
                            // Delete the column. Simplest case.
                            DeletedProperty(propdata, conn);
                            break;
                        default:
                            throw new ApplicationException("The action couldn't be identified");
                    }
                }

                if (mEntityType == EntityType.PV)
                {
                    // Add unique key metadata. Required property metadata is already updated.
                    mUniqueKeyOps.AddMetadata(conn);

                    // If partitioning, rebuild the view and create unique key tables
                    if (mPartitionOps.UseUkTables)
                    {
                        mPartitionOps.CreateUniqueKeyTables(mTargetTable, conn);
                    }
                    else
                        // Otherwise, just add the constraints
                        mUniqueKeyOps.PerformAdds(conn);
                }

                MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
                bool ck = false;
                string chkSum = config.ReadConfiguration(mFilePath, out ck).Checksum;

                mLog.LogDebug("Updating Log Tables: chkSum: " + chkSum);
                switch (mEntityType)
                {
                    // No need to update the PV checksum, it has been updated by DeployProductView code.
                    // The checksum entry for the AV has to be updated.
                    // Note:This update checksum code for AV/SD can be moved to their respective hooks class
                    case EntityType.AV:
                        using (IMTAdapterStatement updateadapstmt = conn.CreateAdapterStatement("queries\\AccountView", "__UPDATE_AV_LOG__"))
                        {
                            updateadapstmt.AddParam("%%AV_CHECKSUM%%", chkSum);
                            updateadapstmt.AddParam("%%AV_NAME%%", mEntityName);
                            updateadapstmt.ExecuteNonQuery();
                        }
                        break;
                    case EntityType.SD:
                        using (IMTAdapterStatement updateadapstmt = conn.CreateAdapterStatement("queries\\ServiceDef", "__UPDATE_SDEF_LOG__"))
                        {
                            updateadapstmt.AddParam("%%SDEF_CHECKSUM%%", chkSum);
                            updateadapstmt.AddParam("%%SDEF_NAME%%", mEntityName);
                            updateadapstmt.ExecuteNonQuery();
                        }
                        break;
                    default:
                        break;
                }

                //CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
                // apply new table description
                using (IMTAdapterStatement updateadapstmt = conn.CreateAdapterStatement("queries\\ServiceDef", "__CREATE_TABLE_DESCRIPTION__"))
                {
                    updateadapstmt.AddParam("%%TABLE_NAME%%", mTargetTable);
                    updateadapstmt.AddParam("%%TABLE_DESCRIPTION%%", description.Trim());
                    updateadapstmt.ExecuteNonQuery();
                }

                if (bUseNonServicedConnection)
                    ((IMTNonServicedConnection)conn).CommitTransaction();

                mLog.LogDebug("Ending ApplyRulesInTransaction function");
            }
            catch (Exception ex)
            {
                mLog.LogError("Error occured during modifying the tables for " + mEntityName + ": " + ex.Message);
                mLog.LogError("Stack Trace:" + ex.StackTrace);

                if (bUseNonServicedConnection)
                    ((IMTNonServicedConnection)conn).RollbackTransaction();
                throw;
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                    conn.Dispose();
                    conn = null;
                }
            }
        }

        private string GetStatementForColumnAdding(IMTConnection conn)
        {
            StringBuilder result = new StringBuilder();

            if (conn.ConnectionInfo.IsSqlServer)
            {
                result.AppendLine(mAddColumn);
                result.AppendLine(mAddColumnDescriptionSql);
            }

            if (conn.ConnectionInfo.IsOracle)
            {
                result.AppendLine(mExecuteImmediateStatement.Replace("%%DDL%%", mAddColumn));
                result.AppendLine(mExecuteImmediateStatement.Replace("%%DDL%%", mAddColumnDescriptionOracle));
            }

            return conn.ConnectionInfo.IsSqlServer
                       ? result.ToString()
                       : String.Format("declare pragma autonomous_transaction; BEGIN\r\n {0}\r\n END;", result);
        }

        private void AddColumn(IMTPropertyMetaData propdata, string defValue, string ColNullDDL, IMTConnection conn)
        {
            // Add a column.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(GetStatementForColumnAdding(conn)))
            {
                stmt.AddParam("%%tabname%%", mTargetTable);
                stmt.AddParam("%%colname%%", GetColNameDDL(propdata));
                stmt.AddParam("%%coltype%%", GetColTypeDDL(propdata));
                stmt.AddParam("%%constraint%%", GetColDefaultConstraintDDL(propdata, defValue), true);
                stmt.AddParam("%%cannull%%", ColNullDDL);
                var descr = conn.ConnectionInfo.IsSqlServer
                                ? propdata.Description
                                : propdata.Description.Replace("'", "''''");
                stmt.AddParam("%%description%%", descr);
                mLog.LogDebug("Query to be executed: " + stmt.Query);

                stmt.ExecuteNonQuery();

                InsertIntoQueryLog(stmt.Query, conn);
            }
        }

        private void AddProperty(IMTPropertyMetaData propdata, IMTConnection conn)
        {
            mLog.LogDebug("Starting AddProperty function");
            
            // Add a column.
            string defValue = GetDefaultValue(conn, propdata);
            AddColumn(propdata, defValue, GetColNullDDL(propdata), conn);

            // SQL server leaves non-required columns as NULL even if a default constraint is set.
            // Hence, we need to set the default value ourselves.
            if (!mIsOracle && !propdata.Required && defValue.Length > 0)
                UpdateDefaultProperty(propdata, defValue, conn);

            // Now update properties table for each product defs.
            InsertIntoPropertyTable(propdata, conn);
            mLog.LogDebug("Ending AddProperty function");
        }

        // Set all null-valued columns to the default value
        private void UpdateDefaultProperty(IMTPropertyMetaData propdata, string defval, IMTConnection conn)
        {
            StringBuilder qbuilder = new StringBuilder();
            qbuilder.Append("UPDATE " + mTargetTable);
            qbuilder.Append(" SET " + propdata.DBColumnName);
            qbuilder.Append(" = " + Delimit(propdata.DBDataType, defval));
            qbuilder.Append(" WHERE " + propdata.DBColumnName + " is NULL");

            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qbuilder.ToString()))
            {
                mLog.LogDebug("Query to be executed: " + qbuilder.ToString());
                stmt.ExecuteNonQuery();
                InsertIntoQueryLog(qbuilder.ToString(), conn);
            }
        }

        private void ModifiedProperty(TableModifications mods, IMTConnection conn)
        {
            mLog.LogDebug("Starting ModifiedProperty function");
            IMTPropertyMetaData propdata = mods.metadata;
            string ColumnName = GetColNameDDL(propdata);
            bool bNonRequiredtoRequired = mods.actionsdone.Contains(TableModifications.ActionName.NonRequiredToRequired);
            bool bRequiredtoNonRequired = mods.actionsdone.Contains(TableModifications.ActionName.RequiredToNonRequired);
            bool bDataTypeChanged = mods.actionsdone.Contains(TableModifications.ActionName.DataTypeChanged);
            bool bOracleAlterColumnTypeWithData = false;
            // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
            bool bDescriptionChanged = mods.actionsdone.Contains(TableModifications.ActionName.DescriptionChanged);

            // For Oracle, if changing column type determine if table contains data.
            if (mIsOracle)
            {
                if (bDataTypeChanged)
                {
                    using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("queries\\DynamicTable", "__IS_COLUMN_EMPTY__"))
                    {
                        astmt.AddParam("%%tabname%%", mTargetTable);
                        astmt.AddParam("%%column%%", ColumnName);
                        using (IMTDataReader reader = astmt.ExecuteReader())
                            if (reader.Read())
                                bOracleAlterColumnTypeWithData = (reader.GetBoolean("empty") == false) ? true : false;
                    }
                }
            }
            else
            {
                // For SQL server, we need drop the default constraint in order to modify the column.
                using (IMTAdapterStatement astmt = conn.CreateAdapterStatement(mDropDefaultConstraint))
                {
                    astmt.AddParam("%%tabname%%", mTargetTable);
                    astmt.AddParam("%%colname%%", ColumnName);
                    mLog.LogDebug("Query to be executed: " + astmt.Query);

                    astmt.ExecuteNonQuery();

                    InsertIntoQueryLog(astmt.Query, conn);
                }
            }

            // 1. string->enum
            // Updating the table with their enum values through executing SP UpdateDataForStringToEnum
            if (propdata.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM
          && IsDBTypeString(propdata.Name))
            {
                mLog.LogDebug("Executing SP UpdateDataForStringToEnum");
                using (IMTCallableStatement callstmt = conn.CreateCallableStatement("UpdateDataForStringToEnum"))
                {
                    callstmt.AddParam("table", MTParameterType.String, mTargetTable);
                    callstmt.AddParam("column", MTParameterType.String, propdata.DBColumnName);
                    callstmt.AddParam("enum_string", MTParameterType.String, propdata.EnumSpace + "/" + propdata.EnumType);
                    callstmt.ExecuteNonQuery();
                    InsertIntoQueryLog("Executing SP UpdateDataForStringToEnum", conn);
                }
            }

            // Handle the DataTypeChanged or Length increased changes

            // Updates has to be done for 2 types of conversions: enum->string and string->enum
            bool enummodifiedtostring = (propdata.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING &&
                                         Convert.ToInt32(mPropsDataType[propdata.Name]) == 8) ? true : false;
            mLog.LogDebug("Value of enummodifiedtostring: " + enummodifiedtostring);

            // Did we force the column to be nullable?
            bool bForcedNullable = false;

            // 2. enum->string
            // The updates for the enum->string conversion. The data type of the column
            // has been changed. so now we can update the corresponding string values
            // from the t_enum_data table.
            if (enummodifiedtostring)
            {
                // First convert the column type to string/varchar before 
                // converting the existing values in the column
                using (IMTAdapterStatement astmt = conn.CreateAdapterStatement(mIsOracle ? mAlterColOra : mAlterColSqlSvr))
                {
                    astmt.AddParam("%%tabname%%", mTargetTable);
                    astmt.AddParam("%%colname%%", ColumnName);
                    astmt.AddParam("%%coltype%%", GetColTypeDDL(propdata));
                    astmt.AddParam("%%cannull%%", "null");  // allow nulls for now
                    bForcedNullable = true; // Only case where we're forcing to null
                    mLog.LogDebug("Query to be executed: " + astmt.Query);
                  
                    astmt.ExecuteNonQuery();

                    InsertIntoQueryLog(astmt.Query, conn);
                }

                // Column type is changed.  Now convert enum_id to enum_data.
                mLog.LogDebug("Executing SP UpdateDataForEnumToString");
                using (IMTCallableStatement callstmt = conn.CreateCallableStatement("UpdateDataForEnumToString"))
                {
                    callstmt.AddParam("table", MTParameterType.String, mTargetTable);
                    callstmt.AddParam("column", MTParameterType.String, propdata.DBColumnName);
                    callstmt.ExecuteNonQuery();
                    InsertIntoQueryLog("Executing SP UpdateDataForEnumToString", conn);
                }
                // Update the column with default values and make the column required.
                if (bNonRequiredtoRequired)
                {
                    mods.actionsdone.Remove(TableModifications.ActionName.NonRequiredToRequired);

                    // Set all null-valued columns to the default value.
                    if (propdata.DefaultValue.ToString().Length > 0)
                        UpdateDefaultProperty(propdata, GetDefaultValue(conn, propdata), conn);
                }
            }
            else
            {
                // Oracle does not allow us to alter column type if it contains data.
                if (bOracleAlterColumnTypeWithData)
                {
                    string TempColumnName = ColumnName + "_tmp";

                    // 1. rename old column to some temp name.
                    using (IMTAdapterStatement astmt = conn.CreateAdapterStatement(mRenameColumn))
                    {
                        astmt.AddParam("%%tabname%%", mTargetTable);
                        astmt.AddParam("%%from%%", ColumnName);
                        astmt.AddParam("%%to%%", TempColumnName);
                        mLog.LogDebug("Query to be executed: " + astmt.Query);
                      
                        astmt.ExecuteNonQuery();
                        InsertIntoQueryLog(astmt.Query, conn);
                    }
                    // 2. create a new column with old colmn name
                    AddColumn(propdata, "", "null", conn);

                    // 3. copy/convert data from temp column to new column
                    using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("queries\\DynamicTable", "__COPY_COLUMN__"))
                    {
                        astmt.AddParam("%%tabname%%", mTargetTable);
                        astmt.AddParam("%%from%%", TempColumnName);
                        astmt.AddParam("%%to%%", ColumnName);
                        
                        astmt.ExecuteNonQuery();

                        InsertIntoQueryLog(astmt.Query, conn);
                    }

                    // 4. drop column with temp column name.
                    DropColumn(propdata, TempColumnName, conn);

                    // done changing datatype.
                    bDataTypeChanged = false;
                }

                // A datatype change and NonRequiredToRequired (with default value) set can take place
                // simultaneously. First table has to be updated with data type change (to NULLABLE column),
                // then setting the default value and then again ALTER table with NOT NULL column
                if (bRequiredtoNonRequired || bDataTypeChanged ||
                            mods.actionsdone.Contains(TableModifications.ActionName.LengthIncreased))
                {
                    if (bRequiredtoNonRequired)
                        mods.actionsdone.Remove(TableModifications.ActionName.RequiredToNonRequired);

                    using (IMTAdapterStatement astmt2 = conn.CreateAdapterStatement(mIsOracle ? mAlterColOra : mAlterColSqlSvr))
                    {
                        astmt2.AddParam("%%tabname%%", mTargetTable);
                        astmt2.AddParam("%%colname%%", ColumnName);
                        astmt2.AddParam("%%coltype%%", GetColTypeDDL(propdata));

                        // We need to set the column to be nullable in order to apply the defaults.
                        // How this is done depends on original property state. If we force the property
                        // to be nullable then we will need to change it back. We do not need to change
                        // it back if the column is already nullable and if it is changed from required
                        // to non required. Must do the following checks in order:
                        if (bRequiredtoNonRequired)
                            astmt2.AddParam("%%cannull%%", "null"); // SQL, ORACLE will set as null
                        else if (bNonRequiredtoRequired)
                            astmt2.AddParam("%%cannull%%", "");     // SQL, ORACLE will leave as null
                        else if (propdata.Required)
                        {
                            astmt2.AddParam("%%cannull%%", "null"); // SQL, ORACLE will set as null
                            bForcedNullable = true; // Only case where we're forcing to null
                        }
                        else
                            astmt2.AddParam("%%cannull%%", "");     // SQL, ORACLE will leave as null

                        mLog.LogDebug("Query to be executed: " + astmt2.Query);
                        
                        astmt2.ExecuteNonQuery();

                        InsertIntoQueryLog(astmt2.Query, conn);
                    }
                }

                if (propdata.DefaultValue.ToString().Length > 0)
                {
                    string defval = GetDefaultValue(conn, propdata);

                    // Set all null-valued columns to the default value
                    UpdateDefaultProperty(propdata, defval, conn);

                    // For SQL server we drop the default constraint in order to modify the column.
                    // Re-apply default value constraint.
                    if (!mIsOracle)
                    {
                        using (IMTAdapterStatement astmt = conn.CreateAdapterStatement(mApplyDefaultConstraint))
                        {
                            astmt.AddParam("%%tabname%%", mTargetTable);
                            astmt.AddParam("%%colname%%", ColumnName);
                            astmt.AddParam("%%default%%", GetColDefaultDDL(propdata, defval), true);
                            mLog.LogDebug("Query to be executed: " + astmt.Query);
                            
                            astmt.ExecuteNonQuery();
                            InsertIntoQueryLog(astmt.Query, conn);
                        }
                    }
                }
            }

            // If the property is required but we temporarily changed it to non-required
            // If we're changing from non-required to required.
            if (bForcedNullable || bNonRequiredtoRequired)
            {
                using (IMTAdapterStatement astmt = conn.CreateAdapterStatement(mIsOracle ? mAlterColOra : mAlterColSqlSvr))
                {
                    astmt.AddParam("%%tabname%%", mTargetTable);
                    astmt.AddParam("%%colname%%", ColumnName);
                    astmt.AddParam("%%coltype%%", GetColTypeDDL(propdata));
                    astmt.AddParam("%%cannull%%", GetColNullDDL(propdata));

                    mLog.LogDebug("Query to be executed: " + astmt.Query);

                    astmt.ExecuteNonQuery();

                    InsertIntoQueryLog(astmt.Query, conn);
                }
            }

            if (mEntityType == EntityType.PT && bNonRequiredtoRequired &&
                CheckWhetherThePropertyIsRowAndDefaultToSet(propdata))
            {
                StringBuilder querybuilder = new StringBuilder();
                querybuilder.Append("UPDATE " + mTargetTable);
                querybuilder.Append(" SET " + propdata.DBColumnName + "_op");
                querybuilder.Append("= '=' WHERE " + propdata.DBColumnName + "_op" + " is NULL ");
                mLog.LogDebug("Query to be executed: " + querybuilder.ToString());
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(querybuilder.ToString()))
                {
                    stmt.ExecuteNonQuery();
                    InsertIntoQueryLog(querybuilder.ToString(), conn);
                }
            }

            // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
            if (bDescriptionChanged)
            {
                using (IMTAdapterStatement astmt = conn.CreateAdapterStatement("queries\\ServiceDef", "__CREATE_COLUMN_DESCRIPTION__"))
                {
                    astmt.AddParam("%%TABLE_NAME%%", mTargetTable);
                    astmt.AddParam("%%COLUMN_NAME%%", ColumnName);
                    astmt.AddParam("%%COLUMN_DESCRIPTION%%", (propdata.Description?? string.Empty).Replace("'", "''"));

                    mLog.LogDebug("Query to be executed: " + astmt.Query);

                    astmt.ExecuteNonQuery();

                    InsertIntoQueryLog(astmt.Query, conn);
                }
            }

            UpdatePropertiesTable(propdata, conn);
        }

        private string GetDefaultValue(IMTConnection conn, IMTPropertyMetaData propdata)
        {
            if (mEntityType == EntityType.PT && propdata.Name.ToLower().EndsWith("_op"))
            {
                if (PropertyWasModifiedToRowFromColumn(propdata.Name.ToLower()))
                    return RetrieveDefaultValueForColumnOp(propdata.Name);
                else if (IsDefaultValueSet(propdata))
                {
                    if (string.IsNullOrEmpty(propdata.DefaultValue.ToString()))
                        return "=";
                    else
                        return propdata.DefaultValue.ToString();
                }
                else if (IsPropertyRequired(propdata))
                    return "=";
            }
            else if ((mEntityType == EntityType.PV || mEntityType == EntityType.SD ||
                      mEntityType == EntityType.PT || mEntityType == EntityType.AV) &&
                     (IsPropertyRequired(propdata) || IsDefaultValueSet(propdata)))
            {
                // Get default value.
                string defvalue = propdata.DefaultValue.ToString();

                // For DateTime, we have to modify the default value (as it's not a datetime string)
                if (propdata.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME)
                {
                    defvalue = defvalue.ToUpper();
                    defvalue = defvalue.Replace("T", " ");
                    defvalue = defvalue.Replace("Z", "");
                }
                else if (propdata.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN)
                {
                    if (defvalue.Length > 0)
                    {
                        if (defvalue[0] == '1' || defvalue[0] == 't' || defvalue[0] == 'T' || defvalue[0] == 'y' || defvalue[0] == 'Y')
                        {
                            return "1";
                        }
                        else if (defvalue[0] == '0' || defvalue[0] == 'f' || defvalue[0] == 'F' || defvalue[0] == 'n' || defvalue[0] == 'N')
                            return "0";
                        else // Invalid default boolean value specified.
                        {
                            string msg = "Invalid default boolean value specified for property '" + propdata.Name + "', value: " + defvalue;
                            throw new ApplicationException(msg);
                        }
                    }
                    else if (propdata.Required)
                    {
                        string msg = "Default boolean value not specified specified for property '" + propdata.Name + "'";
                        throw new ApplicationException(msg);
                    }
                }
                else if (propdata.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM)
                {
                    mLog.LogDebug("Property {0} was enum. Retrieving the enumcode for the default value set.", propdata.DBColumnName);
                    int enumvalue = RetrieveTheEnumCode(propdata.EnumSpace + "/" + propdata.EnumType + "/" + defvalue, conn);
                    return enumvalue.ToString();
                }

                return defvalue;
            }

            return "";
        }

        private void DropColumn(IMTPropertyMetaData propdata, string column, IMTConnection conn)
        {
            // Now drop the column.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mIsOracle ? mDropColumnOra : mDropColumnSqlSvr))
            {
                stmt.AddParam("%%tabname%%", mTargetTable);
                stmt.AddParam("%%colname%%", column);
                mLog.LogDebug("Query to be executed: " + stmt.Query);
                
                stmt.ExecuteNonQuery();

                InsertIntoQueryLog(stmt.Query, conn);
            }
        }

        private void DeletedProperty(IMTPropertyMetaData propdata, IMTConnection conn)
        {
            mLog.LogDebug("Starting DeletedProperty function");

            // Now drop the column.
            DropColumn(propdata, GetColNameDDL(propdata), conn);

            //
            DeleteFromPropertyTable(propdata, conn);
            mLog.LogDebug("Ending DeletedProperty function");
        }

        private string GetColTypeDDL(IMTPropertyMetaData prop)
        {
            StringBuilder ddl = new StringBuilder();
            switch (prop.DataType)
            {
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
                    // the listener never strictly enforced string lengths
                    // so all string columns must be the maximum product string length
                    //    - non-encrypted maximum string length is 255
                    string ctype = mIsOracle ? "nvarchar2(" : "nvarchar(";
                    string len = mEntityType != EntityType.SD ? prop.Length.ToString() : "255";
                    return ctype + len + ")";
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
                    return mIsOracle ? "number(10)" : "integer";
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
                    return mIsOracle ? "number(20)" : "bigint";
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
                    return mIsOracle ? "date" : "datetime";

                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DOUBLE:
                    return mIsOracle ? Constants.METRANET_NUMBER_PRECISION_AND_SCALE_MAX_STR : Constants.METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_STR;
                /* xxx return mIsOracle ? "number" : "float";
                 * We should probably treat DOUBLE as "double precision" or float(53)
                 * however, in other places of the product we treat double as decimal.
                 * See CR15431. To restore proper double support in the product is a large effort
                 * one that may not be necessary to undertake.
                 */

                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
                    return mIsOracle ? "number(10)" : "integer";
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
                    return "char(1)";
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_TIME:
                    return mIsOracle ? "date" : "datetime";
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
                    return mIsOracle ? Constants.METRANET_NUMBER_PRECISION_AND_SCALE_MAX_STR : Constants.METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_STR;
                default:
                    return "<unknown property type>";
            }
        }

        private string GetColNullDDL(IMTPropertyMetaData prop)
        {
            return prop.Required ? "not null" : "null";
        }

        private string GetColNameDDL(IMTPropertyMetaData prop)
        {
            return "c_" + prop.Name;
        }

        private string GetColDefaultDDL(IMTPropertyMetaData prop, string val)
        {
            return ("default " + Delimit(prop.DBDataType, val));
        }

        private string GetColDefaultConstraintDDL(IMTPropertyMetaData prop, string val)
        {
            if (val == "")
                return "";

            if (mIsOracle)
                return ("default " + Delimit(prop.DBDataType, val));
            else
                return ("CONSTRAINT DF_MT_" + mTargetTable + "_" + GetColNameDDL(prop) + " default " + Delimit(prop.DBDataType, val));
        }

        private bool IsDefaultValueSet(IMTPropertyMetaData propdata)
        {
            string rowpropname = propdata.Name.Replace("_op", "");
            XmlDocument doc = new XmlDocument();
            doc.Load(mFilePath);
            XmlNode ptypenode = doc.SelectSingleNode("descendant::ptype[dn='" + rowpropname + "']");
            string defaultvalue = ptypenode.SelectSingleNode("defaultvalue").InnerText;
            if (defaultvalue.Length > 0)
                return true;
            else
                return false;
        }

        private bool IsPropertyRequired(IMTPropertyMetaData propdata)
        {
            string rowpropname = propdata.Name.Replace("_op", "");
            XmlDocument doc = new XmlDocument();
            doc.Load(mFilePath);
            XmlNode ptypenode = doc.SelectSingleNode("descendant::ptype[dn='" + rowpropname + "']");

            return (ptypenode.SelectSingleNode("required").InnerText == "Y") ? true : false;
        }

        private bool PropertyWasModifiedToRowFromColumn(string prop_op_name)
        {
            string propname = prop_op_name.Remove(prop_op_name.Length - 3, 3);
            if (mPropsDataType.ContainsKey(propname) && !mPropsDataType.ContainsKey(prop_op_name))
                return true;
            else
                return false;
        }

        private string RetrieveDefaultValueForColumnOp(string columnopname)
        {
            string propname = columnopname.Remove(columnopname.Length - 3, 3);
            string defvalue = null;
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                string query = "SELECT nm_operatorval from t_param_table_prop where id_param_table=" + mPropFKID + " AND nm_name='" + propname + "'";
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                            defvalue = reader.GetString("nm_operatorval");
                        else
                            throw new Exception("Data for the " + propname + " couldn't be found");
                    }
                }
            }

            if (defvalue == null || defvalue.Length == 0)
                throw new Exception("Default value is blank for the column " + propname);

            switch (defvalue)
            {
                case "not_equal":
                    defvalue = "!=";
                    break;
                case "greater_than":
                    defvalue = ">";
                    break;
                case "less_than":
                    defvalue = "<";
                    break;
                case "greater_equal":
                    defvalue = ">=";
                    break;
                case "less_equal":
                    defvalue = "<=";
                    break;
                default:
                    throw new Exception("Wrong value for operator found for property " + propname);
            }
            return defvalue;
        }

        /// <summary>
        /// Default value for the operator column would be set for 1 case:
        /// 1. If the column was made required from non-required
        /// If the column operator changed to Row operator and made required, in that case we don't have to set the
        /// default value here, as the code would find it as new row operator column added and would do the 
        /// validation in the Added new property scenario
        /// </summary>
        /// <param name="propdata"></param>
        /// <returns></returns>
        private bool CheckWhetherThePropertyIsRowAndDefaultToSet(IMTPropertyMetaData propdata)
        {
            string rowpropname = propdata.Name + "_op";
            if (mPropsDataType.ContainsKey(rowpropname))
                return true;
            else
                return false;
        }

        private string Delimit(string strFieldType, string val)
        {
            string result;
            switch (strFieldType.ToLower())
            {
                case "string":
                case "timestamp":
                    result = String.Format("'{0}'", val);
                    break;

                case "enum":
                case "int32":
                case "int64":
                case "double":
                case "number":
                case "bool":
                    result = val;
                    break;
                
                case "date":
                    result = String.Format(mIsOracle
                              ? "to_date('{0}','yyyy-mm-dd hh24:mi:ss')" 
                              : "'{0}'", val);
                    break;
                 
                default:        // Unknown Type -> convert to string
                    result = String.Format("'{0}'", val);
                    break;
            }

            return result;
        }

        private int GetPropertyValue(IMTPropertyMetaData prop)
        {
            switch (prop.DataType)
            {
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
                    return 0;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
                    return 2;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
                    return 11;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
                    return 3;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DOUBLE:
                    return 5;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
                    return 8;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
                    return 9;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_TIME:
                    return 3;
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
                    return 7;
                default:
                    throw new ApplicationException("Data type for the property couldn't be recognized:" + prop.Name);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propdata"></param>
        /// <param name="conn"></param>
        public void InsertIntoPropertyTable(IMTPropertyMetaData propdata, IMTConnection conn)
        {
            mLog.LogDebug("Starting InsertProperty function");

            const string propSql = @"insert into %%proptabname%% (
      %%pk_col%% %%fk_col%%, nm_name, nm_data_type, nm_column_name, 
      b_required, b_composite_idx, b_single_idx, b_part_of_key, b_exportable, b_filterable, b_user_visible, 
      nm_default_value, n_prop_type, nm_space, nm_enum, b_core %%pt_cols%%) 
      values(%%pk_id%% %%fk_id%%, '%%nm_name%%', '%%nm_data_type%%', '%%nm_column_name%%',
      '%%b_required%%', 'N', 'N', 'N', 'Y', 'Y', 'Y',
      %%nm_default_value%%, '%%n_prop_type%%', '%%nm_space%%', '%%nm_enum%%', '%%b_core%%' %%pt_cols_vals%%)";

            try
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(propSql))
                {

                    // set in column names
                    stmt.AddParam("%%proptabname%%", mPropTableName);
                    stmt.AddParam("%%pk_col%%", mIsOracle ? mPropTablePKName + "," : "");
                    stmt.AddParam("%%fk_col%%", mPropTableFKName);

                    // PT extra column names
                    stmt.AddParam("%%pt_cols%%", mEntityType == EntityType.PT ? ", b_columnoperator, nm_operatorval" : "");

                    // values
                    stmt.AddParam("%%pk_id%%", mIsOracle ? "seq_" + mPropTableName + ".nextval," : "");
                    stmt.AddParam("%%fk_id%%", mPropFKID);
                    stmt.AddParam("%%nm_name%%", propdata.Name);
                    stmt.AddParam("%%nm_data_type%%", propdata.DataTypeAsString);

                    stmt.AddParam("%%nm_column_name%%", propdata.DBColumnName);
                    stmt.AddParam("%%b_required%%", propdata.Required ? "Y" : "N");
                    stmt.AddParam("%%nm_default_value%%",
                                  propdata.DefaultValue.ToString().Length > 0 ? "'" + propdata.DefaultValue + "'" : "null", true);
                    stmt.AddParam("%%n_prop_type%%", GetPropertyValue(propdata));
                    stmt.AddParam("%%nm_space%%", propdata.EnumSpace != null ? propdata.EnumSpace : "");
                    stmt.AddParam("%%nm_enum%%", propdata.EnumSpace != null ? propdata.EnumType : "");
                    stmt.AddParam("%%b_core%%", "N");

                    // PT extra values
                    string ptValues = null;
                    if (mEntityType == EntityType.PT)
                    {
                        IMTAttributes attributes = propdata.Attributes;
                        if (attributes.Exists("column_operator"))
                        {
                            IMTAttribute columnattr = (IMTAttribute)attributes["column_operator"];
                            ptValues = ", 'Y', '" + columnattr.Value.ToString() + "'";
                        }
                        else
                            ptValues = ", 'N', null";
                    }
                    stmt.AddParam("%%pt_cols_vals%%", ptValues != null ? ptValues : "", true);

                    mLog.LogDebug("Insert query generated was: " + stmt.Query);
                    stmt.ExecuteNonQuery();
                    InsertIntoQueryLog(stmt.Query, conn);
                    mLog.LogDebug("Ending UpdateDBProps function");
                }
            }
            catch (Exception ex)
            {
                mLog.LogError("Error occured during modifying the tables for " + mEntityName + ":" + ex.Message);
                mLog.LogError("Stack Trace:" + ex.StackTrace);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propdata"></param>
        /// <param name="conn"></param>
        public void UpdatePropertiesTable(IMTPropertyMetaData propdata, IMTConnection conn)
        {
            mLog.LogDebug("Starting UpdatePropertiesTable function");
            try
            {
                StringBuilder builder = new StringBuilder();
                string query = "";

                // The id is hardcoded for servicedef. it needs to be changed
                builder.Append("UPDATE " + mPropTableName + " SET nm_data_type='" + propdata.DataTypeAsString + "',b_required=" + (propdata.Required ? "'Y'" : "'N'"));

                if (propdata.DefaultValue.ToString().Length > 0)
                    builder.Append(",nm_default_value='" + propdata.DefaultValue + "'");
                else
                    builder.Append(",nm_default_value=null");
                builder.Append(",n_prop_type='" + GetPropertyValue(propdata) + "'");
                if (propdata.EnumSpace != null)
                    builder.Append(",nm_space='" + propdata.EnumSpace + "'");
                else
                    builder.Append(",nm_space=''");
                if (propdata.EnumType != null)
                    builder.Append(",nm_enum='" + propdata.EnumType + "'");
                else
                    builder.Append(",nm_enum=''");

                if (mEntityType == EntityType.PT)
                {
                    IMTAttributes attributes = propdata.Attributes;
                    if (attributes.Exists("column_operator"))
                    {
                        IMTAttribute columnattr = (IMTAttribute)attributes["column_operator"];
                        builder.Append(",b_columnoperator='Y',nm_operatorval='" + columnattr.Value.ToString() + "'");
                    }
                    else
                        builder.Append(",b_columnoperator='N',nm_operatorval=null");
                }

                builder.Append(" WHERE " + mPropTableFKName + "=" + mPropFKID + " AND nm_name='" + propdata.Name + "'");
                query = builder.ToString();

                mLog.LogDebug("Insert query generated was: " + query);
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }

                InsertIntoQueryLog(query, conn);
                mLog.LogDebug("Ending UpdateDBProps function");
            }
            catch (Exception ex)
            {
                mLog.LogError("Error occured during modifying the tables for " + mEntityName + ":" + ex.Message);
                mLog.LogError("Stack Trace:" + ex.StackTrace);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propdata"></param>
        /// <param name="conn"></param>
        private void DeleteFromPropertyTable(IMTPropertyMetaData propdata, IMTConnection conn)
        {
            mLog.LogDebug("Starting DeleteFromPropertyTable function");
            try
            {
                string query = "";
                // The id is hardcoded for servicedef. it needs to be changed
                query = "DELETE FROM " + mPropTableName + " WHERE ";
                query += mPropTableFKName + "=" + mPropFKID + " AND upper(nm_name) = upper('" + propdata.Name + "')";
                mLog.LogDebug("Insert query generated was: " + query);
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }
                mLog.LogDebug("Ending DeleteFromPropertyTable function");
            }
            catch (Exception ex)
            {
                mLog.LogError("Error occured during deleting property from table for " + mEntityName + ":" + ex.Message);
                mLog.LogError("Stack Trace:" + ex.StackTrace);
                throw;
            }
        }

        /// <summary>
        /// Returns the id_enum_data for the passed enum string
        /// </summary>
        /// <param name="enumstring"></param>
        /// <param name="conn"></param>
        /// <returns></returns>
        private static int RetrieveTheEnumCode(string enumstring, IMTConnection conn)
        {
          int enumcode;
          using (var callstmt = conn.CreateCallableStatement("RetrieveEnumCode"))
          {
            callstmt.AddReturnValue(MTParameterType.Integer);
            callstmt.AddParam("enum_string", MTParameterType.String, enumstring);
            callstmt.ExecuteNonQuery();
            if (callstmt.ReturnValue == null || (int)callstmt.ReturnValue == 0)
            {
              throw new ApplicationException("Enum string not found in database: " + enumstring);
            }
            enumcode = (int) callstmt.ReturnValue;
          }
          return enumcode;
        }

        /// <summary>
        /// Gets create table script for sqlserver
        /// </summary>
        private string GetCreateTableDDL(string table, IMTConnection conn)
        {
            mLog.LogDebug("Starting GetCreateTableDDL function");

            // Generate Create Table DDL for specified table.
            string ddl = String.Empty;
            string isNullable = "NULL";
            string isNotNullable = "NOT NULL";
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("GetMetaDataForProps"))
            {
                stmt.AddParam("tablename", MTParameterType.String, table);
                stmt.AddParam("columnname", MTParameterType.String, "");
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        if (ddl.Length > 1)
                            ddl += ",";
                        else
                            ddl = "(";

                        string Type = reader.GetString("type").ToLower();
                        string Name = reader.GetString("name");
                        if (Type == "numeric")
                        {
                            ddl += System.String.Format("{0} {1} ({2},{3}) {4}",
                                Name, Type,
                                reader.GetValue("length"),
                                reader.GetValue("decplaces"),
                                Convert.ToBoolean(reader.GetValue("required")) ? isNotNullable : isNullable);
                        }
                        else if (Type == "char" || Type == "varchar" || Type == "nvarchar" ||
                               Type == "varchar2" || Type == "nvarchar2" ||
                               Type == "varbinary" || Type == "raw")
                        {
                            ddl += System.String.Format("{0} {1} ({2}) {3}",
                                Name, Type, reader.GetValue("length"),
                                Convert.ToBoolean(reader.GetValue("required")) ? isNotNullable : isNullable);
                        }
                        else
                            ddl += System.String.Format("{0} {1} {2}",
                                Name, Type,
                                Convert.ToBoolean(reader.GetValue("required")) ? isNotNullable : isNullable);
                    }

                    if (ddl.Length > 1)
                        ddl += ")";
                }
            }

            ddl = "CREATE TABLE " + table + " " + ddl;
            mLog.LogDebug("Ending GetCreateTableDDL function, query is: " + ddl);

            // Truncating the query if it exceeds the 4000 chars (limit for the varchar)
            if (ddl.Length > 4000)
            {
                ddl = ddl.Substring(0, 4000);
                mLog.LogDebug("Create Table query truncated is: " + ddl);
            }

            return ddl;
        }

        /// <summary>
        /// This function is used to update the query log with the old & modified schema
        /// </summary>
        /// <param name="query"></param>
        /// <param name="conn"></param>
        private void InsertIntoQueryLog(string query, IMTConnection conn)
        {
            using (IMTCallableStatement callstmt = conn.CreateCallableStatement("InsertIntoQueryLog"))
            {
                callstmt.AddParam("groupid", MTParameterType.String, mGroupID);
                if (mViewID == 0)
                    callstmt.AddParam("viewid", MTParameterType.Integer, null);
                else
                    callstmt.AddParam("viewid", MTParameterType.Integer, mViewID);

                callstmt.AddParam("old_schema", MTParameterType.WideString, mCreateTableQuery);
                callstmt.AddParam("query", MTParameterType.WideString, query);
                callstmt.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="filename"></param>
        /// <param name="tableprefix"></param>
        private void DropStagingTables(string filename, string tableprefix)
        {
            mLog.LogDebug("Starting DropStagingTables function");
            MetraTech.DataAccess.IMTServicedConnection connstage = null;
            string tablename = null;
            string servicename = null;
            try
            {
                //Establishing connection with the staging db
                ConnectionInfo stageDBInfo = new ConnectionInfo("NetMeterStage");
                using (connstage = ConnectionManager.CreateConnection(stageDBInfo))
                {

                    MetaDataParser p = new MetaDataParser();
                    PropertyMetaDataSet pset = new PropertyMetaDataSet();
                    p.ReadMetaDataFromFile(pset, filename, tableprefix);
                    if (mEntityType == EntityType.PV)
                        tablename = pset.TableName;
                    if (mEntityType == EntityType.SD)
                        tablename = pset.LongTableName;

                    servicename = pset.Name;

                    switch (mEntityType)
                    {
                        case EntityType.PV:
                            using (IMTAdapterStatement dropadapstmt = connstage.CreateAdapterStatement("queries\\ProductView", "__DROP_PRODUCT_VIEW_STAGE_TABLE__"))
                            {
                                dropadapstmt.AddParam("%%TABLE_NAME%%", tablename);
                                dropadapstmt.ExecuteNonQuery();
                            }
                            break;
                        case EntityType.SD:
                            using (IMTAdapterStatement dropadapstmt = connstage.CreateAdapterStatement("queries\\ServiceDef", "__DROP_SERVICE_DEF_STAGE_TABLE__"))
                            {
                                dropadapstmt.AddParam("%%SDEF_NAME%%", tablename);
                                dropadapstmt.ExecuteNonQuery();
                            }

                            //recreating the table
                            Assembly hooksAssembly = Assembly.Load("MetraTech.Product.Hooks");
                            Type ddlcreatorType = hooksAssembly.GetType("MetraTech.Product.Hooks.DDLCreator");
                            MethodInfo createTableMethod = ddlcreatorType.GetMethod("GenerateCreateTableStatement");
                            ServiceDefinitionCollection mSvcDefCollection = new ServiceDefinitionCollection();
                            IServiceDefinition serviceDef = mSvcDefCollection.GetServiceDefinition(servicename);

                            object[] constparams = { SD_TABLE_PREFIX, serviceDef };
                            Object ddlObject = Activator.CreateInstance(ddlcreatorType, constparams);
                            object[] methodparams = { true };
                            object val = createTableMethod.Invoke(ddlObject, methodparams);
                            string createtable = val.ToString();

                            using (IMTAdapterStatement addDeclare = connstage.CreateAdapterStatement("queries\\ServiceDef", "__ADD_DECLARE__"))
                            {
                                addDeclare.AddParam("%%DDL%%", createtable, true);
                                addDeclare.ExecuteNonQuery();
                            }
                            break;
                        default:
                            break;
                    }
                }

                mLog.LogDebug("Ending DropStagingTables function");
            }
            catch (Exception ex)
            {
                mLog.LogError("Error occured while dropping staging table: " + ex.Message);
                mLog.LogError("StackTrace: " + ex.StackTrace);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        private void RetrievePropsDBDataType()
        {
            string query = "";
            switch (mEntityType)
            {
                case EntityType.PV:
                    query = "SELECT nm_name,n_prop_type FROM t_prod_view_prop where id_prod_view = " + mPropFKID;
                    break;
                case EntityType.PT:
                    query = "SELECT nm_name,n_prop_type FROM t_param_table_prop where id_param_table = " + mPropFKID;
                    break;
                case EntityType.SD:
                    query = "SELECT nm_name,n_prop_type FROM t_service_def_prop where id_service_def = " + mPropFKID;
                    break;
                case EntityType.AV:
                    query = "SELECT nm_name,n_prop_type FROM t_account_view_prop where id_account_view = " + mPropFKID;
                    break;
            }
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(query))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string propname = reader.GetString("nm_name");
                            int proptype = reader.GetInt32("n_prop_type");
                            mPropsDataType.Add(propname, proptype);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="columnName"></param>
        /// <returns></returns>
        private bool IsDBTypeString(string propName)
        {
            int datatype = Convert.ToInt32(mPropsDataType[propName]);
            return (datatype == 0) ? true : false;
        }
    }

    class InternalProductView
    {
        private int mID;
        public int ID
        {
            get { return mID; }
        }

        private bool mCanResubmitFrom;
        public bool CanResubmitFrom
        {
            get { return mCanResubmitFrom; }
            set { mCanResubmitFrom = value; }
        }

        private int mViewID;
        public int ViewID
        {
            get { return mViewID; }
            set { mViewID = value; }
        }

        private string mName;
        public string Name
        {
            get { return mName; }
            set { mName = value; }
        }

        private string mTableName;
        public string TableName
        {
            get { return mTableName; }
            set { mTableName = value; }
        }

        private void Init(IMTDataReader reader)
        {
            mID = reader.GetInt32("id_prod_view");
            mName = reader.GetString("nm_name");
            mTableName = reader.GetString("nm_table_name");
            mViewID = reader.GetInt32("id_view");
            mCanResubmitFrom = reader.GetBoolean("b_can_resubmit_from");
        }

        public InternalProductView(IMTDataReader reader)
        {
            Init(reader);
        }

        public InternalProductView(string nm, IMTConnection conn)
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductView", "__SELECT_PRODUCT_VIEW_BY_NAME__"))
            {
                stmt.AddParam("%%NM_NAME%%", nm);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    Init(reader);
                }
            }
        }
    }

    /// <summary>
    /// Represents a change to properties of an object (atomic types).
    /// </summary>
    class ObjectUpdate
    {
        class ObjectParameter
        {
            private System.Reflection.PropertyInfo mObjectProperty;
            private string mQueryPropertyTag;
            public void Set(Object value, IMTAdapterStatement stmt)
            {
                if (mObjectProperty.PropertyType.Name == "Boolean")
                {
                    stmt.AddParam(mQueryPropertyTag, (bool)mObjectProperty.GetValue(value, null) ? "Y" : "N");
                }
                else
                {
                    stmt.AddParam(mQueryPropertyTag, mObjectProperty.GetValue(value, null));
                }
            }
            public ObjectParameter(Type ty, string objectPropertyName, string queryPropertyTag)
            {
                mQueryPropertyTag = queryPropertyTag;
                mObjectProperty = ty.GetProperty(objectPropertyName);
            }
        }
        private Object mValue;
        private string mQueryTag;
        private ArrayList mParameters;
        public int ExecuteNonQuery(IMTConnection conn)
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductView", mQueryTag))
            {
                foreach (ObjectParameter op in mParameters)
                {
                    op.Set(mValue, stmt);
                }

                return stmt.ExecuteNonQuery();
            }
        }

        public ObjectUpdate(Object o)
        {
            mQueryTag = "__UPDATE_PRODUCT_VIEW_BY_ID__";
            mValue = o;
            Type ty = mValue.GetType();
            mParameters = new ArrayList();
            mParameters.Add(new ObjectParameter(ty, "ID", "%%ID_PROD_VIEW%%"));
            mParameters.Add(new ObjectParameter(ty, "ViewID", "%%ID_VIEW%%"));
            mParameters.Add(new ObjectParameter(ty, "CanResubmitFrom", "%%B_CAN_RESUBMIT_FROM%%"));
            mParameters.Add(new ObjectParameter(ty, "Name", "%%NM_NAME%%"));
            mParameters.Add(new ObjectParameter(ty, "TableName", "%%NM_TABLE%%"));
        }
    }

    class TableModifications
    {
        public enum ActionType
        {
            Added, Modified, Deleted
        }
        public enum ActionName
        {
            //pokh-8june-RowOperatorChanged & ColumnOperatorChanged not needed. As the the MetraConfig code adds the
            //property for the row opeartor, it would be added/dropped when the Column operator modified to Row or vice-versa
            DataTypeChanged, LengthIncreased, RequiredToNonRequired, NonRequiredToRequired, RowOperatorChanged, ColumnOperatorChanged, DescriptionChanged
        }
        public string columnName;
        public ActionType action;
        public IMTPropertyMetaData metadata;
        public ArrayList actionsdone;	//stores the list of actionNames
    }
    /// <summary>
    /// Contains partition state. 
    /// Determines the creation/drop of Unique Key tables,
    /// depending on  partition state.
    /// </summary>
    [ComVisible(false)]
    public class PartitionOps
    {
        Logger mLog = null;
        
        //Depends on partition state, use for Create\Drop Unique Key tables.
        public bool UseUkTables { get; private set; }

        public PartitionOps()
        {
            UseUkTables = false;
        }

        // Reads partition state, set value to UseUKTables variable for using Unique Key Tables.
        public void Init(Logger logger)
        {
            mLog = logger;

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                // Should UK tables be used to check Uniqness across partitions?
                using (IMTAdapterStatement adapstmt = conn.CreateAdapterStatement(
                    "select b_partitioning_enabled from t_usage_server"))
                {
                    using (IMTDataReader reader = adapstmt.ExecuteReader())
                    {
                        int cnt = 0;
                        while (reader.Read())
                        {
                            if (cnt++ > 1)
                                throw new ApplicationException("Too many rows in t_usage_server");

                            bool enabled = reader.GetString("b_partitioning_enabled").ToLower() == "y";

                            //Set using Unique Key Tables to true if partition is enabled and database is SqlServer.
                            UseUkTables = enabled && conn.ConnectionInfo.IsSqlServer;
                        }

                        if (cnt < 1)
                            throw new ApplicationException("No row found in t_usage_server");
                    }
                }
            }
        }

        // Calls stored proc CreateUniqueKeyTables for a given partitioned table.
        public void CreateUniqueKeyTables(string tablename, IMTConnection conn)
        {
            // The stored proc reads the metadata and creates the uk tables accordingly
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateUniqueKeyTables"))
            {
                stmt.AddParam("tabname", MTParameterType.String, tablename);
                mLog.LogDebug(string.Format("Creating unique key tables for [{0}]", tablename));
                stmt.ExecuteNonQuery();
            }
        }

        // Takes a list of UniqueKeys and drops the corresponding unique key tables.
        public void DropUniqueKeyTables(ArrayList dropped, IMTConnection conn)
        {
            // Drop each key given
            foreach (UniqueKey uk in dropped)
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(string.Format(
                    "drop table {0}", uk.TableName)))
                {
                    mLog.LogDebug(string.Format("Dropping unique key table [{0}]", uk.TableName));
                    stmt.ExecuteNonQuery();
                }
            }
        }
    }	// class PartitionOps
}

using System;
using System.Collections.Generic;
using System.Xml;
using MetraTech.Interop.RCD;
using MetraTech.UsageServer;
using MetraTech.Xml;
using MetraTech.DataAccess;

namespace MetraTech.Tax.Framework
{
    /// <summary>
    /// Contains methods that all vendor specific tax managers
    /// must implement, regardless of where it is an synchronous
    /// or asynchronous tax manager.
    /// </summary>
    public class TaxAdapterAssistant
    {
        // Logger
        private readonly Logger mLogger = new Logger("[TaxAdapterAssistant]");

        // The associated adapter (EOP or scheduled)
        protected IRecurringEventRunContext mContext = null;

        // The tax manager that we are going to use to carry out our requests
        protected SyncTaxManagerBatchDb mManager = null;

        // If true, the detailed tax results (one line per tax) will be stored in t_tax_details table.
        protected bool mTaxDetailsNeeded = false;

        // The maximum number of tax calculations errors that can occur before calculations end.
        protected int mMaximumNumberOfErrors = 0;

        // Used to report back how things are going. Usually this is associated with
        // the EOP adapter that is using the assistant.
        private TaxAssistantStatusReporter mStatusReporter = null;

        // Used to help parse the input hook query.  This is the query that is
        // used to populate t_tax_input_...
        private List<String> mInputHookQueryTagList = new List<string>();

        // Used to hep parse the output hook query.  This is the query that takes
        // t_tax_output... and places the data in the correct places.
        private List<String> mOutputHookQueryTagList = new List<string>();

        // The unique ID associated with this tax run.
        private int mTaxRunId = 0;

        // If true, the third party tax vendor will store audit information.
        protected bool mIsAuditingNeeded = true;

        // The tax vendor that is being used to process taxes.
        protected DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor mVendor;

        /// <summary>
        /// Get the tax vendor that is being used.
        /// </summary>
        public DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor vendor
        {
            get { return mVendor; }
        }

        /// <summary>
        /// Set the tax vendor that should be used for calculating taxes.  This method
        /// also instantiates the tax manager that will be used.
        /// </summary>
        /// <param name="giveVendor"></param>
        public void SetVendor(DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor giveVendor)
        {
            mVendor = giveVendor;
            mManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(giveVendor);
            mManager.SetStatusReporter(mStatusReporter);
        }

        /// <summary>
        /// Sets the context of an adapter. TaxAdapterAssistant will use it when stores and loads its state. 
        /// Context is part of the tax manager state
        /// </summary>
        /// <returns>Context ID</returns>
        public void SetAdapterContext(IRecurringEventRunContext givenContext)
        {
            mContext = givenContext;

            // Construct a status reporter that will report messages using the context.
            mStatusReporter = new TaxAssistantStatusReporter(givenContext);

            // If we have a manager already, tell the manager about the reporter.
            if (mManager != null)
                mManager.SetStatusReporter(mStatusReporter);
            if (mManager != null)
                mManager.AdapterUniqueRunId = givenContext.RunID;
        }

        /// <summary>
        /// Determine the Tax Run ID that is associated with the usage interval.
        /// We find the tax run ID by looking in a table that associates the
        /// usage interval with a tax run ID. 
        /// </summary>
        /// <returns>the tax run ID or -1 if there is no associated tax run ID</returns>
        public int LoadTaxRunIdForContext()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                IMTDataReader reader;
                if (mContext.EventType == RecurringEventType.EndOfPeriod)
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(CommonQueryFolder, "__GET_ID_TAX_RUN_FROM_CONTEXT_EOP__"))
                    {
                        stmt.AddParam("%%ID_VENDOR%%", (int)DomainModel.Enums.EnumHelper.GetDbValueByEnum(vendor));
                        stmt.AddParam("%%ID_USAGE_INTERVAL%%", mContext.UsageIntervalID);
                        stmt.AddParam("%%ID_BILLGROUP%%", mContext.BillingGroupID);
                        reader = stmt.ExecuteReader();
                    }
                }
                else if (mContext.EventType == RecurringEventType.Scheduled)
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(CommonQueryFolder, "__GET_ID_TAX_RUN_FROM_CONTEXT_SCHED__"))
                    {
                        stmt.AddParam("%%ID_VENDOR%%", (int)DomainModel.Enums.EnumHelper.GetDbValueByEnum(vendor));
                        stmt.AddParam("%%DT_START%%", mContext.StartDate);
                        stmt.AddParam("%%DT_END%%", mContext.EndDate);
                        reader = stmt.ExecuteReader();
                    }
                }
                else
                {
                    throw new TaxException(string.Format("Unsupported event type {0}", mContext.EventType));
                }

                if (reader.Read())
                {
                    return reader.GetInt32("id_tax_run");
                }

                // We didn't find that tax run ID.
                return -1;
            }
        }

        /// <summary>
        /// Generate a tax run ID to be associated with the context (EOP or scheduled
        /// adapter).  Throws an exception if there already is a tax run ID associated
        /// with the context.
        /// </summary>
        public void GenerateTaxRunForContext()
        {
            try
            {
                //Check that this context does not have a tax run id already
                int id_tax_run = LoadTaxRunIdForContext();

                //If it does throw error
                if (id_tax_run != -1)
                    throw new DuplicatedContextException(string.Format("There is already a tax run id {0} associated with current context. Context: {1}", id_tax_run, GetContextAsString()));

                //If it does not create tax run id from t_current_id table using get next id
                id_tax_run = mManager.GenerateUniqueTaxRunID();
                mLogger.LogDebug("Tax run id generated: {0}", id_tax_run);


                TaxRunId = id_tax_run;

                //Insert a record into t_tax_run
                InsertTaxRunRecord();
            }
            catch (DuplicatedContextException)
            {
                throw; //rethrow original exception
            }
            catch (Exception ex)
            {
                throw new TaxException("Unable to generate new tax run id", ex);
            }
        }

        /// <summary>
        /// Insert the generated tax run ID into the table where we associated
        /// a tax run ID with a usage interval.
        /// </summary>
        private void InsertTaxRunRecord()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(CommonQueryFolder, "__INSERT_TAX_RUN__"))
                {
                    stmt.AddParam("%%ID_TAX_RUN%%", TaxRunId);
                    stmt.AddParam("%%ID_VENDOR%%", (int)DomainModel.Enums.EnumHelper.GetDbValueByEnum(vendor));
                    if (mContext.UsageIntervalID == 0)
                        stmt.AddParam("%%ID_USAGE_INTERVAL%%", DBNull.Value);
                    else
                        stmt.AddParam("%%ID_USAGE_INTERVAL%%", mContext.UsageIntervalID);
                    if (mContext.BillingGroupID == 0)
                        stmt.AddParam("%%ID_BILLGROUP%%", DBNull.Value);
                    else
                        stmt.AddParam("%%ID_BILLGROUP%%", mContext.BillingGroupID);
                    if (mContext.StartDate == new DateTime(1, 1, 1))
                        stmt.AddParam("%%DT_START%%", DBNull.Value);
                    else
                        stmt.AddParam("%%DT_START%%", mContext.StartDate);
                    if (mContext.EndDate == new DateTime(1, 1, 1))
                        stmt.AddParam("%%DT_END%%", DBNull.Value);
                    else
                        stmt.AddParam("%%DT_END%%", mContext.EndDate);
                    stmt.ExecuteNonQuery();
                }
            }

        }

        /// <summary>
        /// Get the tax run ID associated with this context.
        /// If there isn't one, throw an exception.
        /// </summary>
        public void LoadTaxRunForContext()
        {
            //Check that this context does have a tax run id 
            int id_tax_run = LoadTaxRunIdForContext();

            //If it does not throw error
            if (id_tax_run == -1)
            {
                string msg = string.Format("There is no tax run id associated with current context. {0}", GetContextAsString());
                throw new TaxException(string.Format(msg));
            }

            TaxRunId = id_tax_run;
        }

        /// <summary>
        /// Get a string version of the context suitable
        /// for log messages.
        /// </summary>
        /// <returns></returns>
        private string GetContextAsString()
        {
            if (mContext == null)
                return "NULL";

            return mContext.ToString();
        }

        /// <summary>
        /// Sets the tax mode to either "estimated" or "actual".
        /// If "estimated", no auditing is needed and should be
        /// set to false.
        /// </summary>
        public bool IsAuditingNeeded
        {
            get { return mIsAuditingNeeded; }
            set
            {
                mIsAuditingNeeded = value;
                mManager.IsAuditingNeeded = mIsAuditingNeeded;
            }
        }

        /// <summary>
        /// If true, the detailed tax results (one line per tax) will be stored in t_tax_details table.
        /// </summary>
        public bool TaxDetailsNeeded
        {
            get
            {
                return mTaxDetailsNeeded;
            }
            set
            {
                mTaxDetailsNeeded = value;
                mManager.TaxDetailsNeeded = mTaxDetailsNeeded;
            }
        }

        /// <summary>
        /// The maximum number of tax calculations errors that can occur before
        /// tax execution is terminated.
        /// </summary>
        public int MaximumNumberOfErrors
        {
            get
            {
                return mMaximumNumberOfErrors;
            }
            set
            {
                mMaximumNumberOfErrors = value;
                mManager.MaximumNumberOfErrors = mMaximumNumberOfErrors;
            }
        }

        /// <summary>
        /// Get the name of the tax input table associated with this tax run.
        /// </summary>
        public string TableInputTableName
        {
            get { return mManager.GetInputTaxTableName(); }
        }

        /// <summary>
        /// Get the name of the tax output table associated with this tax run.
        /// </summary>
        public string TableOutputTableName
        {
            get { return mManager.GetInputTaxTableName(); }
        }

        /// <summary>
        /// This method populates t_tax_input... by executingn an SI configured query.
        /// This method will execute query from the RMP\Config\Queries\Tax\%%Vendor%%\Customizable\Queries.xml
        /// There will be a query with a tag specified in the adapter config InputHookQueryTag.
        /// SI will write custom queries to take charges from appropriate customer specific place.
        /// </summary>
        public void PopulateTaxInputTableWithCharges()
        {
            mLogger.LogDebug("Populating input tax table: t_tax_input_" + mTaxRunId);
            if (mInputHookQueryTagList.Count == 0)
                mLogger.LogWarning(@"There is no Input hooks to Run. Process will continue, but the tax input table will be empty. Not taxes will be calculated. Query tags for input hooks are specified under RMP\extension\YOUR_EXT\Tax\");

            string queryTag = "";
            try
            {
                mLogger.LogDebug("Executing SQL statements to populate input table.");
                foreach (string InputHookQueryTag in mInputHookQueryTagList)
                {
                    mLogger.LogDebug("Executing SQL defined by tag: " + InputHookQueryTag);
                    queryTag = InputHookQueryTag;
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(HookQueryFolder, InputHookQueryTag))
                        {
                            stmt.AddParam("%%ID_TAX_RUN%%", TaxRunId);
                            stmt.AddParam("%%TAX_VENDOR%%",
                                          (int)MetraTech.DomainModel.Enums.EnumHelper.GetDbValueByEnum(vendor));
                            if (mContext.EventType == RecurringEventType.EndOfPeriod)
                            {
                                stmt.AddParam("%%ID_USAGE_INTERVAL%%", mContext.UsageIntervalID);
                                stmt.AddParam("%%ID_BILL_GROUP%%", mContext.BillingGroupID);
                            }
                            else if (mContext.EventType == RecurringEventType.Scheduled)
                            {
                                mLogger.LogDebug("Using these dates for the scheduled adapter: " + mContext.StartDate + " and " + mContext.EndDate);
                                stmt.AddParam("%%START_DATE%%", mContext.StartDate);
                                stmt.AddParam("%%END_DATE%%", mContext.EndDate);
                            }
                            else
                            {
                                string err = "Unsupported event type: " + mContext.EventType.ToString() +
                                             "Occurred processing tax for " + queryTag;
                                mLogger.LogError(err);
                                throw new TaxException(string.Format(err));
                            }
                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                string err = "Unsupported event type: " + mContext.EventType.ToString() +
                             "Occurred processing tax for " + queryTag + "." +
                             "Error: " + e.Message;
                mLogger.LogError(err);
                throw new TaxException(string.Format(err));
            }
        }


        /// <summary>
        /// This method takes t_tax_output... and distributes that data into the tables
        /// it needs to go in by executing an SI configured query.
        /// This method will execute query from the RMP\Config\Queries\Tax\%%Vendor%%\Customizable\Queries.xml
        /// There will be a query with a tag specified in the adapter config OutputHookQueryTag.
        /// SI will write custom queries to store tax results in the appropriate customer specific place.
        /// </summary>
        public void FetchTaxResultsFromTaxOutputTable()
        {
            if (mOutputHookQueryTagList.Count == 0)
                mLogger.LogWarning(@"There is no Output hooks to Run. Process will continue, but the tax input table will be empty. Not taxes will be calculated. Query tags for input hooks are specified under RMP\extension\YOUR_EXT\Tax\");

            foreach (string OutputHookQueryTag in mOutputHookQueryTagList)
            {
                mLogger.LogDebug("Running output hook with query tag {0}", OutputHookQueryTag);
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(HookQueryFolder, OutputHookQueryTag))
                    {
                        stmt.AddParam("%%ID_TAX_RUN%%", TaxRunId);
                        if (mContext.EventType == RecurringEventType.EndOfPeriod)
                        {
                            stmt.AddParam("%%ID_USAGE_INTERVAL%%", mContext.UsageIntervalID);
                            stmt.AddParam("%%ID_BILL_GROUP%%", mContext.BillingGroupID);
                        }
                        else if (mContext.EventType == RecurringEventType.Scheduled)
                        {
                            stmt.AddParam("%%START_DATE%%", mContext.StartDate);
                            stmt.AddParam("%%END_DATE%%", mContext.EndDate);
                        }
                        else
                        {
                            throw new TaxException(string.Format("Unsupported event type: {0}", mContext.EventType.ToString()));
                        }
                        stmt.ExecuteNonQuery();
                    }
                }
            }
        }

        /// <summary>
        /// The name of the directory that holds the customized input and output hooks.
        /// </summary>
        public string HookQueryFolder { get; set; }

        /// <summary>
        /// Gets the name of the directory that holds configured queries for a particular
        /// tax vendor.  We need this because it holds the name of the specific tag
        /// we should use to find the configured input and output hooks.
        /// </summary>
        public string VendorQueryFolder
        {
            get { return string.Format(@"{0}\{1}", CommonQueryFolder, TaxVendorToString(vendor)); }
        }

        /// <summary>
        /// Gets the name of the directory where general queries are stored.
        /// </summary>
        public string CommonQueryFolder
        {
            get { return @"Queries\Tax"; }
        }

        /// <summary>
        /// Get a printable version of the tax vendor suitable for logging.
        /// </summary>
        /// <param name="givenVendor">tax vendor</param>
        /// <returns>printable verison of the tax vendor</returns>
        private string TaxVendorToString(DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor givenVendor)
        {
            return givenVendor.ToString();
        }

        /// <summary>
        /// Given a string naming a specific tax vendor, return the associated
        /// enum value.
        /// </summary>
        /// <param name="vendorString"></param>
        /// <returns></returns>
        private DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor TaxVendorParseFromString(string vendorString)
        {
            vendorString = vendorString.ToUpper();
            switch (vendorString)
            {
                case "METRATAX": return DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor.MetraTax;
                case "BILLSOFT": return DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor.BillSoft;
                case "TAXWARE": return DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor.Taxware;
                default:
                    throw new TaxException(string.Format("Invalid vendor string:{0}", vendorString));
            }
        }

        /// <summary>
        /// Read the given configuration file. 
        /// Sets the main attributes for tax like: do we want auditing?
        /// how many errors are permitted? do we keep journaling?
        /// what vendor do we use?
        /// </summary>
        /// <param name="configFile"></param>
        /// <returns>true on success</returns>
        public bool ReadConfigFile(string configFile)
        {
            try
            {
                if (configFile == string.Empty)
                    throw new Exception("config file not specified");

                MTXmlDocument doc = new MTXmlDocument();
                doc.Load(configFile);

                string vendorString = doc.GetNodeValueAsString("/xmlconfig/Vendor");
                DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor theVendor = TaxVendorParseFromString(vendorString);

                // Set the vendor to use
                SetVendor(theVendor);

                TaxDetailsNeeded = doc.GetNodeValueAsBool("/xmlconfig/TaxDetailsNeeded");
                IsAuditingNeeded = doc.GetNodeValueAsBool("/xmlconfig/IsAuditingNeeded");
                MaximumNumberOfErrors = doc.GetNodeValueAsInt("/xmlconfig/MaximumNumberOfErrors");

                HookQueryFolder = doc.GetNodeValueAsString("/xmlconfig/HookQueryFolder");

                CreateTaxInputTableQueryTag = doc.GetNodeValueAsString("/xmlconfig/Queries/CreateTaxInputTable");
                CreateTaxInputIndexesQueryTag = doc.GetNodeValueAsString("/xmlconfig/Queries/CreateTaxInputIndexes");

                string HookType = doc.GetNodeValueAsString("/xmlconfig/HookType");
                ReadInputAndOutputHookQueryTagList(HookType);

                return true;
            }
            catch (Exception ex)
            {
                string msg = string.Format("Unable to read config file {0}", configFile);
                throw new InvalidConfigurationException(msg, ex);
            }
        }

        /// <summary>
        /// Read query tags for input and output hooks.
        /// Hooks will be under RMP\Extensions\{Your_Ext}\config\Tax\{vendor_name}Queries.xml
        /// For example RMP\Extensions\AudioConf\config\Tax\BillSoftQueries.xml looks like:
        /// <Tax>
        ///   <hooks>
        ///     <QueryPath>config/Queries/Tax/BillSoft/Customizable</QueryPath>
        ///     <!--<QueryPath>Queries\Tax\Test</QueryPath>-->
        ///     <hook type="EOP">
        ///       <PopulateTaxInputTable>__AUDIOCONF_TO_BILLSOFT_INPUT__</PopulateTaxInputTable>
        ///       <UpdateMetraNetTables>__BILLSOFT_OUTPUT_TO_AUDIOCONF__</UpdateMetraNetTables>
        ///     </hook>
        ///   </hooks>
        /// </Tax>
        /// </summary>
        /// <param name="HookType"></param>
        private void ReadInputAndOutputHookQueryTagList(string HookType)
        {
            //clear the list and load from extension folder config files
            mInputHookQueryTagList.Clear();
            mOutputHookQueryTagList.Clear();

            IMTRcd rcd = new MTRcd();
            string vendorStr = TaxVendorToString(vendor);

            string query = string.Format(@"config\Tax\{0}Queries.xml", vendorStr);
            IMTRcdFileList fileList = rcd.RunQuery(query, false);

            if (fileList.Count == 0)
                mLogger.LogWarning(@"Could not find any custom hooks to run! Query tags for input hooks should be specified under RMP\extension\{0}", query);

            foreach (string filename in fileList)
            {
                ReadInputAndOutputHookQueryTag(filename, HookType);
            }

            if (mInputHookQueryTagList.Count == 0)
                mLogger.LogWarning("Did not find any input hooks of type {0}", HookType);

            if (mOutputHookQueryTagList.Count == 0)
                mLogger.LogWarning("Did not find any output hooks of type {0}", HookType);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="configFile"></param>
        /// <param name="HookType"></param>
        private void ReadInputAndOutputHookQueryTag(string configFile, string HookType)
        {
            if (configFile == string.Empty)
                throw new Exception("config file not specified");

            mLogger.LogDebug("reading query tags for hooks in {0}", configFile);

            MTXmlDocument doc = new MTXmlDocument();
            doc.Load(configFile);

            XmlNodeList nodelist = doc.SelectNodes(string.Format("/Tax/hooks/hook[@type='{0}']", HookType), null);

            if (nodelist == null || nodelist.Count == 0)
            {
                mLogger.LogDebug("No hooks of type {0} found", HookType);
                return;
            }

            foreach (XmlNode hookNode in nodelist)
            {
                string inputHook = MTXmlDocument.GetNodeValueAsString(hookNode, "PopulateTaxInputTable");
                mInputHookQueryTagList.Add(inputHook);
                mLogger.LogDebug("PopulateTaxInputTable: {0}", inputHook);
                string outputHook = MTXmlDocument.GetNodeValueAsString(hookNode, "UpdateMetraNetTables");
                mOutputHookQueryTagList.Add(outputHook);
                mLogger.LogDebug("UpdateMetraNetTables: {0}", outputHook);
            }

        }

        /// <summary>
        /// Takes the name of the tax input table containing all the information
        /// needed to calculate taxes.   Calls the third party vendor to calculate
        /// taxes.  Creates and populates the tax output table.  If all taxes are
        /// successfully created, commits the tax audit information stored by the
        /// third party tax vendor.
        /// </summary>
        public void CalculateTaxes()
        {
            mManager.CalculateTaxes();
        }

        /// <summary>
        /// This method reverses CalculatTaxes.
        /// Can be called after taxes have been calculated
        /// to throw away any third party auditing and to delete
        /// the tax output table.
        /// </summary>
        public void ReverseTaxRun()
        {
            mManager.ReverseTaxRun();
        }

        /// <summary>
        /// Get or set the name of the query tag we should use to create
        /// the tax input table.
        /// </summary>
        public string CreateTaxInputTableQueryTag { get; set; }

        /// <summary>
        /// Get or set the name of the query tag we should use to create
        /// indices for the tax input table.
        /// </summary>
        public string CreateTaxInputIndexesQueryTag { get; set; }

        /// <summary>
        /// This method will execute query from the RMP\Config\Queries\Tax\%%Vendor%%\Customizable\Queries.xml
        /// There will be a query with a tag specified in the adapter config CreateTaxInputTableQueryTag.
        /// SI will write custom queries to create Input table.
        /// </summary>
        public void CreateTaxInputTable()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(HookQueryFolder, CreateTaxInputTableQueryTag))
                {
                    stmt.AddParam("%%ID_TAX_RUN%%", TaxRunId);
                    stmt.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// This method will execute query from the RMP\Config\Queries\Tax\%%Vendor%%\Customizable\Queries.xml
        /// There will be a query with a tag specified in the adapter config CreateTaxInputIndexesQueryTag.
        /// SI will write custom queries to create Input table.
        /// This method will be called once the input table is fully loaded with taxes.
        /// </summary>
        public void CreateTaxInputIndexes()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(HookQueryFolder, CreateTaxInputIndexesQueryTag))
                {
                    stmt.AddParam("%%ID_TAX_RUN%%", TaxRunId);
                    stmt.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Get or set the tax run ID associated with this tax run.
        /// </summary>
        public int TaxRunId
        {
            get { return mTaxRunId; }
            set
            {
                mTaxRunId = value;
                mManager.TaxRunId = mTaxRunId;
            }
        }

        /// <summary>
        /// Delete the tax run ID associated with the context.
        /// </summary>
        public void DeleteTaxRunForContext()
        {
            int taxRunId = LoadTaxRunIdForContext();
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(CommonQueryFolder, "__DELETE_TAX_RUN__"))
                {
                    stmt.AddParam("%%ID_TAX_RUN%%", taxRunId);
                    stmt.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Drop the tax input table.
        /// </summary>
        public void DropInputTable()
        {
            mManager.DropInputTable();
        }
    }

    public abstract class AsyncTaxAdapterAssistant : TaxAdapterAssistant
    {

        /// <summary>
        /// Given the name of a tax input table in the staging database,
        /// passes all the information to the tax vendor and starts the 
        /// calculation of taxes.  
        /// </summary>
        /// <param name="inputTableName"></param>
        public abstract void SubmitChargesToVendor(string inputTableName);

        /// <summary>
        /// Returns true if the vendor has completed calculating all taxes.
        /// </summary>
        /// <returns></returns>
        public abstract Boolean AreCalculationsComplete();

        /// <summary>
        /// Copies the calculated taxes from vendor to the output table.
        /// The name of the output table is derived from the input table
        /// name.
        /// </summary>
        public abstract void UnloadTaxResultsFromVendor();
    }
}

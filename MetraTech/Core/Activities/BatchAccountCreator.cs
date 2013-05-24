using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using System.Transactions;
using MetraTech.DataAccess;
using System.Collections;
using MetraTech.Interop.QueryAdapter;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTAccount;
using System.Runtime.InteropServices;
using System.Reflection;
using MetraTech.DomainModel.Common;

namespace MetraTech.Core.Activities
{
	public class BatchAccountCreator
    {
        #region Private Members
        private static Logger mLogger = new Logger("[BatchAccountCreation]");
        private static string m_EnforceSameCorporation = "1";
        private static bool m_IsEnforceSameCorporationChecked = false;

        private static Stack<string> m_AccountCreationTempTables = new System.Collections.Generic.Stack<string>();
        #endregion

        static BatchAccountCreator()
        {
            string tableBase = string.Format("tmpAcct_%_{0}_%",
                    System.Environment.MachineName.Replace("-", "_"));

            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    List<String> tablesToDrop = new List<string>();

                    using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement("Queries\\AccountCreation", "__GET_TEMP_ACCT_TABLES__"))
                    {
                        adapterStmt.AddParam("%%TABLE_BASE%%", tableBase);

                        using (IMTDataReader rdr = adapterStmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                string tableName = rdr.GetString(0);

                                int startingIndex = tableName.IndexOf("_") + 1;
                                int endingIndex = tableName.IndexOf("_", startingIndex);
                                int processId = Int32.Parse(tableName.Substring(startingIndex, endingIndex - startingIndex));

                                try
                                {
                                    // If process is not found, it throws an exception...
                                    System.Diagnostics.Process.GetProcessById(processId);
                                }
                                catch (Exception)
                                {
                                    tablesToDrop.Add(rdr.GetString(1));
                                }
                            }
                        }
                    }

                    if (tablesToDrop.Count > 0)
                    {
                        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                        {
                            queryAdapter.Item = new MTQueryAdapter();
                            queryAdapter.Item.Init("Queries\\AccountCreation");
                            queryAdapter.Item.SetQueryTag("__DROP_TEMP_ACCT_TABLE__");


                            foreach (var tableName in tablesToDrop)
                            {
                                try
                                {
                                    using (IMTPreparedStatement statement = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                                    {
                                        statement.AddParam("tableName", MTParameterType.String, tableName);

                                        statement.ExecuteNonQuery();
                                    }
                                }
                                catch (Exception e)
                                {
                                    mLogger.LogException("Error cleaning up temp tables", e);
                                }
                            }
                        }
                    }
                }
            }
        }

        #region Public Methods
        public static List<string> CreateAccounts(List<Account> accounts)
        {
            List<string> retval = null;
            Dictionary<int, bool> accountCreateStatus = new Dictionary<int, bool>();

            if (accounts != null && accounts.Count > 0)
            {
                TransactionOptions options = new TransactionOptions();
                options.Timeout = new TimeSpan(0, 2, 0);
                options.IsolationLevel = IsolationLevel.ReadCommitted;

                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, options, EnterpriseServicesInteropOption.Full))
                {
                    string tmpTableName = GetAccountCreationTempTable();

                    InsertAccountsIntoTempTable(accounts, tmpTableName, accountCreateStatus);

                    retval = ExecuteBatchAccountCreation(tmpTableName, accountCreateStatus);

                    ReleaseAccountCreationTempTable(tmpTableName);

                    foreach (Account acct in accounts)
                    {
                        if (acct._AccountID.HasValue && accountCreateStatus[acct._AccountID.Value])
                        {
                            AddAccountViews(acct);
                        }
                    }

                    scope.Complete();
                }
            }

            return retval;
        }
        #endregion

        #region Helper Methods
        private static void CheckEnforceSameCorporation()
        {
            if (!m_IsEnforceSameCorporationChecked)
            {
                IMTProductCatalog productCatalog = new MTProductCatalogClass();

                if (productCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
                {
                    m_EnforceSameCorporation = "0";
                }
                m_IsEnforceSameCorporationChecked = true;
            }
        }

        private static string GetAccountCreationTempTable()
        {
            string tempTableName = string.Empty;
            lock (((ICollection)m_AccountCreationTempTables).SyncRoot)
            {
                if (m_AccountCreationTempTables.Count > 0)
                    tempTableName = m_AccountCreationTempTables.Pop();
            }

            if (!string.IsNullOrEmpty(tempTableName))
            {
                // Truncate for next use
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTStatement stmt = conn.CreateAdapterStatement(string.Format("DELETE FROM {0}", tempTableName)))
                    {
                        stmt.ExecuteNonQuery();
                    }
                }
            }
            else
            {
                DBNameHash hash = new DBNameHash();

                // Create a new one and suppress any external transaction scope
                tempTableName = hash.GetDBNameHash(string.Format("tmpAcct_{0}_{1}_{2}",
                    System.Diagnostics.Process.GetCurrentProcess().Id.ToString(),
                    System.Environment.MachineName.Replace("-", "_"),
                    Guid.NewGuid().ToString("N")));

                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AccountCreation", "__CREATE_BATCH_ACCOUNT_TEMP_TABLE__"))
                        {
                            stmt.AddParam("%%TMP_TABLE_NAME%%", tempTableName);
                            stmt.AddParam("%%TMP_TABLE_IDX_NAME%%", string.Format("idx_{0}", tempTableName.Substring(0, 26)));

                            stmt.ExecuteNonQuery();
                        }
                    }
                }
            }

            return tempTableName;
        }

        private static void InsertAccountsIntoTempTable(List<Account> accounts, string tmpTableName, Dictionary<int, bool> accountCreationStatus)
        {
            string insertText = null;

            #region Get insert query text
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\AccountCreation");
            qa.SetQueryTag("__INSERT_INTO_BATCH_ACCOUNT_TEMP_TABLE__");
            qa.AddParam("%%TMP_TABLE_NAME%%", tmpTableName, false);
            insertText = qa.GetQuery();
            #endregion

            InternalView internalView;
            int requestId = 0;

            IdGenerator accountIdGenerator = new IdGenerator("id_acc", accounts.Count);
            IdGenerator profileIdGenerator = new IdGenerator("id_profile", accounts.Count);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                foreach (Account acct in accounts)
                {
                    internalView = acct.GetInternalView() as InternalView;

                    using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(insertText))
                    {

                        prepStmt.AddParam(MTParameterType.Integer, requestId++);
                        prepStmt.AddParam(MTParameterType.Binary, null);
                        prepStmt.AddParam(MTParameterType.String, "AC");
                        prepStmt.AddParam(MTParameterType.Integer, null);
                        prepStmt.AddParam(MTParameterType.DateTime, acct.AccountStartDate);
                        prepStmt.AddParam(MTParameterType.DateTime, acct.AccountEndDate);
                        prepStmt.AddParam(MTParameterType.String, acct.UserName);
                        prepStmt.AddParam(MTParameterType.String, acct.Name_Space);
                        prepStmt.AddParam(MTParameterType.String, acct.Password_);
                        prepStmt.AddParam(MTParameterType.String, internalView.Language.ToString());
                        prepStmt.AddParam(MTParameterType.Integer, EnumHelper.GetValueByEnum(internalView.TimezoneID));
                        prepStmt.AddParam(MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(internalView.UsageCycleType)));
                        prepStmt.AddParam(MTParameterType.Integer, acct.DayOfMonth);
                        prepStmt.AddParam(MTParameterType.Integer, acct.DayOfWeek);
                        prepStmt.AddParam(MTParameterType.Integer, acct.FirstDayOfMonth);
                        prepStmt.AddParam(MTParameterType.Integer, acct.SecondDayOfMonth);
                        prepStmt.AddParam(MTParameterType.Integer, acct.StartDay);
                        prepStmt.AddParam(MTParameterType.Integer, acct.StartMonth);
                        prepStmt.AddParam(MTParameterType.Integer, acct.StartYear);
                        prepStmt.AddParam(MTParameterType.String, EnumHelper.GetMTBool(internalView.Billable.HasValue ? internalView.Billable.Value : false));
                        prepStmt.AddParam(MTParameterType.Integer, acct.PayerID);
                        prepStmt.AddParam(MTParameterType.DateTime, acct.Payment_StartDate);
                        prepStmt.AddParam(MTParameterType.DateTime, acct.Payment_EndDate);
                        prepStmt.AddParam(MTParameterType.String, acct.PayerAccount);
                        prepStmt.AddParam(MTParameterType.String, acct.PayerAccountNS);
                        prepStmt.AddParam(MTParameterType.Integer, acct.AncestorAccountID);
                        prepStmt.AddParam(MTParameterType.DateTime, acct.Hierarchy_StartDate);
                        prepStmt.AddParam(MTParameterType.DateTime, acct.Hierarchy_EndDate);
                        prepStmt.AddParam(MTParameterType.String, acct.AncestorAccount);
                        prepStmt.AddParam(MTParameterType.String, acct.AncestorAccountNS);
                        prepStmt.AddParam(MTParameterType.String, acct.AccountType);
                        prepStmt.AddParam(MTParameterType.String, EnumHelper.GetMTBool(acct.ApplyDefaultSecurityPolicy.HasValue ? acct.ApplyDefaultSecurityPolicy.Value : false));
                        prepStmt.AddParam(MTParameterType.String, internalView.Currency);
                        prepStmt.AddParam(MTParameterType.Integer, profileIdGenerator.NextMashedId);
                        prepStmt.AddParam(MTParameterType.String, null);

                        if (!acct._AccountID.HasValue)
                        {
                            acct._AccountID = accountIdGenerator.NextMashedId;
                        }

                        prepStmt.AddParam(MTParameterType.Integer, acct._AccountID.Value);

                        prepStmt.ExecuteNonQuery();

                        accountCreationStatus[acct._AccountID.Value] = true;
                    }
                }
            }
        }

        private static List<string> ExecuteBatchAccountCreation(string tmpTableName, Dictionary<int, bool> accountCreationStatus)
        {
            List<string> retval = null;

            CheckEnforceSameCorporation();

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("BatchAccHierarchyCreation"))
                {
                    callableStmt.AddParam("tmp_table_name", MTParameterType.String, tmpTableName);
                    callableStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now);
                    callableStmt.AddParam("enforce_hierarchy_rules", MTParameterType.String, m_EnforceSameCorporation);

                    //lock (m_EnforceSameCorporation)
                    {
                        callableStmt.ExecuteNonQuery();
                    }
                }

                try
                {
                    using (IMTStatement stmt = conn.CreateStatement(string.Format("select id_request, id_account, nm_login, status from {0} where status is not null", tmpTableName)))
                    {

                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                retval = new List<string>();

                                do
                                {
                                    int status = rdr.GetInt32("status");
                                    string error = GetErrorMsg(status);

                                    retval.Add(string.Format("Account {0} failed with error {1}", rdr.GetString("nm_login"), error));

                                    accountCreationStatus[rdr.GetInt32("id_account")] = false;
                                }
                                while (rdr.Read());
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }

            return retval;
        }

        private static void ReleaseAccountCreationTempTable(string tempTableName)
        {
            // TODO: When/how to clean up these puppies?
            lock (((ICollection)m_AccountCreationTempTables).SyncRoot)
            {
                m_AccountCreationTempTables.Push(tempTableName);
            }
        }

        private static string GetErrorMsg(int status)
        {
            string error = String.Empty;
            switch (status)
            {
                case ACCOUNTMAPPER_ERR_ALREADY_EXISTS:
                    {
                        error = ACCOUNTMAPPER_ERR_ALREADY_EXISTS_MSG;
                        break;
                    }
                case MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH:
                    {
                        error = MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH_MSG;
                        break;
                    }
                case MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER:
                    {
                        error = MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER_MSG;
                        break;
                    }
                case MT_CANNOT_RESOLVE_PAYING_ACCOUNT:
                    {
                        error = MT_CANNOT_RESOLVE_PAYING_ACCOUNT_MSG;
                        break;
                    }
                case MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT:
                    {
                        error = MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT_MSG;
                        break;
                    }
                case MT_PARENT_NOT_IN_HIERARCHY:
                    {
                        error = MT_PARENT_NOT_IN_HIERARCHY_MSG;
                        break;
                    }
                case MT_ANCESTOR_OF_INCORRECT_TYPE:
                    {
                        error = MT_ANCESTOR_OF_INCORRECT_TYPE_MSG;
                        break;
                    }
                case MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START:
                    {
                        error = MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START_MSG;
                        break;
                    }
                case MT_ACCOUNT_ALREADY_IN_HIERARCHY:
                    {
                        error = MT_ACCOUNT_ALREADY_IN_HIERARCHY_MSG;
                        break;
                    }
                case MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE:
                    {
                        error = MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE_MSG;
                        break;
                    }
                case MT_PAYMENT_START_AND_END_ARE_THE_SAME:
                    {
                        error = MT_PAYMENT_START_AND_END_ARE_THE_SAME_MSG;
                        break;
                    }
                case MT_PAYMENT_START_AFTER_END:
                    {
                        error = MT_PAYMENT_START_AFTER_END_MSG;
                        break;
                    }
                case MT_ACCOUNT_IS_NOT_BILLABLE:
                    {
                        error = MT_ACCOUNT_IS_NOT_BILLABLE_MSG;
                        break;
                    }
                case MT_PAYER_IN_INVALID_STATE:
                    {
                        error = MT_PAYER_IN_INVALID_STATE_MSG;
                        break;
                    }
                case MT_PAYER_PAYEE_CURRENCY_MISMATCH_SQL:
                case MT_PAYER_PAYEE_CURRENCY_MISMATCH_ORC:
                    {
                        error = MT_PAYER_PAYEE_CURRENCY_MISMATCH_MSG;
                        break;
                    }
                case MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT:
                    {
                        error = MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT_MSG;
                        break;
                    }
                case MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE:
                    {
                        error = MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG;
                        break;
                    }
                case MT_USAGE_CYCLE_INFO_REQUIRED:
                    {
                        error = MT_USAGE_CYCLE_INFO_REQUIRED_MSG;
                        break;
                    }
                default:
                    {
                        // return error
                        error = String.Format("Unable to create account with status '{0}'.", status);
                        break;
                    }
            }

            return error;

        }

        private static void AddAccountViews(Account acct)
        {
            IMTAccountAdapter2 accServer = new MTAccountServerClass();

            // Loop through all views in account.
            MTAccountPropertyCollection newProperties = null;
            MTAccountPropertyCollection keyProperties = null;
            foreach (KeyValuePair<string, List<View>> kvp in acct.GetViews())
            {
                foreach (View view in kvp.Value)
                {
                    // Create a collection of properties instance.
                    if (newProperties != null)
                        Marshal.ReleaseComObject(newProperties);
                    newProperties = new MTAccountPropertyCollection();

                    // Keep track of key properties.
                    if (keyProperties != null)
                        Marshal.ReleaseComObject(keyProperties);
                    keyProperties = new MTAccountPropertyCollection();

                    // Loop through all the properties.
                    foreach (PropertyInfo pi in view.GetMTProperties())
                    {
                        // Has property been changed.
                        bool dirty = view.IsDirty(pi);

                        // Determine if property is part of key.
                        MTDataMemberAttribute attribsProp = acct.GetMTDataMemberAttribute(pi);
                        bool isPartOfKey = attribsProp.IsPartOfKey;

                        // Process property if it has been changed or it is part of key.
                        if (dirty || isPartOfKey)
                        {
                            // Get property value.
                            object value = EnumHelper.GetDbValue(view, pi);

                            // Add property to key collection.
                            if (isPartOfKey)
                                keyProperties.Add("c_" + pi.Name, value);
                            //xxx We should fix the adapter to not require a prefix, 
                            // just like when doing an add or an update

                            // Add property to properties collection
                            newProperties.Add(pi.Name, value);
                        }
                    }

                    // Did we find any valid properties that are non-key properties?
                    if (newProperties.Count - keyProperties.Count == 0)
                    {
                        continue;
                    }

                    // Add account id; it is always in a view.
                    newProperties.Add("id_acc", acct._AccountID);

                    // Initialize adapter for view.
                    accServer.Initialize(kvp.Key);

                    accServer.AddData(kvp.Key, newProperties, null); //xxx maybe psss in rowset?
                }
            }

            // Release COM objects.
            if (newProperties != null)
                Marshal.ReleaseComObject(newProperties);

            if (keyProperties != null)
                Marshal.ReleaseComObject(keyProperties);

            Marshal.ReleaseComObject(accServer);
        }
        #endregion

        #region Error Strings
        private const int ACCOUNTMAPPER_ERR_ALREADY_EXISTS = -501284862;
        private const string ACCOUNTMAPPER_ERR_ALREADY_EXISTS_MSG = "Account mapping already exists";

        private const int MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH = -486604732;
        private const string MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH_MSG = "Account Type and Namespace mismatch during account creation.";

        private const int MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER = -486604768;
        private const string MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER_MSG = "An account marked as non-billable must have a paying account.";

        private const int MT_CANNOT_RESOLVE_PAYING_ACCOUNT = -486604792;
        private const string MT_CANNOT_RESOLVE_PAYING_ACCOUNT_MSG = "Account Creation can not resolve the payer account from the login and namespace.";

        private const int MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT = -486604791;
        private const string MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT_MSG = "Account Creation can not resolve the hierarchy parent from the login and namespace.";

        private const int MT_PARENT_NOT_IN_HIERARCHY = -486604771;
        private const string MT_PARENT_NOT_IN_HIERARCHY_MSG = "The specified parent does not exist in the hierarchy.";

        private const int MT_ANCESTOR_OF_INCORRECT_TYPE = -486604714;
        private const string MT_ANCESTOR_OF_INCORRECT_TYPE_MSG = "The account and ancestor types do not match.";

        private const int MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START = -486604746;
        private const string MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START_MSG = "The system cannot create the account in the hierarchy before the start date of the ancestor.";

        private const int MT_ACCOUNT_ALREADY_IN_HIERARCHY = -486604785;
        private const string MT_ACCOUNT_ALREADY_IN_HIERARCHY_MSG = "The account is already in the hierarchy in the specified time range.";

        private const int MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE = -486604753;
        private const string MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE_MSG = "The system cannot create a payment record before the creation date of the account.";

        private const int MT_PAYMENT_START_AND_END_ARE_THE_SAME = -486604735;
        private const string MT_PAYMENT_START_AND_END_ARE_THE_SAME_MSG = "The system cannot create a payment record where the start and end day are the same day.";

        private const int MT_PAYMENT_START_AFTER_END = -486604734;
        private const string MT_PAYMENT_START_AFTER_END_MSG = "The payment start date must be before the payment end date.";

        private const int MT_ACCOUNT_IS_NOT_BILLABLE = -486604795;
        private const string MT_ACCOUNT_IS_NOT_BILLABLE_MSG = "The paying account is not billable.";

        private const int MT_PAYER_IN_INVALID_STATE = -486604736;
        private const string MT_PAYER_IN_INVALID_STATE_MSG = "The paying account is not active during the payment time interval.";

        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH_SQL = -486604737;  // Error Condition Returned by SQL Server
        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH_ORC = -486604728;  // Error Condition Returned by Oracle
        private const string MT_PAYER_PAYEE_CURRENCY_MISMATCH_MSG = "The currency of the payer account must match the currency of the payee account.";

        private const int MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT = -486604758;
        private const string MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT_MSG = "Both the payer account and payee account must share the same corporate account.";

        private const int MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE = -289472464;
        private const string MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG = "";

        private const int MT_USAGE_CYCLE_INFO_REQUIRED = -486604740;
        private const string MT_USAGE_CYCLE_INFO_REQUIRED_MSG = "Unable to identify account usage cycle";

        #endregion
    }
}

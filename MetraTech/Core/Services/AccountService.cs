/**************************************************************************
* Copyright 2007 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using System.Runtime.Serialization;
using System.Transactions;
using MetraTech.Core.Activities;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.QueryAdapter;
using RS = MetraTech.Interop.Rowset;
using YAAC = MetraTech.Interop.MTYAAC;
using Auth = MetraTech.Interop.MTAuth;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.Enums;
using System.IO;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Validators;
using MetraTech.Accounts.Type;
using MetraTech.Interop.MTYAAC;
using MetraTech.Interop.GenericCollection;
using System.Runtime.InteropServices;
using BaseTypes = MetraTech.DomainModel.BaseTypes;
using MetraTech.Debug.Diagnostics;
using System.Configuration;
using IMTAncestorMgr = MetraTech.Interop.MTYAAC.IMTAncestorMgr;
using PropValType = MetraTech.Interop.MTYAAC.PropValType;
using MetraTech.Core.Services;
using IMTPropertyMetaData = MetraTech.Interop.MTYAAC.IMTPropertyMetaData;
using IMTPropertyMetaDataSet = MetraTech.Interop.MTYAAC.IMTPropertyMetaDataSet;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Interop.MTAccount;
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.Core.Services
{
    [ServiceContract()]
    public interface IAccountService
    {
        // get the list of accounts
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountList(DateTime metraTimeStamp, ref MTList<BaseTypes.Account> accounts, bool displayAliases);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountListTotalRows(DateTime metraTimeStamp, MTList<BaseTypes.Account> accounts, bool displayAliases, out int totalRows);

        // Load account by id.
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void LoadAccount(AccountIdentifier acct, DateTime timeStamp, out BaseTypes.Account account);

        // Load account by id with all the views.
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void LoadAccountWithViews(AccountIdentifier acct, DateTime timeStamp, out BaseTypes.Account account);

        // Load view using Account Id.
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void LoadView(AccountIdentifier acct, string viewType, out List<BaseTypes.View> views);

        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void MoveAccounts(List<AccountIdentifier> accounts, AccountIdentifier newParent, DateTime timeStamp, DateTime moveStartDate);

        // get the list of account IDs
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountIdList(DateTime metraTimeStamp, ref MTList<BaseTypes.Account> accounts, bool displayAliases, out List<int> ids);

        // Add an account without using workflows
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void AddAccountWithoutWorkflow(ref BaseTypes.Account account);

        // Retrieves a name of account type for AllTypes account template.
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAllAccountsTypeName(ref string typeName);

        // Retrieves an account's type name and the value indicating if this account has a LogOn capability.
        [OperationContract]
        [FaultContract(typeof(MASBasicFaultDetail))]
        void GetAccountTypeName(long accountId, ref string typeName, ref bool hasLogonCapability);
    }

    [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
    public class AccountService : AccountLoaderService, IAccountService
    {
        delegate void ReadAccountData(IMTDataReader reader);

        #region Members
        private static AccountServiceConfigSection m_ConfigSection;

        private static IdGenerator profileIdGenerator = null;
        private static IdGenerator accountIdGenerator = null;

        private static Dictionary<string, IMTPropertyMetaData> mAccountMetaData = new Dictionary<string, IMTPropertyMetaData>(StringComparer.CurrentCultureIgnoreCase);
        #endregion

        static AccountService()
        {
            CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(CMASServiceBase_ServiceStarting);
        }

        static void CMASServiceBase_ServiceStarting()
        {
            Configuration config = LoadConfigurationFile(@"Account\AccountService.xml");
            m_ConfigSection = config.GetSection("AccountServiceConfig") as AccountServiceConfigSection;

            using (MTComSmartPtr<IMTAccountCatalog> accCatalog = new MTComSmartPtr<IMTAccountCatalog>())
            {
                accCatalog.Item = new MTAccountCatalog();
                using (MTComSmartPtr<IMTPropertyMetaDataSet> metaDataSet = new MTComSmartPtr<IMTPropertyMetaDataSet>())
                {
                    metaDataSet.Item = accCatalog.Item.GetAccountMetaData();

                    foreach (IMTPropertyMetaData metaData in metaDataSet.Item)
                    {
                        mAccountMetaData[metaData.Name] = metaData;
                    }
                }
            }


        }

        #region IAccountService Methods

        [OperationCapability("Manage Account Hierarchies")]
        public void LoadAccount(AccountIdentifier acct, DateTime timeStamp, out DomainModel.BaseTypes.Account account)
        {
            LoadAccountBase(acct, timeStamp, out account);
        }

        /// <summary>
        /// Retrieves the list of account IDs based on the timestamp, and filters/paging/sorting of passed MTList
        /// </summary>
        /// <param name="metraTimeStamp"></param>
        /// <param name="accounts"></param>
        /// <param name="displayAliases">Indicates which query to use as a base one. If true - "__ADVANCEDSEARCH_ALIASES__", else - "__ADVANCEDSEARCH__"</param>
        /// <param name="ids">Returns a list of found IDs.</param>
        [OperationCapability("Manage Account Hierarchies")]
        public void GetAccountIdList(DateTime metraTimeStamp, ref MTList<BaseTypes.Account> accounts, bool displayAliases, out List<int> ids)
        {

            // ESR-5877 add GetAccountListTimeOut configuration 
            int GetAccountListTimeOut = m_ConfigSection.GetAccountListTimeOut;
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountIdList", GetAccountListTimeOut))
            {
                // Get the session context from the WCF ambient service security context
                CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;
                if (clientIdentity == null)
                {
                    accounts.TotalRows = 0;
                    ids = null;
                    return;
                }

                YAAC.IMTAccountCatalog accountCatalog = InitAccountCatalog(clientIdentity);
                //add default filters
                RS.IMTDataFilter filter = new RS.MTDataFilter();
                //Set up columns for return...we actually just need the account id column
                YAAC.IMTCollection columns = (YAAC.IMTCollection)new Coll.MTCollectionClass();
                YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();

                // Passing a time stamp of timeZero instead of metraTimeStamp tells this method to
                // generate the query with a parameter called "RefDate".  Later within this method
                // we make sure to pass a parameter named RefDate with the value of metraTimeStamp
                //DateTime timeZero = DateTime.MinValue;
                string strSQL = GetAccountListQuery(clientIdentity,
                    metraTimeStamp,
                    accounts,
                    accountCatalog,
                    ref filter,
                    ref columns);
                //extract records
                try
                {
                    List<int> accountList = new List<int>();
                    //open connection
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        GetAccountListInternal(accounts,
                            false,
                            order,
                            strSQL,
                            conn,
                            metraTimeStamp,
                            true,
                            delegate(IMTDataReader reader)
                            {
                                //resolve account id
                                int accountID = reader.GetInt32("_AccountID");
                                if (displayAliases || !accountList.Contains(accountID))
                                {
                                    accountList.Add(accountID);
                                }
                            });
                    }

                    ids = accountList.Count > 0 ? accountList : null;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error in GetAccountIdList", e);

                    accounts.Items.Clear();
                    throw new MASBasicException("Error in AccountService:GetAccountIdList(). Unable to retrieve accounts");
                }
            }
        }

        /// <summary>
        /// Retrieves the list of accounts based on the timestamp, and filters/paging/sorting of passed MTList
        /// </summary>
        /// <param name="metraTimeStamp"></param>
        /// <param name="accounts"></param>
        /// <param name="displayAliases">Indicates which query to use as a base one. If true - "__ADVANCEDSEARCH_ALIASES__", else - "__ADVANCEDSEARCH__"</param>
        [OperationCapability("Manage Account Hierarchies")]
        public void GetAccountList(DateTime metraTimeStamp, ref MTList<BaseTypes.Account> accounts, bool displayAliases)
        {
                int GetAccountListTimeOut = m_ConfigSection.GetAccountListTimeOut;
                using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountList", GetAccountListTimeOut))            {
                // Get the session context from the WCF ambient service security context
                CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;
                if (clientIdentity == null)
                {
                    accounts.TotalRows = 0;
                    return;
                }

                YAAC.IMTAccountCatalog accountCatalog = InitAccountCatalog(clientIdentity);
                //add default filters
                RS.IMTDataFilter filter = new RS.MTDataFilter();
                //Set up columns for return...we actually just need the account id column
                YAAC.IMTCollection columns = (YAAC.IMTCollection)new Coll.MTCollectionClass();
                YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();

                // Passing a time stamp of timeZero instead of metraTimeStamp tells this method to
                // generate the query with a parameter called "RefDate".  Later within this method
                // we make sure to pass a parameter named RefDate with the value of metraTimeStamp
                //DateTime timeZero = DateTime.MinValue;
                string strSQL = GetAccountListQuery(clientIdentity,
                    metraTimeStamp,
                    accounts,
                    accountCatalog,
                    ref filter,
                    ref columns);
                //extract records              

                try
                {
                    //open connection
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        List<int> accountList = new List<int>();

                        GetAccountListInternal(accounts,
                            false,
                            order,
                            strSQL,
                            conn,
                            metraTimeStamp,
                            true,
                            delegate(IMTDataReader reader)
                            {
                                //resolve account id
                                int accountID = reader.GetInt32("_AccountID");
                                accountList.Add(accountID);
                            });

                        StringBuilder accountStringList = new StringBuilder();
                        accountList.ForEach(delegate(int id) { accountStringList.AppendFormat(accountStringList.Length == 0 ? "{0}" : ",{0}", id); });

                        if (accountList.Count == 0)
                        {
                            accounts.TotalRows = 0;
                            return;
                        }

                        // Use the same filters and columns to retrieve the accounts, but remove contact type filter
                        filter.Add("_AccountID", RS.MTOperatorType.OPERATOR_TYPE_IN, accountStringList.ToString());
                        MTFilterElement accountIdFilter = new MTFilterElement("_AccountID", MTFilterElement.OperationType.In, accountStringList.ToString());
                        accounts.Filters.Add(accountIdFilter);

                        List<BaseTypes.Account> tmpList = new List<Account>();
                        GetAccountListInternal(accounts,
                            true,
                            order,
                            strSQL,
                            conn,
                            metraTimeStamp,
                            false,
                            delegate(IMTDataReader reader)
                            {
                                string accountType = reader.GetString("AccountType");
                                int accID = reader.GetInt32("_AccountID");
                                string username = reader.GetString("username");
                                string nameSpace = reader.GetString("name_space");

                                BaseTypes.Account acc;
                                acc = tmpList.Find(p => (p._AccountID == accID) && (p.UserName == username) && (p.Name_Space == nameSpace));

                                //if not in the list, add the acct to list
                                if (acc == null)
                                {
                                    acc = BaseTypes.Account.CreateAccount(accountType);
                                    acc._AccountID = accID;
                                    acc.Name_Space = nameSpace;
                                    acc.UserName = username;

                                    tmpList.Add(acc);
                                }

                                LoadAccountDataFromReader(metraTimeStamp, acc, reader, displayAliases);
                            });

                        accounts.Items.AddRange(tmpList);
                        /*YAAC.IMTSQLRowset rs = (YAAC.IMTSQLRowset)accountCatalog.FindAccountsAsRowset(metraTimeStamp,
                                                                                                       columns,
                                                                                                       (YAAC.IMTDataFilter)filter,
                                                                                                       null,
                                                                                                       order,
                                                                                                       1001,
                                                                                                       out moreRows,
                                                                                                       null);

                        GetAccountListFromRS(ref accounts, rs, metraTimeStamp, displayAliases);*/

                    }
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error in GetAccountList", e);

                    accounts.Items.Clear();
                    throw new MASBasicException("Error in AccountService:GetAccountList(). Unable to retrieve accounts");
                }
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void GetAccountListTotalRows(DateTime metraTimeStamp, MTList<BaseTypes.Account> accounts, bool displayAliases, out int totalRows)
        {
            totalRows = -1;
            using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountListTotalRows"))
            {

                try
                {
                    // Get the session context from the WCF ambient service security context
                    CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;
                    if (clientIdentity == null)
                    {
                        accounts.TotalRows = 0;
                        return;
                    }

                    //initialize account catalog
                    YAAC.IMTAccountCatalog accountCatalog = InitAccountCatalog(clientIdentity);

                    //add default filters
                    RS.IMTDataFilter filter = new RS.MTDataFilter();
                    //Set up columns for return...we actually just need the account id column
                    YAAC.IMTCollection columns = (YAAC.IMTCollection)new Coll.MTCollectionClass();
                    YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
                    YAAC.IMTCollection reverseOrder = (YAAC.IMTCollection)new Coll.MTCollectionClass();

                    // Passing a time stamp of timeZero instead of metraTimeStamp tells this method to
                    // generate the query with a parameter called "RefDate".  Later within this method
                    // we make sure to pass a parameter named RefDate with the value of metraTimeStamp
                    //DateTime timeZero = DateTime.MinValue;
                    string strSQL = GetAccountListQuery(clientIdentity,
                                                        metraTimeStamp,
                                                        accounts,
                                                        accountCatalog,
                                                        ref filter,
                                                        ref columns);
                    //extract records

                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapter();
                        queryAdapter.Item.Init(@"queries\Account");
                        queryAdapter.Item.SetQueryTag((displayAliases)
                                                        ? "__ADVANCEDSEARCH_ALIASES_COUNT__"
                                                        : "__ADVANCEDSEARCH_COUNT__");
                        //open connection
                        using (IMTConnection conn = ConnectionManager.CreateConnection())
                        {
                            queryAdapter.Item.AddParam("%%INNER_QUERY%%", strSQL, true);

                            using (
                              IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                            {

                                // Add default filters
                                prepStmt.AddParam("p_name_space0", MTParameterType.String, "Auth");
                                prepStmt.AddParam("p_name_space1", MTParameterType.String, "rate");
                                prepStmt.AddParam("p_AccountType2", MTParameterType.String, "root");
                                prepStmt.AddParam("p_AccountStatus3", MTParameterType.String, "AR"); //ignore archived accounts

                                #region Apply Filters

                                //apply filters
                                int i = 4;
                                foreach (MTFilterElement filterElement in accounts.Filters)
                                {
                                    object val = filterElement.Value;
                                    prepStmt.AddParam(
                                      string.Format("p_{0}{1}", ResolveFilterColumnName(filterElement.PropertyName, ref val), i++),
                                      ConvertValueToParamType(filterElement.PropertyName, ref val), val);
                                }

                                if (!conn.ConnectionInfo.IsOracle)
                                {
                                    prepStmt.AddParam("RefDate", MTParameterType.DateTime, metraTimeStamp);
                                }

                                #endregion

                                using (IMTDataReader rowset = prepStmt.ExecuteReader())
                                {
                                    rowset.Read();
                                    totalRows = rowset.GetInt32(0);
                                }
                            }
                        }
                    }
                }
                catch (MASBasicException masE)
                {
                    mLogger.LogException("MAS Exception in GetAccountListTotalRows", masE);

                    throw;
                }
                catch (Exception e)
                {
                    mLogger.LogException("Error in GetAccountListTotalRows", e);

                    throw new MASBasicException("Unexpected error getting account list total rows");
                }
            }
        }


        [OperationCapability("Manage Account Hierarchies")]
        public void LoadAccountWithViews(AccountIdentifier acct, DateTime timeStamp, out BaseTypes.Account account)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("LoadAccountWithViews"))
            {
                int accountId = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

                // Get account with views.
                LoadAccountInternal(accountId, timeStamp, true, out account);
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        public void LoadView(AccountIdentifier acct, string viewType, out List<BaseTypes.View> views)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("LoadView"))
            {
                int accountId = AccountIdentifierResolver.ResolveAccountIdentifier(acct);

                views = new List<BaseTypes.View>();
                LoadViewInternal(accountId, viewType, null, views);
            }
        }

        [OperationCapability("Manage Account Hierarchies")]
        [OperationCapability("Move Account")]
        public void MoveAccounts(List<AccountIdentifier> accounts, AccountIdentifier newParent, DateTime timeStamp, DateTime moveStartDate)
        {
            #region Validate NewParent
            int parentId = -1;
            using (HighResolutionTimer timer = new HighResolutionTimer("MoveAccounts"))
            {
                try
                {
                    // First, validate newParent is a valid account
                    parentId = AccountIdentifierResolver.ResolveAccountIdentifier(newParent);

                    if (parentId != 1)
                    {
                        BaseTypes.Account parentAcct = null;

                        LoadAccountInternal(parentId, timeStamp, false, out parentAcct);
                    }
                }
                catch (COMException comE)
                {
                    mLogger.LogException("COM Exception validating parent account", comE);

                    throw new MASBasicException(comE.Message);
                }
                catch (Exception e)
                {
                    mLogger.LogException("Exception validating specified parent account", e);

                    throw new MASBasicException("Specified parent account is not valid for specified timestamp");
                }
            #endregion

                #region Validate accounts to work on
                // Next, make sure we have at least one account to move
                if (accounts.Count == 0)
                {
                    mLogger.LogError("No accounts were specified to be moved");

                    throw new MASBasicException("Must specify at least one account to move");
                }
                #endregion

                #region Get all the descendent accounts
                MetraTech.Interop.MTYAAC.IMTCollection descendents = (MetraTech.Interop.MTYAAC.IMTCollection)new MTCollectionExClass();

                YAAC.IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
                accountCatalog.Init(((YAAC.IMTSessionContext)GetSessionContext()));

                try
                {
                    foreach (AccountIdentifier movedAcct in accounts)
                    {
                        descendents.Add(AccountIdentifierResolver.ResolveAccountIdentifier(movedAcct));
                        //int movedAcctId = AccountIdentifierResolver.ResolveAccountIdentifier(movedAcct);

                        //IMTYAAC yaac = accountCatalog.GetAccount(movedAcctId, timeStamp);

                        //yaac.GetDescendents(descendents, timeStamp, MTHierarchyPathWildCard.RECURSIVE, true, System.Reflection.Missing.Value);
                    }
                }
                catch (COMException comE)
                {
                    mLogger.LogException("COM Exception getting descendent accounts", comE);

                    throw new MASBasicException(comE.Message);
                }
                catch (Exception e)
                {
                    mLogger.LogException("Failed to get account descendents", e);

                    throw new MASBasicException("Error retrieving the descendents of the accounts being moved");
                }
                #endregion

                #region Move Accounts
                try
                {
                    MTYAAC actorYAAC = accountCatalog.GetAccount(GetSessionContext().AccountID, MetraTime.Now);

                    IMTAncestorMgr ancestorMgr = new MTAncestorMgrClass();
                    ancestorMgr.Initialize(((YAAC.IMTSessionContext)GetSessionContext()), actorYAAC);

                    if (descendents.Count > 1)
                    {
                        ancestorMgr.MoveAccountBatch(parentId, descendents, null, moveStartDate);
                    }
                    else
                    {
                        ancestorMgr.MoveAccount(parentId, (int)descendents[1], moveStartDate);
                    }
                }
                catch (COMException comE)
                {
                    mLogger.LogException("COM Exception getting moving accounts", comE);

                    throw new MASBasicException(comE.Message);
                }
                catch (Exception e)
                {
                    mLogger.LogException("Failed to move accounts", e);

                    throw new MASBasicException("Error moving accounts");
                }
            }
                #endregion
        }

        /// <summary>
        /// Add a new account without using workflows
        /// </summary>
        /// <param name="account"></param>
        [OperationCapability("Manage Account Hierarchies")]
        public void AddAccountWithoutWorkflow(ref BaseTypes.Account account)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("AddAccountWithoutWorkflow"))
            {
                try
                {
                    AccountValidator accountValidator = new AccountValidator();
                    List<string> validationErrors;

                    // Validate the account
                    if (!accountValidator.Validate(account, out validationErrors))
                    {
                        mLogger.LogError("Failed to validate account with the following errors '{0}'", validationErrors.ToArray());

                        MASBasicException masE = new MASBasicException("Account failed validation");

                        foreach (string err in validationErrors)
                        {
                            masE.AddErrorMessage(err);
                        }

                        throw masE;
                    }

                    MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = null;
                    if (ServiceSecurityContext.Current != null)
                    {
                        // Get identity context.
                        CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;

                        if (clientIdentity != null)
                        {
                            sessionContext = clientIdentity.SessionContext;
                        }
                    }

                    try
                    {
                        string hierarchyPath = "";
                        string currency = "";
                        int ancestorId = 0;
                        int corporateAccountId = 0;
                        string ancestorType = "";

                        if (profileIdGenerator == null)
                        {
                            profileIdGenerator = new IdGenerator("id_profile", 200);
                        }
                        if (accountIdGenerator == null)
                        {
                            accountIdGenerator = new IdGenerator("id_acc", 200);
                        }

                        // Create the account 
                        AccountHelper.CreateAccount(account, sessionContext,
                            ref hierarchyPath, ref currency, ref ancestorId,
                            ref corporateAccountId, ref ancestorType,
                            profileIdGenerator, accountIdGenerator);

                        // Add views in account
                        AccountHelper.UpdateAllAccountViews(true, account);
                    }
                    catch (MASBasicException masE)
                    {
                        mLogger.LogException("MASBasicException creating account", masE);

                        throw masE;
                    }
                    catch (Exception ex)
                    {
                        mLogger.LogException("Create account failed", ex);

                        MASBasicException masE = new MASBasicException("Create account failed");
                        // Do not want error message (reason) being sent back to UI, just log it.
                        //masE.AddErrorMessage(ex.Message);

                        throw masE;
                    }


                }
                catch (MASBasicException masBasEx)
                {
                    mLogger.LogException("Create Account activity failed.", masBasEx);
                    throw;
                }
                catch (COMException comEx)
                {
                    mLogger.LogException("COM Exception occurred : ", comEx);
                    throw new MASBasicException(comEx.Message);
                }
                catch (Exception ex)
                {
                    mLogger.LogException("Exception occurred while executing Create Account  activity  activity. ", ex);
                    throw new MASBasicException("Exception occurred while executing Create Account  activity  activity.");
                }
            }
        }

        /// <summary>
        /// Retrieves a name of account type for AllTypes account template.
        /// </summary>
        /// <param name="typeName">A name of all types account type if indicated and null otherwise.</param>
        public void GetAllAccountsTypeName(ref string typeName)
        {
            try
            {
                typeName = AccountTemplateService.Config.AllTypesAccountTypeName;
            }
            catch (Exception e)
            {
                mLogger.LogException("Exception getting account template configuration", e);

                throw new MASBasicException("Unknown error getting account template configuration");
            }
        }

        // Retrieves an account's type name and the value indicating if this account has a LogOn capability.
        public void GetAccountTypeName(long accountId, ref string typeName, ref bool hasLogonCapability)
        {
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\AccHierarchies", "__GET_ACCOUNT_TYPE_NAME__"))
                    {
                        stmt.AddParam("%%ID_ACC%%", accountId);
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                typeName = reader.GetString("AccountTypeName");
                                hasLogonCapability = reader.GetInt32("HasLogonCapability") > 0;
                            }
                            else
                            {
                                // Account not found or permission denied
                                throw new MASBasicException(ErrorCodes.ACCOUNT_NOT_FOUND);
                            }
                        }
                    }
                }
            }
            catch (MASBasicException e)
            {
                // Skip logging if account not found.
                if (e.ErrorCode != ErrorCodes.ACCOUNT_NOT_FOUND)
                {
                    mLogger.LogException("Exception getting account type name", e);
                }

                throw;
            }
            catch (Exception e)
            {
                mLogger.LogException("Exception getting account type name", e);

                throw new MASBasicException("Unknown error getting account type name");
            }
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// Initializes the Account catalog instance with an indicated identity.
        /// </summary>
        /// <param name="clientIdentity">The identity to init the Account catalog with.</param>
        /// <returns>An instance of <see cref="YAAC.IMTAccountCatalog"/></returns>
        private static YAAC.IMTAccountCatalog InitAccountCatalog(CMASClientIdentity clientIdentity)
        {
            YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalog();

            YAAC.IMTSessionContext sessionContext = (YAAC.IMTSessionContext)clientIdentity.SessionContext;

            //initialize account catalog
            accountCatalog.Init((YAAC.IMTSessionContext)sessionContext);
            return accountCatalog;
        }

        /// <summary>
        /// Retrieves the list of account IDs with the specified filters and sorting.
        /// </summary>
        /// <param name="accounts">Filters.</param>
        /// <param name="displayAliases">Indicates which query to use as a base one. If true - "__ADVANCEDSEARCH_ALIASES__", else - "__ADVANCEDSEARCH__"</param>
        /// <param name="order">Sorting order.</param>
        /// <param name="strSQL">Base SQL query.</param>
        /// <param name="conn">The connection object to be used.</param>
        /// <param name="applyPagination">The value indocating if the pagination is required.</param>
        /// <param name="readMethod">Determines the method taking account data from the IMTDataReader object.</param>
        private void GetAccountListInternal(
            MTList<BaseTypes.Account> accounts,
            bool displayAliases,
            YAAC.IMTCollection order,
            string strSQL,
            IMTConnection conn,
            DateTime metraTimeStamp,
            bool applyPagination,
            ReadAccountData readMethod)
        {
            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
                queryAdapter.Item = new MTQueryAdapter();
                queryAdapter.Item.Init(@"queries\Account");

                // We load a query based on whether an accountID filter was passed in or not
                if (null == ((accounts.Filters.Find(f => ((MTFilterElement)f).PropertyName.ToUpper().CompareTo("_ACCOUNTID") == 0))))
                {
                    queryAdapter.Item.SetQueryTag((displayAliases) ? "__ADVANCEDSEARCH_ALIASES__" : "__ADVANCEDSEARCH__");
                }
                else
                {
                    if (null == (accounts.Filters.Find(p => ((MTFilterElement)p).Operation == MTFilterElement.OperationType.In)))
                    {
                        queryAdapter.Item.SetQueryTag((displayAliases) ? "__ADVANCEDSEARCH_ALIASES__" : "__ADVANCEDSEARCH__");
                    }
                    else
                    {
                        queryAdapter.Item.SetQueryTag((displayAliases) ?
                            "__ADVANCEDSEARCH_ALIASES_WITH_ACCOUNTIDLIST__" : "__ADVANCEDSEARCH_WITH_ACCOUNTIDLIST__");
                    }
                }
                queryAdapter.Item.AddParam("%%INNER_QUERY%%", strSQL, true);

                // Build a comma separated list of account ID bind variables to feed into the
                // %%ACCOUNTIDLIST%% bind variable
                StringBuilder commaSeparatedIdList = new StringBuilder();
                foreach (MTFilterElement filterElement in
                        accounts.Filters.Where(p => ((MTFilterElement)p).Operation == MTFilterElement.OperationType.In))
                {
                    FilterElement fe = new FilterElement(
                        filterElement.PropertyName.ToUpper(),
                        (FilterElement.OperationType)((int)filterElement.Operation),
                        filterElement.Value);

                    if ((fe.PropertyName.ToUpper().CompareTo("_ACCOUNTID") == 0))
                    {
                        List<string> accountIDList = new List<string>();
                        accountIDList = fe.Value.ToString().Split(new char[] { ',' }).ToList();
                        int accountIdParam = 4;
                        foreach (string str in accountIDList)
                        {
                            commaSeparatedIdList.Append(String.Format("@p_AccountId{0}", accountIdParam));
                            commaSeparatedIdList.Append(",");
                            ++accountIdParam;
                        }
                        // Remove trailing ','
                        commaSeparatedIdList.Remove(commaSeparatedIdList.Length - 1, 1);
                    }
                }

                queryAdapter.Item.AddParamIfFound("%%ACCOUNTIDLIST%%", commaSeparatedIdList.ToString(), true);

                StringBuilder sortColumns = new StringBuilder(2048);
                #region Sort Criteria
                if (accounts.SortCriteria.Count > 0 && !displayAliases)
                {
                    foreach (MetraTech.ActivityServices.Common.SortCriteria sc in accounts.SortCriteria)
                    {
                        object sortOrder = null;
                        string columnName = ResolveFilterColumnName(sc.SortProperty, ref sortOrder);

                        // Skip columns always present in the query
                        if (string.Compare("_AccountID", columnName, true) != 0 &&
                            string.Compare("name_space", columnName, true) != 0 &&
                            string.Compare("username", columnName, true) != 0)
                        {
                            if (conn.ConnectionInfo.IsOracle)
                            {
                                columnName = string.Format("\"{0}\"", columnName.ToUpper());
                            }

                            sortColumns.AppendFormat(", {0}", columnName);
                        }
                    }
                }
                #endregion

                // CORE-6372 Needless actions icons for accounts in Actions column in Advanced Find and in Actions column in Account Hierarchy panel on Finder tab.
                // Adding service data columns.
                if (displayAliases)
                {
                    queryAdapter.Item.AddParamIfFound("%%ALLTYPESACCOUNTTYPENAME%%", AccountTemplateService.Config.AllTypesAccountTypeName, true);
                }

                queryAdapter.Item.AddParam("%%SORT_COLUMN%%", sortColumns.ToString(), true);

                using (IMTPreparedFilterSortStatement countStmt = conn.CreatePreparedFilterSortStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                {
                    // Can't use the base class version because of how parameters are named
                    //base.ApplyFilterSortCriteria<BaseTypes.Account>(countStmt, accounts, new FilterColumnResolver(ResolveFilterColumnName), null);

                    #region Apply Sorting
                    //add sorting info if applies
                    if (accounts.SortCriteria != null && accounts.SortCriteria.Count > 0)
                    {
                        foreach (MetraTech.ActivityServices.Common.SortCriteria sc in accounts.SortCriteria)
                        {
                            object dummy = null;
                            string sortColumn = sc.SortProperty;

                            sortColumn = ResolveFilterColumnName(sc.SortProperty, ref dummy);

                            string sortDirection = (sc.SortDirection == SortType.Descending) ? " DESC" : "";
                            order.Add(sortColumn + sortDirection);

                            if (conn.ConnectionInfo.IsOracle)
                            {
                                sortColumn = string.Format("\"{0}\"", sortColumn.ToUpper());
                            }

                            countStmt.SortCriteria.Add(
                                new MetraTech.DataAccess.SortCriteria(
                                    sortColumn,
                                    ((sc.SortDirection == SortType.Ascending) ? SortDirection.Ascending : SortDirection.Descending)));

                        }
                    }
                    else
                    {
                        string sortColumn = "_AccountID";

                        if (conn.ConnectionInfo.IsOracle)
                        {
                            sortColumn = string.Format("\"{0}\"", sortColumn.ToUpper());
                        }

                        countStmt.SortCriteria.Add(new DataAccess.SortCriteria(sortColumn, SortDirection.Ascending));
                    }

                    #endregion

                    // Add default filters
                    countStmt.AddParam("p_name_space0", MTParameterType.String, "AUTH");
                    countStmt.AddParam("p_name_space1", MTParameterType.String, "RATE");
                    countStmt.AddParam("p_AccountType2", MTParameterType.String, "ROOT");
                    countStmt.AddParam("p_AccountStatus3", MTParameterType.String, "AR"); //ignore archived accounts

                    #region Apply Filters
                    //apply filters as parameters
                    int i = 4;
                    foreach (MTFilterElement filterElement in
                        accounts.Filters.Where(p => ((MTFilterElement)p).Operation != MTFilterElement.OperationType.In))
                    {
                        object val = filterElement.Value;

                        if (conn.ConnectionInfo.IsOracle && val is string)
                        {
                            val = ((string)val).ToUpper();
                        }

                        countStmt.AddParam(
                            string.Format("p_{0}{1}",
                                ResolveFilterColumnName(filterElement.PropertyName, ref val),
                                i++),
                            ConvertValueToParamType(filterElement.PropertyName, ref val),
                            val);
                    }
                    if (!conn.ConnectionInfo.IsOracle)
                    {
                        countStmt.AddParam("RefDate", MTParameterType.DateTime, metraTimeStamp);
                    }

                    // apply IN condition filters
                    foreach (MTFilterElement filterElement in
                        accounts.Filters.Where(p => ((MTFilterElement)p).Operation == MTFilterElement.OperationType.In))
                    {
                        FilterElement fe =
                            new FilterElement(filterElement.PropertyName.ToUpper(), (FilterElement.OperationType)((int)filterElement.Operation), filterElement.Value);
                        // _accountID filter needs to be wrapped as a bind variable parameter                         
                        if ((fe.PropertyName.ToUpper().CompareTo("_ACCOUNTID") != 0))
                            countStmt.AddFilter(fe);
                        else
                        {
                            List<string> accountIDList = new List<string>();
                            accountIDList = fe.Value.ToString().Split(new char[] { ',' }).ToList();
                            int id = 4;
                            object val = fe.Value;

                            foreach (string str in accountIDList)
                            {
                                object strAsObject = str;
                                countStmt.AddParam(String.Format("p_ACCOUNTID{0}", id),
                                   ConvertValueToParamType(fe.PropertyName, ref strAsObject),
                                   strAsObject);
                                ++id;
                            }
                        }
                    }


                    #endregion

                    #region Apply Pagination
                    //set paging info
                    countStmt.CurrentPage = applyPagination ? accounts.CurrentPage : 0;
                    countStmt.PageSize = applyPagination ? accounts.PageSize : 0;
                    #endregion

                    countStmt.MaxTotalRows = accounts.PageSize * m_ConfigSection.GetAccountListMaxPages;

                    // at this point ready to execute query
                    using (IMTDataReader dataReader = countStmt.ExecuteReader())
                    {
                        #region Place Results into Placeholder
                        //multiple views may result in multiple rows returned for the same accID, so need to ensure uniquity
                        while (dataReader.Read())
                        {
                            readMethod(dataReader);
                        }
                        #endregion
                    }

                    /* CORE-7103:"Pagination in Advanced Find grid doesn't work properly"
                     * Count Total rows only for the 1-st internall call. Other times TotalRows returns count of single page anly
                     */
                    if (applyPagination)
                      //finally, set the total number of records returned
                      accounts.TotalRows = countStmt.TotalRows;
                }
            }

            //return accountList;
        }

        /// <summary>
        /// Adds a string to list if it is not there already
        /// </summary>
        /// <param name="stringToInsert">string to insert into list</param>
        /// <param name="stringList">List containing the strings</param>
        private void AddStringToList(string stringToInsert, List<string> stringList)
        {
            if (stringList == null)
            {
                return;
            }

            if (String.IsNullOrEmpty(stringToInsert))
            {
                return;
            }

            //don't add the trailing underscore properties
            if (stringToInsert.LastIndexOf('_') == stringToInsert.Length - 1)
            {
                return;
            }

            //special cases
            if (stringToInsert.ToUpper() == "APPLYDEFAULTSECURITYPOLICY")
            {
                return;
            }

            if (stringList.Contains(stringToInsert.ToUpper()))
            {
                return;
            }

            stringList.Add(stringToInsert.ToUpper());
        }

        /*
         * If the column name contains the prefix for the additional view,
         * strip out the prefix.
         * 
         * Also, resolve values from real booleans into Y or N
         * Returns null if invalid propName was sent in
         */
        private string ResolveFilterColumnName(string propName, ref object propValue, object helper = null)
        {
            //HasChildren stores booleans as Y or N...need to be converted to that from real boolean

            string propNameLeaf = GetLeafObject(propName);
            string propNameCaseInsensitive = propNameLeaf.ToLower();
            // ESR-3873 
            IMTPropertyMetaData metaData = mAccountMetaData[propNameLeaf];

            if (propNameCaseInsensitive == "haschildren")
            {
                if (propValue != null)
                {
                    bool val = (bool)propValue;
                    propValue = (val) ? "Y" : "N";
                }
            }
            else
                // ESR-3873 check datatype if defined as boolean return 1 or 0
                if (metaData.dataType == MetraTech.Interop.MTYAAC.PropValType.PROP_TYPE_BOOLEAN)
                {
                    if (propValue != null)
                    {
                        //ESR-5005 CLONE - MetraView- Booleans in search need to be pull-down list
                        if ((propValue.ToString() != "1") && (propValue.ToString() != "0"))
                        {
                            bool val = Boolean.Parse(propValue.ToString());
                            propValue = (val) ? 1 : 0;
                        }
                    }
                }

            return propNameLeaf;
        }

        /// <summary>
        /// Returns the leaf object in the structure.  So, for input MyObject.MyLeafObject, it will return MyLeafObject
        /// </summary>
        /// <param name="propName"></param>
        /// <returns></returns>
        private string GetLeafObject(string propName)
        {
            //if no '.' found, return without any modifications
            if (propName.IndexOf('.') < 0)
            {
                //attempt to find /
                if (propName.LastIndexOf("/") <= 0)
                {
                    //attempt to find #
                    if (propName.LastIndexOf("#") <= 0)
                    {
                        return propName;
                    }

                    return propName.Substring(propName.LastIndexOf("#") + 1);
                }

                //return everything after /
                return propName.Substring(propName.LastIndexOf("/") + 1);
            }

            //split around the '.'
            string[] arrParts = propName.Split('.');

            if (arrParts.Length < 2)
            {
                return null;
            }

            //return the property name, which is the last item in the split array
            return arrParts[arrParts.Length - 1];
        }

        private static bool IsMTProperty(PropertyInfo pi)
        {
            MTDataMemberAttribute attribute = null;
            if (GetMTDataMemberAttribute(pi, out attribute))
                return true;

            return false;
        }

        protected static List<Type> GetAccountTypeList()
        {
            List<Type> listTypes = new List<Type>();
            Type[] arrTypes = BaseTypes.Account.GetKnownTypes(typeof(MTAccountAttribute));
            string accTypeNameLower;
            string allTypes = (AccountTemplateService.Config.AllTypesAccountTypeName ?? "alltypes").ToLower();

            for (int i = 0; i < arrTypes.Length; i++)
            {
                accTypeNameLower = arrTypes[i].Name.ToLower();
                if ((accTypeNameLower != "root")
                    && (accTypeNameLower != "systemaccount")
                    && (accTypeNameLower != allTypes))
                {
                    listTypes.Add(arrTypes[i]);
                }
            }

            return listTypes;
        }

        [Obsolete("Use GetAccountListInternal method instead.", true)]
        protected void GetAccountListFromRS(ref MTList<BaseTypes.Account> accounts,
                                            YAAC.IMTSQLRowset rs,
                                            DateTime metraTimeStamp, bool displayAliases)
        {
            if (Convert.ToBoolean(rs.EOF) == true)
            {
                return;
            }

            List<BaseTypes.Account> tempAccountList = new List<BaseTypes.Account>();
            CreateShallowAccounts(tempAccountList, rs, displayAliases);

            foreach (BaseTypes.Account curAccount in tempAccountList)
            {
                LoadAccountDataFromRS(curAccount._AccountID.Value, metraTimeStamp, curAccount, rs, displayAliases);

                accounts.Items.Add(curAccount);
            }
        }

        /// <summary>
        /// Strips the object prefix if any.
        /// </summary>
        /// <param name="propName"></param>
        /// <returns></returns>
        protected string GetRawPropertyName(string propName)
        {
            int lastDot = propName.LastIndexOf(".");

            if (lastDot < 0)
            {
                return propName;
            }

            return propName.Substring(lastDot + 1);
        }

        protected bool IsFilterInList(MTList<BaseTypes.Account> accountList, string filterName)
        {
            foreach (MTFilterElement fe in accountList.Filters)
            {
                if (GetRawPropertyName(fe.PropertyName).ToLower() == filterName.ToLower())
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Places the recordset cursor to the record that has specific account ID.
        /// If no such record is found, recordset will be at EOF
        /// </summary>
        /// <param name="rs"></param>
        /// <param name="accountId"></param>
        protected void RepositionRowsetToAccountID(YAAC.IMTSQLRowset rs, int accountId)
        {
            if (rs.RecordCount == 0)
            {
                return;
            }

            rs.MoveFirst();

            while (!Convert.ToBoolean(rs.EOF))
            {
                if ((int)rs.get_Value("_AccountID") == accountId)
                {
                    return;
                }

                rs.MoveNext();
            }
        }

        protected void RepositionRowsetToAccountID(YAAC.IMTSQLRowset rs, int accountId, string userName, string nameSpace, bool displayAliases)
        {
            //if not displaying aliases, reposition is done based only on accID
            if (!displayAliases)
            {
                RepositionRowsetToAccountID(rs, accountId);
                return;
            }

            if (rs.RecordCount == 0)
            {
                return;
            }

            rs.MoveFirst();

            while (!Convert.ToBoolean(rs.EOF))
            {
                if (((int)rs.get_Value("_AccountID") == accountId)
                  && ((string)rs.get_Value("username") == userName)
                  && ((string)rs.get_Value("name_space") == nameSpace)
                  )
                {
                    return;
                }

                rs.MoveNext();
            }
        }

        private void LoadViewInternalFromRS(int accountId, string userName, string nameSpace, string viewType, YAAC.IMTSQLRowset rs, IList views, bool displayAliases)
        {
            // Populate the passed in list of views.
            try
            {
                // Create view for specified type.
                BaseTypes.View view = BaseTypes.View.CreateView(viewType);

                // Use passed in rowset if not null.
                bool filterOnKeys = true; //xxx false;


                // The rowset provided by account finder may have an outer left join on all
                // account views and will result in more rows then there are views.
                // Therefore we need to filter some of the rows out.
                // Account finder will return an empty row even if there is no data for
                // the account extension.
                filterOnKeys = true;

                // Loop through rows in rowset.
                //////rs.MoveFirst();
                //RepositionRowsetToAccountID(rs, accountId);
                RepositionRowsetToAccountID(rs, accountId, userName, nameSpace, displayAliases);

                Hashtable processedViews = new Hashtable();
                while (System.Convert.ToBoolean(rs.EOF) == false)
                {
                    //continue if the record does not have the accountID that was passed in
                    if ((int)rs.get_Value("_AccountID") != accountId)
                    {
                        rs.MoveNext();
                        continue;
                    }

                    // Create a new view if necessary.
                    if (view == null)
                        view = BaseTypes.View.CreateView(viewType);

                    // Create a hash string of all key property values for current view.
                    string keyPropertyValues = String.Empty;

                    // If there are any key properties then we may have more than one view.
                    // If there are no key properties then THERE CAN BE ONLY ONE view.
                    // If all key properties are null then the record may be skipped.
                    // If there is only one view and all the property values are null
                    // then skip the record.
                    bool foundKeyProperties = false;
                    bool anyPropertyValues = false;

                    // Set data in row to view.
                    foreach (PropertyInfo pi in view.GetMTProperties())
                    {
                        // Set value to view.
                        object value = null;
                        SetValue(view, pi, rs, out value);

                        // Append value to key string, if it is part of key.
                        if (filterOnKeys)
                        {
                            // Is the value null?
                            bool NullValue = (value is System.DBNull) ? true : false;
                            if (!NullValue)
                                anyPropertyValues = true;

                            if (IsPartOfKey(pi))
                            {
                                foundKeyProperties = true;

                                if (!NullValue)
                                    keyPropertyValues += value.ToString() + "|";
                            }
                        }
                    }

                    // Should we skip the view record?
                    if (filterOnKeys)
                    {
                        if (
                            // No key properties found, cannot have all null properties.
                            (!anyPropertyValues &&
                             !foundKeyProperties) ||

                            // Missing all key properties.
                            (foundKeyProperties &&
                             keyPropertyValues == String.Empty) ||

                            // Check for duplicate record using key values.
                            processedViews[keyPropertyValues] != null
                          )
                        {
                            view = null;
                            rs.MoveNext();
                            continue;
                        }

                        // Cache the key values.
                        processedViews[keyPropertyValues] = true;
                    }

                    /*****
                     * All view objects are created with the dirty bit set on each parameter.
                     * Update of each parameter also sets the dirty bit on.
                     * Since we're loading a view object, it is not really changed. Therefore,
                     * we need to reset the dirty flag.
                     *****/
                    //view.ResetDirtyFlag();

                    // Add view to list.
                    views.Add(view);

                    // Get the next row.
                    view = null;
                    rs.MoveNext();
                }
            }
            catch (Exception ex)
            {
                mLogger.LogException("Exception loading view internal from RS", ex);

                throw new MASBasicException(ex.Message);
            }
        }

        [Obsolete("Use LoadAccountDataFromReader method instead.", true)]
        protected void LoadAccountDataFromRS(int accountId, DateTime timeStamp, BaseTypes.Account acc, YAAC.IMTSQLRowset rs, bool displayAliases)
        {
            bool allViews = true;

            //RepositionRowsetToAccountID(rs, accountId);
            RepositionRowsetToAccountID(rs, accountId, acc.UserName, acc.Name_Space, displayAliases);

            if (Convert.ToBoolean(rs.EOF))
            {
                return;
            }

            // Set data to Account object based on returned rowset.
            string viewType = String.Empty;
            string className = String.Empty;
            foreach (PropertyInfo pi in acc.GetMTProperties())
            {
                // Check if this is a view.
                if (IsView(pi, out viewType, out className))
                {
                    // Do we need to process views at this time?
                    if (allViews == false)
                        continue;

                    // Load the view.
                    Assembly ass = acc.GetType().Assembly;
                    object views = CreateGenericObject(typeof(List<>), ass.GetType(acc.GetType().Namespace + "." + className), null);
                    IList viewList = (IList)views;

                    // LoadViewInternal throws an exception on failure, so assume success
                    LoadViewInternalFromRS(accountId, acc.UserName, acc.Name_Space, viewType, rs, viewList, displayAliases);

                    // Load view may have positioned our rowset cursor at the end, we need to reset
                    // to make sure we pick up any remaining account properties.
                    //////////rs.MoveFirst();
                    RepositionRowsetToAccountID(rs, accountId, acc.UserName, acc.Name_Space, displayAliases);

                    // Is the view property a list of views?
                    bool isList = (pi.PropertyType == views.GetType()) ? true : false;
                    if (((IList)views).Count > 0)
                    {
                        if (isList)
                            pi.SetValue(acc, views, null);
                        else
                        {
                            // Set only the first item from the list.
                            pi.SetValue(acc, ((IList)views)[0], null);
                        }
                    }
                }
                else
                {
                    // Set value for other properties.
                    object value;
                    SetValue(acc, pi, rs, out value);
                }
            }

            /*****
             * Account objects are created with the dirty bit set on each parameter.
             * Update of each parameter also sets the dirty bit on.
             * Since we're loading the account object, it is not really changed. Therefore,
             * we need to reset the dirty flag.
             *****/
            //acc.ResetDirtyFlag();
        }

        private void SetValue(DomainModel.BaseTypes.BaseObject obj, PropertyInfo pi, IMTDataReader reader, out object value)
        {
            // Set return value.
            value = null;

            // Check if this is a input only property.
            MTDataMemberAttribute attribute = null;
            if (GetMTDataMemberAttribute(pi, out attribute))
            {
                if (attribute.IsInputOnly)
                    return;  // Skip value.
            }

            // Get value from rowset.
            try
            {
                value = reader.GetValue(pi.Name);
                if (EnumHelper.IsEnumType(pi.PropertyType) && !(value is DBNull))
                {
                  value = ConverToEnum(pi, value);
                }
                else if (!(value is DBNull) && (pi.PropertyType == typeof(int) || pi.PropertyType == typeof(int?)))
                {
                    // Oracle returns some numeric values as Int64 that causes type mismatch when assigning to Int32 properties
                    value = Convert.ToInt32(value);
                }
            }
            catch (Exception ex)
            {
                mLogger.LogError(String.Format("Couldn't find account property [{0}] in rowset; skipping it. {1}", pi.Name, ex.Message));
                return;
            }

            obj.SetValue(pi, value);
        }

        private static object ConverToEnum(PropertyInfo pi, object value)
        {
          string strValue = value as string;
          if (strValue != null)
          {
            // Converting from enum value
            Type propertyType;
            if (pi.PropertyType.IsGenericType && pi.PropertyType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
            {
              System.ComponentModel.NullableConverter nullableConverter = new System.ComponentModel.NullableConverter(pi.PropertyType);
              propertyType = nullableConverter.UnderlyingType;
            }
            else
            {
              propertyType = pi.PropertyType;
            }

            value = EnumHelper.GetEnumByValue(propertyType, Convert.ToString(value));
          }
          else
          {
            /*CORE-6663 - "SQL Server: account hierarchy is failed in case Department Account have Billing Cycle with StartDate property." */
            // Enums come either as global enum IDs or as enum indexes.
            Type enumType = pi.PropertyType.IsEnum ? pi.PropertyType : new System.ComponentModel.NullableConverter(pi.PropertyType).UnderlyingType;
            // Converting from enum value ID
            int enumId = Convert.ToInt32(value);
            value = EnumHelper.GetCSharpEnum(enumId);
            // Detect if value came as enum index.
            if (value == null || value.GetType() != enumType)
            {
              //it was not enum global enum index (id was not found in t_enum_data table) use value as is
              value = enumId;
            }
          }
          return value;
        }

        private void LoadViewInternalFromReader(int accountId, string userName, string nameSpace, string viewType, IMTDataReader reader, IList views, bool displayAliases)
        {
            // Populate the passed in list of views.
            try
            {
                // Create view for specified type.
                BaseTypes.View view = BaseTypes.View.CreateView(viewType);

                // Create a new view if necessary.
                if (view == null)
                    view = BaseTypes.View.CreateView(viewType);

                // Create a hash string of all key property values for current view.
                bool hasNoKey = true;
                bool nullKey = true;

                // Set data in row to view.
                foreach (PropertyInfo pi in view.GetMTProperties())
                {
                    // Set value to view.
                    object value;
                    SetValue(view, pi, reader, out value);

                    // Check if key value exists
                    MTDataMemberAttribute attribute;
                    if ((hasNoKey || nullKey) && GetMTDataMemberAttribute(pi, out attribute) && attribute.IsPartOfKey)
                    {
                        hasNoKey = false;
                        nullKey = (value == null) || (value is DBNull) || string.Empty.Equals(value);
                    }
                }

                if ((hasNoKey || !nullKey) && !views.Contains(view))
                {
                    /*****
                        * All view objects are created with the dirty bit set on each parameter.
                        * Update of each parameter also sets the dirty bit on.
                        * Since we're loading a view object, it is not really changed. Therefore,
                        * we need to reset the dirty flag.
                        *****/
                    view.ResetDirtyFlag();

                    // Add view to list.
                    views.Add(view);
                }
            }
            catch (Exception ex)
            {
                mLogger.LogException("Exception loading view internal from DataReader", ex);

                throw new MASBasicException(ex.Message);
            }
        }

        private void LoadPropertyFromReader(BaseTypes.Account acc, string propertyName, IMTDataReader reader)
        {
            PropertyInfo pi = acc.GetType().GetProperty(propertyName);
            object value;

            SetValue(acc, pi, reader, out value);
        }

        private void LoadAccountDataFromReader(DateTime timeStamp, BaseTypes.Account acc, IMTDataReader reader, bool displayAliases)
        {
            bool allViews = true;

            int accountId = reader.GetInt32("_AccountID");

            // Set data to Account object based on returned rowset.
            string viewType = String.Empty;
            string className = String.Empty;
            foreach (PropertyInfo pi in acc.GetMTProperties())
            {
                // Check if this is a view.
                if (IsView(pi, out viewType, out className))
                {
                    // Do we need to process views at this time?
                    if (allViews == false)
                        continue;

                    // Load the view.
                    Assembly ass = acc.GetType().Assembly;
                    object views = CreateGenericObject(typeof(List<>), ass.GetType(acc.GetType().Namespace + "." + className), null);
                    IList viewList = (IList)views;

                    // LoadViewInternal throws an exception on failure, so assume success
                    LoadViewInternalFromReader(accountId, acc.UserName, acc.Name_Space, viewType, reader, viewList, displayAliases);

                    // Is the view property a list of views?
                    bool isList = (pi.PropertyType == views.GetType()) ? true : false;
                    if (((IList)views).Count > 0)
                    {
                        if (isList)
                            pi.SetValue(acc, views, null);
                        else
                        {
                            // Set only the first item from the list.
                            pi.SetValue(acc, ((IList)views)[0], null);
                        }
                    }
                }
                else
                {
                    // Set value for other properties.
                    object value;
                    SetValue(acc, pi, reader, out value);
                }
            }

            // Load service properties
            LoadPropertyFromReader(acc, "HasLogonCapability", reader);
            LoadPropertyFromReader(acc, "CanHaveChildren", reader);

            /*****
             * Account objects are created with the dirty bit set on each parameter.
             * Update of each parameter also sets the dirty bit on.
             * Since we're loading the account object, it is not really changed. Therefore,
             * we need to reset the dirty flag.
             *****/
            acc.ResetDirtyFlag();
        }

        /// <summary>
        /// Creates a list of accounts
        /// </summary>
        /// <param name="accountList"></param>
        /// <param name="rs"></param>
        protected void CreateShallowAccounts(List<BaseTypes.Account> accountList, YAAC.IMTSQLRowset rs, bool displayAliases)
        {
            rs.MoveFirst();

            //create shallow accounts
            while (!Convert.ToBoolean(rs.EOF))
            {
                string accountType = (string)rs.get_Value("AccountType");
                int accID = (int)rs.get_Value("_AccountID");
                string username = (string)rs.get_Value("username");
                string nameSpace = (string)rs.get_Value("name_space");
                bool bIsInList = false;

                //check if account is in the list
                if (displayAliases)
                {
                    bIsInList = IsAccountInList(accountList, accID, username, nameSpace);
                }
                else
                {
                    bIsInList = IsAccountInList(accountList, accID);
                }

                //if not in the list, add the acct to list
                if (!bIsInList)
                {
                    BaseTypes.Account acc = BaseTypes.Account.CreateAccount(accountType);
                    acc._AccountID = accID;
                    acc.Name_Space = nameSpace;
                    acc.UserName = username;

                    accountList.Add(acc);
                }
                rs.MoveNext();
            }
        }

        /// <summary>
        /// Returns true if the account list contains an account with ID specified by accID
        /// </summary>
        /// <param name="accountList"></param>
        /// <param name="accID"></param>
        /// <returns></returns>
        protected bool IsAccountInList(List<BaseTypes.Account> accountList, int accID)
        {
            if ((accountList == null) || (accountList.Count == 0))
            {
                return false;
            }

            foreach (BaseTypes.Account acc in accountList)
            {
                if (acc._AccountID == accID)
                {
                    return true;
                }
            }

            return false;
        }

        protected bool IsAccountInList(List<BaseTypes.Account> accountList, int accID, string userName, string nameSpace)
        {
            if ((accountList == null) || (accountList.Count == 0))
            {
                return false;
            }

            foreach (BaseTypes.Account acc in accountList)
            {
                if ((acc._AccountID == accID) && (acc.UserName == userName) && (acc.Name_Space == nameSpace))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Converts a list of integer to a comma separated list
        /// </summary>
        /// <param name="list"></param>
        /// <returns></returns>
        protected String ConvertListToString(List<Int32> list)
        {
            if (list == null)
            {
                return String.Empty;
            }

            if (list.Count == 0)
            {
                return string.Empty;
            }

            bool bFirst = true;
            StringBuilder sb = new StringBuilder();

            foreach (int curItem in list)
            {
                if (!bFirst)
                {
                    sb.Append(",");
                }
                else
                {
                    bFirst = false;
                }

                sb.Append(curItem);
            }

            return sb.ToString();
        }

        private static List<string> m_FieldNames = null;
        protected static List<string> GetListOfFieldNames()
        {
            if (m_FieldNames == null)
            {
                m_FieldNames = new List<string>();
                List<Type> accountTypes = GetAccountTypeList();
                List<PropertyInfo> fullPropList = new List<PropertyInfo>();

                //for each of the types
                foreach (Type curAccountType in accountTypes)
                {
                    ParseType(curAccountType, String.Empty, fullPropList, m_FieldNames);
                }

                //propListNames should NOT contain the path info, so need to strip it out in second pass
                for (int i = 0; i < m_FieldNames.Count; i++)
                {
                    string propName = m_FieldNames[i];
                    int indexOfLastDot = propName.LastIndexOf('.');
                    if (indexOfLastDot < 0)
                    {
                        continue;
                    }

                    m_FieldNames[i] = propName.Substring(indexOfLastDot + 1);
                }
            }

            return m_FieldNames;
        }

        protected static void ParseType(Type t, string propPath, List<PropertyInfo> fullPropList, List<string> propListNames)
        {
            object[] attributes;

            //get the property list by executing GetProperties() method on current account type
            if (propPath != "")
            {
                propPath = propPath + ".";
            }
            foreach (PropertyInfo pi in t.GetProperties())
            {
                if (pi.PropertyType.BaseType.Name.ToLower() == "view")
                {
                    ParseType(pi.PropertyType, propPath + pi.Name, fullPropList, propListNames);
                }

                //for generic types, get the actual type and feed it in
                else if ((pi.PropertyType.IsGenericType) && (pi.PropertyType.Name == "List`1"))
                {
                    Type[] internalTypes = pi.PropertyType.GetGenericArguments();
                    for (int i = 0; i < internalTypes.Length; i++)
                    {
                        ParseType(internalTypes[i], propPath + pi.Name + "[" + i + "]", fullPropList, propListNames);
                    }
                }

                else
                {
                    //skip the dirty flags by extracting only the properties with MTDataMember attributes
                    attributes = pi.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

                    if ((attributes != null) && (attributes.Length == 1))
                    {
                        if (!propListNames.Contains(propPath + pi.Name.ToLower()))
                        {
                            propListNames.Add(propPath + pi.Name.ToLower());
                            fullPropList.Add(pi);
                        }
                    }
                }
            }

        }

        private string GetAccountListQuery(CMASClientIdentity clientIdentity,
                                            DateTime metraTimeStamp,
                                            MTList<BaseTypes.Account> accounts,
                                            IMTAccountCatalog accountCatalog,
                                            ref RS.IMTDataFilter filter,
                                            ref YAAC.IMTCollection columns)
        {
            #region Prepare SQL Query
            // ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode, (i.e ADO.NET record sets) set to true (append in the "N"), ELSE false
            // (ADO disconnected record sets DO NOT support unicode)
            // reversing work around from 6/28/2010, setting EscapeString to true does NOT break advanced find or smokes, allows searching on unicode characters
            filter.EscapeString = true;

            //do not return any rows where namespace = Auth            
            filter.Add("name_space", RS.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL, "Auth");
            filter.Add("name_space", RS.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL, "rate");
            filter.Add("AccountType", RS.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL, "root");
            filter.Add("AccountStatus", RS.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL, "AR"); //ignore archived accounts           

            //create a list of columns to extract; it will contain all filter and sort columns + the ID field
            List<string> columnList = new List<string>();
            AddStringToList("_AccountID", columnList);
            AddStringToList("Name_Space", columnList);

            //all the columns in the filter list need to be added to the list of columns
            // IN condition is managed separately.
            foreach (MTFilterElement filterElement in accounts.Filters.Where(p => ((MTFilterElement)p).Operation != MTFilterElement.OperationType.In))
            {
                object filterValue = filterElement.Value;
                string filterColumnName = ResolveFilterColumnName(filterElement.PropertyName, ref filterValue);

                filter.Add(filterColumnName, ((int)filterElement.Operation), filterValue);
            }

            if (accounts.SortCriteria != null && accounts.SortCriteria.Count > 0)
            {
                foreach (MetraTech.ActivityServices.Common.SortCriteria sc in accounts.SortCriteria)
                {
                    object sortOrder = null;
                    string sortColumn = ResolveFilterColumnName(sc.SortProperty, ref sortOrder);

                    AddStringToList(sortColumn, columnList);
                }
            }

            List<string> propList = GetListOfFieldNames();
            foreach (string propName in propList)
            {
                AddStringToList(propName, columnList);
            }

            //iterate through columnList, and add items to the real column collection
            foreach (string colName in columnList)
            {
                columns.Add(colName);
            }

            //generate the query
            string strSQL = accountCatalog.GenerateParameterizedAccountSearchQuery(metraTimeStamp, columns, (YAAC.IMTDataFilter)filter,
              null, null, 0);

            #endregion

            return strSQL;
        }

        private MTParameterType ConvertValueToParamType(string propertyName, ref object val)
        {
            MTParameterType retval = 0;

            string propNameLeaf = GetLeafObject(propertyName);
            IMTPropertyMetaData metaData = mAccountMetaData[propNameLeaf];

            switch (metaData.dataType)
            {
                case PropValType.PROP_TYPE_ENUM:
                    retval = MTParameterType.Integer;

                    Enum enumVal = null;

                    if (!val.GetType().IsEnum)
                    {
                        Type enumType = EnumHelper.GetGeneratedEnumType(metaData.EnumSpace, metaData.EnumType, "");

                        enumVal = (Enum)EnumHelper.GetGeneratedEnumByValue(enumType, val.ToString());

                        if (enumVal == null)
                        {
                            enumVal = (Enum)EnumHelper.GetGeneratedEnumByEntry(enumType, val.ToString());
                        }

                        if (enumVal == null)
                        {
                            throw new MASBasicException("Unable to resolve enum filter to generated enum type");
                        }
                    }
                    else
                    {
                        enumVal = (Enum)val;
                    }

                    val = EnumHelper.GetDbValueByEnum(enumVal);

                    break;
                case PropValType.PROP_TYPE_INTEGER:
                    retval = MTParameterType.Integer;
                    break;
                case PropValType.PROP_TYPE_BIGINTEGER:
                    retval = MTParameterType.BigInteger;
                    break;
                case PropValType.PROP_TYPE_ASCII_STRING:
                case PropValType.PROP_TYPE_STRING:
                case PropValType.PROP_TYPE_UNICODE_STRING:
                    retval = MTParameterType.WideString;
                    break;
                case PropValType.PROP_TYPE_DECIMAL:
                case PropValType.PROP_TYPE_DOUBLE:
                    retval = MTParameterType.Decimal;
                    break;
                case PropValType.PROP_TYPE_BOOLEAN:
                    retval = MTParameterType.Boolean;
                    break;
                case PropValType.PROP_TYPE_DATETIME:
                case PropValType.PROP_TYPE_TIME:
                    retval = MTParameterType.DateTime;
                    break;
                default:
                    throw new MASBasicException("Unknown filter data type");
            }

            return retval;
        }


        #endregion
    }

}

using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using BaseTypes = MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTAccount;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Security;
using MetraTech.DataAccess;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTAuth;
using System.Reflection;
using System.Collections;
using System.ServiceModel;
using System.Runtime.Serialization;
using System.Transactions;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.QueryAdapter;
using RS = MetraTech.Interop.Rowset;
using YAAC = MetraTech.Interop.MTYAAC;
using Auth = MetraTech.Interop.MTAuth;
//using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.ActivityServices.Services.Common;
using System.IO;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Validators;
using MetraTech.Interop.MTYAAC;
using MetraTech.Debug.Diagnostics;
using System.Configuration;
using IMTAncestorMgr = MetraTech.Interop.MTYAAC.IMTAncestorMgr;
using PropValType = MetraTech.Interop.MTYAAC.PropValType;
//using MetraTech.Core.Services;
using IMTPropertyMetaData = MetraTech.Interop.MTYAAC.IMTPropertyMetaData;
using IMTPropertyMetaDataSet = MetraTech.Interop.MTYAAC.IMTPropertyMetaDataSet;

namespace MetraTech.Core.Activities
{
 
	public class AccountHelper
	{
    private static Logger mLogger = new Logger("[AccountHelper]");
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
        private const string MT_ANCESTOR_OF_INCORRECT_TYPE_MSG = "The parent account is of incorrect type.";

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

        private const int MT_CURRENCY_MISMATCH = -486604737;  // Error Condition Returned by SQL Server
        private const string MT_CURRENCY_MISMATCH_MSG = "The currency of the account must match the currency of the ancestor account.";

        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH = -486604728;  // Error Condition Returned by Oracle
        private const string MT_PAYER_PAYEE_CURRENCY_MISMATCH_MSG = "The currency of the payer account must match the currency of the payee account.";

        private const int MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT = -486604758;
        private const string MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT_MSG = "Both the payer account and payee account must share the same corporate account.";

        private const int MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE = -289472464;
        private const string MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG = "";

        private const string MT_ACCOUNT_PRICELIST_INVALID = "The price list is invalid.";


    public static UsageCycleData GetUsageCycleData(Account account)
    {
      UsageCycleData usageCycleData = new UsageCycleData();
      InternalView internalView = account.GetInternalView() as InternalView;

      if (internalView.UsageCycleType.HasValue)
      {
        usageCycleData.DayOfMonth = account.DayOfMonth;
        if (account.DayOfWeek != null)
        {
          usageCycleData.DayOfWeek = Convert.ToInt32(EnumHelper.GetValueByEnum(account.DayOfWeek));
        }
        usageCycleData.FirstDayOfMonth = account.FirstDayOfMonth;
        usageCycleData.SecondDayOfMonth = account.SecondDayOfMonth;
        usageCycleData.StartDay = account.StartDay;
        if (account.StartMonth != null)
        {
          usageCycleData.StartMonth = Convert.ToInt32(EnumHelper.GetValueByEnum(account.StartMonth));
        }
        usageCycleData.StartYear = account.StartYear;


        switch (internalView.UsageCycleType)
        {
          case UsageCycleType.Monthly:
            {
			// We don't need to do anything special for montly
			break;
            }
          case UsageCycleType.Daily:
            {
              break;
            }
          case UsageCycleType.Weekly:
            {
              break;
            }
          case UsageCycleType.Bi_weekly:
            {
							// The database only contains data for the first two weeks of 2000. Whatever
							// StartYear, StartMonth, StartDay has been specified must be mapped to a day
							// in that interval.
							DateTime dateTime = new DateTime(usageCycleData.StartYear.Value, usageCycleData.StartMonth.Value, usageCycleData.StartDay.Value);
							DateTime y2k = new DateTime(2000, 1, 1);

							TimeSpan tsDiffBnNowAndY2K = dateTime.Subtract(y2k);
							int diffDaysBnNowAndY2K = Math.Abs(tsDiffBnNowAndY2K.Days);

              if (usageCycleData.StartDay.Value >= 14)
              {
                usageCycleData.StartDay = (diffDaysBnNowAndY2K + 1)%14;
              }
              usageCycleData.StartMonth = 1;
							usageCycleData.StartYear = 2000;

              break;
            }
          case UsageCycleType.Semi_monthly:
            {
			//Don't need to do anything special for semi-monthly
              break;
            }
          case UsageCycleType.Quarterly:
            {
              // normalize the start month to be a value between 1 and 3
              usageCycleData.StartMonth = usageCycleData.StartMonth.Value % 3;
              if (usageCycleData.StartMonth.Value == 0)
              {
                usageCycleData.StartMonth = 3;
              }
              break;
            }
          case UsageCycleType.Annually:
            {
              break;
            }
          case UsageCycleType.Semi_Annually:
            {
              break;
            }
 
          default:
            {
              throw new MASBasicException(String.Format("Invalid Usage Cycle Type '{0}'", internalView.UsageCycleType));
            }
        }
      }

      return usageCycleData;
    }

    public static string EncryptPassword(string userName, string name_space, 
        string password)
    {
      MetraTech.Security.Auth auth = new MetraTech.Security.Auth();
      auth.Initialize(userName, name_space);
      return auth.HashNewPassword(password);
    }
    

    public static MetraTech.Interop.IMTAccountType.IMTAccountType GetAccountType(
        string accountTypeName)
    {
      AccountTypeCollection accountTypeCollection = new AccountTypeCollection();
      return accountTypeCollection.GetAccountType(accountTypeName);
    }

    public static void CreateAccount(BaseTypes.Account account, 
        MetraTech.Interop.MTAuth.IMTSessionContext sessionContext,
        ref string hierarchyPath, ref string currency, ref int ancestorId, 
        ref int corporateAccountId, ref string ancestorType,
        IdGenerator profileIdGenerator, IdGenerator accountIdGenerator)
    {
            try
            {
                Auditor auditor = new Auditor();
                mLogger.LogDebug("Creating account with username '{0}'", account.UserName);

                InternalView internalView = account.GetInternalView() as InternalView;
                MetraTech.Accounts.Type.AccountTypeCollection myCollection = new AccountTypeCollection();
                MetraTech.Interop.IMTAccountType.IMTAccountType accountType = myCollection.GetAccountType(account.AccountType);
                //Debug.Assert(accountType != null);

                CheckCreateCapabilities(account, accountType, sessionContext);
                CheckPaymentAuth(account, sessionContext);

                if (internalView.PriceList != null)
                {
                    CheckPriceList(internalView.PriceList.Value);
                }

                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                                   new TransactionOptions(),
                                                                   EnterpriseServicesInteropOption.Full))
                {
                    int profileId;
                    int accountId = 0;

                    if (profileIdGenerator == null)
                    {
                        profileIdGenerator = new IdGenerator("id_profile", 200);
                    }
                    if (accountIdGenerator == null)
                    {
                        accountIdGenerator = new IdGenerator("id_acc", 200);
                    }

                    profileId = profileIdGenerator.NextId;
                    accountId = accountIdGenerator.NextMashedId;

                    // Execute the stored procedure "AddNewAccount"
                    using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
                    {
                        using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddNewAccount"))
                        {

                            stmt.AddParam("p_id_acc_ext", MTParameterType.String, Guid.NewGuid().ToString("N"));
                            stmt.AddParam("p_acc_state", MTParameterType.String, EnumHelper.GetValueByEnum(account.AccountStatus));
                            // p_acc_status_ext is not used by the stored proc
                            stmt.AddParam("p_acc_status_ext", MTParameterType.Integer, null);

                            stmt.AddParam("p_acc_vtstart", MTParameterType.DateTime, account.AccountStartDate);
                            stmt.AddParam("p_acc_vtend", MTParameterType.DateTime, account.AccountEndDate);
                            stmt.AddParam("p_nm_login", MTParameterType.WideString, account.UserName);
                            stmt.AddParam("p_nm_space", MTParameterType.WideString, account.Name_Space);

                            // Hash the password for MetraNet internal authentication. 
                            stmt.AddParam(
                              "p_tx_password",
                              MTParameterType.WideString,
                              account.AuthenticationType == DomainModel.Enums.Account.Metratech_com_accountcreation.AuthenticationType.MetraNetInternal ? AccountHelper.EncryptPassword(account.UserName, account.Name_Space, account.Password_) : string.Empty);
                            stmt.AddParam("p_auth_type", MTParameterType.Integer, EnumHelper.GetValueByEnum(account.AuthenticationType));

                            stmt.AddParam("p_langcode", MTParameterType.String, internalView.Language.ToString());
                            stmt.AddParam("p_profile_timezone", MTParameterType.Integer, EnumHelper.GetValueByEnum(internalView.TimezoneID));
                            if (internalView.UsageCycleType.HasValue)
                            {
                                stmt.AddParam("p_id_cycle_type", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(internalView.UsageCycleType)));
                            }
                            else
                            {
                                stmt.AddParam("p_id_cycle_type", MTParameterType.Integer, null);
                            }

                            UsageCycleData usageCycleData = AccountHelper.GetUsageCycleData(account);

                            stmt.AddParam("p_day_of_month", MTParameterType.Integer, usageCycleData.DayOfMonth);
                            stmt.AddParam("p_day_of_week", MTParameterType.Integer, usageCycleData.DayOfWeek);
                            stmt.AddParam("p_first_day_of_month", MTParameterType.Integer, usageCycleData.FirstDayOfMonth);
                            stmt.AddParam("p_second_day_of_month", MTParameterType.Integer, usageCycleData.SecondDayOfMonth);
                            stmt.AddParam("p_start_day", MTParameterType.Integer, usageCycleData.StartDay);
                            stmt.AddParam("p_start_month", MTParameterType.Integer, usageCycleData.StartMonth);
                            stmt.AddParam("p_start_year", MTParameterType.Integer, usageCycleData.StartYear);

                            if (!accountType.CanBePayer)
                            {
                                internalView.Billable = false;
                                stmt.AddParam("p_billable", MTParameterType.String, EnumHelper.GetMTBool(false));
                            }
                            else
                            {
                                stmt.AddParam("p_billable", MTParameterType.String, EnumHelper.GetDbValue(internalView, "Billable"));
                            }

                            if (account.PayerID.HasValue)
                            {
                                stmt.AddParam("p_id_payer", MTParameterType.Integer, account.PayerID);
                                // Null out the payer dates - stored proc will always pick up the date from account start date
                                stmt.AddParam("p_payer_startdate", MTParameterType.DateTime, null);
                                stmt.AddParam("p_payer_enddate", MTParameterType.DateTime, null);
                                stmt.AddParam("p_payer_login", MTParameterType.WideString, null);
                                stmt.AddParam("p_payer_namespace", MTParameterType.WideString, null);
                            }
                            else
                            {
                                stmt.AddParam("p_id_payer", MTParameterType.Integer, null);
                                // Null out the payer dates - stored proc will always pick up the date from account start date
                                stmt.AddParam("p_payer_startdate", MTParameterType.DateTime, null);
                                stmt.AddParam("p_payer_enddate", MTParameterType.DateTime, null);
                                stmt.AddParam("p_payer_login", MTParameterType.WideString, account.PayerAccount);
                                stmt.AddParam("p_payer_namespace", MTParameterType.WideString, account.PayerAccountNS);
                            }


                            // If no ancestor information has been specified then set the ancestor account id to 1 or -1
                            // based on accountType.CanHaveSyntheticRoot
                            if (!account.AncestorAccountID.HasValue &&
                                String.IsNullOrEmpty(account.AncestorAccount) &&
                                String.IsNullOrEmpty(account.AncestorAccountNS))
                            {
                                ancestorId = 1;
                                if (accountType.CanHaveSyntheticRoot)
                                {
                                    ancestorId = -1;
                                }
                                stmt.AddParam("p_id_ancestor", MTParameterType.Integer, ancestorId);
                                // Null out the hierarchy dates - stored proc will always pick up the date from account start date 
                                stmt.AddParam("p_hierarchy_start", MTParameterType.DateTime, null);
                                stmt.AddParam("p_hierarchy_end", MTParameterType.DateTime, null);
                                stmt.AddParam("p_ancestor_name", MTParameterType.WideString, null);
                                stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, null);
                            }
                            else if (account.AncestorAccountID.HasValue)
                            {
                                stmt.AddParam("p_id_ancestor", MTParameterType.Integer, account.AncestorAccountID);
                                // Null out the hierarchy dates - stored proc will always pick up the date from account start date 
                                stmt.AddParam("p_hierarchy_start", MTParameterType.DateTime, null);
                                stmt.AddParam("p_hierarchy_end", MTParameterType.DateTime, null);
                                stmt.AddParam("p_ancestor_name", MTParameterType.WideString, null);
                                stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, null);
                            }
                            else
                            {
                                stmt.AddParam("p_id_ancestor", MTParameterType.Integer, null);
                                // Null out the hierarchy dates - stored proc will always pick up the date from account start date 
                                stmt.AddParam("p_hierarchy_start", MTParameterType.DateTime, null);
                                stmt.AddParam("p_hierarchy_end", MTParameterType.DateTime, null);
                                stmt.AddParam("p_ancestor_name", MTParameterType.WideString, account.AncestorAccount);
                                stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, account.AncestorAccountNS);
                            }


                            stmt.AddParam("p_acc_type", MTParameterType.String, account.AccountType);

                            stmt.AddParam("p_apply_default_policy", MTParameterType.String, EnumHelper.GetDbValue(account, "ApplyDefaultSecurityPolicy"));
                            stmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);

                            // Convert to bool
                            IMTProductCatalog productCatalog = new MTProductCatalogClass();
                            string enforceSameCorporation = "1";
                            if (productCatalog.IsBusinessRuleEnabled(MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
                            {
                                enforceSameCorporation = "0";
                            }
                            stmt.AddParam("p_enforce_same_corporation", MTParameterType.String, enforceSameCorporation);
                            stmt.AddParam("p_account_currency", MTParameterType.WideString, internalView.Currency);

                            stmt.AddParam("p_profile_id", MTParameterType.Integer, profileId);

                            // LoginApplication is valid only for system accounts
                            string loginApp = null;
                            if (account is SystemAccount)
                            {
                                loginApp = (EnumHelper.GetValueByEnum(((SystemAccount)account).LoginApplication)).ToString();
                            }
                            stmt.AddParam("p_login_app", MTParameterType.String, loginApp);

                            stmt.AddParam("accountID", MTParameterType.Integer, accountId);

                            // Outputs
                            stmt.AddOutputParam("status", MTParameterType.Integer, 0);
                            stmt.AddOutputParam("p_hierarchy_path", MTParameterType.String, 4000);
                            stmt.AddOutputParam("p_currency", MTParameterType.WideString, 10);
                            stmt.AddOutputParam("p_id_ancestor_out", MTParameterType.Integer, 0);
                            stmt.AddOutputParam("p_corporate_account_id", MTParameterType.Integer, 0);
                            stmt.AddOutputParam("p_ancestor_type_out", MTParameterType.String, 40);

                            try
                            {
                                stmt.ExecuteNonQuery();
                            }
                            catch (Exception e)
                            {
                                mLogger.LogError("Exception adding acct with ID: {0}", accountId);

                                throw e;
                            }

                            // Set the account id on the account object.
                            account._AccountID = accountId;

                            int status = (int)stmt.GetOutputValue("status");

                            if (status == 1)
                            {
                                object dbValue = null;

                                dbValue = stmt.GetOutputValue("p_hierarchy_path");
                                if (dbValue != System.DBNull.Value)
                                {
                                    hierarchyPath = dbValue as string;
                                    // Check account hierarchy capability
                                    IMTSecurity security = new MTSecurityClass();
                                    MetraTech.Interop.MTAuth.IMTCompositeCapability capability =
                                      security.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
                                    capability.GetAtomicPathCapability().SetParameter(hierarchyPath,
                                                                                      MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE);
                                    sessionContext.SecurityContext.CheckAccess(capability);
                                }

                                dbValue = stmt.GetOutputValue("p_currency");
                                if (dbValue != System.DBNull.Value)
                                {
                                    currency = dbValue as string;
                                }

                                dbValue = stmt.GetOutputValue("p_id_ancestor_out");
                                if (dbValue != System.DBNull.Value)
                                {
                                    ancestorId = (int)dbValue;
                                }

                                dbValue = stmt.GetOutputValue("p_corporate_account_id");
                                if (dbValue != System.DBNull.Value)
                                {
                                    corporateAccountId = (int)dbValue;
                                }

                                dbValue = stmt.GetOutputValue("p_ancestor_type_out");
                                if (dbValue != System.DBNull.Value)
                                {
                                    ancestorType = dbValue as string;
                                }

                                auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_CREATE, sessionContext.AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, account._AccountID.Value,
                                String.Format("Successfully created account for username '{0}' with id '{1}'",
                                                    account.UserName, account._AccountID));

                                mLogger.LogInfo("Successfully created account for username '{0}' with id '{1}'",
                                               account.UserName, account._AccountID);

                                // Update materialized views
                                UpdateMaterializedViews(false, account);

#if false
                                // Add views in account.
                                UpdateAllAccountViews(true, account);
#endif

                                scope.Complete();
                            }
                            else
                            {
                                string error = GetErrorMsg(status);
                                mLogger.LogError(error);
                                throw new MASBasicException(error);
                            }
                        }
                    }
                }
            }
            catch (MASBasicException masBasEx)
            {
                mLogger.LogException("Create Account in Create Account activity failed.", masBasEx);
                throw;
            }
            catch (COMException comEx)
            {
                mLogger.LogException("COM Exception occurred : ", comEx);
                throw new MASBasicException(comEx.Message);
            }
            catch (Exception ex)
            {
                // ESR-5404 throw the "ex" error using a MASBasicExpection which throws the error to the UI
                throw new MASBasicException(ex.Message);
            }
        }

        // If forceAdd is true then add the views, otherwise update or add depending
        // on view key properties.
        public static void UpdateAllAccountViews(bool forceAdd, 
            BaseTypes.Account account)
        {
            try
            {
              using (TransactionScope scope = 
                  new TransactionScope(TransactionScopeOption.Required,
                  new TransactionOptions(),
                  EnterpriseServicesInteropOption.Full))
              {
                IMTAccountAdapter2 accServer = new MTAccountServerClass();

                // Loop through all views in account.
                MTAccountPropertyCollection newProperties = null;
                MTAccountPropertyCollection keyProperties = null;
                foreach (KeyValuePair<string, List<View>> kvp in account.GetViews())
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
                            MTDataMemberAttribute attribsProp = account.GetMTDataMemberAttribute(pi);
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
                            mLogger.LogDebug("Skipping " + view.GetType().Name + " view because it has no valid properties.");
                            continue;
                        }

                        // Add account id; it is always in a view.
                        newProperties.Add("id_acc", account._AccountID);

                        // Initialize adapter for view.
                        accServer.Initialize(kvp.Key);

                        // Update properties.
                        if (forceAdd)
                            accServer.AddData(kvp.Key, newProperties, null); //xxx maybe psss in rowset?
                        else // This may be an update or an add.
                        {
                            // Add account id; it is a key property.
                            keyProperties.Add("id_acc", account._AccountID);

                            // Check if account view exists.
                            bool found = false;
                            try
                            {
                                MTSearchResultCollection searchResult = accServer.SearchDataWithUpdLock(kvp.Key, keyProperties, 1, null);
                                found = (searchResult.Count > 0) ? true : false;
                            }
                            catch (COMException ex)
                            {
                                // Not found.
                                if (ex.ErrorCode == -509673469 /* 0xE19F0003 */)
                                    found = false;
                                else
                                    throw ex;
                            }

                            if (found)
                            {
                                // Update account view.
                                mLogger.LogDebug("Updating " + view.GetType().Name + " view properties.");
                                accServer.UpdateData(kvp.Key, newProperties, null);
                            }
                            else
                            {
                                // Add account view.
                                mLogger.LogDebug("Adding " + view.GetType().Name + " view properties.");
                                accServer.AddData(kvp.Key, newProperties, null);
                            }
                        }
                    }
                }

                // Release COM objects.
                if (newProperties != null)
                    Marshal.ReleaseComObject(newProperties);

                if (keyProperties != null)
                    Marshal.ReleaseComObject(keyProperties);

                Marshal.ReleaseComObject(accServer);

                  // Done with transaction.
                  scope.Complete();
              }
            }
            catch (MASBasicException masBasEx)
            {
                mLogger.LogException("error occurred in UpdateAllAccountViews", 
                    masBasEx);
                throw;
            }
            catch (COMException comEx)
            {
                mLogger.LogException("COM Exception occurred : ", comEx);
                throw new MASBasicException(comEx.Message);
            }
            catch (Exception ex)
            {
                mLogger.LogException("Exception occurred in UpdateAllAccountViews", 
                    ex);
                throw new MASBasicException(
                    "Exception occurred in UpdateAllAccountViews");
            }
        }

        private static void CheckCreateCapabilities(BaseTypes.Account account, 
            MetraTech.Interop.IMTAccountType.IMTAccountType accountType,
            MetraTech.Interop.MTAuth.IMTSessionContext sessionContext)
        {
            IMTSecurity security = new MTSecurityClass();
            MetraTech.Interop.MTAuth.IMTCompositeCapability capability = null;

            try
            {
                if (account is SystemAccount)
                {
                    capability = security.GetCapabilityTypeByName("Create CSR accounts").CreateInstance();
                }
                else
                {
                    if (accountType.IsCorporate)
                    {
                        capability = security.GetCapabilityTypeByName("Create corporate accounts").CreateInstance();
                    }
                    else
                    {
                        capability = security.GetCapabilityTypeByName("Create subscriber accounts").CreateInstance();
                    }
                }

                sessionContext.SecurityContext.CheckAccess(capability);
            }
            finally
            {
                Marshal.ReleaseComObject(security);
            }
        }

        private static void CheckPaymentAuth(BaseTypes.Account account,
            MetraTech.Interop.MTAuth.IMTSessionContext sessionContext)
        {
            IMTSecurity security = new MTSecurityClass();
            MetraTech.Interop.MTAuth.IMTCompositeCapability capability = null;

            try
            {
                InternalView internalView = (InternalView)account.GetInternalView();
                if (internalView.Billable.HasValue && internalView.Billable.Value == true)
                {
                    capability = security.GetCapabilityTypeByName("Manage billable accounts").CreateInstance();
                    sessionContext.SecurityContext.CheckAccess(capability);
                }

                if (account.PayerAccount != null || account.PayerID != null)
                {
                    capability = security.GetCapabilityTypeByName("Manage Payment Redirection").CreateInstance();
                    sessionContext.SecurityContext.CheckAccess(capability);
                }
            }
            finally
            {
                Marshal.ReleaseComObject(security);
            }
        }

        private static void CheckPriceList(int priceListId)
        {
            if (priceListId <= 0)
            {
                string error = MT_ACCOUNT_PRICELIST_INVALID;
                mLogger.LogError(error);
                throw new MASBasicException(error);
            }
        }

        private static void UpdateMaterializedViews(bool isUpdate, BaseTypes.Account account)
        {
            Manager materializedViewManager = new Manager();
            materializedViewManager.Initialize();

            if (!materializedViewManager.IsMetraViewSupportEnabled)
            {
                mLogger.LogDebug("Materialized views are not enabled for MetraView.");
                return;
            }
            string baseTableName = "t_dm_account";

            string insertDeltaTableName = materializedViewManager.GenerateDeltaInsertTableName(baseTableName);
            string deleteDeltaTableName = materializedViewManager.GenerateDeltaDeleteTableName(baseTableName);

            // Enable caching support.
            materializedViewManager.EnableCache(true);

            // Prepare the base table bindings.
            materializedViewManager.AddInsertBinding(baseTableName, insertDeltaTableName);
            materializedViewManager.AddDeleteBinding(baseTableName, deleteDeltaTableName);

            using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
            {
                using (IMTAdapterStatement stmt =
                  conn.CreateAdapterStatement(@"Queries\AccountCreation", "__CREATE_ACCOUNT_DELTA_TABLE__"))
                {

                    stmt.AddParam("%%TABLE_NAME%%", insertDeltaTableName, true);

                    stmt.ExecuteNonQuery();
                    stmt.ClearQuery();

                    string mvquery = String.Empty;
                    if (isUpdate)
                    {
                        stmt.QueryTag = "__UPDATE_ACCOUNT_DELTA_TABLE__";
                        mvquery = materializedViewManager.GetMaterializedViewUpdateQuery(new string[] { baseTableName });
                    }
                    else
                    {
                        stmt.QueryTag = "__INSERT_INTO_ACCOUNT_DELTA_TABLE__";
                        mvquery = materializedViewManager.GetMaterializedViewInsertQuery(new string[] { baseTableName });
                    }

                    stmt.AddParam("%%TABLE_NAME%%", baseTableName);
                    stmt.AddParam("%%DELTA_TABLE_NAME%%", insertDeltaTableName);
                    stmt.AddParam("%%ID_ACC_LIST%%", account._AccountID);
                    stmt.ExecuteNonQuery();

                    if (!String.IsNullOrEmpty(mvquery))
                    {
                        using (IMTStatement mvStmt = conn.CreateStatement(mvquery))
                        {
                            mvStmt.ExecuteNonQuery();
                        }
                    }

                    stmt.ClearQuery();
                    stmt.QueryTag = "__TRUNCATE_ACCOUNT_DELTA_TABLE__";
                    stmt.AddParam("%%TABLE_NAME%%", insertDeltaTableName);
                    stmt.ExecuteNonQuery();

                    stmt.ClearQuery();
                    stmt.QueryTag = "__TRUNCATE_ACCOUNT_DELTA_TABLE__";
                    stmt.AddParam("%%TABLE_NAME%%", deleteDeltaTableName);
                    stmt.ExecuteNonQuery();
                }
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
                case MT_CURRENCY_MISMATCH:
                    {
                        error = MT_CURRENCY_MISMATCH_MSG;
                        break;
                    }
                case MT_PAYER_PAYEE_CURRENCY_MISMATCH:
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
                default:
                    {
                        // return error
                        error = String.Format("Unable to create account with status '{0}'.", status);
                        break;
                    }
            }

            return error;

        }


	}

  public class UsageCycleData
  {
    public int? DayOfMonth;
    public int? DayOfWeek;
    public int? FirstDayOfMonth;
    public int? SecondDayOfMonth;
    public int? StartDay;
    public int? StartMonth;
    public int? StartYear;
  }
}

using System;
using System.Diagnostics;
using System.Reflection;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Transactions;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.DomainModel.Common;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Validators;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTAuth;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Activities
{
    public class CreateAccountActivity : BaseAccountActivity
    {
        #region Output Properties
        public static DependencyProperty HierarchyPathProperty = System.Workflow.ComponentModel.DependencyProperty.Register("HierarchyPath", typeof(string), typeof(CreateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string HierarchyPath
        {
            get
            {
                return ((string)(base.GetValue(CreateAccountActivity.HierarchyPathProperty)));
            }
            set
            {
                base.SetValue(CreateAccountActivity.HierarchyPathProperty, value);
            }
        }

        public static DependencyProperty CurrencyProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Currency", typeof(string), typeof(CreateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string Currency
        {
            get
            {
                return ((string)(base.GetValue(CreateAccountActivity.CurrencyProperty)));
            }
            set
            {
                base.SetValue(CreateAccountActivity.CurrencyProperty, value);
            }
        }

        public static DependencyProperty AncestorIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AncestorId", typeof(int), typeof(CreateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int AncestorId
        {
            get
            {
                return ((int)(base.GetValue(CreateAccountActivity.AncestorIdProperty)));
            }
            set
            {
                base.SetValue(CreateAccountActivity.AncestorIdProperty, value);
            }
        }

        public static DependencyProperty CorporateAccountIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("CorporateAccountId", typeof(int), typeof(CreateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int CorporateAccountId
        {
            get
            {
                return ((int)(base.GetValue(CreateAccountActivity.CorporateAccountIdProperty)));
            }
            set
            {
                base.SetValue(CreateAccountActivity.CorporateAccountIdProperty, value);
            }
        }

        public static DependencyProperty AncestorTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AncestorType", typeof(string), typeof(CreateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string AncestorType
        {
            get
            {
                return ((string)(base.GetValue(CreateAccountActivity.AncestorTypeProperty)));
            }
            set
            {
                base.SetValue(CreateAccountActivity.AncestorTypeProperty, value);
            }
        }

        #endregion

        #region Activity overrides
        protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
        {
            using (HighResolutionTimer timer = new HighResolutionTimer("ActivityExecutionStatus_Execute"))
            {
                try
                {
                    AccountValidator accountValidator = new AccountValidator();
                    List<string> validationErrors;

                    // Validate the account
                    if (!accountValidator.Validate(In_Account, out validationErrors))
                    {
                        Logger.LogError("Failed to validate account with the following errors '{0}'", validationErrors.ToArray());

                        MASBasicException masE = new MASBasicException("Account failed validation");

                        foreach (string err in validationErrors)
                        {
                            masE.AddErrorMessage(err);
                        }

                        throw masE;
                    }

                    // Create the account 
                    try
                    {
                        string hierarchyPath = "";
                        string currency = "";
                        int ancestorId = 0;
                        int corporateAccountId = 0;
                        string ancestorType = "";

                        AccountHelper.CreateAccount(In_Account, SessionContext,
                          ref hierarchyPath, ref currency, ref ancestorId,
                          ref corporateAccountId, ref ancestorType,
                          ProfileIdGenerator, AccountIdGenerator);

                        HierarchyPath = hierarchyPath;
                        Currency = currency;
                        AncestorId = ancestorId;
                        CorporateAccountId = corporateAccountId;
                        AncestorType = ancestorType;
                    }
                    catch (MASBasicException masE)
                    {
                        Logger.LogException("MASBasicException creating account", masE);

                        throw masE;
                    }
                    catch (Exception ex)
                    {
                        Logger.LogException("Create account failed", ex);

                        MASBasicException masE = new MASBasicException("Create account failed");
                        // Do not want error message (reason) being sent back to UI, just log it.
                        //masE.AddErrorMessage(ex.Message);

                        throw masE;
                    }
                }
                catch (MASBasicException masBasEx)
                {
                    Logger.LogException("Create Account activity failed.", masBasEx);
                    throw;
                }
                catch (COMException comEx)
                {
                    Logger.LogException("COM Exception occurred : ", comEx);
                    throw new MASBasicException(comEx.Message);
                }
                catch (Exception ex)
                {
                    Logger.LogException("Exception occurred while executing Create Account  activity  activity. ", ex);
                    throw new MASBasicException("Exception occurred while executing Create Account  activity  activity.");
                }
            }
            return ActivityExecutionStatus.Closed;
        }
        #endregion

        #region Private Methods

        private void CreateAccount(Account account)
        {
            try
            {
                Auditor auditor = new Auditor();
                Logger.LogDebug("Creating account with username '{0}'", account.UserName);

                InternalView internalView = account.GetInternalView() as InternalView;
                IMTAccountType accountType = AccountTypesCollection.GetAccountType(account.AccountType);
                //Debug.Assert(accountType != null);

                CheckCreateCapabilities(account, accountType);
                CheckPaymentAuth(account);

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

                    profileId = ProfileIdGenerator.NextId;
                    accountId = AccountIdGenerator.NextMashedId;

                    // Execute the stored procedure "AddNewAccount"
                    using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
                    {
                        using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddNewAccount"))
                        {

                            stmt.AddParam("p_id_acc_ext", MTParameterType.String, Guid.NewGuid().ToString("N"));
                            stmt.AddParam("p_acc_state", MTParameterType.String, EnumHelper.GetValueByEnum(In_Account.AccountStatus));
                            // p_acc_status_ext is not used by the stored proc
                            stmt.AddParam("p_acc_status_ext", MTParameterType.Integer, null);

                            stmt.AddParam("p_acc_vtstart", MTParameterType.DateTime, In_Account.AccountStartDate);
                            stmt.AddParam("p_acc_vtend", MTParameterType.DateTime, In_Account.AccountEndDate);
                            stmt.AddParam("p_nm_login", MTParameterType.WideString, In_Account.UserName);
                            stmt.AddParam("p_nm_space", MTParameterType.WideString, In_Account.Name_Space);

                            // Hash the password for MetraNet internal authentication. 
                            stmt.AddParam(
                              "p_tx_password",
                              MTParameterType.WideString,
                              In_Account.AuthenticationType == DomainModel.Enums.Account.Metratech_com_accountcreation.AuthenticationType.MetraNetInternal ? AccountHelper.EncryptPassword(In_Account.UserName, In_Account.Name_Space, In_Account.Password_) : string.Empty);
                            stmt.AddParam("p_auth_type", MTParameterType.Integer, EnumHelper.GetValueByEnum(In_Account.AuthenticationType));

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

                            UsageCycleData usageCycleData = AccountHelper.GetUsageCycleData(In_Account);

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

                            if (In_Account.PayerID.HasValue)
                            {
                                stmt.AddParam("p_id_payer", MTParameterType.Integer, In_Account.PayerID);
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
                                stmt.AddParam("p_payer_login", MTParameterType.WideString, In_Account.PayerAccount);
                                stmt.AddParam("p_payer_namespace", MTParameterType.WideString, In_Account.PayerAccountNS);
                            }


                            // If no ancestor information has been specified then set the ancestor account id to 1 or -1
                            // based on accountType.CanHaveSyntheticRoot
                            if (!In_Account.AncestorAccountID.HasValue &&
                                String.IsNullOrEmpty(In_Account.AncestorAccount) &&
                                String.IsNullOrEmpty(In_Account.AncestorAccountNS))
                            {
                                int ancestorId = 1;
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
                            else if (In_Account.AncestorAccountID.HasValue)
                            {
                                stmt.AddParam("p_id_ancestor", MTParameterType.Integer, In_Account.AncestorAccountID);
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
                                stmt.AddParam("p_ancestor_name", MTParameterType.WideString, In_Account.AncestorAccount);
                                stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, In_Account.AncestorAccountNS);
                            }


                            stmt.AddParam("p_acc_type", MTParameterType.String, In_Account.AccountType);

                            stmt.AddParam("p_apply_default_policy", MTParameterType.String, EnumHelper.GetDbValue(In_Account, "ApplyDefaultSecurityPolicy"));
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
                            if (In_Account is SystemAccount)
                            {
                                loginApp = (EnumHelper.GetValueByEnum(((SystemAccount)In_Account).LoginApplication)).ToString();
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
                                Logger.LogError("Exception adding acct with ID: {0}", accountId);

                                throw e;
                            }

                            // Set the account id on the account object.
                            In_Account._AccountID = accountId;

                            int status = (int)stmt.GetOutputValue("status");

                            if (status == 1)
                            {
                                object dbValue = null;

                                dbValue = stmt.GetOutputValue("p_hierarchy_path");
                                if (dbValue != System.DBNull.Value)
                                {
                                    HierarchyPath = dbValue as string;
                                    // Check account hierarchy capability
                                    IMTSecurity security = new MTSecurityClass();
                                    MetraTech.Interop.MTAuth.IMTCompositeCapability capability =
                                      security.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
                                    capability.GetAtomicPathCapability().SetParameter(HierarchyPath,
                                                                                      MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE);
                                    SessionContext.SecurityContext.CheckAccess(capability);
                                }

                                dbValue = stmt.GetOutputValue("p_currency");
                                if (dbValue != System.DBNull.Value)
                                {
                                    Currency = dbValue as string;
                                }

                                dbValue = stmt.GetOutputValue("p_id_ancestor_out");
                                if (dbValue != System.DBNull.Value)
                                {
                                    AncestorId = (int)dbValue;
                                }

                                dbValue = stmt.GetOutputValue("p_corporate_account_id");
                                if (dbValue != System.DBNull.Value)
                                {
                                    CorporateAccountId = (int)dbValue;
                                }

                                dbValue = stmt.GetOutputValue("p_ancestor_type_out");
                                if (dbValue != System.DBNull.Value)
                                {
                                    AncestorType = dbValue as string;
                                }

                                auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_ACCOUNT_CREATE, this.SessionContext.AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, In_Account._AccountID.Value,
                                String.Format("Successfully created account for username '{0}' with id '{1}'",
                                                    In_Account.UserName, In_Account._AccountID));

                                Logger.LogInfo("Successfully created account for username '{0}' with id '{1}'",
                                               In_Account.UserName, In_Account._AccountID);

                                // Update materialized views
                                UpdateMaterializedViews(false);

                                scope.Complete();
                            }
                            else
                            {
                                string error = GetErrorMsg(status);
                                Logger.LogError(error);
                                throw new MASBasicException(error);
                            }
                        }
                    }
                }
            }
            catch (MASBasicException masBasEx)
            {
                Logger.LogException("Create Account in Create Account activity failed.", masBasEx);
                throw;
            }
            catch (COMException comEx)
            {
                Logger.LogException("COM Exception occurred : ", comEx);
                throw new MASBasicException(comEx.Message);
            }
            catch (Exception ex)
            {
                // ESR-5404 throw the "ex" error using a MASBasicExpection which throws the error to the UI
                throw new MASBasicException(ex.Message);
            }
        }

        private string GetErrorMsg(int status)
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

        private void SetParamValue(IMTCallableStatement statement,
                                   string parameterName,
                                   MTParameterType parameterType,
                                   object parameterValue,
                                   bool isParamValueValid)
        {
            if (isParamValueValid)
            {
                statement.AddParam(parameterName, parameterType, parameterValue);
            }
            else
            {
                statement.AddParam(parameterName, parameterType, null);
            }
        }

        private void CheckCreateCapabilities(Account account, IMTAccountType accountType)
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

                SessionContext.SecurityContext.CheckAccess(capability);
            }
            finally
            {
                Marshal.ReleaseComObject(security);
            }
        }

        private void CheckPriceList(int priceListId)
        {
            if (priceListId <= 0)
            {
                string error = MT_ACCOUNT_PRICELIST_INVALID;
                Logger.LogError(error);
                throw new MASBasicException(error);
            }
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

        #endregion

        #region Static Members
        private static IdGenerator m_ProfileIdGenerator = null;
        private static IdGenerator m_AccountIdGenerator = null;
        private static AccountTypeCollection m_AccountTypeCollection = null;

        protected static IdGenerator ProfileIdGenerator
        {
            get
            {
                if (m_ProfileIdGenerator == null)
                {
                    m_ProfileIdGenerator = new IdGenerator("id_profile", 200);
                }

                return m_ProfileIdGenerator;
            }
        }

        protected static IdGenerator AccountIdGenerator
        {
            get
            {
                if (m_AccountIdGenerator == null)
                {
                    m_AccountIdGenerator = new IdGenerator("id_acc", 200);
                }

                return m_AccountIdGenerator;
            }
        }

        protected static AccountTypeCollection AccountTypesCollection
        {
            get
            {
                if (m_AccountTypeCollection == null)
                {
                    m_AccountTypeCollection = new AccountTypeCollection();
                }

                return m_AccountTypeCollection;
            }
        }
        #endregion
    }
}

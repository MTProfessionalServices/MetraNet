using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Workflow.ComponentModel;
using System.Transactions;
using System.Diagnostics;
using System.Runtime.InteropServices;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Validators;
using MetraTech.DataAccess;
using PC = MetraTech.Interop.MTProductCatalog;
using MetraTech.Accounts.Type;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTYAAC;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Debug.Diagnostics;
//using MetraTech.Common;

namespace MetraTech.Core.Activities
{
    public partial class UpdateAccountActivity : BaseAccountActivity
    {
        #region Static Members
        private static AccountTypeCollection m_AccountTypeCollection = null;

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

        private static MetraTech.Interop.MTAuth.IMTCompositeCapabilityType m_ManageHierarchyCapability = null;
        protected static MetraTech.Interop.MTAuth.IMTCompositeCapability ManageAccountHierarchyCapability
        {
            get
            {
                if (m_ManageHierarchyCapability == null)
                {
                    IMTSecurity security = new MTSecurityClass();
                    m_ManageHierarchyCapability = security.GetCapabilityTypeByName("Manage Account Hierarchies");
                }

                return m_ManageHierarchyCapability.CreateInstance();
            }
        }
        #endregion

        #region Input Properties

        public static DependencyProperty LoadTimeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("LoadTime", typeof(DateTime?), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public DateTime? LoadTime
        {
            get
            {
                return ((DateTime?)(base.GetValue(UpdateAccountActivity.LoadTimeProperty))) ?? MetraTime.Now;
            }
            set
            {
                base.SetValue(UpdateAccountActivity.LoadTimeProperty, value);
            }
        }

        #endregion

        #region Output Properties
        public static DependencyProperty HasCycleChangedProperty = System.Workflow.ComponentModel.DependencyProperty.Register("HasCycleChanged", typeof(bool), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public bool HasCycleChanged
        {
            get
            {
                return ((bool)(base.GetValue(UpdateAccountActivity.HasCycleChangedProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.HasCycleChangedProperty, value);
            }
        }

        public static DependencyProperty NewCycleIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("NewCycleId", typeof(int), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int NewCycleId
        {
            get
            {
                return ((int)(base.GetValue(UpdateAccountActivity.NewCycleIdProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.NewCycleIdProperty, value);
            }
        }

        public static DependencyProperty HierarchyPathProperty = System.Workflow.ComponentModel.DependencyProperty.Register("HierarchyPath", typeof(string), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string HierarchyPath
        {
            get
            {
                return ((string)(base.GetValue(UpdateAccountActivity.HierarchyPathProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.HierarchyPathProperty, value);
            }
        }

        public static DependencyProperty OldAncestorIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("OldAncestorId", typeof(int), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int OldAncestorId
        {
            get
            {
                return ((int)(base.GetValue(UpdateAccountActivity.OldAncestorIdProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.OldAncestorIdProperty, value);
            }
        }

        public static DependencyProperty AncestorIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AncestorId", typeof(int), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int AncestorId
        {
            get
            {
                return ((int)(base.GetValue(UpdateAccountActivity.AncestorIdProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.AncestorIdProperty, value);
            }
        }

        public static DependencyProperty CorporateAccountIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("CorporateAccountId", typeof(int), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public int CorporateAccountId
        {
            get
            {
                return ((int)(base.GetValue(UpdateAccountActivity.CorporateAccountIdProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.CorporateAccountIdProperty, value);
            }
        }

        public static DependencyProperty AncestorTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AncestorType", typeof(string), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string AncestorType
        {
            get
            {
                return ((string)(base.GetValue(UpdateAccountActivity.AncestorTypeProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.AncestorTypeProperty, value);
            }
        }

        public static DependencyProperty AccountTypeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("AccountType", typeof(string), typeof(UpdateAccountActivity));

        [Description("This is the description which appears in the Property Browser")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string AccountType
        {
            get
            {
                return ((string)(base.GetValue(UpdateAccountActivity.AccountTypeProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountActivity.AccountTypeProperty, value);
            }
        }

        #endregion

        #region Activity overrides
        protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
        {
            Logger.LogDebug("starting UpdateAccountActivity_Execute");
            using (HighResolutionTimer timer = new HighResolutionTimer("UpdateAccountActivity_Execute"))
            {
                try
                {
                    AccountUpdateValidator validator = new AccountUpdateValidator();
                    List<string> validationErrors;

                    // Validate the account
                    if (!validator.Validate(In_Account, out validationErrors))
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
                        UpdateAccount(In_Account);
                    }
                    catch (Exception ex)
                    {
                        Logger.LogException("Update account failed", ex);
                        throw ex;
                    }
                }
                catch (MASBasicException masBasEx)
                {
                    Logger.LogException("Update Account Activity failed.", masBasEx);
                    throw;
                }
                catch (COMException comEx)
                {
                    Logger.LogException("COM Exception occurred : ", comEx);
                    throw new MASBasicException(comEx.Message);
                }
                catch (Exception ex)
                {
                    Logger.LogException("Exception occurred while executing Update Account Activity. ", ex);
                    throw new MASBasicException("Exception occurred while executing Update Account Activity.");
                }
            }

            return ActivityExecutionStatus.Closed;
        }
        #endregion

        private void UpdateAccount(Account account)
        {
            Auditor auditor = new Auditor();
            var resourceManager = new ResourcesManager();

            Logger.LogDebug("Updating account with username '{0}'", account.UserName);

            InternalView internalView = account.GetInternalView() as InternalView;

            // Load the existing account properties
            AccountUpdateData dbAccount =
              GetAccountUpdateData(account._AccountID.Value,
                                   account.Hierarchy_StartDate,
                                   account.Payment_StartDate,
                                   account.AccountStartDate);

            bool updateUsageCycle = true;
            bool updatePaymentInfo = false;
            bool updateAncestorInfo = false;

            String changeInfo = " ";

            // Check usage cycle type
            if (internalView.IsUsageCycleTypeDirty ||
                account.IsDayOfMonthDirty ||
                account.IsDayOfWeekDirty ||
                account.IsFirstDayOfMonthDirty ||
                account.IsSecondDayOfMonthDirty ||
                account.IsStartDayDirty ||
                account.IsStartMonthDirty ||
                account.IsStartYearDirty)
            {
                List<string> validationErrors = new List<string>();
                if (!AccountValidator.ValidateUsageCycle(account, validationErrors))
                {
                    Logger.LogError("Failed to validate account with the following errors '{0}'", validationErrors.ToArray());

                    MASBasicException masE = new MASBasicException("Account failed validation");

                    foreach (string err in validationErrors)
                    {
                        masE.AddErrorMessage(err);
                    }

                    throw masE;
                }

                // If usage cycle type has not changed, null out the items in account
                if (internalView.UsageCycleType == dbAccount.UsageCycleType &&
                    account.DayOfMonth == dbAccount.DayOfMonth &&
                    account.DayOfWeek == dbAccount.DayOfWeek &&
                    account.FirstDayOfMonth == dbAccount.FirstDayOfMonth &&
                    account.SecondDayOfMonth == dbAccount.SecondDayOfMonth &&
                    account.StartDay == dbAccount.StartDay &&
                    account.StartMonth == dbAccount.StartMonth &&
                    account.StartYear == dbAccount.StartYear)
                {
                    // No need to update usage cycle type info
                    updateUsageCycle = false;
                }
            }
            else
            {
                // No need to update usage cycle type info
                updateUsageCycle = false;
            }

            // Check that cycle type can be changed
            if (internalView.IsUsageCycleTypeDirty && internalView.UsageCycleType != null)
            {
                if (internalView.UsageCycleType.Value != dbAccount.UsageCycleType.Value)
                {
                    PC.MTProductCatalogClass pc = new PC.MTProductCatalogClass();
                    PC.IMTPCAccount acc = pc.GetAccount(account._AccountID.Value);
                    if (!acc.CanChangeBillingCycles())
                    {
                        throw new MASBasicException(CANNOT_CHANGE_BILLING_CYCLE);
                    }
                }
            }

            // If payment redirection info has not changed, null out the items in account
            if ((account.IsPayerIDDirty &&
                    account.PayerID.HasValue &&
                        account.PayerID.Value != dbAccount.PayerID.Value) ||

                ((account.IsPayerAccountDirty || account.IsPayerAccountNSDirty) &&
                    (string.Compare(account.PayerAccount, dbAccount.PayerAccount, true) != 0 ||
                    string.Compare(account.PayerAccountNS, dbAccount.PayerAccountNS, true) != 0)) ||

                (account.IsPayment_StartDateDirty && DateTime.Compare(account.Payment_StartDate.Value.Date, dbAccount.Payment_StartDate.Value.Date) != 0) ||
                (account.IsPayment_EndDateDirty && DateTime.Compare(account.Payment_EndDate.Value.Date, dbAccount.Payment_EndDate.Value.Date) != 0)
                )
            {
                updatePaymentInfo = true;
            }

            // Check payment authorization
            if (updatePaymentInfo)
            {
                CheckPaymentAuth(account);
            }

            // If ancestor info has not changed, null out the items in account
            if ((account.IsAncestorAccountIDDirty &&
                    account.AncestorAccountID.HasValue &&
                        account.AncestorAccountID.Value != dbAccount.AncestorAccountID.Value) ||

                ((account.IsAncestorAccountDirty || account.IsAncestorAccountNSDirty) &&
                    (string.Compare(account.AncestorAccount, dbAccount.AncestorAccount, true) != 0 ||
                     string.Compare(account.AncestorAccountNS, dbAccount.AncestorAccountNS, true) != 0)) ||

                (account.IsHierarchy_StartDateDirty && DateTime.Compare(account.Hierarchy_StartDate.Value.Date, dbAccount.Hierarchy_StartDate.Value.Date) != 0) ||
                (account.IsHierarchy_EndDateDirty && DateTime.Compare(account.Hierarchy_EndDate.Value.Date, dbAccount.Hierarchy_EndDate.Value.Date) != 0)
                )
            {
                updateAncestorInfo = true;
            }

            // Check that the account type is not being changed
            if (account.IsAccountTypeDirty)
            {
                if (account.AccountType != dbAccount.AccountType)
                {
                    throw new MASBasicException(CANNOT_CHANGE_ACCOUNT_TYPE);
                }
            }

            // Changing account state
            if (account.IsAccountStatusDirty)
            {
                if (account.AccountStatus.Value != dbAccount.AccountStatus.Value)
                {
                    IMTAccountCatalog accCatalog = new MTAccountCatalog();
                    accCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)SessionContext);
                    MetraTech.Interop.MTYAAC.IMTYAAC yaac =
                      accCatalog.GetAccountByName(account.UserName, account.Name_Space, LoadTime);

                    MetraTech.Interop.MTYAAC.IMTSQLRowset rowset = null;

                    yaac.GetAccountStateMgr().GetStateObject().ChangeState
                      ((MetraTech.Interop.MTYAAC.IMTSessionContext)SessionContext,
                       rowset,
                       account._AccountID.Value,
                       -1,
                       (string)EnumHelper.GetValueByEnum(account.AccountStatus.Value),
                       account.AccountStartDate.Value,
                       account.AccountEndDate.Value);
                    changeInfo += String.Format(resourceManager.GetLocalizedResource("ACOUNT_STATE_WAS"), dbAccount.AccountStatus.Value, account.AccountStatus.Value);
                }
            }

            MetraTech.Interop.IMTAccountType.IMTAccountType accountType =
              AccountTypesCollection.GetAccountType(account.AccountType);
            //Debug.Assert(accountType != null);

            if (account.AncestorAccountID == -1 && !accountType.CanHaveSyntheticRoot)
            {
                throw new MASBasicException(BAD_ANCESTOR);
            }
            if (account.PayerID == -1 && !accountType.CanHaveSyntheticRoot)
            {
                throw new MASBasicException(BAD_PAYER);
            }

            // Check account hierarchy capability
            if (!(account is SystemAccount))
            {
                MetraTech.Interop.MTAuth.IMTCompositeCapability capability = ManageAccountHierarchyCapability;

                capability.GetAtomicPathCapability().SetParameter(dbAccount.HierarchyPath,
                                                                  MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE);
                SessionContext.SecurityContext.CheckAccess(capability);
            }

            // Check update capabilities
            CheckUpdateCapabilities(account, accountType);

                // Execute the stored procedure "AddNewAccount"
                using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
                {
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdateAccount"))
                    {

                        stmt.AddParam("p_loginname", MTParameterType.WideString, In_Account.UserName);
                        stmt.AddParam("p_namespace", MTParameterType.WideString, In_Account.Name_Space);
                        stmt.AddParam("p_id_acc", MTParameterType.Integer, In_Account._AccountID);
                        stmt.AddParam("p_acc_state", MTParameterType.String, EnumHelper.GetValueByEnum(In_Account.AccountStatus));
                        // p_acc_state_ext is not used by the stored proc
                        stmt.AddParam("p_acc_state_ext", MTParameterType.Integer, null);
                        // p_acc_statestart is not used by the stored proc
                        stmt.AddParam("p_acc_statestart", MTParameterType.DateTime, null);

                        if (In_Account.IsPassword_Dirty && !String.IsNullOrEmpty(In_Account.Password_))
                        {
                            stmt.AddParam("p_tx_password", MTParameterType.WideString, AccountHelper.EncryptPassword(In_Account.UserName, In_Account.Name_Space, In_Account.Password_));
                        }
                        else
                        {
                            stmt.AddParam("p_tx_password", MTParameterType.WideString, null);
                        }

                        if (updateUsageCycle)
                        {
                            // Usage cycle info
                            UsageCycleData usageCycleData = AccountHelper.GetUsageCycleData(In_Account);

                            stmt.AddParam("p_id_cycle_type", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(internalView.UsageCycleType)));
                            stmt.AddParam("p_day_of_month", MTParameterType.Integer, usageCycleData.DayOfMonth);
                            stmt.AddParam("p_day_of_week", MTParameterType.Integer, usageCycleData.DayOfWeek);
                            stmt.AddParam("p_first_day_of_month", MTParameterType.Integer, usageCycleData.FirstDayOfMonth);
                            stmt.AddParam("p_second_day_of_month", MTParameterType.Integer, usageCycleData.SecondDayOfMonth);
                            stmt.AddParam("p_start_day", MTParameterType.Integer, usageCycleData.StartDay);
                            stmt.AddParam("p_start_month", MTParameterType.Integer, usageCycleData.StartMonth);
                            stmt.AddParam("p_start_year", MTParameterType.Integer, usageCycleData.StartYear);
                            // Record the changed item to the change info for auditing
                            if (internalView.UsageCycleType != dbAccount.UsageCycleType)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("USAGE_CYCLE_WAS"), dbAccount.UsageCycleType, internalView.UsageCycleType);
                            }

                            if (account.DayOfMonth != dbAccount.DayOfMonth)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("DAY_OF_MONTH_WAS"), (dbAccount.DayOfMonth != null ? dbAccount.DayOfMonth.ToString() : "NULL"),
                                  (account.DayOfMonth != null ? account.DayOfMonth.ToString() : "NULL"));
                            }

                            if (account.DayOfWeek != dbAccount.DayOfWeek)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("DAY_OF_WEEK_WAS"), (dbAccount.DayOfWeek != null ? dbAccount.DayOfWeek.ToString() : "NULL"),
                                  (account.DayOfWeek != null ? account.DayOfWeek.ToString() : "NULL"));
                            }

                            if (account.FirstDayOfMonth != dbAccount.FirstDayOfMonth)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("FIRST_DAY_OF_MONTH_WAS"), (dbAccount.FirstDayOfMonth != null ? dbAccount.FirstDayOfMonth.ToString() : "NULL"),
                                  (account.FirstDayOfMonth != null ? account.FirstDayOfMonth.ToString() : "NULL"));
                            }

                            if (account.SecondDayOfMonth != dbAccount.SecondDayOfMonth)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("SECOND_DAY_OF_MONTH_WAS"), (dbAccount.SecondDayOfMonth != null ? dbAccount.SecondDayOfMonth.ToString() : "NULL"),
                                  (account.SecondDayOfMonth != null ? account.SecondDayOfMonth.ToString() : "NULL"));
                            }

                            if (account.StartDay != dbAccount.StartDay)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("START_DAY_WAS"), (dbAccount.StartDay != null ? dbAccount.StartDay.ToString() : "NULL"),
                                  (account.StartDay != null ? account.StartDay.ToString() : "NULL"));
                                //Even if the start month is the same, log it; the message is confusing to read otherwise.  If it's different, the month check will catch it
                                if (account.StartMonth == dbAccount.StartMonth)
                                {
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("START_MONTH_IS"), (dbAccount.StartMonth != null ? dbAccount.StartMonth.ToString() : "NULL"));
                                }
                            }

                            if (account.StartMonth != dbAccount.StartMonth)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("START_MONTH_WAS"), (dbAccount.StartMonth != null ? dbAccount.StartMonth.ToString() : "NULL"),
                                  (account.StartMonth != null ? account.StartMonth.ToString() : "NULL"));
                                //Even if the start day is the same, log it; the message is confusing to read otherwise.  If it's different, the day check will catch it
                                if (account.StartDay == dbAccount.StartDay)
                                {
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("START_DAY_IS"), (dbAccount.StartDay != null ? dbAccount.StartDay.ToString() : "NULL"));
                                }
                            }

                            if (account.StartYear != dbAccount.StartYear)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("START_YEAR_WAS"), (dbAccount.StartYear != null ? dbAccount.StartYear.ToString() : "NULL"),
                                  (account.StartYear != null ? account.StartYear.ToString() : "NULL"));
                            }
                        }
                        else
                        {
                            stmt.AddParam("p_id_cycle_type", MTParameterType.Integer, null);
                            stmt.AddParam("p_day_of_month", MTParameterType.Integer, null);
                            stmt.AddParam("p_day_of_week", MTParameterType.Integer, null);
                            stmt.AddParam("p_first_day_of_month", MTParameterType.Integer, null);
                            stmt.AddParam("p_second_day_of_month", MTParameterType.Integer, null);
                            stmt.AddParam("p_start_day", MTParameterType.Integer, null);
                            stmt.AddParam("p_start_month", MTParameterType.Integer, null);
                            stmt.AddParam("p_start_year", MTParameterType.Integer, null);
                        }

                        // Payer
                        if (updatePaymentInfo)
                        {
                            if (In_Account.PayerID.HasValue)
                            {
                                stmt.AddParam("p_id_payer", MTParameterType.Integer, In_Account.PayerID);
                                stmt.AddParam("p_payer_login", MTParameterType.WideString, null);
                                stmt.AddParam("p_payer_namespace", MTParameterType.WideString, null);
                                if (dbAccount.PayerID.Value != account.PayerID.Value)
                                {
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("PAYER_ID_WAS"), dbAccount.PayerID.Value, account.PayerID.Value);
                                }
                            }
                            else
                            {
                                stmt.AddParam("p_id_payer", MTParameterType.Integer, null);
                                stmt.AddParam("p_payer_login", MTParameterType.WideString, In_Account.PayerAccount);
                                stmt.AddParam("p_payer_namespace", MTParameterType.WideString, In_Account.PayerAccountNS);
                                if (dbAccount.PayerAccount.CompareTo(account.PayerAccount) != 0)
                                {
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("PAYER_ACCOUNT_WAS"), dbAccount.PayerAccount, account.PayerAccount);
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("PAYER_ACCOUNT_NS_WAS"), dbAccount.PayerAccountNS, account.PayerAccountNS);
                                }
                            }
                            stmt.AddParam("p_payer_startdate", MTParameterType.DateTime, In_Account.Payment_StartDate);
                            stmt.AddParam("p_payer_enddate", MTParameterType.DateTime, In_Account.Payment_EndDate);
                            if (account.IsPayment_StartDateDirty && DateTime.Compare(account.Payment_StartDate.Value.Date, dbAccount.Payment_StartDate.Value.Date) != 0)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("START_DATE_WAS"), dbAccount.Payment_StartDate.Value.Date, account.Payment_StartDate.Value.Date);
                            }
                            if (account.IsPayment_EndDateDirty && DateTime.Compare(account.Payment_EndDate.Value.Date, dbAccount.Payment_EndDate.Value.Date) != 0)
                            {
                                changeInfo += String.Format(resourceManager.GetLocalizedResource("END_DATE_WAS"), dbAccount.Payment_EndDate.Value.Date, account.Payment_EndDate.Value.Date);
                            }
                        }
                        else
                        {
                            stmt.AddParam("p_id_payer", MTParameterType.Integer, null);
                            stmt.AddParam("p_payer_login", MTParameterType.WideString, null);
                            stmt.AddParam("p_payer_namespace", MTParameterType.WideString, null);
                            stmt.AddParam("p_payer_startdate", MTParameterType.DateTime, null);
                            stmt.AddParam("p_payer_enddate", MTParameterType.DateTime, null);
                        }

                        // Ancestor
                        if (updateAncestorInfo)
                        {
                            if (In_Account.AncestorAccountID.HasValue)
                            {
                                stmt.AddParam("p_id_ancestor", MTParameterType.Integer, In_Account.AncestorAccountID);
                                stmt.AddParam("p_ancestor_name", MTParameterType.WideString, null);
                                stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, null);
                                if (dbAccount.AncestorAccountID.Value != account.AncestorAccountID.Value)
                                {
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("ANCESTOR_ACOUNT_ID_WAS"), dbAccount.AncestorAccountID.Value, account.AncestorAccountID.Value);

                                }
                            }
                            else
                            {
                                stmt.AddParam("p_id_ancestor", MTParameterType.Integer, null);
                                stmt.AddParam("p_ancestor_name", MTParameterType.WideString, In_Account.AncestorAccount);
                                stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, In_Account.AncestorAccountNS);
                                if (dbAccount.AncestorAccount.CompareTo(account.AncestorAccount) != 0)
                                {
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("ANCESTOR_ACOUNT_WAS"), dbAccount.AncestorAccount, account.AncestorAccount);
                                    changeInfo += String.Format(resourceManager.GetLocalizedResource("ANCESTOR_ACOUNT_NS_WAS"), dbAccount.AncestorAccountNS, account.AncestorAccountNS);
                                }

                            }
                            stmt.AddParam("p_hierarchy_movedate", MTParameterType.DateTime, In_Account.Hierarchy_StartDate);
                        }
                        else
                        {
                            stmt.AddParam("p_id_ancestor", MTParameterType.Integer, null);
                            stmt.AddParam("p_ancestor_name", MTParameterType.WideString, null);
                            stmt.AddParam("p_ancestor_namespace", MTParameterType.WideString, null);
                            stmt.AddParam("p_hierarchy_movedate", MTParameterType.DateTime, null);
                        }

                        stmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);

                        if (internalView.IsBillableDirty &&
                            internalView.Billable != dbAccount.Billable)
                        {
                            string billable = "Y";
                            if (internalView.Billable.Value == false)
                            {
                                billable = "N";
                            }
                            stmt.AddParam("p_billable", MTParameterType.String, billable);
                        }
                        else
                        {
                            stmt.AddParam("p_billable", MTParameterType.String, null);
                        }

                        // Convert to bool
                        PC.IMTProductCatalog productCatalog = new PC.MTProductCatalogClass();
                        string enforceSameCorporation = "1";
                        if (productCatalog.IsBusinessRuleEnabled(PC.MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == false)
                        {
                            enforceSameCorporation = "0";
                        }

                        stmt.AddParam("p_enforce_same_corporation", MTParameterType.String, enforceSameCorporation);
                        stmt.AddParam("p_account_currency", MTParameterType.WideString, internalView.Currency);

                        // Outputs
                        stmt.AddOutputParam("p_status", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_cyclechanged", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_newcycle", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_accountID", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_hierarchy_path", MTParameterType.String, 4000);
                        stmt.AddOutputParam("p_old_id_ancestor_out", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_id_ancestor_out", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_corporate_account_id", MTParameterType.Integer, 0);
                        stmt.AddOutputParam("p_ancestor_type", MTParameterType.String, 40);
                        stmt.AddOutputParam("p_acc_type", MTParameterType.String, 40);

                        stmt.ExecuteNonQuery();

                        int status = (int)stmt.GetOutputValue("p_status");

                        if (status == 1)
                        {
                            object dbValue = null;

                            dbValue = stmt.GetOutputValue("p_cyclechanged");
                            if (dbValue != System.DBNull.Value)
                            {
                                HasCycleChanged = EnumHelper.StringToBool(Convert.ToString((int)dbValue));
                            }

                            dbValue = stmt.GetOutputValue("p_newcycle");
                            if (dbValue != System.DBNull.Value)
                            {
                                NewCycleId = (int)dbValue;
                            }

                            dbValue = stmt.GetOutputValue("p_hierarchy_path");
                            if (dbValue != System.DBNull.Value)
                            {
                                HierarchyPath = (string)dbValue;
                                // Check account hierarchy capability
                                IMTSecurity security = new MTSecurityClass();
                                MetraTech.Interop.MTAuth.IMTCompositeCapability capability =
                                  security.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
                                capability.GetAtomicPathCapability().SetParameter(HierarchyPath,
                                                                                  MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE);
                                SessionContext.SecurityContext.CheckAccess(capability);
                            }

                            dbValue = stmt.GetOutputValue("p_old_id_ancestor_out");
                            if (dbValue != System.DBNull.Value)
                            {
                                OldAncestorId = (int)dbValue;
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

                            dbValue = stmt.GetOutputValue("p_ancestor_type");
                            if (dbValue != System.DBNull.Value)
                            {
                                AncestorType = (string)dbValue;
                            }

                            dbValue = stmt.GetOutputValue("p_acc_type");
                            if (dbValue != System.DBNull.Value)
                            {
                                AccountType = (string)dbValue;
                            }

                            if (!string.IsNullOrWhiteSpace(changeInfo))
                            {
                                auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_ACCOUNT_UPDATE, this.SessionContext.AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT, In_Account._AccountID.Value,
                                                  String.Format(resourceManager.GetLocalizedResource("SUCCESSFULLY_UPDATED_ACCOUNT_FOR"),
                                                  In_Account.UserName, In_Account._AccountID) + changeInfo, this.SessionContext.LoggedInAs, this.SessionContext.ApplicationName);

                            }
                            Logger.LogInfo("Successfully updated account for username '{0}' with id '{1}'",
                                           In_Account.UserName, In_Account._AccountID);
                        }
                        else
                        {
                            string error = GetErrorMsg(status);
                            Logger.LogError(error);
                            throw new MASBasicException(error);
                        }
                    }
                }

                // Update materialized views
                UpdateMaterializedViews(true);

        }

        private string GetErrorMsg(int status)
        {
            string error = String.Empty;
            switch (status)
            {
                case MTACCOUNT_RESOLUTION_FAILED:
                    {
                        error = MTACCOUNT_RESOLUTION_FAILED_MSG;
                        break;
                    }
                case MTACCOUNT_FAILED_PASSWORD_UPDATE:
                    {
                        error = MTACCOUNT_FAILED_PASSWORD_UPDATE_MSG;
                        break;
                    }
                case MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER:
                    {
                        error = MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER_MSG;
                        break;
                    }
                case MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER:
                    {
                        error = MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER_MSG;
                        break;
                    }
                case MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH:
                    {
                        error = MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH_MSG;
                        break;
                    }
                case MT_PAYMENTUPDATE_FAILED:
                    {
                        error = MT_PAYMENTUPDATE_FAILED_MSG;
                        break;
                    }
                case MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS:
                    {
                        error = MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS_MSG;
                        break;
                    }
                case MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE:
                    {
                        error = MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE_MSG;
                        break;
                    }
                case MT_NEW_PARENT_IS_A_CHILD:
                    {
                        error = MT_NEW_PARENT_IS_A_CHILD_MSG;
                        break;
                    }
                case MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES:
                    {
                        error = MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES_MSG;
                        break;
                    }
                case MT_CANNOT_RESOLVE_PAYING_ACCOUNT:
                    {
                        error = MT_CANNOT_RESOLVE_PAYING_ACCOUNT_MSG;
                        break;
                    }
                case MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER:
                    {
                        error = MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER_MSG;
                        break;
                    }
                case MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER:
                    {
                        error = MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER_MSG;
                        break;
                    }
                case MT_PAYMENT_UDDATE_END_DATE_INVALID:
                    {
                        error = MT_PAYMENT_UDDATE_END_DATE_INVALID_MSG;
                        break;
                    }
                case MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE:
                    {
                        error = MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE_MSG;
                        break;
                    }
                case MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE:
                    {
                        error = MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE_MSG;
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
                case MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER:
                    {
                        error = MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER_MSG;
                        break;
                    }
                case MTPCUSER_EBCR_RECEIVERS_CONFLICT_WITH_EACH_OTHER:
                    {
                        error = MTPCUSER_EBCR_RECEIVERS_CONFLICT_WITH_EACH_OTHER_MSG;
                        break;
                    }
                case MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE:
                    {
                        error = MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG;
                        break;
                    }
                case MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT:
                    {
                        error = MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT_MSG;
                        break;
                    }
                case OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED:
                    {
                        error = OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED_MSG;
                        break;
                    }
                case MT_CANNOT_MOVE_CORPORATE_ACCOUNT:
                    {
                        error = MT_CANNOT_MOVE_CORPORATE_ACCOUNT_MSG;
                        break;
                    }
                case MT_ANCESTOR_OF_INCORRECT_TYPE:
                    {
                        error = MT_ANCESTOR_OF_INCORRECT_TYPE_MSG;
                        break;
                    }
                case MT_ANCESTOR_INVALID_SYNTHETIC_ROOT:
                    {
                        error = MT_ANCESTOR_INVALID_SYNTHETIC_ROOT_MSG;
                        break;
                    }
                default:
                    {
                        // return error
                        error = String.Format("Unable to update account with status '{0}'.", status);
                        break;
                    }
            }

            return error;

        }

        private void CheckUpdateCapabilities(Account account, MetraTech.Interop.IMTAccountType.IMTAccountType accountType)
        {
            IMTSecurity security = new MTSecurityClass();
            MetraTech.Interop.MTAuth.IMTCompositeCapability capability = null;

            try
            {
                if (account is SystemAccount)
                {
                    capability = security.GetCapabilityTypeByName("Update CSR accounts").CreateInstance();
                }
                else
                {
                    if (accountType.IsCorporate)
                    {
                        capability = security.GetCapabilityTypeByName("Update corporate accounts").CreateInstance();
                    }
                    else
                    {
                        capability = security.GetCapabilityTypeByName("Update subscriber accounts").CreateInstance();
                    }
                }

                SessionContext.SecurityContext.CheckAccess(capability);
            }
            finally
            {
                Marshal.ReleaseComObject(security);
            }
        }

        private AccountUpdateData GetAccountUpdateData(int accountId,
                                                      DateTime? ancestorDate,
                                                      DateTime? paymentStartDate,
                                                      DateTime? accountStartDate)
        {
            AccountUpdateData accountUpdateData = new AccountUpdateData();

            DateTime ancestorDate1;
            DateTime paymentStartDate1;
            DateTime accountStartDate1;

            if (ancestorDate == null)
            {
                ancestorDate1 = MetraTime.Now;
            }
            else
            {
                ancestorDate1 = ancestorDate.Value;
            }

            if (paymentStartDate == null)
            {
                paymentStartDate1 = MetraTime.Now;
            }
            else
            {
                paymentStartDate1 = paymentStartDate.Value;
            }

            if (accountStartDate == null)
            {
                accountStartDate1 = MetraTime.Now;
            }
            else
            {
                accountStartDate1 = accountStartDate.Value;
            }

            // Execute the stored procedure "AddNewAccount"
            using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
            {
                using (IMTAdapterStatement stmt =
                  conn.CreateAdapterStatement(@"Queries\AccountCreation",
                                              "__FIND_PROPERTIES_ON_UPDATE_BY_ACCOUNTID__"))
                {

                    stmt.AddParam("%%ID_ACC%%", accountId, true);
                    stmt.AddParam("%%ANCESTORDATE%%", ancestorDate, true);
                    stmt.AddParam("%%PAYMENTDATE%%", paymentStartDate, true);
                    stmt.AddParam("%%STATEDATE%%", accountStartDate, true);

                    // add an update lock to prevent deadlocking later on down the road in updateaccount and child procs for SQL
                    if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
                        stmt.AddParam("%%ADD_LOCK%%", "with (updlock)", true);
                    else
                        stmt.AddParam("%%ADD_LOCK%%", "", true);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (!reader.IsDBNull("id_ancestor"))
                            {
                                accountUpdateData.AncestorAccountID = reader.GetInt32("id_ancestor");
                            }

                            if (!reader.IsDBNull("ancestor_nm_login"))
                            {
                                accountUpdateData.AncestorAccount = reader.GetString("ancestor_nm_login");
                            }

                            if (!reader.IsDBNull("ancestor_nm_space"))
                            {
                                accountUpdateData.AncestorAccountNS = reader.GetString("ancestor_nm_space");
                            }

                            if (!reader.IsDBNull("ancestor_vt_start"))
                            {
                                accountUpdateData.Hierarchy_StartDate = reader.GetDateTime("ancestor_vt_start");
                            }

                            if (!reader.IsDBNull("ancestor_vt_end"))
                            {
                                accountUpdateData.Hierarchy_EndDate = reader.GetDateTime("ancestor_vt_end");
                            }

                            if (!reader.IsDBNull("id_payer"))
                            {
                                accountUpdateData.PayerID = reader.GetInt32("id_payer");
                            }

                            if (!reader.IsDBNull("payer_nm_login"))
                            {
                                accountUpdateData.PayerAccount = reader.GetString("payer_nm_login");
                            }

                            if (!reader.IsDBNull("payer_nm_space"))
                            {
                                accountUpdateData.PayerAccountNS = reader.GetString("payer_nm_space");
                            }

                            if (!reader.IsDBNull("payer_vt_start"))
                            {
                                accountUpdateData.Payment_StartDate = reader.GetDateTime("payer_vt_start");
                            }

                            if (!reader.IsDBNull("payer_vt_end"))
                            {
                                accountUpdateData.Payment_EndDate = reader.GetDateTime("payer_vt_end");
                            }

                            if (!reader.IsDBNull("name"))
                            {
                                accountUpdateData.AccountType = reader.GetString("name");
                            }

                            if (!reader.IsDBNull("path"))
                            {
                                accountUpdateData.HierarchyPath = reader.GetString("path");
                            }

                            if (!reader.IsDBNull("status"))
                            {
                                accountUpdateData.AccountStatus =
                                  (AccountStatus)EnumHelper.GetGeneratedEnumByValue(typeof(AccountStatus), reader.GetString("status"));
                            }

                            if (!reader.IsDBNull("id_cycle_type"))
                            {
                                accountUpdateData.UsageCycleType =
                                  (UsageCycleType)EnumHelper.GetGeneratedEnumByValue(typeof(UsageCycleType), reader.GetInt32("id_cycle_type"));
                            }

                            if (!reader.IsDBNull("day_of_month"))
                            {
                                accountUpdateData.DayOfMonth = reader.GetInt32("day_of_month");
                            }

                            if (!reader.IsDBNull("day_of_week"))
                            {
                                accountUpdateData.DayOfWeek =
                                  (DayOfTheWeek)EnumHelper.GetGeneratedEnumByValue(typeof(DayOfTheWeek), reader.GetInt32("day_of_week"));
                            }

                            if (!reader.IsDBNull("first_day_of_month"))
                            {
                                accountUpdateData.FirstDayOfMonth = reader.GetInt32("first_day_of_month");
                            }

                            if (!reader.IsDBNull("second_day_of_month"))
                            {
                                accountUpdateData.SecondDayOfMonth = reader.GetInt32("second_day_of_month");
                            }

                            if (!reader.IsDBNull("start_day"))
                            {
                                accountUpdateData.StartDay = reader.GetInt32("start_day");
                            }

                            if (!reader.IsDBNull("start_month"))
                            {
                                accountUpdateData.StartMonth =
                                  (MonthOfTheYear)EnumHelper.GetGeneratedEnumByValue(typeof(MonthOfTheYear), reader.GetInt32("start_month"));
                            }

                            if (!reader.IsDBNull("start_year"))
                            {
                                accountUpdateData.StartYear = reader.GetInt32("start_year");
                            }

                            if (!reader.IsDBNull("c_folder"))
                            {
                                accountUpdateData.Folder = EnumHelper.StringToBool(reader.GetString("c_folder"));
                            }

                            if (!reader.IsDBNull("c_billable"))
                            {
                                accountUpdateData.Billable = EnumHelper.StringToBool(reader.GetString("c_billable"));
                            }

                            break;
                        }
                    }
                }
            }

            return accountUpdateData;
        }

        #region Data
        public const string CANNOT_CHANGE_ACCOUNT_TYPE = "Changing the account type is not supported.";
        public const string BAD_ANCESTOR = "Only accounts whose type supports synthetic roots, can set the ancestor to the synthetic root, -1";
        public const string BAD_PAYER = "Only accounts whose type supports synthetic roots, can set the payer to the synthetic root, -1";
        public const string CANNOT_CHANGE_BILLING_CYCLE = "Billing cycle changes are not supported for this user";

        private const int MTACCOUNT_RESOLUTION_FAILED = -509673460;
        private const string MTACCOUNT_RESOLUTION_FAILED_MSG = "Failed to resolve account from login and namespace.";

        private const int MTACCOUNT_FAILED_PASSWORD_UPDATE = -509673461;
        private const string MTACCOUNT_FAILED_PASSWORD_UPDATE_MSG = "Failed to update the password because the account can not be found with the corresponding namespace.";

        private const int MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER = -289472439;
        private const string MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER_MSG =
          "The account pays for a participant subscribed to an aligned charge cycle and cannot change billing cycles.";

        private const int MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER = -289472438;
        private const string MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER_MSG =
          "The account pays for a charge account subscribed to an aligned charge cycle and cannot change billing cycles.";

        private const int MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER = -289472443;
        private const string MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER_MSG = "The specified billing cycle conflicts with the billing cycle of the payer";

        private const int MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER = -289472442;
        private const string MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER_MSG = "The specified billing cycle conflicts with other accounts paid for by the payer";

        private const int MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH = -486604730;
        private const string MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH_MSG =
          "The usage cycle of a member's payer or future payer does not match the usage cycle required by the group subscription.";

        private const int MT_PAYMENTUPDATE_FAILED = -486604781;
        private const string MT_PAYMENTUPDATE_FAILED_MSG = "Failed to update the payment record because the specified record does not exist.";

        private const int MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS = -486604767;
        private const string MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS_MSG = "The account cannot be marked as non-billable as it is paying for other subscribers (or itself) now or in the future.";

        private const int MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE = -486604750;
        private const string MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE_MSG = "The system cannot move an account effective before the start date of the folder or the account.";

        private const int MT_NEW_PARENT_IS_A_CHILD = -486604797;
        private const string MT_NEW_PARENT_IS_A_CHILD_MSG = "The move operation can not be completed because the new parent account is a child of the target account.";

        private const int MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES = -486604759;
        private const string MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES_MSG = "Cannot move account across corporate hierarchies.";

        private const int MT_CANNOT_RESOLVE_PAYING_ACCOUNT = -486604792;
        private const string MT_CANNOT_RESOLVE_PAYING_ACCOUNT_MSG = "Account Creation can not resolve the payer account from the login and namespace.";

        private const int MT_PAYMENT_UDDATE_END_DATE_INVALID = -486604780;
        private const string MT_PAYMENT_UDDATE_END_DATE_INVALID_MSG = "Payment update end date is invalid";

        private const int MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE = -486604749;
        private const string MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE_MSG = "Cannot move payer end date if current end date is infinity";

        private const int MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE = -486604748;
        private const string MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE_MSG = "Cannot move payer start date if current start date is the same as the account start date";

        private const int MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE = -486604753;
        private const string MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE_MSG = "The payer start date cannot be before the account start date";

        private const int MT_PAYMENT_START_AND_END_ARE_THE_SAME = -486604735;
        private const string MT_PAYMENT_START_AND_END_ARE_THE_SAME_MSG = "The payer start and end date cannot be the same";

        private const int MT_PAYMENT_START_AFTER_END = -486604734;
        private const string MT_PAYMENT_START_AFTER_END_MSG = "The payer start date is after the end date";

        private const int MT_ACCOUNT_IS_NOT_BILLABLE = -486604795;
        private const string MT_ACCOUNT_IS_NOT_BILLABLE_MSG = "The payer account is not billable";

        private const int MT_PAYER_IN_INVALID_STATE = -486604736;
        private const string MT_PAYER_IN_INVALID_STATE_MSG = "The payer account is in an invalid state";

        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH_SQL = -486604737;  // Error Condition Returned by SQL Server
        private const int MT_PAYER_PAYEE_CURRENCY_MISMATCH_ORC = -486604728;  // Error Condition Returned by Oracle
        private const string MT_PAYER_PAYEE_CURRENCY_MISMATCH_MSG = "The currency of the payer does not match the currency of the account";

        private const int MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT = -486604758;
        private const string MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT_MSG = "Accounts cannot pay for accounts belonging to other corporate accounts";

        private const int MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER = -289472441;
        private const string MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER_MSG = "The account's billing cycle conflicts with the group subscription receiver's payer's billing cycle";

        private const int MTPCUSER_EBCR_RECEIVERS_CONFLICT_WITH_EACH_OTHER = -289472440;
        private const string MTPCUSER_EBCR_RECEIVERS_CONFLICT_WITH_EACH_OTHER_MSG = "The group subscription's receiver's billing cycles conflict with each other";

        private const int MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE = -289472464;
        private const string MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE_MSG = "The user is subscribed to a product offering that requires all the payers to be on the same cycle";

        private const int MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT = -486604791;
        private const string MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT_MSG = "Cannot resolve ancestor account";

        private const int OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED = -469368827;
        private const string OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED_MSG = "Cannot move an account that is in the closed or archived state";

        private const int MT_CANNOT_MOVE_CORPORATE_ACCOUNT = -486604770;
        private const string MT_CANNOT_MOVE_CORPORATE_ACCOUNT_MSG = "Cannot move a corporate account";

        private const int MT_ANCESTOR_OF_INCORRECT_TYPE = -486604714;
        private const string MT_ANCESTOR_OF_INCORRECT_TYPE_MSG = "Specified ancestor account is of an incorrect type";

        private const int MT_ANCESTOR_INVALID_SYNTHETIC_ROOT = -486604713;
        private const string MT_ANCESTOR_INVALID_SYNTHETIC_ROOT_MSG = "Account cannot have synthetic root as an ancestor account";
        #endregion
    }

    public class AccountUpdateData
    {
        public Nullable<UsageCycleType> UsageCycleType;
        public int? DayOfMonth;
        public Nullable<DayOfTheWeek> DayOfWeek;
        public int? FirstDayOfMonth;
        public int? SecondDayOfMonth;
        public int? StartDay;
        public Nullable<MonthOfTheYear> StartMonth;
        public int? StartYear;

        public int? PayerID;
        public string PayerAccount;
        public string PayerAccountNS;
        public DateTime? Payment_StartDate;
        public DateTime? Payment_EndDate;

        public int? AncestorAccountID;
        public string AncestorAccount;
        public string AncestorAccountNS;
        public DateTime? Hierarchy_StartDate;
        public DateTime? Hierarchy_EndDate;

        public string AccountType;
        public string HierarchyPath;
        public Nullable<AccountStatus> AccountStatus;

        public Nullable<bool> Billable;
        public Nullable<bool> Folder;
    }
}

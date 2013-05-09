using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Xml;
using Lexicons;
using log4net;


namespace NetMeterObj
{
    

    public partial class NetMeterObj
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(NetMeterObj));
        public static List<BeLdpAudCalllogentry> BeLdpAudCalllogentryList;
        public static List<BeLdpAudCalllogreason> BeLdpAudCalllogreasonList;
        public static List<AccUsage> AccUsageList;
        public static List<PvLdperfSimplePV> PvLdperfSimplePVList;
        public static List<PvFlatRecurringCharge> PvFlatRecurringChargeList;
        public static List<AccUsageInterval> AccUsageIntervalList;
        public static List<AccUsageCycle> AccUsageCycleList;
        public static List<UsageCycle> UsageCycleList;
        public static List<Account> AccountList;
        public static List<AccountMapper> AccountMapperList;
        public static List<AccountState> AccountStateList;
        public static List<AccountStateHistory> AccountStateHistoryList;
        public static List<AccountType> AccountTypeList;
        public static List<AccountAncestor> AccountAncestorList;
        public static List<AvInternal> AvInternalList;
        public static List<AvContact> AvContactList;
        public static List<DmAccount> DmAccountList;
        public static List<DmAccountAncestor> DmAccountAncestorList;
        public static List<CapabilityInstance> CapabilityInstanceList;
        public static List<PathCapability> PathCapabilityList;
        public static List<EnumCapability> EnumCapabilityList;
        public static List<Partition> PartitionList;
        public static List<PaymentRedirection> PaymentRedirectionList;
        public static List<PaymentRedirHistory> PaymentRedirHistoryList;
        public static List<PolicyRole> PolicyRoleList;
        public static List<PrincipalPolicy> PrincipalPolicyList;
        public static List<ProdView> ProdViewList;
        public static List<Profile> ProfileList;
        public static List<Role> RoleList;
        public static List<SiteUser> SiteUserList;
        public static List<UsageInterval> UsageIntervalList;
        public static List<UserCredentials> UserCredentialsList;
        public static List<Sub> SubList;
        public static List<SubHistory> SubHistoryList;

        public static Dictionary<Int32, AccUsageCycle> AccUsageCycleBy_id_acc;
        public static Dictionary<Int32, Account> AccountBy_id_acc;
        public static Dictionary<Int32, AccountState> AccountStateBy_id_acc;
        public static Lexicon<Int32, AccountStateHistory> AccountStateHistoryBy_id_acc;
        public static Lexicon<Int32, AccountAncestor> AccountAncestorBy_id_ancestor;
        public static Lexicon<Int32, AccountAncestor> AccountAncestorBy_id_descendent;
        public static Lexicon<Int32, DmAccount> DmAccountBy_id_acc;
        public static Lexicon<Int32, DmAccountAncestor> DmAccountAncestorBy_id_dm_ancestor;
        public static Lexicon<Int32, DmAccountAncestor> DmAccountAncestorBy_id_dm_descendent;
        public static Lexicon<Int32, AccountMapper> AccountMapperBy_id_acc;
        public static Dictionary<Tuple<String, String>, AccountMapper> AccountMapperBy_nm_login_nm_space;
        public static Dictionary<Tuple<String, String>, UserCredentials> UserCredentialsBy_nm_login_nm_space;
        public static Dictionary<Int32, AccountType> AccountTypeBy_id_type;
        public static Dictionary<String, AccountType> AccountTypeBy_name;
        public static Dictionary<Int32, Role> RoleBy_id_role;
        public static Dictionary<String, Role> RoleBy_tx_name;
        public static Lexicon<Int32, PrincipalPolicy> PrincipalPolicyBy_id_acc;
        public static Lexicon<Int32, CapabilityInstance> CapabilityInstanceBy_id_policy;
        public static Dictionary<Int32, UsageCycle> UsageCycleBy_id_usage_cycle;
        public static Lexicon<Int32, UsageInterval> UsageIntervalBy_id_usage_cycle;
        public static Dictionary<Int32, ProdView> ProdViewBy_id_prod_view;
        public static Dictionary<String, ProdView> ProdViewBy_nm_name;
        public static Lexicon<Int32, Sub> SubBy_id_acc;

        public void loadLists(DataContext dc)
        {
            BeLdpAudCalllogentryList = load<BeLdpAudCalllogentry>(dc, "t_be_ldp_aud_calllogentry");
            BeLdpAudCalllogreasonList = load<BeLdpAudCalllogreason>(dc, "t_be_ldp_aud_calllogreason");
            AccUsageList = load<AccUsage>(dc, "t_acc_usage");
            PvLdperfSimplePVList = load<PvLdperfSimplePV>(dc, "t_pv_ldperfSimplePV");
            PvFlatRecurringChargeList = load<PvFlatRecurringCharge>(dc, "t_pv_FlatRecurringCharge");
            AccUsageIntervalList = load<AccUsageInterval>(dc, "t_acc_usage_interval");
            AccUsageCycleList = load<AccUsageCycle>(dc, "t_acc_usage_cycle");
            UsageCycleList = load<UsageCycle>(dc, "t_usage_cycle");
            AccountList = load<Account>(dc, "t_account");
            AccountMapperList = load<AccountMapper>(dc, "t_account_mapper");
            AccountStateList = load<AccountState>(dc, "t_account_state");
            AccountStateHistoryList = load<AccountStateHistory>(dc, "t_account_state_history");
            AccountTypeList = load<AccountType>(dc, "t_account_type");
            AccountAncestorList = load<AccountAncestor>(dc, "t_account_ancestor");
            AvInternalList = load<AvInternal>(dc, "t_av_internal");
            AvContactList = load<AvContact>(dc, "t_av_contact");
            DmAccountList = load<DmAccount>(dc, "t_dm_account");
            DmAccountAncestorList = load<DmAccountAncestor>(dc, "t_dm_account_ancestor");
            CapabilityInstanceList = load<CapabilityInstance>(dc, "t_capability_instance");
            PathCapabilityList = load<PathCapability>(dc, "t_path_capability");
            EnumCapabilityList = load<EnumCapability>(dc, "t_enum_capability");
            PartitionList = load<Partition>(dc, "t_partition");
            PaymentRedirectionList = load<PaymentRedirection>(dc, "t_payment_redirection");
            PaymentRedirHistoryList = load<PaymentRedirHistory>(dc, "t_payment_redir_history");
            PolicyRoleList = load<PolicyRole>(dc, "t_policy_role");
            PrincipalPolicyList = load<PrincipalPolicy>(dc, "t_principal_policy");
            ProdViewList = load<ProdView>(dc, "t_prod_view");
            ProfileList = load<Profile>(dc, "t_profile");
            RoleList = load<Role>(dc, "t_role");
            SiteUserList = load<SiteUser>(dc, "t_site_user");
            UsageIntervalList = load<UsageInterval>(dc, "t_usage_interval");
            UserCredentialsList = load<UserCredentials>(dc, "t_user_credentials");
#if false
            SubList = load<Sub>(dc, "t_sub");
            SubHistoryList = load<SubHistory>(dc, "t_sub_history");
#else
            SubList = new List<Sub>();
            SubHistoryList = new List<SubHistory>();
#endif

            AccUsageCycleBy_id_acc = new Dictionary<Int32, AccUsageCycle>();
            foreach (var item in AccUsageCycleList)
            {
                AccUsageCycleBy_id_acc.Add(item.id_acc, item);
            }
            AccountBy_id_acc = new Dictionary<Int32, Account>();
            foreach (var item in AccountList)
            {
                AccountBy_id_acc.Add(item.id_acc, item);
            }
            AccountStateBy_id_acc = new Dictionary<Int32, AccountState>();
            foreach (var item in AccountStateList)
            {
                AccountStateBy_id_acc.Add(item.id_acc, item);
            }
            AccountStateHistoryBy_id_acc = new Lexicon<Int32, AccountStateHistory>();
            foreach (var item in AccountStateHistoryList)
            {
                AccountStateHistoryBy_id_acc.Add(item.id_acc, item);
            }
            AccountAncestorBy_id_ancestor = new Lexicon<Int32, AccountAncestor>();
            foreach (var item in AccountAncestorList)
            {
                AccountAncestorBy_id_ancestor.Add(item.id_ancestor, item);
            }
            AccountAncestorBy_id_descendent = new Lexicon<Int32, AccountAncestor>();
            foreach (var item in AccountAncestorList)
            {
                AccountAncestorBy_id_descendent.Add(item.id_descendent, item);
            }
            DmAccountBy_id_acc = new Lexicon<Int32, DmAccount>();
            foreach (var item in DmAccountList)
            {
                if (item.id_acc == null) continue;
                DmAccountBy_id_acc.Add((Int32)item.id_acc, item);
            }
            DmAccountAncestorBy_id_dm_ancestor = new Lexicon<Int32, DmAccountAncestor>();
            foreach (var item in DmAccountAncestorList)
            {
                if (item.id_dm_ancestor == null) continue;
                DmAccountAncestorBy_id_dm_ancestor.Add((Int32)item.id_dm_ancestor, item);
            }
            DmAccountAncestorBy_id_dm_descendent = new Lexicon<Int32, DmAccountAncestor>();
            foreach (var item in DmAccountAncestorList)
            {
                if (item.id_dm_descendent == null) continue;
                DmAccountAncestorBy_id_dm_descendent.Add((Int32)item.id_dm_descendent, item);
            }
            AccountMapperBy_id_acc = new Lexicon<Int32, AccountMapper>();
            foreach (var item in AccountMapperList)
            {
                AccountMapperBy_id_acc.Add(item.id_acc, item);
            }
            AccountMapperBy_nm_login_nm_space = new Dictionary<Tuple<String, String>, AccountMapper>();
            foreach (var item in AccountMapperList)
            {
                AccountMapperBy_nm_login_nm_space.Add(new Tuple<String, String>(item.nm_login, item.nm_space), item);
            }
            UserCredentialsBy_nm_login_nm_space = new Dictionary<Tuple<String, String>, UserCredentials>();
            foreach (var item in UserCredentialsList)
            {
                UserCredentialsBy_nm_login_nm_space.Add(new Tuple<String, String>(item.nm_login, item.nm_space), item);
            }
            AccountTypeBy_id_type = new Dictionary<Int32, AccountType>();
            foreach (var item in AccountTypeList)
            {
                AccountTypeBy_id_type.Add(item.id_type, item);
            }
            AccountTypeBy_name = new Dictionary<String, AccountType>();
            foreach (var item in AccountTypeList)
            {
                AccountTypeBy_name.Add(item.name, item);
            }
            RoleBy_id_role = new Dictionary<Int32, Role>();
            foreach (var item in RoleList)
            {
                RoleBy_id_role.Add(item.id_role, item);
            }
            RoleBy_tx_name = new Dictionary<String, Role>();
            foreach (var item in RoleList)
            {
                RoleBy_tx_name.Add(item.tx_name, item);
            }
            PrincipalPolicyBy_id_acc = new Lexicon<Int32, PrincipalPolicy>();
            foreach (var item in PrincipalPolicyList)
            {
                if (item.id_acc == null) continue;
                PrincipalPolicyBy_id_acc.Add((Int32)item.id_acc, item);
            }
            CapabilityInstanceBy_id_policy = new Lexicon<Int32, CapabilityInstance>();
            foreach (var item in CapabilityInstanceList)
            {
                CapabilityInstanceBy_id_policy.Add(item.id_policy, item);
            }
            UsageCycleBy_id_usage_cycle = new Dictionary<Int32, UsageCycle>();
            foreach (var item in UsageCycleList)
            {
                UsageCycleBy_id_usage_cycle.Add(item.id_usage_cycle, item);
            }
            UsageIntervalBy_id_usage_cycle = new Lexicon<Int32, UsageInterval>();
            foreach (var item in UsageIntervalList)
            {
                UsageIntervalBy_id_usage_cycle.Add(item.id_usage_cycle, item);
            }
            ProdViewBy_id_prod_view = new Dictionary<Int32, ProdView>();
            foreach (var item in ProdViewList)
            {
                ProdViewBy_id_prod_view.Add(item.id_prod_view, item);
            }
            ProdViewBy_nm_name = new Dictionary<String, ProdView>();
            foreach (var item in ProdViewList)
            {
                if (item.nm_name == null) continue;
                ProdViewBy_nm_name.Add(item.nm_name, item);
            }
            SubBy_id_acc = new Lexicon<Int32, Sub>();
            foreach (var item in SubList)
            {
                if (item.id_acc == null) continue;
                SubBy_id_acc.Add((Int32)item.id_acc, item);
            }
        }
        public void createAdapterWidgets()
        {
            BeLdpAudCalllogentry.adapterWidget = AdapterWidgetFactory.create("t_be_ldp_aud_calllogentry");
            BeLdpAudCalllogreason.adapterWidget = AdapterWidgetFactory.create("t_be_ldp_aud_calllogreason");
            AccUsage.adapterWidget = AdapterWidgetFactory.create("t_acc_usage");
            PvLdperfSimplePV.adapterWidget = AdapterWidgetFactory.create("t_pv_ldperfSimplePV");
            PvFlatRecurringCharge.adapterWidget = AdapterWidgetFactory.create("t_pv_FlatRecurringCharge");
            AccUsageInterval.adapterWidget = AdapterWidgetFactory.create("t_acc_usage_interval");
            AccUsageCycle.adapterWidget = AdapterWidgetFactory.create("t_acc_usage_cycle");
            UsageCycle.adapterWidget = AdapterWidgetFactory.create("t_usage_cycle");
            Account.adapterWidget = AdapterWidgetFactory.create("t_account");
            AccountMapper.adapterWidget = AdapterWidgetFactory.create("t_account_mapper");
            AccountState.adapterWidget = AdapterWidgetFactory.create("t_account_state");
            AccountStateHistory.adapterWidget = AdapterWidgetFactory.create("t_account_state_history");
            AccountType.adapterWidget = AdapterWidgetFactory.create("t_account_type");
            AccountAncestor.adapterWidget = AdapterWidgetFactory.create("t_account_ancestor");
            AvInternal.adapterWidget = AdapterWidgetFactory.create("t_av_internal");
            AvContact.adapterWidget = AdapterWidgetFactory.create("t_av_contact");
            DmAccount.adapterWidget = AdapterWidgetFactory.create("t_dm_account");
            DmAccountAncestor.adapterWidget = AdapterWidgetFactory.create("t_dm_account_ancestor");
            CapabilityInstance.adapterWidget = AdapterWidgetFactory.create("t_capability_instance");
            PathCapability.adapterWidget = AdapterWidgetFactory.create("t_path_capability");
            EnumCapability.adapterWidget = AdapterWidgetFactory.create("t_enum_capability");
            Partition.adapterWidget = AdapterWidgetFactory.create("t_partition");
            PaymentRedirection.adapterWidget = AdapterWidgetFactory.create("t_payment_redirection");
            PaymentRedirHistory.adapterWidget = AdapterWidgetFactory.create("t_payment_redir_history");
            PolicyRole.adapterWidget = AdapterWidgetFactory.create("t_policy_role");
            PrincipalPolicy.adapterWidget = AdapterWidgetFactory.create("t_principal_policy");
            ProdView.adapterWidget = AdapterWidgetFactory.create("t_prod_view");
            Profile.adapterWidget = AdapterWidgetFactory.create("t_profile");
            Role.adapterWidget = AdapterWidgetFactory.create("t_role");
            SiteUser.adapterWidget = AdapterWidgetFactory.create("t_site_user");
            UsageInterval.adapterWidget = AdapterWidgetFactory.create("t_usage_interval");
            UserCredentials.adapterWidget = AdapterWidgetFactory.create("t_user_credentials");
            Sub.adapterWidget = AdapterWidgetFactory.create("t_sub");
            SubHistory.adapterWidget = AdapterWidgetFactory.create("t_sub_history");
        }
    }

    [DataContract]
    public partial class BeLdpAudCalllogentry : IDbObj
    {
        [DataMember]
        public Guid c_CallLogEntry_Id { set; get; }
        [DataMember]
        public Int32 c__version { set; get; }
        [DataMember]
        public Guid c_internal_key { set; get; }
        [DataMember]
        public DateTime? c_CreationDate { set; get; }
        [DataMember]
        public DateTime? c_UpdateDate { set; get; }
        [DataMember]
        public Int32? c_UID { set; get; }
        [DataMember]
        public Int32? c_CallReasonEntryType { set; get; }
        [DataMember]
        public DateTime c_OccurrenceTime { set; get; }
        [DataMember]
        public Int32? c_CallLogReasonId { set; get; }
        [DataMember]
        public Int32 c_EntityId { set; get; }
        public string TableName() { return "t_be_ldp_aud_calllogentry"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("c_CallLogEntry_Id: ");
            sb.Append(c_CallLogEntry_Id);
            sb.AppendLine();
            sb.Append("c__version: ");
            sb.Append(c__version);
            sb.AppendLine();
            sb.Append("c_internal_key: ");
            sb.Append(c_internal_key);
            sb.AppendLine();
            sb.Append("c_CreationDate: ");
            sb.Append(c_CreationDate);
            sb.AppendLine();
            sb.Append("c_UpdateDate: ");
            sb.Append(c_UpdateDate);
            sb.AppendLine();
            sb.Append("c_UID: ");
            sb.Append(c_UID);
            sb.AppendLine();
            sb.Append("c_CallReasonEntryType: ");
            sb.Append(c_CallReasonEntryType);
            sb.AppendLine();
            sb.Append("c_OccurrenceTime: ");
            sb.Append(c_OccurrenceTime);
            sb.AppendLine();
            sb.Append("c_CallLogReasonId: ");
            sb.Append(c_CallLogReasonId);
            sb.AppendLine();
            sb.Append("c_EntityId: ");
            sb.Append(c_EntityId);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.c_CallLogEntry_Id;
            row[1] = this.c__version;
            row[2] = this.c_internal_key;
            if (this.c_CreationDate != null) row[3] = this.c_CreationDate;
            if (this.c_UpdateDate != null) row[4] = this.c_UpdateDate;
            if (this.c_UID != null) row[5] = this.c_UID;
            if (this.c_CallReasonEntryType != null) row[6] = this.c_CallReasonEntryType;
            row[7] = this.c_OccurrenceTime;
            if (this.c_CallLogReasonId != null) row[8] = this.c_CallLogReasonId;
            row[9] = this.c_EntityId;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class BeLdpAudCalllogreason : IDbObj
    {
        [DataMember]
        public Guid c_CallLogReason_Id { set; get; }
        [DataMember]
        public Int32 c__version { set; get; }
        [DataMember]
        public Guid c_internal_key { set; get; }
        [DataMember]
        public DateTime? c_CreationDate { set; get; }
        [DataMember]
        public DateTime? c_UpdateDate { set; get; }
        [DataMember]
        public Int32? c_UID { set; get; }
        [DataMember]
        public String c_IsActive { set; get; }
        [DataMember]
        public Int32? c_ViewIndexId { set; get; }
        [DataMember]
        public String c_CallLogReasonDesc { set; get; }
        public string TableName() { return "t_be_ldp_aud_calllogreason"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("c_CallLogReason_Id: ");
            sb.Append(c_CallLogReason_Id);
            sb.AppendLine();
            sb.Append("c__version: ");
            sb.Append(c__version);
            sb.AppendLine();
            sb.Append("c_internal_key: ");
            sb.Append(c_internal_key);
            sb.AppendLine();
            sb.Append("c_CreationDate: ");
            sb.Append(c_CreationDate);
            sb.AppendLine();
            sb.Append("c_UpdateDate: ");
            sb.Append(c_UpdateDate);
            sb.AppendLine();
            sb.Append("c_UID: ");
            sb.Append(c_UID);
            sb.AppendLine();
            sb.Append("c_IsActive: ");
            sb.Append(c_IsActive);
            sb.AppendLine();
            sb.Append("c_ViewIndexId: ");
            sb.Append(c_ViewIndexId);
            sb.AppendLine();
            sb.Append("c_CallLogReasonDesc: ");
            sb.Append(c_CallLogReasonDesc);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.c_CallLogReason_Id;
            row[1] = this.c__version;
            row[2] = this.c_internal_key;
            if (this.c_CreationDate != null) row[3] = this.c_CreationDate;
            if (this.c_UpdateDate != null) row[4] = this.c_UpdateDate;
            if (this.c_UID != null) row[5] = this.c_UID;
            row[6] = this.c_IsActive;
            if (this.c_ViewIndexId != null) row[7] = this.c_ViewIndexId;
            if (this.c_CallLogReasonDesc != null) row[8] = this.c_CallLogReasonDesc;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccUsage : IDbObj
    {
        [DataMember]
        public Int64 id_sess { set; get; }
        [DataMember]
        public Byte[] tx_UID { set; get; }
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public Int32 id_payee { set; get; }
        [DataMember]
        public Int32 id_view { set; get; }
        [DataMember]
        public Int32 id_usage_interval { set; get; }
        [DataMember]
        public Int64? id_parent_sess { set; get; }
        [DataMember]
        public Int32? id_prod { set; get; }
        [DataMember]
        public Int32 id_svc { set; get; }
        [DataMember]
        public DateTime dt_session { set; get; }
        [DataMember]
        public Decimal amount { set; get; }
        [DataMember]
        public String am_currency { set; get; }
        [DataMember]
        public DateTime dt_crt { set; get; }
        [DataMember]
        public Byte[] tx_batch { set; get; }
        [DataMember]
        public Decimal? tax_federal { set; get; }
        [DataMember]
        public Decimal? tax_state { set; get; }
        [DataMember]
        public Decimal? tax_county { set; get; }
        [DataMember]
        public Decimal? tax_local { set; get; }
        [DataMember]
        public Decimal? tax_other { set; get; }
        [DataMember]
        public Int32? id_pi_instance { set; get; }
        [DataMember]
        public Int32? id_pi_template { set; get; }
        [DataMember]
        public Int32 id_se { set; get; }
        [DataMember]
        public String div_currency { set; get; }
        [DataMember]
        public Decimal? div_amount { set; get; }
        public string TableName() { return "t_acc_usage"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_sess: ");
            sb.Append(id_sess);
            sb.AppendLine();
            sb.Append("tx_UID: ");
            sb.Append(tx_UID);
            sb.AppendLine();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_payee: ");
            sb.Append(id_payee);
            sb.AppendLine();
            sb.Append("id_view: ");
            sb.Append(id_view);
            sb.AppendLine();
            sb.Append("id_usage_interval: ");
            sb.Append(id_usage_interval);
            sb.AppendLine();
            sb.Append("id_parent_sess: ");
            sb.Append(id_parent_sess);
            sb.AppendLine();
            sb.Append("id_prod: ");
            sb.Append(id_prod);
            sb.AppendLine();
            sb.Append("id_svc: ");
            sb.Append(id_svc);
            sb.AppendLine();
            sb.Append("dt_session: ");
            sb.Append(dt_session);
            sb.AppendLine();
            sb.Append("amount: ");
            sb.Append(amount);
            sb.AppendLine();
            sb.Append("am_currency: ");
            sb.Append(am_currency);
            sb.AppendLine();
            sb.Append("dt_crt: ");
            sb.Append(dt_crt);
            sb.AppendLine();
            sb.Append("tx_batch: ");
            sb.Append(tx_batch);
            sb.AppendLine();
            sb.Append("tax_federal: ");
            sb.Append(tax_federal);
            sb.AppendLine();
            sb.Append("tax_state: ");
            sb.Append(tax_state);
            sb.AppendLine();
            sb.Append("tax_county: ");
            sb.Append(tax_county);
            sb.AppendLine();
            sb.Append("tax_local: ");
            sb.Append(tax_local);
            sb.AppendLine();
            sb.Append("tax_other: ");
            sb.Append(tax_other);
            sb.AppendLine();
            sb.Append("id_pi_instance: ");
            sb.Append(id_pi_instance);
            sb.AppendLine();
            sb.Append("id_pi_template: ");
            sb.Append(id_pi_template);
            sb.AppendLine();
            sb.Append("id_se: ");
            sb.Append(id_se);
            sb.AppendLine();
            sb.Append("div_currency: ");
            sb.Append(div_currency);
            sb.AppendLine();
            sb.Append("div_amount: ");
            sb.Append(div_amount);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_sess;
            row[1] = this.tx_UID;
            row[2] = this.id_acc;
            row[3] = this.id_payee;
            row[4] = this.id_view;
            row[5] = this.id_usage_interval;
            if (this.id_parent_sess != null) row[6] = this.id_parent_sess;
            if (this.id_prod != null) row[7] = this.id_prod;
            row[8] = this.id_svc;
            row[9] = this.dt_session;
            row[10] = this.amount;
            row[11] = this.am_currency;
            row[12] = this.dt_crt;
            if (this.tx_batch != null) row[13] = this.tx_batch;
            if (this.tax_federal != null) row[14] = this.tax_federal;
            if (this.tax_state != null) row[15] = this.tax_state;
            if (this.tax_county != null) row[16] = this.tax_county;
            if (this.tax_local != null) row[17] = this.tax_local;
            if (this.tax_other != null) row[18] = this.tax_other;
            if (this.id_pi_instance != null) row[19] = this.id_pi_instance;
            if (this.id_pi_template != null) row[20] = this.id_pi_template;
            row[21] = this.id_se;
            if (this.div_currency != null) row[22] = this.div_currency;
            if (this.div_amount != null) row[23] = this.div_amount;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PvLdperfSimplePV : IDbObj
    {
        [DataMember]
        public Int64 id_sess { set; get; }
        [DataMember]
        public Int32 id_usage_interval { set; get; }
        [DataMember]
        public String c_Notes { set; get; }
        public string TableName() { return "t_pv_ldperfSimplePV"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_sess: ");
            sb.Append(id_sess);
            sb.AppendLine();
            sb.Append("id_usage_interval: ");
            sb.Append(id_usage_interval);
            sb.AppendLine();
            sb.Append("c_Notes: ");
            sb.Append(c_Notes);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_sess;
            row[1] = this.id_usage_interval;
            if (this.c_Notes != null) row[2] = this.c_Notes;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccUsageInterval : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public Int32 id_usage_interval { set; get; }
        [DataMember]
        public String tx_status { set; get; }
        [DataMember]
        public DateTime? dt_effective { set; get; }
        public string TableName() { return "t_acc_usage_interval"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_usage_interval: ");
            sb.Append(id_usage_interval);
            sb.AppendLine();
            sb.Append("tx_status: ");
            sb.Append(tx_status);
            sb.AppendLine();
            sb.Append("dt_effective: ");
            sb.Append(dt_effective);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            row[1] = this.id_usage_interval;
            row[2] = this.tx_status;
            if (this.dt_effective != null) row[3] = this.dt_effective;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccUsageCycle : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public Int32 id_usage_cycle { set; get; }
        public string TableName() { return "t_acc_usage_cycle"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_usage_cycle: ");
            sb.Append(id_usage_cycle);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            row[1] = this.id_usage_cycle;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class UsageCycle : IDbObj
    {
        [DataMember]
        public Int32 id_usage_cycle { set; get; }
        [DataMember]
        public Int32 id_cycle_type { set; get; }
        [DataMember]
        public Int32? day_of_month { set; get; }
        [DataMember]
        public String tx_period_type { set; get; }
        [DataMember]
        public Int32? day_of_week { set; get; }
        [DataMember]
        public Int32? first_day_of_month { set; get; }
        [DataMember]
        public Int32? second_day_of_month { set; get; }
        [DataMember]
        public Int32? start_day { set; get; }
        [DataMember]
        public Int32? start_month { set; get; }
        [DataMember]
        public Int32? start_year { set; get; }
        public string TableName() { return "t_usage_cycle"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_usage_cycle: ");
            sb.Append(id_usage_cycle);
            sb.AppendLine();
            sb.Append("id_cycle_type: ");
            sb.Append(id_cycle_type);
            sb.AppendLine();
            sb.Append("day_of_month: ");
            sb.Append(day_of_month);
            sb.AppendLine();
            sb.Append("tx_period_type: ");
            sb.Append(tx_period_type);
            sb.AppendLine();
            sb.Append("day_of_week: ");
            sb.Append(day_of_week);
            sb.AppendLine();
            sb.Append("first_day_of_month: ");
            sb.Append(first_day_of_month);
            sb.AppendLine();
            sb.Append("second_day_of_month: ");
            sb.Append(second_day_of_month);
            sb.AppendLine();
            sb.Append("start_day: ");
            sb.Append(start_day);
            sb.AppendLine();
            sb.Append("start_month: ");
            sb.Append(start_month);
            sb.AppendLine();
            sb.Append("start_year: ");
            sb.Append(start_year);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_usage_cycle;
            row[1] = this.id_cycle_type;
            if (this.day_of_month != null) row[2] = this.day_of_month;
            row[3] = this.tx_period_type;
            if (this.day_of_week != null) row[4] = this.day_of_week;
            if (this.first_day_of_month != null) row[5] = this.first_day_of_month;
            if (this.second_day_of_month != null) row[6] = this.second_day_of_month;
            if (this.start_day != null) row[7] = this.start_day;
            if (this.start_month != null) row[8] = this.start_month;
            if (this.start_year != null) row[9] = this.start_year;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class Account : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public Byte[] id_acc_ext { set; get; }
        [DataMember]
        public Int32 id_type { set; get; }
        [DataMember]
        public DateTime dt_crt { set; get; }
        public string TableName() { return "t_account"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_acc_ext: ");
            sb.Append(id_acc_ext);
            sb.AppendLine();
            sb.Append("id_type: ");
            sb.Append(id_type);
            sb.AppendLine();
            sb.Append("dt_crt: ");
            sb.Append(dt_crt);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            row[1] = this.id_acc_ext;
            row[2] = this.id_type;
            row[3] = this.dt_crt;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccountMapper : IDbObj
    {
        [DataMember]
        public String nm_login { set; get; }
        [DataMember]
        public String nm_space { set; get; }
        [DataMember]
        public Int32 id_acc { set; get; }
        public string TableName() { return "t_account_mapper"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("nm_login: ");
            sb.Append(nm_login);
            sb.AppendLine();
            sb.Append("nm_space: ");
            sb.Append(nm_space);
            sb.AppendLine();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.nm_login;
            row[1] = this.nm_space;
            row[2] = this.id_acc;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccountState : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public String status { set; get; }
        [DataMember]
        public DateTime vt_start { set; get; }
        [DataMember]
        public DateTime vt_end { set; get; }
        public string TableName() { return "t_account_state"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("status: ");
            sb.Append(status);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            row[1] = this.status;
            row[2] = this.vt_start;
            row[3] = this.vt_end;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccountStateHistory : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public String status { set; get; }
        [DataMember]
        public DateTime vt_start { set; get; }
        [DataMember]
        public DateTime vt_end { set; get; }
        [DataMember]
        public DateTime tt_start { set; get; }
        [DataMember]
        public DateTime tt_end { set; get; }
        public string TableName() { return "t_account_state_history"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("status: ");
            sb.Append(status);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            sb.Append("tt_start: ");
            sb.Append(tt_start);
            sb.AppendLine();
            sb.Append("tt_end: ");
            sb.Append(tt_end);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            row[1] = this.status;
            row[2] = this.vt_start;
            row[3] = this.vt_end;
            row[4] = this.tt_start;
            row[5] = this.tt_end;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccountType : IDbObj
    {
        [DataMember]
        public Int32 id_type { set; get; }
        [DataMember]
        public String name { set; get; }
        [DataMember]
        public String b_CanSubscribe { set; get; }
        [DataMember]
        public String b_CanBePayer { set; get; }
        [DataMember]
        public String b_CanHaveSyntheticRoot { set; get; }
        [DataMember]
        public String b_CanParticipateInGSub { set; get; }
        [DataMember]
        public String b_IsVisibleInHierarchy { set; get; }
        [DataMember]
        public String b_CanHaveTemplates { set; get; }
        [DataMember]
        public String b_IsCorporate { set; get; }
        [DataMember]
        public String nm_description { set; get; }
        public string TableName() { return "t_account_type"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_type: ");
            sb.Append(id_type);
            sb.AppendLine();
            sb.Append("name: ");
            sb.Append(name);
            sb.AppendLine();
            sb.Append("b_CanSubscribe: ");
            sb.Append(b_CanSubscribe);
            sb.AppendLine();
            sb.Append("b_CanBePayer: ");
            sb.Append(b_CanBePayer);
            sb.AppendLine();
            sb.Append("b_CanHaveSyntheticRoot: ");
            sb.Append(b_CanHaveSyntheticRoot);
            sb.AppendLine();
            sb.Append("b_CanParticipateInGSub: ");
            sb.Append(b_CanParticipateInGSub);
            sb.AppendLine();
            sb.Append("b_IsVisibleInHierarchy: ");
            sb.Append(b_IsVisibleInHierarchy);
            sb.AppendLine();
            sb.Append("b_CanHaveTemplates: ");
            sb.Append(b_CanHaveTemplates);
            sb.AppendLine();
            sb.Append("b_IsCorporate: ");
            sb.Append(b_IsCorporate);
            sb.AppendLine();
            sb.Append("nm_description: ");
            sb.Append(nm_description);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_type;
            row[1] = this.name;
            row[2] = this.b_CanSubscribe;
            row[3] = this.b_CanBePayer;
            row[4] = this.b_CanHaveSyntheticRoot;
            row[5] = this.b_CanParticipateInGSub;
            row[6] = this.b_IsVisibleInHierarchy;
            row[7] = this.b_CanHaveTemplates;
            row[8] = this.b_IsCorporate;
            if (this.nm_description != null) row[9] = this.nm_description;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AccountAncestor : IDbObj
    {
        [DataMember]
        public Int32 id_ancestor { set; get; }
        [DataMember]
        public Int32 id_descendent { set; get; }
        [DataMember]
        public Int32 num_generations { set; get; }
        [DataMember]
        public String b_children { set; get; }
        [DataMember]
        public DateTime? vt_start { set; get; }
        [DataMember]
        public DateTime? vt_end { set; get; }
        [DataMember]
        public String tx_path { set; get; }
        public string TableName() { return "t_account_ancestor"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_ancestor: ");
            sb.Append(id_ancestor);
            sb.AppendLine();
            sb.Append("id_descendent: ");
            sb.Append(id_descendent);
            sb.AppendLine();
            sb.Append("num_generations: ");
            sb.Append(num_generations);
            sb.AppendLine();
            sb.Append("b_children: ");
            sb.Append(b_children);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            sb.Append("tx_path: ");
            sb.Append(tx_path);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_ancestor;
            row[1] = this.id_descendent;
            row[2] = this.num_generations;
            if (this.b_children != null) row[3] = this.b_children;
            if (this.vt_start != null) row[4] = this.vt_start;
            if (this.vt_end != null) row[5] = this.vt_end;
            row[6] = this.tx_path;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AvInternal : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public String c_TaxExempt { set; get; }
        [DataMember]
        public String c_TaxExemptID { set; get; }
        [DataMember]
        public Int32? c_TimezoneID { set; get; }
        [DataMember]
        public Int32? c_PaymentMethod { set; get; }
        [DataMember]
        public Int32? c_SecurityQuestion { set; get; }
        [DataMember]
        public String c_SecurityQuestionText { set; get; }
        [DataMember]
        public String c_SecurityAnswer { set; get; }
        [DataMember]
        public Int32? c_InvoiceMethod { set; get; }
        [DataMember]
        public Int32? c_UsageCycleType { set; get; }
        [DataMember]
        public Int32? c_Language { set; get; }
        [DataMember]
        public Int32? c_StatusReason { set; get; }
        [DataMember]
        public String c_StatusReasonOther { set; get; }
        [DataMember]
        public String c_Currency { set; get; }
        [DataMember]
        public Int32? c_PriceList { set; get; }
        [DataMember]
        public String c_Billable { set; get; }
        [DataMember]
        public String c_Folder { set; get; }
        [DataMember]
        public String c_Division { set; get; }
        [DataMember]
        public Int32? c_TaxVendor { set; get; }
        [DataMember]
        public Int32? c_MetraTaxCountryEligibility { set; get; }
        [DataMember]
        public Int32? c_MetraTaxCountryZone { set; get; }
        [DataMember]
        public String c_MetraTaxHasOverrideBand { set; get; }
        [DataMember]
        public Int32? c_MetraTaxOverrideBand { set; get; }
        [DataMember]
        public Int32? c_TaxServiceAddressPCode { set; get; }
        [DataMember]
        public Int32? c_TaxExemptReason { set; get; }
        [DataMember]
        public DateTime? c_TaxExemptStartDate { set; get; }
        [DataMember]
        public DateTime? c_TaxExemptEndDate { set; get; }
        [DataMember]
        public String c_TaxRegistryReference { set; get; }
        public string TableName() { return "t_av_internal"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("c_TaxExempt: ");
            sb.Append(c_TaxExempt);
            sb.AppendLine();
            sb.Append("c_TaxExemptID: ");
            sb.Append(c_TaxExemptID);
            sb.AppendLine();
            sb.Append("c_TimezoneID: ");
            sb.Append(c_TimezoneID);
            sb.AppendLine();
            sb.Append("c_PaymentMethod: ");
            sb.Append(c_PaymentMethod);
            sb.AppendLine();
            sb.Append("c_SecurityQuestion: ");
            sb.Append(c_SecurityQuestion);
            sb.AppendLine();
            sb.Append("c_SecurityQuestionText: ");
            sb.Append(c_SecurityQuestionText);
            sb.AppendLine();
            sb.Append("c_SecurityAnswer: ");
            sb.Append(c_SecurityAnswer);
            sb.AppendLine();
            sb.Append("c_InvoiceMethod: ");
            sb.Append(c_InvoiceMethod);
            sb.AppendLine();
            sb.Append("c_UsageCycleType: ");
            sb.Append(c_UsageCycleType);
            sb.AppendLine();
            sb.Append("c_Language: ");
            sb.Append(c_Language);
            sb.AppendLine();
            sb.Append("c_StatusReason: ");
            sb.Append(c_StatusReason);
            sb.AppendLine();
            sb.Append("c_StatusReasonOther: ");
            sb.Append(c_StatusReasonOther);
            sb.AppendLine();
            sb.Append("c_Currency: ");
            sb.Append(c_Currency);
            sb.AppendLine();
            sb.Append("c_PriceList: ");
            sb.Append(c_PriceList);
            sb.AppendLine();
            sb.Append("c_Billable: ");
            sb.Append(c_Billable);
            sb.AppendLine();
            sb.Append("c_Folder: ");
            sb.Append(c_Folder);
            sb.AppendLine();
            sb.Append("c_Division: ");
            sb.Append(c_Division);
            sb.AppendLine();
            sb.Append("c_TaxVendor: ");
            sb.Append(c_TaxVendor);
            sb.AppendLine();
            sb.Append("c_MetraTaxCountryEligibility: ");
            sb.Append(c_MetraTaxCountryEligibility);
            sb.AppendLine();
            sb.Append("c_MetraTaxCountryZone: ");
            sb.Append(c_MetraTaxCountryZone);
            sb.AppendLine();
            sb.Append("c_MetraTaxHasOverrideBand: ");
            sb.Append(c_MetraTaxHasOverrideBand);
            sb.AppendLine();
            sb.Append("c_MetraTaxOverrideBand: ");
            sb.Append(c_MetraTaxOverrideBand);
            sb.AppendLine();
            sb.Append("c_TaxServiceAddressPCode: ");
            sb.Append(c_TaxServiceAddressPCode);
            sb.AppendLine();
            sb.Append("c_TaxExemptReason: ");
            sb.Append(c_TaxExemptReason);
            sb.AppendLine();
            sb.Append("c_TaxExemptStartDate: ");
            sb.Append(c_TaxExemptStartDate);
            sb.AppendLine();
            sb.Append("c_TaxExemptEndDate: ");
            sb.Append(c_TaxExemptEndDate);
            sb.AppendLine();
            sb.Append("c_TaxRegistryReference: ");
            sb.Append(c_TaxRegistryReference);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            if (this.c_TaxExempt != null) row[1] = this.c_TaxExempt;
            if (this.c_TaxExemptID != null) row[2] = this.c_TaxExemptID;
            if (this.c_TimezoneID != null) row[3] = this.c_TimezoneID;
            if (this.c_PaymentMethod != null) row[4] = this.c_PaymentMethod;
            if (this.c_SecurityQuestion != null) row[5] = this.c_SecurityQuestion;
            if (this.c_SecurityQuestionText != null) row[6] = this.c_SecurityQuestionText;
            if (this.c_SecurityAnswer != null) row[7] = this.c_SecurityAnswer;
            if (this.c_InvoiceMethod != null) row[8] = this.c_InvoiceMethod;
            if (this.c_UsageCycleType != null) row[9] = this.c_UsageCycleType;
            if (this.c_Language != null) row[10] = this.c_Language;
            if (this.c_StatusReason != null) row[11] = this.c_StatusReason;
            if (this.c_StatusReasonOther != null) row[12] = this.c_StatusReasonOther;
            if (this.c_Currency != null) row[13] = this.c_Currency;
            if (this.c_PriceList != null) row[14] = this.c_PriceList;
            if (this.c_Billable != null) row[15] = this.c_Billable;
            if (this.c_Folder != null) row[16] = this.c_Folder;
            if (this.c_Division != null) row[17] = this.c_Division;
            if (this.c_TaxVendor != null) row[18] = this.c_TaxVendor;
            if (this.c_MetraTaxCountryEligibility != null) row[19] = this.c_MetraTaxCountryEligibility;
            if (this.c_MetraTaxCountryZone != null) row[20] = this.c_MetraTaxCountryZone;
            if (this.c_MetraTaxHasOverrideBand != null) row[21] = this.c_MetraTaxHasOverrideBand;
            if (this.c_MetraTaxOverrideBand != null) row[22] = this.c_MetraTaxOverrideBand;
            if (this.c_TaxServiceAddressPCode != null) row[23] = this.c_TaxServiceAddressPCode;
            if (this.c_TaxExemptReason != null) row[24] = this.c_TaxExemptReason;
            if (this.c_TaxExemptStartDate != null) row[25] = this.c_TaxExemptStartDate;
            if (this.c_TaxExemptEndDate != null) row[26] = this.c_TaxExemptEndDate;
            if (this.c_TaxRegistryReference != null) row[27] = this.c_TaxRegistryReference;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class AvContact : IDbObj
    {
        [DataMember]
        public Int32 id_acc { set; get; }
        [DataMember]
        public Int32 c_ContactType { set; get; }
        [DataMember]
        public String c_FirstName { set; get; }
        [DataMember]
        public String c_MiddleInitial { set; get; }
        [DataMember]
        public String c_LastName { set; get; }
        [DataMember]
        public String c_Email { set; get; }
        [DataMember]
        public String c_PhoneNumber { set; get; }
        [DataMember]
        public String c_Company { set; get; }
        [DataMember]
        public String c_Address1 { set; get; }
        [DataMember]
        public String c_Address2 { set; get; }
        [DataMember]
        public String c_Address3 { set; get; }
        [DataMember]
        public String c_City { set; get; }
        [DataMember]
        public String c_State { set; get; }
        [DataMember]
        public String c_Zip { set; get; }
        [DataMember]
        public Int32? c_Country { set; get; }
        [DataMember]
        public String c_FacsimileTelephoneNumber { set; get; }
        public string TableName() { return "t_av_contact"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("c_ContactType: ");
            sb.Append(c_ContactType);
            sb.AppendLine();
            sb.Append("c_FirstName: ");
            sb.Append(c_FirstName);
            sb.AppendLine();
            sb.Append("c_MiddleInitial: ");
            sb.Append(c_MiddleInitial);
            sb.AppendLine();
            sb.Append("c_LastName: ");
            sb.Append(c_LastName);
            sb.AppendLine();
            sb.Append("c_Email: ");
            sb.Append(c_Email);
            sb.AppendLine();
            sb.Append("c_PhoneNumber: ");
            sb.Append(c_PhoneNumber);
            sb.AppendLine();
            sb.Append("c_Company: ");
            sb.Append(c_Company);
            sb.AppendLine();
            sb.Append("c_Address1: ");
            sb.Append(c_Address1);
            sb.AppendLine();
            sb.Append("c_Address2: ");
            sb.Append(c_Address2);
            sb.AppendLine();
            sb.Append("c_Address3: ");
            sb.Append(c_Address3);
            sb.AppendLine();
            sb.Append("c_City: ");
            sb.Append(c_City);
            sb.AppendLine();
            sb.Append("c_State: ");
            sb.Append(c_State);
            sb.AppendLine();
            sb.Append("c_Zip: ");
            sb.Append(c_Zip);
            sb.AppendLine();
            sb.Append("c_Country: ");
            sb.Append(c_Country);
            sb.AppendLine();
            sb.Append("c_FacsimileTelephoneNumber: ");
            sb.Append(c_FacsimileTelephoneNumber);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_acc;
            row[1] = this.c_ContactType;
            if (this.c_FirstName != null) row[2] = this.c_FirstName;
            if (this.c_MiddleInitial != null) row[3] = this.c_MiddleInitial;
            if (this.c_LastName != null) row[4] = this.c_LastName;
            if (this.c_Email != null) row[5] = this.c_Email;
            if (this.c_PhoneNumber != null) row[6] = this.c_PhoneNumber;
            if (this.c_Company != null) row[7] = this.c_Company;
            if (this.c_Address1 != null) row[8] = this.c_Address1;
            if (this.c_Address2 != null) row[9] = this.c_Address2;
            if (this.c_Address3 != null) row[10] = this.c_Address3;
            if (this.c_City != null) row[11] = this.c_City;
            if (this.c_State != null) row[12] = this.c_State;
            if (this.c_Zip != null) row[13] = this.c_Zip;
            if (this.c_Country != null) row[14] = this.c_Country;
            if (this.c_FacsimileTelephoneNumber != null) row[15] = this.c_FacsimileTelephoneNumber;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class DmAccount : IDbObj
    {
        [DataMember]
        public Int32 id_dm_acc { set; get; }
        [DataMember]
        public Int32? id_acc { set; get; }
        [DataMember]
        public DateTime? vt_start { set; get; }
        [DataMember]
        public DateTime? vt_end { set; get; }
        public string TableName() { return "t_dm_account"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_dm_acc: ");
            sb.Append(id_dm_acc);
            sb.AppendLine();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_dm_acc;
            if (this.id_acc != null) row[1] = this.id_acc;
            if (this.vt_start != null) row[2] = this.vt_start;
            if (this.vt_end != null) row[3] = this.vt_end;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class DmAccountAncestor : IDbObj
    {
        [DataMember]
        public Int32? id_dm_ancestor { set; get; }
        [DataMember]
        public Int32? id_dm_descendent { set; get; }
        [DataMember]
        public Int32? num_generations { set; get; }
        public string TableName() { return "t_dm_account_ancestor"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_dm_ancestor: ");
            sb.Append(id_dm_ancestor);
            sb.AppendLine();
            sb.Append("id_dm_descendent: ");
            sb.Append(id_dm_descendent);
            sb.AppendLine();
            sb.Append("num_generations: ");
            sb.Append(num_generations);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            if (this.id_dm_ancestor != null) row[0] = this.id_dm_ancestor;
            if (this.id_dm_descendent != null) row[1] = this.id_dm_descendent;
            if (this.num_generations != null) row[2] = this.num_generations;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class CapabilityInstance : IDbObj
    {
        [DataMember]
        public Int32 id_cap_instance { set; get; }
        [DataMember]
        public Byte[] tx_guid { set; get; }
        [DataMember]
        public Int32? id_parent_cap_instance { set; get; }
        [DataMember]
        public Int32 id_policy { set; get; }
        [DataMember]
        public Int32 id_cap_type { set; get; }
        public string TableName() { return "t_capability_instance"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_cap_instance: ");
            sb.Append(id_cap_instance);
            sb.AppendLine();
            sb.Append("tx_guid: ");
            sb.Append(tx_guid);
            sb.AppendLine();
            sb.Append("id_parent_cap_instance: ");
            sb.Append(id_parent_cap_instance);
            sb.AppendLine();
            sb.Append("id_policy: ");
            sb.Append(id_policy);
            sb.AppendLine();
            sb.Append("id_cap_type: ");
            sb.Append(id_cap_type);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_cap_instance;
            if (this.tx_guid != null) row[1] = this.tx_guid;
            if (this.id_parent_cap_instance != null) row[2] = this.id_parent_cap_instance;
            row[3] = this.id_policy;
            row[4] = this.id_cap_type;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PathCapability : IDbObj
    {
        [DataMember]
        public Int32 id_cap_instance { set; get; }
        [DataMember]
        public String tx_param_name { set; get; }
        [DataMember]
        public String tx_op { set; get; }
        [DataMember]
        public String param_value { set; get; }
        public string TableName() { return "t_path_capability"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_cap_instance: ");
            sb.Append(id_cap_instance);
            sb.AppendLine();
            sb.Append("tx_param_name: ");
            sb.Append(tx_param_name);
            sb.AppendLine();
            sb.Append("tx_op: ");
            sb.Append(tx_op);
            sb.AppendLine();
            sb.Append("param_value: ");
            sb.Append(param_value);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_cap_instance;
            if (this.tx_param_name != null) row[1] = this.tx_param_name;
            if (this.tx_op != null) row[2] = this.tx_op;
            if (this.param_value != null) row[3] = this.param_value;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class EnumCapability : IDbObj
    {
        [DataMember]
        public Int32 id_cap_instance { set; get; }
        [DataMember]
        public String tx_param_name { set; get; }
        [DataMember]
        public String tx_op { set; get; }
        [DataMember]
        public Int32? param_value { set; get; }
        public string TableName() { return "t_enum_capability"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_cap_instance: ");
            sb.Append(id_cap_instance);
            sb.AppendLine();
            sb.Append("tx_param_name: ");
            sb.Append(tx_param_name);
            sb.AppendLine();
            sb.Append("tx_op: ");
            sb.Append(tx_op);
            sb.AppendLine();
            sb.Append("param_value: ");
            sb.Append(param_value);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_cap_instance;
            if (this.tx_param_name != null) row[1] = this.tx_param_name;
            row[2] = this.tx_op;
            if (this.param_value != null) row[3] = this.param_value;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class Partition : IDbObj
    {
        [DataMember]
        public Int32 id_partition { set; get; }
        [DataMember]
        public String partition_name { set; get; }
        [DataMember]
        public DateTime dt_start { set; get; }
        [DataMember]
        public DateTime dt_end { set; get; }
        [DataMember]
        public Int32 id_interval_start { set; get; }
        [DataMember]
        public Int32 id_interval_end { set; get; }
        [DataMember]
        public String b_default { set; get; }
        [DataMember]
        public String b_active { set; get; }
        public string TableName() { return "t_partition"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_partition: ");
            sb.Append(id_partition);
            sb.AppendLine();
            sb.Append("partition_name: ");
            sb.Append(partition_name);
            sb.AppendLine();
            sb.Append("dt_start: ");
            sb.Append(dt_start);
            sb.AppendLine();
            sb.Append("dt_end: ");
            sb.Append(dt_end);
            sb.AppendLine();
            sb.Append("id_interval_start: ");
            sb.Append(id_interval_start);
            sb.AppendLine();
            sb.Append("id_interval_end: ");
            sb.Append(id_interval_end);
            sb.AppendLine();
            sb.Append("b_default: ");
            sb.Append(b_default);
            sb.AppendLine();
            sb.Append("b_active: ");
            sb.Append(b_active);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_partition;
            row[1] = this.partition_name;
            row[2] = this.dt_start;
            row[3] = this.dt_end;
            row[4] = this.id_interval_start;
            row[5] = this.id_interval_end;
            row[6] = this.b_default;
            row[7] = this.b_active;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PaymentRedirection : IDbObj
    {
        [DataMember]
        public Int32 id_payer { set; get; }
        [DataMember]
        public Int32 id_payee { set; get; }
        [DataMember]
        public DateTime vt_start { set; get; }
        [DataMember]
        public DateTime vt_end { set; get; }
        public string TableName() { return "t_payment_redirection"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_payer: ");
            sb.Append(id_payer);
            sb.AppendLine();
            sb.Append("id_payee: ");
            sb.Append(id_payee);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_payer;
            row[1] = this.id_payee;
            row[2] = this.vt_start;
            row[3] = this.vt_end;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PaymentRedirHistory : IDbObj
    {
        [DataMember]
        public Int32 id_payer { set; get; }
        [DataMember]
        public Int32 id_payee { set; get; }
        [DataMember]
        public DateTime vt_start { set; get; }
        [DataMember]
        public DateTime vt_end { set; get; }
        [DataMember]
        public DateTime tt_start { set; get; }
        [DataMember]
        public DateTime tt_end { set; get; }
        public string TableName() { return "t_payment_redir_history"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_payer: ");
            sb.Append(id_payer);
            sb.AppendLine();
            sb.Append("id_payee: ");
            sb.Append(id_payee);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            sb.Append("tt_start: ");
            sb.Append(tt_start);
            sb.AppendLine();
            sb.Append("tt_end: ");
            sb.Append(tt_end);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_payer;
            row[1] = this.id_payee;
            row[2] = this.vt_start;
            row[3] = this.vt_end;
            row[4] = this.tt_start;
            row[5] = this.tt_end;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PolicyRole : IDbObj
    {
        [DataMember]
        public Int32 id_policy { set; get; }
        [DataMember]
        public Int32 id_role { set; get; }
        public string TableName() { return "t_policy_role"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_policy: ");
            sb.Append(id_policy);
            sb.AppendLine();
            sb.Append("id_role: ");
            sb.Append(id_role);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_policy;
            row[1] = this.id_role;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PrincipalPolicy : IDbObj
    {
        [DataMember]
        public Int32 id_policy { set; get; }
        [DataMember]
        public Int32? id_acc { set; get; }
        [DataMember]
        public Int32? id_role { set; get; }
        [DataMember]
        public String policy_type { set; get; }
        [DataMember]
        public String tx_name { set; get; }
        [DataMember]
        public String tx_desc { set; get; }
        public string TableName() { return "t_principal_policy"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_policy: ");
            sb.Append(id_policy);
            sb.AppendLine();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_role: ");
            sb.Append(id_role);
            sb.AppendLine();
            sb.Append("policy_type: ");
            sb.Append(policy_type);
            sb.AppendLine();
            sb.Append("tx_name: ");
            sb.Append(tx_name);
            sb.AppendLine();
            sb.Append("tx_desc: ");
            sb.Append(tx_desc);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_policy;
            if (this.id_acc != null) row[1] = this.id_acc;
            if (this.id_role != null) row[2] = this.id_role;
            if (this.policy_type != null) row[3] = this.policy_type;
            if (this.tx_name != null) row[4] = this.tx_name;
            if (this.tx_desc != null) row[5] = this.tx_desc;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class ProdView : IDbObj
    {
        [DataMember]
        public Int32 id_prod_view { set; get; }
        [DataMember]
        public Int32 id_view { set; get; }
        [DataMember]
        public DateTime? dt_modified { set; get; }
        [DataMember]
        public String nm_name { set; get; }
        [DataMember]
        public String nm_table_name { set; get; }
        [DataMember]
        public String b_can_resubmit_from { set; get; }
        public string TableName() { return "t_prod_view"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_prod_view: ");
            sb.Append(id_prod_view);
            sb.AppendLine();
            sb.Append("id_view: ");
            sb.Append(id_view);
            sb.AppendLine();
            sb.Append("dt_modified: ");
            sb.Append(dt_modified);
            sb.AppendLine();
            sb.Append("nm_name: ");
            sb.Append(nm_name);
            sb.AppendLine();
            sb.Append("nm_table_name: ");
            sb.Append(nm_table_name);
            sb.AppendLine();
            sb.Append("b_can_resubmit_from: ");
            sb.Append(b_can_resubmit_from);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_prod_view;
            row[1] = this.id_view;
            if (this.dt_modified != null) row[2] = this.dt_modified;
            if (this.nm_name != null) row[3] = this.nm_name;
            if (this.nm_table_name != null) row[4] = this.nm_table_name;
            row[5] = this.b_can_resubmit_from;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class Profile : IDbObj
    {
        [DataMember]
        public Int32 id_profile { set; get; }
        [DataMember]
        public String nm_tag { set; get; }
        [DataMember]
        public String val_tag { set; get; }
        [DataMember]
        public String tx_desc { set; get; }
        public string TableName() { return "t_profile"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_profile: ");
            sb.Append(id_profile);
            sb.AppendLine();
            sb.Append("nm_tag: ");
            sb.Append(nm_tag);
            sb.AppendLine();
            sb.Append("val_tag: ");
            sb.Append(val_tag);
            sb.AppendLine();
            sb.Append("tx_desc: ");
            sb.Append(tx_desc);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_profile;
            row[1] = this.nm_tag;
            if (this.val_tag != null) row[2] = this.val_tag;
            if (this.tx_desc != null) row[3] = this.tx_desc;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class Role : IDbObj
    {
        [DataMember]
        public Int32 id_role { set; get; }
        [DataMember]
        public Byte[] tx_guid { set; get; }
        [DataMember]
        public String tx_name { set; get; }
        [DataMember]
        public String tx_desc { set; get; }
        [DataMember]
        public String csr_assignable { set; get; }
        [DataMember]
        public String subscriber_assignable { set; get; }
        public string TableName() { return "t_role"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_role: ");
            sb.Append(id_role);
            sb.AppendLine();
            sb.Append("tx_guid: ");
            sb.Append(tx_guid);
            sb.AppendLine();
            sb.Append("tx_name: ");
            sb.Append(tx_name);
            sb.AppendLine();
            sb.Append("tx_desc: ");
            sb.Append(tx_desc);
            sb.AppendLine();
            sb.Append("csr_assignable: ");
            sb.Append(csr_assignable);
            sb.AppendLine();
            sb.Append("subscriber_assignable: ");
            sb.Append(subscriber_assignable);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_role;
            if (this.tx_guid != null) row[1] = this.tx_guid;
            row[2] = this.tx_name;
            row[3] = this.tx_desc;
            if (this.csr_assignable != null) row[4] = this.csr_assignable;
            if (this.subscriber_assignable != null) row[5] = this.subscriber_assignable;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class SiteUser : IDbObj
    {
        [DataMember]
        public String nm_login { set; get; }
        [DataMember]
        public Int32 id_site { set; get; }
        [DataMember]
        public Int32? id_profile { set; get; }
        public string TableName() { return "t_site_user"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("nm_login: ");
            sb.Append(nm_login);
            sb.AppendLine();
            sb.Append("id_site: ");
            sb.Append(id_site);
            sb.AppendLine();
            sb.Append("id_profile: ");
            sb.Append(id_profile);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.nm_login;
            row[1] = this.id_site;
            if (this.id_profile != null) row[2] = this.id_profile;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class UsageInterval : IDbObj
    {
        [DataMember]
        public Int32 id_interval { set; get; }
        [DataMember]
        public Int32 id_usage_cycle { set; get; }
        [DataMember]
        public DateTime dt_start { set; get; }
        [DataMember]
        public DateTime dt_end { set; get; }
        [DataMember]
        public String tx_interval_status { set; get; }
        public string TableName() { return "t_usage_interval"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_interval: ");
            sb.Append(id_interval);
            sb.AppendLine();
            sb.Append("id_usage_cycle: ");
            sb.Append(id_usage_cycle);
            sb.AppendLine();
            sb.Append("dt_start: ");
            sb.Append(dt_start);
            sb.AppendLine();
            sb.Append("dt_end: ");
            sb.Append(dt_end);
            sb.AppendLine();
            sb.Append("tx_interval_status: ");
            sb.Append(tx_interval_status);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_interval;
            row[1] = this.id_usage_cycle;
            row[2] = this.dt_start;
            row[3] = this.dt_end;
            row[4] = this.tx_interval_status;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class UserCredentials : IDbObj
    {
        [DataMember]
        public String nm_login { set; get; }
        [DataMember]
        public String nm_space { set; get; }
        [DataMember]
        public String tx_password { set; get; }
        [DataMember]
        public DateTime? dt_expire { set; get; }
        [DataMember]
        public DateTime? dt_last_login { set; get; }
        [DataMember]
        public DateTime? dt_last_logout { set; get; }
        [DataMember]
        public Int32? num_failures_since_login { set; get; }
        [DataMember]
        public DateTime? dt_auto_reset_failures { set; get; }
        [DataMember]
        public String b_enabled { set; get; }
        public string TableName() { return "t_user_credentials"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("nm_login: ");
            sb.Append(nm_login);
            sb.AppendLine();
            sb.Append("nm_space: ");
            sb.Append(nm_space);
            sb.AppendLine();
            sb.Append("tx_password: ");
            sb.Append(tx_password);
            sb.AppendLine();
            sb.Append("dt_expire: ");
            sb.Append(dt_expire);
            sb.AppendLine();
            sb.Append("dt_last_login: ");
            sb.Append(dt_last_login);
            sb.AppendLine();
            sb.Append("dt_last_logout: ");
            sb.Append(dt_last_logout);
            sb.AppendLine();
            sb.Append("num_failures_since_login: ");
            sb.Append(num_failures_since_login);
            sb.AppendLine();
            sb.Append("dt_auto_reset_failures: ");
            sb.Append(dt_auto_reset_failures);
            sb.AppendLine();
            sb.Append("b_enabled: ");
            sb.Append(b_enabled);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.nm_login;
            row[1] = this.nm_space;
            row[2] = this.tx_password;
            if (this.dt_expire != null) row[3] = this.dt_expire;
            if (this.dt_last_login != null) row[4] = this.dt_last_login;
            if (this.dt_last_logout != null) row[5] = this.dt_last_logout;
            if (this.num_failures_since_login != null) row[6] = this.num_failures_since_login;
            if (this.dt_auto_reset_failures != null) row[7] = this.dt_auto_reset_failures;
            if (this.b_enabled != null) row[8] = this.b_enabled;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class Sub : IDbObj
    {
        [DataMember]
        public Int32 id_sub { set; get; }
        [DataMember]
        public Byte[] id_sub_ext { set; get; }
        [DataMember]
        public Int32? id_acc { set; get; }
        [DataMember]
        public Int32 id_po { set; get; }
        [DataMember]
        public DateTime? dt_crt { set; get; }
        [DataMember]
        public DateTime vt_start { set; get; }
        [DataMember]
        public DateTime vt_end { set; get; }
        [DataMember]
        public Int32? id_group { set; get; }
        public string TableName() { return "t_sub"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_sub: ");
            sb.Append(id_sub);
            sb.AppendLine();
            sb.Append("id_sub_ext: ");
            sb.Append(id_sub_ext);
            sb.AppendLine();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_po: ");
            sb.Append(id_po);
            sb.AppendLine();
            sb.Append("dt_crt: ");
            sb.Append(dt_crt);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            sb.Append("id_group: ");
            sb.Append(id_group);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_sub;
            row[1] = this.id_sub_ext;
            if (this.id_acc != null) row[2] = this.id_acc;
            row[3] = this.id_po;
            if (this.dt_crt != null) row[4] = this.dt_crt;
            row[5] = this.vt_start;
            row[6] = this.vt_end;
            if (this.id_group != null) row[7] = this.id_group;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class SubHistory : IDbObj
    {
        [DataMember]
        public Int32? id_sub { set; get; }
        [DataMember]
        public Byte[] id_sub_ext { set; get; }
        [DataMember]
        public Int32? id_acc { set; get; }
        [DataMember]
        public Int32 id_po { set; get; }
        [DataMember]
        public DateTime dt_crt { set; get; }
        [DataMember]
        public Int32? id_group { set; get; }
        [DataMember]
        public DateTime vt_start { set; get; }
        [DataMember]
        public DateTime vt_end { set; get; }
        [DataMember]
        public DateTime tt_start { set; get; }
        [DataMember]
        public DateTime tt_end { set; get; }
        public string TableName() { return "t_sub_history"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_sub: ");
            sb.Append(id_sub);
            sb.AppendLine();
            sb.Append("id_sub_ext: ");
            sb.Append(id_sub_ext);
            sb.AppendLine();
            sb.Append("id_acc: ");
            sb.Append(id_acc);
            sb.AppendLine();
            sb.Append("id_po: ");
            sb.Append(id_po);
            sb.AppendLine();
            sb.Append("dt_crt: ");
            sb.Append(dt_crt);
            sb.AppendLine();
            sb.Append("id_group: ");
            sb.Append(id_group);
            sb.AppendLine();
            sb.Append("vt_start: ");
            sb.Append(vt_start);
            sb.AppendLine();
            sb.Append("vt_end: ");
            sb.Append(vt_end);
            sb.AppendLine();
            sb.Append("tt_start: ");
            sb.Append(tt_start);
            sb.AppendLine();
            sb.Append("tt_end: ");
            sb.Append(tt_end);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            if (this.id_sub != null) row[0] = this.id_sub;
            row[1] = this.id_sub_ext;
            if (this.id_acc != null) row[2] = this.id_acc;
            row[3] = this.id_po;
            row[4] = this.dt_crt;
            if (this.id_group != null) row[5] = this.id_group;
            row[6] = this.vt_start;
            row[7] = this.vt_end;
            row[8] = this.tt_start;
            row[9] = this.tt_end;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }

    [DataContract]
    public partial class PvFlatRecurringCharge : IDbObj
    {
        [DataMember]
        public Int64 id_sess { set; get; }
        [DataMember]
        public Int32 id_usage_interval { set; get; }
        [DataMember]
        public DateTime c_RCIntervalStart { set; get; }
        [DataMember]
        public DateTime c_RCIntervalEnd { set; get; }
        [DataMember]
        public DateTime c_BillingIntervalStart { set; get; }
        [DataMember]
        public DateTime c_BillingIntervalEnd { set; get; }
        [DataMember]
        public DateTime c_RCIntervalSubscriptionStart { set; get; }
        [DataMember]
        public DateTime c_RCIntervalSubscriptionEnd { set; get; }
        [DataMember]
        public String c_Advance { set; get; }
        [DataMember]
        public String c_ProrateOnSubscription { set; get; }
        [DataMember]
        public String c_ProrateInstantly { set; get; }
        [DataMember]
        public String c_ProrateOnUnsubscription { set; get; }
        [DataMember]
        public DateTime c_ProratedIntervalStart { set; get; }
        [DataMember]
        public DateTime c_ProratedIntervalEnd { set; get; }
        [DataMember]
        public Int32? c_ProratedDays { set; get; }
        [DataMember]
        public Decimal? c_ProratedDailyRate { set; get; }
        [DataMember]
        public Decimal? c_RCAmount { set; get; }
        [DataMember]
        public String c_ProratedOnSubscription { set; get; }
        [DataMember]
        public String c_ProratedInstantly { set; get; }
        [DataMember]
        public String c_ProratedOnUnsubscription { set; get; }
        public string TableName() { return "t_pv_FlatRecurringCharge"; }
        public static AdapterWidget adapterWidget;

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("id_sess: ");
            sb.Append(id_sess);
            sb.AppendLine();
            sb.Append("id_usage_interval: ");
            sb.Append(id_usage_interval);
            sb.AppendLine();
            sb.Append("c_RCIntervalStart: ");
            sb.Append(c_RCIntervalStart);
            sb.AppendLine();
            sb.Append("c_RCIntervalEnd: ");
            sb.Append(c_RCIntervalEnd);
            sb.AppendLine();
            sb.Append("c_BillingIntervalStart: ");
            sb.Append(c_BillingIntervalStart);
            sb.AppendLine();
            sb.Append("c_BillingIntervalEnd: ");
            sb.Append(c_BillingIntervalEnd);
            sb.AppendLine();
            sb.Append("c_RCIntervalSubscriptionStart: ");
            sb.Append(c_RCIntervalSubscriptionStart);
            sb.AppendLine();
            sb.Append("c_RCIntervalSubscriptionEnd: ");
            sb.Append(c_RCIntervalSubscriptionEnd);
            sb.AppendLine();
            sb.Append("c_Advance: ");
            sb.Append(c_Advance);
            sb.AppendLine();
            sb.Append("c_ProrateOnSubscription: ");
            sb.Append(c_ProrateOnSubscription);
            sb.AppendLine();
            sb.Append("c_ProrateInstantly: ");
            sb.Append(c_ProrateInstantly);
            sb.AppendLine();
            sb.Append("c_ProrateOnUnsubscription: ");
            sb.Append(c_ProrateOnUnsubscription);
            sb.AppendLine();
            sb.Append("c_ProratedIntervalStart: ");
            sb.Append(c_ProratedIntervalStart);
            sb.AppendLine();
            sb.Append("c_ProratedIntervalEnd: ");
            sb.Append(c_ProratedIntervalEnd);
            sb.AppendLine();
            sb.Append("c_ProratedDays: ");
            sb.Append(c_ProratedDays);
            sb.AppendLine();
            sb.Append("c_ProratedDailyRate: ");
            sb.Append(c_ProratedDailyRate);
            sb.AppendLine();
            sb.Append("c_RCAmount: ");
            sb.Append(c_RCAmount);
            sb.AppendLine();
            sb.Append("c_ProratedOnSubscription: ");
            sb.Append(c_ProratedOnSubscription);
            sb.AppendLine();
            sb.Append("c_ProratedInstantly: ");
            sb.Append(c_ProratedInstantly);
            sb.AppendLine();
            sb.Append("c_ProratedOnUnsubscription: ");
            sb.Append(c_ProratedOnUnsubscription);
            sb.AppendLine();
            return sb.ToString();
        }

        public void ToRow(DataRow row)
        {
            row[0] = this.id_sess;
            row[1] = this.id_usage_interval;
            row[2] = this.c_RCIntervalStart;
            row[3] = this.c_RCIntervalEnd;
            row[4] = this.c_BillingIntervalStart;
            row[5] = this.c_BillingIntervalEnd;
            row[6] = this.c_RCIntervalSubscriptionStart;
            row[7] = this.c_RCIntervalSubscriptionEnd;
            row[8] = this.c_Advance;
            row[9] = this.c_ProrateOnSubscription;
            row[10] = this.c_ProrateInstantly;
            row[11] = this.c_ProrateOnUnsubscription;
            row[12] = this.c_ProratedIntervalStart;
            row[13] = this.c_ProratedIntervalEnd;
            if (this.c_ProratedDays != null) row[14] = this.c_ProratedDays;
            if (this.c_ProratedDailyRate != null) row[15] = this.c_ProratedDailyRate;
            if (this.c_RCAmount != null) row[16] = this.c_RCAmount;
            row[17] = this.c_ProratedOnSubscription;
            row[18] = this.c_ProratedInstantly;
            row[19] = this.c_ProratedOnUnsubscription;
        }

        public void insert()
        {
            DataRow row = adapterWidget.createRow();
            ToRow(row);
            adapterWidget.insertRow(row);
        }
    }
}

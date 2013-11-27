using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using BaselineGUI;
using NetMeterObj;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Diagnostics;
using FakeSecurity;
using log4net;

namespace AppRefData
{
  public class AccountAggregate
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(AccountAggregate));

    static FCSecurity fcSecurity;

    public NetMeterObj.Account account = new NetMeterObj.Account();
    public AvInternal avInternal = new AvInternal();
    public List<AvContact> avContacts = new List<AvContact>();
    public AccountMapper accountMapper = new AccountMapper();
    public AccountState accountState = new AccountState();
    public AccountStateHistory accountStateHistory = new AccountStateHistory();
    // public static List<AccountType> AccountTypeList;
    public List<AccountAncestor> accountAncestors = new List<AccountAncestor>();
    public DmAccount dmAccount = new DmAccount();
    public List<DmAccountAncestor> dmAccountAncestor = new List<DmAccountAncestor>();
    public AccUsageInterval accUsageInterval = new AccUsageInterval();
    public AccUsageCycle accUsageCycle = new AccUsageCycle();
    public UsageInterval usageInterval = new UsageInterval();
    public List<CapabilityInstance> capabilityInstanceList = new List<CapabilityInstance>();
    public List<PathCapability> pathCapabilityList = new List<PathCapability>();
    public List<EnumCapability> enumCapabilityList = new List<EnumCapability>();
    public PolicyRole policyRole = new PolicyRole();
    public PrincipalPolicy principalPolicy = new PrincipalPolicy();
    public Profile profile = new Profile();
    //public static List<Role> RoleList;
    public SiteUser siteUser = new SiteUser();
    public UserCredentials userCredentials = new UserCredentials();
    public PaymentRedirection paymentRedirection = new PaymentRedirection();
    public PaymentRedirHistory paymentRedirHistory = new PaymentRedirHistory();

    //
    DateTime endOfTime = DateTime.Parse("2020-12-31 11:59:59");
    DateTime now = DateTime.Parse("2012-11-15 00:00:00");

    // Public attributes that are used to fill in things
    public string nm_space;
    public string nm_login;
    public string account_status = "AC";
    public Int32 id_parent = -10;
    public Int32 id_usage_cycle;
    public Int32 id_role;
    public Int32 id_site = 1000;
    public Int32 id_type;

    //List of ID's we need to allocate
    public Int32 id_acc;
    public Int32 id_dm_acc;
    public Int32 id_policy;
    public Int32 id_profile;

    static AccountAggregate()
    {
      fcSecurity = FrameworkComponentFactory.find<FCSecurity>();
    }


    public AccountAggregate()
    {
      account.id_acc_ext = new byte[16];
      initContactView();
    }

    public void initIDs()
    {
      id_acc = NetMeter.getMashedID32("id_acc");
      id_profile = NetMeter.getID32("id_profile");
      id_policy = NetMeter.getID32("id_policy");
      id_dm_acc = NetMeter.getID32("id_dm_acc");
    }

    public void pushAttributes()
    {

      account.id_acc = id_acc;
      account.id_type = id_type;
      account.dt_crt = DateTime.Now;


      addAccountState();

      dmAccount.id_dm_acc = id_dm_acc;
      dmAccount.id_acc = id_acc;
      dmAccount.vt_start = now;
      dmAccount.vt_end = endOfTime;
      buildDmAncestor();

      //AccUsageCycle
      accUsageCycle.id_acc = id_acc;
      accUsageCycle.id_usage_cycle = 33;


      addUserToAccount();
      buildAncestors();
      buildAvInternal();

      foreach (AvContact c in avContacts)
      {
        c.id_acc = id_acc;
      }

      buildPaymentRedirection();



      principalPolicy.id_policy = id_policy;
      principalPolicy.id_acc = id_acc;
      principalPolicy.id_role = null;
      principalPolicy.policy_type = "A";
      principalPolicy.tx_name = null;
      principalPolicy.tx_desc = null;

      policyRole.id_policy = id_policy;
      policyRole.id_role = NetMeter.RoleBy_tx_name["Subscriber (MetraView)"].id_role;

      addCapabilityManageAccountHierarchy();
    }

    private void addAccountState()
    {
      accountState.id_acc = id_acc;
      accountState.status = account_status;
      accountState.vt_start = now;
      accountState.vt_end = endOfTime;

      accountStateHistory.id_acc = id_acc;
      accountStateHistory.status = account_status;
      accountStateHistory.vt_start = now;
      accountStateHistory.vt_end = endOfTime;
      accountStateHistory.tt_start = now;
      accountStateHistory.tt_end = endOfTime;
    }

    private void initContactView()
    {
      AvContact contact = new AvContact();
      contact.c_ContactType = FastEnums.eContactType.Bill_To;
      contact.c_FirstName = "John";
      contact.c_LastName = "Smith";
      avContacts.Add(contact);
    }

    private void buildPaymentRedirection()
    {
      paymentRedirection.id_payee = id_acc;
      paymentRedirection.id_payer = id_acc;
      paymentRedirection.vt_start = now;
      paymentRedirection.vt_end = endOfTime;

      paymentRedirHistory.id_payee = id_acc;
      paymentRedirHistory.id_payer = id_acc;
      paymentRedirHistory.vt_start = now;
      paymentRedirHistory.vt_end = endOfTime;
      paymentRedirHistory.tt_start = now;
      paymentRedirHistory.tt_end = endOfTime;
    }


    private void addUserToAccount()
    {
      accountMapper.nm_space = nm_space;
      accountMapper.nm_login = nm_login;
      accountMapper.id_acc = id_acc;

      userCredentials.nm_login = nm_login;
      userCredentials.nm_space = nm_space;
      userCredentials.tx_password = fcSecurity.security.HashNewPassword("123", nm_login, nm_space);
      userCredentials.dt_expire = DateTime.Parse("2038-12-31 10:00:00");
      userCredentials.dt_last_login = DateTime.Parse("2012-12-01 10:00:00");
      userCredentials.dt_last_logout = DateTime.Parse("2012-12-01 11:00:00");
      userCredentials.dt_auto_reset_failures = DateTime.Parse("2012-12-01 11:00:00");
      userCredentials.num_failures_since_login = 0;

      // Why is this Y or N?
      userCredentials.b_enabled = "Y";

      profile.id_profile = id_profile;
      profile.nm_tag = "timeZoneID";
      profile.val_tag = "18";
      profile.tx_desc = "System";

      siteUser.nm_login = nm_login;
      siteUser.id_site = id_site;
      siteUser.id_profile = id_profile;
    }


    public void addCapabilityManageAccountHierarchy()
    {
      // TODO set tx_guid
      CapabilityInstance ci = new CapabilityInstance();
      CapabilityInstance cie = new CapabilityInstance();
      CapabilityInstance cip = new CapabilityInstance();

      EnumCapability ec = new EnumCapability();
      PathCapability pc = new PathCapability();

      ci.id_cap_instance = NetMeter.getID32("id_cap_instance");
      ci.id_parent_cap_instance = null;
      ci.id_policy = id_policy;
      ci.id_cap_type = 3; // Don't know why but... (now fixed)

      cip.id_cap_instance = NetMeter.getID32("id_cap_instance");
      cip.id_parent_cap_instance = ci.id_cap_instance;
      cip.id_policy = id_policy;
      cip.id_cap_type = 1; // path

      cie.id_cap_instance = NetMeter.getID32("id_cap_instance");
      cie.id_parent_cap_instance = ci.id_cap_instance;
      cie.id_policy = id_policy;
      cie.id_cap_type = 2; // enum

      ec.id_cap_instance = cie.id_cap_instance;
      ec.tx_op = "=";
      ec.tx_param_name = null;
      ec.param_value = 2;

      pc.id_cap_instance = cip.id_cap_instance;
      pc.param_value = getValueForPathCapability();
      pc.tx_op = null;
      pc.tx_param_name = null;

      capabilityInstanceList.Add(ci);
      capabilityInstanceList.Add(cip);
      capabilityInstanceList.Add(cie);
      enumCapabilityList.Add(ec);
      pathCapabilityList.Add(pc);
    }


    public string getValueForPathCapability()
    {
      List<AccountAncestor> ancestors = NetMeter.AccountAncestorBy_id_descendent[id_parent];

      Stack<int> path = new Stack<int>();
      path.Push(id_acc);
      int id = id_parent;
      while (id > 1)
      {
        path.Push(id);
        if (!NetMeter.AccountParent.ContainsKey(id))
          break;
        id = NetMeter.AccountParent[id];
      }

      // look for the greatest number of generations
      AccountAncestor oldest = null;
      foreach (var a in ancestors)
      {
        if (oldest == null || a.num_generations > oldest.num_generations)
        {
          oldest = a;
        }
      }

      string spath = "/";
      while (path.Count > 0)
      {
        id = path.Pop();
        spath += string.Format("{0}/", id);
      }

      string spath2 = String.Format("{0}/{1}/", oldest.tx_path, id_acc);

      if( spath != spath2)
      {
        log.ErrorFormat("Path mismatch {0} and {1}", spath, spath2);
      }
      else
      {
        log.DebugFormat("Paths match {0}", spath);
       }
      return spath2;
    }


    public void buildAncestors()
    {
      List<AccountAncestor> ancestors = NetMeter.AccountAncestorBy_id_descendent[id_parent];
      AccountAncestor parent = null;

      foreach (var a in ancestors)
      {
        AccountAncestor b = new AccountAncestor();
        b.id_ancestor = a.id_ancestor;
        b.id_descendent = id_acc;
        b.num_generations = a.num_generations + 1;
        b.vt_start = now;
        b.vt_end = endOfTime;
        if (a.tx_path.StartsWith("/"))
          b.tx_path = string.Format("{0}/{1}", a.tx_path, id_acc);
        else
          b.tx_path = string.Format("/{0}/{1}", a.tx_path, id_acc);

        accountAncestors.Add(b);

        if (a.id_ancestor == 1 && a.id_descendent == id_parent)
        {
          parent = a;
        }
      }
      AccountAncestor aa;

      aa = new AccountAncestor();
      aa.id_ancestor = id_acc;
      aa.id_descendent = id_acc;
      aa.num_generations = 0;
      aa.vt_start = now;
      aa.vt_end = endOfTime;
      aa.tx_path = string.Format("{0}", id_acc);
      accountAncestors.Add(aa);
    }


    public void buildDmAncestor()
    {
      // We have to get the dm equivalent for the parent
      List<DmAccount> dmParents = NetMeter.DmAccountBy_id_acc[id_parent];
      Int32 id_dm_parent = dmParents[0].id_dm_acc;

      List<DmAccountAncestor> ancestors = NetMeter.DmAccountAncestorBy_id_dm_descendent[id_dm_parent];

      foreach (var a in ancestors)
      {
        DmAccountAncestor b = new DmAccountAncestor();
        b.id_dm_ancestor = a.id_dm_ancestor;
        b.id_dm_descendent = id_dm_acc;
        b.num_generations = a.num_generations + 1;
        dmAccountAncestor.Add(b);
      }

      DmAccountAncestor aa;
      aa = new DmAccountAncestor();
      aa.id_dm_ancestor = id_dm_acc;
      aa.id_dm_descendent = id_dm_acc;
      aa.num_generations = 0;
      dmAccountAncestor.Add(aa);
    }

    public void buildAvInternal()
    {
      avInternal.id_acc = id_acc;
      avInternal.c_TaxExempt = null;
      avInternal.c_TaxExemptID = null;
      avInternal.c_TimezoneID = FastEnums.eTimeZoneId.EST;
      avInternal.c_PaymentMethod = null;
      avInternal.c_SecurityQuestion = null;
      avInternal.c_SecurityQuestionText = null;
      avInternal.c_SecurityAnswer = null;
      avInternal.c_InvoiceMethod = FastEnums.Instance.InvoiceMethod.Standard;
      avInternal.c_UsageCycleType = FastEnums.Instance.UsageCycleType.Monthly;
      avInternal.c_Language = 277; //FIXME
      avInternal.c_StatusReason = FastEnums.Instance.StatusReason.None;
      avInternal.c_StatusReasonOther = "No other reason";
      avInternal.c_Currency = "USD";
      avInternal.c_PriceList = null;
      avInternal.c_Billable = "1";
      avInternal.c_Folder = "0";
      avInternal.c_Division = null;
      avInternal.c_TaxVendor = null;
      avInternal.c_MetraTaxCountryEligibility = null;
      avInternal.c_MetraTaxCountryZone = null;
      avInternal.c_MetraTaxHasOverrideBand = null;
      avInternal.c_MetraTaxOverrideBand = null;
      avInternal.c_TaxServiceAddressPCode = null;
      avInternal.c_TaxExemptReason = null;
      avInternal.c_TaxExemptStartDate = null;
      avInternal.c_TaxExemptEndDate = null;
      avInternal.c_TaxRegistryReference = null;
    }



    public void insertIntoDB()
    {
      account.insert();
      avInternal.insert();
      foreach (var item in avContacts)
      {
        item.insert();
      }
      accountMapper.insert();
      accountState.insert();
      accountStateHistory.insert();

      foreach (var item in accountAncestors)
      {
        item.insert();
      }

      dmAccount.insert();
      foreach (var item in dmAccountAncestor)
      {
        item.insert();
      }

      accUsageCycle.insert();

      userCredentials.insert();
      profile.insert();
      siteUser.insert();

      paymentRedirection.insert();
      paymentRedirHistory.insert();

      // Roles and Capabilities
      principalPolicy.insert();
      policyRole.insert();

      if (true)
      {

        foreach (var item in capabilityInstanceList)
        {
          item.insert();
        }
        foreach (var item in enumCapabilityList)
        {
          item.insert();
        }
        foreach (var item in pathCapabilityList)
        {
          item.insert();
        }
      }

    }

    private static void prettyPrint(AccountAggregate acct)
    {
      DataContractJsonSerializer ser = new DataContractJsonSerializer(acct.GetType());
      MemoryStream stream1 = new MemoryStream();
      ser.WriteObject(stream1, acct);

      stream1.Position = 0;
      StreamReader sr = new StreamReader(stream1);
      Console.WriteLine("JSON form of Account object: ");
      string s2 = sr.ReadToEnd();
      //Console.WriteLine(s2);

      JsonPrettyPrinterPlus.JsonPrettyPrinterInternals.JsonPPStrategyContext context = new JsonPrettyPrinterPlus.JsonPrettyPrinterInternals.JsonPPStrategyContext();
      JsonPrettyPrinterPlus.JsonPrettyPrinter jpp = new JsonPrettyPrinterPlus.JsonPrettyPrinter(context);
      string pretty = jpp.PrettyPrint(s2);
      Console.WriteLine(pretty);
    }
  }
}

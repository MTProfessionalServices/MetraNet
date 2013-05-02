using System;
using System.Collections.Generic;
using System.ServiceProcess;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;

using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;

namespace MetraTech.Approvals.Test
{
 #region Shared Helper Methods That Should Be In Different Library
 
  public class SharedTestCode
  {

    #region Windows Service Related
    public static void MakeSureServiceIsStarted(string serviceName)
    {
      MakeSureServiceIsStarted(serviceName, 180);
    }

    public static void MakeSureServiceIsStarted(string serviceName, int timeoutSeconds)
    {
      ServiceController sc = new ServiceController(serviceName);

      if (sc.Status != ServiceControllerStatus.Running)
      {
        Console.WriteLine("The " + serviceName + " service status is currently set to {0}",
                           sc.Status.ToString());
      }

      if (sc.Status == ServiceControllerStatus.Stopped)
      {
        // Start the service if the current status is stopped.

        try
        {
          // Start the service, and wait until its status is "Running".
          Console.WriteLine("Starting " + serviceName + "....");
          sc.Start();
          sc.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(timeoutSeconds));

          // Display the current service status.
          Console.WriteLine("The " + serviceName + " service status is now set to {0}.",
                             sc.Status.ToString());
        }
        catch (System.ServiceProcess.TimeoutException)
        {
          throw new Exception(string.Format("Timed out after {0} seconds waiting for {1} service to start", timeoutSeconds, serviceName));
        }
        catch (InvalidOperationException)
        {
          throw new Exception(string.Format("Unable to start the service {0}", serviceName));
        }
      }
    }
    #endregion

    #region Authorization/Authentication Related
    public static MetraTech.Interop.MTAuth.IMTSessionContext LoginAsSU()
    {
      IMTLoginContext loginContext = new MTLoginContextClass();
      //ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      //sa.Initialize();
      //ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      string suName = "su";
      string suPassword = "su123";
      try
      {
        return loginContext.Login(suName, "system_user", suPassword);
      }
      catch (Exception ex)
      {
        throw new Exception("LoginAsSU failed:" + ex.Message, ex);
      }
    }

    //Because admin password 'expires' and some unit tests update it
    //Admin password can be different at different times
    //This is the 'hacky' way of trying both ways so we don't depend on when the unit test is run
    //or if someone has logged in already manually
    protected static string adminPasswordToTryFirst = "123";
    public static MetraTech.Interop.MTAuth.IMTSessionContext LoginAsAdmin()
    {
      IMTLoginContext loginContext = new MTLoginContextClass();

      string suName = "admin";
      string suPassword = adminPasswordToTryFirst;
      try
      {
        return loginContext.Login(suName, "system_user", suPassword);
      }
      catch (Exception)
      {
        try
        {
          suPassword = "Admin123";
          MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = loginContext.Login(suName, "system_user", suPassword);
          adminPasswordToTryFirst = suPassword;
          return sessionContext;
        }
        catch (Exception)
        {
          try
          {
            suPassword = "1";
            MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = loginContext.Login(suName, "system_user", suPassword);
            adminPasswordToTryFirst = suPassword;
            return sessionContext;
          }
          catch (Exception ex)
          {
            throw new Exception("LoginAsAdmin failed:" + ex.Message, ex);
          }
        }
      }
    }
    #endregion

    #region Group Subscription Related
    public static MTList<GroupSubscriptionMember> GetMembersOfGroupSubscription(int idGroupSubscription)
    {
      MTList<GroupSubscriptionMember> results = new MTList<GroupSubscriptionMember>();

      GroupSubscriptionService_GetMembersForGroupSubscription2_Client getGroupSubMembers =
        new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      getGroupSubMembers.In_groupSubscriptionId = idGroupSubscription;
      getGroupSubMembers.InOut_groupSubscriptionMembers = results;
      getGroupSubMembers.UserName = "su";
      getGroupSubMembers.Password = "su123";
      getGroupSubMembers.Invoke();

      results = getGroupSubMembers.InOut_groupSubscriptionMembers;

      return results;
    }
    #endregion
  }

  #region Product Catalog Related Classes

  public class ProductOfferingFactory
  {
    private IMTProductOffering mProductOffering;
    public IMTProductOffering Item
    {
      get { return mProductOffering; }
    }

    private IMTProductCatalog mProductCatalog;
    private IMTRecurringCharge piTemplate_FRRC_ChargePerParticipant;
    private IMTRecurringCharge piTemplate_FRRC_ChargePerSub;
    private IMTRecurringCharge piTemplate_UDRC_ChargePerParticipant;
    private IMTRecurringCharge piTemplate_UDRC_ChargePerSub;

    private int chargeCounter = 1;
    private int ChargeCounter
    {
      get
      {
        return chargeCounter++;
      }
    }



    protected string baseName = "";
    protected virtual string BaseName
    {
      get { return baseName; }
    }

    protected string uniqueInstanceIdentifier = "";
    protected virtual string UniqueInstanceIdentifier
    {
      get { return uniqueInstanceIdentifier; }
    }

    Dictionary<string, List<UDRCInstanceValue>> m_UDRCInstanceValues = new Dictionary<string, List<UDRCInstanceValue>>();


    public virtual MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContextForCreate()
    {
      return (MetraTech.Interop.MTProductCatalog.IMTSessionContext) SharedTestCode.LoginAsSU();
    }

    public static IMTProductOffering Create(string name, string uniqueIdentifier)
    {
      ProductOfferingFactory productOfferingHolder = new ProductOfferingFactory();
      productOfferingHolder.Instantiate(name, uniqueIdentifier);
      return productOfferingHolder.mProductOffering;
    }

    public void Instantiate(string name,string uniqueIdentifier)
    {
      baseName = name;
      uniqueInstanceIdentifier = uniqueIdentifier;

      MetraTech.Interop.MTProductCatalog.IMTSessionContext sessionContext = GetSessionContextForCreate();

      mProductCatalog = new MTProductCatalogClass();
      mProductCatalog.SetSessionContext(sessionContext);



      piTemplate_FRRC_ChargePerParticipant = CreateFlatRateRecurringCharge(true);

      piTemplate_FRRC_ChargePerSub = CreateFlatRateRecurringCharge(false);



      piTemplate_UDRC_ChargePerParticipant = CreateUDRC(true);

      piTemplate_UDRC_ChargePerSub = CreateUDRC(false);


      //Create a Product Offering
      List<IMTRecurringCharge> charges = new List<IMTRecurringCharge>();
      charges.Add(piTemplate_FRRC_ChargePerParticipant);
      charges.Add(piTemplate_FRRC_ChargePerSub);
      charges.Add(piTemplate_UDRC_ChargePerParticipant);
      charges.Add(piTemplate_UDRC_ChargePerSub);

      mProductOffering = CreateProductOffering(charges);
    }
   
    protected virtual IMTProductOffering CreateProductOffering(List<IMTRecurringCharge> charges)
    {
      IMTProductOffering productOffering = mProductCatalog.CreateProductOffering();
      productOffering.Name = string.Format("{0}_PO_{1}",BaseName, UniqueInstanceIdentifier);
      productOffering.DisplayName = productOffering.Name;
      productOffering.Description = productOffering.Name;
      productOffering.SelfSubscribable = true;
      productOffering.SelfUnsubscribable = false;
      productOffering.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      productOffering.EffectiveDate.StartDate = DateTime.Parse("1/1/2008");
      productOffering.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_NULL;
      productOffering.EffectiveDate.SetEndDateNull();

      foreach (IMTRecurringCharge recurringCharge in charges)
      {
        productOffering.AddPriceableItem((MTPriceableItem)recurringCharge);
      }

      productOffering.AvailabilityDate.StartDate = DateTime.Parse("1/1/2008");
      productOffering.AvailabilityDate.SetEndDateNull();
      productOffering.SetCurrencyCode("USD");
      productOffering.Save();

      return productOffering;
    }

    private IMTRecurringCharge CreateFlatRateRecurringCharge(bool chargePerParticipant)
    {
      IMTPriceableItemType priceableItemTypeFRRC =
          mProductCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge");

      if (priceableItemTypeFRRC == null)
      {
        throw new ApplicationException("'Flat Rate Recurring Charge' Priceable Item Type not found");
      }

      string name = String.Empty;
      if (chargePerParticipant)
      {
        name = string.Format("FRRC_CPP_{0}_{1}", ChargeCounter, UniqueInstanceIdentifier);
      }
      else
      {
        name = string.Format("FRRC_CPS_{0}_{1}", ChargeCounter, UniqueInstanceIdentifier);
      }

      IMTRecurringCharge piTemplate_FRRC = (IMTRecurringCharge)priceableItemTypeFRRC.CreateTemplate(false);
      piTemplate_FRRC.Name = name;
      piTemplate_FRRC.DisplayName = name;
      piTemplate_FRRC.Description = name;
      piTemplate_FRRC.ChargeInAdvance = false;
      piTemplate_FRRC.ProrateOnActivation = true;
      piTemplate_FRRC.ProrateOnDeactivation = true;
      piTemplate_FRRC.ProrateOnRateChange = true;
      piTemplate_FRRC.FixedProrationLength = false;
      piTemplate_FRRC.ChargePerParticipant = chargePerParticipant;
      IMTPCCycle pcCycle = piTemplate_FRRC.Cycle;
      pcCycle.CycleTypeID = 1;
      pcCycle.EndDayOfMonth = 31;
      piTemplate_FRRC.Save();

      return piTemplate_FRRC;
    }

    private IMTRecurringCharge CreateUDRC(bool chargePerParticipant)
    {
      IMTPriceableItemType priceableItemTypeUDRC =
          mProductCatalog.GetPriceableItemTypeByName("Unit Dependent Recurring Charge");

      if (priceableItemTypeUDRC == null)
      {
        throw new ApplicationException("'Unit Dependent Recurring Charge' Priceable Item Type not found");
      }

      string name = String.Empty;
      if (chargePerParticipant)
      {
        name = string.Format("UDRC_CPP_{0}_{1}", ChargeCounter, UniqueInstanceIdentifier);
      }
      else
      {
        name = string.Format("UDRC_CPS_{0}_{1}", ChargeCounter, UniqueInstanceIdentifier);
      }

      IMTRecurringCharge piTemplate_UDRC = (IMTRecurringCharge)priceableItemTypeUDRC.CreateTemplate(false);
      piTemplate_UDRC.Name = name;
      piTemplate_UDRC.DisplayName = name;
      piTemplate_UDRC.Description = name;
      piTemplate_UDRC.ChargeInAdvance = false;
      piTemplate_UDRC.ProrateOnActivation = true;
      piTemplate_UDRC.ProrateOnDeactivation = true;
      piTemplate_UDRC.ProrateOnRateChange = true;
      piTemplate_UDRC.FixedProrationLength = false;
      piTemplate_UDRC.ChargePerParticipant = chargePerParticipant;
      piTemplate_UDRC.UnitName = string.Format("UNIT_{0}_{1}", ChargeCounter, UniqueInstanceIdentifier);
      piTemplate_UDRC.RatingType = MTUDRCRatingType.UDRCRATING_TYPE_TAPERED;
      piTemplate_UDRC.IntegerUnitValue = true;
      piTemplate_UDRC.MinUnitValue = 10;
      piTemplate_UDRC.MaxUnitValue = 1000;
      IMTPCCycle pcCycle = piTemplate_UDRC.Cycle;
      pcCycle.CycleTypeID = 1;
      pcCycle.EndDayOfMonth = 31;
      piTemplate_UDRC.Save();

      return piTemplate_UDRC;
    }

    
  }

  #endregion

  #region Account Related Classes

  public class CorporateAccountFactory
  {
    protected CorporateAccount mCorporateAccount;
    public CorporateAccount Item
    {
      get { return mCorporateAccount; }
    }

    protected string baseName = "";
    protected virtual string BaseName
    {
      get { return baseName; }
    }

    protected string uniqueInstanceIdentifier = "";
    protected virtual string UniqueInstanceIdentifier
    {
      get { return uniqueInstanceIdentifier; }
    }

    protected InternalView internalView;
    protected ContactView billToContactView;
    protected ContactView shipToContactView;

    AccountCreation_AddAccount_Client webServiceClient;

    public virtual MetraTech.Interop.MTAuth.IMTSessionContext GetSessionContextForCreate()
    {
      return SharedTestCode.LoginAsSU();
    }

    public virtual AccountCreation_AddAccount_Client WebServiceClient
    {
      get
      {
        if (webServiceClient == null)
        {
          webServiceClient = new AccountCreation_AddAccount_Client();
          webServiceClient.UserName = "su";
          webServiceClient.Password = "su123";
        }

        return webServiceClient;
      }
    }

    private CorporateAccountFactory() { }
    public CorporateAccountFactory(string name, string uniqueIdentifier)
    {
      baseName = name;
      uniqueInstanceIdentifier = uniqueIdentifier;
    }

    public static CorporateAccount Create(string name, string uniqueIdentifier)
    {
      CorporateAccountFactory accountHolder = new CorporateAccountFactory(name, uniqueIdentifier);
      accountHolder.Instantiate();

      return accountHolder.Item;
    }


    public virtual void Instantiate()
    {

      // Create the internal view
      internalView = (InternalView)View.CreateView(@"metratech.com/internal");
      internalView.UsageCycleType = UsageCycleType.Monthly;
      internalView.Billable = true;
      internalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
      internalView.Language = LanguageCode.US;
      internalView.Currency = SystemCurrencies.USD.ToString();
      internalView.TimezoneID = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

      // Create the billToContactView
      billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
      billToContactView.ContactType = ContactType.Bill_To;
      billToContactView.FirstName = "Rudi";
      billToContactView.LastName = "Perkins";
      //billToContactView.Country = CountryName.Germany;

      // Create the shipToContactView
      shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Harvinder";
      shipToContactView.LastName = "Singh";
      //shipToContactView.Country = CountryName.India;


      mCorporateAccount = CreateCorporateAccount();
    }

  protected virtual CorporateAccount CreateCorporateAccount()
    {
      string username="Corp";
      string nameSpace = String.Empty;
      CorporateAccount account = (CorporateAccount)CreateBaseAccount("CorporateAccount", ref username, ref nameSpace);
      account.AncestorAccountID = 1;
      account.AccountStartDate = MetraTime.Now;

      
      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      WebServiceClient.InOut_Account = account;
      WebServiceClient.Invoke();

      return (CorporateAccount)WebServiceClient.InOut_Account;
    }

  private MetraTech.DomainModel.BaseTypes.Account CreateBaseAccount(string typeName, ref string userName, ref string nameSpace)
  {
    MetraTech.DomainModel.BaseTypes.Account account =
      MetraTech.DomainModel.BaseTypes.Account.CreateAccount(typeName);

    //userName = typeName + "_" + DateTime.Now.ToString("MM/dd HH:mm:ss.") + DateTime.Now.Millisecond.ToString();

    userName = string.Format("{0}_{1}_{2}", userName, BaseName, UniqueInstanceIdentifier);

    if (userName.Length > 40)
    {
      throw new Exception(string.Format("Username '{0}' is too long. It is {1} and should be 40 or less.", userName, userName.Length));
    }
    
    if (String.IsNullOrEmpty(nameSpace))
    {
      nameSpace = "mt";
    }

    account.UserName = userName;
    account.Password_ = "123";
    account.Name_Space = nameSpace;
    account.DayOfMonth = 1;
    account.AccountStatus = AccountStatus.Active;

    return account;
  }

  public CoreSubscriber AddCoreSubscriber(string name)
  {
    string username = name;
    string nameSpace = String.Empty;

    CoreSubscriber account = (CoreSubscriber)CreateBaseAccount("CoreSubscriber", ref username, ref nameSpace);
    account.AncestorAccountID = mCorporateAccount._AccountID;
    account.AccountStartDate = MetraTime.Now;

    account.Internal = internalView;

    // Add the contact views
    //account.LDAP.Add(shipToContactView);
    //account.LDAP.Add(billToContactView);

    // Create the billToContactView
    ContactView billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
    billToContactView.ContactType = ContactType.Bill_To;
    billToContactView.FirstName = username;
    billToContactView.LastName = "Perkins";

    // Create the shipToContactView
    ContactView shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
    shipToContactView.ContactType = ContactType.Ship_To;
    shipToContactView.FirstName = username;
    shipToContactView.LastName = "Perkins";

    // Create the account
    WebServiceClient.InOut_Account = account;
    WebServiceClient.Invoke();

    return (CoreSubscriber)WebServiceClient.InOut_Account;
  }
}

  public class GroupSubscriptionFactory
  {
    protected GroupSubscription mGroupSubscription;
    public GroupSubscription Item
    {
      get { return mGroupSubscription; }
    }

    protected string mUserName = "";
    protected string mPassword = "";

    protected string baseName = "";
    protected virtual string BaseName
    {
      get { return baseName; }
    }

    protected string uniqueInstanceIdentifier = "";
    protected virtual string UniqueInstanceIdentifier
    {
      get { return uniqueInstanceIdentifier; }
    }

    public static GroupSubscription Create(string name, string uniqueIdentifier, int productOfferingId,
                                                      int corporateAccountId,
                                                      List<int> memberAccountIds, string userName, string password)
    {
      GroupSubscriptionFactory groupSubscriptionHolder = new GroupSubscriptionFactory();
      groupSubscriptionHolder.baseName = name;
      groupSubscriptionHolder.uniqueInstanceIdentifier = uniqueIdentifier;
      groupSubscriptionHolder.mUserName = userName;
      groupSubscriptionHolder.mPassword = password;

      groupSubscriptionHolder.CreateGroupSubscription(productOfferingId, corporateAccountId, memberAccountIds);

      return groupSubscriptionHolder.Item;
    }

    public GroupSubscription CreateGroupSubscription(int productOfferingId, 
                                                      int corporateAccountId, 
                                                      List<int> memberAccountIds)
    {
      GroupSubscription groupSubscription = new GroupSubscription();

      #region Initialize 
      
      groupSubscription.SubscriptionSpan = new ProdCatTimeSpan();

      DateTime start = MetraTime.Now.AddDays(1);
      //Round to nearest second for easier comparison with database timestamp later
      groupSubscription.SubscriptionSpan.StartDate = start.RoundToSecond();

      groupSubscription.ProductOfferingId = productOfferingId;
      groupSubscription.ProportionalDistribution = false;
      groupSubscription.DiscountAccountId = memberAccountIds[0];

      groupSubscription.Name = string.Format("{0}_GS_{1}", BaseName, UniqueInstanceIdentifier);
      groupSubscription.Description = "Unit Test";
      groupSubscription.SupportsGroupOperations = true;
      groupSubscription.CorporateAccountId = corporateAccountId;
      Cycle cycle = new Cycle();
      cycle.CycleType = UsageCycleType.Monthly;
      cycle.DayOfMonth = 1;
      groupSubscription.Cycle = cycle;
      #endregion

      #region Create UDRCInstanceValue's

      SubscriptionService_GetUDRCInstancesForPO_Client udrcClient =
        new SubscriptionService_GetUDRCInstancesForPO_Client();
      udrcClient.In_productOfferingId = productOfferingId;
      udrcClient.UserName = mUserName;
      udrcClient.Password = mPassword;
      udrcClient.Invoke();

      UDRCInstanceValue udrcInstanceValue = null;
      Dictionary<string, List<UDRCInstanceValue>> udrcValues =
        new Dictionary<string, List<UDRCInstanceValue>>();

      List<UDRCInstance> udrcInstances = udrcClient.Out_udrcInstances;
      foreach (UDRCInstance udrcInstance in udrcInstances)
      {
        List<UDRCInstanceValue> values = new List<UDRCInstanceValue>();

        udrcInstanceValue = new UDRCInstanceValue();
        udrcInstanceValue.UDRC_Id = udrcInstance.ID;
        udrcInstanceValue.Value = (udrcInstance.MinValue + udrcInstance.MaxValue) / 2;
        udrcInstanceValue.StartDate = groupSubscription.SubscriptionSpan.StartDate.Value;
        udrcInstanceValue.EndDate = MetraTime.Max;
        values.Add(udrcInstanceValue);

        udrcValues.Add(udrcInstance.ID.ToString(), values);

        // Setup Charge Account if necessary
        if (!udrcInstance.ChargePerParticipant)
        {
          // One of the core subscribers 
          udrcInstance.ChargeAccountId = memberAccountIds[0];
          udrcInstance.ChargeAccountSpan = new ProdCatTimeSpan();
          udrcInstance.ChargeAccountSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        }
      }

      // Set the UDRCValues and UDRCInstances
      groupSubscription.UDRCValues = udrcValues;
      groupSubscription.UDRCInstances = udrcInstances;
      #endregion

      #region Set Flat Rate Recurring Charge Accounts
      GroupSubscriptionService_GetFlatRateRecurringChargeInstancesForPO_Client
        flatRateClient = new GroupSubscriptionService_GetFlatRateRecurringChargeInstancesForPO_Client();
      flatRateClient.In_productOfferingId = productOfferingId;
      flatRateClient.UserName = mUserName;
      flatRateClient.Password = mPassword;
      flatRateClient.Invoke();

      List<FlatRateRecurringChargeInstance> flatRateRecurringChargeInstances =
        flatRateClient.Out_flatRateRecurringChargeInstances;

      foreach (FlatRateRecurringChargeInstance flatRateRC in
                flatRateRecurringChargeInstances)
      {
        if (!flatRateRC.ChargePerParticipant)
        {
          flatRateRC.ChargeAccountId = memberAccountIds[0];
          flatRateRC.ChargeAccountSpan = new ProdCatTimeSpan();
          flatRateRC.ChargeAccountSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        }
      }

      groupSubscription.FlatRateRecurringChargeInstances = flatRateRecurringChargeInstances;
      #endregion

      #region Add Members
      groupSubscription.Members = new MTList<GroupSubscriptionMember>();

      foreach (int accountId in memberAccountIds)
      {
        GroupSubscriptionMember gSubMember = new GroupSubscriptionMember();
        gSubMember.AccountId = accountId;
        gSubMember.MembershipSpan = new ProdCatTimeSpan();
        gSubMember.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        groupSubscription.Members.Items.Add(gSubMember);
      }
      #endregion

      #region Save the Group Subscription
      GroupSubscriptionService_AddGroupSubscription_Client addClient =
        new GroupSubscriptionService_AddGroupSubscription_Client();
      addClient.UserName = mUserName;
      addClient.Password = mPassword;
      addClient.InOut_groupSubscription = groupSubscription;
      addClient.Invoke();

      groupSubscription.GroupId = addClient.InOut_groupSubscription.GroupId.Value;
      #endregion

      mGroupSubscription = groupSubscription;

      return mGroupSubscription;
    }
  }

#endregion

  #region DateTime Related Extension Methods
  public static class DateTimeExtensionMethods
  {
    public static DateTime? TruncatedToSecond(this DateTime? dateTime)
    {
      if (dateTime != null)
        return new DateTime(dateTime.Value.Ticks - (dateTime.Value.Ticks % TimeSpan.TicksPerSecond), dateTime.Value.Kind);
      else
        return null;
    }

    public static DateTime? RoundToSecond(this DateTime? dateTime)
    {
      if (dateTime != null)
      {
        DateTime result = new DateTime(dateTime.Value.Year, dateTime.Value.Month, dateTime.Value.Day, dateTime.Value.Hour, dateTime.Value.Minute, dateTime.Value.Second, dateTime.Value.Kind);
        if (dateTime.Value.Millisecond >= 500)
        {
          result.AddSeconds(1);
        }

        return result;
      }
      else
      {
        return null;
      }
    }

    public static DateTime RoundToSecond(this DateTime dateTime)
    {
      DateTime result = new DateTime(dateTime.Year, dateTime.Month, dateTime.Day, dateTime.Hour, dateTime.Minute, dateTime.Second, dateTime.Kind);
      if (dateTime.Millisecond >= 500)
      {
          result.AddSeconds(1);
      }

      return result;
    }

    //  milliseconds modulo 10:    0    1    2    3    4    5    6    7    8    9
    private static readonly int[] OFFSET = { 0, -1, +1, 0, -1, +2, +1, 0, -1, +1 };
    private static readonly DateTime SQL_SERVER_DATETIME_MIN = new DateTime(1753, 01, 01, 00, 00, 00, 000);
    private static readonly DateTime SQL_SERVER_DATETIME_MAX = new DateTime(9999, 12, 31, 23, 59, 59, 997);

    public static DateTime? RoundToSqlServerDateTime(this DateTime? dateTime)
    {
      DateTime dt = new DateTime(dateTime.Value.Year, dateTime.Value.Month, dateTime.Value.Day, dateTime.Value.Hour, dateTime.Value.Minute, dateTime.Value.Second, dateTime.Value.Millisecond);
      int milliseconds = dateTime.Value.Millisecond;
      int t = milliseconds % 10;
      int offset = OFFSET[t];
      DateTime rounded = dt.AddMilliseconds(offset);

      if (rounded < SQL_SERVER_DATETIME_MIN) throw new ArgumentOutOfRangeException("value");
      if (rounded > SQL_SERVER_DATETIME_MAX) throw new ArgumentOutOfRangeException("value");

      return rounded;
    }
  }
  #endregion

 #endregion
}

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Test.Common;
using NUnit.Framework;
using MetraTech.Core.Activities;
using MetraTech.Core.Workflows;
using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.Core.Activities.Test
{
  /// <summary>
  ///    CreateAccountTest
  /// 
  ///    To run this test fixture:
  ///     nunit-console /fixture:MetraTech.Core.Activities.Test.CreateAccountTest /assembly:O:\debug\bin\MetraTech.Core.Activities.Test.dll
  /// </summary>
  /// <remarks>
  ///    The CreateAccountTest class contains NUnit tests which exercise the account creation 
  ///    functionality. Tests include creating the out of the box account types and
  ///    their associated views.
  /// </remarks>
  [Category("NoAutoRun")]
  [TestFixture]
  public class CreateAccountTest
  {
    /// <summary>
    ///    (1) Create the InternalView
    ///    (2) Create Ship-to and Bill-to ContactViews
    ///    (3) Create a Corporate Account
    /// </summary>
    [TestFixtureSetUp]
    public void Setup()
    {
      logger = new Logger("Logging\\CreateAccountTest", "[" + this.GetType().Name + "]");
      logger.LogDebug("Starting CreateAccountTest.Setup()");
      // Create the internal view
      internalView =
        CreateInternalView(UsageCycleType.Monthly,
                           true,
                           SecurityQuestion.MothersMaidenName,
                           LanguageCode.US,
                           SystemCurrencies.USD.ToString(),
                           TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);

      // Create the billToContactView
      billToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
      billToContactView.ContactType = ContactType.Bill_To;
      billToContactView.FirstName = "Boris";
      billToContactView.LastName = "Boruchovich";
      //billToContactView.Country = CountryName.Russia;

      // Create the shipToContactView
      shipToContactView = (ContactView)View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Harvinder";
      shipToContactView.LastName = "Singh";
      //shipToContactView.Country = CountryName.India;

      m_TestId = Utils.GetTestId();

      // Create the parent corporate account
      string userName;
      string nameSpace = String.Empty;
      CorporateAccount tmpCorporateAccount =
        (CorporateAccount)CreateAccount("CorporateAccount", out userName, ref nameSpace);
      tmpCorporateAccount.AncestorAccountID = 1;

      // Set the internal view
      tmpCorporateAccount.Internal = internalView;

      // Add the contact views
      tmpCorporateAccount.LDAP.Add(shipToContactView);
      tmpCorporateAccount.LDAP.Add(billToContactView);
    
      addAccountClient = new AccountCreation_AddAccount_Client();
      addAccountClient.UserName = "su";
      addAccountClient.Password = "su123";
      addAccountClient.InOut_Account = tmpCorporateAccount;

      addAccountClient.Invoke();

      loadAccountClient = new AccountService_LoadAccountWithViews_Client();
      loadAccountClient.UserName = "su";
      loadAccountClient.Password = "su123";
      loadAccountClient.In_acct =
        new AccountIdentifier(tmpCorporateAccount.UserName, tmpCorporateAccount.Name_Space);
      loadAccountClient.In_timeStamp = MetraTime.Now;
      
      // Invoke the service
      loadAccountClient.Invoke();

      corporateAccount = (CorporateAccount)loadAccountClient.Out_account;

      logger.LogDebug("Finished CreateAccountTest.Setup()");
    }
    
    /// <summary>
    ///   TearDown
    /// </summary>
    [TestFixtureTearDown]
    public void TearDown()
    {
    }

      ///<summary>
      ///</summary>
      [Test]
      [Category("CreateCorpAccountWithEndDate")]
    public void T01CreateCorpAccountWithEndDate()
      {
          logger.LogDebug("Starting CreateCorpAccountWithEndDate");

          // Add the corporate account
          string CorpName = string.Format("Corp_{0}_{1}", m_TestId, ++m_TestAccountNumber);
          MetraTech.DomainModel.BaseTypes.Account acc = MetraTech.DomainModel.BaseTypes.Account.CreateAccount("CorporateAccount");
          acc.UserName = CorpName;
          acc.AccountStartDate = DateTime.Parse("2001-06-30T00:00:00");
          acc.AccountEndDate = DateTime.Parse("2037-01-01T00:00:00");
          acc.AccountStatus = AccountStatus.Active;
          acc.DayOfMonth = 31;
          acc.Name_Space = "mt";
          acc.Password_ = "123";

          InternalView internalView = (InternalView)View.CreateView(@"metratech.com/internal");
          internalView.Billable = true;
          internalView.Currency = "USD";
          internalView.Language = LanguageCode.US;
          internalView.UsageCycleType = UsageCycleType.Monthly;
          acc.AddView(internalView, "Internal");

          ContactView contactView = (ContactView)View.CreateView(@"metratech.com/contact");
          contactView.ContactType = ContactType.Bill_To;
          contactView.Country = CountryName.USA;
          acc.AddView(contactView, "LDAP");

          MetraTech.Account.ClientProxies.AccountCreationClient accCreationtClient = null;
          accCreationtClient = new MetraTech.Account.ClientProxies.AccountCreationClient("WSHttpBinding_IAccountCreation");
          accCreationtClient.ClientCredentials.UserName.UserName = "su";
          accCreationtClient.ClientCredentials.UserName.Password = "su123";

          try
          {
              accCreationtClient.AddAccount(ref acc, false);
          }
          catch (Exception )
          { // Handle other general errors not specific to service
              throw;
          }
          finally
          {
              if (accCreationtClient != null)
              {
                  if (accCreationtClient.State == System.ServiceModel.CommunicationState.Opened)
                  {
                      accCreationtClient.Close();
                  }
                  else
                  {
                      accCreationtClient.Abort();
                  }
              }
          }

          logger.LogDebug("Finished CreateCorpAccountWithEndDate");
      }



    #region M2 Acceptance Tests

    /// <summary>
    ///    (1) Creates a CoreSubscriber with an InternalView, a ship-to ContactView and a bill-to ContactView.
    ///    (2) Loads the created account and verifies that the core and view properties match.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("CreateCoreSubscriber")]
      public void T02CreateCoreSubscriber()
    {
      
      logger.LogDebug("Starting CreateCoreSubscriber");

      string userName;
      string nameSpace = String.Empty;
      CoreSubscriber account =
        (CoreSubscriber) CreateAccount("CoreSubscriber", out userName, ref nameSpace);

      account.AncestorAccountID = corporateAccount._AccountID;

      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account
      loadAccountClient.In_acct = new AccountIdentifier(userName, nameSpace);
      loadAccountClient.Invoke();

      CoreSubscriber loadedAccount = loadAccountClient.Out_account as CoreSubscriber;
      Assert.IsNotNull(loadedAccount);
      Assert.IsNotNull(loadedAccount.Internal);
      Assert.IsNotNull(loadedAccount.LDAP);
      Assert.AreEqual(2, loadedAccount.LDAP.Count);

      Assert.AreEqual(userName, loadedAccount.UserName);
      Assert.AreEqual(nameSpace, loadedAccount.Name_Space);

      // Check the internal view
      CheckInternalView(loadedAccount.Internal);
      // Check contact views
      CheckContactViews(loadedAccount.LDAP);

      logger.LogDebug("Finished CreateCoreSubscriber");

    }

    /// <summary>
    ///    (1) Creates a DepartmentAccount with an InternalView, a ship-to ContactView and a bill-to ContactView.
    ///    (2) Loads the created account and verifies that the core and view properties match.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("CreateDepartmentAccount")]
    public void T03CreateDepartmentAccount()
    {
      logger.LogDebug("Starting CreateDepartmentAccount");

      string userName;
      string nameSpace = String.Empty;
      DepartmentAccount account = 
        (DepartmentAccount)CreateAccount("DepartmentAccount", out userName, ref nameSpace);

      account.AncestorAccountID = corporateAccount._AccountID;

      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account
      loadAccountClient.In_acct = new AccountIdentifier(userName, nameSpace);
      loadAccountClient.Invoke();

      DepartmentAccount loadedAccount = loadAccountClient.Out_account as DepartmentAccount;
      Assert.IsNotNull(loadedAccount);
      Assert.IsNotNull(loadedAccount.Internal);
      Assert.IsNotNull(loadedAccount.LDAP);
      Assert.AreEqual(2, loadedAccount.LDAP.Count);

      Assert.AreEqual(userName, loadedAccount.UserName);
      Assert.AreEqual(nameSpace, loadedAccount.Name_Space);
      Assert.AreEqual(AccountStatus.Active, loadedAccount.AccountStatus);

      // Check the internal view
      CheckInternalView(loadedAccount.Internal);
      // Check contact views
      CheckContactViews(loadedAccount.LDAP);

      logger.LogDebug("Finished CreateDepartmentAccount");

    }

    /// <summary>
    ///    (1) Creates a IndependentAccount with an InternalView, a ship-to ContactView and a bill-to ContactView.
    ///    (2) Loads the created account and verifies that the core and view properties match.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("CreateIndependentAccount")]
    public void T04CreateIndependentAccount()
    {
      logger.LogDebug("Starting CreateIndependentAccount");

      string userName;
      string nameSpace = String.Empty;
      IndependentAccount account =
        (IndependentAccount)CreateAccount("IndependentAccount", out userName, ref nameSpace);

      account.AncestorAccountID = 1;

      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account
      loadAccountClient.In_acct = new AccountIdentifier(userName, nameSpace);
      loadAccountClient.Invoke();

      IndependentAccount loadedAccount = loadAccountClient.Out_account as IndependentAccount;
      Assert.IsNotNull(loadedAccount);
      Assert.IsNotNull(loadedAccount.Internal);
      Assert.IsNotNull(loadedAccount.LDAP);
      Assert.AreEqual(2, loadedAccount.LDAP.Count);

      Assert.AreEqual(userName, loadedAccount.UserName);
      Assert.AreEqual(nameSpace, loadedAccount.Name_Space);
      Assert.AreEqual(AccountStatus.Active, loadedAccount.AccountStatus);

      // Check the internal view
      CheckInternalView(loadedAccount.Internal);
      // Check contact views
      CheckContactViews(loadedAccount.LDAP);

      logger.LogDebug("Finished CreateIndependentAccount");
    }

    /// <summary>
    ///    (1) Creates a SystemAccount with an InternalView, a ship-to ContactView and a bill-to ContactView.
    ///    (2) Loads the created account and verifies that the core and view properties match.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("CreateSystemAccount")]
    public void T05CreateSystemAccount()
    {
      logger.LogDebug("Starting CreateSystemAccount");

      string userName;
      string nameSpace = "system_user";
      SystemAccount account =
        (SystemAccount)CreateAccount("SystemAccount", out userName, ref nameSpace);

      account.AncestorAccountID = 1;
      account.LoginApplication = LoginApplication.CSR;

      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account
      loadAccountClient.In_acct = new AccountIdentifier(userName, nameSpace);
      loadAccountClient.Invoke();

      SystemAccount loadedAccount = loadAccountClient.Out_account as SystemAccount;
      Assert.IsNotNull(loadedAccount);
      Assert.IsNotNull(loadedAccount.Internal);
      Assert.IsNotNull(loadedAccount.LDAP);
      Assert.AreEqual(2, loadedAccount.LDAP.Count);

      Assert.AreEqual(userName, loadedAccount.UserName);
      Assert.AreEqual(nameSpace, loadedAccount.Name_Space);
      Assert.AreEqual(AccountStatus.Active, loadedAccount.AccountStatus);

      // Check the internal view
      CheckInternalView(loadedAccount.Internal);
      // Check contact views
      CheckContactViews(loadedAccount.LDAP);

      logger.LogDebug("Finished CreateSystemAccount");
    }

    /// <summary>
    ///    (1) Loads the corporate account created during setup.
    ///    (2) Verifies that the loaded properties are correct.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("LoadAccount")]
    public void T06LoadAccount()
    {
      logger.LogDebug("Starting LoadAccount");

      AccountService_LoadAccount_Client client = new AccountService_LoadAccount_Client();
      client.UserName = "su";
      client.Password = "su123";
      client.In_acct = new AccountIdentifier(corporateAccount._AccountID.Value);
      client.In_timeStamp = MetraTime.Now;

      // Invoke the service
      client.Invoke();

      CorporateAccount loadedAccount = (CorporateAccount)client.Out_account;

      CheckCorporateAccount(loadedAccount);

      // Check that no contact views 
      Assert.AreEqual(0, loadedAccount.LDAP.Count);

      logger.LogDebug("Finished LoadAccount");
    }

    /// <summary>
    ///    (1) Loads the corporate account created during setup.
    ///    (2) Verifies that the loaded properties are correct.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("LoadAccountWithViews")]
    public void T07LoadAccountWithViews()
    {
      logger.LogDebug("Starting LoadAccountWithViews");

      loadAccountClient.In_acct = new AccountIdentifier(corporateAccount._AccountID.Value);
      loadAccountClient.In_timeStamp = MetraTime.Now;

      // Invoke the service
      loadAccountClient.Invoke();

      CorporateAccount loadedAccount = (CorporateAccount)loadAccountClient.Out_account;

      CheckCorporateAccount(loadedAccount);

      // Check that the internal view properties are correct
      CheckInternalView(loadedAccount.Internal);

      // Check contact views 
      CheckContactViews(loadedAccount.LDAP);

      logger.LogDebug("Finished LoadAccountWithViews");
    }

    /// <summary>
    ///    (1) Loads the views of the corporate account created during setup.
    ///    (2) Verifies that the loaded properties are correct.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("LoadViews")]
    public void T08LoadViews()
    {
      logger.LogDebug("Starting LoadViews");

      AccountService_LoadView_Client client = new AccountService_LoadView_Client();
      client.UserName = "su";
      client.Password = "su123";
      client.In_viewType = "ContactView";
      client.In_acct = new AccountIdentifier(corporateAccount._AccountID.Value);
     
      // Invoke the service
      client.Invoke();

      List<View> views = client.Out_views;
      ContactView contactView = null;
      List<ContactView> contactViews = new List<ContactView>();
      foreach (View view in views)
      {
        contactView = view as ContactView;
        Assert.IsNotNull(contactView);
        contactViews.Add(contactView);
      }

      CheckContactViews(contactViews);

      // Check InternalView
      client.In_viewType = "InternalView";
      client.Invoke();

      views = client.Out_views;

      Assert.AreEqual(1, views.Count);

      InternalView internalView1 = views[0] as InternalView;

      Assert.IsNotNull(internalView1);

      CheckInternalView(internalView1);

      logger.LogDebug("Finished LoadViews");
    }

    #endregion

    #region Usage Cycle Tests
    /// <summary>
    ///   (1) Create a corporate account with weekly usage cycle type
    ///   (2) Set day of week to Monday.
    ///   (3) Load the corporate account and check that the day of week is set to Monday.
    /// </summary>
    [Test]
    [Category("TestWeeklyUsageCycleType")]
    public void T09TestWeeklyUsageCycleType()
    {
      logger.LogDebug("Starting TestWeeklyUsageCycleType");

      string username;
      string nameSpace = String.Empty;

      CorporateAccount account = (CorporateAccount)CreateAccount("CorporateAccount", out username, ref nameSpace);
      InternalView internalView = CreateInternalView(UsageCycleType.Weekly,
                                                     true,
                                                     SecurityQuestion.MothersMaidenName,
                                                     LanguageCode.US,
                                                     SystemCurrencies.USD.ToString(),
                                                     TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);
      account.Internal = internalView;
      account.DayOfWeek = DayOfTheWeek.Monday;

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account 
      loadAccountClient.In_acct = new AccountIdentifier(username, nameSpace);
      loadAccountClient.In_timeStamp = MetraTime.Now;

      // Invoke the service
      loadAccountClient.Invoke();

      CorporateAccount loadedAccount = (CorporateAccount)loadAccountClient.Out_account;

      Assert.AreEqual(DayOfTheWeek.Monday, loadedAccount.DayOfWeek.Value);

      logger.LogDebug("Finished TestWeeklyUsageCycleType");

    }

		/// <summary>
		///   (1) Create a corporate account with bi-weekly usage cycle type
		///   (2) Specify StartYear, StartMonth, StartDay.
		///   (3) Load the corporate account and check that cycle type and original specs match.
		/// </summary>
		[Test]
		[Category("TestBiWeeklyUsageCycleType")]
    public void T10TestBiWeeklyUsageCycleType()
		{
			logger.LogDebug("Starting TestBiWeeklyUsageCycleType");

			string username;
			string nameSpace = String.Empty;

			CorporateAccount account = (CorporateAccount)CreateAccount("CorporateAccount", out username, ref nameSpace);
			InternalView internalView = CreateInternalView(UsageCycleType.Bi_weekly,
																										 true,
																										 SecurityQuestion.MothersMaidenName,
																										 LanguageCode.US,
																										 SystemCurrencies.USD.ToString(),
																										 TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);
			account.Internal = internalView;
			account.StartYear = 2009;
			account.StartMonth = MonthOfTheYear.February;
			account.StartDay = 28;

			// Create the account
			addAccountClient.InOut_Account = account;
			addAccountClient.Invoke();

			// Load the account 
			loadAccountClient.In_acct = new AccountIdentifier(username, nameSpace);
			loadAccountClient.In_timeStamp = MetraTime.Now;

			// Invoke the service
			loadAccountClient.Invoke();

			CorporateAccount loadedAccount = (CorporateAccount)loadAccountClient.Out_account;

		  Assert.IsNotNull(loadedAccount);
			Assert.AreEqual(username, loadedAccount.UserName);

			logger.LogDebug("Finished TestBiWeeklyUsageCycleType");

		}
    #endregion

    #region Other Tests
    /// <summary>
    ///    (1) Creates a CoreSubscriber with an InternalView, a ship-to ContactView and a bill-to ContactView.
    ///    (2) Sets start and end dates.
    ///    (3) Loads the created account and verifies that the core and view properties match.
    ///    CR 15408
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    // [Ignore]
    [Category("CreateCoreSubscriberWithDates")]
    public void T11CreateCoreSubscriberWithDates()
    {
      logger.LogDebug("Starting CreateCoreSubscriberWithDates");

      string userName;
      string nameSpace = String.Empty;
      CoreSubscriber account =
        (CoreSubscriber)CreateAccount("CoreSubscriber", out userName, ref nameSpace);

      DateTime startDate = MetraTime.Now.AddDays(1);
      DateTime endDate = MetraTime.Now.AddMonths(2);

      account.AccountStartDate = startDate;
      account.AccountEndDate = endDate;
      account.AncestorAccountID = corporateAccount._AccountID;
      account.PayerID = corporateAccount._AccountID;
      // account.Payment_StartDate = account.AccountStartDate;
      // account.Payment_EndDate = account.AccountEndDate;

      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account
      loadAccountClient.In_acct = new AccountIdentifier(userName, nameSpace);
      loadAccountClient.In_timeStamp = MetraTime.Now.AddDays(1);
      loadAccountClient.Invoke();

      CoreSubscriber loadedAccount = loadAccountClient.Out_account as CoreSubscriber;
      Assert.IsNotNull(loadedAccount);
      Assert.IsNotNull(loadedAccount.Internal);
      Assert.IsNotNull(loadedAccount.LDAP);
      Assert.AreEqual(2, loadedAccount.LDAP.Count);

      Assert.AreEqual(userName, loadedAccount.UserName);
      Assert.AreEqual(nameSpace, loadedAccount.Name_Space);

      Assert.AreEqual(corporateAccount._AccountID, loadedAccount.PayerID);

      // Check the internal view
      CheckInternalView(loadedAccount.Internal);
      // Check contact views
      CheckContactViews(loadedAccount.LDAP);

      // Check the dates
      // Because the days are initialized to start of day
      Assert.AreEqual(new DateTime(startDate.Year, startDate.Month, startDate.Day), loadedAccount.AccountStartDate);
        // End of period is end of day
      Assert.AreEqual(new DateTime(endDate.Year, endDate.Month, endDate.Day,23,59,59), loadedAccount.AccountEndDate);

      logger.LogDebug("Finished CreateCoreSubscriberWithDates");
    }

    /// <summary>
    ///   (1) Create a corporate account with its payer id set to -1 and billable flag set to false.    
    ///   (3) Load the corporate account and check that the billable flag is false.
    /// </summary>
    [Test]
    [Category("CreateNonBillableAccount")]
    public void T12CreateNonBillableAccount()
    {
      logger.LogDebug("Starting CreateNonBillableAccount");

      string username;
      string nameSpace = String.Empty;

      // Create the CoreSubscriber non-billable account
      CoreSubscriber account = (CoreSubscriber)CreateAccount("CoreSubscriber", out username, ref nameSpace);
      InternalView tmpInternalView = CreateInternalView(UsageCycleType.Weekly,
                                                        true,
                                                        SecurityQuestion.MothersMaidenName,
                                                        LanguageCode.US,
                                                        SystemCurrencies.USD.ToString(),
                                                        TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);

      username = "NBA_" + username;
      account.UserName = username;
      account.Internal = tmpInternalView;
      account.DayOfWeek = DayOfTheWeek.Monday;
      account.Internal.Billable = false;
      account.PayerID = corporateAccount._AccountID;
      account.AncestorAccountID = corporateAccount._AccountID;

      // Create the non-billable account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account 
      loadAccountClient.In_acct = new AccountIdentifier(username, nameSpace);
      loadAccountClient.In_timeStamp = MetraTime.Now;

      // Invoke the service
      loadAccountClient.Invoke();

      CoreSubscriber loadedAccount = (CoreSubscriber)loadAccountClient.Out_account;

      Assert.AreEqual(username, loadedAccount.UserName);
      Assert.AreEqual(DayOfTheWeek.Monday, loadedAccount.DayOfWeek.Value);
      Assert.AreEqual(false, loadedAccount.Internal.Billable);

      logger.LogDebug("Finished CreateNonBillableAccount");

    }

    /// <summary>
    ///   (1) Create a corporate account with its payer id set to -1 and billable flag set to false.    
    ///   (2) Load the corporate account and check that the billable flag is false.
    ///   (3) Update the corporate account to non-billable and set its payer id to its own account id (self pay)
    ///   (4) Load the updated account and check that the billable flag is false.
    /// </summary>
    [Test]
    [Category("ChangeNonBillableToBillable")]
    public void T13ChangeNonBillableToBillable()
    {
      logger.LogDebug("Starting ChangeNonBillableToBillable");

      string username;
      string nameSpace = String.Empty;
      
      // Step (1)
      CoreSubscriber account = (CoreSubscriber)CreateAccount("CoreSubscriber", out username, ref nameSpace);
      InternalView internalView = CreateInternalView(UsageCycleType.Weekly,
                                                     true,
                                                     SecurityQuestion.MothersMaidenName,
                                                     LanguageCode.US,
                                                     SystemCurrencies.USD.ToString(),
                                                     TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);

      username = "NB_" + username;
      account.UserName = username;
      account.Internal = internalView;
      account.DayOfWeek = DayOfTheWeek.Monday;
      account.Internal.Billable = false;
      account.PayerID = corporateAccount._AccountID;
      account.AncestorAccountID = corporateAccount._AccountID;

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Step (2) Load the account 
      loadAccountClient.In_acct = new AccountIdentifier(username, nameSpace);
      loadAccountClient.In_timeStamp = MetraTime.Now;

      // Invoke the service
      loadAccountClient.Invoke();

      CoreSubscriber loadedAccount = (CoreSubscriber)loadAccountClient.Out_account;
      Assert.AreEqual(DayOfTheWeek.Monday, loadedAccount.DayOfWeek.Value);
      Assert.AreEqual(false, loadedAccount.Internal.Billable);
      
      // Step (3) Update the account
      loadedAccount.Internal.Billable = true;
      loadedAccount.PayerID = null;
      loadedAccount.PayerAccount = username;
      loadedAccount.PayerAccountNS = nameSpace;
      loadedAccount.Payment_StartDate = MetraTime.Now;

      AccountCreation_UpdateAccount_Client updateClient = new AccountCreation_UpdateAccount_Client();
      updateClient.UserName = "su";
      updateClient.Password = "su123";
      updateClient.In_Account = loadedAccount;

      updateClient.Invoke();

      // Step (4) Load the account and check it's billable flag and payer id
      loadAccountClient.Invoke();
      loadedAccount = (CoreSubscriber)loadAccountClient.Out_account;

      Assert.AreEqual(true, loadedAccount.Internal.Billable);
      Assert.AreEqual(loadedAccount.PayerID, loadedAccount._AccountID);
      
      logger.LogDebug("Finished ChangeNonBillableToBillable");
    }
    #endregion

    #region Negative Tests
    /// <summary>
    ///    (1) Creates a IndependentAccount with an invalid ancestor id.
    ///    // TODO: Fix to check real error message.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("CreateIndependentAccountWithInvalidAncestorId")]
    [Ignore("Activate when error handling is in place")]
    public void T14CreateIndependentAccountWithInvalidAncestorId()
    {
      logger.LogDebug("Starting CreateIndependentAccountWithInvalidAncestorId");

      string userName;
      string nameSpace = String.Empty;
      IndependentAccount account =
        (IndependentAccount)CreateAccount("IndependentAccount", out userName, ref nameSpace);

      account.AncestorAccountID = -10000;

      // Set the internal view
      account.Internal = internalView;

      // Add the contact views
      account.LDAP.Add(shipToContactView);
      account.LDAP.Add(billToContactView);

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // Load the account
      loadAccountClient.In_acct = new AccountIdentifier(userName, nameSpace);
      loadAccountClient.Invoke();

      IndependentAccount loadedAccount = loadAccountClient.Out_account as IndependentAccount;
      Assert.IsNotNull(loadedAccount);
      Assert.IsNotNull(loadedAccount.Internal);
      Assert.IsNotNull(loadedAccount.LDAP);
      Assert.AreEqual(2, loadedAccount.LDAP.Count);

      Assert.AreEqual(userName, loadedAccount.UserName);
      Assert.AreEqual(nameSpace, loadedAccount.Name_Space);
      Assert.AreEqual(AccountStatus.Active, loadedAccount.AccountStatus);

      // Check the internal view
      CheckInternalView(loadedAccount.Internal);
      // Check contact views
      CheckContactViews(loadedAccount.LDAP);

      logger.LogDebug("Finished CreateIndependentAccountWithInvalidAncestorId");
    }

    /// <summary>
    ///   (1) Create a self paying corporate account.
    ///   (2) Load the account created in (1).
    ///   (3) Set the billable flag to false.
    ///   (4) Update the account.
    ///   (5) Expect an error.
    /// </summary>
    [Test]
    [Ignore("Activate when error handling is in place")]
    [Category("ChangeBillableToNonBillableForSelfPayer")]
    public void T15ChangeBillableToNonBillableForSelfPayer()
    {
      logger.LogDebug("Starting ChangeBillableToNonBillableForSelfPayer");

      string username;
      string nameSpace = String.Empty;

      // (1) Create the corporate account
      CorporateAccount account = (CorporateAccount)CreateAccount("CorporateAccount", out username, ref nameSpace);
      InternalView internalView = CreateInternalView(UsageCycleType.Weekly,
                                                     true,
                                                     SecurityQuestion.MothersMaidenName,
                                                     LanguageCode.US,
                                                     SystemCurrencies.USD.ToString(),
                                                     TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_);
      account.Internal = internalView;
      account.DayOfWeek = DayOfTheWeek.Monday;

      // Create the account
      addAccountClient.InOut_Account = account;
      addAccountClient.Invoke();

      // (2) Load the account 
      loadAccountClient.In_acct = new AccountIdentifier(username, nameSpace);
      loadAccountClient.In_timeStamp = MetraTime.Now;

      // Invoke the service
      loadAccountClient.Invoke();

      CorporateAccount loadedAccount = (CorporateAccount)loadAccountClient.Out_account;

      // (3) Update billable flag to false
      loadedAccount.Internal.Billable = false;

      // (4) Update the account
      AccountCreation_UpdateAccount_Client updateClient = new AccountCreation_UpdateAccount_Client();
      updateClient.UserName = "su";
      updateClient.Password = "su123";
      updateClient.In_Account = loadedAccount;
      updateClient.Invoke();

      // Expect error

      logger.LogDebug("Finished ChangeBillableToNonBillableForSelfPayer");
    }
    #endregion

    /// <summary>
    ///   Helper method to create a CorporateAccount.
    /// </summary>
    /// <returns></returns>
    public static CorporateAccount CreateCorporateAccount()
    {
      CreateAccountTest accountTest = new CreateAccountTest();
      accountTest.Setup();
      return accountTest.corporateAccount;
    }

    private MetraTech.DomainModel.BaseTypes.Account CreateAccount(string typeName, out string userName, ref string nameSpace)
    {
      MetraTech.DomainModel.BaseTypes.Account account =
        MetraTech.DomainModel.BaseTypes.Account.CreateAccount(typeName);

      userName = string.Format("{0}_{1}_{2}", typeName, m_TestId, ++m_TestAccountNumber);
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

    private InternalView CreateInternalView(UsageCycleType usageCycleType, 
                                            bool billable,
                                            SecurityQuestion securityQuestion,
                                            LanguageCode language,
                                            string currency,
                                            TimeZoneID timezone)
    {
      InternalView internalView = (InternalView)View.CreateView(@"metratech.com/internal");
      internalView.UsageCycleType = usageCycleType;
      internalView.Billable = billable;
      internalView.SecurityQuestion = securityQuestion;
      internalView.Language = language;
      internalView.Currency = currency;
      internalView.TimezoneID = timezone;

      return internalView;
    }
    private void CheckInternalView(InternalView view)
    {
      Assert.AreEqual(internalView.UsageCycleType, view.UsageCycleType);
      Assert.AreEqual(internalView.Billable, view.Billable);
      Assert.AreEqual(internalView.SecurityQuestion, view.SecurityQuestion);
      Assert.AreEqual(internalView.Language, view.Language);
      Assert.AreEqual(internalView.Currency, view.Currency);
      Assert.AreEqual(internalView.TimezoneID, view.TimezoneID);
    }

    private void CheckContactViews(List<ContactView> views)
    {
      bool foundShipTo = false;
      bool foundBillTo = false;

      foreach (ContactView contactView in views)
      {
        if (contactView.ContactType == ContactType.Ship_To)
        {
          foundShipTo = true;
          CheckContactView(shipToContactView, contactView);
        }

        if (contactView.ContactType == ContactType.Bill_To)
        {
          foundBillTo = true;
          CheckContactView(billToContactView, contactView);
        }
      }

      Assert.IsTrue(foundShipTo);
      Assert.IsTrue(foundBillTo);
    }

    private void CheckContactView(ContactView expectedView, ContactView view)
    {
      Assert.AreEqual(expectedView.FirstName, view.FirstName);
      Assert.AreEqual(expectedView.LastName, view.LastName);
      Assert.AreEqual(expectedView.Country, view.Country);
    }

    private void CheckCorporateAccount(CorporateAccount account)
    {
      Assert.AreEqual(corporateAccount._AccountID, account._AccountID);
      Assert.AreEqual(corporateAccount.UserName, account.UserName);
      Assert.AreEqual(corporateAccount.Name_Space, account.Name_Space);
      Assert.AreEqual(corporateAccount.AncestorAccountID, account.AncestorAccountID);
    }

    #region Data
    private CorporateAccount corporateAccount;
    private InternalView internalView;
    private ContactView billToContactView;
    private ContactView shipToContactView;
    private AccountCreation_AddAccount_Client addAccountClient;
    private AccountService_LoadAccountWithViews_Client loadAccountClient;
    private Logger logger;

    private string m_TestId;
    private int m_TestAccountNumber = 0;
    #endregion
  }
}

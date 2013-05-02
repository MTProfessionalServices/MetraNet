using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.ServiceModel;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using NUnit.Framework;
using MetraTech.Core.Activities;
using MetraTech.Core.Workflows;
using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Account.ClientProxies;
//using MetraTech.Test.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.Core.Activities.Test
{
  /// <summary>
  ///    UpdateAccountTest
  /// 
  ///    To run this test fixture:
  ///     nunit-console /fixture:MetraTech.Core.Activities.Test.UpdateAccountTest /assembly:O:\debug\bin\MetraTech.Core.Activities.Test.dll
  /// </summary>
  /// <remarks>
  ///    The UpdateAccountTest class contains NUnit tests which exercise the account update 
  ///    functionality. Tests include updating both core account properties and account 
  ///    view properties.
  /// </remarks>
  [Category("NoAutoRun")]
  [TestFixture]
  public class UpdateAccountTest
  {
    /// <summary>
    ///    (1) Create corporate account
    ///    (2) Create load client
    ///    (3) Create update client
    /// </summary>
    #region Test Initialization and Cleanup
    [TestFixtureSetUp]
    public void Setup()
    {
      logger = new Logger("Logging\\UpdateAccountTest", "[" + this.GetType().Name + "]");

      // Create corporate account.
      corporateAccount = CreateAccountTest.CreateCorporateAccount();

      // Setup the add client
      addClient = new AccountCreation_AddAccount_Client();
      addClient.UserName = "su";
      addClient.Password = "su123";

      // Setup the load client
      loadClient = new AccountService_LoadAccountWithViews_Client();
      loadClient.UserName = "su";
      loadClient.Password = "su123";
      loadClient.In_timeStamp = MetraTime.Now;
      loadClient.In_acct = new AccountIdentifier(corporateAccount._AccountID.Value);

      // Setup the update client
      updateClient = new AccountCreation_UpdateAccount_Client();
      updateClient.UserName = "su";
      updateClient.Password = "su123";
    }
    
    /// <summary>
    ///   TearDown
    /// </summary>
    [TestFixtureTearDown]
    public void TearDown()
    {
    }
    #endregion

    /// <summary>
    ///    (1) Uses the corporate account created during setup.
    ///    (2) Updates the day of month for the account.
    ///    (3) Loads the updated account and verifies that the day of month is changed.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("UpdateAccountCore")]
    public void T01UpdateAccountCore()
    {
      // Update the cycle type
      updateClient.In_Account = corporateAccount;
      updateClient.In_Account.DayOfMonth = 10;
      updateClient.Invoke();
     
      // Load the updated account
      loadClient.Invoke();

      Assert.AreEqual(10, loadClient.Out_account.DayOfMonth);

    }

    /// <summary>
    ///    (1) Uses the corporate account created during setup.
    ///    (2) Updates contact information for the account.
    ///    (3) Loads the updated account and verifies that the contact information has changed.
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Test]
    [Category("UpdateAccountView")]
    public void T02UpdateAccountView()
    {
      updateClient.In_Account = corporateAccount;

      // Update the contact email
      string newEmail = "abc@yahoo.com";
      ShipToContactView.Email = newEmail;

      // Do the update
      updateClient.Invoke();

      // Load the updated account
      loadClient.Invoke();
      CorporateAccount loadedAccount = loadClient.Out_account as CorporateAccount;

      bool foundShipTo = false;

      foreach (ContactView contactView in loadedAccount.LDAP)
      {
        if (contactView.ContactType == ContactType.Ship_To)
        {
          foundShipTo = true;
          Assert.AreEqual(newEmail, contactView.Email);
        }
      }
      
      // Verify shipto was found
      Assert.IsTrue(foundShipTo);

    }

    /// <summary>
    ///   Use the AccountCreation_UpdateAccountView_Client to update the InternalView.
    /// </summary>
    [Test]
    [Category("UpdateAccountViewInternal")]
    public void T03UpdateAccountViewInternal()
    {
      AccountCreation_UpdateAccountView_Client updateClient = new AccountCreation_UpdateAccountView_Client();
      updateClient.UserName = "su";
      updateClient.Password = "su123";

      // Change the language code
      corporateAccount.Internal.Language = LanguageCode.JP;

      updateClient.In_Account = corporateAccount;
      updateClient.Invoke();

      // Load the updated account
      loadClient.Invoke();
      CorporateAccount loadedAccount = loadClient.Out_account as CorporateAccount;

      Assert.AreEqual(LanguageCode.JP, loadedAccount.Internal.Language);

    }

      /// <summary>
      ///  Create Core Subscriber account
      ///  Change Core Subscriber payer to corporation with mismatching account name/namespace/payerid
      ///  Change Core Subscriber payer to corporation without payerid and account name/namespace set to null
      /// </summary>
      [Test]
      [Category("ChangePayer")]
    public void T04ChangePayer()
      {
          CoreSubscriber account =
            (CoreSubscriber)MetraTech.DomainModel.BaseTypes.Account.CreateAccount("CoreSubscriber");
          string userName = "CoreSubscriberCPA" + "_" + MetraTime.Now.ToString("MM/dd HH:mm:ss.") + MetraTime.Now.Millisecond.ToString();
          string nameSpace = "mt";
          account.UserName = userName;
          account.Password_ = "123";
          account.Name_Space = nameSpace;
          account.DayOfMonth = 1;
          account.AccountStatus = AccountStatus.Active;

          account.AncestorAccountID = corporateAccount._AccountID;

          // Set the internal view
          InternalView internalView = (InternalView)View.CreateView(@"metratech.com/internal");
          internalView.Billable = true;
          internalView.Currency = "USD";
          internalView.Language = LanguageCode.US;
          internalView.UsageCycleType = UsageCycleType.Monthly;
          account.Internal = internalView;

          // Create the account
          AccountCreation_AddAccount_Client addAccountClient = new AccountCreation_AddAccount_Client();
          addAccountClient.UserName = "su";
          addAccountClient.Password = "su123";
          addAccountClient.InOut_Account = account;
          addAccountClient.Invoke();
          account = (CoreSubscriber)addAccountClient.InOut_Account;

          AccountService_LoadAccountWithViews_Client loadAccountClient = new AccountService_LoadAccountWithViews_Client();
          loadAccountClient.UserName = "su";
          loadAccountClient.Password = "su123";
          loadAccountClient.In_acct = new AccountIdentifier(account._AccountID.Value);
          loadAccountClient.In_timeStamp = MetraTime.Now;
          loadAccountClient.Invoke();
          account = (CoreSubscriber)loadAccountClient.Out_account;



          Assert.AreEqual(account._AccountID, account.PayerID);
          Assert.AreEqual(account.UserName, account.PayerAccount);

          // change the payer id, but leave old payer name 
          AccountCreation_UpdateAccount_Client updateAccountClient = new AccountCreation_UpdateAccount_Client();
          updateAccountClient.UserName = "su";
          updateAccountClient.Password = "su123";

          account.PayerID = corporateAccount._AccountID;
          updateAccountClient.In_Account = account;
          bool ExceptionRaised = false;
          try
          {
              updateAccountClient.Invoke();
              ExceptionRaised = false;
          }
          catch (System.ServiceModel.FaultException<MASBasicFaultDetail>)
          {
              ExceptionRaised = true;
          }
          Assert.IsTrue(ExceptionRaised, "FaultException was not raised on Invalid Update Payer call");

          // Update with correct parameters
          account.PayerAccountNS = null;
          account.PayerAccount = null;
          updateAccountClient.In_Account = account;
          updateAccountClient.Invoke();
          loadAccountClient.Invoke();
          account = (CoreSubscriber)loadAccountClient.Out_account;
          Assert.AreEqual(account.PayerID, corporateAccount._AccountID);
          Assert.AreEqual(account.PayerAccount, corporateAccount.UserName);

      }

    /// <summary>
    /// Change Account Status for bug 
    /// </summary>
    /// <returns></returns>
      [Test]
      [Category("ChangeAccountStatus")]
      public void T05ChangeAccountStatus()
      {
        MetraTech.Account.ClientProxies.AccountCreationClient client = null;

        try
        {
          client = new MetraTech.Account.ClientProxies.AccountCreationClient("WSHttpBinding_IAccountCreation");
          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";

          #region "  Payer account "
          // Add the corporate account
          string Payer01AccountName = "Payr_" + MetraTime.Now.ToString("MM/dd HH:mm:ss.") + MetraTime.Now.Millisecond.ToString();
          MetraTech.DomainModel.BaseTypes.Account acc = MetraTech.DomainModel.BaseTypes.Account.CreateAccount("CoreSubscriber");
          acc.UserName = Payer01AccountName;
          acc.AccountStartDate = MetraTime.Now;
          acc.AccountStatus = AccountStatus.Active;
          acc.AncestorAccountID = corporateAccount._AccountID;
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

          try
          {
            client.AddAccount(ref acc, false);
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            { err += "\\n" + msg; }
            //logger.LogErrorSQE(err);
          }
          catch (Exception)
          { // Handle other general errors not specific to service
          }
          #endregion

          #region "  Payee account  "
          // Add the corporate account
          string Payee01AccountName = "Payee_" + MetraTime.Now.ToString("MM/dd HH:mm:ss.") + MetraTime.Now.Millisecond.ToString();
          acc = MetraTech.DomainModel.BaseTypes.Account.CreateAccount("CoreSubscriber");
          acc.UserName = Payee01AccountName;
          acc.AccountStartDate = MetraTime.Now;
          acc.AccountStatus = AccountStatus.PendingActiveApproval;
          acc.AncestorAccountID = corporateAccount._AccountID;
          acc.DayOfMonth = 31;
          acc.Name_Space = "mt";
          acc.PayerAccount = Payer01AccountName;
          acc.PayerAccountNS = "mt";
          acc.Payment_StartDate = MetraTime.Now;
          acc.Payment_EndDate = DateTime.Parse("2010-07-5T00:00:00");
          acc.Password_ = "123";

          internalView = (InternalView)View.CreateView(@"metratech.com/internal");
          internalView.Billable = true;
          internalView.Currency = "USD";
          internalView.Language = LanguageCode.US;
          internalView.UsageCycleType = UsageCycleType.Monthly;
          acc.AddView(internalView, "Internal");

          contactView = (ContactView)View.CreateView(@"metratech.com/contact");
          contactView.ContactType = ContactType.Bill_To;
          contactView.Country = CountryName.USA;
          acc.AddView(contactView, "LDAP");

          try
          {
            client.AddAccount(ref acc, false);
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            { err += "\n" + msg; }
            Assert.Fail(err);
          }
          catch (Exception e)
          { // Handle other general errors not specific to service
            Assert.Fail(e.Message);
          }
          #endregion

          #region "  Update the status "

          AccountService_LoadAccountWithViews_Client loadAccountClient = new AccountService_LoadAccountWithViews_Client();
          loadAccountClient.UserName = "su";
          loadAccountClient.Password = "su123";
          loadAccountClient.In_acct = new AccountIdentifier(acc._AccountID.Value);
          loadAccountClient.In_timeStamp = MetraTime.Now;
          loadAccountClient.Invoke();
          acc = (CoreSubscriber)loadAccountClient.Out_account;

          acc.AccountStatus = AccountStatus.Active;
          try
          {
            //client.
            client.UpdateAccount(acc, false, null);
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            { err += "\n" + msg; }
            Assert.Fail("Unable to change account status: " + err);
          }
          catch (Exception e)
          { // Handle other general errors not specific to service
            Assert.Fail(e.Message);
          }

          #endregion
          client.Close();
        }
        catch (CommunicationException e)
        {          
          client.Abort();
          throw e;
        }
        catch (TimeoutException e)
        {
          client.Abort();
          throw e;
        }
        catch (Exception e)
        {
          client.Abort();
          throw e;
        }
      }


      /// <summary>
      /// Test for ESR-5825 re: ability to update an account with a start date in the future:
      ///    (1) Creates a CoreSubscriber with an InternalView, a ContactView,
      ///          a start date two days in the future and an end date two months in the future.
      ///    (2) Loads the created account using a loadtime equal to the start date and verifies that the core and view properties match.
      ///    (3) Updates the account's status using a loadtime equal to the start date.
      ///    (4) Loads the updated account and verifies that the status is changed.
      ///    (5) Updates the account's status using the default loadtime (should fail).
      ///    (6) Updates the account's status using a new client with the default loadtime (should fail).
      /// </summary>
      [Test]
      // [Ignore]
      [Category("UpdateCoreSubscriberWithFutureStartDate")]
      public void UpdateCoreSubscriberWithFutureStartDate()
      {
          bool bExceptionRaised = false;

          logger.LogDebug("Starting UpdateCoreSubscriberWithFutureStartDate");


          #region Create CoreSubscriber account with future start and end dates

          string userName = "FutureAcct_" + MetraTime.Now.ToString("MM/dd HH:mm:ss.") + MetraTime.Now.Millisecond.ToString();
          MetraTech.DomainModel.BaseTypes.Account acc = MetraTech.DomainModel.BaseTypes.Account.CreateAccount("CoreSubscriber");
          acc.UserName = userName;
          acc.AccountStatus = AccountStatus.PendingActiveApproval;
          acc.AncestorAccountID = corporateAccount._AccountID;
          acc.DayOfMonth = 31;
          acc.Name_Space = "mt";
          acc.PayerID = corporateAccount._AccountID;
          acc.Payment_StartDate = MetraTime.Now;
          acc.Payment_EndDate = DateTime.Parse("2010-07-5T00:00:00");
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

          // Set account's start date in the future.
          DateTime startDate = MetraTime.Now.AddDays(2);
          DateTime endDate = MetraTime.Now.AddMonths(2);
          acc.AccountStartDate = startDate;
          acc.AccountEndDate = endDate;

          addClient.InOut_Account = acc;
          addClient.In_ApplyAccountTemplate = false;

          try
          {
              logger.LogDebug("Calling AddClient");
              addClient.Invoke();
              logger.LogDebug("Successfully created account with a start date in the future");
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
              string err = fe.Message;

              foreach (string msg in fe.Detail.ErrorMessages)
              { err += "\n" + msg; }
              Assert.Fail(err);
          }
          catch (Exception e)
          { // Handle other general errors not specific to service
              Assert.Fail(e.Message);
          }

          #endregion


          #region Load the created account using a loadtime equal to the start date and verify some properties

          acc = (CoreSubscriber)addClient.InOut_Account;
          loadClient.In_acct = new AccountIdentifier(acc._AccountID.Value);
          loadClient.In_timeStamp = startDate;
          logger.LogDebug("Calling loadClient with loadtime equal to the (future) start date");
          loadClient.Invoke();
          logger.LogDebug("Successfully loaded account using loadtime equal to the (future) start date");

          CoreSubscriber loadedAccount = loadClient.Out_account as CoreSubscriber;
          Assert.IsNotNull(loadedAccount);
          Assert.IsNotNull(loadedAccount.Internal);
          Assert.IsNotNull(loadedAccount.LDAP);
          Assert.AreEqual(userName, loadedAccount.UserName);
          Assert.AreEqual("mt", loadedAccount.Name_Space);
          Assert.AreEqual(corporateAccount._AccountID, loadedAccount.PayerID);
          Assert.AreEqual(loadedAccount.AccountStatus, AccountStatus.PendingActiveApproval);

          // Check the dates
          // Because the days are initialized to start of day
          Assert.AreEqual(new DateTime(startDate.Year, startDate.Month, startDate.Day), loadedAccount.AccountStartDate);
          // End of period is end of day
          Assert.AreEqual(new DateTime(endDate.Year, endDate.Month, endDate.Day, 23, 59, 59), loadedAccount.AccountEndDate);

          #endregion


          #region Update the account's status using a loadtime equal to the start date

          updateClient.In_Account = loadedAccount;
          updateClient.In_Account.AccountStatus = AccountStatus.Active;
          updateClient.In_LoadTime = startDate;  // This is the new parameter for ESR-5825.
          logger.LogDebug("Calling updateClient");
          updateClient.Invoke();
          logger.LogDebug("Successfully updated account using loadtime equal to the (future) start date");

          #endregion


          #region Load the updated account (using same startdate-as-loadtime) and verify that the status has changed

          logger.LogDebug("Calling loadClient");
          loadClient.Invoke();
          logger.LogDebug("Successfully loaded account using loadtime equal to the (future) start date");
          loadedAccount = loadClient.Out_account as CoreSubscriber;
          Assert.AreEqual(loadedAccount.AccountStatus, AccountStatus.Active);

          #endregion


          #region Update the account using default loadtime (expect failure)

          updateClient.In_LoadTime = null;  // This is the new parameter for ESR-5825.
          bExceptionRaised = false;
          try
          {
              logger.LogDebug("Calling updateClient");
              updateClient.Invoke();
          }
          catch (System.ServiceModel.FaultException<MASBasicFaultDetail>)
          {
              logger.LogDebug("Raised expected exception when attempting to update account using default loadtime");
              bExceptionRaised = true;
          }
          // We expect an exception to be raised.
          Assert.IsTrue(bExceptionRaised, "FaultException was not raised on Update Account with default loadtime!");

          #endregion


          #region Update the account with a brand new client that uses default loadtime (expect failure)

          AccountCreation_UpdateAccount_Client updateClient2 = new AccountCreation_UpdateAccount_Client();
          updateClient2.UserName = "su";
          updateClient2.Password = "su123";
          updateClient2.In_Account = loadedAccount;
          updateClient2.In_Account.AccountStatus = AccountStatus.Suspended;

          bExceptionRaised = false;
          try
          {
              logger.LogDebug("Calling updateClient2");
              updateClient2.Invoke();
          }
          catch (System.ServiceModel.FaultException<MASBasicFaultDetail>)
          {
              logger.LogDebug("Raised expected exception when attempting to update account using new client with default loadtime");
              bExceptionRaised = true;
          }
          // We expect an exception to be raised.
          Assert.IsTrue(bExceptionRaised, "FaultException was not raised on Update Account using new client with default loadtime!");

          #endregion

          logger.LogDebug("Finished UpdateCoreSubscriberWithFutureStartDate");
      }


      #region Properties
    /// <summary>
    ///   ShipToContactView
    /// </summary>
    protected ContactView ShipToContactView
    {
      get
      {
        ContactView shipToContactView = null;
        foreach (ContactView contactView in corporateAccount.LDAP)
        {
          if (contactView.ContactType == ContactType.Ship_To)
          {
            shipToContactView = contactView;
          }
        }

        return shipToContactView;
      }
    }
    #endregion

    #region Data
    private CorporateAccount corporateAccount;
    private AccountCreation_AddAccount_Client addClient;
    private AccountService_LoadAccountWithViews_Client loadClient;
    private AccountCreation_UpdateAccount_Client updateClient;
    private Logger logger;
    #endregion
  }
}

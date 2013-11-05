using System;
using System.Collections.Generic;
using NUnit.Framework;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Test.Common;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;

namespace MetraTech.Core.Services.Test
{
  using DomainModel.BaseTypes;

  /// <summary>
  /// To run the this test fixture:
  /// nunit-console /fixture:MetraTech.Core.Services.Test.AccountServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
  /// </summary>
  [Category("NoAutoRun")]
  [TestFixture]
  public class AccountServiceTests
  {
    private int _mCorporateAccountId = -1;
    private const int DemoAccountId = 123;
    private AccountServiceClient _accountServiceClient;

    #region Test Initialization and Cleanup

    /// <summary>
    /// Save current state of affairs.
    /// </summary>
    [TestFixtureSetUp]
    public void InitTests()
    {
      // Create corporate account.
      var corporate = String.Format("AcctSvcTest_CorpAccount_{0}", Utils.GetTestId());
      Utils.CreateCorporation(corporate, MetraTime.Now);
      _mCorporateAccountId = Utils.GetSubscriberAccountID(corporate);

      _accountServiceClient = new AccountServiceClient {ClientCredentials = {UserName = {UserName = "su", Password = "su123"}}};
    }

    /// <summary>
    /// Restore system to state prior the test run.
    /// </summary>
    [TestFixtureTearDown]
    public void UninitTests()
    {
      if (_accountServiceClient == null) return;
      if (_accountServiceClient.State == CommunicationState.Opened)
      {
        _accountServiceClient.Close();
      }
      else
      {
        _accountServiceClient.Abort();
      }
    }

    #endregion

    #region Tests

    [Test]
    public void T01GetAccountListTest()
    {
      var accounts = new MTList<Account> {PageSize = 10, CurrentPage = 1};

      var fe = new MTFilterElement("username", MTFilterElement.OperationType.Like, "kevin%");
      accounts.Filters.Add(fe);

      fe = new MTFilterElement("FirstName", MTFilterElement.OperationType.Like, "k%");
      accounts.Filters.Add(fe);

      fe = new MTFilterElement("Currency", MTFilterElement.OperationType.Equal, "USD");
      accounts.Filters.Add(fe);

      accounts.SortCriteria.Add(new SortCriteria("_AccountID", SortType.Ascending));

      _accountServiceClient.GetAccountList(DateTime.Now, ref accounts, false);
    }

    /// <summary>
    /// Test load account.
    /// </summary>
    [Test]
    public void T02LoadAccountTest()
    {
      Account account;
      _accountServiceClient.LoadAccount(new AccountIdentifier(DemoAccountId), MetraTime.Now, out account);
      ValidateAccountId(DemoAccountId, account);
      ValidateIndependentAccount(account);
    }

    /// <summary>
    /// Test load account with all the views.
    /// </summary>
    [Test]
    public void T03LoadAccountWithViewsTest()
    {
      Account account;
      _accountServiceClient.LoadAccountWithViews(new AccountIdentifier(DemoAccountId), MetraTime.Now, out account);
      ValidateAccountId(DemoAccountId, account);
      ValidateIndependentAccount(account);
    }

    /// <summary>
    /// Test load a view for independant account
    /// </summary>
    [Test]
    public void T04LoadViewsIndependantAccountTest()
    {
      LoadAndValidateViews(DemoAccountId);

      List<View> views;
      _accountServiceClient.LoadView(new AccountIdentifier(DemoAccountId), "metratech.com/contact", out views);
      Assert.IsNotNull(views, "LoadView returned a null array, instead of an empty array");
      Assert.AreEqual(0, views.Count, "There should not be any contact views for independent account " + DemoAccountId);
    }

    /// <summary>
    /// Test load a view for corporate account
    /// </summary>
    [Test]
    public void T04LoadViewsCorporateAccountTest()
    {
      LoadAndValidateViews(_mCorporateAccountId);

      List<View> views;
      _accountServiceClient.LoadView(new AccountIdentifier(_mCorporateAccountId), "metratech.com/contact", out views);
      Assert.IsNotNull(views, "Corporate account contact views list missing");
      Assert.IsNotNull(views[0], "Corporate account contact view missing");
      Assert.AreEqual(1, views.Count, "Corporate account " + _mCorporateAccountId);

      var contact = (ContactView)views[0];
      Assert.AreEqual("330 Bear Hill Road", contact.Address1,
        "Invalid information returned in contact view for corporate account {0} ", _mCorporateAccountId); 
    }

    /// <summary>
    /// Test loading of corporate account.
    /// </summary>
    [Test]
    public void T05LoadCorporateAccountTest()
    {
      Account account;
      _accountServiceClient.LoadAccount(new AccountIdentifier(_mCorporateAccountId), MetraTime.Now, out account);
      ValidateAccountId(_mCorporateAccountId, account);
      var corpAccount = (CorporateAccount) account;
      Assert.IsNotNull(corpAccount.Internal, "InternalView is null");
      Assert.AreEqual(0, corpAccount.LDAP.Count, "ContactViews is not null");
    }

    /// <summary>
    /// Test loading of corporate account with views.
    /// </summary>
    [Test]
    public void T06LoadCorporateAccountWithViewsTest()
    {
      Account account;
      _accountServiceClient.LoadAccountWithViews(new AccountIdentifier(_mCorporateAccountId), MetraTime.Now, out account);
      ValidateAccountId(_mCorporateAccountId, account);
      var corpAccount = (CorporateAccount) account;
      Assert.IsNotNull(corpAccount.Internal, "InternalView is null");
      Assert.IsNotNull(corpAccount.LDAP, "ContactViews is null");
      Assert.AreEqual(1, corpAccount.LDAP.Count);
    }

    [Test]
    public void T07GetAccountListWithEnumFilterTest()
    {
      var accounts = new MTList<Account> {PageSize = 2, CurrentPage = 1};
      var fe = new MTFilterElement("Country", MTFilterElement.OperationType.Equal, "USA");
      accounts.Filters.Add(fe);
      accounts.SortCriteria.Add(new SortCriteria("_AccountID", SortType.Ascending));
      _accountServiceClient.GetAccountList(DateTime.Now, ref accounts, false);
    }

    #endregion

    #region PrivateMethods

    private static void ValidateIndependentAccount(Account account)
    {
      // Validate some results.
      var indAcc = (IndependentAccount)account;
      Assert.IsNotNull(indAcc.Internal, "InternalView is null for IndependentAccount: " + DemoAccountId);
      Assert.AreEqual(0, indAcc.LDAP.Count, "ContactViews is not empty for IndependentAccount: " + DemoAccountId);
    }

    private static void ValidateAccountId(int accountId, Account account)
    {
      Assert.AreEqual(accountId, account._AccountID, "Load account failed to get correct account id.");
    }

    private void LoadAndValidateViews(int accountId)
    {
      List<View> views;
      _accountServiceClient.LoadView(new AccountIdentifier(accountId), @"metratech.com/internal", out views);
      Assert.IsNotNull(views, "Account internal views list missing");
      Assert.IsNotNull(views[0], "Account internal view not found");
      Assert.AreEqual(1, views.Count, "There should be one account " + accountId);
    }
    #endregion
  }
}
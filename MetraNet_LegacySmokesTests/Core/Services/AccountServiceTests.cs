using System;
using System.Collections.Generic;
using NUnit.Framework;
using MetraTech.DomainModel.AccountTypes;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.AccountServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
    using MetraTech;
    using MetraTech.Test.Common;
    using MetraTech.DomainModel.Common;
  using MetraTech.DomainModel.BaseTypes;
    using MetraTech.Core.Services;
    using System.ServiceModel;
    using MetraTech.Core.Services.ClientProxies;
    using MetraTech.ActivityServices.Common;

  [Category("NoAutoRun")]
  [TestFixture]
    public class AccountServiceTests
    {
      private int mCorporateAccountId = -1;

      [Test]
      [Category("GetAccountListTest")]
      public void T01GetAccountListTest()
      {
          AccountServiceClient acs = null;
          try
          {
              acs = new AccountServiceClient();
              acs.ClientCredentials.UserName.UserName = "su";
              acs.ClientCredentials.UserName.Password = "su123";

              MTList<Account> accounts = new MTList<Account>();
              accounts.PageSize = 10;
              accounts.CurrentPage = 1;

              MTFilterElement fe = new MTFilterElement("username", MTFilterElement.OperationType.Like, "kevin%");
              accounts.Filters.Add(fe);

              fe = new MTFilterElement("FirstName", MTFilterElement.OperationType.Like, "k%");
              accounts.Filters.Add(fe);

              fe = new MTFilterElement("Currency", MTFilterElement.OperationType.Equal, "USD");
              accounts.Filters.Add(fe);

              accounts.SortCriteria.Add(new SortCriteria("_AccountID", SortType.Ascending));

              acs.GetAccountList(DateTime.Now, ref accounts,false);
          }
          finally
          {
              if (acs != null)
              {
                  if (acs.State == CommunicationState.Opened)
                  {
                      acs.Close();
                  }
                  else
                  {
                      acs.Abort();
                  }
              }
          }
      }

      /// <summary>
      /// Test load account.
      /// </summary>
      [Test]
      public void T02LoadAccountTest()
      {
          AccountServiceClient acs = null;
        try
        {
          acs = new AccountServiceClient();
          acs.ClientCredentials.UserName.UserName = "su";
          acs.ClientCredentials.UserName.Password = "su123";

          int accountId = 123;
          Account account = null;
          acs.LoadAccount(new AccountIdentifier(accountId), MetraTime.Now, out account);
          Assert.AreEqual(accountId, account._AccountID, "Load account failed to get correct account id.");

          // Validate some results.
          IndependentAccount indAcc = (IndependentAccount)account;
          Assert.IsNotNull(indAcc.Internal, "InternalView is null for IndependentAccount: 123");
          Assert.AreEqual(0, indAcc.LDAP.Count, "ContactViews is not empty for IndependentAccount: 123");
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          Utils.Trace("LoadAccountTest Failed");

          foreach (string msg in fe.Detail.ErrorMessages)
          {
            Utils.Trace("Error: " + msg);
          }

          Assert.Fail();
        }
        catch (Exception e)
        {
          Utils.Trace(e.Message);
          throw;
        }
        finally
        {
            if (acs != null)
            {
                if (acs.State == CommunicationState.Opened)
                {
                    acs.Close();
                }
                else
                {
                    acs.Abort();
                }
            }
        }
      }

      /// <summary>
      /// Test load account with all the views.
      /// </summary>
      [Test]
      public void T03LoadAccountWithViewsTest()
      {
          AccountServiceClient acs = null;
        try
        {
          acs = new AccountServiceClient();
          acs.ClientCredentials.UserName.UserName = "su";
          acs.ClientCredentials.UserName.Password = "su123";

          int accountId = 123;
          Account account = null;
          acs.LoadAccountWithViews(new AccountIdentifier(accountId), MetraTime.Now, out account);
          Assert.AreEqual(accountId, account._AccountID, "Load account failed to get correct account id.");

          // Validate some results.
          IndependentAccount indAcc = (IndependentAccount)account;
          Assert.IsNotNull(indAcc.Internal, "InternalView is null");
          Assert.IsNotNull(indAcc.LDAP, "ContactViews is null for IndependentAccount: 123");
          Assert.AreEqual(0, indAcc.LDAP.Count, "There should be no contacts for account 123");
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          Utils.Trace("LoadAccountWithViewsTest Failed");

          foreach (string msg in fe.Detail.ErrorMessages)
          {
            Utils.Trace("Error: " + msg);
          }

          Assert.Fail();
        }
        catch (Exception e)
        {
          Utils.Trace(e.Message);
          throw;
        }
        finally
        {
            if (acs != null)
            {
                if (acs.State == CommunicationState.Opened)
                {
                    acs.Close();
                }
                else
                {
                    acs.Abort();
                }
            }
        }
      }

      /// <summary>
      /// Test load a view.
      /// </summary>
      [Test]
      public void T04LoadViewsTest()
      {
          AccountServiceClient acs = null;
        try
        {
          acs = new AccountServiceClient();
          acs.ClientCredentials.UserName.UserName = "su";
          acs.ClientCredentials.UserName.Password = "su123";

          /*****
           * Independant Account
           *****/
          int accountId = 123;
          List<View> views = null;
          try
          {
            acs.LoadView(new AccountIdentifier(accountId), @"metratech.com/internal", out views);
            Assert.IsNotNull(views, "Independant account internal views list missing");
            Assert.IsNotNull(views[0], "Independant account internal view not found");
            Assert.AreEqual(1, views.Count, "Independent account 123");
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Utils.Trace("Load internal view for account 123 failed");

            foreach (string msg in fe.Detail.ErrorMessages)
            {
              Utils.Trace("Error: " + msg);
            }

            Assert.Fail();
          }          

          views = null;
          try
          {
            acs.LoadView(new AccountIdentifier(accountId), "metratech.com/contact", out views);
            Assert.IsNotNull(views, "LoadView returned a null array, instead of an empty array");
            Assert.AreEqual(0, views.Count, "There should not be any contact views for independent account 123");
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Utils.Trace("Load contact view for account 123 failed");

            foreach (string msg in fe.Detail.ErrorMessages)
            {
              Utils.Trace("Error: " + msg);
            }

            Assert.Fail();
          }

          /*****
           * Corporate Account
           *****/
          views = null;
          try
          {
            acs.LoadView(new AccountIdentifier(mCorporateAccountId), @"metratech.com/internal", out views);
            Assert.IsNotNull(views, "Corporate account internal views list missing");
            Assert.IsNotNull(views[0], "Corporate account internal view not found");
            Assert.AreEqual(1, views.Count, "Independent account 123");
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Utils.Trace("Failed to load internal view for corporate account " + mCorporateAccountId.ToString());

            foreach (string msg in fe.Detail.ErrorMessages)
            {
              Utils.Trace("Error: " + msg);
            }

            Assert.Fail();
          }          

          views = null;
          try
          {
            acs.LoadView(new AccountIdentifier(mCorporateAccountId), "metratech.com/contact", out views);
            Assert.IsNotNull(views, "Corporate account contact views list missing"); 
            Assert.IsNotNull(views[0], "Corporate account contact view missing");
            Assert.AreEqual(1, views.Count, "Corporate account " + mCorporateAccountId.ToString());

            ContactView contact = (ContactView) views[0];
            Assert.AreEqual(contact.Address1, "330 Bear Hill Road", "Invalid information returned in contact view for corporate account {0} ", mCorporateAccountId.ToString());
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Utils.Trace("Failed to load contact view for corporate account " + mCorporateAccountId.ToString());

            foreach (string msg in fe.Detail.ErrorMessages)
            {
              Utils.Trace("Error: " + msg);
            }

            Assert.Fail();
          }
        }
        catch (Exception e)
        {
          Utils.Trace(e.Message);
          throw;
        }
        finally
        {
            if (acs != null)
            {
                if (acs.State == CommunicationState.Opened)
                {
                    acs.Close();
                }
                else
                {
                    acs.Abort();
                }
            }
        }
      }

      /// <summary>
      /// Test loading of corporate account.
      /// </summary>
      [Test]
      public void T05LoadCorporateAccountTest()
      {
          AccountServiceClient acs = null;
        try
        {
          // Load account.
          acs = new AccountServiceClient();
          acs.ClientCredentials.UserName.UserName = "su";
          acs.ClientCredentials.UserName.Password = "su123";

          try
          {
            Account account = null;
            acs.LoadAccount(new AccountIdentifier(mCorporateAccountId), MetraTime.Now, out account);
            Assert.AreEqual(mCorporateAccountId, account._AccountID, "Load account failed to get correct account id.");
            CorporateAccount corpAccount = (CorporateAccount)account;
            Assert.IsNotNull(corpAccount.Internal, "InternalView is null");
            Assert.AreEqual(0, corpAccount.LDAP.Count, "ContactViews is not null");
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Utils.Trace("Failed to load CorporateAccount number " + mCorporateAccountId.ToString());

            foreach (string msg in fe.Detail.ErrorMessages)
            {
              Utils.Trace("Error: " + msg);
            }

            Assert.Fail();
          }
        }
        catch (Exception e)
        {
          Utils.Trace(e.Message);
          throw;
        }
        finally
        {
            if (acs != null)
            {
                if (acs.State == CommunicationState.Opened)
                {
                    acs.Close();
                }
                else
                {
                    acs.Abort();
                }
            }
        }
      }

      /// <summary>
      /// Test loading of corporate account with views.
      /// </summary>
      [Test]
      public void T06LoadCorporateAccountWithViewsTest()
      {
          AccountServiceClient acs = null;
        try
        {
          // Load account.
          acs = new AccountServiceClient();
          acs.ClientCredentials.UserName.UserName = "su";
          acs.ClientCredentials.UserName.Password = "su123";

          try
          {
            Account account = null;
            acs.LoadAccountWithViews(new AccountIdentifier(mCorporateAccountId), MetraTime.Now, out account);
            Assert.AreEqual(mCorporateAccountId, account._AccountID, "Load account failed to get correct account id.");
            CorporateAccount corpAccount = (CorporateAccount)account;
            Assert.IsNotNull(corpAccount.Internal, "InternalView is null");
            Assert.IsNotNull(corpAccount.LDAP, "ContactViews is null");
            Assert.AreEqual(1, corpAccount.LDAP.Count);
          }
          catch (FaultException<MASBasicFaultDetail> fe)
          {
            Utils.Trace("Failed to load CorporateAccount number " + mCorporateAccountId.ToString());

            foreach (string msg in fe.Detail.ErrorMessages)
            {
              Utils.Trace("Error: " + msg);
            }

            Assert.Fail();
          }          
        }
        catch (Exception e)
        {
          Utils.Trace(e.Message);
          throw;
        }
        finally
        {
            if (acs != null)
            {
                if (acs.State == CommunicationState.Opened)
                {
                    acs.Close();
                }
                else
                {
                    acs.Abort();
                }
            }
        }
      }

      [Test]
      [Category("GetAccountListWithEnumFilterTest")]
      public void T07GetAccountListWithEnumFilterTest()
      {
          AccountServiceClient acs = null;
          try
          {
              acs = new AccountServiceClient();
              acs.ClientCredentials.UserName.UserName = "su";
              acs.ClientCredentials.UserName.Password = "su123";

              MTList<Account> accounts = new MTList<Account>();
              accounts.PageSize = 2;
              accounts.CurrentPage = 1;

              MTFilterElement fe = new MTFilterElement("Country", MTFilterElement.OperationType.Equal, "USA");
              accounts.Filters.Add(fe);

              accounts.SortCriteria.Add(new SortCriteria("_AccountID", SortType.Ascending));

              acs.GetAccountList(DateTime.Now, ref accounts, false);
          }
          finally
          {
              if (acs != null)
              {
                  if (acs.State == CommunicationState.Opened)
                  {
                      acs.Close();
                  }
                  else
                  {
                      acs.Abort();
                  }
              }
          }
      }

	    /// <summary>
	    /// Save current state of affairs.
	    /// </summary>
	    [TestFixtureSetUp]
	    public void InitTests()
	    {
        // Create corporate account.
        string corporate = String.Format("AcctSvcTest_CorpAccount_{0}", Utils.GetTestId());
        Utils.CreateCorporation(corporate, MetraTime.Now);
        mCorporateAccountId = Utils.GetSubscriberAccountID(corporate);
      }

	    /// <summary>
	    /// Restore system to state prior the test run.
	    /// </summary>
	    [TestFixtureTearDown] 
	    public void UninitTests()
	    {
        // Do nothing
      }
  }
}

// EOF
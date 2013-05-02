using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
using MetraTech.DomainModel.BaseTypes;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.PropSet;
using MetraTech.Interop.MTRuleSet;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using System.Reflection;
using System.Collections.Generic;
using System.Threading;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.AccountUpdateTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//

namespace MetraTech.Approvals.Test
{
  
  [TestClass]
  //[Ignore("Account update tests not ready for prime time")]
  public class AccountUpdateTest
  {
    [ClassInitialize]
	  public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
    }

    [TestInitialize]
    public void TestSetup()
    {
      Monitor.Enter(LockClass.LockObject);
    }

    [TestCleanup]
    public void TestCleanup()
    {
      Monitor.Exit(LockClass.LockObject);
    }


    private Logger m_Logger = new Logger("[ApprovalManagementTest]");

    #region tests

    [TestMethod]
    [TestCategory("VerifyAccountUpdateWorksIndependentOfApprovals")]
    public void VerifyAccountUpdateWorksIndependentOfApprovals()
    {
      //Create the change
      int accountIdToUpdate = 123;

      //MetraTech.DomainModel.BaseTypes.Account account = new MetraTech.DomainModel.BaseTypes.Account();
      MetraTech.DomainModel.AccountTypes.IndependentAccount account = new IndependentAccount();

      account._AccountID = accountIdToUpdate;

      //Change something on the account
      ContactView shipToContactView;
      shipToContactView = (ContactView) MetraTech.DomainModel.BaseTypes.View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Rudi";
      shipToContactView.LastName = "Perkins";
      shipToContactView.Address1 = DateTime.Now.ToString();

      account.AddView(shipToContactView, "LDAP");

      //Apply the change
      MetraTech.Account.ClientProxies.AccountCreationClient accCreationtClient = null;
      accCreationtClient =
        new MetraTech.Account.ClientProxies.AccountCreationClient("WSHttpBinding_IAccountCreation");
      //accCreationtClient = new MetraTech.Account.ClientProxies.AccountCreationClient();
      accCreationtClient.ClientCredentials.UserName.UserName = "su";
      accCreationtClient.ClientCredentials.UserName.Password = "su123";

      //accCreationtClient.UpdateAccount(account, false);
      accCreationtClient.UpdateAccountView(account);
    }

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeAccount")]
    public void VerifyWeCanSerializeAccount()
    {
      //Create the change
      int accountIdToUpdate = 123;

      //MetraTech.DomainModel.BaseTypes.Account account = new MetraTech.DomainModel.BaseTypes.Account();
      MetraTech.DomainModel.AccountTypes.IndependentAccount accountIn = new IndependentAccount();

      accountIn._AccountID = accountIdToUpdate;

      //Change something on the account
      ContactView shipToContactView;
      shipToContactView = (ContactView) MetraTech.DomainModel.BaseTypes.View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Rudi";
      shipToContactView.LastName = "Perkins";
      shipToContactView.Address1 = DateTime.Now.ToString();

      accountIn.AddView(shipToContactView, "LDAP");

      //Now serialize it

      ChangeDetailsHelper changeDetailsOut = new ChangeDetailsHelper();
      changeDetailsOut["Account"] = accountIn;

      string buffer = changeDetailsOut.ToXml();

      MetraTech.DomainModel.AccountTypes.IndependentAccount accountOut;

      ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
      //Type[] myTypes = MetraTech.DomainModel.BaseTypes.Account.KnownTypes();
      changeDetailsIn.KnownTypes.AddRange(MetraTech.DomainModel.BaseTypes.Account.KnownTypes());
      changeDetailsIn.FromXml(buffer);

      object o = changeDetailsIn["Account"];
      accountOut = (MetraTech.DomainModel.AccountTypes.IndependentAccount) o;

      Assert.AreEqual(accountIn._AccountID, accountOut._AccountID);

    }

    [TestMethod]
    [TestCategory("SubmitAndApproveAccountUpdate")]
    public void SubmitAndApproveAccountUpdate()
    {
      string unitTestName = "SubmitAndApproveAccountUpdate";

      //Create the change
      int accountIdToUpdate = 123;

      //Because we cannot have more than one pending change, before we start our test
      //need to clear out any pending changes for this item from previous or failed tests
      SharedTestCodeApprovals.DenyOrDismissAllChangesThatMatch("AccountUpdate", accountIdToUpdate.ToString());

      //MetraTech.DomainModel.BaseTypes.Account account = new MetraTech.DomainModel.BaseTypes.Account();
      MetraTech.DomainModel.AccountTypes.IndependentAccount accountIn = new IndependentAccount();

      accountIn._AccountID = accountIdToUpdate;

      //Change something on the account
      ContactView shipToContactView;
      shipToContactView = (ContactView)MetraTech.DomainModel.BaseTypes.View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Rudi";
      shipToContactView.LastName = "Perkins";
      shipToContactView.Address1 = DateTime.Now.ToString();

      accountIn.AddView(shipToContactView, "LDAP");

      //Now serialize it
      ChangeDetailsHelper changeDetailsOut = new ChangeDetailsHelper();
      changeDetailsOut["Account"] = accountIn;

      string buffer = changeDetailsOut.ToXml();

      //Create and submit this change
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["AccountUpdate"].Enabled = true;

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "AccountUpdate";
      myNewChange.UniqueItemId = accountIdToUpdate.ToString();

      myNewChange.ChangeDetailsBlob = buffer;

      myNewChange.ItemDisplayName = "Demo";
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + DateTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrieved);

      Assert.AreEqual(changeDetailsRetrieved, myNewChange.ChangeDetailsBlob, "The submitted change details are different from the change details retrieved from the framework");

      //Login in as admin user and approve the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveAccountUpdate();

      approvalFramework.ApproveChange(myChangeId, "Approved by approval framework unit test");

      MTList<ChangeSummary> pendingChangesAfterApproval = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterApproval);

      MTList<ChangeSummary> changesAfterApproval = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref changesAfterApproval);

      //Find our change and make sure state is approved
      ChangeSummary change = null;
      bool foundIt = false;
      for (int i = 0; i < changesAfterApproval.Items.Count; i++)
      {
        change = changesAfterApproval.Items[i];
        if (change.Id == myChangeId)
        {
          foundIt = true;
          break;
        }
      }

      Assert.IsTrue(foundIt, "Couldn't find our approved change with id " + myChangeId);
      Assert.AreEqual(change.CurrentState, ChangeState.Applied, string.Format("Found the approved change with id {0} but the state was '{1}' and not 'Approved'", myChangeId, change.CurrentState));

    }
  
    #endregion
 

  }
}
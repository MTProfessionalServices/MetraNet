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
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.ProductCatalog;
using System.Collections.Generic;
using MetraTech.Core.Services.ClientProxies;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.GroupSubscriptionMemberAddTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
// Note: This test that works with rate schedules requires some rate schedule to run with/against
// Run T:\Development\Core\MTProductCatalog\SimpleSetup.vbs to get some basic rates that this unit test will copy and use as its own
namespace MetraTech.Approvals.Test
{
  [TestClass]
  //[Ignore("Rate update tests not ready for prime time")]
  public class GroupSubscriptionMemberUpdateTest
  {

    private Logger mLogger = new Logger("[ApprovalManagementTest.GroupSubscriptionMembers]");

    [ClassInitialize]
	public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
    }

    #region tests

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeGroupSubscriptionUpdateArguments")]
    public void VerifyWeCanSerializeGroupSubscriptionUpdateArguments()
    {
      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = new GroupSubscriptionMember();
      gsubMember.AccountId = 1;
      gsubMember.MembershipSpan = new ProdCatTimeSpan();
      gsubMember.MembershipSpan.StartDate = MetraTime.Now;
      newMembers.Add(gsubMember);

      ChangeDetailsHelper changeDetailsOut = new ChangeDetailsHelper();
      changeDetailsOut["groupSubscriptionId"] = 111;
      changeDetailsOut["groupSubscriptionMembers"] = newMembers;

      string buffer = changeDetailsOut.ToXml();

      ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
      changeDetailsIn.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
      changeDetailsIn.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
      changeDetailsIn.FromXml(buffer);

      object o = changeDetailsIn["groupSubscriptionMembers"];
      List<GroupSubscriptionMember> membersOut = (List<GroupSubscriptionMember>)o;

      //Assert.AreEqual(accountIn._AccountID, accountOut._AccountID);
    }

    
    [TestMethod]
    [TestCategory("VerifyWeCanUpdateGroupSubscriptionMembersIndependentOfApprovals")]
    public void VerifyWeCanUpdateGroupSubscriptionMembersIndependentOfApprovals()
    {
      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSUpd_NoA";
      string testRun = MetraTime.Now.ToString();
      string testUserName = "su";
      string testPassword = "su123";

      IMTProductOffering productOffering = ProductOfferingFactory.Create(testName, testRun);

      //CorporateAccount corporateAccount = CorporateAccountFactory.Create(testName, testRun);
      CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testName, testRun);
      corpAccountHolder.Instantiate();

      CoreSubscriber subscriberForDiscount = corpAccountHolder.AddCoreSubscriber("Rudi");

      List<int> memberAccountIds = new List<int>();
      memberAccountIds.Add((int)subscriberForDiscount._AccountID);


      GroupSubscription groupSubscription = GroupSubscriptionFactory.Create(testName, testRun, productOffering.ID, (int)corpAccountHolder.Item._AccountID, memberAccountIds, testUserName, testPassword);
      #endregion

      #region Test and Verify

      //Now add another account and add them to group subscription
      CoreSubscriber newSubscriber = corpAccountHolder.AddCoreSubscriber("M1");

      //Now add this account to the group subscription and save
      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = null;

        gsubMember = new GroupSubscriptionMember();
        gsubMember.AccountId = newSubscriber._AccountID.Value;
        gsubMember.MembershipSpan = new ProdCatTimeSpan();
        gsubMember.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
        newMembers.Add(gsubMember);
      
      //Initialize the client and call AddMembers
      GroupSubscriptionService_AddMembersToGroupSubscription_Client addMembersClient = new GroupSubscriptionService_AddMembersToGroupSubscription_Client();
    
      addMembersClient.UserName = testUserName;
      addMembersClient.Password = testPassword;

      addMembersClient.In_groupSubscriptionId = groupSubscription.GroupId.Value;
      addMembersClient.In_groupSubscriptionMembers = newMembers;
      addMembersClient.Invoke();

      //TODO: Verify member was added

      //Now update the member

      List<GroupSubscriptionMember> membersToUpdate = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToUpdate = null;

      gsubMemberToUpdate = new GroupSubscriptionMember();
      gsubMemberToUpdate.AccountId = newSubscriber._AccountID.Value;
      gsubMemberToUpdate.GroupId = groupSubscription.GroupId;
      gsubMemberToUpdate.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      gsubMemberToUpdate.MembershipSpan.EndDate = gsubMemberToUpdate.MembershipSpan.StartDate.Value.AddMonths(1);

      membersToUpdate.Add(gsubMemberToUpdate);

      GroupSubscriptionService_UpdateGroupSubscriptionMember_Client updateGroupSubMemClient = new GroupSubscriptionService_UpdateGroupSubscriptionMember_Client();

      updateGroupSubMemClient.UserName = testUserName;
      updateGroupSubMemClient.Password = testPassword;


      updateGroupSubMemClient.In_groupSubscriptionMember = gsubMemberToUpdate;
      updateGroupSubMemClient.Invoke();

      #endregion
    }


    [TestMethod]
    [TestCategory("ApplyGroupSubscriptionUpdateMembers")]
    public void ApplyGroupSubscriptionUpdateMembers()
    {

      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSDel_Apply";
      string testRun = MetraTime.Now.ToString();
      string testUserName = "su";
      string testPassword = "su123";

      IMTProductOffering productOffering = ProductOfferingFactory.Create(testName, testRun);

      //CorporateAccount corporateAccount = CorporateAccountFactory.Create(testName, testRun);
      CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testName, testRun);
      corpAccountHolder.Instantiate();

      CoreSubscriber subscriberForDiscount = corpAccountHolder.AddCoreSubscriber("Rudi");

      List<int> memberAccountIds = new List<int>();
      memberAccountIds.Add((int)subscriberForDiscount._AccountID);


      GroupSubscription groupSubscription = GroupSubscriptionFactory.Create(testName, testRun, productOffering.ID, (int)corpAccountHolder.Item._AccountID, memberAccountIds, testUserName, testPassword);
      #endregion

      #region Test and Verify

      //Now add another account and add them to group subscription
      CoreSubscriber newSubscriber = corpAccountHolder.AddCoreSubscriber("M1");

      //Now add this account to the group subscription and save
      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = null;

      gsubMember = new GroupSubscriptionMember();
      gsubMember.AccountId = newSubscriber._AccountID.Value;
      gsubMember.MembershipSpan = new ProdCatTimeSpan();
      gsubMember.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      newMembers.Add(gsubMember);


      //Serialize the details
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetails["groupSubscriptionMembers"] = newMembers;

      string buffer = changeDetails.ToXml();


      //Create and submit this change
      //Make sure approvals are not enabled for RateUpdate so we can apply immediately
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["GroupSubscription.AddMembers"].Enabled = false; //By setting to false, the change will be applied directly
      approvalsConfig["GroupSubscription.UpdateMember"].Enabled = false; //By setting to false, the change will be applied directly

      ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalsFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      //MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      //approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.AddMembers";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = buffer;

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Adding member to group subscription: Unit Test " + testName + " on " + DateTime.Now;

      int myChangeId;
      approvalsFramework.SubmitChange(myNewChange, out myChangeId);

      mLogger.LogInfo("Successfully added account {0}({1}) to group subscription for corporate account{2}({3})", newSubscriber.UserName, newSubscriber._AccountID, corpAccountHolder.Item.UserName, corpAccountHolder.Item._AccountID);

      //TODO: Verify member was added

      //Now update the member

      List<GroupSubscriptionMember> membersToUpdate = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToUpdate = null;

      gsubMemberToUpdate = new GroupSubscriptionMember();
      gsubMemberToUpdate.AccountId = newSubscriber._AccountID.Value;
      gsubMemberToUpdate.GroupId = groupSubscription.GroupId;
      gsubMemberToUpdate.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      gsubMemberToUpdate.MembershipSpan.EndDate = gsubMemberToUpdate.MembershipSpan.StartDate.Value.AddMonths(1);

      membersToUpdate.Add(gsubMemberToUpdate);


      //Serialize the details
      ChangeDetailsHelper changeDetailsForUpdate = new ChangeDetailsHelper();
      changeDetailsForUpdate["groupSubscriptionMember"] = gsubMemberToUpdate;

      //Create/Populate the change to be submitted for approval
      //Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.UpdateMember";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetailsForUpdate.ToXml();

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Updating member from group subscription: Unit Test " + testName + " on " + DateTime.Now;

      //int myChangeId;
      approvalsFramework.SubmitChange(myNewChange, out myChangeId);

      #endregion



    }

    [TestMethod]
    [TestCategory("GroupSubscriptionMembers")]
    [TestCategory("SubmitApproveGroupSubscriptionUpdateMembersScenario")]
    public void SubmitApproveGroupSubscriptionUpdateMembersScenario()
    {
      #region Prepare

      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSUpd_App";
      string testRun = MetraTime.Now.ToString();
      string testUserName = "su";
      string testPassword = "su123";

      IMTProductOffering productOffering = ProductOfferingFactory.Create(testName, testRun);

      //CorporateAccount corporateAccount = CorporateAccountFactory.Create(testName, testRun);
      CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testName, testRun);
      corpAccountHolder.Instantiate();

      CoreSubscriber subscriberForDiscount = corpAccountHolder.AddCoreSubscriber("Rudi");

      //Now add another account to be unsubscribed them to group subscription
      CoreSubscriber subscriberToBeUpdated = corpAccountHolder.AddCoreSubscriber("Un1");

      List<int> memberAccountIds = new List<int>();
      memberAccountIds.Add((int)subscriberForDiscount._AccountID);
      memberAccountIds.Add((int)subscriberToBeUpdated._AccountID);

      GroupSubscription groupSubscription = GroupSubscriptionFactory.Create(testName, testRun, productOffering.ID, (int)corpAccountHolder.Item._AccountID, memberAccountIds, testUserName, testPassword);

      //Prepare the change
      //Create the necessary arguments
      List<GroupSubscriptionMember> membersToUpdate = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToUpdate = null;

      gsubMemberToUpdate = new GroupSubscriptionMember();
      gsubMemberToUpdate.AccountId = subscriberToBeUpdated._AccountID.Value;
      gsubMemberToUpdate.GroupId = groupSubscription.GroupId;
      gsubMemberToUpdate.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      gsubMemberToUpdate.MembershipSpan.EndDate = gsubMemberToUpdate.MembershipSpan.StartDate.Value.AddMonths(1);

      membersToUpdate.Add(gsubMemberToUpdate);


      //Serialize the details
      ChangeDetailsHelper changeDetailsForUpdate = new ChangeDetailsHelper();
      changeDetailsForUpdate["groupSubscriptionMember"] = gsubMemberToUpdate;

      //Create/Populate the change to be submitted for approval
      Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.UpdateMember";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetailsForUpdate.ToXml();

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Updating members of group subscription: Ending subscription on " + gsubMemberToUpdate.MembershipSpan.EndDate + ": Unit Test " + testName + " on " + DateTime.Now;
      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitApproveScenario("SubmitApproveGroupSubscriptionUpdateMembersScenario",
        myNewChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        SharedTestCodeApprovals.LoginAsUserWhoCanApproveGroupSubscriptionMembershipUpdate(),
        VerifyMembersHaveNotBeenUpdated,
        VerifyMemberHasBeenUpdated,
        groupSubscription.GroupId.Value);
    }

    #endregion

    #region Internal
    public static bool VerifyMemberHasBeenUpdated(Change change, object myUserDefinedObject)
    {
      return CompareGroupSubscriptionMemberInChangeWithDatabase(change, true);
    }

    public static bool VerifyMembersHaveNotBeenUpdated(Change change, object myUserDefinedObject)
    {
      return CompareGroupSubscriptionMemberInChangeWithDatabase(change, false);
    }

    protected static bool CompareGroupSubscriptionMemberInChangeWithDatabase(Change change, bool ShouldBeSame)
    {
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
      changeDetails.FromBuffer(change.ChangeDetailsBlob);

      GroupSubscriptionMember fromChange = (GroupSubscriptionMember)changeDetails["groupSubscriptionMember"];
      Assert.IsNotNull(fromChange, "Unable to get GroupSubscriptionMember from change");
      Assert.IsTrue(fromChange.AccountId > 0);

      int idGroupSubscription = fromChange.GroupId.Value;
      MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      GroupSubscriptionMember fromDatabase = groupSubscriptionMembers.Items.Find(
            delegate(GroupSubscriptionMember gsm)
            {
              return gsm.AccountId == fromChange.AccountId;
            }
            );

      Assert.IsNotNull(fromDatabase, string.Format("Unable to get GroupSubscriptionMember from database for group subscription {0} and account {1}", idGroupSubscription, fromChange.AccountId));

      //Eventually could write a better/more detailed comparison, for now just check the EndDate which is the value
      //updated by the one test that uses this
      if (ShouldBeSame)
      {
        //Verify that the end date matches
        Assert.AreEqual(fromChange.MembershipSpan.EndDate.RoundToSqlServerDateTime().RoundToSecond(), fromDatabase.MembershipSpan.EndDate.RoundToSqlServerDateTime());

        //Checking that the membership span has been increase by a month is not absolutely necessary and could be removed
        //if we need to reuse this verification function
        Assert.AreEqual(fromDatabase.MembershipSpan.StartDate.RoundToSqlServerDateTime().Value.AddMonths(1), fromDatabase.MembershipSpan.EndDate.RoundToSqlServerDateTime());
      }
      else
      {
        //Verify that the end date does not match
        Assert.AreNotEqual(fromChange.MembershipSpan.EndDate.RoundToSqlServerDateTime().RoundToSecond(), fromDatabase.MembershipSpan.EndDate.RoundToSqlServerDateTime());
      }

      //Just return true, if they are not correct we would have Asserted
      return true;
    }
    #endregion
  }
}
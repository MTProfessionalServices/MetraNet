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
  public class GroupSubscriptionMemberUnsubscribeTest
  {

    private Logger mLogger = new Logger("[ApprovalManagementTest.GroupSubscriptionMembers]");

    #region tests

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeGroupSubscriptionUnsubscribeArguments")]
    public void VerifyWeCanSerializeGroupSubscriptionUnsubscribeArguments()
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
    [TestCategory("VerifyWeCanUnsubscribeGroupSubscriptionMembersIndependentOfApprovals")]
    public void VerifyWeCanUnsubscribeGroupSubscriptionMembersIndependentOfApprovals()
    {
      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSUnS_NoA";
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

      //Now unsubscribe the member two days after

      List<GroupSubscriptionMember> membersToUnsubscribe = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToUnsubscribe = null;

      gsubMemberToUnsubscribe = new GroupSubscriptionMember();
      gsubMemberToUnsubscribe.AccountId = newSubscriber._AccountID.Value;
      gsubMemberToUnsubscribe.GroupId = groupSubscription.GroupId;
      gsubMemberToUnsubscribe.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      gsubMemberToUnsubscribe.MembershipSpan.EndDate = gsubMemberToUnsubscribe.MembershipSpan.StartDate.Value.AddDays(2);

      membersToUnsubscribe.Add(gsubMemberToUnsubscribe);

      GroupSubscriptionService_UnsubscribeGroupSubscriptionMembers_Client unsubscribeGroupSubMembersClient = new GroupSubscriptionService_UnsubscribeGroupSubscriptionMembers_Client();
      unsubscribeGroupSubMembersClient.UserName = testUserName;
      unsubscribeGroupSubMembersClient.Password = testPassword;

      unsubscribeGroupSubMembersClient.In_groupSubscriptionMembers = membersToUnsubscribe;
      unsubscribeGroupSubMembersClient.Invoke();

      //TODO: Verify they are unsubscribed

      #endregion
    }


    //[TestMethod]
    //[TestCategory("ApplyGroupSubscriptionUnsubscribeMembers")]
    public void ApplyGroupSubscriptionUnsubscribeMembers()
    {

      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSUnS_Apply";
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

      ////Initialize the client and call AddMembers
      //GroupSubscriptionService_AddMembersToGroupSubscription_Client addMembersClient = new GroupSubscriptionService_AddMembersToGroupSubscription_Client();

      //addMembersClient.UserName = testUserName;
      //addMembersClient.Password = testPassword;
      //addMembersClient.In_groupSubscriptionId = groupSubscription.GroupId.Value;
      //addMembersClient.In_groupSubscriptionMembers = newMembers;
      //addMembersClient.Invoke();

      //Serialize the details
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetails["groupSubscriptionMembers"] = newMembers;

      string buffer = changeDetails.ToXml();


      //Create and submit this change
      //Make sure approvals are not enabled for RateUpdate so we can apply immediately
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["GroupSubscription.AddMembers"].Enabled = false; //By setting to false, the change will be applied directly
      approvalsConfig["GroupSubscription.UnsubscribeMembers"].Enabled = false; //By setting to false, the change will be applied directly

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

      //Now unsubscribe this member

      List<GroupSubscriptionMember> membersToUnsubscribe = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToUnsubscribe = null;

      gsubMemberToUnsubscribe = new GroupSubscriptionMember();
      gsubMemberToUnsubscribe.AccountId = newSubscriber._AccountID.Value;
      gsubMemberToUnsubscribe.GroupId = groupSubscription.GroupId;
      gsubMemberToUnsubscribe.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      gsubMemberToUnsubscribe.MembershipSpan.EndDate = gsubMemberToUnsubscribe.MembershipSpan.StartDate.Value.AddDays(2);

      membersToUnsubscribe.Add(gsubMemberToUnsubscribe);


      //GroupSubscriptionService_UnsubscribeGroupSubscriptionMembers_Client unsubscribeGroupSubMembersClient = new GroupSubscriptionService_UnsubscribeGroupSubscriptionMembers_Client();
      //unsubscribeGroupSubMembersClient.UserName = testUserName;
      //unsubscribeGroupSubMembersClient.Password = testPassword;

      //unsubscribeGroupSubMembersClient.In_groupSubscriptionMembers = membersToUnsubscribe;
      //unsubscribeGroupSubMembersClient.Invoke();



      //Serialize the details
      ChangeDetailsHelper changeDetailsForUnsubscribe = new ChangeDetailsHelper();
      //changeDetailsForDelete["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetailsForUnsubscribe["groupSubscriptionMembers"] = membersToUnsubscribe;

      //Create/Populate the change to be submitted for approval
      //Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.UnsubscribeMembers";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetailsForUnsubscribe.ToXml();

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Unsubscribing members from group subscription: Unit Test " + testName + " on " + DateTime.Now;

      //int myChangeId;
      approvalsFramework.SubmitChange(myNewChange, out myChangeId);

      #endregion



    }

    [TestMethod]
    [TestCategory("GroupSubscriptionMembers")]
    [TestCategory("SubmitApproveGroupSubscriptionUnsubscribeMembersScenario")]
    public void SubmitApproveGroupSubscriptionUnsubscribeMembersScenario()
    {
      #region Prepare

      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSUns_App";
      string testRun = MetraTime.Now.ToString();
      string testUserName = "su";
      string testPassword = "su123";

      IMTProductOffering productOffering = ProductOfferingFactory.Create(testName, testRun);

      //CorporateAccount corporateAccount = CorporateAccountFactory.Create(testName, testRun);
      CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testName, testRun);
      corpAccountHolder.Instantiate();

      CoreSubscriber subscriberForDiscount = corpAccountHolder.AddCoreSubscriber("Rudi");
      
      //Now add another account to be unsubscribed them to group subscription
      CoreSubscriber subscriberToBeUnsubscribed = corpAccountHolder.AddCoreSubscriber("Un1");

      List<int> memberAccountIds = new List<int>();
      memberAccountIds.Add((int)subscriberForDiscount._AccountID);
      memberAccountIds.Add((int)subscriberToBeUnsubscribed._AccountID);

      GroupSubscription groupSubscription = GroupSubscriptionFactory.Create(testName, testRun, productOffering.ID, (int)corpAccountHolder.Item._AccountID, memberAccountIds, testUserName, testPassword);

      //Prepare the change
      //Create the necessary arguments
      List<GroupSubscriptionMember> membersToUnsubscribe = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToUnsubscribe = null;

      gsubMemberToUnsubscribe = new GroupSubscriptionMember();
      gsubMemberToUnsubscribe.AccountId = subscriberToBeUnsubscribed._AccountID.Value;
      gsubMemberToUnsubscribe.GroupId = groupSubscription.GroupId;
      gsubMemberToUnsubscribe.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      gsubMemberToUnsubscribe.MembershipSpan.EndDate = gsubMemberToUnsubscribe.MembershipSpan.StartDate.Value.AddDays(2);

      membersToUnsubscribe.Add(gsubMemberToUnsubscribe);

      //Serialize the details
      ChangeDetailsHelper changeDetailsForUnsubscribe = new ChangeDetailsHelper();
      //changeDetailsForDelete["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetailsForUnsubscribe["groupSubscriptionMembers"] = membersToUnsubscribe;

      //Create/Populate the change to be submitted for approval
      Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.UnsubscribeMembers";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetailsForUnsubscribe.ToXml();

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Unsubscribing members from group subscription on " + gsubMemberToUnsubscribe.MembershipSpan.EndDate + ": Unit Test " + testName + " on " + DateTime.Now;
      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitApproveScenario("SubmitApproveGroupSubscriptionUnsubscribeMembersScenario",
        myNewChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        SharedTestCodeApprovals.LoginAsUserWhoCanApproveGroupSubscriptionMembershipUpdate(),
        VerifyMembersHaveNotBeenUnsubscribed,
        VerifyMembersHaveBeenUnsubscribed,
        groupSubscription.GroupId.Value);
    }

    #endregion

    #region Internal
    public static bool VerifyMembersHaveBeenUnsubscribed(Change change, object myUserDefinedObject)
    {
      //int idGroupSubscription = (int)myUserDefinedObject;
      //MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      //ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      //changeDetails.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
      //changeDetails.FromBuffer(change.ChangeDetailsBlob);

      //List<GroupSubscriptionMember> membersToDelete = (List<GroupSubscriptionMember>)changeDetails["groupSubscriptionMembers"];

      //bool allMembersFound = true;
      //string membersNotFound = "";
      //foreach (GroupSubscriptionMember gsmThatShouldExist in membersToDelete)
      //{
      //  if (null == groupSubscriptionMembers.Items.Find(
      //      delegate(GroupSubscriptionMember gsm)
      //      {
      //        return gsm.AccountId == gsmThatShouldExist.AccountId;
      //      }
      //      ))
      //  {
      //    allMembersFound = false;
      //    membersNotFound += gsmThatShouldExist.AccountId + ";";
      //  }
      //}

      //Assert.True(allMembersFound, "The following members do not exist in the group subscription: " + membersNotFound);

      //return allMembersFound;

      return true;
    }

    public static bool VerifyMembersHaveNotBeenUnsubscribed(Change change, object myUserDefinedObject)
    {
      //int idGroupSubscription = (int)myUserDefinedObject;
      //MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      //ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      //changeDetails.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
      //changeDetails.FromBuffer(change.ChangeDetailsBlob);

      //List<GroupSubscriptionMember> membersToDelete = (List<GroupSubscriptionMember>)changeDetails["groupSubscriptionMembers"];

      //bool allMembersNotFound = true;
      //string membersFound = "";
      //foreach (GroupSubscriptionMember gsmThatShouldNotExist in membersToDelete)
      //{
      //  if (null != groupSubscriptionMembers.Items.Find(
      //      delegate(GroupSubscriptionMember gsm)
      //      {
      //        return gsm.AccountId == gsmThatShouldNotExist.AccountId;
      //      }
      //      ))
      //  {
      //    allMembersNotFound = false;
      //    membersFound += gsmThatShouldNotExist.AccountId + ";";
      //  }
      //}

      //Assert.True(allMembersNotFound, "The following members exist in the group subscription: " + membersFound);

      //return allMembersNotFound;

      return true;
    }
    #endregion

  }
}
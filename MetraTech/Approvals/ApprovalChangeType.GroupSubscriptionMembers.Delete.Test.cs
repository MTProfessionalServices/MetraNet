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
namespace MetraTech.Approvals.Test
{
  [TestClass]
  //[Ignore("Rate update tests not ready for prime time")]
  public class GroupSubscriptionMemberDeleteTest
  {
    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
    }

    private Logger mLogger = new Logger("[ApprovalManagementTest.GroupSubscriptionMembers]");

    #region tests

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeGroupSubscriptionDeleteArguments")]
    public void VerifyWeCanSerializeGroupSubscriptionDeleteArguments()
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
    [TestCategory("VerifyWeCanDeleteGroupSubscriptionMembersIndependentOfApprovals")]
    public void VerifyWeCanDeleteGroupSubscriptionMembersIndependentOfApprovals()
    {
      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSDel_NoA";
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

      //Now delete the member

      List<GroupSubscriptionMember> membersToDelete = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToDelete = null;

      gsubMemberToDelete = new GroupSubscriptionMember();
      gsubMemberToDelete.AccountId = newSubscriber._AccountID.Value;
      //Not sure if begin/end date needs to be set

      membersToDelete.Add(gsubMemberToDelete);


      GroupSubscriptionService_DeleteMembersFromGroupSubscription_Client deleteMembersClient = new GroupSubscriptionService_DeleteMembersFromGroupSubscription_Client();

      deleteMembersClient.UserName = testUserName;
      deleteMembersClient.Password = testPassword;

      deleteMembersClient.In_groupSubscriptionId = groupSubscription.GroupId.Value;
      deleteMembersClient.In_groupSubscriptionMembers = membersToDelete;
      deleteMembersClient.Invoke();

      #endregion
    }


    [TestMethod]
    [TestCategory("ApplyGroupSubscriptionDeleteMembers")]
    public void ApplyGroupSubscriptionDeleteMembers()
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
      //Make sure approvals is not enabled so we can apply immediately
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["GroupSubscription.AddMembers"].Enabled = false; //By setting to false, the change will be applied directly
      approvalsConfig["GroupSubscription.DeleteMembers"].Enabled = false; //By setting to false, the change will be applied directly

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

      //Now delete the member

      List<GroupSubscriptionMember> membersToDelete = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToDelete = null;

      gsubMemberToDelete = new GroupSubscriptionMember();
      gsubMemberToDelete.AccountId = newSubscriber._AccountID.Value;
      //Not sure if begin/end date needs to be set

      membersToDelete.Add(gsubMemberToDelete);

      //Serialize the details
      ChangeDetailsHelper changeDetailsForDelete = new ChangeDetailsHelper();
      changeDetailsForDelete["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetailsForDelete["groupSubscriptionMembers"] = membersToDelete;

      //Create/Populate the change to be submitted for approval
      //Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.DeleteMembers";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetailsForDelete.ToXml();

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Deleting members from group subscription: Unit Test " + testName + " on " + DateTime.Now;

      //int myChangeId;
      approvalsFramework.SubmitChange(myNewChange, out myChangeId);

      #endregion



    }


    [TestMethod]
    [TestCategory("GroupSubscriptionMembers")]
    [TestCategory("SubmitApproveGroupSubscriptionDeleteMembers")]
    public void SubmitApproveGroupSubscriptionDeleteMembers()
    {
      #region Prepare

      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSDel_App";
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
      //Make sure approvals is not enabled so we can apply immediately
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["GroupSubscription.AddMembers"].Enabled = false; //By setting to false, the change will be applied directly

      ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalsFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

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

      //Prepare the change

      List<GroupSubscriptionMember> membersToDelete = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMemberToDelete = null;

      gsubMemberToDelete = new GroupSubscriptionMember();
      gsubMemberToDelete.AccountId = newSubscriber._AccountID.Value;
      //Not sure if begin/end date needs to be set

      membersToDelete.Add(gsubMemberToDelete);

      //Serialize the details
      ChangeDetailsHelper changeDetailsForDelete = new ChangeDetailsHelper();
      changeDetailsForDelete["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetailsForDelete["groupSubscriptionMembers"] = membersToDelete;

      //Create/Populate the change to be submitted for approval
      //Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.DeleteMembers";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetailsForDelete.ToXml();

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Deleting members from group subscription: Unit Test " + testName + " on " + DateTime.Now;

      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitApproveScenario("SubmitApproveGroupSubscriptionDeleteMembers",
        myNewChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        SharedTestCodeApprovals.LoginAsUserWhoCanApproveGroupSubscriptionMembershipUpdate(),
        VerifyMembersExistInGroupSubscription,
        VerifyMembersDoNotExistInGroupSubscription,
        groupSubscription.GroupId.Value);
    }
    
    #endregion

    #region Internal
    public static bool VerifyMembersExistInGroupSubscription(Change change, object myUserDefinedObject)
    {
      int idGroupSubscription = (int) myUserDefinedObject;
      MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
      changeDetails.FromBuffer(change.ChangeDetailsBlob);

      List<GroupSubscriptionMember> membersToDelete = (List<GroupSubscriptionMember>)changeDetails["groupSubscriptionMembers"];

      bool allMembersFound = true;
      string membersNotFound = "";
      foreach (GroupSubscriptionMember gsmThatShouldExist in membersToDelete)
      {
        if (null == groupSubscriptionMembers.Items.Find(
            delegate(GroupSubscriptionMember gsm)
            {
              return gsm.AccountId == gsmThatShouldExist.AccountId;
            }
            ))
        {
          allMembersFound = false;
          membersNotFound += gsmThatShouldExist.AccountId + ";";
        }
      }

      Assert.IsTrue(allMembersFound, "The following members do not exist in the group subscription: " + membersNotFound);

      return allMembersFound;
    }

    public static bool VerifyMembersDoNotExistInGroupSubscription(Change change, object myUserDefinedObject)
    {
      int idGroupSubscription = (int)myUserDefinedObject;
      MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
      changeDetails.FromBuffer(change.ChangeDetailsBlob);

      List<GroupSubscriptionMember> membersToDelete = (List<GroupSubscriptionMember>)changeDetails["groupSubscriptionMembers"];

      bool allMembersNotFound = true;
      string membersFound = "";
      foreach (GroupSubscriptionMember gsmThatShouldNotExist in membersToDelete)
      {
        if (null != groupSubscriptionMembers.Items.Find(
            delegate(GroupSubscriptionMember gsm)
            {
              return gsm.AccountId == gsmThatShouldNotExist.AccountId;
            }
            ))
        {
          allMembersNotFound = false;
          membersFound += gsmThatShouldNotExist.AccountId + ";";
        }
      }

      Assert.IsTrue(allMembersNotFound, "The following members exist in the group subscription: " + membersFound);

      return allMembersNotFound;
    }
    #endregion




  }
}
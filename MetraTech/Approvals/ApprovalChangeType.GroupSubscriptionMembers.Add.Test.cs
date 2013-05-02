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
  public class GroupSubscriptionMemberAddTest
  {

    private Logger mLogger = new Logger("[ApprovalManagementTest.RateUpdate]");

    [ClassInitialize]
	public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
    }

    #region Tests

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeGroupSubscriptionAddArguments")]
    public void VerifyWeCanSerializeGroupSubscriptionAddArguments()
    {
      
      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = new GroupSubscriptionMember();
      gsubMember.AccountId = 1;
      gsubMember.MembershipSpan = new ProdCatTimeSpan();
      gsubMember.MembershipSpan.StartDate = MetraTime.Now;
      newMembers.Add(gsubMember);

      ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
      changeDetailsIn["groupSubscriptionId"] = 111;
      changeDetailsIn["groupSubscriptionMembers"] = newMembers;

      string buffer = changeDetailsIn.ToXml();

      ChangeDetailsHelper changeDetailsOut = new ChangeDetailsHelper();
      changeDetailsOut.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
      changeDetailsOut.KnownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
      changeDetailsOut.FromXml(buffer);

      object o = changeDetailsOut["groupSubscriptionMembers"];
      List<GroupSubscriptionMember> membersOut = (List<GroupSubscriptionMember>)o;

      Assert.AreEqual(1, membersOut.Count, "Could not retrieve the serialized members");
      Assert.AreEqual(gsubMember.AccountId, membersOut[0].AccountId);
      Assert.AreEqual(gsubMember.MembershipSpan.StartDate, membersOut[0].MembershipSpan.StartDate);
    }

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeGroupSubscriptionAddHierarchyArguments")]
    public void VerifyWeCanSerializeGroupSubscriptionAddHierarchyArguments()
    {
      
      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      Dictionary<AccountIdentifier, AccountTemplateScope> accountsIn = new Dictionary<AccountIdentifier, AccountTemplateScope>();
      AccountIdentifier accountIdentifier = new AccountIdentifier(222);
      accountsIn.Add(accountIdentifier, AccountTemplateScope.CURRENT_FOLDER);

      ProdCatTimeSpan subscriptionTimespan = new ProdCatTimeSpan();
      subscriptionTimespan.StartDate = MetraTime.Now;
      subscriptionTimespan.EndDate = subscriptionTimespan.StartDate.Value.AddMonths(1);

      ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
      changeDetailsIn["groupSubscriptionId"] = 111;
      changeDetailsIn["accounts"] = accountsIn;
      changeDetailsIn["subscriptionSpan"] = subscriptionTimespan;

      string buffer = changeDetailsIn.ToXml();

      ChangeDetailsHelper changeDetailsOut = new ChangeDetailsHelper();
      //changeDetailsOut.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
      changeDetailsOut.KnownTypes.Add(typeof(Dictionary<AccountIdentifier, AccountTemplateScope>));
      changeDetailsOut.KnownTypes.Add(typeof(AccountIdentifier));
      changeDetailsOut.KnownTypes.Add(typeof(AccountTemplateScope));
      changeDetailsOut.KnownTypes.Add(typeof(ProdCatTimeSpan));
      changeDetailsOut.FromXml(buffer);

      object o = changeDetailsOut["accounts"];
      Dictionary<AccountIdentifier, AccountTemplateScope> accountsOut = (Dictionary<AccountIdentifier, AccountTemplateScope>)o;
      ProdCatTimeSpan subscriptionTimespanOut = (ProdCatTimeSpan)changeDetailsOut["subscriptionSpan"];

      Assert.AreEqual(1, accountsOut.Count, "Could not retrieve the serialized members");
      //Assert.AreEqual(AccountTemplateScope.CURRENT_FOLDER, accountsIn[accountIdentifier]);
      //Assert.AreEqual(AccountTemplateScope.CURRENT_FOLDER, accountsOut[accountIdentifier]);
      Assert.AreEqual(subscriptionTimespan.StartDate, subscriptionTimespanOut.StartDate);
      Assert.AreEqual(subscriptionTimespan.EndDate, subscriptionTimespanOut.EndDate);
    }

    [TestMethod]
    [TestCategory("VerifyWeCanAddGroupSubscriptionMembersIndependentOfApprovals")]
    public void VerifyWeCanAddGroupSubscriptionMembersIndependentOfApprovals()
    {
      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSAdd_NoA";
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

      // Retrieve the members and check that they contain our new member
      //MTList<GroupSubscriptionMember> outMembers = new MTList<GroupSubscriptionMember>();


      //GroupSubscriptionService_GetMembersForGroupSubscription2_Client getMembersClient =
      //  new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      //getMembersClient.UserName = userName;
      //getMembersClient.Password = password;
      //getMembersClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      //getMembersClient.InOut_groupSubscriptionMembers = outMembers;
      //getMembersClient.Invoke();


      //foreach (GroupSubscriptionMember newMember in newMembers)
      //{
      //  bool found = false;
      //  foreach (GroupSubscriptionMember dbGsubMember in getMembersClient.InOut_groupSubscriptionMembers.Items)
      //  {
      //    if (dbGsubMember.AccountId.Value == newMember.AccountId.Value)
      //    {
      //      found = true;
      //      break;
      //    }
      //  }

      //  Assert.IsTrue(found, "Unable to find new member");
      //}

      #endregion
    }

    //[TestMethod]
    //[TestCategory("VerifyWeCanAddGroupSubscriptionMemberHierarchyIndependentOfApprovals")]
    public void VerifyWeCanAddGroupSubscriptionMemberHierarchyIndependentOfApprovals()
    {

      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSAddH_NoA";
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

      ////Now add this account to the group subscription and save
      //List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      //GroupSubscriptionMember gsubMember = null;

      //gsubMember = new GroupSubscriptionMember();
      //gsubMember.AccountId = newSubscriber._AccountID.Value;
      //gsubMember.MembershipSpan = new ProdCatTimeSpan();
      //gsubMember.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      //newMembers.Add(gsubMember);

      ////Initialize the client and call AddMembers
      //GroupSubscriptionService_AddMembersToGroupSubscription_Client addMembersClient = new GroupSubscriptionService_AddMembersToGroupSubscription_Client();

      //addMembersClient.UserName = testUserName;
      //addMembersClient.Password = testPassword;
      //addMembersClient.In_groupSubscriptionId = groupSubscription.GroupId.Value;
      //addMembersClient.In_groupSubscriptionMembers = newMembers;
      //addMembersClient.Invoke();

      
      //Create the necessary arguments
      Dictionary<AccountIdentifier, AccountTemplateScope> dictionaryAccounts = new Dictionary<AccountIdentifier, AccountTemplateScope>();
      AccountIdentifier accountIdentifier = new AccountIdentifier(newSubscriber._AccountID.Value);
      dictionaryAccounts.Add(accountIdentifier, AccountTemplateScope.CURRENT_FOLDER);

      ProdCatTimeSpan subscriptionTimespan = new ProdCatTimeSpan();
      subscriptionTimespan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      subscriptionTimespan.EndDate = groupSubscription.SubscriptionSpan.EndDate;


      //Initialize the client and call AddMemberHierarchiesToGroupSubscription
      GroupSubscriptionService_AddMemberHierarchiesToGroupSubscription_Client addMemberHierarchiesToGroupSubscriptionClient = new GroupSubscriptionService_AddMemberHierarchiesToGroupSubscription_Client();

      addMemberHierarchiesToGroupSubscriptionClient.UserName = testUserName;
      addMemberHierarchiesToGroupSubscriptionClient.Password = testPassword;
      
      addMemberHierarchiesToGroupSubscriptionClient.In_accounts = dictionaryAccounts;
      addMemberHierarchiesToGroupSubscriptionClient.In_groupSubscriptionId = groupSubscription.GroupId.Value;
      addMemberHierarchiesToGroupSubscriptionClient.In_subscriptionSpan = subscriptionTimespan;
      
      addMemberHierarchiesToGroupSubscriptionClient.Invoke();


      // Retrieve the members and check that they contain our new member
      //MTList<GroupSubscriptionMember> outMembers = new MTList<GroupSubscriptionMember>();


      //GroupSubscriptionService_GetMembersForGroupSubscription2_Client getMembersClient =
      //  new GroupSubscriptionService_GetMembersForGroupSubscription2_Client();
      //getMembersClient.UserName = userName;
      //getMembersClient.Password = password;
      //getMembersClient.In_groupSubscriptionId = groupSub.GroupId.Value;
      //getMembersClient.InOut_groupSubscriptionMembers = outMembers;
      //getMembersClient.Invoke();


      //foreach (GroupSubscriptionMember newMember in newMembers)
      //{
      //  bool found = false;
      //  foreach (GroupSubscriptionMember dbGsubMember in getMembersClient.InOut_groupSubscriptionMembers.Items)
      //  {
      //    if (dbGsubMember.AccountId.Value == newMember.AccountId.Value)
      //    {
      //      found = true;
      //      break;
      //    }
      //  }

      //  Assert.IsTrue(found, "Unable to find new member");
      //}

      #endregion

 
    }


    [TestMethod]
    [TestCategory("ApplyGroupSubscriptionAddMemberHierarchy")]
    public void ApplyGroupSubscriptionAddMemberHierarchy()
    {

      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSAddHApply";
      string testRun = MetraTime.Now.ToString();
      string testUserName = "su";
      string testPassword = "su123";

      IMTProductOffering productOffering = ProductOfferingFactory.Create(testName, testRun);

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


      //Create the necessary arguments
      Dictionary<AccountIdentifier, AccountTemplateScope> dictionaryAccounts = new Dictionary<AccountIdentifier, AccountTemplateScope>();
      AccountIdentifier accountIdentifier = new AccountIdentifier(newSubscriber._AccountID.Value);
      dictionaryAccounts.Add(accountIdentifier, AccountTemplateScope.CURRENT_FOLDER);

      ProdCatTimeSpan subscriptionTimespan = new ProdCatTimeSpan();
      subscriptionTimespan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      subscriptionTimespan.EndDate = groupSubscription.SubscriptionSpan.EndDate;

      //Serialize the details
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetails["accounts"] = dictionaryAccounts;
      changeDetails["subscriptionSpan"] = subscriptionTimespan;

      string buffer = changeDetails.ToXml();

      //Create and submit this change
      //Make sure approvals are not enabled for RateUpdate so we can apply immediately
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["GroupSubscription.AddMemberHierarchies"].Enabled = false; //By setting to false, the change will be applied directly

      ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalsFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.AddMemberHierarchies";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = buffer;

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Adding member hierarchy to group subscription: Unit Test " + testName + " on " + DateTime.Now;

      int myChangeId;
      approvalsFramework.SubmitChange(myNewChange, out myChangeId);

      mLogger.LogInfo("Successfully added account {0}({1}) to group subscription for corporate account{2}({3})", newSubscriber.UserName, newSubscriber._AccountID, corpAccountHolder.Item.UserName, corpAccountHolder.Item._AccountID);
  

      #endregion


    }

    [TestMethod]
    [TestCategory("ApplyGroupSubscriptionAddMembers")]
    public void ApplyGroupSubscriptionAddMembers()
    {

      #region Prepare
      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSAdd_Apply";
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

      //Now prepare the change: add this account to the group subscription and save
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
    
      #endregion



    }

    [TestMethod]
    [TestCategory("GroupSubscriptionMembers")]
    [TestCategory("SubmitApproveGroupSubscriptionAddMemberHierarchyScenario")]
    public void SubmitApproveGroupSubscriptionAddMemberHierarchyScenario()
    {
      #region Prepare

      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSAddH_App";
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


      //Prepare the change
      
      //Create the necessary arguments
      Dictionary<AccountIdentifier, AccountTemplateScope> dictionaryAccounts = new Dictionary<AccountIdentifier, AccountTemplateScope>();
      AccountIdentifier accountIdentifier = new AccountIdentifier(newSubscriber._AccountID.Value);
      dictionaryAccounts.Add(accountIdentifier, AccountTemplateScope.CURRENT_FOLDER);

      ProdCatTimeSpan subscriptionTimespan = new ProdCatTimeSpan();
      subscriptionTimespan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      subscriptionTimespan.EndDate = groupSubscription.SubscriptionSpan.EndDate;

      //Serialize the details
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetails["accounts"] = dictionaryAccounts;
      changeDetails["subscriptionSpan"] = subscriptionTimespan;

      string buffer = changeDetails.ToXml();


      //Create/Populate the change to be submitted for approval
      Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.AddMemberHierarchies";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = buffer;

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Adding member hierarchy to group subscription: Unit Test " + testName + " on " + DateTime.Now;
      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitApproveScenario("SubmitApproveGroupSubscriptionAddMemberHierarchyScenario",
        myNewChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        SharedTestCodeApprovals.LoginAsUserWhoCanApproveGroupSubscriptionMembershipUpdate(),
        VerifyMemberHierarchiesHaveNotBeenAdded,
        VerifyMemberHierarchiesHaveBeenAdded,
        groupSubscription.GroupId.Value);
    }

    [TestMethod]
    public void SubmitApproveGroupSubscriptionAddMemberScenario()
    {
      #region Prepare

      //Setup a product offering, a group subscription and accounts
      string testName = "A_GSAdd_App";
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


      //Prepare the change

      //Create the necessary arguments
      List<GroupSubscriptionMember> newMembers = new List<GroupSubscriptionMember>();
      GroupSubscriptionMember gsubMember = null;

      gsubMember = new GroupSubscriptionMember();
      gsubMember.AccountId = newSubscriber._AccountID.Value;
      gsubMember.MembershipSpan = new ProdCatTimeSpan();
      gsubMember.MembershipSpan.StartDate = groupSubscription.SubscriptionSpan.StartDate;
      newMembers.Add(gsubMember);

      //Serialize the change details
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["groupSubscriptionId"] = groupSubscription.GroupId.Value;
      changeDetails["groupSubscriptionMembers"] = newMembers;


      //Create/Populate the change to be submitted for approval
      Change myNewChange = new Change();
      myNewChange.ChangeType = "GroupSubscription.AddMembers";

      myNewChange.UniqueItemId = groupSubscription.GroupId.Value.ToString();
      myNewChange.ChangeDetailsBlob = changeDetails.ToXml();;

      myNewChange.ItemDisplayName = groupSubscription.Name;
      myNewChange.Comment = "Adding member to group subscription: Unit Test " + testName + " on " + DateTime.Now;
      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitApproveScenario("SubmitApproveGroupSubscriptionAddMembersScenario",
        myNewChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        SharedTestCodeApprovals.LoginAsUserWhoCanApproveGroupSubscriptionMembershipUpdate(),
        GroupSubscriptionMemberDeleteTest.VerifyMembersDoNotExistInGroupSubscription,
        GroupSubscriptionMemberDeleteTest.VerifyMembersExistInGroupSubscription,
        groupSubscription.GroupId.Value);
    }

    #endregion

    #region Internal
    public bool VerifyMemberHierarchiesHaveBeenAdded(Change change, object myUserDefinedObject)
    {
      int idGroupSubscription = (int)myUserDefinedObject;
      MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails.KnownTypes.Add(typeof(Dictionary<AccountIdentifier, AccountTemplateScope>));
      changeDetails.KnownTypes.Add(typeof(ProdCatTimeSpan));
      changeDetails.FromBuffer(change.ChangeDetailsBlob);

      Dictionary<AccountIdentifier, AccountTemplateScope> accountsToBeAdded = (Dictionary<AccountIdentifier, AccountTemplateScope>)changeDetails["accounts"];

      bool allMembersFound = true;
      string membersNotFound = "";
      foreach (AccountIdentifier accountThatShouldExist in accountsToBeAdded.Keys)
      {
        if (null == groupSubscriptionMembers.Items.Find(
            delegate(GroupSubscriptionMember gsm)
            {
              return gsm.AccountId == accountThatShouldExist.AccountID;
            }
            ))
        {
          allMembersFound = false;
          membersNotFound += accountThatShouldExist.AccountID + ";";
        }
      }

	  Assert.IsTrue(allMembersFound, "The following members do not exist in the group subscription: " + membersNotFound);

      return allMembersFound;
    }

    public bool VerifyMemberHierarchiesHaveNotBeenAdded(Change change, object myUserDefinedObject)
    {
      int idGroupSubscription = (int)myUserDefinedObject;
      MTList<GroupSubscriptionMember> groupSubscriptionMembers = SharedTestCode.GetMembersOfGroupSubscription(idGroupSubscription);

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails.KnownTypes.Add(typeof(Dictionary<AccountIdentifier, AccountTemplateScope>));
      changeDetails.KnownTypes.Add(typeof(ProdCatTimeSpan));
      changeDetails.FromBuffer(change.ChangeDetailsBlob);

      Dictionary<AccountIdentifier, AccountTemplateScope> accountsToBeAdded = (Dictionary<AccountIdentifier, AccountTemplateScope>)changeDetails["accounts"];

      bool allMembersNotFound = true;
      string membersFound = "";
      foreach (AccountIdentifier accountThatShouldNotExist in accountsToBeAdded.Keys)
      {
        if (null != groupSubscriptionMembers.Items.Find(
            delegate(GroupSubscriptionMember gsm)
            {
              return gsm.AccountId == accountThatShouldNotExist.AccountID;
            }
            ))
        {
          allMembersNotFound = false;
          membersFound += accountThatShouldNotExist.AccountID + ";";
        }
      }

	  Assert.IsTrue(allMembersNotFound, "The following members exist in the group subscription: " + membersFound);

      return allMembersNotFound;
    }
 
    #endregion

  }
}
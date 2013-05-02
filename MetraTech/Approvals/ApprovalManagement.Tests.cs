using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;

//using MetraTech.DomainModel.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
using MetraTech.DomainModel.BaseTypes;
using System.Collections.Generic;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.ApprovalManagementTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//
namespace MetraTech.Approvals.Test
{
  [TestClass]
  public class ApprovalManagementTest
  {

    private Logger m_Logger = new Logger("[ApprovalManagementTest]");

    private static int idOFChangeWithLongHistory = 0;

    #region tests

    [TestMethod]
    [TestCategory("GetChanges")]
    public void GetChanges()
    {
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanViewApprovals();

      MTList<ChangeSummary> changes = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref changes);

      //Assert.Greater(changes.Items.Count, 0, "Expected at least some changes in the system");

      MTList<ChangeSummary> pendingChanges = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChanges);

      //Assert.Greater(pendingChanges.Items.Count, 0, "Expected at least some pending changes in the system");
      foreach(ChangeSummary change in pendingChanges.Items)
      {
        Assert.AreEqual(ChangeState.Pending, change.CurrentState, "GetPendingChangesSummary should return only pending changes");
    }
    }

    [TestMethod]
    [TestCategory("SimpleSubmitChange")]
    public void SimpleSubmitChange()
    {
      string unitTestName = "SimpleSubmitChange";

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "1";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1000;
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item 1";
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

    }

    [TestMethod]
    [TestCategory("SimpleFilteringTest")]
    public void SimpleFilteringTest()
    {
      string unitTestName = "SimpleFilteringTest";

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      //Test run unique id
      string testRunUniqueName = unitTestName + " " + MetraTime.Now;
      //Add 100 changes
      int numberOfChangesToAdd = 100;
      int firstChangeId = -1;
      for (int i = 1; i <= numberOfChangesToAdd; i++)
      {
        Change myNewChange = new Change();
        myNewChange.ChangeType = "SampleUpdate";
        myNewChange.UniqueItemId = testRunUniqueName + " " + i.ToString();

        ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
        changeDetails["UpdatedValue"] = 1000;
        myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

        myNewChange.ItemDisplayName = "Filter Test Item " + i;
        myNewChange.Comment = "Submitted by Unit Test " + testRunUniqueName;

        int myChangeId;
        approvalFramework.SubmitChange(myNewChange, out myChangeId);
        
        if (i == 1)
          firstChangeId = myChangeId;
      }

      int userIdOfSubmitter = approvalFramework.SessionContext.AccountID; //Save submitter id for checking filter later

      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanViewApprovals();

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - numberOfChangesToAdd, "Expected pending changes count to be " + numberOfChangesToAdd + " more than before we submitted");

      //Filter for single item
      MTList<ChangeSummary> singleItem = new MTList<ChangeSummary>();
      singleItem.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Equal, firstChangeId) );
      approvalFramework.GetChangesSummary(ref singleItem);

      Assert.AreEqual(singleItem.Items.Count, 1, "Expected filtering to return single item");

      //Filter for all 100 items
      MTList<ChangeSummary> ourItems = new MTList<ChangeSummary>();
      ourItems.Filters.Add(new MTFilterElement("UniqueItemId", MTFilterElement.OperationType.Like, testRunUniqueName + "%"));
      approvalFramework.GetChangesSummary(ref ourItems);

      Assert.AreEqual(ourItems.Items.Count, numberOfChangesToAdd, "Expected filtering to return all but just our items");

      //Create filter for all columns just to test every column if valid even if results are the same
      MTList<ChangeSummary> ourItemsWithAllFilters = new MTList<ChangeSummary>();
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("UniqueItemId", MTFilterElement.OperationType.Like, testRunUniqueName + "%"));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "SampleUpdate"));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.GreaterEqual, firstChangeId));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Less, firstChangeId+numberOfChangesToAdd));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("SubmittedDate", MTFilterElement.OperationType.LessEqual, MetraTime.Now.AddHours(1.0)));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("SubmitterId", MTFilterElement.OperationType.Equal, userIdOfSubmitter));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("ItemDisplayName", MTFilterElement.OperationType.Like, "Filter Test%"));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("ApproverId", MTFilterElement.OperationType.IsNull, null));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("ChangeLastModifiedDate", MTFilterElement.OperationType.IsNull, null));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Comment", MTFilterElement.OperationType.Like, "%" + testRunUniqueName + "%"));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("CurrentState", MTFilterElement.OperationType.Equal, ChangeState.Pending.ToString()));


      approvalFramework.GetChangesSummary(ref ourItemsWithAllFilters);

      Assert.AreEqual(numberOfChangesToAdd, ourItemsWithAllFilters.Items.Count, "Expected filtering to return " + numberOfChangesToAdd + " items.");


      //Negative filtering test for when we pass bad filter column

    }

    [TestMethod]
    [TestCategory("SubmitUpdateApproveChangeScenario")]
    public void SubmitUpdateApproveChangeScenario()
    {
      string unitTestName = "SubmitUpdateApproveChangeScenario";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "1";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1000;
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item 1";
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrieved);

      Assert.AreEqual(changeDetailsRetrieved, myNewChange.ChangeDetailsBlob, "The submitted change details are different from the change details retrieved from the framework");

      changeDetails["UpdatedValue"] = 1100;
      string changeDetailsToBeUpdated = changeDetails.ToBuffer();
      approvalFramework.UpdateChangeDetail(myChangeId, changeDetailsToBeUpdated, "Details updated by unit test on " + MetraTime.Now);

      string changeDetailsRetrievedAfterUpdate;
      approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrievedAfterUpdate);

      Assert.AreEqual(changeDetailsToBeUpdated, changeDetailsRetrievedAfterUpdate, "The updated changed details do not match the details retrieved from the framework after update");

      //Negative Test Case: Approve the change as the submitter of the change (will throw an exception)
      try
      {
        approvalFramework.ApproveChange(myChangeId, "This should fail");
        Assert.Fail("ApproveChange succeeded even though submitter tried to approve the change");
      }
      catch (Exception ex)
      {
        //Make sure exception is that we don't have permission to approve this change
        Assert.IsTrue(ex.Message.Contains("Approver cannot be the submitter of the change"));
      }

      //Save the Last Modified Date so we can verify it was updated after approval
      DateTime lastModifiedPriorToApproval = SharedTestCodeApprovals.GetChangeByIdFromDatabase(myChangeId, approvalFramework).ChangeLastModifiedDate;

      //Login in as admin user and approve the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      int pendingChangeCountBefore = SharedTestCodeApprovals.GetCountOfChangesWithStateOf(ChangeState.Pending);
      int appliedChangeCountBefore = SharedTestCodeApprovals.GetCountOfChangesWithStateOf(ChangeState.Applied);

      approvalFramework.ApproveChange(myChangeId, "Approved by approval framework unit test");

      int pendingChangeCountAfter = SharedTestCodeApprovals.GetCountOfChangesWithStateOf(ChangeState.Pending);
      int appliedChangeCountAfter = SharedTestCodeApprovals.GetCountOfChangesWithStateOf(ChangeState.Applied);

      Assert.AreEqual(pendingChangeCountAfter, pendingChangeCountBefore - 1, "Previous state count should be one less");
      Assert.AreEqual(appliedChangeCountAfter, appliedChangeCountBefore + 1, "New state count should be one more");

      MTList<ChangeSummary> pendingChangesAfterApproval = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterApproval);

      MTList<ChangeSummary> changesAfterApproval = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref changesAfterApproval);

      ChangeSummary appliedChange = SharedTestCodeApprovals.FindChangeInListOfChanges(changesAfterApproval, myChangeId);

      Assert.IsNotNull(appliedChange, "Couldn't find our change with id " + myChangeId);
      Assert.AreEqual(ChangeState.Applied, appliedChange.CurrentState, string.Format("Found the approved change with id {0} but the state was '{1}' and not 'Applied'", myChangeId, appliedChange.CurrentState));

      Assert.IsTrue(appliedChange.ChangeLastModifiedDate > lastModifiedPriorToApproval, "The last modified time on the approved change is not larger than the previous last modified time");

    }

    [TestMethod]
    [TestCategory("SubmitDenyChangeScenario")]
    public void SubmitDenyChangeScenario()
    {
      string unitTestName = "SubmitDenyChangeScenario";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "1";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1000;
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item 1";
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrieved);

      Assert.AreEqual(changeDetailsRetrieved, myNewChange.ChangeDetailsBlob, "The submitted change details are different from the change details retrieved from the framework");

      //Login in as admin user and deny the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      approvalFramework.DenyChange(myChangeId, "Denied by " + unitTestName);

      MTList<ChangeSummary> pendingChangesAfterDenial = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterDenial);

      MTList<ChangeSummary> changesAfterDenial = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref changesAfterDenial);

      //Find our change and make sure state is denied
      ChangeSummary change = null;
      bool foundIt = false;
      for (int i = 0; i < changesAfterDenial.Items.Count; i++)
      {
        change = changesAfterDenial.Items[i];
        if (change.Id == myChangeId)
        {
          foundIt = true;
          break;
        }
      }

      Assert.IsTrue(foundIt, "Couldn't find our denied change with id " + myChangeId);
      Assert.AreEqual(change.CurrentState, ChangeState.Dismissed, string.Format("Found the approved change with id {0} but the state was '{1}' and not 'Denied'", myChangeId, change.CurrentState));

    }

    [TestMethod]
    [TestCategory("SubmitDismissChangeScenario")]
    public void SubmitDismissChangeScenario()
    {
      string unitTestName = "SubmitDismissChangeScenario";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "1";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1000;
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item 1";
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrieved);

      Assert.AreEqual(changeDetailsRetrieved, myNewChange.ChangeDetailsBlob, "The submitted change details are different from the change details retrieved from the framework");

      approvalFramework.DismissChange(myChangeId, "Dismissed/Canceled by " + unitTestName);

      MTList<ChangeSummary> pendingChangesAfterDenial = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterDenial);

      MTList<ChangeSummary> changesAfterDenial = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref changesAfterDenial);

      //Find our change and make sure state is denied
      ChangeSummary change = null;
      bool foundIt = false;
      for (int i = 0; i < changesAfterDenial.Items.Count; i++)
      {
        change = changesAfterDenial.Items[i];
        if (change.Id == myChangeId)
        {
          foundIt = true;
          break;
        }
      }

      Assert.IsTrue(foundIt, "Couldn't find our dismissed change with id " + myChangeId);
      Assert.AreEqual(change.CurrentState, ChangeState.Dismissed, string.Format("Found the approved change with id {0} but the state was '{1}' and not 'Denied'", myChangeId, change.CurrentState));

    }

    [TestMethod]
    [TestCategory("CustomSubmitHandlerBypassesApprovals")]
    public void CustomSubmitHandlerBypassesApprovals()
    {
      string unitTestName = "CustomSubmitHandlerBypassesApprovals";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "2";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();

      changeDetails["UpdatedValue"] = 10; //This value doesn't need approval as per the custom handler

      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item " + myNewChange.UniqueItemId;
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count, "Expected change would not require approvals but number of pending changes has increased");

      
      changeDetails["UpdatedValue"] = 1100; //This value needs approval as per the custom handler
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      int mySecondChangeId;
      approvalFramework.SubmitChange(myNewChange, out mySecondChangeId);

      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);
      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");
    }

    [TestMethod]
    [TestCategory("ErrorDuringApplyReturnedByHistory")]
    public void ErrorDuringApplyReturnedByHistory()
    {
      string unitTestName = "ErrorDuringApplyReturnedByHistory";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "3";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1003.14M; //This value generates an error during the apply but not submit

      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item " + myNewChange.UniqueItemId;
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      //Approve should fail
      //Login in as admin user and approve the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      try
      {
        approvalFramework.ApproveChange(myChangeId, "Approved by approval framework unit test");
        Assert.Fail("Custom handler should have thrown error when change was applied after approval");
      }
      catch (Exception)
      {
      }
      
      //Get the history
      MTList<ChangeHistoryItem> changeHistory = new MTList<ChangeHistoryItem>();
      approvalFramework.GetChangeHistory(myChangeId, ref changeHistory);

      Assert.IsTrue( changeHistory.Items.Count>0, "Expected several items in the history");

    }

    [TestMethod]
    [TestCategory("ErrorDuringApplyIsResubmitted")]
    public void ErrorDuringApplyIsResubmitted()
    {
      string unitTestName = "ErrorDuringApplyIsResubmitted";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "3";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1003.14M; //This value generates an error during the apply but not submit

      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item " + myNewChange.UniqueItemId;
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      //Approve should fail
      //Login in as admin user and approve the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      try
      {
        approvalFramework.ApproveChange(myChangeId, "Approved by approval framework unit test");
        Assert.Fail("Custom handler should have thrown error when change was applied after approval");
      }
      catch (Exception ex)
      {
        Assert.AreEqual(ex.GetType(), typeof(MASBasicException));
      }

      ChangeSummary retrievedChange = SharedTestCodeApprovals.GetChangeByIdFromDatabase(myChangeId, approvalFramework);

      Assert.IsNotNull(retrievedChange,"Unable to find change with id " + myChangeId + " in the database");

      //Now, resubmit the change although it will just fail again
      MTList<int> changesToResubmit = new MTList<int>();
      changesToResubmit.Items.Add(myChangeId);
      try
      {
        approvalFramework.ResubmitFailedChanges(changesToResubmit);
        Assert.Fail("Resubmit failed changes shouldn't throw error for change in Failed  state.");
      }
      catch (Exception ex)
      {
        Assert.AreEqual(ex.GetType(), typeof(MASBasicException));
      }
      
      //Now edit the change details so we can approve it again and have it go through

      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(myChangeId, out changeDetailsRetrieved);

      changeDetails.FromBuffer(changeDetailsRetrieved);
      changeDetails["UpdatedValue"] = ((decimal) changeDetails["UpdatedValue"]) + 10.00M;

      //Login as orginal submitter so we can update
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      string changeDetailsToBeUpdated = changeDetails.ToBuffer();
      approvalFramework.UpdateChangeDetail(myChangeId, changeDetailsToBeUpdated, "Fixing failed value. Details updated by " + unitTestName + " on " + MetraTime.Now);

      ChangeSummary changeAfterUpdate = SharedTestCodeApprovals.GetChangeByIdFromDatabase(myChangeId, approvalFramework);
      Assert.AreEqual(ChangeState.Pending, changeAfterUpdate.CurrentState, "State of change should be 'Pending ' after details updated.");

      //Approve should now succeed
      //Login in as admin user and approve the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      try
      {
        approvalFramework.ApproveChange(myChangeId, "Approved by " + unitTestName);
      }
      catch (Exception ex)
      {
        Assert.Fail("Unable to approve/apply:" + ex.Message);
      }

      //Get the history, make sure we have everything
      MTList<ChangeHistoryItem> changeHistory = new MTList<ChangeHistoryItem>();
      approvalFramework.GetChangeHistory(myChangeId, ref changeHistory);

      Assert.IsTrue(changeHistory.Items.Count == 0, "Expected several items in the history");
      idOFChangeWithLongHistory = myChangeId;
    }

    [TestMethod]
    [TestCategory("GetChangeHistoryLocalization")]
    public void GetChangeHistoryLocalization()
    {
      //string unitTestName = "GetChangeHistoryLocalization";

      //Bit of a testing kludge but don't want to repeat the above test code here but also want change with a long history
      //If the test above has already run, then just use the id of that change, otherwise run it to
      //get an id of a change with a long history
      if (idOFChangeWithLongHistory == 0)
        ErrorDuringApplyIsResubmitted();

      int myChangeId = idOFChangeWithLongHistory;

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanViewApprovals();

      //Get the history, make sure we have everything
      MTList<ChangeHistoryItem> changeHistoryDefault = new MTList<ChangeHistoryItem>();
      approvalFramework.GetChangeHistory(myChangeId, ref changeHistoryDefault);

      Assert.IsTrue(changeHistoryDefault.Items.Count> 0, "Expected several items in the history");

      //Get the history for language, make sure we have everything
      MTList<ChangeHistoryItem> changeHistoryUS = new MTList<ChangeHistoryItem>();
      string locale = "en-US";
      approvalFramework.GetChangeHistory(myChangeId, ref changeHistoryUS, locale);

      Assert.AreEqual(changeHistoryDefault.Items.Count, changeHistoryUS.Items.Count, "Expected same number of entries for localized history for Locale:" + locale);

      //Get the history for language, make sure we have everything
      MTList<ChangeHistoryItem> changeHistoryDE = new MTList<ChangeHistoryItem>();
      locale = "de-DE";
      approvalFramework.GetChangeHistory(myChangeId, ref changeHistoryDE, locale);

      Assert.AreEqual(changeHistoryDefault.Items.Count, changeHistoryDE.Items.Count, "Expected same number of entries for localized history for Locale:" + locale);

    }

    [TestMethod]
    [TestCategory("GetChangeHistoryFiltering")]
    public void GetChangeHistoryFiltering()
    {
      //string unitTestName = "GetChangeHistoryFiltering";

      //Bit of a testing kludge but don't want to repeat the above test code here but also want change with a long history
      //If the test above has already run, then just use the id of that change, otherwise run it to
      //get an id of a change with a long history
      if (idOFChangeWithLongHistory == 0)
        ErrorDuringApplyIsResubmitted();

      int myChangeId = idOFChangeWithLongHistory;  

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanViewApprovals();

      //Get the history, make sure we have everything
      MTList<ChangeHistoryItem> changeHistory = new MTList<ChangeHistoryItem>();
      approvalFramework.GetChangeHistory(myChangeId, ref changeHistory);

	  Assert.IsTrue(changeHistory.Items.Count> 0, "Expected several items in the history");


      ////Filter for single item
      MTList<ChangeHistoryItem> singleItem = new MTList<ChangeHistoryItem>();
      singleItem.Filters.Add(new MTFilterElement("Event", MTFilterElement.OperationType.Equal, 23601));
      approvalFramework.GetChangeHistory(myChangeId, ref singleItem);

      Assert.AreEqual(singleItem.Items.Count, 1, "Expected filtering to return single item");

      //Need to get who the submitter was (technically we should have preserved it in the test run but at the moment we 'know' who it was)
      IMTSessionContext submitterSessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      ////Create filter on every column/field
      MTList<ChangeHistoryItem> ourItemsWithAllFilters = new MTList<ChangeHistoryItem>();
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Greater, -1));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("User", MTFilterElement.OperationType.Equal, submitterSessionContext.AccountID));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("UserDisplayName", MTFilterElement.OperationType.Equal, "su"));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Event", MTFilterElement.OperationType.GreaterEqual, 23601));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("EventDisplayName", MTFilterElement.OperationType.Like, "%Change%"));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Date", MTFilterElement.OperationType.LessEqual, MetraTime.Now.AddHours(12.0)));
      ourItemsWithAllFilters.Filters.Add(new MTFilterElement("Details", MTFilterElement.OperationType.Like, "%" + "a" + "%"));

      approvalFramework.GetChangeHistory(myChangeId, ref ourItemsWithAllFilters);

      Assert.IsTrue(0< ourItemsWithAllFilters.Items.Count, "Expected filtering to return some items");


    }


    [TestMethod]
    [TestCategory("GetPendingChangeIdsForItem")]
    public void GetPendingChangeIdsForItem()
    {
      string unitTestName = "GetPendingChangeIdsForItem";

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = unitTestName + MetraTime.Now;

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1000;
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item Used For " + unitTestName;
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;

      //Submit the change twice
      approvalFramework.SubmitChange(myNewChange, out myChangeId);
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 2, "Expected pending changes count to be two more than before we submitted");

      System.Collections.Generic.List<int> changeIds;
      approvalFramework.GetPendingChangeIdsForItem(myNewChange.ChangeType, myNewChange.UniqueItemId, out changeIds);

      Assert.AreEqual(2, changeIds.Count);
    }
    #endregion

    [TestMethod]
    [TestCategory("GetPendingChangeNotificationsForUser")]
    public void GetPendingChangeNotificationsForUser()
    {
      //string unitTestName = "GetPendingChangeNotificationsForUser";
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      List<ChangeNotificationSummary> pendingChangeNotifications = new List<ChangeNotificationSummary>();

      approvalFramework.GetPendingChangeNotificationsForUser(840, out pendingChangeNotifications);

      
    }

  }
}

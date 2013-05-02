using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Approvals.Test
{
  class ApprovalTestScenarios
  {
    /// <summary>
    /// Standard Submit and Approve scenario
    /// </summary>
    /// <param name="unitTestName">Test name for logging and error messages</param>
    /// <param name="change">The change to be used in the scenario</param>
    /// <param name="userToSubmitChange">User who can submit this change</param>
    /// <param name="userToApproveChange">User who can approve this change</param>
    /// <param name="methodToVerifyChangeHasNotBeenApplied">Method to be used to determine the change has not been applied</param>
    /// <param name="methodToVerifyChangeHasBeenApplied">Method to be used to determine the change has been applied</param>
    /// <param name="userDefinedObjectForVerificationIfNeeded">null or object to be passed to the methods that do verification</param>
    public static void MoveChangeThroughSubmitApproveScenario(string unitTestName,
                                                      Change change,
                                                      MetraTech.Interop.MTAuth.IMTSessionContext userToSubmitChange,
                                                      MetraTech.Interop.MTAuth.IMTSessionContext userToApproveChange,
                                                      Func<Change, object, bool> methodToVerifyChangeHasNotBeenApplied,
                                                      Func<Change, object, bool> methodToVerifyChangeHasBeenApplied,
                                                      object userDefinedObjectForVerificationIfNeeded)
    {

      //Step 1: Turn approvals for this change type
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig[change.ChangeType].Enabled = true;

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalFramework.SessionContext = userToSubmitChange;

      //Step 2: Get list of pending changes before submit
      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      //Step 3: Submit the change
      int newChangeId;
      approvalFramework.SubmitChange(change, out newChangeId);

      //Step 4: Get list of pending changes after and verify
      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      //Step 5: Get change details and verify they are the same
      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(newChangeId, out changeDetailsRetrieved);

      Assert.AreEqual(changeDetailsRetrieved, change.ChangeDetailsBlob, "The submitted change details are different from the change details retrieved from the framework");

      //Step 6: Call passed method to verify change has not been applied
      if (!methodToVerifyChangeHasNotBeenApplied(change, userDefinedObjectForVerificationIfNeeded))
      {
        Assert.Fail(string.Format("{0} : Change has been applied when it should be pending", unitTestName));
      }

      ////Negative Test Case: Approve the change as the submitter of the change (will throw an exception)
      //try
      //{
      //  approvalFramework.ApproveChange(myChangeId, "This should fail");
      //  Assert.Fail("ApproveChange succeeded even though submitter tried to approve the change");
      //}
      //catch (Exception ex)
      //{
      //  //Make sure exception is that we don't have permission to approve this change
      //  Assert.IsTrue(ex.Message.Contains("Approver cannot be the submitter of the change"));
      //}

      //Save the Last Modified Date so we can verify it was updated after approval
      DateTime lastModifiedPriorToApproval = SharedTestCodeApprovals.GetChangeByIdFromDatabase(newChangeId, approvalFramework).ChangeLastModifiedDate;


      //Step 7: Approve the change
      approvalFramework.SessionContext = userToApproveChange;

      approvalFramework.ApproveChange(newChangeId, "Approved by approval framework unit test");

      //Step 8: Get list of pending and nonpending changes and verify
      MTList<ChangeSummary> pendingChangesAfterApproval = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterApproval);

      MTList<ChangeSummary> changesAfterApproval = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref changesAfterApproval);

      ChangeSummary appliedChange = SharedTestCodeApprovals.FindChangeInListOfChanges(changesAfterApproval, newChangeId);

      Assert.IsNotNull(appliedChange, "Couldn't find our change with id " + newChangeId);
      Assert.AreEqual(ChangeState.Applied, appliedChange.CurrentState, string.Format("Found the approved change with id {0} but the state was '{1}' and not 'Applied'", newChangeId, appliedChange.CurrentState));

      Assert.IsTrue(appliedChange.ChangeLastModifiedDate > lastModifiedPriorToApproval, "The last modified time on the approved change is not larger than the previous last modified time");

      //Step 9: Verify the change was applied with the provided method
      if (!methodToVerifyChangeHasBeenApplied(change, userDefinedObjectForVerificationIfNeeded))
      {
        Assert.Fail(string.Format("{0} : Change does not appear to have been applied", unitTestName));
      }

    }
  
      /// <summary>
    /// Standard Submit scenario
    /// </summary>
    /// <param name="unitTestName">Test name for logging and error messages</param>
    /// <param name="change">The change to be used in the scenario</param>
    /// <param name="userToSubmitChange">User who can submit this change</param>
    /// <param name="methodToVerifyChangeHasNotBeenApplied">Method to be used to determine the change has not been applied</param>
    /// <param name="userDefinedObjectForVerificationIfNeeded">null or object to be passed to the methods that do verification</param>
    public static void MoveChangeThroughSubmitScenario(string unitTestName,
                                                      Change change,
                                                      MetraTech.Interop.MTAuth.IMTSessionContext userToSubmitChange,
                                                      Func<Change, object, bool> methodToVerifyChangeHasNotBeenApplied,
                                                      object userDefinedObjectForVerificationIfNeeded)
    {

      //Step 1: Turn approvals for this change type
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig[change.ChangeType].Enabled = true;

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalFramework.SessionContext = userToSubmitChange;

      //Step 2: Get list of pending changes before submit
      MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);

      //Step 3: Submit the change
      int newChangeId;
      approvalFramework.SubmitChange(change, out newChangeId);

      //Step 4: Get list of pending changes after and verify
      MTList<ChangeSummary> pendingChangesAfter = new MTList<ChangeSummary>();
      approvalFramework.GetPendingChangesSummary(ref pendingChangesAfter);

      Assert.AreEqual(pendingChangesBefore.Items.Count, pendingChangesAfter.Items.Count - 1, "Expected pending changes count to be one more than before we submitted");

      //Step 5: Get change details and verify they are the same
      string changeDetailsRetrieved;
      approvalFramework.GetChangeDetails(newChangeId, out changeDetailsRetrieved);

      Assert.AreEqual(changeDetailsRetrieved, change.ChangeDetailsBlob, "The submitted change details are different from the change details retrieved from the framework");

      //Step 6: Call passed method to verify change has not been applied
      if (!methodToVerifyChangeHasNotBeenApplied(change, userDefinedObjectForVerificationIfNeeded))
      {
        Assert.Fail(string.Format("{0} : Change has been applied when it should be pending", unitTestName));
      }

      ////Negative Test Case: Approve the change as the submitter of the change (will throw an exception)
      //try
      //{
      //  approvalFramework.ApproveChange(myChangeId, "This should fail");
      //  Assert.Fail("ApproveChange succeeded even though submitter tried to approve the change");
      //}
      //catch (Exception ex)
      //{
      //  //Make sure exception is that we don't have permission to approve this change
      //  Assert.IsTrue(ex.Message.Contains("Approver cannot be the submitter of the change"));
      //}

      ////Save the Last Modified Date so we can verify it was updated after approval
      //DateTime lastModifiedPriorToApproval = SharedTestCodeApprovals.GetChangeByIdFromDatabase(newChangeId, approvalFramework).ChangeLastModifiedDate;


      ////Step 7: Approve the change
      //approvalFramework.SessionContext = userToApproveChange;

      //approvalFramework.ApproveChange(newChangeId, "Approved by approval framework unit test");

      ////Step 8: Get list of pending and nonpending changes and verify
      //MTList<ChangeSummary> pendingChangesAfterApproval = new MTList<ChangeSummary>();
      //approvalFramework.GetPendingChangesSummary(ref pendingChangesAfterApproval);

      //MTList<ChangeSummary> changesAfterApproval = new MTList<ChangeSummary>();
      //approvalFramework.GetChangesSummary(ref changesAfterApproval);

      //ChangeSummary appliedChange = SharedTestCodeApprovals.FindChangeInListOfChanges(changesAfterApproval, newChangeId);

      //Assert.IsNotNull(appliedChange, "Couldn't find our change with id " + newChangeId);
      //Assert.AreEqual(ChangeState.Applied, appliedChange.CurrentState, string.Format("Found the approved change with id {0} but the state was '{1}' and not 'Applied'", newChangeId, appliedChange.CurrentState));

      //Assert.IsTrue(appliedChange.ChangeLastModifiedDate > lastModifiedPriorToApproval, "The last modified time on the approved change is not larger than the previous last modified time");

      ////Step 9: Verify the change was applied with the provided method
      //if (!methodToVerifyChangeHasBeenApplied(change, userDefinedObjectForVerificationIfNeeded))
      //{
      //  Assert.Fail(string.Format("{0} : Change does not appear to have been applied", unitTestName));
      //}

    }
  }
}

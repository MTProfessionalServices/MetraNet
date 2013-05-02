using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Approvals.Test
{
  class SharedTestCodeApprovals
  {
    public static ChangeSummary GetChangeByIdFromDatabase(int changeId, ApprovalManagementImplementation approvalFramework)
    {

      //TODO: Eventually can use filter to retrieve just our particular id

      MTList<ChangeSummary> allChanges = new MTList<ChangeSummary>();
      approvalFramework.GetChangesSummary(ref allChanges);

      //Find our change
      foreach (ChangeSummary change in allChanges.Items)
      {
        if (change.Id == changeId)
        {
          return change;
        }
      }

      return null; //Didn't find it
    }

    public static ChangeSummary FindChangeInListOfChanges(MTList<ChangeSummary> listToSearch, int changeId)
    {
      //Find our change
      ChangeSummary change = null;
      for (int i = 0; i < listToSearch.Items.Count; i++)
      {
        change = listToSearch.Items[i];
        if (change.Id == changeId)
          return change;
      }

      return null;
    }

    /// <summary>
    /// Helper function to count number of changes with a given state
    /// </summary>
    /// <param name="state"></param>
    public static int GetCountOfChangesWithStateOf(ChangeState state)
    {
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCode.LoginAsSU();

      MTList<ChangeSummary> changesWithParticularStatus = new MTList<ChangeSummary>();
      changesWithParticularStatus.Filters.Add(new MTFilterElement("CurrentState", MTFilterElement.OperationType.Equal, state.ToString()));
      approvalFramework.GetChangesSummary(ref changesWithParticularStatus);

      return changesWithParticularStatus.TotalRows;
    }

    /// <summary>
    /// Help function to clear all previous changes to an item from previous test runs or failed test runs
    /// </summary>
    /// <param name="changeType">name of the change type or null for all</param>
    /// <param name="uniqueItemId">name of the unique item id to clear or null for all</param>
    /// <param name="approvalFramework"></param>
    public static void DenyOrDismissAllChangesThatMatch(string changeType, string uniqueItemId, ApprovalManagementImplementation approvalFramework)
    {
      MTList<ChangeSummary> itemsToDismiss = new MTList<ChangeSummary>();
      if (!string.IsNullOrEmpty(changeType))
        itemsToDismiss.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, changeType));
      if (!string.IsNullOrEmpty(uniqueItemId))
        itemsToDismiss.Filters.Add(new MTFilterElement("UniqueItemId", MTFilterElement.OperationType.Equal, uniqueItemId));

      approvalFramework.GetChangesSummary(ref itemsToDismiss);

      //Now dismiss all these
      foreach(ChangeSummary change in itemsToDismiss.Items)
      {
        //If change is Dismissed or Applied, then we don't have to do anything
        if ((change.CurrentState != ChangeState.Dismissed) && (change.CurrentState!=ChangeState.Applied))
        {
          if (change.SubmitterId == approvalFramework.SessionContext.AccountID)
            approvalFramework.DismissChange(change.Id,
                                            "Dismissed while setting up for next test run (DenyOrDismissAllChangesThatMatch)");
          else
            approvalFramework.DenyChange(change.Id,
                                         "Denied while setting up for next test run (DenyOrDismissAllChangesThatMatch)");
        }
      }

    }

    /// <summary>
    /// Help function to clear all previous changes to an item from previous test runs or failed test runs
    /// </summary>
    /// <param name="changeType">name of the change type or null for all</param>
    /// <param name="uniqueItemId">name of the unique item id to clear or null for all</param>
    public static void DenyOrDismissAllChangesThatMatch(string changeType, string uniqueItemId)
    {
      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
      approvalFramework.SessionContext = SharedTestCode.LoginAsSU();

      DenyOrDismissAllChangesThatMatch(changeType, uniqueItemId, approvalFramework);
    }

    public static IMTSessionContext LoginAsUserWhoCanSubmitChanges()
    {
      return SharedTestCode.LoginAsSU();
    }

    public static IMTSessionContext LoginAsUserWhoCanViewApprovals()
    {
      return SharedTestCode.LoginAsAdmin();
    }

    public static IMTSessionContext LoginAsUserWhoCanApproveSampleUpdate()
    {
      return SharedTestCode.LoginAsAdmin();
    }

    public static IMTSessionContext LoginAsUserWhoCanApproveRateUpdate()
    {
      return SharedTestCode.LoginAsAdmin();
    }

    public static IMTSessionContext LoginAsUserWhoCanApproveGroupSubscriptionMembershipUpdate()
    {
      return SharedTestCode.LoginAsAdmin();
    }

    public static IMTSessionContext LoginAsUserWhoCanApproveAccountUpdate()
    {
      return SharedTestCode.LoginAsAdmin();
    }
  }
}

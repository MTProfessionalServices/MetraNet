using System;
using System.Runtime.InteropServices;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.DomainModel.BaseTypes;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;

namespace MetraTech.Approvals
{
  /// <summary>
  /// The main interface to the approvals client
  /// </summary>
  [Guid("23224F10-3BE4-4DB9-9630-F17D2BFB49E5")]
  [ComVisible(true)]
  public interface IApprovalsSimplifiedClient
  {

    /// <summary>
    /// SessionContext used to secure certain methods, set this first
    /// </summary>
    Auth.IMTSessionContext SessionContext { set; }

    int SubmitChangeForApproval(string changeType, string uniqueItemId, string itemDisplayName, string changeComment, string changeDetailsPayload, out string errorDetails);

    /// <summary>
    /// Determines if approvals are enabled for this change type
    /// </summary>
    /// <param name="changeType"></param>
    /// <returns></returns>
    bool ApprovalsEnabled(string changeType);

    /// <summary>
    /// Determines if approvals are enabled for this change type
    /// </summary>
    /// <param name="changeType"></param>
    /// <returns></returns>
    bool ApprovalAllowsMoreThanOnePendingChange(string changeType);

    /// <summary>
    /// Determines if there is a pending change already for this change type and if
    /// </summary>
    /// <param name="changeType"></param>
    /// <param name="uniqueItemId"></param>
    /// <returns></returns>
    bool HasPendingChange(string changeType, string uniqueItemId /*, out ArrayList pendingChangeIds*/);

    /// <summary>
    /// Returns the serialized change details for the given change id
    /// </summary>
    /// <param name="changeId">Id of the change being requested</param>
    /// <returns>string with buffer of change details that have been serialized</returns>
    string GetChangeDetails(int changeId);

    /// <summary>
    /// Returns the change summary objects so various properties of the change can be inspected
    /// </summary>
    /// <param name="changeId">Id of the change being requested</param>
    /// <returns>ChangeSummary object with details about the change</returns>
    ChangeSummary GetChangeSummary(int changeId);

    MetraTech.DomainModel.ProductCatalog.ProductOffering Convert(MetraTech.Interop.MTProductCatalog.MTProductOffering from);
  }


  [ClassInterface(ClassInterfaceType.None)]
  [Guid("EE2BD2CD-303C-4AE1-AE82-837D85DE8E8C")]
  [ComVisible(true)]
  public class SimplifiedClient : IApprovalsSimplifiedClient
  {
    private Auth.IMTSessionContext mSessionContext = null;

    //TODO: Switch to use web service and pull out simplified client into its own assembly
    private ApprovalManagementImplementation mApprovalFramework = null;

    private const string MISSING_SESSION_CONTEXT = "Caller must first set a valid session context before calling this method!";

    public SimplifiedClient()
    {
      mApprovalFramework=new ApprovalManagementImplementation();
    }

    #region IApprovalsSimplifiedClient Members

    public Auth.IMTSessionContext SessionContext
    {
			set 
			{
				if (value == null)
					throw new ApplicationException(MISSING_SESSION_CONTEXT);

				mSessionContext = value;
			  mApprovalFramework.SessionContext = mSessionContext;
			}
    }
    

    public int SubmitChangeForApproval(string changeType, string uniqueItemId, string itemDisplayName, string changeComment, string changeDetailsPayload, out string errorDetails)
    {
      Change myNewChange = new Change();
      myNewChange.ChangeType = changeType;
      myNewChange.UniqueItemId = uniqueItemId;

      myNewChange.ChangeDetailsBlob = changeDetailsPayload;

      myNewChange.ItemDisplayName = itemDisplayName;
      myNewChange.Comment = changeComment;

      int newChangeId;
      mApprovalFramework.SubmitChange(myNewChange, out newChangeId);

      errorDetails = "";

      return newChangeId;
    }

    public bool HasPendingChange(string changeType, string uniqueItemId)
    {
      if (mSessionContext == null)
        throw new ApplicationException(MISSING_SESSION_CONTEXT);

      List<int> pendingChanges;
      mApprovalFramework.GetPendingChangeIdsForItem(changeType, uniqueItemId, out pendingChanges);

      return (pendingChanges.Count != 0);
    }

    public bool  ApprovalsEnabled(string changeType)
    {
      bool notUsed;
      return mApprovalFramework.ApprovalsEnabledForChangeType(changeType, out notUsed);
    }

    public bool  ApprovalAllowsMoreThanOnePendingChange(string changeType)
    {
      bool allowsMoreThanOnePendingChange;
      mApprovalFramework.ApprovalsEnabledForChangeType(changeType, out allowsMoreThanOnePendingChange);
      return allowsMoreThanOnePendingChange;
    }

    public string GetChangeDetails(int changeId)
    {
      string details;
      mApprovalFramework.GetChangeDetails(changeId,out details);
      return details;
    }

    public ChangeSummary GetChangeSummary(int changeId)
    {
      MTList<ChangeSummary> singleItem = new MTList<ChangeSummary>();
      singleItem.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Equal, changeId));
      mApprovalFramework.GetChangesSummary(ref singleItem);

      if (singleItem.Items.Count == 0)
        throw new Exception(string.Format("Approvals Change with id {0} not found.", changeId));
      else if (singleItem.Items.Count>1)
        throw new Exception(string.Format("More than one Approvals Change with id {0} found. Internal Error.", changeId));

      return singleItem.Items[0];
    }

    public MetraTech.DomainModel.ProductCatalog.ProductOffering Convert(MetraTech.Interop.MTProductCatalog.MTProductOffering from)
    {
        return DiffManager.Convert(from);
    }

    #endregion
  }
}


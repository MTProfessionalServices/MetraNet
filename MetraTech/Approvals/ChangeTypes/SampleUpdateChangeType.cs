using System;
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.Approvals.ChangeTypes
{
  class SampleUpdateChangeType : IApprovalFrameworkSubmitChange, IApprovalFrameworkApplyChange, IApprovalFrameworkDenyChange
  {
    void IApprovalFrameworkApplyChange.ApplyChange(Change change, string commmentFromApprover, Interop.MTAuth.IMTSessionContext sessionContext)
    {
      //Update the system with the change

      Logger logger = new Logger("[ApprovalFrameworkSampleChangeType]");
      logger.LogDebug("SampleUpdate: ApplyChange called");

      //commmentFromApprover, if provided by the user/process that approved the change, has been already been audited using the approval framework but is supplied here if it is needed
      //The change itself has the comment from the submitter (change.Comment), if provided, and is most likely the comment to be used when the change is applied if it is needed

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper(change.ChangeDetailsBlob);
      decimal newValue = decimal.Parse(changeDetails["UpdatedValue"].ToString());

      //Simulate error for testing
      if ((newValue == 3.14M) || (newValue == 1003.14M))
      {
        throw new Exception("Error Updating: Setting the value to pi or (1000 + pi) is silly and not allowed");
      }

      DateTime timeChangeApplied = MetraTime.Now;
      logger.LogInfo("SampleUpdate: Change from user id {0} applied with value of {1} on {2}: Change Comment:'{3}'", sessionContext.AccountID, timeChangeApplied, newValue, change.Comment);

    }

    void IApprovalFrameworkSubmitChange.BeforeSubmitChange(ref Change change, ref bool changeRequiresApproval, Interop.MTAuth.IMTSessionContext sessionContext)
    {
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper(change.ChangeDetailsBlob);

      decimal newValue = decimal.Parse(changeDetails["UpdatedValue"].ToString());

      //Check for errors before the change is submitted
      //Example: Check that this user is authorized to make this change
      //Example: Check the input or change details for common mistakes or issues
      if ((newValue<0.00M) || (newValue>1000000.00M))
      {
        throw new ArgumentException("Value must be between 0 and 999999.99", "UpdatedValue");
      }

      //Add customization that decides if this particular change needs approval or can be applied immediately; by default it would go to approval process
      //Example: If the value is more than 1000, then it must be approved
      if (newValue < 1000.00M)
        changeRequiresApproval = false;
      else
        changeRequiresApproval = true;
    }

    void IApprovalFrameworkDenyChange.DenyChange(Change change, string commentFromDenier, Interop.MTAuth.IMTSessionContext sessionContext)
    {
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper(change.ChangeDetailsBlob);
      decimal newValue = (decimal)changeDetails["UpdatedValue"];

      Logger logger = new Logger("[ApprovalFrameworkSampleChangeType");
      logger.LogInfo("SampleUpdate: Change from user id {0} with value of {1} was denied: Change Comment:'{2}': Comment as to why it was denied:'{3}'", sessionContext.AccountID, newValue, change.Comment, commentFromDenier);

    }
  }
}

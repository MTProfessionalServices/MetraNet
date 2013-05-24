using MetraTech.Approvals;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuth;

namespace SampleChangeType
{
  class EmptySample : IApprovalFrameworkSubmitChange, IApprovalFrameworkApplyChange, IApprovalFrameworkDenyChange
  {
    void IApprovalFrameworkApplyChange.ApplyChange(Change change, string commment, IMTSessionContext sessionContext)
    {

    }

    void IApprovalFrameworkSubmitChange.BeforeSubmitChange(ref Change change, ref bool changeRequiresApproval, IMTSessionContext sessionContext)
    {
      changeRequiresApproval = true;
    }

    void IApprovalFrameworkDenyChange.DenyChange(Change change, string comment, IMTSessionContext sessionContext)
    {

    }
  }
}

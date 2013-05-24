using System;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuth;
using System.Collections.Generic;

namespace MetraTech.Approvals
{
  public interface IApprovalFrameworkSubmitChange
  {
    void BeforeSubmitChange(ref Change change, ref bool changeRequiresApproval, IMTSessionContext sessionContext);
  }

  public interface IApprovalFrameworkApplyChange
  {
    void ApplyChange(Change change, string commmentFromApprover, IMTSessionContext sessionContext);
  }

  public interface IApprovalFrameworkDenyChange
  {
    void DenyChange(Change change, string commentFromDenier, IMTSessionContext sessionContext);
  }

  public interface ISerializeRegisterKnownTypes
  {
    void RegisterKnownTypes(ref List<Type> knownTypes);
  }
}

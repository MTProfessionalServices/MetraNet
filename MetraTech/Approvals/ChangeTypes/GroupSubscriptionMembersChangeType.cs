using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Approvals.ChangeTypes
{
  class GroupSubscriptionMembersChangeType : ISerializeRegisterKnownTypes
  {
    #region ISerializeRegisterKnownTypes Members

    public void RegisterKnownTypes(ref List<Type> knownTypes)
    {
      knownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember));
      knownTypes.Add(typeof(List<MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember>));
    }

    #endregion
  }
}

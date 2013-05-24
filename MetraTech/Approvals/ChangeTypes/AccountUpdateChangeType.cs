using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Approvals.ChangeTypes
{
  class AccountUpdateChangeType : ISerializeRegisterKnownTypes
  {
    #region ISerializeRegisterKnownTypes Members

    public void RegisterKnownTypes(ref List<Type> knownTypes)
    {
      knownTypes.AddRange(MetraTech.DomainModel.BaseTypes.Account.KnownTypes());
    }

    #endregion
  }
}

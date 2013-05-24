using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Approvals.ChangeTypes
{
  class ProductOfferingUpdateChangeType : ISerializeRegisterKnownTypes
  {
    #region ISerializeRegisterKnownTypes Members

    public void RegisterKnownTypes(ref List<Type> knownTypes)
    {
      knownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.ProductOffering));
    }

    #endregion
  }
}

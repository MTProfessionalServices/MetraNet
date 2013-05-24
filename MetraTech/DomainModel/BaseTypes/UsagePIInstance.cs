using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    public abstract class UsagePIInstance : BasePriceableItemInstance
    {
        protected override PriceableItemKinds GetPIKind()
        {
            return PriceableItemKinds.Usage;
    }
    }
}

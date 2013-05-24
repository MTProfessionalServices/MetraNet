using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    public class RecurringChargePITemplate : BaseRecurringChargePITemplate
    {
        protected override PriceableItemKinds GetPIKind()
        {
            return PriceableItemKinds.Recurring;
        }

    }
}

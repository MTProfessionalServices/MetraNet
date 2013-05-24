using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.MetraPay
{
    [Serializable]
    public enum TransactionType
    {
        DEBIT = 0,
        CREDIT,
        AUTHORIZE,
        REVERSE_AUTH,
        CAPTURE
    }
}

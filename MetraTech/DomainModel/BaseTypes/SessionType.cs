using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.BaseTypes
{
    [Serializable]
    public enum SessionType
    {
        Atomic = 0,
        Compound = 1
    }
}

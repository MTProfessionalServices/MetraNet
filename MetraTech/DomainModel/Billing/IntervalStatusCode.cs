using System;
using System.Runtime.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [Serializable]
    public enum IntervalStatusCode
    {
        Open = 0,
        SoftClosed = 1,
        HardClosed = 2,
        Archived = 3
    }
}
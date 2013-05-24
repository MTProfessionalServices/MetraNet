using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    [KnownType(typeof(DateRangeSlice))]
    [KnownType(typeof(UsageIntervalSlice))]
    [KnownType(typeof(IntersectionSlice))]
    [KnownType(typeof(CurrentAccountIntervalSlice))]
    public abstract class TimeSlice : BaseSlice
    {
    }
}
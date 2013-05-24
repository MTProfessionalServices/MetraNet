using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    [KnownType(typeof(SingleSessionSlice))]
    [KnownType(typeof(SessionChildrenSlice))]
    [KnownType(typeof(RootSessionSlice))]
    [KnownType(typeof(AllSessionSlice))]
    public abstract class SessionSlice : BaseSlice
    {
    }
}
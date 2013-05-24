using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    [KnownType(typeof(PayerAccountSlice))]
    [KnownType(typeof(PayeeAccountSlice))]
    [KnownType(typeof(PayerAndPayeeSlice))]
    [KnownType(typeof(DescendentPayeeSlice))]
    public abstract class AccountSlice : BaseSlice
    {
    }
}
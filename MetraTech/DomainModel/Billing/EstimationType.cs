using System;
using System.Runtime.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [Serializable]
    public enum EstimationType
    {
        None = 0,
        CurrentBalance = 1,
        PreviousBalance = 2
    }
}
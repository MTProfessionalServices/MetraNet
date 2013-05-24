using System;
using System.Runtime.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [Serializable]
    public enum ReportViewType
    {
        OnlineBill = 0,
        Interactive = 1
    }
}
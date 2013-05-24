using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class AllSessionSlice : SessionSlice
    {
    }
}
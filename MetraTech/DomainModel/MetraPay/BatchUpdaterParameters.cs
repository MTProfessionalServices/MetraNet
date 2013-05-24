using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.MetraPay
{
    [AttributeUsage(AttributeTargets.Property, AllowMultiple=false)]
    public class BatchUpdaterParameterAttribute : Attribute
    {
        public string QueryTag { get; set; }
    }

    [DataContract]
    [Serializable]
    public class BatchUpdaterParameters : BaseObject
    {
    }
}

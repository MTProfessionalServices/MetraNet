using System;
using System.Runtime.Serialization;

namespace MetraTech.BusinessEntity.Core.Model
{
  [Serializable]
  [DataContract(IsReference = true)]
  public class SubscriptionDef : MetranetEntity
  {
    [DataMember]
    public virtual int SubscriptionId { get; set; }
  }
}

using System;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.Core.Config;

namespace MetraTech.BusinessEntity.Core.Model
{
  [Serializable]
  [DataContract(IsReference = true)]
  public class AccountDef : MetranetEntity
  {
    [DataMember]
    public virtual int AccountId { get; set; }
  }
}

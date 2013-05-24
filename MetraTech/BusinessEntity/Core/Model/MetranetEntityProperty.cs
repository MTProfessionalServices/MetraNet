using System;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.Core.Config;

namespace MetraTech.BusinessEntity.Core.Model
{
  /// <summary>
  /// </summary>
  [Serializable]
  [DataContract(IsReference = true)]
  public class MetranetEntityProperty
  {
    [DataMember]
    public string Name { get; set; }
    [DataMember]
    public string TypeName { get; set; }
    [DataMember]
    public object Value { get; set; }
  }
}

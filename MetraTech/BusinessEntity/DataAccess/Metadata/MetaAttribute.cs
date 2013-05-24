using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class MetaAttribute
  {
    public MetaAttribute()
    {
      Values = new List<string>();
    }
    
    internal MetaAttribute Clone()
    {
      var metaAttribute = new MetaAttribute() {Name = this.Name, Value = this.Value};
      metaAttribute.Values.AddRange(Values);
      return metaAttribute;
    }

    #region Public Properties
    [DataMember]
    public string Name { get; set; }
    [DataMember]
    public string Value { get; set; }
    [DataMember]
    public List<string> Values { get; set; }
    #endregion
  }
}

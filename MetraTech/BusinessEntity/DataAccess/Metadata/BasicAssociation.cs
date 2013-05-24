using System;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class BasicAssociation
  {
    public virtual string PropertyName { get; set; }
    // Have to name this better
    public virtual string OtherPropertyName { get; set; }
    public virtual string EntityTypeName { get; set; }
  }
}

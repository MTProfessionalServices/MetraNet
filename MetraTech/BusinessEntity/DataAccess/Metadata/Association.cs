using System;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class Association : BasicAssociation
  {
    public virtual EntityInstance EntityInstance { get; set; } 
  }
}

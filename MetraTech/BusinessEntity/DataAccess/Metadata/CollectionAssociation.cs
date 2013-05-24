using System;
using System.Collections.Generic;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class CollectionAssociation : BasicAssociation
  {
    public CollectionAssociation()
    {
      EntityInstances = new List<EntityInstance>();
    }

    public virtual IList<EntityInstance> EntityInstances { get; private set; }
  }
}

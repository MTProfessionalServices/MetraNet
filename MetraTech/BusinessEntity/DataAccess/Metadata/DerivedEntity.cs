using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.BusinessEntity.Core;
using NHibernate.Cfg.MappingSchema;

using MetraTech.Basic;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class DerivedEntity : Entity
  {
    #region Public Methods
    public DerivedEntity(string fullName) : base(fullName)
    {
      EntityType = EntityType.Derived;
    }
    #endregion

    #region Internal Methods
    internal Entity ReadHbmMapping(HbmMapping hbmMapping)
    {
      Entity entity = null;

      return entity;
    }

    
    #endregion

    #region Protected Methods
    protected DerivedEntity(DerivedEntity derivedEntity)
      : base(derivedEntity)
    {
    }
    #endregion

  }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core.Persistence;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class RelatedEntity
  {
    public Entity Entity { get; set; } 
    public Multiplicity Multiplicity {get; set;}
    public string PropertyName { get; set; }
  }
}

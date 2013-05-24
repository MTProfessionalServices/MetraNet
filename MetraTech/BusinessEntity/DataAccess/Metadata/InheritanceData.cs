using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class InheritanceData
  {
    public Entity ParentEntity { get; set; }
    public Entity DerivedEntity { get; set; }

    public override string ToString()
    {
      string parentEntityName = ParentEntity != null ? ParentEntity.FullName : "";
      string derivedEntityName = DerivedEntity != null ? DerivedEntity.FullName : "";

      return String.Format("InheritanceData: ParentEntity = '{0}', DerivedEntity = '{1}'",
                           parentEntityName, derivedEntityName);
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as InheritanceData;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.ParentEntity.Equals(ParentEntity) &&
             compareTo.DerivedEntity.Equals(DerivedEntity);
    }

    public override int GetHashCode()
    {
      return String.Concat(ParentEntity.FullName, DerivedEntity.FullName).GetHashCode();
    }
  }
}

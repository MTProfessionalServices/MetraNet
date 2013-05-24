using System;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class InternalProperty
  {
    #region Public Properties
    public virtual string Name { get; set; }
    public virtual PropertyType PropertyType { get; set; }
    public virtual object Value { get; set; }
    #endregion

    public override bool Equals(object obj)
    {
      var compareTo = obj as InternalProperty;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.Name == Name;
    }

    public override int GetHashCode()
    {
      return Name.GetHashCode();
    }

  }
}

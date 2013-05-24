using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public abstract class Metadata
  {
    #region Constructor
    protected Metadata()
    {
    }
    #endregion

    #region Properties

    // public IMetadataAccess MetadataAccessor { get; private set; }

    #endregion

    #region Methods
    public abstract bool Validate(out List<ErrorObject> validationErrors);
    #endregion
  }

  /// <summary>
  /// Provides a comparer for supporting LINQ methods such as Intersect, Union and Distinct.
  /// This may be used for comparing objects of type <see cref="Metadata" /> and anything 
  /// that derives from it, such as <see cref="Entity" /> and <see cref="Property" />.
  /// 
  /// NOTE:  Microsoft decided that set operators such as Intersect, Union and Distinct should 
  /// not use the IEqualityComparer's Equals() method when comparing objects, but should instead 
  /// use IEqualityComparer's GetHashCode() method.
  /// </summary>
  public class MetadataEqualityComparer<T> : IEqualityComparer<T> where T : Metadata
  {
    public bool Equals(T firstObject, T secondObject)
    {
      // While SQL would return false for the following condition, returning true when 
      // comparing two null values is consistent with the C# language
      if (firstObject == null && secondObject == null)
        return true;

      if (firstObject == null ^ secondObject == null)
        return false;

      return firstObject.Equals(secondObject);
    }

    public int GetHashCode(T obj)
    {
      return obj.GetHashCode();
    }
  }
}

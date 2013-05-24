  using System.Reflection;
  using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Runtime.Serialization;
  using MetraTech.Basic;


  namespace MetraTech.BusinessEntity.DataAccess.Metadata
  {
  /// <summary>
  /// Provides a standard base class for facilitating comparison of objects.
  /// 
  /// For a discussion of the implementation of Equals/GetHashCode, see 
  /// http://devlicio.us/blogs/billy_mccafferty/archive/2007/04/25/using-equals-gethashcode-effectively.aspx
  /// and http://groups.google.com/group/sharp-architecture/browse_thread/thread/f76d1678e68e3ece?hl=en for 
  /// an in depth and conclusive resolution.
  /// </summary>
  [Serializable]
  [DataContract(IsReference = true)]
  public abstract class BaseBmeObject
  {
    public override bool Equals(object obj) {
          BaseBmeObject compareTo = obj as BaseBmeObject;

          if (ReferenceEquals(this, compareTo))
              return true;

          return compareTo != null && GetType().Equals(compareTo.GetTypeUnproxied()) &&
              HasSameObjectBusinessKeyAs(compareTo);
      }

    /// <summary>
    /// This is used to provide the hashcode identifier of an object using the businessKey 
    /// properties of the object; although it's necessary for NHibernate's use, this can 
    /// also be useful for business logic purposes and has been included in this base 
    /// class, accordingly.  Since it is recommended that GetHashCode change infrequently, 
    /// if at all, in an object's lifetime, it's important that properties are carefully
    /// selected which truly represent the businessKey of an object.
    /// </summary>
    public override int GetHashCode() {
      unchecked
      {
        List<object> businessKeyPropertyValues = GetBusinessKeyPropertyValues();

        // It's possible for two objects to return the same hash code based on 
        // identically valued properties, even if they're of two different types, 
        // so we include the object's type in the hash calculation
        int hashCode = GetType().GetHashCode();

        foreach (object value in businessKeyPropertyValues) {
          if (value != null)
            hashCode = (hashCode * HASH_MULTIPLIER) ^ value.GetHashCode();
        }

        if (businessKeyPropertyValues.Any())
            return hashCode;

        // If no properties were flagged as being part of the businessKey of the object,
        // then simply return the hashcode of the base object as the hashcode.
        return base.GetHashCode();
      }
    }

    /// <summary>
      /// You may override this method to provide your own comparison routine.
      /// </summary>
    public virtual bool HasSameObjectBusinessKeyAs(BaseBmeObject compareTo)
    {
      Dictionary<string, Dictionary<string, object>> businessKeyPropertyValues =
        GetBusinessKeyPropertyValuesByBusinessKey();

      Dictionary<string, Dictionary<string, object>> compareToBusinessKeyPropertyValues =
        compareTo.GetBusinessKeyPropertyValuesByBusinessKey();

      foreach(KeyValuePair<string, Dictionary<string, object>> kvp in businessKeyPropertyValues)
      {
        Dictionary<string, object> compareToKeyValues;
        if (!compareToBusinessKeyPropertyValues.TryGetValue(kvp.Key, out compareToKeyValues))
        {
          return false;
        }
        
        foreach(KeyValuePair<string, object> innerKvp in kvp.Value)
        {
          object compareToValue;
          if (!compareToKeyValues.TryGetValue(innerKvp.Key, out compareToValue))
          {
            return false;
          }

          if (!innerKvp.Value.Equals(compareToValue))
          {
            return false;
          }
        }
      }

      // If we've gotten this far and businessKey properties were found, then we can
      // assume that everything matched; otherwise, if there were no businessKey 
      // properties, then simply return the default behavior of Equals
      return businessKeyPropertyValues.Any() || base.Equals(compareTo);
    }

    /// <summary>
      /// </summary>
    public virtual Dictionary<string, IEnumerable<PropertyInfo>> GetBusinessKeyProperties()
      {
        Dictionary<string, IEnumerable<PropertyInfo>> properties;

        if (businessKeyPropertiesDictionary == null)
            businessKeyPropertiesDictionary = new Dictionary<Type, Dictionary<string, IEnumerable<PropertyInfo>>>();

        if (businessKeyPropertiesDictionary.TryGetValue(GetType(), out properties))
            return properties;

        return (businessKeyPropertiesDictionary[GetType()] = GetTypeSpecificBusinessKeyProperties());
      }

    /// <summary>
    /// When NHibernate proxies objects, it masks the type of the actual entity object.
    /// This wrapper burrows into the proxied object to get its actual type.
    /// 
    /// Although this assumes NHibernate is being used, it doesn't require any NHibernate
    /// related dependencies and has no bad side effects if NHibernate isn't being used.
    /// 
    /// Related discussion is at http://groups.google.com/group/sharp-architecture/browse_thread/thread/ddd05f9baede023a ...thanks Jay Oliver!
    /// </summary>
    protected virtual Type GetTypeUnproxied() {
        return GetType();
    } 

    /// <summary>
    /// Enforces the template method pattern to have child objects determine which specific 
    /// properties should and should not be included in the object businessKey comparison.  Note
    /// that the the BaseBmeObject already takes care of performance caching, so this method 
    /// shouldn't worry about caching...just return the goods man!
    /// </summary>
    protected abstract Dictionary<string, IEnumerable<PropertyInfo>> GetTypeSpecificBusinessKeyProperties();


    private List<object> GetBusinessKeyPropertyValues()
    {
      var propertyValues = new List<object>();
      Dictionary<string, IEnumerable<PropertyInfo>> businessKeyProperties = GetBusinessKeyProperties();

      foreach(KeyValuePair<string, IEnumerable<PropertyInfo>> kvp in businessKeyProperties)
      {
        PropertyInfo businessKeyProperty = GetType().GetProperty(kvp.Key);
        Check.Require(businessKeyProperty != null, 
                      String.Format("Cannot find business key property '{0}' on type '{1}'", kvp.Key, GetType().FullName));
        object businessKeyPropertyInstance = businessKeyProperty.GetValue(this, null);
        Check.Require(businessKeyPropertyInstance != null, 
                      String.Format("Cannot retrieve business key instance for property name '{0}' on type '{1}'", kvp.Key, GetType().FullName));

        foreach(PropertyInfo propertyInfo in kvp.Value)
        {
          propertyValues.Add(propertyInfo.GetValue(businessKeyPropertyInstance, null));
        }
      }

      return propertyValues;
    }

    private Dictionary<string, Dictionary<string, object>> GetBusinessKeyPropertyValuesByBusinessKey()
    {
      var propertyValuesByBusinessKey = new Dictionary<string, Dictionary<string, object>>();
      Dictionary<string, IEnumerable<PropertyInfo>> businessKeyProperties = GetBusinessKeyProperties();

      foreach (KeyValuePair<string, IEnumerable<PropertyInfo>> kvp in businessKeyProperties)
      {
        if (businessKeyProperties.ContainsKey(kvp.Key))
        {
          continue;
        }

        PropertyInfo businessKeyProperty = GetType().GetProperty(kvp.Key);
        Check.Require(businessKeyProperty != null,
                      String.Format("Cannot find business key property '{0}' on type '{1}'", kvp.Key, GetType().FullName));
        object businessKeyPropertyInstance = businessKeyProperty.GetValue(this, null);
        Check.Require(businessKeyPropertyInstance != null,
                      String.Format("Cannot retrieve business key instance for property name '{0}' on type '{1}'",
                                    kvp.Key, GetType().FullName));

        var propertyValues = new Dictionary<string, object>();
        foreach (PropertyInfo propertyInfo in kvp.Value)
        {
          propertyValues.Add(propertyInfo.Name, propertyInfo.GetValue(businessKeyPropertyInstance, null));
        }
      }

      return propertyValuesByBusinessKey;
    }

    /// <summary>
    /// This static member caches the domain businessKey properties to avoid looking them up for 
    /// each instance of the same type.
    /// 
    /// A description of the very slick ThreadStatic attribute may be found at 
    /// http://www.dotnetjunkies.com/WebLog/chris.taylor/archive/2005/08/18/132026.aspx
    /// 
    /// The key is the Type of the DataObject
    /// The key in the inner Dictionary is the name of the BusinessKey property
    /// The value in the inner dictionary is an enumeration of PropertyInfo, one for each property
    /// on the corresponding business key class
    /// </summary>
    [ThreadStatic]
    private static Dictionary<Type, Dictionary<string, IEnumerable<PropertyInfo>>> businessKeyPropertiesDictionary;
        
    /// <summary>
    /// To help ensure hashcode uniqueness, a carefully selected random number multiplier 
    /// is used within the calculation.  Goodrich and Tamassia's Data Structures and
    /// Algorithms in Java asserts that 31, 33, 37, 39 and 41 will produce the fewest number
    /// of collisions.  See http://computinglife.wordpress.com/2008/11/20/why-do-hash-functions-use-prime-numbers/
    /// for more information.
    /// </summary>
    private const int HASH_MULTIPLIER = 31;
  }
}

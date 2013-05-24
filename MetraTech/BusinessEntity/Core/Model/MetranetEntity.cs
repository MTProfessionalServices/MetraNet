using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.Core.Config;

namespace MetraTech.BusinessEntity.Core.Model
{
  /// <summary>
  ///   Base class for Metranet entities e.g. AccountDef.
  /// </summary>
  [Serializable]
  [DataContract(IsReference = true)]
  [KnownType("GetKnownTypes")]
  public class MetranetEntity : IMetranetEntity
  {
    [DataMember]
    public MetraNetEntityConfig MetraNetEntityConfig { get; set; }

    [DataMember]
    public List<MetranetEntityProperty> Properties
    {
      get
      {
        var properties = new List<MetranetEntityProperty>();
        var metranetEntityProperties = GetType()
                                      .GetProperties(BindingFlags.Public | BindingFlags.Instance)
                                      .Where(p => p.Name != "MetraNetEntityConfig" && p.Name != "Properties");

        foreach(PropertyInfo propertyInfo in metranetEntityProperties)
        {
          properties.Add(new MetranetEntityProperty()
                           {
                             Name = propertyInfo.Name,
                             TypeName = propertyInfo.PropertyType.FullName,
                             Value = propertyInfo.GetValue(this, null)
                           });
        }

        return properties;
      }
    }

    public static Type[] GetKnownTypes()
    {
      var knownTypes = new List<Type>();
      foreach (MetraNetEntityConfig metranetEntityConfig in BusinessEntityConfig.Instance.MetraNetEntityConfigs)
      {
        knownTypes.Add(Type.GetType(metranetEntityConfig.AssemblyQualifiedName, true));
      }
      return knownTypes.ToArray();
    }

    #region Data
    #endregion
  }
}

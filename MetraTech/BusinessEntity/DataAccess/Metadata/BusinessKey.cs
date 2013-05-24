using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  [DataContract(IsReference = true)]
  [KnownType("GetKnownTypes")]
  public abstract class BusinessKey : IBusinessKey
  {
    #region Properties
    public abstract string EntityFullName { get; set; }
    #endregion

    #region Public Static Methods
    public static bool MatchBusinessKey(string entityName, BusinessKey businessKey)
    {
      return businessKey.GetType().FullName == Name.GetEntityBusinessKeyFullName(entityName);
    }

    public static void CheckProperties(string entityName, List<PropertyInstance> businessKeyProperties)
    {
      BusinessKey businessKey = GetBusinessKey(entityName);
      businessKey.CheckProperties(businessKeyProperties);
    }

    public static BusinessKey GetBusinessKey(string entityName)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      string businessKeyTypeName = Name.GetEntityBusinessKeyAssemblyQualifiedName(entityName);
      BusinessKey businessKey = Activator.CreateInstance(Type.GetType(businessKeyTypeName)) as BusinessKey;
      Check.Require(businessKey != null, String.Format("Cannot create business key instance from type '{0}'", businessKeyTypeName));

      return businessKey;
    }

    public static List<PropertyInstance> GetBusinessKeyProperties(string entityName)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      string businessKeyTypeName = Name.GetEntityBusinessKeyAssemblyQualifiedName(entityName);
      BusinessKey businessKey = Activator.CreateInstance(Type.GetType(businessKeyTypeName)) as BusinessKey;
      Check.Require(businessKey != null, String.Format("Cannot create business key instance from type '{0}'", businessKeyTypeName));

      return businessKey.GetPropertyData();
    }

    public static Type[] GetKnownTypes()
    {
      return DataObject.BusinessKeyKnownTypes;
    } 

    #endregion

    #region Public Methods

    /// <summary>
    ///   Implemented by derived classes to clear all relationship properties
    /// </summary>
    public abstract object Clone();

    public virtual object GetValue(string propertyName)
    {
      object value = null;
      if (String.IsNullOrEmpty(propertyName))
      {
        return value;
      }

      PropertyInfo propertyInfo = GetType().GetProperty(propertyName);
      if (propertyInfo != null)
      {
        value = propertyInfo.GetValue(this, null);
      }

      return value;
    }

    public virtual void SetValue(string propertyName, object value)
    {
      Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty", SystemConfig.CallerInfo);

      PropertyInfo propertyInfo = GetType().GetProperty(propertyName);
      if (propertyInfo != null)
      {
        propertyInfo.SetValue(this, value, null);
      }
    }

    public Dictionary<string, object> GetPropertyNameValues()
    {
      var propertyNameValues = new Dictionary<string, object>();
      List<PropertyInfo> propertyInfos = GetProperties();
      foreach(PropertyInfo propertyInfo in propertyInfos)
      {
        propertyNameValues.Add(propertyInfo.Name, propertyInfo.GetValue(this, null));
      }

      return propertyNameValues;
    }

    public Dictionary<string, string> GetPropertyColumnNames()
    {
      var propertyColumnNames = new Dictionary<string, string>();
      List<PropertyInfo> propertyInfos = GetProperties();
      foreach (PropertyInfo propertyInfo in propertyInfos)
      {
        propertyColumnNames.Add(propertyInfo.Name, Property.GetColumnName(propertyInfo.Name));
      }

      return propertyColumnNames;
    }

    public List<PropertyInfo> GetProperties()
    {
      var propertyInfos = new List<PropertyInfo>();
      PropertyInfo[] properties = GetType().GetProperties();
      foreach (PropertyInfo propertyInfo in properties)
      {
        if (propertyInfo.Name == "EntityFullName")
        {
          continue;
        }

        propertyInfos.Add(propertyInfo);
      }
      return propertyInfos;
    }

    public List<PropertyInstance> GetPropertyData()
    {
      var properties = new List<PropertyInstance>();
      var propertyInfos = GetProperties();
      foreach(PropertyInfo propertyInfo in propertyInfos)
      {
        var propertyInstance =
          new PropertyInstance(propertyInfo.Name, propertyInfo.PropertyType.AssemblyQualifiedName, true);
        
        propertyInstance.Value = propertyInfo.GetValue(this, null);

        properties.Add(propertyInstance);
      }

      return properties;
    }

    public void SetPropertyData(List<PropertyInstance> properties)
    {
      var propertyInfos = GetProperties();
      foreach (PropertyInstance propertyInstance in properties)
      {
        PropertyInfo propertyInfo = propertyInfos.Find(p => p.Name == propertyInstance.Name);
        Check.Require(propertyInfo != null, 
                      String.Format("Cannot find property with name '{0}' on business key class '{1}'",
                                    propertyInstance.Name, GetType().FullName),
                      SystemConfig.CallerInfo);
        propertyInfo.SetValue(this, propertyInstance.Value, null);
      }
    }

    public bool IsBusinessKeyProperty(string propertyName)
    {
      bool isBusinessKeyProperty = false;

      var propertyInfos = GetProperties();

      foreach (PropertyInfo businessKeyPropertyInfo in propertyInfos)
      {
        if (businessKeyPropertyInfo.Name == propertyName)
        {
          isBusinessKeyProperty = true;
          break;
        }
      }

      return isBusinessKeyProperty;
    }

    public bool HasNullProperties()
    {
      List<PropertyInstance> properties = GetPropertyData();
      PropertyInstance property = properties.Find(p => !p.Type.IsValueType && p.Value == null);
      if (property == null)
      {
        return false;
      }

      return true;
    }

    public void CheckProperties(List<PropertyInstance> businessKeyProperties)
    {
      Check.Require(businessKeyProperties != null, "businessKeyProperties cannot be null", SystemConfig.CallerInfo);
      List<PropertyInfo> propertyInfos = GetProperties();
      foreach(PropertyInfo propertyInfo in propertyInfos)
      {
        PropertyInstance propertyInstance = businessKeyProperties.Find(p => p.Name == propertyInfo.Name);
        if (propertyInstance == null ||
            (!propertyInfo.PropertyType.IsValueType && propertyInstance.Value == null))
        {
          string message =
            String.Format("The property '{0}' on business key '{1}' is not specified or has a null value",
                          propertyInfo.Name, GetType().FullName);
          throw new DataAccessException(message);
        }
      }
    }

    public override String ToString()
    {
      List<PropertyInstance> properties = GetPropertyData();
      return StringUtil.Join(" : ", properties, p => p.ToString());
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as BusinessKey;

      if (compareTo == null)
      {
        return false;
      }

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      Dictionary<string, object> propertyNameValues = GetPropertyNameValues();
      Dictionary<string, object> compareToPropertyNameValues = compareTo.GetPropertyNameValues();

      foreach(KeyValuePair<string, object> kvp in propertyNameValues)
      {
        if (!compareToPropertyNameValues.ContainsKey(kvp.Key))
        {
          return false;
        }

        object compareToValue;
        compareToPropertyNameValues.TryGetValue(kvp.Key, out compareToValue);
        if (compareToValue != null && kvp.Value != null)
        {
          if (!compareToValue.Equals(kvp.Value))
          {
            return false;
          }
        }
      }
      
      return true;
    }

    public override int GetHashCode()
    {
      Dictionary<string, object> propertyNameValues = GetPropertyNameValues();
      string combinedValueString = String.Empty;
      foreach(KeyValuePair<string, object> kvp in propertyNameValues)
      {
        if (kvp.Value != null)
        {
          combinedValueString += kvp.Value.ToString();
        }
      }

      return combinedValueString.GetHashCode();
    }
    #endregion

    #region Internal Methods
    internal void SetInternalKey(Guid key)
    {
      PropertyInfo internalKey = GetType().GetProperty("InternalKey");
      Check.Require(internalKey != null,
                    String.Format("Cannot find InternalKey property for BusinessKey type '{0}' on entity '{1}'",
                                  GetType().FullName, EntityFullName));
      internalKey.SetValue(this, key, null);
    }

    internal bool IsInternal()
    {
      PropertyInfo internalKey = GetType().GetProperty("InternalKey");
      return internalKey != null;
    }
    #endregion
  }

}

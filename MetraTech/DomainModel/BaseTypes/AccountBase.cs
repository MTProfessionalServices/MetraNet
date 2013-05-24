using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;
using System.IO;

using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  public abstract class AccountBase : BaseObject
  {
    #region Public Methods
    /// <summary>
    ///    Return the value of the IsRequired property on the MTDataMemberAttribute for the given propertyName
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public bool IsRequiredProperty(string propertyName)
    {
      bool required = false;

      PropertyInfo propertyInfo = GetProperty(propertyName);
      if (propertyInfo != null)
      {
        MTDataMemberAttribute attrib = GetMTDataMemberAttribute(propertyInfo);

        if (attrib != null)
        {
          required = attrib.IsRequired;
        }
      }

      return required;
    }

    public bool IsRequiredPropertySet(string propertyName)
    {
      bool propertySet = true;

      PropertyInfo propertyInfo = GetProperty(propertyName);
      if (propertyInfo != null)
      {
        MTDataMemberAttribute attrib = GetMTDataMemberAttribute(propertyInfo);

        if (attrib != null && attrib.IsRequired)
        {
          //ESR-4415 Misleading exception when mandatory string attribute in Account View is not populated 
          //if (GetValue(propertyInfo) == null)
          if ((GetValue(propertyInfo) == null) || (GetValue(propertyInfo).ToString() == ""))
          {
            propertySet = false;
          }
        }
      }

      return propertySet;
    }

    private static Dictionary<PropertyInfo, MTDataMemberAttribute> m_CachedAttributes = new Dictionary<PropertyInfo, MTDataMemberAttribute>();
    public MTDataMemberAttribute GetMTDataMemberAttribute(PropertyInfo propertyInfo)
    {
      MTDataMemberAttribute dataMemberAttribute = null;

      lock (m_CachedAttributes)
      {
        if (m_CachedAttributes.ContainsKey(propertyInfo))
        {
          dataMemberAttribute = m_CachedAttributes[propertyInfo];
        }
        else
        {
          object[] attributes = propertyInfo.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

          if (attributes != null && attributes.Length == 1)
          {
            dataMemberAttribute = attributes[0] as MTDataMemberAttribute;
          }

          m_CachedAttributes.Add(propertyInfo, dataMemberAttribute);
        }
      }

      return dataMemberAttribute;
    }

    public static Assembly GetAccountTypesAssembly()
    {
        return BaseObject.GetAssembly(GENERATED_ACCOUNT_ASSEMBLY);
      }

    /// <summary>
    ///   Return the list of types which have an attribute of the type specified by attributeType
    /// </summary>
    /// <param name="attributeType"></param>
    /// <returns></returns>
    public static Type[] GetKnownTypes(Type attributeType)
    {
        return BaseObject.GetTypesFromAssemblyByAttribute(GENERATED_ACCOUNT_ASSEMBLY, attributeType);
          }

    /// <summary>
    ///   Foreach string property on this class that is dirty:
    ///    If the MTDataMemberAttribute.Length property is greater than 0 
    ///    then
    ///      if the length of the string is greater than MTDataMemberAttribute.Length add
    ///      a validation error string to the validationErrors collection.
    /// </summary>
    /// <param name="validationErrors"></param>
    public void CheckStringLengths(ref List<string> validationErrors)
    {
      foreach (PropertyInfo propertyInfo in GetMTProperties())
      {
        if (propertyInfo.PropertyType == typeof(String) && IsDirty(propertyInfo.Name))
        {
          MTDataMemberAttribute attribute = GetMTDataMemberAttribute(propertyInfo);
          if (attribute != null)
          {
            int length = attribute.Length;
            if (length > 0)
            {
              string value = propertyInfo.GetValue(this, null) as String;
              if (value != null)
              {
                if (value.Length > length)
                {
                  validationErrors.Add(String.Format("The length of property '{0}' should be less than or equal to '{1}'", propertyInfo.Name, length));
                }
              }
            }
          }
        }
      }
    }

    /// <summary>
    ///   Return the value of the Length property on the MTDataMemberAttribute for the given propertyName
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public int GetPropertyLength(string propertyName)
    {
      int length = 0;

      PropertyInfo propertyInfo = GetProperty(propertyName);
      if (propertyInfo != null)
      {
        object[] attributes = propertyInfo.GetCustomAttributes(typeof(MTDataMemberAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          length = ((MTDataMemberAttribute)attributes[0]).Length;
        }
      }

      return length;
    }

    /// <summary>
    ///   Return those properties whose corresponding isDirty property has a value of false.
    /// </summary>
    /// <returns></returns>
    public List<PropertyInfo> GetUnchangedProperties()
    {
      List<PropertyInfo> properties = new List<PropertyInfo>();
      List<string> dirtyProperties = new List<string>();

      foreach (PropertyInfo propertyInfo in GetProperties())
      {
        if (propertyInfo.Name.StartsWith("Is") && propertyInfo.Name.EndsWith("Dirty"))
        {
          bool isDirty = (bool)propertyInfo.GetValue(this, null);
          if (!isDirty)
          {
            // Remove 'Is' 
            string propertyName = propertyInfo.Name.Remove(0, 2);
            // Remove 'Dirty'
            dirtyProperties.Add(propertyName.Replace("Dirty", ""));
          }
        }
      }

      PropertyInfo regularPropertyInfo;
      foreach (string dirtyPropName in dirtyProperties)
      {
        // Get the regular PropertyInfo. Ignore views
        regularPropertyInfo = GetProperty(dirtyPropName);
        object[] attributes = regularPropertyInfo.GetCustomAttributes(typeof(MTViewAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          continue;
        }
        properties.Add(regularPropertyInfo);
      }

      return properties;
    }
    #endregion

    #region Data
    //[NonSerialized]
//    protected static Logger logger = new Logger("Logging\\DomainModel\\BaseObject", "[DomainModel]");
    #endregion
  }
}

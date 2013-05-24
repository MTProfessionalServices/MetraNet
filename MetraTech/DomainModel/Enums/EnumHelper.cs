using System;
using System.Reflection;
using System.ComponentModel;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Resources;
using System.Collections;
using System.Threading;
using System.Globalization;
using MetraTech.Interop.MTEnumConfig;
using MetraTech;
using MetraTech.Interop.NameID;
using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.Enums
{
  public class EnumHelper : CommonEnumHelper
  {
    private static Dictionary<int,Object> CSharpEnumDictionary = new Dictionary<int,object>();

    /// <summary>
    ///   Return the enum given the C# type name.
    /// </summary>
    /// <param name="typeName"></param>
    /// <returns></returns>
    public static object GetEnumByTypeName(string typeName)
    {
      object enumInstance = null;
      Assembly assembly = GetAssembly(enumAssemblyName, "");
      if (assembly != null)
      {
        Type enumType = assembly.GetType(enumAssemblyName + "." + typeName, false, true);
        if (enumType != null)
        {
          enumInstance = Enum.ToObject(enumType, 0);
        }
      }

      return enumInstance;
    }

    /// <summary>
    ///   Return the enumType given the C# type name.
    /// </summary>
    /// <param name="typeName"></param>
    /// <returns></returns>
    public static Type GetEnumTypeByTypeName(string typeName)
    {
      Type enumType = null;
      Assembly assembly = GetAssembly(enumAssemblyName, "");
      if (assembly != null)
      {
        enumType = assembly.GetType(typeName, false, true);
      }

      return enumType;
    }

    /// <summary>
    ///   Return true if the given type is an enum type or a nullable enum type
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    public static bool IsEnumType(Type type)
    {
      bool isEnumType = false;

      if (type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
      {
        NullableConverter nullableConverter = new NullableConverter(type);
        if (nullableConverter.UnderlyingType.BaseType == typeof(Enum))
        {
          isEnumType = true;
        }
      }
      else if (type == typeof(Enum))
      {
        isEnumType = true;
      }

      return isEnumType;
    }

    /// <summary>
    ///   Given the value of id_enum_data in t_enum_data, return the equivalent C# enum
    /// </summary>
    /// <param name="enumDataId"></param>
    /// <returns></returns>
    public static object GetCSharpEnum(int enumDataId)
    {
      lock (CSharpEnumDictionary)
      {
        if (CSharpEnumDictionary.ContainsKey(enumDataId)) return CSharpEnumDictionary[enumDataId];
      }
      object csharpEnum = null;

      IMTNameID nameID = new MTNameIDClass();
      string enumStr = nameID.GetName(enumDataId).Trim();

      string[] enumParts = enumStr.Split('/');

      string value = enumParts[enumParts.Length - 1];
      string enumTypeStr = enumParts[enumParts.Length - 2];

      string enumSpace = enumParts[0];

      for (int i = 1; i < enumParts.Length - 2; i++)
      {
        enumSpace += "/" + enumParts[i];
      }

      Type enumType = GetGeneratedEnumType(enumSpace, enumTypeStr, "");
      csharpEnum = GetGeneratedEnumByEntry(enumType, value);

      lock (CSharpEnumDictionary)
      {
        CSharpEnumDictionary[enumDataId] = csharpEnum;
      }
      return csharpEnum;
    }

    /// <summary>
    ///    Given an enum specified as the following in the configuration:
    /// 
    ///    <enum name="PaymentMethod">
    ///      <description>Payment method</description>
    ///      <entries>
    ///        <entry name="CreditOrACH">
    ///          <value>1</value>
    ///        </entry>
    ///        <entry name="CashOrCheck">
    ///          <value>2</value>
    ///        </entry>
    ///      </entries>
    ///    </enum>
    /// 
    ///    Return the C# enum instance that matches the given entry name.
    ///    Hence, if the given entry name is CreditOrACH and the given enumType is MetraTech.Enums.PaymentMethod,
    ///    the PaymentMethod.CreditOrACH C# enum instance will be returned.
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="entryName"></param>
    /// <returns></returns>
    public static object GetGeneratedEnumByEntry(Type enumType, string entryName)
    {
        object enumInstance = null;

        object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
            MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;
            if (attribute != null)
            {
                int index = -1;

                foreach (string oldEnumValue in attribute.OldEnumValues)
                {
                    string name = string.Empty;
                    string[] internalValues;

                    SplitEnumAttribute(oldEnumValue, out name, out internalValues);

                    if (String.Compare(name, entryName, true) == 0)
                    {
                        index = GetEnumAttributeOrdinal(oldEnumValue);
                        break;
                    }
                }

                if (index != -1)
                {
                    enumInstance = Enum.ToObject(enumType, index);
                }
            }
        }

        return enumInstance;
    }

    /// <summary>
    ///    Given an enum specified as the following in the configuration:
    /// 
    ///    <enum name="PaymentMethod">
    ///      <description>Payment method</description>
    ///      <entries>
    ///        <entry name="CreditOrACH">
    ///          <value>1</value>
    ///        </entry>
    ///        <entry name="CashOrCheck">
    ///          <value>2</value>
    ///        </entry>
    ///      </entries>
    ///    </enum>
    /// 
    ///    Return the C# enum instance that matches the given value.
    ///    Hence, if the given value is 1 and the given enumType is MetraTech.Enums.PaymentMethod,
    ///    the PaymentMethod.CreditOrACH C# enum instance will be returned.
    /// 
    ///    Only the first value will be checked.
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="value"></param>
    /// <returns></returns>
    public static object GetGeneratedEnumByValue(Type enumType, object value)
    {
      if (value == null)
      {
        return null;
      }

      object enumInstance = null;

      object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
      if (attributes != null && attributes.Length > 0)
      {
        MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;
        if (attribute != null)
        {
          string[] paramValues = null;
          string name = String.Empty;
          int index = -1;
          int localOrdinal = 0;

          foreach (string oldEnumValue in attribute.OldEnumValues)
          {
            localOrdinal = SplitEnumAttribute(oldEnumValue, out name, out paramValues);
            if (paramValues != null && paramValues.Length > 0)
            {
              if (paramValues[0].ToLower() == value.ToString().ToLower())
              {
                index = localOrdinal;
                break;
              }
            }
          }

          if (index != -1)
          {
            enumInstance = Enum.ToObject(enumType, index);
          }
        }
      }

      return enumInstance;
    }

    private static Dictionary<string, Type> m_GeneratedTypeCache = new Dictionary<string, Type>();

    /*
    ///    Get the generated enum which corresponds to the given enum space and enum type. 
    ///    Enum property types in msixdef files have the enum space and enum types as attributes on the <type> element.
    ///    eg. 
    ///      
    ///        <ptype>
		///        <dn>PaymentMethod</dn>
		///        <type EnumSpace="metratech.com/accountcreation" EnumType="PaymentMethod">enum</type>
		///        <length></length>
		///        <required>N</required>
		///        <defaultvalue></defaultvalue>
    ///        <description>Payment method.</description>
	  ///      </ptype>
    ///     
    /// 
    /// <param name="configEnumSpace"></param>
    /// <param name="configEnumType"></param>
    /// <returns></returns>
    */
    public static Type GetGeneratedEnumType(string configEnumSpace, string configEnumType, string searchDir)
    {
      Type enumType = null;

      string fqn = string.Format("{0}/{1}", configEnumSpace, configEnumType);

      lock (m_GeneratedTypeCache)
      {
        if (m_GeneratedTypeCache.ContainsKey(fqn))
        {
          enumType = m_GeneratedTypeCache[fqn];
        }
      }

      if(enumType == null)
      {

        // Load the types from MetraTech.DomainModel.Enums.Generated.dll
        Assembly assembly = GetAssembly(enumAssemblyName, searchDir);

        if (assembly == null)
        {
          logger.LogError("Unable to load assembly '" + enumAssemblyName + "'");
          throw new ApplicationException("Unable to load assembly '" + enumAssemblyName + "'");
        }

        Type attributeType = typeof(MTEnumAttribute);
        foreach (Type type in assembly.GetTypes())
        {
          object[] attributes = type.GetCustomAttributes(attributeType, false);
          if (attributes != null && attributes.Length > 0)
          {
            MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;
            if (attribute != null)
            {
              if (attribute.EnumSpace.ToLower() == configEnumSpace.ToLower() &&
                  attribute.EnumName.ToLower() == configEnumType.ToLower())
              {
                enumType = type;

                lock (m_GeneratedTypeCache)
                {
                  if (!m_GeneratedTypeCache.ContainsKey(fqn))
                  {
                    m_GeneratedTypeCache.Add(fqn, enumType);
                  }
                }

                break;
              }
            }
          }
        }
      }

      return enumType;
    }

    

    

    /// <summary>
    ///    Return '1' if value is 'true', otherwise return '0' 
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public static string GetMTBool(bool value)
    {
      string mtbool = "1";

      if (value == false)
      {
        mtbool = "0";
      }

      return mtbool;
    }

    /// <summary>
    /// Returns the value of the multi-value enum instance.
    /// </summary>
    /// <param name="enumInstance">instance to return</param>
    /// <param name="valueID">0-based position of the value in the list of values</param>
    /// <returns></returns>
    public static object GetValueByEnum(object enumInstance, int valueID)
    {
      return GetValueByEnumInternal(enumInstance, false, valueID);
    }

    public static object GetDbValueByEnum(object enumInstance)
    {
      return GetValueByEnumInternal(enumInstance, true, -1);
    }

    public static object GetValueByEnum(object enumInstance)
    {
      return GetValueByEnumInternal(enumInstance, false, -1);
    }

    /// <summary>
    ///    Given an enum specified as the following in the configuration:
    /// 
    ///    <enum name="PaymentMethod">
    ///      <description>Payment method</description>
    ///      <entries>
    ///        <entry name="CreditOrACH">
    ///          <value>1</value>
    ///        </entry>
    ///        <entry name="CashOrCheck">
    ///          <value>2</value>
    ///        </entry>
    ///      </entries>
    ///    </enum>
    /// 
    ///    Return the <entry name=...> for the entry corresponding to the given enumInstance.
    /// </summary>
    /// <param name="enumInstance"></param>
    /// <returns></returns>
    public static string GetEnumEntryName(object enumInstance)
    {
      string entryName = String.Empty;

      if (enumInstance != null && enumInstance.GetType().BaseType == typeof(Enum))
      {
        int id = (int)enumInstance;

        // Get the enum type.
        Type enumType = enumInstance.GetType();

        object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;
          if (attribute.OldEnumValues != null && attribute.OldEnumValues.Length > id)
          {
            string[] internalValues;
            SplitEnumAttribute(attribute.OldEnumValues[id], out entryName, out internalValues);
          }
        }
      }

      return entryName;
    }



    /// <summary>
    ///   If getDBValue is true, return id_enum_data for the given enumInstance
    /// </summary>
    /// <param name="enumInstance"></param>
    /// <param name="getDbValue"></param>
    /// <param name="valueID"></param>
    /// <returns></returns>
    private static object GetValueByEnumInternal(object enumInstance, bool getDbValue, int valueID)
    {
      object value = null;

      // Make sure we have a valid enum object.
      if (enumInstance != null && enumInstance.GetType().BaseType == typeof(Enum))
      {
        // Get the enum type.
        Type enumType = enumInstance.GetType();

        // Get the enum value name.
        string enumValue = Enum.GetName(enumType, enumInstance);

        // Get type attributes.
        object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          // Get the enum attribute.
          MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;

          // Get the ineternal enum values.
          string[] internalEnumValues = attribute.OldEnumValues;
          if (internalEnumValues.Length > 0)
          {
            // Loop through enum names array and find the mapped internal value.
            string[] enumNames = Enum.GetNames(enumInstance.GetType());
            for (int i = 0; i < enumNames.Length; i++)
            {
              // Check if enum value matches sepecified value.
              if (enumNames[i].Equals(enumValue))
              {
                // Found it, get internal value and parse.
                string name = String.Empty;
                string[] paramValues = null;
                SplitEnumAttribute(internalEnumValues[i], out name, out paramValues);
                if (paramValues.Length > 0)
                {
                  if (getDbValue)
                  {
                    // Convert to database enum integer.
                    string enumName;
                    if (String.IsNullOrEmpty(attribute.EnumName))
                      enumName = enumType.Name;
                    else
                      enumName = attribute.EnumName;

                    EnumConfigClass enumConfig = new EnumConfigClass();
                    value = enumConfig.GetID(attribute.EnumSpace, enumName, name);
                  }
                  else
                  {
                    //if position of the value was not specified, return the first value
                    if (valueID < 0)
                    {
                      value = paramValues[0];
                    }
                      //otherwise return the value at specified position, provided it exists
                    else
                    {
                      if (valueID < paramValues.Length)
                      {
                        value = paramValues[valueID];
                      }
                    }
                  }
                }

                break;
              }
            }
          }
        }
      }

      // enum value not found.
      return value;
    }

    public static object GetDbValue(object obj, string propertyName)
    {
      PropertyInfo propertyInfo = obj.GetType().GetProperty(propertyName);
      return GetDbValue(obj, propertyInfo);
    }

    public static object GetDbValue(object obj, PropertyInfo pi)
    {
      // Get value.
      object value = pi.GetValue(obj, null);
      if (value == null)
      {
        return null;
      }

      // Check if this is a nullable type.
      Type type = pi.PropertyType;
      if (type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
      {
        NullableConverter nc = new NullableConverter(pi.PropertyType);
        type = nc.UnderlyingType;
      }

      // Process conversions.
      if (type == typeof(Boolean))
        return EnumHelper.GetMTBool((bool)value);
      else if (type.BaseType == typeof(Enum))
        return EnumHelper.GetDbValueByEnum(value);
      else
        return value;
    }

		/// <summary>
		///    Given an enum instance, get the fully qualified name for this instance
		///    based on the attribute data. The fully qualifed name of the enum looks like
		///    the following for the 'account' enum instance on the 'actiontype' enum:
		///    
		///    metratech.com/accountcreation/actiontype/account
		///    
		///    i.e. enum space/enum type/enum name/entry name
		/// </summary>
		/// <param name="enumInstance"></param>
		/// <returns></returns>
		public static string GetFQN(object enumInstance)
		{
			string fqn = String.Empty;

			if (enumInstance != null && enumInstance.GetType().BaseType == typeof(Enum))
			{
				int id = (int) enumInstance;

				// Get the enum type.
				Type enumType = enumInstance.GetType();

				object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
				if (attributes != null && attributes.Length > 0)
				{
					MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;

					fqn = attribute.EnumSpace + "/" + attribute.EnumName + "/" + GetEnumEntryName(enumInstance);
				}
			}

			return fqn;
		}
    #region Data
    private static readonly Logger logger =
        new Logger("Logging\\DomainModel\\EnumHelper", "[EnumHelper]");
    #endregion
  }
}

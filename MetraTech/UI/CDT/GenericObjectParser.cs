using System;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.UI.Tools;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.UI.CDT
{ 
  public class GenericObjectParser
  {
    /// <summary>
    /// Build up a list of PropertyInfo objects, and Property names with dot notation for binding and creating controls.
    /// </summary>
    /// <example>
    /// <![CDATA[
    ///     List<PropertyInfo> fullPropList = new List<PropertyInfo>();
    ///     List<string> propListNames = new List<string>();
    ///     GenericObjectParser.ParseType(objectType, "", fullPropList, propListNames);
    /// ]]>
    /// </example>
    /// <param name="t"></param>
    /// <param name="propPath"></param>
    /// <param name="fullPropList"></param>
    /// <param name="propListNames"></param>
    static public void ParseType(Type t, string propPath, List<PropertyInfo> fullPropList, List<string> propListNames)
    {
      // object[] attributes;

      // Get the property list by executing GetProperties() method on current type 
      if (propPath != "")
      {
        propPath = propPath + ".";
      }

      foreach (PropertyInfo pi in t.GetProperties())
      {
        if ((pi.PropertyType.BaseType != null) &&
            (pi.PropertyType.BaseType.Name.ToLower() == "view")) // account views
        {
            if (!(t.IsSubclassOf(typeof(DataObject))))
                ParseType(pi.PropertyType, propPath + pi.Name, fullPropList, propListNames);
        }
        else if ((pi.PropertyType.IsGenericType) && (pi.PropertyType.Name == "List`1"))  // For generic types, get the actual type and feed it in
        {
          Type[] internalTypes = pi.PropertyType.GetGenericArguments();
          for (int i = 0; i < internalTypes.Length; i++)
          {
              if (!(t.IsSubclassOf(typeof(DataObject)))) 
                  ParseType(internalTypes[i], propPath + pi.Name + "[" + i + "]", fullPropList, propListNames);
          }
        }
        else
        {
          // Skip the dirty flags by extracting only the properties with MTDataMember attributes
          //attributes = pi.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

          //if ((attributes != null) && (attributes.Length == 1))
         // {
            if (!propListNames.Contains(propPath + pi.Name))
            {
              propListNames.Add(propPath + pi.Name);
              fullPropList.Add(pi);
            }

            // Recurse if any other properties on type and if not a value type
            if (!pi.PropertyType.IsValueType && 
                pi.PropertyType.Name != "String" &&
                pi.PropertyType.GetProperties().Length > 0) 
            {
                if (!(t.IsSubclassOf(typeof(DataObject)))) 
                  ParseType(pi.PropertyType, propPath + pi.Name, fullPropList, propListNames);
            }

          //}
        }
      }

    }

    /// <summary>
    /// Parses an object and returns a dictionary of dotted notation keys and values
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="propPath"></param>
    /// <param name="values"></param>
    static public void ParseObjectForValues(object obj, string propPath, Dictionary<string, string> values)
    {
      Type t = obj.GetType();
      List<PropertyInfo> fullPropList = new List<PropertyInfo>();
      List<string> propListNames = new List<string>();

      ParseType(t, propPath, fullPropList, propListNames);
      foreach (var name in propListNames)
      {
        var val = Utils.GetPropertyEx(obj, name);
        if (val != null)
        {
          values.Add(name, val.ToString());
        }
        else
        {
          values.Add(name, null);
        }
      } 
    }

    /// <summary>
    /// Copies the data of one object to another. The target object 'pulls' properties of the first. 
    /// The object copy is a shallow copy only. Any nested types will be copied as 
    /// whole values rather than individual property assignments (ie. via assignment)
    /// </summary>
    /// <param name="source">The source object to copy from</param>
    /// <param name="target">The object to copy to</param>
    /// <param name="excludedProperties">A comma delimited list of properties that should not be copied</param>
    /// <param name="memberAccess">Reflection binding access</param>
    /// see:  http://www.west-wind.com/weblog/posts/847436.aspx
    public static void CopyObjectData(object source, object target, string excludedProperties, BindingFlags memberAccess)
    {
      List<string> excluded = null;
      if (!string.IsNullOrEmpty(excludedProperties))
        excluded.AddRange(excludedProperties.Split(new char[1] {','}, StringSplitOptions.RemoveEmptyEntries));

      MemberInfo[] miT = target.GetType().GetMembers(memberAccess);
      foreach (MemberInfo Field in miT)
      {
        string name = Field.Name;

        // Skip over any property exceptions
        if (!string.IsNullOrEmpty(excludedProperties) && excluded.Contains(name))
          continue;

        if (Field.MemberType == MemberTypes.Field)
        {
          FieldInfo SourceField = source.GetType().GetField(name);
          if (SourceField == null)
            continue;

          object SourceValue = SourceField.GetValue(source);
          ((FieldInfo)Field).SetValue(target, SourceValue);
        }
        else if (Field.MemberType == MemberTypes.Property)
        {
          PropertyInfo piTarget = Field as PropertyInfo;
          PropertyInfo SourceField = source.GetType().GetProperty(name, memberAccess);
          if (SourceField == null)
            continue;

          if (piTarget.CanWrite && SourceField.CanRead)
          {
            object SourceValue = SourceField.GetValue(source, null);
            piTarget.SetValue(target, SourceValue, null);
          }
        }
      }
    }

  }
}

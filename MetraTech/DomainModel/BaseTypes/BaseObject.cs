using System;
using System.Collections.Generic;
using System.Resources;
using System.Runtime.Serialization;
using System.Reflection;
using System.Diagnostics;
using System.ComponentModel;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;
using System.IO;

// The NeutralResourcesLanguageAttribute informs the ResourceManager of the language used to 
// write the neutral culture's resources for an assembly, and can also inform the 
// ResourceManager of the assembly to use (either the main assembly or a satellite assembly) 
// to retrieve neutral resources using the resource fallback process. 
[assembly: NeutralResourcesLanguageAttribute("en", UltimateResourceFallbackLocation.Satellite)]

namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  public abstract class BaseObject : IExtensibleDataObject
  {
    #region Public Methods
    /// <summary>
    ///    Return the value of the property specified by the given propertyName.
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public object GetValue(string propertyName)
    {
      return GetValue(GetProperty(propertyName));
    }

    public object GetValue(PropertyInfo propInfo)
    {
      return propInfo.GetValue(this, null);
    }

    private static Dictionary<Type, List<PropertyInfo>> m_CachedProperties = new Dictionary<Type, List<PropertyInfo>>();
    public List<PropertyInfo> GetProperties()
    {
      List<PropertyInfo> properties = null;

      Type thisType = GetType();
      lock (m_CachedProperties)
      {
        if (m_CachedProperties.ContainsKey(thisType))
        {
          properties = m_CachedProperties[thisType];
        }
        else
        {
          properties = new List<PropertyInfo>(thisType.GetProperties());
          m_CachedProperties.Add(thisType, properties);
        }
      }

      return properties;
    }

    private static Dictionary<Type, List<PropertyInfo>> m_CachedMTProperties = new Dictionary<Type, List<PropertyInfo>>();
    public List<PropertyInfo> GetMTProperties()
    {
      List<PropertyInfo> properties = new List<PropertyInfo>();
      object[] attributes;

      Type thisType = GetType();
      lock (m_CachedMTProperties)
      {
        if (m_CachedMTProperties.ContainsKey(thisType))
        {
          properties = m_CachedMTProperties[thisType];
        }
        else
        {
          foreach (PropertyInfo propertyInfo in GetType().GetProperties())
          {
            attributes = propertyInfo.GetCustomAttributes(typeof(MTDataMemberAttribute), false);
            if (attributes != null && attributes.Length == 1)
            {
              properties.Add(propertyInfo);
            }
          }

          m_CachedMTProperties.Add(thisType, properties);
        }
      }

      return properties;
    }

    public PropertyInfo GetProperty(string propertyName)
    {
      PropertyInfo retval = null;
      List<PropertyInfo> properties = null;
      Type thisType = GetType();

      properties = GetProperties();

      if (properties != null)
      {
        foreach (PropertyInfo info in properties)
        {
          if (info.Name == propertyName)
          {
            retval = info;
            break;
          }
        }
      }

      return retval;
    }

    /// <summary>
    ///    SetValue
    /// </summary>
    /// <param name="pi"></param>
    /// <param name="value"></param>
    public void SetValue(PropertyInfo pi, object value)
    {
      // Check if this is a nullable type.
      Type type = pi.PropertyType;
      if (type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
      {
        NullableConverter nc = new NullableConverter(pi.PropertyType);
        type = nc.UnderlyingType;
      }

      // ESR-3393 add "try/catch" block to catch required properties that are not set  
      try
      {
          // Process conversions.
          if (value is DBNull)
          {
              pi.SetValue(this, null, null);
          }
          else if (type == typeof(Boolean))
          {
              pi.SetValue(this, CommonEnumHelper.StringToBool(value.ToString()), null);
          }
          else if (type.BaseType == typeof(Enum))
          {
              if (value.GetType().IsEnum)
              {
                  pi.SetValue(this, value, null);
              }
              else
              {
                  pi.SetValue(this, CommonEnumHelper.GetEnumByValue(type.UnderlyingSystemType, value.ToString()), null);
              }
          }
          else
              pi.SetValue(this, value, null);  
      } 
      catch (Exception ex)
      {
           throw new ApplicationException(string.Format("Error in SetValue for pi.Name : '{0}' ",pi.Name, ex));
      }
    }

    /// <summary>
    ///    SetValue
    /// </summary>
    /// <param name="propertyName"></param>
    /// <param name="value"></param>
    public void SetValue(string propertyName, object value)
    {
      PropertyInfo propertyInfo = GetProperty(propertyName);
      if (propertyInfo == null)
      {
        throw new ApplicationException("Property not found on account type");
      }

      SetValue(propertyInfo, value);
    }

    /// <summary>
    ///   Return the display name for the given enumInstance
    /// </summary>
    /// <param name="enumInstance"></param>
    /// <returns></returns>
    public static string GetDisplayName(object enumInstance)
    {
      string displayName = String.Empty;
      if (enumInstance == null)
      {
        return displayName;
      }

      object[] attributes = enumInstance.GetType().GetCustomAttributes(typeof(MTEnumLocalizationAttribute), false);
      if (attributes != null && attributes.Length > 0)
      {
        MTEnumLocalizationAttribute attribute = attributes[0] as MTEnumLocalizationAttribute;
        Debug.Assert(attribute != null);

        if (attribute.ResourceIds != null && attribute.ResourceIds.Length > 0)
        {
          int enumValue = (int)enumInstance;
          string key = attribute.ResourceIds[enumValue];
          displayName = ResourceManager.GetString(key);
        }
      }

      return displayName;
    }

    /// <summary>
    ///   Return the enum for the given enumType which matches the given displayName.
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="displayName"></param>
    /// <returns></returns>
    public static object GetEnumInstanceByDisplayName(Type enumType, object displayName)
    {
      object enumInstance = null;

      string localizedName = displayName as string;

      if (localizedName == null)
      {
        return enumInstance;
      }

      object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumLocalizationAttribute), false);
      if (attributes != null && attributes.Length > 0)
      {
        MTEnumLocalizationAttribute attribute = attributes[0] as MTEnumLocalizationAttribute;
        Debug.Assert(attribute != null);

        if (attribute.ResourceIds != null && attribute.ResourceIds.Length > 0)
        {
          for (int i = 0; i < attribute.ResourceIds.Length; i++)
          {
            if (localizedName == ResourceManager.GetString(attribute.ResourceIds[i]))
            {
              enumInstance = Enum.ToObject(enumType, i);
              break;
            }
          }
        }
      }

      return enumInstance;
    }

    /// <summary>
    ///   Return a list of EnumData objects for the given enumType.
    /// </summary>
    /// <param name="enumType"></param>
    /// <returns></returns>
    public static List<EnumData> GetEnumData(Type enumType)
    {
      return GetEnumDataInternal(enumType, null);
    }

    /// <summary>
    ///   Return a list of EnumData objects for the given enumInstance.
    /// </summary>
    /// <param name="enumInstance"></param>
    /// <returns></returns>
    public static List<EnumData> GetEnumData(object enumInstance)
    {
      return GetEnumDataInternal(enumInstance.GetType(), enumInstance);
    }

    public bool IsDirty(PropertyInfo pi)
    {
      PropertyInfo dirtyProperty = GetProperty("Is" + pi.Name + "Dirty");
      if (dirtyProperty == null)
      {
        throw new Exception("Missing dirty property: " + GetType().Name + "." + pi.Name);
      }

      return (bool)dirtyProperty.GetValue(this, null);
    }

    /// <summary>
    ///   Return true if the property with the given name has its dirty flag set to true.
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public bool IsDirty(string propertyName)
    {
      bool dirty = false;

      PropertyInfo propertyInfo = GetProperty("Is" + propertyName + "Dirty");

      if (propertyInfo != null)
      {
        dirty = (bool)propertyInfo.GetValue(this, null);
      }

      return dirty;
    }

    public bool IsDirtyProperty(PropertyInfo pi)
    {
      bool isDirtyProperty = false;

      if (pi.Name.StartsWith("Is") && pi.Name.EndsWith("Dirty") && pi.PropertyType == typeof(bool))
      {
        isDirtyProperty = true;
      }

      return isDirtyProperty;
    }

    public void ResetDirtyFlag()
    {
      List<FieldInfo> fieldInfos = new List<FieldInfo>();
      Type t = GetType();
      fieldInfos.AddRange(t.GetFields(BindingFlags.Instance | BindingFlags.NonPublic));
      while (t != null)
      {
        fieldInfos.AddRange(t.GetFields(BindingFlags.Instance | BindingFlags.NonPublic));
        t = t.BaseType;
      }

      foreach (FieldInfo fieldInfo in fieldInfos)
      {
        if (fieldInfo.Name.StartsWith("is") && fieldInfo.Name.EndsWith("Dirty") && fieldInfo.FieldType == typeof(bool))
        {
          fieldInfo.SetValue(this, false);
        }
      }
    }

    public static Assembly GetAssembly(string assemblyName)
    {
        Assembly assembly;
        try
        {
            assembly = Assembly.Load(assemblyName);
        }
        catch (Exception)
        {
            // For the webapp, AppDomain.CurrentDomain.BaseDirectory will be one level higher than
            // the bin directory
            if (!assemblyName.EndsWith(".dll", true, null))
            {
                assemblyName = assemblyName + ".dll";
            }

            string[] files =
              Directory.GetFiles(AppDomain.CurrentDomain.BaseDirectory, assemblyName, SearchOption.AllDirectories);

            if (files == null || files.Length == 0)
            {
                throw new ApplicationException(string.Format("Unable to find assembly '{0}' in BaseDirectory : {1}", assemblyName, AppDomain.CurrentDomain.BaseDirectory));
            }

            string fileNameWithPath = files[0];

            try
            {
                string mtTempDir = Path.Combine(Path.GetTempPath(), "MTCodeGeneration");
                if (!Directory.Exists(mtTempDir))
                {
                    Directory.CreateDirectory(mtTempDir);
                }

                string tempAssemblyPath = Path.Combine(mtTempDir, Path.GetFileName(fileNameWithPath));

                if (!File.Exists(tempAssemblyPath))
                {
                    File.Copy(fileNameWithPath, tempAssemblyPath, true);
                }
                else
                {
                    // File exists. If the file time has changed, then copy the file
                    // to a guid based directory and load it from there.
                    DateTime originalFileTime = File.GetLastWriteTime(fileNameWithPath);
                    DateTime tempFileTime = File.GetLastWriteTime(tempAssemblyPath);

                    if (originalFileTime > tempFileTime)
                    {
                        DirectoryInfo dirInfo = Directory.CreateDirectory(Path.Combine(mtTempDir, Guid.NewGuid().ToString()));
                        tempAssemblyPath = Path.Combine(dirInfo.FullName, Path.GetFileName(fileNameWithPath));
                        File.Copy(fileNameWithPath, tempAssemblyPath, true);
                    }
                }

                assembly = Assembly.LoadFrom(tempAssemblyPath);
            }
            catch (Exception e)
            {
                //logger.LogException("Unable to load assembly 'MetraTech.DomainModel.BaseTypes.Generated.dll' from BaseDirectory : " + AppDomain.CurrentDomain.BaseDirectory, e);
                throw new ApplicationException(string.Format("Unable to load assembly '{0}' from BaseDirectory : {1}", assemblyName, AppDomain.CurrentDomain.BaseDirectory), e);
            }
        }

        return assembly;
    }

    public static Type[] GetTypesFromAssemblyByAttribute(string assemblyName, Type attributeType)
    {
        List<Type> types = new List<Type>();

        Assembly assembly = GetAssembly(assemblyName);

        if (assembly != null)
        {
            foreach (Type type in assembly.GetTypes())
            {
                object[] attributes = type.GetCustomAttributes(attributeType, false);
                if (attributes != null && attributes.Length > 0)
                {
                    types.Add(type);
                }
            }
        }

        return types.ToArray();
    }
    #endregion

    #region Properties
    /// <summary>
    ///   Returns the cached ResourceManager instance used by this class.
    /// </summary>
    protected static ResourceManager ResourceManager
    {
      get
      {
        return resourceManager;
      }
    }
    #endregion

    #region Protected Methods
    protected void SetDirtyFlag(PropertyInfo pi)
    {
        FieldInfo fi = GetType().GetField("is" + pi.Name + "Dirty", BindingFlags.NonPublic | BindingFlags.Instance);

        if (fi == null)
        {
            throw new Exception("Missing dirty field: " + GetType().Name + "." + pi.Name);
        }

        fi.SetValue(this, true);
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// 
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="enumInstance"></param>
    /// <returns></returns>
    private static List<EnumData> GetEnumDataInternal(Type enumType,
                                                      object enumInstance)
    {
      List<EnumData> enums = new List<EnumData>();
      EnumData enumData = null;

      object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumLocalizationAttribute), false);
      if (attributes != null && attributes.Length > 0)
      {
        MTEnumLocalizationAttribute attribute = attributes[0] as MTEnumLocalizationAttribute;
        Debug.Assert(attribute != null);
        string displayName = String.Empty;

        if (attribute.ResourceIds != null && attribute.ResourceIds.Length > 0)
        {
          for (int i = 0; i < attribute.ResourceIds.Length; i++)
          {
            displayName = ResourceManager.GetString(attribute.ResourceIds[i]);
            if (String.IsNullOrEmpty(displayName))
            {
              continue;
            }
            enumData = new EnumData();
            enumData.DisplayName = displayName;
            // Enums are generated with zero based integer values
            enumData.EnumInstance = Enum.ToObject(enumType, i);

            if (enumInstance != null)
            {
              if (enumInstance.ToString() == enumData.EnumInstance.ToString())
              {
                enumData.Selected = true;
              }
            }

            enums.Add(enumData);
          }
        }

      }
      else
      {
        foreach (string s in Enum.GetNames(enumType))
        {
          enumData = new EnumData();
          enumData.DisplayName = s;
          enumData.EnumInstance = Enum.ToObject(enumType, Enum.Parse(enumType, s));

          if (enumInstance != null)
          {
            if (enumInstance.ToString() == enumData.EnumInstance.ToString())
            {
              enumData.Selected = true;
            }
          }

          enums.Add(enumData);
        }
      }

      return enums;
    }
    #endregion

    #region Data
    private static readonly ResourceManager resourceManager = 
      new ResourceManager("MetraTech.DomainModel", Assembly.GetExecutingAssembly());

    [NonSerialized]
    [ScriptIgnore]
    ExtensionDataObject m_ExtensionData;

    [NonSerialized]
    protected const string PRODUCT_CATALOG_GENERATED_ASSEMBLY = "MetraTech.DomainModel.ProductCatalog.Generated";
    [NonSerialized]
    protected const string GENERATED_ACCOUNT_ASSEMBLY = "MetraTech.DomainModel.AccountTypes.Generated";

    #endregion

    #region IExtensibleDataObject Members

    public ExtensionDataObject ExtensionData
    {
      get
      {
        return m_ExtensionData;
      }
      set
      {
        m_ExtensionData = value;
      }
    }

    #endregion
  }

  public class EnumData
  {
    private string displayName;
    public string DisplayName
    {
      get { return displayName; }
      set { displayName = value; }
    }

    private object enumInstance;
    public object EnumInstance
    {
      get { return enumInstance; }
      set { enumInstance = value; }
    }

    private bool selected;
    public bool Selected
    {
      get { return selected; }
      set { selected = value; }
    }
  }
}

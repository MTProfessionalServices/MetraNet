using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Common;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract(IsReference = true)]
  [Serializable]
  public class PropertyInstance
  {
    #region Constructor
    public PropertyInstance(string name, string assemblyQualifiedTypeName, bool isBusinessKey)
    {
      string assemblyName;
      propertyType = Property.GetPropertyType(assemblyQualifiedTypeName, out typeName, out assemblyName);
      this.assemblyQualifiedTypeName = assemblyQualifiedTypeName;
      this.isBusinessKey = isBusinessKey;
      Name = name;
    }

    public PropertyInstance(string name, string assemblyQualifiedTypeName, bool isBusinessKey, object value)
    {
      string assemblyName;
      propertyType = Property.GetPropertyType(assemblyQualifiedTypeName, out typeName, out assemblyName);
      this.assemblyQualifiedTypeName = assemblyQualifiedTypeName;
      this.isBusinessKey = isBusinessKey;
      Name = name;
      Value = value;
    }

    #endregion

    #region Properties
    [DataMember]
    public string Name { get; set; }

    [DataMember(Name = "TypeName")] 
    private string typeName;
    public string TypeName 
    { 
      get
      {
        return typeName;
      }
    }

    [DataMember(Name = "AssemblyQualifiedTypeName")]
    private string assemblyQualifiedTypeName;
    public string AssemblyQualifiedTypeName
    {
      get
      {
        return assemblyQualifiedTypeName;
      }
    }

    [DataMember(Name = "PropertyType")]
    private PropertyType propertyType;
    public PropertyType PropertyType
    {
      get
      {
        return propertyType;
      }
    }

    [DataMember(Name = "IsBusinessKey")]
    private bool isBusinessKey;
    public bool IsBusinessKey
    {
      get
      {
        return isBusinessKey;
      }
      set
      {
        isBusinessKey = value;
      }
    }

    [DataMember(Name = "IsCompound")]
    private bool isCompound;
    public bool IsCompound
    {
      get
      {
        return isCompound;
      }
      set
      {
        isCompound = value;
      }
    }

    [DataMember(Name = "IsLegacyPrimaryKey")]
    private bool isLegacyPrimaryKey;
    public bool IsLegacyPrimaryKey
    {
      get
      {
        return isLegacyPrimaryKey;
      }
      set
      {
        isLegacyPrimaryKey = value;
      }
    }

    public Type Type
    {
      get
      {
        return System.Type.GetType(assemblyQualifiedTypeName); 
      }
    }
  
    private object propertyValue;
    [DataMember]
    public object Value
    {
      get { return propertyValue; }
      set
      {
        if (value != null && value.GetType().FullName != TypeName)
        {
          propertyValue = StringUtil.ChangeType(value, Type);
        }
        else
        {
        propertyValue = value;
      }
    }
    }

    #endregion

    #region Public Methods
    public override string ToString()
    {
      return String.Format("Name = '{0}' : Type = '{1}' : Value = '{2}'", Name, TypeName, Value);
    }

    public void Validate()
    {
      Check.Ensure(!String.IsNullOrEmpty(TypeName), "TypeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(AssemblyQualifiedTypeName), "AssemblyQualifiedTypeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Ensure(!String.IsNullOrEmpty(Name), "Name cannot be null or empty", SystemConfig.CallerInfo);
    }

    #endregion
  }
}

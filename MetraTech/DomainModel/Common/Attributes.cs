using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.DomainModel.Common
{
  [AttributeUsage(AttributeTargets.Property, Inherited = false)]
  public sealed class MTDataMemberAttribute : Attribute
  {
    private bool isRequired = false;
    public bool IsRequired
    {
      get { return isRequired; }
      set { isRequired = value; }
    }

    private string description;
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    private int length;
    public int Length
    {
      get { return length; }
      set { length = value; }
    }

    private bool isOut = false;
    public bool IsOut
    {
      get { return isOut; }
      set { isOut = value; }
    }

    private bool isInOut = false;
    public bool IsInOut
    {
      get { return isInOut; }
      set { isInOut = value; }
    }

    private string viewType;
    public string ViewType
    {
      get { return viewType; }
      set { viewType = value; }
    }

    private bool isListView = false;
    public bool IsListView
    {
      get { return isListView; }
      set { isListView = value; }
    }

    private string className;
    public string ClassName
    {
      get { return className; }
      set { className = value; }
    }

    private bool hasDefault = false;
    public bool HasDefault
    {
      get { return hasDefault; }
      set { hasDefault = value; }
    }

    private bool isPartOfKey = false;
    public bool IsPartOfKey
    {
      get { return isPartOfKey; }
      set { isPartOfKey = value; }
    }

    private string viewName;
    public string ViewName
    {
      get { return viewName; }
      set { viewName = value; }
    }

    private bool isInputOnly = false;
    public bool IsInputOnly
    {
      get { return isInputOnly; }
      set { isInputOnly = value; }
    }

    private string msixType;
    public string MsixType
    {
      get { return msixType; }
      set { msixType = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTDataMemberAttribute";
  }

  [AttributeUsage(AttributeTargets.Enum)]
  public sealed class MTEnumAttribute : Attribute
  {
    
    private string description;
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    private string[] oldEnumValues;
    public string[] OldEnumValues
    {
      get { return oldEnumValues; }
      set { oldEnumValues = value; }
    }

    private bool storedAsInt = true;
    public bool StoredAsInt
    {
      get { return storedAsInt; }
      set { storedAsInt = value; }
    }
    private string enumSpace;
    public string EnumSpace
    {
      get { return enumSpace; }
      set { enumSpace = value; }
    }
    private string enumName;
    public string EnumName
    {
      get { return enumName; }
      set { enumName = value; }
    }

    private string[] keys;
    public string[] Keys
    {
      get { return keys; }
      set { keys = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTEnumAttribute";
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTViewAttribute : Attribute
  {
    private string viewType;
    public string ViewType
    {
      get { return viewType; }
      set { viewType = value; }
    }

    private string extension;
    public string Extension
    {
      get { return extension; }
      set { extension = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTViewAttribute";
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTAccountAttribute : Attribute
  {
    private string extension;
    public string Extension
    {
      get { return extension; }
      set { extension = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTAccountAttribute";
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTPriceableItemInstanceAttribute : Attribute
  {
      public string PIType { get; set; }
      public const string QualifiedName = "MetraTech.DomainModel.Common.MTPriceableItemInstanceAttribute";
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTPriceableItemTemplateAttribute : Attribute
  {
      public string PIType { get; set; }
      public const string QualifiedName = "MetraTech.DomainModel.Common.MTPriceableItemTemplateAttribute";
  }

  [AttributeUsage(AttributeTargets.Enum)]
  public sealed class MTEnumLocalizationAttribute : Attribute
  {
    private string localeSpace;
    public string LocaleSpace
    {
      get { return localeSpace; }
      set { localeSpace = value; }
    }

    private string extension;
    public string Extension
    {
      get { return extension; }
      set { extension = value; }
    }

    // Used by Enums
    private string[] resourceIds;
    public string[] ResourceIds
    {
      get { return resourceIds; }
      set { resourceIds = value; }
    }

    // Used by Enums
    private string[] mtLocalizationIds;
    public string[] MTLocalizationIds
    {
      get { return mtLocalizationIds; }
      set { mtLocalizationIds = value; }
    }

    private string[] defaultValues;
    public string[] DefaultValues
    {
      get { return defaultValues; }
      set { defaultValues = value; }
    }

    private string[] localizationFiles;
    public string[] LocalizationFiles
    {
      get { return localizationFiles; }
      set { localizationFiles = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTEnumLocalizationAttribute";
  }

  [AttributeUsage(AttributeTargets.Property)]
  public sealed class MTPropertyLocalizationAttribute : Attribute
  {
    private string localeSpace;
    public string LocaleSpace
    {
      get { return localeSpace; }
      set { localeSpace = value; }
    }

    private string extension;
    public string Extension
    {
      get { return extension; }
      set { extension = value; }
    }

    private string resourceId;
    public string ResourceId
    {
      get { return resourceId; }
      set { resourceId = value; }
    }

    private string mtLocalizationId;
    public string MTLocalizationId
    {
      get { return mtLocalizationId; }
      set { mtLocalizationId = value; }
    }

    private string defaultValue;
    public string DefaultValue
    {
      get { return defaultValue; }
      set { defaultValue = value; }
    }

    private string[] localizationFiles;
    public string[] LocalizationFiles
    {
      get { return localizationFiles; }
      set { localizationFiles = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTPropertyLocalizationAttribute";
  }

  [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
  public sealed class MTDirtyPropertyAttribute : Attribute
  {
    public MTDirtyPropertyAttribute(string propertyName)
    {
      PropertyName = propertyName;
    }

    private string propertyName;
    public string PropertyName
    {
      get { return propertyName; }
      set { propertyName = value; }
    }

    public const string QualifiedName = "MetraTech.DomainModel.Common.MTDirtyPropertyAttribute";
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class CounterTypeMetadataAttribute : Attribute
  {

      public string Name
      {

          get
          {
              return m_Name;
          }
          set
          {
              m_Name = value;
          }

      }

      public string Description
      {
          get
          {
              return m_Description;
          }
          set
          {
              m_Description = value;
          }
      }

      public bool ValidForDistribution
      {
          get
          {
              return m_ValidForDistribution;
          }
          set
          {
              m_ValidForDistribution = value;
          }
      }


      private string m_Name;
      private string m_Description;
      private bool m_ValidForDistribution;
  }

  [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
  public sealed class CounterParamMetadataAttribute : Attribute
  {

      public string Kind 
      { 
          get
          { 
              return m_Kind; 
          }
          set
          {
              m_Kind = value;
          }
      }

      public string DBType 
      { 
          get 
          { 
              return m_DBType; 
          }
          set
          {
              m_DBType = value;
          }
      }

      string m_Kind;
      string m_DBType;
  }

  [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
  public sealed class CounterPropertyDefinitionAttribute : Attribute
  {
      public string Name
      {
          get
          {
              return m_Name;
          }
          set
          {
              m_Name = value;
          }
      }

      public string DisplayName
      {
          get
          {
              return m_DisplayName;
          }
          set
          {
              m_DisplayName = value;
          }
      }

      public string ServiceProperty
      {
          get
          {
              return m_ServiceProperty;
          }
          set
          {
              m_ServiceProperty = value;
          }
      }

      string m_Name;
      string m_DisplayName;
      string m_ServiceProperty;
  }

  [AttributeUsage(AttributeTargets.Property)]
  public sealed class MTAdjustmentTypeAttribute : Attribute
  {
      public string Type { get; set; }
  }


  [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
  public sealed class MTExtendedPropertyAttribute : Attribute
  {
      public string ColumnName { get; set; }
      public string TableName { get; set; }
  }

  [AttributeUsage(AttributeTargets.Property)]
  public sealed class MTRateSchedulesPropertyAttribute : Attribute
  {
      public string ParameterTable { get; set; }
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTRateEntryAttribute : Attribute
  {
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTDefaultRateEntryAttribute : Attribute
  {
  }

  [AttributeUsage(AttributeTargets.Class)]
  public sealed class MTProductViewAttribute : Attribute
  {
      public string ViewName { get; set; }
  }

  [AttributeUsage(AttributeTargets.Property)]
  public sealed class MTRateEntryMetadataAttribute : Attribute
  {
      public MTRateEntryMetadataAttribute()
      {
          IsAction = false;
          IsCondition = false;
          Filterable = false;
      }

      public bool IsAction { get; set; }
      public bool IsCondition { get; set; }
      public bool IsOperator { get; set; }
      public bool OperatorPerRule { get; set; }
      public bool Filterable { get; set; }
      public string ColumnName { get; set; }
      public string DataType { get; set; }
      public int Length { get; set; }
  }

  [AttributeUsage(AttributeTargets.Property)]
  public sealed class MTProductViewMetadataAttribute : Attribute
  {
      public MTProductViewMetadataAttribute()
      {
          Filterable = false;
          UserVisible = false;
          Exportable = false;
      }

      public bool Filterable { get; set; }
      public bool UserVisible { get; set; }
      public bool Exportable { get; set; }
      public string ColumnName { get; set; }
      public string DataType { get; set; }
      public int Length { get; set; }
  }
}

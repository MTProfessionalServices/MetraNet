using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
  /// <summary>
  /// This is the domain object representing the SpecificationCharacteristic.
  /// </summary>
  [DataContract]
  [Serializable]
  public class SpecificationCharacteristic : BaseObject
  {
    #region ID
    private bool isIDDirty = true;
    private int? m_ID;
    [MTDataMember(Description = "This is the identifier of the product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? ID
    {
      get { return m_ID; }
      set
      {

        m_ID = value;
        isIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDDirty
    {
      get { return isIDDirty; }
    }
    #endregion

    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Name
    {
      get { return m_Name; }
      set
      {
        m_Name = value;
        isNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNameDirty
    {
      get { return isNameDirty; }
    }
    #endregion

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "This is the Description of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Description
    {
      get { return m_Description; }
      set
      {
        m_Description = value;
        isDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDescriptionDirty
    {
      get { return isDescriptionDirty; }
    }
    #endregion

    #region Category
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCategoryDirty = false;
    private string m_Category;
    [MTDataMember(Description = "This is the Category of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Category
    {
      get { return m_Category; }
      set
      {
        m_Category = value;
        isCategoryDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCategoryDirty
    {
      get { return isCategoryDirty; }
    }
    #endregion

    #region CategoryDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCategoryDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_CategoryDisplayNames = null;
    [MTDataMember(Description = "This is a collection of localized display names for the category of the specification chracteristic. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> CategoryDisplayNames
    {
      get { return m_CategoryDisplayNames; }
      set
      {
        m_CategoryDisplayNames = value;
        isCategoryDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCategoryDisplayNamesDirty
    {
      get { return isCategoryDisplayNamesDirty; }
    }
    #endregion

    #region SpecType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSpecTypeDirty = false;
    private MetraTech.DomainModel.Enums.Core.Global.PropertyType m_SpecType;
    [MTDataMember(Description = "This is the SpecType of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MetraTech.DomainModel.Enums.Core.Global.PropertyType SpecType
    {
      get { return m_SpecType; }
      set
      {
          m_SpecType = value;
          isSpecTypeDirty = true;
      }
    }
	  [ScriptIgnore]
    public bool IsSpecTypeDirty
    {
      get { return isSpecTypeDirty; }
    }
    #endregion
  
    #region IsRequired
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsRequiredDirty = false;
    private bool m_IsRequired;
    [MTDataMember(Description = "This is if the specification chracteristic is required on the entity or not.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool IsRequired
    {
      get { return m_IsRequired; }
      set
      {
        m_IsRequired = value;
        isIsRequiredDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIsRequiredDirty
    {
      get { return isIsRequiredDirty; }
    }
    #endregion

    #region DisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDisplayNameDirty = false;
    private string m_DisplayName;
    [MTDataMember(Description = "This is the display name of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DisplayName
    {
      get { return m_DisplayName; }
      set
      {
        m_DisplayName = value;
        isDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDisplayNameDirty
    {
      get { return isDisplayNameDirty; }
    }
    #endregion

    #region LocalizedDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDisplayNames = null;
    [MTDataMember(Description = "This is a collection of localized display names for the specification chracteristic. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDisplayNames
    {
      get { return m_LocalizedDisplayNames; }
      set
      {
        m_LocalizedDisplayNames = value;
        isLocalizedDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDisplayNamesDirty
    {
      get { return isLocalizedDisplayNamesDirty; }
    }
    #endregion

    #region LocalizedDescriptions
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDescriptionsDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDescriptions = null;
    [MTDataMember(Description = "This is a collection of localized descriptions for the specification characteristic.  The collection is keyed by values from the LanguageCode enumeration.  If a value cannot be found for a specific LanguageCode, the value from the Description property should be used as a default.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDescriptions
    {
      get { return m_LocalizedDescriptions; }
      set
      {
        m_LocalizedDescriptions = value;
        isLocalizedDescriptionsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDescriptionsDirty
    {
      get { return isLocalizedDescriptionsDirty; }
    }
    #endregion

    #region SpecCharacteristicValues
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSpecCharacteristicValuesDirty = false;
    private List<SpecCharacteristicValue> m_SpecCharacteristicValues = new List<SpecCharacteristicValue>();
    [MTDataMember(Description = "This is the collection of SpecCharacteristicValues associated with the specification chracteristic", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<SpecCharacteristicValue> SpecCharacteristicValues
    {
      get
      {
        if (m_SpecCharacteristicValues == null)
        {
          m_SpecCharacteristicValues = new List<SpecCharacteristicValue>();
        }

        return m_SpecCharacteristicValues;
      }
      set
      {

        m_SpecCharacteristicValues = value;
        isSpecCharacteristicValuesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSpecCharacteristicValuesDirty
    {
      get { return isSpecCharacteristicValuesDirty; }
    }
    #endregion

    #region DisplayOrder
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDisplayOrderDirty = false;
    private int? m_DisplayOrder;
    [MTDataMember(Description = "Display order of the property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? DisplayOrder
    {
      get { return m_DisplayOrder; }
      set
      {
        m_DisplayOrder = value;
        isDisplayOrderDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDisplayOrderDirty
    {
      get { return isDisplayOrderDirty; }
    }
    #endregion

    #region UserVisible
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUserVisibleDirty = false;
    private bool m_UserVisible;
    [MTDataMember(Description = "This attribute determines if the specification characteristic is user visible.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool UserVisible
    {
      get { return m_UserVisible; }
      set
      {
        m_UserVisible = value;
        isUserVisibleDirty = true;
      }
}
    [ScriptIgnore]
    public bool IsUserVisibleDirty
    {
      get { return isUserVisibleDirty; }
    }
    #endregion

    #region UserEditable
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUserEditableDirty = false;
    private bool m_UserEditable;
    [MTDataMember(Description = "This attribute determines if the specification characteristic is user editable.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool UserEditable
    {
      get { return m_UserEditable; }
      set
      {
        m_UserEditable = value;
        isUserEditableDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUserEditableDirty
    {
      get { return isUserEditableDirty; }
    }
    #endregion

    #region StartDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartDateDirty = false;
    private DateTime m_StartDate;
    [MTDataMember(Description = "This attribute determines the start date of the spec.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime StartDate
    {
      get { return m_StartDate; }
      set
      {
        m_StartDate = value;
        isStartDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartDateDirty
    {
      get { return isStartDateDirty; }
    }
    #endregion

    #region EndDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEndDateDirty = false;
    private DateTime m_EndDate;
    [MTDataMember(Description = "This attribute determines the end date of the spec.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime EndDate
    {
      get { return m_EndDate; }
      set
      {
        m_EndDate = value;
        isEndDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEndDateDirty
    {
      get { return isEndDateDirty; }
    }
    #endregion

    #region MinValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMinValueDirty = false;
    private string m_MinValue;
    [MTDataMember(Description = "This is the MinValue of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string MinValue
    {
      get { return m_MinValue; }
      set
      {
        m_MinValue = value;
        isMinValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMinValueDirty
    {
      get { return isMinValueDirty; }
    }
    #endregion

    #region MaxValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMaxValueDirty = false;
    private string m_MaxValue;
    [MTDataMember(Description = "This is the MaxValue of the specification chracteristic.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string MaxValue
    {
      get { return m_MaxValue; }
      set
      {
        m_MaxValue = value;
        isMaxValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMaxValueDirty
    {
      get { return isMaxValueDirty; }
    }
    #endregion
  }
}

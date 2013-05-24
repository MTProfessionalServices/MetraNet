using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraTech.DomainModel.ProductCatalog
{
  /// <summary>
  /// CharacteristicValue is the instantiated value of the SpecCharacteristicValue in the system
  /// </summary>
  [DataContract]
  [Serializable]
  public class CharacteristicValue : BaseObject
  {
    #region SpecCharValId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSpecCharValIdDirty = false;
    private int? m_SpecCharValId;
    [MTDataMember(Description = "This is the id of the spec characteristic", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? SpecCharValId
    {
      get { return m_SpecCharValId; }
      set
      {

        m_SpecCharValId = value;
        isSpecCharValIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSpecCharValIdDirty
    {
      get { return isSpecCharValIdDirty; }
    }
    #endregion

    #region EntityId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEntityIdDirty = false;
    private int m_EntityId;
    [MTDataMember(Description = "This is the id of the spec characteristic", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int EntityId
    {
      get { return m_EntityId; }
      set
      {

        m_EntityId = value;
        isEntityIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEntityIdDirty
    {
      get { return isEntityIdDirty; }
    }
    #endregion

    #region Value
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isValueDirty = false;
    private string m_Value;
    [MTDataMember(Description = "This is the instantiated value of the spec char value.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Value
    {
      get { return m_Value; }
      set
      {
        m_Value = value;
        isValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsValueDirty
    {
      get { return isValueDirty; }
    }
    #endregion

    #region LocalizedDisplayValues
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDisplayValuesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDisplayValues = null;
    [MTDataMember(Description = "This is a collection of localized display names for the characteristic value. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDisplayValues
    {
      get { return m_LocalizedDisplayValues; }
      set
      {
        m_LocalizedDisplayValues = value;
        isLocalizedDisplayValuesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDisplayValuesDirty
    {
      get { return isLocalizedDisplayValuesDirty; }
    }
    #endregion

    #region StartDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartDateDirty = false;
    private DateTime m_StartDate;
    [MTDataMember(Description = "The StartDate of the value ", Length = 40)]
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
    [MTDataMember(Description = "The EndDate of the value ", Length = 40)]
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

    #region SpecName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSpecNameDirty = false;
    private string m_SpecName;
    [MTDataMember(Description = "This is the name of the specification characteristic that this value belongs to.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string SpecName
    {
      get { return m_SpecName; }
      set
      {
        m_SpecName = value;
        isSpecNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSpecNameDirty
    {
      get { return isSpecNameDirty; }
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
  }
}

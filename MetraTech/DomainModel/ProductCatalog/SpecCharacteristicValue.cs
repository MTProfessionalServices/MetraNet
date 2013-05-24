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
  /// This is a domain object representing the spec characteristic value
  /// </summary>
  [DataContract]
  [Serializable]
  public class SpecCharacteristicValue : BaseObject
  {

    #region ID
    private bool isIDDirty = true;
    private int? m_ID;
    [MTDataMember(Description = "This is the identifier of the specification characteristic value.", Length = 40)]
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

    #region IsDefault
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsDefaultDirty = false;
    private bool m_IsDefault;
    [MTDataMember(Description = "This is if this the default spec characteristic value.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool IsDefault
    {
      get { return m_IsDefault; }
      set
      {
        m_IsDefault = value;
        isIsDefaultDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIsDefaultDirty
    {
      get { return isIsDefaultDirty; }
    }
    #endregion

    #region Value
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isValueDirty = false;
    private string m_Value;
    [MTDataMember(Description = "This is describes the spec characteristic value.", Length = 40)]
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

    #region ValueID
    private bool isValueIDDirty = true;
    private int m_ValueID;
    [MTDataMember(Description = "This is the id of the specification characteristic value description.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int ValueID
    {
      get { return m_ValueID; }
      set
      {

        m_ValueID = value;
        isValueIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsValueIDDirty
    {
      get { return isValueIDDirty; }
    }
    #endregion

    #region LocalizedDisplayValues
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDisplayValuesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDisplayValues = null;
    [MTDataMember(Description = "This is a collection of localized display names for the spec characteristic value. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
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

  }
}

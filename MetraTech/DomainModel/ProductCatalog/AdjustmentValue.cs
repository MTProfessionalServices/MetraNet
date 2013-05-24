using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class AdjustmentValue : BaseObject
    {

        #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the property to be used as an input or an output.", Length = 40)]
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

        #region DisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDisplayNameDirty = false;
    private string m_DisplayName;
    [MTDataMember(Description = "This is the display name for the adjustment Value property.", Length = 40)]
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
    [MTDataMember(Description = "This is a collection of localized display names for the Adjustment Value. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
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

        #region DataType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDataTypeDirty = false;
    private string m_DataType;
    [MTDataMember(Description = "This property specifies the data type of the adjustment value property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DataType
    {
      get { return m_DataType; }
      set
      {
          m_DataType = value;
          isDataTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDataTypeDirty
    {
      get { return isDataTypeDirty; }
    }
    #endregion

    }
}

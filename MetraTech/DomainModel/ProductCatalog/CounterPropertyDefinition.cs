using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class CounterPropertyDefinition : BaseObject
    {

        #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the counter property definition.", Length = 40)]
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
    [MTDataMember(Description = "This is the display name for the counter property definition.", Length = 40)]
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
    [MTDataMember(Description = "This is a collection of localized display names for the counter property definition. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
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

        #region ServiceProperty
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isServicePropertyDirty = false;
    private string m_ServiceProperty;
    [MTDataMember(Description = "This is the name of the property from the service definition into which the counter value is placed.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ServiceProperty
    {
      get { return m_ServiceProperty; }
      set
      {
          m_ServiceProperty = value;
          isServicePropertyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsServicePropertyDirty
    {
      get { return isServicePropertyDirty; }
    }
    #endregion

        #region PreferredCounterTypeName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPreferredCounterTypeNameDirty = false;
    private string m_PreferredCounterTypeName;
    [MTDataMember(Description = "This specifies the preferred method for calculating the counter property value during execution. This can be overridden at the priceable item template and priceable item instance levels.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PreferredCounterTypeName
    {
      get { return m_PreferredCounterTypeName; }
      set
      {
          m_PreferredCounterTypeName = value;
          isPreferredCounterTypeNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPreferredCounterTypeNameDirty
    {
      get { return isPreferredCounterTypeNameDirty; }
    }
    #endregion

    }
}

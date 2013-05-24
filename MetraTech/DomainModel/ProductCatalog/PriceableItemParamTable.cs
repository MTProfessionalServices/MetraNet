using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;
namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]
  public class PriceableItemParamTable : BaseObject
  {

    #region piInstanceID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPiInstanceIDDirty = false;
    private PCIdentifier m_piInstanceID;
    [MTDataMember(Description = "This is the priceable item instance id.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public PCIdentifier piInstanceID
    {
      get { return m_piInstanceID; }
      set
      {

        m_piInstanceID = value;
        isPiInstanceIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPiInstanceIDDirty
    {
      get { return isPiInstanceIDDirty; }
    }
    #endregion

    #region LocalizedPIInstDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedPIInstDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedPIInstDisplayNames = new Dictionary<LanguageCode, string>();
    [MTDataMember(Description = "This will contain a dictionary of the priceable item instance’s localized DisplayNames.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedPIInstDisplayNames
    {
      get 
      {
          if (m_LocalizedPIInstDisplayNames == null)
          {
              m_LocalizedPIInstDisplayNames = new Dictionary<LanguageCode, string>();
          }

          return m_LocalizedPIInstDisplayNames; 
      }
      set
      {
        m_LocalizedPIInstDisplayNames = value;
        isLocalizedPIInstDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedPIInstDisplayNamesDirty
    {
      get { return isLocalizedPIInstDisplayNamesDirty; }
    }
    #endregion

    #region paramTableID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParamTableIDDirty = false;
    private PCIdentifier m_paramTableID;
    [MTDataMember(Description = "This is the id of the parameter table.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public PCIdentifier paramTableID
    {
      get { return m_paramTableID; }
      set
      {

        m_paramTableID = value;
        isParamTableIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParamTableIDDirty
    {
      get { return isParamTableIDDirty; }
    }
    #endregion

    #region LocalizedPTDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedPTDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedPTDisplayNames = new Dictionary<LanguageCode, string>();
    [MTDataMember(Description = "This will contain a dictionary of the parameter table’s localized DisplayNames.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedPTDisplayNames
    {
      get
      {
          if (m_LocalizedPTDisplayNames == null)
          {
              m_LocalizedPTDisplayNames = new Dictionary<LanguageCode, string>();
          }

          return m_LocalizedPTDisplayNames; 
      }
      set
      {
        m_LocalizedPTDisplayNames = value;
        isLocalizedPTDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedPTDisplayNamesDirty
    {
      get { return isLocalizedPTDisplayNamesDirty; }
    }
    #endregion

    #region PersonalRate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPersonalRateDirty = false;
    private bool? m_PersonalRate;
    [MTDataMember(Description = "This Boolean value represents whether an ICB rate exists for this priceable item in this subscription.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? PersonalRate
    {
      get { return m_PersonalRate; }
      set
      {

        m_PersonalRate = value;
        isPersonalRateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPersonalRateDirty
    {
      get { return isPersonalRateDirty; }
    }
    #endregion

    #region CanICB
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanICBDirty = false;
    private bool? m_CanICB;
    [MTDataMember(Description = "This Boolean value represents whether a custom ICB rate exists is allowed for this subscription.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool? CanICB
    {
      get { return m_CanICB; }
      set
      {

        m_CanICB = value;
        isCanICBDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCanICBDirty
    {
      get { return isCanICBDirty; }
    }
    #endregion
  }
}

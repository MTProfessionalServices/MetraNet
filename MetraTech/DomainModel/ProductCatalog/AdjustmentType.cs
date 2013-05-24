using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    public enum CalculationEngineTypes { MTSQL = 1 }
    public enum AdjustmentKinds { Flat = 1, Percent, Minutes, Rebill }

    [DataContract]
    [Serializable]
    public class AdjustmentType : BaseObject
    {

        #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name for the adjustment type. This must be unique across all adjustment types.", Length = 40)]
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
    [MTDataMember(Description = "This is the default description for the adjustment type.", Length = 40)]
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

        #region LocalizedDescriptions
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDescriptionsDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDescriptions = null;
    [MTDataMember(Description = "This stores a collection of localized descriptions for the adjustment type. It is keyed by values from the LanguageCode enumeration.", Length = 40)]
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

        #region DisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDisplayNameDirty = false;
    private string m_DisplayName;
    [MTDataMember(Description = "This is the display name for the adjustment type.", Length = 40)]
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
    [MTDataMember(Description = "This is a collection of localized display names for the Adjustment type. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
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

        #region CalculationEngine
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCalculationEngineDirty = false;
    private CalculationEngineTypes m_CalculationEngine;
    [MTDataMember(Description = "This property stores a values from the calculation engine types enumeration. This specifies the calculation engine type that is used to execute the rule specified in the formula property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalculationEngineTypes CalculationEngine
    {
      get { return m_CalculationEngine; }
      set
      {
          m_CalculationEngine = value;
          isCalculationEngineDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCalculationEngineDirty
    {
      get { return isCalculationEngineDirty; }
    }
    #endregion

        #region Formula
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFormulaDirty = false;
    private string m_Formula;
    [MTDataMember(Description = "This is the formula used to calculate the total outputs of the adjustment based on the inputs. The format of the formula string is dependent on the type of the calculation engine as specified in the CalculationEngineTypes property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Formula
    {
      get { return m_Formula; }
      set
      {
          m_Formula = value;
          isFormulaDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFormulaDirty
    {
      get { return isFormulaDirty; }
    }
    #endregion

        #region SupportsBulk
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSupportsBulkDirty = false;
    private bool m_SupportsBulk;
    [MTDataMember(Description = "This value indicates whether or not the adjustment type supports applying the adjustment to multiple transactions at once or if it must be applied to one transaction at a time.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool SupportsBulk
    {
      get { return m_SupportsBulk; }
      set
      {
          m_SupportsBulk = value;
          isSupportsBulkDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSupportsBulkDirty
    {
      get { return isSupportsBulkDirty; }
    }
    #endregion

        #region AdjustmentKind
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentKindDirty = false;
    private AdjustmentKinds m_AdjustmentKind;
    [MTDataMember(Description = "This property indicates the kind of the adjustment type.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public AdjustmentKinds AdjustmentKind
    {
      get { return m_AdjustmentKind; }
      set
      {
          m_AdjustmentKind = value;
          isAdjustmentKindDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdjustmentKindDirty
    {
      get { return isAdjustmentKindDirty; }
    }
    #endregion

        #region RequiredInputs
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRequiredInputsDirty = false;
    private List<AdjustmentValue> m_RequiredInputs;
    [MTDataMember(Description = "This is a collection of AdjustmentValue instances. These instances define the set of required inputs for the calculation formula. These specify the properties that must be supplied by the end user prior to calcuating the adjustment.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<AdjustmentValue> RequiredInputs
    {
      get { return m_RequiredInputs; }
      set
      {
          m_RequiredInputs = value;
          isRequiredInputsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRequiredInputsDirty
    {
      get { return isRequiredInputsDirty; }
    }
    #endregion
        
        #region Outputs
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOutputsDirty = false;
    private List<AdjustmentValue> m_Outputs;
    [MTDataMember(Description = "This is a collection of AdjustmentValue instances. These instances define the set of outputs from the calculation formula.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<AdjustmentValue> Outputs
    {
      get { return m_Outputs; }
      set
      {
          m_Outputs = value;
          isOutputsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsOutputsDirty
    {
      get { return isOutputsDirty; }
    }
    #endregion

        #region ApplicabilityRuleDefs
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isApplicabilityRuleDefsDirty = false;
    private List<ApplicabilityRuleDef> m_ApplicabilityRuleDefs;
    [MTDataMember(Description = "This is a collection of ApplicabilityRuleDef instances. Each instance stores all the metadata for a given applicability rule associated with the adjustment type.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<ApplicabilityRuleDef> ApplicabilityRuleDefs
    {
      get { return m_ApplicabilityRuleDefs; }
      set
      {
          m_ApplicabilityRuleDefs = value;
          isApplicabilityRuleDefsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsApplicabilityRuleDefsDirty
    {
      get { return isApplicabilityRuleDefsDirty; }
    }
    #endregion


    }
}

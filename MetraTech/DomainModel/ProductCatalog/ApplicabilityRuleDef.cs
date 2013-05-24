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
    public class ApplicabilityRuleDef : BaseObject
    {

        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNameDirty = false;
        private string m_Name;
        [MTDataMember(Description = "This is the name for the applicability rule definition.", Length = 40)]
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
        [MTDataMember(Description = "This is the default description for the applicability rule definition.", Length = 40)]
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
        [MTDataMember(Description = "This stores a collection of localized descriptions for the applicability rule definition. It is keyed by values from the LanguageCode enumeration.", Length = 40)]
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
        [MTDataMember(Description = "This is the display name for the applicability rule definition.", Length = 40)]
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
        [MTDataMember(Description = "This is a collection of localized display names for the applicability rule definition. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
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
    }
}

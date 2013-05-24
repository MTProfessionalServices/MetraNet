using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class PriceableItemType : BaseObject
    {

        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the priceable item type. This must be unique for each priceable item type. ", Length = 40)]
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
        [MTDataMember(Description = "This is the default description for the Priceable Item Type.", Length = 40)]
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
        [MTDataMember(Description = "This stores a collection of localized descriptions for the priceable item type. It is keyed by values from the LanguageCode enumeration.", Length = 40)]
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

        string LocalizedDescription(LanguageCode langCode)
        {
            if (m_LocalizedDescriptions.ContainsKey(langCode))
            {
                return m_LocalizedDescriptions[langCode];
            }
            else
            {
                return m_Description;
            }
        }

        #region ParentPriceableItem
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParentPriceableItemDirty = false;
    private PCIdentifier  m_ParentPriceableItem;
    [MTDataMember(Description = "This stores an identifier information to a parent priceable item type.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public PCIdentifier ParentPriceableItem
        {
            get { return m_ParentPriceableItem; }
            set
            {
                m_ParentPriceableItem = value;
                isParentPriceableItemDirty = true;
            }
        }
    [ScriptIgnore]
    public bool IsParentPriceableItemDirty
        {
            get { return isParentPriceableItemDirty; }
        }
        #endregion

        #region ChildPriceableItemTypes
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChildPriceableItemTypesDirty = false;
    private List<PCIdentifier> m_ChildPriceableItemTypes;
    [MTDataMember(Description = "This is a collection of zero or more identifiers to a child priceable item types.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<PCIdentifier> ChildPriceableItemTypes
        {
            get { return m_ChildPriceableItemTypes; }
            set
            {
                m_ChildPriceableItemTypes = value;
                isChildPriceableItemTypesDirty = true;
            }
        }
    [ScriptIgnore]
    public bool IsChildPriceableItemTypesDirty
        {
            get { return isChildPriceableItemTypesDirty; }
        }
        #endregion

        #region ServiceDefName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isServiceDefNameDirty = false;
        private string m_ServiceDefName;
        [MTDataMember(Description = "This property stores the name of the service definition to which this priceable item is related. When a record is received on that service definition, the rating looks for priceable item instances of this type.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ServiceDefName
        {
            get { return m_ServiceDefName; }
            set
            {
                m_ServiceDefName = value;
                isServiceDefNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsServiceDefNameDirty
        {
            get { return isServiceDefNameDirty; }
        }
        #endregion

        #region ProductViewName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isProductViewNameDirty = false;
        private string m_ProductViewName;
        [MTDataMember(Description = "This property stores the name of the product view that will store the results of rating of rating for this priceable item type for invoice generation and for display on the online-bill.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ProductViewName
        {
            get { return m_ProductViewName; }
            set
            {
                m_ProductViewName = value;
                isProductViewNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsProductViewNameDirty
        {
            get { return isProductViewNameDirty; }
        }
        #endregion

        #region Kind
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isKindDirty = false;
        private PriceableItemKinds m_Kind;
        [MTDataMember(Description = "This property specifies the kind of the priceable item type.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PriceableItemKinds Kind
        {
            get { return m_Kind; }
            set
            {
                m_Kind = value;
                isKindDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsKindDirty
        {
            get { return isKindDirty; }
        }
        #endregion

        #region ParameterTables
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterTablesDirty = false;
        private List<string> m_ParameterTables;
        [MTDataMember(Description = "This property stores a collection of strings. Each string is the name of a parameter table used by this priceable item type during rating.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<string> ParameterTables
        {
            get { return m_ParameterTables; }
            set
            {
                m_ParameterTables = value;
                isParameterTablesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsParameterTablesDirty
        {
            get { return isParameterTablesDirty; }
        }
        #endregion

        #region AdjustmentTypes
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentTypesDirty = false;
        private List<AdjustmentType> m_AdjustmentTypes;
        [MTDataMember(Description = "This property stores a collection of AdjustmentType instances. If the Priceable item type supports adjustments, this collection will have an instance of the AdjustmentType class for each adjustment type to define the metadata for that adjustment type.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<AdjustmentType> AdjustmentTypes
        {
            get { return m_AdjustmentTypes; }
            set
            {
                m_AdjustmentTypes = value;
                isAdjustmentTypesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentTypesDirty
        {
            get { return isAdjustmentTypesDirty; }
        }
        #endregion

        #region CounterProperties
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCounterPropertiesDirty = false;
        private List<CounterPropertyDefinition> m_CounterProperties;
        [MTDataMember(Description = "This property stores a collection of CounterPropertyDefinition instances. These instances store the metadata for counter properties. Counter properties are used in aggregate rating to values that cover all the usage records.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<CounterPropertyDefinition> CounterProperties
        {
            get { return m_CounterProperties; }
            set
            {
                m_CounterProperties = value;
                isCounterPropertiesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCounterPropertiesDirty
        {
            get { return isCounterPropertiesDirty; }
        }
        #endregion

        #region ChargeProperties
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChargePropertiesDirty = false;
        private List<Charge> m_ChargeProperties;
        [MTDataMember(Description = "This property stores a collection of Charge instances. Each Charge instance identifies a property of the product view that stores a charge value (e.g. a value that gets added together to generate the total charge for the record). These are used for adjustments. This collection may have zero or more instances in it.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<Charge> ChargeProperties
        {
            get { return m_ChargeProperties; }
            set
            {
                m_ChargeProperties = value;
                isChargePropertiesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChargePropertiesDirty
        {
            get { return isChargePropertiesDirty; }
        }
        #endregion
    }
}

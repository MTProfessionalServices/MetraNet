using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;
using System.Resources;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.Billing
{
    [Serializable]
    [DataContract]
    public class ChildUsageSummary : BaseObject
    {
        #region ProductSlice
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isProductSliceDirty = false;
        private SingleProductSlice m_ProductSlice;
        [MTDataMember(Description = "This is the product slice that can be used to retrieve the usage details for this summary", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public SingleProductSlice ProductSlice
        {
            get { return m_ProductSlice; }
            set
            {
                m_ProductSlice = value;
                isProductSliceDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsProductSliceDirty
        {
            get { return isProductSliceDirty; }
        }

        #region ProductSlice Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "MetraTech.DomainModel.Billing.ChildUsageSummary.ProductSlice",
                                       DefaultValue = "Product Slice",
                                       MTLocalizationId = "metratech.com/productview/ProductSlice",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/productview")]
        public string ProductSliceDisplayName
        {
            get
            {
                return ResourceManager.GetString("MetraTech.DomainModel.Billing.ChildUsageSummary.ProductSlice");
            }
        }
        #endregion
    
        #endregion

        #region DisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayNameDirty = false;
        private string m_DisplayName;
        [MTDataMember(Description = "This is the display name for the product view associated with this child usage type", Length = 40)]
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

        #region DisplayName Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "MetraTech.DomainModel.Billing.ChildUsageSummary.DisplayName",
                                       DefaultValue = "Display Name",
                                       MTLocalizationId = "metratech.com/productview/DisplayName",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/productview")]
        public string DisplayNameDisplayName
        {
            get
            {
                return ResourceManager.GetString("MetraTech.DomainModel.Billing.ChildUsageSummary.DisplayName");
            }
        }
        #endregion
    
        #endregion

        #region DisplayAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayAmountDirty = false;
        private decimal m_DisplayAmount;
        [MTDataMember(Description = "This is the display amount for the child usage summary", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal DisplayAmount
        {
            get { return m_DisplayAmount; }
            set
            {
                m_DisplayAmount = value;
                isDisplayAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDisplayAmountDirty
        {
            get { return isDisplayAmountDirty; }
        }

        #region DisplayAmount Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "MetraTech.DomainModel.Billing.ChildUsageSummary.DisplayAmount",
                                       DefaultValue = "Display Amount",
                                       MTLocalizationId = "metratech.com/productview/DisplayAmount",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/productview")]
        public string DisplayAmountDisplayName
        {
            get
            {
                return ResourceManager.GetString("MetraTech.DomainModel.Billing.ChildUsageSummary.DisplayAmount");
            }
        }
        #endregion
    
        #endregion

        #region DisplayAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayAmountAsStringDirty = false;
        private string m_DisplayAmountAsString;
        [MTDataMember(Description = "This is the display amount for the child usage summary localized as a currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string DisplayAmountAsString
        {
            get { return m_DisplayAmountAsString; }
            set
            {
                m_DisplayAmountAsString = value;
                isDisplayAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDisplayAmountAsStringDirty
        {
            get { return isDisplayAmountAsStringDirty; }
        }

        #region DisplayAmountAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "MetraTech.DomainModel.Billing.ChildUsageSummary.DisplayAmountAsString",
                                       DefaultValue = "Display Amount",
                                       MTLocalizationId = "metratech.com/productview/DisplayAmount",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/productview")]
        public string DisplayAmountAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("MetraTech.DomainModel.Billing.ChildUsageSummary.DisplayAmountAsString");
            }
        }
        #endregion
        #endregion
    }
}

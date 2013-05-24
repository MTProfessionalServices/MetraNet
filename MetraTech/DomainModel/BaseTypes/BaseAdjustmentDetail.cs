using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [Serializable]
    [DataContract]
    public class BaseAdjustmentDetail : BaseObject
    {
        #region SessionID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSessionIDDirty = false;
        private long m_SessionID;
        [MTDataMember(Description = "This is the session ID of the adjustment transaction", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public long SessionID
        {
            get { return m_SessionID; }
            set
            {
                m_SessionID = value;
                isSessionIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSessionIDDirty
        {
            get { return isSessionIDDirty; }
        }

        #region SessionID Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.SessionID",
                                       DefaultValue = "SessionID",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/SessionID",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string SessionIDDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.SessionID");
            }
        }
        #endregion
    
        #endregion

        #region AdjustmentTemplateDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentTemplateDisplayNameDirty = false;
        private string m_AdjustmentTemplateDisplayName;
        [MTDataMember(Description = "This is the display name of the adjustment template", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdjustmentTemplateDisplayName
        {
            get { return m_AdjustmentTemplateDisplayName; }
            set
            {
                m_AdjustmentTemplateDisplayName = value;
                isAdjustmentTemplateDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentTemplateDisplayNameDirty
        {
            get { return isAdjustmentTemplateDisplayNameDirty; }
        }

        #region AdjustmentTemplateDisplayName Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentTemplateDisplayName",
                                       DefaultValue = "AdjustmentTemplateDisplayName",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentTemplateDisplayName",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentTemplateDisplayNameDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentTemplateDisplayName");
            }
        }
        #endregion  
    
        #endregion

        #region AdjustmentInstanceDisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentInstanceDisplayNameDirty = false;
        private string m_AdjustmentInstanceDisplayName;
        [MTDataMember(Description = "This is the display name of the adjustment instance", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdjustmentInstanceDisplayName
        {
            get { return m_AdjustmentInstanceDisplayName; }
            set
            {
                m_AdjustmentInstanceDisplayName = value;
                isAdjustmentInstanceDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentInstanceDisplayNameDirty
        {
            get { return isAdjustmentInstanceDisplayNameDirty; }
        }

        #region AdjustmentInstanceDisplayName Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentInstanceDisplayName",
                                       DefaultValue = "AdjustmentInstanceDisplayName",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentInstanceDisplayName",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentInstanceDisplayNameDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentInstanceDisplayName");
            }
        }
        #endregion
    
        #endregion

        #region Description
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDescriptionDirty = false;
        private string m_Description;
        [MTDataMember(Description = "This is the description of the adjustment", Length = 40)]
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

        #region Description Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.Description",
                                       DefaultValue = "Description",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/Description",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string DescriptionDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.Description");
            }
        }
        #endregion
    
        #endregion

        #region AdjustmentReason
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentReasonDirty = false;
        private ReasonCode m_AdjustmentReason;
        [MTDataMember(Description = "This is the reason code for why the adjustment was made", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ReasonCode AdjustmentReason
        {
            get { return m_AdjustmentReason; }
            set
            {
                m_AdjustmentReason = value;
                isAdjustmentReasonDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentReasonDirty
        {
            get { return isAdjustmentReasonDirty; }
        }

        #region AdjustmentReason Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentReason",
                                       DefaultValue = "AdjustmentReason",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentReason",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentReasonDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentReason");
            }
        }
        #endregion
    
        #endregion

        #region UnadjustedAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUnadjustedAmountDirty = false;
        private decimal m_UnadjustedAmount;
        [MTDataMember(Description = "This is the original, unadjusted amount", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal UnadjustedAmount
        {
            get { return m_UnadjustedAmount; }
            set
            {
                m_UnadjustedAmount = value;
                isUnadjustedAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUnadjustedAmountDirty
        {
            get { return isUnadjustedAmountDirty; }
        }

        #region UnadjustedAmount Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmount",
                                       DefaultValue = "UnadjustedAmount",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/UnadjustedAmount",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string UnadjustedAmountDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmount");
            }
        }
        #endregion
    
        #endregion

        #region UnadjustedAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUnadjustedAmountAsStringDirty = false;
        private string m_UnadjustedAmountAsString;
        [MTDataMember(Description = "This is the original, unadjusted amount as a localized currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UnadjustedAmountAsString
        {
            get { return m_UnadjustedAmountAsString; }
            set
            {
                m_UnadjustedAmountAsString = value;
                isUnadjustedAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUnadjustedAmountAsStringDirty
        {
            get { return isUnadjustedAmountAsStringDirty; }
        }

        #region UnadjustedAmountAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmountAsString",
                                       DefaultValue = "UnadjustedAmountAsString",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/UnadjustedAmountAsString",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string UnadjustedAmountAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmountAsString");
            }
        }
        #endregion
    
        #endregion

        #region UnadjustedAmountWithTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUnadjustedAmountWithTaxDirty = false;
        private decimal m_UnadjustedAmountWithTax;
        [MTDataMember(Description = "This is the original, unadjusted amount with the original tax included", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal UnadjustedAmountWithTax
        {
            get { return m_UnadjustedAmountWithTax; }
            set
            {
                m_UnadjustedAmountWithTax = value;
                isUnadjustedAmountWithTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUnadjustedAmountWithTaxDirty
        {
            get { return isUnadjustedAmountWithTaxDirty; }
        }

        #region UnadjustedAmountWithTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmountWithTax",
                                       DefaultValue = "UnadjustedAmountWithTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/UnadjustedAmountWithTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string UnadjustedAmountWithTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmountWithTax");
            }
        }
        #endregion
    
        #endregion

        #region UnadjustedAmountWithTaxAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUnadjustedAmountWithTaxAsStringDirty = false;
        private string m_UnadjustedAmountWithTaxAsString;
        [MTDataMember(Description = "This is the original, unadjusted amount, including tax, as a localized currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UnadjustedAmountWithTaxAsString
        {
            get { return m_UnadjustedAmountWithTaxAsString; }
            set
            {
                m_UnadjustedAmountWithTaxAsString = value;
                isUnadjustedAmountWithTaxAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsUnadjustedAmountWithTaxAsStringDirty
        {
            get { return isUnadjustedAmountWithTaxAsStringDirty; }
        }

        #region UnadjustedAmountWithTaxAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmountWithTaxAsString",
                                       DefaultValue = "UnadjustedAmountWithTaxAsString",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/UnadjustedAmountWithTaxAsString",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string UnadjustedAmountWithTaxAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.UnadjustedAmountWithTaxAsString");
            }
        }
        #endregion
    
        #endregion

        #region FederalTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isFederalTaxDirty = false;
        private TaxData m_FederalTax;
        [MTDataMember(Description = "This is the federal tax information", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxData FederalTax
        {
            get { return m_FederalTax; }
            set
            {
                m_FederalTax = value;
                isFederalTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsFederalTaxDirty
        {
            get { return isFederalTaxDirty; }
        }

        #region FederalTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.FederalTax",
                                       DefaultValue = "FederalTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/FederalTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string FederalTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.FederalTax");
            }
        }
        #endregion
    
        #endregion

        #region StateTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStateTaxDirty = false;
        private TaxData m_StateTax;
        [MTDataMember(Description = "This is the state tax information", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxData StateTax
        {
            get { return m_StateTax; }
            set
            {
                m_StateTax = value;
                isStateTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsStateTaxDirty
        {
            get { return isStateTaxDirty; }
        }

        #region StateTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.StateTax",
                                       DefaultValue = "StateTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/StateTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string StateTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.StateTax");
            }
        }
        #endregion
    
        #endregion

        #region CountyTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCountyTaxDirty = false;
        private TaxData m_CountyTax;
        [MTDataMember(Description = "This is the county tax information", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxData CountyTax
        {
            get { return m_CountyTax; }
            set
            {
                m_CountyTax = value;
                isCountyTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCountyTaxDirty
        {
            get { return isCountyTaxDirty; }
        }

        #region CountyTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.CountyTax",
                                       DefaultValue = "CountyTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/CountyTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string CountyTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.CountyTax");
            }
        }
        #endregion
    
        #endregion

        #region LocalTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isLocalTaxDirty = false;
        private TaxData m_LocalTax;
        [MTDataMember(Description = "This is the local tax data", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxData LocalTax
        {
            get { return m_LocalTax; }
            set
            {
                m_LocalTax = value;
                isLocalTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsLocalTaxDirty
        {
            get { return isLocalTaxDirty; }
        }

        #region LocalTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.LocalTax",
                                       DefaultValue = "LocalTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/LocalTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string LocalTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.LocalTax");
            }
        }
        #endregion
    
        #endregion

        #region OtherTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isOtherTaxDirty = false;
        private TaxData m_OtherTax;
        [MTDataMember(Description = "This is other, miscellaneous tax data", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxData OtherTax
        {
            get { return m_OtherTax; }
            set
            {
                m_OtherTax = value;
                isOtherTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsOtherTaxDirty
        {
            get { return isOtherTaxDirty; }
        }

        #region OtherTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.OtherTax",
                                       DefaultValue = "OtherTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/OtherTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string OtherTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.OtherTax");
            }
        }
        #endregion
    
        #endregion

        #region AdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentAmountDirty = false;
        private decimal m_AdjustmentAmount;
        [MTDataMember(Description = "This is the amount of the adjustment", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal AdjustmentAmount
        {
            get { return m_AdjustmentAmount; }
            set
            {
                m_AdjustmentAmount = value;
                isAdjustmentAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentAmountDirty
        {
            get { return isAdjustmentAmountDirty; }
        }

        #region AdjustmentAmount Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmount",
                                       DefaultValue = "AdjustmentAmount",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentAmount",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentAmountDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmount");
            }
        }
        #endregion
    
        #endregion

        #region AdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentAmountAsStringDirty = false;
        private string m_AdjustmentAmountAsString;
        [MTDataMember(Description = "This is the amount of the adjustment as a localized currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdjustmentAmountAsString
        {
            get { return m_AdjustmentAmountAsString; }
            set
            {
                m_AdjustmentAmountAsString = value;
                isAdjustmentAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentAmountAsStringDirty
        {
            get { return isAdjustmentAmountAsStringDirty; }
        }

        #region AdjustmentAmountAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmountAsString",
                                       DefaultValue = "AdjustmentAmountAsString",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentAmountAsString",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentAmountAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmountAsString");
            }
        }
        #endregion
    
        #endregion

        #region AdjustedAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustedAmountDirty = false;
        private decimal m_AdjustedAmount;
        [MTDataMember(Description = "This is the adjusted amount of the charge", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal AdjustedAmount
        {
            get { return m_AdjustedAmount; }
            set
            {
                m_AdjustedAmount = value;
                isAdjustedAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustedAmountDirty
        {
            get { return isAdjustedAmountDirty; }
        }

        #region AdjustedAmount Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmount",
                                       DefaultValue = "AdjustedAmount",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustedAmount",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustedAmountDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmount");
            }
        }
        #endregion
    
        #endregion

        #region AdjustedAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustedAmountAsStringDirty = false;
        private string m_AdjustedAmountAsString;
        [MTDataMember(Description = "This is the adjusted amount of the charge as a localized currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdjustedAmountAsString
        {
            get { return m_AdjustedAmountAsString; }
            set
            {
                m_AdjustedAmountAsString = value;
                isAdjustedAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustedAmountAsStringDirty
        {
            get { return isAdjustedAmountAsStringDirty; }
        }

        #region AdjustedAmountAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmountAsString",
                                       DefaultValue = "AdjustedAmountAsString",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustedAmountAsString",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustedAmountAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmountAsString");
            }
        }
        #endregion
    
        #endregion

        #region AdjustmentAmountWithTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentAmountWithTaxDirty = false;
        private decimal m_AdjustmentAmountWithTax;
        [MTDataMember(Description = "This is the amount of the adjustment including tax", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal AdjustmentAmountWithTax
        {
            get { return m_AdjustmentAmountWithTax; }
            set
            {
                m_AdjustmentAmountWithTax = value;
                isAdjustmentAmountWithTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentAmountWithTaxDirty
        {
            get { return isAdjustmentAmountWithTaxDirty; }
        }

        #region AdjustmentAmountWithTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmountWithTax",
                                       DefaultValue = "AdjustmentAmountWithTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentAmountWithTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentAmountWithTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmountWithTax");
            }
        }
        #endregion
    
        #endregion

        #region AdjustmentAmountWithTaxAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentAmountWithTaxAsStringDirty = false;
        private string m_AdjustmentAmountWithTaxAsString;
        [MTDataMember(Description = "This is the amount of the adjustment including tax as a localized currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdjustmentAmountWithTaxAsString
        {
            get { return m_AdjustmentAmountWithTaxAsString; }
            set
            {
                m_AdjustmentAmountWithTaxAsString = value;
                isAdjustmentAmountWithTaxAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustmentAmountWithTaxAsStringDirty
        {
            get { return isAdjustmentAmountWithTaxAsStringDirty; }
        }

        #region AdjustmentAmountWithTaxAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmountWithTaxAsString",
                                       DefaultValue = "AdjustmentAmountWithTaxAsString",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustmentAmountWithTaxAsString",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustmentAmountWithTaxAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustmentAmountWithTaxAsString");
            }
        }
        #endregion
    
        #endregion

        #region AdjustedAmountWithTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustedAmountWithTaxDirty = false;
        private decimal m_AdjustedAmountWithTax;
        [MTDataMember(Description = "This is the adjusted amount including tax", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal AdjustedAmountWithTax
        {
            get { return m_AdjustedAmountWithTax; }
            set
            {
                m_AdjustedAmountWithTax = value;
                isAdjustedAmountWithTaxDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustedAmountWithTaxDirty
        {
            get { return isAdjustedAmountWithTaxDirty; }
        }

        #region AdjustedAmountWithTax Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmountWithTax",
                                       DefaultValue = "AdjustedAmountWithTax",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustedAmountWithTax",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustedAmountWithTaxDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmountWithTax");
            }
        }
        #endregion
    
        #endregion

        #region AdjustedAmountWithTaxAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustedAmountWithTaxAsStringDirty = false;
        private string m_AdjustedAmountWithTaxAsString;
        [MTDataMember(Description = "This is the adjusted amount with tax as a localized currency string", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdjustedAmountWithTaxAsString
        {
            get { return m_AdjustedAmountWithTaxAsString; }
            set
            {
                m_AdjustedAmountWithTaxAsString = value;
                isAdjustedAmountWithTaxAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAdjustedAmountWithTaxAsStringDirty
        {
            get { return isAdjustedAmountWithTaxAsStringDirty; }
        }

        #region AdjustedAmountWithTaxAsString Display Name
        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmountWithTaxAsString",
                                       DefaultValue = "AdjustedAmountWithTaxAsString",
                                       MTLocalizationId = "metratech.com/defaultadjustmentdetail/AdjustedAmountWithTaxAsString",
                                         Extension = "Core",
                                         LocaleSpace = "metratech.com/defaultadjustmentdetail")]
        public string AdjustedAmountWithTaxAsStringDisplayName
        {
            get
            {
                return ResourceManager.GetString("metratech.domainmodel.productview.defaultadjustmentdetail.AdjustedAmountWithTaxAsString");
            }
        }
        #endregion
    
        #endregion
    }
}

using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    [KnownType("KnownTypes")]
    public class BaseProductView : BaseObject
    {
        #region IntervalID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIntervalIDDirty = false;
        private int m_IntervalID;

        [MTDataMember(Description = "This is the interval identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int IntervalID
        {
            get { return m_IntervalID; }
            set
            {
                m_IntervalID = value;
                isIntervalIDDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIntervalIDDirty
        {
            get { return isIntervalIDDirty; }
        }

        #region IntervalID Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.IntervalID",
            DefaultValue = "IntervalID",
            MTLocalizationId = "metratech.com/defaultproductview/IntervalID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string IntervalIDDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.IntervalID"); }
        }

        #endregion

        #endregion

        #region ViewID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isViewIDDirty = false;
        private int m_ViewID;

        [MTDataMember(Description = "This is the view identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ViewID
        {
            get { return m_ViewID; }
            set
            {
                m_ViewID = value;
                isViewIDDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsViewIDDirty
        {
            get { return isViewIDDirty; }
        }

        #region ViewID Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.ViewID",
            DefaultValue = "ViewID",
            MTLocalizationId = "metratech.com/defaultproductview/ViewID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string ViewIDDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.ViewID"); }
        }

        #endregion

        #endregion

        #region SessionID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isSessionIDDirty = false;
        private long m_SessionID;

        [MTDataMember(Description = "This is the session identifier.", Length = 40)]
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

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.SessionID",
            DefaultValue = "SessionID",
            MTLocalizationId = "metratech.com/defaultproductview/SessionID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string SessionIDDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.SessionID"); }
        }

        #endregion

        #endregion



        #region ParentSessionID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isParentSessionIDDirty = false;
        private long? m_ParentSessionID;

        [MTDataMember(Description = "This is the identifier of the parent session, if any", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public long? ParentSessionID
        {
            get { return m_ParentSessionID; }
            set
            {
                m_ParentSessionID = value;
                isParentSessionIDDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsParentSessionIDDirty
        {
            get { return isParentSessionIDDirty; }
        }

        #region ParentSessionID Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.ParentSessionID",
            DefaultValue = "ParentSessionID",
            MTLocalizationId = "metratech.com/defaultproductview/ParentSessionID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string ParentSessionIDDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.ParentSessionID"); }
        }

        #endregion

        #endregion

        #region AccountID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAccountIDDirty = false;
        private AccountIdentifier m_AccountID;

        [MTDataMember(Description = "This is the identifier for the account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountIdentifier AccountID
        {
            get { return m_AccountID; }
            set
            {
                m_AccountID = value;
                isAccountIDDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAccountIDDirty
        {
            get { return isAccountIDDirty; }
        }

        #region AccountID Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.AccountID",
            DefaultValue = "AccountID",
            MTLocalizationId = "metratech.com/defaultproductview/AccountID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string AccountIDDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.AccountID"); }
        }

        #endregion

        #endregion

        #region Currency

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCurrencyDirty = false;
        private string m_Currency;

        [MTDataMember(Description = "This is the currency used.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Currency
        {
            get { return m_Currency; }
            set
            {
                m_Currency = value;
                isCurrencyDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCurrencyDirty
        {
            get { return isCurrencyDirty; }
        }

        #region Currency Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.Currency",
            DefaultValue = "Currency",
            MTLocalizationId = "metratech.com/defaultproductview/Currency",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string CurrencyDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.Currency"); }
        }

        #endregion

        #endregion

        #region Amount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAmountDirty = false;
        private decimal m_Amount;

        [MTDataMember(Description = "This is the amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal Amount
        {
            get { return m_Amount; }
            set
            {
                m_Amount = value;
                isAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAmountDirty
        {
            get { return isAmountDirty; }
        }

        #region Amount Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.Amount",
            DefaultValue = "Amount",
            MTLocalizationId = "metratech.com/defaultproductview/Amount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string AmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.Amount"); }
        }

        #endregion

        #endregion

        #region DisplayAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isDisplayAmountDirty = false;
        private decimal m_DisplayAmount;

        [MTDataMember(Description = "This is the amount displayed.", Length = 40)]
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

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.DisplayAmount",
            DefaultValue = "DisplayAmount",
            MTLocalizationId = "metratech.com/defaultproductview/DisplayAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string DisplayAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.DisplayAmount"); }
        }

        #endregion

        #endregion

        #region DisplayAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isDisplayAmountAsStringDirty = false;
        private string m_DisplayAmountAsString;

        [MTDataMember(Description = "This is the text representation of the amount displayed.", Length = 40)]
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

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.DisplayAmountAsString",
            DefaultValue = "DisplayAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/DisplayAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string DisplayAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.DisplayAmountAsString");
            }
        }

        #endregion

        #endregion

        #region TimeStamp

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isTimeStampDirty = false;
        private DateTime m_TimeStamp;

        [MTDataMember(Description = "This is the time stamp.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime TimeStamp
        {
            get { return m_TimeStamp; }
            set
            {
                m_TimeStamp = value;
                isTimeStampDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsTimeStampDirty
        {
            get { return isTimeStampDirty; }
        }

        #region TimeStamp Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.TimeStamp",
            DefaultValue = "TimeStamp",
            MTLocalizationId = "metratech.com/defaultproductview/TimeStamp",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string TimeStampDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.TimeStamp"); }
        }

        #endregion

        #endregion

        #region PITemplate

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isPITemplateDirty = false;
        private int m_PITemplate;

        [MTDataMember(Description = "This is the Priceable Item Template numeric identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int PITemplate
        {
            get { return m_PITemplate; }
            set
            {
                m_PITemplate = value;
                isPITemplateDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsPITemplateDirty
        {
            get { return isPITemplateDirty; }
        }

        #region PITemplate Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.PITemplate",
            DefaultValue = "PITemplate",
            MTLocalizationId = "metratech.com/defaultproductview/PITemplate",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string PITemplateDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.PITemplate"); }
        }

        #endregion

        #endregion

        #region PIInstance

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isPIInstanceDirty = false;
        private int m_PIInstance;

        [MTDataMember(Description = "This is the Priceable Item Instance numeric identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int PIInstance
        {
            get { return m_PIInstance; }
            set
            {
                m_PIInstance = value;
                isPIInstanceDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsPIInstanceDirty
        {
            get { return isPIInstanceDirty; }
        }

        #region PIInstance Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.PIInstance",
            DefaultValue = "PIInstance",
            MTLocalizationId = "metratech.com/defaultproductview/PIInstance",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string PIInstanceDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.PIInstance"); }
        }

        #endregion

        #endregion

        #region SessionType

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isSessionTypeDirty = false;
        private SessionType m_SessionType;

        [MTDataMember(Description = "This is the session type.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public SessionType SessionType
        {
            get { return m_SessionType; }
            set
            {
                m_SessionType = value;
                isSessionTypeDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsSessionTypeDirty
        {
            get { return isSessionTypeDirty; }
        }

        #region SessionType Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.SessionType"
            ,
            DefaultValue = "SessionType",
            MTLocalizationId = "metratech.com/defaultproductview/SessionType",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string SessionTypeDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.SessionType"); }
        }

        #endregion

        #endregion

        #region SessionType Value Display Name

        public string SessionTypeValueDisplayName
        {
            get { return GetDisplayName(this.SessionType); }
            set { this.SessionType = ((SessionType) (GetEnumInstanceByDisplayName(typeof (SessionType), value))); }
        }

        #endregion

        #region TaxAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isTaxAmountDirty = false;
        private decimal m_TaxAmount;

        [MTDataMember(Description = "This is the tax amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal TaxAmount
        {
            get { return m_TaxAmount; }
            set
            {
                m_TaxAmount = value;
                isTaxAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsTaxAmountDirty
        {
            get { return isTaxAmountDirty; }
        }

        #region TaxAmount Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.TaxAmount",
            DefaultValue = "TaxAmount",
            MTLocalizationId = "metratech.com/defaultproductview/TaxAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string TaxAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.TaxAmount"); }
        }

        #endregion

        #endregion

        #region TaxAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isTaxAmountAsStringDirty = false;
        private string m_TaxAmountAsString;

        [MTDataMember(Description = "This is the text representation of the tax amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TaxAmountAsString
        {
            get { return m_TaxAmountAsString; }
            set
            {
                m_TaxAmountAsString = value;
                isTaxAmountAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsTaxAmountAsStringDirty
        {
            get { return isTaxAmountAsStringDirty; }
        }

        #region TaxAmountAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.TaxAmountAsString",
            DefaultValue = "TaxAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/TaxAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string TaxAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.TaxAmountAsString");
            }
        }

        #endregion

        #endregion

        #region FederalTaxAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isFederalTaxAmountDirty = false;
        private decimal m_FederalTaxAmount;

        [MTDataMember(Description = "This is the amount of federal tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal FederalTaxAmount
        {
            get { return m_FederalTaxAmount; }
            set
            {
                m_FederalTaxAmount = value;
                isFederalTaxAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsFederalTaxAmountDirty
        {
            get { return isFederalTaxAmountDirty; }
        }

        #region FederalTaxAmount Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.FederalTaxAmount",
            DefaultValue = "FederalTaxAmount",
            MTLocalizationId = "metratech.com/defaultproductview/FederalTaxAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string FederalTaxAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.FederalTaxAmount"); }
        }

        #endregion

        #endregion

        #region FederalTaxAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isFederalTaxAmountAsStringDirty = false;
        private string m_FederalTaxAmountAsString;

        [MTDataMember(Description = "This is the text representation of the federal tax amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string FederalTaxAmountAsString
        {
            get { return m_FederalTaxAmountAsString; }
            set
            {
                m_FederalTaxAmountAsString = value;
                isFederalTaxAmountAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsFederalTaxAmountAsStringDirty
        {
            get { return isFederalTaxAmountAsStringDirty; }
        }

        #region FederalTaxAmountAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.FederalTaxAmountAsString",
            DefaultValue = "FederalTaxAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/FederalTaxAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string FederalTaxAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.FederalTaxAmountAsString");
            }
        }

        #endregion

        #endregion

        #region StateTaxAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isStateTaxAmountDirty = false;
        private decimal m_StateTaxAmount;

        [MTDataMember(Description = "This is the amount of state tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal StateTaxAmount
        {
            get { return m_StateTaxAmount; }
            set
            {
                m_StateTaxAmount = value;
                isStateTaxAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsStateTaxAmountDirty
        {
            get { return isStateTaxAmountDirty; }
        }

        #region StateTaxAmount Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.StateTaxAmount",
            DefaultValue = "StateTaxAmount",
            MTLocalizationId = "metratech.com/defaultproductview/StateTaxAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string StateTaxAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.StateTaxAmount"); }
        }

        #endregion

        #endregion

        #region StateTaxAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isStateTaxAmountAsStringDirty = false;
        private string m_StateTaxAmountAsString;

        [MTDataMember(Description = "This is a text representation of the amount of state tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string StateTaxAmountAsString
        {
            get { return m_StateTaxAmountAsString; }
            set
            {
                m_StateTaxAmountAsString = value;
                isStateTaxAmountAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsStateTaxAmountAsStringDirty
        {
            get { return isStateTaxAmountAsStringDirty; }
        }

        #region StateTaxAmountAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.StateTaxAmountAsString",
            DefaultValue = "StateTaxAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/StateTaxAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string StateTaxAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.StateTaxAmountAsString");
            }
        }

        #endregion

        #endregion

        #region CountyTaxAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCountyTaxAmountDirty = false;
        private decimal m_CountyTaxAmount;

        [MTDataMember(Description = "This is the amount of county tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal CountyTaxAmount
        {
            get { return m_CountyTaxAmount; }
            set
            {
                m_CountyTaxAmount = value;
                isCountyTaxAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCountyTaxAmountDirty
        {
            get { return isCountyTaxAmountDirty; }
        }

        #region CountyTaxAmount Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.CountyTaxAmount",
            DefaultValue = "CountyTaxAmount",
            MTLocalizationId = "metratech.com/defaultproductview/CountyTaxAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string CountyTaxAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.CountyTaxAmount"); }
        }

        #endregion

        #endregion

        #region CountyTaxAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCountyTaxAmountAsStringDirty = false;
        private string m_CountyTaxAmountAsString;

        [MTDataMember(Description = "This is a text representation of the amount of county tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string CountyTaxAmountAsString
        {
            get { return m_CountyTaxAmountAsString; }
            set
            {
                m_CountyTaxAmountAsString = value;
                isCountyTaxAmountAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCountyTaxAmountAsStringDirty
        {
            get { return isCountyTaxAmountAsStringDirty; }
        }

        #region CountyTaxAmountAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.CountyTaxAmountAsString",
            DefaultValue = "CountyTaxAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/CountyTaxAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string CountyTaxAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.CountyTaxAmountAsString");
            }
        }

        #endregion

        #endregion

        #region LocalTaxAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isLocalTaxAmountDirty = false;
        private decimal m_LocalTaxAmount;

        [MTDataMember(Description = "This is the amount of local tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal LocalTaxAmount
        {
            get { return m_LocalTaxAmount; }
            set
            {
                m_LocalTaxAmount = value;
                isLocalTaxAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsLocalTaxAmountDirty
        {
            get { return isLocalTaxAmountDirty; }
        }

        #region LocalTaxAmount Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.LocalTaxAmount",
            DefaultValue = "LocalTaxAmount",
            MTLocalizationId = "metratech.com/defaultproductview/LocalTaxAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string LocalTaxAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.LocalTaxAmount"); }
        }

        #endregion

        #endregion

        #region LocalTaxAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isLocalTaxAmountAsStringDirty = false;
        private string m_LocalTaxAmountAsString;

        [MTDataMember(Description = "This is a text representation of the amount of local tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string LocalTaxAmountAsString
        {
            get { return m_LocalTaxAmountAsString; }
            set
            {
                m_LocalTaxAmountAsString = value;
                isLocalTaxAmountAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsLocalTaxAmountAsStringDirty
        {
            get { return isLocalTaxAmountAsStringDirty; }
        }

        #region LocalTaxAmountAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.LocalTaxAmountAsString",
            DefaultValue = "LocalTaxAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/LocalTaxAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string LocalTaxAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.LocalTaxAmountAsString");
            }
        }

        #endregion

        #endregion

        #region OtherTaxAmount

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isOtherTaxAmountDirty = false;
        private decimal m_OtherTaxAmount;

        [MTDataMember(Description = "This is the amount of other tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal OtherTaxAmount
        {
            get { return m_OtherTaxAmount; }
            set
            {
                m_OtherTaxAmount = value;
                isOtherTaxAmountDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsOtherTaxAmountDirty
        {
            get { return isOtherTaxAmountDirty; }
        }

        #region OtherTaxAmount Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.OtherTaxAmount",
            DefaultValue = "OtherTaxAmount",
            MTLocalizationId = "metratech.com/defaultproductview/OtherTaxAmount",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string OtherTaxAmountDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.OtherTaxAmount"); }
        }

        #endregion

        #endregion

        #region OtherTaxAmountAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isOtherTaxAmountAsStringDirty = false;
        private string m_OtherTaxAmountAsString;

        [MTDataMember(Description = "This is a text representation of the amount of other tax.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string OtherTaxAmountAsString
        {
            get { return m_OtherTaxAmountAsString; }
            set
            {
                m_OtherTaxAmountAsString = value;
                isOtherTaxAmountAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsOtherTaxAmountAsStringDirty
        {
            get { return isOtherTaxAmountAsStringDirty; }
        }

        #region OtherTaxAmountAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.OtherTaxAmountAsString",
            DefaultValue = "OtherTaxAmountAsString",
            MTLocalizationId = "metratech.com/defaultproductview/OtherTaxAmountAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string OtherTaxAmountAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.OtherTaxAmountAsString");
            }
        }

        #endregion

        #endregion

        #region AmountWithTax

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAmountWithTaxDirty = false;
        private decimal m_AmountWithTax;

        [MTDataMember(Description = "This is the amount with tax included.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal AmountWithTax
        {
            get { return m_AmountWithTax; }
            set
            {
                m_AmountWithTax = value;
                isAmountWithTaxDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAmountWithTaxDirty
        {
            get { return isAmountWithTaxDirty; }
        }

        #region AmountWithTax Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.AmountWithTax",
            DefaultValue = "AmountWithTax",
            MTLocalizationId = "metratech.com/defaultproductview/AmountWithTax",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string AmountWithTaxDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.AmountWithTax"); }
        }

        #endregion

        #endregion

        #region AmountWithTaxAsString

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAmountWithTaxAsStringDirty = false;
        private string m_AmountWithTaxAsString;

        [MTDataMember(Description = "This is a string representation of the amount with tax included.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AmountWithTaxAsString
        {
            get { return m_AmountWithTaxAsString; }
            set
            {
                m_AmountWithTaxAsString = value;
                isAmountWithTaxAsStringDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAmountWithTaxAsStringDirty
        {
            get { return isAmountWithTaxAsStringDirty; }
        }

        #region AmountWithTaxAsString Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.AmountWithTaxAsString",
            DefaultValue = "AmountWithTaxAsString",
            MTLocalizationId = "metratech.com/defaultproductview/AmountWithTaxAsString",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string AmountWithTaxAsStringDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.AmountWithTaxAsString");
            }
        }

        #endregion

        #endregion

        #region CompoundAdjustmentInfo

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundAdjustmentInfoDirty = false;
        private Adjustments m_CompoundAdjustmentInfo;

        [MTDataMember(Description = "Thi is the compound adjustment information.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Adjustments CompoundAdjustmentInfo
        {
            get { return m_CompoundAdjustmentInfo; }
            set
            {
                m_CompoundAdjustmentInfo = value;
                isCompoundAdjustmentInfoDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundAdjustmentInfoDirty
        {
            get { return isCompoundAdjustmentInfoDirty; }
        }

        #endregion

        #region AtomicAdjustmentInfo

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicAdjustmentInfoDirty = false;
        private Adjustments m_AtomicAdjustmentInfo;

        [MTDataMember(Description = "This is the atomic adjustment information.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Adjustments AtomicAdjustmentInfo
        {
            get { return m_AtomicAdjustmentInfo; }
            set
            {
                m_AtomicAdjustmentInfo = value;
                isAtomicAdjustmentInfoDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicAdjustmentInfoDirty
        {
            get { return isAtomicAdjustmentInfoDirty; }
        }

        #endregion

        #region CompoundTotalTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundTotalTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_CompoundTotalTaxAdjustments;

        [MTDataMember(Description = "These are the compound total tax adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments CompoundTotalTaxAdjustments
        {
            get { return m_CompoundTotalTaxAdjustments; }
            set
            {
                m_CompoundTotalTaxAdjustments = value;
                isCompoundTotalTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundTotalTaxAdjustmentsDirty
        {
            get { return isCompoundTotalTaxAdjustmentsDirty; }
        }

        #endregion

        #region CompoundFederalTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundFederalTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_CompoundFederalTaxAdjustments;

        [MTDataMember(Description = "These are the compound federal tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments CompoundFederalTaxAdjustments
        {
            get { return m_CompoundFederalTaxAdjustments; }
            set
            {
                m_CompoundFederalTaxAdjustments = value;
                isCompoundFederalTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundFederalTaxAdjustmentsDirty
        {
            get { return isCompoundFederalTaxAdjustmentsDirty; }
        }

        #endregion

        #region CompoundStateTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundStateTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_CompoundStateTaxAdjustments;

        [MTDataMember(Description = "These are the compound state tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments CompoundStateTaxAdjustments
        {
            get { return m_CompoundStateTaxAdjustments; }
            set
            {
                m_CompoundStateTaxAdjustments = value;
                isCompoundStateTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundStateTaxAdjustmentsDirty
        {
            get { return isCompoundStateTaxAdjustmentsDirty; }
        }

        #endregion

        #region CompoundCountyTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundCountyTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_CompoundCountyTaxAdjustments;

        [MTDataMember(Description = "These are the compound county tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments CompoundCountyTaxAdjustments
        {
            get { return m_CompoundCountyTaxAdjustments; }
            set
            {
                m_CompoundCountyTaxAdjustments = value;
                isCompoundCountyTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundCountyTaxAdjustmentsDirty
        {
            get { return isCompoundCountyTaxAdjustmentsDirty; }
        }

        #endregion

        #region CompoundLocalTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundLocalTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_CompoundLocalTaxAdjustments;

        [MTDataMember(Description = "These are the compound local tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments CompoundLocalTaxAdjustments
        {
            get { return m_CompoundLocalTaxAdjustments; }
            set
            {
                m_CompoundLocalTaxAdjustments = value;
                isCompoundLocalTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundLocalTaxAdjustmentsDirty
        {
            get { return isCompoundLocalTaxAdjustmentsDirty; }
        }

        #endregion

        #region CompoundOtherTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCompoundOtherTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_CompoundOtherTaxAdjustments;

        [MTDataMember(Description = "These are the compound other tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments CompoundOtherTaxAdjustments
        {
            get { return m_CompoundOtherTaxAdjustments; }
            set
            {
                m_CompoundOtherTaxAdjustments = value;
                isCompoundOtherTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCompoundOtherTaxAdjustmentsDirty
        {
            get { return isCompoundOtherTaxAdjustmentsDirty; }
        }

        #endregion

        #region AtomicTotalTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicTotalTaxAdjustmentsDirty = false;
        private TaxAdjustments m_AtomicTotalTaxAdjustments;

        [MTDataMember(Description = "These are the atomic total tax adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments AtomicTotalTaxAdjustments
        {
            get { return m_AtomicTotalTaxAdjustments; }
            set
            {
                m_AtomicTotalTaxAdjustments = value;
                isAtomicTotalTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicTotalTaxAdjustmentsDirty
        {
            get { return isAtomicTotalTaxAdjustmentsDirty; }
        }

        #endregion

        #region AtomicFederalTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicFederalTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_AtomicFederalTaxAdjustments;

        [MTDataMember(Description = "These are the atomic federal tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments AtomicFederalTaxAdjustments
        {
            get { return m_AtomicFederalTaxAdjustments; }
            set
            {
                m_AtomicFederalTaxAdjustments = value;
                isAtomicFederalTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicFederalTaxAdjustmentsDirty
        {
            get { return isAtomicFederalTaxAdjustmentsDirty; }
        }

        #endregion

        #region AtomicStateTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicStateTaxAdjustmentsDirty = false;
        private TaxAdjustments m_AtomicStateTaxAdjustments;

        [MTDataMember(Description = "These are the atomic state tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments AtomicStateTaxAdjustments
        {
            get { return m_AtomicStateTaxAdjustments; }
            set
            {
                m_AtomicStateTaxAdjustments = value;
                isAtomicStateTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicStateTaxAdjustmentsDirty
        {
            get { return isAtomicStateTaxAdjustmentsDirty; }
        }

        #endregion

        #region AtomicCountyTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicCountyTaxAdjustmentsDirty =
            false;

        private TaxAdjustments m_AtomicCountyTaxAdjustments;

        [MTDataMember(Description = "These are the atomic county tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments AtomicCountyTaxAdjustments
        {
            get { return m_AtomicCountyTaxAdjustments; }
            set
            {
                m_AtomicCountyTaxAdjustments = value;
                isAtomicCountyTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicCountyTaxAdjustmentsDirty
        {
            get { return isAtomicCountyTaxAdjustmentsDirty; }
        }

        #endregion

        #region AtomicLocalTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicLocalTaxAdjustmentsDirty = false;
        private TaxAdjustments m_AtomicLocalTaxAdjustments;

        [MTDataMember(Description = "These are the atomic local tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments AtomicLocalTaxAdjustments
        {
            get { return m_AtomicLocalTaxAdjustments; }
            set
            {
                m_AtomicLocalTaxAdjustments = value;
                isAtomicLocalTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicLocalTaxAdjustmentsDirty
        {
            get { return isAtomicLocalTaxAdjustmentsDirty; }
        }

        #endregion

        #region AtomicOtherTaxAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isAtomicOtherTaxAdjustmentsDirty = false;
        private TaxAdjustments m_AtomicOtherTaxAdjustments;

        [MTDataMember(Description = "These are the atomic other tax adjustments", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxAdjustments AtomicOtherTaxAdjustments
        {
            get { return m_AtomicOtherTaxAdjustments; }
            set
            {
                m_AtomicOtherTaxAdjustments = value;
                isAtomicOtherTaxAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAtomicOtherTaxAdjustmentsDirty
        {
            get { return isAtomicOtherTaxAdjustmentsDirty; }
        }

        #endregion

        #region IsPreBillTransaction

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsPreBillTransactionDirty = false;
        private bool m_IsPreBillTransaction;

        [MTDataMember(Description = "If true, this indicator shows that this is a pre-bill transaction.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsPreBillTransaction
        {
            get { return m_IsPreBillTransaction; }
            set
            {
                m_IsPreBillTransaction = value;
                isIsPreBillTransactionDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsPreBillTransactionDirty
        {
            get { return isIsPreBillTransactionDirty; }
        }

        #region IsPreBillTransaction Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.IsPreBillTransaction",
            DefaultValue = "IsPreBillTransaction",
            MTLocalizationId = "metratech.com/defaultproductview/IsPreBillTransaction",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string IsPreBillTransactionDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.IsPreBillTransaction");
            }
        }

        #endregion

        #endregion

        #region IsAdjusted

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsAdjustedDirty = false;
        private bool m_IsAdjusted;

        [MTDataMember(Description = "If true, this indicator shows that the adjustments had been applied.", Length = 40)
        ]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsAdjusted
        {
            get { return m_IsAdjusted; }
            set
            {
                m_IsAdjusted = value;
                isIsAdjustedDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsAdjustedDirty
        {
            get { return isIsAdjustedDirty; }
        }

        #region IsAdjusted Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.IsAdjusted",
            DefaultValue = "IsAdjusted",
            MTLocalizationId = "metratech.com/defaultproductview/IsAdjusted",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string IsAdjustedDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.IsAdjusted"); }
        }

        #endregion

        #endregion

        #region IsPreBillAdjusted

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsPreBillAdjustedDirty = false;
        private bool m_IsPreBillAdjusted;

        [MTDataMember(Description = "If true, this indicator shows that pre-bill adjustments had been applied.",
            Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsPreBillAdjusted
        {
            get { return m_IsPreBillAdjusted; }
            set
            {
                m_IsPreBillAdjusted = value;
                isIsPreBillAdjustedDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsPreBillAdjustedDirty
        {
            get { return isIsPreBillAdjustedDirty; }
        }

        #region IsPreBillAdjusted Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.IsPreBillAdjusted",
            DefaultValue = "IsPreBillAdjusted",
            MTLocalizationId = "metratech.com/defaultproductview/IsPreBillAdjusted",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string IsPreBillAdjustedDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.IsPreBillAdjusted");
            }
        }

        #endregion

        #endregion

        #region IsPostBillAdjusted

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsPostBillAdjustedDirty = false;
        private bool m_IsPostBillAdjusted;

        [MTDataMember(Description = "If true, this indicator shows that post-bill adjustments had been applied.",
            Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsPostBillAdjusted
        {
            get { return m_IsPostBillAdjusted; }
            set
            {
                m_IsPostBillAdjusted = value;
                isIsPostBillAdjustedDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsPostBillAdjustedDirty
        {
            get { return isIsPostBillAdjustedDirty; }
        }

        #region IsPostBillAdjusted Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.IsPostBillAdjusted",
            DefaultValue = "IsPostBillAdjusted",
            MTLocalizationId = "metratech.com/defaultproductview/IsPostBillAdjusted",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string IsPostBillAdjustedDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.IsPostBillAdjusted");
            }
        }

        #endregion

        #endregion

        #region CanAdjust

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCanAdjustDirty = false;
        private bool m_CanAdjust;

        [MTDataMember(Description = "Indicated wether adjustments can be applied.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool CanAdjust
        {
            get { return m_CanAdjust; }
            set
            {
                m_CanAdjust = value;
                isCanAdjustDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCanAdjustDirty
        {
            get { return isCanAdjustDirty; }
        }

        #region CanAdjust Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.CanAdjust",
            DefaultValue = "CanAdjust",
            MTLocalizationId = "metratech.com/defaultproductview/CanAdjust",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string CanAdjustDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.CanAdjust"); }
        }

        #endregion

        #endregion

        #region CanRebill

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCanRebillDirty = false;
        private bool m_CanRebill;

        [MTDataMember(Description = "Indicates wether re-billing is allowed.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool CanRebill
        {
            get { return m_CanRebill; }
            set
            {
                m_CanRebill = value;
                isCanRebillDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCanRebillDirty
        {
            get { return isCanRebillDirty; }
        }

        #region CanRebill Display Name

        [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.productview.defaultproductview.CanRebill",
            DefaultValue = "CanRebill",
            MTLocalizationId = "metratech.com/defaultproductview/CanRebill",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string CanRebillDisplayName
        {
            get { return ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.CanRebill"); }
        }

        #endregion

        #endregion

        #region CanManageAdjustments

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isCanManageAdjustmentsDirty = false;
        private bool m_CanManageAdjustments;

        [MTDataMember(Description = "Indicates wether adjustment management is allowed.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool CanManageAdjustments
        {
            get { return m_CanManageAdjustments; }
            set
            {
                m_CanManageAdjustments = value;
                isCanManageAdjustmentsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsCanManageAdjustmentsDirty
        {
            get { return isCanManageAdjustmentsDirty; }
        }

        #region CanManageAdjustments Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.CanManageAdjustments",
            DefaultValue = "CanManageAdjustments",
            MTLocalizationId = "metratech.com/defaultproductview/CanManageAdjustments",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string CanManageAdjustmentsDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.CanManageAdjustments");
            }
        }

        #endregion

        #endregion

        #region PreBillAdjustmentID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isPreBillAdjustmentIDDirty = false;
        private int m_PreBillAdjustmentID;

        [MTDataMember(Description = "This is the pre-bill adjustment identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int PreBillAdjustmentID
        {
            get { return m_PreBillAdjustmentID; }
            set
            {
                m_PreBillAdjustmentID = value;
                isPreBillAdjustmentIDDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsPreBillAdjustmentIDDirty
        {
            get { return isPreBillAdjustmentIDDirty; }
        }

        #region PreBillAdjustmentID Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.PreBillAdjustmentID",
            DefaultValue = "PreBillAdjustmentID",
            MTLocalizationId = "metratech.com/defaultproductview/PreBillAdjustmentID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string PreBillAdjustmentIDDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString("metratech.domainmodel.productview.defaultproductview.PreBillAdjustmentID");
            }
        }

        #endregion

        #endregion

        #region PostBillAdjustmentID

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isPostBillAdjustmentIDDirty = false;
        private int m_PostBillAdjustmentID;

        [MTDataMember(Description = "This is the post-bill adjustment identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int PostBillAdjustmentID
        {
            get { return m_PostBillAdjustmentID; }
            set
            {
                m_PostBillAdjustmentID = value;
                isPostBillAdjustmentIDDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsPostBillAdjustmentIDDirty
        {
            get { return isPostBillAdjustmentIDDirty; }
        }

        #region PostBillAdjustmentID Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.PostBillAdjustmentID",
            DefaultValue = "PostBillAdjustmentID",
            MTLocalizationId = "metratech.com/defaultproductview/PostBillAdjustmentID",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string PostBillAdjustmentIDDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.PostBillAdjustmentID");
            }
        }

        #endregion

        #endregion

        #region IsIntervalSoftClosed

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsIntervalSoftClosedDirty = false;
        private bool m_IsIntervalSoftClosed;

        [MTDataMember(Description = "Indicates that the interval had been soft closed.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsIntervalSoftClosed
        {
            get { return m_IsIntervalSoftClosed; }
            set
            {
                m_IsIntervalSoftClosed = value;
                isIsIntervalSoftClosedDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsIntervalSoftClosedDirty
        {
            get { return isIsIntervalSoftClosedDirty; }
        }

        #region IsIntervalSoftClosed Display Name

        [MTPropertyLocalizationAttribute(
            ResourceId = "metratech.domainmodel.productview.defaultproductview.IsIntervalSoftClosed",
            DefaultValue = "IsIntervalSoftClosed",
            MTLocalizationId = "metratech.com/defaultproductview/IsIntervalSoftClosed",
            Extension = "Core",
            LocaleSpace = "metratech.com/defaultproductview")]
        public string IsIntervalSoftClosedDisplayName
        {
            get
            {
                return
                    ResourceManager.GetString(
                        "metratech.domainmodel.productview.defaultproductview.IsIntervalSoftClosed");
            }
        }

        #endregion

        #endregion

        #region IsTaxInclusive

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsTaxInclusiveDirty = false;
        private bool? m_IsTaxInclusive;

        [MTDataMember(Description = "Is this tax inclusive?  Null means unknown", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool? IsTaxInclusive
        {
            get { return m_IsTaxInclusive; }
            set
            {
                m_IsTaxInclusive = value;
                isIsTaxInclusiveDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsTaxInclusiveDirty
        {
            get { return isIsTaxInclusiveDirty; }
        }

        #endregion

        #region IsTaxAlreadyCalculated

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsTaxAlreadyCalculatedDirty = false;
        private bool m_IsTaxAlreadyCalculated;

        [MTDataMember(Description = "Has this tax been calculated yet?", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsTaxAlreadyCalculated
        {
            get { return m_IsTaxAlreadyCalculated; }
            set
            {
                m_IsTaxAlreadyCalculated = value;
                isIsTaxAlreadyCalculatedDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsTaxAlreadyCalculatedDirty
        {
            get { return isIsTaxAlreadyCalculatedDirty; }
        }

        #region IsTaxInformational

        [DataMember(IsRequired = false, EmitDefaultValue = false)] private bool isIsTaxInformationalDirty = false;
        private bool m_IsTaxInformational;

        [MTDataMember(Description = "Is this tax informational only?", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool IsTaxInformational
        {
            get { return m_IsTaxInformational; }
            set
            {
                m_IsTaxInformational = value;
                isIsTaxInformationalDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIsTaxInformationalDirty
        {
            get { return isIsTaxInformationalDirty; }
        }

        #endregion

        #endregion

        public static Type[] KnownTypes()
        {
            return BaseObject.GetTypesFromAssemblyByAttribute(GENERATED_ASSEMBLY_NAME, typeof (MTProductViewAttribute));
        }

        #region Private Data

        [NonSerialized] private const string GENERATED_ASSEMBLY_NAME = "MetraTech.DomainModel.Billing.Generated";

        #endregion
    }
}

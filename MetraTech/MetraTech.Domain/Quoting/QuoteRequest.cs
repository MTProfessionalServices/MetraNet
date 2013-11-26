using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
    [DataContract]
    [Serializable]
    public class QuoteRequest
    {
        #region Accounts

        private bool isAccountsDirty;
        private List<int> _accounts;
        [MTDataMember(Description = "List of accounts to create quote for")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<int> Accounts
        {
            get { return _accounts ?? (_accounts = new List<int>()); }
            set
            {
                _accounts = value ?? new List<int>();
                isAccountsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsAccountsDirty
        {
            get { return isAccountsDirty; }
        }

        #endregion

        #region ProductOfferings

        private bool isProductOfferingsDirty;
        private List<int> _productOfferings;
        [MTDataMember(Description = "List of product offerings to create quote for")]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<int> ProductOfferings
        {
            get { return _productOfferings; }
            set
            {
                _productOfferings = value ?? new List<int>();
                isProductOfferingsDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsProductOfferingsDirty
        {
            get { return isProductOfferingsDirty; }
        }

        #endregion

        #region QuoteIdentifier

        private bool isQuoteIdentifierDirty;
        private string m_QuoteIdentifier;
        [MTDataMember(Description = "Quote identifier", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string QuoteIdentifier
        {
            get { return m_QuoteIdentifier; }
            set
            {
                m_QuoteIdentifier = value;
                isQuoteIdentifierDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsQuoteIdentifierDirty
        {
            get { return isQuoteIdentifierDirty; }
        }

        #endregion

        #region QuoteDescription

        private bool isQuoteDescriptionDirty;
        private string m_QuoteDescription;
        [MTDataMember(Description = "Quote identifier", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string QuoteDescription
        {
            get { return m_QuoteDescription; }
            set
            {
                m_QuoteDescription = value;
                isQuoteDescriptionDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsQuoteDescriptionDirty
        {
            get { return isQuoteDescriptionDirty; }
        }

        #endregion

        #region Quoting parameters

        private List<IndividualPrice> _icbPrices;
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        [MTDataMember(Description = "Individual price parameters", Length = 40)]
        public List<IndividualPrice> IcbPrices
        {
            get { return _icbPrices ?? (_icbPrices = new List<IndividualPrice>()); }
            set
            {
                _icbPrices = value ?? new List<IndividualPrice>();
                IsIcbPricesDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsIcbPricesDirty { get; set; }

        #endregion

        #region EffectiveDate

        private bool isEffectiveDateDirty;
        private DateTime m_EffectiveDate;
        [MTDataMember(Description = "Quote effective date", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime EffectiveDate
        {
            get { return m_EffectiveDate; }
            set
            {
                m_EffectiveDate = value;
                isEffectiveDateDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsEffectiveDateDirty
        {
            get { return isEffectiveDateDirty; }
        }

        #endregion

        #region EffectiveEndDate

        private bool isEffectiveEndDateDirty;
        private DateTime m_EffectiveEndDate;
        [MTDataMember(Description = "Quote effective end date", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime EffectiveEndDate
        {
            get { return m_EffectiveEndDate; }
            set
            {
                m_EffectiveEndDate = value;
                isEffectiveEndDateDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsEffectiveEndDateDirty
        {
            get { return isEffectiveEndDateDirty; }
        }

        #endregion

        #region Localization

        private bool isLocalizationDirty;
        private string m_Localization;
        [MTDataMember(Description = "Quote localization", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Localization
        {
            get { return m_Localization; }
            set
            {
                m_Localization = value;
                isLocalizationDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsLocalizationDirty
        {
            get { return isLocalizationDirty; }
        }

        #endregion

        #region ReportParameters

        private bool isReportParametersDirty;
        private ReportParams m_ReportParameters;
        [MTDataMember(Description = "Quote report parameters", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ReportParams ReportParameters
        {
            get { return m_ReportParameters; }
            set
            {
                m_ReportParameters = value;
                isReportParametersDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsReportParametersDirty
        {
            get { return isReportParametersDirty; }
        }

        #endregion

        #region SubscriptionParameters

        private bool isSubscriptionParametersDirty;
        private SubscriptionParameters m_SubscriptionParameters;
        [MTDataMember(Description = "Quote Subscription parameters", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public SubscriptionParameters SubscriptionParameters
        {
            get { return m_SubscriptionParameters; }
            set
            {
                m_SubscriptionParameters = value;
                isSubscriptionParametersDirty = true;
            }
        }

        [ScriptIgnore]
        public bool IsSubscriptionParametersDirty
        {
            get { return isSubscriptionParametersDirty; }
        }

        #endregion

        [MTDataMember(Description = "Shoud response contain Quote Artifacts (Chrages, bathec ID, Usage interval, subscription Ids and etc.)", Length = 80)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool ShowQuoteArtefacts { get; set; }

        public QuoteRequest()
        {
            Accounts = new List<int>();
            ProductOfferings = new List<int>();
            SubscriptionParameters = new SubscriptionParameters();
            IcbPrices = new List<IndividualPrice>();

            EffectiveDate = MetraTime.Now;
            EffectiveEndDate = MetraTime.Now;

            ReportParameters = new ReportParams { PDFReport = false };

            ShowQuoteArtefacts = false;
        }
    }
}
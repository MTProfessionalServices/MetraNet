using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class ReportParameters : BaseObject
    {
        #region ReportView
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportViewDirty = false;
        private ReportViewType m_ReportView;
        [MTDataMember(Description = "This is the type or the report view.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ReportViewType ReportView
        {
          get { return m_ReportView; }
          set
          {
              m_ReportView = value;
              isReportViewDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportViewDirty
        {
          get { return isReportViewDirty; }
        }
        #endregion

        #region ReportView Value Display Name
        public string ReportViewValueDisplayName
        {
          get
          {
            return GetDisplayName(this.ReportView);
          }
          set
          {
            this.ReportView = ((ReportViewType)(GetEnumInstanceByDisplayName(typeof(ReportViewType), value)));
          }
        }
        #endregion

        #region DateRange
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDateRangeDirty = false;
        private TimeSlice m_DateRange;
        [MTDataMember(Description = "This is the date range of the report.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TimeSlice DateRange
        {
          get { return m_DateRange; }
          set
          {
              m_DateRange = value;
              isDateRangeDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsDateRangeDirty
        {
          get { return isDateRangeDirty; }
        }
        #endregion

        #region UseSecondPassData
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUseSecondPassDataDirty = false;
        private bool m_UseSecondPassData;
        [MTDataMember(Description = "This flag indicates wether second pass data should be used.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool UseSecondPassData
        {
          get { return m_UseSecondPassData; }
          set
          {
              m_UseSecondPassData = value;
              isUseSecondPassDataDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsUseSecondPassDataDirty
        {
          get { return isUseSecondPassDataDirty; }
        }
        #endregion

        #region InlineAdjustments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInlineAdjustmentsDirty = false;
        private bool m_InlineAdjustments;
        [MTDataMember(Description = "This flag indicates wether adjustments should be inlined.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool InlineAdjustments
        {
          get { return m_InlineAdjustments; }
          set
          {
              m_InlineAdjustments = value;
              isInlineAdjustmentsDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsInlineAdjustmentsDirty
        {
          get { return isInlineAdjustmentsDirty; }
        }
        #endregion

        #region InlineVATTaxes
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInlineVATTaxesDirty = false;
        private bool m_InlineVATTaxes;
        [MTDataMember(Description = "This flag indicates wether VAT taxes should be inlined.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool InlineVATTaxes
        {
          get { return m_InlineVATTaxes; }
          set
          {
              m_InlineVATTaxes = value;
              isInlineVATTaxesDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsInlineVATTaxesDirty
        {
          get { return isInlineVATTaxesDirty; }
        }
        #endregion

        #region Language
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isLanguageDirty = false;
        private LanguageCode m_Language;
        [MTDataMember(Description = "This is the language code.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public LanguageCode Language
        {
          get { return m_Language; }
          set
          {
              m_Language = value;
              isLanguageDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsLanguageDirty
        {
          get { return isLanguageDirty; }
        }
        #endregion
    
    }
}
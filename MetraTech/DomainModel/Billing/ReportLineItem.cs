using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    [KnownType(typeof(ReportLevel))]
    [KnownType(typeof(ReportCharge))]
    public class ReportLineItem : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private int m_ID;
        [MTDataMember(Description = "This is the line item identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ID
        {
          get { return m_ID; }
          set
          {
              m_ID = value;
              isIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsIDDirty
        {
          get { return isIDDirty; }
        }
        #endregion

        #region Currency
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrencyDirty = false;
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
        #endregion

        #region Amount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAmountDirty = false;
        private decimal m_Amount;
        [MTDataMember(Description = "This is the line item amount.", Length = 40)]
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
        #endregion

        #region DisplayAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayAmountDirty = false;
        private decimal m_DisplayAmount;
        [MTDataMember(Description = "This is the amount to be displayed.", Length = 40)]
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
        #endregion

        #region DisplayAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayAmountAsStringDirty = false;
        private string m_DisplayAmountAsString;
        [MTDataMember(Description = "This is the textual representation of the amount to be displayed.", Length = 40)]
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
        #endregion

        #region AmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAmountAsStringDirty = false;
        private string m_AmountAsString;
        [MTDataMember(Description = "This is the text representation of the amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AmountAsString
        {
          get { return m_AmountAsString; }
          set
          {
              m_AmountAsString = value;
              isAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAmountAsStringDirty
        {
          get { return isAmountAsStringDirty; }
        }
        #endregion

        #region AdjustmentInfo
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentInfoDirty = false;
        private Adjustments m_AdjustmentInfo;
        [MTDataMember(Description = "These are the adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Adjustments AdjustmentInfo
        {
          get { return m_AdjustmentInfo; }
          set
          {
              m_AdjustmentInfo = value;
              isAdjustmentInfoDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdjustmentInfoDirty
        {
          get { return isAdjustmentInfoDirty; }
        }
        #endregion

        #region PreAndPostBillTotalTaxAdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreAndPostBillTotalTaxAdjustmentAmountDirty = false;
        private decimal m_PreAndPostBillTotalTaxAdjustmentAmount;
        [MTDataMember(Description = "This is the total amount of pre and post bill tax adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PreAndPostBillTotalTaxAdjustmentAmount
        {
          get { return m_PreAndPostBillTotalTaxAdjustmentAmount; }
          set
          {
              m_PreAndPostBillTotalTaxAdjustmentAmount = value;
              isPreAndPostBillTotalTaxAdjustmentAmountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreAndPostBillTotalTaxAdjustmentAmountDirty
        {
          get { return isPreAndPostBillTotalTaxAdjustmentAmountDirty; }
        }
        #endregion

        #region PreAndPostBillTotalTaxAdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreAndPostBillTotalTaxAdjustmentAmountAsStringDirty = false;
        private string m_PreAndPostBillTotalTaxAdjustmentAmountAsString;
        [MTDataMember(Description = "This is the text representation of the total amount of pre and post bill tax adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PreAndPostBillTotalTaxAdjustmentAmountAsString
        {
          get { return m_PreAndPostBillTotalTaxAdjustmentAmountAsString; }
          set
          {
              m_PreAndPostBillTotalTaxAdjustmentAmountAsString = value;
              isPreAndPostBillTotalTaxAdjustmentAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreAndPostBillTotalTaxAdjustmentAmountAsStringDirty
        {
          get { return isPreAndPostBillTotalTaxAdjustmentAmountAsStringDirty; }
        }
        #endregion
                        
        #region TotalTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTotalTaxDirty = false;
        private TaxData m_TotalTax;
        [MTDataMember(Description = "This is the total tax amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public TaxData TotalTax
        {
          get { return m_TotalTax; }
          set
          {
              m_TotalTax = value;
              isTotalTaxDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsTotalTaxDirty
        {
          get { return isTotalTaxDirty; }
        }
        #endregion

        #region FederalTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isFederalTaxDirty = false;
        private TaxData m_FederalTax;
        [MTDataMember(Description = "This is the federal tax amount.", Length = 40)]
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
        #endregion

        #region StateTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStateTaxDirty = false;
        private TaxData m_StateTax;
        [MTDataMember(Description = "This is the state tax amount.", Length = 40)]
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
        #endregion

        #region CountyTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCountyTaxDirty = false;
        private TaxData m_CountyTax;
        [MTDataMember(Description = "This is the county tax amount.", Length = 40)]
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
        #endregion

        #region LocalTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isLocalTaxDirty = false;
        private TaxData m_LocalTax;
        [MTDataMember(Description = "This is the local tax amount.", Length = 40)]
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
        #endregion

        #region OtherTax
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isOtherTaxDirty = false;
        private TaxData m_OtherTax;
        [MTDataMember(Description = "This is the other tax amount.", Length = 40)]
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
        #endregion
    }
}
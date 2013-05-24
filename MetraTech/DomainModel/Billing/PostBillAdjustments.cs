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
    public class PostBillAdjustments : BaseObject
    {
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

        #region NumAdjustments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumAdjustmentsDirty = false;
        private int m_NumAdjustments;
        [MTDataMember(Description = "This is the number of adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumAdjustments
        {
          get { return m_NumAdjustments; }
          set
          {
              m_NumAdjustments = value;
              isNumAdjustmentsDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsNumAdjustmentsDirty
        {
          get { return isNumAdjustmentsDirty; }
        }
        #endregion

        #region AdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentAmountDirty = false;
        private decimal m_AdjustmentAmount;
        [MTDataMember(Description = "This is the adjustment amount.", Length = 40)]
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
        #endregion

        #region AdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdjustmentAmountAsStringDirty = false;
        private string m_AdjustmentAmountAsString;
        [MTDataMember(Description = "This is the text representation of the adjustment amount.", Length = 40)]
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
        #endregion

        #region AdjustmentDisplayAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentDisplayAmountDirty = false;
    private decimal m_AdjustmentDisplayAmount;
    [MTDataMember(Description = "This is the display amount based on inline tax  flag.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AdjustmentDisplayAmount
    {
      get { return m_AdjustmentDisplayAmount;   }
      set
      {
          m_AdjustmentDisplayAmount = value;
          isAdjustmentDisplayAmountDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAdjustmentDisplayAmountDirty
    {
      get { return isAdjustmentDisplayAmountDirty; }
    }
    #endregion

        #region AdjustmentDisplayAmountAsString
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentDisplayAmountAsStringDirty = false;
    private string m_AdjustmentDisplayAmountAsString;
    [MTDataMember(Description = "This is the localized display amount in a string format.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AdjustmentDisplayAmountAsString
    {
      get { return m_AdjustmentDisplayAmountAsString; }
      set
      {
          m_AdjustmentDisplayAmountAsString = value;
          isAdjustmentDisplayAmountAsStringDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAdjustmentDisplayAmountAsStringDirty
    {
      get { return isAdjustmentDisplayAmountAsStringDirty; }
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
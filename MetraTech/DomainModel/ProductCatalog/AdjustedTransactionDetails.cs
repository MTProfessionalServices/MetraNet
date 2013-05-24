using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.Web.Script.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;


namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]
  public class AdjustedTransactionDetail : BaseObject
  {
    #region AdjTrxId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjTrxIdDirty = false;
    private int m_AdjTrxId;
    [MTDataMember(Description = "AdjTrxId ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int AdjTrxId
    {
      get { return m_AdjTrxId; }
      set
      {
        m_AdjTrxId = value;
        isAdjTrxIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdjTrxIdDirty
    {
      get { return isAdjTrxIdDirty; }
    }
    #endregion

    #region AdjustmentAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentAmountDirty = false;
    private decimal m_AdjustmentAmount;
    [MTDataMember(Description = "Adjustment Amount", Length = 40)]
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

    #region AdjustmentCreationDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentCreationDateDirty = false;
    private DateTime m_AdjustmentCreationDate;
    [MTDataMember(Description = "This is the adjustment creation date ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime AdjustmentCreationDate
    {
      get { return m_AdjustmentCreationDate; }
      set
      {
        m_AdjustmentCreationDate = value;
        isAdjustmentCreationDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdjustmentCreationDateDirty
    {
      get { return isAdjustmentCreationDateDirty; }
    }
    #endregion

    #region AdjustmentCurrency
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentCurrencyDirty = false;
    private SystemCurrencies m_AdjustmentCurrency;
    [MTDataMember(Description = "AdjustmentCurrency of the adjustment. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SystemCurrencies AdjustmentCurrency
    {
      get { return m_AdjustmentCurrency; }
      set
      {
        m_AdjustmentCurrency = value;
        isAdjustmentCurrencyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdjustmentCurrencyDirty
    {
      get { return isAdjustmentCurrencyDirty; }
    }
    #endregion

    #region Status
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStatusDirty = false;
    private string m_Status;
    [MTDataMember(Description = "Adjustment Status", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Status
    {
      get { return m_Status; }
      set
      {
        m_Status = value;
        isStatusDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStatusDirty
    {
      get { return isStatusDirty; }
    }
    #endregion

    #region AdjustmentTemplateDisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentTemplateDisplayNameDirty = false;
    private string m_AdjustmentTemplateDisplayName;
    [MTDataMember(Description = "The Adjustment Template Display Name", Length = 40)]
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
    #endregion

    #region AdjustmentType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentTypeDirty = false;
    private int m_AdjustmentType;
    [MTDataMember(Description = "This is the adjustment type.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int AdjustmentType
    {
      get { return m_AdjustmentType; }
      set
      {
          m_AdjustmentType = value;
          isAdjustmentTypeDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAdjustmentTypeDirty
    {
      get { return isAdjustmentTypeDirty; }
    }
    #endregion

    #region AdjustmentUsageInterval
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentUsageIntervalDirty = false;
    private int m_AdjustmentUsageInterval;
    [MTDataMember(Description = "The Adjustment Usage Interval", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int AdjustmentUsageInterval
    {
      get { return m_AdjustmentUsageInterval; }
      set
      {
        m_AdjustmentUsageInterval = value;
        isAdjustmentUsageIntervalDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdjustmentUsageIntervalDirty
    {
      get { return isAdjustmentUsageIntervalDirty; }
    }
    #endregion

    #region AtomicPostbillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillAdjAmtDirty = false;
    private decimal m_AtomicPostbillAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillAdjAmt
    {
      get { return m_AtomicPostbillAdjAmt; }
      set
      {
        m_AtomicPostbillAdjAmt = value;
        isAtomicPostbillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillAdjAmtDirty
    {
      get { return isAtomicPostbillAdjAmtDirty; }
    }
    #endregion

    #region AtomicPostbillAdjedAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillAdjedAmtDirty = false;
    private decimal m_AtomicPostbillAdjedAmt;
    [MTDataMember(Description = "The Atomic Postbill Adjed Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillAdjedAmt
    {
      get { return m_AtomicPostbillAdjedAmt; }
      set
      {
        m_AtomicPostbillAdjedAmt = value;
        isAtomicPostbillAdjedAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillAdjedAmtDirty
    {
      get { return isAtomicPostbillAdjedAmtDirty; }
    }
    #endregion

    #region AtomicPostbillCntyTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillCntyTaxAdjAmtDirty = false;
    private decimal m_AtomicPostbillCntyTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill Country tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillCntyTaxAdjAmt
    {
      get { return m_AtomicPostbillCntyTaxAdjAmt; }
      set
      {
        m_AtomicPostbillCntyTaxAdjAmt = value;
        isAtomicPostbillCntyTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillCntyTaxAdjAmtDirty
    {
      get { return isAtomicPostbillCntyTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPostbillFedTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillFedTaxAdjAmtDirty = false;
    private decimal m_AtomicPostbillFedTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill Fed Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillFedTaxAdjAmt
    {
      get { return m_AtomicPostbillFedTaxAdjAmt; }
      set
      {
        m_AtomicPostbillFedTaxAdjAmt = value;
        isAtomicPostbillFedTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillFedTaxAdjAmtDirty
    {
      get { return isAtomicPostbillFedTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPostbillLocalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillLocalTaxAdjAmtDirty = false;
    private decimal m_AtomicPostbillLocalTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill Local Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillLocalTaxAdjAmt
    {
      get { return m_AtomicPostbillLocalTaxAdjAmt; }
      set
      {
        m_AtomicPostbillLocalTaxAdjAmt = value;
        isAtomicPostbillLocalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillLocalTaxAdjAmtDirty
    {
      get { return isAtomicPostbillLocalTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPostbillOtherTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillOtherTaxAdjAmtDirty = false;
    private decimal m_AtomicPostbillOtherTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill Other Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillOtherTaxAdjAmt
    {
      get { return m_AtomicPostbillOtherTaxAdjAmt; }
      set
      {
        m_AtomicPostbillOtherTaxAdjAmt = value;
        isAtomicPostbillOtherTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillOtherTaxAdjAmtDirty
    {
      get { return isAtomicPostbillOtherTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPostbillStateTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillStateTaxAdjAmtDirty = false;
    private decimal m_AtomicPostbillStateTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill State Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillStateTaxAdjAmt
    {
      get { return m_AtomicPostbillStateTaxAdjAmt; }
      set
      {
        m_AtomicPostbillStateTaxAdjAmt = value;
        isAtomicPostbillStateTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillStateTaxAdjAmtDirty
    {
      get { return isAtomicPostbillStateTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPostbillTotalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPostbillTotalTaxAdjAmtDirty = false;
    private decimal m_AtomicPostbillTotalTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Postbill Total Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPostbillTotalTaxAdjAmt
    {
      get { return m_AtomicPostbillTotalTaxAdjAmt; }
      set
      {
        m_AtomicPostbillTotalTaxAdjAmt = value;
        isAtomicPostbillTotalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPostbillTotalTaxAdjAmtDirty
    {
      get { return isAtomicPostbillTotalTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillAdjAmtDirty = false;
    private decimal m_AtomicPrebillAdjAmt;
    [MTDataMember(Description = "The Atomic Prebill Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillAdjAmt
    {
      get { return m_AtomicPrebillAdjAmt; }
      set
      {
        m_AtomicPrebillAdjAmt = value;
        isAtomicPrebillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillAdjAmtDirty
    {
      get { return isAtomicPrebillAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillAdjedAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillAdjedAmtDirty = false;
    private decimal m_AtomicPrebillAdjedAmt;
    [MTDataMember(Description = "Atomic Prebill Adjed Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillAdjedAmt
    {
      get { return m_AtomicPrebillAdjedAmt; }
      set
      {
        m_AtomicPrebillAdjedAmt = value;
        isAtomicPrebillAdjedAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillAdjedAmtDirty
    {
      get { return isAtomicPrebillAdjedAmtDirty; }
    }
    #endregion

    #region AtomicPrebillCntyTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillCntyTaxAdjAmtDirty = false;
    private decimal m_AtomicPrebillCntyTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Prebill Cnty Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillCntyTaxAdjAmt
    {
      get { return m_AtomicPrebillCntyTaxAdjAmt; }
      set
      {
        m_AtomicPrebillCntyTaxAdjAmt = value;
        isAtomicPrebillCntyTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillCntyTaxAdjAmtDirty
    {
      get { return isAtomicPrebillCntyTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillFedTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillFedTaxAdjAmtDirty = false;
    private decimal m_AtomicPrebillFedTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Prebill Fed Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillFedTaxAdjAmt
    {
      get { return m_AtomicPrebillFedTaxAdjAmt; }
      set
      {
        m_AtomicPrebillFedTaxAdjAmt = value;
        isAtomicPrebillFedTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillFedTaxAdjAmtDirty
    {
      get { return isAtomicPrebillFedTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillLocalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillLocalTaxAdjAmtDirty = false;
    private decimal m_AtomicPrebillLocalTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Prebill Local Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillLocalTaxAdjAmt
    {
      get { return m_AtomicPrebillLocalTaxAdjAmt; }
      set
      {
        m_AtomicPrebillLocalTaxAdjAmt = value;
        isAtomicPrebillLocalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillLocalTaxAdjAmtDirty
    {
      get { return isAtomicPrebillLocalTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillOtherTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillOtherTaxAdjAmtDirty = false;
    private decimal m_AtomicPrebillOtherTaxAdjAmt;
    [MTDataMember(Description = "Atomic Prebill Other Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillOtherTaxAdjAmt
    {
      get { return m_AtomicPrebillOtherTaxAdjAmt; }
      set
      {
        m_AtomicPrebillOtherTaxAdjAmt = value;
        isAtomicPrebillOtherTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillOtherTaxAdjAmtDirty
    {
      get { return isAtomicPrebillOtherTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillStateTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillStateTaxAdjAmtDirty = false;
    private decimal m_AtomicPrebillStateTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Prebill State Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillStateTaxAdjAmt
    {
      get { return m_AtomicPrebillStateTaxAdjAmt; }
      set
      {
        m_AtomicPrebillStateTaxAdjAmt = value;
        isAtomicPrebillStateTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillStateTaxAdjAmtDirty
    {
      get { return isAtomicPrebillStateTaxAdjAmtDirty; }
    }
    #endregion

    #region AtomicPrebillTotalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAtomicPrebillTotalTaxAdjAmtDirty = false;
    private decimal m_AtomicPrebillTotalTaxAdjAmt;
    [MTDataMember(Description = "The Atomic Prebill Total Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AtomicPrebillTotalTaxAdjAmt
    {
      get { return m_AtomicPrebillTotalTaxAdjAmt; }
      set
      {
        m_AtomicPrebillTotalTaxAdjAmt = value;
        isAtomicPrebillTotalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAtomicPrebillTotalTaxAdjAmtDirty
    {
      get { return isAtomicPrebillTotalTaxAdjAmtDirty; }
    }
    #endregion

    #region CanAdjust
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanAdjustDirty = false;
    private bool m_CanAdjust;
    [MTDataMember(Description = "Can Adjust", Length = 40)]
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
    #endregion

    #region CanManageAdjustments
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanManageAdjustmentsDirty = false;
    private bool m_CanManageAdjustments;
    [MTDataMember(Description = "Can Manage Adjustments", Length = 40)]
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
    #endregion

    #region CanManagePostbillAdjustment
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanManagePostbillAdjustmentDirty = false;
    private bool m_CanManagePostbillAdjustment;
    [MTDataMember(Description = "Can Manage Postbill Adjustment", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool CanManagePostbillAdjustment
    {
      get { return m_CanManagePostbillAdjustment; }
      set
      {
        m_CanManagePostbillAdjustment = value;
        isCanManagePostbillAdjustmentDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCanManagePostbillAdjustmentDirty
    {
      get { return isCanManagePostbillAdjustmentDirty; }
    }
    #endregion

    #region CanManagePrebillAdjustment
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanManagePrebillAdjustmentDirty = false;
    private bool m_CanManagePrebillAdjustment;
    [MTDataMember(Description = "Can Manage Prebill Adjustment", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool CanManagePrebillAdjustment
    {
      get { return m_CanManagePrebillAdjustment; }
      set
      {
        m_CanManagePrebillAdjustment = value;
        isCanManagePrebillAdjustmentDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCanManagePrebillAdjustmentDirty
    {
      get { return isCanManagePrebillAdjustmentDirty; }
    }
    #endregion

    #region CanRebill
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCanRebillDirty = false;
    private bool m_CanRebill;
    [MTDataMember(Description = "Can Rebill", Length = 40)]
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
    #endregion

    #region CompoundPostbillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillAdjAmtDirty = false;
    private decimal m_CompoundPostbillAdjAmt;
    [MTDataMember(Description = "Compound Postbill Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillAdjAmt
    {
      get { return m_CompoundPostbillAdjAmt; }
      set
      {
        m_CompoundPostbillAdjAmt = value;
        isCompoundPostbillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillAdjAmtDirty
    {
      get { return isCompoundPostbillAdjAmtDirty; }
    }
    #endregion

    #region CompoundPostbillAdjedAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillAdjedAmtDirty = false;
    private decimal m_CompoundPostbillAdjedAmt;
    [MTDataMember(Description = "Compound Postbill Adjed Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillAdjedAmt
    {
      get { return m_CompoundPostbillAdjedAmt; }
      set
      {
        m_CompoundPostbillAdjedAmt = value;
        isCompoundPostbillAdjedAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillAdjedAmtDirty
    {
      get { return isCompoundPostbillAdjedAmtDirty; }
    }
    #endregion

    #region CompoundPostbillCntyTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillCntyTaxAdjAmtDirty = false;
    private decimal m_CompoundPostbillCntyTaxAdjAmt;
    [MTDataMember(Description = "Compound Postbill Cnty Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillCntyTaxAdjAmt
    {
      get { return m_CompoundPostbillCntyTaxAdjAmt; }
      set
      {
        m_CompoundPostbillCntyTaxAdjAmt = value;
        isCompoundPostbillCntyTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillCntyTaxAdjAmtDirty
    {
      get { return isCompoundPostbillCntyTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPostbillFedTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillFedTaxAdjAmtDirty = false;
    private decimal m_CompoundPostbillFedTaxAdjAmt;
    [MTDataMember(Description = "The Compound Postbill Fed Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillFedTaxAdjAmt
    {
      get { return m_CompoundPostbillFedTaxAdjAmt; }
      set
      {
        m_CompoundPostbillFedTaxAdjAmt = value;
        isCompoundPostbillFedTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillFedTaxAdjAmtDirty
    {
      get { return isCompoundPostbillFedTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPostbillLocalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillLocalTaxAdjAmtDirty = false;
    private decimal m_CompoundPostbillLocalTaxAdjAmt;
    [MTDataMember(Description = "The Compound Postbill Local Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillLocalTaxAdjAmt
    {
      get { return m_CompoundPostbillLocalTaxAdjAmt; }
      set
      {
        m_CompoundPostbillLocalTaxAdjAmt = value;
        isCompoundPostbillLocalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillLocalTaxAdjAmtDirty
    {
      get { return isCompoundPostbillLocalTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPostbillOtherTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillOtherTaxAdjAmtDirty = false;
    private decimal m_CompoundPostbillOtherTaxAdjAmt;
    [MTDataMember(Description = "Compound Postbill Other Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillOtherTaxAdjAmt
    {
      get { return m_CompoundPostbillOtherTaxAdjAmt; }
      set
      {
        m_CompoundPostbillOtherTaxAdjAmt = value;
        isCompoundPostbillOtherTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillOtherTaxAdjAmtDirty
    {
      get { return isCompoundPostbillOtherTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPostbillStateTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillStateTaxAdjAmtDirty = false;
    private decimal m_CompoundPostbillStateTaxAdjAmt;
    [MTDataMember(Description = "The Compound Postbill State Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillStateTaxAdjAmt
    {
      get { return m_CompoundPostbillStateTaxAdjAmt; }
      set
      {
        m_CompoundPostbillStateTaxAdjAmt = value;
        isCompoundPostbillStateTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillStateTaxAdjAmtDirty
    {
      get { return isCompoundPostbillStateTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPostbillTotalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPostbillTotalTaxAdjAmtDirty = false;
    private decimal m_CompoundPostbillTotalTaxAdjAmt;
    [MTDataMember(Description = "The Compound Postbill Total Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPostbillTotalTaxAdjAmt
    {
      get { return m_CompoundPostbillTotalTaxAdjAmt; }
      set
      {
        m_CompoundPostbillTotalTaxAdjAmt = value;
        isCompoundPostbillTotalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPostbillTotalTaxAdjAmtDirty
    {
      get { return isCompoundPostbillTotalTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPrebillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillAdjAmtDirty = false;
    private decimal m_CompoundPrebillAdjAmt;
    [MTDataMember(Description = "The Compound Prebill Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillAdjAmt
    {
      get { return m_CompoundPrebillAdjAmt; }
      set
      {
        m_CompoundPrebillAdjAmt = value;
        isCompoundPrebillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillAdjAmtDirty
    {
      get { return isCompoundPrebillAdjAmtDirty; }
    }
    #endregion

    #region CompoundPrebillAdjedAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillAdjedAmtDirty = false;
    private decimal m_CompoundPrebillAdjedAmt;
    [MTDataMember(Description = "The Compound Prebill Adjed Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillAdjedAmt
    {
      get { return m_CompoundPrebillAdjedAmt; }
      set
      {
        m_CompoundPrebillAdjedAmt = value;
        isCompoundPrebillAdjedAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillAdjedAmtDirty
    {
      get { return isCompoundPrebillAdjedAmtDirty; }
    }
    #endregion

    #region CompoundPrebillCntyTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillCntyTaxAdjAmtDirty = false;
    private decimal m_CompoundPrebillCntyTaxAdjAmt;
    [MTDataMember(Description = "The Compound Prebill Cnty Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillCntyTaxAdjAmt
    {
      get { return m_CompoundPrebillCntyTaxAdjAmt; }
      set
      {
        m_CompoundPrebillCntyTaxAdjAmt = value;
        isCompoundPrebillCntyTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillCntyTaxAdjAmtDirty
    {
      get { return isCompoundPrebillCntyTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPrebillFedTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillFedTaxAdjAmtDirty = false;
    private decimal m_CompoundPrebillFedTaxAdjAmt;
    [MTDataMember(Description = "The Compound Prebill Fed Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillFedTaxAdjAmt
    {
      get { return m_CompoundPrebillFedTaxAdjAmt; }
      set
      {
        m_CompoundPrebillFedTaxAdjAmt = value;
        isCompoundPrebillFedTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillFedTaxAdjAmtDirty
    {
      get { return isCompoundPrebillFedTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPrebillLocalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillLocalTaxAdjAmtDirty = false;
    private decimal m_CompoundPrebillLocalTaxAdjAmt;
    [MTDataMember(Description = "The Compound Prebill Local Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillLocalTaxAdjAmt
    {
      get { return m_CompoundPrebillLocalTaxAdjAmt; }
      set
      {
        m_CompoundPrebillLocalTaxAdjAmt = value;
        isCompoundPrebillLocalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillLocalTaxAdjAmtDirty
    {
      get { return isCompoundPrebillLocalTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPrebillOtherTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillOtherTaxAdjAmtDirty = false;
    private decimal m_CompoundPrebillOtherTaxAdjAmt;
    [MTDataMember(Description = "The Compound Prebill Other Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillOtherTaxAdjAmt
    {
      get { return m_CompoundPrebillOtherTaxAdjAmt; }
      set
      {
        m_CompoundPrebillOtherTaxAdjAmt = value;
        isCompoundPrebillOtherTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillOtherTaxAdjAmtDirty
    {
      get { return isCompoundPrebillOtherTaxAdjAmtDirty; }
    }
    #endregion

    #region CompoundPrebillTotalTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompoundPrebillTotalTaxAdjAmtDirty = false;
    private decimal m_CompoundPrebillTotalTaxAdjAmt;
    [MTDataMember(Description = "The Compound Prebill Total Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompoundPrebillTotalTaxAdjAmt
    {
      get { return m_CompoundPrebillTotalTaxAdjAmt; }
      set
      {
        m_CompoundPrebillTotalTaxAdjAmt = value;
        isCompoundPrebillTotalTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompoundPrebillTotalTaxAdjAmtDirty
    {
      get { return isCompoundPrebillTotalTaxAdjAmtDirty; }
    }
    #endregion

    #region CompundPrebillStateTaxAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompundPrebillStateTaxAdjAmtDirty = false;
    private decimal m_CompundPrebillStateTaxAdjAmt;
    [MTDataMember(Description = "Compund Prebill State Tax Adj Amt", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal CompundPrebillStateTaxAdjAmt
    {
      get { return m_CompundPrebillStateTaxAdjAmt; }
      set
      {
        m_CompundPrebillStateTaxAdjAmt = value;
        isCompundPrebillStateTaxAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompundPrebillStateTaxAdjAmtDirty
    {
      get { return isCompundPrebillStateTaxAdjAmtDirty; }
    }
    #endregion

    #region CountyTaxAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCountyTaxAmountDirty = false;
    private decimal m_CountyTaxAmount;
    [MTDataMember(Description = "The County Tax Amount", Length = 40)]
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
    #endregion

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "The Adjustment Description ", Length = 40)]
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

    #region DivAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDivAmountDirty = false;
    private decimal m_DivAmount;
    [MTDataMember(Description = "The Division Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal DivAmount
    {
      get { return m_DivAmount; }
      set
      {
        m_DivAmount = value;
        isDivAmountDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDivAmountDirty
    {
      get { return isDivAmountDirty; }
    }
    #endregion

    #region DivCurrency
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDivCurrencyDirty = false;
    private SystemCurrencies m_DivCurrency;
    [MTDataMember(Description = "The Division Currency of the adjustment. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SystemCurrencies DivCurrency
    {
      get { return m_DivCurrency; }
      set
      {
        m_DivCurrency = value;
        isDivCurrencyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDivCurrencyDirty
    {
      get { return isDivCurrencyDirty; }
    }
    #endregion

    #region FederalTaxAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFederalTaxAmountDirty = false;
    private decimal m_FederalTaxAmount;
    [MTDataMember(Description = "The Federal tax amount", Length = 40)]
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
    #endregion

    #region LanguageCode
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLanguageCodeDirty = false;
    private LanguageCode m_LanguageCode;
    [MTDataMember(Description = "Language Code", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public LanguageCode LanguageCode
    {
      get { return m_LanguageCode; }
      set
      {
        m_LanguageCode = value;
        isLanguageCodeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLanguageCodeDirty
    {
      get { return isLanguageCodeDirty; }
    }
    #endregion

    #region LocalTaxAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalTaxAmountDirty = false;
    private decimal m_LocalTaxAmount;
    [MTDataMember(Description = "The Local Tax Amount", Length = 40)]
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
    #endregion

    #region ModifedDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isModifedDateDirty = false;
    private DateTime m_ModifedDate;
    [MTDataMember(Description = "The Modifed Date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime ModifedDate
    {
      get { return m_ModifedDate; }
      set
      {
        m_ModifedDate = value;
        isModifedDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsModifedDateDirty
    {
      get { return isModifedDateDirty; }
    }
    #endregion

    #region NumPostbillAdjustedChildren
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNumPostbillAdjustedChildrenDirty = false;
    private int m_NumPostbillAdjustedChildren;
    [MTDataMember(Description = "The Num Postbill Adjusted Children", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int NumPostbillAdjustedChildren
    {
      get { return m_NumPostbillAdjustedChildren; }
      set
      {
        m_NumPostbillAdjustedChildren = value;
        isNumPostbillAdjustedChildrenDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNumPostbillAdjustedChildrenDirty
    {
      get { return isNumPostbillAdjustedChildrenDirty; }
    }
    #endregion

    #region NumPrebillAdjustedChildren
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNumPrebillAdjustedChildrenDirty = false;
    private int m_NumPrebillAdjustedChildren;
    [MTDataMember(Description = "The Number of Prebill Adjusted Children", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int NumPrebillAdjustedChildren
    {
      get { return m_NumPrebillAdjustedChildren; }
      set
      {
        m_NumPrebillAdjustedChildren = value;
        isNumPrebillAdjustedChildrenDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNumPrebillAdjustedChildrenDirty
    {
      get { return isNumPrebillAdjustedChildrenDirty; }
    }
    #endregion

    #region OtherTaxAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOtherTaxAmountDirty = false;
    private decimal m_OtherTaxAmount;
    [MTDataMember(Description = "Other Tax Amount", Length = 40)]
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
    #endregion

    // TODO: Should this be nullable??
    #region ParentSessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParentSessionIdDirty = false;
    private long m_ParentSessionId;
    [MTDataMember(Description = "This is the parent session id.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public long ParentSessionId
    {
      get { return m_ParentSessionId; }
      set
      {
          m_ParentSessionId = value;
          isParentSessionIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsParentSessionIdDirty
    {
      get { return isParentSessionIdDirty; }
    }
    #endregion

    #region PendingPostbillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPendingPostbillAdjAmtDirty = false;
    private decimal m_PendingPostbillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PendingPostbillAdjAmt
    {
      get { return m_PendingPostbillAdjAmt; }
      set
      {
        m_PendingPostbillAdjAmt = value;
        isPendingPostbillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPendingPostbillAdjAmtDirty
    {
      get { return isPendingPostbillAdjAmtDirty; }
    }
    #endregion

    #region PendingPrebillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPendingPrebillAdjAmtDirty = false;
    private decimal m_PendingPrebillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PendingPrebillAdjAmt
    {
      get { return m_PendingPrebillAdjAmt; }
      set
      {
        m_PendingPrebillAdjAmt = value;
        isPendingPrebillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPendingPrebillAdjAmtDirty
    {
      get { return isPendingPrebillAdjAmtDirty; }
    }
    #endregion

    #region PITemplateDisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPITemplateDisplayNameDirty = false;
    private string m_PITemplateDisplayName;
    [MTDataMember(Description = "PI Template display name", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PITemplateDisplayName
    {
      get { return m_PITemplateDisplayName; }
      set
      {
        m_PITemplateDisplayName = value;
        isPITemplateDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPITemplateDisplayNameDirty
    {
      get { return isPITemplateDisplayNameDirty; }
    }
    #endregion

    #region PostbillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPostbillAdjAmtDirty = false;
    private decimal m_PostbillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PostbillAdjAmt
    {
      get { return m_PostbillAdjAmt; }
      set
      {
        m_PostbillAdjAmt = value;
        isPostbillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPostbillAdjAmtDirty
    {
      get { return isPostbillAdjAmtDirty; }
    }
    #endregion

    #region PostbillAdjDefaultDesc
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPostbillAdjDefaultDescDirty = false;
    private string m_PostbillAdjDefaultDesc;
    [MTDataMember(Description = "The Postbill Adj Default Desc", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PostbillAdjDefaultDesc
    {
      get { return m_PostbillAdjDefaultDesc; }
      set
      {
        m_PostbillAdjDefaultDesc = value;
        isPostbillAdjDefaultDescDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPostbillAdjDefaultDescDirty
    {
      get { return isPostbillAdjDefaultDescDirty; }
    }
    #endregion

    #region PostbillAdjustmentDescription
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPostbillAdjustmentDescriptionDirty = false;
    private string m_PostbillAdjustmentDescription;
    [MTDataMember(Description = "The Postbill Adjustment Description", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PostbillAdjustmentDescription
    {
      get { return m_PostbillAdjustmentDescription; }
      set
      {
        m_PostbillAdjustmentDescription = value;
        isPostbillAdjustmentDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPostbillAdjustmentDescriptionDirty
    {
      get { return isPostbillAdjustmentDescriptionDirty; }
    }
    #endregion

    #region PrebillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPrebillAdjAmtDirty = false;
    private decimal m_PrebillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PrebillAdjAmt
    {
      get { return m_PrebillAdjAmt; }
      set
      {
        m_PrebillAdjAmt = value;
        isPrebillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPrebillAdjAmtDirty
    {
      get { return isPrebillAdjAmtDirty; }
    }
    #endregion

    #region PrebillAdjDefaultDesc
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPrebillAdjDefaultDescDirty = false;
    private string m_PrebillAdjDefaultDesc;
    [MTDataMember(Description = "The Prebill Adj Default Desc", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PrebillAdjDefaultDesc
    {
      get { return m_PrebillAdjDefaultDesc; }
      set
      {
        m_PrebillAdjDefaultDesc = value;
        isPrebillAdjDefaultDescDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPrebillAdjDefaultDescDirty
    {
      get { return isPrebillAdjDefaultDescDirty; }
    }
    #endregion

    #region PrebillAdjustmentDescription
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPrebillAdjustmentDescriptionDirty = false;
    private string m_PrebillAdjustmentDescription;
    [MTDataMember(Description = "The Prebill Adjustment Description", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PrebillAdjustmentDescription
    {
      get { return m_PrebillAdjustmentDescription; }
      set
      {
        m_PrebillAdjustmentDescription = value;
        isPrebillAdjustmentDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPrebillAdjustmentDescriptionDirty
    {
      get { return isPrebillAdjustmentDescriptionDirty; }
    }
    #endregion

    #region ReasonCodeDescription
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReasonCodeDescriptionDirty = false;
    private string m_ReasonCodeDescription;
    [MTDataMember(Description = "The Reason Code Description", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReasonCodeDescription
    {
      get { return m_ReasonCodeDescription; }
      set
      {
        m_ReasonCodeDescription = value;
        isReasonCodeDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReasonCodeDescriptionDirty
    {
      get { return isReasonCodeDescriptionDirty; }
    }
    #endregion

    #region ReasonCodeDisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReasonCodeDisplayNameDirty = false;
    private string m_ReasonCodeDisplayName;
    [MTDataMember(Description = "The Reason Code Display Name", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReasonCodeDisplayName
    {
      get { return m_ReasonCodeDisplayName; }
      set
      {
        m_ReasonCodeDisplayName = value;
        isReasonCodeDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReasonCodeDisplayNameDirty
    {
      get { return isReasonCodeDisplayNameDirty; }
    }
    #endregion

    #region ReasonCodeId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReasonCodeIdDirty = false;
    private int m_ReasonCodeId;
    [MTDataMember(Description = "The Reason Code Id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int ReasonCodeId
    {
      get { return m_ReasonCodeId; }
      set
      {
        m_ReasonCodeId = value;
        isReasonCodeIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReasonCodeIdDirty
    {
      get { return isReasonCodeIdDirty; }
    }
    #endregion

    #region ReasonCodeName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReasonCodeNameDirty = false;
    private string m_ReasonCodeName;
    [MTDataMember(Description = "The Reason Code Name", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReasonCodeName
    {
      get { return m_ReasonCodeName; }
      set
      {
        m_ReasonCodeName = value;
        isReasonCodeNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReasonCodeNameDirty
    {
      get { return isReasonCodeNameDirty; }
    }
    #endregion

    #region SessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSessionIdDirty = false;
    private long m_SessionId;
    [MTDataMember(Description = "Session id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public long SessionId
    {
      get { return m_SessionId; }
      set
      {
        m_SessionId = value;
        isSessionIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSessionIdDirty
    {
      get { return isSessionIdDirty; }
    }
    #endregion

    #region StateTaxAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStateTaxAmountDirty = false;
    private decimal m_StateTaxAmount;
    [MTDataMember(Description = "This is the State Tax Amount", Length = 40)]
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
    #endregion

    #region UsageIntervalId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUsageIntervalIdDirty = false;
    private int m_UsageIntervalId;
    [MTDataMember(Description = "Usage Interval id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int UsageIntervalId
    {
      get { return m_UsageIntervalId; }
      set
      {
        m_UsageIntervalId = value;
        isUsageIntervalIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUsageIntervalIdDirty
    {
      get { return isUsageIntervalIdDirty; }
    }
    #endregion

    #region UserNamePayee
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUserNamePayeeDirty = false;
    private string m_UserNamePayee;
    [MTDataMember(Description = "Username payee", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UserNamePayee
    {
      get { return m_UserNamePayee; }
      set
      {
        m_UserNamePayee = value;
        isUserNamePayeeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUserNamePayeeDirty
    {
      get { return isUserNamePayeeDirty; }
    }
    #endregion

    #region UserNamePayer
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUserNamePayerDirty = false;
    private string m_UserNamePayer;
    [MTDataMember(Description = "Username payer", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UserNamePayer
    {
      get { return m_UserNamePayer; }
      set
      {
        m_UserNamePayer = value;
        isUserNamePayerDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUserNamePayerDirty
    {
      get { return isUserNamePayerDirty; }
    }
    #endregion
  }
}

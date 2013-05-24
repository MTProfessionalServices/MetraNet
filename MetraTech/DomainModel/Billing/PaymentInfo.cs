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
  /// <summary>
  /// This class is used by UsageService.GetPaymentInfo to return information about last payment
  /// and display it in MetraView
  /// </summary>
  public class PaymentInfo : BaseObject
  {
    #region AmountDue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountDueDirty = false;
    private Decimal m_AmountDue;
    [MTDataMember(Description = "The total amount due", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Decimal AmountDue
    {
      get { return m_AmountDue; }
      set
      {
          m_AmountDue = value;
          isAmountDueDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAmountDueDirty
    {
      get { return isAmountDueDirty; }
    }
    #endregion

    #region AmountDueAsString
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountDueAsStringDirty = false;
    private string m_AmountDueAsString;
    [MTDataMember(Description = "This is text representation of the amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AmountDueAsString
    {
      get { return m_AmountDueAsString; }
      set
      {
          m_AmountDueAsString = value;
          isAmountDueAsStringDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAmountDueAsStringDirty
    {
      get { return isAmountDueAsStringDirty; }
    }
    #endregion

    #region DueDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDueDateDirty = false;
    private DateTime m_DueDate;
    [MTDataMember(Description = "Payment due date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime DueDate
    {
      get { return m_DueDate; }
      set
      {
          m_DueDate = value;
          isDueDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsDueDateDirty
    {
      get { return isDueDateDirty; }
    }
    #endregion

    #region InvoiceNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInvoiceNumberDirty = false;
    private string m_InvoiceNumber;
    [MTDataMember(Description = "This is textual representation of the invoice number", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string InvoiceNumber
    {
      get { return m_InvoiceNumber; }
      set
      {
          m_InvoiceNumber = value;
          isInvoiceNumberDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsInvoiceNumberDirty
    {
      get { return isInvoiceNumberDirty; }
    }
    #endregion

    #region InvoiceDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInvoiceDateDirty = false;
    private DateTime m_InvoiceDate;
    [MTDataMember(Description = "Date of the invoice", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime InvoiceDate
    {
      get { return m_InvoiceDate; }
      set
      {
          m_InvoiceDate = value;
          isInvoiceDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsInvoiceDateDirty
    {
      get { return isInvoiceDateDirty; }
    }
    #endregion

    #region LastPaymentAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLastPaymentAmountDirty = false;
    private decimal m_LastPaymentAmount;
    [MTDataMember(Description = "The amount of last payment", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal LastPaymentAmount
    {
      get { return m_LastPaymentAmount; }
      set
      {
          m_LastPaymentAmount = value;
          isLastPaymentAmountDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsLastPaymentAmountDirty
    {
      get { return isLastPaymentAmountDirty; }
    }
    #endregion

    #region LastPaymentAmountAsString
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLastPaymentAmountAsStringDirty = false;
    private String m_LastPaymentAmountAsString;
    [MTDataMember(Description = "This is text representation of tha last payment amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public String LastPaymentAmountAsString
    {
      get { return m_LastPaymentAmountAsString; }
      set
      {
          m_LastPaymentAmountAsString = value;
          isLastPaymentAmountAsStringDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsLastPaymentAmountAsStringDirty
    {
      get { return isLastPaymentAmountAsStringDirty; }
    }
    #endregion

    #region LastPaymentDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLastPaymentDateDirty = false;
    private DateTime m_LastPaymentDate;
    [MTDataMember(Description = "This is a date of last payment", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime LastPaymentDate
    {
      get { return m_LastPaymentDate; }
      set
      {
          m_LastPaymentDate = value;
          isLastPaymentDateDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsLastPaymentDateDirty
    {
      get { return isLastPaymentDateDirty; }
    }
    #endregion

    #region Currency
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCurrencyDirty = false;
    private String m_Currency;
    [MTDataMember(Description = "This is a currency", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public String Currency
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
  }
}

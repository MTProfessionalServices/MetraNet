using System;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.Billing
{
  public class PaymentTransaction : BaseObject
  {

    #region TransactionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTransactionIdDirty = false;
    private Guid m_TransactionId;
    [MTDataMember(Description = "Transaction ID", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid TransactionId
    {
      get { return m_TransactionId; }
      set
      {
          m_TransactionId = value;
          isTransactionIdDirty = true;
      }
    }
	  [ScriptIgnore]
    public bool IsTransactionIdDirty
    {
      get { return isTransactionIdDirty; }
    }
    #endregion

    #region InvoiceNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInvoiceNumberDirty = false;
    private string m_InvoiceNumber;
    [MTDataMember(Description = "Invoice Number", Length = 40)]
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

    #region Payer
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayerDirty = false;
    private int m_Payer;
    [MTDataMember(Description = "Payer", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int Payer
    {
      get { return m_Payer; }
      set
      {
          m_Payer = value;
          isPayerDirty = true;
      }
    }
	  [ScriptIgnore]
    public bool IsPayerDirty
    {
      get { return isPayerDirty; }
    }
    #endregion

    #region Payee
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPayeeDirty = false;
    private int m_Payee;
    [MTDataMember(Description = "Payee", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int Payee
    {
      get { return m_Payee; }
      set
      {
          m_Payee = value;
          isPayeeDirty = true;
      }
    }
	  [ScriptIgnore]
    public bool IsPayeeDirty
    {
      get { return isPayeeDirty; }
    }
    #endregion

    #region Amount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountDirty = false;
    private decimal m_Amount;
    [MTDataMember(Description = "Amount", Length = 40)]
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

    #region AmountAsString
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountAsStringDirty = false;
    private string m_AmountAsString;
    [MTDataMember(Description = "Amount as String", Length = 40)]
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

    #region TransactionDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTransactionDateDirty = false;
    private DateTime m_TransactionDate;
    [MTDataMember(Description = "Transaction Date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime TransactionDate
    {
      get { return m_TransactionDate; }
      set
      {
          m_TransactionDate = value;
          isTransactionDateDirty = true;
      }
    }
	  [ScriptIgnore]
    public bool IsTransactionDateDirty
    {
      get { return isTransactionDateDirty; }
    }
    #endregion

    #region Status
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStatusDirty = false;
    private string m_Status;
    [MTDataMember(Description = "Status", Length = 40)]
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

  }
}
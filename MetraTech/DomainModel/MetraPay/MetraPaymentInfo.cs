using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.MetraPay
{
  [DataContract]
  [Serializable]
  public class MetraPaymentInfo : BaseObject
  {
    #region InvoiceNum
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isInvoiceNumDirty = false;
    protected string m_InvoiceNum;
    [MTDataMember(Description = "This is the invoice number for the transaction", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string InvoiceNum
    {
      get { return m_InvoiceNum; }
      set
      {
        m_InvoiceNum = value;
        isInvoiceNumDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsInvoiceNumDirty
    {
      get { return isInvoiceNumDirty; }
    }
    #endregion

    #region InvoiceDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isInvoiceDateDirty = false;
    protected DateTime m_InvoiceDate;
    [MTDataMember(Description = "This is the date on the invoice", Length = 40)]
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

    #region PONum
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isPONumDirty = false;
    protected string m_PONum;
    [MTDataMember(Description = "This is the purchase order number", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PONum
    {
      get { return m_PONum; }
      set
      {
        m_PONum = value;
        isPONumDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPONumDirty
    {
      get { return isPONumDirty; }
    }
    #endregion

    #region Currency
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isCurrencyDirty = false;
    protected string m_Currency;
    [MTDataMember(Description = "This is the currency for the transaction", Length = 40)]
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
    protected bool isAmountDirty = false;
    protected decimal m_Amount;
    [MTDataMember(Description = "This is the amount of the transaction.  THis i", Length = 40)]
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

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isDescriptionDirty = false;
    protected string m_Description;
    [MTDataMember(Description = "This is a description of the transaction", Length = 40)]
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

    #region TransactionID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isTransactionIDDirty = false;
    protected string m_TransactionID;
    [MTDataMember(Description = "This is the transaction ID that has been exchanged with the payment processor for this transaction", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TransactionID
    {
      get { return m_TransactionID; }
      set
      {
        m_TransactionID = value;
        isTransactionIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTransactionIDDirty
    {
      get { return isTransactionIDDirty; }
    }
    #endregion

    #region MetraPaymentInvoices
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isMetraPaymentInvoicesDirty = false;
    protected List<MetraPaymentInvoice> m_MetraPaymentInvoices;
    [MTDataMember(Description = "This is the List of Metrapay invoices associated to this metrapay info.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<MetraPaymentInvoice> MetraPaymentInvoices
    {
      get { return m_MetraPaymentInvoices; }
      set
      {
        m_MetraPaymentInvoices = value;
        isMetraPaymentInvoicesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMetraPaymentInvoicesDirty
    {
      get { return isMetraPaymentInvoicesDirty; }
    }
    #endregion

    #region TransactionSessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTransactionSessionIdDirty = false;
    private Guid m_TransactionSessionId;
    [MTDataMember(Description = "The unique transaction session id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid TransactionSessionId
    {
      get { return m_TransactionSessionId; }
      set
      {
          m_TransactionSessionId = value;
          isTransactionSessionIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsTransactionSessionIdDirty
    {
      get { return isTransactionSessionIdDirty; }
    }
    #endregion

  }
}

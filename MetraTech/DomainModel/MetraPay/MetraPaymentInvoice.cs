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
    public class MetraPaymentInvoice : BaseObject
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
        protected DateTime? m_InvoiceDate;
        [MTDataMember(Description = "This is the date on the invoice", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime? InvoiceDate
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

        #region AmountToPay
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        protected bool isAmountToPayDirty = false;
        protected decimal m_AmountToPay;
        [MTDataMember(Description = "This is the amount to pay.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal AmountToPay
        {
            get { return m_AmountToPay; }
            set
            {
                m_AmountToPay = value;
                isAmountToPayDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAmountToPayDirty
        {
            get { return isAmountToPayDirty; }
        }
        #endregion

    }
}

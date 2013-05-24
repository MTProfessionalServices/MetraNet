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
    public class InvoiceInfo : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private int m_ID;
        [MTDataMember(Description = "This the numeric identifier.", Length = 40)]
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

	#region InvoiceNum
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInvoiceNumDirty = false;
        private int m_InvoiceNum;
        [MTDataMember(Description = "This is the invoice number.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int InvoiceNum
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

        #region InvoiceString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInvoiceStringDirty = false;
        private string m_InvoiceString;
        [MTDataMember(Description = "This is the invoice description.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string InvoiceString
        {
          get { return m_InvoiceString; }
          set
          {
              m_InvoiceString = value;
              isInvoiceStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsInvoiceStringDirty
        {
          get { return isInvoiceStringDirty; }
        }
        #endregion

        #region InvoiceDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInvoiceDateDirty = false;
        private DateTime m_InvoiceDate;
        [MTDataMember(Description = "This is the date of the invoice.", Length = 40)]
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

        #region InvoiceDueDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInvoiceDueDateDirty = false;
        private DateTime m_InvoiceDueDate;
        [MTDataMember(Description = "This is the date the payment is due.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime InvoiceDueDate
        {
          get { return m_InvoiceDueDate; }
          set
          {
              m_InvoiceDueDate = value;
              isInvoiceDueDateDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsInvoiceDueDateDirty
        {
          get { return isInvoiceDueDateDirty; }
        }
        #endregion

        #region IntervalID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIntervalIDDirty = false;
        private int m_IntervalID;
        [MTDataMember(Description = "This is the invoice interval identifier.", Length = 40)]
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
        #endregion

        #region IntervalStartDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIntervalStartDateDirty = false;
        private DateTime m_IntervalStartDate;
        [MTDataMember(Description = "This is the interval start date.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime IntervalStartDate
        {
          get { return m_IntervalStartDate; }
          set
          {
              m_IntervalStartDate = value;
              isIntervalStartDateDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsIntervalStartDateDirty
        {
          get { return isIntervalStartDateDirty; }
        }
        #endregion

        #region IntervalEndDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIntervalEndDateDirty = false;
        private DateTime m_IntervalEndDate;
        [MTDataMember(Description = "This is the interval end date.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime IntervalEndDate
        {
          get { return m_IntervalEndDate; }
          set
          {
              m_IntervalEndDate = value;
              isIntervalEndDateDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsIntervalEndDateDirty
        {
          get { return isIntervalEndDateDirty; }
        }
        #endregion

        #region Currency
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrencyDirty = false;
        private string m_Currency;
        [MTDataMember(Description = "This is the currency.", Length = 40)]
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

        #region PayerAccount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPayerAccountDirty = false;
        private InvoiceAccount m_PayerAccount;
        [MTDataMember(Description = "This is the account of the payer.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public InvoiceAccount PayerAccount
        {
          get { return m_PayerAccount; }
          set
          {
              m_PayerAccount = value;
              isPayerAccountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPayerAccountDirty
        {
          get { return isPayerAccountDirty; }
        }
        #endregion

        #region PayeeAccount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPayeeAccountDirty = false;
        private InvoiceAccount m_PayeeAccount;
        [MTDataMember(Description = "This is the account of the payee.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public InvoiceAccount PayeeAccount
        {
          get { return m_PayeeAccount; }
          set
          {
              m_PayeeAccount = value;
              isPayeeAccountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPayeeAccountDirty
        {
          get { return isPayeeAccountDirty; }
        }
        #endregion
    }
}
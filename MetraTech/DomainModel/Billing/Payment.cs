using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class Payment : BaseObject
    {
        #region SessionID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSessionIDDirty = false;
        private long m_SessionID;
        [MTDataMember(Description = "This is the session identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public long SessionID
        {
            get { return m_SessionID; }
            set
            {
                m_SessionID = value;
                isSessionIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSessionIDDirty
        {
            get { return isSessionIDDirty; }
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

        #region Amount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAmountDirty = false;
        private decimal m_Amount;
        [MTDataMember(Description = "This is the amount of payment.", Length = 40)]
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
        [MTDataMember(Description = "This is the text representation of the payment amount.", Length = 40)]
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

        #region Description
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDescriptionDirty = false;
        private string m_Description;
        [MTDataMember(Description = "This is the payment explanation.", Length = 40)]
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

        #region PaymentDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPaymentDateDirty = false;
        private DateTime m_PaymentDate;
        [MTDataMember(Description = "This is the date of the payment.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime PaymentDate
        {
            get { return m_PaymentDate; }
            set
            {
                m_PaymentDate = value;
                isPaymentDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPaymentDateDirty
        {
            get { return isPaymentDateDirty; }
        }
        #endregion

        #region ReasonCode
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReasonCodeDirty = false;
        private Nullable<MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode> m_ReasonCode;
        [MTDataMember(Description = "This is the reason code for the payment.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Nullable<MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode> ReasonCode
        {
            get { return m_ReasonCode; }
            set
            {
                m_ReasonCode = value;
                isReasonCodeDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsReasonCodeDirty
        {
            get { return isReasonCodeDirty; }
        }
        #endregion

        #region ReasonCode Value Display Name
        public string ReasonCodeValueDisplayName
        {
            get
            {
                if (ReasonCode.HasValue)
                {
                    return GetDisplayName(this.ReasonCode.Value);
                }
                else
                {
                    return "";
                }
            }
            set
            {
                this.ReasonCode = ((MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode)(GetEnumInstanceByDisplayName(typeof(MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments.ReasonCode), value)));
            }
        }
        #endregion

        #region PaymentMethod
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPaymentMethodDirty = false;
        private PaymentMethod m_PaymentMethod;
        [MTDataMember(Description = "This is the method of payment.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PaymentMethod PaymentMethod
        {
            get { return m_PaymentMethod; }
            set
            {
                m_PaymentMethod = value;
                isPaymentMethodDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPaymentMethodDirty
        {
            get { return isPaymentMethodDirty; }
        }
        #endregion

        #region PaymentMethod Value Display Name
        public string PaymentMethodValueDisplayName
        {
            get
            {
                return GetDisplayName(this.PaymentMethod);
            }
            set
            {
                this.PaymentMethod = ((PaymentMethod)(GetEnumInstanceByDisplayName(typeof(PaymentMethod), value)));
            }
        }
        #endregion

        #region CreditCardType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCreditCardTypeDirty = false;
        private MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType? m_CreditCardType;
        [MTDataMember(Description = "This is the type of credit card used.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType? CreditCardType
        {
            get { return m_CreditCardType; }
            set
            {
                m_CreditCardType = value;
                isCreditCardTypeDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCreditCardTypeDirty
        {
            get { return isCreditCardTypeDirty; }
        }
        #endregion

        #region CreditCardType Value Display Name
        public string CreditCardTypeValueDisplayName
        {
            get
            {
                return GetDisplayName(this.CreditCardType);
            }
            set
            {
                if ((value == null) || (value == string.Empty))
                {
                    this.CreditCardType = null;
                }
                else
                {
                    this.CreditCardType = ((MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType)(GetEnumInstanceByDisplayName(typeof(MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType), value)));
                }
            }
        }
        #endregion

        #region CheckOrCardNumber
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCheckOrCardNumberDirty = false;
        private string m_CheckOrCardNumber;
        [MTDataMember(Description = "This is either a check number or a credit card number.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string CheckOrCardNumber
        {
            get { return m_CheckOrCardNumber; }
            set
            {
                m_CheckOrCardNumber = value;
                isCheckOrCardNumberDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCheckOrCardNumberDirty
        {
            get { return isCheckOrCardNumberDirty; }
        }
        #endregion

        #region PaymentTxnID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPaymentTxnIDDirty = false;
        private string m_PaymentTxnID;
        [MTDataMember(Description = "This is the Payment Txn ID.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PaymentTxnID
        {
            get { return m_PaymentTxnID; }
            set
            {
                m_PaymentTxnID = value;
                isPaymentTxnIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPaymentTxnIDDirty
        {
            get { return isPaymentTxnIDDirty; }
        }
        #endregion
        
        #region ReferenceID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReferenceIDDirty = false;
        private string m_ReferenceID;
        [MTDataMember(Description = "This is the Reference ID.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ReferenceID
        {
            get { return m_ReferenceID; }
            set
            {
                m_ReferenceID = value;
                isReferenceIDDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsReferenceIDDirty
        {
            get { return IsReferenceIDDirty; }
        }
        #endregion
    }
}
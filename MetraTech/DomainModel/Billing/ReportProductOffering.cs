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
    public class ReportProductOffering : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private string m_ID;
        [MTDataMember(Description = "This is the product offering identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ID
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

        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNameDirty = false;
        private string m_Name;
        [MTDataMember(Description = "This is the product offering name.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Name
        {
            get { return m_Name; }
            set
            {
                m_Name = value;
                isNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNameDirty
        {
            get { return isNameDirty; }
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
        [MTDataMember(Description = "This is the amount.", Length = 40)]
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

        #region Charges
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChargesDirty = false;
        private List<ReportCharge> m_Charges = null;
        [MTDataMember(Description = "These are the charges for this product offering.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<ReportCharge> Charges
        {
          get { return m_Charges; }
          set
          {
              m_Charges = value;
              isChargesDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsChargesDirty
        {
          get { return isChargesDirty; }
        }
        #endregion
    }
}
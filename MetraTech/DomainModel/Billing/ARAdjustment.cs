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
    public class ARAdjustment : BaseObject
    {
        #region SessionID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSessionIDDirty = false;
        private long  m_SessionID;
        [MTDataMember(Description = "This is the session identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public long  SessionID
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

        #region Amount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAmountDirty = false;
        private decimal m_Amount;
        [MTDataMember(Description = "This is the amount of the adjustment.", Length = 40)]
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

        #region Description
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDescriptionDirty = false;
        private string m_Description;
        [MTDataMember(Description = "This text describes the adjustment.", Length = 40)]
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

        #region EventDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEventDateDirty = false;
        private DateTime m_EventDate;
        [MTDataMember(Description = "This is the date for the adjustment.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime EventDate
        {
          get { return m_EventDate; }
          set
          {
              m_EventDate = value;
              isEventDateDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsEventDateDirty
        {
          get { return isEventDateDirty; }
        }
        #endregion

        #region ReasonCode
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReasonCodeDirty = false;
        private string m_ReasonCode;
        [MTDataMember(Description = "This is the reason for the adjustment", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ReasonCode
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
    }
}
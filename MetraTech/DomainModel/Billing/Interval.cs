using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;

using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class Interval : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private int m_ID;
        [MTDataMember(Description = "This is the interval numeric identifier.", Length = 40)]
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

        #region StartDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDateDirty = false;
        private DateTime m_StartDate;
        [MTDataMember(Description = "This is the start date for the interval.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime StartDate
        {
          get { return m_StartDate; }
          set
          {
              m_StartDate = value;
              isStartDateDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsStartDateDirty
        {
          get { return isStartDateDirty; }
        }
        #endregion

        #region EndDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEndDateDirty = false;
        private DateTime m_EndDate;
        [MTDataMember(Description = "This is the end date for the interval.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime EndDate
        {
          get { return m_EndDate; }
          set
          {
              m_EndDate = value;
              isEndDateDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsEndDateDirty
        {
          get { return isEndDateDirty; }
        }
        #endregion

        #region Status
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStatusDirty = false;
        private IntervalStatusCode m_Status;
        [MTDataMember(Description = "This is the status code enumeration for the interval.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public IntervalStatusCode Status
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

        #region Status Value Display Name
        public string StatusValueDisplayName
        {
          get
          {
            return GetDisplayName(this.Status);
          }
          set
          {
            this.Status = ((IntervalStatusCode)(GetEnumInstanceByDisplayName(typeof(IntervalStatusCode), value)));
          }
        }
        #endregion
    
        #region InvoiceNumber
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInvoiceNumberDirty = false;
        private string m_InvoiceNumber;
        [MTDataMember(Description = "This is the textual representation of the invoice number for the interval.", Length = 40)]
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

        #region UsageAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUsageAmountDirty = false;
        private decimal? m_UsageAmount;
        [MTDataMember(Description = "This is the usage amount for the interval.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal? UsageAmount
        {
          get { return m_UsageAmount; }
          set
          {
              m_UsageAmount = value;
              isUsageAmountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsUsageAmountDirty
        {
          get { return isUsageAmountDirty; }
        }
        #endregion

        #region UsageAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUsageAmountAsStringDirty = false;
        private string m_UsageAmountAsString;
        [MTDataMember(Description = "This is a text representation of usage amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string UsageAmountAsString
        {
          get { return m_UsageAmountAsString; }
          set
          {
              m_UsageAmountAsString = value;
              isUsageAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsUsageAmountAsStringDirty
        {
          get { return isUsageAmountAsStringDirty; }
        }
        #endregion
    }
}

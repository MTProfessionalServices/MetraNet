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
    public class DescendentPayeeSlice : AccountSlice
    {
        #region AncestorAccountId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAncestorAccountIdDirty = false;
        private AccountIdentifier m_AncestorAccountId;
        [MTDataMember(Description = "This is the identifier of the ancestor account.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountIdentifier AncestorAccountId
        {
          get { return m_AncestorAccountId; }
          set
          {
              m_AncestorAccountId = value;
              isAncestorAccountIdDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAncestorAccountIdDirty
        {
          get { return isAncestorAccountIdDirty; }
        }
        #endregion

        #region StartDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isStartDateDirty = false;
        private DateTime m_StartDate;
        [MTDataMember(Description = "This is the start date defined for the slice.", Length = 40)]
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
        [MTDataMember(Description = "This is the end date defined for the slice.", Length = 40)]
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
    }
}
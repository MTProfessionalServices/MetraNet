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
    public class DateRangeSlice : TimeSlice
    {
        #region Begin
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isBeginDirty = false;
        private DateTime m_Begin;
        [MTDataMember(Description = "This is the begin date.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime Begin
        {
          get { return m_Begin; }
          set
          {
              m_Begin = value;
              isBeginDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsBeginDirty
        {
          get { return isBeginDirty; }
        }
        #endregion

        #region End
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEndDirty = false;
        private DateTime m_End;
        [MTDataMember(Description = "This is the end date.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateTime End
        {
          get { return m_End; }
          set
          {
              m_End = value;
              isEndDirty = true;
          } 
        }
        [ScriptIgnore]
        public bool IsEndDirty
        {
          get { return isEndDirty; }
        }
        #endregion
    }
}
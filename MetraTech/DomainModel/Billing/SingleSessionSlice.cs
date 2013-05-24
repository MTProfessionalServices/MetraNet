using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class SingleSessionSlice : SessionSlice
    {
        #region SessionId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSessionIdDirty = false;
        private Int64 m_SessionId;
        [MTDataMember(Description = "This is the session identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Int64 SessionId
        {
          get { return m_SessionId; }
          set
          {
              m_SessionId = value;
              isSessionIdDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsSessionIdDirty
        {
          get { return isSessionIdDirty; }
        }
        #endregion
    }
}
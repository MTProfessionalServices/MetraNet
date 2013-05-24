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
    public class SessionChildrenSlice : SessionSlice
    {
        #region ParentSessionId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParentSessionIdDirty = false;
        private Int64 m_ParentSessionId;
        [MTDataMember(Description = "This is the identifier of the parent session.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Int64 ParentSessionId
        {
          get { return m_ParentSessionId; }
          set
          {
              m_ParentSessionId = value;
              isParentSessionIdDirty = true;
          }
        }
        public bool IsParentSessionIdDirty
        {
          get { return isParentSessionIdDirty; }
        }
        #endregion
    }
}
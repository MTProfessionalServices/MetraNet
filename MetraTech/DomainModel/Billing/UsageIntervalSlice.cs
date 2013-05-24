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
    public class UsageIntervalSlice : TimeSlice
    {
        #region UsageInterval
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isUsageIntervalDirty = false;
        private int m_UsageInterval;    
        [MTDataMember(Description = "This is the numeric index of the usage interval.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int UsageInterval
        {
          get { return m_UsageInterval; }
          set
          {
              m_UsageInterval = value;
              isUsageIntervalDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsUsageIntervalDirty
        {
          get { return isUsageIntervalDirty; }
        }
        #endregion
    }
}
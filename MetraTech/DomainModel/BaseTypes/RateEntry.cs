using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    public enum RateEntryOperators
    {
        Equal,
        NotEqual,
        Greater,
        GreaterEqual,
        Less,
        LessEqual
    }

    [DataContract]
    [Serializable]
    public abstract class RateEntry : BaseObject
    {
        #region RateScheduleId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRateScheduleIdDirty = false;
    private int? m_RateScheduleId;
    [MTDataMember(Description = "This is the internal identifier of the rate entry to which this entry belongs.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? RateScheduleId
    {
      get { return m_RateScheduleId; }
      set
      {
          m_RateScheduleId = value;
          isRateScheduleIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRateScheduleIdDirty
    {
      get { return isRateScheduleIdDirty; }
    }
    #endregion

        #region Index
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIndexDirty = false;
    private int m_Index;
    [MTDataMember(Description = "This is the index of the rate entry within the rate schedule.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int Index
    {
      get { return m_Index; }
      set
      {
          m_Index = value;
          isIndexDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIndexDirty
    {
      get { return isIndexDirty; }
    }
    #endregion
    }
}

using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com_calendar;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class CalendarDayPeriod : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier of the calendar day period. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? ID
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

        #region Code
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCodeDirty = false;
    private CalendarCode m_Code;
    [MTDataMember(Description = "This is the time classification code for the period. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarCode Code
    {
      get { return m_Code; }
      set
      {
          m_Code = value;
          isCodeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCodeDirty
    {
      get { return isCodeDirty; }
    }
    #endregion

        #region Code Value Display Name
    public string CodeValueDisplayName
    {
      get
      {
        return GetDisplayName(this.Code);
      }
      set
      {
        this.Code = ((CalendarCode)(GetEnumInstanceByDisplayName(typeof(CalendarCode), value)));
      }
    }
    #endregion
    
        #region StartTime
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStartTimeDirty = false;
    private DateTime m_StartTime;
    [MTDataMember(Description = "This defines the starting time of day for the period.  Any date component in the DateTime structure will be ignored.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime StartTime
    {
      get { return m_StartTime; }
      set
      {
          m_StartTime = value;
          isStartTimeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartTimeDirty
    {
      get { return isStartTimeDirty; }
    }
    #endregion

        #region EndTime
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEndTimeDirty = false;
    private DateTime m_EndTime;
    [MTDataMember(Description = "This defines the ending time of day for the period.  Any date component in the DateTime structure will be ignored. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime EndTime
    {
      get { return m_EndTime; }
      set
      {
          m_EndTime = value;
          isEndTimeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEndTimeDirty
    {
      get { return isEndTimeDirty; }
    }
    #endregion

    }
}

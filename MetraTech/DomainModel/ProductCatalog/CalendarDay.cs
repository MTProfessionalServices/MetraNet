using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com_calendar;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public abstract class CalendarDay : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier for the calendar day. ", Length = 40)]
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
    [MTDataMember(Description = " This is the default code for the day (e.g. peak, off-peak).", Length = 40)]
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
    
        #region Periods
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPeriodsDirty = false;
    private List<CalendarDayPeriod> m_Periods;
    [MTDataMember(Description = " This is the list of time periods during the calendar day that define different codes.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<CalendarDayPeriod> Periods
    {
      get { return m_Periods; }
      set
      {
          m_Periods = value;
          isPeriodsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPeriodsDirty
    {
      get { return isPeriodsDirty; }
    }
    #endregion
    }
}

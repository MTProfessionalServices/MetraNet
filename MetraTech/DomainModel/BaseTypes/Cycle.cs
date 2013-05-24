using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  public class Cycle : BaseObject
  {
    #region CycleType
    private bool isCycleTypeDirty = true;
    private UsageCycleType m_CycleType;
    [MTDataMember(Description = "Cycle Type (daily, weekly, monthly, etc)", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public UsageCycleType CycleType
    {
      get { return m_CycleType; }
      set
      {

        m_CycleType = value;
        isCycleTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCycleTypeDirty
    {
      get { return isCycleTypeDirty; }
    }
    #endregion

    #region DayOfMonth
    private bool isDayOfMonthDirty = true;
    private int? m_DayOfMonth;
    [MTDataMember(Description = "Day of the month", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? DayOfMonth
    {
      get { return m_DayOfMonth; }
      set
      {

        m_DayOfMonth = value;
        isDayOfMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDayOfMonthDirty
    {
      get { return isDayOfMonthDirty; }
    }
    #endregion

    #region DayOfWeek
    [System.Runtime.Serialization.DataMemberAttribute(IsRequired = false, EmitDefaultValue = false)]
    private bool isDayOfWeekDirty = false;
    private Nullable<DayOfTheWeek> dayOfWeek;
    [MTDataMember(Description = "The day of the week on which the user wants to be billed (for the weekly usage cycle type).")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<DayOfTheWeek> DayOfWeek
    {
      get { return dayOfWeek; }
      set
      {
        dayOfWeek = value;
        isDayOfWeekDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsDayOfWeekDirty
    {
      get { return isDayOfWeekDirty; }
    }

    [MTPropertyLocalizationAttribute(ResourceId = "metratech.domainmodel.basetypes.cycle.dayofweek",
                                   DefaultValue = "DayOfWeek",
                                   MTLocalizationId = "metratech.com/cycle/DayOfWeek",
                                     Extension = "Account",
                                     LocaleSpace = "metratech.com/cycle")]
    public string DayOfWeekDisplayName
    {
      get
      {
        return ResourceManager.GetString("metratech.domainmodel.basetypes.cycle.dayofweek");
      }
    }

    public string DayOfWeekValueDisplayName
    {
      get
      {
        return GetDisplayName(this.DayOfWeek);
      }
      set
      {
        this.DayOfWeek = ((System.Nullable<DayOfTheWeek>)(GetEnumInstanceByDisplayName(typeof(DayOfTheWeek), value)));
      }
    }
    #endregion

    #region FirstDayOfMonth
    private bool isFirstDayOfMonthDirty = true;
    private int? m_FirstDayOfMonth;
    [MTDataMember(Description = "First day of the month", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? FirstDayOfMonth
    {
      get { return m_FirstDayOfMonth; }
      set
      {

        m_FirstDayOfMonth = value;
        isFirstDayOfMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFirstDayOfMonthDirty
    {
      get { return isFirstDayOfMonthDirty; }
    }
    #endregion

    #region SecondDayOfMonth
    private bool isSecondDayOfMonthDirty = true;
    private int? m_SecondDayOfMonth;
    [MTDataMember(Description = "Second day of the month", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? SecondDayOfMonth
    {
      get { return m_SecondDayOfMonth; }
      set
      {

        m_SecondDayOfMonth = value;
        isSecondDayOfMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSecondDayOfMonthDirty
    {
      get { return isSecondDayOfMonthDirty; }
    }
    #endregion

    #region StartDay
    private bool isStartDayDirty = true;
    private int? m_StartDay;
    [MTDataMember(Description = "Start day", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? StartDay
    {
      get { return m_StartDay; }
      set
      {

        m_StartDay = value;
        isStartDayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartDayDirty
    {
      get { return isStartDayDirty; }
    }
    #endregion

    #region StartMonth
    private bool isStartMonthDirty = true;
    private Nullable<MonthOfTheYear> m_StartMonth;
    [MTDataMember(Description = "Start month", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<MonthOfTheYear> StartMonth
    {
      get { return m_StartMonth; }
      set
      {

        m_StartMonth = value;
        isStartMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartMonthDirty
    {
      get { return isStartMonthDirty; }
    }
    #endregion

    #region StartYear
    private bool isStartYearDirty = true;
    private int? m_StartYear;
    [MTDataMember(Description = "Start year", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? StartYear
    {
      get { return m_StartYear; }
      set
      {

        m_StartYear = value;
        isStartYearDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartYearDirty
    {
      get { return isStartYearDirty; }
    }
    #endregion
  }
}

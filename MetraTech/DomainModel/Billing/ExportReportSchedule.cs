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
  public class ExportReportSchedule : BaseObject
  {
    #region IDReportSchedule
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isIDReportScheduleDirty = false;
    private int m_IDReportSchedule;
    [MTDataMember(Description = "This the Report Schedule ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDReportSchedule
    {
      get { return m_IDReportSchedule; }
      set
      {
        m_IDReportSchedule = value;
        isIDReportScheduleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDReportScheduleDirty
    {
      get { return isIDReportScheduleDirty; }
    }
    #endregion

    #region IDReportInstanceIDSch
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDReportInstanceIDSchDirty = false;
    private int m_IDReportInstanceIDSch;
    [MTDataMember(Description = "This the Report Instance ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDReportInstanceIDSch
    {
      get { return m_IDReportInstanceIDSch; }
      set
      {
        m_IDReportInstanceIDSch = value;
        isIDReportInstanceIDSchDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDReportInstanceIDSchDirty
    {
      get { return isIDReportInstanceIDSchDirty; }
    }
    #endregion

    #region IDReportForSchedule
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDReportForScheduleDirty = false;
    private int m_IDReportForSchedule;
    [MTDataMember(Description = "This the Report Schedule ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDReportForSchedule
    {
      get { return m_IDReportForSchedule; }
      set
      {
        m_IDReportForSchedule = value;
        isIDReportForScheduleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDReportForScheduleDirty
    {
      get { return isIDReportForScheduleDirty; }
    }
    #endregion

    #region IDSchedule
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDScheduleDirty = false;
    private int m_IDSchedule;
    [MTDataMember(Description = "This the Schedule ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDSchedule
    {
      get { return m_IDSchedule; }
      set
      {
        m_IDSchedule = value;
        isIDScheduleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDScheduleDirty
    {
      get { return isIDScheduleDirty; }
    }
    #endregion

    #region ScheduleType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isScheduleTypeDirty = false;
    private ScheduleTypeEnum m_ScheduleType;
    [MTDataMember(Description = "This the Schedule Type..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ScheduleTypeEnum ScheduleType
    {
      get { return m_ScheduleType; }
      set
      {
        m_ScheduleType = value;
        isScheduleTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsScheduleTypeDirty
    {
      get { return isScheduleTypeDirty; }
    }
    #endregion

    #region ScheduleTypeText
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isScheduleTypeTextDirty = false;
    private string m_ScheduleTypeText;
    [MTDataMember(Description = "This the Schedule Type in Text Format..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ScheduleTypeText
    {
      get { return m_ScheduleTypeText; }
      set
      {
        m_ScheduleTypeText = value;
        isScheduleTypeTextDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsScheduleTypeTextDirty
    {
      get { return isScheduleTypeTextDirty; }
    }
    #endregion

      
      
      
      #region ScheduleCreationDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isScheduleCreationDateDirty = false;
    private DateTime m_ScheduleCreationDate;
    [MTDataMember(Description = "This the Schedule Creation Date..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime ScheduleCreationDate
    {
      get { return m_ScheduleCreationDate; }
      set
      {
        m_ScheduleCreationDate = value;
        isScheduleCreationDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsScheduleCreationDateDirty
    {
      get { return isScheduleCreationDateDirty; }
    }
    #endregion

    #region ExecuteTime
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteTimeDirty = false;
    private string m_ExecuteTime;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ExecuteTime
    {
      get { return m_ExecuteTime; }
      set
      {
        m_ExecuteTime = value;
        isExecuteTimeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteTimeDirty
    {
      get { return isExecuteTimeDirty; }
    }
    #endregion

    #region RepeatHour
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRepeatHourDirty = false;
    private int m_RepeatHour;
    [MTDataMember(Description = "This the Repeat Hour for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int RepeatHour
    {
      get { return m_RepeatHour; }
      set
      {
        m_RepeatHour = value;
        isRepeatHourDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRepeatHourDirty
    {
      get { return isRepeatHourDirty; }
    }
    #endregion

    #region ExecuteStartTime
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteStartTimeDirty = false;
    private string m_ExecuteStartTime;
    [MTDataMember(Description = "This the Execute Start Time of Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ExecuteStartTime
    {
      get { return m_ExecuteStartTime; }
      set
      {
        m_ExecuteStartTime = value;
        isExecuteStartTimeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteStartTimeDirty
    {
      get { return isExecuteStartTimeDirty; }
    }
    #endregion

    #region ExecuteEndTime
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteEndTimeDirty = false;
    private string m_ExecuteEndTime;
    [MTDataMember(Description = "This the Execute End Time of Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ExecuteEndTime
    {
      get { return m_ExecuteEndTime; }
      set
      {
        m_ExecuteEndTime = value;
        isExecuteEndTimeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteEndTimeDirty
    {
      get { return isExecuteEndTimeDirty; }
    }
    #endregion

    #region SkipLastDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipLastDayMonthDirty = false;
    private SkipLastDayOfMonthEnum m_SkipLastDayMonth;
    [MTDataMember(Description = "This the Last day of month of Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipLastDayOfMonthEnum SkipLastDayMonth
    {
      get { return m_SkipLastDayMonth; }
      set
      {
        m_SkipLastDayMonth = value;
        isSkipLastDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipLastDayMonthDirty
    {
      get { return isSkipLastDayMonthDirty; }
    }
    #endregion

    #region bSkipLastDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipLastDayMonthDirty = false;
    private bool m_bSkipLastDayMonth;
    [MTDataMember(Description = "This the Last day of month of Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipLastDayMonth
    {
      get { return m_bSkipLastDayMonth; }
      set
      {
        m_bSkipLastDayMonth = value;
        isbSkipLastDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipLastDayMonthDirty
    {
      get { return isbSkipLastDayMonthDirty; }
    }
    #endregion

    #region SkipFirstDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipFirstDayMonthDirty = false;
    private SkipFirstDayOfMonthEnum m_SkipFirstDayMonth;
    [MTDataMember(Description = "This the First day of month of Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipFirstDayOfMonthEnum SkipFirstDayMonth
    {
      get { return m_SkipFirstDayMonth; }
      set
      {
        m_SkipFirstDayMonth = value;
        isSkipFirstDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipFirstDayMonthDirty
    {
      get { return isSkipFirstDayMonthDirty; }
    }
    #endregion

    #region bSkipFirstDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipFirstDayMonthDirty = false;
    private bool  m_bSkipFirstDayMonth;
    [MTDataMember(Description = "This the First day of month of Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipFirstDayMonth
    {
      get { return m_bSkipFirstDayMonth; }
      set
      {
        m_bSkipFirstDayMonth = value;
        isbSkipFirstDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipFirstDayMonthDirty
    {
      get { return isbSkipFirstDayMonthDirty; }
    }
    #endregion

    #region DaysInterval
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDaysIntervalDirty = false;
    private int m_DaysInterval;
    [MTDataMember(Description = "This the Days Interval for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int DaysInterval
    {
      get { return m_DaysInterval; }
      set
      {
        m_DaysInterval = value;
        isDaysIntervalDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDaysIntervalDirty
    {
      get { return isDaysIntervalDirty; }
    }
    #endregion

    #region MonthToDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMonthToDateDirty = false;
    private MonthToDateEnum m_MonthToDate;
    [MTDataMember(Description = "This the Month To Date for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MonthToDateEnum MonthToDate
    {
      get { return m_MonthToDate; }
      set
      {
        m_MonthToDate = value;
        isMonthToDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMonthToDateDirty
    {
      get { return isMonthToDateDirty; }
    }
    #endregion

    #region bMonthToDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbMonthToDateDirty = false;
    private bool m_bMonthToDate;
    [MTDataMember(Description = "This the Month To Date for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bMonthToDate
    {
      get { return m_bMonthToDate; }
      set
      {
        m_bMonthToDate = value;
        isbMonthToDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbMonthToDateDirty
    {
      get { return isbMonthToDateDirty; }
    }
    #endregion

    #region ExecuteDay
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteDayDirty = false;
    private int m_ExecuteDay;
    [MTDataMember(Description = "This the Execute Day for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int ExecuteDay
    {
      get { return m_ExecuteDay; }
      set
      {
        m_ExecuteDay = value;
        isExecuteDayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteDayDirty
    {
      get { return isExecuteDayDirty; }
    }
    #endregion

    #region bExecuteDay
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteDayDirty = false;
    private bool m_bExecuteDay;
    [MTDataMember(Description = "This the Last day of month of Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteDay
    {
      get { return m_bExecuteDay; }
      set
      {
        m_bExecuteDay = value;
        isbExecuteDayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteDayDirty
    {
      get { return isbExecuteDayDirty; }
    }
    #endregion
  
    #region ExecuteLastDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteLastDayMonthDirty = false;
    private ExecuteLastDayOfMonthEnum m_ExecuteLastDayMonth;
    [MTDataMember(Description = "This the Last day of month of Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteLastDayOfMonthEnum ExecuteLastDayMonth
    {
      get { return m_ExecuteLastDayMonth; }
      set
      {
        m_ExecuteLastDayMonth = value;
        isExecuteLastDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteLastDayMonthDirty
    {
      get { return isExecuteLastDayMonthDirty; }
    }
    #endregion

    #region bExecuteLastDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteLastDayMonthDirty = false;
    private bool m_bExecuteLastDayMonth;
    [MTDataMember(Description = "This the Last day of month of Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteLastDayMonth
    {
      get { return m_bExecuteLastDayMonth; }
      set
      {
        m_bExecuteLastDayMonth = value;
        isbExecuteLastDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteLastDayMonthDirty
    {
      get { return isbExecuteLastDayMonthDirty; }
    }
    #endregion  

      
      #region ExecuteFirstDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteFirstDayMonthDirty = false;
    private ExecuteFirstDayOfMonthEnum m_ExecuteFirstDayMonth;
    [MTDataMember(Description = "This the First day of month of Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteFirstDayOfMonthEnum ExecuteFirstDayMonth
    {
      get { return m_ExecuteFirstDayMonth; }
      set
      {
        m_ExecuteFirstDayMonth = value;
        isExecuteFirstDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteFirstDayMonthDirty
    {
      get { return isExecuteFirstDayMonthDirty; }
    }
    #endregion

    #region bExecuteFirstDayMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteFirstDayMonthDirty = false;
    private bool m_bExecuteFirstDayMonth;
    [MTDataMember(Description = "This the First day of month of Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteFirstDayMonth
    {
      get { return m_bExecuteFirstDayMonth; }
      set
      {
        m_bExecuteFirstDayMonth = value;
        isbExecuteFirstDayMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteFirstDayMonthDirty
    {
      get { return isbExecuteFirstDayMonthDirty; }
    }
    #endregion



    #region SkipMonth
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipMonthDirty = false;
    private string m_SkipMonth;
    [MTDataMember(Description = "This the Skip Month of Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string SkipMonth
    {
      get { return m_SkipMonth; }
      set
      {
        m_SkipMonth = value;
        isSkipMonthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipMonthDirty
    {
      get { return isSkipMonthDirty; }
    }
    #endregion


    #region ExecuteWeekDays
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteWeekDaysDirty = false;
    private string m_ExecuteWeekDays;
    [MTDataMember(Description = "This the Execute Weekdays for Weekly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ExecuteWeekDays
    {
      get { return m_ExecuteWeekDays; }
      set
      {
        m_ExecuteWeekDays = value;
        isExecuteWeekDaysDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteWeekDaysDirty
    {
      get { return isExecuteWeekDaysDirty; }
    }
    #endregion

    #region SkipWeekDays
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipWeekDaysDirty = false;
    private string m_SkipWeekDays;
    [MTDataMember(Description = "This the Skip Weekdays for Weekly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string SkipWeekDays
    {
      get { return m_SkipWeekDays; }
      set
      {
        m_SkipWeekDays = value;
        isSkipWeekDaysDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipWeekDaysDirty
    {
      get { return isSkipWeekDaysDirty; }
    }
    #endregion


    #region SkipSunday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipSundayDirty = false;
    private SkipThisDayEnum m_SkipSunday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipSunday
    {
      get { return m_SkipSunday; }
      set
      {
        m_SkipSunday = value;
        isSkipSundayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipSundayDirty
    {
      get { return isSkipSundayDirty; }
    }
    #endregion

  
      #region SkipMonday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipMondayDirty = false;
    private SkipThisDayEnum m_SkipMonday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipMonday
    {
      get { return m_SkipMonday; }
      set
      {
        m_SkipMonday = value;
        isSkipMondayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipMondayDirty
    {
      get { return isSkipMondayDirty; }
    }
    #endregion

    #region SkipTuesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipTuesdayDirty = false;
    private SkipThisDayEnum m_SkipTuesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipTuesday
    {
      get { return m_SkipTuesday; }
      set
      {
        m_SkipTuesday = value;
        isSkipTuesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipTuesdayDirty
    {
      get { return isSkipTuesdayDirty; }
    }
    #endregion

    #region SkipWednesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipWednesdayDirty = false;
    private SkipThisDayEnum m_SkipWednesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipWednesday
    {
      get { return m_SkipWednesday; }
      set
      {
        m_SkipWednesday = value;
        isSkipWednesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipWednesdayDirty
    {
      get { return isSkipWednesdayDirty; }
    }
    #endregion

    #region SkipThursday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipThursdayDirty = false;
    private SkipThisDayEnum m_SkipThursday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipThursday
    {
      get { return m_SkipThursday; }
      set
      {
        m_SkipThursday = value;
        isSkipThursdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipThursdayDirty
    {
      get { return isSkipThursdayDirty; }
    }
    #endregion

    #region SkipFriday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipFridayDirty = false;
    private SkipThisDayEnum m_SkipFriday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipFriday
    {
      get { return m_SkipFriday; }
      set
      {
        m_SkipFriday = value;
        isSkipFridayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipFridayDirty
    {
      get { return isSkipFridayDirty; }
    }
    #endregion

    #region SkipSaturday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipSaturdayDirty = false;
    private SkipThisDayEnum m_SkipSaturday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisDayEnum SkipSaturday
    {
      get { return m_SkipSaturday; }
      set
      {
        m_SkipSaturday = value;
        isSkipSaturdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipSaturdayDirty
    {
      get { return isSkipSaturdayDirty; }
    }
    #endregion

    #region ExecuteSunday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteSundayDirty = false;
    private ExecuteThisDayEnum m_ExecuteSunday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteSunday
    {
      get { return m_ExecuteSunday; }
      set
      {
        m_ExecuteSunday = value;
        isExecuteSundayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteSundayDirty
    {
      get { return isExecuteSundayDirty; }
    }
    #endregion


    #region ExecuteMonday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteMondayDirty = false;
    private ExecuteThisDayEnum m_ExecuteMonday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteMonday
    {
      get { return m_ExecuteMonday; }
      set
      {
        m_ExecuteMonday = value;
        isExecuteMondayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteMondayDirty
    {
      get { return isExecuteMondayDirty; }
    }
    #endregion

    #region ExecuteTuesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteTuesdayDirty = false;
    private ExecuteThisDayEnum m_ExecuteTuesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteTuesday
    {
      get { return m_ExecuteTuesday; }
      set
      {
        m_ExecuteTuesday = value;
        isExecuteTuesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteTuesdayDirty
    {
      get { return isExecuteTuesdayDirty; }
    }
    #endregion

    #region ExecuteWednesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteWednesdayDirty = false;
    private ExecuteThisDayEnum m_ExecuteWednesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteWednesday
    {
      get { return m_ExecuteWednesday; }
      set
      {
        m_ExecuteWednesday = value;
        isExecuteWednesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteWednesdayDirty
    {
      get { return isExecuteWednesdayDirty; }
    }
    #endregion

    #region ExecuteThursday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteThursdayDirty = false;
    private ExecuteThisDayEnum m_ExecuteThursday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteThursday
    {
      get { return m_ExecuteThursday; }
      set
      {
        m_ExecuteThursday = value;
        isExecuteThursdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteThursdayDirty
    {
      get { return isExecuteThursdayDirty; }
    }
    #endregion

    #region ExecuteFriday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteFridayDirty = false;
    private ExecuteThisDayEnum m_ExecuteFriday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteFriday
    {
      get { return m_ExecuteFriday; }
      set
      {
        m_ExecuteFriday = value;
        isExecuteFridayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteFridayDirty
    {
      get { return isExecuteFridayDirty; }
    }
    #endregion

    #region ExecuteSaturday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isExecuteSaturdayDirty = false;
    private ExecuteThisDayEnum m_ExecuteSaturday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ExecuteThisDayEnum ExecuteSaturday
    {
      get { return m_ExecuteSaturday; }
      set
      {
        m_ExecuteSaturday = value;
        isExecuteSaturdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExecuteSaturdayDirty
    {
      get { return isExecuteSaturdayDirty; }
    }
    #endregion

    #region SkipJanuary
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipJanuaryDirty = false;
    private SkipThisMonthEnum m_SkipJanuary;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipJanuary
    {
      get { return m_SkipJanuary; }
      set
      {
        m_SkipJanuary = value;
        isSkipJanuaryDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipJanuaryDirty
    {
      get { return isSkipJanuaryDirty; }
    }
    #endregion

    #region SkipFebruary
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipFebruaryDirty = false;
    private SkipThisMonthEnum m_SkipFebruary;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipFebruary
    {
      get { return m_SkipFebruary; }
      set
      {
        m_SkipFebruary = value;
        isSkipFebruaryDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipFebruaryDirty
    {
      get { return isSkipFebruaryDirty; }
    }
    #endregion

    #region SkipMarch
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipMarchDirty = false;
    private SkipThisMonthEnum m_SkipMarch;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipMarch
    {
      get { return m_SkipMarch; }
      set
      {
        m_SkipMarch = value;
        isSkipMarchDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipMarchDirty
    {
      get { return isSkipMarchDirty; }
    }
    #endregion

    #region SkipApril
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipAprilDirty = false;
    private SkipThisMonthEnum m_SkipApril;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipApril
    {
      get { return m_SkipApril; }
      set
      {
        m_SkipApril = value;
        isSkipAprilDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipAprilDirty
    {
      get { return isSkipAprilDirty; }
    }
    #endregion

    #region SkipMay
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipMayDirty = false;
    private SkipThisMonthEnum m_SkipMay;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipMay
    {
      get { return m_SkipMay; }
      set
      {
        m_SkipMay = value;
        isSkipMayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipMayDirty
    {
      get { return isSkipMayDirty; }
    }
    #endregion

    #region SkipJune
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipJuneDirty = false;
    private SkipThisMonthEnum m_SkipJune;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipJune
    {
      get { return m_SkipJune; }
      set
      {
        m_SkipJune = value;
        isSkipJuneDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipJuneDirty
    {
      get { return isSkipJuneDirty; }
    }
    #endregion

    #region SkipJuly
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipJulyDirty = false;
    private SkipThisMonthEnum m_SkipJuly;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipJuly
    {
      get { return m_SkipJuly; }
      set
      {
        m_SkipJuly = value;
        isSkipJulyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipJulyDirty
    {
      get { return isSkipJulyDirty; }
    }
    #endregion

    #region SkipAugust
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipAugustDirty = false;
    private SkipThisMonthEnum m_SkipAugust;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipAugust
    {
      get { return m_SkipAugust; }
      set
      {
        m_SkipAugust = value;
        isSkipAugustDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipAugustDirty
    {
      get { return isSkipAugustDirty; }
    }
    #endregion

    #region SkipSeptember
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipSeptemberDirty = false;
    private SkipThisMonthEnum m_SkipSeptember;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipSeptember
    {
      get { return m_SkipSeptember; }
      set
      {
        m_SkipSeptember = value;
        isSkipSeptemberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipSeptemberDirty
    {
      get { return isSkipSeptemberDirty; }
    }
    #endregion

    #region SkipOctober
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipOctoberDirty = false;
    private SkipThisMonthEnum m_SkipOctober;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipOctober
    {
      get { return m_SkipOctober; }
      set
      {
        m_SkipOctober = value;
        isSkipOctoberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipOctoberDirty
    {
      get { return isSkipOctoberDirty; }
    }
    #endregion

    #region SkipNovember
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipNovemberDirty = false;
    private SkipThisMonthEnum m_SkipNovember;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipNovember
    {
      get { return m_SkipNovember; }
      set
      {
        m_SkipNovember = value;
        isSkipNovemberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipNovemberDirty
    {
      get { return isSkipNovemberDirty; }
    }
    #endregion

    #region SkipDecember
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSkipDecemberDirty = false;
    private SkipThisMonthEnum m_SkipDecember;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SkipThisMonthEnum SkipDecember
    {
      get { return m_SkipDecember; }
      set
      {
        m_SkipDecember = value;
        isSkipDecemberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSkipDecemberDirty
    {
      get { return isSkipDecemberDirty; }
    }
    #endregion

    //boolean DOM objects

    #region bSkipSunday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipSundayDirty = false;
    private bool m_bSkipSunday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipSunday
    {
      get { return m_bSkipSunday; }
      set
      {
        m_bSkipSunday = value;
        isbSkipSundayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipSundayDirty
    {
      get { return isbSkipSundayDirty; }
    }
    #endregion


    #region bSkipMonday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipMondayDirty = false;
    private bool m_bSkipMonday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipMonday
    {
      get { return m_bSkipMonday; }
      set
      {
        m_bSkipMonday = value;
        isbSkipMondayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipMondayDirty
    {
      get { return isbSkipMondayDirty; }
    }
    #endregion

    #region bSkipTuesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipTuesdayDirty = false;
    private bool m_bSkipTuesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipTuesday
    {
      get { return m_bSkipTuesday; }
      set
      {
        m_bSkipTuesday = value;
        isbSkipTuesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipTuesdayDirty
    {
      get { return isbSkipTuesdayDirty; }
    }
    #endregion

    #region bSkipWednesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipWednesdayDirty = false;
    private bool m_bSkipWednesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipWednesday
    {
      get { return m_bSkipWednesday; }
      set
      {
        m_bSkipWednesday = value;
        isbSkipWednesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipWednesdayDirty
    {
      get { return isbSkipWednesdayDirty; }
    }
    #endregion

    #region bSkipThursday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipThursdayDirty = false;
    private bool m_bSkipThursday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipThursday
    {
      get { return m_bSkipThursday; }
      set
      {
        m_bSkipThursday = value;
        isbSkipThursdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipThursdayDirty
    {
      get { return isbSkipThursdayDirty; }
    }
    #endregion

    #region bSkipFriday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipFridayDirty = false;
    private bool m_bSkipFriday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipFriday
    {
      get { return m_bSkipFriday; }
      set
      {
        m_bSkipFriday = value;
        isbSkipFridayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipFridayDirty
    {
      get { return isbSkipFridayDirty; }
    }
    #endregion

    #region bSkipSaturday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipSaturdayDirty = false;
    private bool m_bSkipSaturday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipSaturday
    {
      get { return m_bSkipSaturday; }
      set
      {
        m_bSkipSaturday = value;
        isbSkipSaturdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipSaturdayDirty
    {
      get { return isbSkipSaturdayDirty; }
    }
    #endregion

    #region bExecuteSunday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteSundayDirty = false;
    private bool m_bExecuteSunday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteSunday
    {
      get { return m_bExecuteSunday; }
      set
      {
        m_bExecuteSunday = value;
        isbExecuteSundayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteSundayDirty
    {
      get { return isbExecuteSundayDirty; }
    }
    #endregion


    #region bExecuteMonday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteMondayDirty = false;
    private bool m_bExecuteMonday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteMonday
    {
      get { return m_bExecuteMonday; }
      set
      {
        m_bExecuteMonday = value;
        isbExecuteMondayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteMondayDirty
    {
      get { return isbExecuteMondayDirty; }
    }
    #endregion

    #region bExecuteTuesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteTuesdayDirty = false;
    private bool m_bExecuteTuesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteTuesday
    {
      get { return m_bExecuteTuesday; }
      set
      {
        m_bExecuteTuesday = value;
        isbExecuteTuesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteTuesdayDirty
    {
      get { return isbExecuteTuesdayDirty; }
    }
    #endregion

    #region bExecuteWednesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteWednesdayDirty = false;
    private bool m_bExecuteWednesday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteWednesday
    {
      get { return m_bExecuteWednesday; }
      set
      {
        m_bExecuteWednesday = value;
        isbExecuteWednesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteWednesdayDirty
    {
      get { return isbExecuteWednesdayDirty; }
    }
    #endregion

    #region bExecuteThursday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteThursdayDirty = false;
    private bool m_bExecuteThursday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteThursday
    {
      get { return m_bExecuteThursday; }
      set
      {
        m_bExecuteThursday = value;
        isbExecuteThursdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteThursdayDirty
    {
      get { return isbExecuteThursdayDirty; }
    }
    #endregion

    #region bExecuteFriday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteFridayDirty = false;
    private bool m_bExecuteFriday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteFriday
    {
      get { return m_bExecuteFriday; }
      set
      {
        m_bExecuteFriday = value;
        isbExecuteFridayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteFridayDirty
    {
      get { return isbExecuteFridayDirty; }
    }
    #endregion

    #region bExecuteSaturday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbExecuteSaturdayDirty = false;
    private bool m_bExecuteSaturday;
    [MTDataMember(Description = "This the Execute Time for Daily Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bExecuteSaturday
    {
      get { return m_bExecuteSaturday; }
      set
      {
        m_bExecuteSaturday = value;
        isbExecuteSaturdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbExecuteSaturdayDirty
    {
      get { return isbExecuteSaturdayDirty; }
    }
    #endregion

    #region bSkipJanuary
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipJanuaryDirty = false;
    private bool m_bSkipJanuary;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipJanuary
    {
      get { return m_bSkipJanuary; }
      set
      {
        m_bSkipJanuary = value;
        isbSkipJanuaryDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipJanuaryDirty
    {
      get { return isbSkipJanuaryDirty; }
    }
    #endregion

    #region bSkipFebruary
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipFebruaryDirty = false;
    private bool m_bSkipFebruary;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipFebruary
    {
      get { return m_bSkipFebruary; }
      set
      {
        m_bSkipFebruary = value;
        isbSkipFebruaryDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipFebruaryDirty
    {
      get { return isbSkipFebruaryDirty; }
    }
    #endregion

    #region bSkipMarch
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipMarchDirty = false;
    private bool m_bSkipMarch;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipMarch
    {
      get { return m_bSkipMarch; }
      set
      {
        m_bSkipMarch = value;
        isbSkipMarchDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipMarchDirty
    {
      get { return isbSkipMarchDirty; }
    }
    #endregion

    #region bSkipApril
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipAprilDirty = false;
    private bool m_bSkipApril;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipApril
    {
      get { return m_bSkipApril; }
      set
      {
        m_bSkipApril = value;
        isbSkipAprilDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipAprilDirty
    {
      get { return isbSkipAprilDirty; }
    }
    #endregion

    #region bSkipMay
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipMayDirty = false;
    private bool m_bSkipMay;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipMay
    {
      get { return m_bSkipMay; }
      set
      {
        m_bSkipMay = value;
        isbSkipMayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipMayDirty
    {
      get { return isbSkipMayDirty; }
    }
    #endregion

    #region bSkipJune
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipJuneDirty = false;
    private bool m_bSkipJune;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipJune
    {
      get { return m_bSkipJune; }
      set
      {
        m_bSkipJune = value;
        isbSkipJuneDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipJuneDirty
    {
      get { return isbSkipJuneDirty; }
    }
    #endregion

    #region bSkipJuly
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipJulyDirty = false;
    private bool m_bSkipJuly;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipJuly
    {
      get { return m_bSkipJuly; }
      set
      {
        m_bSkipJuly = value;
        isbSkipJulyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipJulyDirty
    {
      get { return isbSkipJulyDirty; }
    }
    #endregion

    #region bSkipAugust
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipAugustDirty = false;
    private bool m_bSkipAugust;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipAugust
    {
      get { return m_bSkipAugust; }
      set
      {
        m_bSkipAugust = value;
        isbSkipAugustDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipAugustDirty
    {
      get { return isbSkipAugustDirty; }
    }
    #endregion

    #region bSkipSeptember
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipSeptemberDirty = false;
    private bool m_bSkipSeptember;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipSeptember
    {
      get { return m_bSkipSeptember; }
      set
      {
        m_bSkipSeptember = value;
        isbSkipSeptemberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipSeptemberDirty
    {
      get { return isbSkipSeptemberDirty; }
    }
    #endregion

    #region bSkipOctober
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipOctoberDirty = false;
    private bool m_bSkipOctober;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipOctober
    {
      get { return m_bSkipOctober; }
      set
      {
        m_bSkipOctober = value;
        isbSkipOctoberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipOctoberDirty
    {
      get { return isbSkipOctoberDirty; }
    }
    #endregion

    #region bSkipNovember
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipNovemberDirty = false;
    private bool m_bSkipNovember;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipNovember
    {
      get { return m_bSkipNovember; }
      set
      {
        m_bSkipNovember = value;
        isbSkipNovemberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipNovemberDirty
    {
      get { return isbSkipNovemberDirty; }
    }
    #endregion

    #region bSkipDecember
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbSkipDecemberDirty = false;
    private bool m_bSkipDecember;
    [MTDataMember(Description = "This the Execute Time for Monthly Schedule.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bSkipDecember
    {
      get { return m_bSkipDecember; }
      set
      {
        m_bSkipDecember = value;
        isbSkipDecemberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbSkipDecemberDirty
    {
      get { return isbSkipDecemberDirty; }
    }
    #endregion





    }
}

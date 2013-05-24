using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.ProductCatalog
{
    [DataContract]
    [Serializable]
    public class Calendar : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier for the calendar. ", Length = 40)]
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

        #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name for the calendar instance. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Name
    {
      get { return m_Name; }
      set
      {
          m_Name = value;
          isNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNameDirty
    {
      get { return isNameDirty; }
    }
    #endregion

        #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "This is the description for the calendar instance.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Description
    {
      get { return m_Description; }
      set
      {
          m_Description = value;
          isDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDescriptionDirty
    {
      get { return isDescriptionDirty; }
    }
    #endregion

        #region LocalizedDescriptions
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDescriptionsDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDescriptions = new Dictionary<LanguageCode,string>();
    [MTDataMember(Description = "This is a collection of localized descriptions for the calendar.  The collection is keyed by values from the LanguageCode enumeration.  If a value cannot be found for a specific LanguageCode, the value from the Description property should be used as a default. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDescriptions
    {
      get 
      {
          if (m_LocalizedDescriptions == null)
          {
              m_LocalizedDescriptions = new Dictionary<LanguageCode, string>();
          }

          return m_LocalizedDescriptions; 
      }
      set
      {
          m_LocalizedDescriptions = value;
          isLocalizedDescriptionsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDescriptionsDirty
    {
      get { return isLocalizedDescriptionsDirty; }
    }
    #endregion

        #region Holidays
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isHolidaysDirty = false;
    private List<CalendarHoliday> m_Holidays;
    [MTDataMember(Description = "This is a collection of CalendarHoliday objects that define the time-period classifications for specific holidays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<CalendarHoliday> Holidays
    {
      get { return m_Holidays; }
      set
      {
          m_Holidays = value;
          isHolidaysDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsHolidaysDirty
    {
      get { return isHolidaysDirty; }
    }
    #endregion

        #region DefaultWeekday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDefaultWeekdayDirty = false;
    private CalendarWeekday m_DefaultWeekday;
    [MTDataMember(Description = "This is an instance of the CalendarWeekday class that defines the default time-period classifications for weekdays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday DefaultWeekday
    {
      get { return m_DefaultWeekday; }
      set
      {
          m_DefaultWeekday = value;
          isDefaultWeekdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDefaultWeekdayDirty
    {
      get { return isDefaultWeekdayDirty; }
    }
    #endregion

        #region Monday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMondayDirty = false;
    private CalendarWeekday m_Monday;
    [MTDataMember(Description = "This is an instance of the CalendarWeekday class that defines the time-period classifications for Mondays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Monday
    {
      get { return m_Monday; }
      set
      {
          m_Monday = value;
          isMondayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMondayDirty
    {
      get { return isMondayDirty; }
    }
    #endregion

        #region Tuesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTuesdayDirty = false;
    private CalendarWeekday m_Tuesday;
    [MTDataMember(Description = "This is an instance of the CalendarWeekday class that defines the time-period classifications for Tuesdays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Tuesday
    {
      get { return m_Tuesday; }
      set
      {
          m_Tuesday = value;
          isTuesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTuesdayDirty
    {
      get { return isTuesdayDirty; }
    }
    #endregion

        #region Wednesday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isWednesdayDirty = false;
    private CalendarWeekday m_Wednesday;
    [MTDataMember(Description = "This is an instance of the CalendarWeekday class that defines the time-period classifications for Wednesdays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Wednesday
    {
      get { return m_Wednesday; }
      set
      {
          m_Wednesday = value;
          isWednesdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsWednesdayDirty
    {
      get { return isWednesdayDirty; }
    }
    #endregion

        #region Thursday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isThursdayDirty = false;
    private CalendarWeekday m_Thursday;
    [MTDataMember(Description = " This is an instance of the CalendarWeekday class that defines the time-period classifications for Thursdays.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Thursday
    {
      get { return m_Thursday; }
      set
      {
          m_Thursday = value;
          isThursdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsThursdayDirty
    {
      get { return isThursdayDirty; }
    }
    #endregion

        #region Friday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFridayDirty = false;
    private CalendarWeekday m_Friday;
    [MTDataMember(Description = "This is an instance of the CalendarWeekday class that defines the time-period classifications for Fridays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Friday
    {
      get { return m_Friday; }
      set
      {
          m_Friday = value;
          isFridayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFridayDirty
    {
      get { return isFridayDirty; }
    }
    #endregion

        #region DefaultWeekend
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDefaultWeekendDirty = false;
    private CalendarWeekday m_DefaultWeekend;
    [MTDataMember(Description = " This is an instance of the CalendarWeekday class that defines the default time-period classifications for weekend days.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday DefaultWeekend
    {
      get { return m_DefaultWeekend; }
      set
      {
          m_DefaultWeekend = value;
          isDefaultWeekendDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDefaultWeekendDirty
    {
      get { return isDefaultWeekendDirty; }
    }
    #endregion

        #region Saturday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSaturdayDirty = false;
    private CalendarWeekday m_Saturday;
    [MTDataMember(Description = " This is an instance of the CalendarWeekday class that defines the time-period classifications for Saturdays.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Saturday
    {
      get { return m_Saturday; }
      set
      {
          m_Saturday = value;
          isSaturdayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSaturdayDirty
    {
      get { return isSaturdayDirty; }
    }
    #endregion

        #region Sunday
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSundayDirty = false;
    private CalendarWeekday m_Sunday;
    [MTDataMember(Description = "This is an instance of the CalendarWeekday class that defines the time-period classifications for Sundays. ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CalendarWeekday Sunday
    {
      get { return m_Sunday; }
      set
      {
          m_Sunday = value;
          isSundayDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSundayDirty
    {
      get { return isSundayDirty; }
    }
    #endregion
    }
}

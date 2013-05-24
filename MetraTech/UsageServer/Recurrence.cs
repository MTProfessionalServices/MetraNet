using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Runtime.Serialization;
using System.Xml;
using MetraTech.Xml;

namespace MetraTech.UsageServer
{
  [KnownType(typeof(MinutelyRecurrencePattern))]
  [KnownType(typeof(DailyRecurrencePattern))]
  [KnownType(typeof(WeeklyRecurrencePattern))]
  [KnownType(typeof(MonthlyRecurrencePattern))]
  [KnownType(typeof(ManualRecurrencePattern))]
  [KnownType(typeof(Times))]
  [KnownType(typeof(DaysOfWeek))]
  [KnownType(typeof(DaysOfMonth))]
  [KnownType(typeof(DaysOfMonth.DayOfMonthTemplate))]
  [KnownType(typeof(DaysOfMonth.DayOfMonthTemplateByDayNumber))]
  [KnownType(typeof(DaysOfMonth.DayOfMonthTemplateByWeekDay))]
  [KnownType(typeof(DaysOfMonth.DayOfMonthTemplateLastDay))]
  [DataContract]
  [Serializable]
  public abstract class BaseRecurrencePattern
  {
    [DataMember]
    protected DateTime mStartDate;
    [DataMember]
    public virtual DateTime StartDate
    {
      get { return mStartDate; }
      set { mStartDate = value; }
    }
    [DataMember]
    public DateTime OverrideDate;
    [DataMember]
    public Boolean IsPaused;

    public BaseRecurrencePattern()
    {
      // default start date to '2010-01-01T00:00:00.00'
      StartDate = new DateTime(2010, 1, 1, 0, 0, 0);
      OverrideDate = MetraTime.Min;
      IsPaused = false;
    }

    /// <summary>
    /// Next Occurrence of the event. Override is used, isPaused is used.
    /// </summary>
    /// <returns></returns>
    public DateTime GetNextOccurrence()
    {
      if (IsPaused) return MetraTime.Max;
      if (IsOverride) return OverrideDate;
      return GetNextPatternOccurrence();
    }

    /// <summary>
    /// Next Occurrence of the pattern
    /// </summary>
    public DateTime GetNextPatternOccurrence()
    {
      return GetNextPatternOccurrenceAfter(MetraTime.Now);
    }

    /// <summary>
    /// Calculate the next time the pattern occurrs after given date.
    /// For example pattern "Every 1 day, at 5:00AM" will return:
    ///   GetNextPatternOccurrenceAfter("2001-01-24 10:00 AM") -> "2001-01-25 5:00 AM"
    /// </summary>
    /// <param name="date">date after which the next occurrence should happen</param>
    /// <returns>date of the next occurrence</returns>
    public abstract DateTime GetNextPatternOccurrenceAfter(DateTime date);

    /// <summary>
    /// Date of the pattern occurrence if you skip first one.
    /// For example if you have pattern "Every 1 day, at 5:00AM" and now is "2001-01-24 10:00 AM"
    ///  next occurrence would be "2001-01-25 5:00 AM" 
    ///  and skip one occurrence would be "2001-01-26 5:00 AM"
    /// </summary>
    /// <returns></returns>
    public DateTime GetSkipOnePatternOccurrence()
    {
      DateTime nextPatternOccurrence = GetNextPatternOccurrence();
      DateTime nextPatternOccurrenceSkipOne = GetNextPatternOccurrenceAfter(nextPatternOccurrence);
      return nextPatternOccurrenceSkipOne;
    }

    /// <summary>
    /// Is override date actualy the same as skip one date? If so than it is a skip one date
    /// </summary>
    public Boolean IsSkipOne
    {
      get
      {
        return (GetSkipOnePatternOccurrence() == OverrideDate);
      }
      set
      {
        if (value)
        {
          OverrideDate = GetSkipOnePatternOccurrence();
        }
        else
        {
          OverrideDate = MetraTime.Min;
        }
      }
    }

    public Boolean IsOverride
    {
      get
      {
        return (OverrideDate > MetraTime.Now);
      }
    }

    public override bool Equals(object obj)
    {
      if (!PatternEquals(obj)) return false;
      BaseRecurrencePattern other = (BaseRecurrencePattern)obj;
      if (other == null) return false;
      if (other.IsPaused != IsPaused) return false;
      // if override is in the past - we do not care about it.
      if (IsOverride || other.IsOverride) {
        if (other.OverrideDate != OverrideDate) return false;
      }
      return true;
    }

    public override string ToString()
    {
      return base.ToString();
    }

    /// <summary>
    ///  check that 2 patterns are equal. Do not check paused/override flags.
    /// </summary>
    /// <param name="obj"></param>
    public virtual bool PatternEquals(object obj) {
      if (obj == null) return false;
      BaseRecurrencePattern other = (BaseRecurrencePattern)obj;
      if (other == null) return false;
      if (other.StartDate != StartDate) return false;
      if (other.GetType() != GetType()) return false; // so we don't compare minutely to monthly
      return true;
    }

    public override int GetHashCode()
    {
      return StartDate.GetHashCode() ^ OverrideDate.GetHashCode() ^ IsPaused.GetHashCode();
    }


  }

  [DataContract]
  [Serializable]
  public class MinutelyRecurrencePattern : BaseRecurrencePattern
  {
    public int mIntervalInMinutes;
    [DataMember]
    public int IntervalInMinutes
    {
      get { return mIntervalInMinutes; }
      set
      {
        if (value <= 0) throw new Exception("Interval in Minutes must be a positive number");
        mIntervalInMinutes = value;
      }
    }

    public MinutelyRecurrencePattern(int intervalInMinutes)
    {
      this.IntervalInMinutes = intervalInMinutes;
    }
    public override string ToString()
    {
      return string.Format("Every {0} minute(s)", IntervalInMinutes);
    }

    public override DateTime GetNextPatternOccurrenceAfter(DateTime date)
    {
      date = date.AddSeconds(1); //add one second as to not get the same date
      if (StartDate > date) return GetNextPatternOccurrenceAfter(StartDate);
      TimeSpan ts = date.Subtract(StartDate);
      int minutes = ((int)Math.Floor(ts.TotalMinutes) / IntervalInMinutes + 1) * IntervalInMinutes;
      return StartDate.AddMinutes(minutes);
    }

    public override bool PatternEquals(object obj)
    {
      if (!base.PatternEquals(obj)) return false;
      MinutelyRecurrencePattern other = (MinutelyRecurrencePattern)obj;
      if (other == null) return false;
      return (IntervalInMinutes == other.IntervalInMinutes);
    }
  }

  [DataContract]
  [Serializable]
  public class DailyRecurrencePattern : BaseRecurrencePattern
  {
    public int mIntervalInDays;
    [DataMember]
    public int IntervalInDays
    {
      get { return mIntervalInDays; }
      set {
        if (value <= 0) throw new Exception("Interval in Days must be a positive number");
        mIntervalInDays = value;
      } 
    }
    [DataMember]
    public Times ExecutionTimes;
    public DailyRecurrencePattern(int intervalInDays, string executionTimes)
      : base()
    {
      this.IntervalInDays = intervalInDays;
      this.ExecutionTimes = Times.Parse(executionTimes);
    }

    public override DateTime GetNextPatternOccurrenceAfter(DateTime date)
    {
      date = date.AddSeconds(1); //add one second as to not get the same date
      if (StartDate > date) return GetNextPatternOccurrenceAfter(StartDate);
      TimeSpan ts = date.Subtract(StartDate);
      int totalDays = (int)Math.Floor(ts.TotalDays); // truncate to the lowest int.
      DateTime nextDate;
      if (totalDays % IntervalInDays == 0)
      { // if pattern falls on the same date
        nextDate = date;
      }
      else
      {
        int daysDifference = (totalDays / IntervalInDays + 1) * IntervalInDays;
        nextDate = StartDate.AddDays(daysDifference);
        nextDate = nextDate.Subtract(nextDate.TimeOfDay);// if it is next day, it should start from midnight
      }
      bool isNextDay;
      TimeSpan timeOfDay = ExecutionTimes.NextTime(nextDate.TimeOfDay, out isNextDay);
      if (isNextDay)
      {
        nextDate = date.AddDays(IntervalInDays);
      }
      return new DateTime(nextDate.Year, nextDate.Month, nextDate.Day, timeOfDay.Hours, timeOfDay.Minutes, timeOfDay.Seconds);
    }

    public override string ToString()
    {
      return string.Format("Every {0} days at {1}", IntervalInDays, ExecutionTimes.ToString());
    }

    public override bool PatternEquals(object obj)
    {
      if (!base.PatternEquals(obj)) return false;
      DailyRecurrencePattern other = (DailyRecurrencePattern)obj;
      if (other == null) return false;
      if (IntervalInDays != other.IntervalInDays) return false;
      if (ExecutionTimes.ToString() != other.ExecutionTimes.ToString()) return false;
      return true;
    }

  }

  [DataContract]
  [Serializable]
  public class WeeklyRecurrencePattern : BaseRecurrencePattern
  {
    public override DateTime StartDate
    {
      get { return base.StartDate; }
      set
      {
        base.StartDate = value;
        FixStartDate(); // move to sunday midnight
      }
    }
    public int mIntervalInWeeks;
    [DataMember]
    public int IntervalInWeeks
    { 
      get { return mIntervalInWeeks; } 
      set { 
        if (value <= 0) throw new Exception("Interval in Weeks must be a positive number");
        mIntervalInWeeks= value;
      }
    }
    [DataMember]
    public Times ExecutionTimes;
    [DataMember]
    public DaysOfWeek DaysOfWeek;

    public WeeklyRecurrencePattern(int intervalInWeeks, string executionTimes, string daysOfWeek)
      : base()
    {
      this.IntervalInWeeks = intervalInWeeks;
      this.ExecutionTimes = Times.Parse(executionTimes);
      this.DaysOfWeek = DaysOfWeek.Parse(daysOfWeek);
      FixStartDate();
    }

    /// <summary>
    /// Move start date to the beginning of the week, sunday Midnight
    /// </summary>
    private void FixStartDate()
    {
      while (mStartDate.DayOfWeek != DayOfWeek.Sunday) mStartDate = mStartDate.AddDays(-1);
      mStartDate = StartDate.Subtract(StartDate.TimeOfDay);
    }

    public override string ToString()
    {
      return string.Format("Every {0} week(s) on {1} at {2}", IntervalInWeeks, DaysOfWeek.ToString(), ExecutionTimes.ToString());
    }

    public override DateTime GetNextPatternOccurrenceAfter(DateTime date)
    {
      date = date.AddSeconds(1); //add one second as to not get the same date
      if (StartDate > date) return GetNextPatternOccurrenceAfter(StartDate);
      TimeSpan ts = date.Subtract(StartDate);
      int totalWeeks = (int)Math.Floor(ts.TotalDays / 7); // truncate to the lowest int.

      DateTime nextDate;
      if (totalWeeks % IntervalInWeeks == 0)
      { // if pattern falls on the same week
        nextDate = date;
      }
      else
      {
        int daysDifference = ((totalWeeks / IntervalInWeeks + 1) * IntervalInWeeks) * 7;
        nextDate = StartDate.AddDays(daysDifference);
        nextDate = nextDate.Subtract(nextDate.TimeOfDay);// if it is next day, it should start from midnight
        while (nextDate.DayOfWeek != DayOfWeek.Sunday) nextDate = nextDate.AddDays(-1); // if it is next week, it should start from Sunday
      }
      bool isNextWeek;
      DayOfWeek dof = DaysOfWeek.NextTime(nextDate.DayOfWeek, out isNextWeek);
      if (isNextWeek)
      {
        nextDate = nextDate.AddDays(7 * IntervalInWeeks); // add interval in weeks
        nextDate = nextDate.Subtract(nextDate.TimeOfDay);// if it is next day, it should start from midnight
        while (nextDate.DayOfWeek != DayOfWeek.Sunday) nextDate = nextDate.AddDays(-1); // move to beginning of the week
      }
      if (nextDate.DayOfWeek != dof)
      {
        nextDate = nextDate.Subtract(nextDate.TimeOfDay);// if it is next day, it should start from midnight
        while (nextDate.DayOfWeek != dof) nextDate = nextDate.AddDays(1); // move to the right day
      }

      bool isNextDay;
      TimeSpan timeOfDay = ExecutionTimes.NextTime(nextDate.TimeOfDay, out isNextDay);
      if (isNextDay)
      {
        nextDate = nextDate.AddDays(1);
        nextDate = nextDate.Subtract(nextDate.TimeOfDay);
        return GetNextPatternOccurrenceAfter(nextDate);// to lazy to repeat all steps, just repeat them recursively
      }
      return new DateTime(nextDate.Year, nextDate.Month, nextDate.Day, timeOfDay.Hours, timeOfDay.Minutes, timeOfDay.Seconds);
    }

    public override bool PatternEquals(object obj)
    {
      if (!base.PatternEquals(obj)) return false;
      WeeklyRecurrencePattern other = (WeeklyRecurrencePattern)obj;
      if (other == null) return false;
      if (IntervalInWeeks != other.IntervalInWeeks) return false;
      if (ExecutionTimes.ToString() != other.ExecutionTimes.ToString()) return false;
      if (DaysOfWeek.ToString() != other.DaysOfWeek.ToString()) return false;
      return true;
    }

  }

  [DataContract]
  [Serializable]
  public class MonthlyRecurrencePattern : BaseRecurrencePattern
  {
    public int mIntervalInMonth;
    [DataMember]
    public int IntervalInMonth
    {
      get { return mIntervalInMonth; }
      set
      {
        if (value <= 0) throw new Exception("Interval in Month must be a positive number");
        mIntervalInMonth = value;
      }
    }
    [DataMember]
    public Times ExecutionTimes;
    [DataMember]
    public DaysOfMonth DaysOfMonth;

    public MonthlyRecurrencePattern(int intervalInMonth, string executionTimes, string daysOfMonth)
      : base()
    {
      this.IntervalInMonth = intervalInMonth;
      this.ExecutionTimes = Times.Parse(executionTimes);
      this.DaysOfMonth = DaysOfMonth.Parse(daysOfMonth);
    }

    public override string ToString()
    {
      return string.Format("Every {0} month(s) on {1} at {2}", IntervalInMonth, DaysOfMonth.ToString(), ExecutionTimes.ToString());
    }

    public override DateTime GetNextPatternOccurrenceAfter(DateTime date)
    {
      date = date.AddSeconds(1); //add one second as to not get the same date
      if (StartDate > date) return GetNextPatternOccurrenceAfter(StartDate);
      // Calculate total month between start month and 
      int TotalMonth = (date.Year - StartDate.Year) * 12 + (date.Month - StartDate.Month);

      DateTime nextDate;
      if (TotalMonth % IntervalInMonth == 0)
      { // if pattern falls on the same week
        nextDate = date;
      }
      else
      {
        nextDate = (new DateTime(StartDate.Year, StartDate.Month, 1)).AddMonths((TotalMonth / IntervalInMonth + 1) * IntervalInMonth);
      }
      bool isNextMonth;
      int DayInMonth = DaysOfMonth.NextTime(nextDate, out isNextMonth);
      if (isNextMonth)
      {
        nextDate = (new DateTime(nextDate.Year, nextDate.Month, 1)).AddMonths(IntervalInMonth);// add IntervalInMonth
        DayInMonth = DaysOfMonth.NextTime(nextDate, out isNextMonth); // recalculate DayInMonth. -1 was retured before
        nextDate = new DateTime(nextDate.Year, nextDate.Month, DayInMonth); // set to the right day in month
      }
      else
      {
        if (DayInMonth != nextDate.Day)
          nextDate = new DateTime(nextDate.Year, nextDate.Month, DayInMonth); // set to the right day in month
      }

      bool isNextDay;
      TimeSpan timeOfDay = ExecutionTimes.NextTime(nextDate.TimeOfDay, out isNextDay);
      if (isNextDay)
      {
        nextDate = nextDate.AddDays(1);
        nextDate = nextDate.Subtract(nextDate.TimeOfDay);
        return GetNextPatternOccurrenceAfter(nextDate);// to lazy to repeat all steps, just repeat them recursively
      }
      return new DateTime(nextDate.Year, nextDate.Month, nextDate.Day, timeOfDay.Hours, timeOfDay.Minutes, timeOfDay.Seconds);
    }

    public override bool PatternEquals(object obj)
    {
      if (!base.PatternEquals(obj)) return false;
      MonthlyRecurrencePattern other = (MonthlyRecurrencePattern)obj;
      if (other == null) return false;
      if (IntervalInMonth != other.IntervalInMonth) return false;
      if (ExecutionTimes.ToString() != other.ExecutionTimes.ToString()) return false;
      if (DaysOfMonth.ToString() != other.DaysOfMonth.ToString()) return false;
      return true;
    }

  }

  [DataContract]
  [Serializable]
  public class ManualRecurrencePattern : BaseRecurrencePattern
  {
    public override string ToString()
    {
      return "Manual";
    }

    public override DateTime GetNextPatternOccurrenceAfter(DateTime date)
    {
      return MetraTime.Max;
    }
  }

  /// <summary>
  /// A class to work with a list of execution times. execution times is point in time during the 
  /// 24 hour period when the adapter need to run. This class can parse string of execution times,
  /// compare two lists, convert to string in en-US format.
  /// For example adapter might need to run at 1 AM, and 1PM. Execution time will parse a string like
  /// "1:00 AM, 1:00 PM" or "1:00,13:00" or any format readable by DateTime.Parse.
  /// </summary>
  [DataContract]
  [Serializable]
  public class Times
  {
    [DataMember]
    private List<TimeSpan> timeList = new List<TimeSpan>();

    /// <summary>
    /// Private constructor to force the use of Parse
    /// </summary>
    private Times() { }

    /// <summary>
    /// Parse comma delimited string with execution times and store them in internal TimeSpan list
    /// For example adapter might need to run at 1 AM, and 1PM. Execution time will parse a string like
    /// "1:00 AM, 1:00 PM" or "1:00,13:00" or any format readable by DateTime.Parse.
    /// </summary>
    /// <param name="timesStr"></param>
    /// <returns></returns>
    public static Times Parse(string timesStr)
    {
      Times times = new Times();
      string[] timeArray = timesStr.Split(',');
      if (timeArray.Length == 0) throw new Exception("Nothing to parse");
      foreach (string time in timeArray)
      {
        TimeSpan ts = ParseTimeUnitFromString(time);
        if (!times.timeList.Contains(ts))
        {
          times.timeList.Add(ts);
        }
      }
      times.timeList.Sort(); // this is important.
      return times;
    }

    /// <summary>
    /// Convert a list of TimeSpans to a comma delimited string list. "t" is used to format time.
    /// Output will look like "1:00 AM, 2:25 PM, 6:15 PM"
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      List<string> stringList = new List<string>();
      foreach (TimeSpan ts in timeList)
      {
        // Use a simple trick here. Can't create a DateTime struct with no date part, so
        // use any date part with valid hour/minute and convert it to string using just time portion.
        string timeStr = TimeUnitToString(ts);
        stringList.Add(timeStr);
      }

      return string.Join(", ", stringList.ToArray());
    }

    /// <summary>
    /// Return the next time event should occurr after given afterTime paramter.
    /// For example for time list like "1:00 AM, 2:25 PM, 6:15 PM" and
    /// timeAfter is "2:00 PM" next time will be same day at 2:25 PM and isNextDay will be false
    /// timeAfter is "7:00 PM" next time will be 1:00 AM on some different day, isNextDay wll be true
    /// </summary>
    /// <param name="afterTime">time during the day after which event should occur</param>
    /// <param name="isNextDay">
    /// false - if event is the same day
    /// true  - if event is some other day
    /// </param>
    /// <returns></returns>
    public TimeSpan NextTime(TimeSpan afterTime, out Boolean isNextDay)
    {
      isNextDay = false;
      foreach (TimeSpan time in timeList)
      {
        if (afterTime <= time) return time;
      }
      isNextDay = true;
      return timeList[0];
    }

    private static TimeSpan ParseTimeUnitFromString(string time)
    {
      //DateTime d = DateTime.Parse(time);
      DateTime d;
      if (!DateTime.TryParse(time, out d))
        throw new Exception(string.Format("Unable to parse time {0}", time));
      return d.TimeOfDay;
    }

    private string TimeUnitToString(TimeSpan ts)
    {
      // Use a simple trick here. Can't create a DateTime struct with no date part, so
      // use any date part with valid hour/minute and convert it to string using just time portion.

      DateTime date = new DateTime(2010, 01, 24, ts.Hours, ts.Minutes, 0);
      string timeStr = date.ToString("t"); // in the format "9:15 PM"
      return timeStr;
    }

  }

  /// <summary>
  /// A class to work with a list of week days. Week Day is a day in the week when the adapter need to run.
  /// This class can parse string of week days, compare two lists, convert to string in en-US format.
  /// For example adapter might need to run at Monday, Wednesday and Friday. DaysOfWeek will parse a string like
  /// "Mon, Tue, Fri" or "Monday, Tuesday, Friday" or any other form familiar to DateTimeFormatInfo class.
  /// </summary>
  [DataContract]
  [Serializable]
  public class DaysOfWeek
  {
    [DataMember]
    private List<DayOfWeek> timeList = new List<DayOfWeek>();

    private DaysOfWeek() { } // private constructor so that DaysOfWeek only created through parse

    /// <summary>
    /// Parse comma delimited string with days of week and store them in internal DayOfWeek list
    /// For example adapter might need to run at Monday, Wednesday and Friday. DaysOfWeek will parse a string like
    /// "Mon, Tue, Fri" or "Monday, Tuesday, Friday" or any other form familiar to DateTimeFormatInfo class.
    /// </summary>
    /// <param name="daysStr"></param>
    /// <returns></returns>
    public static DaysOfWeek Parse(string daysStr)
    {
      DaysOfWeek days = new DaysOfWeek();
      string[] timeArray = daysStr.Split(',');
      if (timeArray.Length == 0) throw new Exception("Nothing to parse");
      foreach (string time in timeArray)
      {
        DayOfWeek d = ParseTimeUnitFromString(time);
        if (!days.timeList.Contains(d)) {
          days.timeList.Add(d);
        }
      }
      days.timeList.Sort(); // this is important.
      return days;
    }

    public override string ToString()
    {
      List<string> stringList = new List<string>();
      foreach (DayOfWeek day in timeList)
      {
        string timeStr = TimeUnitToString(day);
        stringList.Add(timeStr);
      }

      return string.Join(", ", stringList.ToArray());
    }

    private static DayOfWeek ParseTimeUnitFromString(string time)
    {
      time = time.Trim();
      CultureInfo ci = new CultureInfo("en-US");
      DateTimeFormatInfo dtfi = ci.DateTimeFormat;
      for (int i = 0; i < 7; i++)
      {
        if (String.Equals(time, dtfi.AbbreviatedDayNames[i], StringComparison.InvariantCultureIgnoreCase)) return (DayOfWeek)i;
        if (String.Equals(time, dtfi.DayNames[i], StringComparison.InvariantCultureIgnoreCase)) return (DayOfWeek)i;
        if (String.Equals(time, dtfi.ShortestDayNames[i], StringComparison.InvariantCultureIgnoreCase)) return (DayOfWeek)i;
      }
      throw new Exception(string.Format("Can't parse day of week: {0}", time));

    }

    private string TimeUnitToString(DayOfWeek day)
    {
      CultureInfo ci = new CultureInfo("en-US");
      DateTimeFormatInfo dtfi = ci.DateTimeFormat;
      return dtfi.AbbreviatedDayNames[(int)day];
    }

    /// <summary>
    /// Return the next time event should occurr after given afterTime paramter.
    /// For example for time list like "Mon, Wed, Fri" and
    /// timeAfter is "Tue" next time will be same week on Wed and isNextWeek will be false
    /// timeAfter is "Sat" next time will be Mon on some different week, isNextWeek wll be true
    /// </summary>
    /// <param name="afterTime">day during the week after which event should occur</param>
    /// <param name="isNextDay">
    /// false - if event is the same day
    /// true  - if event is some other day
    /// </param>
    /// <returns></returns>
    public DayOfWeek NextTime(DayOfWeek afterTime, out Boolean isNextWeek)
    {
      isNextWeek = false;
      foreach (DayOfWeek time in timeList)
      {
        if (afterTime <= time) return time;
      }
      isNextWeek = true;
      return timeList[0];
    }

  }

  /// <summary>
  /// A class to work with a list of days in the month. Day in the month is a template representing some 
  /// day in a month when adapter need to run. Template can have 3 basic forms.
  /// Will parse strings in the following format:
  ///       Format: <DayOfMonth [,DayOfMonth] ...>
  ///               DayOfMonth: {Accessor DayOfWeek | DayNumber | Last Day}
  ///               Accessor: First, Second, Third, Fourth, Last
  ///               DayOfWeek: Name of the Day of the week (Sunday, Monday, etc...)
  ///               DayNumber: 1,2,...,31
  ///               Last Day: indicates the last day of the month
  ///       Example: DaysOfMonth="15,last day" - run on the 15 of the month and on the last day of the month
  ///                DaysOfMonth="First Monday" - run on first Monday of every month
  ///                DaysOfMonth="1,15" - run on 1st and 15th of the month
  /// </summary>
  [DataContract]
  [Serializable]
  public class DaysOfMonth
  {
    [Serializable]
    public abstract class DayOfMonthTemplate
    {
      public abstract DateTime GetDayInMonth(int year, int month);
      public override bool Equals(Object obj)
      {
        //Check for null and compare run-time types.
        if (obj == null || GetType() != obj.GetType()) return false;
        return true;
      }
      public override int GetHashCode()
      {
        return base.GetHashCode();
      }
    }

    [Serializable]
    public class DayOfMonthTemplateByDayNumber : DayOfMonthTemplate, IComparable<DayOfMonthTemplateByDayNumber>
    {
      public int DayNumber;
      public DayOfMonthTemplateByDayNumber(int dayNumber)
      {
        if ((dayNumber < 1) || (dayNumber > 31))
          throw new ArgumentOutOfRangeException("dayNumber", "must be betweek 1 and 31");
        this.DayNumber = dayNumber;
      }
      public override DateTime GetDayInMonth(int year, int month)
      {
        int daysInMonth = DateTime.DaysInMonth(year, month);
        if (DayNumber <= daysInMonth) return new DateTime(year, month, DayNumber);
        else return new DateTime(year, month, daysInMonth);// return last day
      }
      public override string ToString()
      {
        return DayNumber.ToString();
      }
      public override bool Equals(Object obj)
      {
        return base.Equals(obj) && DayNumber == ((DayOfMonthTemplateByDayNumber)obj).DayNumber;
      }
      public override int GetHashCode()
      {
        return DayNumber;
      }

      #region IComparable<DayOfMonthTemplateByDayNumber> Members

      public int CompareTo(DayOfMonthTemplateByDayNumber other)
      {
        // If other is not a valid object reference, this instance is greater.
        if (other == null) return 1;

        return DayNumber.CompareTo(other.DayNumber);
      }

      #endregion
    }

    [Serializable]
    public class DayOfMonthTemplateLastDay : DayOfMonthTemplate
    {
      public override DateTime GetDayInMonth(int year, int month)
      {
        int daysInMonth = DateTime.DaysInMonth(year, month);
        return new DateTime(year, month, daysInMonth);// return last day
      }
      public override string ToString()
      {
        return "Last Day";
      }
    }

    [Serializable]
    public class DayOfMonthTemplateByWeekDay : DayOfMonthTemplate, IComparable<DayOfMonthTemplateByWeekDay>
    {
      public enum WeekDayAccessor { First, Second, Third, Fourth, Last };
      private WeekDayAccessor Accessor;
      private DayOfWeek Day;
      public DayOfMonthTemplateByWeekDay(WeekDayAccessor accessor, DayOfWeek day)
      {
        this.Accessor = accessor;
        this.Day = day;
      }
      public override DateTime GetDayInMonth(int year, int month)
      {
        int daysInMonth = DateTime.DaysInMonth(year, month);
        // What is this monstrocity? 
        // It is basically an array representing given calendar month/year.
        // But as you can't declare array of generic lists, I get away with
        // creating dictionary of lists. No typecasting anywhere and can use Last()
        Dictionary<DayOfWeek, List<DateTime>> MonthCalendar = new Dictionary<DayOfWeek, List<DateTime>>();
        //initialize
        foreach (DayOfWeek day in Enum.GetValues(typeof(DayOfWeek)))
        {
          MonthCalendar[day] = new List<DateTime>();
        }
        //populate
        for (int day = 1; day <= daysInMonth; day++)
        {
          DateTime date = new DateTime(year, month, day);
          MonthCalendar[date.DayOfWeek].Add(date);
        }
        //pick the right one
        switch (Accessor)
        {
          case WeekDayAccessor.First:
            return MonthCalendar[Day][0];
          case WeekDayAccessor.Second:
            return MonthCalendar[Day][1];
          case WeekDayAccessor.Third:
            return MonthCalendar[Day][2];
          case WeekDayAccessor.Fourth:
            return MonthCalendar[Day][3];
          case WeekDayAccessor.Last:
            return MonthCalendar[Day].Last();
          default:
            throw new Exception("How did I get here?");
        }
      }
      public override string ToString()
      {
        return string.Format("{0} {1}", Accessor.ToString(), Day.ToString());
      }
      public override bool Equals(Object obj)
      {
        if (!base.Equals(obj)) return false;
        DayOfMonthTemplateByWeekDay dayobj = (DayOfMonthTemplateByWeekDay)obj;
        return (dayobj.Day == Day && dayobj.Accessor == Accessor);
      }
      public override int GetHashCode()
      {
        return (int)Day^(int)Accessor;
      }

      #region IComparable<DayOfMonthTemplateByWeekDay> Members

      public int CompareTo(DayOfMonthTemplateByWeekDay other)
      {
        if (other == null) return 1;
        if (Accessor == other.Accessor) return Day.CompareTo(other.Day);
        return Accessor.CompareTo(other.Accessor);
      }

      #endregion
    }

    [DataMember]
    private List<DayOfMonthTemplate> timeList = new List<DayOfMonthTemplate>();

    private DaysOfMonth() { } // private constructor so that DaysOfMonth only created through parse

    /// <summary>
    /// Parse comma delimited string with days of week and store them in internal DayOfWeek list
    /// For example adapter might need to run at Monday, Wednesday and Friday. Execution time will parse a string like
    /// "Mon, Tue, Fri" or "Monday, Tuesday, Friday" or any other form familiar to DateTimeFormatInfo class.
    /// </summary>
    /// <param name="daysStr"></param>
    /// <returns></returns>
    public static DaysOfMonth Parse(string daysStr)
    {
      DaysOfMonth days = new DaysOfMonth();
      string[] timeArray = daysStr.Split(',');
      if (timeArray.Length == 0) throw new Exception("Nothing to parse");
      foreach (string time in timeArray)
      {
        DayOfMonthTemplate d = ParseTimeUnitFromString(time);
        if (!days.timeList.Contains(d))
        {
          days.timeList.Add(d);
        }
      }
      days.timeList.Sort(CompareTemplatesByType);
      return days;
    }

    private static int CompareTemplatesByType(DayOfMonthTemplate x, DayOfMonthTemplate y)
    {
      if (x == null)
      {
        if (y == null)
        {
          // If x is null and y is null, they're
          // equal. 
          return 0;
        }
        else
        {
          // If x is null and y is not null, y
          // is greater. 
          return -1;
        }
      }
      else
      {
        // If x is not null...
        //
        if (y == null)
        // ...and y is null, x is greater.
        {
          return 1;
        }
        else
        {
          // ...and y is not null, compare the 
          // types of the two templates.
          //
          if (x is DayOfMonthTemplateLastDay)
          {
            if (y is DayOfMonthTemplateLastDay) return 0;
            else return 1; // make it last
          }
          if (x is DayOfMonthTemplateByDayNumber)
          {
            if (y is DayOfMonthTemplateByDayNumber)
              return ((DayOfMonthTemplateByDayNumber)x).CompareTo((DayOfMonthTemplateByDayNumber)y);
            else return -1; // make it first
          }
          if (x is DayOfMonthTemplateByWeekDay)
          {
            if (y is DayOfMonthTemplateByWeekDay)
              return ((DayOfMonthTemplateByWeekDay)x).CompareTo((DayOfMonthTemplateByWeekDay)y);
            else if (y is DayOfMonthTemplateByDayNumber) return 1;
            else return -1; // y is LastDay, make it last item.
          }
        }
      }
      return 0; // we should never be here.
    }

    public override string ToString()
    {
      List<string> stringList = new List<string>();
      foreach (DayOfMonthTemplate day in timeList)
      {
        string timeStr = TimeUnitToString(day);
        stringList.Add(timeStr);
      }

      return string.Join(", ", stringList.ToArray());
    }

    private static DayOfMonthTemplate ParseTimeUnitFromString(string time)
    {
      try
      {
        time = time.Trim();
        if (Regex.IsMatch(time, @"last\s+day", RegexOptions.IgnoreCase)) return new DayOfMonthTemplateLastDay();
        if (Regex.IsMatch(time, @"\d")) return new DayOfMonthTemplateByDayNumber(int.Parse(time));
        Regex ByWeekDayPattern = new Regex(@"(first|second|third|fourth|last)\s+(.*)", RegexOptions.IgnoreCase);
        Match m = ByWeekDayPattern.Match(time);
        if (m.Success)
        {
          if (m.Groups.Count != 3) throw new Exception(string.Format("Unable to Parse day of month template: {0}", time));
          string accessorStr = m.Groups[1].Value;
          string weekdayStr = m.Groups[2].Value;
          DayOfMonthTemplateByWeekDay.WeekDayAccessor accessor = ParseAccessorString(accessorStr);
          DayOfWeek day = ParseDayOfWeekString(weekdayStr);
          return new DayOfMonthTemplateByWeekDay(accessor, day);
        }
        else
        {
          throw new Exception(string.Format("Unable to parse day of month template: {0}", time));
        }
      }
      catch (Exception ex)
      {
        throw new Exception(string.Format("Unable to parse day of month template: <{0}>", time), ex);
      }
    }

    private static DayOfWeek ParseDayOfWeekString(string weekDayStr)
    {
      CultureInfo ci = new CultureInfo("en-US");
      DateTimeFormatInfo dtfi = ci.DateTimeFormat;
      for (int i = 0; i < 7; i++)
      {
        if (String.Equals(weekDayStr, dtfi.AbbreviatedDayNames[i], StringComparison.InvariantCultureIgnoreCase)) return (DayOfWeek)i;
        if (String.Equals(weekDayStr, dtfi.DayNames[i], StringComparison.InvariantCultureIgnoreCase)) return (DayOfWeek)i;
        if (String.Equals(weekDayStr, dtfi.ShortestDayNames[i], StringComparison.InvariantCultureIgnoreCase)) return (DayOfWeek)i;
      }
      throw new Exception(string.Format("Unable to parse week day string. <{0}> is not a valid day of the week", weekDayStr));
    }

    private static DayOfMonthTemplateByWeekDay.WeekDayAccessor ParseAccessorString(string accessorStr)
    {
      if (string.Compare(accessorStr, "first", true) == 0) return DayOfMonthTemplateByWeekDay.WeekDayAccessor.First;
      if (string.Compare(accessorStr, "second", true) == 0) return DayOfMonthTemplateByWeekDay.WeekDayAccessor.Second;
      if (string.Compare(accessorStr, "third", true) == 0) return DayOfMonthTemplateByWeekDay.WeekDayAccessor.Third;
      if (string.Compare(accessorStr, "fourth", true) == 0) return DayOfMonthTemplateByWeekDay.WeekDayAccessor.Fourth;
      if (string.Compare(accessorStr, "last", true) == 0) return DayOfMonthTemplateByWeekDay.WeekDayAccessor.Last;
      throw new Exception(string.Format("Unable to parse week day accessor: {0}", accessorStr));
    }

    private string TimeUnitToString(DayOfMonthTemplate day)
    {
      return day.ToString();
    }

    /// <summary>
    /// Return the next day in month event should occurr after given afterTime paramter.
    /// For example for time list like "First Mon, Second Wed, Last Friday" and
    /// timeAfter is "Tuesday, Feb 1, 2011" next time will be same month on First Monday, 
    /// that would be on Feb 7, 2011 and isNextMonth will be false
    /// timeAfter is "Saturday, Feb 26" next time will be First Mon on some different Month, 
    /// isNextWeek wll be true
    /// </summary>
    /// <param name="afterTime">day during the month after which event should occur</param>
    /// <param name="isNextDay">
    /// false - if event is the same month
    /// true  - if event is some other month
    /// </param>
    /// <returns>Day Number in a month</returns>
    public int NextTime(DateTime afterTime, out Boolean isNextMonth)
    {
      isNextMonth = false;
      //build a list for the given month.
      List<DateTime> dayList = new List<DateTime>();
      foreach (DayOfMonthTemplate day in timeList)
      {
        dayList.Add(day.GetDayInMonth(afterTime.Year, afterTime.Month));
      }
      dayList.Sort(); //sort ascending
      foreach (DateTime day in dayList)
      {
        if (afterTime.Day <= day.Day) return day.Day;
      }
      isNextMonth = true;
      // Don't know what is next month, as interval can be more than 1 month and templates
      // for the day in the month fall on different days in every month
      return -1; 
    }

  }

  /// <summary>
  /// Factory to read/write recurrence pattern to/from xml node, as it is stored
  /// in recurring_events.xml
  /// </summary>
  public static class RecurrencePatternFactory
  {
    /// <summary>
    /// Returns XML representation of Recurrence Pattern that can be stored in recurring_events.xml
    /// </summary>
    /// <param name="newPattern"></param>
    /// <returns></returns>
    public static string RecurrencePatternToXml(BaseRecurrencePattern newPattern)
    {
      string xmlstr = "";
      if (newPattern is MinutelyRecurrencePattern) {
        MinutelyRecurrencePattern pattern = newPattern as MinutelyRecurrencePattern;
        xmlstr = string.Format(@"
        <Minutely>
          <Start>{0}</Start>
          <Interval>{1}</Interval>
        </Minutely>
      ",pattern.StartDate, pattern.IntervalInMinutes);
      }
      else if (newPattern is DailyRecurrencePattern) {
        DailyRecurrencePattern pattern = newPattern as DailyRecurrencePattern;
        xmlstr = string.Format(@"
        <Daily>
          <Start>{0}</Start>
          <Interval>{1}</Interval>
          <Times>{2}</Times>
        </Daily>
      ", pattern.StartDate, pattern.IntervalInDays, pattern.ExecutionTimes.ToString());
      } 
      else if (newPattern is WeeklyRecurrencePattern) {
        WeeklyRecurrencePattern pattern = newPattern as WeeklyRecurrencePattern;
        xmlstr = string.Format(@"
        <Weekly>
           <Start>{0}</Start>
           <Interval>{1}</Interval>
           <Times>{2}</Times>
           <DaysOfWeek>{3}</DaysOfWeek>
        </Weekly>
      ", pattern.StartDate, pattern.IntervalInWeeks, pattern.ExecutionTimes.ToString(), pattern.DaysOfWeek.ToString());
      }
      else if (newPattern is MonthlyRecurrencePattern)
      {
        MonthlyRecurrencePattern pattern = newPattern as MonthlyRecurrencePattern;
        xmlstr = string.Format(@"
        <Monthly>
           <Start>{0}</Start>
           <Interval>{1}</Interval>
           <Times>{2}</Times>
           <DaysOfMonth>{3}</DaysOfMonth>
        </Monthly>
      ", pattern.StartDate, pattern.IntervalInMonth, pattern.ExecutionTimes.ToString(), pattern.DaysOfMonth.ToString());
      }
      else if (newPattern is ManualRecurrencePattern)
      {
        xmlstr = @"
        <Manual/>
      ";
      }
      else
      {
        throw new UsageServerException(
            String.Format("Unknow recurrence pattern {0}", newPattern.ToString()));
      }
      return xmlstr;
    }

    public static BaseRecurrencePattern ReadRecurrencePattern(XmlNode eventNode)
    {
      XmlNode RecurringPatternNode = eventNode.SelectSingleNode("RecurrencePattern");
      XmlNode PatternChildNode = RecurringPatternNode.FirstChild;
      // Skip the comments if any
      while (PatternChildNode != null && PatternChildNode.NodeType == XmlNodeType.Comment)
        PatternChildNode = PatternChildNode.NextSibling;
      if (PatternChildNode == null)
        throw new InvalidConfigurationException(
            String.Format("The <RecurrencePattern> tag must contain one pattern in scheduled event!\nXML:{0}", RecurringPatternNode.OuterXml));

      switch (PatternChildNode.Name)
      {
        case "Minutely":
          return ReadMinutelyPattern(PatternChildNode);
        case "Daily":
          return ReadDailyPattern(PatternChildNode);
        case "Weekly":
          return ReadWeeklyPattern(PatternChildNode);
        case "Monthly":
          return ReadMonthlyPattern(PatternChildNode);
        case "Manual":
          return ReadManualPattern(PatternChildNode);
        case "SystemCycle":
          return ReadSystemCyclePattern(PatternChildNode);
        case "IntervalInMinutes":
          return ReadIntervalInMinutesPattern(PatternChildNode);
        default:
          throw new InvalidConfigurationException(
              String.Format("Unknow recurrence pattern {0}", PatternChildNode.Name));

      }
    }

    private static BaseRecurrencePattern ReadManualPattern(XmlNode PatternChildNode)
    {
      //<RecurrencePattern>
      //  <Manual/>
      //</RecurrencePattern>
      ManualRecurrencePattern pattern = new ManualRecurrencePattern();
      return pattern;
    }

    private static MinutelyRecurrencePattern ReadIntervalInMinutesPattern(XmlNode node)
    {
      // <RecurrencePattern>
      //   <IntervalInMinutes>30</IntervalInMinutes>
      // </RecurrencePattern>

      int minutes = MTXmlDocument.GetNodeValueAsInt(node.ParentNode, "IntervalInMinutes");
      if (minutes <= 0)
        throw new InvalidConfigurationException("The IntervalInMinutes setting must contain a positive integer!");
      MinutelyRecurrencePattern pattern = new MinutelyRecurrencePattern(minutes);

      return pattern;
    }

    private static DailyRecurrencePattern ReadSystemCyclePattern(XmlNode node)
    {
      // <RecurrencePattern>
      //   <SystemCycle>Daily</SystemCycle>
      // </RecurrencePattern>

      // <RecurrencePattern>
      //   <SystemCycle>30</SystemCycle>
      // </RecurrencePattern>

      string strValue = node.InnerText;
      if (String.Compare(strValue, "Daily", true) == 0)
      {
        // default to 5:00 AM for system cycle.
        return new DailyRecurrencePattern(1, "5:00 AM");
      }
      else
        // At least for now, the only cycle supported is Daily
        // schedule.CycleID = System.Int32.Parse(strValue);
        throw new InvalidConfigurationException(
          String.Format("The SystemCycle must be 'Daily' not '{0}'!", strValue));

    }

    private static MonthlyRecurrencePattern ReadMonthlyPattern(XmlNode node)
    {
      //<RecurrencePattern>
      //  <Monthly>
      //     <Start>01/01/2011 10:30 PM</Start>
      //     <Interval>1</Interval>
      //     <Times>1:00 AM, 2:00 PM</Times>
      //     <DaysOfMonth>First day, Last day, 1, 15, First Monday</DaysOfMonth>
      //  </Monthly>
      //</RecurrencePattern>
      int interval = MTXmlDocument.GetNodeValueAsInt(node, "Interval", 1);
      if (interval <= 0)
        throw new InvalidConfigurationException("The Interval setting must contain a positive integer!");
      DateTime startDate = MTXmlDocument.GetNodeValueAsDateTime(node, "Start", new DateTime(2010, 1, 1));
      string times = MTXmlDocument.GetNodeValueAsString(node, "Times");
      string daysOfMonth = MTXmlDocument.GetNodeValueAsString(node, "DaysOfMonth");
      MonthlyRecurrencePattern pattern = new MonthlyRecurrencePattern(interval, times, daysOfMonth);
      pattern.StartDate = startDate;

      return pattern;
    }

    private static WeeklyRecurrencePattern ReadWeeklyPattern(XmlNode node)
    {
      //<RecurrencePattern>
      //  <Weekly>
      //     <Start>01/01/2011 10:30 PM</Start>
      //     <Interval>1</Interval>
      //     <Times>1:00 AM, 2:00 PM</Times>
      //     <DaysOfWeek>Mon,Tue,Thu</DaysOfWeek>
      //  </Weekly>
      //</RecurrencePattern>
      int interval = MTXmlDocument.GetNodeValueAsInt(node, "Interval", 1);
      if (interval <= 0)
        throw new InvalidConfigurationException("The Interval setting must contain a positive integer!");
      DateTime startDate = MTXmlDocument.GetNodeValueAsDateTime(node, "Start", new DateTime(2010, 1, 1));
      string times = MTXmlDocument.GetNodeValueAsString(node, "Times");
      string daysOfWeek = MTXmlDocument.GetNodeValueAsString(node, "DaysOfWeek");
      WeeklyRecurrencePattern pattern = new WeeklyRecurrencePattern(interval, times, daysOfWeek);
      pattern.StartDate = startDate;

      return pattern;
    }

    private static DailyRecurrencePattern ReadDailyPattern(XmlNode node)
    {
      //<RecurrencePattern>
      //  <Dayly>
      //     <Start>01/01/2011 10:30 PM</Start>
      //     <Interval>1</Interval>
      //     <Times>1:00 AM, 2:00 PM</Times>
      //  </Dayly>
      //</RecurrencePattern>
      int interval = MTXmlDocument.GetNodeValueAsInt(node, "Interval", 1);
      if (interval <= 0)
        throw new InvalidConfigurationException("The Interval setting must contain a positive integer!");
      DateTime startDate = MTXmlDocument.GetNodeValueAsDateTime(node, "Start", new DateTime(2010, 1, 1));
      string times = MTXmlDocument.GetNodeValueAsString(node, "Times");
      DailyRecurrencePattern pattern = new DailyRecurrencePattern(interval, times);
      pattern.StartDate = startDate;
      return pattern;
    }

    private static MinutelyRecurrencePattern ReadMinutelyPattern(XmlNode node)
    {
      //<RecurrencePattern>
      //  <Minutely>
      //     <effective_date ptype="DATETIME">1998-12-1T00:00:00Z</effective_date>
      //     <Start>01/01/2011 10:30 PM</Start>
      //     <Interval>60</Interval>
      //  </Minutely>
      //</RecurrencePattern>

      int minutes = MTXmlDocument.GetNodeValueAsInt(node, "Interval", 1);
      if (minutes <= 0)
        throw new InvalidConfigurationException("The Interval setting must contain a positive integer!");
      DateTime startDate = MTXmlDocument.GetNodeValueAsDateTime(node, "Start", new DateTime(2010, 1, 1));
      MinutelyRecurrencePattern pattern = new MinutelyRecurrencePattern(minutes);
      pattern.StartDate = startDate;
      return pattern;
    }
  }
}

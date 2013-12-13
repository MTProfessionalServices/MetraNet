
namespace MetraTech.UsageServer
{
  using System;
  using System.Diagnostics;
  using System.Collections;
  using System.Runtime.InteropServices;

  using DataAccess;
  
  /// <summary>
  /// All possible cycle types.
  /// </summary>

  // 1	MTStdMonthly.MTStdMonthly.1							Monthly
  // 2	MTStdOnDemand.MTStdOnDemand.1						On-demand
  // 3	MTStdUsageCycle.MTStdDaily.1						Daily
  // 4	MTStdUsageCycle.MTStdWeekly.1						Weekly
  // 5	MTStdUsageCycle.MTStdBiWeekly.1					Bi-weekly
  // 6	MTStdUsageCycle.MTStdSemiMonthly.1			Semi-monthly
  // 7	MTStdUsageCycle.MTStdQuarterly.1				Quarterly
  // 8	MTStdUsageCycle.MTStdAnnually.1					Annually
  // 9	MTStdUsageCycle.MTStdSemiAnnually.1			SemiAnnually
  [Guid("7F78C83F-82E2-3B84-A247-E7F77745C74A")]
  public enum CycleType
  {
    /// <summary>Monthly cycle type</summary>
    Monthly = 1,

    /// <summary>Daily cycle type</summary>
    Daily = 3,

    /// <summary>Weekly cycle type</summary>
    Weekly = 4,

    /// <summary>Bi-weekly cycle type</summary>
    BiWeekly = 5,

    /// <summary>Semi-monthly cycle type</summary>
    SemiMonthly = 6,

    /// <summary>Quarterly cycle type</summary>
    Quarterly = 7,

    /// <summary>Annual cycle type</summary>
    Annual = 8,

    /// <summary>Semi-annual cycle type</summary>
    SemiAnnual = 9,

    /// <summary>Used for events that occur on all cycles</summary>
    All = -1,
  }

  /// <summary>
  /// Column index for values coming back from usage cycle query
  /// </summary>

  // 0 id_usage_cycle
  // 1 id_cycle_type
  // 2 day_of_month
  // 3 day_of_week
  // 4 first_day_of_month
  // 5 second_day_of_month
  // 6 start_day
  // 7 start_month
  // 8 start_year
  internal enum CycleQueryColumns
  {
    IDUsageCycle = 0,
    IDCycleType,
    DayOfMonth,
    DayOfWeek,
    FirstDayOfMonth,
    SecondDayOfMonth,
    StartDay,
    StartMonth,
    StartYear
  }

  /// <summary>
  /// Properties used to define each cycle
  /// </summary>
  [GuidAttribute("c5c5a80f-9c8d-4511-8a83-653041eb3d28")]
  public interface ICycle
  {
    /// <summary>
    /// Day of week for weekly cycle.
    /// </summary>
    DayOfWeek DayOfWeek
    { get; set; }

    /// <summary>
    /// True when day of week is set.
    /// </summary>
    bool IsDayOfWeekSet
    { get; }


    /// <summary>
    /// Day of month for montly cycle.
    /// </summary>
    int DayOfMonth
    { get; set; }

    /// <summary>
    /// True when day of month is set.
    /// </summary>
    bool IsDayOfMonthSet
    { get; }


    /// <summary>
    /// First day of month for semi-montly cycle.
    /// </summary>
    int FirstDayOfMonth
    { get; set; }

    /// <summary>
    /// True when first day of month is set.
    /// </summary>
    bool IsFirstDayOfMonthSet
    { get; }


    /// <summary>
    /// Second day of month for semi-montly cycle.
    /// </summary>
    int SecondDayOfMonth
    { get; set; }

    /// <summary>
    /// True when second day of month is set.
    /// </summary>
    bool IsSecondDayOfMonthSet
    { get; }


    /// <summary>
    /// Beginning month of month for bi-weekly cycle.
    /// </summary>
    int StartMonth
    { get; set; }

    /// <summary>
    /// True when start month is set.
    /// </summary>
    bool IsStartMonthSet
    { get; }


    /// <summary>
    /// Beginning day of month for bi-weekly cycle.
    /// </summary>
    int StartDay
    { get; set; }

    /// <summary>
    /// True when start day is set.
    /// </summary>
    bool IsStartDaySet
    { get; }


    /// <summary>
    /// Beginning year for bi-weekly cycle.
    /// </summary>
    int StartYear
    { get; set; }

    /// <summary>
    /// True when start year is set.
    /// </summary>
    bool IsStartYearSet
    { get; }


    /// <summary>
    /// Cycle ID (populated from the database when known)
    /// </summary>
    int CycleID
    { get; set; }

    /// <summary>
    /// True when cycle ID is set.
    /// </summary>
    bool IsCycleIDSet
    { get; }

    /// <summary>
    /// Cycle type (when known)
    /// </summary>
    CycleType CycleType
    { get; set; }

    /// <summary>
    /// True when cycle ID is set.
    /// </summary>
    bool IsCycleTypeSet
    { get; }


    /// <summary>
    /// The day of the year, between 1 and 366.
    /// </summary>
    int DayOfYear
    { get; set; }

    /// <summary>
    /// True when day of year is set.
    /// </summary>
    bool IsDayOfYearSet
    { get; }


    /// <summary>
    /// Clear all properties.
    /// </summary>
    void Clear();

    /// <summary>
    /// Retrieve properties from a database query
    /// </summary>
    void Populate(IMTDataReader reader);
  }

  /// <remarks>
  /// Public cycle management API.
  /// </remarks>
  [ComVisible(false)]
  public class UsageCycleManager
  {
    private ArrayList _mAllCycles;
    
    /// <summary>
    /// Add all possible usage cycles to the database
    /// </summary>
    public void AddUsageCycles()
    {
      var allCycles = AllUsageCycles;

      using (var bulkInsert = BulkInsertManager.CreateBulkInsert("NetMeter"))
      {
        bulkInsert.PrepareForInsert("t_usage_cycle", 1000);

        var n = 0;
        foreach (ICycle cycle in allCycles)
        {
          InitRow(bulkInsert, cycle);
          bulkInsert.AddBatch();
          if (++n%1000 == 0)
            bulkInsert.ExecuteBatch();
        }

        bulkInsert.ExecuteBatch();
      }
    }

    /// <summary>
    /// List of all usage cycles, in order
    /// </summary>
    public ArrayList AllUsageCycles
    {
      get
      {
        if (_mAllCycles != null)
          return _mAllCycles;

        _mAllCycles = new ArrayList();

        Type[] cycleTypeTypes =
        {
          typeof (DailyCycleType),
          typeof (MonthlyCycleType),
          typeof (WeeklyCycleType),
          typeof (BiWeeklyCycleType),
          typeof (SemiMonthlyCycleType),
          typeof (QuarterlyCycleType),
          typeof (AnnualCycleType),
          typeof (SemiAnnualCycleType)
        };

        var cycleID = 1;

        // silly names, but the real object is the CycleType... its .NET type is a CycleType Type
        foreach (var cycleTypeType in cycleTypeTypes)
        {
          // create the cycle type object
          var constructorInfo = cycleTypeType.GetConstructor(Type.EmptyTypes);
          if (constructorInfo == null) continue;
          var cycleType = (ICycleType)constructorInfo.Invoke(null);

          // generate all cycles for this cycle type
          var cycles = cycleType.GenerateCycles();

          // number them
          foreach (var cycle in cycles)
          {
            // skip discontinued IDs
            if (CycleUtils.IsDiscontinuedCycleID(cycleID))
              // skip the ID
              ++cycleID;

            cycle.CycleID = cycleID++;
          }

          _mAllCycles.AddRange(cycles);
        }

        return _mAllCycles;
      }
    }

    private static void InitRow(IBulkInsert bulkInsert, ICycle cycle)
    {
      bulkInsert.SetValue(1, MTParameterType.Integer, cycle.CycleID);
      bulkInsert.SetValue(2, MTParameterType.Integer, (int) cycle.CycleType);

      if (cycle.IsDayOfMonthSet)
        bulkInsert.SetValue(3, MTParameterType.Integer, cycle.DayOfMonth);

      bulkInsert.SetValue(4, MTParameterType.String, "B");

      if (cycle.IsDayOfWeekSet)
        bulkInsert.SetValue(5, MTParameterType.Integer, (int) cycle.DayOfWeek);

      if (cycle.IsFirstDayOfMonthSet)
        bulkInsert.SetValue(6, MTParameterType.Integer, cycle.FirstDayOfMonth);

      if (cycle.IsSecondDayOfMonthSet)
        bulkInsert.SetValue(7, MTParameterType.Integer, cycle.SecondDayOfMonth);

      if (cycle.IsStartDaySet)
        bulkInsert.SetValue(8, MTParameterType.Integer, cycle.StartDay);

      if (cycle.IsStartMonthSet)
        bulkInsert.SetValue(9, MTParameterType.Integer, cycle.StartMonth);

      if (cycle.IsStartYearSet)
        bulkInsert.SetValue(10, MTParameterType.Integer, cycle.StartYear);
    }
  }

  /// <remarks>
  /// Base interface used to define the begin and end date of
  /// any cycle type given a reference date ("today") and the properties
  /// defining that cycle.
  /// </remarks>
  [ComVisible(false)]
  public interface ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate);


    /// <summary>
    /// Return true if the given cycle is in its
    /// canonical form for this cycle type.
    /// </summary>
    bool IsCanonical(ICycle cycle);

    /// <summary>
    /// Convert the given cycle into its canonical form.
    /// </summary>
    void MakeCanonical(ICycle cycle);

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    ICycle[] GenerateCycles();
  }

  /// <summary>
  /// Represents an exact cyclic recurrence in time. 
  /// a cycle type + specific recurrence details = a cycle
  /// Example: Monthly + ending on the 15th = Monthly ending on the 15th (cycle ID 17)
  /// </summary>
  [ComVisible(false)]
  public class Cycle : ICycle
  {
    /// <summary>
    /// Initialize to a known state
    /// </summary>
    public Cycle()
    {
      Clear();
    }

    /// <summary>
    /// Clear all properties.
    /// </summary>
    public void Clear()
    {
      _mDayOfWeek = DayOfWeek.Monday; // make the state of each property consistent
      _mDayOfWeekSet = false;
      _mDayOfMonth = -1;
      _mFirstDayOfMonth = -1;
      _mSecondDayOfMonth = -1;
      _mStartMonth = -1;
      _mStartDay = -1;
      _mStartYear = -1;
      _mCycleID = -1;
      _mCycleType = CycleType.All; // make the state of each property consistent
      _mCycleTypeSet = false;
      _mDayOfYear = -1;
    }

    /// <summary>
    /// Generate a string representation of the cycle.
    /// Useful for debugging.
    /// </summary>
    public override string ToString()
    {
      var builder = new System.Text.StringBuilder();
      builder.Append("Cycle:");
      if (IsDayOfWeekSet)
        builder.AppendFormat(" DayOfWeek = {0}", DayOfWeek);
      if (IsDayOfMonthSet)
        builder.AppendFormat(" DayOfMonth = {0}", DayOfMonth);
      if (IsFirstDayOfMonthSet)
        builder.AppendFormat(" FirstDayOfMonth = {0}", FirstDayOfMonth);
      if (IsSecondDayOfMonthSet)
        builder.AppendFormat(" SecondDayOfMonth = {0}", SecondDayOfMonth);
      if (IsStartMonthSet)
        builder.AppendFormat(" StartMonth = {0}", StartMonth);
      if (IsStartDaySet)
        builder.AppendFormat(" StartDay = {0}", StartDay);
      if (IsStartYearSet)
        builder.AppendFormat(" StartYear = {0}", StartYear);
      if (IsCycleIDSet)
        builder.AppendFormat(" CycleID = {0}", CycleID);
      if (IsDayOfYearSet)
        builder.AppendFormat(" DayOfYear = {0}", DayOfYear);

      return builder.ToString();
    }
    
    /// <summary>
    /// Day of week for weekly cycle.
    /// </summary>
    public DayOfWeek DayOfWeek
    {
      get
      {
        return _mDayOfWeek;
      }
      set
      {
        _mDayOfWeek = value;
        _mDayOfWeekSet = true;
      }
    }

    /// <summary>
    /// True when day of week is set.
    /// </summary>
    public bool IsDayOfWeekSet
    {
      get
      {
        return _mDayOfWeekSet;
      }
    }

    /// <summary>
    /// Day of month for montly cycle.
    /// </summary>
    public int DayOfMonth
    {
      get
      {
        return _mDayOfMonth;
      }
      set
      {
        if (value <= 0 || value > MaxDaysInMonth)
          throw new UsageServerException(String.Format("Day of month value {0} is not between 1 and {1}", value, MaxDaysInMonth), true);
        _mDayOfMonth = value;
      }
    }

    /// <summary>
    /// True when day of month is set.
    /// </summary>
    public bool IsDayOfMonthSet
    {
      get
      {
        return _mDayOfMonth != -1;
      }
    }

    /// <summary>
    /// First day of month for semi-montly cycle.
    /// </summary>
    public int FirstDayOfMonth
    {
      get
      {
        return _mFirstDayOfMonth;
      }
      set
      {
        if (value < 1 || value >= MaxDaysInMonth)
          throw new UsageServerException(String.Format("First day value {0} must be greater or equal than 1 and less than {1}", 
            value, MaxDaysInMonth), true);

        if (IsSecondDayOfMonthSet && value >= SecondDayOfMonth)
          throw new UsageServerException("The first day must be less than the second day", true);

        _mFirstDayOfMonth = value;
      }
    }

    /// <summary>
    /// True when first day of month is set.
    /// </summary>
    public bool IsFirstDayOfMonthSet
    {
      get
      {
        return _mFirstDayOfMonth != -1;
      }
    }

    /// <summary>
    /// Second day of month for semi-montly cycle.
    /// </summary>
    public int SecondDayOfMonth
    {
      get
      {
        return _mSecondDayOfMonth;
      }
      set
      {
        if (value <= 1 || value > MaxDaysInMonth)
          throw new UsageServerException(String.Format("Second day value {0} must be greater or equal than 1 " +
                                                       "and less than {1}", value, MaxDaysInMonth), true);

        if (IsFirstDayOfMonthSet && value <= FirstDayOfMonth)
          throw new UsageServerException("The second day must be greater than the first day", true);

        _mSecondDayOfMonth = value;
      }
    }

    /// <summary>
    /// True when second day of month is set.
    /// </summary>
    public bool IsSecondDayOfMonthSet
    {
      get
      {
        return _mSecondDayOfMonth != -1;
      }
    }

    /// <summary>
    /// Beginning month of month for bi-weekly cycle.
    /// </summary>
    public int StartMonth
    {
      get
      {
        return _mStartMonth;
      }
      set
      {
        // NOTE: Quarterly cycle further assumes that the
        // month is within the first quarter
        if (value < 1 || value > 12)
          throw new UsageServerException(String.Format("StartMonth value {0} not a valid month number between 1 and 12", value), true);
        _mStartMonth = value;
      }
    }

    /// <summary>
    /// True when start month is set.
    /// </summary>
    public bool IsStartMonthSet
    {
      get
      {
        return _mStartMonth != -1;
      }
    }

    /// <summary>
    /// Beginning day of month for bi-weekly cycle.
    /// </summary>
    public int StartDay
    {
      get
      {
        return _mStartDay;
      }
      set
      {
        // this also has to be further validated later, but this
        // test must always be true.
        if (value < 1 || value > MaxDaysInMonth)
          throw new UsageServerException(String.Format("StartDay {0} must be between 1 and {1}", value, MaxDaysInMonth), true);

        _mStartDay = value;
      }
    }

    /// <summary>
    /// True when start day is set.
    /// </summary>
    public bool IsStartDaySet
    {
      get
      {
        return _mStartDay != -1;
      }
    }

    /// <summary>
    /// Beginning year for bi-weekly cycle.
    /// </summary>
    public int StartYear
    {
      get
      {
        return _mStartYear;
      }
      set
      {
        _mStartYear = value;
      }
    }

    /// <summary>
    /// True when start year is set.
    /// </summary>
    public bool IsStartYearSet
    {
      get
      {
        return _mStartYear != -1;
      }
    }


    /// <summary>
    /// Cycle ID (populated from the database when known)
    /// </summary>
    public int CycleID
    {
      get
      {
        return _mCycleID;
      }
      set
      {
        _mCycleID = value;
      }
    }

    /// <summary>
    /// True when cycle ID is set.
    /// </summary>
    public bool IsCycleIDSet
    {
      get
      {
        return _mCycleID != -1;
      }
    }

    /// <summary>
    /// Cycle type (when known)
    /// </summary>
    public CycleType CycleType
    {
      get
      {
        return _mCycleType;
      }
      set
      {
        _mCycleType = value;
        _mCycleTypeSet = true;
      }
    }

    /// <summary>
    /// True when cycle ID is set.
    /// </summary>
    public bool IsCycleTypeSet
    {
      get
      {
        return _mCycleTypeSet;
      }
    }


    /// <summary>
    /// The day of the year, between 1 and 366.
    /// </summary>
    public int DayOfYear
    {
      get
      {
        return _mDayOfYear;
      }
      set
      {
        if (!(value >= 1 && value <= 365))
          throw new UsageServerException(String.Format("DayOfYear {0} must be between 1 and 365", value), true);

        _mDayOfYear = value;
      }
    }

    /// <summary>
    /// True when day of year is set.
    /// </summary>
    public bool IsDayOfYearSet
    {
      get
      {
        return _mDayOfYear != -1;
      }
    }

    /// <summary>
    /// Retrieve properties from a database query
    /// </summary>
    public void Populate(IMTDataReader reader)
    {
      _mCycleID = reader.GetInt32((int) CycleQueryColumns.IDUsageCycle);
      var rawCycleType = reader.GetInt32((int)CycleQueryColumns.IDCycleType);

      if (!CycleUtils.IsSupportedCycleType(rawCycleType))
        throw new ApplicationException(String.Format("Unsupported cycle type {0}", rawCycleType));

      var cycleType = (CycleType)rawCycleType;
      CycleType = cycleType;
      switch (cycleType)
      {
        case CycleType.Monthly:
          DayOfMonth = reader.GetInt32((int) CycleQueryColumns.DayOfMonth);
          break;
        case CycleType.Daily:
          break;
        case CycleType.Weekly:
          // be careful to correct for the fact that MetraTech uses Sunday=1; ... ; Saturday=7
          // and .NET uses Sunday=0; ... ; Saturday=6
          DayOfWeek = (DayOfWeek) (reader.GetInt32((int) CycleQueryColumns.DayOfWeek) - 1);
          break;

        case CycleType.BiWeekly:
          StartDay = reader.GetInt32((int) CycleQueryColumns.StartDay);
          StartMonth = reader.GetInt32((int) CycleQueryColumns.StartMonth);
          StartYear = reader.GetInt32((int) CycleQueryColumns.StartYear);
          break;

        case CycleType.SemiMonthly:
          FirstDayOfMonth = reader.GetInt32((int) CycleQueryColumns.FirstDayOfMonth);
          SecondDayOfMonth = reader.GetInt32((int) CycleQueryColumns.SecondDayOfMonth);
          break;

        case CycleType.Quarterly:
        case CycleType.SemiAnnual:
        case CycleType.Annual:
          StartDay = reader.GetInt32((int) CycleQueryColumns.StartDay);
          StartMonth = reader.GetInt32((int) CycleQueryColumns.StartMonth);
          break;
      }
    }

    public const int MaxDaysInMonth = 31;
    private DayOfWeek _mDayOfWeek;
    private bool _mDayOfWeekSet;
    private int _mDayOfMonth;
    private int _mFirstDayOfMonth;
    private int _mSecondDayOfMonth;
    private int _mStartMonth;
    private int _mStartDay;
    private int _mStartYear;
    private int _mCycleID;
    private CycleType _mCycleType;
    private bool _mCycleTypeSet;
    private int _mDayOfYear;
  }

  /// <remarks>
  /// Utility functions used by the various Cycle objects.
  /// </remarks>
  [ComVisible(false)]
  public static class CycleUtils
  {
    /// <summary>
    /// Return true if the given integer maps to a supported cycle type.
    /// </summary>
    public static bool IsSupportedCycleType(int cycleType)
    {
      return Enum.IsDefined(typeof (CycleType), cycleType);
    }

    /// <summary>
    /// Return true if the given integer maps to a discontinued cycle type.
    /// </summary>
    public static bool IsDiscontinuedCycleType(int cycleType)
    {
      // 2 - OnDemand
      return cycleType == 2;
    }

    /// <summary>
    /// Return true if the given cycle ID has been discontinued
    /// </summary>
    public static bool IsDiscontinuedCycleID(int cycleId)
    {
      // from COMUsageServer.cpp
      return cycleId == 1;
    }

    /// <summary>
    /// last day of the given month.
    /// </summary>
    public static DateTime LastDayOfMonth(DateTime date)
    {
      var calendar = new System.Globalization.GregorianCalendar();

      // determine real end of month
      return date.AddDays(calendar.GetDaysInMonth(date.Year, date.Month) - date.Day);
    }

    /// <summary>
    /// return the date representing the given day of the same month
    /// as the timestamp passed in.
    /// </summary>
    public static DateTime MoveToDay(DateTime date, int dayOfMonth)
    {
      var targetDay = dayOfMonth;
      var lastDayOfMonth = DateTime.DaysInMonth(date.Year, date.Month);

      if (targetDay > lastDayOfMonth)
      {
        targetDay = lastDayOfMonth;
      }
      var movedDate = new DateTime(date.Year, date.Month, targetDay);

      return movedDate;
    }

    /// <summary>
    /// Returns a CycleType, given the name of the cycle.
    /// </summary>
    public static CycleType ParseCycleType(string cycleType)
    {
      switch (cycleType)
      {
        case "Monthly":
          return CycleType.Monthly;
        case "Daily":
          return CycleType.Daily;
        case "Weekly":
          return CycleType.Weekly;
        case "Bi-weekly":
          return CycleType.BiWeekly;
        case "Semi-monthly":
          return CycleType.SemiMonthly;
        case "Quarterly":
          return CycleType.Quarterly;
        case "Annually":
          return CycleType.Annual;
        case "Semi-Annually":
          return CycleType.SemiAnnual;
        case "All":
          return CycleType.All;
        default:
          throw new ArgumentException(String.Format("Invalid cycle type name {0}", cycleType));
      }
    }
  }

  /// <summary>
  /// Monthly usage cycle type.
  /// </summary>
  [ComVisible(false)]
  public class MonthlyCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);

      endDate = ComputeEndDate(referenceDate, cycle);

      // Intervals cannot overlap and need to be continuous.
      // Calculate the start date as the day after end date of the previous interval
      // We remove a month from the end date because it is guaranteed to be in the interval
      // that is immediatly before the current one
      var endDateForPreviousInterval = ComputeEndDate(endDate.AddMonths(-1), cycle);
      startDate = endDateForPreviousInterval.AddDays(1);
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
      if (((Cycle) cycle).DayOfMonth == -1)
        throw new ArgumentException("cycle.DayOfMonth property must be initialized");
    }

    private static DateTime ComputeEndDate(DateTime referenceDate, ICycle cycle)
    {
      // sets the endDate to the closing day of the current month
      var endDate = CycleUtils.MoveToDay(referenceDate, cycle.DayOfMonth);

      // if we are after the closing day then we need to
      // fast foward the ending date ahead one month
      if (referenceDate > endDate)
      {
        endDate = endDate.AddMonths(1);
      }
      return endDate;
    }

    /// <summary>
    /// Return true if the given cycle is in its
    /// canonical form for this type of cycle.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      return true;
    }

    /// <summary>
    /// do nothing since any day of the month is canonical
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
    }

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // 31 cycles
      var cycles = new ICycle[Cycle.MaxDaysInMonth];
      var day = 1;
      for (var cycleId = 0; cycleId < Cycle.MaxDaysInMonth; cycleId++)
      {
        ICycle cycle = new Cycle();
        cycles[cycleId] = cycle;
        cycle.DayOfMonth = day++;
        cycle.CycleType = CycleType.Monthly;
        MakeCanonical(cycle);
      }
      return cycles;
    }
  }

  /// <summary>
  /// Daily usage cycle.
  /// </summary>
  [ComVisible(false)]
  public class DailyCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      // translated from MTStdDaily.cpp
      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      // daily is easy.
      // NOTE: cycle is not used
      startDate = today;
      endDate = today;
    }


    /// <summary>
    /// Always returns true.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      return true;
    }

    /// <summary>
    /// Daily cycle is always in canonical form.
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
    }

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // 1 cycle
      var cycles = new ICycle[1];
      ICycle cycle = new Cycle();
      // no properties to set!
      cycle.CycleType = CycleType.Daily;
      cycles[0] = cycle;
      return cycles;
    }
  }

  /// <summary>
  /// Weekly usage cycle type.
  /// </summary>
  [ComVisible(false)]
  public class WeeklyCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);

      // translated from MTStdWeekly.cpp
      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      // The end date is the date of the next occurence of the day of week passed in.
      // The start date can be calculated by taking the end date and subtracting 6. 
      endDate = today;

      // figure out the day of the next given day of the week
      var dayOfWeek = endDate.DayOfWeek;
      var advance = cycle.DayOfWeek - dayOfWeek;
      if (advance < 0)
        advance += 7;

      endDate = endDate.AddDays(advance);


      startDate = endDate.AddDays(-6);
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
    }

    /// <summary>
    /// Always returns true.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      return true;
    }

    /// <summary>
    /// Weekly cycle is always in canonical form.
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
    }

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // 7 cycles - each day of week
      var cycles = new ICycle[7];
      for (var day = 1; day <= 7; day++)
      {
        ICycle cycle = new Cycle();
        cycles[day - 1] = cycle;
        cycle.DayOfWeek = (DayOfWeek) day;
        cycle.CycleType = CycleType.Weekly;
      }
      return cycles;
    }

  }

  /// <summary>
  /// Semi-Monthly usage cycle.
  /// </summary>
  [ComVisible(false)]
  public class SemiMonthlyCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);

      MakeCanonical(cycle);

      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      // second day   first day   second day   first day
      //       |-----------|-----------|-----------|
      //             1           2           3
      //
      //  ===========><======================><============
      //   last month      current month        next month
      //
      // figure out whether we're currently in interval 1, 2, or 3

      var firstDay = cycle.FirstDayOfMonth;
      var secondDay = cycle.SecondDayOfMonth;

      // second day of last month
      var lastMonthSecondDay = CycleUtils.MoveToDay(today.AddMonths(-1), secondDay);
      var currentMonthFirstDay = CycleUtils.MoveToDay(today, firstDay);
      var currentMonthSecondDay = CycleUtils.MoveToDay(today, secondDay);
      var nextMonthFirstDay = currentMonthFirstDay.AddMonths(1);

      // intervals end at the end of the day.  that's why we add
      // 1 day to some of the following dates
      if (today < currentMonthFirstDay.AddDays(1))
      {
        startDate = lastMonthSecondDay.AddDays(1);
        endDate = currentMonthFirstDay;
      }
      else if (today < currentMonthSecondDay.AddDays(1))
      {
        startDate = currentMonthFirstDay.AddDays(1);
        endDate = currentMonthSecondDay;
      }
      else
      {
        startDate = currentMonthSecondDay.AddDays(1);
        endDate = nextMonthFirstDay;
      }
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
      if (((Cycle) cycle).FirstDayOfMonth == -1)
        throw new ArgumentException("cycle.FirstDayOfMonth property must be initialized");
      if (((Cycle) cycle).SecondDayOfMonth == -1)
        throw new ArgumentException("cycle.SecondDayOfMonth property must be initialized");
    }

    /// <summary>
    /// Return true if the given cycle is in its
    /// canonical form for this type of cycle.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      return true;
    }

    /// <summary>
    /// Semi-montly cycle is in canonical form when
    /// second day of month is set to 31 if it's above 27.
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
    }

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // first day is 1 to 30
      // second day is first day + 1 to 31

      // first day has 30 combinations
      // second day has 29.. 28.. 27...
      // 27th day has 1 combination - 31
      // therefore total number is
      //   = sum of the first 30 integers
      //   = 30 (30 + 1) / 2
      //   = 465
      const int numDays = Cycle.MaxDaysInMonth - 1;
      const int numCycles = (numDays * (numDays + 1)) / 2;
      var cycles = new ICycle[numCycles];
      var cycleID = 0;
      for (var first = 1; first <= Cycle.MaxDaysInMonth - 1; first++)
      {
        for (var second = first + 1; second <= Cycle.MaxDaysInMonth; second++)
        {
          ICycle cycle = new Cycle();
          cycles[cycleID++] = cycle;
          cycle.FirstDayOfMonth = first;
          cycle.SecondDayOfMonth = second;
          cycle.CycleType = CycleType.SemiMonthly;
          Debug.Assert(IsCanonical(cycle));
        }
      }
      return cycles;
    }

  }

  /// <summary>
  /// Quarterly usage cycle.
  /// </summary>
  [ComVisible(false)]
  public class QuarterlyCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);
      MakeCanonical(cycle);

      var quarterStarts = new DateTime[6];

      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      // the beginning of each interval within the year
      quarterStarts[1] = new DateTime(today.Year, cycle.StartMonth,
        Math.Min(cycle.StartDay, DateTime.DaysInMonth(today.Year, cycle.StartMonth)));
      quarterStarts[2] = quarterStarts[1].AddMonths(3);
      quarterStarts[3] = quarterStarts[2].AddMonths(3);
      quarterStarts[4] = quarterStarts[3].AddMonths(3);

      // the beginning of the last interval of last year
      quarterStarts[0] = quarterStarts[1].AddMonths(-3);

      // the beginning of the first interval of the next year
      quarterStarts[5] = quarterStarts[4].AddMonths(3);

      //Sometimes adding 3 months can screw you up.  You might go from 1/31 -> 4/30, 
      //  then from 4/30 -> 7/30, which is a mistake.  So check for those errors, and 
      //  set them to the right date.
      for (var i = 0; i < quarterStarts.Length; i++)
      {
        if (quarterStarts[i].Day >= cycle.StartDay) continue;
        var correctDay = Math.Min(cycle.StartDay, DateTime.DaysInMonth(quarterStarts[i].Year, quarterStarts[i].Month));
        quarterStarts[i] = new DateTime(quarterStarts[i].Year, quarterStarts[i].Month, correctDay);
      }
      // now, which interval do we fall into?
      for (var i = 0; i < quarterStarts.Length - 1; i++)
      {
        var start = quarterStarts[i];
        var end = quarterStarts[i + 1];

        if (today < start || today >= end) continue;
        startDate = start;
        endDate = end.AddDays(-1);
        return;
      }

      throw new UsageServerException("Must fall into one of the intervals!", true);
    }

    /// <summary>
    /// Return true if the given cycle is in its
    /// canonical form for this type of cycle.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      CheckParams(cycle);
      return cycle.StartMonth >= 1 && cycle.StartMonth <= 3;
    }

    /// <summary>
    /// Quarterly cycle is in canonical form when
    /// month is set to be within the first quarter
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
      CheckParams(cycle);
      // 1 = Jan, 2 = Feb, ...
      // for example: (1 - 1) % 3 + 1 = 1
      //              (4 - 1) % 3 + 1 = 1
      var month = (cycle.StartMonth - 1) % 3 + 1;
      cycle.StartMonth = month;
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
      if (((Cycle) cycle).StartMonth == -1)
        throw new ArgumentException("cycle.StartMonth property must be initialized");
      if (((Cycle)cycle).StartDay == -1)
        throw new ArgumentException("cycle.StartDay property must be initialized");
    }

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // 3 months in a quarter, so 3 * days_in_months quarterly cycles
      var cycles = new ICycle[3 * Cycle.MaxDaysInMonth];
      var cycleId = 0;
      for (var month = 1; month <= 3; month++)
      {
        for (var day = 1; day <= Cycle.MaxDaysInMonth; day++)
        {
          ICycle cycle = new Cycle();
          cycles[cycleId++] = cycle;
          cycle.StartMonth = month;
          cycle.StartDay = day;
          cycle.CycleType = CycleType.Quarterly;
          Debug.Assert(IsCanonical(cycle));
        }
      }
      return cycles;
    }
  }

  /// <summary>
  /// Bi-weekly usage cycle type.
  /// </summary>
  [ComVisible(false)]
  public class BiWeeklyCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);

      // translated from MTStdBiWeekly.cpp
      MakeCanonical(cycle);

      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      var month = cycle.StartMonth;
      var day = cycle.StartDay;
      var year = cycle.StartYear;

      var cycleReference = new DateTime(year, month, day);
      var diff = (today - cycleReference).Days;
      long intervals = diff > 0 ? diff/14 : diff/14 - 1;

      // choose start time that's an even number of 14 day periods
      // after the reference
      startDate = cycleReference.AddDays(intervals*14);

      // end time is end of this day, that's why we use 13
      endDate = startDate.AddDays(13);
    }

    /// <summary>
    /// Return true if the given cycle is in its
    /// canonical form for this type of cycle.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      CheckParams(cycle);

      return cycle.StartYear == 2000
             && cycle.StartMonth == 1
             && cycle.StartDay >= 1 && cycle.StartDay <= 14;
    }

    /// <summary>
    /// Bi-weekly cycle is in canonical form when 
    /// year, month, day are set to one of the first 14 days of January 2000
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
      CheckParams(cycle);
      // NOTE: turning the cycle into canonical form
      // is basically as expensive as computing the cycle.
      // we check to see if it's in correct form first.
      if (IsCanonical(cycle))
        return;

      var month = cycle.StartMonth;
      var day = cycle.StartDay;
      var year = cycle.StartYear;

      var calendar = new System.Globalization.GregorianCalendar();

      var daysInMonth = calendar.GetDaysInMonth(year, month);

      if (day > daysInMonth)
        throw new UsageServerException(
          String.Format("StartDay {0} must be a valid day of month for the Bi-weekly cycle", day), true);

      var fixedReference = new DateTime(2000, 1, 1);

      var cycleReference = new DateTime(year, month, day);
      var diffDays = (cycleReference - fixedReference).Days;
      var diffDaysMod = diffDays%14;

      var startDay = diffDays >= 0 ? diffDaysMod + 1 : 14 + (1 + diffDays)%14;

      cycle.StartYear = 2000;
      cycle.StartMonth = 1;
      cycle.StartDay = startDay;
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
      if (((Cycle) cycle).StartDay == -1)
        throw new ArgumentException("cycle.StartDay property must be initialized");
      if (((Cycle) cycle).StartMonth == -1)
        throw new ArgumentException("cycle.StartMonth property must be initialized");
      if (((Cycle) cycle).StartYear == -1)
        throw new ArgumentException("cycle.StartYear property must be initialized");
    }

    /// <summary>
    /// Generate all possible cycles for this cycle type.
    /// NOTE: these cycles are generated in the correct order to match
    /// previous versions of the product
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // first 14 days of January 2000
      var cycles = new ICycle[14];
      for (var day = 1; day <= 14; day++)
      {
        ICycle cycle = new Cycle();
        cycles[day - 1] = cycle;
        cycle.StartYear = 2000;
        cycle.StartMonth = 1;
        cycle.StartDay = day;
        cycle.CycleType = CycleType.BiWeekly;
        Debug.Assert(IsCanonical(cycle));
      }
      return cycles;
    }
  }

  /// <summary>
  /// Annual usage cycle.
  /// </summary>
  [ComVisible(false)]
  public class AnnualCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);

      // translated from MTStdAnnually.cpp
      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      var month = cycle.StartMonth;
      var day = cycle.StartDay;

      var calendar = new System.Globalization.GregorianCalendar();

      // accordeing to MTStdAnnually:
      //  "we don't care about leap year so a fixed year is ok"
      var daysInMonth = calendar.GetDaysInMonth(1999, month);

      if (!(day >= 1 && day <= daysInMonth))
        throw new ArgumentException(String.Format("StartDay {0} must be a valid day of month", day));

      startDate = new DateTime(referenceDate.Year, month, day);
      endDate = startDate.AddDays(-1);

      if (today >= startDate)
        endDate = endDate.AddYears(1);
      else
        startDate = startDate.AddYears(-1);
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
      if (((Cycle) cycle).StartDay == -1)
        throw new ArgumentException("cycle.StartDay property must be initialized");
      if (((Cycle) cycle).StartMonth == -1)
        throw new ArgumentException("cycle.StartMonth property must be initialized");
    }

    /// <summary>
    /// Always returns true.
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      return true;
    }

    /// <summary>
    /// Annual cycle is always in canonical form
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
    }

    /// <summary>
    /// Generate all possible cycles for Annual cycle type.
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // for each month, all possible days from the year 1999
      // feb was not a leap year in 1999
      // 365 days in the year
      var calendar = new System.Globalization.GregorianCalendar();
    }
  }

  /// <summary>
  /// Semi-annual usage cycle.
  /// </summary>
  [ComVisible(false)]
  public class SemiAnnualCycleType : ICycleType
  {
    /// <summary>
    /// Compute the start and end of the interval containing the reference date,
    /// given the cycle.
    /// </summary>
    public void ComputeStartAndEndDate(DateTime referenceDate,
      ICycle cycle,
      out DateTime startDate,
      out DateTime endDate)
    {
      CheckParams(cycle);

      // translated from MTStdSemiAnnually.cpp
      var today = new DateTime(referenceDate.Year, referenceDate.Month, referenceDate.Day);

      var month = cycle.StartMonth;
      var day = cycle.StartDay;

      var calendar = new System.Globalization.GregorianCalendar();

      // according to MTStdAnnually:
      //  "we don't care about leap year so a fixed year is ok"
      var daysInMonth = calendar.GetDaysInMonth(1999, month);

      if (!(day >= 1 && day <= daysInMonth))
        throw new ArgumentException(String.Format("StartDay {0} must be a valid day of month", day));

      startDate = new DateTime(referenceDate.Year, month, day);
      endDate = startDate.AddMonths(6);

      //Figure out which half of the year we're in, and adjust the start or end date forward or backward a year.
      //  There are three possibilities for where we are:
      //  Before the start date: Switch start and dates, and subtract a year from the start
      //  Between start & end dates: we're good, so don't do anything
      //  After the end date: Switch start and end dates, and add a year to the end date
      DateTime tempDate;
      if (today < startDate)
      {
        tempDate = startDate;
        startDate = endDate;
        endDate = tempDate;
        startDate = startDate.AddYears(-1);
      }
      else if (today >= endDate)
      {
        tempDate = startDate;
        startDate = endDate;
        endDate = tempDate;
        endDate = endDate.AddYears(1);
      }
      endDate = endDate.AddDays(-1);
    }

    private static void CheckParams(ICycle cycle)
    {
      if (cycle == null)
        throw new ArgumentNullException("cycle");
      if (((Cycle) cycle).StartDay == -1)
        throw new ArgumentException("cycle.StartDay property must be initialized");
      if (((Cycle) cycle).StartMonth == -1)
        throw new ArgumentException("cycle.StartMonth property must be initialized");
    }

    /// <summary>
    /// Always true
    /// </summary>
    public bool IsCanonical(ICycle cycle)
    {
      return true;
    }

    /// <summary>
    /// Select appropriate cycle
    /// </summary>
    public void MakeCanonical(ICycle cycle)
    {
    }

    /// <summary>
    /// Generate all possible cycles for SemiAnnual cycle type.
    /// </summary>
    public ICycle[] GenerateCycles()
    {
      // for each month, all possible days from the year 1999
      // feb was not a leap year in 1999
      // 365 days in the year
      var calendar = new System.Globalization.GregorianCalendar();

      var cycles = new ICycle[365];
      var cycleId = 0;
      for (var month = 1; month <= 12; month++)
      {
        for (var day = 1; day <= calendar.GetDaysInMonth(1999, month); day++)
        {
          ICycle cycle = new Cycle();
          cycle.StartMonth = month;
          cycle.StartDay = day;
          cycle.CycleType = CycleType.SemiAnnual;
          cycles[cycleId++] = cycle;
        }
      }
      return cycles;
    }
  }
}

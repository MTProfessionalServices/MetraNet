namespace MetraTech.UsageServer.Test
{
	using System;
	using System.Runtime.InteropServices;

	using NUnit.Framework;

	// imports legacy Usage Server objects for comparison against new objects
	using OldUsageCycle = MetraTech.Interop.MTStdUsageCycle;
	using OldUsageServer = MetraTech.Interop.MTUsageServer;


	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.UsageServer.Test.CycleTests /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class CycleTests
	{

    /// <summary>
    /// Test of daily cycles.
    /// </summary>
    [Test]
    public void T01TestDailyCycles()
    {
      ICycleType cycleType = new DailyCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdDaily();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      cycle.Clear();

      DateTime refDate = new DateTime(2001, 1, 1);
      // test every day for 5 years.  this way we know we hit a leap year
      for (int i = 0; i < 365 * 5; i++)
      {
        ComputeAndTestDates(refDate,
                            cycleType, cycle,
                            stdcycle, cycleProps);

        refDate = refDate.AddDays(1);
      }
    }

    /// <summary>
    /// Test of weekly cycles.
    /// </summary>
    [Test]
    public void T02TestWeeklyCycles()
    {
      ICycleType cycleType = new WeeklyCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdWeekly();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("DayOfWeek", 1);

      // test cycles on each day of the week
      for (int day = 1; day <= 7; day++)
      {
        cycleProps.ModifyProperty("DayOfWeek", day);

        cycle.Clear();
        cycle.DayOfWeek = (DayOfWeek)day - 1;

        DateTime refDate = new DateTime(2001, 1, 1);
        // test every day for 5 years.  this way we know we hit a leap year
        for (int i = 0; i < 365 * 5; i++)
        {
          ComputeAndTestDates(refDate,
                              cycleType, cycle,
                              stdcycle, cycleProps);

          refDate = refDate.AddDays(1);
        }
      }

    }

    /// <summary>
    /// Test of bi-weekly
    /// </summary>
    [Test]
    public void T03TestBiWeeklyCycles()
    {
      ICycleType cycleType = new BiWeeklyCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdBiWeekly();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("StartYear", 2000);
      cycleProps.AddProperty("StartMonth", 1);
      cycleProps.AddProperty("StartDay", 1);

      // test for first 14 days of the year
      for (int day = 1; day < 14; day++)
      {
        cycleProps.ModifyProperty("StartDay", day);

        cycle.Clear();
        cycle.StartYear = 2000;
        cycle.StartMonth = 1;
        cycle.StartDay = day;

        DateTime refDate = new DateTime(2001, 1, 1);
        // test every day for 5 years.  this way we know we hit a leap year
        for (int i = 0; i < 365 * 5; i++)
        {
          ComputeAndTestDates(refDate,
                              cycleType, cycle,
                              stdcycle, cycleProps);

          refDate = refDate.AddDays(1);
        }
      }

    }

    /// <summary>
    /// Test of semi-weekly cycles.
    /// </summary>
    [Test]
    public void T04TestSemiMonthlyCycles()
    {
      ICycleType cycleType = new SemiMonthlyCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdSemiMonthly();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("FirstDayOfMonth", 1);
      cycleProps.AddProperty("SecondDayOfMonth", 2);

      // test on each combination of first day of month/second day of month
      for (int first = 1; first <= 27; first++)
      {
        cycleProps.ModifyProperty("FirstDayOfMonth", first);
        for (int second = first + 1; second <= 31; second++)
        {
          cycleProps.ModifyProperty("SecondDayOfMonth", second);

          cycle.Clear();
          cycle.FirstDayOfMonth = first;
          cycle.SecondDayOfMonth = second;

          DateTime refDate = new DateTime(2001, 1, 1);
          // test every day for 5 years.  this way we know we hit a leap year
          for (int i = 0; i < 365 * 5; i++)
          {
            // NOTE: the new cycle object seems to be about 5 times faster
            // than the old adapter.  these test can be long (60 seconds or so)
            ComputeAndTestDates(refDate,
                                cycleType, cycle,
                                stdcycle, cycleProps);

            refDate = refDate.AddDays(1);
          }
        }
      }
    }

    /// <summary>
    /// Test of monthly cycles.
    /// </summary>
    [Test]
    public void T05TestMonthlyCycles()
    {
      new OldUsageServer.COMUsageCyclePropertyColl();

      ICycleType cycleType = new MonthlyCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdMonthly();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("DayOfMonth", 1);

      // test cycles on each day of the month
      for (int day = 1; day <= 31; day++)
      {
        cycleProps.ModifyProperty("DayOfMonth", day);

        cycle.Clear();
        cycle.DayOfMonth = day;

        DateTime refDate = new DateTime(2001, 1, 1);
        // test every day for 5 years.  this way we know we hit a leap year
        for (int i = 0; i < 365 * 5; i++)
        {
          ComputeAndTestDates(refDate,
                              cycleType, cycle,
                              stdcycle, cycleProps);

          refDate = refDate.AddDays(1);
        }
      }
    }

    /// <summary>
    /// Test of quarterly cycles
    /// </summary>
    [Test]
    public void T06TestQuarterlyCycles()
    {
      ICycleType cycleType = new QuarterlyCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdQuarterly();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("StartMonth", 1);
      cycleProps.AddProperty("StartDay", 1);

      // test each valid day in the quarter
      for (int month = 1; month <= 3; month++)
      {
        cycleProps.ModifyProperty("StartMonth", month);
        for (int day = 1; day <= 27; day++)
        {
          cycleProps.ModifyProperty("StartDay", day);

          cycle.Clear();
          cycle.StartMonth = month;
          cycle.StartDay = day;

          DateTime refDate = new DateTime(2001, 1, 1);
          // test every day for 5 years.  this way we know we hit a leap year
          for (int i = 0; i < 365 * 5; i++)
          {
            // NOTE: the new cycle object seems to be about 10 times faster
            // than the old adapter.  these test can take a little while (15 seconds or so)
            ComputeAndTestDates(refDate,
                                cycleType, cycle,
                                stdcycle, cycleProps);

            refDate = refDate.AddDays(1);
          }
        }
      }
    }

    /// <summary>
    /// Test of Annual
    /// </summary>
    [Test]
    public void T07TestAnnualCycles()
    {
      ICycleType cycleType = new AnnualCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdAnnually();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("StartMonth", 1);
      cycleProps.AddProperty("StartDay", 1);

      System.Globalization.Calendar calendar =
        new System.Globalization.GregorianCalendar();

      // test each day of the year
      for (int month = 1; month <= 12; month++)
      {
        cycleProps.ModifyProperty("StartMonth", month);
        for (int day = 1; day <= calendar.GetDaysInMonth(1999, month); day++)
        {
          cycleProps.ModifyProperty("StartDay", day);

          cycle.Clear();
          cycle.StartMonth = month;
          cycle.StartDay = day;

          DateTime refDate = new DateTime(2001, 1, 1);
          // test every day for 5 years.  this way we know we hit a leap year
          for (int i = 0; i < 365 * 5; i++)
          {
            ComputeAndTestDates(refDate,
                                cycleType, cycle,
                                stdcycle, cycleProps);

            refDate = refDate.AddDays(1);
          }

        }
      }
    }

    /// <summary>
    /// Test of semiannual
    /// </summary>
    [Test]
    public void T08TestSemiAnnualCycles()
    {
      ICycleType cycleType = new SemiAnnualCycleType();

      OldUsageCycle.IMTUsageCycle stdcycle = (OldUsageCycle.IMTUsageCycle)new OldUsageCycle.MTStdSemiAnnually();

      OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps =
        (OldUsageCycle.ICOMUsageCyclePropertyColl)new OldUsageServer.COMUsageCyclePropertyColl();

      Cycle cycle = new Cycle();

      // have to call AddProperty once, then use ModifyProperty
      cycleProps.AddProperty("StartMonth", 1);
      cycleProps.AddProperty("StartDay", 1);

      System.Globalization.Calendar calendar =
        new System.Globalization.GregorianCalendar();
 //     DateTime refDate = new DateTime(2001, 7, 1);

      // test each day of the year
      for (int month = 1; month <= 12; month++)
      {
        cycleProps.ModifyProperty("StartMonth", month);
        for (int day = 1; day <= calendar.GetDaysInMonth(1999, month); day++)
        {
          cycleProps.ModifyProperty("StartDay", day);

          cycle.Clear();
          cycle.StartMonth = month;
          cycle.StartDay = day;

          DateTime refDate = new DateTime(2001,1, 1);
          // test every day for 5 years.  this way we know we hit a leap year
//          DateTime refDate = new DateTime(2003, 8, 29);
          for (int i = 0; i < 365 * 5; i++)
          {
            ComputeAndTestDates(refDate,
                                cycleType, cycle,
                                stdcycle, cycleProps);

            refDate = refDate.AddDays(1);
          }

        }
      }
    }
		private void ComputeAndTestDates(DateTime refDate,
																		 ICycleType cycleType, 
																		 ICycle cycle,
																		 OldUsageCycle.IMTUsageCycle stdcycle,
																		 OldUsageCycle.ICOMUsageCyclePropertyColl cycleProps)
		{
			// calculate using the new Cycle interface
			DateTime start;
			DateTime end;
			cycleType.ComputeStartAndEndDate(refDate, cycle, out start, out end);

			// compute the same way using the old cycle objects
			DateTime stdStart;
			DateTime stdEnd;
			stdcycle.ComputeStartAndEndDate(refDate, cycleProps, out stdStart, out stdEnd);

			if (stdStart != start || stdEnd != end)
			{
				string message = String.Format("Mismatch for reference date {0}: {1}, Old code returned: {2} - {3}, New code returned: {4} - {5}",
																			 refDate, cycle, stdStart, stdEnd, start, end);
				Assert.Fail(message);
			}
		}
	}
}

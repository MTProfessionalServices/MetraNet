using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
using System.ServiceProcess;
using System.Runtime.InteropServices;
using NUnit.Framework;

using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.Test;
using MetraTech.Pipeline;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.COMMeter;
using MetraTech.Interop.PipelineTransaction;

namespace MetraTech.UsageServer.Test
{
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.UsageServer.Test.RecurrenceTests /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
	//
  [TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
  public class RecurrenceTests
  {


    /// <summary>
    /// Test Minutely Recurrence Pattern
    /// </summary>
    [Test]
    public void TestMinutely()
    {
      MinutelyRecurrencePattern minutely = new MinutelyRecurrencePattern(15);
      Assert.AreEqual(minutely.IsPaused, false, "Hey, should not be paused");
      Assert.AreEqual(minutely.IsSkipOne, false, "Should not be skipped one");
      Assert.AreEqual(DateTime.Parse("01/10/2011 7:45 PM"), minutely.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/2011 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(minutely.StartDate.AddMinutes(15),    minutely.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/1990 7:34 PM")), "NextPatternOccurrence Failed");
      DateTime next = minutely.GetNextOccurrence();
      minutely.IsSkipOne = true;
      Assert.AreEqual(true, minutely.IsSkipOne, "Should be skipped one");
      Assert.AreEqual(true, minutely.IsOverride, "Should be override");
      DateTime nextSkipOne = minutely.GetNextOccurrence();
      TimeSpan ts = nextSkipOne.Subtract(next);
      Assert.AreEqual(15, ts.TotalMinutes,  "Skip one interval missmatch");
      minutely.IsSkipOne = false;
      Assert.AreEqual(false, minutely.IsOverride, "Should not be override now");
    }

    /// <summary>
    /// Test Daily Recurrence Pattern
    /// </summary>
    [Test]
    public void TestDaily()
    {
      DailyRecurrencePattern daily = new DailyRecurrencePattern(2, "5:00 AM");
      daily = new DailyRecurrencePattern(5, "5:00 AM,18:22, 2:00");// parse some complex time
      Assert.AreEqual(daily.IsPaused, false, "Hey, should not be paused");
      Assert.AreEqual(daily.IsSkipOne, false, "Should not be skipped one");
      Assert.AreEqual(DateTime.Parse("01/11/2011 2:00 AM"), daily.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/2011 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/11/2011 6:22 PM"), daily.GetNextPatternOccurrenceAfter(DateTime.Parse("01/11/2011 3:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/16/2011 2:00 AM"), daily.GetNextPatternOccurrenceAfter(DateTime.Parse("01/11/2011 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(daily.StartDate.Add(new TimeSpan(2, 0, 0)), daily.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/1990 7:34 PM")), "NextPatternOccurrence Failed");

      daily = new DailyRecurrencePattern(5, "5:00 PM");
      DateTime next = daily.GetNextOccurrence();
      daily.IsSkipOne = true;
      Assert.AreEqual(true, daily.IsSkipOne, "Should be skipped one");
      Assert.AreEqual(true, daily.IsOverride, "Should be override");
      DateTime nextSkipOne = daily.GetNextOccurrence();
      TimeSpan ts = nextSkipOne.Subtract(next);
      Assert.AreEqual(5, ts.TotalDays, "Skip one interval missmatch");
      daily.IsSkipOne = false;
      Assert.AreEqual(false, daily.IsOverride, "Should not be override now");
    }


    /// <summary>
    /// Test Weekly Recurrence Pattern
    /// </summary>
    [Test]
    public void TestWeekly()
    {
      WeeklyRecurrencePattern weekly = new WeeklyRecurrencePattern(2, "5:00 AM", "Mon, Tuesday, We");
      weekly = new WeeklyRecurrencePattern(5, "5:00 AM,18:22, 2:00", "Mon, Wed, Fri");// parse some complex time
      Assert.AreEqual(weekly.IsPaused, false, "Hey, should not be paused");
      Assert.AreEqual(weekly.IsSkipOne, false, "Should not be skipped one");
      Assert.AreEqual(DateTime.Parse("01/17/2011 2:00 AM"), weekly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/2011 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/17/2011 6:22 PM"), weekly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/17/2011 3:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/19/2011 2:00 AM"), weekly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/18/2011 3:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("02/21/2011 2:00 AM"), weekly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/21/2011 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/19/2011 2:00 AM"), weekly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/17/2011 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(weekly.StartDate.Add(new TimeSpan(1, 2, 0, 0)), weekly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/1990 7:34 PM")), "NextPatternOccurrence Failed");

      weekly = new WeeklyRecurrencePattern(5, "5:00 PM", "Mon");
      DateTime next = weekly.GetNextOccurrence();
      weekly.IsSkipOne = true;
      Assert.AreEqual(true, weekly.IsSkipOne, "Should be skipped one");
      Assert.AreEqual(true, weekly.IsOverride, "Should be override");
      DateTime nextSkipOne = weekly.GetNextOccurrence();
      TimeSpan ts = nextSkipOne.Subtract(next);
      Assert.AreEqual(5 * 7, ts.TotalDays, "Skip one interval missmatch");
      weekly.IsSkipOne = false;
      Assert.AreEqual(false, weekly.IsOverride, "Should not be override now");
    }

    /// <summary>
    /// Test Monthly Recurrence Pattern
    /// </summary>
    [Test]
    public void TestMonthly()
    {
      MonthlyRecurrencePattern monthly = new MonthlyRecurrencePattern(2, "4:00 PM", "1,Second Monday,last day");
      Assert.AreEqual(monthly.IsPaused, false, "Hey, should not be paused");
      Assert.AreEqual(monthly.IsSkipOne, false, "Should not be skipped one");
      Assert.AreEqual(DateTime.Parse("01/01/2011 4:00 PM"), monthly.GetNextPatternOccurrenceAfter(DateTime.Parse("12/31/2010 7:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/01/2011 4:00 PM"), monthly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/01/2011 3:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/10/2011 4:00 PM"), monthly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/01/2011 4:34 PM")), "NextPatternOccurrence Failed");
      Assert.AreEqual(DateTime.Parse("01/31/2011 4:00 PM"), monthly.GetNextPatternOccurrenceAfter(DateTime.Parse("01/10/2011 4:34 PM")), "NextPatternOccurrence Failed");

      monthly = new MonthlyRecurrencePattern(10, "2:00 AM", "10");
      DateTime next = monthly.GetNextOccurrence();
      monthly.IsSkipOne = true;
      Assert.AreEqual(true, monthly.IsSkipOne, "Should be skipped one");
      Assert.AreEqual(true, monthly.IsOverride, "Should be override");
      DateTime nextSkipOne = monthly.GetNextOccurrence();
      Assert.AreEqual(next.AddMonths(10), nextSkipOne, "Skip one interval missmatch");
      monthly.IsSkipOne = false;
      Assert.AreEqual(false, monthly.IsOverride, "Should not be override now");
    }



    /// <summary>
    /// Test DaysOfMonth class
    /// </summary>
    [Test]
    public void TestDaysOfMonth()
    {
      Boolean nextMonth;
      DaysOfMonth dayOfMonth = DaysOfMonth.Parse("First Monday");
      int day = dayOfMonth.NextTime(DateTime.Parse("01/19/2011"), out nextMonth);
      Assert.AreEqual(-1, day, "Next time day incorrect");
      Assert.AreEqual(nextMonth, true, "next time nextMonth incorrect");
      day = dayOfMonth.NextTime(DateTime.Parse("01/01/2011"), out nextMonth);
      Assert.AreEqual(3, day, "day");
      Assert.AreEqual(false, nextMonth, "month");
      day = dayOfMonth.NextTime(DateTime.Parse("01/03/2011"), out nextMonth);
      Assert.AreEqual(3, day, "day");
      Assert.AreEqual(false, nextMonth, "month");
      dayOfMonth = DaysOfMonth.Parse("Second Tuesday, Third Wednesday, Fourth Thursday, Last Friday");
      //day = dayOfMonth.NextTime

      dayOfMonth = DaysOfMonth.Parse("last day, last day, last day");
      // test that I can parse different formats, eliminate replicatng patterns, sort properly.
      Assert.AreEqual(
        DaysOfMonth.Parse("last day, last day, last day, first monday, 1, last day, 12, second tuesday, first tuesday").ToString(),
        DaysOfMonth.Parse("Second tue, First Tue, 1, 12, last day, first mon, last day").ToString(),
        "Comparison between similar objects with different representation");
      dayOfMonth = DaysOfMonth.Parse("1,15, last  day");
      day = dayOfMonth.NextTime(DateTime.Parse("07/12/2011"), out nextMonth);
      Assert.AreEqual(15, day, "day");
      Assert.AreEqual(false, nextMonth, "month");
      day = dayOfMonth.NextTime(DateTime.Parse("07/01/2011"), out nextMonth);
      Assert.AreEqual(1, day, "day");
      Assert.AreEqual(false, nextMonth, "month");
      day = dayOfMonth.NextTime(DateTime.Parse("07/16/2011"), out nextMonth);
      Assert.AreEqual(31, day, "day");
      Assert.AreEqual(false, nextMonth, "month");

    }

    /// <summary>
    /// Test Times class
    /// </summary>
    [Test]
    public void TestTimes()
    {
      // test that I can parse different formats, eliminate replicatng times, sort properly.
      Assert.AreEqual(
        Times.Parse("2:00 ,16:00,3:00,4:00 PM, 2:00 AM").ToString(),
        Times.Parse("4:00 PM,  2:00 AM,3:00 AM").ToString(),
        "Comparison between similar objects with different representation");

    }



  }
}

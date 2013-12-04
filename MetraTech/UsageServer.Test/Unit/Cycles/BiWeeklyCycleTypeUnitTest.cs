using System;
using System.Linq;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class BiWeeklyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new BiWeeklyCycleType();

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenNotCanonicalCycleCycleAndRefDayEqualToCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 03, 23);
      var cycle = new Cycle {StartDay = 23, StartMonth = 3, StartYear = 2013};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 23), _start);
      Assert.AreEqual(new DateTime(2013, 04, 05), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenNotCanonicalCycleAndRefDayEqualToCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 04, 05);
      var cycle = new Cycle {StartDay = 23, StartMonth = 3, StartYear = 2013};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 23), _start);
      Assert.AreEqual(new DateTime(2013, 04, 05), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenNotCanonicalCycleAndRefDayBeforeCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 03, 22);
      var cycle = new Cycle { StartDay = 23, StartMonth = 3, StartYear = 2013 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 09), _start);
      Assert.AreEqual(new DateTime(2013, 03, 22), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenNotCanonicalCycleAndRefDayAfterCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 04, 06);
      var cycle = new Cycle { StartDay = 23, StartMonth = 3, StartYear = 2013 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 04, 06), _start);
      Assert.AreEqual(new DateTime(2013, 04, 19), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenNotCanonicalCycleStartsAtLastDayOf14DaysPeriodTest()
    {
      _refDate = new DateTime(2013, 12, 31);
      var cycle = new Cycle { StartDay = 9, StartMonth = 3, StartYear = 2012 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 12, 27), _start);
      Assert.AreEqual(new DateTime(2014, 01, 09), _end);
  }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateLessThanNotCanonicalCycleStartDateTest()
    {
      _refDate = new DateTime(2012, 02, 29);
      var cycle = new Cycle { StartDay = 9, StartMonth = 3, StartYear = 2012 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2012, 02, 24), _start);
      Assert.AreEqual(new DateTime(2012, 03, 08), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateYearLessThan2000Test()
    {
      _refDate = new DateTime(1999, 12, 17);
      var cycle = new Cycle { StartDay = 20, StartMonth = 12, StartYear = 1999 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(1999, 12, 06), _start);
      Assert.AreEqual(new DateTime(1999, 12, 19), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateIsEqualCanonicalCycleStartDateTest()
    {
      _refDate = new DateTime(2000, 1, 2);
      var cycle = new Cycle { StartDay = 2, StartMonth = 1, StartYear = 2000 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2000, 1, 02), _start);
      Assert.AreEqual(new DateTime(2000, 1, 15), _end);
    }

    [TestMethod, MTUnitTest]
    public void MakeCanonicalWhenCycleIsCanonical()
    {
      var cycle = new Cycle { StartDay = 2, StartMonth = 1, StartYear = 2000 };
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(2, cycle.StartDay);
      Assert.AreEqual(1, cycle.StartMonth);
      Assert.AreEqual(2000, cycle.StartYear);
    }

    [TestMethod, MTUnitTest]
    public void MakeCanonicalWhenCycleGreaterThanCanonicalTest()
    {
      var cycle = new Cycle { StartDay = 17, StartMonth = 1, StartYear = 2000 };
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(3, cycle.StartDay);
      Assert.AreEqual(1, cycle.StartMonth);
      Assert.AreEqual(2000, cycle.StartYear);
    }

    [TestMethod, MTUnitTest]
    public void MakeCanonicalWhenCycleLessThanCanonicalTest()
    {
      var cycle = new Cycle {StartDay = 15, StartMonth = 12, StartYear = 1999};
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(12, cycle.StartDay);
      Assert.AreEqual(1, cycle.StartMonth);
      Assert.AreEqual(2000, cycle.StartYear);
    }

    [TestMethod, MTUnitTest]
    public void IsCanonicalWhenMonthIsNotCanonical()
    {
      var cycle = new Cycle { StartDay = 15, StartMonth = 1, StartYear = 2000 };
      Assert.IsFalse(_cycleType.IsCanonical(cycle));
    }

    [TestMethod, MTUnitTest]
    public void IsCanonicalWhenCycleIsCanonical()
    {
      var cycle = new Cycle { StartDay = 14, StartMonth = 1, StartYear = 2000};
      Assert.IsTrue(_cycleType.IsCanonical(cycle));
    }

    [TestMethod, MTUnitTest]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();

      // Should be 14 bi-weekly cycles
      Assert.AreEqual(14, cycles.Length);
     
      foreach (var cycle in cycles)
      {
        //Validate required cycle properties
        Assert.IsTrue(cycle.StartYear == 2000);
        Assert.IsTrue(cycle.StartMonth == 1);
        Assert.IsTrue(cycle.StartDay >= 1 && cycle.StartDay <= 14);
        Assert.AreEqual(cycle.CycleType, CycleType.BiWeekly);
        //Cycle's properties listed below should not be set
        Assert.AreEqual(cycle.DayOfMonth, -1);
        Assert.AreEqual(cycle.DayOfWeek, DayOfWeek.Monday);
        Assert.AreEqual(cycle.DayOfYear, -1);
        Assert.AreEqual(cycle.FirstDayOfMonth, -1);
        Assert.AreEqual(cycle.SecondDayOfMonth, -1);
        //Validate that current cycle is uniqe in the collection of cycles
        // ReSharper disable ReturnValueOfPureMethodIsNotUsed
        cycles.Single(c => c.StartDay == cycle.StartDay);
        // ReSharper restore ReturnValueOfPureMethodIsNotUsed
      }
    }
  }
}
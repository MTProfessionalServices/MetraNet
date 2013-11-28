using System;
using System.Linq;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class QuarterlyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new QuarterlyCycleType();

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateEqualToCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 07, 01);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 04, 30), _start);
      Assert.AreEqual(new DateTime(2013, 07, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateADayBeforeCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 07, 30);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 04, 30), _start);
      Assert.AreEqual(new DateTime(2013, 07, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateEqualToCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 10, 30);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 07, 31), _start);
      Assert.AreEqual(new DateTime(2013, 10, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateADayAfterCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 10, 31);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 10, 31), _start);
      Assert.AreEqual(new DateTime(2014, 01, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenCycleStartDateADayBeforeEndDateOfMonthTest()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle {StartDay = 30, StartMonth = 3};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 30), _start);
      Assert.AreEqual(new DateTime(2013, 06, 29), _end);

      _refDate = new DateTime(2013, 11, 01);
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 09, 30), _start);
      Assert.AreEqual(new DateTime(2013, 12, 29), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenCycleStartDateEqualToEndDateOfMonthTest()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle {StartDay = 31, StartMonth = 3};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 31), _start);
      Assert.AreEqual(new DateTime(2013, 06, 29), _end);

      _refDate = new DateTime(2013, 11, 01);
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);
      Assert.AreEqual(new DateTime(2013, 09, 30), _start);
      Assert.AreEqual(new DateTime(2013, 12, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateFebruaryCaseTest()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle {StartDay = 29, StartMonth = 2};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 02, 28), _start);
      Assert.AreEqual(new DateTime(2013, 05, 28), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateShouldThrowExceptionIfCycleIsNull()
    {
      ExceptionAssert.Expected<ArgumentNullException>(
        () => _cycleType.ComputeStartAndEndDate(DateTime.Now, null, out _start, out _end),
        "Value cannot be null.\r\nParameter name: cycle");
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateShouldThrowExceptionIfCycleStartMonthMissed()
    {
      var cycle = new Cycle {StartDay = 1};
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(DateTime.Now, cycle, out _start, out _end),
        "cycle.StartMonth property must be initialized");
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateShouldThrowExceptionIfCycleStartDayMissed()
    {
      var cycle = new Cycle {StartMonth = 1};
      
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(DateTime.Now, cycle, out _start, out _end),
        "cycle.StartDay property must be initialized");
    }

    [TestMethod, MTUnitTest]
    public void MakeCanonicalWhenMonthIsCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 2 };
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(2, cycle.StartMonth);
    }

    [TestMethod, MTUnitTest]
    public void MakeCanonicalWhenMonthIsNotCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 11 };
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(2, cycle.StartMonth);
    }

    [TestMethod, MTUnitTest]
    public void IsCanonicalWhenMonthIsNotCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 11 };
      Assert.IsFalse(_cycleType.IsCanonical(cycle));
    }

    [TestMethod, MTUnitTest]
    public void IsCanonicalWhenMonthIsCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 2 };
      Assert.IsTrue(_cycleType.IsCanonical(cycle));
    }

    [TestMethod, MTUnitTest]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();

      // Should be 93 quarterly cycles
      Assert.AreEqual(93, cycles.Length);

      foreach (var cycle in cycles)
      {
        //Validate required cycle properties
        Assert.IsTrue(cycle.StartMonth >= 1 && cycle.StartMonth <= 3);
        Assert.IsTrue(cycle.StartDay >= 1 && cycle.StartDay <= 31);
        Assert.AreEqual(cycle.CycleType, CycleType.Quarterly);
        //Cycle's properties listed below should not be set
        Assert.AreEqual(cycle.StartYear, -1);
        Assert.AreEqual(cycle.DayOfMonth, -1);
        Assert.AreEqual(cycle.DayOfWeek, DayOfWeek.Monday);
        Assert.AreEqual(cycle.DayOfYear, -1);
        Assert.AreEqual(cycle.FirstDayOfMonth, -1);
        Assert.AreEqual(cycle.SecondDayOfMonth, -1);
        //Validate that current cycle is uniqe in the collection of cycles
        // ReSharper disable ReturnValueOfPureMethodIsNotUsed
        cycles.Single(c => c.StartMonth == cycle.StartMonth && c.StartDay == cycle.StartDay);
        // ReSharper restore ReturnValueOfPureMethodIsNotUsed
      }
    }
  }
}
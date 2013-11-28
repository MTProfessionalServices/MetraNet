using System;
using System.Linq;
using MetraTech.TestCommon;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestFixture]
  public class SemiMonthlyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new SemiMonthlyCycleType();

    [Test]
    public void ComputeStartAndEndDateWhenRefDateLessThanFirstDayAndSecondDayTest()
    {
      _refDate = new DateTime(2013, 03, 04);
      var cycle = new Cycle { FirstDayOfMonth = 5, SecondDayOfMonth = 15 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 02, 16), _start);
      Assert.AreEqual(new DateTime(2013, 03, 05), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateGreaterThanFirstDayAndLessThanSecondDayTest()
    {
      _refDate = new DateTime(2013, 03, 06);
      var cycle = new Cycle { FirstDayOfMonth = 5, SecondDayOfMonth = 15 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 06), _start);
      Assert.AreEqual(new DateTime(2013, 03, 15), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateGreaterThanFirstDayAndSecondDayTest()
    {
      _refDate = new DateTime(2013, 03, 24);
      var cycle = new Cycle { FirstDayOfMonth = 5, SecondDayOfMonth = 15 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 16), _start);
      Assert.AreEqual(new DateTime(2013, 04, 05), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenSecondDayOfMonthAbsentTest()
    {
      _refDate = new DateTime(2013, 07, 01);
      var cycle = new Cycle { FirstDayOfMonth = 5 };
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end),
        "cycle.SecondDayOfMonth property must be initialized");
    }

    [Test]
    public void ComputeStartAndEndDateWhenFirstDayOfMonthAbsentTest()
    {
      _refDate = new DateTime(2013, 07, 01);
      var cycle = new Cycle { SecondDayOfMonth = 5 };
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end),
        "cycle.FirstDayOfMonth property must be initialized");
    }

    [Test]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();

      // Should be 465 semi-monthly cycles
      Assert.AreEqual(465, cycles.Length);

      foreach (var cycle in cycles)
      {
        //Validate required cycle properties
        Assert.IsTrue(cycle.FirstDayOfMonth >= 1 && cycle.FirstDayOfMonth <= 30);
        Assert.IsTrue(cycle.SecondDayOfMonth >= cycle.FirstDayOfMonth && cycle.SecondDayOfMonth <= 31);
        Assert.AreEqual(cycle.CycleType, CycleType.SemiMonthly);
        //Cycle's properties listed below should not be set
        Assert.AreEqual(cycle.StartYear, -1);
        Assert.AreEqual(cycle.StartMonth, -1);
        Assert.AreEqual(cycle.StartDay, -1);
        Assert.AreEqual(cycle.DayOfMonth, -1);
        Assert.AreEqual(cycle.DayOfWeek, DayOfWeek.Monday);
        Assert.AreEqual(cycle.DayOfYear, -1);
        //Validate that current cycle is uniqe in the collection of cycles
        // ReSharper disable ReturnValueOfPureMethodIsNotUsed
        cycles.Single(c => c.FirstDayOfMonth == cycle.FirstDayOfMonth && c.SecondDayOfMonth == cycle.SecondDayOfMonth);
        // ReSharper restore ReturnValueOfPureMethodIsNotUsed
      }
    }
  }
}
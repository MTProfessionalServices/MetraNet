using System;
using System.Linq;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  //TODO Delete this class when all legacy smoke tests become MStest ones instead of Nunit ones
  //This test class duplicates the same class stored in c...\Legacy_Internal\Source\MetraTech\UsageServer.Test\
  //because at this point MetraTech tests use Nunit framework
  [TestFixture]
  public class MonthlyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new MonthlyCycleType();

    [Test]
    public void RefDayLessThanDayOfMOnth()
    {
      _refDate = new DateTime(2013, 12, 01);
      var cycle = new Cycle { DayOfMonth = 31};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 12, 01), _start);
      Assert.AreEqual(new DateTime(2013, 12, 31), _end);
    }

    [Test]
    public void RefDayGreaterThanDayOfMonth()
    {
      _refDate = new DateTime(2013, 12, 31);
      var cycle = new Cycle { DayOfMonth = 2};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 12, 03), _start);
      Assert.AreEqual(new DateTime(2014, 01, 02), _end);
    }

    [Test]
    public void RefDayEaqualToDayOfMOnth()
    {
      _refDate = new DateTime(2013, 12, 01);
      var cycle = new Cycle { DayOfMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 11, 02), _start);
      Assert.AreEqual(new DateTime(2013, 12, 01), _end);
    }

    [Test]
    public void RefDayFallsIn30DaysMonthAndEqualToDayOfMonth()
    {
      _refDate = new DateTime(2013, 04, 30);
      var cycle = new Cycle { DayOfMonth = 30 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 31), _start);
      Assert.AreEqual(new DateTime(2013, 04, 30), _end);
    }

    [Test]
    public void RefDayFallsIn30DaysMonthAndLessThanDayOfMonth()
    {
      _refDate = new DateTime(2013, 04, 30);
      var cycle = new Cycle { DayOfMonth =  31};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 04, 01), _start);
      Assert.AreEqual(new DateTime(2013, 04, 30), _end);
    }

    [Test]
    public void RefDayFallsIn31DaysMonthAndEqualToDayOfMonth()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle { DayOfMonth = 30 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 31), _start);
      Assert.AreEqual(new DateTime(2013, 04, 30), _end);
    }

    [Test]
    public void RefDayFallsIn31DaysMonthAndLessThanDayOfMonth()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle { DayOfMonth = 31};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 01), _start);
      Assert.AreEqual(new DateTime(2013, 03, 31), _end);
    }

    [Test]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();

      // Should be 31 monthly cycles
      Assert.AreEqual(31, cycles.Length);

      foreach (var cycle in cycles)
      {
        //Validate required cycle properties
        Assert.IsTrue(cycle.DayOfMonth >= 1 && cycle.DayOfMonth <= 31);
        Assert.AreEqual(cycle.CycleType, CycleType.Monthly);
        //Cycle's properties listed below should not be set
        Assert.AreEqual(cycle.StartYear, -1);
        Assert.AreEqual(cycle.StartMonth, -1);
        Assert.AreEqual(cycle.StartDay, -1);
        Assert.AreEqual(cycle.DayOfWeek, DayOfWeek.Monday);
        Assert.AreEqual(cycle.DayOfYear, -1);
        Assert.AreEqual(cycle.FirstDayOfMonth, -1);
        Assert.AreEqual(cycle.SecondDayOfMonth, -1);
        //Validate that current cycle is uniqe in the collection of cycles
        // ReSharper disable ReturnValueOfPureMethodIsNotUsed
        cycles.Single(c => c.DayOfMonth == cycle.DayOfMonth);
        // ReSharper restore ReturnValueOfPureMethodIsNotUsed
      }
    }
  }
}
using System;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
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
  }
}
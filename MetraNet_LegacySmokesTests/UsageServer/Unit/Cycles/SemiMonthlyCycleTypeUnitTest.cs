using System;
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
  }
}
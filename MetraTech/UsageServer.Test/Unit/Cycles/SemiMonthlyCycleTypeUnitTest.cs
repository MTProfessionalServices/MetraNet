using System;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class SemiMonthlyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new SemiMonthlyCycleType();

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateLessThanFirstDayAndSecondDayTest()
    {
      _refDate = new DateTime(2013, 03, 04);
      var cycle = new Cycle { FirstDayOfMonth = 5, SecondDayOfMonth = 15 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 02, 16), _start);
      Assert.AreEqual(new DateTime(2013, 03, 05), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateGreaterThanFirstDayAndLessThanSecondDayTest()
    {
      _refDate = new DateTime(2013, 03, 06);
      var cycle = new Cycle { FirstDayOfMonth = 5, SecondDayOfMonth = 15 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 06), _start);
      Assert.AreEqual(new DateTime(2013, 03, 15), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateGreaterThanFirstDayAndSecondDayTest()
    {
      _refDate = new DateTime(2013, 03, 24);
      var cycle = new Cycle { FirstDayOfMonth = 5, SecondDayOfMonth = 15 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 16), _start);
      Assert.AreEqual(new DateTime(2013, 04, 05), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenSecondDayOfMonthAbsentTest()
    {
      _refDate = new DateTime(2013, 07, 01);
      var cycle = new Cycle { FirstDayOfMonth = 5 };
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end),
        "cycle.SecondDayOfMonth property must be initialized");
    }

    [TestMethod, MTUnitTest]
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
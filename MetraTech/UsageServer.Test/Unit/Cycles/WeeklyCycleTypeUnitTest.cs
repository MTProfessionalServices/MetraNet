using System;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class WeeklyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new WeeklyCycleType();

    [TestMethod, MTUnitTest]
    public void RefDayEqualToDayOfWeekTest()
    {
      _refDate = new DateTime(2013, 09, 24);
      var cycle = new Cycle {DayOfWeek = DayOfWeek.Tuesday};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 09, 18), _start);
      Assert.AreEqual(new DateTime(2013, 09, 24), _end);
    }

    [TestMethod, MTUnitTest]
    public void RefDayLessThanDayOfWeek()
    {
      _refDate = new DateTime(2013, 09, 23);
      var cycle = new Cycle {DayOfWeek = DayOfWeek.Sunday};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 09, 23), _start);
      Assert.AreEqual(new DateTime(2013, 09, 29), _end);
    }

    [TestMethod, MTUnitTest]
    public void RefDayGreaterThanDayOfWeek()
    {
      _refDate = new DateTime(2013, 09, 29);
      var cycle = new Cycle {DayOfWeek = DayOfWeek.Monday};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 09, 24), _start);
      Assert.AreEqual(new DateTime(2013, 09, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void MondayIsDefaultDayOfWeekTest()
    {
      _refDate = new DateTime(2013, 09, 29);
      var cycle = new Cycle ();
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 09, 24), _start);
      Assert.AreEqual(new DateTime(2013, 09, 30), _end);
    }
  }
}
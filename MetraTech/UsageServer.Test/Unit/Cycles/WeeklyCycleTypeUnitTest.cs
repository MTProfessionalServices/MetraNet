using System;
using System.Linq;
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

    [TestMethod, MTUnitTest]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();

      // Should be 7 weekly cycles
      Assert.AreEqual(7, cycles.Length);

      foreach (var cycle in cycles)
      {
        Assert.AreEqual(cycle.CycleType, CycleType.Weekly);
        //Cycle's properties listed below should not be set
        Assert.AreEqual(cycle.StartYear, -1);
        Assert.AreEqual(cycle.StartMonth, -1);
        Assert.AreEqual(cycle.StartDay, -1);
        Assert.AreEqual(cycle.DayOfMonth, -1);
        Assert.AreEqual(cycle.DayOfYear, -1);
        Assert.AreEqual(cycle.FirstDayOfMonth, -1);
        Assert.AreEqual(cycle.SecondDayOfMonth, -1);
        //Validate that current cycle is uniqe in the collection of cycles
        // ReSharper disable ReturnValueOfPureMethodIsNotUsed
        cycles.Single(c => c.DayOfWeek == cycle.DayOfWeek);
        // ReSharper restore ReturnValueOfPureMethodIsNotUsed
      }
    }
  }
}

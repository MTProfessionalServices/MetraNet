using System;
using System.Linq;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class AnnualCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new AnnualCycleType();

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateAfterCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 12, 01);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 01, 31), _start);
      Assert.AreEqual(new DateTime(2014, 01, 30), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateBeforeCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 01, 31);
      var cycle = new Cycle { StartDay = 1, StartMonth = 3 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2012, 03, 01), _start);
      Assert.AreEqual(new DateTime(2013, 02, 28), _end);
    }

    [TestMethod, MTUnitTest]
    public void ComputeStartAndEndDateWhenRefDateBeforeCycleStartDateLeapYearTest()
    {
      _refDate = new DateTime(2012, 01, 31);
      var cycle = new Cycle { StartDay = 1, StartMonth = 3 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2011, 03, 01), _start);
      Assert.AreEqual(new DateTime(2012, 02, 29), _end);
    }

    [TestMethod, MTUnitTest]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();

      // Should be 365 annual cycles
      Assert.AreEqual(365, cycles.Length);

      foreach (var cycle in cycles)
      {
        //Validate required cycle properties
        Assert.IsTrue(cycle.StartMonth >= 1 && cycle.StartMonth <= 12);
        Assert.IsTrue(cycle.StartDay >= 1 && cycle.StartDay<=DateTime.DaysInMonth(1999, cycle.StartMonth));
        Assert.AreEqual(cycle.CycleType, CycleType.Annual);
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

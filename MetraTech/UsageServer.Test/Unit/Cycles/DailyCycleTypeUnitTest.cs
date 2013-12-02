using System;
using System.Linq;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class DailyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new DailyCycleType();

    [TestMethod, MTUnitTest]
    public void DailyCycleTypeTest()
    {
      _refDate = DateTime.Now;
      var cycle = new Cycle {StartDay = 1, StartMonth = 3};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(_refDate.DayOfYear, _start.DayOfYear);
      Assert.AreEqual(_refDate.DayOfYear, _end.DayOfYear);
    }

    [TestMethod, MTUnitTest]
    public void GenerateCyclesTest()
    {
      var cycles = _cycleType.GenerateCycles();
      // Should be 1 daily cycle
      var cycle = cycles.Single();
      Assert.AreEqual(cycle.CycleType, CycleType.Daily);
      //Cycle's properties listed below should not be set
      Assert.AreEqual(cycle.StartYear, -1);
      Assert.AreEqual(cycle.StartMonth, -1);
      Assert.AreEqual(cycle.StartDay, -1);
      Assert.AreEqual(cycle.DayOfMonth, -1);
      Assert.AreEqual(cycle.DayOfWeek, DayOfWeek.Monday);
      Assert.AreEqual(cycle.DayOfYear, -1);
      Assert.AreEqual(cycle.FirstDayOfMonth, -1);
      Assert.AreEqual(cycle.SecondDayOfMonth, -1);
    }
  }
}

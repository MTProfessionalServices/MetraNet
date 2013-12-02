using System;
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
      var cycle = new Cycle { StartDay = 1, StartMonth = 3 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(_refDate.DayOfYear, _start.DayOfYear);
      Assert.AreEqual(_refDate.DayOfYear, _end.DayOfYear);
    }
  }
}
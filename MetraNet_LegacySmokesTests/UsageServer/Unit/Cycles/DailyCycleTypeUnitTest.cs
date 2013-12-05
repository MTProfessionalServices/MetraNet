using System;
using System.Linq;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  //TODO Delete this class when all legacy smoke tests become MStest ones instead of Nunit ones
  //This test class duplicates the same class stored in c...\Legacy_Internal\Source\MetraTech\UsageServer.Test\
  //because at this point MetraTech tests use Nunit framework
  [TestFixture]
  public class DailyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new DailyCycleType();

    [Test]
    public void DailyCycleTypeTest()
    {
      _refDate = DateTime.Now;
      var cycle = new Cycle { StartDay = 1, StartMonth = 3 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(_refDate.DayOfYear, _start.DayOfYear);
      Assert.AreEqual(_refDate.DayOfYear, _end.DayOfYear);
    }

    [Test]
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
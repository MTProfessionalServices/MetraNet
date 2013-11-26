using System;
using MetraTech.TestCommon;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestFixture]
  public class SemiAnnualCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new SemiAnnualCycleType();

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateIsJan01AndEqualRefDateTest()
    {
      _refDate = new DateTime(2013, 01, 01);
      var cycle = new Cycle { StartDay = 1, StartMonth = 1 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 01, 01), _start);
      Assert.AreEqual(new DateTime(2013, 06, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateJan01AndRefDateIsCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 06, 30);
      var cycle = new Cycle { StartDay = 1, StartMonth = 1 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 01, 01), _start);
      Assert.AreEqual(new DateTime(2013, 06, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateBeforeCycleStartDateTest()
    {
      _refDate = new DateTime(2012, 12, 31);
      var cycle = new Cycle { StartDay = 1, StartMonth = 1 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2012, 07, 01), _start);
      Assert.AreEqual(new DateTime(2012, 12, 31), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateAfterCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 07, 01);
      var cycle = new Cycle { StartDay = 1, StartMonth = 1 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 07, 01), _start);
      Assert.AreEqual(new DateTime(2013, 12, 31), _end);
    }

    [Test]
    public void ComputeStartAndEndDateShouldReturnSameIntervalAsIfCycleStartDateJan01Test()
    {
      _refDate = new DateTime(2013, 06, 30);
      var cycle = new Cycle { StartDay = 1, StartMonth = 7 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 01, 01), _start);
      Assert.AreEqual(new DateTime(2013, 06, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateDec31AndEqualRefDateTest()
    {
      _refDate = new DateTime(2013, 12, 31);
      var cycle = new Cycle { StartDay = 31, StartMonth = 12 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 12, 31), _start);
      Assert.AreEqual(new DateTime(2014, 06, 29), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateDec31AndRefDateBeforeStartDateTest()
    {
      _refDate = new DateTime(2013, 12, 30);
      var cycle = new Cycle { StartDay = 31, StartMonth = 12 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 06, 30), _start);
      Assert.AreEqual(new DateTime(2013, 12, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateFeb28Test()
    {
      _refDate = new DateTime(2013, 09, 30);
      var cycle = new Cycle { StartDay = 28, StartMonth = 2 };
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 08, 28), _start);
      Assert.AreEqual(new DateTime(2014, 02, 27), _end);
    }

    [Test]
    public void ComputeStartAndEndDateShouldThrowExceptionWhenCycleStartDateFeb29Test()
    {
      _refDate = new DateTime(2013, 09, 30);
      var cycle = new Cycle { StartDay = 29, StartMonth = 2 };
      
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end),
        "StartDay 29 must be a valid day of month");
    }
  }
}
using System;
using MetraTech.TestCommon;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestFixture]
  public class QuarterlyCycleTypeUnitTest
  {
    private DateTime _start;
    private DateTime _end;
    private DateTime _refDate;
    private readonly ICycleType _cycleType = new QuarterlyCycleType();

    [Test]
    public void ComputeStartAndEndDateWhenRefDateEqualToCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 07, 01);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 04, 30), _start);
      Assert.AreEqual(new DateTime(2013, 07, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateADayBeforeCycleStartDateTest()
    {
      _refDate = new DateTime(2013, 07, 30);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 04, 30), _start);
      Assert.AreEqual(new DateTime(2013, 07, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateEqualToCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 10, 30);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 07, 31), _start);
      Assert.AreEqual(new DateTime(2013, 10, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenRefDateADayAfterCycleEndDateTest()
    {
      _refDate = new DateTime(2013, 10, 31);
      var cycle = new Cycle {StartDay = 31, StartMonth = 1};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 10, 31), _start);
      Assert.AreEqual(new DateTime(2014, 01, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateADayBeforeEndDateOfMonthTest()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle {StartDay = 30, StartMonth = 3};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 30), _start);
      Assert.AreEqual(new DateTime(2013, 06, 29), _end);

      _refDate = new DateTime(2013, 11, 01);
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 09, 30), _start);
      Assert.AreEqual(new DateTime(2013, 12, 29), _end);
    }

    [Test]
    public void ComputeStartAndEndDateWhenCycleStartDateEqualToEndDateOfMonthTest()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle {StartDay = 31, StartMonth = 3};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 03, 31), _start);
      Assert.AreEqual(new DateTime(2013, 06, 29), _end);

      _refDate = new DateTime(2013, 11, 01);
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);
      Assert.AreEqual(new DateTime(2013, 09, 30), _start);
      Assert.AreEqual(new DateTime(2013, 12, 30), _end);
    }

    [Test]
    public void ComputeStartAndEndDateFebruaryCaseTest()
    {
      _refDate = new DateTime(2013, 03, 31);
      var cycle = new Cycle {StartDay = 29, StartMonth = 2};
      _cycleType.ComputeStartAndEndDate(_refDate, cycle, out _start, out _end);

      Assert.AreEqual(new DateTime(2013, 02, 28), _start);
      Assert.AreEqual(new DateTime(2013, 05, 28), _end);
    }

    [Test]
    public void ComputeStartAndEndDateShouldThrowExceptionIfCycleIsNull()
    {
      ExceptionAssert.Expected<ArgumentNullException>(
        () => _cycleType.ComputeStartAndEndDate(DateTime.Now, null, out _start, out _end),
        "Value cannot be null.\r\nParameter name: cycle");
    }

    [Test]
    public void ComputeStartAndEndDateShouldThrowExceptionIfCycleStartMonthMissed()
    {
      var cycle = new Cycle {StartDay = 1};
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(DateTime.Now, cycle, out _start, out _end),
        "cycle.StartMonth property must be initialized");
    }

    [Test]
    public void ComputeStartAndEndDateShouldThrowExceptionIfCycleStartDayMissed()
    {
      var cycle = new Cycle {StartMonth = 1};
      
      ExceptionAssert.Expected<ArgumentException>(
        () => _cycleType.ComputeStartAndEndDate(DateTime.Now, cycle, out _start, out _end),
        "cycle.StartDay property must be initialized");
    }

    [Test]
    public void MakeCanonicalWhenMonthIsCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 2 };
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(2, cycle.StartMonth);
    }

    [Test]
    public void MakeCanonicalWhenMonthIsNotCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 11 };
      _cycleType.MakeCanonical(cycle);

      Assert.AreEqual(2, cycle.StartMonth);
    }

    [Test]
    public void IsCanonicalWhenMonthIsNotCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 11 };
      Assert.IsFalse(_cycleType.IsCanonical(cycle));
    }

    [Test]
    public void IsCanonicalWhenMonthIsCanonical()
    {
      var cycle = new Cycle { StartDay = 29, StartMonth = 2 };
      Assert.IsTrue(_cycleType.IsCanonical(cycle));
    }
  }
}
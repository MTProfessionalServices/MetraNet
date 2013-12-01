using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class CycleUnitTest
  {

    [TestMethod, MTUnitTest]
    public void SetFirstDayGreaterThanSecondDayTest()
    {
      var cycle = new Cycle {SecondDayOfMonth = 15};
      ExceptionAssert.Expected<UsageServerException>(() => cycle.FirstDayOfMonth = 16,
        "The first day must be less than the second day");
    }
    
    [TestMethod, MTUnitTest]
    public void SetFirstDayGreaterThanMaxDaysInMonthTest()
    {
      ExceptionAssert.Expected<UsageServerException>(() => new Cycle { FirstDayOfMonth = 32 },
        "First day value 32 must be greater or equal than 1 and less than 31");
    }

    [TestMethod, MTUnitTest]
    public void SetSecondDayLessThanFirstDayTest()
    {
      var cycle = new Cycle { FirstDayOfMonth = 15 };
      ExceptionAssert.Expected<UsageServerException>(() => cycle.SecondDayOfMonth = 14,
        "The second day must be greater than the first day");
    }

    [TestMethod, MTUnitTest]
    public void SetSecondDayGreaterThanMaxDaysInMonthTest()
    {
      ExceptionAssert.Expected<UsageServerException>(() => new Cycle { SecondDayOfMonth = 32 },
        "First day value 32 must be greater or equal than 1 and less than 31");
    }

    [TestMethod, MTUnitTest]
    public void SetStartMonthNegativeTest()
    {
      ExceptionAssert.Expected<UsageServerException>(() => new Cycle { StartMonth = 0 },
        "StartMonth value 0 not a valid month number between 1 and 12");
      ExceptionAssert.Expected<UsageServerException>(() => new Cycle { StartMonth = 15 },
        "StartMonth value 15 not a valid month number between 1 and 12");
    }

    [TestMethod, MTUnitTest]
    public void SetStartDayNegativeTest()
    {
      ExceptionAssert.Expected<UsageServerException>(() => new Cycle { StartDay = 0 },
        "StartDay 0 must be between 1 and 31");
      ExceptionAssert.Expected<UsageServerException>(() => new Cycle { StartDay = 32 },
        "StartDay 32 must be between 1 and 31");
    }

    [TestMethod, MTUnitTest]
    public void SetDayOfYearNegativeTest()
    {
      var cycle = new Cycle();
      ExceptionAssert.Expected<UsageServerException>(() => cycle.DayOfYear = 0,
        "DayOfYear 0 must be between 1 and 365");
      ExceptionAssert.Expected<UsageServerException>(() => cycle.DayOfYear = 366,
        "DayOfYear 366 must be between 1 and 365");
    }
  }
}
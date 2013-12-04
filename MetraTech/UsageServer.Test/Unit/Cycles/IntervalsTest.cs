using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MetraTech.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using FakeItEasy;

namespace MetraTech.UsageServer.Test.Unit.Cycles
{
  [TestClass]
  public class IntervalsTest
  {
    #region Private fields

    private IMTDataReader _fDataReader;
    private IMTAdapterStatement _fAdapterStatement;
    private IMTConnection _fConnection;
    private IBulkInsert _fBulkInsert;
    private ILogger _fLogger;
    private UsageIntervalManager _usageIntervalManager;

    #endregion

    [TestInitialize]
    public void TestInit()
    {
      //Fake connection related interfaces
      _fDataReader = A.Fake<IMTDataReader>();
      A.CallTo(() => _fDataReader.IsDBNull(A<int>.Ignored)).Returns(true);
      A.CallTo(() => _fDataReader.GetInt32(A<int>.Ignored)).ReturnsLazily((int i) => i);
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.IDUsageCycle))).Returns(0);
      
      _fAdapterStatement = A.Fake<IMTAdapterStatement>();
      A.CallTo(() => _fAdapterStatement.ExecuteReader()).Returns(_fDataReader);

      _fConnection = A.Fake<IMTConnection>();
      A.CallTo(() => _fConnection.CreateStatement(A<String>.Ignored)).Returns(_fAdapterStatement);
      A.CallTo(() => _fConnection.CreateAdapterStatement(A<String>.Ignored, A<String>.Ignored))
       .Returns(_fAdapterStatement);
      DbConnectionFactory.SetDbConnection(_fConnection);

      //Fake the DB insert interface
      _fBulkInsert = A.Fake<IBulkInsert>();
      BulkInsertFactory.SetBulkInsert(_fBulkInsert);
      
      _fLogger = A.Fake<ILogger>();
      _usageIntervalManager = new UsageIntervalManager(_fLogger);
    }

    #region Tests

    [TestMethod]
    public void CreateReferenceCycles_PeriodTooShort_ShouldReturnZeroIntervalsTest()
    {
      SetNumberOfFakedReadOperations(2);
      SetBiweeklyCycleFake(2, 1, 2000);
      var startDate = new DateTime(2000, 1, 1);
      var endDate = new DateTime(2000, 1, 2);
      var producedIntervals = _usageIntervalManager.CreateReferenceIntervals(startDate, endDate);
      Assert.AreEqual(0, producedIntervals.Count);
    }

    [TestMethod]
    public void CreateReferenceCycles_PeriodEndDateLessThanStartDate_ShouldReturnZeroIntervals()
    {
      SetNumberOfFakedReadOperations(2);
      SetAnnualCycleFake(31, 3);
      var startDate = new DateTime(2001, 1, 1);
      var endDate = new DateTime(2000, 1, 3);
      var producedIntervals = _usageIntervalManager.CreateReferenceIntervals(startDate, endDate);
      Assert.AreEqual(0, producedIntervals.Count);
    }

    [TestMethod]
    public void CreateReferenceCycles_NoCyclesInDatabase_ShouldReturnZeroIntervals()
    {
      SetNumberOfFakedReadOperations(1);
      SetAnnualCycleFake(31, 3);
      var startDate = new DateTime(1999, 3, 31);
      var endDate = new DateTime(2001, 3, 31);
      var producedIntervals = _usageIntervalManager.CreateReferenceIntervals(startDate, endDate);
      Assert.AreEqual(0, producedIntervals.Count);
    }

    [TestMethod]
    public void CreateReferenceCycles_BiWeeklyCycleType_ShouldReturnOneIntervalTest()
    {
      SetNumberOfFakedReadOperations(2);
      SetBiweeklyCycleFake(2, 1, 2000);
      var startDate = new DateTime(2000, 1, 1);
      var endDate = new DateTime(2000, 1, 3);
      var producedIntervals = _usageIntervalManager.CreateReferenceIntervals(startDate, endDate);
      var expectedIntervals = new List<UsageInterval>
        {
          new UsageInterval(0)
            {
              CycleType = CycleType.BiWeekly,
              StartDate = new DateTime(2000, 1, 2),
              EndDate = new DateTime(2000, 1, 15, 23, 59, 59)
            }
        };
      CompareIntervals(expectedIntervals, producedIntervals);
    }

    [TestMethod]
    public void CreateReferenceCycles_PeriodLengthGreaterThanCycleLength_ShouldReturn2AnnualIntervals()
    {
      SetNumberOfFakedReadOperations(2);
      SetAnnualCycleFake(31, 3);
      var startDate = new DateTime(1999, 3, 31);
      var endDate = new DateTime(2001, 3, 31);
      var producedIntervals = _usageIntervalManager.CreateReferenceIntervals(startDate, endDate);
      var expectedIntervals = new List<UsageInterval>
        {
          new UsageInterval(0)
            {
              CycleType = CycleType.Annual,
              StartDate = new DateTime(1999, 3, 31),
              EndDate = new DateTime(2000, 3, 30, 23, 59, 59)
            },
          new UsageInterval(0)
            {
              CycleType = CycleType.Annual,
              StartDate = new DateTime(2000, 3, 31),
              EndDate = new DateTime(2001, 3, 30, 23, 59, 59)
            }
        };
      CompareIntervals(expectedIntervals, producedIntervals);
    }

    #endregion
    
    #region Private methods

    private void SetNumberOfFakedReadOperations(int i)
    {
      A.CallTo(() => _fDataReader.Read()).Returns(true).NumberOfTimes(i);
    }

    // 1	MTStdMonthly.MTStdMonthly.1							Monthly
    // 2	MTStdOnDemand.MTStdOnDemand.1						On-demand
    // 3	MTStdUsageCycle.MTStdDaily.1						Daily
    // 4	MTStdUsageCycle.MTStdWeekly.1						Weekly
    // 5	MTStdUsageCycle.MTStdBiWeekly.1					Bi-weekly
    // 6	MTStdUsageCycle.MTStdSemiMonthly.1			Semi-monthly
    // 7	MTStdUsageCycle.MTStdQuarterly.1				Quarterly
    // 8	MTStdUsageCycle.MTStdAnnually.1					Annually
    // 9	MTStdUsageCycle.MTStdSemiAnnually.1			SemiAnnually
    private void SetBiweeklyCycleFake(int startDay, int startMonth, int startYear)
    {
      // Specifies the type of cycle usage intervals are going to be created for
      // 5 means bi-weekly
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.IDCycleType))).Returns(5);
      // Specifies a cycle usage intervals are going to be created for
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.StartDay))).Returns(startDay);
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.StartMonth)))
       .Returns(startMonth);
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.StartYear))).Returns(startYear);
    }

    private void SetAnnualCycleFake(int startDay, int startMonth)
    {
      // Specifies the type of cycle usage intervals are going to be created for
      // 5 means bi-weekly
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.IDCycleType))).Returns(8);
      // Specifies a cycle usage intervals are going to be created for
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.StartDay))).Returns(startDay);
      A.CallTo(() => _fDataReader.GetInt32(A<int>.That.IsEqualTo((int) CycleQueryColumns.StartMonth)))
       .Returns(startMonth);
    }

    private class UsageIntervalComparer : IComparer
    {
      public int Compare(object x, object y)
      {
        var interval1 = (UsageInterval) x;
        var interval2 = (UsageInterval) y;

        if (interval1.StartDate == interval2.StartDate && interval1.EndDate == interval2.EndDate &&
            interval1.CycleType == interval2.CycleType)
          return 0;
        
        return -1;
      }
    }

    private static void CompareIntervals(IEnumerable<UsageInterval> expectedIntervals,
                                         IEnumerable<UsageInterval> producedIntervals)
    {
      CollectionAssert.AreEqual(expectedIntervals.OrderBy(i => i.StartDate).ToList(),
                                producedIntervals.OrderBy(i => i.StartDate).ToList(),
                                new UsageIntervalComparer());
    }

    #endregion
  }
}

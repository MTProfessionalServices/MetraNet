using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using RevRecModel = MetraTech.DomainModel.ProductCatalog.RevenueRecognitionReportDefinition;

namespace MetraNet
{
  ///<summary>
  /// Contains a set of methods reports may use to get data.
  ///</summary>
  public static class ReportingtHelper
  {
    private const string sqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCustom\Queries\UI\Dashboard";
    private static string[] _currencies;

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public static string[] GetCurrencies()
    {
      if (_currencies != null) return _currencies;

      var charges = GetEarnedRevenue(GetCycleStartDate(null), String.Empty, String.Empty, String.Empty, null)
                    .Concat(GetDeferredRevenue(GetCycleEndDate(null), String.Empty, String.Empty, String.Empty, null));
      return _currencies = charges.Select(x => x.Currency).Distinct().ToArray();
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public static IEnumerable<AccountingCycle> GetAccountingCycles()
    {
      return GetData<AccountingCycle>("__GET_ACCOUNTING_CYCLE_FILTER__", null);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public static IEnumerable<KeyValuePair<int, string>> GetProducts()
    {
      return GetData<KeyValuePair<Int32, string>>("__GET_PRODUCTS_FILTER__", null);
    }

    /// <summary>
    /// Returns collection of earned charges.
    /// </summary>
    /// <param name="startDate">The date we a looking data from.</param>
    /// <param name="currency"></param>
    /// <param name="revenueCode"></param>
    /// <param name="deferredRevenueCode"></param>
    /// <param name="productId"></param>
    /// <returns></returns>
    public static IEnumerable<SegregatedCharges> GetEarnedRevenue(DateTime startDate, string currency, string revenueCode, string deferredRevenueCode, int? productId)
    {
      var paramDict = new Dictionary<string, object>
        {
          {"%%START_DATE%%", startDate},
          {"%%CURRENCY%%", currency}, 
          {"%%REVENUECODE%%", revenueCode}, 
          {"%%DEFREVENUECODE%%", deferredRevenueCode},
          {"%%PRODUCTID%%", productId}
        };

      return GetData<SegregatedCharges>("__GET_EARNED_REVENUE__", paramDict);
    }

    /// <summary>
    /// Returns collection of deferred charges.
    /// </summary>
    /// <param name="endDate">The date we a looking data up to.</param>
    /// <param name="currency"></param>
    /// <param name="revenueCode"></param>
    /// <param name="deferredRevenueCode"></param>
    /// <param name="productId"></param>
    /// <returns></returns>
    public static IEnumerable<SegregatedCharges> GetDeferredRevenue(DateTime endDate, string currency, string revenueCode, string deferredRevenueCode, int? productId)
    {
      var paramDict = new Dictionary<string, object>
        {
          {"%%END_DATE%%", endDate},
          {"%%CURRENCY%%", currency},
          {"%%REVENUECODE%%", revenueCode}, 
          {"%%DEFREVENUECODE%%", deferredRevenueCode},
          {"%%PRODUCTID%%", productId}
        };

      return GetData<SegregatedCharges>("__GET_DEFERRED_REVENUE__", paramDict);
    }

    /// <summary>
    /// Returns collection of deferred charges.
    /// </summary>
    /// <param name="startDate">The date we a looking data from.</param>
    /// <param name="endDate">The date we a looking data up to.</param>
    /// <param name="currency"></param>
    /// <param name="revenueCode"></param>
    /// <param name="deferredRevenueCode"></param>
    /// <param name="productId"></param>
    /// <returns></returns>
    public static IEnumerable<SegregatedCharges> GetIncrementalEarnedRevenue(DateTime startDate, DateTime endDate, string currency, string revenueCode, string deferredRevenueCode, int? productId)
    {
      var paramDict = new Dictionary<string, object>
        {
          {"%%START_DATE%%", startDate},
          {"%%END_DATE%%", endDate},
          {"%%CURRENCY%%", currency},
          {"%%REVENUECODE%%", revenueCode}, 
          {"%%DEFREVENUECODE%%", deferredRevenueCode},
          {"%%PRODUCTID%%", productId}
        };

      return GetData<SegregatedCharges>("__GET_INCREMENTAL_EARNED_REVENUE__", paramDict);
    }

    /// <summary>
    /// Figure out the start date of an accounting cycle.
    /// </summary>
    /// <param name="cycle"></param>
    /// <returns></returns>
    public static DateTime GetCycleStartDate(AccountingCycle cycle)
    {
      var result = new DateTime(DateTime.Today.AddMonths(-2).Year, DateTime.Today.AddMonths(-2).Month, DateTime.DaysInMonth(DateTime.Today.AddMonths(-2).Year, DateTime.Today.AddMonths(-2).Month));
      if (cycle != null && cycle.EndDate.Day < result.Day)
        result = new DateTime(result.Year, result.Month, cycle.EndDate.Day);
      return result.AddDays(1);
    }

    /// <summary>
    /// Figure out the end date of an accounting cycle.
    /// </summary>
    /// <param name="cycle"></param>
    /// <returns></returns>
    public static DateTime GetCycleEndDate(AccountingCycle cycle)
    {
      var result = new DateTime(DateTime.Today.AddMonths(-1).Year, DateTime.Today.AddMonths(-1).Month, DateTime.DaysInMonth(DateTime.Today.AddMonths(-1).Year, DateTime.Today.AddMonths(-1).Month), 23, 59, 59);
      if (cycle != null && cycle.EndDate.Day < result.Day)
        result = new DateTime(result.Year, result.Month, cycle.EndDate.Day, 23, 59, 59);
      return result;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="currency">Currency code</param>
    /// <param name="revenueCode">Revenue code</param>
    /// <param name="deferredRevenueCode">Deferred revenue code</param>
    /// <param name="productId">Product ID</param>
    /// <param name="idRevRec">Start ID for add it into MTFilterGrid</param>
    /// <returns></returns>
    public static List<RevRecModel> GetRevRec(string currency, string revenueCode, string deferredRevenueCode, int? productId, int idRevRec)
    {
      var accountingCycle = GetAccountingCycles().SingleOrDefault(x => x.IsDefault);
      if (accountingCycle != null)
        accountingCycle = GetAccountingCycles().FirstOrDefault();
      var data = new List<RevRecModel>();
      var revRecData = GetRevRecRawData(accountingCycle, currency, revenueCode, deferredRevenueCode)
                       .Select(x => x.GetRoundRevRecModel())
                       .ToList();
      revRecData.ForEach(x => { x.Id = ++idRevRec; data.Add(x); });

      return data;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="accountingCycle"></param>
    /// <param name="currency">Currency code</param>
    /// <param name="revenueCode">Revenue code</param>
    /// <param name="deferredRevenueCode">Deferred revenue code</param>
    /// <returns></returns>
    public static List<RevenueRecognitionReportData> GetRevRecRawData(AccountingCycle accountingCycle, string currency, string revenueCode, string deferredRevenueCode)
    {
      var startDate = GetCycleStartDate(accountingCycle);
      var endDate = GetCycleEndDate(accountingCycle);

      var incremental = GetIncrementalEarnedRevenue(startDate, endDate, currency, revenueCode, deferredRevenueCode, productId).ToList();
      var deferred = GetDeferredRevenue(endDate, currency, revenueCode, deferredRevenueCode, productId).ToList();
      var earned = GetEarnedRevenue(startDate, currency, revenueCode, deferredRevenueCode, productId).ToList();

      var groups =
        earned.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode })
              .Concat(incremental.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode }))
              .Concat(deferred.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode }))
              .Distinct().OrderBy(x => x.Currency).ThenBy(x => x.RevenueCode).ThenBy(x => x.DeferredRevenueCode).ToList();

      var data = new List<RevenueRecognitionReportData>();

      foreach (var rowGroup in groups)
      {
        var decimalTotalEarned = new Dictionary<int, double>();
        var decimalIncrementalEarned = new Dictionary<int, double>();
        var decimalDeferred = new Dictionary<int, double>();

        var calculatedDeferred = deferred.Where(x => x.Currency.Equals(rowGroup.Currency)
                                                       && x.RevenueCode.Equals(rowGroup.RevenueCode)
                                                       && x.DeferredRevenueCode.Equals(rowGroup.DeferredRevenueCode))
                                           .Select(x => x.ProrationDate * x.ProrationAmount).Sum();

        var calculatedIncrementalEarned = incremental.Where(x => x.Currency.Equals(rowGroup.Currency)
                                                       && x.RevenueCode.Equals(rowGroup.RevenueCode)
                                                       && x.DeferredRevenueCode.Equals(rowGroup.DeferredRevenueCode))
                                           .Select(x => x.ProrationDate * x.ProrationAmount).Sum();

        var calculatedTotalEarned = earned.Where(x => x.Currency.Equals(rowGroup.Currency)
                                                       && x.RevenueCode.Equals(rowGroup.RevenueCode)
                                                       && x.DeferredRevenueCode.Equals(rowGroup.DeferredRevenueCode))
                                           .Select(x => x.ProrationDate * x.ProrationAmount).Sum() + calculatedIncrementalEarned;


        decimalTotalEarned.Add(1, (double)calculatedTotalEarned);
        decimalIncrementalEarned.Add(1, (double)calculatedIncrementalEarned);
        decimalDeferred.Add(1, (double)calculatedDeferred);

        for (var i = 1; i < 13; i++)
        {
          var monthNext = endDate.AddMonths(i).AddDays(-1);
          var calculatedDeferredPrev = calculatedDeferred;

          calculatedDeferred = deferred.Where(x => x.Currency.Equals(rowGroup.Currency)
                                                   && x.RevenueCode.Equals(rowGroup.RevenueCode)
                                                   && x.DeferredRevenueCode.Equals(rowGroup.DeferredRevenueCode)
                                                   && x.EndSubscriptionDate > monthNext)
                                       .Select(x => new
                                       {
                                         sum1 =
                                                    (x.EndSubscriptionDate > monthNext &&
                                                     x.StartSubscriptionDate > monthNext)
                                                      ? (x.EndSubscriptionDate - x.StartSubscriptionDate).Days *
                                                        x.ProrationAmount
                                                      : 0,
                                         sum2 =
                                                    (x.EndSubscriptionDate > monthNext &&
                                                     x.StartSubscriptionDate < monthNext)
                                                      ? (x.EndSubscriptionDate - monthNext).Days * x.ProrationAmount
                                                      : 0
                                       }
            ).Sum(x => x.sum1 + x.sum2);

          calculatedIncrementalEarned = calculatedDeferredPrev - calculatedDeferred;

          calculatedTotalEarned = calculatedTotalEarned + calculatedIncrementalEarned;

          decimalIncrementalEarned.Add(i+1, (double)calculatedIncrementalEarned);
          decimalDeferred.Add(i+1, (double)calculatedDeferred);
          decimalTotalEarned.Add(i+1, (double)calculatedTotalEarned);
        }
        var earnedRow = new RevenueRecognitionReportData
        {
          Currency = rowGroup.Currency,
          RevenueCode = rowGroup.RevenueCode,
          DeferredRevenueCode = rowGroup.DeferredRevenueCode,
          RevenuePart = "Earned",
          ColumnsData = decimalTotalEarned
        };

        var incrementalRow = new RevenueRecognitionReportData
        {
          RevenuePart = "Incremental",
          ColumnsData = decimalIncrementalEarned
        };

        var deferredRow = new RevenueRecognitionReportData
        {
          RevenuePart = "Deferred",
          ColumnsData = decimalDeferred
        };

        data.Add(earnedRow);
        data.Add(incrementalRow);
        data.Add(deferredRow);
      }
      return data;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="accountingCycleId"></param>
    /// <returns></returns>
    public static string[] GetRevRecReportHeaders(string accountingCycleId)
    {
      var accCycle = GetAccountingCycles().SingleOrDefault(x => x.Id.Equals(Guid.Parse(accountingCycleId)));
      var endDate = GetCycleEndDate(accCycle);
      var accEndDate = accCycle == null ? endDate : accCycle.EndDate;
      var isEndOfMonth = accEndDate.Day == DateTime.DaysInMonth(accEndDate.Year, accEndDate.Month);
      var headers = new string[13];
      for (var i = 0; i < headers.Length; i++)
      {
        headers[i] = (isEndOfMonth ? endDate.AddMonths(i).GetLastDayMonth() : endDate.AddMonths(i)).ToString("d MMM yyyy", Thread.CurrentThread.CurrentUICulture);
      }
      return headers;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="date"></param>
    /// <returns></returns>
    public static bool IsLastDayMonth(this DateTime date)
    {
      return date.Day == DateTime.DaysInMonth(date.Year, date.Month);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="date"></param>
    /// <returns></returns>
    public static DateTime GetLastDayMonth(this DateTime date)
    {
      return date.Day == DateTime.DaysInMonth(date.Year, date.Month) ? date
                         : new DateTime(date.Year, date.Month, DateTime.DaysInMonth(date.Year, date.Month), date.Hour, date.Minute, date.Second, date.Millisecond);
    }

    private static IEnumerable<T> GetData<T>(string sqlQueryTag, Dictionary<string, object> paramDict)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateAdapterStatement(sqlQueriesPath, sqlQueryTag))
        {
          if (paramDict != null)
          {
            foreach (var pair in paramDict)
            {
              stmt.AddParam(pair.Key, pair.Value);
            }
          }

          using (var reader = stmt.ExecuteReader())
          {
            var typeName = typeof(T).ToString();
            Object result;
            switch (typeName)
            {
              case "MetraNet.SegregatedCharges":
                result = ExtractSegregatedCharges(reader);
                break;
              case "MetraNet.AccountingCycle":
                result = ExtractAccountingCycles(reader);
                break;
              case "System.Collections.Generic.KeyValuePair`2[System.Int32,System.String]":
                result = ExtractProduts(reader);
                break;
              default:
                result = null;
                break;
            }
            return result as IEnumerable<T>;
          }
        }
      }
    }

    private static IEnumerable<KeyValuePair<Int32, string>> ExtractProduts(IMTDataReader rdr)
    {
      var res = new List<KeyValuePair<Int32, string>>();

      while (rdr.Read())
      {
        res.Add(new KeyValuePair<int, string>(rdr.GetInt32("id_pi_template"), rdr.GetString("nm_name")));
      }

      return res;
    }

    private static IEnumerable<SegregatedCharges> ExtractSegregatedCharges(IMTDataReader rdr)
    {
      var res = new List<SegregatedCharges>();

      while (rdr.Read())
      {
        var sch = new SegregatedCharges
        {
          Currency = rdr.GetString("am_currency"),
          RevenueCode = !rdr.IsDBNull("c_RevenueCode") ? rdr.GetString("c_RevenueCode") : "",
          DeferredRevenueCode = !rdr.IsDBNull("c_DeferredRevenueCode") ? rdr.GetString("c_DeferredRevenueCode") : "",
          StartSubscriptionDate = rdr.GetDateTime("SubscriptionStart"),
          EndSubscriptionDate = rdr.GetDateTime("SubscriptionEnd"),
          ProrationDate = rdr.GetInt32("c_ProratedDays"),
          ProrationAmount = rdr.GetDecimal("c_ProratedDailyRate")
        };

        res.Add(sch);
      }

      return res;
    }

    private static IEnumerable<AccountingCycle> ExtractAccountingCycles(IMTDataReader rdr)
    {
      var res = new List<AccountingCycle>();

      while (rdr.Read())
      {
        var accCycle = new AccountingCycle
          {
            Id = rdr.GetGuid("c_AccountingCycle_Id"),
            EndDate = rdr.GetDateTime("c_Day"),
            Name = rdr.GetString("c_Name"),
            CycleType = (UsageCycleType)rdr.GetInt32("c_Cycle"),
            IsDefault = rdr.GetString("c_IsDefault").ToUpper() == "T"
          };
        res.Add(accCycle);
      }

      return res;
    }
  }

  /// <summary>
  /// 
  /// </summary>
  public class SegregatedCharges
  {
    public string Currency { get; set; }
    public DateTime StartSubscriptionDate { get; set; }
    public DateTime EndSubscriptionDate { get; set; }
    public string RevenueCode { get; set; }
    public string DeferredRevenueCode { get; set; }
    public int ProrationDate { get; set; }
    public decimal ProrationAmount { get; set; }
  }

  /// <summary>
  /// A value object which reflects BME AccountingCycle.
  /// </summary>
  public class AccountingCycle
  {
    // Record Id.
    public Guid Id { get; set; }

    // Date to represent the end day of a cycle.
    public DateTime EndDate { get; set; }

    // The name of a cycle.
    public string Name { get; set; }

    // The type of a cycle.
    public UsageCycleType CycleType { get; set; }

    // Identifies the cycle as default.
    public bool IsDefault { get; set; }
  }

  public class RevenueRecognitionReportData
  {
    public string Currency { get; set; }

    public Int32 ProductId { get; set; }

    public string RevenueCode { get; set; }

    public string DeferredRevenueCode { get; set; }

    public string RevenuePart { get; set; }

    /// <summary>
    /// Amonts by columns:
    ///    Key - column's Id.
    ///    Value - amount.
    /// </summary>
    public IDictionary<int, double> ColumnsData { get; set; }

    public RevRecModel GetRoundRevRecModel()
    {
      return new RevRecModel
        {
          Currency = Currency,
          RevenueCode = RevenueCode,
          DeferredRevenueCode = DeferredRevenueCode,
          RevenuePart = RevenuePart,
          Amount1 = ColumnsData.ContainsKey(1) ? ColumnsData[1].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount2 = ColumnsData.ContainsKey(2) ? ColumnsData[2].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount3 = ColumnsData.ContainsKey(3) ? ColumnsData[3].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount4 = ColumnsData.ContainsKey(4) ? ColumnsData[4].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount5 = ColumnsData.ContainsKey(5) ? ColumnsData[5].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount6 = ColumnsData.ContainsKey(6) ? ColumnsData[6].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount7 = ColumnsData.ContainsKey(7) ? ColumnsData[7].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount8 = ColumnsData.ContainsKey(8) ? ColumnsData[8].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount9 = ColumnsData.ContainsKey(9) ? ColumnsData[9].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount10 = ColumnsData.ContainsKey(10) ? ColumnsData[10].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount11 = ColumnsData.ContainsKey(11) ? ColumnsData[11].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount12 = ColumnsData.ContainsKey(12) ? ColumnsData[12].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty,
          Amount13 = ColumnsData.ContainsKey(13) ? ColumnsData[13].ToString("N2", Thread.CurrentThread.CurrentUICulture) : String.Empty
        };
    }
  }

}

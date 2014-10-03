﻿using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.DataAccess;
using RevRecModel = MetraTech.DomainModel.ProductCatalog.RevenueRecognitionReportDefinition;
using System.Globalization;

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
    public static IDictionary<string, string> GetAccountingCycles()
    {
      return GetData<KeyValuePair<string, string>>("__GET_ACCOUNTING_CYCLE_FILTER__", null).ToDictionary(x => x.Key, x => x.Value);
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
      return new DateTime(DateTime.Today.AddMonths(-1).Year, DateTime.Today.AddMonths(-1).Month, cycle != null ? cycle.CycleEndDate.Day + 1 : 1);
    }

    /// <summary>
    /// Figure out the end date of an accounting cycle.
    /// </summary>
    /// <param name="cycle"></param>
    /// <returns></returns>
    public static DateTime GetCycleEndDate(AccountingCycle cycle)
    {
      return new DateTime(DateTime.Today.Year, DateTime.Today.Month, cycle != null ? cycle.CycleEndDate.Day : 1);
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
      var startDate = GetCycleStartDate(null);
      var endDate = GetCycleEndDate(null);

      var incremental = GetIncrementalEarnedRevenue(startDate, endDate, currency, revenueCode, deferredRevenueCode, productId).ToList();
      var deferred = GetDeferredRevenue(endDate, currency, revenueCode, deferredRevenueCode, productId).ToList();
      var earned = GetEarnedRevenue(startDate, currency, revenueCode, deferredRevenueCode, productId).ToList();

      var groups =
        earned.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode })
              .Concat(incremental.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode }))
              .Concat(deferred.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode }))
              .Distinct().OrderBy(x => x.Currency).ThenBy(x => x.RevenueCode).ThenBy(x => x.DeferredRevenueCode).ToList();

      var data = new List<RevRecModel>();

      foreach (var rowGroup in groups)
      {
        var earnedRow = new RevRecModel
        {
          Id = ++idRevRec,
          Currency = rowGroup.Currency,
          RevenueCode = rowGroup.RevenueCode,
          DeferredRevenueCode = rowGroup.DeferredRevenueCode,
          RevenuePart = "Earned"
        };

        var incrementalRow = new RevRecModel
        {
          Id = ++idRevRec,
          RevenuePart = "Incremental"
        };

        var deferredRow = new RevRecModel
        {
          Id = ++idRevRec,
          RevenuePart = "Deferred"
        };

        var decimalTotalEarned = new Dictionary<string, double>();
        var decimalIncrementalEarned = new Dictionary<string, double>();
        var decimalDeferred = new Dictionary<string, double>();

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


        decimalTotalEarned.Add("1", (double)calculatedTotalEarned);
        decimalIncrementalEarned.Add("1", (double)calculatedIncrementalEarned);
        decimalDeferred.Add("1", (double)calculatedDeferred);

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

          var key = (i + 1).ToString(CultureInfo.InvariantCulture);
          decimalIncrementalEarned.Add(key, (double)calculatedIncrementalEarned);
          decimalDeferred.Add(key, (double)calculatedDeferred);
          decimalTotalEarned.Add(key, (double)calculatedTotalEarned);
        }

        RoundRevRecModel(earnedRow, decimalTotalEarned);
        RoundRevRecModel(incrementalRow, decimalIncrementalEarned);
        RoundRevRecModel(deferredRow, decimalDeferred);

        data.Add(earnedRow);
        data.Add(incrementalRow);
        data.Add(deferredRow);
      }

      return data;
    }

    private static void RoundRevRecModel(RevRecModel revRecModel, Dictionary<string, double> calculations)
    {
      revRecModel.Amount1 = calculations["1"].ToString("N2");
      revRecModel.Amount2 = calculations["2"].ToString("N2");
      revRecModel.Amount3 = calculations["3"].ToString("N2");
      revRecModel.Amount4 = calculations["4"].ToString("N2");
      revRecModel.Amount5 = calculations["5"].ToString("N2");
      revRecModel.Amount6 = calculations["6"].ToString("N2");
      revRecModel.Amount7 = calculations["7"].ToString("N2");
      revRecModel.Amount8 = calculations["8"].ToString("N2");
      revRecModel.Amount9 = calculations["9"].ToString("N2");
      revRecModel.Amount10 = calculations["10"].ToString("N2");
      revRecModel.Amount11 = calculations["11"].ToString("N2");
      revRecModel.Amount12 = calculations["12"].ToString("N2");
      revRecModel.Amount13 = calculations["13"].ToString("N2");
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
              case "System.Collections.Generic.KeyValuePair`2[System.String,System.String]":
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

    private static IEnumerable<KeyValuePair<string, string>> ExtractAccountingCycles(IMTDataReader rdr)
    {
      var res = new Dictionary<string, string>();

      while (rdr.Read())
      {
        res.Add(rdr.GetGuid("c_AccountingCycle_Id").ToString(), rdr.GetString("c_Name"));
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
    public Guid AccountingCycleId { get; set; }

    // Date to represent the end day of a cycle.
    public DateTime CycleEndDate { get; set; }
  }
}

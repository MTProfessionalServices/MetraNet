using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.DataAccess;
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

      var paramDictEarned = new Dictionary<string, object>
        {
          {"%%START_DATE%%", new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)},
          {"%%CURRENCY%%", ""}, 
          {"%%REVENUECODE%%", ""}, 
          {"%%DEFREVENUECODE%%", ""}
        };

      var earned = GetData<SegregatedCharges>("__GET_EARNED_REVENUE__", paramDictEarned);
      return _currencies = earned.Select(x => x.Currency).Distinct().ToArray();
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
    /// <returns></returns>
    public static IEnumerable<SegregatedCharges> GetEarnedRevenue(DateTime startDate, string currency, string revenueCode, string deferredRevenueCode)
    {
      var paramDict = new Dictionary<string, object>
        {
          {"%%START_DATE%%", startDate},
          {"%%CURRENCY%%", currency}, 
          {"%%REVENUECODE%%", revenueCode}, 
          {"%%DEFREVENUECODE%%", deferredRevenueCode}
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
    /// <returns></returns>
    public static IEnumerable<SegregatedCharges> GetDeferredRevenue(DateTime endDate, string currency, string revenueCode, string deferredRevenueCode)
    {
      var paramDict = new Dictionary<string, object>
        {
          {"%%END_DATE%%", endDate},
          {"%%CURRENCY%%", currency},
          {"%%REVENUECODE%%", revenueCode}, 
          {"%%DEFREVENUECODE%%", deferredRevenueCode}
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
    /// <returns></returns>
    public static IEnumerable<SegregatedCharges> GetIncrementalEarnedRevenue(DateTime startDate, DateTime endDate, string currency, string revenueCode, string deferredRevenueCode)
    {
      var paramDict = new Dictionary<string, object>
        {
          {"%%START_DATE%%", startDate},
          {"%%END_DATE%%", endDate},
          {"%%CURRENCY%%", currency},
          {"%%REVENUECODE%%", revenueCode}, 
          {"%%DEFREVENUECODE%%", deferredRevenueCode}
        };

      return GetData<SegregatedCharges>("__GET_INCREMENTAL_EARNED_REVENUE__", paramDict);
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
        res.Add(new KeyValuePair<int, string>(rdr.GetInt32("id_pi"), rdr.GetString("nm_name")));
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
}

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using MetraNet;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.UI.Common;
using RevRecModel = MetraTech.DomainModel.ProductCatalog.RevenueRecognitionReportDefinition;

public partial class AjaxServices_LoadRevenueRecognitionData : MTListServicePage
{
    private const string sqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCustom\Queries\UI\Dashboard";
    private static int idRevRec;

    protected void Page_Load(object sender, EventArgs e)
    {
      var items = new MTList<RevRecModel> {TotalRows = 100, PageSize = 100, CurrentPage = 1};
      SetFilters(items);
      var revRec = GetRevRec(items);
      items.Items.AddRange(revRec);

      //convert adjustments into JSON
      var jss = new JavaScriptSerializer();
      var json = jss.Serialize(items);
      json = FixJsonDate(json);
      json = FixJsonBigInt(json);
      Response.Write(json);
    }

    public List<RevRecModel> GetRevRec(MTList<RevRecModel> items)
    {
      var now = DateTime.Now;
      var startDate = new DateTime(now.Year, now.Month - 1, 1);
      var endDate = new DateTime(now.Year, now.Month, 1);

      var currencyLINQ = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "Currency");
      var currency = currencyLINQ == null ? "" : currencyLINQ.Value;

      var incremental = ReportingtHelper.GetIncrementalEarnedRevenue(startDate, endDate, currency).ToList();
      var deferred = ReportingtHelper.GetDeferredRevenue(endDate, currency).ToList();
      var earned = ReportingtHelper.GetEarnedRevenue(startDate, currency).ToList();

      var groups =
        earned.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode })
              .Concat(incremental.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode }))
              .Concat(deferred.Select(x => new { x.Currency, x.RevenueCode, x.DeferredRevenueCode }))
              .Distinct()
              .ToList();

      var data = new List<RevRecModel>();

      foreach (var rowGroup in groups)
      {
        var earnedRow = new RevRecModel
        {
          Id = idRevRec,
          Currency = rowGroup.Currency,
          RevenueCode = rowGroup.RevenueCode,
          DeferredRevenueCode = rowGroup.DeferredRevenueCode,
          RevenuePart = "Earned"
        };

        var incrementalRow = new RevRecModel
        {
          Id = ++idRevRec,
          Currency = rowGroup.Currency,
          RevenueCode = rowGroup.RevenueCode,
          DeferredRevenueCode = rowGroup.DeferredRevenueCode,
          RevenuePart = "Incremental"
        };

        var deferredRow = new RevRecModel
        {
          Id = ++idRevRec,
          Currency = rowGroup.Currency,
          RevenueCode = rowGroup.RevenueCode,
          DeferredRevenueCode = rowGroup.DeferredRevenueCode,
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
                                           .Select(x => (x.EndSubscriptionDate - monthNext).Days * x.ProrationAmount).Sum();

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

    private static List<SegregatedCharges> GetData(string sqlQueryTag, Dictionary<string, object> paramDict)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(sqlQueriesPath, sqlQueryTag))
        {
          if (paramDict != null)
          {
            foreach (var pair in paramDict)
            {
              stmt.AddParam(pair.Key, pair.Value);
            }
          }

          using (IMTDataReader reader = stmt.ExecuteReader())
          {

            return ConstructItems(reader);
            // get the total rows that would be returned without paging
          }
        }
      }
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

    protected static List<SegregatedCharges> ConstructItems(IMTDataReader rdr)
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
}

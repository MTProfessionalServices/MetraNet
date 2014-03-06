using System.Data.Common;
using System.Data.SqlClient;
using System.Web.Mvc;
using MetraNet.DbContext;
using System.Linq;
using System.Collections.Generic;
using System;

namespace ASP.Controllers
{
  [Authorize]
  public class ReportController : MTController
  {
    public JsonResult NewCustomers()
    {
      Title = "New Customers Report";
      var obj = GetTerritoryCodes();

      return Json(obj);
    }

    public JsonResult MRRByProduct()
    {
      Title = "Monthly Recurring Revenue By Product Report";

      var monthsArr = new string[12];
      var lastMonth = (new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)).AddMonths(-1);

      for (int i = 0; i <= 11; i++)
        monthsArr[11 - i] = lastMonth.AddMonths(-i).ToString("MMM yy");

      ViewBag.GridMonthsArr = monthsArr;

      ViewBag.ProductsList = GetProductCodes();
      ViewBag.TerritoryList = GetTerritoryCodes();

      return Json("");
    }

    private IEnumerable<SelectListItem> GetProductCodes()
    {
      var list = new List<SelectListItem>();
      list.Add(new SelectListItem() { Selected = true, Text = "All", Value = "all" });

      using (var dbContext = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
      {
        var products =
          (from subByMonth in dbContext.SubscriptionsByMonth
           join sub in dbContext.SubscriptionTable on subByMonth.SubscriptionId equals sub.SubscriptionId
           where
             subByMonth.Month.HasValue &&
             subByMonth.Month >= DateTime.Today.AddMonths(-13) &&
             subByMonth.Month <= DateTime.Now
           select sub.ProductCode).Distinct().OrderBy(x => x).ToList();

        list.AddRange(products.Select(productCode => new SelectListItem() { Text = productCode, Value = productCode }));
      }
      return list;
    }

    private IEnumerable<SelectListItem> GetTerritoryCodes()
    {
      var list = new List<SelectListItem> { new SelectListItem() { Selected = true, Text = "All", Value = "all" } };

      using (var dbContext = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
      {
        var codes =
          (from st in dbContext.SubscriptionTable
           join c in dbContext.Customer on st.AccountId equals c.AccountId
           where
             st.StartDate.HasValue &&
             st.StartDate.Value >= DateTime.Today.AddMonths(-13) &&
             st.StartDate.Value <= DateTime.Now
           select c.Territorycode).Distinct().OrderBy(x => x).ToList();

        list.AddRange(codes.Select(code => new SelectListItem() { Text = code, Value = code }));
      }
      return list;
    }

    private static DbConnection GetDefaultDatabaseConnectionSubscriptiondatamart()
    {
      //var connectionInfo = new ConnectionInfo("NetMeter"){ Catalog = "Subscriptiondatamart" };
      //return ConnectionBase.GetDbConnection(connectionInfo, false);
      var connString = new SqlConnectionStringBuilder
      {
        DataSource = "localhost",
        InitialCatalog = "Subscriptiondatamart",
        UserID = "nmdbo",
        Password = "MetraTech1"
      };
      return new SqlConnection(connString.ToString());
    }

    /*public ActionResult Churn()
    {
      Title = "Churn Report";

      var monthsArr = new string[12];
      var lastMonth = (new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)).AddMonths(-1);

      for (int i = 0; i <= 11; i++)
        monthsArr[11 - i] = lastMonth.AddMonths(-i).ToString("MMM yy");

      ViewBag.GridMonthsArr = monthsArr;

      ViewBag.ProductsList = GetProductCodes();

      return View();
    }

    public ActionResult ExpiringSubscriptions()
    {
      Title = "Expiring Subscriptions Report";

      var monthsArr = new string[12];
      var lastMonth = (new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)).AddMonths(-1);

      for (int i = 0; i <= 11; i++)
        monthsArr[11 - i] = lastMonth.AddMonths(-i).ToString("MMM yy");

      ViewBag.GridMonthsArr = monthsArr;

      ViewBag.TerritoryList = GetTerritoryCodes();

      return View();
    }

    public ActionResult NewTCV()
    {
      Title = "New Total Contract Value Report";

      var monthsArr = new string[12];
      var lastMonth = (new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)).AddMonths(-1);

      for (int i = 0; i <= 11; i++)
        monthsArr[11 - i] = lastMonth.AddMonths(-i).ToString("MMM yy");

      ViewBag.GridMonthsArr = monthsArr;

      ViewBag.TerritoryList = GetTerritoryCodes();

      return View();
    }

    public ActionResult RevenueRecognition()
    {
      Title = "Revenue Recognition Report";

      ViewBag.ProductsList = GetProductCodes();
      ViewBag.SubscriptionId = "N/A";
      ViewBag.TotalRevenue = "$0.00";
      return View();
    }

    public JsonResult RevenueRecognitionTotal()
    {
      var result = "";
      var subscriptionIdStr = GetParamValueFromRequest("subscriptionId");
      int subscriptionId;
      int.TryParse(subscriptionIdStr, out subscriptionId);

      using (var dbDataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
      {

        var amount = (from sr in dbDataMart.RevenueRecognitionReport
                  where (String.IsNullOrEmpty(subscriptionIdStr) || sr.SubscriptionId == subscriptionId)
                  select sr).Sum(x => (decimal?)x.DRAmount) ?? 0m;
        result = amount.ToString("0.00");
      }
      return Json(new {TotalRevenue = result}, JsonRequestBehavior.AllowGet);
    }

    public ActionResult SubscriptionCounters()
    {
      Title = "Subscription Counters Report";

      ViewBag.ProductsList = GetProductCodes();
      ViewBag.SalesRepList = GetSalesReps();
      ViewBag.CustomerList = GetCustomers();

      return View();
    }

    public JsonResult SubscriptionCountersPieCharts()
    {
      var productCode = GetParamValueFromRequest("productCode");
      var salesRepCode = GetParamValueFromRequest("salesrepCode");
      var customerCode = GetParamValueFromRequest("customerCode");
      var resultArr = new String[4];
      int customerId;
      int.TryParse(customerCode, out customerId);
      using (var dbDataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
      {
        var counters = (from c in dbDataMart.Counters
                      where c.StartDate >= DateTime.Today.AddMonths(-13)
                         && c.StartDate < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1)
                         && (String.IsNullOrEmpty(customerCode) || c.PayeeID == customerId)
                         && c.BundledUnits != 999999.00m
                      group c by new
                      {
                        c.SubscriptionID
                      } into grp
                      select new
                      {
                        Count = grp.Key.SubscriptionID,
                        ConsumedUnits = grp.Sum(x => x.UnitsConsumed > x.BundledUnits ? x.BundledUnits : x.UnitsConsumed),
                        BundledUnits = grp.Sum(x => x.BundledUnits),
                        OverageConsumedUnits = grp.Sum(x => x.UnitsConsumed > x.BundledUnits ? x.UnitsConsumed - x.BundledUnits : 0m),
                        PricePerUnit = grp.Sum(x => x.ProratedBundledPricePerUnit)
                      }).ToList();


        var consumedUnitsPercents = counters.Sum(x => x.ConsumedUnits / x.BundledUnits * 100);
        var countSubsribers = counters.Count();
        var consumedOverageUnitsPercents = counters.Sum(x => x.OverageConsumedUnits / x.BundledUnits * 100);
        var countSubsribersOveraged = counters.Count(x => x.OverageConsumedUnits > 0);
        var bundledConsumedUnits = counters.Sum(x => x.ConsumedUnits);
        var overageConsumedUnits = counters.Sum(x => x.OverageConsumedUnits);
        var pricesPerUnit = counters.Sum(x => x.PricePerUnit);

        // Average % Bundled Units Consumed
        resultArr[0] = (consumedUnitsPercents / countSubsribers).ToString("0.00");
        // Average % Overage Units Consumed
        resultArr[1] = (consumedOverageUnitsPercents / countSubsribersOveraged).ToString("0.00");
        // Average Bundled vs. Overage Units
        resultArr[2] = String.Format("{0}/{1}",
                        (bundledConsumedUnits / countSubsribers).ToString("0."),
                        (overageConsumedUnits / countSubsribersOveraged).ToString("0."));
        // Average Price per Bundled Unit
        resultArr[3] = ((double)pricesPerUnit / countSubsribers).ToString("0.00");
      }
      return Json(resultArr, JsonRequestBehavior.AllowGet);
    }

    public XmlResult Chart(string id)
    {
      XElement result = null;
      var productCode = GetParamValueFromRequest("productCode");
      var territoryCode = GetParamValueFromRequest("territoryCode");
      var salesRepCode = GetParamValueFromRequest("salesrepCode");
      var customerCode = GetParamValueFromRequest("customerCode");

      switch (id)
      {
        case "NewCustomersByMonth":
          using (var dbDataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.NewCustomersByMonth(dbDataMart, territoryCode);
          break;
        case "MRRByMonth":
          var MRRBase = DataGridService.GetFilterBoolValueFromRequest(Request.QueryString, "MRRBase");
          var MRRNew = DataGridService.GetFilterBoolValueFromRequest(Request.QueryString, "MRRNew");
          var MRRRenewal = DataGridService.GetFilterBoolValueFromRequest(Request.QueryString, "MRRRenewal");
          var MRRPriceChange = DataGridService.GetFilterBoolValueFromRequest(Request.QueryString, "MRRPriceChange");
          var MRRChurn = DataGridService.GetFilterBoolValueFromRequest(Request.QueryString, "MRRChurn");
          var MRRCancellation = DataGridService.GetFilterBoolValueFromRequest(Request.QueryString, "MRRCancellation");

          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.MRRByMonth(DataMart, productCode, territoryCode, MRRBase, MRRNew, MRRRenewal, MRRPriceChange, MRRChurn, MRRCancellation);
          break;
        case "NewTCVByMonth":
          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.NewTCVByMonth(DataMart, territoryCode);
          break;
        case "ChurnByMonth":
          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.ChurnByMonth(DataMart, productCode);
          break;
        case "ExpiringSubscriptionsByMonth":
          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.ExpiringSubscriptionsByMonth(DataMart, territoryCode);
          break;
        case "ExpiringSubscriptionsQuantityByMonth":
          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.ExpiringSubscriptionsQuantityByMonth(DataMart, territoryCode);
          break;
        case "SubscriptionCountersBundledUnitsPercentsByMonth":
          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.SubscriptionCountersBundledUnitsPercentsByMonth(DataMart, productCode, salesRepCode, customerCode);
          break;
        case "SubscriptionCountersOverageByMonth":
          using (var dataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.SubscriptionCountersOverageByMonth(dataMart, productCode, salesRepCode, customerCode);
          break;
        case "SubscriptionCountersOveragePercentsByMonth":
          using (var dataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.SubscriptionCountersOveragePercentsByMonth(dataMart, productCode, salesRepCode, customerCode);
          break;
        case "SubscriptionCountersUnitsByMonth":
          using (var dataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.SubscriptionCountersUnitsByMonth(dataMart, productCode, salesRepCode, customerCode);
          break;
        case "SubscriptionCountersPricePerBundledUnitByMonth":
          using (var DataMart = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
            result = ReportsChartService.SubscriptionCountersPricePerBundledUnitByMonth(DataMart, productCode, salesRepCode, customerCode);
          break;
      }

      return new XmlResult(result);
    }

    private string GetParamValueFromRequest(string paramName)
    {
      string paramValue = null;

      if (Request.QueryString.AllKeys.Contains(paramName))
        paramValue = Request.QueryString.Get(paramName);

      return paramValue;
    }
     
    private IEnumerable<SelectListItem> GetSalesReps()
    {
      var list = new List<SelectListItem>();
      list.Add(new SelectListItem() { Selected = true, Text = "All", Value = "all" });

      using (var dbContext = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
      {
        var codes =
          (from st in dbContext.TerritorryCodeCSRMap
           where
             st.C_firstname != string.Empty || st.C_lastname != string.Empty
           select new { Name = st.C_firstname + " " + st.C_lastname, AccountId = st.Id_acc.Value }).Distinct().OrderBy(x => x.Name).ToList();

        foreach (var code in codes)
          list.Add(new SelectListItem() { Text = code.Name, Value = code.AccountId.ToString() });
      }
      return list;
    }

    private IEnumerable<SelectListItem> GetCustomers()
    {
      var list = new List<SelectListItem>();
      list.Add(new SelectListItem() { Selected = true, Text = "All", Value = "all" });

      using (var dbContext = new DataMart(GetDefaultDatabaseConnectionSubscriptiondatamart()))
      {
        var codes =
          (from c in dbContext.Customer
           where
             c.CompanyName != string.Empty
           select new { Name = c.CompanyName, AccountId = c.AccountId }).Distinct().OrderBy(x => x.Name).ToList();

        list.AddRange(codes.Select(code => new SelectListItem() {Text = code.Name, Value = code.AccountId.ToString()}));
      }
      return list;
    }
     
    */

  }
}

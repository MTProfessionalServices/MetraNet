using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Presentation.Reports;
using MetraTech.UI.Common;
using RevRecModel = MetraTech.DomainModel.ProductCatalog.RevenueRecognitionReportDefinition;

public partial class AjaxServices_LoadExpectedRevRecData : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("View Summary Financial Information"))
      Response.End();

    try
    {
      var items = new MTList<RevRecModel>();
      SetFilters(items);

      var currencyLinq = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "Currency");
      var currency = (string)(currencyLinq == null ? "" : currencyLinq.Value);
      var revenueCodeLinq = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "RevenueCode");
      var revenueCode = (string)(revenueCodeLinq == null ? "" : revenueCodeLinq.Value);
      var deferredRevenueCodeLinq = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "DeferredRevenueCode");
      var deferredRevenueCode = (string)(deferredRevenueCodeLinq == null ? "" : deferredRevenueCodeLinq.Value);
      var productIdLinq = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "ProductId");
      var productId = (productIdLinq == null ? (int?)null : Convert.ToInt32(productIdLinq.Value));
      var accountingCycleIdLinq = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "AccountingCycleId");
      var accountingCycleId = (accountingCycleIdLinq == null ? "" : accountingCycleIdLinq.Value.ToString().Replace("%", ""));

      var revRec = new DeferredRevenueHelper().GetExpectedRevRec(currency, revenueCode, deferredRevenueCode, productId, accountingCycleId, 0);
      items.Items.AddRange(revRec);
      if (Page.Request["mode"] == "csv")
      {
        Response.BufferOutput = false;
        Response.ContentType = "application/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
        Response.BinaryWrite(BOM);
        var strCsv = ConvertObjectToCSV(items, true);
        Response.Write(strCsv);
      }
      else
      {
        var json = new JavaScriptSerializer().Serialize(items);
        json = FixJsonDate(json);
        json = FixJsonBigInt(json);
        Response.Write(json);
      }
    }
    catch (Exception ex)
    {
      Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
      throw;
    }
    finally
    {
      Response.End();
    }
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

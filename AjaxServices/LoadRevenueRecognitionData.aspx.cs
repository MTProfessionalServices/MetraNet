﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using MetraNet;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.UI.Common;
using RevRecModel = MetraTech.DomainModel.ProductCatalog.RevenueRecognitionReportDefinition;

public partial class AjaxServices_LoadRevenueRecognitionData : MTListServicePage
{
    private static int idRevRec;

    protected void Page_Load(object sender, EventArgs e)
    {
      var items = new MTList<RevRecModel> {TotalRows = 100, PageSize = 100, CurrentPage = 1};
      SetFilters(items);

      var currencyLINQ = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "Currency");
      var currency = (string)(currencyLINQ == null ? "" : currencyLINQ.Value);
      var revenueCodeLINQ = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "RevenueCode");
      var revenueCode = (string)(revenueCodeLINQ == null ? "" : revenueCodeLINQ.Value);
      var deferredRevenueCodeLINQ = items.Filters.Cast<MTFilterElement>().FirstOrDefault(x => x.PropertyName == "DeferredRevenueCode");
      var deferredRevenueCode = (string)(deferredRevenueCodeLINQ == null ? "" : deferredRevenueCodeLINQ.Value);

      var revRec = ReportingtHelper.GetRevRec(currency, revenueCode, deferredRevenueCode, idRevRec);
      items.Items.AddRange(revRec);

      var jss = new JavaScriptSerializer();
      var json = jss.Serialize(items);
      json = FixJsonDate(json);
      json = FixJsonBigInt(json);
      Response.Write(json);
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

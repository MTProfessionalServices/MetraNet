using System;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Common;

public partial class AjaxServices_VisualizeService : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    //parse query name
    var operation = Request["operation"];
    if (string.IsNullOrEmpty(operation))
    {
      Logger.LogWarning("No query specified");
      Response.Write("{\"Items\":[]}");
      Response.End();
      return;
    }
    Logger.LogInfo("operation : " + operation);

    using (new HighResolutionTimer("QueryService", 5000))
    {
      const string connectionInfo = "NetMeter";
      const string catalog = "NetMeter";
      var items = new MTList<SQLRecord>();
      var paramDict = new Dictionary<string, object>();
      
      if (operation.Equals("ftoverxdays"))
      {
        var threshold = Request["threshold"];
        if (string.IsNullOrEmpty(threshold))
        {
          Logger.LogWarning("No query specified");
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }
        paramDict.Add("%%AGE_THRESHOLD%%", int.Parse(threshold));

        VisualizeService.GetData(connectionInfo, catalog, "__GET_FAILEDTRANSACTIONS_OVERXDAYS__", paramDict, ref items);
      }
      else if (operation.Equals("ft30dayaging"))
      {
        VisualizeService.GetData(connectionInfo, catalog, "__GET_FAILEDTRANSACTIONS_30DAYAGING__", null, ref items);
      }
      else if (operation.Equals("ftgettotal"))
      {
        VisualizeService.GetData(connectionInfo, catalog, "__GET_FAILEDTRANSACTIONS_TOTAL__", null, ref items);
      }
      else if (operation.Equals("batchusage30day"))
      {
        VisualizeService.GetData(connectionInfo, catalog, "__GET_BATCHUSAGE_30DAYBATCHESUDR__", null, ref items);
      }
      else if (operation.Equals("getlastbatch"))
      {
        VisualizeService.GetData(connectionInfo, catalog, "__GET_BATCHUSAGE_LASTBATCH__", null, ref items);
      }
      else if (operation.Equals("activebillrun") || operation.Equals("activebillrunsummary"))
      {
        var idUsageInterval = Request["intervalid"];
        if (string.IsNullOrEmpty(idUsageInterval))
        {
          Logger.LogWarning("No intervalid specified");
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }
        paramDict.Add("%%ID_USAGE_INTERVAL%%", int.Parse(idUsageInterval));

        if (operation.Equals("activebillrun"))
          VisualizeService.GetData(connectionInfo, catalog, "__GET_ACTIVEBILLRUN_CURRENTAVERAGE__", paramDict, ref items);
        else if (operation.Equals("activebillrunsummary"))
          VisualizeService.GetData(connectionInfo, catalog, "__GET_ACTIVEBILLRUN_SUMMARY__", paramDict, ref items);
      }
      else if (operation.Equals("billclosesummary") || operation.Equals("billclosedetails"))
      {
        var idUsageInterval = Request["intervalid"];
        if (string.IsNullOrEmpty(idUsageInterval))
        {
          Logger.LogWarning("No intervalid specified");
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }
        paramDict.Add("%%ID_USAGE_INTERVAL%%", int.Parse(idUsageInterval));

        if (operation.Equals("billclosedetails"))
          VisualizeService.GetData(connectionInfo, catalog, "__GET_BILLCLOSESYNOPSIS_DETAILS__", paramDict, ref items);
        else
          VisualizeService.GetData(connectionInfo, catalog, "__GET_BILLCLOSESYNOPSIS_SUMMARY__", paramDict, ref items);
      }

      if (items.Items.Count == 0)
      {
        Response.Write("{\"Items\":[]}");
        Response.End();
        return;
      }

      var json = VisualizeService.SerializeItems(items);
      Logger.LogInfo("Returning " + json);
      Response.Write(json);
      Response.End();
    }
  }
}

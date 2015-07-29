using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
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

        VisualizeService.GetData("__GET_FAILEDTRANSACTIONS_OVERXDAYS__", paramDict, ref items);
      }
      else if (operation.Equals("ft30dayaging"))
      {
        VisualizeService.GetData("__GET_FAILEDTRANSACTIONS_30DAYAGING__", null, ref items);
      }
      else if (operation.Equals("ftgettotal"))
      {
        VisualizeService.GetData("__GET_FAILEDTRANSACTIONS_TOTAL__", null, ref items);
      }
      else if (operation.Equals("batchusage30day"))
      {
        VisualizeService.GetData("__GET_BATCHUSAGE_30DAYBATCHESUDR__", null, ref items);
      }
      else if (operation.Equals("getlastbatch"))
      {
        VisualizeService.GetData("__GET_BATCHUSAGE_LASTBATCH__", null, ref items);
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
          VisualizeService.GetData("__GET_ACTIVEBILLRUN_CURRENTAVERAGE__", paramDict, ref items);
        else if (operation.Equals("activebillrunsummary"))
          VisualizeService.GetData("__GET_ACTIVEBILLRUN_SUMMARY__", paramDict, ref items);
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
          VisualizeService.GetData("__GET_BILLCLOSESYNOPSIS_DETAILS__", paramDict, ref items);
        else
          VisualizeService.GetData("__GET_BILLCLOSESYNOPSIS_SUMMARY__", paramDict, ref items);
      }

      if (items.Items.Count == 0)
      {
        Response.Write("{\"Items\":[]}");
        Response.End();
        return;
      }

      var json = SerializeItems(operation, items);
      Logger.LogInfo("Returning " + json);
      Response.Write(json);
      Response.End();
    }
  }

  private string SerializeItems(string operation, MTList<SQLRecord> items)
  {
    return (operation.Equals("activebillrunsummary")) ? ConstructJson(operation, items) :  VisualizeService.SerializeItems(items);
  }

  private string ConstructJson(string operation, MTList<SQLRecord> items)
  {
    var json = new StringBuilder();
    string item = string.Empty;

    json.Append("{\"Items\":[");

    for (int i = 0; i < items.Items.Count; i++)
    {
      SQLRecord record = items.Items[i];

      if (i > 0)
      {
        json.Append(",");
      }

      json.Append("{");

      if (record.Fields.Count > 0)
      {
        if (operation.Equals("activebillrunsummary"))
        {
          item = string.Format("\"id_interval\":{0},", FormatFieldValue(record.Fields[0]));
          json.Append(item);
          item = string.Format("\"end_date\":{0},", FormatDateTime(record.Fields[1], "d"));
          json.Append(item);
          item = string.Format("\"eop_adapter_count\":{0},", FormatFieldValue(record.Fields[2]));
          json.Append(item);
          item = string.Format("\"eop_start_time\":{0},", FormatDateTime(record.Fields[3], "d"));
          json.Append(item);
          item = string.Format("\"last_adapter_run_time\":{0},", FormatDateTime(record.Fields[4], "d"));
          json.Append(item);
          item = string.Format("\"eop_rtr_adapter_count\":{0},", FormatFieldValue(record.Fields[5]));
          json.Append(item);
          item = string.Format("\"eop_nyr_adapter_count\":{0},", FormatFieldValue(record.Fields[6]));
          json.Append(item);
          item = string.Format("\"eop_failed_adapter_count\":{0},", FormatFieldValue(record.Fields[7]));
          json.Append(item);
          item = string.Format("\"eop_succeeded_adapter_count\":{0},", FormatFieldValue(record.Fields[8]));
          json.Append(item);
          item = string.Format("\"last_eop_adapter_name\":{0},", FormatFieldValue(record.Fields[9]));
          json.Append(item);
          item = string.Format("\"last_eop_adapter_duration\":{0},", FormatFieldValue(record.Fields[10]));
          json.Append(item);
          item = string.Format("\"last_eop_adapter_status\":{0},", FormatFieldValue(record.Fields[11]));
          json.Append(item);
          double variance = 0.0;
          if (record.Fields[12] != null && record.Fields[12].FieldValue != null && !String.IsNullOrEmpty(record.Fields[12].FieldValue.ToString()))
          {
            variance = Double.Parse(record.Fields[12].FieldValue.ToString(), CultureInfo.CurrentCulture);
          }
          item = string.Format("\"varianceAsString\":\"{0}\",", variance.ToString("G", CultureInfo.CreateSpecificCulture("en-US")));
          json.Append(item);
          item = string.Format("\"earliest_eta\":\"{0}\",", string.Format("{0} {1}", Convert.ToDateTime(record.Fields[13].FieldValue).ToString("d"), Convert.ToDateTime(record.Fields[13].FieldValue).ToString("HH:mm:ss")));
          json.Append(item);
          item = string.Format("\"eta_offset\":\"{0}\"", Double.Parse(FormatFieldValue(record.Fields[14])));
          json.Append(item);
        }
      }
      json.Append("}");
    }

    json.Append("]");

    json.Append("}");

    return json.ToString();
  }

  private string FormatFieldValue(SQLField field, CultureInfo formatCulture = null)
  {
    if (field.FieldValue == null) return "null";
    string fieldValue;
    fieldValue = (formatCulture == null) ? field.FieldValue.ToString() : Convert.ToString(field.FieldValue, formatCulture); // field.ToString();

    // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
    //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
    // CORE-5938: Audit log: incorrect character encoding in Details row 
    var sb = new StringBuilder((fieldValue ?? string.Empty).EncodeForHtml());
    sb = sb.Replace("\"", "\\\"");
    //CORE-5320: strip all the new line characters. They are not allowed in jason
    // Oracle can return them and breeak our ExtJs grid with an ugly "Session Time Out" catch all error message
    // TODO: need to find other places where JSON is generated and strip new line characters.
    sb = sb.Replace("\n", "<br />");
    sb = sb.Replace("\r", "");

    return ((typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType ||
             typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType))
             ? string.Format("\"{0}\"", sb)
             : string.Format("{0}", sb);

  }

  private string FormatDateTime(SQLField field, string format)
  {
    return (field.FieldValue == null) ? "null" : string.Format("\"{0}\"", Convert.ToDateTime(field.FieldValue).ToString(format).EncodeForHtml());
  }

}

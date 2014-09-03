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
        String operation = Request["operation"];
         if (string.IsNullOrEmpty(operation))
        {
            Logger.LogWarning("No query specified");
            Response.Write("{\"Items\":[]}");
            Response.End();
            return;
        }

        Logger.LogInfo("operation : " + operation);

        using (new HighResolutionTimer("VisualizeService", 5000))
        {
            MTList<SQLRecord> items = new MTList<SQLRecord>();
            Dictionary<string, object> paramDict = new Dictionary<string, object>();

            //System.Diagnostics.Debugger.Break();
            string connectionInfo = "NetMeter";
            string catalog = "NetMeter";


            if (operation.Equals("ftoverxdays"))
            {
                string threshold = Request["threshold"];
               
                if (string.IsNullOrEmpty(threshold))
                {
                    Logger.LogWarning("No query specified");
                    Response.Write("{\"Items\":[]}");
                    Response.End();
                    return;
                }

                paramDict.Add("%%AGE_THRESHOLD%%", int.Parse(threshold));
                VisualizeService.GetData(connectionInfo,catalog,"__GET_FAILEDTRANSACTIONS_OVERXDAYS__",paramDict,ref items);
            }
            else if (operation.Equals("AnalyticsTopMRR"))
            {
				        paramDict.Add("%%METRATIME%%", MetraTech.MetraTime.Now);
                VisualizeService.GetData(connectionInfo, catalog, "__SubscriptionSummary_TopMRR__", paramDict, ref items);
            }
            else if (operation.Equals("AnalyticsTopMRRGain"))
            {
				        paramDict.Add("%%METRATIME%%", MetraTech.MetraTime.Now);
                VisualizeService.GetData(connectionInfo, catalog, "__SubscriptionSummary_TopMRRGain__", paramDict, ref items);
            }
            else if (operation.Equals("AnalyticsTopMRRLoss"))
            {
				        paramDict.Add("%%METRATIME%%", MetraTech.MetraTime.Now);
                VisualizeService.GetData(connectionInfo, catalog, "__SubscriptionSummary_TopMRRLoss__", paramDict, ref items);
            }

            else if (operation.Equals("AnalyticsTopSubscriptions"))
            {
                VisualizeService.GetData(connectionInfo,catalog,"__SubscriptionSummary_TopSubscriptions__", null, ref items);
            }
            else if (operation.Equals("AnalyticsTopSubscriptionGain"))
            {
                VisualizeService.GetData(connectionInfo,catalog,"__SubscriptionSummary_TopSubscriptionsGain__", null, ref items);
            }
            else if (operation.Equals("AnalyticsTopSubscriptionLoss"))
            {
                VisualizeService.GetData(connectionInfo,catalog,"__SubscriptionSummary_TopSubscriptionsLoss__", null, ref items);
            }

            else if (operation.Equals("AnalyticsTopOfferingsByNewCustomers"))
            {
                VisualizeService.GetData(connectionInfo,catalog,"__SubscriptionSummary_TopSubscriptionsByNewCustomers__", null, ref items);
            }

            else if (operation.Equals("AnalyticsSingleProductOverTime"))
            {
                VisualizeService.GetData(connectionInfo,catalog,"__SubscriptionSummary_SingleProductOverTime__", null, ref items);
            }

            else if (operation.Equals("billclosesummary") || operation.Equals("billclosedetails"))
            {

                    paramDict = new Dictionary<string, object>();

                    string id_usage_interval = Request["intervalid"];
               
                    if (string.IsNullOrEmpty(id_usage_interval))
                    {
                        Logger.LogWarning("No intervalid specified");
                        Response.Write("{\"Items\":[]}");
                        Response.End();
                        return;
                    }

                    paramDict.Add("%%ID_USAGE_INTERVAL%%", int.Parse(id_usage_interval));

                    if(operation.Equals("billclosedetails"))
                        VisualizeService.GetData(connectionInfo,catalog,"__GET_BILLCLOSESYNOPSIS_DETAILS__", paramDict, ref items);
                    else 
                       VisualizeService.GetData(connectionInfo,catalog,"__GET_BILLCLOSESYNOPSIS_SUMMARY__", paramDict, ref items);
                   
            }


            if (items.Items.Count == 0)
            {
                Response.Write("{\"Items\":[]}");
                Response.End();
                return;
            }

            string json = SerializeItems(operation, items);
            Logger.LogInfo("Returning " + json);
            Response.Write(json);
            Response.End();
        }

    }

    private string SerializeItems(string operation, MTList<SQLRecord> items)
    {
      string json;

      if (operation.Equals("AnalyticsTopMRR") || operation.Equals("AnalyticsTopMRRGain") ||
          operation.Equals("AnalyticsTopMRRLoss") || operation.Equals("AnalyticsSingleProductOverTime"))
      {
        json = ConstructJson(operation, items);
      }
      else
      {
        json = VisualizeService.SerializeItems(items);
      }
      return json;
    }

    private string ConstructJson(string operation, MTList<SQLRecord> items)
    {
       var json = new StringBuilder();
      string item = string.Empty;
      //format dates/amounts used as data in client side for formatting or plotting graphs using invaraint culture otherwise culture specific decimal/group seperators mess up with json returned
      var invariantCulture = CultureInfo.InvariantCulture;

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
          if (operation.Equals("AnalyticsTopMRR") || operation.Equals("AnalyticsTopMRRGain") ||
              operation.Equals("AnalyticsTopMRRLoss"))
          {
            item = string.Format("\"ordernum\":{0},", FormatFieldValue(record.Fields[0]));
            json.Append(item);
            item = string.Format("\"productcode\":{0},", FormatFieldValue(record.Fields[2]));
            json.Append(item);
            item = string.Format("\"month\":{0},", FormatFieldValue(record.Fields[3]));
            json.Append(item);
            item = string.Format("\"mrr\":{0},", FormatFieldValue(record.Fields[4], invariantCulture));
            json.Append(item);
            item = string.Format("\"mrrAsString\":{0},", FormatAmount(record.Fields[4]));
            json.Append(item);
            item = string.Format("\"mrrprevious\":{0},", FormatFieldValue(record.Fields[5], invariantCulture));
            json.Append(item);
            item = string.Format("\"mrrpreviousAsString\":{0},", FormatAmount(record.Fields[5]));
            json.Append(item);
            item = string.Format("\"mrrchange\":{0},", FormatFieldValue(record.Fields[6], invariantCulture));
            json.Append(item);
            item = string.Format("\"mrrchangeAsString\":{0}", FormatAmount(record.Fields[6]));
            json.Append(item);
          }
          else if (operation.Equals("AnalyticsSingleProductOverTime"))
          {
            item = string.Format("\"ordernum\":{0},", FormatFieldValue(record.Fields[0]));
            json.Append(item);
            item = string.Format("\"productcode\":{0},", FormatFieldValue(record.Fields[2]));
            json.Append(item);
            item = string.Format("\"month\":{0},", FormatFieldValue(record.Fields[3]));
            json.Append(item);
            item = string.Format("\"revenue\":{0},", FormatFieldValue(record.Fields[4], invariantCulture));
            json.Append(item);
            item = string.Format("\"revenueAsString\":{0},", FormatAmount(record.Fields[4]));
            json.Append(item);
            item = string.Format("\"revenueprevious\":{0},", FormatFieldValue(record.Fields[5], invariantCulture));
            json.Append(item);
            item = string.Format("\"revenuepreviousAsString\":{0},", FormatAmount(record.Fields[5]));
            json.Append(item);
            item = string.Format("\"revenuechange\":{0},", FormatFieldValue(record.Fields[6], invariantCulture));
            json.Append(item);
            item = string.Format("\"revenuechangeAsString\":{0}", FormatAmount(record.Fields[6]));
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

    private string FormatAmount(SQLField field)
    {
      return (field.FieldValue == null) ? "null" : string.Format("\"{0}\"", Convert.ToDecimal(field.FieldValue).ToString("N2").EncodeForJavaScript());
    }
}

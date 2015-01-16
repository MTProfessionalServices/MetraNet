using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Interop.RCD;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.Xml;


public partial class AjaxServices_VisualizeService : MTListServicePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    bool showFinancialData = UI.CoarseCheckCapability("View Summary Financial Information");

    ////parse query name
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
      try
      {
        MTList<SQLRecord> items = new MTList<SQLRecord>();
        Dictionary<string, object> paramDict = new Dictionary<string, object>();


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
          VisualizeService.GetData("__GET_FAILEDTRANSACTIONS_OVERXDAYS__", paramDict, ref items);
        }
        else if (operation.Equals("AnalyticsTopMRR") && showFinancialData)
        {
          paramDict.Add("%%ID_LANG%%", UI.SessionContext.LanguageID);
          paramDict.Add("%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now);
          VisualizeService.GetData("__SubscriptionSummary_TopMRR__", paramDict, ref items);
        }
        else if (operation.Equals("AnalyticsTopMRRGain")  && showFinancialData)
        {
          paramDict.Add("%%ID_LANG%%", UI.SessionContext.LanguageID);
          paramDict.Add("%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now);
          VisualizeService.GetData("__SubscriptionSummary_TopMRRGain__", paramDict, ref items);
        }
        else if (operation.Equals("AnalyticsTopMRRLoss")  && showFinancialData)
        {
          paramDict.Add("%%ID_LANG%%", UI.SessionContext.LanguageID);
          paramDict.Add("%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now);
          VisualizeService.GetData("__SubscriptionSummary_TopMRRLoss__", paramDict, ref items);
        }

        else if (operation.Equals("AnalyticsTopSubscriptions")  && showFinancialData)
        {
          paramDict.Add("%%ID_LANG%%", UI.SessionContext.LanguageID);
          paramDict.Add("%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now);
          VisualizeService.GetData("__SubscriptionSummary_TopSubscriptions__", paramDict, ref items);
        }
        else if (operation.Equals("AnalyticsTopSubscriptionGain")  && showFinancialData)
        {
          paramDict.Add("%%ID_LANG%%", UI.SessionContext.LanguageID);
          paramDict.Add("%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now);
          VisualizeService.GetData("__SubscriptionSummary_TopSubscriptionsGain__", paramDict,
                                   ref items);
        }
        else if (operation.Equals("AnalyticsTopSubscriptionLoss")  && showFinancialData)
        {
          paramDict.Add("%%ID_LANG%%", UI.SessionContext.LanguageID);
          paramDict.Add("%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now);
          VisualizeService.GetData("__SubscriptionSummary_TopSubscriptionsLoss__", paramDict,
                                   ref items);
        }

        else if (operation.Equals("AnalyticsTopOfferingsByNewCustomers")  && showFinancialData)
        {
          VisualizeService.GetData("__SubscriptionSummary_TopSubscriptionsByNewCustomers__",
                                   null, ref items);
        }

        else if (operation.Equals("AnalyticsSingleProductOverTime")  && showFinancialData)
        {
          VisualizeService.GetData("__SubscriptionSummary_SingleProductOverTime__", null,
                                   ref items);
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

        string json = SerializeItems(operation, items);
        Logger.LogInfo("Returning " + json);
        Response.Write(json);
        Response.End();
      }
      catch (ThreadAbortException ex)
      {
        //Looks like Response.End is deprecated/changed
        //Might have a lot of unhandled exceptions in product from when we call response.end
        //http://support.microsoft.com/kb/312629
        //Logger.LogError("Thread Abort Exception: {0} {1}", ex.Message, ex.ToString());
        Logger.LogInfo("Handled Exception from Response.Write() {0} ", ex.Message);
      }
      catch (Exception ex)
      {
        Logger.LogError("Exception: {0} {1}", ex.Message, ex.ToString());
        Response.Write("{\"Items\":[]}");
        Response.End();
      }
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
    string reportingCurrency = GetReportingCurrency();

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
          item = string.Format("\"productname\":{0},", FormatFieldValue(record.Fields[1]));
          json.Append(item);
          item = string.Format("\"month\":{0},", FormatFieldValue(record.Fields[3]));
          json.Append(item);
          item = string.Format("\"mrr\":{0},", FormatFieldValue(record.Fields[4], invariantCulture));
          json.Append(item);
          item = string.Format("\"mrrAsString\":{0},", FormatAmount(record.Fields[4], reportingCurrency));
          json.Append(item);
          item = string.Format("\"mrrprevious\":{0},", FormatFieldValue(record.Fields[5], invariantCulture));
          json.Append(item);
          item = string.Format("\"mrrchange\":{0},", FormatFieldValue(record.Fields[6], invariantCulture));
          json.Append(item);
          item = string.Format("\"mrrabschange\":{0},", FormatFieldValue(record.Fields[7], invariantCulture));
          json.Append(item);
          item = string.Format("\"mrrabschangeAsString\":{0}", FormatAmount(record.Fields[7], reportingCurrency));
          json.Append(item);
        }
        else if (operation.Equals("AnalyticsSingleProductOverTime"))
        {
          item = string.Format("\"ordernum\":{0},", FormatFieldValue(record.Fields[0]));
          json.Append(item);
          item = string.Format("\"productcode\":{0},", FormatFieldValue(record.Fields[2]));
          json.Append(item);
          item = string.Format("\"productname\":{0},", FormatFieldValue(record.Fields[1]));
          json.Append(item);
          item = string.Format("\"month\":{0},", FormatFieldValue(record.Fields[3]));
          json.Append(item);
          item = string.Format("\"revenue\":{0},", FormatFieldValue(record.Fields[4], invariantCulture));
          json.Append(item);
          item = string.Format("\"revenueAsString\":{0},", FormatAmount(record.Fields[4], reportingCurrency));
          json.Append(item);
          item = string.Format("\"revenueprevious\":{0},", FormatFieldValue(record.Fields[5], invariantCulture));
          json.Append(item);
          item = string.Format("\"revenuechange\":{0}", FormatFieldValue(record.Fields[6], invariantCulture));
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

  private string FormatAmount(SQLField field, string currency)
  {
    return string.Format("\"{0}\"", (field.FieldValue == null) ? "" : CurrencyFormatter.Format(field.FieldValue, currency));
  }

  private string GetReportingCurrency()
  {
    string reportingCurrency;
    MTXmlDocument doc = new MTXmlDocument();
    IMTRcd rcd = new MTRcd();
    try
    {
      string configFile = Path.Combine(rcd.ExtensionDir, @"SystemConfig\config\UsageServer\GenerateAnalyticsDatamart.xml");
      doc.Load(configFile);
      reportingCurrency = doc.GetNodeValueAsString("/xmlconfig/PrimaryCurrency", "USD");
    }
    catch (Exception e)
    {
      Logger.LogWarning("Couldnot load GenerateAnalyticsDatamart config file. Using USD as the default reporting currency. Details: {0} " + e.InnerException);
      reportingCurrency = "USD";
    }
    return reportingCurrency;
  }

}

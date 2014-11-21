using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class AjaxServices_VisualizeService : MTListServicePage
{
  private const string sqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCustom\Queries\UI\Dashboard";
  private const string noQueryMessage = "No query specified";
  private readonly Dictionary<string, string> _queryDict = new Dictionary<string, string> { 
                                                                                            { "RevenueReport",      "__GET_REPORT_REVENUE_CHART__"},
                                                                                            { "MRRReport",          "__GET_REPORT_MRR_CHART__"},
                                                                                            { "NewCustomersReport", "__GET_REPORT_NEWCUSTOMERS_CHART__"},
                                                                                          };

  protected void Page_Load(object sender, EventArgs e)
  {
    //parse query name
    var operation = Request["operation"];
    var json = "{\"Items\":[]}";

    if (string.IsNullOrEmpty(operation) || !_queryDict.ContainsKey(operation))
    {
      Logger.LogWarning(noQueryMessage);
      Response.Write(json);
      Response.End();
      return;
    }

    Logger.LogInfo("operation : " + operation);

    using (new HighResolutionTimer("QueryService", 5000))
    {
      try
      {
        var items = new MTList<SQLRecord>();
        var paramDict = new Dictionary<string, object>();

        //the same date range is set in ReportsAnalyticsDashboard.aspx.cs; any change made here should be done there too
        var firstMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-25).AddDays(1 - DateTime.Today.Day - 15);
        var firstDayOfCurrentMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToUniversalTime().Date;

        var monthAfterFirstMonthAndHalf = firstMonthAndHalf.AddMonths(1);
        var firstDayOfFirstMonth = new DateTime(monthAfterFirstMonthAndHalf.Year, monthAfterFirstMonthAndHalf.Month, 1).ToUniversalTime().Date;

        paramDict.Add("%%FROM_DATE%%", firstDayOfFirstMonth);
        paramDict.Add("%%TO_DATE%%", firstDayOfCurrentMonth);

        if (operation.ToLower().Equals("revenuereport") || operation.ToLower().Equals("mrrreport") ) 
        {
            paramDict.Add("%%ID_LANG_CODE%%", UI.SessionContext.LanguageID);
        }
        GetData(_queryDict[operation], paramDict, ref items);

        if (items.Items.Count == 0)
        {
          Response.Write(json);
          Response.End();
          return;
        }

        json = ConstructJson(operation, items); 
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


  private void GetData(string sqlQueryTag, Dictionary<string, object> paramDict, ref MTList<SQLRecord> items)
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

          ConstructItems(reader, ref items);
          // get the total rows that would be returned without paging
        }
      }
      conn.Close();
    }
  }

  protected void ConstructItems(IMTDataReader rdr, ref MTList<SQLRecord> items)
  {
    items.Items.Clear();

    // process the results
    while (rdr.Read())
    {
      var record = new SQLRecord();

      for (int i = 0; i < rdr.FieldCount; i++)
      {
        SQLField field = new SQLField();
        field.FieldDataType = rdr.GetType(i);
        field.FieldName = rdr.GetName(i);

        if (!rdr.IsDBNull(i))
        {
          field.FieldValue = rdr.GetValue(i);
        }

        record.Fields.Add(field);
      }

      items.Items.Add(record);
    }
  }

  private string ConstructJson(string operation, MTList<SQLRecord> items)
  {
    var json = new StringBuilder();
    string item = string.Empty;
    string period = string.Empty;
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
        period = string.Format("\"{0} {1}\"", Convert.ToDateTime(record.Fields[0].FieldValue).ToString("MMMM"), Convert.ToDateTime(record.Fields[0].FieldValue).ToString("yyyy"));
        if (operation.Equals("RevenueReport") || operation.Equals("MRRReport"))
        {
          item = string.Format("\"date\":{0},", FormatFieldValue(record.Fields[0], invariantCulture));
          json.Append(item);
          item = string.Format("\"currency\":{0},", FormatFieldValue(record.Fields[1]));
          json.Append(item);
          item = string.Format("\"amount\":{0},", FormatFieldValue(record.Fields[2], invariantCulture));
          json.Append(item);
          item = string.Format("\"amountAsString\":{0},", FormatAmount(record.Fields[2], Convert.ToString(record.Fields[1].FieldValue)));
          json.Append(item);
          item = string.Format("\"localizedCurrency\":{0},", FormatFieldValue(record.Fields[3]));
          json.Append(item);
          item = string.Format("\"period\":{0}", period);
          json.Append(item);
        }
        else if (operation.Equals("NewCustomersReport"))
        {
          item = string.Format("\"date\":{0},", FormatFieldValue(record.Fields[0], invariantCulture));
          json.Append(item);
          item = string.Format("\"customersCount\":{0},", FormatFieldValue(record.Fields[1]));
          json.Append(item);
          item = string.Format("\"period\":{0}", period);
          json.Append(item);
        }
      }
      json.Append("}");
    }

    json.Append("]");

    json.Append("}");

    return json.ToString();
  }

  private string FormatDateTime(SQLField field, string format)
  {
    return (field.FieldValue == null) ? "null" : string.Format("\"{0}\"", Convert.ToDateTime(field.FieldValue).ToString(format).EncodeForHtml());
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
}

using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class AjaxServices_VisualizeService : MTListServicePage
{
  private const string sqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCustom\Queries\UI\Dashboard";
  private const string noQueryMessage = "No query specified";
  private readonly Dictionary<string, string> _queryDict = new Dictionary<string, string> { { "ftoverxdays", "__GET_FAILEDTRANSACTIONS_OVERXDAYS__" },
                                                                                            { "ft30dayaging", "__GET_FAILEDTRANSACTIONS_30DAYAGING__"},
                                                                                            { "ftgettotal", "__GET_FAILEDTRANSACTIONS_TOTAL__"},
                                                                                            { "batchusage30day", "__GET_BATCHUSAGE_30DAYBATCHESUDR__"},
                                                                                            { "getlastbatch", "__GET_BATCHUSAGE_LASTBATCH__"},
                                                                                            { "activebillrun", "__GET_ACTIVEBILLRUN_CURRENTAVERAGE__"},
                                                                                            { "activebillrunsummary", "__GET_ACTIVEBILLRUN_SUMMARY__"},
                                                                                            { "billclosesummary", "__GET_BILLCLOSESYNOPSIS_SUMMARY__"},
                                                                                            { "billclosedetails", "__GET_BILLCLOSESYNOPSIS_DETAILS__"},
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
      var items = new MTList<SQLRecord>();
      var paramDict = new Dictionary<string, object>();

      switch (operation)
      {
        case "ftoverxdays":
          var threshold = Request["threshold"];

          if (string.IsNullOrEmpty(threshold))
          {
            Logger.LogWarning(noQueryMessage);
            Response.Write(json);
            Response.End();
            return;
          }

          paramDict.Add("%%AGE_THRESHOLD%%", int.Parse(threshold));
          break;
        case "activebillrun":
        case "activebillrunsummary":
        case "billclosedetails":
        case "billclosesummary":
          var id_usage_interval = Request["intervalid"];

          if (string.IsNullOrEmpty(id_usage_interval))
          {
            Logger.LogWarning("No intervalid specified");
            Response.Write(json);
            Response.End();
            return;
          }

          paramDict.Add("%%ID_USAGE_INTERVAL%%", int.Parse(id_usage_interval));
          break;
      }
      GetData(_queryDict[operation], paramDict, ref items);

      if (items.Items.Count == 0)
      {
        Response.Write(json);
        Response.End();
        return;
      }

      json = SerializeItems(items);
      Logger.LogInfo("Returning " + json);
      Response.Write(json);
      Response.End();
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

  protected string SerializeItems(MTList<SQLRecord> items)
  {
    var json = new StringBuilder();

    json.Append("{\"Items\":[");

    for (int i = 0; i < items.Items.Count; i++)
    {
      SQLRecord record = items.Items[i];

      if (i > 0)
      {
        json.Append(",");
      }

      json.Append("{");

      //iterate through fields
      for (int j = 0; j < record.Fields.Count; j++)
      {
        SQLField field = record.Fields[j];
        if (j > 0)
        {
          json.Append(",");
        }

        json.Append("\"");
        json.Append(field.FieldName);
        json.Append("\":");

        if (field.FieldValue == null)
        {
          json.Append("null");
        }
        else
        {

          if (typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType || typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType)
          {
            json.Append("\"");
          }

          string value;
          if (typeof(Byte[]) == field.FieldDataType)
          {
            var enc = Encoding.ASCII;
            value = enc.GetString((Byte[])(field.FieldValue));
          }
          else
          {
            value = field.FieldValue.ToString();
          }

          // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
          //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
          // CORE-5938: Audit log: incorrect character encoding in Details row 
          var sb = new StringBuilder(value.EncodeForHtml());
          sb = sb.Replace("\"", "\\\"");
          //CORE-5320: strip all the new line characters. They are not allowed in jason
          // Oracle can return them and breeak our ExtJs grid with an ugly "Session Time Out" catch all error message
          // TODO: need to find other places where JSON is generated and strip new line characters.
          sb = sb.Replace("\n", "<br />");
          sb = sb.Replace("\r", "");
          string fieldvalue = sb.ToString();

          json.Append(fieldvalue);

          if (typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType || typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType)
          {
            json.Append("\"");
          }
        }
      }

      json.Append("}");
    }

    json.Append("]");

    json.Append("}");

    return json.ToString();
  }
}

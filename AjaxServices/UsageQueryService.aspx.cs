using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.ServiceModel;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;


public partial class AjaxServices_UsageQueryService : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;
  protected SQLQueryInfo QueryInfo;
  protected List<int> exportColumns = new List<int>();

  protected bool ExtractDataInternal(ref MTList<SQLRecord> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;

      // open the connection
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          // Get a filter/sort statement
          using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(QueryInfo.QueryDir, QueryInfo.QueryName))
          {

              // Set the parameters
              foreach (SQLQueryParam param in QueryInfo.Params)
              {
                  //stmt.AddParam(param.FieldName, param.FieldValue);
                  stmt.AddParamIfFound(param.FieldName, param.FieldValue);
              }

              #region Apply Sorting
              //add sorting info if applies
              if (items.SortCriteria != null && items.SortCriteria.Count > 0)
              {
                  foreach (MetraTech.ActivityServices.Common.SortCriteria sc in items.SortCriteria)
                  {
                      stmt.SortCriteria.Add(
                          new MetraTech.DataAccess.SortCriteria(
                              sc.SortProperty,
                              ((sc.SortDirection == SortType.Ascending) ? MetraTech.DataAccess.SortDirection.Ascending : MetraTech.DataAccess.SortDirection.Descending)));
                  }
              }

              #endregion

              #region Apply Filters
              //apply filters
              foreach (MTBaseFilterElement filterElement in items.Filters)
              {
                  BaseFilterElement fe = ConvertMTFilterElement(filterElement);

                  stmt.AddFilter(fe);
              }
              #endregion

              #region Apply Pagination
              //set paging info
              stmt.CurrentPage = items.CurrentPage;
              stmt.PageSize = items.PageSize;
              #endregion

              // execute the query
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                  // process the results
                  while (rdr.Read())
                  {
                      SQLRecord record = new SQLRecord();

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

                  // get the total rows that would be returned without paging
                  items.TotalRows = stmt.TotalRows;
              }
          }
      }
    }

    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }

    return true;
  }

    private BaseFilterElement ConvertMTFilterElement(MTBaseFilterElement filterElement)
  {
      BaseFilterElement bfe = null;

      if (filterElement.GetType() == typeof(MTBinaryFilterOperator))
      {
          MTBinaryFilterOperator bfo = filterElement as MTBinaryFilterOperator;

          bfe = new BinaryFilterElement(
                      ConvertMTFilterElement(bfo.LeftHandElement),
                      (BinaryFilterElement.BinaryOperatorType)((int)bfo.OperatorType),
                      ConvertMTFilterElement(bfo.RightHandElement));
      }
      else if (filterElement.GetType() == typeof(MTFilterElement))
      {
          MTFilterElement fe = filterElement as MTFilterElement;
          object filterValue = fe.Value;

          bfe = new FilterElement(fe.PropertyName.Replace('.', '_'),
            (FilterElement.OperationType)((int)fe.Operation),
            filterValue);
      }
      else
      {
          throw new MASBasicException("Unexpected MTBaseFilterElement type");
      }

      return bfe;
  }

  protected bool ExtractData(ref MTList<SQLRecord> items)
  {
    if (Page.Request["mode"] == "csv")
    {
      Response.BufferOutput = false;
      Response.ContentType = "application/csv";
      Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
    }

    //if there are more records to process than we can process at once, we need to break up into multiple batches
    if ((items.PageSize > MAX_RECORDS_PER_BATCH) && ((Page.Request["mode"] == "csv") || (Page.Request["mode"] == "SelectAll")))
    {
      int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

      var sb = new StringBuilder();
      int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
      for (int batchID = 0; batchID < numBatches; batchID++)
      {
        ExtractDataInternal(ref items, batchID + 1, MAX_RECORDS_PER_BATCH);
        if (Page.Request["mode"] == "csv")
        {
          string strCSV = ConvertObjectToCSV(items, (batchID == 0));
          Response.Write(strCSV);
        }

        // select all
        if (Page.Request["mode"] == "SelectAll")
        {
          string column = Request["idNode"];
          foreach (var r in items.Items)
          {
            foreach (var c in r.Fields)
            {
              if (c.FieldName.Equals(column))
              {
                sb.Append(c.FieldValue);
                continue;
              }
            }
            sb.Append(",");
          }
        }
      }

      if (Page.Request["mode"] == "SelectAll")
      {
        Session["SelectedIDs"] = sb.ToString().Trim(new[] {','});
        var result = new AjaxResponse();
        result.Success = true;
        result.Message = String.Format("Selected {0} items.", items.TotalRows);
        Response.Write(result.ToJson());
        Response.End();
      }
    }
    else
    {
      ExtractDataInternal(ref items, items.CurrentPage, items.PageSize);
      if (Page.Request["mode"] == "csv")
      {
        string strCSV = ConvertObjectToCSV(items, true);
        Response.Write(strCSV);
      }

      // select all
      if (Page.Request["mode"] == "SelectAll")
      {
        var sb = new StringBuilder();
        string column = Request["idNode"];
        foreach(var r in items.Items)
        {
          foreach(var c in r.Fields)
          {
            if(c.FieldName.Equals(column))
            {
              sb.Append(c.FieldValue);
              continue;
            }
          }
          sb.Append(",");
        }
        Session["SelectedIDs"] = sb.ToString().Trim(new[] {','});
        var result = new AjaxResponse();
        result.Success = true;
        result.Message = String.Format("Selected {0} items.", items.TotalRows);
        Response.Write(result.ToJson());
        Response.End();
      }
    }

    return true;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    bool generateMetaData = false;
      //parse query name
    String qsQuery = Request["urlparam_q"];
    if (string.IsNullOrEmpty(qsQuery))
    {
      Logger.LogWarning("No query specified");
      Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
      Response.End();
      return;
    }

	String qm = Request["urlparam_m"];
    if (!string.IsNullOrEmpty(qm))
	{
		generateMetaData = bool.Parse(qm);
	}

    //populate the object
    try
    {
      QueryInfo = SQLQueryInfo.Extract(qsQuery);
    }
    catch
    {
      Logger.LogWarning("Unable to parse query parameters " + qsQuery);
      Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
      Response.End();
      return;
    }

      if (QueryInfo == null)
    {
      Logger.LogWarning("Unable to load query parameters");
      Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
      Response.End();
      return;
    }

    using (new HighResolutionTimer("QueryService", 5000))
    {

      MTList<SQLRecord> items = new MTList<SQLRecord>();

//      SetPaging(items);
      SetSorting(items);
      SetFilters(items);

      //unable to extract data
      if (!ExtractData(ref items))
      {
        return;
      }

      if (items.Items.Count == 0)
      {
        Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
        Response.End();
        return;
      }

      if ((Page.Request["mode"] != "csv") && (Page.Request["mode"] != "SelectAll"))
      {
        //convert paymentMethods into JSON
        string json = SerializeItems(items);
        Response.Write(json);
      }

      Response.End();
    }

  }

  //populate an array of columns, that are indices into the Fields collection
  protected void PopulateColumnList(MTList<SQLRecord> mtList)
  {

    int columnIndex = 0;
    while (!String.IsNullOrEmpty(Request["column[" + columnIndex.ToString() + "][columnID]"]))
    {
      //column name that we need to look up in the fields collection
      string columnID = Request["column[" + columnIndex.ToString() + "][columnID]"];

      if (mtList.Items.Count > 0)
      {
        SQLRecord curRecord = mtList.Items[0];
        for (int i = 0; i < curRecord.Fields.Count; i++)
        {
          SQLField curField = curRecord.Fields[i];

          if (curField.FieldName.ToLower() == columnID.ToLower() && !exportColumns.Contains(i))
          {
            exportColumns.Add(i);
            break;
          }
        }
      }

      columnIndex++;
    }

  }

  protected string ConvertObjectToCSV(MTList<SQLRecord> mtList, bool bIncludeHeaders)
  {
    StringBuilder sb = new StringBuilder();

    //add headers if necessary
    if (bIncludeHeaders)
    {
      sb.Append(base.GenerateCSVHeader());
      if (sb.ToString().Length > 0)
      {
        sb.Append("\n");
      }
    }

    PopulateColumnList(mtList);

    //iterate through the list of items
    foreach (SQLRecord curRecord in mtList.Items)
    {
      string curRowCSV = ConvertRowToCSV(curRecord);
      sb.Append(curRowCSV);
      sb.Append("\n");
    }

    return sb.ToString();
  }

  protected new string GenerateCSVHeader()
  {
    StringBuilder sb = new StringBuilder();

    //iterate through the fields that we want to extract
    int columnIndex = 0;
    while (!String.IsNullOrEmpty(Request["column[" + columnIndex.ToString() + "][columnID]"]))
    {
      string headerText = Request["column[" + columnIndex.ToString() + "][headerText]"];
      string columnID = Request["column[" + columnIndex.ToString() + "][columnID]"];
      if (columnIndex > 0)
      {
        sb.Append(",");
      }

      sb.Append("\"");
      if (headerText != null)
      {
        sb.Append(headerText.ToString().Replace("\"", "\"\""));
      }
      else
      {
        sb.Append(columnID.ToString().Replace("\"", "\"\""));
      }
      sb.Append("\"");

      columnIndex++;
    }

    return sb.ToString();
  }

  protected string ConvertRowToCSV(SQLRecord curRecord)
  {
    if (curRecord == null)
    {
      return string.Empty;
    }
    StringBuilder sb = new StringBuilder();

    //iterate through columns
    for (int i = 0; i < exportColumns.Count; i++)
    {
      if (i > 0)
      {
        sb.Append(",");
      }

      sb.Append("\"");

      int realFieldID = exportColumns[i];
      if (curRecord.Fields[realFieldID].FieldValue != null)
      {
        sb.Append(curRecord.Fields[realFieldID].FieldValue.ToString().Replace("\"", "\"\""));
      }
      sb.Append("\"");
    }
    return sb.ToString();
  }

  protected string SerializeItems(MTList<SQLRecord> items)
  {

    var jsons = new List<Dictionary<string, string>>();
    for (int i = 0; i < items.Items.Count; i++ )
    {
      SQLRecord record = items.Items[i];

      var json = new Dictionary<string, string>();

      //iterate through fields
      for (int j = 0; j < record.Fields.Count; j++)
      {
        SQLField field = record.Fields[j];
        // decision_object_id
        if (field.FieldName.Equals("decision_object_id") && field.FieldValue != null)
        {
          string[] values = field.FieldValue.ToString().Split(new string[1] { "<|" }, StringSplitOptions.None);
          string[] headers = GetHeaders(Convert.ToInt32(values[0]));
          for (int xyz = 0; xyz < headers.Length; xyz++)
          {
            json[headers[xyz]] = "\"" + values[xyz + 1] + "\"";
          }
          continue;
        }

        if (field.FieldValue == null)
        {
          json[field.FieldName] = "null";
        }
        else
        {
          var json1 = new StringBuilder();
            if (typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType || typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType)
          {
            json1.Append("\"");
          }


            string value = "0";
            if (typeof(Byte[]) == field.FieldDataType)
            {
                System.Text.Encoding enc = System.Text.Encoding.ASCII;
                value = enc.GetString((Byte[])(field.FieldValue));
            }
            else
            {
                value = field.FieldValue.ToString();
            }


          // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
          //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
          // CORE-5938: Audit log: incorrect character encoding in Details row 
          StringBuilder sb = new StringBuilder((value ?? string.Empty).EncodeForHtml());
          sb = sb.Replace("\"", "\\\"");
          //CORE-5320: strip all the new line characters. They are not allowed in jason
          // Oracle can return them and breeak our ExtJs grid with an ugly "Session Time Out" catch all error message
          // TODO: need to find other places where JSON is generated and strip new line characters.
          sb = sb.Replace("\n", "<br />");
          sb = sb.Replace("\r", "");
          string fieldvalue = sb.ToString();

          json1.Append(fieldvalue);

          if (typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType || typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType)
          {
            json1.Append("\"");
          }

          if (!json.ContainsKey(field.FieldName))
          {
            json[field.FieldName] = json1.ToString();
          }
        }
      }

      jsons.Add(json);
    }

    StringBuilder json2 = new StringBuilder();

    json2.Append("{");

    json2.Append("\"TotalRows\":");
    json2.Append(jsons.Count.ToString());
    json2.Append(", \"Items\":[");
    bool first = true;
    foreach (var j in jsons)
    {
      if (!first)
      {
        json2.Append(",");
      }
      first = false;
      bool f = true;
      json2.Append("{");
      foreach (var k in j.Keys)
      {
        if (!f)
        {
          json2.Append(",");
        }
        f = false;
        json2.Append("\"");
        json2.Append(k);
        json2.Append("\":");
        json2.Append(j[k]);
      }
      json2.Append("}");
    }
    json2.Append("]");
//    json2.Append(", \"CurrentPage\":");
//    json2.Append(items.CurrentPage.ToString());
//    json2.Append(", \"PageSize\":");
//    json2.Append(items.PageSize.ToString());
    json2.Append(", \"SortProperty\":");
    if (items.SortCriteria == null || items.SortCriteria.Count == 0)
    {
        json2.Append("null");
        json2.Append(", \"SortDirection\":\"");
        json2.Append(SortType.Ascending.ToString());
    }
    else
    {
        json2.Append("\"");
        json2.Append(items.SortCriteria[0].SortProperty);
        json2.Append("\"");
        json2.Append(", \"SortDirection\":\"");
        json2.Append(items.SortCriteria[0].SortDirection.ToString());

    }
    json2.Append("\"}");

    return json2.ToString();
  }


  // TODO: cache this
  // TODO: THIS IS COPY/PASTED from decision service.  please consolidate...
  public static string[] GetHeaders(int id)
  {
    string[] list = null;
    using (var conn = ConnectionManager.CreateConnection())
    {
      using (var stmt = conn.CreateAdapterStatement("MetraViewServices", "__MVM_GET_COUNTER_HEADERS__"))
      {
        stmt.AddParam("%%FORMAT_ID%%", id);
        using (var rdr = stmt.ExecuteReader())
        {
          while (rdr.Read())
          {
            string a1 = string.Empty;
            if (!rdr.IsDBNull("format_string1"))
            {
              a1 += rdr.GetString("format_string1");
            }
            if (!rdr.IsDBNull("format_string2"))
            {
              a1 += rdr.GetString("format_string2");
            }
            if (!rdr.IsDBNull("format_string3"))
            {
              a1 += rdr.GetString("format_string3");
            }
            if (!rdr.IsDBNull("format_string4"))
            {
              a1 += rdr.GetString("format_string4");
            }
            if (!rdr.IsDBNull("format_string5"))
            {
              a1 += rdr.GetString("format_string5");
            }
            list = a1.ToLowerInvariant().Split(',');
          }
        }
      }
    }
    return list;
  }
}

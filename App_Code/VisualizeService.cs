using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech;
using MetraTech.UI.Controls;
using System.Web.UI.WebControls;

/// <summary>
/// Summary description for VisualizeService
/// </summary>
public class VisualizeService
{
  private const string SqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCore\Queries\UI\Dashboard";
  protected static readonly Logger logger = new Logger("[VisualizeService]");
  private const int MaxDdCount = 50;

  public static void GetData(string connectionInfo, string catalog, string sqlQueryTag,
                             Dictionary<string, object> paramDict, ref MTList<SQLRecord> items)
  {
    var ciDbServer = new ConnectionInfo(connectionInfo) {Catalog = catalog};
    logger.LogInfo("Connection Ifno:" + connectionInfo);

    using (var conn = ConnectionManager.CreateConnection(ciDbServer))
    {
      using (var stmt = conn.CreateAdapterStatement(SqlQueriesPath, sqlQueryTag))
      {
        if (paramDict != null)
        {
          foreach (var pair in paramDict)
          {
            stmt.AddParam(pair.Key, pair.Value);
          }
        }
        using (var reader = stmt.ExecuteReader())
        {
          ConstructItems(reader, ref items);
          // get the total rows that would be returned without paging
        }
      }
    }
  }

  protected static void ConstructItems(IMTDataReader rdr, ref MTList<SQLRecord> items)
  {
    items.Items.Clear();

    while (rdr.Read())
    {
      var record = new SQLRecord();
      for (int i = 0; i < rdr.FieldCount; i++)
      {
        var field = new SQLField {FieldDataType = rdr.GetType(i), FieldName = rdr.GetName(i)};

        if (!rdr.IsDBNull(i))
        {
          field.FieldValue = rdr.GetValue(i);
        }
        record.Fields.Add(field);
      }
      items.Items.Add(record);
    }
  }

  public static string SerializeItems(MTList<SQLRecord> items)
  {
    var json = new StringBuilder();
    json.Append("{\"Items\":[");

    for (int i = 0; i < items.Items.Count; i++)
    {
      var record = items.Items[i];

      if (i > 0)
      {
        json.Append(",");
      }
      json.Append("{");

      for (int j = 0; j < record.Fields.Count; j++)
      {
        var field = record.Fields[j];
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
          if (typeof (String) == field.FieldDataType || typeof (DateTime) == field.FieldDataType ||
              typeof (Guid) == field.FieldDataType || typeof (Byte[]) == field.FieldDataType)
          {
            json.Append("\"");
          }

          string value;
          if (typeof (Byte[]) == field.FieldDataType)
          {
            var enc = Encoding.ASCII;
            value = enc.GetString((Byte[]) (field.FieldValue));
          }
          else
          {
            value = field.FieldValue.ToString();
          }

          // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
          //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
          // CORE-5938: Audit log: incorrect character encoding in Details row 
          var sb = new StringBuilder((value).EncodeForHtml());
          sb = sb.Replace("\"", "\\\"");
          //CORE-5320: strip all the new line characters. They are not allowed in jason
          // Oracle can return them and breeak our ExtJs grid with an ugly "Session Time Out" catch all error message
          // TODO: need to find other places where JSON is generated and strip new line characters.
          sb = sb.Replace("\n", "<br />");
          sb = sb.Replace("\r", "");
          string fieldvalue = sb.ToString();
          json.Append(fieldvalue);

          if (typeof (String) == field.FieldDataType || typeof (DateTime) == field.FieldDataType ||
              typeof (Guid) == field.FieldDataType || typeof (Byte[]) == field.FieldDataType)
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

  public static void ConfigureAndLoadGrid(MTFilterGrid grid, string queryName, string queryPath = SqlQueriesPath,
                                          Dictionary<string, object> paramDict = null)
  {
    var sqi = new SQLQueryInfo {QueryName = queryName, QueryDir = queryPath};

    if (paramDict != null)
    {
      foreach (var pair in paramDict)
      {
        var param = new SQLQueryParam {FieldName = pair.Key, FieldValue = pair.Value};
        sqi.Params.Add(param);
      }
    }
    var qsParam = SQLQueryInfo.Compact(sqi);
    grid.DataSourceURLParams.Add("q", qsParam);
  }

  public static void ConfigureAndLoadDropDowns(MTDropDown dropDown, string colDisplay, string colValue, string queryName,
                                               string queryPath = SqlQueriesPath,
                                               Dictionary<string, object> paramDict = null)
  {
    using (var conn = ConnectionManager.CreateConnection())
    {
      using (var stmt = conn.CreateAdapterStatement(queryPath, queryName))
      {
        if (paramDict != null)
        {
          foreach (var pair in paramDict)
          {
            stmt.AddParam(pair.Key, pair.Value);
          }
        }

        using (var reader = stmt.ExecuteReader())
        {
          var items = new ListItem[MaxDdCount];
          int count = 0;
          int displayOrdinal = 0;
          int valueOrdinal = 0;

          while (reader.Read())
          {
            items[count] = new ListItem();
            if (count == 0)
            {
              for (int i = 0; i < reader.FieldCount; i++)
              {
                if (reader.GetName(i).Equals(colDisplay))
                  displayOrdinal = i;
                if (reader.GetName(i).Equals(colValue))
                  valueOrdinal = i;
              }
              items[count].Selected = true;
            }
            items[count].Text = reader.GetValue(displayOrdinal).ToString();
            items[count].Value = reader.GetValue(valueOrdinal).ToString();

            dropDown.Items.Add(items[count]);
            count = count + 1;
          }
        }
      }
    }
  }
}
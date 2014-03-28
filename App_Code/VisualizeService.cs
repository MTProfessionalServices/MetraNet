using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech;

/// <summary>
///   Summary description for VisualizeService
/// </summary>
public class VisualizeService
{
  private const string sqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCore\Queries\UI\Dashboard";
  protected readonly static Logger logger = new Logger("[VisualizeService]");

  

  public static void GetData(string connectionInfo, string catalog, string sqlQueryTag, Dictionary<string, object> paramDict, ref MTList<SQLRecord> items)
  {
    //System.Diagnostics.Debugger.Break();
    var ciDBServer = new ConnectionInfo(connectionInfo);
    ciDBServer.Catalog = catalog;

   logger.LogInfo("Connection Ifno:" + connectionInfo);

    using (IMTConnection conn = ConnectionManager.CreateConnection(ciDBServer))
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


  protected static void ConstructItems(IMTDataReader rdr, ref MTList<SQLRecord> items)
  {
    items.Items.Clear();

    // process the results
    while (rdr.Read())
    {
      var record = new SQLRecord();


      for (int i = 0; i < rdr.FieldCount; i++)
      {
        var field = new SQLField();
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

  public static string SerializeItems(MTList<SQLRecord> items)
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
          if (typeof (String) == field.FieldDataType || typeof (DateTime) == field.FieldDataType ||
              typeof (Guid) == field.FieldDataType || typeof (Byte[]) == field.FieldDataType)
          {
            json.Append("\"");
          }


          string value = "0";
          if (typeof (Byte[]) == field.FieldDataType)
          {
            Encoding enc = Encoding.ASCII;
            value = enc.GetString((Byte[]) (field.FieldValue));
          }
          else
          {
            value = field.FieldValue.ToString();
          }


          // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
          //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
          // CORE-5938: Audit log: incorrect character encoding in Details row 
          var sb = new StringBuilder((value ?? string.Empty).EncodeForHtml());
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
}
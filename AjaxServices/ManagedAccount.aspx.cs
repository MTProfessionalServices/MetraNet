using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;


public partial class AjaxServices_ManagedAccount : MTListServicePage
{
  string sqlQueriesPath = @"Queries\AccHierarchies";

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

    using (new HighResolutionTimer("ManagedAccount", 5000))
    {
      try
      {
        MTList<SQLRecord> items = new MTList<SQLRecord>();
        Dictionary<string, object> paramDict = new Dictionary<string, object>();

        if (!String.IsNullOrEmpty(UI.Subscriber["_AccountID"]))
        {
          paramDict.Add("%%ACCOUNT_ID%%", int.Parse(UI.Subscriber["_AccountID"]));
        }
        else
        {
          Logger.LogWarning("No account currently managed");
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }

        if (operation.Equals("subscriptionsummary"))
        {
          GetData("__ACCOUNT_SUBSCRIPTIONSUMMARY__", paramDict, ref items);
        }

        if (operation.Equals("paymentsummary"))
        {
          GetData("__ACCOUNT_PAYMENTSUMMARY__", paramDict, ref items);
        }

        if (operation.Equals("invoicesummary"))
        {
          GetData("__ACCOUNT_INVOICESUMMARY__", paramDict, ref items);
        }

        if (operation.Equals("balancesummary"))
        {
          GetData("__ACCOUNT_BALANCESUMMARY__", paramDict, ref items);
        }

        if (operation.Equals("billingsummary"))
        {
          GetData("__ACCOUNT_BILLINGSUMMARY__", paramDict, ref items);
        }

        if (operation.Equals("discountcommitmentsummary"))
        {
          GetData("__ACCOUNT_DISCOUNTANDCOMMITMENTSUMMARY__", paramDict, ref items);
        }

        if (items.Items.Count == 0)
        {
          Response.Write("{\"Items\":[]}");
          Response.End();
        }
        else
        {
          string json = SerializeItems(items);
          Logger.LogInfo("Returning " + json);
          Response.Write(json);
          Response.End();
        }

      }
      catch (ThreadAbortException ex)
      {
        //Looks like Response.End is deprecated/changed
        //Might have a lot of unhandled exceptions in product from when we call response.end
        //http://support.microsoft.com/kb/312629
        Logger.LogError("Thread Abort Exception: {0} {1}", ex.Message, ex.ToString());
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
  }

  protected string SerializeItems(MTList<SQLRecord> items)
  {
    StringBuilder json = new StringBuilder();

    //json.Append("{\"TotalRows\":");
    //json.Append(items.TotalRows.ToString());

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

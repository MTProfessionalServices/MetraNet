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


public partial class AjaxServices_VisualizeService : MTListServicePage
{
    string sqlQueriesPath = @"..\Extensions\SystemConfig\config\SqlCustom\Queries\UI\Dashboard";

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

        using (new HighResolutionTimer("QueryService", 5000))
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
                GetData("__GET_FAILEDTRANSACTIONS_OVERXDAYS__",paramDict,ref items);
            }
            else if (operation.Equals("ft30dayaging"))
            {
                

               GetData("__GET_FAILEDTRANSACTIONS_30DAYAGING__", null, ref items);
            }
            else if (operation.Equals("ftgettotal"))
            {


                GetData("__GET_FAILEDTRANSACTIONS_TOTAL__", null, ref items);
            }
            else if (operation.Equals("batchusage30day"))
            {


                GetData("__GET_BATCHUSAGE_30DAYBATCHESUDR__", null, ref items);
            }
            else if (operation.Equals("getlastbatch"))
            {


                GetData("__GET_BATCHUSAGE_LASTBATCH__", null, ref items);
            }
            else if (operation.Equals("activebillrun") || operation.Equals("activebillrunsummary"))
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

                if (operation.Equals("activebillrun"))
                {
                    GetData("__GET_ACTIVEBILLRUN_CURRENTAVERAGE__", paramDict, ref items);
                }
                else if (operation.Equals("activebillrunsummary"))
                {

                    GetData("__GET_ACTIVEBILLRUN_SUMMARY__", paramDict, ref items);
                }
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
                    GetData("__GET_BILLCLOSESYNOPSIS_DETAILS__", paramDict, ref items);
                else
                    GetData("__GET_BILLCLOSESYNOPSIS_SUMMARY__", paramDict, ref items);

            }


            if (items.Items.Count == 0)
            {
                Response.Write("{\"Items\":[]}");
                Response.End();
                return;
            }

            string json = SerializeItems(items);
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

    for (int i = 0; i < items.Items.Count; i++ )
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

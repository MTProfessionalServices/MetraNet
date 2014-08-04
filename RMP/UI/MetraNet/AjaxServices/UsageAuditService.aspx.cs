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


public partial class AjaxServices_UsageAuditService : MTListServicePage
{
  protected SQLQueryInfo QueryInfo;
  protected void Page_Load(object sender, EventArgs e)
  {
    //parse query name
    String qsQuery = Request["urlparam_q"];
    if (string.IsNullOrEmpty(qsQuery))
    {
      Logger.LogWarning("No query specified");
      Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
      Response.End();
      return;
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

    var nmPvTable = string.Empty;
    var idUsageInterval = string.Empty;
    var idSess = string.Empty;
    bool? bChanged = null;
    var filters = new Dictionary<string, string>();
    int filterID = 0;
    while (!String.IsNullOrEmpty(this.Request["filter[" + filterID.ToString() + "][field]"]))
    {
      string propertyName = this.Request["filter[" + filterID.ToString().Replace("#", "") + "][field]"];
      if (String.IsNullOrEmpty(propertyName))
      {
        filterID++;
        continue;
      }
      var value = this.Request["filter[" + filterID.ToString() + "][data][value]"];

//      Logger.LogFatal(propertyName + "(" + this.Request["filter[" + filterID.ToString() + "][data][comparison]"] + ") = " + value);
      if (string.IsNullOrEmpty(this.Request["filter[" + filterID.ToString() + "][data][comparison]"]) || "eq".Equals(this.Request["filter[" + filterID.ToString() + "][data][comparison]"]) || "lk".Equals(this.Request["filter[" + filterID.ToString() + "][data][comparison]"]))
      {
        if ("nm_pv_table".Equals(propertyName))
        {
          nmPvTable = value;
        }
        else if ("id_usage_interval".Equals(propertyName))
        {
          idUsageInterval = value;
        }
        else if ("id_sess".Equals(propertyName))
        {
          idSess = value;
        }
        else if ("b_changed".Equals(propertyName))
        {
          bChanged = Convert.ToBoolean(value);
        }
        else
        {
          filters[propertyName] = value;
        }
      }
      filterID++;
    }

    using (new HighResolutionTimer("QueryService", 5000))
    {

      // open the connection
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        // Get a filter/sort statement
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueryInfo.QueryDir, QueryInfo.QueryName))
        {
          stmt.AddParam("%%NM_PV_TABLE%%", nmPvTable);
          stmt.AddParam("%%ID_INTERVAL%%", idUsageInterval);
          stmt.AddParam("%%ID_SESS%%", idSess);

          // execute the query
          using (IMTDataReader rdr = stmt.ExecuteReader())
          {

            // process the results
            while (rdr.Read())
            {
              // load orig
              if (rdr.IsDBNull("orig_values_packed"))
              {
                continue;
              }
              var origValuesPacked = rdr.GetString("orig_values_packed");
              var origInterval = string.Empty;
              if (!rdr.IsDBNull("orig_usage_interval"))
              {
                origInterval = rdr.GetInt32("orig_interval").ToString();
              }
              // parse orig
              var orig = new Dictionary<string, string>();
              string[] values = origValuesPacked.Split(new string[1] { ","/*"<|"*/ }, StringSplitOptions.None);
              string[] headers = GetHeaders(Convert.ToInt32(values[0]));
              for (int j = 0; j < headers.Length; j++)
              {
                orig[headers[j]] = values[j + 1];
              }
              var diff = new List<AuditDiff>();
              for (int i = 0; i < rdr.FieldCount; i++)
              {
                var nmColumn = rdr.GetName(i);

                if (filters.ContainsKey("nm_column") && !filters["nm_column"].Equals(nmColumn))
                {
                  continue;
                }

                if (!nmColumn.Equals("orig_values_packed") && !nmColumn.Equals("orig_usage_interval"))
                {
                  var value = string.Empty;

                  if (!rdr.IsDBNull(i))
                  {
                    var v = rdr.GetValue(i);
//                    Logger.LogFatal(nmColumn + "(" + v.GetType().Name + "): " + v);
                    if (v is DateTime)
                    {
                      var d = (DateTime)v;
                      value = d.ToString("yyyy-MM-dd HH:mm:ss.fff");
                    }
                    else if (v is Guid)
                    {
                      value = ((Guid) v).ToString("N").ToUpper();
                    }
                    else if (v is Byte[])
                    {
                      try
                      {
                        value = new Guid((Byte[]) v).ToString("N").ToUpper();
                      }
                      catch (Exception ex)
                      {
                        Logger.LogException("Unable to create guid for byte[]", ex);
                        value = Convert.ToString(v);
                      }
                    }
                    else
                    {
                      value = Convert.ToString(v);
                    }
                  }
                  AuditDiff df = null;
                  if (orig.ContainsKey(nmColumn))
                  {
                    df = new AuditDiff(nmColumn, orig[nmColumn], value);
                  }
                  else if (nmColumn.Equals("id_usage_interval") && !string.IsNullOrEmpty(origInterval))
                  {
                    df = new AuditDiff(nmColumn, origInterval, value);
                  }
                  else
                  {
                    df = new AuditDiff(nmColumn, value, value);
                  }

                  if (filters.ContainsKey("tx_before") && !filters["tx_before"].Equals(df.tx_before))
                  {
                    continue;
                  }

                  if (filters.ContainsKey("tx_after") && !filters["tx_after"].Equals(df.tx_after))
                  {
                    continue;
                  }

                  if ((!bChanged.HasValue) || (bChanged.Value == df.b_changed))
                  {
                    diff.Add(df);
                  }
                }

              }

              var json = Newtonsoft.Json.JsonConvert.SerializeObject(diff);
              Response.Write("{\"TotalRows\":" + diff.Count + ",\"Items\":" + json + "}");
              Response.End();
              return;
            }
          }
        }
      }

    }
    Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
    Response.End();
    return;
  }

  //    json.Append(", \"CurrentPage\":");
  //    json.Append(", \"PageSize\":");
  //    json.Append(", \"SortProperty\":");
  //        json.Append("null");
  //        json.Append(", \"SortDirection\":\"");
  //        json.Append(SortType.Ascending.ToString());
  
  public class AuditDiff
  {
    public string nm_column { get; set; }
    public string tx_before { get; set; }
    public string tx_after { get; set; }
    public bool b_changed { get; set; }

    public AuditDiff(string nmColumn, string txBefore, string txAfter)
    {
      this.nm_column = nmColumn;
      this.tx_before = txBefore;
      this.tx_after = txAfter;
      this.b_changed = !this.tx_before.Equals(this.tx_after);
    }
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

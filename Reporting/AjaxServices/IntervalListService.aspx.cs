using System;
using System.Text;
using MetraTech.UI.Common;
using MetraTech;
using MTYAAC = MetraTech.Interop.MTYAAC;
using Rowset = MetraTech.Interop.Rowset;
using MetraTech.UI.Tools;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTProductCatalog;

public partial class AjaxServices_IntervalListService : MTPage
{
    private const string EMPTY_JSON = "{\"TotalRows\":\"0\",\"records\":[]}";

    protected void Page_Load(object sender, EventArgs e)
    {
        string cycleType = Request["CycleType"];

        MetraTech.Interop.Rowset.IMTSQLRowset rowset = new MetraTech.Interop.Rowset.MTSQLRowset();
        rowset.Init("\\dummy");
        rowset.SetQueryString(
            "select ui.id_interval, ui.dt_start, ui.dt_end from t_usage_interval ui join t_usage_cycle uc on ui.id_usage_cycle = uc.id_usage_cycle join t_usage_cycle_type uct on uc.id_cycle_type = uct.id_cycle_type where uct.id_cycle_type = %%CYCLETYPE%% order by 1 desc");
        rowset.AddParam("%%CYCLETYPE%%", cycleType);
        rowset.Execute();

        if ((rowset == null) || (rowset.RecordCount == 0))
        {
            Response.Write(EMPTY_JSON);
            Response.End();
            return;
        }

        //string json = Converter.GetRowsetAsJson(rowset, 0, 1000);
        string json = GetIntervalListAsJson(rowset, 0, 1000);
        Response.Write("{" + json + "}");
        Response.End();
    }


    private static string GetIntervalListAsJson(Rowset.IMTRowSet rs, int start, int limit)
    {
        StringBuilder sb = new StringBuilder();

        sb.Append("[");
        rs.MoveFirst();
        bool bFirst = true;
        int count = 0;

        while (!Convert.ToBoolean(rs.EOF))
        {
            if (count >= start && count < start + limit)
            {
                if (!bFirst)
                {
                    sb.Append(",");
                }
                else
                {
                    bFirst = false;
                }

                sb.Append("{");
                sb.Append(
                    String.Format("\"value\":\"{0}\",\"text\":\"{1} - {2} ({0})\"", 
                        rs.get_Value(0),
                        ((DateTime) rs.get_Value(1)).ToShortDateString(),
                        ((DateTime) rs.get_Value(2)).ToShortDateString()
                        )
                    );
                sb.Append("}");
            }

            count++;
            rs.MoveNext();
        }
        sb.Append("]");
        string json = String.Format("\"TotalRows\":\"{0}\",\"records\":{1}", rs.RecordCount.ToString(), sb.ToString());
        return json;
    }

}

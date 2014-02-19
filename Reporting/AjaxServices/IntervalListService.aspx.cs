using System;
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
        rowset.SetQueryString("select ui.id_interval, ui.dt_start, ui.dt_end from t_usage_interval ui join t_usage_cycle uc on ui.id_usage_cycle = uc.id_usage_cycle join t_usage_cycle_type uct on uc.id_cycle_type = uct.id_cycle_type where uct.id_cycle_type = %%CYCLETYPE%% order by 1 desc");
        rowset.AddParam("%%CYCLETYPE%%", cycleType);
        rowset.Execute();

        if ((rowset == null) || (rowset.RecordCount == 0))
        {
            Response.Write(EMPTY_JSON);
            Response.End();
            return;
        }

        string json = Converter.GetRowsetAsJson(rowset, 0, 1000);
        Response.Write("{" + json + "}");
        Response.End();
    }

}
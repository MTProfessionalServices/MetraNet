using System;
using MetraTech.UI.Common;
using MetraTech;
using MTYAAC = MetraTech.Interop.MTYAAC;
using Rowset = MetraTech.Interop.Rowset;
using MetraTech.UI.Tools;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTProductCatalog;

public partial class AjaxServices_BillGroupListService : MTPage
{
    private const string EMPTY_JSON = "{\"TotalRows\":\"0\",\"records\":[]}";

    protected void Page_Load(object sender, EventArgs e)
    {
        string intervalId = Request["IntervalId"];

        MetraTech.Interop.Rowset.IMTSQLRowset rowset = new MetraTech.Interop.Rowset.MTSQLRowset();
        rowset.Init("\\dummy");
        rowset.SetQueryString("select id_billgroup, tx_name from t_billgroup where id_usage_interval = %%INTERVALID%%");
        rowset.AddParam("%%INTERVALID%%", intervalId);
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
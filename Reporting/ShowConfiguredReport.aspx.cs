using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class ShowConfiguredReport : MTPage
{
    private string internalId = "";
    private string queryName = "";
    private string extension = "";
    private string gridLayoutName = "";

    protected override void OnLoad(EventArgs e)
    {
        internalId = Request["InternalId"];
        gridLayoutName = Request["GridLayoutName"];
        queryName = Request["QueryName"];
        extension = Request["Extension"];

        // Override Extensions and Template so they load from the right place
        MTFilterGridBasicReport.ExtensionName = extension;
        MTFilterGridBasicReport.TemplateFileName = gridLayoutName;

        // MTFilterGridBasicReport.Title = gridLayoutName;

        base.OnLoad(e);
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        // Override whatever may have been loaded from the grid layout
        MTFilterGridBasicReport.DataSourceURL = "~/AjaxServices/QueryService.aspx"; // Use generic AJAX service to execute query

        SQLQueryInfo sqi = new SQLQueryInfo();
        sqi.QueryName = queryName;
        sqi.QueryDir = "dummy"; // No longer required by Query Manager

        //SQLQueryParam param = new SQLQueryParam();
        //param.FieldName = "%%ENTITY_TYPE%%";
        //param.FieldValue = "1";
        //sqi.Params.Add(param);


        if (!string.IsNullOrEmpty(Request["IntervalId"]))
        {
            int intervalId = int.Parse(Request["IntervalId"]);
            SQLQueryParam param = new SQLQueryParam();
            param.FieldName = "%%ID_INTERVAL%%";
            param.FieldValue = intervalId;
            sqi.Params.Add(param);

            // Add Language (hardcoded for now until I can figure out how to map .Net Locale to MT language codes
            SQLQueryParam paramLang = new SQLQueryParam();
            paramLang.FieldName = "%%ID_LANG_CODE%%";
            paramLang.FieldValue = 840;
            sqi.Params.Add(paramLang);
        }

        if (!string.IsNullOrEmpty(Request["BillGroupId"]))
        {
            int billGroupId = int.Parse(Request["BillGroupId"]);
            SQLQueryParam param = new SQLQueryParam();
            param.FieldName = "%%ID_BILLINGGROUP%%";
            param.FieldValue = billGroupId;
            sqi.Params.Add(param);
        }

        string qsParam = SQLQueryInfo.Compact(sqi);
        MTFilterGridBasicReport.DataSourceURLParams.Clear();
        MTFilterGridBasicReport.DataSourceURLParams.Add("q", qsParam);

        base.OnLoadComplete(e);
    }

}

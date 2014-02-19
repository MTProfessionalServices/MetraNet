using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class ShowBasicReport : MTPage
{
    private string templateFileName = "";
    private string queryName = "";
    private string extension = "";

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

        string qsParam = SQLQueryInfo.Compact(sqi);
        MTFilterGridBasicReport.DataSourceURLParams.Add("q", qsParam);

        base.OnLoadComplete(e);
    }

    protected override void OnLoad(EventArgs e)
    {
        templateFileName = Request["GridLayoutName"];
        queryName = Request["QueryName"];
        extension = Request["Extension"];

        // Override Extensions and Template so they load from the right place
        MTFilterGridBasicReport.ExtensionName = extension;
        MTFilterGridBasicReport.TemplateFileName = templateFileName;

        base.OnLoad(e);
    }

}

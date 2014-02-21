using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class ShowBasicReport : MTPage
{
    private string templateFileName = "";
    public string queryName = "";
    private string extension = "";
	public string queryUrl = "";
	public string queryParam = "";

    protected override void OnLoadComplete(EventArgs e)
    {
        base.OnLoadComplete(e);
    }

    protected override void OnLoad(EventArgs e)
    {
        templateFileName = Request["GridLayoutName"];
        queryName = Request["QueryName"];
        extension = Request["Extension"];
		
//		if (string.IsNullOrEmpty(templateFileName))
		{
			templateFileName = "BasicReport";
		}

        queryUrl = "/MetraNet/AjaxServices/QueryService.aspx"; // Use generic AJAX service to execute query

        SQLQueryInfo sqi = new SQLQueryInfo();
        sqi.QueryName = queryName;
        sqi.QueryDir = "dummy"; // No longer required by Query Manager

        //SQLQueryParam param = new SQLQueryParam();
        //param.FieldName = "%%ENTITY_TYPE%%";
        //param.FieldValue = "1";
        //sqi.Params.Add(param);

        queryParam = SQLQueryInfo.Compact(sqi);

        base.OnLoad(e);
    }

}

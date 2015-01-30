using System;
using MetraTech.UI.Common;

public partial class ShowBasicReport : MTPage
{
  private string internalId = "";
  public string reportName = "";
  private string queryName = "";
  //private string extension = "";
  //private string gridLayoutName = "";


  public string queryUrl = "";
  public string queryParam = "";

  protected override void OnLoadComplete(EventArgs e)
  {
    base.OnLoadComplete(e);
  }

  protected override void OnLoad(EventArgs e)
  {
    internalId = Request["InternalId"];
    reportName = Request["Name"];
    queryName = Request["QueryName"];

    // if (string.IsNullOrEmpty(gridLayoutName))
    //{
    //  gridLayoutName = "BasicReport";
    //  extension = "Reporting";
    //}

    queryUrl = "/MetraNet/AjaxServices/QueryService.aspx?limit=10000"; // Use generic AJAX service to execute query

    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = queryName;
    sqi.QueryDir = "dummy"; // No longer required by Query Manager

    //SQLQueryParam param = new SQLQueryParam();
    //param.FieldName = "%%ENTITY_TYPE%%";
    //param.FieldValue = "1";
    //sqi.Params.Add(param);

    SQLQueryParam paramLang = new SQLQueryParam();
    paramLang.FieldName = "%%ID_LANG_CODE%%";
    paramLang.FieldValue = UI.User.SessionContext.LanguageID;
    sqi.Params.Add(paramLang);

    queryParam = SQLQueryInfo.Compact(sqi);

    base.OnLoad(e);
  }

}

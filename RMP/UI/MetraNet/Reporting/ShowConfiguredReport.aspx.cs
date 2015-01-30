using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class ShowConfiguredReport : MTPage
{
  #region Properties

  public string ReturnUrl
  {
    get { return ViewState["ReturnURL"] as string; }
    set { ViewState["ReturnURL"] = value; }
  }

  #endregion

  #region Variables

  private string internalId = "";
  private string reportName = "";
  private string queryName = "";
  private string extension = "";
  private string gridLayoutName = "";

  #endregion

  #region Events

  protected override void OnLoad(EventArgs e)
  {
    internalId = Request["InternalId"];
    reportName = Request["Name"];
    queryName = Request["QueryName"];
    extension = Request["Extension"];
    gridLayoutName = Request["GridLayoutName"];

    // Override Extensions and Template so they load from the right place
    MTFilterGridReport.ExtensionName = extension;
    MTFilterGridReport.TemplateFileName = gridLayoutName;

    base.OnLoad(e);
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    MTFilterGridReport.Title = reportName;

    // By default add back/previous button for all the reports
    MTFilterGridReport.Buttons = MTButtonType.Back;

    // Override whatever may have been loaded from the grid layout
    MTFilterGridReport.DataSourceURL = "~/AjaxServices/QueryService.aspx"; // Use generic AJAX service to execute query

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
    }

    if (!string.IsNullOrEmpty(Request["BillGroupId"]))
    {
      int billGroupId = int.Parse(Request["BillGroupId"]);
      SQLQueryParam param = new SQLQueryParam();
      param.FieldName = "%%ID_BILLINGGROUP%%";
      param.FieldValue = billGroupId;
      sqi.Params.Add(param);
    }

    SQLQueryParam paramLang = new SQLQueryParam();
    paramLang.FieldName = "%%ID_LANG_CODE%%";
    paramLang.FieldValue = UI.User.SessionContext.LanguageID;
    sqi.Params.Add(paramLang);

    string qsParam = SQLQueryInfo.Compact(sqi);
    MTFilterGridReport.DataSourceURLParams.Clear();
    MTFilterGridReport.DataSourceURLParams.Add("q", qsParam);

    PartitionLibrary.SetupFilterGridForPartitionSystemUser(MTFilterGridReport, "Partition", false);
    base.OnLoadComplete(e);
  }


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      ResolveReturnURL();
    }
  }

  #endregion

  #region Private Methods

  private void ResolveReturnURL()
  {
    if (String.IsNullOrEmpty(Request["ReturnURL"]))
    {
      ReturnUrl = Request.UrlReferrer != null
                    ? Request.UrlReferrer.ToString()
                    : UI.DictionaryManager["DashboardPage"].ToString();
    }
    else
    {
      ReturnUrl = Request["ReturnURL"].Replace("'", "").Replace("|", "?").Replace("**", "&");
    }
  }

  #endregion
}

using System;
using MetraTech.UI.Common;

public partial class Metraflow_Step_Log : MTPage
{
  public string RouteTo
  {
    get { return ViewState["RouteTo"] as string; }
    set { ViewState["RouteTo"] = value; }
  }

  protected void Page_load(EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
    {
      Response.End();
      return;
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    if (Request.UrlReferrer != null)
      RouteTo = !String.IsNullOrEmpty(Request.QueryString["url"]) ? Decrypt(Request.QueryString["url"]) : Request.UrlReferrer.ToString();

    var sqi = new SQLQueryInfo();
    sqi.QueryName = "__SELECT_METRAFLOW_STEP_LOG__";
    sqi.QueryDir = "Queries\\Database";

    var param = new SQLQueryParam();
    param.FieldName = "%%TRACKING_ID%%";
    param.FieldValue = Request.QueryString["trackingID"];

    sqi.Params.Add(param);

    string qsParam = SQLQueryInfo.Compact(sqi);
    MyGrid1.DataSourceURLParams.Add("q", qsParam);
        
    base.OnLoadComplete(e);
  }
  
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(RouteTo);
  }
}

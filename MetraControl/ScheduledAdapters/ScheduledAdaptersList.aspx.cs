using System;
using MetraTech.UI.Common;

public partial class ScheduledAdaptersList : MTPage
{
  private const string QueryName = "__GET_SCHEDULED_ADAPTER_LIST__";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    var sqi = new SQLQueryInfo {QueryName = QueryName, QueryDir = "dummy"};

    var param = new SQLQueryParam {FieldName = "%%ID_LANG_CODE%%", FieldValue = UI.SessionContext.LanguageID};
    sqi.Params.Add(param);

    var qsParam = SQLQueryInfo.Compact(sqi);
    ScheduledAdaptersListGrid.DataSourceURLParams.Clear();
    ScheduledAdaptersListGrid.DataSourceURLParams.Add("q", qsParam);

    base.OnLoadComplete(e);
  }
}

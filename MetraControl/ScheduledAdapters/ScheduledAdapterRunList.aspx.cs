using System;
using System.Data.SqlTypes;
using System.Globalization;
using MetraTech.UI.Common;
using Newtonsoft.Json;

namespace MetraNet.MetraControl.ScheduledAdapters
{
  public partial class ScheduledAdapterRunList : MTPage
  {
    protected static string JsonLocalizedStatuses;

    protected int Duration;

    protected void Page_Load(object sender, EventArgs e)
    {
      if (IsPostBack) return;

      if (!String.IsNullOrEmpty(Request["duration"]))
        Int32.TryParse(Request["duration"], out Duration);

      if (!UI.CoarseCheckCapability("Manage Scheduled Adapters")) Response.End();
      JsonLocalizedStatuses = JsonConvert.SerializeObject(Formatters.GetAdapterInstanceStatusesLocalized());
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      ScheduledAdapterRunListGrid.DataSourceURL = "~/AjaxServices/QueryService.aspx";
      var sqi = new SQLQueryInfo { QueryName = "__GET_SCHEDULED_ADAPTER_RUN_LIST__" };
      var param = new SQLQueryParam { FieldName = "%%END_DATE%%", FieldValue = (Duration != 0 ? DateTime.Now.AddHours(Duration) : SqlDateTime.MinValue.Value).ToString(CultureInfo.InvariantCulture)};
      sqi.Params.Add(param);
      param = new SQLQueryParam { FieldName = "%%ID_LANG_CODE%%", FieldValue = UI.SessionContext.LanguageID};
      sqi.Params.Add(param);
      param = new SQLQueryParam { FieldName = "%%MIN_DATE%%", FieldValue = SqlDateTime.MinValue.Value.ToString(CultureInfo.InvariantCulture) };
      sqi.Params.Add(param);
      var qsParam = SQLQueryInfo.Compact(sqi);
      ScheduledAdapterRunListGrid.DataSourceURLParams.Clear();
      ScheduledAdapterRunListGrid.DataSourceURLParams.Add("q", qsParam);
      base.OnLoadComplete(e);
    }
  }
}
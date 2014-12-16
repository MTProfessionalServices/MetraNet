using System;
using System.Globalization;
using System.Threading;
using System.Web;
using MetraTech.DataAccess;
using MetraTech.UI.Common;

public partial class AdapterInstanceInformation : MTPage
{
  protected string InstanceId;
  protected string DisplayName;
  protected string Status;
  protected string StatusText;
  protected string ArgStartDate;
  protected string ArgEndDate;
  protected string DisplayNameEncoded;
  protected string BillingGroupId;
  protected string IntervalId;
  private string _reverseMode;
  private string _disableActions;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage EOP Adapters"))
    {
      Response.End();
      return;
    }

    InstanceId = Request["ID"];
    IntervalId = Request["IntervalId"];
    BillingGroupId = Request["BillingGroupId"];
    _disableActions = Request["DisableActions"];
    btnRefresh.Text = Resources.JSConsts.TEXT_NOWCAST_REFRESH;
    btnCancel.Text = Resources.JSConsts.TEXT_CANCEL;

    if (IsPostBack)
    {
      if (Request.Form["__EVENTTARGET"] == btnRunAdaptersLater.ClientID)
      {
        btnRunAdaptersLater_Click(this, new EventArgs());
      }
      else if (Request.Form["__EVENTTARGET"] == btnRevertAdaptersLater.ClientID)
      {
        btnRevertAdapters_Click(this, new EventArgs());
      }
      return;
    }
    InitControls();
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    if (String.IsNullOrEmpty(InstanceId)) return;
    AdapterInstanceRunHistoryGrid.DataSourceURL = "~/AjaxServices/QueryService.aspx";
    AuditHistoryGrid.DataSourceURL = "~/AjaxServices/QueryService.aspx";

    int paramValue;
    Int32.TryParse(InstanceId, out paramValue);
    var sqi = new SQLQueryInfo { QueryName = "__GET_ADAPTER_RUN_LIST_FOR_INSTANCE__" };
    var param = new SQLQueryParam { FieldName = "%%ID_INSTANCE%%", FieldValue = paramValue };
    sqi.Params.Add(param);
    var qsParam = SQLQueryInfo.Compact(sqi);
    AdapterInstanceRunHistoryGrid.DataSourceURLParams.Clear();
    AdapterInstanceRunHistoryGrid.DataSourceURLParams.Add("q", qsParam);

    sqi = new SQLQueryInfo { QueryName = "__GET_ADAPTER_INSTANCE_AUDIT_HISTORY__" };
    if (!String.IsNullOrEmpty(BillingGroupId) && Int32.TryParse(BillingGroupId, out paramValue))
    {
      sqi.QueryName = "__GET_BILLINGGROUP_ADAPER_AUDIT_HISTORY__";
      param = new SQLQueryParam { FieldName = "%%ID_BILLGROUP%%", FieldValue = paramValue };
    }
    else if (!String.IsNullOrEmpty(BillingGroupId) && Int32.TryParse(BillingGroupId, out paramValue))
    {
      sqi.QueryName = "__GET_INTERVAL_ADAPER_AUDIT_HISTORY__";
      param = new SQLQueryParam { FieldName = "%%ID_INTERVAL%%", FieldValue = paramValue };
    }
    sqi.Params.Add(param);
    qsParam = SQLQueryInfo.Compact(sqi);
    AuditHistoryGrid.DataSourceURLParams.Clear();
    AuditHistoryGrid.DataSourceURLParams.Add("q", qsParam);

    base.OnLoadComplete(e);
  }

  private void InitControls()
  {
    LoadSummaryInfo();
    lblInstanceIdValue.Text = InstanceId;
    lblAdapterValue.Text = DisplayName;
    lblArgEndValue.Text = ArgEndDate;
    lblArgStartValue.Text = ArgStartDate;
    lblStatusValue.Text = StatusText;

    bool bShowReverseOption = false;
    bool bShowRunOption = false;
    bool bShowMarkAsNotReadyToRun = false;

    // Determine button state
    switch (Status)
    {
      case "Failed":
      case "Succeeded":
        bShowReverseOption = true;
        break;
      case "ReadyToRun":
      case "ReadyToReverse":
        bShowMarkAsNotReadyToRun = true;
        break;
      case "NotYetRun":
        bShowRunOption = true;
        break;
    }

    if (_reverseMode == "NotImplemented")
      bShowReverseOption = false;

    if (_disableActions == "true")
    {
      bShowReverseOption = false;
      bShowRunOption = false;
      bShowMarkAsNotReadyToRun = false;
    }
    btnRunAdapters.Enabled = btnRunAdaptersLater.Enabled = bShowRunOption;
    btnRevertAdapters.Enabled = btnRevertAdaptersLater.Enabled = bShowReverseOption;
    btnCancelSubmittedAction.Enabled = bShowMarkAsNotReadyToRun;
    btnHistory.Enabled = !String.IsNullOrEmpty(DisplayName);
  }

  private void LoadSummaryInfo()
  {
    using (IMTConnection conn = ConnectionManager.CreateConnection())
    {
      using (var stmt = conn.CreateAdapterStatement(@"..\config\SqlCore\Queries\mom", "__GET_ADAPTER_INSTANCE_INFORMATION__"))
      {
        int paramValue;
        Int32.TryParse(InstanceId, out paramValue);
        stmt.AddParam("%%ID_INSTANCE%%", paramValue);
        stmt.AddParam("%%ID_LANG_CODE%%", UI.SessionContext.LanguageID);

        using (var reader = stmt.ExecuteReader())
        {
          while (reader.Read())
          {
            Status = reader.IsDBNull("Status") ? "" : reader.GetString("Status");
            StatusText = MetraNet.Formatters.GetAdapterInstanceStatusMessage(Status, reader.IsDBNull("EffectiveDate") ? (DateTime?)null : reader.GetDateTime("EffectiveDate"));
            DisplayName = reader.IsDBNull("tx_display_name") ? "" : HttpUtility.HtmlEncode(reader.GetString("tx_display_name"));
            DisplayNameEncoded = HttpUtility.UrlEncode(DisplayName);
            _reverseMode = reader.IsDBNull("ReverseMode") ? "" : reader.GetString("ReverseMode");
            ArgStartDate = reader.IsDBNull("ArgStartDate") ? "" : reader.GetDateTime("ArgStartDate").ToString(Thread.CurrentThread.CurrentUICulture);
            ArgEndDate = reader.IsDBNull("ArgEndDate") ? "" : reader.GetDateTime("ArgEndDate").ToString(Thread.CurrentThread.CurrentUICulture);
          }
        }
      }
    }
  }

  protected void btnRunAdapters_Click(object sender, EventArgs e)
  {
    try
    {
      var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };

      usmClient.SubmitEventForExecution(Convert.ToInt32(InstanceId), false, "");
      usmClient.NotifyServiceOfSubmittedEvents();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
    }
    InitControls();
  }

  protected void btnRunAdaptersLater_Click(object sender, EventArgs e)
  {
    try
    {
      DateTime laterOn;
      if (String.IsNullOrEmpty(dtRunRevertOn.Text) ||
          !DateTime.TryParse(dtRunRevertOn.Text, Thread.CurrentThread.CurrentUICulture, DateTimeStyles.AssumeLocal, out laterOn))
        return;

      var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };
      usmClient.SubmitEventForExecution(Convert.ToInt32(InstanceId), false, laterOn, "");
      usmClient.NotifyServiceOfSubmittedEvents();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
    }
    InitControls();
  }

  protected void btnRevertAdapters_Click(object sender, EventArgs e)
  {
    try
    {
      var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };

      usmClient.SubmitEventForReversal(Convert.ToInt32(InstanceId), false, "");
      usmClient.NotifyServiceOfSubmittedEvents();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
    }
    InitControls();
  }

  protected void btnRevertAdaptersLater_Click(object sender, EventArgs e)
  {
    try
    {
      DateTime laterOn;
      if (String.IsNullOrEmpty(dtRunRevertOn.Text) ||
          !DateTime.TryParse(dtRunRevertOn.Text, Thread.CurrentThread.CurrentUICulture, DateTimeStyles.AssumeLocal, out laterOn))
        return;

      var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };
      usmClient.SubmitEventForReversal(Convert.ToInt32(InstanceId), false, laterOn, "");
      usmClient.NotifyServiceOfSubmittedEvents();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
    }
    InitControls();
  }

  protected void btnCancelSubmittedAction_Click(object sender, EventArgs e)
  {
    try
    {
      var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };
      usmClient.CancelSubmittedEvent(Convert.ToInt32(InstanceId), "");
      usmClient.NotifyServiceOfSubmittedEvents();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
    }
    InitControls();
  }

  protected string GetDurationMessage(string value, string dtEnd)
  {
    return value + " - " + dtEnd;
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    var returnUrl = !String.IsNullOrEmpty(Request.QueryString["ReturnUrl"])
                  ? Request.QueryString["ReturnUrl"]
                  : Request.Url.AbsolutePath.Remove(Request.Url.AbsolutePath.IndexOf(Request.ApplicationPath, StringComparison.InvariantCulture) + Request.ApplicationPath.Length);
    Response.Redirect(returnUrl, false);
  }

  protected void btnRefresh_Click(object sender, EventArgs e)
  {
    InitControls();
  }
}
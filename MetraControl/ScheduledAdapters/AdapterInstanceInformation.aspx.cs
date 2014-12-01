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
  private string DisableActions;

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
    DisableActions = Request["DisableActions"];
    if (IsPostBack)
    {
      if (Request.Form["__EVENTTARGET"] == btnRunAdaptersLater.ClientID)
      {
        btnRunAdaptersLater_Click(this, new EventArgs());
      }
      else if (Request.Form["__EVENTTARGET"] == btnRevertAdaptersLater.ClientID) {
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
    //var IntervalDescription = Request["IntervalDescription"];
    //lblArgStart.Visible = lblArgEnd.Visible = lblArgStartValue.Visible = lblArgEndValue.Visible = !String.IsNullOrEmpty(IntervalDescription);
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

    if (DisableActions == "true")
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

        using (var reader = stmt.ExecuteReader())
        {
          while (reader.Read())
          {
            Status = reader.IsDBNull("Status") ? "" : reader.GetString("Status");
            StatusText = MetraNet.Formatters.GetAdapterInstanceStatusMessage(Status, reader.IsDBNull("EffectiveDate") ? (DateTime?)null : reader.GetDateTime("EffectiveDate"));
            DisplayName = reader.IsDBNull("DisplayName") ? "" : HttpUtility.HtmlEncode(reader.GetString("DisplayName"));
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
    var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };

    usmClient.SubmitEventForExecution(Convert.ToInt32(InstanceId), false, "");
    usmClient.NotifyServiceOfSubmittedEvents();
    InitControls();
  }

  protected void btnRunAdaptersLater_Click(object sender, EventArgs e)
  {
    DateTime laterOn;
    if (String.IsNullOrEmpty(dtRunRevertOn.Text) ||
        !DateTime.TryParse(dtRunRevertOn.Text, Thread.CurrentThread.CurrentUICulture, DateTimeStyles.AssumeLocal, out laterOn))
      return;

    var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };
    usmClient.SubmitEventForExecution(Convert.ToInt32(InstanceId), false, laterOn, "");
    usmClient.NotifyServiceOfSubmittedEvents();
    InitControls();
  }

  protected void btnRevertAdapters_Click(object sender, EventArgs e)
  {
    var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };

    usmClient.SubmitEventForReversal(Convert.ToInt32(InstanceId), false, "");
    usmClient.NotifyServiceOfSubmittedEvents();
    InitControls();
  }

  protected void btnRevertAdaptersLater_Click(object sender, EventArgs e)
  {
    DateTime laterOn;
    if (String.IsNullOrEmpty(dtRunRevertOn.Text) ||
        !DateTime.TryParse(dtRunRevertOn.Text, Thread.CurrentThread.CurrentUICulture, DateTimeStyles.AssumeLocal, out laterOn))
      return;

    var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };
    usmClient.SubmitEventForReversal(Convert.ToInt32(InstanceId), false, laterOn, "");
    usmClient.NotifyServiceOfSubmittedEvents();
    InitControls();
  }

  protected void btnCancelSubmittedAction_Click(object sender, EventArgs e)
  {
    var usmClient = new MetraTech.UsageServer.Client { SessionContext = UI.User.SessionContext };

    usmClient.CancelSubmittedEvent(Convert.ToInt32(InstanceId), "");
    usmClient.NotifyServiceOfSubmittedEvents();
    InitControls();
  }

  protected string GetDurationMessage(string value, string dtEnd)
  {
    return value + " - " + dtEnd;
  }
}
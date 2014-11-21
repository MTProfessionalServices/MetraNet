using System;
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

    if (IsPostBack) return;
    InstanceId = Request["ID"];
    IntervalId = Request["IntervalId"];
    BillingGroupId = Request["BillingGroupId"];
    DisableActions = Request["DisableActions"];
    InitControls();
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    if (String.IsNullOrEmpty(InstanceId)) return;
    AdapterInstanceRunHistoryGrid.DataSourceURL = "~/AjaxServices/QueryService.aspx";

    var sqi = new SQLQueryInfo { QueryName = "__GET_ADAPTER_RUN_LIST_FOR_INSTANCE__" };
    var param = new SQLQueryParam { FieldName = "%%ID_INSTANCE%%", FieldValue = int.Parse(InstanceId) };
    sqi.Params.Add(param);

    var qsParam = SQLQueryInfo.Compact(sqi);
    AdapterInstanceRunHistoryGrid.DataSourceURLParams.Clear();
    AdapterInstanceRunHistoryGrid.DataSourceURLParams.Add("q", qsParam);

    base.OnLoadComplete(e);
  }

  private void InitControls()
  {
    LoadSummaryInfo();
    //var IntervalDescription = Request["IntervalDescription"];
    //lblArgStart.Visible = lblArgEnd.Visible = lblArgStartValue.Visible = lblArgEndValue.Visible = !String.IsNullOrEmpty(IntervalDescription);
    lblInstanceIdValue.Text = InstanceId;
    lblAdapterValue.Text = DisplayNameEncoded;
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
    btnReverseAdapters.Enabled = btnReverseAdaptersLater.Enabled = bShowReverseOption;
    btnCancelSubmittedAction.Enabled = bShowMarkAsNotReadyToRun;
  }

  private void LoadSummaryInfo()
  {
    using (IMTConnection conn = ConnectionManager.CreateConnection())
    {
      using (var stmt = conn.CreateAdapterStatement(@"..\config\SqlCore\Queries\mom", "__GET_ADAPTER_INSTANCE_INFORMATION__"))
      {
        stmt.AddParam("%%ID_INSTANCE%%", Convert.ToInt32(InstanceId));

        using (var reader = stmt.ExecuteReader())
        {
          while (reader.Read())
          {
            Status = reader.IsDBNull("Status") ? "" : reader.GetString("Status");
            StatusText = MetraNet.Formatters.GetAdapterInstanceStatusMessage(Status, reader.IsDBNull("EffectiveDate") ? (DateTime?)null : reader.GetDateTime("EffectiveDate"));
            DisplayName = reader.IsDBNull("DisplayName") ? "" : reader.GetString("DisplayName");
            DisplayNameEncoded = HttpUtility.HtmlEncode(DisplayName);
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

  }
  protected void btnRunAdaptersLater_Click(object sender, EventArgs e)
  {

  }
  protected void btnReverseAdapters_Click(object sender, EventArgs e)
  {

  }
  protected void btnReverseAdaptersLater_Click(object sender, EventArgs e)
  {

  }
  protected void btnCancelSubmittedAction_Click(object sender, EventArgs e)
  {

  }

  protected string GetDurationMessage(string value, string dtEnd)
  {
    return value + " - " + dtEnd;
  }
}
using System;
using System.Globalization;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;

public partial class ScheduleDaily : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage Scheduled Adapters"))
    {
      Response.End();
      return;
    }

    if (IsPostBack) return;

    var schedAdapterClient = new ScheduleAdapterServiceClient();

    try
    {
      if (Request.QueryString["AdapterName"] != null)
      {
        ViewState["AdapterName"] = Request.QueryString["AdapterName"];
      }

      if (Request.QueryString["EventID"] != null)
      {
        ViewState["EventID"] = Request.QueryString["EventID"];
      }

      RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"] + ") ";

      if (schedAdapterClient.ClientCredentials != null)
      {
        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      BaseRecurrencePattern recurPattern;
      schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
      var dailyRecurrencePattern = recurPattern as DailyRecurrencePattern;
      if (dailyRecurrencePattern != null)
      {
        tbDays.Text = dailyRecurrencePattern.IntervalInDays.ToString(CultureInfo.InvariantCulture);
        tbStartDate.Text = dailyRecurrencePattern.StartDate.ToShortDateString();
        tbStartTime.Text = dailyRecurrencePattern.ExecutionTimes.ToString();
      }
      else
      {
        tbStartDate.Text = new DateTime(2010, 1, 1).ToShortDateString();
        tbStartTime.Text = new DateTime(2010, 1, 1).ToShortTimeString();
      }
      schedAdapterClient.Close();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      Logger.LogError(ex.Message);
      schedAdapterClient.Abort();
    }
  }

  protected void btnSave_Click(object sender, EventArgs e)
  {
    var schedAdapterClient = new ScheduleAdapterServiceClient();

    try
    {
      BaseRecurrencePattern updateRecurPattern = new DailyRecurrencePattern(Convert.ToInt32(tbDays.Text), tbStartTime.Text);
      updateRecurPattern.StartDate = Convert.ToDateTime(tbStartDate.Text);

      if (schedAdapterClient.ClientCredentials != null)
      {
        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }
      schedAdapterClient.UpdateRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), updateRecurPattern);
      schedAdapterClient.Close();

      Page.ClientScript.RegisterStartupScript(Page.GetType(), "go_Back",
                                              "<script type='text/javascript'>window.getFrameMetraNet().MainContentIframe.location.href='ScheduledAdaptersList.aspx'</script>");
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      Logger.LogError(ex.Message);
      tbDays.Text = "";
      schedAdapterClient.Abort();
    }

  }

}
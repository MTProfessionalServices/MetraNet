using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;


public partial class ScheduleMinutely : MTPage
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
      int hours, minutes;

      for (hours = 0; hours < 25; hours++)
      {
        var hoursListItem = new ListItem
          {
            Text = hours.ToString(CultureInfo.InvariantCulture),
            Value = hours.ToString(CultureInfo.InvariantCulture)
          };
        ddHours.Items.Add(hoursListItem);
      }
      for (minutes = 0; minutes < 61; minutes++)
      {
        var minutesListItem = new ListItem
          {
            Text = minutes.ToString(CultureInfo.InvariantCulture),
            Value = minutes.ToString(CultureInfo.InvariantCulture)
          };
        ddMinutes.Items.Add(minutesListItem);
      }


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
      var minutelyRecurrencePattern = recurPattern as MinutelyRecurrencePattern;
      if (minutelyRecurrencePattern != null)
      {
        int intervalInMintues = minutelyRecurrencePattern.IntervalInMinutes;

        var tspan = TimeSpan.FromMinutes(intervalInMintues);
        if (tspan.Days.ToString(CultureInfo.InvariantCulture) != "0")
        {
          tbDays.Text = tspan.Days.ToString(CultureInfo.InvariantCulture);
        }
        ddHours.SelectedValue = tspan.Hours.ToString(CultureInfo.InvariantCulture);
        ddMinutes.SelectedValue = tspan.Minutes.ToString(CultureInfo.InvariantCulture);

        tbStartDate.Text = minutelyRecurrencePattern.StartDate.ToShortDateString();
        tbStartTime.Text = minutelyRecurrencePattern.StartDate.ToShortTimeString();
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
      int daysToMinutes = 0;
      if (tbDays.Text != String.Empty)
      {
        daysToMinutes = Convert.ToInt32(tbDays.Text)*24*60;
      }
      var hoursToMinutes = Convert.ToInt32(ddHours.SelectedValue)*60;
      var minutes = daysToMinutes + hoursToMinutes + Convert.ToInt32(ddMinutes.SelectedValue);
      BaseRecurrencePattern updateRecurPattern = new MinutelyRecurrencePattern(minutes);
      var startDate = Convert.ToDateTime(tbStartDate.Text + " " + tbStartTime.Text);
      updateRecurPattern.StartDate = startDate;

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
      tbDays.Text = "";
      Logger.LogError(ex.Message);
      schedAdapterClient.Abort();
    }
  }
}
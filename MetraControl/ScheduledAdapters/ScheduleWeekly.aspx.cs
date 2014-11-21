using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;

public partial class ScheduleWeekly : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage Scheduled Adapters"))
    {
      Response.End();
      return;
    }

    if (!IsPostBack)
    {
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

        int weeks;
        for (weeks = 0; weeks < 53; weeks++)
        {
          var weeksListItem = new ListItem { Text = weeks.ToString(CultureInfo.InvariantCulture), Value = weeks.ToString(CultureInfo.InvariantCulture) };

          ddWeeks.Items.Add(weeksListItem);
        }
        sbWeekly.Url = "AjaxServices/RecurrencePatternSvc.aspx?RecurPattern=weekly";
        sbWeekly.Name = "days";
        sbWeekly.DisplayField = "'day'";
        sbWeekly.ValueField = "'id'";
        sbWeekly.Fields = "'id', 'day'";
        sbWeekly.EmptyText = String.Format("'{0}'", GetLocalResourceObject("sbWeekly_EmptyText"));

        if (schedAdapterClient.ClientCredentials != null)
        {
          schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        BaseRecurrencePattern recurPattern;
        schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
        var recurrencePattern = recurPattern as WeeklyRecurrencePattern;
        if (recurrencePattern != null)
        {
          var weeklyRecurPattern = recurrencePattern;
          ddWeeks.SelectedValue = weeklyRecurPattern.IntervalInWeeks.ToString(CultureInfo.InvariantCulture);
          var daysArray = weeklyRecurPattern.DaysOfWeek.ToString().Split(',');
          var days = "";
          for (var i = 0; i < daysArray.Length; i++)
          {
            days = i == daysArray.Length - 1 ? days + daysArray[i].Trim() : days + daysArray[i].Trim() + ",";
          }
          sbWeekly.SelectedValue = days;
          tbStartDate.Text = weeklyRecurPattern.StartDate.ToShortDateString();
          tbStartTime.Text = weeklyRecurPattern.ExecutionTimes.ToString();
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
  }

  protected void btnSave_Click(object sender, EventArgs e)
  {
    var schedAdapterClient = new ScheduleAdapterServiceClient();

    try
    {
      BaseRecurrencePattern updateRecurPattern = new WeeklyRecurrencePattern(Convert.ToInt32(ddWeeks.SelectedValue), tbStartTime.Text, dayOfWeek.Value);
      var startDate = Convert.ToDateTime(tbStartDate.Text);
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
      Logger.LogError(ex.Message);
      tbStartTime.Text = "";
      tbStartDate.Text = "";
      ddWeeks.SelectedIndex = 0;
      schedAdapterClient.Abort();
    }
  }
}
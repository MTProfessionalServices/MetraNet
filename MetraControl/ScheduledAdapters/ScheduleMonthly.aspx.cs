using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;

public partial class ScheduleMonthly : MTPage
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
      RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"] + ")";

      int months;
      for (months = 0; months < 13; months++)
      {
        var monthsListItem = new ListItem
          {
            Text = months.ToString(CultureInfo.InvariantCulture),
            Value = months.ToString(CultureInfo.InvariantCulture)
          };
        ddMonths.Items.Add(monthsListItem);
      }

      //populate months
      for (int i = 1; i <= 12; i++)
      {
        //String month = (i < 10) ? "0" + i.ToString() : i.ToString();
        ddExpMonth.Items.Add(i.ToString(CultureInfo.InvariantCulture));
      }

      //populate years
      var curYear = DateTime.Today.Year;
      for (var i = 0; i <= 20; i++)
      {
        ddExpYear.Items.Add((curYear + i).ToString());
      }
      sbMonthly.Url = "AjaxServices/RecurrencePatternSvc.aspx?RecurPattern=monthly";
      sbMonthly.Name = "recurrencepattern";
      sbMonthly.DisplayField = "'pattern'";
      sbMonthly.ValueField = "'id'";
      sbMonthly.Fields = "'id', 'pattern'";
      sbMonthly.EmptyText = String.Format("'{0}'", GetLocalResourceObject("sbMonthly_EmptyText"));

      if (schedAdapterClient.ClientCredentials != null)
      {
        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      BaseRecurrencePattern recurPattern;
      schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
      var recurrencePattern = recurPattern as MonthlyRecurrencePattern;
      if (recurrencePattern != null)
      {
        var monthsArray = recurrencePattern.DaysOfMonth.ToString().Split(',');
        var daysOfMonth = "";
        for (int i = 0; i < monthsArray.Length; i++)
        {
          if (i == monthsArray.Length - 1)
          {
            daysOfMonth = daysOfMonth + monthsArray[i].Trim();
          }
          else
          {
            daysOfMonth = daysOfMonth + monthsArray[i].Trim() + ",";
          }
        }
        sbMonthly.SelectedValue = daysOfMonth;
        ddMonths.SelectedValue = recurrencePattern.IntervalInMonth.ToString(CultureInfo.InvariantCulture);
        tbStartTime.Text = recurrencePattern.ExecutionTimes.ToString();
        ddExpYear.SelectedValue = recurrencePattern.StartDate.Year.ToString(CultureInfo.InvariantCulture);
        ddExpMonth.SelectedValue = recurrencePattern.StartDate.Month.ToString(CultureInfo.InvariantCulture);
      }
      else
      {
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
      BaseRecurrencePattern updateRecurPattern = new MonthlyRecurrencePattern(Convert.ToInt32(ddMonths.SelectedValue), tbStartTime.Text, monthlyPattern.Value);

      var startDate = ddExpYear.SelectedValue + "-" + ddExpMonth.SelectedValue;
      var dtStartDate = DateTime.Parse(startDate);
      updateRecurPattern.StartDate = dtStartDate;

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
      ddMonths.SelectedIndex = 0;
      schedAdapterClient.Abort();
    }
  }
}
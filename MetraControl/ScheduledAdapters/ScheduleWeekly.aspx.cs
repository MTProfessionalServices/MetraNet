using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
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
      ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
      try
      {
          if (Request.QueryString["AdapterName"] != null)
          {
            ViewState["AdapterName"] = Request.QueryString["AdapterName"].ToString();
          }

          if (Request.QueryString["EventID"] != null)
          {
            ViewState["EventID"] = Request.QueryString["EventID"].ToString();
          }

          RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"].ToString() + ") ";

          int weeks;
          for (weeks = 0; weeks < 53; weeks++)
          {
            ListItem weeksListItem = new ListItem();
           /* if(weeks == 0)
            {
              weeksListItem.Text = "";
              weeksListItem.Value = weeks.ToString();
            }
            else
            {
              weeksListItem.Text = weeks.ToString();
              weeksListItem.Value = weeks.ToString();
            }*/

            weeksListItem.Text = weeks.ToString();
            weeksListItem.Value = weeks.ToString();
            ddWeeks.Items.Add(weeksListItem);
          }
          sbWeekly.Url = "AjaxServices/RecurrencePatternSvc.aspx?RecurPattern=weekly";
          sbWeekly.Name = "days";
          sbWeekly.DisplayField = "'day'";
          sbWeekly.ValueField = "'id'";
          sbWeekly.Fields = "'id', 'day'";
          sbWeekly.EmptyText = "'" + GetLocalResourceObject("sbWeekly_EmptyText").ToString() + "'";
     
          schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          BaseRecurrencePattern recurPattern;
          schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
          if (recurPattern is WeeklyRecurrencePattern)
          {
            WeeklyRecurrencePattern weeklyRecurPattern = (WeeklyRecurrencePattern)recurPattern;
            ddWeeks.SelectedValue = weeklyRecurPattern.IntervalInWeeks.ToString();
            string[] daysArray = weeklyRecurPattern.DaysOfWeek.ToString().Split(',');
            string days = "";
            for (int i = 0; i < daysArray.Length; i++)
            {
              if (i == daysArray.Length-1)
              {
                days = days + daysArray[i].Trim();
              }
              else
              {
                days = days + daysArray[i].Trim() + ",";
              }
             
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
        this.Logger.LogError(ex.Message);
        schedAdapterClient.Abort();
      }
    }
  }


  protected void btnSave_Click(object sender, EventArgs e)
  {
    ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
    BaseRecurrencePattern updateRecurPattern;
    bool updatedFlag = false;

    try
    {
      updateRecurPattern = new WeeklyRecurrencePattern(Convert.ToInt32(ddWeeks.SelectedValue), tbStartTime.Text, dayOfWeek.Value);
      DateTime startDate = Convert.ToDateTime(tbStartDate.Text);
      updateRecurPattern.StartDate = startDate;
      
      schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
      schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      schedAdapterClient.UpdateRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), updateRecurPattern);
      schedAdapterClient.Close();
      updatedFlag = true;
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
      tbStartTime.Text = "";
      tbStartDate.Text = "";
      ddWeeks.SelectedIndex = 0;
      schedAdapterClient.Abort();
    }

    if (updatedFlag)
    {
      Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "goBack", "<script>parent.parent.location.href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.List.asp'</script>");
    }

  }
}
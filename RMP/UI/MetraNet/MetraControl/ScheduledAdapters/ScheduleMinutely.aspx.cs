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


public partial class ScheduleMinutely : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
    BaseRecurrencePattern recurPattern;

    if (!IsPostBack)
    {
      try
      {
       int hours, minutes;

       for (hours = 0; hours < 25; hours++)
       {
          ListItem hoursListItem = new ListItem();
         /* if (hours == 0)
          {
            hoursListItem.Text = "";
            hoursListItem.Value = hours.ToString();
          }
          else
          {
            hoursListItem.Text = hours.ToString();
            hoursListItem.Value = hours.ToString();
          }*/

          hoursListItem.Text = hours.ToString();
          hoursListItem.Value = hours.ToString();
          ddHours.Items.Add(hoursListItem);
       }
       for (minutes = 0; minutes < 61; minutes++)
       {
         ListItem minutesListItem = new ListItem();
        /* if(minutes == 0)
         {
           minutesListItem.Text = "";
           minutesListItem.Value = minutes.ToString();
         }
         else
         {
           minutesListItem.Text = minutes.ToString();
           minutesListItem.Value = minutes.ToString();
         }*/

         minutesListItem.Text = minutes.ToString();
         minutesListItem.Value = minutes.ToString();
         ddMinutes.Items.Add(minutesListItem);
       }
  

      if (Request.QueryString["AdapterName"] != null)
      {
        ViewState["AdapterName"] = Request.QueryString["AdapterName"].ToString();
      }

      if (Request.QueryString["EventID"] != null)
      {
        ViewState["EventID"] = Request.QueryString["EventID"].ToString();
      }

      RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"].ToString() + ") ";
      schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
      schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
      if (recurPattern is MinutelyRecurrencePattern)
      {
        MinutelyRecurrencePattern minutelyPattern = (MinutelyRecurrencePattern)recurPattern;
        int intervalInMintues = minutelyPattern.IntervalInMinutes;

        TimeSpan tspan = TimeSpan.FromMinutes(intervalInMintues);
        if (tspan.Days.ToString() != "0")
        {
          tbDays.Text = tspan.Days.ToString();
        }
        ddHours.SelectedValue = tspan.Hours.ToString();
        ddMinutes.SelectedValue = tspan.Minutes.ToString();
        
        if (recurPattern.StartDate != null)
        {
          tbStartDate.Text = recurPattern.StartDate.ToShortDateString();
          tbStartTime.Text = recurPattern.StartDate.ToShortTimeString();
        }
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
    BaseRecurrencePattern updateRecurPattern;
    ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
    bool updatedFlag = false;

    try
    {
      int daysToMinutes = 0;
      if (tbDays.Text != String.Empty)
      {
        daysToMinutes = Convert.ToInt32(tbDays.Text)*24*60;
      }
      int hoursToMinutes = Convert.ToInt32(ddHours.SelectedValue) * 60;
      int minutes = daysToMinutes + hoursToMinutes + Convert.ToInt32(ddMinutes.SelectedValue);
      updateRecurPattern = new MinutelyRecurrencePattern(minutes);
      DateTime startDate = Convert.ToDateTime(tbStartDate.Text + " " + tbStartTime.Text);
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
      tbDays.Text = "";  
      this.Logger.LogError(ex.Message);
      schedAdapterClient.Abort();
    }
    
    if (updatedFlag)
    {
      Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "goBack", "<script>parent.parent.location.href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.List.asp'</script>");
    }
  }
}
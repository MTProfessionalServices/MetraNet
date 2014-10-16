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

public partial class ScheduleMonthly : MTPage
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
          RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"].ToString() + ")";
          
          int months;
          for (months = 0; months < 13; months++)
          {
            ListItem monthsListItem = new ListItem();
           /* if(months == 0)
            {
              monthsListItem.Text = "";
              monthsListItem.Value = months.ToString();
            }
            else
            {
              monthsListItem.Text = months.ToString();
              monthsListItem.Value = months.ToString(); 
            }*/

            monthsListItem.Text = months.ToString();
            monthsListItem.Value = months.ToString(); 
            ddMonths.Items.Add(monthsListItem);
          }
      
          //populate months
          for (int i = 1; i <= 12; i++)
          {
            //String month = (i < 10) ? "0" + i.ToString() : i.ToString();
            ddExpMonth.Items.Add(i.ToString());
          }

          //populate years
          int curYear = DateTime.Today.Year;
          for (int i = 0; i <= 20; i++)
          {
            ddExpYear.Items.Add((curYear + i).ToString());
          }
          sbMonthly.Url = "AjaxServices/RecurrencePatternSvc.aspx?RecurPattern=monthly";
          sbMonthly.Name = "recurrencepattern";
          sbMonthly.DisplayField = "'pattern'";
          sbMonthly.ValueField = "'id'";
          sbMonthly.Fields = "'id', 'pattern'";
          sbMonthly.EmptyText = "'" + GetLocalResourceObject("sbMonthly_EmptyText").ToString() + "'";

          schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          BaseRecurrencePattern recurPattern;
          schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
          if (recurPattern is MonthlyRecurrencePattern)
          {
            MonthlyRecurrencePattern monthlyRecPattern = (MonthlyRecurrencePattern)recurPattern;
            string[] monthsArray = monthlyRecPattern.DaysOfMonth.ToString().Split(',');
            string daysOfMonth = "";
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
            ddMonths.SelectedValue = monthlyRecPattern.IntervalInMonth.ToString();
            tbStartTime.Text = monthlyRecPattern.ExecutionTimes.ToString();
            ddExpYear.SelectedValue = monthlyRecPattern.StartDate.Year.ToString();
            ddExpMonth.SelectedValue = monthlyRecPattern.StartDate.Month.ToString();
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
      updateRecurPattern = new MonthlyRecurrencePattern(Convert.ToInt32(ddMonths.SelectedValue), tbStartTime.Text, monthlyPattern.Value);

      string startDate = ddExpYear.SelectedValue + "-" + ddExpMonth.SelectedValue;
      DateTime dtStartDate = DateTime.Parse(startDate);
      updateRecurPattern.StartDate = dtStartDate;

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
      ddMonths.SelectedIndex = 0;
      schedAdapterClient.Abort();
    }

    if (updatedFlag)
    {
      Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "goBack", "<script>parent.parent.location.href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.List.asp'</script>");
    }
  }
}
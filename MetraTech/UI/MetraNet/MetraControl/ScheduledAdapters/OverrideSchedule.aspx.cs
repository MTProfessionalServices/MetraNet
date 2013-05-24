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


public partial class OverrideSchedule : MTPage
{

public BaseRecurrencePattern recurPattern;
 
  protected void Page_Load(object sender, EventArgs e)
  {

    if (!IsPostBack)
    {    
      ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
      try
      {
        if (Request.QueryString["AdapterName"] != null)
        {
          PageTitle.Text = PageTitle.Text + " (" + Request.QueryString["AdapterName"].ToString() + ")";
        }
        if (Request.QueryString["ScheduleName"] != null)
        {
          CurrentScheduleLiteral.Text = Request.QueryString["ScheduleName"].ToString();
        }
        if (Request.QueryString["EventID"] != null)
        {
          ViewState["EventID"] = Request.QueryString["EventID"].ToString();
        }
       
        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
     
        schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
        ViewState["CurrentRecurrencePattern"] = recurPattern;

        DateTime nextOccurrence = recurPattern.GetNextPatternOccurrence();
        if (nextOccurrence != null)
        {
          radOnSchedule.BoxLabel = radOnSchedule.BoxLabel + " " + nextOccurrence;
        }

        DateTime skipOneOccurrence = recurPattern.GetSkipOnePatternOccurrence();
        if (skipOneOccurrence != null)
        {
          radSkipOne.BoxLabel = radSkipOne.BoxLabel + " " + recurPattern.GetSkipOnePatternOccurrence();
        }

        radPause.Checked = recurPattern.IsPaused;
        radSkipOne.Checked = recurPattern.IsSkipOne;
        

        if (recurPattern.IsSkipOne && recurPattern.IsOverride)
        {
          radSkipOne.Checked = true;
        }
        else
        {
          if (recurPattern.IsOverride)
          {
            radOverride.Checked = recurPattern.IsOverride;
            tbStartDate.Text = recurPattern.OverrideDate.ToShortDateString();
            tbStartTime.Text = recurPattern.OverrideDate.ToShortTimeString();
          }            
        }

        if (tbStartDate.Text == "")
        {
          tbStartDate.Text = skipOneOccurrence.ToShortDateString();
          tbStartTime.Text = skipOneOccurrence.ToShortTimeString();
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
     schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
     schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

     updateRecurPattern = (BaseRecurrencePattern)ViewState["CurrentRecurrencePattern"];
     updateRecurPattern.IsPaused = radPause.Checked;
     updateRecurPattern.IsSkipOne = radSkipOne.Checked;

     if (radOnSchedule.Checked)
     {
       updateRecurPattern.IsPaused = false;
       updateRecurPattern.IsSkipOne = false;
     }

     if (radOverride.Checked)
     {
       string overrideDate = Convert.ToDateTime(tbStartDate.Text).ToShortDateString() + " " + tbStartTime.Text;
       updateRecurPattern.OverrideDate = Convert.ToDateTime(overrideDate);
     }

     schedAdapterClient.UpdateRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), updateRecurPattern);
     schedAdapterClient.Close();
     updatedFlag = true;
    
   }
   catch (Exception ex)
   {
     SetError(ex.Message);
     tbStartDate.Text = "";
     tbStartTime.Text = "";
     schedAdapterClient.Abort(); 
     this.Logger.LogError(ex.Message);    
   }

   if (updatedFlag)
   {
     Response.Redirect("/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.List.asp");
   }
   
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.List.asp");
  }

}
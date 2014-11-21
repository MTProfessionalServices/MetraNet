using System;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;


public partial class OverrideSchedule : MTPage
{

  public BaseRecurrencePattern recurPattern;

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
        PageTitle.Text = String.Format("{0} ({1})", PageTitle.Text, Request.QueryString["AdapterName"]);
      }
      if (Request.QueryString["ScheduleName"] != null)
      {
        CurrentScheduleLiteral.Text = Request.QueryString["ScheduleName"];
      }
      if (Request.QueryString["EventID"] != null)
      {
        ViewState["EventID"] = Request.QueryString["EventID"];
      }

      if (schedAdapterClient.ClientCredentials != null)
      {
        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
      ViewState["CurrentRecurrencePattern"] = recurPattern;

      var nextOccurrence = recurPattern.GetNextPatternOccurrence();
      radOnSchedule.BoxLabel = String.Format("{0} {1}", radOnSchedule.BoxLabel, nextOccurrence);

      DateTime skipOneOccurrence = recurPattern.GetSkipOnePatternOccurrence();
      radSkipOne.BoxLabel = String.Format("{0} {1}", radSkipOne.BoxLabel, recurPattern.GetSkipOnePatternOccurrence());

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
      Logger.LogError(ex.Message);
      schedAdapterClient.Abort();
    }
  }


  protected void btnSave_Click(object sender, EventArgs e)
  {
    var schedAdapterClient = new ScheduleAdapterServiceClient();
    try
    {
      if (schedAdapterClient.ClientCredentials != null)
      {
        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      var updateRecurPattern = (BaseRecurrencePattern)ViewState["CurrentRecurrencePattern"];
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
      Response.Redirect("ScheduledAdaptersList.aspx", false);
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      tbStartDate.Text = "";
      tbStartTime.Text = "";
      schedAdapterClient.Abort();
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ScheduledAdaptersList.aspx");
  }
}
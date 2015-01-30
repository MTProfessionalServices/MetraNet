using System;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UsageServer;

public partial class ScheduleManual : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage Scheduled Adapters"))
    {
      Response.End();
      return;
    }

    if (IsPostBack) return;

    if (Request.QueryString["AdapterName"] != null)
    {
      ViewState["AdapterName"] = Request.QueryString["AdapterName"];
    }

    if (Request.QueryString["EventID"] != null)
    {
      ViewState["EventID"] = Request.QueryString["EventID"];
    }

    RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"] + ") ";
  }

  protected void btnSave_Click(object sender, EventArgs e)
  {
    var schedAdapterClient = new ScheduleAdapterServiceClient();

    try
    {
      BaseRecurrencePattern updateRecurPattern = new ManualRecurrencePattern();

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
      schedAdapterClient.Abort();
    }
  }
}
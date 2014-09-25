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

public partial class ScheduleManual : MTPage
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
      if (Request.QueryString["AdapterName"] != null)
      {
        ViewState["AdapterName"] = Request.QueryString["AdapterName"].ToString();
      }

      if (Request.QueryString["EventID"] != null)
      {
        ViewState["EventID"] = Request.QueryString["EventID"].ToString();
      }

      RecurrencePatternPanel.Text = RecurrencePatternPanel.Text + " (" + ViewState["AdapterName"].ToString() + ") ";
    }


  }

  protected void btnSave_Click(object sender, EventArgs e)
  {
    ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
    BaseRecurrencePattern updateRecurPattern;
    bool updatedFlag = false;

    try
    {
      updateRecurPattern = new ManualRecurrencePattern();

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
      schedAdapterClient.Abort();
    }

    if (updatedFlag)
    {
      Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "goBack", "<script>parent.parent.location.href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/ScheduledAdapter.List.asp'</script>");
    }


  }

}
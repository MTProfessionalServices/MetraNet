using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.ServiceModel;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.UsageServer;

public partial class AmpAddAccountGroupPage : AmpWizardBasePage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    if (!IsPostBack)
    {

    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    // Save the new Account Group
    AmpServiceClient ampSvcClient = null;
    try
    {
      ampSvcClient = new AmpServiceClient();
      if (ampSvcClient.ClientCredentials != null)
      {
        ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      AccountQualificationGroup aqg = new AccountQualificationGroup();
      ampSvcClient.CreateAccountQualificationGroup(Name.Text, Description.Text, out aqg);
      //logger.LogDebug(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_ACCOUNT_GROUP").ToString(), Name.Text));

      // Clean up client.
      ampSvcClient.Close();
      ampSvcClient = null;

      // Close the page
      Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", 
                                              String.Format("closeWindow(\"{0}\");", Name.Text),
                                              true);
    }
    catch (Exception ex)
    {
      string exMessage = ex.Message;
      //SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_SAVE_DECISION").ToString(),
       //                      AmpDecisionName));
      logger.LogException("An error occurred while saving Account Group '" + Name.Text + "'", ex);

      // Stay on current page.
    }
    finally
    {
      if (ampSvcClient != null)
      {
        ampSvcClient.Abort();
      }
    }

  }


  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow(\"\");", true);
  }
}
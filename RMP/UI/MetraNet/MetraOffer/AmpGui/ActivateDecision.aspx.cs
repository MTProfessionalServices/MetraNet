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
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.DomainModel.ProductCatalog;


public partial class AmpActivateDecisionPage : AmpWizardBasePage
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
      ErrorCheckFirstTable.Visible = false;

      if (AmpIsErrorChecked == "false")
      {
        // show message that error check must be done before activating Decision
        ErrorCheckFirstTable.Visible = true;
      }
    }

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
  }

}
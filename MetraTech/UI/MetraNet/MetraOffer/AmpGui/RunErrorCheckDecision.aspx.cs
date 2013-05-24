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


public partial class AmpRunErrorCheckDecisionPage : AmpWizardBasePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }
  }

  /// <summary>
  /// On Load Complete gives you a chance to change the default properties on the grid.
  /// </summary>
  /// <param name="e"></param>
  protected override void OnLoadComplete(EventArgs e)
  {
    // Pass the curent Decision's name to the RunErrorCheckDecisionSvc
    DecisionValidationErrorsGrid.DataSourceURL =
                String.Format("/MetraNet/MetraOffer/AmpGui/AjaxServices/RunErrorCheckDecisionSvc.aspx?ampDecisionName={0}",
                              AmpDecisionName);

    // Set the flag that says the error check was done on this page
    AmpIsErrorChecked = "true";

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
  }

}
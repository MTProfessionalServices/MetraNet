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


public partial class AmpMiscellaneousAttributesPage : AmpWizardBasePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    // Set the current, next, and previous AMP pages right away.
    AmpCurrentPage = "MiscellaneousAttributes.aspx";
    AmpNextPage = "ErrorCheck.aspx";
    AmpPreviousPage = "DecisionInteractions.aspx";

    //TBD Monitor changes made to the controls on the page.
    //MonitorChangesInControl(tbGenInfoName);

    // The Continue button should NOT prompt the user if the controls have changed.
    //TBD However, we don't need to call IgnoreChangesInControl(btnContinue) here
    // because of how OnClientClick is defined for the button.
    //IgnoreChangesInControl(btnContinue);

    if (!IsPostBack)
    {
      // If we are only Viewing a decision, show the "Continue" button.
      if (AmpAction == "View")
      {
        btnContinue.Visible = true;
        btnSaveAndContinue.Visible = false;
      }
      else // If we are editing a decision, show the "Save & Continue" button
      {
        btnContinue.Visible = false;
        btnSaveAndContinue.Visible = true;
      }
    }
  }

  /// <summary>
  /// On Load Complete gives you a chance to change the default properties on the grid.
  /// </summary>
  /// <param name="e"></param>
  protected override void OnLoadComplete(EventArgs e)
  {
    // Pass the curent Decision's name to the MiscellaneousAttributesSvc
    MiscellanousAttributesGrid.DataSourceURL =
                String.Format("/MetraNet/MetraOffer/AmpGui/AjaxServices/MiscellaneousAttributesSvc.aspx?ampDecisionName={0}",
                              AmpDecisionName);

    if (AmpAction == "View")
    {
      // Remove the Actions column
      foreach (MTGridDataElement element in MiscellanousAttributesGrid.Elements)
      {
        if (element.ID == "Actions")
        {
          element.IsColumn = false;
        }
        else if (element.ID == "ColumnName")
        {
          element.Width = 180;
        }
      }
    }
    else {
      // if we are not in "View" mode, add a toolbar button to Add new Miscellaneous attributes:
      MTGridButton button = new MTGridButton();
      button.ButtonID = "Add";
      button.ButtonText = GetLocalResourceObject("TEXT_ADD").ToString();
      button.ToolTip = GetLocalResourceObject("TEXT_ADD_TOOLTIP").ToString();
      button.JSHandlerFunction = "onAdd";
      button.IconClass = "Add";
      MiscellanousAttributesGrid.ToolbarButtons.Add(button);
    }
  }

  protected void btnContinue_Click(object sender, EventArgs e)
  {

    // Advance to next page in wizard.  Set EndResponse parameter to false
    // to prevent Response.Redirect from throwing ThreadAbortException.
    Response.Redirect(AmpNextPage, false);

  } // btnContinue_Click

}
using System;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;

public partial class AmpChargeCreditDirectivesPage : AmpWizardBasePage
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
        AmpCurrentPage = "ChargeCreditDirectives.aspx";
        AmpNextPage = "ChargeCreditAttributes.aspx";
        AmpPreviousPage = "ChargeCreditProductView.aspx";

        if (!IsPostBack)
        {
            CurrentGeneratedChargeInstance = GetGeneratedChargeWithClient();

            tbChargeCreditName.Text = AmpChargeCreditName;
            tbProductViewName.Text = CurrentGeneratedChargeInstance.ProductViewName;
        }
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        // Pass the values to the service
        DirectivesGrid.DataSourceURL =
            String.Format(
                "/MetraNet/MetraOffer/AmpGui/AjaxServices/ChargeCreditDirectivesSvc.aspx?ampGeneratedChargeName={0}",
                AmpChargeCreditName);
        PVGrid.DataSourceURL =
            String.Format(
                "/MetraNet/MetraOffer/AmpGui/AjaxServices/ProdViewPopulatedSvc.aspx?ampGeneratedChargeName={0}&ampProductViewName={1}",
                AmpChargeCreditName, CurrentGeneratedChargeInstance.ProductViewName);

        SetMode();
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
        //NOTE: There is no need to save anything here. Everything already been saved
        //if (AmpChargeCreditAction != "View")
        //{
        //    SaveGeneratedChargeWithClient();
        //}

        // Advance to next page in wizard.  Set EndResponse parameter to false
        // to prevent Response.Redirect from throwing ThreadAbortException.
        Response.Redirect(AmpNextPage, false);
    }


    // Set control properties based on current mode(View/Edit).
    private void SetMode()
    {
      if (AmpChargeCreditAction != "View")
      {
        MTGridButton button = new MTGridButton();
        button.ButtonID = "Add";
        button.ButtonText = GetLocalResourceObject("TEXT_ADD").ToString();
        button.ToolTip = GetLocalResourceObject("TEXT_ADD_TOOLTIP").ToString();
        button.JSHandlerFunction = "onAdd";
        button.IconClass = "Add";
        DirectivesGrid.ToolbarButtons.Add(button);
        DirectivesGrid.Height = 210;
      }
    }
}
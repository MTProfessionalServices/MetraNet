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
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.DomainModel.BaseTypes;

public partial class AmpChargeCreditProductViewPage : AmpWizardBasePage
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
        AmpCurrentPage = "ChargeCreditProductView.aspx";
        AmpNextPage = "ChargeCreditDirectives.aspx";
        AmpPreviousPage = "ChargeCreditAttributes.aspx";

        MonitorChangesInControl(tbChargeCreditName);
        MonitorChangesInControl(tbDescription);
        MonitorChangesInControlByClientId(hiddenAmountChainGroupName.ClientID);
        if (AmpUsageQualificationAction != "View")
        {
          ddProductViews.Attributes.Add("onChange", "MPC_setNeedToConfirm(false);");
        }

        if (!IsPostBack)
        {
            InitWithClient();

            //View/Edit mode
            SetMode();
        }
    }


    protected void btnContinue_Click(object sender, EventArgs e)
    {
        if (AmpChargeCreditAction != "View")
        {
            AmpChargeCreditName = tbChargeCreditName.Text;
            bool createNewCharge = (CurrentGeneratedChargeInstance == null) || 
                                   (CurrentGeneratedChargeInstance.Name != tbChargeCreditName.Text);

            if (!ParseValuesFromControls())
            {
              return;  // Stay on same page.
            }

            if (createNewCharge)
            {
              GeneratedCharge newCharge; //we don't use it
              if (!CreateGeneratedChargeWithClient(CurrentGeneratedChargeInstance.Name,
                                                   CurrentGeneratedChargeInstance.Description,
                                                   CurrentGeneratedChargeInstance.ProductViewName,
                                                   CurrentGeneratedChargeInstance.AmountChainName,
                                                   out newCharge))
              {
                return;
              }

              // Change AmpChargeCreditAction to "Created" so that if we come back to the ChargeCreditProductView page,
              // we know we should load the generated charge.
              AmpChargeCreditAction = "Created";

            }
            else if (!SaveGeneratedChargeWithClient())
            {
                return;
            }
        }

        // Advance to next page in wizard.  Set EndResponse parameter to false
        // to prevent Response.Redirect from throwing ThreadAbortException.
        Response.Redirect(AmpNextPage, false);
    }


    private void InitWithClient()
    {
        AmpServiceClient ampSvcClient = null;
        try
        {
            ampSvcClient = new AmpServiceClient();
            if (ampSvcClient.ClientCredentials != null)
            {
                ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            InitControls(ampSvcClient);

            // Clean up client.
            ampSvcClient.Close();
            ampSvcClient = null;
        }
        catch (Exception ex)
        {
            var errorMessage = GetLocalResourceObject("TEXT_ERROR_INIT_CONTROLS").ToString();
            SetError(errorMessage);
            logger.LogException(errorMessage, ex);
        }
        finally
        {
            if (ampSvcClient != null)
            {
                ampSvcClient.Abort();
            }
        }
    }

    private void InitControls(AmpServiceClient ampSvcClient)
    {
        tbChargeCreditName.Text = "";
        tbDescription.Text = "";
        var prodViewNames = new MTList<ProductViewNameInstance>();

        ampSvcClient.GetProductViewNamesWithLocalizedNames(ref prodViewNames);
        InitDropDown(prodViewNames);

        RetrieveGenChargeAction();
        if (!String.IsNullOrEmpty(AmpChargeCreditAction) && (AmpChargeCreditAction != "Create"))
        {
            RetrieveGenChargeName();
            if (!String.IsNullOrEmpty(AmpChargeCreditName))
            {
                GeneratedCharge currentGeneratedCharge;
                ampSvcClient.GetGeneratedCharge(AmpChargeCreditName, out currentGeneratedCharge);
                CurrentGeneratedChargeInstance = currentGeneratedCharge;

                if (CurrentGeneratedChargeInstance != null)
                {
                    tbChargeCreditName.Text = CurrentGeneratedChargeInstance.Name;
                    tbDescription.Text = String.IsNullOrEmpty(CurrentGeneratedChargeInstance.Description)
                                         ? ""
                                         : CurrentGeneratedChargeInstance.Description;
                    ViewDescriptionText.Text = String.IsNullOrEmpty(CurrentGeneratedChargeInstance.Description)
                                         ? ""
                                         : CurrentGeneratedChargeInstance.Description;

                    if (!String.IsNullOrEmpty(CurrentGeneratedChargeInstance.ProductViewName))
                    {
                      foreach (ListItem item in ddProductViews.Items)
                      {
                        if (item.Text == CurrentGeneratedChargeInstance.ProductViewName)
                        {
                          item.Selected = true;
                        }
                      }
                        ddProductViews.SelectedItem.Text = CurrentGeneratedChargeInstance.ProductViewName;
                    }

                    if (!String.IsNullOrEmpty(CurrentGeneratedChargeInstance.AmountChainName))
                    {
                        hiddenAmountChainGroupName.Value = CurrentGeneratedChargeInstance.AmountChainName;
                    }
                }
            }
        }

    }

    //TODO: move to base class (a lot of similar using in other pages)
    private void InitDropDown(MTList<ProductViewNameInstance> namesList)
    {
      if (namesList.Items.Count > 0)
      {
        char[] delimiterChars = {'/'};
        foreach (var name in namesList.Items)
        {
          // strip the text up to the '/' character out of the product view name
          string[] words = name.Name.Split(delimiterChars);
          ddProductViews.Items.Add(new ListItem {Text = name.TableName, Value = words[1]});
        }
      }
    }

  // Set control properties based on current mode(View/Edit).
    private void SetMode()
    {
        if (AmpChargeCreditAction == "View")
        {
            tbChargeCreditName.ReadOnly = true;
            tbDescription.ReadOnly = true;
            btnSaveAndContinue.Visible = false;
            ddProductViews.Enabled = false;
            editDescriptionDiv.Attributes.Add("style", "display: none;");
            viewDescriptionDiv.Attributes.Add("style", "display: block;");
        }
        else
        {
            btnContinue.Visible = false;
            editDescriptionDiv.Attributes.Add("style", "display: block;");
            viewDescriptionDiv.Attributes.Add("style", "display: none;");
        }
    }

    private void RetrieveGenChargeAction()
    {
      //if we click 'Back' button on next page, AmpChargeCreditAction already initialized & Request value is empty
      if (!String.IsNullOrEmpty(Request["GenChargeAction"]))
      {
        AmpChargeCreditAction = Request["GenChargeAction"];
      }

      if (String.IsNullOrEmpty(AmpChargeCreditAction))
      {
        var errorMessage = GetLocalResourceObject("TEXT_ERROR_RETRIEVE_GENERATED_CHARGE_ACTION").ToString();
        SetError(errorMessage);
        logger.LogException(errorMessage, new Exception(errorMessage));
      }
    }

    private void RetrieveGenChargeName()
    {
      //if we click 'Back' button on next page, AmpChargeCreditName already initialized & Request value is empty
      if (!String.IsNullOrEmpty(Request["GenChargeName"]))
      {
        AmpChargeCreditName = Request["GenChargeName"];
      }

      if (String.IsNullOrEmpty(AmpChargeCreditName))
      {
        var errorMessage = GetLocalResourceObject("TEXT_ERROR_RETRIEVE_GENERATED_CHARGE_NAME").ToString();
        SetError(errorMessage);
        logger.LogException(errorMessage, new Exception(errorMessage));
      }
    }

    /// <summary>
    /// Gets the values from controls and fills Decision and GeneratedCharge properties.
    /// Returns true if control settings are valid, else false.
    /// </summary>
    private bool ParseValuesFromControls()
    {
      if (CurrentGeneratedChargeInstance == null)
      {
        CurrentGeneratedChargeInstance = new GeneratedCharge();
      }
      //TODO: If Charge name was changed, should we delete Generated Charge with old name?

      CurrentGeneratedChargeInstance.Name = tbChargeCreditName.Text;
      CurrentGeneratedChargeInstance.Description = tbDescription.Text;
      CurrentGeneratedChargeInstance.ProductViewName = ddProductViews.SelectedItem.Text;

      if (!string.IsNullOrWhiteSpace(hiddenAmountChainGroupName.Value))
      {
        CurrentGeneratedChargeInstance.AmountChainName = hiddenAmountChainGroupName.Value;
      }
      else
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_NO_AMOUNT_CHAIN_GROUP").ToString());
        logger.LogError(String.Format("No Amount Chain Group was selected for Generated Charge '{0}'", CurrentGeneratedChargeInstance.Name));
        return false;
      }

      return true;
    }


    private bool CreateGeneratedChargeWithClient(string chargeName, string description,
                                                 string productViewName, string amountChainName,
                                                 out GeneratedCharge generatedCharge)
    {
      bool success;

      AmpServiceClient ampSvcClient = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.CreateGeneratedCharge(chargeName, description, productViewName, amountChainName, out generatedCharge);

        // Clean up client.
        ampSvcClient.Close();
        ampSvcClient = null;
        success = true;
      }
      catch (Exception ex)
      {
        var errorMessage = String.Format(GetLocalResourceObject("TEXT_ERROR_CREATE_GENERATED_CHARGE").ToString(),
                                         chargeName);
        SetError(errorMessage);
        logger.LogException(errorMessage, ex);
        generatedCharge = null;
        success = false;
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }

      return success;
    }

    protected void ddProductViews_SelectedIndexChanged(object sender, EventArgs e)
    {
      grAmountChainGroup.DataSourceURL = String.Format("/MetraNet/MetraOffer/AmpGui/AjaxServices/AmountChainGroupForProdViewSvc.aspx?ProductViewName={0}",
                ddProductViews.SelectedValue);
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      // Pass the values to the service
      grAmountChainGroup.DataSourceURL = String.Format("/MetraNet/MetraOffer/AmpGui/AjaxServices/AmountChainGroupForProdViewSvc.aspx?ProductViewName={0}",
          ddProductViews.SelectedValue);
    }
}
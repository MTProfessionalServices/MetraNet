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


public partial class AmpSelectUsageQualificationPage : AmpWizardBasePage
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
    AmpCurrentPage = "SelectUsageQualification.aspx";
    AmpNextPage = "ItemsToAggregate.aspx";
    AmpPreviousPage = "AccountGroup.aspx";

    // Monitor changes made to the controls on the page.
    MonitorChangesInControlByClientId(hiddenUsageQualGroupName.ClientID);

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

      // Get the decision and its current usage qualification group setting.
      AmpServiceClient ampSvcGetDecisionClient = null;
      try
      {

        ampSvcGetDecisionClient = new AmpServiceClient();
        if (ampSvcGetDecisionClient.ClientCredentials != null)
        {
          ampSvcGetDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcGetDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        Decision decisionInstance;
        ampSvcGetDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);

        CurrentDecisionInstance = decisionInstance;

        if (decisionInstance.UsageQualificationGroup != null)
        {
          hiddenUsageQualGroupName.Value = decisionInstance.UsageQualificationGroup;

          // Can't do anything now about selecting the radio button that
          // corresponds to the decision's current usage qualification group.
          // (Must wait until the grid control is loaded.
          // After the grid control is loaded, if AmpAction is "View",
          // we also must disable selection of other rows!)
        }

        // Clean up client.
        ampSvcGetDecisionClient.Close();
        ampSvcGetDecisionClient = null;

      }
      catch (Exception ex)
      {
        SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_RETRIEVE_DECISION").ToString(), AmpDecisionName));
        logger.LogException("An error occurred while retrieving Decision '" + AmpDecisionName + "'", ex);
      }
      finally
      {
        if (ampSvcGetDecisionClient != null)
        {
          ampSvcGetDecisionClient.Abort();
        }
      }

    } // if (!IsPostBack)
  }


  protected override void OnLoadComplete(EventArgs e)
  {
    if (AmpAction != "View")
    {
      // If we are not in "View" mode, add an "Add" toolbar button to the grid of Usage Qualifications.
      MTGridButton button = new MTGridButton();
      button.ButtonID = "Add";
      button.ButtonText = GetLocalResourceObject("TEXT_ADD").ToString();
      button.ToolTip = GetLocalResourceObject("TEXT_ADD_TOOLTIP").ToString();
      button.IconClass = "Add";
      button.JSHandlerFunction = "onAdd";
      UsageQualGrid.ToolbarButtons.Add(button);
    }
  }


  protected void btnContinue_Click(object sender, EventArgs e)
  {
    AmpServiceClient ampSvcStoreDecisionClient = null;

    try
    {
      ampSvcStoreDecisionClient = new AmpServiceClient();
      if (ampSvcStoreDecisionClient.ClientCredentials != null)
      {
        ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      if (AmpAction != "View")
      {
        // Update decision's usage qualification group based on selected radio button.
        CurrentDecisionInstance.UsageQualificationGroup = hiddenUsageQualGroupName.Value;
        ampSvcStoreDecisionClient.SaveDecision(CurrentDecisionInstance);
        logger.LogDebug(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(), AmpDecisionName));
      }

      // Clean up client.
      ampSvcStoreDecisionClient.Close();
      ampSvcStoreDecisionClient = null;

      // Advance to next page in wizard.  Set EndResponse parameter to false
      // to prevent Response.Redirect from throwing ThreadAbortException.
      Response.Redirect(AmpNextPage, false);
    }
    catch (Exception ex)
    {
      SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_SAVE_DECISION").ToString(), AmpDecisionName));
      logger.LogException("An error occurred while saving Decision '" + AmpDecisionName + "'", ex);

      // Stay on current page.
    }
    finally
    {
      if (ampSvcStoreDecisionClient != null)
      {
        ampSvcStoreDecisionClient.Abort();
      }
    }

  } // btnContinue_Click

}
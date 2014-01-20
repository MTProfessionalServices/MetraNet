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

public partial class AmpDecisionInteractionsPage : AmpWizardBasePage
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
    AmpCurrentPage = "DecisionInteractions.aspx";
    AmpNextPage = "DecisionPriority.aspx";
    AmpPreviousPage = "ExecutionFrequency.aspx";

    //TBD Monitor changes made to the controls on the page.
    MonitorChangesInControl(RadioButtonList1);

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
      // Get the current value for the Decision's items to aggregate
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

        // depending on the value set for IsUsageConsumbed attribute, show that value as the selected radio button on the page.
        foreach (ListItem item in RadioButtonList1.Items)
        {
          switch (item.Value)
          {
            case "UsageConsumed":
              if (CurrentDecisionInstance.IsUsageConsumed == true)
              {
                item.Selected = true;
              }
              else
              {
                item.Selected = false;
              }
              break;
            case "UsageNOTConsumed":
              if (CurrentDecisionInstance.IsUsageConsumed == false)
              {
                item.Selected = true;
              }
              else
              {
                item.Selected = false;
              }
              break;
          }
        }

        // if we are in View mode, do not allow the radio button selections to change or the text box value to change.
        if (AmpAction == "View")
        {
          foreach (ListItem item in RadioButtonList1.Items)
          {
            if (item.Selected == false)
            {
              item.Enabled = false;
            }
          }
        }
        else
        {
          RadioButtonList1.Enabled = true;
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
    }
  }

  protected void btnContinue_Click(object sender, EventArgs e)
  {
    AmpServiceClient ampSvcStoreDecisionClient = null;
    // if any of the radio buttons are selected, update the decision to reflect the selected values.
    try
    {
      if (AmpAction != "View")
      {
        // If not viewing, save the decision.
        ampSvcStoreDecisionClient = new AmpServiceClient();
        if (ampSvcStoreDecisionClient.ClientCredentials != null)
        {
          ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        foreach (ListItem item in RadioButtonList1.Items)
        {
          switch (item.Value)
          {
            case "UsageConsumed":
              if (item.Selected == true)
              {
                CurrentDecisionInstance.IsUsageConsumed = true;
              }
              break;
            case "UsageNOTConsumed":
              if (item.Selected == true)
              {
                CurrentDecisionInstance.IsUsageConsumed = false;
              }
              break;
          }
        }

        ampSvcStoreDecisionClient.SaveDecision(CurrentDecisionInstance);
        logger.LogDebug(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(), AmpDecisionName));

        // Clean up client.
        ampSvcStoreDecisionClient.Close();
        ampSvcStoreDecisionClient = null;
      }
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
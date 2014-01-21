using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.UsageServer;

public partial class AmpErrorCheckPage : AmpWizardBasePage
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
    AmpCurrentPage = "ErrorCheck.aspx";
    AmpNextPage = "Start.aspx";
    AmpPreviousPage = "MiscellaneousAttributes.aspx";

    if (!IsPostBack)
    {
      // reset the AmpIsErrorChecked flag so the user is forced to do an Error Check before activating the Decision
      AmpIsErrorChecked = "false";

      // If the Decision is already active, don't show the "Activate Decision" button
      if (isDecisionActive() == true)
      {
        DeactivateDecisionButtonDiv.Visible = true;
        ActivateDecisionButtonDiv.Visible = false;
      }
      else
      {
        DeactivateDecisionButtonDiv.Visible = false;
        ActivateDecisionButtonDiv.Visible = true;
      }

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

  // This method checks to see if the current Decision is active or not
  // Returns true if the current Decision is active; otherwise, returns false.
  private bool isDecisionActive()
  {
    bool retval = false;
    AmpServiceClient ampSvcStoreDecisionClient = null;

    try
    {
      ampSvcStoreDecisionClient = new AmpServiceClient();
      if (ampSvcStoreDecisionClient.ClientCredentials != null)
      {
        ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      Decision decisionInstance;
      ampSvcStoreDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);

      // Clean up client.
      ampSvcStoreDecisionClient.Close();
      ampSvcStoreDecisionClient = null;

      if (decisionInstance.IsActive == true)
      {
        retval = true;
      }
    }
    catch (Exception ex)
    {
      SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_RETRIEVE_DECISION").ToString(), AmpDecisionName));
      logger.LogException("An error occurred while retrieving Decision '" + AmpDecisionName + "'", ex);
      retval = false;
    }
    finally
    {
      if (ampSvcStoreDecisionClient != null)
      {
        ampSvcStoreDecisionClient.Abort();
      }
    }
    return retval;
  }

  // Returns true on successful activation of the Decision
  // Returns false on failure to activate Decision
  private bool activateDecision()
  {
    // Activate the Decision
    AmpServiceClient ampSvcStoreDecisionClient = null;
    try
    {
      ampSvcStoreDecisionClient = new AmpServiceClient();
      if (ampSvcStoreDecisionClient.ClientCredentials != null)
      {
        ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      Decision decisionInstance;
      ampSvcStoreDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);
      decisionInstance.IsActive = true;
      ampSvcStoreDecisionClient.SaveDecision(decisionInstance);

      logger.LogInfo("Activated Decision Type '" + AmpDecisionName + "'");

      // Clean up client.
      ampSvcStoreDecisionClient.Close();
      ampSvcStoreDecisionClient = null;
    }
    catch (Exception ex)
    {
      SetError(GetLocalResourceObject("TEXT_ERROR_ACTIVATING_DECISION").ToString() + " '" + AmpDecisionName + "'");
      logger.LogException("An error occurred while activating Decision '" + AmpDecisionName + "'", ex);
      return false;
    }
    finally
    {
      if (ampSvcStoreDecisionClient != null)
      {
        ampSvcStoreDecisionClient.Abort();
      }
    }
    return true;
  }

  // Returns true on successful deactivation of the Decision
  // Returns false on failure to deactivate Decision
  private bool deactivateDecision()
  {
    // Activate the Decision
    AmpServiceClient ampSvcStoreDecisionClient = null;
    try
    {
      ampSvcStoreDecisionClient = new AmpServiceClient();
      if (ampSvcStoreDecisionClient.ClientCredentials != null)
      {
        ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      Decision decisionInstance;
      ampSvcStoreDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);
      decisionInstance.IsActive = false;
      ampSvcStoreDecisionClient.SaveDecision(decisionInstance);

      logger.LogInfo("Deactivated Decision Type '" + AmpDecisionName + "'");

      // Clean up client.
      ampSvcStoreDecisionClient.Close();
      ampSvcStoreDecisionClient = null;
    }
    catch (Exception ex)
    {
      SetError(GetLocalResourceObject("TEXT_ERROR_deACTIVATING_DECISION").ToString() + " '" + AmpDecisionName + "'");
      logger.LogException("An error occurred while deactivating Decision '" + AmpDecisionName + "'", ex);
      return false;
    }
    finally
    {
      if (ampSvcStoreDecisionClient != null)
      {
        ampSvcStoreDecisionClient.Abort();
      }
    }
    return true;
  }

  protected void btnActivateDecision_Click(object sender, EventArgs e)
  {
    // First, check if an error check has been done on the page. If not, alert to the user 
    // to run the error check first and exit function.
    if (AmpIsErrorChecked == "false")
    {
      Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "onActivateDecision();", true);
    }
    else
    {
      // Error check has already been run, so activate the decision type.
      activateDecision();

      // Show the appropriate text and button if the Decision Type is active
      if (isDecisionActive() == true)
      {
        DeactivateDecisionButtonDiv.Visible = true;
        ActivateDecisionButtonDiv.Visible = false;
      }
      else
      {
        DeactivateDecisionButtonDiv.Visible = false;
        ActivateDecisionButtonDiv.Visible = true;
      }
    }
  }

  protected void btnDeactivateDecision_Click(object sender, EventArgs e)
  {
    deactivateDecision();

    // Show the appropriate text and button if the Decision Type is inactive
    if (isDecisionActive() == true)
    {
      DeactivateDecisionButtonDiv.Visible = true;
      ActivateDecisionButtonDiv.Visible = false;
    }
    else
    {
      DeactivateDecisionButtonDiv.Visible = false;
      ActivateDecisionButtonDiv.Visible = true;
    }
  }

}
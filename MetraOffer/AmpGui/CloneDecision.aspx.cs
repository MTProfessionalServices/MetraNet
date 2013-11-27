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

public partial class AmpCloneDecisionPage : AmpWizardBasePage
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
        string decisionName = Request.QueryString["OrigDecisionName"];
        string activeFlag = Request.QueryString["OrigIsActive"];
        
        tbOrigDecisionName.Text = decisionName;

        if (activeFlag == "true")
        {
          cbDeactivateDecision.Visible = true;
          cbDeactivateDecision.BoxLabel = String.Format(cbDeactivateDecision.BoxLabel, decisionName);
        }
      }
    }


    protected void btnOK_Click(object sender, EventArgs e)
    {      
      string origDecisionName = tbOrigDecisionName.Text;
      string newDecisionName = tbNewDecisionName.Text;
      string newDescription = tbDescription.Text;

      AmpServiceClient ampSvcCloneDecisionClient = null;
      try
      {
        ampSvcCloneDecisionClient = new AmpServiceClient();
        if (ampSvcCloneDecisionClient.ClientCredentials != null)
        {
          ampSvcCloneDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcCloneDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        // Create the clone decision, deactivate it and make it editable.
        Decision cloneDecisionInstance;
        ampSvcCloneDecisionClient.CloneDecision(origDecisionName, newDecisionName, newDescription, out cloneDecisionInstance);
        cloneDecisionInstance.IsActive = false;
        cloneDecisionInstance.IsEditable = true;
        ampSvcCloneDecisionClient.SaveDecision(cloneDecisionInstance);
        logger.LogDebug(GetLocalResourceObject("TEXT_SUCCESS_CLONE_DECISION").ToString() + " '" + newDecisionName + "'");

        // Deactivate the original decision if box checked by user.
        if (cbDeactivateDecision.Visible & cbDeactivateDecision.Checked)
        {
          Decision origDecisionInstance;
          ampSvcCloneDecisionClient.GetDecision(origDecisionName, out origDecisionInstance);
          origDecisionInstance.IsActive = false;
          ampSvcCloneDecisionClient.SaveDecision(origDecisionInstance);           
        }

        // Clean up client.
        ampSvcCloneDecisionClient.Close();
        ampSvcCloneDecisionClient = null;

        // Close the page
        Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        // We may add error codes to AMP service exceptions in the future, but for now
        // this handler is here to provide a useful message to the AMP GUI user
        // if cloning of a decision failed because the name is already in use.
        string exMessage = ex.Detail.ErrorMessages[0];
        if (exMessage.Contains("Violation of UNIQUE KEY constraint"))
        {
          SetError(GetLocalResourceObject("TEXT_ERROR_DUPLICATE_DECISION_NAME").ToString() + ": '" + newDecisionName + "'");
          logger.LogException("Error: Decision name already in use: '" + newDecisionName + "'", ex);
        }
        else
        {
          SetError(GetLocalResourceObject("TEXT_ERROR_CLONE_DECISION").ToString() + " '" + origDecisionName + "'");
          logger.LogException("An error occurred while cloning Decision: '" + origDecisionName, ex);
        }

        // stay on page so user sees that an error occurred when cloning the decision
      }
      catch (Exception ex)
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_CLONE_DECISION").ToString() + " '" + origDecisionName + "'");
        logger.LogException("An error occurred while cloning Decision: '" + origDecisionName, ex);

        // stay on page so user sees that an error occurred when cloning the decision
      }
      finally
      {
        if (ampSvcCloneDecisionClient != null)
        {
          ampSvcCloneDecisionClient.Abort();
        }
      } 
    }


    protected void btnCancel_Click(object sender, EventArgs e)
    {      
      Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);      
    }
}
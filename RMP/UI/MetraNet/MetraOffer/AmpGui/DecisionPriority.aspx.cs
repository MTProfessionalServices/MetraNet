using System;
using System.Collections;
using System.Collections.Generic;
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

public partial class AmpDecisionPriorityPage : AmpWizardBasePage
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
    AmpCurrentPage = "DecisionPriority.aspx";
    AmpNextPage = "MiscellaneousAttributes.aspx";
    AmpPreviousPage = "DecisionInteractions.aspx";
    MonitorChangesInControlByClientId(ctrlValue.ddSourceTypeClientId);
    MonitorChangesInControlByClientId(ctrlValue.tbNumericSourceClientId);
    MonitorChangesInControlByClientId(ctrlValue.tbTextSourceClientId);
    MonitorChangesInControlByClientId(ctrlValue.ddSourceClientId);

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

        // Populate the drop down list with values from the decision's configured parameter table.
        List<KeyValuePair<String, String>> columns;
        if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName, out columns))
        {
          ctrlValue.DropdownItems = columns;
        }

        // If PriorityColumnName is null/not set for the decision, disable the drop down list and unselect the radio button for the drop down list.
        if (CurrentDecisionInstance.PriorityColumnName == null ||
          CurrentDecisionInstance.PriorityColumnName.Length == 0 ||
          CurrentDecisionInstance.PriorityColumnName.Equals(""))
        {
          ctrlValue.TextboxText = CurrentDecisionInstance.PriorityValue.ToString();
          ctrlValue.UseTextbox = true;
        }
        else
        {
          ctrlValue.DropdownSelectedText = CurrentDecisionInstance.PriorityColumnName;
          ctrlValue.UseDropdown = true;
        }

        // if we are in View mode, do not allow the values to change.
        ctrlValue.SetMode(AmpAction);

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

        if (ctrlValue.UseTextbox)
        {
          // get the number entered by the user and set that as the new hardcoded decision priority value for the Decision
          if (!String.IsNullOrEmpty(ctrlValue.TextboxText))
            CurrentDecisionInstance.PriorityValue = Convert.ToInt32(ctrlValue.TextboxText);
          else
          {
            throw new Exception(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_SAVE_DECISION").ToString(), AmpDecisionName)); 
          }
          // clear the Decision's priority column name in the case that the user configures a hardcoded priority value for this Decision
          CurrentDecisionInstance.PriorityColumnName = null;
        }
        else if (ctrlValue.UseDropdown && !String.IsNullOrEmpty(ctrlValue.DropdownSelectedText))
        {
          // Get the parameter table column name selected by the user and set that value in the Decision's PriorityColumnName
          CurrentDecisionInstance.PriorityColumnName = ctrlValue.DropdownSelectedText;
          CurrentDecisionInstance.PriorityValue = null;
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


  protected override void OnInit(EventArgs e)
  {
    // Register an event handler for a change in ctrlValue's ddSourceType dropdown.
    ctrlValue.EventSourceTypeChanged += new EventHandler(eventHandlerSourceTypeChanged);

    base.OnInit(e);
  }


  private void eventHandlerSourceTypeChanged(object sender, EventArgs e)
  {
    // Show grid if using hardcoded priority level value; hide grid if getting priority level from PT column.  
    if (ctrlValue.UseTextbox)
    {
      gridDiv.Attributes.Add("style", "display: block;");
    }
    else
    {
      gridDiv.Attributes.Add("style", "display: none;");
    }
  }

}
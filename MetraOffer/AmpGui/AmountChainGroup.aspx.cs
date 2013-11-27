using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.DomainModel.ProductCatalog;

public partial class AmpAmountChainGroupPage : AmpWizardBasePage
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
        AmpCurrentPage = "AmountChainGroup.aspx";
        AmpNextPage = "ExecutionFrequency.aspx";
        AmpPreviousPage = "SelectDecisionAction.aspx";

        // Monitor changes made to the controls on the page.
        MonitorChangesInControlByClientId(hiddenAmtChainGroupName.ClientID);
        MonitorChangesInControl(ddAmountChainGroupFromParamTableSource);

        setCheckBoxEventHandler();

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

                // Disable the controls in View mode
                ddAmountChainGroupFromParamTableSource.ReadOnly = true;
                FromParamTableCheckBox.Enabled = false;
            }
            else // If we are editing a decision, show the "Save & Continue" button
            {
                btnContinue.Visible = false;
                btnSaveAndContinue.Visible = true;
            }

            // Get the decision and its current amount chain group setting.
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

                List<KeyValuePair<String, String>> paramTableColumns;
                if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName,
                                                           out paramTableColumns))
                {
                    setParamTableDropDown(paramTableColumns);
                }

                if (!String.IsNullOrEmpty(decisionInstance.PvToAmountChainMappingValue))
                {
                    hiddenAmtChainGroupName.Value = decisionInstance.PvToAmountChainMappingValue;
                    FromParamTableCheckBox.Checked = false;
                    ddAmountChainGroupFromParamTableSource.Enabled = false;
                    if (AmpAction == "View")
                    {
                        divAmountChainGroupFromParamTableDropdownSource.Attributes.Add("style", "display: none;");
                    }
                    // Can't do anything now about selecting the radio button that
                    // corresponds to the decision's current amount chain group.
                    // (Must wait until the grid control is loaded.
                    // After the grid control is loaded, if AmpAction is "View",
                    // we also must disable selection of other rows!)
                }
                else
                {
                    hiddenAmtChainGroupName.Value = decisionInstance.PvToAmountChainMappingColumnName;
                    FromParamTableCheckBox.Checked = true;
                    ddAmountChainGroupFromParamTableSource.Enabled = true;
                    ddAmountChainGroupFromParamTableSource.SelectedValue = decisionInstance.PvToAmountChainMappingColumnName;
                    divAmountChainGroupGrid.Attributes.Add("style", "display: none;");
                }

                // Clean up client.
                ampSvcGetDecisionClient.Close();
                ampSvcGetDecisionClient = null;

            }
            catch (Exception ex)
            {
                SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_RETRIEVE_DECISION").ToString(),
                                       AmpDecisionName));
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

    private void setParamTableDropDown(List<KeyValuePair<String, String>> paramTableColumns)
    {
        ddAmountChainGroupFromParamTableSource.Items.Clear();
        foreach (var item in paramTableColumns)
        {
            ddAmountChainGroupFromParamTableSource.Items.Add(new ListItem(item.Value, item.Key));
        }
    }

    private void setCheckBoxEventHandler()
    {
        FromParamTableCheckBox.Listeners = @"{ 'check' : this.onChange_" + FromParamTableCheckBox.ID + @", scope: this }";

        String scriptString = "<script type=\"text/javascript\">";
        scriptString += "function onChange_" + FromParamTableCheckBox.ID + "(field, newvalue, oldvalue) \n";
        scriptString += "{ \n";
        scriptString += "return updateActiveControls(); \n";
        scriptString += "} \n";
        scriptString += "</script>";

        Page.ClientScript.RegisterStartupScript(FromParamTableCheckBox.GetType(), "onChange_" + FromParamTableCheckBox.ID, scriptString);
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
      AmpServiceClient ampSvcStoreDecisionClient = null;

      try
      {
        // NOTE: We may want to remove this check and let the 
        // Error Check page warn the user later.  This would allow the user
        // to continue defining a new Decision now, while postponing
        // the definition of a new Amount Chain Group to use with the Decision.
        if ((AmpAction != "View") && (hiddenAmtChainGroupName.Value == String.Empty))
        {
          SetError(GetLocalResourceObject("TEXT_ERROR_NO_AMOUNT_CHAIN_GROUP").ToString());
          logger.LogError(String.Format("No Amount Chain Group was selected for Decision '{0}'", AmpDecisionName));
          return;  // Stay on same page.
        }

        ampSvcStoreDecisionClient = new AmpServiceClient();
        if (ampSvcStoreDecisionClient.ClientCredentials != null)
        {
          ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        if (AmpAction != "View")
        {
          // Update decision's amount chain group based on selected radio button.
            if (!FromParamTableCheckBox.Checked)
            {
                CurrentDecisionInstance.PvToAmountChainMappingValue = hiddenAmtChainGroupName.Value;
                CurrentDecisionInstance.PvToAmountChainMappingColumnName = null;
            }
            else if (FromParamTableCheckBox.Checked)
            {
                CurrentDecisionInstance.PvToAmountChainMappingValue = null;
                CurrentDecisionInstance.PvToAmountChainMappingColumnName = ddAmountChainGroupFromParamTableSource.SelectedValue;
            }
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

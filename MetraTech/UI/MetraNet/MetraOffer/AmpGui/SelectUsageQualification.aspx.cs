using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Controls;
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
        setCheckBoxEventHandler();
        // Monitor changes made to the controls on the page.
        MonitorChangesInControlByClientId(hiddenUsageQualGroupName.ClientID);
        MonitorChangesInControlByClientId(ddUsageQualFromParamTableSource.ClientID);
        MonitorChangesInControlByClientId(FromParamTableCheckBox.ClientID);
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
                FromParamTableCheckBox.Enabled = false;
                ddUsageQualFromParamTableSource.ReadOnly = true;
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
                List<KeyValuePair<String, String>> paramTableColumns;
                if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName,
                                                           out paramTableColumns))
                {
                    setParamTableDropDown(paramTableColumns);
                }
                if (decisionInstance.UsageQualificationGroupValue != null)
                {
                    hiddenUsageQualGroupName.Value = decisionInstance.UsageQualificationGroupValue;
                    ddUsageQualFromParamTableSource.Enabled = false;

                    if (AmpAction == "View")
                    {
                        divUsageQualFromParamTableDropdownSource.Attributes.Add("style", "display: none;");
                    }
                    // Can't do anything now about selecting the radio button that
                    // corresponds to the decision's current usage qualification group.
                    // (Must wait until the grid control is loaded.
                    // After the grid control is loaded, if AmpAction is "View",
                    // we also must disable selection of other rows!)
                }
                else
                {
                    FromParamTableCheckBox.Checked = true;
                    hiddenUsageQualGroupName.Value = decisionInstance.UsageQualificationGroupColumnName;
                    ddUsageQualFromParamTableSource.SelectedValue = hiddenUsageQualGroupName.Value;
                    divUsageQualGrid.Attributes.Add("style", "display: none;");
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
        ddUsageQualFromParamTableSource.Items.Clear();
        foreach (var item in paramTableColumns)
        {
            ddUsageQualFromParamTableSource.Items.Add(new ListItem(item.Value, item.Key));
        }
    }

    private void setCheckBoxEventHandler()
    {
        FromParamTableCheckBox.Listeners = @"{ 'check' : this.onChange_" + FromParamTableCheckBox.ID +
                                           @", scope: this }";

        String scriptString = "<script type=\"text/javascript\">";
        scriptString += "function onChange_" + FromParamTableCheckBox.ID + "(field, newvalue, oldvalue) \n";
        scriptString += "{ \n";
        scriptString += "return updateActiveControls(); \n";
        scriptString += "} \n";
        scriptString += "</script>";

        Page.ClientScript.RegisterStartupScript(FromParamTableCheckBox.GetType(),
                                                "onChange_" + FromParamTableCheckBox.ID, scriptString);
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
            if (AmpAction != "View" && String.IsNullOrEmpty(hiddenUsageQualGroupName.Value))
            {
                SetError(GetLocalResourceObject("TEXT_ERROR_NO_USAGE_QUAL").ToString());
                logger.LogError(String.Format("No Usage Qualification was selected for Decision '{0}'", AmpDecisionName));
                return; // Stay on same page.

            }


            if (AmpAction != "View")
            {
                if (FromParamTableCheckBox.Checked)
                {
                    CurrentDecisionInstance.UsageQualificationGroupColumnName = hiddenUsageQualGroupName.Value;
                    CurrentDecisionInstance.UsageQualificationGroupValue = null;
                    logger.LogError("is saving :" + CurrentDecisionInstance.UsageQualificationGroupColumnName + " " +
                                    CurrentDecisionInstance.UsageQualificationGroupValue);
                }
                else
                {
                    CurrentDecisionInstance.UsageQualificationGroupValue = hiddenUsageQualGroupName.Value;
                    CurrentDecisionInstance.UsageQualificationGroupColumnName = null;
                }
                ampSvcStoreDecisionClient.SaveDecision(CurrentDecisionInstance);
                logger.LogDebug(
                    String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(),
                                  AmpDecisionName));
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
            SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_SAVE_DECISION").ToString(),
                                   AmpDecisionName));
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

    }

    // btnContinue_Click

}
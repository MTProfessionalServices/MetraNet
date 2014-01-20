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

public partial class AmpItemsToAggregatePage : AmpWizardBasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        this.lblTitle.Text = String.Format(this.lblTitle.Text, this.AmpDecisionName);
        // Extra check that user has permission to configure AMP decisions.
        if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
        {
            Response.End();
            return;
        }

        // Set the current, next, and previous AMP pages right away.
        AmpCurrentPage = "ItemsToAggregate.aspx";
        AmpNextPage = "DecisionRange.aspx";
        AmpPreviousPage = "SelectUsageQualification.aspx";

        // Monitor changes made to the controls on the page.
        MonitorChangesInControl(radAddUpMonetaryChargeAmounts);
        MonitorChangesInControl(radAddUpUnitsOfUsage);
        MonitorChangesInControl(radCountTheNumberOfEvents);
        MonitorChangesInControl(radGetItemAggregatedFromParamTable);
        MonitorChangesInControl(ddItemAggregatedFromParamTableSource);

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

            // clear out the radio buttons for items to aggregate
            radAddUpMonetaryChargeAmounts.Checked = false;
            radAddUpUnitsOfUsage.Checked = false;
            radCountTheNumberOfEvents.Checked = false;
            radGetItemAggregatedFromParamTable.Checked = false;

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

                List<KeyValuePair<String, String>> paramTableColumns;
                if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName, out paramTableColumns))
                {
                    setParamTableDropDown(paramTableColumns);
                }

                // depending on the value set for ItemAggregated, show that value as the selected radio button on the page.
                if (decisionInstance.ItemAggregatedValue.HasValue)
                {
                    switch (decisionInstance.ItemAggregatedValue.ToString())
                    {
                        case "AGGREGATE_UNITS_OF_USAGE":
                            radAddUpUnitsOfUsage.Checked = true;
                            break;
                        case "AGGREGATE_USAGE_EVENTS":
                            radCountTheNumberOfEvents.Checked = true;
                            break;
                        case "AGGREGATE_AMOUNT":
                            radAddUpMonetaryChargeAmounts.Checked = true;
                            break;
                    }
                    divItemAggregatedFromParamTableDropdownSource.Attributes.Add("style", "display:none");
                }
                else
                {
                    radGetItemAggregatedFromParamTable.Checked = true;
                    divItemAggregatedFromParamTableDropdownSource.Attributes.Add("style", "display:block");
                }

                // if we are in View mode, do not allow the radio button selection to change.
                if (AmpAction == "View")
                {
                    if (radAddUpMonetaryChargeAmounts.Checked)
                    {
                        radAddUpMonetaryChargeAmounts.Enabled = true;
                        radAddUpUnitsOfUsage.Enabled = false;
                        radCountTheNumberOfEvents.Enabled = false;
                        radGetItemAggregatedFromParamTable.Enabled = false;
                    }
                    else if (radAddUpUnitsOfUsage.Checked)
                    {
                        radAddUpMonetaryChargeAmounts.Enabled = false;
                        radAddUpUnitsOfUsage.Enabled = true;
                        radCountTheNumberOfEvents.Enabled = false;
                        radGetItemAggregatedFromParamTable.Enabled = false;
                        
                    }
                    else if (radCountTheNumberOfEvents.Checked)
                    {
                        radAddUpMonetaryChargeAmounts.Enabled = false;
                        radAddUpUnitsOfUsage.Enabled = false;
                        radCountTheNumberOfEvents.Enabled = true;
                        radGetItemAggregatedFromParamTable.Enabled = false;
                        
                    }
                    else if (radGetItemAggregatedFromParamTable.Checked)
                    {
                        radAddUpMonetaryChargeAmounts.Enabled = false;
                        radAddUpUnitsOfUsage.Enabled = false;
                        radCountTheNumberOfEvents.Enabled = false;
                        radGetItemAggregatedFromParamTable.Enabled = true;                        
                    }

                    ddItemAggregatedFromParamTableSource.Enabled = false;
                    ddItemAggregatedFromParamTableSource.ReadOnly = true;
                }
                else // allow the radio button selection to change
                {
                    radAddUpMonetaryChargeAmounts.Enabled = true;
                    radAddUpUnitsOfUsage.Enabled = true;
                    radCountTheNumberOfEvents.Enabled = true;
                    radGetItemAggregatedFromParamTable.Enabled = true;

                    // Show/Hide the parameter table column drop down depending on which radio button is selected
                    radAddUpMonetaryChargeAmounts.Attributes.Add("OnClick", "Javascript:ShowHideParamTableDD();");
                    radAddUpUnitsOfUsage.InputAttributes.Add("OnClick", "Javascript:ShowHideParamTableDD();");
                    radCountTheNumberOfEvents.InputAttributes.Add("OnClick", "Javascript:ShowHideParamTableDD();");
                    radGetItemAggregatedFromParamTable.InputAttributes.Add("OnClick",
                                                                           "Javascript:ShowHideParamTableDD();");
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
        }

    }

    private void setParamTableDropDown(List<KeyValuePair<String, String>> paramTableColumns)
    {
        ddItemAggregatedFromParamTableSource.Items.Clear();
        foreach (var item in paramTableColumns)
        {
            ddItemAggregatedFromParamTableSource.Items.Add(new ListItem(item.Value, item.Key));
        }
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
        AmpServiceClient ampSvcStoreDecisionClient = null;
        // if any of the radio buttons are selected, update the decision to reflect the selected aggregation method.
        try
        {
            if (radAddUpUnitsOfUsage.Checked ||
                radCountTheNumberOfEvents.Checked ||
                radAddUpMonetaryChargeAmounts.Checked ||
                radGetItemAggregatedFromParamTable.Checked)
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

                    if (radAddUpUnitsOfUsage.Checked)
                    {
                        CurrentDecisionInstance.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_UNITS_OF_USAGE;
                        CurrentDecisionInstance.ItemAggregatedColumnName = null;
                    }
                    else if (radCountTheNumberOfEvents.Checked)
                    {
                        CurrentDecisionInstance.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_USAGE_EVENTS;
                        CurrentDecisionInstance.ItemAggregatedColumnName = null;
                    }
                    else if (radAddUpMonetaryChargeAmounts.Checked)
                    {
                        CurrentDecisionInstance.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_AMOUNT;
                        CurrentDecisionInstance.ItemAggregatedColumnName = null;
                    }
                    else if (radGetItemAggregatedFromParamTable.Checked)
                    {
                        CurrentDecisionInstance.ItemAggregatedValue = null;
                        CurrentDecisionInstance.ItemAggregatedColumnName =
                            ddItemAggregatedFromParamTableSource.SelectedValue;
                    }

                    ampSvcStoreDecisionClient.SaveDecision(CurrentDecisionInstance);
                    logger.LogDebug(
                        String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(),
                                      AmpDecisionName));

                    // Clean up client.
                    ampSvcStoreDecisionClient.Close();
                    ampSvcStoreDecisionClient = null;
                }
            }
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
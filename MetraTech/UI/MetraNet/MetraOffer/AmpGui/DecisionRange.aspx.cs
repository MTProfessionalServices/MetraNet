using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;


public partial class AmpDecisionRangePage : AmpWizardBasePage
{
    protected bool showDivRestartParamTable = false;
    protected bool showDivProrateStartParamTable = false;
    protected bool showDivProrateEndParamTable = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Extra check that user has permission to configure AMP decisions.
        if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
        {
            Response.End();
            return;
        }
        this.lblTitleDecisionRange.Text = String.Format(this.lblTitleDecisionRange.Text, this.AmpDecisionName);
        // Set the current, next, and previous AMP pages right away.
        AmpCurrentPage = "DecisionRange.aspx";
        AmpNextPage = "DecisionCycle.aspx";
        AmpPreviousPage = "ItemsToAggregate.aspx";

        if (!IsPostBack)
        {
            MonitorChangesInControlByClientId(startRange.ddSourceTypeClientId);
            MonitorChangesInControlByClientId(startRange.tbNumericSourceClientId);
            MonitorChangesInControlByClientId(startRange.tbTextSourceClientId);
            MonitorChangesInControlByClientId(startRange.ddSourceClientId);
            MonitorChangesInControlByClientId(endRange.ddSourceTypeClientId);
            MonitorChangesInControlByClientId(endRange.tbNumericSourceClientId);
            MonitorChangesInControlByClientId(endRange.tbTextSourceClientId);
            MonitorChangesInControlByClientId(endRange.ddSourceClientId);
            MonitorChangesInControl(ddDecisionRangeRestart);
            MonitorChangesInControl(ddProrateEnd);
            MonitorChangesInControl(ddProrateStart);
            MonitorChangesInControl(ddRangeRestartFromParamTableSource);
            MonitorChangesInControl(ddProrateStartFromParamTableDropdownSource);
            MonitorChangesInControl(ddProrateEndFromParamTableDropdownSource);

            CurrentDecisionInstance = GetDecision();

            SetUpYesNoDropDown(ddDecisionRangeRestart);
            SetUpYesNoDropDown(ddProrateStart);
            SetUpYesNoDropDown(ddProrateEnd);
            // Fill drop down controls for start and end range parameter table field
            FillDropDownControls(CurrentDecisionInstance.ParameterTableName);

            //Setup page settings for different ampActions
            DecisionRangePageSettings();
        }
    }

    private void SetUpYesNoDropDown(MTDropDown dropDown)
    {
        dropDown.Items.Add(new ListItem {Text = Resources.Resource.TEXT_YES, Value = Resources.Resource.TEXT_YES});
        dropDown.Items.Add(new ListItem {Text = Resources.Resource.TEXT_NO, Value = Resources.Resource.TEXT_NO});
        dropDown.Items.Add(new ListItem
            {
                Text = Resources.Resource.TEXT_FROM_PARAMETER_TABLE,
                Value = Resources.Resource.TEXT_FROM_PARAMETER_TABLE
            });
        dropDown.Listeners = @"{ 'select' : " + dropDown.ID + "Changed , 'load' : " + dropDown.ID +
                             "InitialState, scope: this }";
    }

    private void FillDropDownControls(string tableName)
    {
        // Populate the drop down list with values from the decision's configured parameter table.
        List<KeyValuePair<String, String>> columns;
        if (GetParameterTableColumnNamesWithClient(tableName, out columns))
        {
            startRange.DropdownItems = columns;
            endRange.DropdownItems = columns;
            foreach (var keyValuePair in columns)
            {
                ddRangeRestartFromParamTableSource.Items.Add(new ListItem(keyValuePair.Key, keyValuePair.Value));
                ddProrateStartFromParamTableDropdownSource.Items.Add(new ListItem(keyValuePair.Key, keyValuePair.Value));
                ddProrateEndFromParamTableDropdownSource.Items.Add(new ListItem(keyValuePair.Key, keyValuePair.Value));
            }
        }
    }

    private Decision GetDecision()
    {
        AmpServiceClient ampSvcGetDecisionClient = null;
        Decision decisionInstance = null;
        try
        {
            ampSvcGetDecisionClient = new AmpServiceClient();
            if (ampSvcGetDecisionClient.ClientCredentials != null)
            {
                ampSvcGetDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                ampSvcGetDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            ampSvcGetDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);
        }
        catch (Exception ex)
        {
            SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_RETRIEVE_DECISION, AmpDecisionName));
            logger.LogException(String.Format("An error occurred while retrieving Decision '{0}'", AmpDecisionName), ex);
        }
        finally
        {
            if (ampSvcGetDecisionClient != null)
            {
                ampSvcGetDecisionClient.Abort();
            }
        }
        return decisionInstance;
    }

    private void EditActionSettings()
    {
        if (CurrentDecisionInstance.TierStartValue != null)
        {
            startRange.TextboxText = CurrentDecisionInstance.TierStartValue.ToString();
            startRange.UseTextbox = true;
        }
        else if (CurrentDecisionInstance.TierStartColumnName != null)
        {
            startRange.DropdownSelectedText = CurrentDecisionInstance.TierStartColumnName;
            startRange.UseDropdown = true;
        }
        if (CurrentDecisionInstance.TierEndValue != null)
        {
            endRange.TextboxText = CurrentDecisionInstance.TierEndValue.ToString();
            endRange.UseTextbox = true;
        }
        else if (CurrentDecisionInstance.TierEndColumnName != null)
        {
            endRange.DropdownSelectedText = CurrentDecisionInstance.TierEndColumnName;
            endRange.UseDropdown = true;
        }
        else
        {
            endRange.UseTextbox = true;
        }

        if (!String.IsNullOrEmpty(CurrentDecisionInstance.TierRepetitionValue))
        {
            ddDecisionRangeRestart.SelectedValue = CurrentDecisionInstance.TierRepetitionValue.Equals("None")
                                                       ? Resources.Resource.TEXT_NO
                                                       : Resources.Resource.TEXT_YES;
        }
        else
        {
            ddDecisionRangeRestart.SelectedValue = Resources.Resource.TEXT_FROM_PARAMETER_TABLE;
            ddRangeRestartFromParamTableSource.SelectedValue = CurrentDecisionInstance.TierRepetitionColumnName;
        }

        if (CurrentDecisionInstance.TierProrationValue != null)
        {
            switch (CurrentDecisionInstance.TierProrationValue)
            {
                case Decision.TierProrationEnum.PRORATE_BOTH:
                    ddProrateStart.SelectedValue = Resources.Resource.TEXT_YES;
                    ddProrateEnd.SelectedValue = Resources.Resource.TEXT_YES;
                    break;
                case Decision.TierProrationEnum.PRORATE_TIER_START:
                    ddProrateStart.SelectedValue = Resources.Resource.TEXT_YES;
                    ddProrateEnd.SelectedValue = Resources.Resource.TEXT_NO;
                    break;
                case Decision.TierProrationEnum.PRORATE_TIER_END:
                    ddProrateStart.SelectedValue = Resources.Resource.TEXT_NO;
                    ddProrateEnd.SelectedValue = Resources.Resource.TEXT_YES;
                    break;
                case Decision.TierProrationEnum.PRORATE_NONE:
                    ddProrateStart.SelectedValue = Resources.Resource.TEXT_NO;
                    ddProrateEnd.SelectedValue = Resources.Resource.TEXT_NO;
                    break;
            }
        }
        else
        {
            ddProrateStart.SelectedValue = Resources.Resource.TEXT_FROM_PARAMETER_TABLE;
            ddProrateEnd.SelectedValue = Resources.Resource.TEXT_FROM_PARAMETER_TABLE;
            ddProrateStartFromParamTableDropdownSource.SelectedValue = CurrentDecisionInstance.TierProrationColumnName;
            ddProrateEndFromParamTableDropdownSource.SelectedValue = CurrentDecisionInstance.TierProrationColumnName;
        }

        if (ddDecisionRangeRestart.SelectedValue == Resources.Resource.TEXT_FROM_PARAMETER_TABLE)
        {
            showDivRestartParamTable = true;
        }
        if (ddProrateStart.SelectedValue == Resources.Resource.TEXT_FROM_PARAMETER_TABLE)
        {
            showDivProrateStartParamTable = true;
        }
        if (ddProrateEnd.SelectedValue == Resources.Resource.TEXT_FROM_PARAMETER_TABLE)
        {
            showDivProrateEndParamTable = true;
        }
    }

    private void ViewActionSettings()
    {
        startRange.ReadOnly = true;
        endRange.ReadOnly = true;

        btnSaveAndContinue.CausesValidation = false;
        btnSaveAndContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
    }

    private void DefaultActionSettings()
    {
        startRange.UseTextbox = true;
        startRange.TextboxText = "0";

        endRange.UseTextbox = true;
        endRange.TextboxText = "0";
    }


    private void DecisionRangePageSettings()
    {
        btnSaveAndContinue.Text = AmpAction != "View"
                                      ? Resources.Resource.TEXT_NEXT
                                      : Resources.Resource.TEXT_CONTINUE;

        switch (AmpAction)
        {
            case "Edit":
                EditActionSettings();
                break;
            case "View":
                EditActionSettings();
                ViewActionSettings();
                break;
            case "Created":
                DefaultActionSettings();
                EditActionSettings();
                break;
            default:
                DefaultActionSettings();
                break;
        }
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
        AmpServiceClient ampSvcSaveDecisionRangeClient = null;
        try
        {
            ampSvcSaveDecisionRangeClient = new AmpServiceClient();
            if (ampSvcSaveDecisionRangeClient.ClientCredentials != null)
            {
                ampSvcSaveDecisionRangeClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                ampSvcSaveDecisionRangeClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            if (AmpAction != "View")
            {
                SetDecisionProperties();
                ampSvcSaveDecisionRangeClient.SaveDecision(CurrentDecisionInstance);
                logger.LogDebug(String.Format(Resources.AmpWizard.TEXT_SUCCESS_SAVE_DECISION, AmpDecisionName));
            }

            ampSvcSaveDecisionRangeClient.Close();
            ampSvcSaveDecisionRangeClient = null;

            Response.Redirect(AmpNextPage, false);
        }
        catch (Exception ex)
        {
            SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_SAVE_DECISION, AmpDecisionName));
            logger.LogException(String.Format("An error occurred while saving Decision '{0}'", AmpDecisionName), ex);
        }
        finally
        {
            if (ampSvcSaveDecisionRangeClient != null)
            {
                ampSvcSaveDecisionRangeClient.Abort();
            }
        }
    }

    private void SetDecisionProperties()
    {
        //setup start of range property
        if (startRange.UseTextbox == true && !String.IsNullOrEmpty(startRange.TextboxText))
        {
            CurrentDecisionInstance.TierStartValue = Decimal.Parse(startRange.TextboxText);
            CurrentDecisionInstance.TierStartColumnName = null;
        }
        else
        {
            CurrentDecisionInstance.TierStartColumnName = startRange.DropdownSelectedText;
            CurrentDecisionInstance.TierStartValue = null;
        }

        //setup end of range property
        if (endRange.UseTextbox == true && !String.IsNullOrEmpty(endRange.TextboxText))
        {
            CurrentDecisionInstance.TierEndValue = Decimal.Parse(endRange.TextboxText);
            CurrentDecisionInstance.TierEndColumnName = null;
        }
        else
        {
            CurrentDecisionInstance.TierEndColumnName = endRange.DropdownSelectedText;
            CurrentDecisionInstance.TierEndValue = null;
        }

        //setup rest as decision property 
        if (ddDecisionRangeRestart.SelectedValue == Resources.Resource.TEXT_YES)
        {
            CurrentDecisionInstance.TierRepetitionValue = "Individual";
            CurrentDecisionInstance.TierRepetitionColumnName = null;
        }
        else if (ddDecisionRangeRestart.SelectedValue == Resources.Resource.TEXT_NO)
        {
            CurrentDecisionInstance.TierRepetitionValue = "None";
            CurrentDecisionInstance.TierRepetitionColumnName = null;
        }
        else
        {
            CurrentDecisionInstance.TierRepetitionValue = null;
            CurrentDecisionInstance.TierRepetitionColumnName = ddRangeRestartFromParamTableSource.SelectedValue;
        }

        //setup proration properties
        if (ddProrateStart.SelectedValue != Resources.Resource.TEXT_FROM_PARAMETER_TABLE &&
            ddProrateEnd.SelectedValue != Resources.Resource.TEXT_FROM_PARAMETER_TABLE)
        {
            if ((ddProrateStart.SelectedValue == Resources.Resource.TEXT_YES) &&
                (ddProrateEnd.SelectedValue == Resources.Resource.TEXT_YES))
            {
                CurrentDecisionInstance.TierProrationValue = Decision.TierProrationEnum.PRORATE_BOTH;
            }

            if ((ddProrateStart.SelectedValue == Resources.Resource.TEXT_YES) &&
                (ddProrateEnd.SelectedValue == Resources.Resource.TEXT_NO))
            {
                CurrentDecisionInstance.TierProrationValue = Decision.TierProrationEnum.PRORATE_TIER_START;
            }

            if ((ddProrateStart.SelectedValue == Resources.Resource.TEXT_NO) &&
                (ddProrateEnd.SelectedValue == Resources.Resource.TEXT_YES))
            {
                CurrentDecisionInstance.TierProrationValue = Decision.TierProrationEnum.PRORATE_TIER_END;
            }

            if ((ddProrateStart.SelectedValue == Resources.Resource.TEXT_NO) &&
                (ddProrateEnd.SelectedValue == Resources.Resource.TEXT_NO))
            {
                CurrentDecisionInstance.TierProrationValue = Decision.TierProrationEnum.PRORATE_NONE;
            }
            CurrentDecisionInstance.TierProrationColumnName = null;
        }
        else
        {
            // One of them is set to from parameter table, so set them both to first parameter table column
            CurrentDecisionInstance.TierProrationValue = null;
            CurrentDecisionInstance.TierProrationColumnName = ddProrateStartFromParamTableDropdownSource.SelectedValue;
        }
    }
}
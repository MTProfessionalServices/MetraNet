using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.MetraNet.App_Code;


public partial class AmpDecisionCyclePage : AmpWizardBasePage
{
    protected bool ShowDivDecisionCycle = true;
    protected bool ShowDivParamTable = false;
    protected void Page_Load(object sender, EventArgs e)
    {

        // Extra check that user has permission to configure AMP decisions.
        if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
        {
            Response.End();
            return;
        }
        setTimeCycleUnitDropDown();

        
        if (!IsPostBack)
        {
            // Set the current, next, and previous AMP pages right away.
            AmpCurrentPage = "DecisionCycle.aspx";
            AmpNextPage = "SelectDecisionAction.aspx";
            AmpPreviousPage = "DecisionRange.aspx";

            if (AmpAction != "View")
            {
                MonitorChangesInControl(ddTimeCycleUnit);
                MonitorChangesInControl(RBL_DecisionEffect);
                MonitorChangesInControlByClientId(numberOfMonth.ddSourceTypeClientId);
                MonitorChangesInControlByClientId(numberOfMonth.tbNumericSourceClientId);
                MonitorChangesInControlByClientId(numberOfMonth.tbTextSourceClientId);
                MonitorChangesInControlByClientId(numberOfMonth.ddSourceClientId);
                MonitorChangesInControlByClientId(numberMonthBillingInterval.ddSourceTypeClientId);
                MonitorChangesInControlByClientId(numberMonthBillingInterval.tbNumericSourceClientId);
                MonitorChangesInControlByClientId(numberMonthBillingInterval.tbTextSourceClientId);
                MonitorChangesInControlByClientId(numberMonthBillingInterval.ddSourceClientId);
                MonitorChangesInControlByClientId(decisionCycleCustomized.ddSourceTypeClientId);
                MonitorChangesInControlByClientId(decisionCycleCustomized.tbNumericSourceClientId);
                MonitorChangesInControlByClientId(decisionCycleCustomized.tbTextSourceClientId);
                MonitorChangesInControlByClientId(decisionCycleCustomized.ddSourceClientId);
                MonitorChangesInControlByClientId(ddUnitOfTimeFromParamTableSource.ClientID);
            }


            CurrentDecisionInstance = GetDecisionWithClient();
            lblTitleDecisionCycle.Text = String.Format(lblTitleDecisionCycle.Text, CurrentDecisionInstance.Name);
            SetDDUnitOfTimeEvent();
            DecisionCyclePageSettings();

        }
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {

        if (AmpAction != "View")
        {
            if (!SetDecisionCycleProperties())
            {
                return;
            }
            if (!SaveDecisionWithClient())
            {
                return;
            }
        }
        Response.Redirect(AmpNextPage, false);
    }

    private void setTimeCycleUnitDropDown()
    {

        List<string> items = new List<string>(GetLocalResourceObject("LIST_DD_TIME_CYCLE_UNIT").ToString().Split(','));
        int i = 0;
        foreach (var item in items)
        {
            ddTimeCycleUnit.Items.Add(new ListItem { Text = item, Value = i.ToString() });
            i++;
        }
        ddTimeCycleUnit.Listeners = @"{ 'select' : DecisionCycleUnitOfTimeChanged , 'load' : DecisionCycleUnitOfTimeInitialState, scope: this }";
    }

    private void setParamTableDropDown(List<KeyValuePair<String, String>> paramTableColumns)
    {
        ddUnitOfTimeFromParamTableSource.Items.Clear();
        foreach (var item in paramTableColumns)
        {
            ddUnitOfTimeFromParamTableSource.Items.Add(new ListItem(item.Value, item.Key));
        }
    }

    private void DecisionCyclePageSettings()
    {
        InitializeAmpControlProperties();

        List<KeyValuePair<String, String>> paramTableColumns;
        if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName, out paramTableColumns))
        {
            numberOfMonth.DropdownItems = paramTableColumns;
            numberMonthBillingInterval.DropdownItems = paramTableColumns;
            decisionCycleCustomized.DropdownItems = paramTableColumns;
            setParamTableDropDown(paramTableColumns);
        }

        DecisionCycleActionSettings();

        if (AmpAction == "View")
        {
            ViewActionSettings();

            btnSaveAndContinue.Text = Resources.Resource.TEXT_CONTINUE;
            btnSaveAndContinue.CausesValidation = false;
            btnSaveAndContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
        }
        else
        {
            btnSaveAndContinue.Text = Resources.Resource.TEXT_NEXT;
        }
    }

    private void ViewActionSettings()
    {
        ddUnitOfTimeFromParamTableSource.Enabled = false;
        ddTimeCycleUnit.Enabled = false;
        SetRadioButtonViewAction(RBL_DecisionEffect);
        numberOfMonth.ReadOnly = true;
        numberMonthBillingInterval.ReadOnly = true;
        decisionCycleCustomized.ReadOnly = true;
        ddUnitOfTimeFromParamTableSource.ReadOnly = true;
        if (RBL_DecisionEffect.Items[0].Selected)
        {
            decisionCycleCustomized.Visible = false;
        }
    }

    private void DecisionCycleActionSettings()
    {
        GetDecisionCycleUnitOfTime();

        if (!CurrentDecisionInstance.CycleUnitTypeValue.Equals(Decision.CycleUnitTypeEnum.CYCLE_GET_FROM_PARAMETER_TABLE))
        {
            // disable the parameter table drop down for this property
            ddUnitOfTimeFromParamTableSource.Enabled = false;
        }
        else
        {
            // enable the parameter table drop down for this property
            ddUnitOfTimeFromParamTableSource.Enabled = true;
        }

        if (CurrentDecisionInstance.CycleUnitsPerTierValue != null)
        {
            numberOfMonth.UseTextbox = true;
            numberOfMonth.TextboxText = CurrentDecisionInstance.CycleUnitsPerTierValue.ToString();
        }
        else if (CurrentDecisionInstance.CycleUnitsPerTierColumnName != null)
        {
            numberOfMonth.UseDropdown = true;
            numberOfMonth.DropdownSelectedText = CurrentDecisionInstance.CycleUnitsPerTierColumnName;
        }

        if (CurrentDecisionInstance.CycleUnitsOffsetValue != null)
        {
            numberMonthBillingInterval.UseTextbox = true;
            numberMonthBillingInterval.TextboxText = CurrentDecisionInstance.CycleUnitsOffsetValue.ToString();
        }
        else if (CurrentDecisionInstance.CycleUnitsOffsetColumnName != null)
        {
            numberMonthBillingInterval.UseDropdown = true;
            numberMonthBillingInterval.DropdownSelectedText = CurrentDecisionInstance.CycleUnitsOffsetColumnName;
        }

        if (CurrentDecisionInstance.CyclesValue != null && CurrentDecisionInstance.CyclesValue == 0)
        {
            RBL_DecisionEffect.Items[0].Selected = true;
        }
        else if (CurrentDecisionInstance.CyclesValue != null && CurrentDecisionInstance.CyclesValue > 0)
        {
            RBL_DecisionEffect.Items[1].Selected = true;
            decisionCycleCustomized.UseTextbox = true;
            decisionCycleCustomized.TextboxText = CurrentDecisionInstance.CyclesValue.ToString();
        }
        else
        {
            RBL_DecisionEffect.Items[1].Selected = true;
            decisionCycleCustomized.UseDropdown = true;
            decisionCycleCustomized.DropdownSelectedText = CurrentDecisionInstance.CyclesColumnName;
        }
    }

    private bool SetDecisionCycleProperties()
    {
        // set unit of time for decision cycle
        SetDecisionCycleUnitOfTime();
        if (numberOfMonth.UseTextbox && !String.IsNullOrEmpty(numberOfMonth.TextboxText))
            {
                CurrentDecisionInstance.CycleUnitsPerTierValue = Int32.Parse(numberOfMonth.TextboxText);
                CurrentDecisionInstance.CycleUnitsPerTierColumnName = null;
            }
        else if (numberOfMonth.UseTextbox &&  String.IsNullOrEmpty(numberOfMonth.TextboxText))
            {
                SetError(Convert.ToString(GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_UNIT_OF_TIME")));
                logger.LogError(String.Format("No value for the unit of time for the Decision Cycle'{0}'",
                                          AmpDecisionName));
                return false;
            }
        else if (!String.IsNullOrEmpty(numberOfMonth.DropdownSelectedText))
            {
                CurrentDecisionInstance.CycleUnitsPerTierColumnName = numberOfMonth.DropdownSelectedText;
                CurrentDecisionInstance.CycleUnitsPerTierValue = null;
            }
        else
            {
                SetError(Convert.ToString(GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_UNIT_OF_TIME")));
                logger.LogError(String.Format("No value for the unit of time for the Decision Cycle'{0}'",
                                              AmpDecisionName));
                return false;
            }

            //set number of month from the beginning of the billing interval
            if (numberMonthBillingInterval.UseTextbox && !String.IsNullOrEmpty(numberMonthBillingInterval.TextboxText))
            {
                CurrentDecisionInstance.CycleUnitsOffsetValue = Int32.Parse(numberMonthBillingInterval.TextboxText);
                CurrentDecisionInstance.CycleUnitsOffsetColumnName = null;
            }
            else if (numberMonthBillingInterval.UseTextbox &&  String.IsNullOrEmpty(numberMonthBillingInterval.TextboxText))
            {
                SetError(GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_UNIT_OF_TIME_INTERVAL").ToString());
                logger.LogError(
                    String.Format(
                        "No value for the unit of time from the beginning of the billing interval to the start of the Decision Cycle'{0}'",
                        AmpDecisionName));
                return false;
            }
            else if (!String.IsNullOrEmpty(numberMonthBillingInterval.DropdownSelectedText))
            {
                CurrentDecisionInstance.CycleUnitsOffsetColumnName = numberMonthBillingInterval.DropdownSelectedText;
                CurrentDecisionInstance.CycleUnitsOffsetValue = null;
            }
            else
            {
                SetError(GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_UNIT_OF_TIME_INTERVAL").ToString());
                logger.LogError(
                    String.Format(
                        "No value for the unit of time from the beginning of the billing interval to the start of the Decision Cycle'{0}'",
                        AmpDecisionName));
                return false;
            }

        if (RBL_DecisionEffect.SelectedValue.Equals("Indefinitely"))
        {
            CurrentDecisionInstance.CyclesValue = 0;
            CurrentDecisionInstance.CyclesColumnName = null;
        }
        else if (decisionCycleCustomized.UseTextbox && !String.IsNullOrEmpty(decisionCycleCustomized.TextboxText))
        {
            CurrentDecisionInstance.CyclesValue = Int32.Parse(decisionCycleCustomized.TextboxText);
            CurrentDecisionInstance.CyclesColumnName = null;
        }
        else if (decisionCycleCustomized.UseDropdown &&
                 !String.IsNullOrEmpty(decisionCycleCustomized.DropdownSelectedText))
        {
            CurrentDecisionInstance.CyclesColumnName = decisionCycleCustomized.DropdownSelectedText;
            CurrentDecisionInstance.CyclesValue = null;
        }
        else
        {
            SetError(Convert.ToString(GetLocalResourceObject("TEXT_ERROR_NO_VALUE_SPECIFIC_NUMBER")));
            logger.LogError(String.Format("No value for a specific number of Decision Cycles '{0}'", AmpDecisionName));
            return false;
        }
        return true;
    }

    private void SetDecisionCycleUnitOfTime()
    {
        CurrentDecisionInstance.CycleUnitTypeValue = (Decision.CycleUnitTypeEnum)Convert.ToInt32(ddTimeCycleUnit.SelectedItem.Value);
        CurrentDecisionInstance.CycleUnitTypeColumnName = null;
        if (Decision.CycleUnitTypeEnum.CYCLE_GET_FROM_PARAMETER_TABLE.Equals((Decision.CycleUnitTypeEnum)Convert.ToInt32(ddTimeCycleUnit.SelectedItem.Value)))
        {
            CurrentDecisionInstance.CycleUnitTypeColumnName = ddUnitOfTimeFromParamTableSource.SelectedItem.Value;
        }
    }

    private void GetDecisionCycleUnitOfTime()
    {
            ddTimeCycleUnit.SelectedIndex = (int) CurrentDecisionInstance.CycleUnitTypeValue;
            switch (CurrentDecisionInstance.CycleUnitTypeValue)
            {
                case Decision.CycleUnitTypeEnum.CYCLE_SAME_AS_BILLING_INTERVAL:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfBillingIntervals.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberBIBillingInterval.Text"));
                    break;
                case Decision.CycleUnitTypeEnum.CYCLE_DAILY:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfDays.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberDaysBillingInterval.Text"));
                    break;
                case Decision.CycleUnitTypeEnum.CYCLE_WEEKLY:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfWeeks.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberWeeksBillingInterval.Text"));
                    break;
                case Decision.CycleUnitTypeEnum.CYCLE_MONTHLY:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfMonth.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberMonthBillingInterval.Text"));
                    break;
                case Decision.CycleUnitTypeEnum.CYCLE_QUARTERLY:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfQuarters.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberQuartersBillingInterval.Text"));
                    break;
                case Decision.CycleUnitTypeEnum.CYCLE_ANNUALLY:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfYears.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberYearsBillingInterval.Text"));
                    break;
                case Decision.CycleUnitTypeEnum.CYCLE_GET_FROM_PARAMETER_TABLE:
                    lblNumberOfMonth.Text = Convert.ToString(GetLocalResourceObject("lblNumberOfTimeUnits.Text"));
                    lblNumberMonthBillingInterval.Text =
                        Convert.ToString(GetLocalResourceObject("lblNumberTimeUnitsBillingInterval.Text"));
                    ddUnitOfTimeFromParamTableSource.SelectedValue = CurrentDecisionInstance.CycleUnitTypeColumnName;
                    ShowDivParamTable = true;
                    break;
            }
       }


    private void SetDDUnitOfTimeEvent()
    {
        //Add event to Unit of Time items
        ddTimeCycleUnit.Attributes.Add("onChange", "return DecisionCycleUnitOfTimeChanged()");

        RBL_DecisionEffect.Items[0].Attributes.Add("onClick",
                                                   String.Format("return ChangeDecisionCycleEffectState(false, '{0}')",
                                                                 decisionCycleCustomized.ClientID));
        RBL_DecisionEffect.Items[1].Attributes.Add("onClick",
                                                   String.Format("return ChangeDecisionCycleEffectState(true, '{0}')",
                                                                 decisionCycleCustomized.ClientID));
    }


    private void InitializeAmpControlProperties()
    {
        numberOfMonth.UseTextbox = true;
        numberOfMonth.TextboxText = string.Empty;
        numberOfMonth.AllowDecimalsInTextbox = false;
        numberOfMonth.AllowNegativeInTextbox = false;
        numberOfMonth.TextboxMaxValue = Int32.MaxValue;

        numberMonthBillingInterval.UseTextbox = true;
        numberMonthBillingInterval.TextboxText = string.Empty;
        numberMonthBillingInterval.AllowDecimalsInTextbox = false;
        numberMonthBillingInterval.AllowNegativeInTextbox = false;
        numberMonthBillingInterval.TextboxMaxValue = Int32.MaxValue;

        decisionCycleCustomized.UseTextbox = true;
        decisionCycleCustomized.TextboxText = string.Empty;
        decisionCycleCustomized.AllowDecimalsInTextbox = false;
        decisionCycleCustomized.AllowNegativeInTextbox = false;
        decisionCycleCustomized.TextboxMaxValue = Int32.MaxValue;
    }

}
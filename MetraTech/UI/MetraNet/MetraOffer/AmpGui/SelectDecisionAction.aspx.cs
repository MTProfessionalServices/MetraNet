using System;
using System.Collections.Generic;
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
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;


public partial class AmpSelectDecisionActionPage : AmpWizardBasePage
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
    AmpCurrentPage = "SelectDecisionAction.aspx";
    AmpNextPage = "AmountChainGroup.aspx";
    AmpPreviousPage = "DecisionCycle.aspx";

    // The Continue button and View Generated Charge button
    // should NOT prompt the user if the controls have changed.
    // However, we take care of this on the client-side instead of
    // calling IgnoreChangesInControl() here.

    SetupOnclickActions();

    if (!IsPostBack)
    {
      // Monitor changes made to the controls on the page.
      if (AmpAction != "View")
      {
        //MonitorChangesInControl(BucketRadioButtons);
        MonitorChangesInControl(radUnitRate);
        MonitorChangesInControl(radEventRate);
        MonitorChangesInControl(radDiscount);
        MonitorChangesInControl(radGenCharge);
        MonitorChangesInControlByClientId(unitRate.ddSourceTypeClientId);
        MonitorChangesInControlByClientId(unitRate.tbNumericSourceClientId);
        MonitorChangesInControlByClientId(unitRate.tbTextSourceClientId);
        MonitorChangesInControlByClientId(unitRate.ddSourceClientId);
        MonitorChangesInControlByClientId(eventRate.ddSourceTypeClientId);
        MonitorChangesInControlByClientId(eventRate.tbNumericSourceClientId);
        MonitorChangesInControlByClientId(eventRate.tbTextSourceClientId);
        MonitorChangesInControlByClientId(eventRate.ddSourceClientId);
        MonitorChangesInControlByClientId(discount.ddSourceTypeClientId);
        MonitorChangesInControlByClientId(discount.tbNumericSourceClientId);
        MonitorChangesInControlByClientId(discount.tbTextSourceClientId);
        MonitorChangesInControlByClientId(discount.ddSourceClientId);
      }

      // Retrieve decision from database.
      CurrentDecisionInstance = GetDecisionWithClient();
      if (CurrentDecisionInstance == null)
      {
        return;
      }
      PopulateDropDownControl();
      ClearAllControls();

      PopulateControlsFromDecision();

      // Set button text; disable some controls.
      SetMode();

    } // if (!IsPostBack)
  }


  // Unselect everything and clear all hardcoded boxes and dropdown selections.
  //TBD Disable all radio buttons and controls?
  private void ClearAllControls()
  {
    radUnitRate.Checked = false;
    radEventRate.Checked = false;
    radDiscount.Checked = false;
    radGenCharge.Checked = false;
    unitRate.UseTextbox = true;
    unitRate.TextboxText = string.Empty;
    eventRate.UseTextbox = true;
    eventRate.TextboxText = string.Empty;
    discount.UseTextbox = true;
    discount.TextboxText = string.Empty;

    if (AmpAction == "View")
    {
      unitRate.Visible = false;
      eventRate.Visible = false;
      discount.Visible = false;
    }
  }

  private void PopulateDropDownControl()
  {
    // Populate dropdown lists on the page.
    List<KeyValuePair<String, String>> paramTableColumns;
    if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName, out paramTableColumns))
    {
      unitRate.DropdownItems = paramTableColumns;
      eventRate.DropdownItems = paramTableColumns;
      discount.DropdownItems = paramTableColumns;
    }
  }


  private void PopulateControlsFromDecision()
  {
    // Now set the radio buttons and controls based on the Decision's contents.
    //TBD Enable/disable controls appropriately!
    if (CurrentDecisionInstance.IsBulkDecision != null)
    {
	  if (CurrentDecisionInstance.IsBulkDecision == true)
      {
        singleBucket.Checked = true;
      }
      else
      {
        multiBucket.Checked = true;
      }
    }
    if (CurrentDecisionInstance.PerUnitRateValue != null)
    {
      radUnitRate.Checked = true;
      unitRate.Visible = true;
      unitRate.UseTextbox = true;
      unitRate.TextboxText = CurrentDecisionInstance.PerUnitRateValue.ToString();
    }
    else if (!string.IsNullOrWhiteSpace(CurrentDecisionInstance.PerUnitRateColumnName))
    {
      radUnitRate.Checked = true;
      unitRate.Visible = true;
      unitRate.UseDropdown = true;
      unitRate.DropdownSelectedText = CurrentDecisionInstance.PerUnitRateColumnName;
    }
    else if (CurrentDecisionInstance.PerEventCostValue != null)
    {
      radEventRate.Checked = true;
      eventRate.Visible = true;
      eventRate.UseTextbox = true;
      eventRate.TextboxText = CurrentDecisionInstance.PerEventCostValue.ToString();
    }
    else if (!string.IsNullOrWhiteSpace(CurrentDecisionInstance.PerEventCostColumnName))
    {
      radEventRate.Checked = true;
      eventRate.Visible = true;
      eventRate.UseDropdown = true;
      eventRate.DropdownSelectedText = CurrentDecisionInstance.PerEventCostColumnName;
    }
    else if (CurrentDecisionInstance.TierDiscountValue != null)
    {
      radDiscount.Checked = true;
      discount.Visible = true;
      discount.UseTextbox = true;
      discount.TextboxText = CurrentDecisionInstance.TierDiscountValue.ToString();
    }
    else if (!string.IsNullOrWhiteSpace(CurrentDecisionInstance.TierDiscountColumnName))
    {
      radDiscount.Checked = true;
      discount.Visible = true;
      discount.UseDropdown = true;
      discount.DropdownSelectedText = CurrentDecisionInstance.TierDiscountColumnName;
    }
    else
    {
      radGenCharge.Checked = true;
    }
  }


  // Set control properties based on current mode(View/Edit).
  private void SetMode()
  {
    btnSaveAndContinue.Text = ((AmpAction != "View") ? Resources.Resource.TEXT_SAVE_AND_CONTINUE
                                                     : Resources.Resource.TEXT_CONTINUE);


    if (AmpAction == "View")
    {
      // Disable the unselected radio buttons.
      multiBucket.Enabled = multiBucket.Checked;
      singleBucket.Enabled = singleBucket.Checked;
	  radUnitRate.Enabled = radUnitRate.Checked;
      radEventRate.Enabled = radEventRate.Checked;
      radDiscount.Enabled = radDiscount.Checked;
      radGenCharge.Enabled = radGenCharge.Checked;

      unitRate.ReadOnly = true;
      eventRate.ReadOnly = true;
      discount.ReadOnly = true;

      btnSaveAndContinue.CausesValidation = false;
      btnSaveAndContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
    }
  }


  protected void btnContinue_Click(object sender, EventArgs e)
  {
    if (AmpAction != "View")
    {
      if (!PopulateDecisionFromControls())
      {
        return;  // Stay on same page.
      }
      if (!SaveDecisionWithClient())
      {
        return;  // Stay on same page.
      }
    }

    if (radGenCharge.Checked)
    {
      AmpNextPage = "ChargeCreditAttributes.aspx";
    }

    Response.Redirect(AmpNextPage, false);
  }


  // Sets the properties of decision CurrentDecisionInstance based on the control settings.
  // Returns true if control settings are valid, else false.
  private bool PopulateDecisionFromControls()
  {
    //Multi vs single-bucket in list.
	if (!multiBucket.Checked && !singleBucket.Checked)
	{
      SetError(GetLocalResourceObject("TEXT_ERROR_NO_INCREMENTAL_OR_BULK").ToString());
      logger.LogError(String.Format("Neither Incremental nor In Bulk processing was specified for Decision '{0}'", AmpDecisionName));
      return false;
    }
	if (multiBucket.Checked )
    {
      CurrentDecisionInstance.IsBulkDecision = false;
    }
    else if (singleBucket.Checked)
    {
      CurrentDecisionInstance.IsBulkDecision = true;
    }
    // Make sure exactly one radio button for decision actions is selected.
    if (!radUnitRate.Checked && !radEventRate.Checked && !radDiscount.Checked && !radGenCharge.Checked)
    {
      SetError(GetLocalResourceObject("TEXT_ERROR_NO_DECISION_ACTION").ToString());
      logger.LogError(String.Format("No Decision action was specified for Decision '{0}'", AmpDecisionName));
      return false;
    }

    // Clear all action-related decision properties except for GeneratedCharge.
    CurrentDecisionInstance.PerUnitRateValue = null;
    CurrentDecisionInstance.PerUnitRateColumnName = null;
    CurrentDecisionInstance.PerEventCostValue = null;
    CurrentDecisionInstance.PerEventCostColumnName = null;
    CurrentDecisionInstance.TierDiscountValue = null;
    CurrentDecisionInstance.TierDiscountColumnName = null;

    if (radUnitRate.Checked)
    {
      if (unitRate.UseTextbox && !string.IsNullOrWhiteSpace(unitRate.TextboxText))
      {
        CurrentDecisionInstance.PerUnitRateValue = Convert.ToDecimal(unitRate.TextboxText);
        CurrentDecisionInstance.PerUnitRateColumnName = null;
      }
      else if (unitRate.UseDropdown && !string.IsNullOrWhiteSpace(unitRate.DropdownSelectedText))
      {
        CurrentDecisionInstance.PerUnitRateValue = null;
        CurrentDecisionInstance.PerUnitRateColumnName = unitRate.DropdownSelectedText;
      }
      else
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_NO_UNIT_RATE_VALUE").ToString());
        logger.LogError(String.Format("No value for the new unit rate was specified for Decision '{0}'", AmpDecisionName));
        return false;
      }
    }

    else if (radEventRate.Checked)
    {
      if (eventRate.UseTextbox && !string.IsNullOrWhiteSpace(eventRate.TextboxText))
      {
        CurrentDecisionInstance.PerEventCostValue = Convert.ToDecimal(eventRate.TextboxText);
        CurrentDecisionInstance.PerEventCostColumnName = null;
      }
      else if (eventRate.UseDropdown && !string.IsNullOrWhiteSpace(eventRate.DropdownSelectedText))
      {
        CurrentDecisionInstance.PerEventCostValue = null;
        CurrentDecisionInstance.PerEventCostColumnName = eventRate.DropdownSelectedText;
      }
      else
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_NO_EVENT_RATE_VALUE").ToString());
        logger.LogError(String.Format("No value for the new event rate was specified for Decision '{0}'", AmpDecisionName));
        return false;
      }
    }

    else if (radDiscount.Checked)
    {
      if (discount.UseTextbox && !string.IsNullOrWhiteSpace(discount.TextboxText))
      {
        CurrentDecisionInstance.TierDiscountValue = Convert.ToDecimal(discount.TextboxText);
        CurrentDecisionInstance.TierDiscountColumnName = null;
      }
      else if (discount.UseDropdown && !string.IsNullOrWhiteSpace(discount.DropdownSelectedText))
      {
        CurrentDecisionInstance.TierDiscountValue = null;
        CurrentDecisionInstance.TierDiscountColumnName = discount.DropdownSelectedText;
      }
      else
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_NO_DISCOUNT_VALUE").ToString());
        logger.LogError(String.Format("No value for the discount was specified for Decision '{0}'", AmpDecisionName));
        return false;
      }
    }

    if (!radGenCharge.Checked)
    {
      // Clear out any existing info about generated charges.
      CurrentDecisionInstance.GeneratedCharge = null;
      CurrentDecisionInstance.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_NONE;
    }

    return true;
  }


  private void SetupOnclickActions()
  {
    radUnitRate.Attributes.Add("onClick", String.Format("return EnableAppropriateUserControls(false, '{0}','{1}','{2}')", eventRate.ClientID, discount.ClientID, unitRate.ClientID));
    radEventRate.Attributes.Add("onClick", String.Format("return EnableAppropriateUserControls(false, '{0}','{1}','{2}')", unitRate.ClientID, discount.ClientID, eventRate.ClientID));
    radDiscount.Attributes.Add("onClick", String.Format("return EnableAppropriateUserControls(false, '{0}','{1}','{2}')", unitRate.ClientID, eventRate.ClientID, discount.ClientID));
    radGenCharge.Attributes.Add("onClick", String.Format("return EnableAppropriateUserControls(false, '{0}','{1}','{2}')", unitRate.ClientID, eventRate.ClientID, discount.ClientID)); 
  }

}
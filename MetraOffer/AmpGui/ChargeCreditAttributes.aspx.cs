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
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.UI.MetraNet.App_Code;


public partial class AmpChargeCreditAttributesPage : AmpWizardBasePage
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
        AmpCurrentPage = "ChargeCreditAttributes.aspx";
        AmpNextPage = "AmountChainGroup.aspx";
        AmpPreviousPage = "SelectDecisionAction.aspx";

        if (!IsPostBack)
        {
            CurrentDecisionInstance = GetDecisionWithClient();
            InitColumnNameDDList();

            if (String.IsNullOrEmpty(CurrentDecisionInstance.ChargeColumnName))
            {
              ctrlValue.TextboxText = CurrentDecisionInstance.ChargeValue.ToString();
              ctrlValue.UseTextbox = true;
            }
            else
            {
              ctrlValue.DropdownSelectedText = CurrentDecisionInstance.ChargeColumnName;
              ctrlValue.UseDropdown = true;
            }

            if (CurrentDecisionInstance.ChargeCondition != Decision.ChargeConditionEnum.CHARGE_NONE)
            {
                radListWhenGenerate.SelectedValue = CurrentDecisionInstance.ChargeCondition.ToString();
            }

            SetRadListDisableListeners();

            if (radListWhenGenerate.SelectedIndex == 3)
            {
                // if (CurrentDecisionInstance.ChargeAmountType != Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_NONE)[todo: Add NONE statement to ChargeAmountTypeEnum]
                radListHowApply.SelectedValue = CurrentDecisionInstance.ChargeAmountType.ToString();
            }
            else
            {
                radListHowApply.SelectedIndex = 0;
            }

            if (!string.IsNullOrWhiteSpace(CurrentDecisionInstance.GeneratedCharge))
            {
              hiddenGeneratedChargeName.Value = CurrentDecisionInstance.GeneratedCharge;

              // Can't do anything now about selecting the radio button that
              // corresponds to the decision's current generated charge.
              // (Must wait until the grid control is loaded.
              // After the grid control is loaded, if AmpAction is "View",
              // we also must disable selection of other rows!)
            }

            SetMode();
            SetControlMonitorChanges();
        }
    }


    protected override void OnLoadComplete(EventArgs e)
    {
      // Pass the values to the service
      GeneratedChargesGrid.DataSourceURL =
          String.Format(
              "/MetraNet/MetraOffer/AmpGui/AjaxServices/GeneratedChargeSvc.aspx?command=LoadGrid");

      if (AmpAction != "View")
      {
        // If we are not in "View" mode, add an "Add" toolbar button to the grid of GeneratedCharges.
        MTGridButton button = new MTGridButton();
        button.ButtonID = "Add";
        button.ButtonText = GetLocalResourceObject("TEXT_ADD").ToString();
        button.ToolTip = GetLocalResourceObject("TEXT_ADD_TOOLTIP").ToString();
        button.IconClass = "Add";
        button.JSHandlerFunction = "onAdd";
        GeneratedChargesGrid.ToolbarButtons.Add(button);
      }
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
      if (AmpAction != "View")
      {
        if (!ParseValuesFromControls())
        {
          return; // Stay on same page.
        }
        if (!SaveDecisionWithClient())
        {
          return; // Stay on same page.
        }
      }
      Response.Redirect(AmpNextPage, false);
    }

    /// <summary>
    /// ChargeColumnNames dropdown control initialization
    /// </summary>
    private void InitColumnNameDDList()
    {
      List<KeyValuePair<String, String>> columns;
      if (GetParameterTableColumnNamesWithClient(CurrentDecisionInstance.ParameterTableName, out columns))
      {
        ctrlValue.DropdownItems = columns;
      }
    }

    /// <summary>
    /// Set control properties based on current mode(View/Edit).
    /// </summary>
    private void SetMode()
    {
      ctrlValue.SetMode(AmpAction);

      if (AmpAction == "View") // The View mode
      {

        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "onViewGeneratedCharge",
                                                    "<script language=javascript> " +
                                                    "function onViewGeneratedCharge(name) { location.href= 'ChargeCreditProductView.aspx?GenChargeAction=View&GenChargeName=' + name; } " +
                                                    "</script>");

        foreach (ListItem item in radListWhenGenerate.Items)
        {
          item.Enabled = item.Selected;
        }

        if (radListWhenGenerate.SelectedIndex == 3)
        {
          foreach (ListItem item in radListHowApply.Items)
          {
            item.Enabled = item.Selected;
          }
        }
        else
        {
          radListHowApply.Attributes.Add("disabled", "true");
          lbHowApply.Attributes.Add("disabled", "true");
        }

        // The "beforerowselect" event handler defined in ChargeCreditAttributes.aspx
        // takes care of preventing changes to GeneratedChargesGrid.

        btnSaveAndContinue.Visible = false;
      }
      else // Edit or Create mode
      {
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "onViewGeneratedCharge",
                                            "<script language=javascript> " +
                                            "function onViewGeneratedCharge(name) { " +
                                            "makeAjaxRequest(\"UpdateDecision\",'"+ GetLocalResourceObject("TEXT_ERROR_UPDATING_CHARGE_CREDIT_ATTRIBUTE") + AmpDecisionName + "'); " +
                                            "location.href= 'ChargeCreditProductView.aspx?GenChargeAction=View&GenChargeName=' + name; } " +
                                            "</script>");

        if (radListWhenGenerate.SelectedIndex != 3)
        {
          radListHowApply.Attributes.Add("disabled", "true");
          lbHowApply.Attributes.Add("disabled", "true");
        }

        btnContinue.Visible = false;
      }
    }

  /// <summary>
    /// Gets the values from controls and fills Decision and GeneratedCharge properties.
    /// Returns true if control settings are valid, else false.
    /// </summary>
    private bool ParseValuesFromControls()
    {
        if (!string.IsNullOrWhiteSpace(hiddenGeneratedChargeName.Value))
        {
            CurrentDecisionInstance.GeneratedCharge = hiddenGeneratedChargeName.Value;
        }
        else
        {
            SetError(GetLocalResourceObject("TEXT_ERROR_NO_GENERATED_CHARGE").ToString());
            logger.LogError(String.Format("No Generated Charge was selected for Decision '{0}'", AmpDecisionName));
            return false;
        }

        if (ctrlValue.UseTextbox && !String.IsNullOrEmpty(ctrlValue.TextboxText))
        {
            CurrentDecisionInstance.ChargeValue = Convert.ToDecimal(ctrlValue.TextboxText);
            CurrentDecisionInstance.ChargeColumnName = null;
        }
        else if (ctrlValue.UseDropdown && !String.IsNullOrEmpty(ctrlValue.DropdownSelectedText))
        {
            CurrentDecisionInstance.ChargeColumnName = ctrlValue.DropdownSelectedText;
            CurrentDecisionInstance.ChargeValue = null;
        }

        Decision.ChargeConditionEnum selectedChargeCondition;
        Enum.TryParse(radListWhenGenerate.SelectedValue, out selectedChargeCondition);
        CurrentDecisionInstance.ChargeCondition = selectedChargeCondition;

        Decision.ChargeAmountTypeEnum selectedAmountType;
        Enum.TryParse(radListHowApply.SelectedValue, out selectedAmountType);
        CurrentDecisionInstance.ChargeAmountType = selectedAmountType;

        return true;
    }
    

    private void SetRadListDisableListeners()
    {
        radListWhenGenerate.Items[0].Attributes.Add("onClick", "return ChangeHowApplyState(true)");
        radListWhenGenerate.Items[1].Attributes.Add("onClick", "return ChangeHowApplyState(true)");
        radListWhenGenerate.Items[2].Attributes.Add("onClick", "return ChangeHowApplyState(true)");
        radListWhenGenerate.Items[3].Attributes.Add("onClick", "return ChangeHowApplyState(false)");
    }

    private void SetControlMonitorChanges()
    {
      // Monitor changes made to the controls on the page.
      MonitorChangesInControl(radListWhenGenerate);
      MonitorChangesInControl(radListHowApply);
      MonitorChangesInControlByClientId(ctrlValue.ddSourceTypeClientId);
      MonitorChangesInControlByClientId(ctrlValue.tbNumericSourceClientId);
      MonitorChangesInControlByClientId(ctrlValue.tbTextSourceClientId);
      MonitorChangesInControlByClientId(ctrlValue.ddSourceClientId);
      MonitorChangesInControlByClientId(hiddenGeneratedChargeName.ClientID);

      // The Continue button and View Generated Charge button
      // should NOT prompt the user if the controls have changed.
      // However, we take care of this on the client-side instead of
      // calling IgnoreChangesInControl() here.

    }

}
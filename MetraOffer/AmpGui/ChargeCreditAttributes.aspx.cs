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
        setEventHandlers();

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


            if (radListWhenGenerate.SelectedIndex == 3)
            {
                // if (CurrentDecisionInstance.ChargeAmountType != Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_NONE)[todo: Add NONE statement to ChargeAmountTypeEnum]
                    radListHowApply.SelectedValue = CurrentDecisionInstance.ChargeAmountTypeValue.ToString();
                if (
                    CurrentDecisionInstance.ChargeAmountTypeValue.Equals(
                        Decision.ChargeAmountTypeEnum.CHARGE_FROM_PARAM_TABLE))
                    ddChargeCreditAttrFromParamTableSource1.SelectedValue =
                        CurrentDecisionInstance.ChargeAmountTypeColumnName;
            }
            else
            {
                radListHowApply.SelectedIndex = 0;
            }

            if (!string.IsNullOrWhiteSpace(CurrentDecisionInstance.GeneratedChargeValue))
            {
              hiddenGeneratedChargeName.Value = CurrentDecisionInstance.GeneratedChargeValue;

              // Can't do anything now about selecting the radio button that
              // corresponds to the decision's current generated charge.
              // (Must wait until the grid control is loaded.
              // After the grid control is loaded, if AmpAction is "View",
              // we also must disable selection of other rows!)
            }
            else
            {
                Logger.LogError("loading value :" + CurrentDecisionInstance.GeneratedChargeColumnName);
                hiddenGeneratedChargeName.Value = CurrentDecisionInstance.GeneratedChargeColumnName;
                FromParamTableCheckBox.Checked = true;


            }

            updateActiveControls_serverside();
            SetMode();
            SetControlMonitorChanges();
        }
    }
    private void setEventHandlers()
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

    protected void updateActiveControls_serverside()
    {
        if (radListHowApply.SelectedIndex == 4)
            ddChargeCreditAttrFromParamTableSource1.Enabled = true;
        else
            ddChargeCreditAttrFromParamTableSource1.Enabled = false;
        if (FromParamTableCheckBox.Checked)
        {
            ddChargeCreditAttrFromParamTableSource2.Enabled = true;
            ddChargeCreditAttrFromParamTableSource2.SelectedValue = hiddenGeneratedChargeName.Value;
            divGrid.Attributes.Add("style","display:none;");
        }
        else
        {
            ddChargeCreditAttrFromParamTableSource2.Enabled = false;
            divGrid.Attributes.Add("style", "display:block;");
            
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
            updateActiveControls_serverside();
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
        setParamTableDropDown(columns, ddChargeCreditAttrFromParamTableSource1);
        setParamTableDropDown(columns, ddChargeCreditAttrFromParamTableSource2);

      }
    }
    private void setParamTableDropDown(List<KeyValuePair<String, String>> paramTableColumns, MTDropDown mtdd)
    {
        mtdd.Items.Clear();
        foreach (var item in paramTableColumns)
        {
            mtdd.Items.Add(new ListItem(item.Value, item.Key));
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
            divHow.Attributes.Add("display","none;");
        }

        // The "beforerowselect" event handler defined in ChargeCreditAttributes.aspx
        // takes care of preventing changes to GeneratedChargesGrid.

          FromParamTableCheckBox.Enabled = false;
          ddChargeCreditAttrFromParamTableSource2.Enabled = false;
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


        btnContinue.Visible = false;
      }
    }

  /// <summary>
    /// Gets the values from controls and fills Decision and GeneratedCharge properties.
    /// Returns true if control settings are valid, else false.
    /// </summary>
    private bool ParseValuesFromControls()
  {
      if (FromParamTableCheckBox.Checked)
      {
          hiddenGeneratedChargeName.Value = ddChargeCreditAttrFromParamTableSource2.SelectedValue;
          CurrentDecisionInstance.GeneratedChargeValue = null;
          CurrentDecisionInstance.GeneratedChargeColumnName = hiddenGeneratedChargeName.Value;
      }
      else
      {
          if (!string.IsNullOrWhiteSpace(hiddenGeneratedChargeName.Value))
          {

              CurrentDecisionInstance.GeneratedChargeValue = hiddenGeneratedChargeName.Value;
              CurrentDecisionInstance.GeneratedChargeColumnName = null;

          }
          else
          {
              SetError(GetLocalResourceObject("TEXT_ERROR_NO_GENERATED_CHARGE").ToString());
              logger.LogError(String.Format("No Generated Charge was selected for Decision '{0}'", AmpDecisionName));
              return false;
          }
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
          CurrentDecisionInstance.ChargeAmountTypeValue = selectedAmountType;
        if(selectedAmountType.Equals(Decision.ChargeAmountTypeEnum.CHARGE_FROM_PARAM_TABLE))
           CurrentDecisionInstance.ChargeAmountTypeColumnName = ddChargeCreditAttrFromParamTableSource1.SelectedValue;
        return true;
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
      MonitorChangesInControlByClientId(ddChargeCreditAttrFromParamTableSource1.ClientID);
      MonitorChangesInControlByClientId(ddChargeCreditAttrFromParamTableSource2.ClientID);

      // The Continue button and View Generated Charge button
      // should NOT prompt the user if the controls have changed.
      // However, we take care of this on the client-side instead of
      // calling IgnoreChangesInControl() here.

    }

}
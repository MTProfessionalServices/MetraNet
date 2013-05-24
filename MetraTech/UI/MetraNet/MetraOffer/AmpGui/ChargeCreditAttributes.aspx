<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ChargeCreditAttributes.aspx.cs" Inherits="AmpChargeCreditAttributesPage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Charge/Credit: Calculation Attributes" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>

  <br/>

  <div style="padding-left:10px">
  
    <asp:Label ID="lbChargeValue" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" Width="270" 
        Font-Size="9pt" Text="What should the value of the Charge/Credit be?" meta:resourcekey="lbChargeValueResource1" />

    <table>
        <tr>
            <td>
                <div style="padding-left:20px;padding-right:5px;" >
                    <asp:Label ID="lbPositiveValue" runat="server" ForeColor="DarkBlue" Font-Size="8pt" 
                    Text="A positive value indicates a charge." meta:resourcekey="lbPositiveValueResource1" />
                    <br/>
                    <asp:Label ID="lbNegativeValue" runat="server" ForeColor="DarkBlue" Font-Size="8pt"
                    Text="A negative value indicates a credit." meta:resourcekey="lbNegativeValueResource1" />
                </div>
            </td>

            <td style="padding-top:5px;">
               <ampc:AmpTextboxOrDropdown ID="ctrlValue" runat="server"
                 TextboxIsNumeric="true" AllowDecimalsInTextbox="true" AllowNegativeInTextbox="true" AllowBlankTextbox="false"
                 TextboxMaxValue="2147483647" TextboxMinValue="-2147483647">
               </ampc:AmpTextboxOrDropdown>
            </td>

        </tr>
    </table>
    
    <br />
    <br />

    <table style="width: 550px">
        <tr>
            <td>
                <asp:Label ID="lbWhenGenerate" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
                Font-Size="9pt" meta:resourcekey="lbWhenGenerate" 
                Text="When should the new Charge/Credit be generated?" />  
                <br />
            </td>
        </tr>
        <tr style="padding-top:100px">
            <td style="padding-left:10px">
                <asp:RadioButtonList ID="radListWhenGenerate" runat="server" ForeColor="DarkBlue" Font-Size="9pt">
                    <asp:ListItem Text="<%$ Resources:radEveryTimeText %>" Value="CHARGE_ON_EVERY" Selected="True" />
                    <asp:ListItem Text="<%$ Resources:radOnceFirstEnterText %>" Value="CHARGE_ON_INBOUND" />
                    <asp:ListItem Text="<%$ Resources:radOnceFirstExitText %>" Value="CHARGE_ON_OUTBOUND" />
                    <asp:ListItem Text="<%$ Resources:radOnceAfterSummedText %>" Value="CHARGE_ON_FINAL" />
                </asp:RadioButtonList>
            </td>
        </tr>
    </table>
        
    <div style="padding-left:50px; padding-top:10px;">

                    <asp:Label ID="lbHowApply" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
                        Font-Size="9pt" meta:resourcekey="lbHowApplied" 
                        Text="How should the Charge/Credit be applied?" />  
                    <span style="color:blue;text-decoration:underline;cursor:pointer;" 
                          onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_HOW_APPLY, TEXT_AMPWIZARD_HELP_HOW_APPLY, 400, 190)">
                       <img id="Img1" src='/Res/Images/icons/help.png' />
                    </span>
        
        <div style="padding-left:10px">
            <asp:RadioButtonList ID="radListHowApply" runat="server" ForeColor="DarkBlue" Font-Size="9pt">
                <asp:ListItem Text="<%$ Resources:radPropText %>" Value="CHARGE_AMOUNT_PROPORTIONAL" Selected="True" />
                <asp:ListItem Text="<%$ Resources:radInvPropText %>" Value="CHARGE_AMOUNT_INVERSE_PROPORTIONAL" />
                <asp:ListItem Text="<%$ Resources:radAggrMultText %>" Value="CHARGE_PERCENTAGE" />
                <asp:ListItem Text="<%$ Resources:radEntireValueText %>" Value="CHARGE_AMOUNT_FLAT" />
            </asp:RadioButtonList>
        </div>

    </div>

  <br />

  <asp:Label ID="lbSelectFromGrid" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
                Font-Size="9pt" meta:resourcekey="lbSelectFromGrid" 
                Text="Select a Generated Charge/Credit from the grid or add a new one:" />  
  <span style="color:blue;text-decoration:underline;cursor:pointer;" 
        onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_GENERATED_CHARGE_GRID, TEXT_AMPWIZARD_HELP_GENERATED_CHARGE_GRID, 400, 75)">
      <img id="Img2" src='/Res/Images/icons/help.png' />
  </span>

  <div id="divGrid" style="padding-left:12px;padding-top:5px;">
    <MT:MTFilterGrid ID="GeneratedChargesGrid" runat="server" TemplateFileName="AmpWizard.GeneratedCharges" ExtensionName="MvmAmp">
    </MT:MTFilterGrid>
  </div>  

  <br />
          
      <div style="padding-left:0.85in; padding-top:0in;">   
          <table>
            <col style="width:190px"/>
            <col style="width:190px"/>
            <tr>
              <td align="left">
                <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                             OnClientClick="setLocationHref(ampPreviousPage); return false;"
                             CausesValidation="false" TabIndex="230" />
              </td>
              <td align="right">
                <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$Resources:Resource,TEXT_SAVE_AND_CONTINUE%>"
                             OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); onContinueClick(); } else { MPC_setNeedToConfirm(true); return false; }"
                             OnClick="btnContinue_Click"
                             CausesValidation="true" TabIndex="240"/>
                <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_CONTINUE%>"
                             OnClientClick="MPC_setNeedToConfirm(false);"                             
                             OnClick="btnContinue_Click" 
                             CausesValidation="False" TabIndex="240"/>
              </td>
            </tr>
          </table> 
      </div>

  </div>


  <input id="hiddenGeneratedChargeName" type="hidden" runat="server" value="" />


  <script type="text/javascript" language="javascript">
  
      function ChangeHowApplyState(bDisabled) {
          ChangeControlState("<%=lbHowApply.ClientID %>", bDisabled);
          ChangeControlState("<%=radListHowApply.ClientID %>", bDisabled);
      }
      
      function ChangeControlState(controlId, bDisabled) {
          document.getElementById(controlId).disabled = bDisabled;
      }    
      
      // This flag is needed to enable us to select the current generated charge
      // in the grid after loading the grid, even if the user is just viewing the decision type.
      var initializingGridSelection = false;


      Ext.onReady(function () {
        // Define an event handler for the grid control's Load event,
        // which will select the radio button that corresponds to the 
        // decision type's current generated charge, if any.
       
        dataStore_<%= GeneratedChargesGrid.ClientID %>.on(
          "load",
          function(store, records, options)
          {
            var currentGeneratedChargeName = Ext.get("<%=hiddenGeneratedChargeName.ClientID%>").dom.value;
            for (var i = 0; i < records.length; i++)
            {
              if (records[i].data.Name === currentGeneratedChargeName)
              {
                // Found the right row!
                initializingGridSelection = true;  // to permit row selection even if action is View
                grid_<%= GeneratedChargesGrid.ClientID %>.getSelectionModel().selectRow(i);
                break;
              }
            }
          }
        );

        // Define an event handler for the grid's beforerowselect event,
        // which makes the grid readonly if the AmpAction is "View"
        // by preventing any row from being selected.
        var selectionModel = grid_<%= GeneratedChargesGrid.ClientID %>.getSelectionModel();
        selectionModel.on(
          "beforerowselect",
          function()
          {
            if (initializingGridSelection == true)
            {
              initializingGridSelection = false;
            }
            else if (ampAction === "View")
            {
              return false;
            }
          }
        );

        selectionModel.on(
          "selectionchange",
          function()
          {
            if (ampAction === "View")
            {
              return false;
            }
            else {
              // Not in View mode, so update the hidden input field for monitoring changes to selected row
              var records = grid_<%= GeneratedChargesGrid.ClientID %>.getSelectionModel().getSelections();
              if (records.length > 0) {
                Ext.get("<%=hiddenGeneratedChargeName.ClientID%>").dom.value = records[0].data.Name;
              }
            }
          }
        );
        
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        MPC_assignInitialValues();
      });
      
      
    function onContinueClick() {
      // Store the selected generated charge/credit name.
      var records = grid_<%= GeneratedChargesGrid.ClientID %>.getSelectionModel().getSelections();
      if (("<%=AmpAction%>" != 'View') && (records.length > 0))
      {
        Ext.get("<%=hiddenGeneratedChargeName.ClientID%>").dom.value = records[0].data.Name;
      }
    }

    function makeAjaxRequest(svcCommand, errorText)
    {
      var v_whenGenerate = '0';
      if (Ext.get("<%=radListWhenGenerate.ClientID%>"+'_0').dom.checked)
      {
        v_whenGenerate = Ext.get("<%=radListWhenGenerate.ClientID%>"+'_0').dom.value;
      }
      else if (Ext.get("<%=radListWhenGenerate.ClientID%>"+'_1').dom.checked)
      {
        v_whenGenerate = Ext.get("<%=radListWhenGenerate.ClientID%>"+'_1').dom.value;
      }
      else if (Ext.get("<%=radListWhenGenerate.ClientID%>"+'_2').dom.checked)
      {
        v_whenGenerate = Ext.get("<%=radListWhenGenerate.ClientID%>"+'_2').dom.value;
      }
      else if (Ext.get("<%=radListWhenGenerate.ClientID%>"+'_3').dom.checked)
      {
        v_whenGenerate = Ext.get("<%=radListWhenGenerate.ClientID%>"+'_3').dom.value;
      }

      var v_howApply = '0';
      if (Ext.get("<%=radListHowApply.ClientID%>"+'_0').dom.checked)
      {
        v_howApply = Ext.get("<%=radListHowApply.ClientID%>"+'_0').dom.value;
      }
      else if (Ext.get("<%=radListHowApply.ClientID%>"+'_1').dom.checked)
      {
        v_howApply = Ext.get("<%=radListHowApply.ClientID%>"+'_1').dom.value;
      }
      else if (Ext.get("<%=radListHowApply.ClientID%>"+'_2').dom.checked)
      {
        v_howApply = Ext.get("<%=radListHowApply.ClientID%>"+'_2').dom.value;
      }
      else if (Ext.get("<%=radListHowApply.ClientID%>"+'_3').dom.checked)
      {
        v_howApply = Ext.get("<%=radListHowApply.ClientID%>"+'_3').dom.value;
      }
      
        var parameters = { 
          command: svcCommand,
          ampDecisionName : '<%=AmpDecisionName%>',
          ddSourceType: Ext.get("<%=ctrlValue.ClientID%>"+'_ddSourceType').dom.value,
          numericSource: Ext.get("<%=ctrlValue.ClientID%>"+'_tbNumericSource').dom.value,
          ddSource : Ext.get("<%=ctrlValue.ClientID%>"+'_ddSource').dom.value,
          whenGenerate: v_whenGenerate,
          howApply: v_howApply
        };

        // make the call back to the server
        Ext.Ajax.request({
                url: '/MetraNet/MetraOffer/AmpGui/AjaxServices/GeneratedChargeSvc.aspx',
                params: parameters,
                scope: this,
                disableCaching: true,
                callback: function(options, success, response) {
                    if (!success)
                    {
                        Ext.UI.SystemError(errorText);
                    }
                }
        });
    }

    // Event handler for Add button in AmpWizard.GeneratedCharges gridlayout
    function onAdd_<%=GeneratedChargesGrid.ClientID %>()
    {
      MPC_setNeedToConfirm(false);
      makeAjaxRequest("UpdateDecision",
        '<%= GetLocalResourceObject("TEXT_ERROR_UPDATING_CHARGE_CREDIT_ATTRIBUTE") %>' + '<%= AmpDecisionName %>');
      
      location.href = "ChargeCreditProductView.aspx?GenChargeAction=Create";
    }

    OverrideRenderer_<%=GeneratedChargesGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer);
    };
        
    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";    
   
      // View
      str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='View' title='{1}' onclick='MPC_setNeedToConfirm(false);' href='JavaScript:onViewGeneratedCharge(\"{0}\");'><img src='/Res/Images/icons/view.gif' alt='{1}' /></a>", record.data.Name, TEXT_AMPWIZARD_VIEW);
   
      return str;
    }



    </script>

</asp:Content>

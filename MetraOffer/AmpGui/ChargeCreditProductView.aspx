<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ChargeCreditProductView.aspx.cs" Inherits="AmpChargeCreditProductViewPage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
    <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Charge/Credit: Definition" meta:resourcekey="lblTitleResource1"></asp:Label>
    </div>
   
    <br />
    
    <div style="padding-left:10px">
        
        <table>
        <tr>
            <td>
                <!-- Label attribute of MTTextBoxControl does not recognize "/" symbol, so we need to use LabelSeparator attr.for now -->
                <MT:MTTextBoxControl ID="tbChargeCreditName" runat="server" AllowBlank="False" LabelSeparator="Charge/Credit Name:"
                    TabIndex="200" ControlWidth="200" ControlHeight="18" HideLabel="False"
                    LabelWidth="120" meta:resourcekey="tbChargeCreditNameResource1" Listeners="{}" ReadOnly="False"
                    XType="TextField" XTypeNameSpace="form" VType="decisionRelatedName"/>
            </td>
            <td>
                <div style="padding-top:4px;padding-left:10px;">
                    <img id="Img2" src='/Res/Images/icons/cog_error_32x32.png' runat="server" title="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" />
                </div>
            </td>
                
        </tr>
        <tr>
            <td>
              <div id="editDescriptionDiv" runat="server">
                <MT:MTTextArea ID="tbDescription" runat="server" AllowBlank="True"
                    TabIndex="210" ControlWidth="200" ControlHeight="50" HideLabel="False" LabelSeparator=":"
                    LabelWidth="120" meta:resourcekey="tbDescriptionResource1" ReadOnly="False"
                    XType="TextArea" XTypeNameSpace="form" Listeners="{}" />
              </div> <!-- editDescriptionDiv -->
              <div id="viewDescriptionDiv" runat="server">
                <table class="ChargeCreditProductViewViewDescription" >
                  <tr>
                    <td class="ChargeCreditProductViewViewDescriptionCol1">
                      <MT:MTLabel ID="ViewDescriptionLabel" runat="server" Text="Description:" meta:resourcekey="ViewDescriptionLabelResource"/>
                    </td>
                    <td class="ChargeCreditProductViewViewDescriptionCol2">
                      <MT:MTLabel ID="ViewDescriptionText" runat="server" />
                    </td>
                  </tr>
                </table>                
              </div> <!-- viewDescriptionDiv -->
            </td>
            <td>
            </td>
        </tr>
        </table>
    
        <br />
        <br />
        
        <table>
            <tr>
                <td>
                    <asp:Label ID="lbChooseProductView" style="line-height:20px;" runat="server" Font-Bold="False" Width="200" ForeColor="DarkBlue"
                    Font-Size="9pt" Text="Which Product View is associated with the new Charge/Credit?" meta:resourcekey="lbChooseProductViewResource1" />
                </td>
                <td>
                <asp:DropDownList ID="ddProductViews" runat="server" AutoPostBack="True"  AllowBlank="True" ControlWidth="250" ListWidth="250" 
                                   HideLabel="True" Editable="false" onselectedindexchanged="ddProductViews_SelectedIndexChanged"></asp:DropDownList>            
                </td>
            </tr>
            <tr>
                <td>
                    <span style="color: blue; text-decoration: underline; cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_MORE_PRODUCT_VIEW, 450, 75)"
                        id="ProductViewMoreLink">
                        <asp:Literal ID="MoreInfoLiteral" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" />
                    </span>
                </td>
            </tr>
        </table>
    
        <br />
        <br />
    
        <table>
            <tr>
                <td>
                    <asp:Label ID="lbSelectAmountChGr" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
                    Font-Size="9pt" meta:resourcekey="lbSelectAmountChGr" 
                    Text="Select the Amount Chain Group to use for the new Charge/Credit:" />
                </td>
                <td>
                    <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AMOUNT_CHAIN_GROUP, TEXT_AMPWIZARD_HELP_AMOUNT_CHAIN_GROUP_2, 450, 100)">
                       <img id="Img1" src='/Res/Images/icons/help.png' />
                    </span>
                </td>
            </tr>
        </table>
    
    <br />

    </div>
        
    <MT:MTFilterGrid ID="grAmountChainGroup" runat="server" TemplateFileName="AmpWizard.AmountChainGroupsForProdView" ExtensionName="MvmAmp" />

  
    <div style="padding-left:0.85in; padding-top:0.22in;">   
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
                            OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); onContinueClick();} else { MPC_setNeedToConfirm(true); return false; }"
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
        
    <input id="hiddenAmountChainGroupName" type="hidden" runat="server" value="" />
    
    <script type="text/javascript" language="javascript">
        
        function onContinueClick() {
            // Store the selected amount chain group name.
            var records = grid_<%= grAmountChainGroup.ClientID %>.getSelectionModel().getSelections();
            if (("<%=AmpChargeCreditAction%>" != 'View') && (records.length > 0))
            {
                Ext.get("<%=hiddenAmountChainGroupName.ClientID%>").dom.value = records[0].data.Name;
            }
        }
        
        // This flag is needed to enable us to select the current amount chain group
        // in the grid after loading the grid, even if the user is just viewing the decision type.
        var initializingGridSelection = false;
      
        Ext.onReady(function () {
            
            // Define an event handler for the grid control's Load event,
            // which will select the radio button that corresponds to the 
            // decision type's current amount chain group.
            dataStore_<%= grAmountChainGroup.ClientID %>.on(
              "load",
              function(store, records, options)
              {
                var currentAmountChainGroupName = Ext.get("<%=hiddenAmountChainGroupName.ClientID%>").dom.value;
                for (var i = 0; i < records.length; i++)
                {
                  if (records[i].data.Name === currentAmountChainGroupName)
                  {
                    // Found the right row!
                    initializingGridSelection = true;  // to permit row selection even if action is View
                    grid_<%= grAmountChainGroup.ClientID %>.getSelectionModel().selectRow(i);
                    break;
                  }
                }
              }
            );

            // Define an event handler for the grid's beforerowselect event,
            // which makes the grid readonly if the AmpChargeCreditAction is "View"
            // by preventing any row from being selected.
            var selectionModel = grid_<%= grAmountChainGroup.ClientID %>.getSelectionModel();
            selectionModel.on(
              "beforerowselect",
              function()
              {
                if (initializingGridSelection == true)
                {
                  initializingGridSelection = false;
                }
                else if ("<%=AmpChargeCreditAction%>" === "View")
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
                  var records = grid_<%= grAmountChainGroup.ClientID %>.getSelectionModel().getSelections();
                  if (records.length > 0) {
                    Ext.get("<%=hiddenAmountChainGroupName.ClientID%>").dom.value = records[0].data.Name;
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
    
    </script>

</asp:Content>

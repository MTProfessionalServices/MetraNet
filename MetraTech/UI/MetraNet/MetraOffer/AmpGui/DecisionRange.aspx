<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master"
    AutoEventWireup="true" CodeFile="DecisionRange.aspx.cs" Inherits="AmpDecisionRangePage" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc1" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc2" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="CaptionBar">
        <asp:Label ID="lblTitleDecisionRange" runat="server" Text="Range" meta:resourcekey="lblTitleResource1"></asp:Label>
    </div>
    <div>
        <table style="width: 100%">
            <tr>
                <td style="width: 2%; vertical-align: top; padding-top:10px" align="center">
                       &nbsp;</td>
                <td valign="top" style="width: 90%">
                    <div style="line-height: 20px; padding-top: 10px; padding-left: 10px">
                                <div style="float:left"><asp:Label ID="lblDecisionRange" meta:resourcekey="lblDecisionRange" runat="server"
                            Font-Bold="False" ForeColor="Black" Font-Size="9pt" Text="The aggregate value for the Decision Type has a range of values within which the Decision Type is applicable." />
                                </div>
                                   <div style="fit-position: right;" align="left">
                                       <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DECISION_RANGE, TEXT_AMPWIZARD_MORE_DECISION_RANGE, 450, 70)">
                                    <img id="Img1" src='/Res/Images/icons/help.png' align="left" /></span>
                            </div>
                        </div>
                </td>
            </tr>
            <tr>
                 <td style="width: 2%"></td>
                 <td>
                     <table>
                      <tr>
                         
                         <td style="padding-left: 100px; width : 100px ;" align="right" >
                           <asp:Label ID="lblStartOfRange" meta:resourcekey="lblStartOfRange" runat="server"
                            Font-Bold="False" ForeColor="Black" Font-Size="9pt"
                            Text="Start of range:" />
                         </td>
                         <td>
                           <ampc1:AmpTextboxOrDropdown ID="startRange" runat="server" TextboxIsNumeric="true"></ampc1:AmpTextboxOrDropdown>
                         </td>
                      </tr>
                      <tr>
                        <td style="padding-left: 100px" align="right">
                          <asp:Label ID="lblEndOfRange" meta:resourcekey="lblEndOfRange" runat="server" 
                            Font-Bold="False" ForeColor="Black" Font-Size="9pt" 
                            Text="End of range:" />
                        </td>
                        <td>
                          <ampc2:AmpTextboxOrDropdown ID="endRange" runat="server" TextboxIsNumeric="true"></ampc2:AmpTextboxOrDropdown>
                        </td>
                      </tr>
               </table>
                 </td>
            </tr>
            <tr>
                <td style="width: 2%; vertical-align: top; padding-top:10px" align="center">
                       &nbsp;</td>
                <td valign="top" style="width: 90%">
                    <div style="line-height: 20px; padding-top: 10px; padding-left: 10px">
                                <div style="float:left">
                                  <asp:Label ID="Label2"  runat="server" Font-Bold="False"
                                    ForeColor="DarkBlue" Font-Size="9pt" Text="<%$ Resources: lblDecisionRangeRestart.Text%>"  />
                                <MT:MTDropDown ID="ddDecisionRangeRestart" runat="server" HideLabel="True" Label="Prorate at start?"  ControlWidth="160" ListWidth="200" AllowBlank="False" Editable="True"/>
                                </div>
                                   <div style="fit-position: right;" align="left">
                                       <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_RESTART_RANGE, TEXT_AMPWIZARD_HELP_DECISION_RANGE, 450, 70)">
                                    <img id="ImageHelp" src='/Res/Images/icons/help.png' /></span>
           
                            </div>
                        </div>
                </td>
            </tr>

                    <br />
            <tr>
                <td style="width: 2%; vertical-align: top; padding-top:10px; height: 32px;" 
                    align="center">
                       </td>
                <td valign="top" style="width: 90%; height: 32px;">
                    <div style="line-height: 20px; padding-top: 10px; padding-left: 10px">
                                <div style="float:left "><asp:Label ID="lblDecisionRangeProration" meta:resourcekey="lblDecisionRangeProration" runat="server"
                                Font-Bold="False" ForeColor="Black" Height="100%" Font-Size="9pt" Text="Prorate the range at subscription activation and/or termination." />
                                </div>
                                   <div style="fit-position: right;" align="left">
                                       <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DECISION_RANGE_PRORATION,  TEXT_AMPWIZARD_MORE_DECISION_RANGE_PRORATION, 450, 190)">
                                    <img id="Img2" src='/Res/Images/icons/help.png' align="left"/></span>
                            </div>
                        </div>
                </td>
            </tr>
  <tr>
                            <td style="width: 2%; vertical-align: top; padding-top:10px" align="center">
                                    &nbsp;</td>
                                <td valign="top" style="width: 90%">
                                    <asp:Label ID="lblUnitOfTime"  runat="server" Font-Bold="False"
          ForeColor="DarkBlue" Font-Size="9pt" Text="<%$ Resources: lblProrateStart.Text%>"  />
                                <MT:MTDropDown ID="ddProrateStart" runat="server" HideLabel="True" Label="Prorate at start?"  ControlWidth="160" ListWidth="200" AllowBlank="False" Editable="True"/>
                                </td>
                        </tr>
                        <tr>
                        <td style="width: 2%; vertical-align: top; padding-top:10px" align="center">
                            &nbsp;</td>
                            <td valign="top" style="width: 90%">
                            <asp:Label ID="Label1"  runat="server" Font-Bold="False"
          ForeColor="DarkBlue" Font-Size="9pt" Text="<%$ Resources: lblProrateEnd.Text%>"  />
                              <MT:MTDropDown ID="ddProrateEnd" runat="server" HideLabel="True" Label="Prorate at end?"  ControlWidth="160" ListWidth="200" AllowBlank="False" Editable="True"/>
                                
                            </td>
                        </tr>
        
           
                <div style="padding-left: 0.85in; padding-top: 0.2in;">
            <tr>
                <td style="width: 2%; vertical-align: top; padding-top: 10px" align="center">
                    &nbsp;</td>
                <td valign="top" style="width:90%">
                    &nbsp;</td>
            </tr>
           
                    <table>
            <col style="width: 190px" />
            <col style="width: 190px" />
            <tr>
                <td align="left">
                    <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                        OnClientClick="setLocationHref(ampPreviousPage); return false;" CausesValidation="false"
                        TabIndex="230" />
                </td>
                <td align="right">
                    <MT:MTButton ID="btnSaveAndContinue" runat="server" OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
                        OnClick="btnContinue_Click" CausesValidation="true" TabIndex="240" />                 
                </td>
            </tr>
        </table>
                </div>
            </>

        </table>
    </div>

    <script type="text/javascript" language="javascript">
      
      function ChangeControlState(textBoxControl, dropDownControl, disabledTextBox) {
        var txb = Ext.getCmp(textBoxControl);
        var cmb = Ext.getCmp(dropDownControl);

        if (disabledTextBox) {
          cmb.enable();
          txb.disable();
          txb.setValue('');
        }
        else {
          cmb.disable();
          cmb.setValue('');
          txb.enable();
        }

      }

      Ext.onReady(function () {
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        MPC_assignInitialValues();
      });

    </script>
</asp:Content>

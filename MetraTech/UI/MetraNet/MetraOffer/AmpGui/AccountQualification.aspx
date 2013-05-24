<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="AccountQualification.aspx.cs" Inherits="AmpAccountQualificationPage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
    <div class="CaptionBar">
      <asp:Label ID="lblTitle" runat="server" Text="Account Qualification" meta:resourcekey="lblTitleResource1"></asp:Label>
    </div>
   
    <br />
    
    <div style="line-height:20px;padding-top:10px;padding-left:15px;">

      <asp:Label ID="lblAccountQualification" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
        Font-Size="9pt" meta:resourcekey="lblAccountQualificationResource1" 
        Text="On this page you will define an Account Qualification for an account group."/>

      <br />
      <div style="padding-top:5px;">
        <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_ACCOUNT_QUALIFICATION, 420, 130)" id="moreLink" >
          <asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" Visible="False" />
        </span>
      </div>

      <br />
    </div>

    <div style="padding-left:15px">
        
      <!--table cellpadding="0" cellspacing="0" style="width:100%;"-->
      <table>
        <tr> <!-- Row 1: Nested table -->
          <table>
            <col style="width:250px"/>
            <tr> <!-- Source Field textbox in left column.  Include textbox in right column. -->
              <td>
                <MT:MTTextBoxControl ID="tbSourceField" runat="server" AllowBlank="True"
                    TabIndex="210" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" Label="Source Field"
                    LabelWidth="120" meta:resourcekey="tbSourceFieldResource1" ReadOnly="False"
                    XType="TextField" XTypeNameSpace="form" Listeners="{}" />
              </td>
              <td>
                <MT:MTTextBoxControl ID="tbTableToInclude" runat="server" AllowBlank="True"
                    TabIndex="220" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" Label="Table to Include"
                    LabelWidth="120" meta:resourcekey="tbTableToIncludeResource1" ReadOnly="False"
                    XType="TextField" XTypeNameSpace="form" Listeners="{}" />
              </td>
            </tr>
            <tr> <!-- Match Field textbox in right column. -->
              <td>
              </td>
              <td>
                <MT:MTTextBoxControl ID="tbMatchField" runat="server" AllowBlank="True"
                    TabIndex="230" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" Label="Match Field"
                    LabelWidth="120" meta:resourcekey="tbMatchFieldResource1" ReadOnly="False"
                    XType="TextField" XTypeNameSpace="form" Listeners="{}" />
              </td>
            </tr>
            <tr> <!-- Output Field textbox in right column. -->
              <td>
              </td>
              <td>
                <MT:MTTextBoxControl ID="tbOutputField" runat="server" AllowBlank="True"
                    TabIndex="240" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" Label="Output Field"
                    LabelWidth="120" meta:resourcekey="tbOutputFieldResource1" ReadOnly="False"
                    XType="TextField" XTypeNameSpace="form" Listeners="{}" />
              </td>
            </tr>
          </table>
        </tr>
        <tr> <!-- Row 2: Include Filter text area-->
          <td>
            <div style="padding-top: 5px;">
              <div id="editIncludeFilterDiv" runat="server">
              <MT:MTTextArea ID="tbIncludeFilter" runat="server" AllowBlank="True"
                TabIndex="250" ControlWidth="373" ControlHeight="50" HideLabel="False" LabelSeparator=":" Label="Include Filter (SQL)"
                LabelWidth="120" meta:resourcekey="tbIncludeFilterResource1" ReadOnly="False"
                XType="TextArea" XTypeNameSpace="form" Listeners="{}" />
              </div> <!-- editIncludeFilterDiv -->
              <div id="viewIncludeFilterDiv" runat="server">
                <table class="AccountQualificationViewIncludeFilter" >
                  <tr>
                    <td class="AccountQualificationViewIncludeFilterCol1">
                      <MT:MTLabel ID="ViewIncludeFilterLabel" runat="server" Text="Description:" meta:resourcekey="ViewIncludeFilterLabelResource"/>
                    </td>
                    <td class="AccountQualificationViewIncludeFilterCol2">
                      <MT:MTLabel ID="ViewIncludeFilterText" runat="server" />
                    </td>
                  </tr>
                </table>
              </div> <!-- viewIncludeFilterDiv -->
            </div>
          </td>
        </tr>
        <tr> <!-- Row 3: Filter textarea -->
          <td>
            <div style="padding-top: 25px;">
              <div id="editFilterDiv" runat="server">
              <MT:MTTextArea ID="tbFilter" runat="server" AllowBlank="True"
                TabIndex="260" ControlWidth="373" ControlHeight="50" HideLabel="False" LabelSeparator=":" Label="Filter (MVM script)"
                LabelWidth="120" meta:resourcekey="tbFilterResource1" ReadOnly="False"
                XType="TextArea" XTypeNameSpace="form" Listeners="{}" />
              </div> <!-- editFilterDiv -->
              <div id="viewFilterDiv" runat="server">
                <table class="AccountQualificationViewFilter" >
                  <tr>
                    <td class="AccountQualificationViewFilterCol1">
                      <MT:MTLabel ID="ViewFilterLabel" runat="server" Text="Description:" meta:resourcekey="ViewFilterLabelResource"/>
                    </td>
                    <td class="AccountQualificationViewFilterCol2">
                      <MT:MTLabel ID="ViewFilterText" runat="server" />
                    </td>
                  </tr>
                </table>
              </div> <!-- viewFilterDiv -->
            </div>
          </td>
        </tr>
        <tr> <!-- Row 4: Mode dropdown -->
          <td>
            <div style="padding-top: 5px;">
              <MT:MTDropDown ID="ddMode" runat="server" AllowBlank="False" 
                TabIndex="270" ControlWidth="200" ListWidth="200" 
                Label="FOOMode" meta:resourcekey="ddModeResource1" LabelWidth="120" LabelSeparator=":" HideLabel="False"
                ReadOnly="false" Editable="True"
                CausesValidation="True" Listeners="{}" >    
              </MT:MTDropDown>  
            </div>
          </td>
        </tr>

      </table>
    
      <br />
        
    </div>
        
    <!-- 
      Regarding positioning of the Back and Continue buttons:
      The br element is needed; leave it there!
      The padding-left and padding-top might change from page to page,
      but leave the col width the same to maintain the same spacing between buttons on every page.
    -->
    <br />
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
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_SAVE_AND_CONTINUE%>"   
                            OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"                          
                            OnClick="btnContinue_Click"
                            CausesValidation="true" TabIndex="240"/>
            </td>
        </tr>
        </table> 
    </div>
        
    
    <script type="text/javascript" language="javascript">
        
        Ext.onReady(function () {
                        
            // Record the initial values of the page's controls.
            // (Note:  This is called here, and not on the master page,
            // because the call to document.getElementById() returns null
            // if executed on the master page.)
            MPC_assignInitialValues();
        });
    
    </script>

</asp:Content>

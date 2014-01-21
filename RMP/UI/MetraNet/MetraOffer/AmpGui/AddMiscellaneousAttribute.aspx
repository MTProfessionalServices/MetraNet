<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="AddMiscellaneousAttribute.aspx.cs" Inherits="AmpAddMiscellaneousAttributePage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow() {
    top.Ext.getCmp('addMiscAttributeWindow').close();
  }

</script>

<br/>
<br/>
  <MT:MTTextBoxControl ID="MiscAttributeName" runat="server" AllowBlank="False" 
    ControlHeight="18" ControlWidth="245" HideLabel="False" Label="Name" meta:resourcekey="MiscAttributeNameLabel"
    LabelSeparator=":" LabelWidth="56" Listeners="{}" MaxLength="-1" 
    MinLength="0" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null" ReadOnly="False" 
    ValidationRegex="null" XType="TextField" XTypeNameSpace="form" VType="decisionRelatedName" />
  <br/>
  <table>
      <tr>
      <td style="padding-top: 10px; padding-left: 16px;" valign="top">
        <MT:MTLabel ID="ValueLabel" meta:resourcekey="ValueLabel" runat="server" 
          Font-Bold="True" ForeColor="Black" Font-Size="8pt" Text="Value:"/>
      </td>
      <td>
         <ampc:AmpTextboxOrDropdown ID="ctrlValue" runat="server"
             TextboxIsNumeric="false">
         </ampc:AmpTextboxOrDropdown>
      </td>
    </tr>
</table>

  <br/>
  <div style="clear:both;">
      <table style="margin-top:30px; margin-left:130px;" cellspacing="30">
        <tr>
          <td>
            <MT:MTButton ID="btnOK" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>"  OnClick="btnOK_Click" 
              OnClientClick="return ValidateForm();" 
              TabIndex="240" meta:resourcekey="btnOKResource1" />      
          </td>
          <td>
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="250" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table>
  </div>

 </asp:Content>


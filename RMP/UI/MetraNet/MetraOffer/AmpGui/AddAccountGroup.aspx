<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="AddAccountGroup.aspx.cs" Inherits="AmpAddAccountGroupPage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow(newAccountGroupName) {
    top.Ext.getCmp('addAccountGroupWindow').myExtraParams.newAccountGroupName = newAccountGroupName;
    top.Ext.getCmp('addAccountGroupWindow').close();
  }

</script>

<br/>
<br/>
  <MT:MTTextBoxControl ID="Name" runat="server" AllowBlank="False" 
    ControlHeight="18" ControlWidth="300" HideLabel="False" Label="Name" meta:resourcekey="NameLabel"
    LabelSeparator=":" LabelWidth="70" Listeners="{}" MaxLength="-1" 
    MinLength="0" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null" ReadOnly="False" 
    ValidationRegex="null" XType="TextField" XTypeNameSpace="form" VType="decisionRelatedName" />
  <br/>
  <MT:MTTextArea ID="Description" runat="server" AllowBlank="True" ControlWidth="300" ControlHeight="70" HideLabel="False" Label="Description" meta:resourcekey="DescriptionLabel"
                 LabelSeparator=":" LabelWidth="70" XType="TextArea" XTypeNameSpace="form" Listeners="{}" ReadOnly="False" />

  <br/>
  <div style="clear:both;">
      <table style="margin-top:0px; margin-left:130px;" cellspacing="30">
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


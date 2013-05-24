<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="CloneDecision.aspx.cs" Inherits="AmpCloneDecisionPage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow() {
    top.Ext.getCmp('cloneWin').close();
  }

</script>
  
  <br /><br /><br />
 
  <div class="Left">     
     <MT:MTTextBoxControl ID="tbOrigDecisionName" runat="server" AllowBlank="True" Label="Decision Type to be Cloned"
        TabIndex="200" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="160" Listeners="{}" meta:resourcekey="tbOrigDecisionNameResource1" ReadOnly="True"
        XType="TextField" XTypeNameSpace="form" />      
     <MT:MTTextBoxControl ID="tbNewDecisionName" runat="server" AllowBlank="False" Label="New Decision Type Name"
        TabIndex="210" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="160" Listeners="{}" meta:resourcekey="tbNewDecisionNameResource1" ReadOnly="False"
        XType="TextField" XTypeNameSpace="form" VType="decisionRelatedName" />
     <MT:MTTextArea ID="tbDescription" runat="server" AllowBlank="True" Label="Description"
        TabIndex="220" ControlWidth="200" ControlHeight="50" HideLabel="False" LabelSeparator=":"
        LabelWidth="160" Listeners="{}" meta:resourcekey="tbDescriptionResource1" ReadOnly="False"
        XType="TextArea" XTypeNameSpace="form" />   
     <MT:MTCheckBoxControl ID="cbDeactivateDecision" runat="server" BoxLabel="Deactivate" Visible="false" 
        meta:resourcekey="cbDeactivateDecisionResource1" 
        Checked="false" XType="Checkbox" XTypeNameSpace="form" ControlWidth="300" TabIndex="230"/> 
  </div>
 
  <div style="clear:both;">
      <table style="margin-top:10px; margin-left:138px;" cellspacing="30">
        <tr>
          <td>
            <MT:MTButton ID="btnOK" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>"  OnClick="btnOK_Click" OnClientClick="return ValidateForm();" TabIndex="240" />      
          </td>
          <td>
            <MT:MTButton ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="250" />
          </td>
        </tr>
      </table>
  </div>

 </asp:Content>


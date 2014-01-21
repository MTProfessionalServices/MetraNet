<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="DeleteMiscellaneousAttribute.aspx.cs" Inherits="AmpDeleteMiscellaneousAttributePage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow() {
    top.Ext.getCmp('deleteMiscAttributeWindow').close();
  }

</script>
<asp:HiddenField ID="Name" runat="server" />
<div style="padding-left: 20px; padding-top: 20px;">
  <MT:MTLabel ID="Question" runat="server"
    Font-Bold="False" ForeColor="Black" Font-Size="9pt" 
    />
</div>

  <div id="YesAndNoButtonsDiv" style="clear:both;" runat="server">
      <table style="margin-top:0px; margin-left:130px;" cellspacing="30">
        <tr>
          <td>
            <MT:MTButton ID="btnYes" runat="server" 
              Text="<%$ Resources:Resource,TEXT_YES %>"  OnClick="btnYes_Click"
              TabIndex="240" />      
          </td>
          <td>
            <MT:MTButton ID="btnNo" runat="server" 
              Text="<%$ Resources:Resource,TEXT_NO %>" OnClick="btnNo_Click" 
              CausesValidation="False" TabIndex="250" />
          </td>
        </tr>
      </table>
  </div>

 </asp:Content>


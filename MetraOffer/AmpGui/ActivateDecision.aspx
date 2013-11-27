<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ActivateDecision.aspx.cs" Inherits="AmpActivateDecisionPage" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

  function closeWindow() {
    top.Ext.getCmp('activateWin').close();
  }

</script>

  <br/>
  <table id="ErrorCheckFirstTable" runat="server" style="width: 100%">
    <tr>
      <td>
        &nbsp;</td>
      <td>
        &nbsp;</td>
      <td>
        <asp:Label ID="ErrorCheckFirst" runat="server" Text="Sorry, you must do an Error Check before activating your Decision Type." meta:resourcekey="ErrorCheckFirstLabel"></asp:Label></td>
    </tr>
  </table>

  <br />
    <div style="clear:both;">
      <table style="margin-top:30px; margin-left:160px;" cellspacing="30">
        <tr>
          <td>
            <MT:MTButton ID="btnOK" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>"   
              OnClick="btnOK_Click"
              TabIndex="240" />
          </td>
         </tr>
      </table>
  </div>

</asp:Content>


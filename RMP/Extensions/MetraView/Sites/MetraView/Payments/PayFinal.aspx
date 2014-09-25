<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_PayFinal" CodeFile="PayFinal.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Src="../UserControls/BillAndPayments.ascx" TagName="BillAndPayments" TagPrefix="uc4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <h1><asp:Localize ID="Localize1" meta:resourcekey="PaymentConfirmation" runat="server" Text="Payment Confirmation"></asp:Localize></h1>
  <div class="box500">
    <div class="box500top"></div>
    <div class="box">
      <table cellspacing="10" cellpadding="0">
        <tr>
          <td width="50%" style="vertical-align:top">
            <asp:Localize ID="Localize6" meta:resourcekey="InstructionsTest" runat="server" Text="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat"></asp:Localize>
          </td>
          <td width="50%" style="vertical-align:top">
            <uc4:BillAndPayments ID="BillAndPayments2" runat="server" HidePaymentButton="true" />
          </td>
        </tr>
      </table>
      <div class="clearer"></div>
    </div>
  </div>
  


  <div class="box500">
    <div class="box500top"></div>
    <div class="box">
    <MT:MTLiteralControl ID="lcConfirmationNumber" runat="server" Label="Confirmation number" ControlWidth="320" LabelWidth="140"
      Text="" meta:resourcekey="lcConfirmationNumber" />
  <MT:MTLiteralControl ID="lcAmount" runat="server" Label="Amount" ControlWidth="320" LabelWidth="140"
      Text="" meta:resourcekey="lcAmount"/>
  <MT:MTLiteralControl ID="lcDate" runat="server" Label="Date" ControlWidth="320" LabelWidth="140"
      Text="" meta:resourcekey="lcDate" />
  <MT:MTLiteralControl ID="lcMethod" runat="server" Label="Method" ControlWidth="320" LabelWidth="140"
      Text="" meta:resourcekey="lcMethod"/>
  <MT:MTLiteralControl ID="lcType" runat="server" Label="Card Type" ControlWidth="320" LabelWidth="140"
      Text="" meta:resourcekey="lcType" />
  <MT:MTLiteralControl ID="lcNumber" runat="server" Label="Card Number" ControlWidth="320" LabelWidth="140"
      Text="" meta:resourcekey="lcNumber"/>
      <div class="clearer"></div>
    </div>
  </div>



</asp:Content>


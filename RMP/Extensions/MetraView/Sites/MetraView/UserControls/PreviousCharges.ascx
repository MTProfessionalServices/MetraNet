<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_PreviousCharges" CodeFile="PreviousCharges.ascx.cs" %>

<h6><asp:Localize meta:resourcekey="PaymentsCreditsAdjustments" runat="server">Payments, Credits, & Adjustments</asp:Localize></h6>
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><asp:Localize meta:resourcekey="PreviousBalance" runat="server">Previous Balance</asp:Localize></td>
    <td class="amount"><%= GetPreviousBalanceAmount() %></td>
  </tr>
  <%= GetPostBillAdjustments() %>
  <%= GetPaymentsReceived() %>
</table>
<hr />

<table width="100%" cellspacing="0" cellpadding="0">
  <tr class="subtotal">
    <td><asp:Localize meta:resourcekey="TotalBalanceForward" runat="server">Total Balance Forward</asp:Localize></td>
    <td class="amount"><%= GetBalanceForwardAmount() %></td>
  </tr>
</table>


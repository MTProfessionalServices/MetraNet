<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_BillAndPayments" CodeFile="BillAndPayments.ascx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<h6><asp:Localize meta:resourcekey="BillAndPayments" runat="server">Payment Information</asp:Localize></h6>
<table width="200px;" cellspacing="0" cellpadding="0">
  <tr id="lastPaymentDiv" runat="server">
    <td><asp:Localize meta:resourcekey="LastPayment" runat="server">Last Payment</asp:Localize> <%= GetPaymentDate() %>:</td>
    <td class="amount"><%= GetPaymentAmount() %></td>
  </tr>
  <tr class="even subtotal" id="totalAmountDueDiv" runat="server">
    <td><asp:Localize meta:resourcekey="TotalAmountDue" runat="server">Total Amount Due:</asp:Localize></td>
    <td class="amount"><%= GetPreviousBalance() %></td>
  </tr>
  <tr id="dueDateDiv" runat="server">
    <td><asp:Localize meta:resourcekey="PaymentDue" runat="server">Payment Due:</asp:Localize> <%= GetPaymentDueDate() %></td>
    <td class="amount"></td>
  </tr>
  <tr id="noPaymentDueDiv"  runat="server">
    <td colspan="2">
      <asp:Localize runat="server" meta:resourcekey="NoPaymentIsDue">No Payment is Due</asp:Localize>
    </td>
  </tr>
</table>

<asp:Panel ID="PanelPaymentButton" runat="server">
<div class="button">
    <span class="buttonleft"><!--leftcorner--></span>
    <a href="<%=Request.ApplicationPath%>/Payments/MakePayment.aspx"><asp:Localize meta:resourcekey="PayNow" runat="server">Pay Now</asp:Localize></a>
    <span class="buttonright"><!--rightcorner--></span>
</div>
</asp:Panel>


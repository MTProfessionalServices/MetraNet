<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_CurrentCharges" CodeFile="CurrentCharges.ascx.cs" %>

<%= GetCharges() %>
    
<hr />
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><asp:Localize meta:resourcekey="SubTotal" runat="server">Sub-Total</asp:Localize></td>
    <td class="amount"><%= GetSubTotalAmount() %></td>
  </tr>
</table> 

<asp:Panel ID="PanelAdjustments" runat="server">  
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><%= GetAdjustmentDetailLink() %></td>
    <td class="amount"><%= GetPreBillAdjustmentAmount() %></td>
  </tr>
</table>     
</asp:Panel>

<asp:Panel ID="PanelTaxes" runat="server">  
<table width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td><asp:Localize ID="Localize1" meta:resourcekey="Tax" runat="server">Tax</asp:Localize></td>
    <td class="amount"><%= GetTaxAmount() %></td>
  </tr>
  <tr>
    <td><asp:Localize meta:resourcekey="TaxAdjustments" runat="server">Tax Adjustments</asp:Localize></td>
    <td class="amount"><%= GetTaxAdjustmentAmount() %></td>
  </tr>
</table>     
</asp:Panel>

<table width="100%" cellspacing="0" cellpadding="0">  
  <tr class="subtotal">
    <td><asp:Localize meta:resourcekey="TotalCharges" runat="server">Total Charges</asp:Localize></td>
    <td class="amount"><%= GetTotalCurrentChargesAmount() %></td>
  </tr>
</table>    

<asp:Panel ID="PanelCurrentTotalAmount" runat="server">
  <hr />
  <table width="100%" cellspacing="0" cellpadding="0">
    <tr class="subtotal">
      <td><asp:Localize meta:resourcekey="Total" runat="server">Total</asp:Localize></td>
      <td class="amount"><%= GetCurrentTotalAmount() %></td>
    </tr>
  </table>   
</asp:Panel>
   
<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_GreenInvoice" CodeFile="GreenInvoice.ascx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Panel ID="PanelGoGreen" Visible="false" runat="server">
<MT:MTSecurity ID='Security1' runat="server" Capabilities='Update Subscriber Accounts'>
<div class="box200">
  <div class="box200top"></div>
  <div class="box">
    <h6><asp:Localize meta:resourcekey="GoingGreen" runat="server">Going Green?</asp:Localize></h6>
    <div style="text-align:center">
      <a href="<%=Request.ApplicationPath%>/GoPaperless.aspx">
        <asp:Image ID="Image1" ImageUrl="~/Images/GoGreen.png" AlternateText="Go paperless" runat="server" ToolTip="Go paperless" meta:resourcekey="lblGreenImageResource1" /> 
      </a>
    </div>
    <p>
      <asp:Localize meta:resourcekey="Switch" runat="server">Switch to our</asp:Localize> <a href="<%=Request.ApplicationPath%>/GoPaperless.aspx"><asp:Localize meta:resourcekey="PaperlessBilling" runat="server">paperless billing</asp:Localize></a><asp:Localize meta:resourcekey="OnlinePayment" runat="server">, and online payment.</asp:Localize>
    </p>
  </div>
</div>
</MT:MTSecurity>
</asp:Panel>


<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_PayerInfo" CodeFile="PayerInfo.ascx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<p>
  <%= GetPayingAccountAddress() %>
</p>
<asp:Panel ID="CorpEditPanel" runat="server">
  <MT:MTSecurity ID='Security1' runat="server" Capabilities='Update Subscriber Accounts'>
  <div class="button">
    <span class="buttonleft"><!--leftcorner--></span>
    <a href="<%=Request.ApplicationPath%>/AccountInfo.aspx"><asp:Localize meta:resourcekey="EditAccount" runat="server">Edit Account</asp:Localize></a>
    <span class="buttonright"><!--rightcorner--></span>
   </div>
  </MT:MTSecurity>
</asp:Panel>
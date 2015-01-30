<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Subscriptions" CodeFile="Subscriptions.ascx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

 <MT:MTSecurity ID='Security1' runat="server" Capabilities='Create Subscription'>
<asp:Literal ID="LitEmptyText1" runat="server" Visible="false" Text="<br />No Records Found." meta:resourcekey="EmptyLiteral" /> 
<asp:Label ID="LitCurrPlan" runat="server"></asp:Label> 
<br />
<br />
<hr />
<h6>
<asp:Localize ID="Localize3" meta:resourcekey="AvailablePlans" runat="server">Available Product Offerings</asp:Localize></h6>
<asp:Literal ID="LitEmptyText2" runat="server" Visible="false" Text="No Records Found." meta:resourcekey="EmptyLiteral" />
<asp:Label ID="LitProdOff" runat="server"></asp:Label>
<br />
  
<asp:Panel ID="EditButton" runat="server">
 <div class="button" id="AddButton" runat="server">
  <span class="buttonleft"><!--leftcorner--></span>
  <a href="<%=Request.ApplicationPath %>/Subscriptions.aspx">
    <asp:Localize ID="Localize1" meta:resourcekey="btnAddResource1" runat="server">Add Subscription</asp:Localize>
  </a>
  <span class="buttonright"><!--rightcorner--></span>
 </div>
</asp:Panel>
 </MT:MTSecurity>

    
   
 


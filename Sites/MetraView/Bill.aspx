<%@ Page Async="false" AsyncTimeout="120" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Bill" CodeFile="Bill.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>
<%@ Register src="UserControls/Intervals.ascx" tagname="Intervals" tagprefix="uc1" %>
<%@ Register src="UserControls/PayerInfo.ascx" tagname="PayerInfo" tagprefix="uc2" %>
<%@ Register src="UserControls/PreviousCharges.ascx" tagname="PreviousCharges" tagprefix="uc3" %>
<%@ Register src="UserControls/BillAndPayments.ascx" tagname="BillAndPayments" tagprefix="uc4" %>
<%@ Register src="UserControls/CurrentCharges.ascx" tagname="CurrentCharges" tagprefix="uc5" %>
<%@ Register src="UserControls/CurrentChargesByFolder.ascx" tagname="CurrentChargesByFolder" tagprefix="uc6" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <h1><asp:Localize meta:resourcekey="BillAndPayments" runat="server">Bill & Payments</asp:Localize></h1>
  
  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
    <div class="left">
      <uc4:BillAndPayments ID="BillAndPayments1" runat="server" />
    </div>
    <div class="right">
      <uc2:PayerInfo ID="PayerInfo1" runat="server" />
    </div> 
    <div class="clearer"></div>
  </div>
  </div>
  
  <asp:Panel ID="panelBill" runat="server">
    <div class="box500plain">
    <div class="box500plaintop"></div>
    <div class="box">
      <div class="left">
        <uc1:Intervals ID="Intervals1" runat="server" />
      </div>
      <div class="right">
        <%= GetPrintIcon() %>
      </div>
      <div class="clearer"></div>

      <uc3:PreviousCharges ID="PreviousCharges1" runat="server" />
      <br />
      
      <asp:Panel ID="PanelCurrentCharges" runat="server">
        <h6><asp:Localize ID="Localize1" meta:resourcekey="Charge" runat="server">Charges</asp:Localize> <small>[ <a href="<%= UI.DictionaryManager["BillPage"] + "?view=details"%>"><asp:Localize meta:resourcekey="DetailedView" runat="server">Detailed View</asp:Localize></a> ]</small></h6>   
        <uc5:CurrentCharges ID="CurrentCharges1" runat="server" />
      </asp:Panel>
      <asp:Panel Visible="false" ID="PanelCurrentChargesByFolder" runat="server">
        <h6><asp:Localize ID="Localize2" meta:resourcekey="Charge" runat="server">Charge Details</asp:Localize> <small>[ <a href="<%= UI.DictionaryManager["BillPage"] + "?view=summary" %>"><asp:Localize meta:resourcekey="SummaryView" runat="server">Summary View</asp:Localize></a> ]</small></h6>   
        <uc6:CurrentChargesByFolder ID="CurrentChargesByFolder1" runat="server" />
      </asp:Panel>
    </div>
    <div class="box500plainbtm"></div>
    </div>
  </asp:Panel>
  
  <asp:Panel ID="panelNoBillMessage" Visible="false" runat="server">
    <%= GetNoBillMessage() %>
  </asp:Panel>  

    <asp:Panel ID="panelEstimate" Visible="false" runat="server">
    <%= GetEstimateMessage() %>
  </asp:Panel> 
</asp:Content>


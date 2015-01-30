<%@ Page Language="C#" MasterPageFile="~/MasterPages/SubscriptionsPageExt.master" AutoEventWireup="true" Inherits="Subscriptions" CodeFile="SubscriptionProperties.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <asp:Label ID="LitCurrPlan" runat="server"></asp:Label>
  <asp:Literal ID="LitEmptyText" runat="server" Visible="false" Text="No Records Found." meta:resourcekey="EmptyLiteral" />
  <h1>
    <asp:Localize ID="Localize1" meta:resourcekey="AddSubscription" runat="server">Add Subscription</asp:Localize></h1>

    <!-- Properties -->
    <MT:MTPanel ID="pnlSubscriptionProperties"  Width="450" runat="server" Collapsible="false" meta:resourcekey="pnlSubscriptionProperties"></MT:MTPanel>
  
    <asp:RadioButtonList ID="radPoList" runat="server" AppendDataBoundItems="true"></asp:RadioButtonList>
    <asp:Label ID="EmptyLabel" runat="server" Text="No Records Found" meta:resourcekey="EmptyLabel" Visible="false" ></asp:Label>
    <div class="button" id="AddButton" runat="server">
      <div class="centerbutton">
        <span class="buttonleft"><!--leftcorner--></span>
          <asp:Button OnClick="btnOK_Click" ID="btnOK" OnClientClick="return ValidateForm();" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" />
        <span class="buttonright"><!--rightcorner--></span>
      </div>
      <span class="buttonleft"><!--leftcorner--></span>
        <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false" Text="<%$Resources:Resource,TEXT_CANCEL%>" />
      <span class="buttonright"><!--rightcorner--></span>         
    </div>
  
</asp:Content>


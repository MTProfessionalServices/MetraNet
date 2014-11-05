<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ManageSubscriptionParameters.aspx.cs" Inherits="MetraNet.AccountConfigSets.ManageSubscriptionParameters"
Title="MetraNet - Manage Subscription Parameters" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="ManageSubscriptionParameterTitle" runat="server" meta:resourcekey="manageSubscriptionParameterTitle"/>
  <br />
  <MT:MTPanel ID="MTPanelSubscriptionParameters" runat="server" Collapsible="True" meta:resourcekey="panelSubscriptionParametersResource">    
    <div id="leftColumn2" class="LeftColumn">      
       <MT:MTTextBoxControl ID="MTtbSubParamsDescription" AllowBlank="True" ReadOnly="True" 
        LabelWidth="120" runat="server" meta:resourcekey="tbSubParamsDescriptionResource"/>
       <MT:MTTextBoxControl ID="MTtbSubParamsPo" AllowBlank="True" ReadOnly="True"
        LabelWidth="120" runat="server" meta:resourcekey="tbSubParamsPoResource"/>
      <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpSubParamsStartDate" 
        Label="Start date" LabelWidth="120" meta:resourcekey="dpSubParamsStartDateResource" ReadOnly="True"
        runat="server"></MT:MTDatePicker>
      <MT:MTDatePicker AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpSubParamsEndDate"
        Label="End date" LabelWidth="120" meta:resourcekey="dpSubParamsEndDateResource" ReadOnly="True"
        runat="server"></MT:MTDatePicker>
      <MT:MTInlineSearch ID="MTisCorpAccountId" AllowBlank="True" ReadOnly="True"
        LabelWidth="120" runat="server" meta:resourcekey="isCorpAccountIdResource"/>
      <MT:MTTextBoxControl ID="MTtbGroupSubscriptionName" AllowBlank="True" ReadOnly="True"
        LabelWidth="120" runat="server" meta:resourcekey="tbGroupSubscriptionNameResource"/>
    </div>
    <div id="PlaceHolderUDRCGrid" class="RightColumn">
    </div>
  </MT:MTPanel>
</asp:Content>

<%@ Page Language="C#"  MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="UsageStatisticsFilter.aspx.cs" Inherits="MetraNet.MetraControl.Usage.UsageStatisticsFilter" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="MTTitleUsageStatisticsFilter" meta:resourcekey="MTTitleUsageStatisticsFilter" runat="server" />
  
  <br />

  <MT:MTPanel ID="MTPanelDateRange" meta:resourcekey="MTPanelDateRange" runat="server" Width="350">
    <MT:MTDatePicker ID="MTDatePickerFrom" LabelWidth="100" runat="server" />
    <MT:MTDatePicker ID="MTDatePickerTo" LabelWidth="100" runat="server" />
    <br />
    <div align="center">
      <MT:MTButton ID="MTButtonSearch" OnClick="ButtonSearchClick" runat="server" />
    </div>
  </MT:MTPanel>

</asp:Content>


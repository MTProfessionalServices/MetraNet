<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="RunScheduledAdapter.aspx.cs" Inherits="MetraNet.MetraControl.ScheduledAdapters.RunScheduledAdapter" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="RunScheduledAdapterMTTitle" runat="server" meta:resourcekey="RunScheduledAdapterMTTitle" />  
  <MT:MTFilterGrid ID="RunScheduledAdapterGrid" runat="server" TemplateFileName="RunScheduledAdapterGrid" ExtensionName="Core" />
</asp:Content>
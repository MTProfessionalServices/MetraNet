<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Charts_TopUsage" CodeFile="TopUsage.aspx.cs" Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<div style="padding:5px">
  <MT:MTChart ID="Chart3" runat="server" Width="300" Height="300" Text="<%$Resources:Resource, TEXT_HIERARCHY_LEVELS%>" />

  <br />

  <MT:MTChart ID="Chart2" runat="server" Text="<%$Resources:Resource, TEXT_ACCT_MOST_USAGE%>" />
 
</div>
 
</asp:Content>


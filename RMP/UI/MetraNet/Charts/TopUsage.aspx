<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Charts_TopUsage" CodeFile="TopUsage.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script>
  if (top.events) {
    top.events.on('INFO_MESSAGE', launch, this);
  }
  function launch(msg) {
    alert("Received event in MetraNet:" + msg);
  }	

</script>

<div style="padding:5px">
  <MT:MTChart ID="Chart3" runat="server" Width="300" Height="300" Text="Hierarchy Levels with the Most Accounts" />

  <br />

  <MT:MTChart ID="Chart2" runat="server" Text="Accounts with the most usage bar chart" />
 
</div>
 
</asp:Content>


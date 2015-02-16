<%@ Page Async="true" AsyncTimeout="120" Language="C#" MasterPageFile="~/MasterPages/MetraViewExt.master" AutoEventWireup="true" Inherits="_Default" CodeFile="Default.aspx.cs" Culture="auto" UICulture="auto"
Title="<%$Resources:Resource,TEXT_TITLE%>" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Src="UserControls/ServerDescription.ascx" TagName="ServerDescription" TagPrefix="uc1" %>
<%@ Register src="UserControls/UsageGraph.ascx" tagname="UsageGraph" tagprefix="uc2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:Dashboard ID="Dashboard1" Name="MainDashboard" runat="server" />
<div class="clearer"><!--important--></div>
  <script type="text/javascript">
    Ext.onReady(function(){
      var mainframe = window.frameElement.ownerDocument.getElementById("MainContent");
      mainframe.style.overflow = 'hidden';
    });
    </script>
</asp:Content>


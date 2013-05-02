<%@ Page Language="C#" MasterPageFile="~/MasterPages/DetailsPageExt.master" AutoEventWireup="true" Inherits="AdjustmentDetails" CodeFile="AdjustmentDetails.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <script type="text/javascript">
    var accountSlice = "<%= AccountSliceString %>";
  </script>

  <h1><asp:Localize meta:resourcekey="AdjustmentDetails" runat="server">Adjustment Details</asp:Localize></h1>
  <MT:MTFilterGrid ID="MTFilterGrid1" ExtensionName="MetraView" TemplateFileName="AdjustmentDetail.xml" runat="server"></MT:MTFilterGrid>

  <div id="divButton" runat="server" class="button">
    <span class="buttonleft"><!--leftcorner--></span>
    <a href="JavaScript:history.go(-1)">Back</a>
    <span class="buttonright"><!--rightcorner--></span>
  </div>
  
</asp:Content>


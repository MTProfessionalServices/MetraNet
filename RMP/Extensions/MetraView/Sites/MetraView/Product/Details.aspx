<%@ Page Language="C#" MasterPageFile="~/MasterPages/DetailsPageExt.master" AutoEventWireup="true" Inherits="Product_Details" CodeFile="Details.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="../UserControls/ReportParams.ascx" tagname="ReportParams" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script type="text/javascript">
  var accountSlice = "<%= HttpUtility.HtmlEncode(AccountSliceString) %>";
  var productSlice = "<%= HttpUtility.HtmlEncode(ProductSliceString) %>";
</script>

  <h1><asp:Localize meta:resourcekey="Details" runat="server">Details</asp:Localize></h1>
  
  <uc1:ReportParams ID="ReportParams1" runat="server" />
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server"></MT:MTFilterGrid>

  <div id="divButton" runat="server" class="button">
    <span class="buttonleft"><!--leftcorner--></span>
    <a href="JavaScript:history.go(-1)"><asp:Localize meta:resourcekey="Back" runat="server">Back</asp:Localize></a>
    <span class="buttonright"><!--rightcorner--></span>
  </div>

</asp:Content>


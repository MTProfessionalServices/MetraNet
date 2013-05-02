<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Reports_DownloadInvoices" CodeFile="DownloadInvoices.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>"%>
<%@ Register src="../UserControls/Intervals.ascx" tagname="Intervals" tagprefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<h1><%=Resources.Resource.TEXT_DOWNLOAD_INVOICES %></h1>

<uc1:Intervals ID="Intervals1" runat="server" />
<p></p>
<ul>
<asp:Literal ID="InvoiceList" runat="server"></asp:Literal>
</ul>
</asp:Content>


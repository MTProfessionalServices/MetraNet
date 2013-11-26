<%@ Page Language="C#" MasterPageFile="~/MasterPages/AdminPageExt.master" AutoEventWireup="true" Inherits="BE" CodeFile="BE.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Import Namespace="MetraTech.BusinessEntity.DataAccess.Metadata"%>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="<%$Resources:Resource, TEXT_BE_TITLE %>" runat="server"/><br />

  <asp:DataList ID="DataList1" runat="server">
  <ItemTemplate>
    &nbsp;&nbsp;
    <a href='<%# Request.ApplicationPath  %>/BE/BEList.aspx?Name=<%# Utils.EncodeForHtml(((Entity)Container.DataItem).FullName)  %>&NewBreadcrumb=true&Extension=<%# Utils.EncodeForHtml(((Entity)Container.DataItem).ExtensionName)  %>'><%# Utils.EncodeForHtml(((Entity)Container.DataItem).ClassName) %></a> 
    <br /><br />
  </ItemTemplate>
  </asp:DataList>

  <asp:Label Visible="false" ID="lblNoBEs" runat="server" meta:resourcekey="lblNoBEs" Text="No items to display{NL}"></asp:Label>
</asp:Content>


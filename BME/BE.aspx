<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="BE" CodeFile="BE.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Import Namespace="MetraTech.BusinessEntity.DataAccess.Metadata"%>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<MT:MTTitle ID="MTTitle1" Text="List of Business Entities" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

  <asp:DataList ID="DataList1" runat="server">
  <ItemTemplate>
    &nbsp;&nbsp;
    <a href='<%# Request.ApplicationPath  %>/BME/BEList.aspx?Name=<%# Utils.EncodeForHtml(((Entity)Container.DataItem).FullName)  %>&NewBreadcrumb=true&Extension=<%# Utils.EncodeForHtml(((Entity)Container.DataItem).ExtensionName)  %>'><%# Utils.EncodeForHtml(((Entity)Container.DataItem).ClassName) %></a> 
    <br /><br />
  </ItemTemplate>
  </asp:DataList>

  <asp:Label Visible="false" ID="lblNoBEs" runat="server" meta:resourcekey="lblNoBEs" Text="No items to display{NL}"></asp:Label>
</asp:Content>


<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="UserControls_ticketToMCM" Title="MetraNet" CodeFile="TicketToMCM.aspx.cs" %>
<%@ Import Namespace="MetraTech.SecurityFramework" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<iframe src="<%=(URL ?? string.Empty).EncodeForHtmlAttribute()%>" id="ticketFrame" name="ticketFrame" width="100%" height="95%" style="width:100%;height:95%;" frameborder="0" scrolling="yes"></iframe>
</asp:Content>




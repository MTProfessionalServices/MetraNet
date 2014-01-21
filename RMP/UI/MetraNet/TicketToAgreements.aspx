<%@ Page Language="C#" ValidateRequest="false" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="TicketToAgreements" Title="MetraNet" CodeFile="TicketToAgreements.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<iframe src="<%=URL%>" id="ticketFrame" name="ticketFrame" width="100%" height="100%" style="width:100%;height:100%;" frameborder="0" scrolling="auto"></iframe>
</asp:Content>


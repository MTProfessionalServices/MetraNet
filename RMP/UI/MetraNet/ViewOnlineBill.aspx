<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="ViewOnlineBill" Title="MetraNet" CodeFile="ViewOnlineBill.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <iframe src="<%=URL%>" id="ticketFrame" name="ticketFrame" 
    width="100%" height="95%" style="margin-bottom: -2px; padding-bottom: -2px;" 
    frameborder="0" scrolling="auto"></iframe>
</asp:Content>


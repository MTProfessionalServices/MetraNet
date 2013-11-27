<%@ Page Language="C#" MasterPageFile="~/MasterPages/AdminPageExt.master" AutoEventWireup="true" Inherits="Admin_Logs" CodeFile="Logs.aspx.cs" Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<iframe frameborder="0" src="<%=Request.ApplicationPath%>/elmah.axd" width="100%" height="600px"></iframe>

</asp:Content>


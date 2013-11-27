<%@ Page Language="C#" MasterPageFile="~/MasterPages/MetraViewExt.master" AutoEventWireup="true" Inherits="SelectBillEntryPoint" Culture="auto" UICulture="auto"
CodeFile="SelectBillEntryPoint.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text=""
        Visible="true"></asp:Label>
</asp:Content>
<%@ Page Language="C#" MasterPageFile="~/MasterPages/PaymentPageExt.master" AutoEventWireup="true" Inherits="Payments_ViewPaymentHistory" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ViewPaymentHistory.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<h1><asp:Localize ID="Localize1" meta:resourcekey="ViewPaymentHistory" runat="server">Payment History</asp:Localize></h1>
  
  <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="MetraView" TemplateFileName="PaymentHistoryLayoutTemplate"></MT:MTFilterGrid>
   
</asp:Content>

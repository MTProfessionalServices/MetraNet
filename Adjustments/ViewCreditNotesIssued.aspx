<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ViewCreditNotesIssued.aspx.cs" Inherits="Adjustments_ViewCreditNotesIssued"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" ExtensionName="Core" 
    TemplateFileName="CreditNotesIssued.xml">
  </MT:MTFilterGrid>

</asp:Content>


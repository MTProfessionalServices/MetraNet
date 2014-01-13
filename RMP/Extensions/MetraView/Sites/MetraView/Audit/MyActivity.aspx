<%@ Page Language="C#" MasterPageFile="~/MasterPages/MetraViewExt.master" AutoEventWireup="true" Inherits="Audit_MyActivity" CodeFile="~/Audit/MyActivity.aspx.cs" Culture="auto" UICulture="auto"  meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
 
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
          
  <MT:MTFilterGrid ID="MyGrid1" runat="Server" ExtensionName="MetraView" TemplateFileName="MyActivityTemplate.xml"></MT:MTFilterGrid>

</asp:Content>

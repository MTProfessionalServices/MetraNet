<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Audit_AuditLog" Title="MetraNet" CodeFile="AuditLog.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <script type="text/javascript">

  Ext.onReady(function() {

    // Sometimes when we come back from old MAM or MetraView we may have an extra frame.
    // This code busts out of it.
    if (getFrameMetraNet() && getFrameMetraNet().MainContentIframe) {
      if (getFrameMetraNet().MainContentIframe.location != document.location) {
        getFrameMetraNet().MainContentIframe.location.replace(document.location);
      }
    }
  });
  </script>
  
  <MT:MTFilterGrid ID="MyGrid1" runat="Server" ExtensionName="Account" TemplateFileName="AuditLogLayoutTemplate.xml"></MT:MTFilterGrid>

</asp:Content>


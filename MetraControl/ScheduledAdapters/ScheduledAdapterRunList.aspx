<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  CodeFile="ScheduledAdapterRunList.aspx.cs" Inherits="MetraNet.MetraControl.ScheduledAdapters.ScheduledAdapterRunList" %>

<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="ScheduledAdapterRunListMTTitle" runat="server" meta:resourcekey="ScheduledAdapterRunListMTTitle"/>
  <MT:MTFilterGrid ID="ScheduledAdapterRunListGrid" runat="server" TemplateFileName="ScheduledAdapterRunListGrid.xml"
    ExtensionName="Core" />
  <script type="text/javascript">
    OverrideRenderer_<%= ScheduledAdapterRunListGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('id_instance'), IdInstanceRenderer);
    };
    
    function IdInstanceRenderer(value, meta, record) {
      return String.format("<a href='/MetraNet/MetraControl/ScheduledAdapters/AdapterInstanceInformation.aspx?ID={0}&ReturnUrl=ScheduledAdapterRunList.aspx' style='cursor:pointer'>{0}</a>", value);
    }
    
    function onCancel_<%= ScheduledAdapterRunListGrid.ClientID %>() {
      window.location.href = "/MetraNet/";
      return false;
    }
  </script>
</asp:Content>

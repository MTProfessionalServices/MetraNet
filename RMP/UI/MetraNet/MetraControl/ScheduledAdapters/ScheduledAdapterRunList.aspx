<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  CodeFile="ScheduledAdapterRunList.aspx.cs" Inherits="MetraNet.MetraControl.ScheduledAdapters.ScheduledAdapterRunList" %>

<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="ScheduledAdapterRunListMTTitle" runat="server" meta:resourcekey="ScheduledAdapterRunListMTTitle"/>
  <MT:MTFilterGrid ID="ScheduledAdapterRunListGrid" runat="server" TemplateFileName="ScheduledAdapterRunListGrid.xml"
    ExtensionName="Core" />
  <script type="text/javascript">
    var locolizedStatuses = Ext.util.JSON.decode('<%=JsonLocalizedStatuses%>');
    var duration = '<%=String.IsNullOrEmpty(Request.QueryString["duration"]) ? String.Empty : "?duration="+Request.QueryString["duration"] %>';
    
    OverrideRenderer_<%= ScheduledAdapterRunListGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('id_instance'), IdInstanceRenderer);
      cm.setRenderer(cm.getIndexById('tx_status'), StatusRenderer);
    };
    
    function IdInstanceRenderer(value, meta, record) {
      return String.format("<a href='/MetraNet/MetraControl/ScheduledAdapters/AdapterInstanceInformation.aspx?ID={0}&ReturnUrl=ScheduledAdapterRunList.aspx{1}' style='cursor:pointer'>{0}</a>", value, duration);
    }
    
    function StatusRenderer(value, meta, record) {
      return getLocolizedStatus(value);
    }
    
    function onCancel_<%= ScheduledAdapterRunListGrid.ClientID %>() {
      window.location.href = "/MetraNet/";
      return false;
    }
    
    function getLocolizedStatus(status) {
      if (!locolizedStatuses[status]) {
        locolizedStatuses[status] = status;
      }
      return locolizedStatuses[status];
    }
  </script>
</asp:Content>

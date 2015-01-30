<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="Notifications.aspx.cs" Inherits="Notifications" Title="Notifications" Culture="auto" UICulture="auto" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="widget" data-row="6" data-col="1" data-sizex="8" data-sizey="3">
  <MT:MTFilterGrid ID="NotificationsGrid" runat="server" TemplateFileName="NotificationEventsLayout.xml" ExtensionName="Account" ></MT:MTFilterGrid>
  <asp:HiddenField runat="server" ID="hiddenIn"/>
  <asp:HiddenField runat="server" ID="HiddenOut"/>
  </div>
    <script type="text/javascript">
    var recentNotificationTpl;
    OverrideRenderer_<%= NotificationsGrid.ClientID %> = function(cm) {
      cm.getColumnById('notification_event_prop_values').renderer = replaceTemplates;
  
    }

    function replaceTemplates(value, meta, record, rowIndex, colIndex, store) {
      meta.attr = "style='white-space:normal;'";
      var template = '';
      <%=defineJavaScriptDictionary() %>;
      template = hashtable[record.json.notification_event_name];
      template = template.replace(/&gt;/gi, ">");
      template = template.replace(/&lt;/gi, "<");
      recentNotificationTpl = new Ext.XTemplate(
              "<tpl>",
                  '<div id="recennotification">' + template + '</div>',
              '</tpl>'
                  );
      return recentNotificationTpl.applyTemplate(record.json);
    }

  </script>
</asp:Content>

<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="Notifications.aspx.cs" Inherits="Notifications" Title="Notifications" Culture="auto" UICulture="auto" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="widget" data-row="6" data-col="1" data-sizex="8" data-sizey="3">
  <MT:MTFilterGrid ID="NotificationsGrid" runat="server" TemplateFileName="NotificationEventsLayout.xml" ExtensionName="Account" ></MT:MTFilterGrid>
  </div>
    <script type="text/javascript">
    var recentNotificationTpl;
    OverrideRenderer_<%= NotificationsGrid.ClientID %> = function(cm) {
      cm.getColumnById('notification_event_prop_values').renderer = replaceTemplates;
  
    }

    function replaceTemplates(value, meta, record, rowIndex, colIndex, store) {
      meta.attr = "style='white-space:normal;'";
      var SubEnding = 'Subscription End Date';
      var GSubEnding = 'Group Subscription End Date';
      var DemoNotificationEvent = 'Demo Notification Event';
      var template = '';
      if (record.json.notification_event_name == SubEnding)
        template = SUBSCRIPTION_ENDING_TEMPLATE;
      else if (record.json.notification_event_name == GSubEnding)
        template = GROUP_SUBSCRIPTION_ENDING_TEMPLATE;
      else if  (record.json.notification_event_name == DemoNotificationEvent)
        template  = DEMO_NOTIFICATION_EVENT_TEMPLATE;
              recentNotificationTpl = new Ext.XTemplate(
              "<tpl>",
                  '<div id="recennotification">' + template + '</div>',
              '</tpl>'
                  );
      return recentNotificationTpl.applyTemplate(record.json);
    }

  </script>
</asp:Content>

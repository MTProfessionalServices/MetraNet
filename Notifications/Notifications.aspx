<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="Notifications.aspx.cs" Inherits="Notifications" Title="Notifications" Culture="auto" UICulture="auto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div id="recentNotificationsContainer" style="width: 700px; padding: 10px;"></div>
  
  <script type="text/javascript">
    Ext.onReady(function () {
      var p = new Ext.Panel({
        items: [{
          title: TEXT_RECENT_NOTIFICATION,
          html: '<div id="recentNotificationsList"><i>' + '</i></div>',
          renderTo: 'recentNotificationsContainer',
          listeners: {
            render: function (panel) {
              var SubEnding = 'Subscription End Date';
              var GSubEnding = 'Group Subscription End Date';
              var recentNotificationTpl = new Ext.XTemplate(
          '<tpl for="Items">',
                "<tpl if=", '"', "notification_event_name==", "'", SubEnding, "'", '"', '>',
                    '<p><div id="recentSubscriptiponList"><i>' + SUBSCRIPTION_ENDING_TEMPLATE + '</i></div></p>',
                '</tpl>',
                "<tpl if=", '"', "notification_event_name==", "'", GSubEnding, "'", '"', '>',
                  '<p><div id="recentGroupSubscriptionList"><i>' + GROUP_SUBSCRIPTION_ENDING_TEMPLATE + '</i></div></p>',
               '</tpl>',
          '</tpl>'
      );
              Ext.Ajax.request({
                url: '/MetraNet/Notifications/AjaxServices/GetNotifications.aspx',
                timeout: 10000,
                pageSize:100,
                params: {},
                success: function (response) {
                  recentNotificationTpl.overwrite(this.body, Ext.decode(response.responseText));
                },
                failure: function () {
                  alert('failure');
                },
                scope: panel
              });
            }
          }
        }
  ]

      });
    });
  </script>
</asp:Content>

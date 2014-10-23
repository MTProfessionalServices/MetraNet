<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="Notifications.aspx.cs" Inherits="Notifications" Title="Notifications" Culture="auto" UICulture="auto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div id="recentNotificationsContainer" style="width: 900px; padding: 10px;"></div>
  
  <script type="text/javascript">
    var recentNotificationTpl;
    var p;
    var mypanel;
    var pageno = 1;
    Ext.onReady(function () {
      p = new Ext.Panel({
        id: 'armita',
        items: [{
          title: TEXT_RECENT_NOTIFICATION,
          html: '<div id="recentNotificationsList"><i>' + '</i></div>',
          renderTo: 'recentNotificationsContainer',
          listeners: {
            render: function (panel) {
              var SubEnding = 'Subscription Ending';
              var GSubEnding = 'Group Subscription Ending';
              recentNotificationTpl = new Ext.XTemplate(
                  '<tpl for="Items">',
                  "<tpl if=", '"', "notification_event_name==", "'", SubEnding, "'", '"', '>',
                  '<p><div id="recentSubscriptiponList"><i>' + SUBSCRIPTION_ENDING_TEMPLATE + '</i></div></p>',
                  '</tpl>',
                  "<tpl if=", '"', "notification_event_name==", "'", GSubEnding, "'", '"', '>',
                  '<p><div id="recentGroupSubscriptionList"><i>' + GROUP_SUBSCRIPTION_ENDING_TEMPLATE + '</i></div></p>',
                  '</tpl>',
                  '</tpl>'
                  );
              mypanel = panel;
              fetchData(panel, recentNotificationTpl);
            }
          }
        }
        ]

      });
    });

    function fetchData(panel, recentNotificationTpl) {
      Ext.Ajax.request({
        url: '/MetraNet/Notifications/AjaxServices/GetNotifications.aspx',
        timeout: 10000,
        params: {pageSize : 100, currentPage : pageno},
        success: function (response) {
          recentNotificationTpl.overwrite(panel.body, Ext.decode(response.responseText));
          if (response.responseText.length > 12) {
            var link = document.createElement("a");
            link.href = 'JavaScript:fetchData(mypanel, recentNotificationTpl);';
            link.text = 'More...';
            panel.body.dom.appendChild(link);
            pageno++;
          }
          mypanel = panel;
        },
        failure: function () {
          return null;
        },
        scope: panel
      });
    }
  </script>
</asp:Content>

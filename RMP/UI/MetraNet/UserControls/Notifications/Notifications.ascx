<%@ Control Language="C#"  AutoEventWireup="true"
  CodeFile="Notifications.ascx.cs" Inherits="UserControl_Notifications"  %>
  
  <div id="recentNotificationsContainer" style="width: 400px; padding: 10px;"></div>
  <script type="text/javascript">
    var recentNotificationTpl;
    var p;
    var mypanel;
    var pageno = 1;
    Ext.onReady(function () {
      <%=defineJavaScriptDictionary() %>;
      var l = <%=getLimit()%>;
      p = new Ext.Panel({
        items: [{
            title: TEXT_RECENT_NOTIFICATION,
            html: '<div id="recentNotificationsList"><p>' + '</p></div>',
            renderTo: 'recentNotificationsContainer',
            listeners: {
              render: function(panel) {
                Ext.Ajax.request({
                  url: '/MetraNet/Notifications/AjaxServices/GetNotifications.aspx',
                  timeout: 10000,
                  params: { limit:l, currentPage: pageno },
                  success: function(response) {
                      var template = '';
                      var items;
                      items = Ext.decode(response.responseText).Items;
                      if (items.length == 0) {
                        var p = document.createElement("p");                      
                        var i = document.createElement("i");
                        var text = document.createTextNode(TEXT_NO_RECENT_NOTIFICATIONS);
                        i.appendChild(text);
                        document.getElementById("recentNotificationsList").appendChild(i).appendChild(p);                                    
                      }
                      else{
                      for(var i = 0; i < items.length; i++)
                      {
                          template = hashtable[items[i].notification_event_name];
                          template = template.replace(/&gt;/gi, ">");
                          template = template.replace(/&lt;/gi, "<");
                        var bg;
                        i % 2 ? bg = "" : bg = "background:whitesmoke;";
                          recentNotificationTpl = new Ext.XTemplate(
                            "<tpl>",
                            '<div id="recentnotification" style=\"'+ bg +' padding-bottom:10px;\">'+ template + '<br/>'+ '</div>',
                            '</tpl>'
                          );
                          recentNotificationTpl.append(panel.body, items[i]);
//                        var br = document.createElement("br");
//                        panel.body.dom.appendChild(br);
                      }
                      var link = document.createElement("a");
                      link.href = '/MetraNet/Notifications/Notifications.aspx';
                      link.text = TEXT_VIEW_ALL;
                      link.style.cssText  = 'float:right';
                      panel.body.dom.appendChild(link);
                    }
                  }
                });
              }
            }
          }
        ]

      });
    });

  </script>

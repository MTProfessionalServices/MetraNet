using System;
using System.Collections.Generic;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Common;

public partial class Notifications_AjaxServices_NotificationService : MTListServicePage
{
    protected void Page_Load(object sender, EventArgs e)
    {

      Logger.LogInfo("Getting list of Notifications");

      using (new HighResolutionTimer("NotificationService", 5000))
      {
          string json =  "{\"Items\":[" +
                         "{\"notificationType\":\"SubscriptionEnding\",\"notificationDate\":\"10/14/14\",\"nm_login\":\"demo\",\"po_name\":\"OrderCookiesPO\",\"end_date\":\"10/31/14\",\"id_acc\":123}," +
                         "{\"notificationType\":\"GroupSubscriptionEnding\",\"notificationDate\":\"10/14/14\",\"nm_login\":\"demo\",\"po_name\":\"OrderCookiesPO_group_sub\",\"end_date\":\"10/31/14\",\"id_acc\":123}," +
                         "{\"notificationType\":\"SubscriptionEnding\",\"notificationDate\":\"10/10/14\",\"nm_login\":\"demo\",\"po_name\":\"FashionSalePO\",\"end_date\":\"10/16/14\",\"id_acc\":123}" +
                         "]}";

          Logger.LogInfo("Returning " + json);
          Response.Write(json);
          Response.End();
      }
    }
}
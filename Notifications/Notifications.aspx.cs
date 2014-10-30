using System;
using MetraTech.UI.Common;

public partial class Notifications : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected override void OnLoadComplete(EventArgs e)
    {
        NotificationsGrid.DataSourceURL =
          @"/MetraNet/Notifications/AjaxServices/GetNotifications.aspx";

    }

}
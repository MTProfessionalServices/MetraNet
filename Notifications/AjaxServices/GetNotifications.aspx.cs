using System;
using System.Collections.Generic;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Common;

public partial class Notifications_AjaxServices_NotificationService : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 100;

  protected void Page_Load(object sender, EventArgs e)
  {
    Logger.LogInfo("Getting list of Notifications");
    int pageSize = Convert.ToInt32(Request.Params["pageSize"]);
    int currentPage = Convert.ToInt32(Request.Params["currentPage"]);

    using (new HighResolutionTimer("NotificationService", 10000))
    {
      try
      {
        MTList<SQLRecord> listOfNotificationEvents = new MTList<SQLRecord>();

        listOfNotificationEvents.SortCriteria.Add(new SortCriteria("dt_crt", SortType.Descending));
        listOfNotificationEvents.PageSize = (pageSize == 0) ? MAX_RECORDS_PER_BATCH : pageSize;
        listOfNotificationEvents.CurrentPage = (currentPage == 0) ? 1 : currentPage;
        
        NotificationService.GetNotificationEvents(ref listOfNotificationEvents, UI.User.AccountId);

        if (listOfNotificationEvents.Items.Count == 0)
        {
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }

        string json = VisualizeService.SerializeItems(listOfNotificationEvents);
        Logger.LogInfo("Returning " + json);
        Response.Write(json);
        Response.End();
      }
      catch (ThreadAbortException ex)
      {
        //Looks like Response.End is deprecated/changed
        //Might have a lot of unhandled exceptions in product from when we call response.end
        //http://support.microsoft.com/kb/312629
        //Logger.LogError("Thread Abort Exception: {0} {1}", ex.Message, ex.ToString());
        Logger.LogInfo("Handled Exception from Response.Write() {0} ", ex.Message);
      }
      catch (Exception ex)
      {
        Logger.LogError("Exception: {0} {1}", ex.Message, ex.ToString());
        Response.Write("{\"Items\":[]}");
        Response.End();
      }
    }
  }
}

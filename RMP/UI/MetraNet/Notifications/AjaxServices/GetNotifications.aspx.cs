using System;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Common;

public partial class Notifications_AjaxServices_NotificationService : MTListServicePage
{
  private string PrependTotalRowsToJson(int totalRows, String json)
  {
    if (String.IsNullOrEmpty(json))
      return json;

    return json.Replace("{\"Items\":", "{\"TotalRows\":" + totalRows + ",\"Items\":");
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    Logger.LogInfo("Getting list of Notifications");

    using (new HighResolutionTimer("NotificationService", 10000))
    {
      try
      {
        MTList<SQLRecord> listOfNotificationEvents = new MTList<SQLRecord>();

        SetFilters(listOfNotificationEvents);
        SetSorting(listOfNotificationEvents);
        SetPaging(listOfNotificationEvents);

        NotificationService.GetNotificationEvents(ref listOfNotificationEvents, UI.User.AccountId, UI.SessionContext.LanguageID);
        if (listOfNotificationEvents.Items.Count == 0)
        {
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }

        string json = VisualizeService.SerializeItems(listOfNotificationEvents);
        json = PrependTotalRowsToJson(listOfNotificationEvents.TotalRows, json);

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

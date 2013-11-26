using System;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Notifications;
using MetraTech.UI.Common;

public partial class Notifications_AjaxServices_GetNotificationEndpoints : MTListServicePage
{
  //private const int MAX_RECORDS_PER_BATCH = 50;

  //protected bool ExtractData(ApprovalManagementServiceClient client, ref MTList<ChangeHistoryItem> items)
  //{
  //  if (Page.Request["mode"] == "csv")
  //  {
  //    Response.BufferOutput = false;
  //    Response.ContentType = "application/csv";
  //    Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
  //  }

  //  //if there are more records to process than we can process at once, we need to break up into multiple batches
  //  if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
  //  {
  //    int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

  //    int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
  //    for (int batchID = 0; batchID < numBatches; batchID++)
  //    {
  //      ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

  //      string strCSV = ConvertObjectToCSV(items, (batchID == 0));
  //      Response.Write(strCSV);
  //    }
  //  }
  //  else
  //  {
  //    ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize);
  //    if (Page.Request["mode"] == "csv")
  //    {
  //      string strCSV = ConvertObjectToCSV(items, true);
  //      Response.Write(strCSV);
  //    }
  //  }

  //  return true;
  //}

  //protected bool ExtractDataInternal(ApprovalManagementServiceClient client, ref MTList<ChangeHistoryItem> items, int batchID, int limit)
  //{
  //  try
  //  {
  //    items.Items.Clear();

  //    items.PageSize = limit;
  //    items.CurrentPage = batchID;

  //    int changeId = (int)Session["intSessionChangeID"];

  //      client.GetChangeHistory(changeId, ref items);
  //  }
  //  catch (FaultException<MASBasicFaultDetail> ex)
  //  {
  //    Response.StatusCode = 500;
  //    Logger.LogError(ex.Detail.ErrorMessages[0]);
  //    Response.End();
  //    return false;
  //  }
  //  catch (CommunicationException ex)
  //  {
  //    Response.StatusCode = 500;
  //    Logger.LogError(ex.Message);
  //    Response.End();
  //    return false;
  //  }
  //  catch (Exception ex)
  //  {
  //    Response.StatusCode = 500;
  //    Logger.LogError(ex.Message);
  //    Response.End();
  //    return false;
  //  }

  //  return true;
  //}

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new HighResolutionTimer("GetNotificationEndpoints", 5000))
    {
      try
      {
        MTList<NotificationEndpoint> items = new MTList<NotificationEndpoint>();

        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        using (var db = new MetraNetContext())
        {
          string sortExpression = "";
          if (items.SortCriteria.Count == 1)
          {
            sortExpression = items.SortCriteria[0].SortProperty;
            if (items.SortCriteria[0].SortDirection == SortType.Descending)
            {
              sortExpression += " desc";
            }
          }
          else
          {
            //Set default until we can dynamically build it
            sortExpression = "EntityId";
          }

          var allEndpoints = db.NotificationEndpoints.OrderBy(sortExpression).Skip((items.CurrentPage-1) * items.PageSize).Take(items.PageSize);

          foreach (var notificationEndpoint in allEndpoints)
          {
            items.Items.Add(notificationEndpoint);
          }

          items.TotalRows = db.NotificationEndpoints.Count();

        }

        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          HttpContext.Current.ApplicationInstance.CompleteRequest();
          return;
        }

        if (Page.Request["mode"] != "csv")
        {
          //convert paymentMethods into JSON
          JavaScriptSerializer jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);
          json = FixJsonDate(json);
          Response.Write(json);
        }

      }
      catch (Exception ex)
      {
        Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
        throw;
      }
      finally
      {
        Response.End();
      }
    }
  }
    
}
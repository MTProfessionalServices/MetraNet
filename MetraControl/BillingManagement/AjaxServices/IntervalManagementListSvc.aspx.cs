using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Diagnostics;
using System.Resources;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using System.Threading;

public partial class MetraControl_BillingManagement_AjaxServices_IntervalManagementListSvc : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  private Logger logger = new Logger("[BillingManagement]");

  protected bool ExtractDataInternal(IntervalManagementServiceClient client, string statusFilterValue,
                                     ref MTList<Interval> items,
                                     int batchID, int limit)
  {
    try
    {
      items.Items.Clear();
      items.PageSize = limit;
      items.CurrentPage = batchID;

      if (statusFilterValue != null)
      {
        switch (statusFilterValue)
        {
          case "Active":
            if (PartitionLibrary.PartitionData.isPartitionUser)
            {
              client.GetActiveIntervalsForPartition(ref items, PartitionLibrary.PartitionData.PartitionId);
            }
            else
            {
              client.GetActiveIntervals(ref items);
            }
            break;
          case "Billable":
            if (PartitionLibrary.PartitionData.isPartitionUser)
            {
              client.GetBillableIntervalsForPartition(ref items, PartitionLibrary.PartitionData.PartitionId);
            }
            else
            {
              client.GetBillableIntervals(ref items);
            }
            break;
          case "Completed":
            if (PartitionLibrary.PartitionData.isPartitionUser)
            {
              client.GetCompletedIntervalsForPartition(ref items, PartitionLibrary.PartitionData.PartitionId);
            }
            else
            {
              client.GetCompletedIntervals(ref items);
            }
            break;
          default:
            if (PartitionLibrary.PartitionData.isPartitionUser)
            {
              client.GetIntervalsForPartition(ref items, PartitionLibrary.PartitionData.PartitionId);
            }
            else
            {
              client.GetIntervals(ref items);
            }
            break;
        }
      }
      else
      {
        if (PartitionLibrary.PartitionData.isPartitionUser)
        {
          client.GetIntervalsForPartition(ref items, PartitionLibrary.PartitionData.PartitionId);
        }
        else
        {
          client.GetIntervals(ref items);
        }
      }
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500; // right status code?
      logger.LogException("An error occurred while retrieving interval data.  Please check system logs.", ex);
      return false;
    }

    return true;
  }

  protected bool ExtractData(IntervalManagementServiceClient client, string statusFilterValue, ref MTList<Interval> items)
  {
    if (Page.Request["mode"] == "csv")
    {
      Response.BufferOutput = false;
      Response.ContentType = "application/csv";
      Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
      Response.BinaryWrite(BOM);
    }

    //if there are more records to process than we can process at once, we need to break up into multiple batches
    if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
    {
      int advancePage = (items.PageSize%MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize/MAX_RECORDS_PER_BATCH);
      for (int batchID = 0; batchID < numBatches; batchID++)
      {
        if (!ExtractDataInternal(client, statusFilterValue, ref items, batchID + 1, MAX_RECORDS_PER_BATCH))
        {
          //unable to extract data
          return false;
        }

        string strCSV = ConvertObjectToCSV(items, (batchID == 0));
        Response.Write(strCSV);
      }
    }
    else
    {
      if (!ExtractDataInternal(client, statusFilterValue, ref items, items.CurrentPage, items.PageSize))
      {
        //unable to extract data
        return false;
      }

      if (Page.Request["mode"] == "csv")
      {
        string strCSV = ConvertObjectToCSV(items, true);
        Response.Write(strCSV);
      }
    }

    return true;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new HighResolutionTimer("BillingManagementSvcAjax", 5000))
    {
      IntervalManagementServiceClient client = null;

      try
      {
        // Set up client.
        client = new IntervalManagementServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

		string statusFilterValue = Request["Intervals"];
		
        MTList<Interval> items = new MTList<Interval>();

        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        if (ExtractData(client, statusFilterValue, ref items))
        {
          if (items.Items.Count == 0)
          {
            Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
            HttpContext.Current.ApplicationInstance.CompleteRequest();
          }
          else if (Page.Request["mode"] != "csv")
          {
            JavaScriptSerializer jss = new JavaScriptSerializer();
            string json = jss.Serialize(items);
			
			// Fix Dates in json before sending to Response
            var me = new MatchEvaluator(MTListServicePage.MatchDate);
            json = Regex.Replace(json, "\\\\/\\Date[(](-?\\d+)[)]\\\\/", me, RegexOptions.None);
            Response.Write(json);
          }
        }

        // Clean up client.
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        logger.LogException("An error occurred while retrieving interval data.  Please check system logs.", ex);
        throw;
      }
      finally
      {
        Response.End();
        if (client != null)
        {
          client.Abort();
        }
      }
    } // using

  } // Page_Load
}
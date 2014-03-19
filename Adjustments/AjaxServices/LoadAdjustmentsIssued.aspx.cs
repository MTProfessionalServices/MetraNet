using System;
using System.Web;
using System.ServiceModel;
using MetraTech;
using MetraTech.UI.Common;
using System.Web.Script.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;

public partial class Adjustments_AjaxServices_LoadAdjustmentsIssued : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

 protected bool ExtractDataInternal(CreditNoteServiceClient client, ref MTList<AdjustmentDetail> items, int timeInterval, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;

     client.GetAdjustmentsToIncludeInCreditNotes(ref items, UI.Subscriber.SelectedAccount._AccountID.Value, MetraTime.Now.Date.AddDays(timeInterval), MetraTime.Now.Date);
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Detail.ErrorMessages[0]);
      Response.End();
      return false;
    }
    catch (CommunicationException ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }

    return true;
  }

 protected bool ExtractData(CreditNoteServiceClient client, ref MTList<AdjustmentDetail> items, int timeInterval)
  {
    if (Page.Request["mode"] == "csv")
    {
      Response.BufferOutput = false;
      Response.ContentType = "application/csv";
      Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
    }

    //if there are more records to process than we can process at once, we need to break up into multiple batches
    if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
    {
      int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
      for (int batchID = 0; batchID < numBatches; batchID++)
      {
        ExtractDataInternal(client, ref items, timeInterval, batchID + 1, MAX_RECORDS_PER_BATCH);

        string strCSV = ConvertObjectToCSV(items, (batchID == 0));
        Response.Write(strCSV);
      }
    }
    else
    {
      ExtractDataInternal(client, ref items, timeInterval, items.CurrentPage, items.PageSize);
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
   using (new HighResolutionTimer("LoadAdjustmentsIssued", 5000))
    {
      CreditNoteServiceClient client = null;
      try
      {
        client = new CreditNoteServiceClient();

        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        var items = new MTList<AdjustmentDetail>();

        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        // The default value for time interval is 30 days
        int timeInterval = -30;
        string selectedInterval = Page.Request["timeInterval"];
        if (selectedInterval != null)
        {
          timeInterval = -1 * Convert.ToInt32(selectedInterval.Substring(0, selectedInterval.IndexOf(" ")));
        }
        
        //unable to extract data
        if (!ExtractData(client, ref items, timeInterval))
        {
          return;
        }

        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          HttpContext.Current.ApplicationInstance.CompleteRequest();
          return;
        }

        if (Page.Request["mode"] != "csv")
        {
          //convert adjustments into JSON
          JavaScriptSerializer jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);
          json = FixJsonDate(json);
          json = FixJsonBigInt(json);
          Response.Write(json);
        }

        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
        Response.End();
      }
    }
  }
}
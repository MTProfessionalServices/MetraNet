using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.Domain.Quoting;
using MetraTech.UI.Common;

namespace MetraNet.AjaxServices
{
  public partial class Adjustments_AjaxServices_LoadQuotesList : MTListServicePage
  {
    private const int MaxRecordsPerBatch = 50;

    protected bool ExtractDataInternal(ref MTList<Quote> items, int batchID, int limit)
    {
      try
      {
        using (var client = new QuotingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          items.Items.Clear();

          items.PageSize = limit;
          items.CurrentPage = batchID;

          client.GetQuotes(ref items);
        }
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

    protected bool ExtractData(ref MTList<Quote> items)
    {
      if (Page.Request["mode"] == "csv")
      {
        Response.BufferOutput = false;
        Response.ContentType = "application/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
      }

      //if there are more records to process than we can process at once, we need to break up into multiple batches
      if ((items.PageSize > MaxRecordsPerBatch) && (Page.Request["mode"] == "csv"))
      {
        int advancePage = (items.PageSize % MaxRecordsPerBatch != 0) ? 1 : 0;

        int numBatches = advancePage + (items.PageSize / MaxRecordsPerBatch);
        for (int batchID = 0; batchID < numBatches; batchID++)
        {
          ExtractDataInternal(ref items, batchID + 1, MaxRecordsPerBatch);

          string strCSV = ConvertObjectToCSV(items, (batchID == 0));
          Response.Write(strCSV);
        }
      }
      else
      {
        ExtractDataInternal(ref items, items.CurrentPage, items.PageSize);
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
      using (new HighResolutionTimer("LoadQuoteList", 5000))
      {
        try
        {  
            var items = new MTList<Quote>();

            SetPaging(items);
            SetSorting(items);
            SetFilters(items);

            //unable to extract data
            if (!ExtractData(ref items))
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
              var jss = new JavaScriptSerializer();
              string json = jss.Serialize(items);
              json = FixJsonDate(json);
              json = FixJsonBigInt(json);
              Response.Write(json);
            }
        }
        catch
          (Exception ex)
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
}
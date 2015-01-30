using System;
using System.ServiceModel;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

namespace MetraNet.AjaxServices
{
  public partial class LoadPosForQuote : MTListServicePage
  {
    private const int MaxRecordsPerBatch = 50;

    protected void Page_Load(object sender, EventArgs e)
    {
      using (new HighResolutionTimer("LoadPosForQuote", 5000))
      {
        try
        {
          var items = new MTList<ProductOffering>();

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
            var jss = new JavaScriptSerializer();
            string json = SerialiseItemsToJason(items);
            //string json = jss.Serialize(items);
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

    protected bool ExtractData(ref MTList<ProductOffering> items)
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

    protected bool ExtractDataInternal(ref MTList<ProductOffering> items, int batchID, int limit)
    {
      items.Items.Clear();
      items.PageSize = limit;
      items.CurrentPage = batchID;
      try
      {
        GetPos(ref items);
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Response.StatusCode = 500;
        Logger.LogError(ex.Detail.ErrorMessages[0]);
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

    private void GetPos(ref MTList<ProductOffering> items)
    {
      var client = GetClientPos();
      client.InOut_productOfferings = items;
      client.Invoke();
      items = client.InOut_productOfferings;
    }

    private ProductOfferingService_GetProductOfferings_Client GetClientPos()
    {
      return new ProductOfferingService_GetProductOfferings_Client
        {
          UserName = UI.User.UserName,
          Password = UI.User.SessionPassword,
        };
    }

    //for BME entity
    private string SerialiseItemsToJason(MTList<ProductOffering> items)
    {
      var json = new StringBuilder();
      var jss = new JavaScriptSerializer();

      json.Append("{\"TotalRows\":");
      // ReSharper disable SpecifyACultureInStringConversionExplicitly
      json.Append(items.TotalRows.ToString());
      json.Append(", \"Items\":[");

      int j = 0;
      foreach (var item in items.Items)
      {
        if (!(j == 0 || j == items.Items.Count))
        {
          json.Append(",");
        }

        json.Append("{");

        json.Append("\"POPartitionId\":");
        json.Append("\"");
        json.Append(item.POPartitionId);
        json.Append("\",");

        json.Append("\"ProductOfferingId\":");
        json.Append("\"");
        json.Append(item.ProductOfferingId);
        json.Append("\",");

        json.Append("\"Name\":");
        json.Append("\"");
        json.Append(item.DisplayName.EncodeForJavaScript());
        json.Append("\",");

        json.Append("\"Description\":");
        json.Append("\"");
        json.Append(item.Description.EncodeForJavaScript());
        json.Append("\",");

        //json.Append("\"InternalInformationURL\":");
        //json.Append("\"");
        //json.Append(item.InternalInformationURL.EncodeForJavaScript());
        //json.Append("\",");

        //json.Append("\"ExternalInformationURL\":");
        //json.Append("\"");
        //json.Append(item.ExternalInformationURL.EncodeForJavaScript());
        
        json.Append("}");
        j++;
      }

      json.Append("]");
      json.Append(", \"CurrentPage\":");
      json.Append(items.CurrentPage.ToString());
      json.Append(", \"PageSize\":");
      json.Append(items.PageSize.ToString());
      //json.Append(", \"Filters\":");
      //json.Append(jss.Serialize(items.Filters));
      json.Append(", \"SortProperty\":");
      if (items.SortCriteria == null || items.SortCriteria.Count == 0)
      {
        json.Append("null");
        json.Append(", \"SortDirection\":\"");
        json.Append(SortType.Ascending.ToString());
      }
      else
      {
        json.Append("\"");
        json.Append(items.SortCriteria[0].SortProperty);
        json.Append("\"");
        json.Append(", \"SortDirection\":\"");
        json.Append(items.SortCriteria[0].SortDirection.ToString());

      }
      json.Append("\"}");
      return json.ToString();
    }
  }
}
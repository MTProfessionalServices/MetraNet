using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using System.ServiceModel;
using System.Web.Script.Serialization;
using MetraTech.Debug.Diagnostics;
using MetraTech;
using Core.UI;

public partial class AjaxServices_MyReportsSvc : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  protected bool ExtractDataInternal(RepositoryService_LoadInstances_Client client, ref MTList<DataObject> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;
      client.InOut_dataObjects = items;

      client.Invoke();
      items = client.InOut_dataObjects;
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

  protected bool ExtractData(RepositoryService_LoadInstances_Client client, ref MTList<DataObject> items)
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
      int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
      for (int batchID = 0; batchID < numBatches; batchID++)
      {
        ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

        string strCSV = ConvertObjectToCSV(items, (batchID == 0));
        Response.Write(strCSV);
      }
    }
    else
    {
      ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize);
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
    using (new HighResolutionTimer("MyReportsService", 5000))
    {
      RepositoryService_LoadInstances_Client client = null;

      try
      {
        client = new RepositoryService_LoadInstances_Client();

        client.UserName = UI.User.UserName;
        client.Password = UI.User.SessionPassword;
        client.In_entityName = typeof(SavedSearch).FullName;
        MTList<DataObject> items = new MTList<DataObject>();

        items.Filters.Add(new MTFilterElement("CreatedBy", MTFilterElement.OperationType.Equal, UI.SessionContext.AccountID));
        items.SortCriteria.Add(new SortCriteria("CreatedDate", SortType.Descending));

        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        //unable to extract data
        if (!ExtractData(client, ref items))
        {
          return;
        }

        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          Response.End();
          return;
        }

        if (Page.Request["mode"] != "csv")
        {
          //convert paymentMethods into JSON
          JavaScriptSerializer jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);

          Response.Write(json);
        }    
      }
      catch (Exception ex)
      {
        Response.Write("Error processing request");
        Logger.LogException("Error processing request", ex);
      }
      Response.End();
    }
  }
}

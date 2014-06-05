using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.ProductView;
using MetraTech.UI.Common;

public partial class Adjustments_AjaxServices_LoadMiscAsjustments : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  //esr-4446 using Metratech_com_AccountCreditProductView instead of MiscellaneousAdjustment
  protected bool ExtractDataInternal(AdjustmentsServiceClient client, ref MTList<Metratech_com_AccountCreditProductView> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;

      // test data
      /*var a = new Metratech_com_AccountCreditProductView()
      {
        Amount = 123.45M,
        InvoiceNumber = "7483",
        Comment = "Hello World",
        Id = Guid.NewGuid()
      };
      items.Items.Add(a);
       */
      // end test data

      client.GetAccountCredits(ref items, true);
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

  protected bool ExtractData(AdjustmentsServiceClient client, ref MTList<Metratech_com_AccountCreditProductView> items)
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
    using (new HighResolutionTimer("LoadMiscellaneousAdjustments", 5000))
    {
      AdjustmentsServiceClient client = null;

      try
      {
        client = new AdjustmentsServiceClient();

        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        var items = new MTList<Metratech_com_AccountCreditProductView>();

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
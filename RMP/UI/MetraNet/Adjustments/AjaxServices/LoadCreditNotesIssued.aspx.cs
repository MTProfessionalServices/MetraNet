using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.ProductView;
using MetraTech.UI.Common;

public partial class Adjustments_AjaxServices_LoadCreditNotesIssued : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  protected bool ExtractDataInternal(CreditNoteServiceClient client, string accountsFilterValue, ref MTList<CreditNoteDetail> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;

      if (accountsFilterValue == "ALL")
      {
        client.GetIssuedCreditNotes(ref items, null, UI.SessionContext.LanguageID);
      }
      else
      {
        client.GetIssuedCreditNotes(ref items, UI.Subscriber.SelectedAccount._AccountID, UI.SessionContext.LanguageID);
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

  protected bool ExtractData(CreditNoteServiceClient client, string accountsFilterValue, ref MTList<CreditNoteDetail> items)
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
        ExtractDataInternal(client, accountsFilterValue, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

        string strCSV = ConvertObjectToCSV(items, (batchID == 0));
        Response.Write(strCSV);
      }
    }
    else
    {
      ExtractDataInternal(client, accountsFilterValue,ref items, items.CurrentPage, items.PageSize);
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
    using (new HighResolutionTimer("LoadCreditNotesIssued", 5000))
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

        var items = new MTList<CreditNoteDetail>();

        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        string accountsFilterValue = Request["Accounts"];

        //unable to extract data
        if (!ExtractData(client, accountsFilterValue, ref items))
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
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;

using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using System.Threading;
using MetraTech.DomainModel.BaseTypes;


public partial class ApprovalFrameworkManagement_AjaxServices_GetChangesSummary : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  protected bool ExtractData(ApprovalManagementServiceClient client, ref MTList<ChangeSummary> items)
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

  protected bool ExtractDataInternal(ApprovalManagementServiceClient client, ref MTList<ChangeSummary> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;

      string changestate = (string)Session["strChangeState"];

      if (changestate == "PENDING")
      {
          items.Filters.Add(new MTFilterElement("CurrentState", MTFilterElement.OperationType.Equal, ChangeState.Pending.ToString()));

          //client.GetPendingChangesSummary(ref items);
          client.GetChangesSummary(ref items);
      }
      else
      {
          if (changestate == "FAILED")
          {
              items.Filters.Add(new MTFilterElement("CurrentState", MTFilterElement.OperationType.Equal, ChangeState.FailedToApply.ToString()));
              //client.GetFailedChangesSummary(ref items);
             client.GetChangesSummary(ref items); 
          }
          else
          {
              client.GetChangesSummary(ref items);
          }
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

  protected void Page_Load(object sender, EventArgs e)
  {
      using (new HighResolutionTimer("GetChangesSummaryAjax", 5000))
    {
        ApprovalManagementServiceClient client = null;

      try
      {
          client = new ApprovalManagementServiceClient(); 
        

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        MTList<ChangeSummary> items = new MTList<ChangeSummary>();

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
          //convert paymentMethods into JSON
          JavaScriptSerializer jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);
          json = FixJsonDate(json);
          Response.Write(json);
        }

        client.Close();
      }
      catch (Exception ex)
      {
        Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
        client.Abort();
        throw;
      }
      finally
      {
        Response.End();
      }
    }
  }
    
}
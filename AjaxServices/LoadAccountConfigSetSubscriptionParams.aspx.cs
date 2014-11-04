using System;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Web;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.Domain.AccountConfigurationSets;
using System.Web.Script.Serialization;

namespace MetraNet.AjaxServices
{
  public partial class LoadAccountConfigSetSubscriptionParams : MTListServicePage
  {
    private const int MaxRecordsPerBatch = 50;

    protected void Page_Load(object sender, EventArgs e)
    {
      using (new HighResolutionTimer("LoadAccountConfigSetList", 5000))
      {
        try
        {
          var items = new MTList<AccountConfigSetParameters>();

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
            var json = jss.Serialize(items);
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

    protected bool ExtractData(ref MTList<AccountConfigSetParameters> items)
    {
      if (Page.Request["mode"] == "csv")
      {
        Response.BufferOutput = false;
        Response.ContentType = "application/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
        Response.BinaryWrite(BOM);
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

    protected bool ExtractDataInternal(ref MTList<AccountConfigSetParameters> items, int batchID, int limit)
    {
      items.Items.Clear();
      items.PageSize = limit;
      items.CurrentPage = batchID;
      try
      {
        GetAccountConfigSetParameters(ref items);
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

    private void GetAccountConfigSetParameters(ref MTList<AccountConfigSetParameters> items)
    {
      var client = GetClientAccountConfigSetParameters();
      client.InOut_acsList = items;
      client.Invoke();
      items = client.InOut_acsList;
    }

    private AccountConfigurationSetService_GetAccountConfigSetSubscriptionParamsList_Client GetClientAccountConfigSetParameters()
    {
      return new AccountConfigurationSetService_GetAccountConfigSetSubscriptionParamsList_Client
        {
          UserName = UI.User.UserName,
          Password = UI.User.SessionPassword
        };
    }

  }
}
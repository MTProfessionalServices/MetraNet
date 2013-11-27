using System;
using System.Web;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;

public partial class AjaxServices_FindPaymentTransactions : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    protected bool ExtractDataInternal(CleanupTransactionServiceClient client, ref MTList<PaymentTransaction> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();

            items.PageSize = limit;
            items.CurrentPage = batchID;

            client.GetPaymentTransactions(ref items);
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

    protected bool ExtractData(CleanupTransactionServiceClient client, ref MTList<PaymentTransaction> items)
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

    protected void Page_Load(object sender, EventArgs e)
    {
        using (new HighResolutionTimer("PaymentTransactions", 5000))
        {
          CleanupTransactionServiceClient client = null;

            try
            {
              client = new CleanupTransactionServiceClient();

              client.ClientCredentials.UserName.UserName = UI.User.UserName;
              client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
              MTList<PaymentTransaction> items = new MTList<PaymentTransaction>();

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

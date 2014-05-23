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
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;

public partial class AjaxServices_FindCCSvc : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;


    protected bool ExtractDataInternal(RecurringPaymentsServiceClient client, ref MTList<MetraPaymentMethod> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();

            items.PageSize = limit;
            items.CurrentPage = batchID;

            AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);

            client.GetPaymentMethodSummaries(acct, ref items);
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

    protected bool ExtractData(RecurringPaymentsServiceClient client, ref MTList<MetraPaymentMethod> items)
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
        using (new HighResolutionTimer("FindCCSvcAjax", 5000))
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient();

                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
                MTList<MetraPaymentMethod> items = new MTList<MetraPaymentMethod>();

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

                Response.End();
            }
            finally
            {
                if (client != null)
                {
                    if (client.State == CommunicationState.Opened)
                    {
                        client.Close();
                    }
                    else
                    {
                        client.Abort();
                    }
                }
            }
        }
    }
}

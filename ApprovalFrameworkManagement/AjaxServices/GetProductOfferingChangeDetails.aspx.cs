using System;
using System.Reflection;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using System.Collections.Generic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.DomainModel.Common;

public partial class ApprovalFrameworkManagement_AjaxServices_GetProductOfferingChangeDetails : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    protected bool ExtractData(ApprovalManagementServiceClient client, ProductOfferingServiceClient poClient, ref MTList<ChangeDetailsDisplay> items)
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
                ExtractDataInternal(client, poClient, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

                string strCSV = ConvertObjectToCSV(items, (batchID == 0));
                Response.Write(strCSV);
            }
        }
        else
        {
            ExtractDataInternal(client, poClient, ref items, items.CurrentPage, items.PageSize);
            if (Page.Request["mode"] == "csv")
            {
                string strCSV = ConvertObjectToCSV(items, true);
                Response.Write(strCSV);
            }
        }

        return true;
    }

    protected bool ExtractDataInternal(ApprovalManagementServiceClient client, ProductOfferingServiceClient poClient, ref MTList<ChangeDetailsDisplay> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();

            items.PageSize = limit;
            items.CurrentPage = batchID;

            int changeId = (int)Session["intchangeid"];

            string pochangedetailsblob = String.Empty;
            client.GetChangeDetails(changeId, ref pochangedetailsblob);

            ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
            changeDetailsIn.KnownTypes.Add(typeof(MetraTech.DomainModel.ProductCatalog.ProductOffering));
            changeDetailsIn.FromXml(pochangedetailsblob);

            // Once you get the change details blob, you can now parse it for the property name and updated value, Key-Value Pair. 
            object o = changeDetailsIn["productOffering"];
            MetraTech.DomainModel.ProductCatalog.ProductOffering newPO = o as MetraTech.DomainModel.ProductCatalog.ProductOffering;
            
            if (null == newPO)
            {
                Logger.LogError("Got Invalid Product Offering Type");
                throw new NullReferenceException("Got Null Product Offering from ChangeDetails");
            }

            MetraTech.DomainModel.ProductCatalog.ProductOffering oldPO = null;
            if (!changeDetailsIn.ContainsKey("productOffering.OLD"))
            {
                MetraTech.ActivityServices.Common.PCIdentifier poID = new MetraTech.ActivityServices.Common.PCIdentifier((int)newPO.ProductOfferingId.Value);
                poClient.GetProductOffering(poID, out oldPO);
                oldPO.PriceableItems = null;
            }
            else
            {
                o = changeDetailsIn["productOffering.OLD"];
                oldPO = o as MetraTech.DomainModel.ProductCatalog.ProductOffering;
            }

            foreach (var change in MetraTech.Approvals.DiffManager.Diff(oldPO, newPO, true))
            {
                items.Items.Add(new ChangeDetailsDisplay() { PropertyName = change.Name, OldValue = (change.Before==null)?string.Empty:change.Before.ToString(), UpdatedValue = (change.After==null)?string.Empty:change.After.ToString() });
            }
        }
        catch (FaultException<MASBasicFaultDetail> ex)
        {
            Response.StatusCode = 500;
            Logger.LogError(ex.Detail.ErrorMessages[0]);
            Logger.LogException("Error", ex);
            Response.End();
            return false;
        }
        catch (CommunicationException ex)
        {
            Response.StatusCode = 500;
            Logger.LogError(ex.Message);
            Logger.LogException("Error", ex);
            Response.End();
            return false;
        }
        catch (Exception ex)
        {
            Response.StatusCode = 500;
            Logger.LogError(ex.Message);
            Logger.LogException("Error", ex);
            Response.End();
            return false;
        }

        return true;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        using (new HighResolutionTimer("GetProductOfferingChangeDetailsAjax", 5000))
        {
            ApprovalManagementServiceClient client = null;
            ProductOfferingServiceClient poClient = null;

            try
            {
                client = new ApprovalManagementServiceClient();
                poClient = new ProductOfferingServiceClient();

                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
                poClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                poClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

                MTList<ChangeDetailsDisplay> items = new MTList<ChangeDetailsDisplay>();

                SetPaging(items);
                SetSorting(items);
                SetFilters(items);

                //unable to extract data
                if (!ExtractData(client, poClient, ref items))
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
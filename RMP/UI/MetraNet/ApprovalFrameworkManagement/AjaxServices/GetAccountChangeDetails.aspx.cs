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

public partial class ApprovalFrameworkManagement_AjaxServices_GetAccountChangeDetails : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    protected bool ExtractData(ApprovalManagementServiceClient client, ref MTList<ChangeDetailsDisplay> items)
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

    protected bool ExtractDataInternal(ApprovalManagementServiceClient client, ref MTList<ChangeDetailsDisplay> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();

            items.PageSize = limit;
            items.CurrentPage = batchID;

            int changeId = (int)Session["intchangeid"];

            string accountchangedetailsblob = String.Empty;
            client.GetChangeDetails(changeId, ref accountchangedetailsblob);

            ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
            changeDetailsIn.FromBuffer(accountchangedetailsblob);

            // Once you get the change details blob, you can now parse it for the property name and updated value, Key-Value Pair. 
            object o = changeDetailsIn["Account"];
            MetraTech.DomainModel.BaseTypes.Account newAccount = o as MetraTech.DomainModel.BaseTypes.Account;

            if (null == newAccount)
            {
                Logger.LogError("Got Invalid Account Type");
                throw new NullReferenceException("Got Null Account from ChangeDetails");
            }

            // Load the "actual" Account object from the database using the accountId.
            Account staleAccount = AccountLib.LoadAccount((int)newAccount._AccountID, UI.User, ApplicationTime);

            if (staleAccount.PayerID != newAccount.PayerID)
 	          {
 	            ChangeDetailsDisplay changeDetailsDisplay = new ChangeDetailsDisplay();
 	            changeDetailsDisplay.PropertyName = "PayerID";
 	            changeDetailsDisplay.OldValue = staleAccount.PayerID.ToString();
 	            changeDetailsDisplay.UpdatedValue = newAccount.PayerID.ToString();
 	            items.Items.Add(changeDetailsDisplay);
 	          }
            if (staleAccount.AncestorAccountID != newAccount.AncestorAccountID)
            {
              ChangeDetailsDisplay changeDetailsDisplay = new ChangeDetailsDisplay();
              changeDetailsDisplay.PropertyName = "AncestorAccountID";
              changeDetailsDisplay.OldValue = staleAccount.AncestorAccountID.ToString();
              changeDetailsDisplay.UpdatedValue = newAccount.AncestorAccountID.ToString();
              items.Items.Add(changeDetailsDisplay);
            }

            // Creating a dictionary here with stale account property --> value as the key --> value pairs
            Dictionary<string, object> staleAccountViewKeyValues = new Dictionary<string, object>();
            Dictionary<string, List<View>> staleAccountViews = staleAccount.GetViews();
            Logger.LogDebug("Found views: " + staleAccountViews.Count);
            foreach (KeyValuePair<string, List<View>> staleAccountView in staleAccountViews)
            {
                Logger.LogDebug("Found view key: " + staleAccountView.Key);
                foreach (View staleAccntView in staleAccountView.Value)
                {
                    Logger.LogDebug("Found view: " + staleAccntView.ViewName);
                    FieldInfo[] fieldInfos = staleAccntView.GetType().GetFields(BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);

                    foreach (FieldInfo fieldInfo in fieldInfos)
                    {
                        string fieldKey;
                        if (typeof(ContactView).Equals(staleAccntView.GetType()))
                        {
                            fieldKey = string.Format("{0}[{2}]/{1}", staleAccountView.Key, fieldInfo.Name, staleAccntView.GetValue("ContactType"));
                        }
                        else
                        {
                            fieldKey = string.Format("{0}/{1}", staleAccountView.Key, fieldInfo.Name);
                        }
                        Logger.LogDebug("Found field: " + fieldKey + " value: " + fieldInfo.GetValue(staleAccntView));
                        staleAccountViewKeyValues.Add(fieldKey, fieldInfo.GetValue(staleAccntView));
                    }
                }
            }

            Logger.LogDebug("And now new...");
            // Creating a dictionary here with account blob for the change ID, account property --> value as the key --> value pairs
            Dictionary<string, object> newAccountViewKeyValues = new Dictionary<string, object>();
            Dictionary<string, List<View>> newAccountViews = newAccount.GetViews();
            foreach (KeyValuePair<string, List<View>> newAccountView in newAccountViews)
            {
                Logger.LogDebug("Found view key: " + newAccountView.Key);
                foreach (View newAccntView in newAccountView.Value)
                {
                    Logger.LogDebug("Found view: " + newAccntView.ViewName);
                    FieldInfo[] fieldInfos = newAccntView.GetType().GetFields(BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                    foreach (FieldInfo fieldInfo in fieldInfos)
                    {
                        string fieldKey;
                        if (typeof(ContactView).Equals(newAccntView.GetType()))
                        {
                            fieldKey = string.Format("{0}[{2}]/{1}", newAccountView.Key, fieldInfo.Name, newAccntView.GetValue("ContactType"));
                        }
                        else
                        {
                            fieldKey = string.Format("{0}/{1}", newAccountView.Key, fieldInfo.Name);
                        }
                        Logger.LogDebug("Found field: " + fieldKey + " value: " + fieldInfo.GetValue(newAccntView));
                        newAccountViewKeyValues.Add(fieldKey, fieldInfo.GetValue(newAccntView));
                    }
                }
            }

            // Build a dictionary with the key-value pairs of property-->value 
            // what we will build is a "diff" of the stale account and the 
            // changes we intend to apply
            foreach (string staleAccountPropertyKey in staleAccountViewKeyValues.Keys)
            {
                // NOTE : what happens if someone creates a new property with Dirty in it....
                if (staleAccountPropertyKey.Contains("Dirty"))
                    continue;

                foreach (string newAccountPropertyKey in newAccountViewKeyValues.Keys)
                {
                    if (newAccountPropertyKey.Contains("Dirty"))
                        continue;

                    if ((newAccountPropertyKey.Equals(staleAccountPropertyKey)) &&
                        !(Object.Equals(staleAccountViewKeyValues[staleAccountPropertyKey], newAccountViewKeyValues[newAccountPropertyKey])))
                    {
                        Logger.LogDebug("FOUND A DIFF: " + newAccountPropertyKey);
                        // Skip change values where NULL was replaced with empty string
                        // they are non-changes);
                        if (null == staleAccountViewKeyValues[staleAccountPropertyKey] && String.IsNullOrEmpty(newAccountViewKeyValues[newAccountPropertyKey].ToString()))
                            continue;

                        ChangeDetailsDisplay changeDetailsDisplay = new ChangeDetailsDisplay();
                        changeDetailsDisplay.PropertyName = newAccountPropertyKey;
                        if (null == staleAccountViewKeyValues[staleAccountPropertyKey])
                            changeDetailsDisplay.OldValue = "NULL";
                        else
                            changeDetailsDisplay.OldValue = staleAccountViewKeyValues[staleAccountPropertyKey].ToString();

                        if (null == newAccountViewKeyValues[newAccountPropertyKey])
                            changeDetailsDisplay.UpdatedValue = "NULL";
                        else
                            changeDetailsDisplay.UpdatedValue = newAccountViewKeyValues[newAccountPropertyKey].ToString();

                        items.Items.Add(changeDetailsDisplay);
                    }
                }
            }
            foreach (string newAccountPropertyKey in newAccountViewKeyValues.Keys)
            {
                if (!staleAccountViewKeyValues.ContainsKey(newAccountPropertyKey))
                {
                    if (newAccountPropertyKey.Contains("Dirty"))
                        continue;
                    object value = newAccountViewKeyValues[newAccountPropertyKey];
                    if (value != null)
                    {
                        if (value is string && string.IsNullOrEmpty((string)value)) continue;
                        ChangeDetailsDisplay changeDetailsDisplay = new ChangeDetailsDisplay();
                        changeDetailsDisplay.PropertyName = newAccountPropertyKey;
                        changeDetailsDisplay.OldValue = string.Empty;

                        changeDetailsDisplay.UpdatedValue =
                            newAccountViewKeyValues[newAccountPropertyKey].ToString();

                        items.Items.Add(changeDetailsDisplay);
                    }
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
        using (new HighResolutionTimer("GetAccountChangeDetailsAjax", 5000))
        {
            ApprovalManagementServiceClient client = null;

            try
            {
                Logger.LogDebug("HERE I AM--------------------------------------...");
                client = new ApprovalManagementServiceClient();

                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

                MTList<ChangeDetailsDisplay> items = new MTList<ChangeDetailsDisplay>();

                SetPaging(items);
                SetSorting(items);
                SetFilters(items);

                //unable to extract data
                if (!ExtractData(client, ref items))
                {
                    Logger.LogDebug("FAILED TO EXTRACT...");
                    return;
                }

                if (items.Items.Count == 0)
                {
                    Logger.LogDebug("NOTHING--------------------------------------...");
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
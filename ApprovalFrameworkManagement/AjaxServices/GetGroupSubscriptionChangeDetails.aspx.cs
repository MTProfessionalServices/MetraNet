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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;

public partial class ApprovalFrameworkManagement_AjaxServices_GetGroupSubscriptionChangeDetails : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    protected bool ExtractData(ApprovalManagementServiceClient client, GroupSubscriptionServiceClient gsClient, ref MTList<GroupSubscriptionChangeDetailsDisplay> items)
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
                ExtractDataInternal(client, gsClient, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

                string strCSV = ConvertObjectToCSV(items, (batchID == 0));
                Response.Write(strCSV);
            }
        }
        else
        {
            ExtractDataInternal(client, gsClient, ref items, items.CurrentPage, items.PageSize);
            if (Page.Request["mode"] == "csv")
            {
                string strCSV = ConvertObjectToCSV(items, true);
                Response.Write(strCSV);
            }
        }

        return true;
    }

    protected bool ExtractDataInternal(ApprovalManagementServiceClient client, GroupSubscriptionServiceClient gsClient, ref MTList<GroupSubscriptionChangeDetailsDisplay> items, int batchID, int limit)
    {
      try
      {
        items.Items.Clear();

        items.PageSize = limit;
        items.CurrentPage = batchID;

        int changeId = (int)Session["intchangeid"];

        string gschangedetailsblob = String.Empty;
        client.GetChangeDetails(changeId, ref gschangedetailsblob);

        ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
        changeDetailsIn.FromBuffer(gschangedetailsblob); 

        // Once you get the change details blob, you can now parse it for the property name and updated value, Key-Value Pair. 
        int gsId = -1;
        Object o = null;
        if (changeDetailsIn.ContainsKey("groupSubscriptionId"))
        {
          o = changeDetailsIn["groupSubscriptionId"];
          gsId = (int)o;
        }
        //Now get the specific info for this change   
        ProdCatTimeSpan timeSpan = null;
        if (changeDetailsIn.ContainsKey("subscriptionSpan"))
        {
          o = changeDetailsIn["subscriptionSpan"];
          timeSpan = o as ProdCatTimeSpan;
        }

        if (changeDetailsIn.ContainsKey("accounts"))
        {
          o = changeDetailsIn["accounts"];
          //Account could be a list or a dictionary; try both.
          var accountsAsDictionary = o as Dictionary<AccountIdentifier, MetraTech.DomainModel.ProductCatalog.AccountTemplateScope>;
          var accountsAsList = o as List<GroupSubscriptionMember>;

          if (accountsAsDictionary != null)
          {
            foreach (var account in accountsAsDictionary)
            {
              GroupSubscriptionChangeDetailsDisplay changeDetailsDisplay = new GroupSubscriptionChangeDetailsDisplay();
              GroupSubscription gsub = new GroupSubscription();
              gsClient.GetGroupSubscriptionDetail(gsId, out gsub);

              changeDetailsDisplay.GroupSubName = (gsub.Name == null) ? "" : gsub.Name;
              changeDetailsDisplay.GroupSubId = gsId;
              changeDetailsDisplay.MemberId = (account.Key.AccountID == null) ? -1 : (int)account.Key.AccountID;
              if (timeSpan != null)
              {
                changeDetailsDisplay.StartDate = (timeSpan.StartDate == null) ? " " : timeSpan.StartDate.ToString();
                changeDetailsDisplay.EndDate = (timeSpan.EndDate == null) ? " " : timeSpan.EndDate.ToString();
              }
              changeDetailsDisplay.AccountName = string.IsNullOrEmpty(account.Key.Username) ? string.Empty : account.Key.Username;
              items.Items.Add(changeDetailsDisplay);
            }
          }
          else if (accountsAsList != null)
          {
            foreach (var account in accountsAsList)
            {
              items.Items.Add(HandleGroupSubMember(account, gsId, gsClient));
            }
          }
          else
          {
            Logger.LogError("Got an unknown acount list type: " + o.GetType());
            throw new NullReferenceException("Got Null account list from ChangeDetails");
          } 
        }


        if (changeDetailsIn.ContainsKey("groupSubscriptionMembers"))
        {
          o = changeDetailsIn["groupSubscriptionMembers"];
          List<GroupSubscriptionMember> groupSubList = o as List<GroupSubscriptionMember>;
          foreach (var account in groupSubList)
          {
            items.Items.Add(HandleGroupSubMember(account, gsId, gsClient));
          }
        }
        if (changeDetailsIn.ContainsKey("groupSubscriptionMember"))
        {
          o = changeDetailsIn["groupSubscriptionMember"];
          GroupSubscriptionMember account = o as GroupSubscriptionMember;
          items.Items.Add(HandleGroupSubMember(account, gsId, gsClient));
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

    private GroupSubscriptionChangeDetailsDisplay HandleGroupSubMember(GroupSubscriptionMember account, int gsId, GroupSubscriptionServiceClient gsClient)
    {
      GroupSubscription gsub = new GroupSubscription();
      gsClient.GetGroupSubscriptionDetail(gsId, out gsub);
      GroupSubscriptionChangeDetailsDisplay changeDetailsDisplay = new GroupSubscriptionChangeDetailsDisplay();
      changeDetailsDisplay.GroupSubId = (account.GroupId == null) ? gsId : (int)account.GroupId;
      changeDetailsDisplay.MemberId = (account.AccountId == null) ? -1 : (int)account.AccountId;
      changeDetailsDisplay.GroupSubName = (gsub.Name == null) ? " " : gsub.Name;
      changeDetailsDisplay.AccountName = (account.AccountName == null) ? " " : account.AccountName;
      ProdCatTimeSpan timeSpan = account.MembershipSpan;
      if (timeSpan != null)
      {
        changeDetailsDisplay.StartDate = (timeSpan.StartDate == null) ? " " : timeSpan.StartDate.ToString();
        changeDetailsDisplay.EndDate = (timeSpan.EndDate == null) ? " " : timeSpan.EndDate.ToString();
      }
      changeDetailsDisplay.AccountName = string.IsNullOrEmpty(account.AccountName) ? string.Empty : account.AccountName;
      GroupSubscriptionMember oldMemberInfo = null;
      gsClient.GetMemberInfoForGroupSubscription(changeDetailsDisplay.GroupSubId, changeDetailsDisplay.MemberId, ref oldMemberInfo);
      changeDetailsDisplay.OldStartDate = (oldMemberInfo != null) ? oldMemberInfo.MembershipSpan.StartDate.ToString() : "";
      changeDetailsDisplay.OldEndDate = (oldMemberInfo != null) ? oldMemberInfo.MembershipSpan.EndDate.ToString() : "";
      return changeDetailsDisplay;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        using (new HighResolutionTimer("GetGroupSubscriptionChangeDetailsAjax", 5000))
        {
            ApprovalManagementServiceClient client = null;
            GroupSubscriptionServiceClient gsClient = null;

            try
            {
                client = new ApprovalManagementServiceClient();
                gsClient = new GroupSubscriptionServiceClient();

                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
                gsClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                gsClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

                MTList<GroupSubscriptionChangeDetailsDisplay> items = new MTList<GroupSubscriptionChangeDetailsDisplay>();

                SetPaging(items);
                SetSorting(items);
                SetFilters(items);

                //unable to extract data
                if (!ExtractData(client, gsClient, ref items))
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
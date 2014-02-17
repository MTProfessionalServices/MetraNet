using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ServiceModel;
using System.Text;
using MetraTech;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using MetraTech.Approvals;
using MetraTech.Approvals.ChangeTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using System.Web.Script.Serialization;

public partial class ApprovalFrameworkManagement_AjaxServices_ChangeOperation : MTPage
{
  private string strincomingchangeid;
  private int intincomingchangeid;
  private String strincomingcomment;
  private String strincomingaction;
  private bool UpdatedItemRequested = false;

  protected void SendResult(bool success, string msg, ChangeSummary updatedItem)
  {
    string strResponse = "{success: " + success.ToString().ToLower() + ", message:'" + msg + "'";

    if (updatedItem != null)
    {
      JavaScriptSerializer jss = new JavaScriptSerializer();
      strResponse += ", updatedItem:" + jss.Serialize(updatedItem);
    }

    strResponse += "}";

    Response.Write(strResponse);
    Response.End();
  }

  protected void Page_Load(object sender, EventArgs e)
  {
      strincomingchangeid = Request["changeid"];
      intincomingchangeid = System.Convert.ToInt32(strincomingchangeid);

      strincomingcomment = Request["comment"].ToString();
      strincomingaction = Request["action"].ToString().ToLower();

    if (!string.IsNullOrEmpty(Request["ReturnUpdatedItem"]))
    {
      UpdatedItemRequested = Boolean.Parse(Request["ReturnUpdatedItem"]);
    }

    ChangeSummary updatedItem = null;

    var approvalClient = new ApprovalManagementServiceClient();
    var subscriptionClient = new SubscriptionServiceClient();
    // Now call the operation based on the action 
    try
    {
      SetCredantional(approvalClient.ClientCredentials);
      
      var changeBlob = "";
      approvalClient.GetChangeDetails(intincomingchangeid, ref changeBlob);
      var changeDetails = new ChangeDetailsHelper(changeBlob);
      var newSub = (Subscription)changeDetails[SubscriptionChangeType.SubscriptionKey];
      var subscriber = (AccountIdentifier)changeDetails[SubscriptionChangeType.AccountIdentifierKey];

      var change = CompareWithCurrentSubscription(newSub, subscriber, subscriptionClient);

      changeDetails[SubscriptionChangeType.SubscriptionChangeKey] = change;
      approvalClient.UpdateChangeDetails(intincomingchangeid, changeDetails.ToBuffer(), "SubscriptionChange object was stored");

      if (strincomingaction == "approve")
      {
        approvalClient.ApproveChange(intincomingchangeid, strincomingcomment);
      }

      if (strincomingaction == "deny")
      {
        approvalClient.DenyChange(intincomingchangeid, strincomingcomment);
      }

      if (strincomingaction == "dismiss")
      {
        approvalClient.DismissChange(intincomingchangeid, strincomingcomment);
      }

      if (strincomingaction == "resubmit")
      {
        MTList<int> mychangeid = new MTList<int>();
        mychangeid.Items.Add(intincomingchangeid);

        approvalClient.ResubmitFailedChanges(mychangeid);
      }

      if (UpdatedItemRequested)
      {
        MTList<ChangeSummary> items = new MTList<ChangeSummary>();
        items.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Equal, intincomingchangeid));
        approvalClient.GetChangesSummary(ref items);
        if (items.Items.Count == 1)
        {
          updatedItem = items.Items[0];
        }
        else
        {
          throw new Exception("Change Id " + strincomingchangeid +
                              " was updated but the change could not be retrieved. GetChangeSummary returned " +
                              items.Items.Count + " items");
        }
      }
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Logger.LogException("Change Id " + strincomingchangeid + " failed to " + strincomingaction, ex);
      StringBuilder sb = new StringBuilder();
      foreach (string err in ex.Detail.ErrorMessages)
      {
        sb.Append(err);
        sb.Append("; ");
      }
      //SendResult(false, sb.ToString().Replace("'", "\\'"));
      SendResult(false, sb.ToString().EncodeForJavaScript(), updatedItem);
    }
    catch (Exception ex)
    {
      Logger.LogException("Change Id " + strincomingchangeid + " failed to " + strincomingaction, ex);
      //SendResult(false, ex.Message.Replace("'", "\\'"));
      SendResult(false, ex.Message.EncodeForJavaScript(), updatedItem);
      return;
    }
    finally
    {
      if (approvalClient.State == CommunicationState.Faulted)
        approvalClient.Abort();
      else
        approvalClient.Close();

      if (subscriptionClient.State == CommunicationState.Faulted)
        subscriptionClient.Abort();
      else
        subscriptionClient.Close();
    }

    SendResult(true, "", updatedItem);
  }

  private SubscriptionChange CompareWithCurrentSubscription(Subscription newSubscription, AccountIdentifier accOfNewSub, SubscriptionServiceClient subscriptionClient)
  {
    Subscription currentSub = null;
    List<UDRCInstance> currentUdrcInstances = null;
    List<UDRCInstance> newUdrcInstances = null;

    if (newSubscription.SubscriptionId.HasValue)
    {
      SetCredantional(subscriptionClient.ClientCredentials);
      subscriptionClient.GetSubscriptionDetail(accOfNewSub, newSubscription.SubscriptionId.Value, out currentSub);
      subscriptionClient.GetUDRCInstancesForPO(newSubscription.ProductOfferingId, out newUdrcInstances);

      subscriptionClient.GetUDRCInstancesForPO(currentSub.ProductOfferingId, out currentUdrcInstances);
    }

    return SubscriptionChangeType.GetSubscriptionChange(currentSub, newSubscription, currentUdrcInstances, newUdrcInstances, accOfNewSub.AccountID.Value);
  }

  private void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
  {
    if (clientCredentials == null)
      throw new InvalidOperationException("Client credentials is null");

    clientCredentials.UserName.UserName = UI.User.UserName;
    clientCredentials.UserName.Password = UI.User.SessionPassword;
  }
}

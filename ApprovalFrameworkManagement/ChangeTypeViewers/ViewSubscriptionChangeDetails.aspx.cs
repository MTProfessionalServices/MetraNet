using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Approvals;
using MetraTech.Approvals.ChangeTypes;

public partial class ApprovalFrameworkManagement_ViewSubscriptionChangeDetails : MTPage
{
  public int ChangeId { get; set; }
  public SubscriptionChange SubChange { get; set; }

  #region Event Listeners

  protected void Page_Load(object sender, EventArgs e)
  {
    ChangeId = Convert.ToInt32(Request.QueryString["changeid"]);
    var currState = Request.QueryString["currentstate"];

    var approvalClient = new ApprovalManagementServiceClient();
    
    try
    {
      SetCredantional(approvalClient.ClientCredentials);

      var changeBlob = "";
      approvalClient.GetChangeDetails(ChangeId, ref changeBlob);
      var changeDetails = new ChangeDetailsHelper(changeBlob);
      var newSub = (Subscription)changeDetails[SubscriptionChangeType.SubscriptionKey];
      var subscriber = (AccountIdentifier)changeDetails[SubscriptionChangeType.AccountIdentifierKey];

      if (changeDetails.ContainsKey(SubscriptionChangeType.SubscriptionChangeKey))
      {
        // This change was already applied/denied/dismissed and stores subscription changes for that moment
        SubChange = (SubscriptionChange) changeDetails[SubscriptionChangeType.SubscriptionChangeKey];
      }
      else
      {
        // This change is in the Pending state and has no SubscriptionChange object
        SubChange = CompareWithCurrentSubscription(newSub, subscriber);
      }

      // TODO: Get account name using {subscriber} by WCF
      SubChange.AccountName = "AccountName";
      SubChange.ProductOfferingName = newSub.ProductOffering.Name;
    }
    finally
    {
      if (approvalClient.State == CommunicationState.Faulted)
        approvalClient.Abort();
      else
        approvalClient.Close();
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    Response.Write("<div id='xmlPretty' class='x-hide-display'>IsNew = '" + SubChange.IsNewEntity + "'</div>");
    Response.Write("<div id='xmlRaw' class='x-hide-display'><textarea rows='20' cols='80'>IsNew = '" + SubChange.IsNewEntity + "'</textarea>" +
                   "</div>");

    base.OnLoadComplete(e);
  }

  #endregion

  #region Private Methods

  private SubscriptionChange CompareWithCurrentSubscription(Subscription newSubscription, AccountIdentifier accOfNewSub)
  {
    Subscription currentSub = null;

    var subscriptionClient = new SubscriptionServiceClient();
    try
    {
      SetCredantional(subscriptionClient.ClientCredentials);

      if (newSubscription.SubscriptionId.HasValue)
      {
        subscriptionClient.GetSubscriptionDetail(accOfNewSub, newSubscription.SubscriptionId.Value, out currentSub);
      }
    }
    finally
    {
      if (subscriptionClient.State == CommunicationState.Faulted)
        subscriptionClient.Abort();
      else
        subscriptionClient.Close();
    }

    return SubscriptionChangeType.GetSubscriptionChange(currentSub, newSubscription);
  }
  
  private void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
  {
    if (clientCredentials == null)
      throw new InvalidOperationException("Client credentials is null");

    clientCredentials.UserName.UserName = UI.User.UserName;
    clientCredentials.UserName.Password = UI.User.SessionPassword;
  }
  
  #endregion
}


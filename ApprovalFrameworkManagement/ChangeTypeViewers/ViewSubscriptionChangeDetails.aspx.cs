using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Approvals;
using MetraTech.Approvals.ChangeTypes;
using MetraTech.UI.Controls;

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

      InitBasicProperties(SubChange);
      InitUdrcProperties(SubChange);
      InitSubscriptionProperties(SubChange);

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

  private void InitBasicProperties(SubscriptionChange subChange)
  {
    // Start Date
    SetViewChangeControl(SubChangeBasicStartDate, subChange.BasicProperties[0]);
    // Next start of payer's billing period after this date
    //SetViewChangeControl(SubChangeBasicNextStart, subChange.BasicProperties[1]);
    // End Date
    SetViewChangeControl(SubChangeBasicEndDate, subChange.BasicProperties[1]);
    // Next end of payer's billing period after this date
    //SetViewChangeControl(SubChangeBasicNextEnd, subChange.BasicProperties[3]);
  }

  private void InitUdrcProperties(SubscriptionChange subChange)
  {
    if (subChange.UdrcProperties.Count > 0)
    {
      foreach (var change in subChange.UdrcProperties)
      {
        SetViewChangeControl(change);
      }
    }
  }

  private void InitSubscriptionProperties(SubscriptionChange subChange)
  {
    if (subChange.ExtendedProperties.Count > 0)
    {
      this.Controls.Add(new MTLabel { Text = "Subscription Properties" });
      foreach (var change in subChange.ExtendedProperties)
      {
        SetViewChangeControl(new MTViewChangeControl(), change);
      }
    }
  }

  private void SetViewChangeControl(UdrcChange changedProp)
  {
    this.Controls.Add(new MTLabel { Text = changedProp.UdrcName });
    foreach (var change in changedProp.UdrcValueChanges)
    {
      SetViewChangeControl(new MTViewChangeControl(), change);
    }    
  }

  private void SetViewChangeControl(MTViewChangeControl viewControl, ChangedValue changedProp)
  {
    viewControl.Label = changedProp.DisplayName;
    viewControl.ValueOld = changedProp.OldValue;
    viewControl.ValueNew = changedProp.NewValue;
  }

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


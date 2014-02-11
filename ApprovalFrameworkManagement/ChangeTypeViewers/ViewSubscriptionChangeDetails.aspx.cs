using System;
using System.ServiceModel;
using System.Web;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Approvals;
using MetraTech.Approvals.ChangeTypes;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.BaseTypes;

public partial class ApprovalFrameworkManagement_ViewSubscriptionChangeDetails : MTPage
{
  public SubscriptionChange SubChange { get; set; }
  protected string AccountTypeName { get; set; }

  #region Event Listeners
  
  protected void Page_Load(object sender, EventArgs e)
  {
    var changeId = Convert.ToInt32(Request.QueryString["changeid"]);
    var changeDetails = GetChangeDetails(changeId);

    var newSub = (Subscription)changeDetails[SubscriptionChangeType.SubscriptionKey];
    var subscriberIdent = (AccountIdentifier)changeDetails[SubscriptionChangeType.AccountIdentifierKey];

    var subscriber = GetAccount(subscriberIdent);
    
    if (changeDetails.ContainsKey(SubscriptionChangeType.SubscriptionChangeKey))
    {
      // This change was already applied/denied/dismissed and stores subscription changes for that moment
      SubChange = (SubscriptionChange)changeDetails[SubscriptionChangeType.SubscriptionChangeKey];
    }
    else
    {
      // This change is in the Pending state and has no SubscriptionChange object
      SubChange = CompareWithCurrentSubscription(newSub, subscriberIdent);
    }
    
    SubChange.IsNewEntity = newSub.SubscriptionId == null;
    SubChange.AccountName = subscriber.UserName;
    SubChange.ProductOfferingName = newSub.ProductOffering.Name;
    
    InitBasicProperties(SubChange);
    InitUdrcProperties(SubChange);
    InitSubscriptionProperties(SubChange);

    AccountTypeName = subscriber.AccountType;
    DataBind();
  }
  
  #endregion

  #region Private Methods

  private System.Web.UI.Control _parenControl = null;
  private void InitBasicProperties(SubscriptionChange subChange)
  {
    lblChangesSummaryTitle.Text = SubChange.IsNewEntity
                       ? GetGlobalResourceObject("Resource", "newSubscription").ToString()
                       : GetGlobalResourceObject("Resource", "updateSubscription").ToString();
    
    LblAccountName.Text = SubChange.AccountName;
    LblPoName.Text = SubChange.ProductOfferingName;

    // Start Date
    SetViewChangeControl(SubChangeBasicStartDate, subChange.StartDateChange);
    // Next start of payer's billing period after this date
    SetViewChangeControl(SubChangeBasicNextStart, subChange.StartDateTypeChange);
    // End Date
    SetViewChangeControl(SubChangeBasicEndDate, subChange.EndDateChange);
    // Next end of payer's billing period after this date
    SetViewChangeControl(SubChangeBasicNextEnd, subChange.EndDateTypeChange);
    _parenControl = SubChangeBasicNextEnd.Parent;
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
      _parenControl.Controls.Add(new MTLabel { Text = "Subscription Properties" });
      foreach (var change in subChange.ExtendedProperties)
      {
        AddViewChangeControl(_parenControl, change);
      }
    }
  }

  private void SetViewChangeControl(UdrcChange changedProp)
  {
    _parenControl.Controls.Add(new MTLabel { Text = changedProp.UdrcName });
    foreach (var change in changedProp.UdrcValueChanges)
    {
      AddViewChangeControl(_parenControl, change);
    }    
  }

  private void AddViewChangeControl(System.Web.UI.Control  parentControl, ChangedValue changedProp)
  {
     var newControl = new MTViewChangeControl();
     SetViewChangeControl(newControl, changedProp);
     parentControl.Controls.Add(newControl);
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
  
  private ChangeDetailsHelper GetChangeDetails(int changeId)
  {
    ChangeDetailsHelper changeDetails;

    var approvalClient = new ApprovalManagementServiceClient();
    try
    {
      SetCredantional(approvalClient.ClientCredentials);
      var changeBlob = String.Empty;
      approvalClient.GetChangeDetails(changeId, ref changeBlob);
      changeDetails = new ChangeDetailsHelper(changeBlob);
    }
    finally
    {
      if (approvalClient.State == CommunicationState.Faulted)
        approvalClient.Abort();
      else
        approvalClient.Close();
    }

    return changeDetails;
  }
  
  private Account GetAccount(AccountIdentifier accountIdentifier)
  {
    Account account;

    var accountClient = new AccountServiceClient();
    try
    {
      SetCredantional(accountClient.ClientCredentials);
      accountClient.LoadAccount(accountIdentifier, DateTime.Now, out account); // TODO: What is DateTime parameter???
    }
    finally
    {
      if (accountClient.State == CommunicationState.Faulted)
        accountClient.Abort();
      else
        accountClient.Close();
    }

    return account;
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


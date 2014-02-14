using System;
using System.Collections.Generic;
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
using System.Web.UI;

public partial class ApprovalFrameworkManagement_ViewSubscriptionChangeDetails : MTPage
{
  public SubscriptionChange SubChange { get; set; }

  #region Event Listeners
  
  protected void Page_Load(object sender, EventArgs e)
  {
    var changeId = Convert.ToInt32(Request.QueryString["changeid"]);
    var changeDetails = GetChangeDetails(changeId);

    var newSub = (Subscription)changeDetails[SubscriptionChangeType.SubscriptionKey];
    var subscriberIdent = (AccountIdentifier)changeDetails[SubscriptionChangeType.AccountIdentifierKey];
    
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
    
    InitBasicProperties(SubChange);
    InitUdrcProperties(SubChange);
    InitSubscriptionProperties(SubChange);
  }
  
  #endregion

  #region Private Methods

  private Control _parenControl;
  private void InitBasicProperties(SubscriptionChange subChange)
  {
    lblChangesSummaryTitle.Text = SubChange.IsNewEntity
                       ? GetGlobalResourceObject("Resource", "newSubscription").ToString()
                       : GetGlobalResourceObject("Resource", "updateSubscription").ToString();

    LblAccountName.Text = String.Format("<img src='/ImageHandler/images/Account/{0}/account.gif' />  {1}", SubChange.AccountType, SubChange.AccountName);
    LblPoName.Text = SubChange.ProductOfferingName;
    
    // Start Date
    SetViewChangeControl(SubChangeBasicStartDate, subChange.StartDateChange, true);
    // Next start of payer's billing period after this date
    SetViewChangeControl(SubChangeBasicNextStart, subChange.StartDateTypeChange, true);
    // End Date
    SetViewChangeControl(SubChangeBasicEndDate, subChange.EndDateChange, true);
    // Next end of payer's billing period after this date
    SetViewChangeControl(SubChangeBasicNextEnd, subChange.EndDateTypeChange, true);
    _parenControl = SubChangeBasicNextEnd.Parent;
  }

  private void InitUdrcProperties(SubscriptionChange subChange)
  {
    if (subChange.UdrcProperties.Count > 0)
    {
      _parenControl.Controls.Add(new LiteralControl("<br />"));
      _parenControl.Controls.Add(new MTSection {Text = GetLocalResourceObject("UDRC_SECTION_NAME").ToString()});

      foreach (var change in subChange.UdrcProperties)
      {
        SetUdrsViewChangeControls(change);
      }
    }
  }

  private void InitSubscriptionProperties(SubscriptionChange subChange)
  {
    if (subChange.ExtendedProperties.Count > 0)
    {
      _parenControl.Controls.Add(new LiteralControl("<br />"));
      _parenControl.Controls.Add(new MTSection
        {
          Text = GetLocalResourceObject("SUB_PROPS_SECTION_NAME").ToString()
        });

      foreach (var change in subChange.ExtendedProperties)
      {
        AddViewChangeControl(_parenControl, change);
      }
    }
  }

  private void SetUdrsViewChangeControls(UdrcChange changedProp)
  {
    //TODO: Localize
    _parenControl.Controls.Add(new MTViewChangeControl{ Label="UDRS Name", ValueNew = String.Format("<b>{0}</b>", changedProp.UdrcName)  });
    foreach (var change in changedProp.UdrcValueChanges)
    {
      AddViewChangeControl(_parenControl, change);
    }    
  }

  private void AddViewChangeControl(System.Web.UI.Control  parentControl, ChangedValue changedProp)
  {
     var newControl = new MTViewChangeControl();
     SetViewChangeControl(newControl, changedProp, false);
     parentControl.Controls.Add(newControl);
  }

  private void SetViewChangeControl(MTViewChangeControl viewControl, ChangedValue changedProp, bool useLocalResxResource)
  {
    viewControl.ControlState = AdapteEnumFromApproveToUIControl(changedProp.State);
    viewControl.ValueOld = changedProp.OldValue;
    viewControl.ValueNew = changedProp.NewValue;
    if (!useLocalResxResource)
    {
      viewControl.Label = changedProp.DisplayName;
    }
  }

  private MTViewChangeControl.ChangeState AdapteEnumFromApproveToUIControl(ChangeValueState state)
  {
     switch (state)
      {
        case ChangeValueState.NotChanged:
         return MTViewChangeControl.ChangeState.NotChanged;

        case ChangeValueState.New:
          return MTViewChangeControl.ChangeState.New;

        case ChangeValueState.Updated:
           return MTViewChangeControl.ChangeState.Updated;

        case ChangeValueState.Deleted:
           return MTViewChangeControl.ChangeState.Deleted;

        default:
           throw new NotImplementedException(String.Format("Can't adapte ChangeValueState '{0}' from Approval Framework '{0}' to UI Control state.", state));
      }
  }

  private SubscriptionChange CompareWithCurrentSubscription(Subscription newSubscription, AccountIdentifier accOfNewSub)
  {
    Subscription currentSub = null;
    List<UDRCInstance> currentUdrcInstances = null;
    List<UDRCInstance> newUdrcInstances = null;
    
    var subscriptionClient = new SubscriptionServiceClient();
    try
    {
      SetCredantional(subscriptionClient.ClientCredentials);

      if (newSubscription.SubscriptionId.HasValue)
      {
        subscriptionClient.GetSubscriptionDetail(accOfNewSub, newSubscription.SubscriptionId.Value, out currentSub);
        subscriptionClient.GetUDRCInstancesForPO(newSubscription.ProductOfferingId, out newUdrcInstances);

        subscriptionClient.GetUDRCInstancesForPO(currentSub.ProductOfferingId, out currentUdrcInstances);
      }
    }
    finally
    {
      if (subscriptionClient.State == CommunicationState.Faulted)
        subscriptionClient.Abort();
      else
        subscriptionClient.Close();
    }

    return SubscriptionChangeType.GetSubscriptionChange(currentSub, newSubscription, currentUdrcInstances, newUdrcInstances, accOfNewSub.AccountID.Value);
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
  
  private void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
  {
    if (clientCredentials == null)
      throw new InvalidOperationException("Client credentials is null");

    clientCredentials.UserName.UserName = UI.User.UserName;
    clientCredentials.UserName.Password = UI.User.SessionPassword;
  }
  
  #endregion
}


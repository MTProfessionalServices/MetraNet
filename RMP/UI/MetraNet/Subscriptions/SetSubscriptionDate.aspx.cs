using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Linq;
using MetraTech.Approvals.ChangeTypes;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Tools;
using MetraNet.Models;

public partial class Subscriptions_SetSubscriptionDate : MTPage
{
  public Subscription SubscriptionInstance
  {
    get { return ViewState["SubscriptionInstance"] as Subscription; }
    set { ViewState["SubscriptionInstance"] = value; }
  }

  public Dictionary<string, SpecCharacteristicValueModel> SpecValues
  {
    get { return Session["SpecValues"] as Dictionary<string, SpecCharacteristicValueModel>; }
    set { Session["SpecValues"] = value; }
  }

  public string ChangeType
  {
    get { return ViewState["ChangeType"] as string; }
    set { ViewState["ChangeType"] = value; }
  }

  #region Event Listeners

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      SpecValues = new Dictionary<string, SpecCharacteristicValueModel>();
      SubscriptionInstance = PageNav.Data.Out_StateInitData["SubscriptionInstance"] as Subscription;

      if (SubscriptionInstance != null)
      {
        LblMessage.Text = FormatDateMessage(SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate,
                                            SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate);

        // validate date range client side in Ext
        StartDate.Options += String.Format(",minValue:'{0}',maxValue:'{1}'",
                                           SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate,
                                           SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate);

        EndDate.Options += String.Format(",minValue:'{0}',maxValue:'{1}',compareValue:'{2}'",
                                         SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate,
                                         SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate,
                                         DateTime.Today);

        if (SubscriptionInstance.SubscriptionSpan.StartDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod)
        {
          cbStartNextBillingPeriod.Checked = true;
        }

        if (SubscriptionInstance.SubscriptionSpan.EndDateType == ProdCatTimeSpan.MTPCDateType.NextBillingPeriod)
        {
          cbEndNextBillingPeriod.Checked = true;
        }

        // if subscription dates are null default them to the effective dates on the PO
        if (SubscriptionInstance.SubscriptionSpan.StartDate == null)
        {
          SubscriptionInstance.SubscriptionSpan.StartDate = ApplicationTime;
          //SubscriptionInstance.SubscriptionSpan.StartDate = SubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate;
        }

        if (SubscriptionInstance.SubscriptionSpan.EndDate == null)
        {
          SubscriptionInstance.SubscriptionSpan.EndDate = SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate;
        }

        // Bind Subscription Properties
        SpecCharacteristicsBinder.BindProperties(pnlSubscriptionProperties,
                                                 SubscriptionInstance, this, SpecValues);

        var isNew = SubscriptionInstance.SubscriptionId == null;
        ChangeType = isNew
                       ? SubscriptionChangeType.AddSubscriptionChangeTypeName
                       : SubscriptionChangeType.UpdateSubscriptionChangeTypeName;
        var changeTypeShortName = isNew
                                    ? SubscriptionChangeType.AddSubscriptionChangeTypeShortName
                                    : SubscriptionChangeType.UpdateSubscriptionChangeTypeShortName;
        var uniqueSubChageId = String.Format("{0}_{1}_{2}", UI.Subscriber.SelectedAccount._AccountID,
                                             SubscriptionInstance.ProductOfferingId, changeTypeShortName);
        CheckPendingChanges(ChangeType, uniqueSubChageId, isNew);
      }

      if (!MTDataBinder1.DataBind())
      {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
      else
      {
          // SECENG: Added HTML encoding
          lblDisplayName.Text = Utils.EncodeForHtml(lblDisplayName.Text);
          lblDescDispName.Text = Utils.EncodeForHtml(lblDescDispName.Text);
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (!Page.IsValid) return;

    var oldSubStartDate = SubscriptionInstance.SubscriptionSpan.StartDate.Value;
    MTDataBinder1.Unbind();
    var newSubStartDate = SubscriptionInstance.SubscriptionSpan.StartDate.Value;

    var sub = SubscriptionInstance;

    if (cbStartNextBillingPeriod.Checked)
    {
      sub.SubscriptionSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
    }

    if (cbEndNextBillingPeriod.Checked)
    {
      sub.SubscriptionSpan.EndDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
    }

    // Unbind Subscription Properties
    var charVals = new List<CharacteristicValue>();
    SpecCharacteristicsBinder.UnbindProperies(charVals, pnlSubscriptionProperties, SpecValues);
    sub.CharacteristicValues = charVals;

    var isApprovalsEnabled = IsApprovalsEnabled(ChangeType);

    // CORE-9296: If Subscription Start Date was changed to earlier - update UDRC Start Date accordingly.    
    if (newSubStartDate < oldSubStartDate)
      foreach (var valueListOfUdrc in sub.UDRCValues.Values)
      {
        var udrcVal = valueListOfUdrc.Find(v => v.StartDate == oldSubStartDate);
        if (udrcVal != null && !valueListOfUdrc.Exists(v => v.StartDate < udrcVal.StartDate)) // Ensure this is the 1-st UDRC value.
          udrcVal.StartDate = newSubStartDate;
      }
    //// DELETE Unsusable Values if Sub Start Date moved forward:
    //else if (newSubStartDate > oldSubStartDate)
    //  foreach (var valueListOfUdrc in sub.UDRCValues.Values)
    //  {
    //    valueListOfUdrc.RemoveAll(v => v.EndDate < newSubStartDate);

    //    var udrcVal = valueListOfUdrc.Find(v => v.StartDate <= newSubStartDate);
    //    if (udrcVal != null)
    //      udrcVal.StartDate = newSubStartDate;
    //  }

    var update = new SubscriptionsEvents_OKSetSubscriptionDate_Client
      {
        In_SubscriptionInstance = sub,
        In_AccountId = new AccountIdentifier(UI.User.AccountId),
        In_IsApprovalEnabled = isApprovalsEnabled
      };
    
    PageNav.Execute(update);

    if (isApprovalsEnabled && !HasUdrcValues(sub))
    {
      Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
    }
  }
  
  protected void btnCancel_Click(object sender, EventArgs e)
  {
    var cancel = new SubscriptionsEvents_CancelSubscriptions_Client
      {
        In_AccountId = new AccountIdentifier(UI.User.AccountId)
      };
    PageNav.Execute(cancel);
  }

  #endregion

  #region Private Methods
  
  private bool IsApprovalsEnabled(string changeType)
  {
    bool isEnabled;

    var client = new ApprovalManagementServiceClient();
    try
    {
      SetCredantional(client.ClientCredentials);
      client.ApprovalEnabledForChangeType(changeType, out isEnabled);
    }
    finally
    {
      if (client.State == CommunicationState.Faulted)
        client.Abort();
      else
        client.Close();
    }

    return isEnabled;
  }

  private bool HasUdrcValues(Subscription sub)
  {
    List<UDRCInstance> listOfUdrcs;

    var client = new SubscriptionServiceClient();
    try
    {
      SetCredantional(client.ClientCredentials);
      client.GetUDRCInstancesForPO(sub.ProductOfferingId, out listOfUdrcs);
    }
    finally
    {
      if (client.State == CommunicationState.Faulted)
        client.Abort();
      else
        client.Close();
    }

    return listOfUdrcs.Count > 0;
  }

  private void CheckPendingChanges(string changeType, string subId, bool isNew)
  {
    if (HasPendingChanges(changeType, subId))
    {
      const string approvalFrameworkManagementUrl =
        "/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING";
      var changeTypeDisplayName = isNew
                         ? GetGlobalResourceObject("Resource", "newSubscription").ToString()
                         : GetGlobalResourceObject("Resource", "updateSubscription").ToString();

      var strPendingChangeWarning =
        String.Format(GetLocalResourceObject("pendingChangeWarningFormat").ToString(),
                      changeTypeDisplayName, approvalFrameworkManagementUrl);
      divLblMessage.Visible = true;
      lblInfoMessage.Text = strPendingChangeWarning;

      if (!IsMoreThanOnePendingChangeAllowed(changeType))
      {
        // Disable all options except "Cancel" button
        StartDate.Enabled =
          EndDate.Enabled =
          cbEndNextBillingPeriod.Enabled =
          cbStartNextBillingPeriod.Enabled =
          pnlSubscriptionProperties.Enabled =
          btnOK.Enabled = false;

        SetError(String.Format(GetLocalResourceObject("pendingChangeUiErrorFormat").ToString(), changeTypeDisplayName));
        Logger.LogError(
          string.Format(
            "The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.",
            subId, changeType));
      }
    }
  }

  private bool IsMoreThanOnePendingChangeAllowed(string changeType)
  {
    bool isAllowed;

    var client = new ApprovalManagementServiceClient();
    try
    {
      SetCredantional(client.ClientCredentials);
      client.AllowMoreThanOnePendingChangeForChangeType(changeType, out isAllowed);
    }
    finally
    {
      if (client.State == CommunicationState.Faulted)
        client.Abort();
      else
        client.Close();
    }

    return isAllowed;
  }

  private bool HasPendingChanges(string changeType, string subId)
  {
    List<int> pendingChangeIds;

    var client = new ApprovalManagementServiceClient();
    try
    {
      SetCredantional(client.ClientCredentials);
      client.GetPendingChangeIdsForItem(changeType, subId, out pendingChangeIds);
    }
    finally
    {
      if (client.State == CommunicationState.Faulted)
        client.Abort();
      else
        client.Close();
    }

    return pendingChangeIds.Count > 0;
  }

  private void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
  {
    if (clientCredentials == null)
      throw new InvalidOperationException("Client credentials is null");

    clientCredentials.UserName.UserName = UI.User.UserName;
    clientCredentials.UserName.Password = UI.User.SessionPassword;
  }

  private static string FormatDateMessage(DateTime? startDate, DateTime? endDate)
  {
    var msg = Resources.Resource.TEXT_SUB_DATE_MESSAGE_START;

    if (startDate.HasValue)
    {
      msg += String.Format(" {0} {1}", Resources.Resource.TEXT_AFTER, startDate.Value.ToShortDateString());
    }

    if (startDate.HasValue && endDate.HasValue)
    {
      msg += String.Format(" {0}", Resources.Resource.TEXT_AND);
    }

    if (endDate.HasValue)
    {
      msg += String.Format(" {0} {1}", Resources.Resource.TEXT_BEFORE, endDate.Value.ToShortDateString());
    }

    return msg;
  }

  #endregion
}
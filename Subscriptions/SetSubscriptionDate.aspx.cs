using System;
using System.Collections.Generic;
using MetraTech;
using MetraTech.Approvals;
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
        if(SubscriptionInstance.SubscriptionSpan.StartDate == null)
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

    MTDataBinder1.Unbind();

    if (cbStartNextBillingPeriod.Checked)
    {
      SubscriptionInstance.SubscriptionSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
    }

    if (cbEndNextBillingPeriod.Checked)
    {
      SubscriptionInstance.SubscriptionSpan.EndDateType = ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
    }

    // Unbind Subscription Properties
    var charVals = new List<CharacteristicValue>();
    SpecCharacteristicsBinder.UnbindProperies(charVals, pnlSubscriptionProperties, SpecValues);
    SubscriptionInstance.CharacteristicValues = charVals;

    ProcessTheSubscription(SubscriptionInstance);
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

  /// <summary>
  /// Depending on the conditions does one of the followig:
  /// 1. Saves subscription;
  /// 2. Goes to UDRC screen;
  /// 3. Sending submitted change to approval, if approval is enabled
  /// </summary>
  private void ProcessTheSubscription(Subscription sub)
  {
    var isNewSubscription = sub.SubscriptionId == null;
    var changeTypeName = isNewSubscription
                           ? SubscriptionChangeType.AddSubscriptionChangeTypeName
                           : SubscriptionChangeType.UpdateSubscriptionChangeTypeName;

    if (IsApprovalsEnabled(changeTypeName) && !HasUdrcValues(sub))
    {
      var changeId = SubmitSubscriptionChangeForApproval(sub, changeTypeName, isNewSubscription);
      Response.Redirect(
        String.Format("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx?ChangeId={0}", changeId),
        false);
    }
    else
    {
      var update = new SubscriptionsEvents_OKSetSubscriptionDate_Client
        {
          In_SubscriptionInstance = sub,
          In_AccountId = new AccountIdentifier(UI.User.AccountId)
        };
      PageNav.Execute(update);
    }
  }

  /// <summary>
  /// Submits a change to pending approvement using Approval Service
  /// </summary>
  /// <param name="sub">Subscription</param>
  /// <param name="changeTypeName">Type of submitted change</param>
  /// <param name="isNewSub">Is it new subscription or update of existing</param>
  /// <returns>ID of submitted change</returns>
  private int SubmitSubscriptionChangeForApproval(Subscription sub, string changeTypeName, bool isNewSub)
  {
    var subscriber = UI.Subscriber.SelectedAccount;
    if (!subscriber._AccountID.HasValue)
    {
      throw new NullReferenceException("AccountID property is empty");
    }
    var changeNameShort = isNewSub ? "Sub.Add" : "Sub.Update";
    var changeCommentFormat = isNewSub
                                ? "Subscribing account '{0}' to product offering '{1}' on '{2}'"
                                : "Updating subscription of account '{0}' to product offering '{1}' on '{2}'";

    var changeDetails = new ChangeDetailsHelper();
    changeDetails[SubscriptionChangeType.AccountIdentifierKey] = new AccountIdentifier(subscriber._AccountID.Value);
    changeDetails[SubscriptionChangeType.SubscriptionKey] = sub;
      // TODO:  "sub" is a 'ref' parameter of SubscriptionService.AddSubscription(). Ensure it will be tracked appropriately

    var subscriptionChange = new Change
      {
        ChangeType = changeTypeName,
        ChangeDetailsBlob = changeDetails.ToXml(),
        UniqueItemId = String.Format("{0}_{1}_{2}", subscriber._AccountID.Value, sub.ProductOfferingId, changeNameShort),
        ItemDisplayName = sub.ProductOffering.Name,
        Comment = String.Format(changeCommentFormat, subscriber.UserName, sub.ProductOffering.Name, MetraTime.Now)
      };

    int changeId;
    using (var client = new ApprovalManagementServiceClient())
    {
      SetCredantional(client.ClientCredentials);
      client.SubmitChange(subscriptionChange, out changeId);
    }
    return changeId;
  }

  private bool IsApprovalsEnabled(string changeType)
  {
    bool isEnabled;
    using (var client = new ApprovalManagementServiceClient())
    {
      SetCredantional(client.ClientCredentials);
      client.ApprovalEnabledForChangeType(changeType, out isEnabled);
    }
    return isEnabled;
  }

  private bool HasUdrcValues(Subscription sub)
  {
    List<UDRCInstance> listOfUdrcs;
    using (var client = new SubscriptionServiceClient())
    {
      SetCredantional(client.ClientCredentials);
      client.GetUDRCInstancesForPO(sub.ProductOfferingId, out listOfUdrcs);
    }
    return listOfUdrcs.Count > 0;
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
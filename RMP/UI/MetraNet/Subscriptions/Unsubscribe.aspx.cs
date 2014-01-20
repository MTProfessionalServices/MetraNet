using System;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;

public partial class Subscriptions_Unsubscribe : MTPage
{
  public Subscription SubscriptionInstance
  {
    get { return ViewState["SubscriptionInstance"] as Subscription; }
    set { ViewState["SubscriptionInstance"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      SubscriptionInstance = PageNav.Data.Out_StateInitData["SubscriptionInstance"] as Subscription;

      if (SubscriptionInstance != null)
      {
        EndDate.Options += String.Format(",minValue:'{0}',maxValue:'{1}'",
                                         SubscriptionInstance.SubscriptionSpan.StartDate,
                                         SubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate);
      }

      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      SubscriptionsEvents_OKUnsubscribeSubscription_Client unsub = new SubscriptionsEvents_OKUnsubscribeSubscription_Client();
      unsub.In_SubscriptionInstance = SubscriptionInstance;
      unsub.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      PageNav.Execute(unsub);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    SubscriptionsEvents_CancelSubscriptions_Client cancel = new SubscriptionsEvents_CancelSubscriptions_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }
}
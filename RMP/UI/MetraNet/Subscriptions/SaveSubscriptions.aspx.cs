using System;

using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.PageNav.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class Subscriptions_SaveSubscriptions : MTPage
{
  public Subscription SubscriptionInstance
  {
    get { return ViewState["SubscriptionInstance"] as Subscription; }
    set { ViewState["SubscriptionInstance"] = value; }
  }

  public bool IsNewSubscription
  {
    get { return (bool)ViewState["IsNewSubscription"]; }
    set { ViewState["IsNewSubscription"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      // Perform Session cleanup, TODO: find a better way to store these items
      Session.Remove("SubscriptionInstance");
      Session.Remove("UDRCs");
      Session.Remove("UDRCDictionary"); 
      Session.Remove("udrc_State");
      Session.Remove("udrc_InterfaceName");
      Session.Remove("udrc_ProcessorId");

      SubscriptionInstance = PageNav.Data.Out_StateInitData["SubscriptionInstance"] as Subscription;
      IsNewSubscription = (bool)PageNav.Data.Out_StateInitData["IsNewSubscription"];

      if (IsNewSubscription)
      {
        lblTitle.Text = GetLocalResourceObject("lblTitleResource1").ToString(); 
        lblSubscription.Text = GetLocalResourceObject("lblSubscriptionResource1").ToString();
      }
      else
      {
        lblTitle.Text = GetLocalResourceObject("lblTitleUpdatedResource1").ToString();
        lblSubscription.Text = GetLocalResourceObject("lblSubscriptionUpdatedResource1").ToString();
      }

      if (!this.MTDataBinder1.DataBind())
      {
          this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
      else
      {
          // SECENG: Fixing XSS injection.
          lblDisplayName.Text = lblDisplayName.Text.EncodeForHtml();
      }
    }
  }

  protected void btnCancel_Click1(object sender, EventArgs e)
  {
    SubscriptionsEvents_CancelManageSubscriptions_Client cancel = new SubscriptionsEvents_CancelManageSubscriptions_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }

  protected void btnBackToManage_Click(object sender, EventArgs e)
  {
    SubscriptionsEvents_CancelSubscriptions_Client cancel = new SubscriptionsEvents_CancelSubscriptions_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }
}
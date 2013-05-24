using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;

public partial class Subscriptions_DeleteSubscription : MTPage
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
      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  public override void Validate()
  {
    base.Validate();
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      this.MTDataBinder1.Unbind();

      SubscriptionsEvents_OKDeleteSubscription_Client del = new SubscriptionsEvents_OKDeleteSubscription_Client();
      del.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      del.In_SubscriptionId = (int)SubscriptionInstance.SubscriptionId;
      PageNav.Execute(del);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    SubscriptionsEvents_CancelSubscriptions_Client cancel = new SubscriptionsEvents_CancelSubscriptions_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }
}
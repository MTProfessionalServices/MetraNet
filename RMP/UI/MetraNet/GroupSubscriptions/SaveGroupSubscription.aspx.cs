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

public partial class GroupSubscriptions_SaveGroupSubscription : MTPage
{
  public Subscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
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
      try
      {
        GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
        IsNewSubscription = (bool)PageNav.Data.Out_StateInitData["IsNewSubscription"];

        if (IsNewSubscription)
        {
          lblGroupSubscription.Text = LblCreate.Text;
        }
        else
        {
          lblGroupSubscription.Text = LblUpdate.Text;
        }

        if (!this.MTDataBinder1.DataBind())
        {
          this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
        }
      }
      catch (Exception exc)
      {
        string Message = GetLocalResourceObject("ErrorSaveGroupSub").ToString();
        SetError(Message);
        Logger.LogError(exc.Message);
      }
    }
  }

  protected void btnBackToDashboard_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_BackToDashboard_Client backToDashboard = new GroupSubscriptionsEvents_BackToDashboard_Client();
    backToDashboard.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(backToDashboard);
  }

  protected void btnBackToManage_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_BackToManageGroupSubscriptions_Client backToManage = new GroupSubscriptionsEvents_BackToManageGroupSubscriptions_Client();
    backToManage.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(backToManage);
  }
}

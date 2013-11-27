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
using MetraTech.UI.Tools;

public partial class GroupSubscriptions_DeleteGroupSubscription : MTPage
{
  public GroupSubscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
  }

  public GroupSubscription CurrentGroupSubscription
  {
    get { return ViewState["CurrentGroupSubscription"] as GroupSubscription; }
    set { ViewState["CurrentGroupSubscription"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
      CurrentGroupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;

      if (CurrentGroupSubscription.Name != "")
      {
        //MTPanel1.Text = GetLocalResourceObject("PanelTitle").ToString() + " \\'" + HttpUtility.HtmlEncode(CurrentGroupSubscription.Name.Replace("'","\\'")) + "\\'";
        MTPanel1.Text = GetLocalResourceObject("PanelTitle").ToString() + " " + Utils.EncodeForHtml(CurrentGroupSubscription.Name);
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    this.MTDataBinder1.Unbind();

    try
    {
      GroupSubscriptionsEvents_OKDeleteGroupSubscription_Client del = new GroupSubscriptionsEvents_OKDeleteGroupSubscription_Client();
      del.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      del.In_GroupSubscriptionId = (int)GroupSubscriptionInstance.GroupId;
      PageNav.Execute(del);
    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorDeleteGroupSub").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelDeleteGroupSubscription_Client cancel = new GroupSubscriptionsEvents_CancelDeleteGroupSubscription_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }
}

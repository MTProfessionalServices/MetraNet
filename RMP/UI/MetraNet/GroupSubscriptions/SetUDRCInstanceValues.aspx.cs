using System;
using System.Collections.Generic;
using System.Web.UI;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;

public partial class GroupSubscriptions_SetUDRCInstanceValues : MTPage
{
  public GroupSubscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
  }

  public UDRCInstance CurrentUDRCInstance
  {
    get { return ViewState["CurrentUDRCInstance"] as UDRCInstance; }
    set { ViewState["CurrentUDRCInstance"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
      CurrentUDRCInstance = PageNav.Data.Out_StateInitData["CurrentUDRCInstance"] as UDRCInstance;
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    UDRCValueGrid.Title = CurrentUDRCInstance.UnitDisplayName;
  }

  protected void btnOK_Click(object sender, EventArgs eventArgs)
  {
    try
    {
      GroupSubscriptionsEvents_OKSetUDRCInstanceValue_Client okSetUdrcInstanceValueClient =
          new GroupSubscriptionsEvents_OKSetUDRCInstanceValue_Client();
      okSetUdrcInstanceValueClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      okSetUdrcInstanceValueClient.In_GroupSubscriptionInstance = GroupSubscriptionInstance;
      PageNav.Execute(okSetUdrcInstanceValueClient);
    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorLoadUDRCInstances").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs eventArgs)
  {
    GroupSubscriptionsEvents_CancelSetUDRCInstanceValue_Client cancelSetUdrcInstanceValueClient =
        new GroupSubscriptionsEvents_CancelSetUDRCInstanceValue_Client();
    cancelSetUdrcInstanceValueClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancelSetUdrcInstanceValueClient);
  }

}
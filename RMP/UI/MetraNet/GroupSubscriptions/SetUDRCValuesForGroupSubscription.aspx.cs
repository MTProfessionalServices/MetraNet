using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;

public partial class GroupSubscriptions_SetUDRCValues : MTPage
{
  public List<UDRCInstance> UDRCInstances
  {
    get { return ViewState["UDRCInstances"] as List<UDRCInstance>; }
    set { ViewState["UDRCInstances"] = value; }
  }

  public List<FlatRateRecurringChargeInstance> FlatRateRCInstances
  {
    get { return ViewState["FlatRateRCInstances"] as List<FlatRateRecurringChargeInstance>; }
    set { ViewState["FlatRateRCInstances"] = value; }
  }

  public GroupSubscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
  }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      UDRCInstances = PageNav.Data.Out_StateInitData["UDRCInstances"] as List<UDRCInstance>;
      FlatRateRCInstances = PageNav.Data.Out_StateInitData["FlatRateRCInstances"] as List<FlatRateRecurringChargeInstance>;
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelSetUDRCValues_Client cancelSetUDRCValues = new GroupSubscriptionsEvents_CancelSetUDRCValues_Client();
    cancelSetUDRCValues.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancelSetUDRCValues);
  }

  protected void btnSave_Click(object sender, EventArgs eventArgs)
  {
    try
    {
      GroupSubscriptionsEvents_SaveSetUDRCValues_Client saveSetUDRCValuesClient = new GroupSubscriptionsEvents_SaveSetUDRCValues_Client();
      saveSetUDRCValuesClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);      
      saveSetUDRCValuesClient.In_GroupSubscriptionInstance = GroupSubscriptionInstance;
      PageNav.Execute(saveSetUDRCValuesClient);
    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorSaveGroupSub").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }
}
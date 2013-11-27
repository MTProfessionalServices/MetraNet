using System;
using System.Collections.Generic;
using System.Web.UI;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;

public partial class GroupSubscriptions_SetFlatRateRCAccount : MTPage
{

  public FlatRateRecurringChargeInstance CurrentFlatRateRCInstance
  {
    get { return ViewState["CurrentFlatRateRCInstance"] as FlatRateRecurringChargeInstance; }
    set { ViewState["CurrentFlatRateRCInstance"] = value; }
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
      CurrentFlatRateRCInstance = PageNav.Data.Out_StateInitData["CurrentFlatRateRCInstance"] as FlatRateRecurringChargeInstance;
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = CurrentFlatRateRCInstance.GetType();
      MTGenericForm1.RenderObjectInstanceName = "CurrentFlatRateRCInstance";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.TemplateName = "FlatRateRChargeAccount";
      MTGenericForm1.ReadOnly = false;

      lblSetFRRCAccountTitle.Text = GetLocalResourceObject("FRRCDisplayName").ToString() + CurrentFlatRateRCInstance.DisplayName;
      if (CurrentFlatRateRCInstance.ChargeAccountSpan.StartDate == null)
      {
        CurrentFlatRateRCInstance.ChargeAccountSpan.StartDate = GroupSubscriptionInstance.SubscriptionSpan.StartDate.Value;
      }

      if (CurrentFlatRateRCInstance.ChargeAccountSpan.EndDate == null)
      {
        CurrentFlatRateRCInstance.ChargeAccountSpan.EndDate = GroupSubscriptionInstance.SubscriptionSpan.EndDate.Value;
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }
    }

  }


  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Page.Validate();
      MTDataBinder1.Unbind();
      bool okFlag = true;

      int chargeAcctId = int.Parse(AcctIdTextBox.Value);
      if (chargeAcctId > 0)
      {
        Account acc = new Account();
        acc = MetraTech.UI.Common.AccountLib.LoadAccount(chargeAcctId, UI.User, ApplicationTime);
        if (acc == null)
        {
          okFlag = false;
          SetError(GetLocalResourceObject("ErrorChargeAcctId").ToString());
        }
      }
      else
      {
        okFlag = false;
        SetError(GetLocalResourceObject("ErrorChargeAcctId").ToString());
      }

      if (okFlag)
      {

       /* if (GroupSubscriptionInstance.FlatRateRecurringChargeInstances == null)
       {
          GroupSubscriptionInstance.FlatRateRecurringChargeInstances = new List<FlatRateRecurringChargeInstance>();         
          GroupSubscriptionInstance.FlatRateRecurringChargeInstances.Add(CurrentFlatRateRCInstance);
        }
        else
        {*/
          foreach (FlatRateRecurringChargeInstance frrc in GroupSubscriptionInstance.FlatRateRecurringChargeInstances)
          {
            if (frrc.ID == CurrentFlatRateRCInstance.ID)
            {
              frrc.ChargeAccountId = CurrentFlatRateRCInstance.ChargeAccountId;
              frrc.ChargeAccountSpan = new ProdCatTimeSpan();
              frrc.ChargeAccountSpan.StartDate = CurrentFlatRateRCInstance.ChargeAccountSpan.StartDate;
              frrc.ChargeAccountSpan.EndDate = CurrentFlatRateRCInstance.ChargeAccountSpan.EndDate;
            }           
          }

         
        //}

        GroupSubscriptionsEvents_OKSetFlatRateRCAccount_Client setFlatRateRcAccountClient =
            new GroupSubscriptionsEvents_OKSetFlatRateRCAccount_Client();
        setFlatRateRcAccountClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        setFlatRateRcAccountClient.In_GroupSubscriptionInstance = GroupSubscriptionInstance;
        PageNav.Execute(setFlatRateRcAccountClient);
      }
    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorEditFlatRateRCAcct").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }

  }
  protected void btnCancel_Click(object sender, EventArgs eventArgs)
  {
    GroupSubscriptionsEvents_CancelSetFlatRateRCAccount_Client cancelSetfrrcAccountClient =
        new GroupSubscriptionsEvents_CancelSetFlatRateRCAccount_Client();
    cancelSetfrrcAccountClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancelSetfrrcAccountClient);
  }





}
using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;

public partial class GroupSubscriptions_SetUDRCAccount : MTPage
{

  public UDRCInstance CurrentUDRCInstance
  {
    get { return ViewState["CurrentUDRCInstance"] as UDRCInstance; }
    set { ViewState["CurrentUDRCInstance"] = value; }
  }

  public GroupSubscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    base.OnLoadComplete(e);
  }
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      CurrentUDRCInstance = PageNav.Data.Out_StateInitData["CurrentUDRCInstance"] as UDRCInstance;
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = CurrentUDRCInstance.GetType();
      MTGenericForm1.RenderObjectInstanceName = "CurrentUDRCInstance";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.TemplateName = "UDRChargeAccount";
      MTGenericForm1.ReadOnly = false;

      lblSetUDRChargeAccountTitle.Text = GetLocalResourceObject("UDRCDisplayName").ToString() + CurrentUDRCInstance.DisplayName;
      if (CurrentUDRCInstance.ChargeAccountSpan.StartDate == null)
      {
        CurrentUDRCInstance.ChargeAccountSpan.StartDate = GroupSubscriptionInstance.SubscriptionSpan.StartDate.Value;
      }

      if (CurrentUDRCInstance.ChargeAccountSpan.EndDate == null)
      {
        CurrentUDRCInstance.ChargeAccountSpan.EndDate = GroupSubscriptionInstance.SubscriptionSpan.EndDate.Value;
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
        /*if (GroupSubscriptionInstance.UDRCInstances == null)
        {
            GroupSubscriptionInstance.UDRCInstances = new List<UDRCInstance>();
            GroupSubscriptionInstance.UDRCInstances.Add(CurrentUDRCInstance);
        }       
        else
        {  */                   
              List<UDRCInstance> udrcInstList = new List<UDRCInstance>();
              udrcInstList = GroupSubscriptionInstance.UDRCInstances;
         
             foreach(UDRCInstance udrc in GroupSubscriptionInstance.UDRCInstances)
             {
                if(udrc.ID == CurrentUDRCInstance.ID)
                {
                  udrc.ChargeAccountId = CurrentUDRCInstance.ChargeAccountId;
                  udrc.ChargeAccountSpan = new ProdCatTimeSpan();
                  udrc.ChargeAccountSpan.StartDate = CurrentUDRCInstance.ChargeAccountSpan.StartDate;
                  udrc.ChargeAccountSpan.EndDate = CurrentUDRCInstance.ChargeAccountSpan.EndDate;      
                }
             }
        /* if(udrcInstList.Contains(CurrentUDRCInstance))
              {
                  UDRCInstance udrc = udrcInstList.Find
                  (
                    delegate(UDRCInstance udrcInst) { return udrcInst == CurrentUDRCInstance; }
                  );            
                  udrc.ChargeAccountId = CurrentUDRCInstance.ChargeAccountId;
                  udrc.ChargeAccountSpan = new ProdCatTimeSpan();         
                  udrc.ChargeAccountSpan.StartDate = CurrentUDRCInstance.ChargeAccountSpan.StartDate;
                  udrc.ChargeAccountSpan.EndDate = CurrentUDRCInstance.ChargeAccountSpan.EndDate;                  
              }*/
              /*else
              {
                 GroupSubscriptionInstance.UDRCInstances.Add(CurrentUDRCInstance);
              }*/
                              
          //}

        GroupSubscriptionsEvents_OKSetUDRCAccount_Client setUdrcAccountClient =
            new GroupSubscriptionsEvents_OKSetUDRCAccount_Client();
        setUdrcAccountClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        setUdrcAccountClient.In_GroupSubscriptionInstance = GroupSubscriptionInstance;
        PageNav.Execute(setUdrcAccountClient);

      }
    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorEditUDRCAcct").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }
  protected void btnCancel_Click(object sender, EventArgs eventArgs)
  {
    GroupSubscriptionsEvents_CancelSetUDRCAccount_Client cancelSetUdrcAccountClient =
        new GroupSubscriptionsEvents_CancelSetUDRCAccount_Client();
    cancelSetUdrcAccountClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancelSetUdrcAccountClient);
  }





}
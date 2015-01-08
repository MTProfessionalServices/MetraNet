using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraNet.Models;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.Enums.Core.Global;

using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;
using System.Text;
using MetraTech.ActivityServices.Common;

public partial class GroupSubscriptions_SetGroupSubscriptionDate : MTPage
{

  public string MetraTimeNow
  {
    get { return ApplicationTime.ToShortDateString(); }
  }

  public Cycle POCycleInstance
  {
    get
    {
        if (ViewState["POCycleInstance"] == null)
      {
          ViewState["POCycleInstance"] = new Cycle();
      }
        return ViewState["POCycleInstance"] as Cycle;
    }
      set { ViewState["POCycleInstance"] = value; }
  }

  public Cycle AcctCycleInstance
  {
      get
      {
          if (ViewState["AcctCycleInstance"] == null)
          {
              ViewState["AcctCycleInstance"] = new Cycle();
          }
          return ViewState["AcctCycleInstance"] as Cycle;
      }
      set { ViewState["AcctCycleInstance"] = value; }
  }

  public GroupSubscription GroupSubscriptionInstance
  {
    get { return ViewState["GroupSubscriptionInstance"] as GroupSubscription; }
    set { ViewState["GroupSubscriptionInstance"] = value; }
  }

  public Dictionary<string, SpecCharacteristicValueModel> SpecValues
  {
    get { return Session["SpecValues"] as Dictionary<string, SpecCharacteristicValueModel>; }
    set { Session["SpecValues"] = value; }
  }

  public bool ShowDiscConfig;
  public bool ShowUsageCyclePanel;

  protected bool isCorporate = false;
  public bool IsCorporate
  {
    get
    {
      return isCorporate;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
     
    if (!IsPostBack)
    {
      SpecValues = new Dictionary<string, SpecCharacteristicValueModel>();
      GroupSubscriptionInstance = PageNav.Data.Out_StateInitData["GroupSubscriptionInstance"] as GroupSubscription;
    
      if (GroupSubscriptionInstance != null)
      {
        if (UI.Subscriber.SelectedAccount == null)
        {
          GroupSubscriptionInstance.CorporateAccountId = 1;
        }
        else
        {
          CheckIsCorporate();
          if (isCorporate)
          {
            GroupSubscriptionInstance.CorporateAccountId = UI.Subscriber.SelectedAccount._AccountID.Value;
          }
          else
          {
            GroupSubscriptionInstance.CorporateAccountId = UI.Subscriber.SelectedAccount.AncestorAccountID.Value;
          }
        }
        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        if (GroupSubscriptionInstance != null) MTGenericForm1.RenderObjectType = GroupSubscriptionInstance.GetType();
        MTGenericForm1.RenderObjectInstanceName = "GroupSubscriptionInstance";
        MTGenericForm1.TemplatePath = TemplatePath;
        MTGenericForm1.ReadOnly = false;

        // EBCR Warning 
        PanelEBCRWarning.Visible = GroupSubscriptionInstance.WarnOnEBCRStartDateChange ?? false;
        
        // Support Group Operations
        //FEAT-4446  Remove legacy rating options from MetraOffer/MetraCare/MetraView
        PanelSharedCounters.Visible = false; //GroupSubscriptionInstance.SupportsGroupOperations;

        if (GroupSubscriptionInstance.DiscountAccountId != null)
        {
          radSharedCounters.Checked = true;
          radNoSharedCounters.Checked = false;
          PanelDiscountAccount.Visible = true;
          ShowDiscConfig = false; 
        }
        else
        {
          radSharedCounters.Checked = false;
          radNoSharedCounters.Checked = true;
          ShowDiscConfig = false;
        }

        if (UI.Subscriber.SelectedAccount == null)
        {
            AccountsPanel.Visible = true;
        }
        

        //Add case
        if (GroupSubscriptionInstance.Cycle == null)
        {         
            if (GroupSubscriptionInstance.ProductOffering.UsageCycleType > 0)
            {
                switch (GroupSubscriptionInstance.ProductOffering.UsageCycleType)
                {
                    case 1:
                        POCycleInstance.CycleType = UsageCycleType.Monthly;
                        POCycleInstance.DayOfMonth = 3;
                        break;

                    case 3:
                        POCycleInstance.CycleType = UsageCycleType.Daily;
                        break;

                    case 4:
                        POCycleInstance.CycleType = UsageCycleType.Weekly;
                        break;

                    case 5:
                        POCycleInstance.CycleType = UsageCycleType.Bi_weekly;
                        break;

                    case 6:
                        POCycleInstance.CycleType = UsageCycleType.Semi_monthly;
                        break;

                    case 7:
                        POCycleInstance.CycleType = UsageCycleType.Quarterly;
                        break;

                    case 8:
                        POCycleInstance.CycleType = UsageCycleType.Annually;
                        break;
                    case 9:
                        POCycleInstance.CycleType = UsageCycleType.Semi_Annually;
                        break;
                }            

                UsageCyclePanel.Visible = true;
                cbUsageCycleEnforced.Visible = false;
                LblEnforced.Visible = true;
                MTBillingCycleControl1.Visible = true;
                MTBillingCycleControl1.EnforceCycle = true;
                MTBillingCycleControl1.CycleList.Enabled = false;
            }
            else
            {
                UsageCyclePanel.Visible = false;
            }                    

        }
        else //Edit Case
        {       
       
           //LblEnforced.Visible = true;
           POCycleInstance = GroupSubscriptionInstance.Cycle;                
           UsageCyclePanel.Visible = true;
           AccountsPanel.Visible = false;          
           MTBillingCycleControl1.ReadOnly = true;
        }          

      }
      else
      {
        /* if (radSharedCounters.Checked)
          {
            PanelDiscountAccount.Visible = true;
          }*/  
      }

      
      //if (GroupSubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate == null)
      if(GroupSubscriptionInstance.SubscriptionSpan.StartDate == null)
      {
        GroupSubscriptionInstance.SubscriptionSpan.StartDate = ApplicationTime;
      }
      else
      {
        cbUsageCycleEnforced.Visible = false;
      }
     

      if (GroupSubscriptionInstance.SubscriptionSpan.EndDate == null)
      {
        if (GroupSubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate == null)
        {
          GroupSubscriptionInstance.SubscriptionSpan.EndDate = MetraTech.MetraTime.Max;
        }
        else
        {
          GroupSubscriptionInstance.SubscriptionSpan.EndDate = GroupSubscriptionInstance.ProductOffering.EffectiveTimeSpan.EndDate;
        }
      }

      // Bind Subscription Properties
      SpecCharacteristicsBinder.BindProperties(pnlSubscriptionProperties,
        GroupSubscriptionInstance, this, SpecValues);

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

    }
    else
    {
      /*if (radSharedCounters.Checked)
       {
         PanelDiscountAccount.Visible = true;
       }*/
    }
  }


  protected void CheckIsCorporate()
  {
    if (UI.Subscriber.SelectedAccount != null)
    {
      AccountTypeManager accountTypeManager = new AccountTypeManager();
      YAAC.MTYAAC yaac = new YAAC.MTYAAC();
      yaac.InitAsSecuredResource((int)UI.Subscriber.SelectedAccount._AccountID,
                                 (MetraTech.Interop.MTYAAC.IMTSessionContext)UI.SessionContext,
                                 ApplicationTime);
      IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)UI.SessionContext,
                                                                     yaac.AccountTypeID);
      isCorporate = accType.IsCorporate;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    bool OKFlag = true;

    try
    {
      Page.Validate();
      MTDataBinder1.Unbind();

      // Unbind Subscription Properties
      var charVals = new List<CharacteristicValue>();
      SpecCharacteristicsBinder.UnbindProperies(charVals, pnlSubscriptionProperties, SpecValues);
      GroupSubscriptionInstance.CharacteristicValues = charVals;

      DateTime dt1 = GroupSubscriptionInstance.SubscriptionSpan.StartDate.Value;
      
      //ESR-5661 fixed so that GS can be created with past start date but after PO start date
      DateTime dt2;

      if (GroupSubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate == null)
      {
        dt2 = MetraTech.MetraTime.Min;
      }
      else
      {
        dt2 = Convert.ToDateTime(GroupSubscriptionInstance.ProductOffering.EffectiveTimeSpan.StartDate);
      }

      if ( dt1.Date < dt2.Date )
      {
        string errorMsg = GetLocalResourceObject("ERROR_START_DATE").ToString();
        SetError(errorMsg);
        OKFlag = false;
      }

      GroupSubscriptionInstance.ProportionalDistribution = true;

      //FEAT-4446  Remove legacy rating options from MetraOffer/MetraCare/MetraView
      //if (radNoSharedCounters.Checked)
      //{
      //  GroupSubscriptionInstance.ProportionalDistribution = true;
      //}
      //else
      //{
      //  GroupSubscriptionInstance.ProportionalDistribution = false;
      //  if(tbAcctGrpDis.AccountID == "")
      //  {
      //    string Message = GetLocalResourceObject("ErrorGrpDis").ToString();
      //    SetError(Message);
      //    Logger.LogError(Message);
      //    PanelDiscountAccount.Style.Add("visibility", "visible");
      //    OKFlag = false;
      //    ShowDiscConfig = true;
      //  }
      //  else
      //  {
      //    int DiscAcctId = int.Parse(tbAcctGrpDis.AccountID);
      //    Account acc = new Account();
      //    acc = MetraTech.UI.Common.AccountLib.LoadAccount(DiscAcctId, UI.User, ApplicationTime);

      //    if (acc == null)
      //    {
      //      string Message = GetLocalResourceObject("ErrorGrpDis").ToString();
      //      SetError(Message);
      //      Logger.LogError(Message);
      //      PanelDiscountAccount.Style.Add("visibility", "visible");
      //      OKFlag = false;
      //      ShowDiscConfig = true;
      //    }
      //    else
      //    {
      //      GroupSubscriptionInstance.DiscountAccountId = DiscAcctId;
      //      ShowDiscConfig = false;
      //    }
          
      //  }
        
      //}

     // if (MTRadioControl2.Checked)
     // {
        GroupSubscriptionInstance.DiscountDistribution = DiscountDistribution.Account;
     // }

        bool submitFlag = true;
      if (OKFlag)
      {        
    
   // Add case
          
          Cycle AcctCycle = new Cycle();
          if (GroupSubscriptionInstance.Cycle == null)
          {              
              if (UI.Subscriber.SelectedAccount == null)
              {
                  Configure_UsageCycle();
                  if (AcctCycleInstance != null)
                  {
                      AcctCycle = AcctCycleInstance;
                  }
              }
              else //if account already loaded
              {
                  InternalView internalView = new InternalView();
                  internalView = (InternalView)UI.Subscriber.SelectedAccount.GetInternalView();
                  Account acct = UI.Subscriber.SelectedAccount;
                  Cycle cycle = new Cycle();
                  switch (internalView.UsageCycleType.Value)
                  {
                      case UsageCycleType.Monthly: // Monthly
                          {
                              cycle.CycleType = UsageCycleType.Monthly;
                              cycle.DayOfMonth = acct.DayOfMonth;
                              break;
                          }
                      case UsageCycleType.Daily: // Daily
                          {
                              cycle.CycleType = UsageCycleType.Daily;
                              break;
                          }
                      case UsageCycleType.Weekly: // Weekly
                          {
                              cycle.CycleType = UsageCycleType.Weekly;
                              cycle.DayOfWeek = acct.DayOfWeek;
                              break;
                          }
                      case UsageCycleType.Bi_weekly: // Bi-weekly
                          {
                              cycle.CycleType = UsageCycleType.Bi_weekly;
                              cycle.StartDay = acct.StartDay;
                              cycle.StartMonth = acct.StartMonth;
                              cycle.StartYear = acct.StartYear;
                              break;
                          }
                      case UsageCycleType.Semi_monthly: // Semi-monthly
                          {
                              cycle.CycleType = UsageCycleType.Semi_monthly;
                              cycle.FirstDayOfMonth = acct.FirstDayOfMonth;
                              cycle.SecondDayOfMonth = acct.SecondDayOfMonth;
                              break;
                          }
                      case UsageCycleType.Quarterly: // Quarterly
                          {
                              cycle.CycleType = UsageCycleType.Quarterly;
                              cycle.StartDay = acct.StartDay;
                              cycle.StartMonth = acct.StartMonth;
                              break;
                          }
                      case UsageCycleType.Annually: // Annually
                          {
                              cycle.CycleType = UsageCycleType.Annually;
                              cycle.StartDay = acct.StartDay;
                              cycle.StartMonth = acct.StartMonth;
                              break;
                          }
                      case UsageCycleType.Semi_Annually: // SemiAnnually
                          {
                            cycle.CycleType = UsageCycleType.Semi_Annually;
                            cycle.StartDay = acct.StartDay;
                            cycle.StartMonth = acct.StartMonth;
                            break;
                          }
                      default:
                          {
                              break;
                          }
                  }
                  AcctCycle = cycle;               
              } // else account already loaded  
              
              if (AcctCycle != null)
              {
                  if (GroupSubscriptionInstance.ProductOffering.UsageCycleType > 0)
                  {
                      //check cycle type
                      if (POCycleInstance.CycleType == AcctCycle.CycleType)
                      {
                          GroupSubscriptionInstance.Cycle = new Cycle();
                          GroupSubscriptionInstance.Cycle = AcctCycle;
                      }
                      else
                      {
                          SetError(GetLocalResourceObject("ErrorSelectAccount").ToString());
                          submitFlag = false;
                      }                 
                  }
                  else if (GroupSubscriptionInstance.ProductOffering.UsageCycleType == 0)
                  {
                      GroupSubscriptionInstance.Cycle = new Cycle();
                      GroupSubscriptionInstance.Cycle = AcctCycle;
                  }
              }

          }
          else //edit case
          {
               
          }

          if (submitFlag)
          {
              GroupSubscriptionsEvents_OKSetGroupSubscriptionDate_Client setGroupSubDate =
                  new GroupSubscriptionsEvents_OKSetGroupSubscriptionDate_Client();
              setGroupSubDate.In_AccountId = new AccountIdentifier(UI.User.AccountId);
              setGroupSubDate.In_GroupSubscriptionInstance = GroupSubscriptionInstance;
              PageNav.Execute(setGroupSubDate);
          }
      }
    }
    catch (Exception ex)
    {
      PanelDiscountAccount.Style.Add("visibility", "visible");
      if (OKFlag)
      {
        string Message = GetLocalResourceObject("ErrorAddGroupSub").ToString();
        SetError(Message);
      }
      else
      {
        string Message = GetLocalResourceObject("ErrorGrpDis").ToString();
        SetError(Message);
      }
      Logger.LogError(ex.Message);
    }

  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelSetGroupSubscriptionDate_Client cancel = new GroupSubscriptionsEvents_CancelSetGroupSubscriptionDate_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }

  protected void Configure_UsageCycle()
  {
      if (!String.IsNullOrEmpty(MTAccountSearch.AccountID))
      {
          Account acct = AccountLib.LoadAccount(Int32.Parse(MTAccountSearch.AccountID), UI.User, ApplicationTime);
          InternalView internalView = (InternalView)acct.GetInternalView();
          Cycle cycle = new Cycle();
          switch (internalView.UsageCycleType.Value)
          {
              case UsageCycleType.Monthly: // Monthly
                  {
                      cycle.CycleType = UsageCycleType.Monthly;
                      cycle.DayOfMonth = acct.DayOfMonth;
                      break;
                  }
              case UsageCycleType.Daily: // Daily
                  {
                      cycle.CycleType = UsageCycleType.Daily;
                      break;
                  }
              case UsageCycleType.Weekly: // Weekly
                  {
                      cycle.CycleType = UsageCycleType.Weekly;
                      cycle.DayOfWeek = acct.DayOfWeek;
                      break;
                  }
              case UsageCycleType.Bi_weekly: // Bi-weekly
                  {
                      cycle.CycleType = UsageCycleType.Bi_weekly;
                      cycle.StartDay = acct.StartDay;
                      cycle.StartMonth = acct.StartMonth;
                      cycle.StartYear = acct.StartYear;
                      break;
                  }
              case UsageCycleType.Semi_monthly: // Semi-monthly
                  {
                      cycle.CycleType = UsageCycleType.Semi_monthly;
                      cycle.FirstDayOfMonth = acct.FirstDayOfMonth;
                      cycle.SecondDayOfMonth = acct.SecondDayOfMonth;
                      break;
                  }
              case UsageCycleType.Quarterly: // Quarterly
                  {
                      cycle.CycleType = UsageCycleType.Quarterly;
                      cycle.StartDay = acct.StartDay;
                      cycle.StartMonth = acct.StartMonth;
                      break;
                  }
              case UsageCycleType.Semi_Annually: // Annually
                  {
                    cycle.CycleType = UsageCycleType.Semi_Annually;
                    cycle.StartDay = acct.StartDay;
                    cycle.StartMonth = acct.StartMonth;
                    break;
                  }

              case UsageCycleType.Annually: // Annually
                  {
                      cycle.CycleType = UsageCycleType.Annually;
                      cycle.StartDay = acct.StartDay;
                      cycle.StartMonth = acct.StartMonth;
                      break;
                  }
              default:
                  {
                      break;
                  }
          }
          AcctCycleInstance = cycle;

      }
  }
  
}
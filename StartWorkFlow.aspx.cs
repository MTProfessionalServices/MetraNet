using System;
using System.Data;
using System.Diagnostics;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTProductCatalog;


public partial class StartWorkFlow : MTPage
{
  private string mWorkflowName = null; 
  public string WorkflowName
  {
    get { return mWorkflowName; }
    set { mWorkflowName = value; }
  }

  private bool isCorporateAccount(int accID)
  {
    AccountTypeManager accountTypeManager = new AccountTypeManager();
    YAAC.MTYAAC yaac = new YAAC.MTYAAC();
    yaac.InitAsSecuredResource(accID,
                               (MetraTech.Interop.MTYAAC.IMTSessionContext)UI.SessionContext,
                               ApplicationTime);
    IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)UI.SessionContext,
                                                                   yaac.AccountTypeID);
    bool isCorporate = accType.IsCorporate;
    return isCorporate;
  }

  //Given any account, figure out which corporate account it lives under.  Return 0 if none found.
  //Move it to BaseTypes.Account
  protected int GetCorporateAcctForAcct(int accID)
  {
    MetraTech.DomainModel.BaseTypes.Account acc = MetraTech.UI.Common.AccountLib.LoadAccount(accID, UI.User, ApplicationTime);

    bool isCorporate = isCorporateAccount(accID);

    if (isCorporate)
    {
      return accID;
    }

    //fringe case - got all the way to the top, but no corporate accts detected
    if (!acc.AncestorAccountID.HasValue)
    {
      return 0;
    }

    //call recursively on ancestor
    return GetCorporateAcctForAcct(acc.AncestorAccountID.Value);
  }

  public static bool GlobalGroupSubActivated = false;

  protected void Page_Load(object sender, EventArgs e)
  {
    // We can not have a try/catch block here because we will get a "thread aborted"
    // error when the PageNave.Execute doees a redirect.
    //try
    //{
      if (Request["WorkFlowName"] != null)
      {
        WorkflowName = Request["WorkFlowName"].ToString();
      }

      // Populate Proxy Class
      switch (WorkflowName)
      {
        // Add Account
        case "AddAccountWorkflow":
          {
            // Create Account Proxy class
            if (Request["AccountType"] != null)
            {
              AddAccountEvents_StartAddAccountOfType_Client acc1 = new AddAccountEvents_StartAddAccountOfType_Client();
              acc1.In_AccountId = new AccountIdentifier(UI.User.AccountId);
              acc1.In_SelectedAccountType = Request["AccountType"];
              PageNav.Execute(acc1);
            }
            else if (Request["AncestorID"] != null)
            {
              AddAccountEvents_StartAddAccountWithTemplate_Client accWithTemplate = new AddAccountEvents_StartAddAccountWithTemplate_Client();
           
              AccountIdentifier templateIdentifier = new AccountIdentifier(int.Parse(Request["AncestorID"]));
              accWithTemplate.In_TemplateAccount = templateIdentifier;
              accWithTemplate.In_AccountId = new AccountIdentifier(UI.User.AccountId);
              accWithTemplate.In_TemplateEffectiveDate = ApplicationTime;
              PageNav.Execute(accWithTemplate);
            }
            else
            {
              AddAccountEvents_StartAddAccount_Client acc = new AddAccountEvents_StartAddAccount_Client();
              acc.In_AccountId = new AccountIdentifier(UI.User.AccountId);
              PageNav.Execute(acc);
            }
            break;
          }

        // Update Account
        case "UpdateAccountWorkflow":
          {
            // Update Account Proxy class
            UpdateAccountEvents_StartUpdateAccount_Client acc = new UpdateAccountEvents_StartUpdateAccount_Client();
            acc.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            acc.In_UpdateAccountId = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"].ToString()));
            acc.In_LoadTime = ApplicationTime;
            PageNav.Execute(acc);
            break;
          }

        // Update Contact Info
        case "ContactUpdateWorkflow":
          {
            // Update contact Proxy class
            ContactUpdateEvents_StartContactUpdate_Client acc = new ContactUpdateEvents_StartContactUpdate_Client();
            acc.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            acc.In_UpdateAccountId = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"].ToString()));
            PageNav.Execute(acc);
            break;
          }

        // Subscriptions
        case "SubscriptionsWorkflow":
          {
            // Subscriptions Proxy class
            SubscriptionsEvents_StartSubscriptions_Client acc = new SubscriptionsEvents_StartSubscriptions_Client();
            acc.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            acc.In_AccountIdentifier = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"].ToString()));
            if (!String.IsNullOrEmpty(Request["StartWithStep"]))
            {
              acc.In_StartWithStep = Request["StartWithStep"];
            }

            PageNav.Execute(acc);
            break;
          }

        // GroupSubscriptions
        case "GroupSubscriptionsWorkflow":
          {
            // Group Subscriptions Proxy class
            GroupSubscriptionsEvents_StartGroupSubscriptions_Client GroupSubAcct = new GroupSubscriptionsEvents_StartGroupSubscriptions_Client();

            if (GlobalGroupSubActivated)
            {
                if (UI.Subscriber.SelectedAccount == null)
                {
                    GroupSubAcct.In_AccountId = new AccountIdentifier(UI.User.AccountId);
                    GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(1);
                    GroupSubAcct.In_AccountType = "CorporateAccount";
                    GroupSubAcct.In_CorporateAccountIdentifier = new AccountIdentifier(1);
                }
                else
                {
                  GroupSubAcct.In_AccountId = new AccountIdentifier(UI.User.AccountId);
                  int idAcc = int.Parse(UI.Subscriber["_AccountID"].ToString());
                  bool isCorporate = isCorporateAccount(idAcc);
                  if (isCorporate)
                    GroupSubAcct.In_AccountType = "CorporateAccount";
                  else
                    GroupSubAcct.In_AccountType = UI.Subscriber.SelectedAccount.AccountType;
                  GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(idAcc);
                    GroupSubAcct.In_CorporateAccountIdentifier =
                        //new AccountIdentifier(int.Parse(UI.Subscriber.SelectedAccount.AncestorAccountID.Value.ToString()));
                                new AccountIdentifier(MetraTech.UI.Tools.Utils.GetCorporateAccountOfChildAccount(UI.Subscriber.SelectedAccount._AccountID.Value, ApplicationTime));     
                }
            }
            else
            {              
              GroupSubAcct.In_AccountId = new AccountIdentifier(UI.User.AccountId);
              int idAcc = int.Parse(UI.Subscriber["_AccountID"].ToString());
              bool isCorporate = isCorporateAccount(idAcc);
              if (isCorporate)
                GroupSubAcct.In_AccountType = "CorporateAccount";
              else
                GroupSubAcct.In_AccountType = UI.Subscriber.SelectedAccount.AccountType;
              GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(idAcc);
              GroupSubAcct.In_CorporateAccountIdentifier =
                //new AccountIdentifier(int.Parse(UI.Subscriber.SelectedAccount.AncestorAccountID.Value.ToString()));
                          new AccountIdentifier(MetraTech.UI.Tools.Utils.GetCorporateAccountOfChildAccount(UI.Subscriber.SelectedAccount._AccountID.Value, ApplicationTime));              
            }

            if (!String.IsNullOrEmpty(Request["StartWithStepGr"]))
            {
              GroupSubAcct.In_StartWithStepGr = Request["StartWithStepGr"];
            }

            PageNav.Execute(GroupSubAcct);           
            break;
          }


	// Global GroupSubscriptions Hierarchy rules relaxed
        case "GlobalGroupSubscriptionsWorkflow":
          {
              GlobalGroupSubActivated = true;
              GroupSubscriptionsEvents_StartGroupSubscriptions_Client GroupSubAcct = new GroupSubscriptionsEvents_StartGroupSubscriptions_Client();
              if (UI.Subscriber.SelectedAccount == null)
              {
                  // Subscriptions Proxy class                
                  GroupSubAcct.In_AccountId = new AccountIdentifier(UI.User.AccountId);
                  GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(1);
                  GroupSubAcct.In_AccountType = "CorporateAccount";
                  GroupSubAcct.In_CorporateAccountIdentifier = new AccountIdentifier(1);
              }
              else
              {
                  GroupSubAcct.In_AccountId = new AccountIdentifier(UI.User.AccountId);
                  int idAcc = int.Parse(UI.Subscriber["_AccountID"].ToString());
                  bool isCorporate = isCorporateAccount(idAcc);
                  if (isCorporate)
                    GroupSubAcct.In_AccountType = "CorporateAccount";
                  else
                    GroupSubAcct.In_AccountType = UI.Subscriber.SelectedAccount.AccountType;
                  GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(idAcc);
                  GroupSubAcct.In_CorporateAccountIdentifier =
                      //new AccountIdentifier(int.Parse(UI.Subscriber.SelectedAccount.AncestorAccountID.Value.ToString()));
                              new AccountIdentifier(MetraTech.UI.Tools.Utils.GetCorporateAccountOfChildAccount(UI.Subscriber.SelectedAccount._AccountID.Value, ApplicationTime));     
              }

             PageNav.Execute(GroupSubAcct);
             break;
          }


        // Account Templates
        case "TemplateWorkflow":
          {
            TemplateEvents_StartTemplateWorkflow_Client acc = new TemplateEvents_StartTemplateWorkflow_Client();
            acc.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            acc.In_AccountIdentifier = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"].ToString()));
            PageNav.Execute(acc);
            break;
          }

        // Account Templates on Account Move
        case "TemplateWorkflowMove":
          {
            // Parameters = &Mode=Move&AccountID=[ACCOUNTID]&AncestorAccountID=[ANCESTORACCOUNTID]&MoveStartDate=[MOVESTARTDATE]&Types=[TYPES]"
            string ancestor = Request.QueryString["AncestorAccountID"].ToString();
            TemplateEvents_StartMoveTemplateWorkflow_Client acc = new TemplateEvents_StartMoveTemplateWorkflow_Client();
            acc.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            acc.In_AccountIdentifier = new AccountIdentifier(int.Parse(ancestor));
            acc.In_MoveAccountsString = Request.QueryString["Types"].ToString();
            PageNav.Execute(acc);
            break;
          }

        
        default:
          break;

      }

   // }
   // catch (Exception exp)
   // {
   //   Logger.LogException("Error calling PageNav.Execute", exp);
   //   SetError(exp.Message.ToString());
   // }
  }


}

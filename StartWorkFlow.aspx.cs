using System;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTProductCatalog;


public partial class StartWorkFlow : MTPage
{
  public string WorkflowName { get; set; }

  private bool isCorporateAccount(int accID)
  {
    var accountTypeManager = new AccountTypeManager();
    var yaac = new YAAC.MTYAAC();
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
      WorkflowName = Request["WorkFlowName"];
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
            var acc1 = new AddAccountEvents_StartAddAccountOfType_Client
              {
                In_AccountId = new AccountIdentifier(UI.User.AccountId),
                In_SelectedAccountType = Request["AccountType"]
              };

            if (Request["ParentId"] != null)
            {
              acc1.In_ParentAccountId = int.Parse(Request["ParentId"]);
              acc1.In_ParentAccountName = Request["ParentName"];
            }

            PageNav.Execute(acc1);
          }
          else if (Request["AncestorID"] != null)
          {
            var accWithTemplate = new AddAccountEvents_StartAddAccountWithTemplate_Client();

            var templateIdentifier = new AccountIdentifier(int.Parse(Request["AncestorID"]));
            accWithTemplate.In_TemplateAccount = templateIdentifier;
            accWithTemplate.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            accWithTemplate.In_TemplateEffectiveDate = ApplicationTime;
            PageNav.Execute(accWithTemplate);
          }
          else
          {
            var acc = new AddAccountEvents_StartAddAccount_Client
              {
                In_AccountId = new AccountIdentifier(UI.User.AccountId)
              };
            PageNav.Execute(acc);
          }
          break;
        }

      // Update Account
      case "UpdateAccountWorkflow":
        {
          // Update Account Proxy class
          var acc = new UpdateAccountEvents_StartUpdateAccount_Client
            {
              In_AccountId = new AccountIdentifier(UI.User.AccountId),
              In_UpdateAccountId = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"])),
              In_LoadTime = ApplicationTime
            };
          PageNav.Execute(acc);
          break;
        }

      // Update Contact Info
      case "ContactUpdateWorkflow":
        {
          // Update contact Proxy class
          var acc = new ContactUpdateEvents_StartContactUpdate_Client
            {
              In_AccountId = new AccountIdentifier(UI.User.AccountId),
              In_UpdateAccountId = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"]))
            };
          PageNav.Execute(acc);
          break;
        }

      // Subscriptions
      case "SubscriptionsWorkflow":
        {
          // Subscriptions Proxy class
          var acc = new SubscriptionsEvents_StartSubscriptions_Client
            {
              In_AccountId = new AccountIdentifier(UI.User.AccountId),
              In_AccountIdentifier = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"]))
            };
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
          var GroupSubAcct = new GroupSubscriptionsEvents_StartGroupSubscriptions_Client();

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
              int idAcc = int.Parse(UI.Subscriber["_AccountID"]);
              bool isCorporate = isCorporateAccount(idAcc);
              GroupSubAcct.In_AccountType = isCorporate ? "CorporateAccount" : UI.Subscriber.SelectedAccount.AccountType;
              GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(idAcc);
              if (UI.Subscriber.SelectedAccount._AccountID != null)
                GroupSubAcct.In_CorporateAccountIdentifier =
                  //new AccountIdentifier(int.Parse(UI.Subscriber.SelectedAccount.AncestorAccountID.Value.ToString()));
                  new AccountIdentifier(MetraTech.UI.Tools.Utils.GetCorporateAccountOfChildAccount(UI.Subscriber.SelectedAccount._AccountID.Value, ApplicationTime));
            }
          }
          else
          {
            GroupSubAcct.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            int idAcc = int.Parse(UI.Subscriber["_AccountID"]);
            bool isCorporate = isCorporateAccount(idAcc);
            GroupSubAcct.In_AccountType = isCorporate ? "CorporateAccount" : UI.Subscriber.SelectedAccount.AccountType;
            GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(idAcc);
            if (UI.Subscriber.SelectedAccount._AccountID != null)
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
          var GroupSubAcct = new GroupSubscriptionsEvents_StartGroupSubscriptions_Client();
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
            int idAcc = int.Parse(UI.Subscriber["_AccountID"]);
            bool isCorporate = isCorporateAccount(idAcc);
            GroupSubAcct.In_AccountType = isCorporate ? "CorporateAccount" : UI.Subscriber.SelectedAccount.AccountType;
            GroupSubAcct.In_AccountIdentifier = new AccountIdentifier(idAcc);
            if (UI.Subscriber.SelectedAccount._AccountID != null)
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
          var acc = new TemplateEvents_StartTemplateWorkflow_Client
            {
              In_AccountId = new AccountIdentifier(UI.User.AccountId),
              In_AccountIdentifier = new AccountIdentifier(int.Parse(UI.Subscriber["_AccountID"]))
            };
          PageNav.Execute(acc);
          break;
        }

      // Account Templates on Account Move
      case "TemplateWorkflowMove":
        {
          // Parameters = &Mode=Move&AccountID=[ACCOUNTID]&AncestorAccountID=[ANCESTORACCOUNTID]&MoveStartDate=[MOVESTARTDATE]&Types=[TYPES]"
          string ancestor = Request.QueryString["AncestorAccountID"];
          var acc = new TemplateEvents_StartMoveTemplateWorkflow_Client
            {
              In_AccountId = new AccountIdentifier(UI.User.AccountId),
              In_AccountIdentifier = new AccountIdentifier(int.Parse(ancestor)),
              In_MoveAccountsString = Request.QueryString["Types"]
            };
          PageNav.Execute(acc);
          break;
        }

      case "AddPartitionWorkflow":
        {
          var addPartitionClient = new AddPartitionEvents_StartAddPartition_Client
            {
              In_AccountId = new AccountIdentifier(UI.User.AccountId)
            };
          PageNav.Execute(addPartitionClient);
          break;
        }
    }

    // }
    // catch (Exception exp)
    // {
    //   Logger.LogException("Error calling PageNav.Execute", exp);
    //   SetError(exp.Message.ToString());
    // }
  }


}

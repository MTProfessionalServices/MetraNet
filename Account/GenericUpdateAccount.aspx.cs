using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;


public partial class GenericUpdateAccount : MTAccountPage
{

  //Approval Framework Code Starts Here 
  public int? bAccountUpdateApprovalsEnabled
  {
    get { return ViewState["bAccountUpdateApprovalsEnabled"] as int?; }
    set { ViewState["bAccountUpdateApprovalsEnabled"] = value; }
  } //so we can read it any time in the session

  public bool bAllowMoreThanOnePendingChange { get; set; }
  public bool bAccountHasPendingChange { get; set; }
  public string strChangeType { get; set; }
  //Approval Framework Code Ends Here 

  private readonly List<string> skipProperties = new List<string>();
  private void SetupSkipProperties()
  {
    skipProperties.Add("username");
    skipProperties.Add("ancestoraccountns");
    skipProperties.Add("ancestoraccount");
    skipProperties.Add("password_");
    skipProperties.Add("accountstartdate");
    skipProperties.Add("name_space");
    skipProperties.Add("applydefaultsecuritypolicy");
    skipProperties.Add("internal.timezoneid");
    skipProperties.Add("payerid");
    skipProperties.Add("accountstartdate");
    skipProperties.Add("internal.language");
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      Account = PageNav.Data.Out_StateInitData["Account"] as Account;
      if (Account == null) return;

      var Properties = Account.GetType().GetProperties();
      foreach (var property in Properties)
      {
        object Result = property.GetValue(Account, null);
        if (Result == null)
        {
          try
          {
            Type type = property.PropertyType;
            if (!type.ToString().Contains("System."))
              property.SetValue(Account, Activator.CreateInstance(type), null);
          }
          catch (Exception exp)
          {
            Logger.LogWarning(exp.Message);
          }
        }
      }
      
      MTGenericForm1.RenderObjectType = Account.GetType();
      MTGenericForm1.RenderObjectInstanceName = "Account";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.ReadOnly = false;
      SetupSkipProperties();
      MTGenericForm1.IgnoreProperties = skipProperties;

      #region Approval Framework Code Starts Here 

      var client = new ApprovalManagementServiceClient();

      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }
      strChangeType = "AccountUpdate";
      bAccountHasPendingChange = false;
      bAccountUpdateApprovalsEnabled = 0;

      var mactc = new MTList<ChangeTypeConfiguration>();

      client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

      if (mactc.Items[0].Enabled)
      {
        bAccountUpdateApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
      }

      if (bAccountUpdateApprovalsEnabled == 1)
      {
        bAllowMoreThanOnePendingChange = mactc.Items[0].AllowMoreThanOnePendingChange;

        List<int> pendingchangeids;
        string straccountid = UI.Subscriber.SelectedAccount._AccountID.ToString();

        client.GetPendingChangeIdsForItem(strChangeType, straccountid, out pendingchangeids);

        if (pendingchangeids.Count != 0)
        {
          bAccountHasPendingChange = true;
        }

        if (!bAllowMoreThanOnePendingChange)
        {
          if (bAccountHasPendingChange)
          {
            //todo potential localization issue
            SetError("This account already has Account Update type pending change. This type of change does not allow more than one pending changes.");
            Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", UI.Subscriber.SelectedAccount.UserName, "AccountUpdate"));
            btnOK.Visible = false;
            client.Abort();
          }
        }

        if (bAccountHasPendingChange)
        {
          //todo potential localization issue
          const string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
          const string strPendingChangeWarning = "This account already has pending change in the approval framework queue. " + approvalframeworkmanagementurl + " Click here to view pending changes.";
          divLblMessage.Visible = true;
          lblMessage.Text = strPendingChangeWarning;
        }

      }

      #endregion//Approval Framework Code Ends Here

    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      var update = new UpdateAccountEvents_UpdateAccount_Client
        {
          In_Account = Account,
          In_AccountId = new AccountIdentifier(UI.User.AccountId),
          In_ApplyAccountTemplates = cbApplyTemplate.Checked,
          In_LoadTime = ApplicationTime,
          In_IsApprovalEnabled = bAccountUpdateApprovalsEnabled == 1
        };

      //Approval Framework related code starts here

      //Approval Framework related code ends here

      PageNav.Execute(update);

    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    var cancel = new UpdateAccountEvents_CancelUpdateAccount_Client
      {
        In_AccountId = new AccountIdentifier(UI.User.AccountId)
      };
    PageNav.Execute(cancel);
  }


}

using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.UI.Tools;
using MetraTech.ActivityServices.Common;
using MetraTech.Approvals;
using System.Windows.Forms;
using MetraTech.Core.Services.ClientProxies;
using System.Xml.Serialization;

public partial class Account_ContactUpdate : MTPage
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

  public ContactView Contact
  {
    get { return ViewState["SelectedContact"] as ContactView; }
    set { ViewState["SelectedContact"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      Contact = PageNav.Data.Out_StateInitData["SelectedContact"] as ContactView;
      if(Contact == null) return;

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = Contact.GetType();
      MTGenericForm1.RenderObjectInstanceName = "Contact";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.ReadOnly = false;

      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

      if (Contact.ContactType != null)
      {
        ddContactType.ReadOnly = true;
      }
      else
      {
        // remove existing contact types from drop down
        //Account acc = UI.Subscriber.SelectedAccount;
        //foreach (ContactView v in (List<ContactView>)Utils.GetProperty(acc, "LDAP"))
        //{
        //  ListItem itm = ddContactType.Items.FindByValue(v.ContactType.ToString());
        //  ddContactType.Items.Remove(itm);
        //}

        //// remove none
        //ListItem itmNone = ddContactType.Items.FindByValue("None");
        //ddContactType.Items.Remove(itmNone);
      }
      //Approval Framework Code Starts Here 

      ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      strChangeType = "AccountUpdate";
      bAccountHasPendingChange = false;
      bAccountUpdateApprovalsEnabled = 0;

      MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

      client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

      if (mactc.Items[0].Enabled)
      {
        bAccountUpdateApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }

      if (bAccountUpdateApprovalsEnabled == 1)
      {
        bAllowMoreThanOnePendingChange = mactc.Items[0].AllowMoreThanOnePendingChange;

        List<int> pendingchangeids;
        string straccountid = "";
        straccountid = UI.Subscriber.SelectedAccount._AccountID.ToString();

        client.GetPendingChangeIdsForItem(strChangeType, straccountid, out pendingchangeids);

        if (pendingchangeids.Count != 0)
        {
          bAccountHasPendingChange = true;
  }

        if (!bAllowMoreThanOnePendingChange)
        {
          if (bAccountHasPendingChange)
          {
            SetError("This account already has Account Update type pending change. This type of change does not allow more than one pending changes.");
            this.Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", UI.Subscriber.SelectedAccount.UserName, "AccountUpdate"));
            btnOK.Visible = false;
            client.Abort();
          }

        }

        if (bAccountHasPendingChange)
        {
          string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
          string strPendingChangeWarning = "This account already has pending change in the approval framework queue." + approvalframeworkmanagementurl + " Click here to view pending changes.";
          divLblMessage.Visible = true;
          lblMessage.Text = strPendingChangeWarning;
        }

      }
      //Approval Framework Code Ends Here 
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    if (Contact.ContactType == null)
    {
      Account acc = UI.Subscriber.SelectedAccount;
      foreach (ContactView v in (List<ContactView>) Utils.GetProperty(acc, "LDAP"))
      {
        ListItem itm = ddContactType.Items.FindByValue(v.ContactType.ToString());
        ddContactType.Items.Remove(itm);
      }

      // remove none
      ListItem itmNone = ddContactType.Items.FindByValue("None");
      ddContactType.Items.Remove(itmNone);
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();
      ContactUpdateEvents_OKUpdateContact_Client update = new ContactUpdateEvents_OKUpdateContact_Client();
      update.In_SelectedContact = Contact;
      update.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      update.In_LoadTime = ApplicationTime;

      PageNav.Execute(update);    
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    ContactUpdateEvents_CancelContactUpdate_Client cancel = new ContactUpdateEvents_CancelContactUpdate_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }

}

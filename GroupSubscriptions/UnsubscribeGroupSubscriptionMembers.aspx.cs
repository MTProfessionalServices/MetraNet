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
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Approvals;
using System.Collections.Generic;
using MetraTech.Core.Services.ClientProxies;


public partial class GroupSubscriptions_UnsubscribeGroupSubscriptionMembers : MTPage
{
  //Approval Framework Code Starts Here 
  public int? bGroupSubscriptionUnsubscribeMembersApprovalsEnabled
  {
    get { return ViewState["bGroupSubscriptionUnsubscribeMembersApprovalsEnabled"] as int?; }
    set { ViewState["bGroupSubscriptionUnsubscribeMembersApprovalsEnabled"] = value; }
  } //so we can read it any time in the session

  public bool bAllowMoreThanOnePendingChange { get; set; }
  public bool bGroupSubHasPendingChange { get; set; }
  public string strChangeType { get; set; }
  //Approval Framework Code Ends Here 


  public GroupSubscription CurrentGroupSubscription
  {
    get { return ViewState["CurrentGroupSubscription"] as GroupSubscription; }
    set { ViewState["CurrentGroupSubscription"] = value; }
  }


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      CurrentGroupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;

      if (CurrentGroupSubscription.Name != "")
      {
        Panel1.Text = Panel1.Text + " (" + CurrentGroupSubscription.Name + ")";
      }

      if (!this.MTDataBinder1.DataBind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

      string gsid = "";
      gsid = CurrentGroupSubscription.GroupId.ToString();
      CheckPendingChanges(gsid);


    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Page.Validate();
      MTDataBinder1.Unbind();

      GroupSubscriptionMember gsm = new GroupSubscriptionMember();
      gsm.MembershipSpan.EndDate = Convert.ToDateTime(this.MTEffecEndDatePicker.Text);

      //Moving this to page load event
      //string gsid = "";
      //gsid = CurrentGroupSubscription.GroupId.ToString();
      //CheckPendingChanges(gsid);


      GroupSubscriptionsEvents_OKUnsubscribeGroupSubscriptionMembers_Client unsubscribe =
          new GroupSubscriptionsEvents_OKUnsubscribeGroupSubscriptionMembers_Client();
      unsubscribe.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      unsubscribe.In_GroupSubscriptionMember = gsm;
      
      //Approval Framework related code starts here
      if (bGroupSubscriptionUnsubscribeMembersApprovalsEnabled == 1)
      {
        unsubscribe.In_IsApprovalEnabled = true;
      }
      else
      { 
        unsubscribe.In_IsApprovalEnabled = false; 
      }
      //Approval Framework related code ends here

      PageNav.Execute(unsubscribe);

      // Show the change submitted confirmation page if this change is submitted to the approval framework
      if (bGroupSubscriptionUnsubscribeMembersApprovalsEnabled == 1)
      {
          Session["RedirectLoc"] = Response.RedirectLocation;
          Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
      }

    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorUnsubscribeGroupSubMember").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelUnsubscribeGroupSubscriptionMembers_Client cancel =
        new GroupSubscriptionsEvents_CancelUnsubscribeGroupSubscriptionMembers_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }

  protected void CheckPendingChanges(string groupsubid)
  {
    ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

    strChangeType = "GroupSubscription.UnsubscribeMembers";
    bGroupSubHasPendingChange = false;
    bGroupSubscriptionUnsubscribeMembersApprovalsEnabled = 0;

    MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bGroupSubscriptionUnsubscribeMembersApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }

    if (bGroupSubscriptionUnsubscribeMembersApprovalsEnabled == 1)
    {
      bAllowMoreThanOnePendingChange = mactc.Items[0].AllowMoreThanOnePendingChange;

      List<int> pendingchangeids;
      client.GetPendingChangeIdsForItem(strChangeType, groupsubid, out pendingchangeids);

      if (pendingchangeids.Count != 0)
      {
        bGroupSubHasPendingChange = true;
      }

      if (!bAllowMoreThanOnePendingChange)
      {
        if (bGroupSubHasPendingChange)
        {
          SetError("This Group Subscription has Unsubscribe Members type pending change. This type of change does not allow more than one pending changes.");
          this.Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", groupsubid, strChangeType));
        }

      }

      if (bGroupSubHasPendingChange)
      {
        string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
        string strPendingChangeWarning = "This Group Subscription has Unsubscribe Members type pending change." + approvalframeworkmanagementurl + " Click here to view pending changes.";

        divLblMessage.Visible = true;
        lblMessage.Text = strPendingChangeWarning;
      }
    }
    //Approval Framework Code Ends Here 
  }
}

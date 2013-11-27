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

public partial class GroupSubscriptions_DeleteGroupSubscriptionMembers : MTPage
{

  //Approval Framework Code Starts Here 
  public int? bGroupSubscriptionDeleteMembersApprovalsEnabled
  {
    get { return ViewState["bGroupSubscriptionDeleteMembersApprovalsEnabled"] as int?; }
    set { ViewState["bGroupSubscriptionDeleteMembersApprovalsEnabled"] = value; }
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
        MTPanel1.Text = GetLocalResourceObject("PanelTitle").ToString() + " (" + CurrentGroupSubscription.Name + ")";
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
      GroupSubscriptionsEvents_OKDeleteGroupSubscriptionMembers_Client del = new GroupSubscriptionsEvents_OKDeleteGroupSubscriptionMembers_Client();
      del.In_AccountId = new AccountIdentifier(UI.User.AccountId);


      //Moving this to page load event
      //string gsid = "";
      //gsid = CurrentGroupSubscription.GroupId.ToString();
      //CheckPendingChanges(gsid);

      //Approval Framework related code starts here
      if (bGroupSubscriptionDeleteMembersApprovalsEnabled == 1)
      {
        del.In_IsApprovalEnabled = true;
      }
      else
      { del.In_IsApprovalEnabled = false; }
      //Approval Framework related code ends here

      PageNav.Execute(del);

      // Show the change submitted confirmation page if this change is submitted to the approval framework
      if (bGroupSubscriptionDeleteMembersApprovalsEnabled == 1)
      {
          Session["RedirectLoc"] = Response.RedirectLocation;
          Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
      }

    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorDeleteGroupSubMember").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelDeleteGroupSubscriptionMembers_Client cancel = new GroupSubscriptionsEvents_CancelDeleteGroupSubscriptionMembers_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }


  protected void CheckPendingChanges(string groupsubid)
  {
    ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

    strChangeType = "GroupSubscription.DeleteMembers";
    bGroupSubHasPendingChange = false;
    bGroupSubscriptionDeleteMembersApprovalsEnabled = 0;

    MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bGroupSubscriptionDeleteMembersApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }

    if (bGroupSubscriptionDeleteMembersApprovalsEnabled == 1)
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
          SetError("This Group Subscription has Delete Members type pending change. This type of change does not allow more than one pending changes.");
          this.Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", groupsubid, strChangeType));
        }

      }

      if (bGroupSubHasPendingChange)
      {
        string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
        string strPendingChangeWarning = "This Group Subscription has Delete Members type pending change." + approvalframeworkmanagementurl + " Click here to view pending changes.";

        divLblMessage.Visible = true;
        lblMessage.Text = strPendingChangeWarning;
      }
    }
    //}
    //Approval Framework Code Ends Here 

  }

}

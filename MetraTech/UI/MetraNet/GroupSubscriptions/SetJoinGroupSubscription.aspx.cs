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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;

public partial class GroupSubscriptions_SetJoinGroupSubscription : MTPage
{

  //Approval Framework Code Starts Here 
  public int? bGroupSubscriptionAddMembersApprovalsEnabled
  {
    get { return ViewState["bGroupSubscriptionAddMembersApprovalsEnabled"] as int?; }
    set { ViewState["bGroupSubscriptionAddMembersApprovalsEnabled"] = value; }
  } //so we can read it any time in the session

  public bool bAllowMoreThanOnePendingChange { get; set; }
  public bool bGroupSubHasPendingChange { get; set; }
  public string strChangeType { get; set; }
  //Approval Framework Code Ends Here 


  public int GroupSubscriptionId
  {
    get { return (int)ViewState["GroupSubscriptionId"]; }
    set { ViewState["GroupSubscriptionId"] = value; }
  }

  public GroupSubscription CurrentGroupSubscription
  {
    get { return ViewState["CurrentGroupSubscription"] as GroupSubscription; }
    set { ViewState["CurrentGroupSubscription"] = value; }
  }


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      try
      {
        CurrentGroupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;

        if (CurrentGroupSubscription.Name != "")
        {
          Panel1.Text = Panel1.Text + " (" + CurrentGroupSubscription.Name + ")";
          MTEffecStartDatePicker.Text = CurrentGroupSubscription.SubscriptionSpan.StartDate.Value.ToShortDateString();
          MTEffecEndDatePicker.Text = CurrentGroupSubscription.SubscriptionSpan.EndDate.Value.ToShortDateString();
        }

        this.tbAccountName.Text = UI.Subscriber.SelectedAccount.UserName;
        GroupSubscriptionId = (int)PageNav.Data.Out_StateInitData["GroupSubscriptionId"];
      }
      catch (Exception ex)
      {
        string Message = GetLocalResourceObject("ErrorJoinGroupSub").ToString();
        SetError(Message);
        Logger.LogError(ex.Message);
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
      gsm.AccountId = UI.Subscriber.SelectedAccount._AccountID.Value;
      gsm.AccountName = UI.Subscriber.SelectedAccount.UserName;
      gsm.MembershipSpan.StartDate = Convert.ToDateTime(this.MTEffecStartDatePicker.Text);
      gsm.MembershipSpan.EndDate = Convert.ToDateTime(this.MTEffecEndDatePicker.Text).AddDays(1).AddSeconds(-1);
      gsm.GroupId = GroupSubscriptionId;

      //Moving this to page load event 
      //string gsid = "";
      //gsid = CurrentGroupSubscription.GroupId.ToString();
      //CheckPendingChanges(gsid);

      List<GroupSubscriptionMember> gsmlist = new List<GroupSubscriptionMember>();
      gsmlist.Add(gsm);

      GroupSubscriptionsEvents_OK_SetGroupSubscriptionJoin_Client okSetGroupSubscriptionJoinClient =
          new GroupSubscriptionsEvents_OK_SetGroupSubscriptionJoin_Client();
      okSetGroupSubscriptionJoinClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      okSetGroupSubscriptionJoinClient.In_SelectedGroupSubscriptionMemberList = gsmlist;
      okSetGroupSubscriptionJoinClient.In_GroupSubscriptionId = GroupSubscriptionId;

      //Approval Framework related code starts here
      if (bGroupSubscriptionAddMembersApprovalsEnabled == 1)
      {
        okSetGroupSubscriptionJoinClient.In_IsApprovalEnabled = true;
      }
      else
      {
        okSetGroupSubscriptionJoinClient.In_IsApprovalEnabled = false;
      }
      //Approval Framework related code ends here


      PageNav.Execute(okSetGroupSubscriptionJoinClient);

      // Show the change submitted confirmation page if this change is submitted to the approval framework
      if (bGroupSubscriptionAddMembersApprovalsEnabled == 1)
      {
          Session["RedirectLoc"] = Response.RedirectLocation;
          Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
      }

    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorJoinGroupSub").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelSetGroupSubscriptionJoin_Client cancelSetGroupSubscriptionJoinClient =
        new GroupSubscriptionsEvents_CancelSetGroupSubscriptionJoin_Client();
    cancelSetGroupSubscriptionJoinClient.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancelSetGroupSubscriptionJoinClient);
  }

  protected void CheckPendingChanges(string groupsubid)
  {
    ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

    strChangeType = "GroupSubscription.AddMembers";
    bGroupSubHasPendingChange = false;
    bGroupSubscriptionAddMembersApprovalsEnabled = 0;

    MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bGroupSubscriptionAddMembersApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }

    if (bGroupSubscriptionAddMembersApprovalsEnabled == 1)
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
          SetError("This Group Subscription has Add Members type pending change. This type of change does not allow more than one pending changes.");
          this.Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", groupsubid, strChangeType));
        }

      }

      if (bGroupSubHasPendingChange)
      {
        string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
        string strPendingChangeWarning = "This Group Subscription has Add Members type pending change." + approvalframeworkmanagementurl + " Click here to view pending changes.";

        divLblMessage.Visible = true;
        lblMessage.Text = strPendingChangeWarning;
      }
    }
    //Approval Framework Code Ends Here 
  }


}
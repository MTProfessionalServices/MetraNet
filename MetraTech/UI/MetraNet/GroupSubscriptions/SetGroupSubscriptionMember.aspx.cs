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

using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;

public partial class GroupSubscriptions_SetGroupSubscriptionMember : MTPage
{
  //Approval Framework Code Starts Here 
  public int? bGroupSubscriptionUpdateMemberApprovalsEnabled
  {
    get { return ViewState["bGroupSubscriptionUpdateMemberApprovalsEnabled"] as int?; }
    set { ViewState["bGroupSubscriptionUpdateMemberApprovalsEnabled"] = value; }
  } //so we can read it any time in the session

  public bool bAllowMoreThanOnePendingChange { get; set; }
  public bool bGroupSubHasPendingChange { get; set; }
  public string strChangeType { get; set; }
  //Approval Framework Code Ends Here 

  
  public GroupSubscriptionMember GroupSubscriptionMember
  {
    get { return ViewState["GroupSubscriptionMember"] as GroupSubscriptionMember; }
    set { ViewState["GroupSubscriptionMember"] = value; }
  }

  public GroupSubscription CurrentGroupSubscription
  {
    get { return ViewState["CurrentGroupSubscription"] as GroupSubscription; }
    set { ViewState["CurrentGroupSubscription"] = value; }
  }


  protected override void OnLoadComplete(EventArgs e)
  {
   /* if (MTGenericForm1.PanelList.Count > 0)
    {
      //set the panel test
      MTGenericForm1.PanelList[0].Text = HttpUtility.HtmlEncode(String.Format(GetLocalResourceObject("PANEL_TEXT").ToString(), CurrentGroupSubscription.Name)).Replace("'","\\'");
    }*/
    base.OnLoadComplete(e);
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      CurrentGroupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;

      if (CurrentGroupSubscription.Name != "")
      {
        lblSetGroupSubMemberTitle.Text = 
          HttpUtility.HtmlEncode(GetLocalResourceObject("lblSetGroupSubMemberTitleResource1.Text").ToString()).Replace("'", "\\'");
      }

      GroupSubscriptionMember = (MetraTech.DomainModel.ProductCatalog.GroupSubscriptionMember)PageNav.Data.Out_StateInitData["GroupSubscriptionMember"];

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = GroupSubscriptionMember.GetType();
      MTGenericForm1.RenderObjectInstanceName = "GroupSubscriptionMember";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.TemplateName = "GroupSubscriptionMember";
      MTGenericForm1.ReadOnly = false;

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
      GroupSubscriptionsEvents_OKSetGroupSubscriptionMember_Client setGroupSubMember = new GroupSubscriptionsEvents_OKSetGroupSubscriptionMember_Client();
      setGroupSubMember.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      DateTime? temp = GroupSubscriptionMember.MembershipSpan.EndDate.Value;
      GroupSubscriptionMember.MembershipSpan.EndDate = temp.Value.AddDays(1).AddSeconds(-1);
      setGroupSubMember.In_GroupSubscriptionMember = GroupSubscriptionMember;

     //Moving this to page load event
     // string gsid = "";
     // gsid = CurrentGroupSubscription.GroupId.ToString();
     // CheckPendingChanges(gsid);

      //Approval Framework related code starts here
      if (bGroupSubscriptionUpdateMemberApprovalsEnabled == 1)
      {
        setGroupSubMember.In_IsApprovalEnabled = true;
      }
      else
      { setGroupSubMember.In_IsApprovalEnabled = false; }
      //Approval Framework related code ends here


      PageNav.Execute(setGroupSubMember);

      // Show the change submitted confirmation page if this change is submitted to the approval framework
      if (bGroupSubscriptionUpdateMemberApprovalsEnabled == 1)
      {
          Session["RedirectLoc"] = Response.RedirectLocation;
          Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
      }

    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorEditGrpSubMember").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelSetGroupSubscriptionMember_Client cancel = new GroupSubscriptionsEvents_CancelSetGroupSubscriptionMember_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }

  protected void CheckPendingChanges(string groupsubid)
  {
    ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

    strChangeType = "GroupSubscription.UpdateMember";
    bGroupSubHasPendingChange = false;
    bGroupSubscriptionUpdateMemberApprovalsEnabled = 0;

    MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bGroupSubscriptionUpdateMemberApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }

    if (bGroupSubscriptionUpdateMemberApprovalsEnabled == 1)
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
          SetError("This Group Subscription has Update Member type pending change. This type of change does not allow more than one pending changes.");
          this.Logger.LogError(string.Format("The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.", groupsubid, strChangeType));
        }

      }

      if (bGroupSubHasPendingChange)
      {
        string approvalframeworkmanagementurl = "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
        string strPendingChangeWarning = "This Group Subscription has Update Member type pending change." + approvalframeworkmanagementurl + " Click here to view pending changes.";

        divLblMessage.Visible = true;
        lblMessage.Text = strPendingChangeWarning;
      }
    }
    //Approval Framework Code Ends Here 
  }
}

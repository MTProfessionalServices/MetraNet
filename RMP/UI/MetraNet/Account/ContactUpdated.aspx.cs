using System;
using MetraTech.UI.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;

using MetraTech.UI.Tools;
using MetraTech.ActivityServices.Common;
using System.Windows.Forms;


public partial class ContactUpdated : MTPage
{
  public int? bAccountUpdateApprovalsEnabled
  {
    get { return ViewState["bAccountUpdateApprovalsEnabled"] as int?; }
    set { ViewState["bAccountUpdateApprovalsEnabled"] = value; }
  } //so we can read it any time in the session
  public string strChangeType { get; set; }

  
  protected void Page_Load(object sender, EventArgs e)
  {
    //Approval Framework Code Starts Here 

    ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    strChangeType = "AccountUpdate";

    bAccountUpdateApprovalsEnabled = 0;

    MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bAccountUpdateApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }

    if (bAccountUpdateApprovalsEnabled == 1)
    {
      lblMessage.Text = Server.HtmlEncode(GetLocalResourceObject("contactchangesubmittedSuccessMsg").ToString());
      lblTitle.Text = Server.HtmlEncode(GetLocalResourceObject("contactchangesubmittedSuccessTitle").ToString());
    }

    else
    {
    lblMessage.Text = Server.HtmlEncode(GetLocalResourceObject("contactUpdateSuccessMsg").ToString());
    lblTitle.Text = Server.HtmlEncode(GetLocalResourceObject("contactUpdateSuccessTitle").ToString());
  }

}

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Response.Redirect("/MetraNet/StartWorkFlow.aspx?WorkFlowName=ContactUpdateWorkflow");
  }
}

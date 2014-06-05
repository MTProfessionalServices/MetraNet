using System;
using MetraTech.UI.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;


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

    var client = new ApprovalManagementServiceClient();

    if (client.ClientCredentials != null)
    {
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    }
    strChangeType = "AccountUpdate";

    bAccountUpdateApprovalsEnabled = 0;

    var mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bAccountUpdateApprovalsEnabled = 1;// mactc.Items[0].Enabled; 
    }
    // ReSharper disable PossibleNullReferenceException
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
    // ReSharper disable Html.PathError
    Response.Redirect("/MetraNet/StartWorkFlow.aspx?WorkFlowName=ContactUpdateWorkflow");
    // ReSharper restore Html.PathError
  }
}

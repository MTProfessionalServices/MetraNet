using System;
using MetraTech.UI.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;

public partial class Account_AccountUpdated : MTPage
{

  public int UpdatedAccountId
  {
    get { return int.Parse(ViewState["UpdatedAccountId"].ToString()); }
    set { ViewState["UpdatedAccountId"] = value; }
  }

  public int? bAccountUpdateApprovalsEnabled
  {
    get { return ViewState["bAccountUpdateApprovalsEnabled"] as int?; }
    set { ViewState["bAccountUpdateApprovalsEnabled"] = value; }
  } //so we can read it any time in the session
  public string strChangeType { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      UpdatedAccountId = int.Parse(((Account)PageNav.Data.Out_StateInitData["Account"])._AccountID.ToString());
    }

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

    if (bAccountUpdateApprovalsEnabled == 1)
    {
      var resourceObject = GetLocalResourceObject("accountchangesubmittedSuccessTitle");
      if (resourceObject != null)
        Panel1.Text = Server.HtmlEncode(resourceObject.ToString());

      var localResourceObject = GetLocalResourceObject("accountchangesubmittedSuccessMsg");
      if (localResourceObject != null)
        Label1.Text = Server.HtmlEncode(localResourceObject.ToString());
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    /** Redirected to Account Summary page -  fix for bug CORE-628 */
    Response.Redirect(UI.DictionaryManager["AccountSummaryPage"].ToString());
  }
}

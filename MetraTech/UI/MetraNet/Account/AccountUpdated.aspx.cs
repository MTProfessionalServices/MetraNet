using System;
using MetraTech.UI.Common;
using MetraTech.Approvals;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;

using MetraTech.UI.Tools;
using MetraTech.ActivityServices.Common;
using System.Windows.Forms;

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
      UpdatedAccountId =int.Parse(((MetraTech.DomainModel.BaseTypes.Account)PageNav.Data.Out_StateInitData["Account"])._AccountID.ToString());
    }

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
      Panel1.Text = Server.HtmlEncode(GetLocalResourceObject("accountchangesubmittedSuccessTitle").ToString()); ;
      Label1.Text = Server.HtmlEncode(GetLocalResourceObject("accountchangesubmittedSuccessMsg").ToString());
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    /** Redirected to Account Summary page -  fix for bug CORE-628 */
    Response.Redirect(UI.DictionaryManager["AccountSummaryPage"].ToString());
  }
}

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
using MetraTech.DomainModel;
using MetraTech.ActivityServices.Common;

public partial class Templates_AddTemplate : MTPage
{
  public ArrayList AccountTypes
  {
    get { return ViewState["AccountTypes"] as ArrayList; }
    set { ViewState["AccountTypes"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      AccountTypes = PageNav.Data.Out_StateInitData["AccountTypes"] as ArrayList;

      if(AccountTypes.Count == 0)
      {
        PanelControls.Visible = false;
        PanelMessage.Visible = true;
        btnOK.Visible = false;
      }

      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    TemplateEvents_CancelAddTemplate_Client cancel = new TemplateEvents_CancelAddTemplate_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }
}
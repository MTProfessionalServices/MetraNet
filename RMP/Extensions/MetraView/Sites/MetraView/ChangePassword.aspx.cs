using System;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class ChangePassword : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      if(Session["ChangePasswordMsg"] != null)
      {
        lblMessage.Text = "<b>" + Session["ChangePasswordMsg"] + "</b>";
      }

      lblMessage.Text += GetLocalResourceObject("TEXT_STANDARD_CHANGE_PASSWORD_MSG");
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Auth auth = new Auth();
      auth.Initialize(UI.User.UserName, SiteConfig.AuthSettings.AuthenticationNamespace);
      if (auth.ChangePassword(tbOldPassword.Text, tbNewPassword.Text, UI.SessionContext))
      {
        // Password change successful
        Session["ChangePasswordMsg"] = null;
        Response.Redirect(UI.DictionaryManager["ChangePasswordSuccessPage"].ToString(), false);
      }
      else
      {
          Session[Constants.ERROR] = GetLocalResourceObject("InvalidOldpassword");
      }
    }
    catch(Exception)
    {
      Session[Constants.ERROR] = GetLocalResourceObject("InvalidPassword");
    }

  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
  }
}
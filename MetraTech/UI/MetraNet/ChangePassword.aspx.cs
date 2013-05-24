using System;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class ChangePassword : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    tbUserName.Text = UI.User.UserName;

    if (!IsPostBack)
    {
      if(Session["ChangePasswordMsg"] != null)
      {
        lblMessage.Text = string.Format("<b>{0}</b>", Session["ChangePasswordMsg"]);
      }

      lblMessage.Text += GetLocalResourceObject("TEXT_STANDARD_CHANGE_PASSWORD_MSG");

      if ((UI.User.UserName.ToLower() == "su") &&
          (UI.User.NameSpace.ToLower() == "system_user"))
      {
        lblMessage.Text += GetLocalResourceObject("TEXT_SU_NOTE");
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      var auth = new Auth();
      auth.Initialize(tbUserName.Text, "system_user");
      if (auth.ChangePassword(tbOldPassword.Text, tbNewPassword.Text, UI.SessionContext))
      {
        // Password change successful
        Session["ChangePasswordMsg"] = null;
        Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString(), false);
      }
    }
    catch(Exception exp)
    {
      Session[Constants.ERROR] = exp.Message;
    }

  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
  }
}
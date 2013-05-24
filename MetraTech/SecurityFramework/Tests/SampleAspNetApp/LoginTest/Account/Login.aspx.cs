using System;
using System.Web.UI.WebControls;
using System.Web.Security;
using MetraTech.SecurityFramework;

namespace WebApplication1.Account
{
  public partial class Login : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
     // RegisterHyperLink.NavigateUrl = "Register.aspx?ReturnUrl=" + HttpUtility.UrlEncode(Request.QueryString["ReturnUrl"]);
    }

    protected void LoginUser_Authenticate(object sender, AuthenticateEventArgs e)
    {
      if (FormsAuthentication.Authenticate(LoginUser.UserName, LoginUser.Password))
      {
        SecurityKernel.SecurityMonitor.Api.ReportLogin();

        FormsAuthentication.RedirectFromLoginPage(LoginUser.UserName, LoginUser.RememberMeSet);
      }
      else
      {
       //TODO: login fail
      }
    }
  }
}

using System;
using System.Web.Security;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using LoginStatus = MetraTech.Security.LoginStatus;
using MetraTech.ActivityServices.Services.Common;

public partial class login : MTPage
{
  private const string SYSTEM_USER_NAMESPACE = "system_user";
  private const int m_ticketLifeSpanInMins = 65;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI != null)
    {
      UI.Subscriber.CloseAccount();
    }
    
    Login1.Focus();
  }

  // Change Password OK Handler
  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Auth auth = new Auth();
      auth.Initialize(tbUserName.Text, SYSTEM_USER_NAMESPACE);

      MetraTech.Security.LoginStatus loginStatus = AttemptLogin(tbUserName.Text, tbOldPassword.Text, SYSTEM_USER_NAMESPACE);

      if ((loginStatus == MetraTech.Security.LoginStatus.OK) || (loginStatus == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon))
      {
        if (auth.ChangePassword(tbOldPassword.Text, tbNewPassword.Text, UI.SessionContext))
        {
          // Password change was successful... redirect to DefaultPage.
          Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
        }
        else  // Unable to change password
        {
          reasonText.InnerHtml = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
          ShowPopup.Value = "true";
        }
      }
      else  // Failed login
      {
        reasonText.InnerHtml = GetLoginStatusText(loginStatus);
        ShowPopup.Value = "true";
      }
    }
    catch (Exception exp)
    {
      reasonText.InnerHtml =  Server.HtmlEncode(exp.Message);
      ShowPopup.Value = "true";
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Session.Abandon();
    FormsAuthentication.SignOut();

    pnlChangePassword.Visible = false;
    pnlLogin.Visible = true;
  }
  
  protected void Login1_Authenticate(object sender, AuthenticateEventArgs e)
  {
    DoLogin();
  }

  private MetraTech.Security.LoginStatus AttemptLogin(string username, string password, string name_space)
  {
    if(username.ToLower() == "su")
      return LoginStatus.NoCapabilityToLogonToThisApplication;

    UI = new UIManager();

    // Attempt Login
    object tmp = null;  //IMTSessionContext

    Auth auth = new Auth();
    auth.Initialize(username, name_space);
    MetraTech.Security.LoginStatus status = auth.Login(password, null, ref tmp);
    IMTSessionContext context = tmp as IMTSessionContext;
    if ((status == MetraTech.Security.LoginStatus.OK) || (status == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon))
    {
        IMTSessionContext sessionContext = tmp as IMTSessionContext;
        string ticket = TicketManager.CreateTicket(context.AccountID, name_space, username, m_ticketLifeSpanInMins);
        SetupUserData(username, name_space, sessionContext, ticket);
    }

    return status;
  }

  private string GetLoginStatusText(MetraTech.Security.LoginStatus status)
  {
    String strErrText = string.Empty;

    switch (status)
    {
      case MetraTech.Security.LoginStatus.OK:
        break;

      case MetraTech.Security.LoginStatus.OKPasswordExpiringSoon:
        Auth auth = new Auth();
        auth.Initialize(tbUserName.Text, SYSTEM_USER_NAMESPACE);
        int days = auth.DaysUntilPasswordExpires();

        strErrText = String.Format(Resources.ErrorMessages.ERROR_LOGIN_PASSWORD_EXPIRING, days);
        break;

      case MetraTech.Security.LoginStatus.FailedUsernameOrPassword:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      case MetraTech.Security.LoginStatus.FailedPasswordExpired:
        strErrText = Resources.ErrorMessages.ERROR_PASSWORD_EXPIRED;
        break;

      case MetraTech.Security.LoginStatus.NoCapabilityToLogonToThisApplication:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      default:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;
    }

    return strErrText;
  }

  private void DoLogin()
  {
    // Create a UIManager
    UI = new UIManager();

    // Retrieve username and password from control
    string userName = Login1.UserName;
    string password = Login1.Password;


    // Attempt Login
    // SECENG: ESR-4117 BSS 28332 MetraNet Security Framework DoS (Unauthenticated) (SecEx)
    // The login logic updated with Password and UserName limitations: like it is in NetMeter DB fields size (255 for UserName and 1024 for Password)
    if ((!string.IsNullOrEmpty(userName) && userName.Length > 255) ||
        (!string.IsNullOrEmpty(password) && password.Length > 1024))
    {
        Login1.FailureText = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        return;
    }

    object tmp = null;  //IMTSessionContext
    Auth auth = new Auth();
    auth.Initialize(userName, SYSTEM_USER_NAMESPACE, userName, "MetraNet");
    MetraTech.Security.LoginStatus status = auth.Login(password, null, ref tmp);
    IMTSessionContext sessionContext = tmp as IMTSessionContext;
    string ticket = "";
    // Don't generate ticket if user not authenticated
    if (status == MetraTech.Security.LoginStatus.OK || status == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon)
    {
        ticket = TicketManager.CreateTicket(sessionContext.AccountID, SYSTEM_USER_NAMESPACE, userName, m_ticketLifeSpanInMins);
    }
    if (userName.ToLower() == "su")
      status = LoginStatus.NoCapabilityToLogonToThisApplication;

    string err = "";
    switch (status)
    {
      // Success cases
      case MetraTech.Security.LoginStatus.OK:
        SetupUserData(userName, SYSTEM_USER_NAMESPACE, sessionContext, ticket);
        if (UI.CoarseCheckCapability("Manage Account Hierarchies"))
        {
          // CORE-4889 - Session Identifier Not Updated 
          WebUtils.RegenerateSessionId();
          Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());  
        }
        else
        {
          err = Resources.ErrorMessages.ERROR_CAPABILITY_INVALID;
        }
        break;

      case MetraTech.Security.LoginStatus.OKPasswordExpiringSoon:
       
        //PasswordManager passwordManager = new PasswordManager();
        //passwordManager.Initialize(userName, SYSTEM_USER_NAMESPACE);
       // int days = passwordManager.DaysUntilPasswordExpires();

        // if days <= 0 then show change password panel, except for su which requires special steps.
//if (days <= 0)
//{
        //  if (userName.ToLower() != "su")
        //  {
            pnlLogin.Visible = false;
            pnlChangePassword.Visible = true;

            tbUserName.Text = userName;
            break;
        //  }
//}

//SetupUserData(userName, SYSTEM_USER_NAMESPACE, sessionContext);

      //  Session["ChangePasswordMsg"] = String.Format(Resources.ErrorMessages.ERROR_LOGIN_PASSWORD_EXPIRING, days);
      //  Server.Transfer(UI.DictionaryManager["DefaultPage"] + "?URL=" + Encrypt(UI.DictionaryManager["ChangePasswordPage"].ToString()));
     //   break;
      
      // Error cases 
      case MetraTech.Security.LoginStatus.FailedUsernameOrPassword:
        err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      case MetraTech.Security.LoginStatus.FailedPasswordExpired:
        err = Resources.ErrorMessages.ERROR_PASSWORD_EXPIRED;
        break;

      case MetraTech.Security.LoginStatus.NoCapabilityToLogonToThisApplication:
        err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      case MetraTech.Security.LoginStatus.FailedUsernameIsLocked:
        err = Resources.ErrorMessages.ERROR_LOGIN_LOCKED;
        break;

      default:
        err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;
    }
    Login1.FailureText = err;

  }

  private void SetupUserData(string userName, string nameSpace, IMTSessionContext sessionContext, string ticket)
  {
    // Setup user data
    UI.User.UserName = userName;
    UI.User.NameSpace = nameSpace;
    UI.User.AccountId = sessionContext.AccountID;
    UI.User.SessionContext = sessionContext;
    UI.User.Ticket = ticket;

    // Logon was valid.
    FormsAuthentication.SetAuthCookie(userName, false);
    Logger.LogDebug("Account " + UI.User.AccountId.ToString() + " logged into MetraNet.");
  }
}

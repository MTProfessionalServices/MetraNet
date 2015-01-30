using System;
using System.Globalization;
using System.Threading;
using System.Web.Security;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums;

public partial class login : MTPage
{
  private string _nameSpace;
  private string _authApp;
  private const int m_ticketLifeSpanInMins = 65;
  private int _currLanguage;
  
  protected override void OnPreInit(EventArgs e)
  {
    if (!String.IsNullOrEmpty(Request.QueryString["l"]))
    {

      Session[Constants.SELECTED_LANGUAGE] = Request.QueryString["l"];
    }
    else
    {
      if (!String.IsNullOrEmpty(SiteConfig.Settings.Culture))
      {
        if (Session[Constants.SELECTED_LANGUAGE] == null)
        {
          Session[Constants.SELECTED_LANGUAGE] = SiteConfig.Settings.Culture;
        }
      }
      else
      {
        Session[Constants.SELECTED_LANGUAGE] = "en-US";
      }
    }
    Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(Session[Constants.SELECTED_LANGUAGE].ToString());
    Thread.CurrentThread.CurrentUICulture = new CultureInfo(Session[Constants.SELECTED_LANGUAGE].ToString());

    base.OnPreInit(e);
  }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    _nameSpace = SiteConfig.AuthSettings.AuthenticationNamespace;
    _authApp = SiteConfig.AuthSettings.AuthenticationCapabilityApplicationValue;
    _currLanguage =  Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1));

    if (UI != null)
    {
      UI.Subscriber.CloseAccount();
    }
    
    Login1.Focus();
    reasonText.InnerHtml = "";
  }

  // Change Password OK Handler
  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Auth auth = new Auth();
      auth.Initialize(tbUserName.Text, _nameSpace);

      MetraTech.Security.LoginStatus loginStatus = AttemptLogin(tbUserName.Text, tbOldPassword.Text, _nameSpace);

      if ((loginStatus == MetraTech.Security.LoginStatus.OK) || (loginStatus == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon))
      {
        if (auth.ChangePassword(tbOldPassword.Text, tbNewPassword.Text, UI.SessionContext))
        {
          // Password change was successful... redirect to DefaultPage or Select Bill Page
          var capabilites = UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Impersonation");
          if (capabilites.Count == 0)
            Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
          else
            Response.Redirect(UI.DictionaryManager["SelectBillPage"].ToString());            
        }
        else  // Unable to change password
        {
          reasonText.InnerHtml = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        }
      }
      else  // Failed login
      {
        reasonText.InnerHtml = GetLoginStatusText(loginStatus);
      }
    }
    catch (Exception exp)
    {
      if (exp.Message.Contains("The new password does not meet security requirements"))
      {
        object title = Resources.ErrorMessages.ERROR_PASSWORD_DOESNT_MEET_REQUIREMENTS;
        reasonText.InnerHtml = title != null 
          ? Server.HtmlEncode(title.ToString()).Replace("\r\n", "<br/>") 
          : Server.HtmlEncode(exp.Message).Replace("\r\n", "<br/>");
      }
      else
        reasonText.InnerHtml = Server.HtmlEncode(exp.Message).Replace("\r\n", "<br/>");
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
    UI = new UIManager();

    // Attempt Login
    object tmp = null;  //IMTSessionContext

    Auth auth = new Auth();
    auth.Initialize(username, name_space, username, "MetraView", _currLanguage);
    MetraTech.Security.LoginStatus status = auth.Login(password, _authApp, ref tmp);
    if((status == MetraTech.Security.LoginStatus.OK) || (status == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon))
    {
      IMTSessionContext sessionContext = tmp as IMTSessionContext;
      string ticket = MetraTech.ActivityServices.Services.Common.TicketManager.CreateTicket(sessionContext.AccountID, name_space, username, m_ticketLifeSpanInMins);
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
        auth.Initialize(tbUserName.Text, _nameSpace);
        int days = auth.DaysUntilPasswordExpires();

        strErrText = String.Format(Resources.ErrorMessages.ERROR_LOGIN_PASSWORD_EXPIRING, days);
        break;

      case MetraTech.Security.LoginStatus.FailedUsernameOrPassword:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      case MetraTech.Security.LoginStatus.FailedPasswordExpired:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_LOCKED;
        break;

      case MetraTech.Security.LoginStatus.NoCapabilityToLogonToThisApplication:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      case MetraTech.Security.LoginStatus.FailedUsernameIsLocked:
        strErrText = Resources.ErrorMessages.ERROR_LOGIN_LOCKED;
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
    auth.Initialize(userName, _nameSpace, userName, "MetraView", _currLanguage);
    MetraTech.Security.LoginStatus status = auth.Login(password, _authApp, ref tmp);
    IMTSessionContext sessionContext = tmp as IMTSessionContext;
    string ticket = "";
    // Don't generate ticket if user not authenticated
    if (status == MetraTech.Security.LoginStatus.OK || status == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon)
    {
        ticket = MetraTech.ActivityServices.Services.Common.TicketManager.CreateTicket(sessionContext.AccountID, _nameSpace, userName, m_ticketLifeSpanInMins);
    }

    string err = "";
    switch (status)
    {
      // Success cases
      case MetraTech.Security.LoginStatus.OK:
        SetupUserData(userName, _nameSpace, sessionContext, ticket);
        if(SiteConfig.IsSiteDownForMaintenance(UI))
        {
          err = Resources.Resource.TEXT_SITE_DOWN_FOR_MAINTENANCE;
        }
        else
        {
          var capabilites = UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Impersonation");
          for (int i = 1; i <= capabilites.Count; i++ )
          {
            string t = capabilites[i].GetType().ToString();
          }
          if (capabilites.Count == 0)
              Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
            else
              Response.Redirect(UI.DictionaryManager["SelectBillPage"].ToString());  
        }
        break;

      case MetraTech.Security.LoginStatus.OKPasswordExpiringSoon:

        auth = new Auth();
        auth.Initialize(userName, _nameSpace);
        int days = auth.DaysUntilPasswordExpires();

        // if days <= 0 then show change password panel, except for su which requires special steps.
        if (days <= 0)
        {
          if (userName.ToLower() != "su")
          {
            pnlLogin.Visible = false;
            pnlChangePassword.Visible = true;

            tbUserName.Text = userName;
            break;
          }
        }

        SetupUserData(userName, _nameSpace, sessionContext, ticket);

        Session["ChangePasswordMsg"] = String.Format(Resources.ErrorMessages.ERROR_LOGIN_PASSWORD_EXPIRING, days);

        if (SiteConfig.IsSiteDownForMaintenance(UI))
        {
          err = Resources.Resource.TEXT_SITE_DOWN_FOR_MAINTENANCE;
        }
        else
        {
            Response.Redirect(UI.DictionaryManager["DefaultPage"] + "?URL=" + Encrypt(UI.DictionaryManager["ChangePasswordPage"].ToString()) + "&Crypto=true");
        }
        break;
      
      // Error cases 
      case MetraTech.Security.LoginStatus.FailedUsernameOrPassword:
        err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
        break;

      case MetraTech.Security.LoginStatus.FailedPasswordExpired:
        err = Resources.ErrorMessages.ERROR_LOGIN_LOCKED;
        auth.LockAccount();
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

    // Load the logged in account as the subscriber
    Account acc = AccountLib.LoadAccount(UI.User.AccountId, UI.User, MetraTech.MetraTime.Now);
    if (acc != null)
    {
      UI.Subscriber.SelectedAccount = acc;
    }

    // Load User Profile (SiteConfig.Profile)
    Session["UserProfile"] = BusinessEntityHelper.LoadUserProfile(acc);

    // Logon was valid.
    FormsAuthentication.SetAuthCookie(Request.ApplicationPath + userName, false);
    Logger.LogInfo(String.Format("{0} logged into {1}.", userName, Request.ApplicationPath));
    Session["Username"] = userName;

    Session[SiteConstants.Interval] = null;
    Session[SiteConstants.SelectedIntervalId] = null;
  }

}

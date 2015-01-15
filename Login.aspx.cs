using System;
using System.Web.Security;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;
using LoginStatus = MetraTech.Security.LoginStatus;
using MetraTech.ActivityServices.Services.Common;
using System.Globalization;

public partial class login : MTPage
{
    private const string SYSTEM_USER_NAMESPACE = "system_user";
    private const int m_ticketLifeSpanInMins = 65;
    public string dataLangNum = "1";
    public String userNameTxt = " UserName";
    public String passwordTxt = "Password";
    public String newpasswordTxt = "New Password";
    public String confirmnewpasswordTxt = "Confirm New Password";

    public String loginTxt = "Login";
    public String showFailureText = "false";
    public String showChangePasswdFailureText = "false";
    public string language = "en-US";

    public string enterPasswordTxt;
    public string enterNewPasswordTxt;
    public string enterConfirmPasswordTxt;
    public string passwordsDontMatchTxt;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (UI != null)
        {
            UI.Subscriber.CloseAccount();
        }


        //Login1.LoginButtonText = GetLocalResourceObject("Login1Resource1.LoginButtonText").ToString();
        userNameTxt = GetLocalResourceObject("Login1Resource1.UserNameLabelText").ToString();
        passwordTxt = GetLocalResourceObject("Login1Resource1.PasswordLabelText").ToString();
        newpasswordTxt = string.Format("{0}", GetLocalResourceObject("NEW_PASSWORD_TEXT"));
        confirmnewpasswordTxt = string.Format("{0}", GetLocalResourceObject("CONFIRM_PASSWORD_TEXT")); 
        language = (string)Session[Constants.SELECTED_LANGUAGE];
     
        Button btnLogin = (Button)Login1.FindControl("Login");
        btnLogin.Text =  GetLocalResourceObject("Login1Resource1.LoginButtonText").ToString();

        enterPasswordTxt = string.Format("{0}", GetLocalResourceObject("ENTER_PASSWORD"));
        enterNewPasswordTxt = string.Format("{0}", GetLocalResourceObject("ENTER_NEW_PASSWORD"));
        enterConfirmPasswordTxt = string.Format("{0}", GetLocalResourceObject("ENTER_CONFIRM_PASSWORD"));
        passwordsDontMatchTxt = string.Format("{0}", GetLocalResourceObject("PASSWORDS_DONT_MATCH"));

        showFailureText = "false";
        showChangePasswdFailureText = "false";
        Page.Title = (string)GetLocalResourceObject("PageResource1.Title");
        Login1.Focus();
    }



    protected override void OnPreInit(EventArgs e)
    {
        if (!String.IsNullOrEmpty(Request.QueryString["l"]))
        {

            Session[Constants.SELECTED_LANGUAGE] = Request.QueryString["l"];
            dataLangNum = Request.QueryString.Get("datalangnum");

        }
        else
        {
           Session[Constants.SELECTED_LANGUAGE] = "en-US";
           dataLangNum = "1";

            
        }
        System.Threading.Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(Session[Constants.SELECTED_LANGUAGE].ToString());
        System.Threading.Thread.CurrentThread.CurrentUICulture = new CultureInfo(Session[Constants.SELECTED_LANGUAGE].ToString());

        base.OnPreInit(e);
    }

    // Change Password OK Handler
    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        try
        {

            Auth auth = new Auth();
            auth.Initialize(Login1.UserName, SYSTEM_USER_NAMESPACE);

            MetraTech.Security.LoginStatus loginStatus = AttemptLogin(Login1.UserName, CurrentPassword.Text, SYSTEM_USER_NAMESPACE);


            if ((loginStatus == MetraTech.Security.LoginStatus.OK) || (loginStatus == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon))
            {
                if (auth.ChangePassword(CurrentPassword.Text, NewPassword.Text, UI.SessionContext))
                {
                    // Password change was successful... redirect to DefaultPage.
                    Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString());
                }
                else  // Unable to change password
                {

                    divChangePasswdFailureText.InnerHtml = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
                    showChangePasswdFailureText = "true";
                }
            }
            else  // Failed login
            {
              divChangePasswdFailureText.InnerHtml = GetLoginStatusText(loginStatus);
              showChangePasswdFailureText = "true"; 
            }
        }
        catch (Exception exp)
        {
          divChangePasswdFailureText.InnerHtml =
            Server.HtmlEncode(exp.Message.Contains("The new password does not meet security requirements")
                                ? Resources.ErrorMessages.ERROR_PASSWORD_DOESNT_MEET_REQUIREMENTS
                                : exp.Message);
          showChangePasswdFailureText = "true";
        }
    var currLanguage = Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1));

        pnlChangePassword.Visible = true;
        pnlLogin.Visible = false;
        pnlLogin.Style.Add("display", "none");
        pnlChangePassword.Style.Add("display", "block");
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Session.Abandon();
        FormsAuthentication.SignOut();

        pnlChangePassword.Visible = false;
        pnlLogin.Visible = true;
        pnlLogin.Style.Add("display", "block");
        pnlChangePassword.Style.Add("display", "none");
       
    }

    protected void Login1_Authenticate(object sender, AuthenticateEventArgs e)
    {
        DoLogin();
    }

    private MetraTech.Security.LoginStatus AttemptLogin(string username, string password, string name_space)
    {
        if (username.ToLower() == "su")
            return LoginStatus.NoCapabilityToLogonToThisApplication;

        UI = new UIManager();

        // Attempt Login
        object tmp = null;  //IMTSessionContext
        var currLanguage = Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1));
        Auth auth = new Auth();
        auth.Initialize(username, name_space, currLanguage);
        MetraTech.Security.LoginStatus status = auth.Login(password, null, ref tmp);

        IMTSessionContext context = tmp as IMTSessionContext;
        if ((status == MetraTech.Security.LoginStatus.OK) || (status == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon))
        {
            IMTSessionContext sessionContext = tmp as IMTSessionContext;
            string ticket = TicketManager.CreateTicket(context.AccountID, name_space, username, m_ticketLifeSpanInMins, currLanguage);
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
                auth.Initialize(Login1.UserName, SYSTEM_USER_NAMESPACE);
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
      showFailureText = "true";

      return;
    }

    object tmp = null; //IMTSessionContext
        Auth auth = new Auth();
        var currLanguage = Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1));
        auth.Initialize(userName, SYSTEM_USER_NAMESPACE, userName, "MetraNet", currLanguage);
       MetraTech.Security.LoginStatus status = auth.Login(password, null, ref tmp);
        IMTSessionContext sessionContext = tmp as IMTSessionContext;

        string ticket = "";
        // Don't generate ticket if user not authenticated

    //GOWRI:Uncomment to check the change passwd
   //status = MetraTech.Security.LoginStatus.OKPasswordExpiringSoon;

        if (status == MetraTech.Security.LoginStatus.OK || status == MetraTech.Security.LoginStatus.OKPasswordExpiringSoon)
        {
     ticket = TicketManager.CreateTicket(sessionContext.AccountID, SYSTEM_USER_NAMESPACE, userName, m_ticketLifeSpanInMins, currLanguage);
        }

        if (userName.ToLower() == "su")
            status = LoginStatus.NoCapabilityToLogonToThisApplication;

        string err = "";
    bool isChangePwd = false;

    
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
        pnlLogin.Style.Add("display", "none");
        pnlChangePassword.Style.Add("display","block");
        pnlChangePassword.Visible = true;

         Logger.LogInfo("Change password is " + userName);
        isChangePwd = true;
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

        if (err != "")
        {
          if(!isChangePwd)
            showFailureText = "true";
        }

    }

    private void SetupUserData(string userName, string nameSpace, IMTSessionContext sessionContext, string ticket)
    {
        // Setup user data
        UI.User.UserName = userName;
        UI.User.NameSpace = nameSpace;
        UI.User.AccountId = sessionContext.AccountID;
        UI.User.SessionContext = sessionContext;
        UI.User.Ticket = ticket;

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Store Partition Information for this user - to be used in other screens to limit what this account can see
        PartitionData partitionData = PartitionLibrary.RetrievePartitionInformation();
        UI.User.SetData("PartitionData", partitionData);
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // Logon was valid.
        FormsAuthentication.SetAuthCookie(userName, false);
        Logger.LogDebug("Account " + UI.User.AccountId.ToString() + " logged into MetraNet.");
    }
}

using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using Core.UI.Interface;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;

public partial class Mobile_Login : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Create a UIManager
    UI = new UIManager();

    // Retrieve username and password from control
    string username = Request["username"];
    string password = Request["password"];

    object tmp = null;  //IMTSessionContext
    Auth auth = new Auth();
    auth.Initialize(username, "mt" /*SiteConfig.AuthSettings.AuthenticationNamespace*/ );
    LoginStatus status = auth.Login(password, SiteConfig.AuthSettings.AuthenticationCapabilityApplicationValue, ref tmp);
    IMTSessionContext sessionContext = tmp as IMTSessionContext;
    string result = "";
    string result1 = "{ \"success\": \"";
    string result2 = "\", \"id\": ";
    string result3= "}";

    switch (status)
    {
      // Success cases
      case LoginStatus.OK:
      case LoginStatus.OKPasswordExpiringSoon:
        SetupUserData(username, "mt" /*SiteConfig.AuthSettings.AuthenticationNamespace*/, sessionContext);
        result = result1 + "true" + result2 + UI.Subscriber.SelectedAccount._AccountID + result3;
        break;

      // Error cases 
      case LoginStatus.FailedUsernameOrPassword:
      case LoginStatus.FailedPasswordExpired:
      case LoginStatus.NoCapabilityToLogonToThisApplication:
        result = result1 + "false" + result2 + "0" + result3;
        break;
    }

    Response.Write(result);
    Response.End();
  }

  private void SetupUserData(string userName, string nameSpace, IMTSessionContext sessionContext)
  {
    // Setup user data
    UI.User.UserName = userName;
    UI.User.NameSpace = nameSpace;
    UI.User.AccountId = sessionContext.AccountID;
    UI.User.SessionContext = sessionContext;

    // Load the logged in account as the subscriber
    Account acc = AccountLib.LoadAccount(UI.User.AccountId, UI.User, MetraTech.MetraTime.Now);
    if (acc != null)
    {
      UI.Subscriber.SelectedAccount = acc;
      Session["Username"] = userName;
      Session[SiteConstants.Interval] = null;
      Session[SiteConstants.SelectedIntervalId] = null;
    }

    // Load User Profile (SiteConfig.Profile)
    Session["UserProfile"] = BusinessEntityHelper.LoadUserProfile(acc);

    // Logon was valid.
    FormsAuthentication.SetAuthCookie(Request.ApplicationPath + userName, false);
    Logger.LogInfo(String.Format("{0} logged into {1}.", userName, Request.ApplicationPath));
  }

}
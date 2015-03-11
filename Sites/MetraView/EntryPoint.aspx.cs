using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.Security;
using Core.UI.Interface;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.UI.Common;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;

public partial class EntryPointPage : MTPage
{
  private const int m_ticketLifeSpanInMins = 65;

  protected void Page_Load(object sender, EventArgs e)
  {
    HttpContext.Current.Response.AddHeader("p3p", "CP=\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\"");
    // Create a UIManager
    UI = new UIManager();

    // Retrieve username and password from control
    string userName = Request.QueryString["UserName"];
    string nameSpace = Request.QueryString["NameSpace"];
    string ticket = Request.QueryString["Ticket"];
    string loadAccount = Request.QueryString["LoadAccount"];
    string URL = Request.QueryString["URL"];
    string Name = Request.QueryString["Name"];
    string refstr = Request.QueryString["ref"];
    //Set session variables to logout from asp applications when MetraView user logs out. Valid only when MetraView is loaded from MetraCare
    Session["IsMAMActive"] = string.IsNullOrEmpty(Request.QueryString["IsMAMActive"]) ? "" : Request.QueryString["IsMAMActive"];
    Session["IsMOMActive"] = string.IsNullOrEmpty(Request.QueryString["IsMOMActive"]) ? "" : Request.QueryString["IsMOMActive"];
    Session["IsMCMActive"] = string.IsNullOrEmpty(Request.QueryString["IsMCMActive"]) ? "" : Request.QueryString["IsMCMActive"];

    SetMetraViewLanguage(string.IsNullOrEmpty(Request.QueryString["LanguageCode"]) ? "" : Request.QueryString["LanguageCode"]);

    
    // Get URL for entrypoint name
    if(!String.IsNullOrEmpty(Name))
    {
      var entryPoints = SiteConfig.Settings.EntryPoints as List<IEntryPoint>;
      if (entryPoints != null)
      {
        var entryPoint = entryPoints.Find(ep => ((Core.UI.EntryPoint)ep).EntryPointBusinessKey.EntryPointName.ToLower() == Name.ToLower());
        URL = entryPoint.Url;
      }
    }

    if (String.IsNullOrEmpty(URL))
    {
      URL = UI.DictionaryManager["DefaultPage"].ToString();
    }

    object tmp = null;  //IMTSessionContext
    Auth auth = new Auth();
    auth.Initialize(userName, nameSpace);
    LoginStatus status = auth.LoginWithTicket(ticket, ref tmp);
    IMTSessionContext sessionContext = tmp as IMTSessionContext;
    string err = "";

    Session[Constants.PAGE_RUNNING_FROM_METRANET] = (Request.UrlReferrer != null) && Request.UrlReferrer.Host.Equals(auth.DecryptStringData(refstr), StringComparison.InvariantCultureIgnoreCase);

    //check if session context allows access to metraview
    IMTSecurity security = new MTSecurity();
    MetraTech.Interop.MTAuth.IMTCompositeCapability appLogon = security.GetCapabilityTypeByName("Application LogOn").CreateInstance();
    MetraTech.Interop.MTAuth.IMTEnumTypeCapability enumCap = appLogon.GetAtomicEnumCapability();
    enumCap.SetParameter("MPS");
    bool hasAccessToMV = sessionContext.SecurityContext.HasAccess(appLogon);
    if (!hasAccessToMV)
    {
      err = Resources.ErrorMessages.ERROR_LOGIN_INVALID; 
    }
    if (hasAccessToMV)
    {
      switch (status)
      {
        // Success cases
        case LoginStatus.OK:
          SetupUserData(userName, nameSpace, sessionContext);
        Response.Redirect(UI.DictionaryManager["DefaultPage"]+ "?LoadCurrentUser=" + Server.UrlEncode(loadAccount) + "&URL=" + Server.UrlEncode(URL));
          break;

        case LoginStatus.OKPasswordExpiringSoon:
          SetupUserData(userName, nameSpace, sessionContext);

          auth = new Auth();
          auth.Initialize(userName, nameSpace);
          int days = auth.DaysUntilPasswordExpires();

          Session["ChangePasswordMsg"] = String.Format(Resources.ErrorMessages.ERROR_LOGIN_PASSWORD_EXPIRING, days);
          Response.Redirect(UI.DictionaryManager["DefaultPage"] + "?URL=" + Server.UrlEncode(UI.DictionaryManager["ChangePasswordPage"].ToString()));
          break;

        // Error cases 
        case LoginStatus.FailedUsernameOrPassword:
          err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
          break;

        case LoginStatus.FailedPasswordExpired:
          err = Resources.ErrorMessages.ERROR_LOGIN_LOCKED;
          break;

        case LoginStatus.NoCapabilityToLogonToThisApplication:
          err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
          break;

        default:
          err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
          break;
      }
    }

    Response.Write(err);
  }

  private void SetupUserData(string userName, string nameSpace, IMTSessionContext sessionContext)
  {
      string ticket = MetraTech.ActivityServices.Services.Common.TicketManager.CreateTicket(sessionContext.AccountID, nameSpace, userName, m_ticketLifeSpanInMins);
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
      Session["Username"] = userName;
      // ESR-4488 clear ALL cached session data when we have an new acc
      ClearSessionData(userName, nameSpace, sessionContext);
    }

    // Load User Profile (SiteConfig.Profile)
    Session["UserProfile"] = BusinessEntityHelper.LoadUserProfile(acc);

    // Logon was valid.
    FormsAuthentication.SetAuthCookie(Request.ApplicationPath + userName, false);
    Logger.LogInfo(String.Format("{0} logged into {1}.", userName, Request.ApplicationPath));

    Auditor auditor = new Auditor();
    auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_LOGIN_SUCCESS,
                          sessionContext.AccountID,
                          (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                          -1,
                          String.Format("Login successful for username={0} namespace={1}", userName, nameSpace),
                          sessionContext.LoggedInAs,
                          sessionContext.ApplicationName);

  }
  private void ClearSessionData(string userName, string nameSpace, IMTSessionContext sessionContext)
  {
      // ESR-4488 clear all session constants      
      Session[SiteConstants.View] = null;
      Session[SiteConstants.ActiveMenu] = null;
      Session[SiteConstants.StartDate] = null;
      Session[SiteConstants.EndDate] = null;
      Session[SiteConstants.Intervals] = null;
      Session[SiteConstants.IntervalQueryString] = null;
      Session[SiteConstants.Interval] = null;
      Session[SiteConstants.SelectedIntervalId] = null;
      Session[SiteConstants.ReportParameters] = null;
      Session[SiteConstants.InvoiceReport] = null;
      Session[SiteConstants.DefaultInvoiceReport] = null;
      Session[SiteConstants.Payment] = null;
      Session[SiteConstants.ReportLevel] = null;
      Session[SiteConstants.ReportView] = null;
      Session[SiteConstants.InvoiceAccount] = null;
      Session[SiteConstants.REPORT_DICTIONARY] = null;
      Session[SiteConstants.LocaleTransator] = null;
      Session[SiteConstants.LastActiveInterval] = null;
      Session[SiteConstants.PaymentInformation] = null;
      Session[SiteConstants.OwnedAccount] = null;
      
  }

  private void SetMetraViewLanguage(string languageCode)
  {
    string browserLanguage = Thread.CurrentThread.CurrentCulture.Name;
    if (languageCode == "")
    {
      Session[Constants.SELECTED_LANGUAGE] =  !string.IsNullOrEmpty(browserLanguage) ? browserLanguage : "en-US";  
    }
    else
    {
      Session[Constants.SELECTED_LANGUAGE] = languageCode;
    }
    Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(Session[Constants.SELECTED_LANGUAGE].ToString());
    Thread.CurrentThread.CurrentUICulture = new CultureInfo(Session[Constants.SELECTED_LANGUAGE].ToString());
  }
}

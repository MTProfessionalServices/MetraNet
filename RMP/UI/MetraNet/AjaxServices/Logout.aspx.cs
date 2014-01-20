using System;
using System.Net;
using System.Web.Security;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Services.Common;

public partial class Logout : MTPage
{
  private const string _mcmLogoutUrl = "/mcm/LogOut.asp";
  private const string _cookiePathSeparator = "/";
  private const string _portParamName = "SERVER_PORT";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (Session["IsMAMActive"] != null && (bool)Session["IsMAMActive"])
    {
      Response.Write("LOGOUT_MAM");
    }

    //CORE-5999 Logout from MCM application for current user.
    if (Session["IsMCMActive"] != null && (bool)Session["IsMCMActive"])
    {
      McmLogout();
    }
    TicketManager.InvalidateTicket(UI.User.Ticket);    
    FormsAuthentication.SignOut();
    Session.Abandon();
    Response.End();
  }

  private void McmLogout()
  {
    string protocol = Request.IsSecureConnection ? Uri.UriSchemeHttps : Uri.UriSchemeHttp;
    string hostAddress = Request.UserHostAddress;
    int port = int.Parse(Request.Params[_portParamName]);
    Uri absolute = new Uri((new UriBuilder(protocol, hostAddress, port)).ToString());

    Auth auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace);

    string relativeUrlString = auth.CreateEntryPoint("mcm", "system_user", 0, _mcmLogoutUrl, false, true);
    Uri relative = new Uri(relativeUrlString, UriKind.Relative);
    Uri uri = new Uri(absolute, relative);

    //Request to page for abadon session in MCM application for current session in MetraNet.
    var request = WebRequest.Create(uri) as HttpWebRequest;
    request.CookieContainer = new CookieContainer();

    foreach (var cookie in Request.Cookies.AllKeys)
    {
      request.CookieContainer.Add(absolute, new Cookie(cookie, Request.Cookies[cookie].Value, _cookiePathSeparator));
    }

    try
    {
      request.GetResponse();
    }
    catch (Exception exc)
    {
      Logger.LogException("Error while logout from MCM application: ", exc);
      throw;
    }
  }
}

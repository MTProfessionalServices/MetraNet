using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using MetraTech.Security;
using MetraTech.UI.Tools;

namespace MetraTech.UI.Common
{

    public class LogoutUtil
    {
        private const string _mcmLogoutUrl = "/mcm/LogOut.asp";
        private const string _momLogoutUrl = "/mom/default/dialog/LogOut.asp";
        private const string _mamLogoutUrl = "/MAM/Default/Dialog/logout.asp";
        private const string _cookiePathSeparator = "/";
        private const string _portParamName = "SERVER_PORT";
        
        //moved this code from metranet\logout.aspx to here since its now being used in metraview too
        public void LogoutFromAspApp(HttpRequest currHttpRequest, string username, string nmspace, string appName)
        {
            string protocol = currHttpRequest.IsSecureConnection ? Uri.UriSchemeHttps : Uri.UriSchemeHttp;
            string hostAddress = currHttpRequest.UserHostAddress;
            int port = int.Parse(currHttpRequest.Params[_portParamName]);
            Uri absolute = new Uri((new UriBuilder(protocol, hostAddress, port)).ToString());

            Auth auth = new Auth();
            auth.Initialize(username, nmspace);


            string relativeUrlString = auth.CreateEntryPoint(appName, "system_user", 0, GetLogoutUrl(appName), false, true);
            Uri relative = new Uri(relativeUrlString, UriKind.Relative);
            Uri uri = new Uri(absolute, relative);

            //Request page to abadon session for the application for current session in MetraNet.
            var request = WebRequest.Create(uri) as HttpWebRequest;
            request.CookieContainer = new CookieContainer();

            foreach (var cookie in currHttpRequest.Cookies.AllKeys)
            {
                request.CookieContainer.Add(absolute, new Cookie(cookie, currHttpRequest.Cookies[cookie].Value, _cookiePathSeparator));
            }

            try
            {
                request.GetResponse();
            }
            catch (Exception exc)
            {
                Utils.CommonLogger.LogException(String.Format("Error while logout from {0} application: ", appName), exc);
                throw;
            }
        }

        private string GetLogoutUrl(string appName)
        {
            switch (appName)
            {
                case "mcm":
                    return _mcmLogoutUrl;
                case "mom":
                    return _momLogoutUrl;
                case "mam":
                    return _mamLogoutUrl;
            }
            return string.Empty;
        }
    }
}
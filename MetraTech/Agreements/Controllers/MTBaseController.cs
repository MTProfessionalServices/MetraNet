using System;
using System.Collections.Concurrent;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Hosting;
using System.Web.Http.Routing;
using System.Web.Mvc;
using System.Web.Security;
using System.Xml;
using MetraTech;
using MetraTech.Agreements.Models;
using MetraTech.DataAccess;
using MetraTech.Interop.MTServerAccess;

using MetraTech.Security;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using System.Web.Routing;

namespace MetraTech.Agreements.Controllers
{
    public class MTBaseController : Controller
    {
        public ConcurrentDictionary<int, UIManager> ActiveUsers
        {
            get
            {
                if (System.Web.HttpContext.Current.Application["ActiveUsers"] == null)
                {
                    System.Web.HttpContext.Current.Application.Lock();
                    System.Web.HttpContext.Current.Application["ActiveUsers"] = new ConcurrentDictionary<int, UIManager>();
                    System.Web.HttpContext.Current.Application.UnLock();
                } 
                return System.Web.HttpContext.Current.Application["ActiveUsers"] as ConcurrentDictionary<int, UIManager>;
            }
        }

        protected override void Initialize(RequestContext requestContext)
        {
            base.Initialize(requestContext);
            if ((requestContext.HttpContext.Response.Cookies.Count == 0) && (!requestContext.HttpContext.Request.IsAuthenticated))
            {
                string userName = "";
                string ticket = "";
                string nameSpace = "";
                string[] req = null;
                object tmp = null;  //IMTSessionContext
                Auth auth = new Auth();

                // TODO: This needs to be cleaned up.
                string queryString = requestContext.HttpContext.Request.Params["UserName"];

                if (queryString != null)
                {
                    req = queryString.Split('-');
                    userName = req[0].Trim();
                    string[] temp = req[1].Trim().Split('=');

                    nameSpace = temp[1];
                    // rip out the the Ticket
                    ticket = req[2].Substring(7);
                    auth.Initialize(userName, nameSpace);
                    LoginStatus status = auth.LoginWithTicket(ticket, ref tmp);
                    IMTSessionContext sessionContext = tmp as IMTSessionContext;

                    if ((status == LoginStatus.OK) || (status == LoginStatus.OKPasswordExpiringSoon))
                    {
                        UIManager UI = new UIManager();
                        UI.User.UserName = userName;
                        UI.User.NameSpace = nameSpace;
                        int accountId = sessionContext.AccountID;
                        UI.User.AccountId = accountId;
                        UI.User.SessionContext = sessionContext;
                        ActiveUsers.TryAdd(accountId, UI);
                        FormsAuthentication.SetAuthCookie(userName, false);
                        Response.Redirect(String.Format("ShowAllTemplates?AccountId={0}", Server.UrlEncode(accountId.ToString())));
                    }
                }
            }
        }
    }
}

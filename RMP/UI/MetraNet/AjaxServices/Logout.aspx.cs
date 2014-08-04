using System;
using System.Net;
using System.Web.Security;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Services.Common;

public partial class Logout : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    LogoutFromAspApplications();

    var lang = Session[Constants.SELECTED_LANGUAGE];
    TicketManager.InvalidateTicket(UI.User.Ticket);    
    FormsAuthentication.SignOut();
    Session.Abandon();
    Response.Write(lang);
    Response.End();
  }

  private void LogoutFromAspApplications()
  {
      LogoutUtil logoutUtility = new LogoutUtil();
      if (Convert.ToBoolean(Session["IsMAMActive"]))
      {
          logoutUtility.LogoutFromAspApp(Request, UI.User.UserName, UI.User.NameSpace, "mam");
      }

      if (Convert.ToBoolean(Session["IsMCMActive"]))
      {
          logoutUtility.LogoutFromAspApp(Request, UI.User.UserName, UI.User.NameSpace, "mcm");
      }

      if (Convert.ToBoolean(Session["IsMOMActive"]))
      {
          logoutUtility.LogoutFromAspApp(Request, UI.User.UserName, UI.User.NameSpace, "mom");
      }
  }
  
}

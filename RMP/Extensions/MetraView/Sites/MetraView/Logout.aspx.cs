using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

public partial class Logout : MTPage
{
 
  protected void Page_Load(object sender, EventArgs e)
  {
    LogoutFromAspApplications();
    var lang = Session[Constants.SELECTED_LANGUAGE];
    MetraTech.ActivityServices.Services.Common.TicketManager.InvalidateTicket(UI.User.Ticket);

    Session.Abandon();
    FormsAuthentication.SignOut();

    // CORE-4889 - Session Identifier Not Updated 
    WebUtils.RegenerateSessionId();

    Response.Redirect("Login.aspx?l=" + lang);
  }

  private void LogoutFromAspApplications()
  {
      //CORE-7184: Logout from the asp applications that have been loaded. Valid only when MetraView is loaded from MetraCare
      LogoutUtil utility = new LogoutUtil();
      if (Convert.ToString(Session["IsMAMActive"]) != "" && Convert.ToBoolean(Session["IsMAMActive"]))
      {
          utility.LogoutFromAspApp(Request, UI.User.UserName, UI.User.NameSpace, "mam");
      }
      if (Convert.ToString(Session["IsMOMActive"]) != "" && Convert.ToBoolean(Session["IsMOMActive"]))
      {
          utility.LogoutFromAspApp(Request, UI.User.UserName, UI.User.NameSpace, "mom");
      }
      if (Convert.ToString(Session["IsMCMActive"]) != "" && Convert.ToBoolean(Session["IsMCMActive"])) 
      {
          utility.LogoutFromAspApp(Request, UI.User.UserName, UI.User.NameSpace, "mcm");
      }

  }
}

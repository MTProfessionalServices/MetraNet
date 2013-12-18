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
    var lang = Session[Constants.SELECTED_LANGUAGE];
    MetraTech.ActivityServices.Services.Common.TicketManager.InvalidateTicket(UI.User.Ticket);

    Session.Abandon();
    FormsAuthentication.SignOut();

    // CORE-4889 - Session Identifier Not Updated 
    WebUtils.RegenerateSessionId();

    Response.Redirect("Login.aspx?l=" + lang);
  }
}

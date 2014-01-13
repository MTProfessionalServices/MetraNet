using System;
using System.Web.Security;

public partial class LogoutService : System.Web.UI.Page
{
  protected void Page_Load(object sender, EventArgs e)
  {
    //  MetraTech.ActivityServices.Services.Common.TicketManager.InvalidateTicket(UI.User.Ticket);
    Session.Abandon();
    FormsAuthentication.SignOut();
    Response.End();
  }
}

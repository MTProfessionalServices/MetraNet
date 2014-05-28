using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TicketToMOMNoMenu : System.Web.UI.Page
{
  public string URL = "";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (Request.QueryString["Title"] != null)
    {
      Title = Server.HtmlEncode(Request.QueryString["Title"]);
    }

    if (Request.QueryString["URL"] == null) return;

    Session["IsMOMActive"] = true;

    // replace | with ? and ** with &
    var gotoURL = Request.QueryString["URL"].Replace("|", "?").Replace("**", "&");

    HelpPage = MetraTech.Core.UI.CoreUISiteGateway.GetHelpPageAsp(Server, Session, gotoURL, Logger);

    Auth auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace);
    URL = auth.CreateEntryPoint("mom", "system_user", 0, gotoURL, false, true);
  }
}
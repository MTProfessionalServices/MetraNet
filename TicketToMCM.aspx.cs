using System;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class UserControls_ticketToMCM : MTPage
{
	public string URL = "";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (Request.QueryString["Title"] != null)
    {
      Title = Server.HtmlEncode(Request.QueryString["Title"]);
    }

    if (Request.QueryString["URL"] == null) return;

    Session["IsMCMActive"] = true;

    // replace | with ? and ** with &
    var gotoURL = Request.QueryString["URL"].Replace("|", "?").Replace("**", "&");
    gotoURL = gotoURL.Replace("!", "|");

    HelpPage = MetraTech.Core.UI.CoreUISiteGateway.GetHelpPageAsp(Server, Session, gotoURL, Logger);

    var auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace);
    URL = auth.CreateEntryPoint("mcm", "system_user", 0, gotoURL, false, true);
    
    if (Request.QueryString["Redirect"] != null && Request.QueryString["Redirect"].ToUpper() == "TRUE")
    {
      Response.Redirect(URL, true);
    }
  }
}

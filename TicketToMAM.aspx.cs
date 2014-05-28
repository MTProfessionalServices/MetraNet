using System;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class UserControls_ticketToMAM : MTPage
{
	public string URL = "";

	protected void Page_Load(object sender, EventArgs e)
	{
		if (Request.QueryString["Title"] != null)
		{
			Title = Server.HtmlEncode(Request.QueryString["Title"]);
		}

	  if (Request.QueryString["URL"] == null) return;

	  Session["IsMAMActive"] = true;

	  // replace | with ? and ** with &
	  var gotoURL = Request.QueryString["URL"].Replace("|", "?").Replace("**", "&");

	  HelpPage = MetraTech.Core.UI.CoreUISiteGateway.GetHelpPageAsp(Server, Session, gotoURL, Logger);

	  var auth = new Auth();
	  auth.Initialize(UI.User.UserName, UI.User.NameSpace);
	  var accountId = UI.Subscriber.SelectedAccount == null ? 0 : int.Parse(UI.Subscriber["_AccountID"]);
	  URL = auth.CreateEntryPoint("mam", "system_user", accountId, gotoURL, false, true);
	}
}

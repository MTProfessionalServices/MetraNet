using System;
using MetraTech.DomainModel.Enums;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class UserControls_ticketToMAMNoMenu : MTPage
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

    HelpPage = MetraTech.Core.UI.CoreUISiteGateway.GetDefaultHelpPage(Server, Session, gotoURL, Logger);

	  var auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace, UI.User.UserName,
                     "MetraNet", Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)));

    var accountId = UI.Subscriber.SelectedAccount == null ? 0 : int.Parse(UI.Subscriber["_AccountID"]);
    URL = auth.CreateEntryPoint("mam", "system_user", accountId , gotoURL, false, true);
	}
}

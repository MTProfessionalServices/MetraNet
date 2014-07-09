using System;
using System.Threading;
using MetraTech.UI.Common;
using MetraTech.Security;
using MetraTech.SecurityFramework;

public partial class UserControls_ticketToMAMNoMenu : MTPage
{
	public string URL = "";

	protected void Page_Load(object sender, EventArgs e)
	{
		if (Request.QueryString["Title"] != null)
		{
			Title = Server.HtmlEncode(Request.QueryString["Title"]);
		}

		if (Request.QueryString["URL"] != null)
		{
			Session["IsMAMActive"] = true;

			// replace | with ? and ** with &
			string gotoURL = Request.QueryString["URL"].Replace("|", "?").Replace("**", "&");

			try
			{
				ApiInput input = new ApiInput(gotoURL);
				SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input);
			}
			catch (AccessControllerException accessExp)
			{
				Session[Constants.ERROR] = accessExp.Message;
				gotoURL = string.Empty;
			}
			catch (Exception exp)
			{
				Session[Constants.ERROR] = exp.Message;
				throw exp;
			}

			// Setup help URL
			string helpName = "welcome.aspx";
			try
			{
				string[] helpArr = gotoURL.Split('?');
				helpName = helpArr[0].Substring(helpArr[0].LastIndexOf("/") + 1);
				helpName = helpName.Substring(0, helpName.LastIndexOf('.'));
			}
			catch (Exception exp)
			{
				// Could not get help url
				Logger.LogException("Could not get help URL from:" + gotoURL, exp);
			}
			HelpPage = "/MetraNetHelp/" + Thread.CurrentThread.CurrentCulture + "/index.htm?toc.htm?" + helpName + ".hlp.htm";

			Auth auth = new Auth();
			auth.Initialize(UI.User.UserName, UI.User.NameSpace);
			if (UI.Subscriber.SelectedAccount != null)
			{
				URL = auth.CreateEntryPoint("mam", "system_user", int.Parse(UI.Subscriber["_AccountID"]), gotoURL, false, true);
			}
			else
			{
				URL = auth.CreateEntryPoint("mam", "system_user", 0, gotoURL, false, true);
			}
		}
	}

}

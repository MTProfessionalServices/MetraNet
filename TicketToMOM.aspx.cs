using System;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.Security;

public partial class UserControls_ticketToMOM : MTPage
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
    try
    {
      gotoURL = gotoURL + (gotoURL.Contains("?") ? "&" : "?") + "language=" + Session["MTSelectedLanguage"];
      var input = new ApiInput(gotoURL);
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
      throw;
    }
    HelpPage = MetraTech.Core.UI.CoreUISiteGateway.GetDefaultHelpPage(Server, Session, gotoURL, Logger);

    var auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace);
    URL = auth.CreateEntryPoint("mom", "system_user", 0, gotoURL, false, true);
  }
}
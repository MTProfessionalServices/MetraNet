using System;
using MetraTech.DomainModel.Enums;
using MetraTech.UI.Common;
using MetraTech.Security;
using MetraTech.SecurityFramework;

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
    auth.Initialize(UI.User.UserName, UI.User.NameSpace, UI.User.UserName,
                    "MetraNet", Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)));

    URL = auth.CreateEntryPoint("mcm", "system_user", 0, gotoURL, false, true);

    if (Request.QueryString["Redirect"] == null || Request.QueryString["Redirect"].ToUpper() != "TRUE") return;

    var response = MetraTech.Core.UI.CoreUISiteGateway.GetAspResponse(HelpPage, URL);
    Response.Write(response);
  }
}
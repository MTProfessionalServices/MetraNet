using System;
using MetraTech.DomainModel.Enums;
using MetraTech;
using MetraTech.DomainModel.Enums;
using MetraTech.UI.Common;
using MetraTech.Security;
using MetraTech.SecurityFramework;

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
    try
    {
        if (gotoURL.Contains("?"))
          gotoURL = gotoURL + "&language=" + GetLanguageCode();
        else
          gotoURL = gotoURL + "?language=" + GetLanguageCode();
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
      throw;
    }
       
    HelpPage = MetraTech.Core.UI.CoreUISiteGateway.GetDefaultHelpPage(Server, Session, gotoURL, Logger);

    var auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace, UI.User.UserName,
                    "MetraNet", Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)));

    var accountId = UI.Subscriber.SelectedAccount == null ? 0 : int.Parse(UI.Subscriber["_AccountID"]);
    URL = auth.CreateEntryPoint("mam", "system_user", accountId, gotoURL, false, true);
  }

			Auth auth = new Auth();
      auth.InitializeWithLanguage(UI.User.UserName, UI.User.NameSpace, Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)));
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

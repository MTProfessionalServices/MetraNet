using System;
using MetraTech.DomainModel.Enums;
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

      if (Request.QueryString["ReturnUrl"] != null)
        gotoURL = gotoURL + (gotoURL.Contains("?") ? "&" : "?") + "ReturnUrl=" + Uri.EscapeDataString(Request.QueryString["ReturnUrl"]);

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

    int partitionId = 1;
    if (PartitionLibrary.PartitionData.isPartitionUser)
    {
      partitionId = PartitionLibrary.PartitionData.PartitionId;
    }

    var auth = new Auth();
    auth.Initialize(UI.User.UserName, UI.User.NameSpace, UI.User.UserName, 
                    "MetraNet", Convert.ToInt16(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)));

    URL = auth.CreateEntryPointWithPartitionID("mom", "system_user", 0, gotoURL, false, true, partitionId);
  }
}
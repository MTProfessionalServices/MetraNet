using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using MetraTech.UI.Common;
using MetraTech.Interop.MTAuth;
using MetraTech.Security;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.Common;
using MetraTech.SecurityFramework;

public partial class EntryPoint : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Create a UIManager
        UI = new UIManager();

        // Retrieve username and password from control
        string userName = Request["UserName"];
        string nameSpace = Request["NameSpace"];
        string ticket = Request["Ticket"];
        string loadAccount = Request["LoadAccount"];
        string URL = Request["URL"];
        string loadFrame = Request["LoadFrame"] ?? "true";

        object tmp = null;  //IMTSessionContext
        Auth auth = new Auth();
        auth.Initialize(userName, nameSpace);
        MetraTech.Security.LoginStatus status = auth.LoginWithTicket(ticket, ref tmp);
        IMTSessionContext sessionContext = tmp as IMTSessionContext;
        string err = "";

        // SECENG
        // Fixing issue ESR-4041 MSOL BSS 27485 Metracare: Open redirection [/mam/EntryPoint.asp] (ESR for 18272) (Post-PB)
        // Added verification of the URL supplied
        try
        {
            ApiInput input = new ApiInput(URL);
            SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input);
        }
        catch (AccessControllerException accessExp)
        {
            Session[Constants.ERROR] = accessExp.Message;
            URL = string.Empty;
        }
        catch (Exception exp)
        {
            Session[Constants.ERROR] = exp.Message;
            throw exp;
        }

        switch (status)
        {
            // Success cases
            case MetraTech.Security.LoginStatus.OK:
                SetupUserData(userName, nameSpace, sessionContext);
                if (loadFrame.ToLower() == "false")
                {
                    Response.Redirect(URL + "&LoadFrame=false");
                }
                else
                {
                    Response.Redirect(UI.DictionaryManager["DefaultPage"].ToString() + "?LoadCurrentUser=" + Server.UrlEncode(loadAccount) + "&URL=" + Encrypt(Server.UrlEncode(URL)));
                }
                break;

            case MetraTech.Security.LoginStatus.OKPasswordExpiringSoon:
                SetupUserData(userName, nameSpace, sessionContext);

                auth = new Auth();
                auth.Initialize(userName, nameSpace);
                int days = auth.DaysUntilPasswordExpires();

                Session["ChangePasswordMsg"] = String.Format(Resources.ErrorMessages.ERROR_LOGIN_PASSWORD_EXPIRING, days.ToString());
                Response.Redirect(UI.DictionaryManager["DefaultPage"] + "?URL=" + Encrypt(UI.DictionaryManager["ChangePasswordPage"].ToString()));
                break;

            // Error cases 
            case MetraTech.Security.LoginStatus.FailedUsernameOrPassword:
                err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
                break;

            case MetraTech.Security.LoginStatus.FailedPasswordExpired:
                err = Resources.ErrorMessages.ERROR_LOGIN_LOCKED;
                break;

            case MetraTech.Security.LoginStatus.NoCapabilityToLogonToThisApplication:
                err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
                break;

            default:
                err = Resources.ErrorMessages.ERROR_LOGIN_INVALID;
                break;
        }

        Response.Write(err);
    }

    private void SetupUserData(string userName, string nameSpace, IMTSessionContext sessionContext)
    {
        // Setup user data
        UI.User.UserName = userName;
        UI.User.NameSpace = nameSpace;
        UI.User.AccountId = sessionContext.AccountID;
        UI.User.SessionContext = sessionContext;

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Store Partition Information for this user - to be used in other screens to limit what this account can see
        PartitionData PartitionData = PartitionLibrary.RetrievePartitionInformation();
        UI.User.SetData("PartitionData", PartitionData);
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // Logon was valid.
        Session["IsTicketed"] = true;
        FormsAuthentication.SetAuthCookie(userName, false);
        Logger.LogDebug("Account " + UI.User.AccountId.ToString() + " logged into MetraNet.");
    }

}
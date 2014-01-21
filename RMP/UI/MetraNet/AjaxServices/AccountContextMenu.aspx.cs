using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;

public partial class AjaxServices_AccountContextMenu : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string accountIdText = Request.Form["id_acc"];
        long accountId;
        if (string.IsNullOrWhiteSpace(accountIdText) || !long.TryParse(accountIdText, out accountId))
        {
            throw new Exception("Account not indicated");
        }

		string canManageStr = Request.Form["canManage"];
		bool canManage;
		if (!bool.TryParse(canManageStr, out canManage))
		{
		  canManage = false;
		}
		
        // Getting selected account type name
        AccountService_GetAccountTypeName_Client client = new AccountService_GetAccountTypeName_Client();
        client.UserName = UI.User.UserName;
        client.Password = UI.User.SessionPassword;
        client.In_accountId = accountId;

        string accountTypeName;
        bool accountHasLogonCapability;

        try
        {
            client.Invoke();
            accountTypeName = client.InOut_typeName;
            accountHasLogonCapability = client.InOut_hasLogonCapability;
        }
        catch (FaultException<MASBasicFaultDetail> ex)
        {
            // Handle the case if an account was not found or permission to account denied.
            if (ex.Detail.ErrorCode == ErrorCodes.ACCOUNT_NOT_FOUND)
            {
                Response.Write(string.Format("alert('Requested account {0} was not found');", accountId));
                Response.End();
                return;
            }
            else
            {
                throw;
            }
        }

        // Getting the menu for account
        string menuFilename = Server.MapPath("/MetraNet") + @"\Config\Menus\AccountHierarchyContextMenu.xml";
        bool forceReload = (ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true");
        MenuManager mm = MenuManager.Load(menuFilename, forceReload);
        MetraTech.UI.Common.Menu menu = mm[accountTypeName] ?? mm["DefaultAccountHierarchyContextMenu"];

        // Checking for ViewOnlineBill capability
        if (!accountHasLogonCapability)
        {
            menu.RemoveMenuItemById("SelfCarePortal");
        }
		
		if (!canManage)
		{
		  menu.RemoveMenuItemById("UpdateAccount");
		  menu.RemoveMenuItemById("UpdateContact");
		}

        string menuScript = MenuRenderer.RenderMenuContext(menu, UI);
        Response.Write(menuScript);
        Response.End();
    }
}
using System;
using MetraTech.UI.Common;
using System.Configuration;

/// <summary>
/// The menu user control is used to render the menus according to the logged in user's
/// capabilities.  The whole menu is loaded into a MenuManager and placed in the 
/// Application in the global.asax.  This is accessed here durring the rendering.
/// 
/// Files of interest:  /MetraNet/Menu/menu.xml, App_GlobalResources/MainMenu.resx, 
///                     App_Code/RenderMenu.cs
/// </summary>
public partial class UserControls_MetraOfferMenu : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session[Constants.METRAOFFER_MENU] == null)
        {
            MenuHtml.Text = RenderMainMenu();
            Session[Constants.METRAOFFER_MENU] = MenuHtml.Text;
        }
        else
        {
            MenuHtml.Text = Session[Constants.METRAOFFER_MENU] as string;
        }
    }

    /// <summary>
    /// Renders menu items according to the logged in user's capabilities and locale.
    /// </summary>
    /// <returns>Menu HTML</returns>
    public string RenderMainMenu()
    {
        // CORE-359 : There were concurrency issues with having a shared menu.  Need to re-examine caching of menu.
        //MenuManager mm = Application[Constants.MAIN_MENU] as MenuManager;
        string menuFilename = Server.MapPath("/MetraNet") + @"\Config\Menus\MetraOfferMenu.xml";
        bool forceReload = (ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true");
        MenuManager mm = MenuManager.Load(menuFilename, forceReload);

        Menu menu;
        try
        {
            menu = mm[Constants.METRAOFFER_MENU];
            if (menu == null)
            {
                throw new Exception(String.Format("{0} not found in {1}", Constants.METRAOFFER_MENU, menuFilename));
            }
        }
        catch (Exception exp)
        {
            ((MTPage)Page).Logger.LogError("Invalid menu file; check to make sure MetraOfferMenu.xml is valid: " + exp);
            return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, Constants.METRAOFFER_MENU);
        }

        if (PartitionLibrary.IsPartition)
        {
            menu.RemoveMenuItemById("PriceableItems");
            // menu.RemoveMenuItemById("MDTConfig");
            // menu.RemoveMenuItemById("LOV");
            menu.RemoveMenuItemById("ManageCalendars");
            menu.RemoveMenuItemById("BulkSubscriptionChange");
            menu.RemoveMenuItemById("PCAuditLog");
            //menu.RemoveMenuItemById("HiddenOfferings");
            menu.RemoveMenuItemById("ManageAmpDecisions");
        }

        return MenuRenderer.Render(menu, BaseUI);
    }

    public MTPage BaseMTPage
    {
        get { return (MTPage)Page; }
    }

    public UIManager BaseUI
    {
        get { return BaseMTPage.UI; }
    }
}

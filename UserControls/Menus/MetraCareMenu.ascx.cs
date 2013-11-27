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
public partial class UserControls_MetraCareMenu : System.Web.UI.UserControl
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (Session["MetraCareMenu"] == null)
    {
      MenuHtml.Text = RenderMainMenu();
      Session[Constants.METRACARE_MENU] = MenuHtml.Text;
    }
    else
    {
      MenuHtml.Text = Session[Constants.METRACARE_MENU] as string;
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
    string menuFilename = Server.MapPath("/MetraNet") + @"\Config\Menus\MetraCareMenu.xml";
    bool forceReload;
    try{
        forceReload	= (ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true");
	} catch (Exception e){
	    ((MTPage)Page).Logger.LogError("DemoMode setting not found in web.config. " + e);
		throw;
    }
	
    MenuManager mm = MenuManager.Load(menuFilename, forceReload);

    Menu menu;
    try
    {
      menu = mm[Constants.METRACARE_MENU];
      if (menu == null)
      {
        throw new Exception(String.Format("{0} not found in {1}", Constants.METRACARE_MENU, menuFilename));
      }
    }
    catch (Exception exp)
    {
      ((MTPage)Page).Logger.LogError("Invalid menu file; check to make sure MetraCareMenu.xml is valid: " + exp);
      return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, Constants.METRACARE_MENU);
    }

    // Hide function not supported by the current AD authentication implementation
    MetraTech.Security.Auth auth = new MetraTech.Security.Auth();
    auth.Initialize(BaseUI.User.UserName, BaseUI.User.NameSpace);
    if (auth.Credentials.AuthenticationType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.AuthenticationType.ActiveDirectory)
    {
      menu.RemoveMenuItemById("ChangePassword");
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

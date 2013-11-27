using System;
using MetraTech.UI.Common;

/// <summary>
/// The menu user control is used to render the menus according to the logged in user's
/// capabilities.  
/// 
/// Files of interest:  /MetraView/Config/Menus/AdminMenu.xml, App_GlobalResources/AdminMenu.resx, 
///                     App_Code/RenderMenu.cs
/// </summary>
public partial class UserControls_AdminMenu : System.Web.UI.UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("MetraView Admin"))
    {
      Response.Write(Resources.ErrorMessages.ERROR_ACCESS_DENIED);
      Response.End();
      return;
    }

      if (Session[Constants.ADMIN_MENU] == null)
      {
        MenuHtml.Text = RenderMainMenu();
        Session[Constants.ADMIN_MENU] = MenuHtml.Text;
      }
      else
      {
        MenuHtml.Text = Session[Constants.ADMIN_MENU] as string;
      }
    }

  /// <summary>
  /// Renders menu items according to the logged in user's capabilities and locale.
  /// </summary>
  /// <returns>Menu HTML</returns>
  public string RenderMainMenu()
  {
    string menuFilename = Server.MapPath(Request.ApplicationPath) + @"\Config\Menus\AdminMenu.xml";
    MenuManager mm = MenuManager.Load(menuFilename);

    Menu menu;
    try
    {
      menu = mm[Constants.ADMIN_MENU];
      if (menu == null)
      {
        throw new Exception(String.Format("{0} not found in {1}", Constants.ADMIN_MENU, menuFilename));
      }
    }
    catch (Exception exp)
    {
      ((MTPage)Page).Logger.LogError("Invalid menu file; check to make sure AdminMenu.xml is valid: " + exp);
      return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, Constants.ADMIN_MENU);
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

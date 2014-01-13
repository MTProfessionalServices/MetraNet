using System;
using MetraTech.UI.Common;

/// <summary>
/// The menu user control is used to render the menus according to the logged in user's
/// capabilities.
/// 
/// Files of interest:  /MetraView/Config/Menus/TopMenu.xml, App_GlobalResources/TopMenu.resx, 
///                     App_Code/RenderMenu.cs
/// </summary>
public partial class UserControls_TopMenu : System.Web.UI.UserControl
{
  private bool IsAdmin = true;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (IsAdmin)
    {
      if (Session[Constants.TOP_MENU] == null)
      {
        MenuHtml.Text = RenderMainMenu();
        Session[Constants.TOP_MENU] = MenuHtml.Text;
      }
      else
      {
        MenuHtml.Text = Session[Constants.TOP_MENU] as string;
      }
    }
  }

  /// <summary>
  /// Renders menu items according to the logged in user's capabilities and locale.
  /// </summary>
  /// <returns>Menu HTML</returns>
  public string RenderMainMenu()
  {
    string menuFilename = Server.MapPath(Request.ApplicationPath) + @"\Config\Menus\TopMenu.xml";
    MenuManager mm = MenuManager.Load(menuFilename);

    Menu menu;
    try
    {
      menu = mm[Constants.TOP_MENU];
      if (menu == null)
      {
        throw new Exception(String.Format("{0} not found in {1}", Constants.TOP_MENU, menuFilename));
      }
    }
    catch (Exception exp)
    {
      ((MTPage)Page).Logger.LogError("Invalid menu file; check to make sure TopMenu.xml is valid: " + exp);
      return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, Constants.TOP_MENU);
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

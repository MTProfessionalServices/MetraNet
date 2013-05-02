using System;
using MetraTech.UI.Common;

/// <summary>
/// The menu user control is used to render the menus according to the logged in user's
/// capabilities.  
/// 
/// Files of interest:  /MetraView/Config/Menus/BillSubMenu.xml, App_GlobalResources/BillSubMenu.resx, 
///                     App_Code/RenderMenu.cs
/// </summary>
public partial class UserControls_BillSubMenu : System.Web.UI.UserControl
{

  protected void Page_Load(object sender, EventArgs e)
  {
    if (Visible == false) return;

    if (Session[Constants.BILL_SUB_MENU] == null)
    {
      MenuHtml.Text = RenderMainMenu();
      Session[Constants.BILL_SUB_MENU] = MenuHtml.Text;
    }
    else
    {
      MenuHtml.Text = Session[Constants.BILL_SUB_MENU] as string;
    }
  }

  /// <summary>
  /// Renders menu items according to the logged in user's capabilities and locale.
  /// </summary>
  /// <returns>Menu HTML</returns>
  public string RenderMainMenu()
  {
    string menuFilename = Server.MapPath(Request.ApplicationPath) + @"\Config\Menus\BillSubMenu.xml";
    MenuManager mm = MenuManager.Load(menuFilename);

    Menu menu;
    try
    {
      menu = mm[Constants.BILL_SUB_MENU];
      if (menu == null)
      {
        throw new Exception(String.Format("{0} not found in {1}", Constants.BILL_SUB_MENU, menuFilename));
      }
    }
    catch (Exception exp)
    {
      ((MTPage)Page).Logger.LogError("Invalid menu file; check to make sure BillSubMenu.xml is valid: " + exp);
      return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, Constants.BILL_SUB_MENU);
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

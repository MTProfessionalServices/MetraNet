using System;
using MetraTech.Accounts.Type;
using MetraTech.Interop.MTYAAC;
using MetraTech.UI.Common;
using YAAC = MetraTech.Interop.MTYAAC;
using IMTSessionContext=MetraTech.Interop.MTProductCatalog.IMTSessionContext;
using IMTAccountType=MetraTech.Interop.IMTAccountType.IMTAccountType;

/// <summary>
/// The menu user control is used to render the menus according to the logged in user's
/// capabilities. 
/// 
/// Files of interest:  /MetraView/Config/Menus/MainMenu.xml, App_GlobalResources/MainMenu.resx, 
///                     App_Code/RenderMenu.cs
/// </summary>
public partial class UserControls_MainMenu : System.Web.UI.UserControl
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (Session[Constants.MAIN_MENU] == null)
    {
      MenuHtml.Text = RenderMainMenu();
      //Session[Constants.MAIN_MENU] = MenuHtml.Text;
    }
    else
    {
     // MenuHtml.Text = Session[Constants.MAIN_MENU] as string;
    }
  }

  /// <summary>
  /// Renders menu items according to the logged in user's capabilities and locale.
  /// </summary>
  /// <returns>Menu HTML</returns>
  public string RenderMainMenu()
  {
    string menuFilename = Server.MapPath(Request.ApplicationPath) + @"\Config\Menus\MainMenu.xml";
    MenuManager mm = MenuManager.Load(menuFilename);

    Menu menu;
    try
    {
      menu = mm[Constants.MAIN_MENU];
      if (menu == null)
      {
        throw new Exception(String.Format("{0} not found in {1}", Constants.MAIN_MENU, menuFilename));
      }
    }
    catch (Exception exp)
    {
      ((MTPage)Page).Logger.LogError("Invalid menu file; check to make sure MainMenu.xml is valid: " + exp);
      return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, Constants.MAIN_MENU);
    }

    UpdateMenu(ref menu);

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


  public void UpdateMenu(ref Menu menu)
  {
    MTPage page = Parent.Page as MTPage;

    if (page != null)
    {

      AccountTypeManager accountTypeManager = new AccountTypeManager();
      MTYAAC yaac = new MTYAAC();
      yaac.InitAsSecuredResource((int)page.UI.Subscriber.SelectedAccount._AccountID,
                                 (MetraTech.Interop.MTYAAC.IMTSessionContext)page.UI.SessionContext,
                                 page.ApplicationTime);
      IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)page.UI.SessionContext,
                                                                     yaac.AccountTypeID);
      
      // Corporate accounts need the update capability for the account info menu option
      if (accType.IsCorporate)
      {
        if (!BaseUI.CoarseCheckCapability("Update corporate accounts"))
        {
          menu.RemoveMenuItemById("AccountInfo");
        }
      }

      if(SiteConfig.Settings.BillSetting.AllowSelfCare == false)
      {
        menu.RemoveMenuItemById("AccountInfo");
        menu.RemoveMenuItemById("MySubscriptions");
      }

      if (Session["IsOwner"] == null)
        menu.RemoveMenuItemById("SelectBillEntry");

    }
  }

}

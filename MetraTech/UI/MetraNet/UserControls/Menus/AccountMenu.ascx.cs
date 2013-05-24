using System;
using System.Collections.Generic;
using MetraTech;
using MetraTech.Accounts.Type;
using MetraTech.Interop.MTYAAC;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.UI.Common;
using MetraTech.Security;
using IMTAccountType=MetraTech.Interop.IMTAccountType.IMTAccountType;
using IMTSessionContext=MetraTech.Interop.MTProductCatalog.IMTSessionContext;
using IMTSQLRowset=MetraTech.Interop.IMTAccountType.IMTSQLRowset;
using RCD = MetraTech.Interop.RCD;
using MetraTech.Interop.MTAuth;
using System.Configuration;

public partial class UserControls_AccountMenu : System.Web.UI.UserControl
{
  private Auth auth;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (BaseUI == null)
      return;

    if (BaseUI.Subscriber.SelectedAccount != null)
    {
      // Is account locked?  If so let's indicate this up by the menu.
      auth = new Auth();
      auth.Initialize(BaseUI.Subscriber.SelectedAccount.UserName, BaseUI.Subscriber.SelectedAccount.Name_Space);
      if (auth.Credentials.IsEnabled)
      {
        AccountLockedHtml.Text = "";
      }
      else
      {
        string msg = String.Format(Resources.Resource.TEXT_ACCOUNT_LOCKED, BaseUI.Subscriber.SelectedAccount.UserName);
        AccountLockedHtml.Text = "<span class='ImportantMessage' style='position:absolute;top:30px;left:300px;z-index:1000;'>" + msg + "</span>";
      }

      // Update menu to ensure that the menu reflects the changes made to capabilities/roles if any
      LoadMenu();
    }
    else
    {
      MenuHtml.Text = "";
    }
  }

  public void LoadMenu()
  {
    MenuHtml.Text = RenderAccountMenu();
    Session[Constants.ACCOUNT_MENU] = MenuHtml.Text;
  }

  /// <summary>
  /// Renders the Account Menu items according to the logged in user's capabilities and locale.
  /// </summary>
  /// <returns>Menu HTML</returns>
  public string RenderAccountMenu()
  {
    // CORE-359 : There were concurrency issues with having a shared menu.  Need to re-examine caching of menu.
    //MenuManager mm = Application[Constants.MAIN_MENU] as MenuManager;
    string menuFilename = Server.MapPath("/MetraNet") + @"\Config\Menus\MetraCareMenu.xml";
    bool forceReload = (ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true");
    MenuManager mm = MenuManager.Load(menuFilename, forceReload);


    Menu menu = null;
    string accountType = null;
    try
    {
      // Get menu with an ID that equals the AccountType name, or if one doesn't exist
      // load the DefaultAccountMenu.
      accountType = BaseUI.Subscriber["AccountType"];
      if (mm != null)
      {
        if (!mm.Exists(accountType))
        {
          accountType = "DefaultAccountMenu";
        }

        menu = mm[accountType];
      }

      if ((mm == null) || (menu == null))
      {
        throw new Exception(String.Format("{0} not found in {1}", accountType, menuFilename));
      }
    }
    catch (Exception exp)
    {
      BaseMTPage.Logger.LogError("Invalid menu file; check to make sure MetraCareMenu.xml is valid: " + exp);
      return String.Format("{0} [{1}]", Resources.ErrorMessages.ERROR_MAIN_MENU, accountType);
    }

    // Modify menu with business rules before rendering
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
      // Remove some items from future created accounts 
      if (page.ApplicationTime > MetraTech.MetraTime.Now.ToEndOfDay())
      {
        menu.RemoveMenuItemById("ViewOnlineBill");
        menu.RemoveMenuItemById("AdjustTransactions");
        menu.RemoveMenuItemById("BulkAdjustments");
        menu.RemoveMenuItemById("IssueMiscAdjustment");
      }
      
      //remove View Online Bill if the managed user doesn't have access to it
      if (page.UI.Subscriber.SessionContext != null)
      {
        IMTSecurity security = new MTSecurity();

        MetraTech.Interop.MTAuth.IMTCompositeCapability appLogon = security.GetCapabilityTypeByName("Application LogOn").CreateInstance();
        MetraTech.Interop.MTAuth.IMTEnumTypeCapability enumCap = appLogon.GetAtomicEnumCapability();
        enumCap.SetParameter("MPS");
        bool hasAccessToMV = page.UI.Subscriber.SessionContext.SecurityContext.HasAccess(appLogon);
        
        if (!hasAccessToMV)
        {
          menu.RemoveMenuItemById("ViewOnlineBill");
        }
      }
      
      // Only show templates if they are supported by the current account type
      AccountTypeManager accountTypeManager = new AccountTypeManager();
      YAAC.MTYAAC yaac = new YAAC.MTYAAC();
      yaac.InitAsSecuredResource((int) page.UI.Subscriber.SelectedAccount._AccountID,
                                 (MetraTech.Interop.MTYAAC.IMTSessionContext) page.UI.SessionContext,
                                 page.ApplicationTime);
      IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext) page.UI.SessionContext,
                                                                     yaac.AccountTypeID);
      if (!accType.CanHaveTemplates)
      {
        menu.RemoveMenuItemById("EditAccountTemplate");
      }

      // Don't show move account for account types that are not visible in the hierarchy
      if (!accType.IsVisibleInHierarchy)
      {
        menu.RemoveMenuItemById("MoveAccount");
        menu.RemoveMenuItemById("PayerForMe");
        menu.RemoveMenuItemById("GroupSubscriptions3");

      }

      // Remove PaymentMethods if PaymentServer is not installed
      bool isPaymentServerInstalled = false;
      RCD.IMTRcd rcd = new RCD.MTRcd();
      foreach (string extension in rcd.ExtensionList)
      {
        if (extension.ToLower() == "paymentsvrclient")
        {
          isPaymentServerInstalled = true;
          break;
        }
      }
      if(isPaymentServerInstalled == false)
      {
        menu.RemoveMenuItemById("PaymentMethods");
      }

      // Hide function not supported by the current AD authentication implementation
      if (auth != null && auth.Credentials.AuthenticationType == MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.AuthenticationType.ActiveDirectory)
      {
        if (auth.Credentials.Name_Space.ToUpperInvariant() == "SYSTEM_USER")
        {
          /// CSRs
          menu.RemoveMenuItemById("SUGeneratePassword");
          menu.RemoveMenuItemById("SUUnlockAccount");
        }
        else
        {
          // Customer accounts
          menu.RemoveMenuItemById("GeneratePassword");
          menu.RemoveMenuItemById("UnlockAccount");
        }        
      }
    }

  }
}

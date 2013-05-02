using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Interop.RCD;

namespace MetraTech.UI.Common.Test
{
  /// <summary>
  ///   Unit Tests for MenuManager.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console.exe /fixture:MetraTech.UI.Common.Test.MenuManagerTest /assembly:MetraTech.UI.Common.Test.dll
  /// </summary>
  [TestClass]
  public class MenuManagerTest
  {
    /// <summary>
    /// Location of menu file
    /// </summary>
    public string menuFilename;
    public string menuFilename2;

    /// <summary>
    /// MenuManager instance for test
    /// </summary>
    public MenuManager menuManager;
    public MenuManager menuManager2;

    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [ClassInitialize]
    public void Init()
    {
      // Seed config file
      //mm = new MenuManager();
      //MenuSection menuSection = new MenuSection();
      //menuSection.ID = "TestSection";
      //menuSection.Caption = "Test Section";
      //MenuItem menuItem = new MenuItem();
      //menuItem.ID = "TestMenu";
      //menuItem.Caption = "Test Menu";
      //menuItem.Icon = "/Res/Images/icon.gif";
      //menuItem.Link = "#";
      //menuItem.Target = "";
      //menuItem.RequiredCapabilities.Capabilities.Add("Manage Account");
      //menuItem.RequiredCapabilities.Capabilities.Add("Manage Account 2");
      //menuSection.MenuItems.Add(menuItem);
      //Menu menu = new Menu();
      //menu.ID = "TestMenu";
      //menu.Type = MenuManager.MenuType.Horizontal;
      //menu.MenuSections.Add(menuSection);
      //mm.Menus.Add(menu);
      //mm.Save(menuFilename);
      // End seed code

      // Find the menu file from the registry
      IMTRcd r = new MTRcdClass();
      menuFilename = r.InstallDir + @"UI\MetraNet\Config\Menus\MetraCareMenu.xml";
      menuFilename2 = r.InstallDir + @"Extensions\MetraView\Sites\MetraView\Config\Menus\MainMenu.xml";
      if (!System.IO.File.Exists(menuFilename))
      {
        // if file doesn't exists we are on a dev box
          menuFilename = @"s:\MetraTech\UI\MetraNet\Config\Menus\MetraCareMenu.xml";
      }
      
      menuManager = MenuManager.Load(menuFilename);
      menuManager2 = MenuManager.Load(menuFilename2);
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [ClassCleanup]
    public void Dispose()
    {
    }

    /// <summary>
    /// TestMenuManager - verifies that we can load the MetraCare menu correctly
    /// </summary>
    [TestMethod]
    [TestCategory("TestMenuManager")]
    public void TestMenuManager()
    {
      Assert.IsNotNull(menuManager);
      // Echo menu
      RenderMenu(menuManager);


      Assert.IsNotNull(menuManager2);
      // Echo menu
      RenderMenu(menuManager2);
    }

    /// <summary>
    /// Test rendering menu
    /// </summary>
    /// <param name="mm"></param>
    private void RenderMenu(MenuManager mm)
    {
      foreach (Menu menu in mm.Menus)
      {
        Console.WriteLine("*** " + menu.ID);
        foreach (MenuSection menuSection in menu.MenuSections)
        {
          Console.WriteLine(" + " + menuSection.ID);
          foreach (MenuItem menuItem in menuSection.MenuItems)
          {
            Console.WriteLine("  - " + menuItem.ID);
            foreach (string cap in menuItem.RequiredCapabilities.Capabilities)
            {
              if (menuItem.RequiredCapabilities.Operator == OperatorType.And)
              {
                Console.WriteLine("   && " + cap);
              }
              else
              {
                Console.WriteLine("   || "  + cap);
              }
            }
          }
        }
      }
    }
  }
}

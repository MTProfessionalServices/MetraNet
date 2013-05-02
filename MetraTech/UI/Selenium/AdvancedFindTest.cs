using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:AdvFind /fixture:MetraTech.UI.Test.Selenium /assembly:o:\debug\bin\MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Subscription smoke test suite for MetraCare
  /// </summary>
  [TestFixture]
  public class AdvancedFindTest
  {
    #region Private Properties
    private ISelenium selenium;
    private StringBuilder verificationErrors;
    private TestLibrary test = null;
    private long seed;
    #endregion

    #region SetupTest
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [SetUp]
    public void SetupTest()
    {
      SeleniumServer.StartSeleniumServer();
      test = new TestLibrary(out selenium);
      verificationErrors = new StringBuilder();

      // Login
      test.LoginMetraNet("Admin", "Admin123");

      // Create user for us to create a subscription on
      seed = System.DateTime.Now.Ticks;
      test.CreateCoreSubscriber(
        "Username_" + seed.ToString(),
        "First_" + seed.ToString(),
        "Last_" + seed.ToString(),
        "Company_" + seed.ToString(),
        "CoreSubscriber",
        DateTime.Now,
        "MetraTech",
        "MetraTech");
    }
    #endregion

    #region TearDownTest
    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [TearDown]
    public void TeardownTest()
    {
      try
      {
        selenium.Stop();
      }
      catch (Exception)
      {
        // Ignore errors if unable to close the browser
      }
      Assert.AreEqual("", verificationErrors.ToString());
    }
    #endregion

    #region AdvancedFind Tests
    /// <summary>
    /// CreateSubscriptionTest creates a new coresubscriber account, and subscribes them to a simple test product offering.
    /// </summary>
    [Test]
    [Category("AdvFind")]
    public void CreateAdvancedFindTest()
    {
      selenium.SelectFrame("relative=up");
      test.ClickButton("Advanced Find");
      Thread.Sleep(10000);
      selenium.SelectFrame("MainContentIframe");
      Thread.Sleep(10000);

      test.WaitForTextPresent("Search Filters");
      
      //search using account name
      Thread.Sleep(1000);
      test.ClickButton("Clear");
      selenium.Type("//div[@id='wrapper_filter_UserName_ctl00_ContentPlaceHolder1_MyGrid1']/div/div/div/div/input", "Username_" + seed.ToString());
      test.ClickButton("Search");
      test.WaitForTextPresent("Accounts");
      test.ClickButton("Clear");
      test.WaitForTextPresent("Username_" + seed.ToString());      

      //search using first name
      Thread.Sleep(1000);
      test.ClickButton("Clear"); 
      selenium.Type("filter_LDAP_Bill-To_#FirstName_ctl00_ContentPlaceHolder1_MyGrid1", "First_" + seed.ToString());
      test.ClickButton("Search");

      test.WaitForTextPresent("Username_" + seed.ToString());

      //search using last name
      Thread.Sleep(1000);
      test.ClickButton("Clear");
      selenium.Type("filter_LDAP_Bill-To_#LastName_ctl00_ContentPlaceHolder1_MyGrid1", "Last_" + seed.ToString());
      test.ClickButton("Search");

      test.WaitForTextPresent("Username_" + seed.ToString());

      //search by account type and username
      Thread.Sleep(1000);
      test.ClickButton("Clear");
      selenium.Type("filter_UserName_ctl00_ContentPlaceHolder1_MyGrid1", "Username_" + seed.ToString());
      selenium.Type("combo_filter_AccountTypeID_ctl00_ContentPlaceHolder1_MyGrid1-value", "Co");
      test.ClickButton("Search");
      test.WaitForTextPresent("Username_" + seed.ToString());

      //search by account status and username
      Thread.Sleep(1000);
      test.ClickButton("Clear");
      selenium.Type("filter_UserName_ctl00_ContentPlaceHolder1_MyGrid1", "Username_" + seed.ToString());
      selenium.Type("filter_AccountStatus_ctl00_ContentPlaceHolder1_MyGrid1", "Active");
      test.ClickButton("Search");

      test.WaitForTextPresent("Username_" + seed.ToString());

      //Ancestor Account and username
      Thread.Sleep(1000);
      test.ClickButton("Clear");
      selenium.Type("filter_UserName_ctl00_ContentPlaceHolder1_MyGrid1", "Username_" + seed.ToString());
      selenium.Type("combo_filter_AncestorAccountID_ctl00_ContentPlaceHolder1_MyGrid1", "");
      selenium.TypeKeys("combo_filter_AncestorAccountID_ctl00_ContentPlaceHolder1_MyGrid1", "MetraTech");
      selenium.Type("filter_UserName_ctl00_ContentPlaceHolder1_MyGrid1", "Username_" + seed.ToString());
      Thread.Sleep(6000);
      selenium.KeyDown("combo_filter_AncestorAccountID_ctl00_ContentPlaceHolder1_MyGrid1", "\\13");

      Thread.Sleep(2000);
      test.ClickButton("Search");
      test.WaitForTextPresent("First_" + seed.ToString());
           
    }
    #endregion
  }
}

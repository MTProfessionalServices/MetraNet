using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:Template /fixture:MetraTech.UI.Test.Selenium /assembly:o:\debug\bin\MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Account Template test suite for MetraCare
  /// </summary>
  [TestFixture]
  public class AccountTemplateTests
  {
    #region Private Properties
    private ISelenium selenium;
    private StringBuilder verificationErrors;
    private string mUserName = "";
    private TestLibrary test = null;
    #endregion

    #region SetupTest
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [TestFixtureSetUp]
    public void SetupTest()
    {
      SeleniumServer.StartSeleniumServer();

      selenium = new DefaultSelenium("localhost", 4444, "*firefox", "http://localhost");
      selenium.Start();
      selenium.WindowMaximize();
      selenium.WindowFocus();
      test = new TestLibrary(selenium);
      verificationErrors = new StringBuilder();

      // Login
      test.LoginMetraCare("su", "su123");

      // Create user for us to create a subscription on
  //  //  mUserName = "KevinTest" + System.DateTime.Now.Ticks;
  //    test.CreateCoreSubscriber(mUserName);

      // Lookup mUserName
      //test.ManageAccount(mUserName);
    }
    #endregion

    #region TearDownTest
    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [TestFixtureTearDown]
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

    #region Template Tests
    /// <summary>
    /// Template Tests
    /// </summary>
    [Test]
    [Category("Template")]
    public void AccountTemplateTest()
    {
      // Lookup MetraTech and select edit template
      test.ManageAccount("MetraTech");
      test.SelectMenu("Account Details", "Edit Template");
      test.Wait();
   
      // Add Template
      test.ClickButton("Add Template");
      test.Wait();

      selenium.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "label=CoreSubscriber");
      test.ClickButton("OK");
      test.Wait();

      test.WaitForTextPresent("Description");
      selenium.Type("ctl00_ContentPlaceHolder1_tbDescription", "Test Account Template");
      selenium.Type("ctl00_ContentPlaceHolder1_tbLDAP_0__Address1", "1 Main St.");
      selenium.Type("ctl00_ContentPlaceHolder1_tbLDAP_0__City", "Manchester");
      selenium.Type("ctl00_ContentPlaceHolder1_tbLDAP_0__State", "NH");
      selenium.Type("ctl00_ContentPlaceHolder1_tbLDAP_0__Zip", "03102");

      // Add subscription to template
      test.WaitForTextPresent("Add Subscription");
      test.ClickButton("Add Subscription");
      test.Wait();

      test.SelectGridRow("MTFilterGrid1", 0);
      test.ClickButton("OK");
      test.Wait();

      test.ClickButton("Save");
      test.WaitForTextPresent("Account Templates");

      // Delete Template
      test.ClickID("delete");
      selenium.SelectFrame("relative=up");
      test.WaitForTextPresent("Are you sure you want to delete");
      test.ClickButton("OK");
      selenium.SelectFrame("MainContentIframe");
      test.WaitForTextPresent("There are no Account Templates on this account.");
    }
    #endregion
  }
}

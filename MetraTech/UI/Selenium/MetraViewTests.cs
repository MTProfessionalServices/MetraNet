using System;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:MetraView /fixture:MetraTech.UI.Test.Selenium /assembly:MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// MetraView smoke test suite
  /// </summary>
  [TestFixture]
  public class MetraViewTests
  {
    #region Private Properties
    private ISelenium selenium;
    private string userName = "demo";
    private string password = "demo123";
    private TestLibrary test;
    #endregion

    #region SetupTest
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [TestFixtureSetUp]
    public void SetupTest()
    {
      SeleniumServer.StartSeleniumServer();
      test = new TestLibrary(out selenium);
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
    }
    #endregion

    #region MetraView Tests
    /// <summary>
    /// Simple Menu Test
    /// </summary>
    [Test]
    [Category("MetraView")]
    public void MetraViewLoginTest()
    {
      // Login
      test.LoginMetraView(userName, password);
      test.WaitForTextPresent("Available Product Offerings");

      // Click bill
      test.ClickID("linkBill");
      test.Wait();
      test.WaitForTextPresent("Payment Information");

      // Click reports
      test.ClickID("linkReports");
      test.Wait();
      test.WaitForTextPresent("Usage");

      // Click account info
      test.ClickID("linkAccountInfo");
      test.Wait();
      test.WaitForTextPresent("First Name:");    
    }
    #endregion
  }
}

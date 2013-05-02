using System;
using System.Text;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:MetraControl /fixture:MetraTech.UI.Test.Selenium /assembly:MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Subscription smoke test suite for MetraCare
  /// </summary>
  [TestFixture]
  public class MetraControlTests
  {
    #region Private Properties
    private ISelenium selenium;
    private StringBuilder verificationErrors;
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
      test = new TestLibrary(out selenium);
      verificationErrors = new StringBuilder();

      // Login
      test.LoginMetraNet("Admin", "Admin123");
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

    #region MetraControl Tests

    /// <summary>
    /// Clicks to make sure MetraControl is up
    /// </summary>
    [Test]
    [Category("MetraControl")]
    public void _01_MetraControlTest()
    {
      test.SelectAppMenu("MetraControl");
    
      test.SelectMainMenu("BillableIntervals");

      selenium.SelectFrame("ticketFrame");

     
      try
      {
        Assert.IsTrue(selenium.IsTextPresent("Billable Intervals"));
      }
      catch (AssertionException e)
      {
        verificationErrors.Append(e.Message);
      }

    }

  
    #endregion
  }
}

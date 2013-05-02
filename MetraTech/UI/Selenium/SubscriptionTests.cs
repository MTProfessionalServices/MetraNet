using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:Subscription /fixture:MetraTech.UI.Test.Selenium /assembly:o:\debug\bin\MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Subscription smoke test suite for MetraCare
  /// </summary>
  [TestFixture]
  public class SubscriptionTests
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
      test = new TestLibrary(out selenium);
      verificationErrors = new StringBuilder();

      // Prime UI
      //test.PrimeUI();
      //Thread.Sleep(10000);

      // Login
      test.LoginMetraNet("Admin", "Admin123");
      
      // Create user for us to create a subscription on
      mUserName = "KevinTest" + System.DateTime.Now.Ticks;
      test.CreateCoreSubscriber(mUserName);

      // Lookup mUserName
      test.ManageAccount(mUserName);
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

    #region Subscription Tests
    /// <summary>
    /// CreateSubscriptionTest creates a new subscription to a simple test product offering.
    /// </summary>
    [Test]
    [Category("Subscription")]
    public void _01_CreateSubscriptionTest()
    {
      test.SelectMenuItemOnSpan("Subscriptions", "Subscriptions");
      test.Wait();

      test.ClickButton("Add Subscription");
      test.Wait();

      test.WaitForTextPresent("Offering");

      // Apply Filter
      selenium.Click("//div[@id='filterPanel1_div_ctl00_ContentPlaceHolder1_MyGrid1']/div/div/div/div/div[@class='x-tool x-tool-toggle']");
      test.WaitForTextPresent("Search");  
      test.SetTextByName("filter_DisplayName_ctl00_ContentPlaceHolder1_MyGrid1", "Simple Product");
      test.ClickButton("Search");
      Thread.Sleep(5000);
      test.WaitForTextPresent("a simple test product offering");

      test.SelectGridRow("MyGrid1", 0);
      test.ClickButton("OK");
      test.Wait();

      test.SetText("StartDate", System.DateTime.Now.ToShortDateString());
      test.ClickButton("OK");
      test.Wait();

      test.ClickButton("Add");
      test.WaitForTextPresent("Add Monthly Per-Subscription Unit Dependent Recurring Charge");
      test.SetTextByName("Value", "10");
      test.ClickButton("OK");
      test.Wait();

      test.WaitForTextPresent("10");
      test.Click("OK");
      test.Wait();

      test.ClickButton("Manage Subscriptions");
      test.Wait();
      test.WaitForTextPresent("Current");
    }

    /// <summary>
    /// UpdateSubscriptionTest - Updates the newly created subscription with a new start date
    /// </summary>
    [Test]
    [Category("Subscription")]
    public void _02_ModifySubscriptionTest()
    {
      test.SelectMenuItemOnSpan("Subscriptions", "Subscriptions");
    //  test.Wait();

      test.WaitForTextPresent("Simple Product Offering");
      test.ClickLinkContainsText("Simple Product Offering");
      test.Wait();

      test.SetText("StartDate", System.DateTime.Now.AddDays(2).ToShortDateString());
      test.ClickButton("OK");
      test.Wait();

      test.Click("OK");
      test.Wait();

      test.ClickButton("Manage Subscriptions");
      test.Wait();
     // test.WaitForTextPresent("Future");
    }

    /// <summary>
    /// UnsubscribeSubscriptionTest - Unsubscribes the subscription in the future
    /// </summary>
    [Test]
    [Category("Subscription")]
    public void _03_UnsubscribeSubscriptionTest()
    {
      test.SelectMenuItemOnSpan("Subscriptions", "Subscriptions");
     // test.Wait();

      test.WaitForTextPresent("Simple Product Offering");
      test.ClickID("unsubscribe");
      test.Wait();

      test.SetText("EndDate", System.DateTime.Now.AddDays(7).ToShortDateString());
      test.ClickButton("OK");
      test.Wait();

     // test.WaitForTextPresent("Current");

    }

    /// <summary>
    /// DelteSubscriptionTest - Deletes the newly created subscription
    /// </summary>
     [Test]
     [Category("Subscription")]
     public void _04_DeleteSubscriptionTest()
     {
       test.SelectMenuItemOnSpan("Subscriptions", "Subscriptions");
      // test.Wait();

       test.WaitForTextPresent("Simple Product Offering");
       test.ClickID("delete");
       test.Wait();

       test.ClickButton("OK");
       test.Wait();
      // test.WaitForTextPresent("No records found");
     }
    #endregion
  }
}

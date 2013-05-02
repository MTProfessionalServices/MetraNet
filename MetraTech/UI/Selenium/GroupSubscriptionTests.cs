using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:GroupSubscription /fixture:MetraTech.UI.Test.Selenium /assembly:o:\debug\bin\MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Group Subscription smoke test suite for MetraCare
  /// </summary>
  [TestFixture]
  public class GroupSubscriptionTests
  {
       
    #region Private Properties
    private ISelenium selenium;

    private StringBuilder verificationErrors;
    private string mUserName = "";
    private string mCoreSubUserName = "";
    private string mCoreSubUserName1 = "";
    private string mGroupSubName = "";
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
      test.LoginMetraNet("Admin", "123");

      // Create user for us to create a group subscription on
      mUserName = "KevinTestCorp" + System.DateTime.Now.Ticks;
      test.CreateCorporateAccount(mUserName);
      
      // Lookup mUserName
      test.ManageAccount(mUserName);
      selenium.SelectFrame("relative=up");

      mCoreSubUserName = "KevinTestCoreSub" + System.DateTime.Now.Ticks;
      test.CreateCoreSubscriber(mCoreSubUserName, "Core", "Subscriber001", "MetraTech", "CoreSubscriber", System.DateTime.Now, mUserName, mUserName);

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

    #region Group Subscription Tests
    /// <summary>
    /// GroupSubscriptionForAudioConfPO creates a new group subscription to a audio conf product offering.
    /// </summary>
    [Test]
    [Category("GroupSubscription")]
    public void GroupSubscriptionForAudioConfPO()
    {
      test.SelectMenuItemOnSpan("Subscriptions", "Group Subscriptions");
      test.Wait();

      //Add Group Subscription
      test.ClickButton("Add Group Subscription");
      test.Wait();

      test.WaitForTextPresent("Offering");

      // Apply Filter
      selenium.Click("//div[@id='filterPanel1_div_ctl00_ContentPlaceHolder1_POGrid']/div/div/div/div/div[@class='x-tool x-tool-toggle']");
      test.WaitForTextPresent("Search");
      test.SetTextByName("filter_DisplayName_ctl00_ContentPlaceHolder1_POGrid", "Audio Conferencing");
      test.ClickButton("Search");
      Thread.Sleep(5000);
      test.WaitForTextPresent("Product Offering for audio conferencing reference implementation using currency USD");

      test.SelectGridRow("POGrid", 0);
      test.ClickButton("OK");
      test.Wait();

      mGroupSubName = "TestAudioConfGroupSub" + System.DateTime.Now.Ticks;
      test.SetText("tbName", mGroupSubName);
      test.SetText("tbDescription", "Test Audio Conference Group Subscription");
      test.ClickButton("OK");
      Thread.Sleep(5000);
      
      //Edit Group Subscription
      test.ClickButton("Manage Group Subscriptions");
      test.ClickID("Edit");
      test.Wait();

      selenium.Click("//div[@id='MTCtl_ctl00_ContentPlaceHolder1_radSharedCounters']/div/input");
      Thread.Sleep(5000);

      selenium.Type("ctl00_ContentPlaceHolder1_tbAcctGrpDis", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAcctGrpDis", mUserName);
      test.ClickInlineSearch(mUserName);

      test.ClickButton("OK");
      Thread.Sleep(5000);

      //Add Member
      test.ClickButton("Manage Group Subscriptions");
      test.ClickID("members");
      test.Wait();

      test.ClickButton("Add Members");
      test.ClickButton("Select Accounts");
      Thread.Sleep(5000);
      selenium.SelectFrame("relative=up");
      selenium.SelectFrame("accountSelectorWindow2");
      selenium.Type("combo_filter_AncestorAccountID_ctl00_ContentPlaceHolder1_MyGrid1", "");
      selenium.TypeKeys("combo_filter_AncestorAccountID_ctl00_ContentPlaceHolder1_MyGrid1", mUserName);
      test.ClickInlineSearch(mUserName);
      test.ClickButton("Search");
      Thread.Sleep(5000);

      test.SelectGridRow("MyGrid1", 0);
      test.ClickButton("OK");
      selenium.SelectFrame("relative=parent");
      selenium.SelectFrame("MainContentIframe");
      test.ClickButton("OK");

      //Edit Member dates
      test.ClickID("Edit");
      test.Wait();

      test.SetText("tbMembershipSpan_StartDate", System.DateTime.Now.AddDays(1).ToShortDateString());
      test.ClickButton("OK");
      Thread.Sleep(5000);

      //Unsubscribe Member
      test.SelectGridRow("GroupSubMemGrid", 0);
      test.ClickButton("Unsubscribe Members");
      test.Wait();
      test.SetText("MTEffecEndDatePicker", System.DateTime.Now.AddDays(1).ToShortDateString());
      test.ClickButton("OK");
      Thread.Sleep(5000);

      //Delete Member
      test.SelectGridRow("GroupSubMemGrid", 0);
      test.ClickButton("Delete Members");
      test.ClickButton("OK");
      Thread.Sleep(5000);
    }

    /// <summary>
    ///  GroupSubscriptionForSimpleTestPO creates a new group subscription to a simple test product offering.
    /// </summary>
    [Test]
    [Category("GroupSubscription")]
    public void GroupSubscriptionForSimpleTestPO()
    {
      test.SelectMenuItemOnSpan("Subscriptions", "Group Subscriptions");
      test.Wait();

      ///////////////////Add Group Subscription/////////////////////////////////////
      test.ClickButton("Add Group Subscription");
      test.Wait();

      test.WaitForTextPresent("Offering");

      // Apply Filter
      selenium.Click("//div[@id='filterPanel1_div_ctl00_ContentPlaceHolder1_POGrid']/div/div/div/div/div[@class='x-tool x-tool-toggle']");
      test.WaitForTextPresent("Search");
      test.SetTextByName("filter_DisplayName_ctl00_ContentPlaceHolder1_POGrid", "Simple Product");
      test.ClickButton("Search");
      Thread.Sleep(5000);
      test.WaitForTextPresent("a simple test product offering");

      test.SelectGridRow("POGrid", 0);
      test.ClickButton("OK");
      test.Wait();

      test.SetText("tbName", "SimpleTestPOGroupSub" + System.DateTime.Now.Ticks);
      test.SetText("tbDescription", "Simple Test Product Offering Group Subscription");

      selenium.Click("//div[@id='MTCtl_ctl00_ContentPlaceHolder1_radSharedCounters']/div/input");
      Thread.Sleep(5000);

      selenium.Type("ctl00_ContentPlaceHolder1_tbAcctGrpDis", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAcctGrpDis", mUserName);
      test.ClickInlineSearch(mUserName);

      test.ClickButton("OK");
      Thread.Sleep(5000);

      //Edit UDRC Charge Account
      test.ClickID("Edit");
      test.Wait();
      selenium.Type("ctl00_ContentPlaceHolder1_tbChargeAccountId", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbChargeAccountId", mUserName);
      test.ClickInlineSearch(mUserName);

      test.ClickButton("OK");
      test.Wait();

      //Edit Flat Rate Charge Account
      test.ClickID("EditChargeAcct");
      test.Wait();
      selenium.Type("ctl00_ContentPlaceHolder1_tbChargeAccountId", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbChargeAccountId", mUserName);
      test.ClickInlineSearch(mUserName);

      test.ClickButton("OK");
      test.Wait();

      //Set UDRC Values
      test.ClickID("UDRCValues");
      test.Wait();

      test.ClickButton("Add");
      test.Wait();

      test.SetText("tbValue", "20");
      test.ClickButton("OK");
      test.Wait();

      test.ClickButton("OK");
      test.Wait();

      test.ClickButton("Save");
      test.Wait();

      ///////////////////////////////////////Edit Group Subscription//////////////////////////////////
      //test.SelectGridRow("GroupSubGrid", 0);
      test.SetTextByName("filter_Description_ctl00_ContentPlaceHolder1_GroupSubGrid", "Simple Test Product Offering");
      test.ClickButton("Search");
      Thread.Sleep(5000);
      test.WaitForTextPresent("a simple test product offering");
      test.ClickID("Edit");
      test.Wait();

      selenium.Click("//div[@id='MTCtl_ctl00_ContentPlaceHolder1_radSharedCounters']/div/input");
      Thread.Sleep(5000);

      selenium.Type("ctl00_ContentPlaceHolder1_tbAcctGrpDis", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAcctGrpDis", mCoreSubUserName);
      test.ClickInlineSearch(mCoreSubUserName);

      test.ClickButton("OK");
      test.Wait();

      //Edit UDRC Charge Account
      test.ClickID("Edit");
      test.Wait();
      selenium.Type("ctl00_ContentPlaceHolder1_tbChargeAccountId", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbChargeAccountId", mCoreSubUserName);
      test.ClickInlineSearch(mCoreSubUserName);

      test.ClickButton("OK");
      test.Wait();

      //Edit Flat Rate Charge Account
      test.ClickID("EditChargeAcct");
      test.Wait();
      selenium.Type("ctl00_ContentPlaceHolder1_tbChargeAccountId", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbChargeAccountId", mCoreSubUserName);
      test.ClickInlineSearch(mCoreSubUserName);

      test.ClickButton("OK");
      test.Wait();

      //Set UDRC Values
      test.ClickID("UDRCValues");
      test.Wait();

      test.ClickButton("Add");
      test.Wait();

      test.SetText("tbValue", "30");
      test.SetText("tbStartDate", System.DateTime.Now.AddDays(2).ToShortDateString());
      test.ClickButton("OK");
      test.Wait();

      test.ClickButton("OK");
      test.Wait();

      test.ClickButton("Save");
      test.Wait();
     
    }

    /// <summary>
    /// JoinGroupSubscription joins a core subscriber to an existing group subscription
    /// </summary>
    [Test]
    [Category("GroupSubscription")]
    public void JoinGroupSubscriptionTest()
    {
     // selenium.SelectFrame("relative=up");

      mCoreSubUserName1 = "KevinTestCS" + System.DateTime.Now.Ticks;
      test.CreateCoreSubscriber(mCoreSubUserName1, "Core", "Subscriber002", "MetraTech", "CoreSubscriber", System.DateTime.Now, mUserName, mUserName);
      test.ManageAccount(mCoreSubUserName1);

      test.SelectMenuItemOnSpan("Subscriptions", "Group Subscriptions");
      test.Wait();

      //Join Group Subscription
      test.ClickButton("Join Group Subscription");
      Thread.Sleep(5000);
      test.Wait();
      
      test.SelectGridRow("JoinGroupSubGrid", 0);
      test.ClickButton("OK");
      Thread.Sleep(5000);
      test.Wait();

      test.ClickButton("OK");
      Thread.Sleep(5000);
    }


    #endregion
  }


}



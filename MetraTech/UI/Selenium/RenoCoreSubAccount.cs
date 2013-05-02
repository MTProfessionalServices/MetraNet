using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /fixture:MetraTech.UI.Test.Selenium /assembly:o:\debug\bin\MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// CoreSubscriber Tests
  /// </summary>
  [TestFixture]
  public class RenoCoreSubAccount
  {
    private ISelenium selenium;
    private StringBuilder verificationErrors;
    private TestLibrary test = null;

    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [SetUp]
    public void SetupTest()
    {
      SeleniumServer.StartSeleniumServer();
      test = new TestLibrary(out selenium);
      verificationErrors = new StringBuilder();
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    // [TearDown]
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

    /// <summary>
    /// Create and update CoreSubscriber
    /// </summary>
    [Test]
    [Category("CoreSub")]
    public void TheRenoCoreSubAccountTest()
    {
      for (int i = 0; i < 1; i++)
      {
        Random rand = new Random();
        string UserName = "CoreSubUser" + rand.Next(1, 1000).ToString();
        
        //Open Login page
        test.LoginMetraNet("Admin", "Admin123");
       
        //Click "Add Account" button
      /*  selenium.Click("link=Add Account");
        selenium.WaitForPageToLoad("30000");*/
        selenium.SelectFrame("relative=up");
        test.ClickButton("Advanced Find");
        Thread.Sleep(1000);

        //Click "Add Account"
        selenium.Click("AddAccountWorkflow");
        Thread.Sleep(1000);
        selenium.SelectFrame("MainContentIframe");

        //Select "Account Type"
        test.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "CoreSubscriber");

        //Click "Ok" button
        test.ClickID("ctl00_ContentPlaceHolder1_btnOK");
        test.Wait();

        //Populate the fields
        //First name
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("ctl00_ContentPlaceHolder1_tbFirstName")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Type("ctl00_ContentPlaceHolder1_tbFirstName", "Core");

        //Middle Initial
        selenium.Type("ctl00_ContentPlaceHolder1_tbMiddleInitial", "S");

        //Last name
        selenium.Type("ctl00_ContentPlaceHolder1_tbLastName", "Subscriber");

        //Email
        selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "metratechto@yahoo.com");

        //Address
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress1", "Test Test");

        //Address1
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress2", "Test1 Test1");

        //Address2
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress3", "Test2 Test2");

        //City
        selenium.Type("ctl00_ContentPlaceHolder1_tbCity", "Test1");

        //Phone number
        selenium.Type("ctl00_ContentPlaceHolder1_tbPhoneNumber", "999-999-9999");

        //State
        selenium.Type("ctl00_ContentPlaceHolder1_tbState", "Test1");

        //Fax
        selenium.Type("ctl00_ContentPlaceHolder1_tbFacsimileTelephoneNumber", "888-888-8888");

        //Zipcode
        selenium.Type("ctl00_ContentPlaceHolder1_tbZip", "00000");

        //Company
        selenium.Type("ctl00_ContentPlaceHolder1_tbCompany", "Test1");

        //Country
        test.Select("ctl00_ContentPlaceHolder1_ddCountry", "Afghanistan");

        // Billing Cycle
        test.Select("ctl00_ContentPlaceHolder1_billingcycles", "Monthly");

        //Username
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("ctl00_ContentPlaceHolder1_tbUserName")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Type("ctl00_ContentPlaceHolder1_tbUserName", UserName);

        //Click "Validate" button
        selenium.Click("//button[text()='Validate']");
        bool OkFlag = true;

        try
        {
          Assert.IsTrue(selenium.IsVisible("ctl00_ContentPlaceHolder1_lblUsernameOK"));
        }
        catch (Exception)
        {
          OkFlag = false;
        }


        while (OkFlag == false)
        {
          UserName = "CoreSubUser" + rand.Next(1, 1000).ToString();
          selenium.Type("ctl00_ContentPlaceHolder1_tbUserName", UserName);
          selenium.Click("//button[text()='Validate']");
          try
          {
            Assert.IsTrue(selenium.IsVisible("ctl00_ContentPlaceHolder1_lblUsernameOK"));
            OkFlag = true;
          }
          catch (Exception)
          {
            OkFlag = false;
          }
        }

        Thread.Sleep(2000);


        //Click "Generate" button
        selenium.Click("//button[text()='Generate']");

        //Start Date
        selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", System.DateTime.Now.ToShortDateString());

        //Ancestor Account
        selenium.Type("ctl00_ContentPlaceHolder1_tbAncestorAccount", "");
        selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAncestorAccount", "MetraTech");
        test.ClickInlineSearch("MetraTech");

        //Check EmailNotification
        selenium.Click("ctl00_ContentPlaceHolder1_cbEmailNotification");

        //Language
        test.Select("ctl00_ContentPlaceHolder1_ddLanguage", "US English");

        //Currency
        test.Select("ctl00_ContentPlaceHolder1_ddCurrency", "USD");

        //Paper Invoice
        test.Select("ctl00_ContentPlaceHolder1_ddPaperInvoice", "Standard");

        //Status reason
        test.Select("ctl00_ContentPlaceHolder1_ddStatusReason", "Pending Approval");

        //Other
        selenium.Type("ctl00_ContentPlaceHolder1_tbOther", "Test Test");

        //Tax Exempt
        selenium.Click("ctl00_ContentPlaceHolder1_cbTaxExempt");

        //Tax exempt ID
        selenium.Type("ctl00_ContentPlaceHolder1_tbTaxExemptID", "700");

        //Security Question
        test.Select("ctl00_ContentPlaceHolder1_ddSecurityQuestion", "Social Security Number");

        //Security Answer
        selenium.Type("ctl00_ContentPlaceHolder1_tbSecurityAnswer", "Test");

        //Click "Ok" button
        Thread.Sleep(2000);
        test.ClickID("ctl00_ContentPlaceHolder1_btnOK");
        Thread.Sleep(3000);


        /************UPDATE ACCOUNT ************/

        selenium.SelectFrame("relative=up");
        selenium.Type("search", "");
        selenium.TypeKeys("search", UserName);
        test.ClickInlineSearch(UserName);
        selenium.WaitForPageToLoad("30000");
        selenium.SelectFrame("MainContentIframe");


        //Click "Account Details"
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("//button[text()='Account Details']")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Click("//button[text()='Account Details']");

        //Click "Update Account"
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("//span[text()='Update Account']")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Click("//span[text()='Update Account']");

        //Modify "Company"
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("ctl00_ContentPlaceHolder1_tbCompany")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Type("ctl00_ContentPlaceHolder1_tbCompany", "Company Name");

        //Click "Ok" button
        test.ClickID("ctl00_ContentPlaceHolder1_btnOk");

        /************* UPDATE CONTACT **********/
        //Click "Account Details"
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("//button[text()='Account Details']")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Click("//button[text()='Account Details']");

        //Click "Update Contacts"
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("//span[text()='Update Contacts']")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Click("//span[text()='Update Contacts']");

        //Click "Edit" button
        test.ClickLink("Bill-To");
        
        //Change "Phone number"
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("ctl00_ContentPlaceHolder1_tbPhoneNumber")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Type("ctl00_ContentPlaceHolder1_tbPhoneNumber", "111-111-1111");

        //Click "Ok" button
        test.ClickID("ctl00_ContentPlaceHolder1_btnOK");
        Thread.Sleep(3000);

        TeardownTest();
        SetupTest();
      }

      TeardownTest();
    }


  }
}

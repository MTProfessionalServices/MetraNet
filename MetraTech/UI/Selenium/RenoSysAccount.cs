using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// SystemAccount tests.
  /// </summary>
  [TestFixture]
  public class RenoSysAccount
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
    //[TearDown]
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
    /// Create and update SystemAccount
    /// </summary>
    [Test]
    public void TheRenoSystemAccountTest()
    {

      for (int i = 0; i < 1; i++)
      {
        //Open Login page
        test.LoginMetraNet("Admin", "Admin123");

        //Click "Add Account"
       // selenium.Click("link=Add CSR");
        test.ClickButton("Advanced Find");
        Thread.Sleep(1000);
        selenium.Click("link=Add CSR");
        Thread.Sleep(1000);
        test.Wait();
        selenium.SelectFrame("MainContentIframe");
        //Populate the fields

        //First Name
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
        selenium.Type("ctl00_ContentPlaceHolder1_tbFirstName", "System");

        //Middle Initial
        selenium.Type("ctl00_ContentPlaceHolder1_tbMiddleInitial", "S");

        //Last Name
        selenium.Type("ctl00_ContentPlaceHolder1_tbLastName", "Account");

        //Email
        selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "metratechto@yahoo.com");

        //Address
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress1", "330 Bear Hill Road");

        //Address1
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress2", "Test Test");

        //Address2
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress3", "Test Test");

        //City
        selenium.Type("ctl00_ContentPlaceHolder1_tbCity", "Waltham");

        //Phone number
        selenium.Type("ctl00_ContentPlaceHolder1_tbPhoneNumber", "911-932-9221");

        //State
        selenium.Type("ctl00_ContentPlaceHolder1_tbState", "MA");

        //Fax
        selenium.Type("ctl00_ContentPlaceHolder1_tbFacsimileTelephoneNumber", "222-333-7777");

        //Zipcode
        selenium.Type("ctl00_ContentPlaceHolder1_tbZip", "76538");

        //Company
        selenium.Type("ctl00_ContentPlaceHolder1_tbCompany", "MetraTech Corporation");

        //Country
        test.Select("ctl00_ContentPlaceHolder1_ddCountry", "USA");

        //Language
        test.Select("ctl00_ContentPlaceHolder1_ddLanguage", "US English");

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

        Random rand = new Random();
        string UserName = "SysAcctUser" + rand.Next(1, 1000).ToString();
        selenium.Type("ctl00_ContentPlaceHolder1_tbUserName", UserName);

        selenium.Type("ctl00_ContentPlaceHolder1_tbPassword", "SysAccTest");

        selenium.Type("ctl00_ContentPlaceHolder1_tbConfirmPassword", "SysAccTest");

        //Start Date
        selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", System.DateTime.Now.ToShortDateString());

        //Ancestor account
        selenium.Type("ctl00_ContentPlaceHolder1_tbAncestorAccount", " (1)");

        //click "Ok" button
        test.ClickID("ctl00_ContentPlaceHolder1_Button1");
        Thread.Sleep(6000);             

        //*************UPDATE SYSTEM USER ACCOUNT****************************/
        test.ClickID("ctl00_ContentPlaceHolder1_btnManage");
        selenium.WaitForPageToLoad("30000");


        //*************UPDATE SYSTEM ACCOUNT****************************/
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
        selenium.WaitForPageToLoad("30000");
        Thread.Sleep(6000);

        //Modify Email
        for (int second = 0; ; second++)
        {
          if (second >= 60) Assert.Fail("timeout");
          try
          {
            if (selenium.IsElementPresent("ctl00_ContentPlaceHolder1_tbEmail")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "TestSysUserAccount@MetraTech.com");

        //Retype password
        //selenium.Type("ctl00_ContentPlaceHolder1_tbPassword", "SysAccTest");

        //Retype confirm password
        //selenium.Type("ctl00_ContentPlaceHolder1_tbConfirmPassword", "SysAccTest");

        //Click "Ok" button
        test.ClickID("ctl00_ContentPlaceHolder1_btnOK");
        Thread.Sleep(6000);
        
        TeardownTest();
        SetupTest();

      }

      TeardownTest();
    }

  }
}


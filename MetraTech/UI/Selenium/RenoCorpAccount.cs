using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using Selenium;

namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// CorporateAccount tests
  /// </summary>
  [TestFixture]
  public class RenoCorpAccount
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
    [TearDown] //To be commented finally
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
    /// Create and update CorporateAccount
    /// </summary>
    [Test]
    public void TheRenoCorpAccountTest()
    {

      for (int i = 0; i < 1; i++)
      {
        //To be uncommented
        Random rand = new Random();
        string UserName = "CorpAcctUser" + rand.Next(1, 1000).ToString();

        //Login page
        test.LoginMetraNet("Admin", "Admin123");

        // Click "Add Account"
       /* selenium.Click("link=Add Account");
        selenium.WaitForPageToLoad("30000");*/

        selenium.SelectFrame("relative=up");
        test.ClickButton("Advanced Find");
        Thread.Sleep(1000);

        //Click "Add Account"
        selenium.Click("AddAccountWorkflow");
        Thread.Sleep(1000);
        selenium.SelectFrame("MainContentIframe");

        //Select "Account Type"
        test.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "CorporateAccount");

        //Click "OK" button
        test.ClickID("ctl00_ContentPlaceHolder1_btnOK");
        test.Wait();

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
        selenium.Type("ctl00_ContentPlaceHolder1_tbFirstName", "Corporate");

        //Middle Initial
        selenium.Type("ctl00_ContentPlaceHolder1_tbMiddleInitial", "C");

        //Last name
        selenium.Type("ctl00_ContentPlaceHolder1_tbLastName", "Account");

        //Email
        selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "metratechto@yahoo.com");

        //Address
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress1", "330 Bear Hill Road");

        //Address1
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress2", "Test");

        //Address2
        selenium.Type("ctl00_ContentPlaceHolder1_tbAddress3", "Test");

        //City
        selenium.Type("ctl00_ContentPlaceHolder1_tbCity", "Waltham");

        //Phone number
        selenium.Type("ctl00_ContentPlaceHolder1_tbPhoneNumber", "123-456-6789");

        //State
        selenium.Type("ctl00_ContentPlaceHolder1_tbState", "MA");

        //Fax
        selenium.Type("ctl00_ContentPlaceHolder1_tbFacsimileTelephoneNumber", "888-888-8888");

        //Zipcode
        selenium.Type("ctl00_ContentPlaceHolder1_tbZip", "12223");

        //Company
        selenium.Type("ctl00_ContentPlaceHolder1_tbCompany", "MetraTech");
        
        //Country
        test.Select("ctl00_ContentPlaceHolder1_ddCountry", "Algeria");
        
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

        //Validate button
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
          UserName = "CorpAcctUser" + rand.Next(1, 1000).ToString();
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
        
        //Generate button
        selenium.Click("//button[text()='Generate']");

        //Type Start Date
        selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", System.DateTime.Now.ToShortDateString());

        //Ancestor Account
        selenium.Type("ctl00_ContentPlaceHolder1_tbAncestorAccount", " (1)");

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
        Thread.Sleep(1000);
        test.ClickID("ctl00_ContentPlaceHolder1_btnOK");
        Thread.Sleep(3000);
                
        /****************UPDATE ACCOUNT**************/

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
            if (selenium.IsElementPresent("//span[text() ='Update Account']")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Click("//span[text() ='Update Account']");

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
        selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "TestCorpAcc@MetraTech.com");

        //Click "Ok" button
        test.ClickID("ctl00_ContentPlaceHolder1_btnOk");
        Thread.Sleep(3000);

        //********************UPDATE CONTACT*************************/
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
            if (selenium.IsElementPresent("//span[text() ='Update Contacts']")) break;
          }
          catch (Exception)
          { }
          Thread.Sleep(1000);
        }
        selenium.Click("//span[text() ='Update Contacts']");

        //Click "Edit" button
        test.ClickLink("Bill-To");

        //Change "Company"
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
        selenium.Type("ctl00_ContentPlaceHolder1_tbCompany", "MetraTech Corporation");

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

using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using MetraTech.Security;
using NUnit.Framework;
using Selenium;

using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// TestLibrary that contains common test functions used when driving the UI with Selenium
  /// </summary>
  public class TestLibrary
  {
    #region Private Members
    private const string GRID_PREFIX = "grid_ctl00_ContentPlaceHolder1_";
    private const string GRID_DATASTORE_PREFIX = "dataStore_ctl00_ContentPlaceHolder1_";
    private const string CONTROL_PREFIX = "ctl00_ContentPlaceHolder1_";
    private ISelenium selenium = null;
    #endregion

    #region Public Members
    /// <summary>
    /// UserName of the account the TestLibrary is currently working with.
    /// </summary>
    public string UserName = "";
    #endregion

    #region Constructor
    /// <summary>
    /// Constructor that takes in an instance of selenium
    /// </summary>
    /// <param name="sel"></param>
    public TestLibrary(out ISelenium sel)
    {
      sel = new DefaultSelenium("localhost", 4444, "*chrome", "http://localhost");
      //sel = new DefaultSelenium("localhost", 4444, "*firefox", "http://localhost");
      sel.Start();
      sel.SetTimeout("90000");
      sel.WindowMaximize();
      sel.WindowFocus();
      selenium = sel;
    }

	/// <summary>Constructor that takes in an instance of selenium</summary>
	/// <param name="lHost"></param>
	/// <param name="lPort"></param>
	/// <param name="lBrowser"></param>
	/// <param name="lUrl"></param>
	/// <param name="sel"></param>
	public TestLibrary(string lHost, int lPort, string lBrowser, string lUrl, out ISelenium sel)
	{
		sel = new DefaultSelenium(lHost, lPort, lBrowser, lUrl);
		sel.Start();
		sel.SetTimeout("90000");
		sel.WindowMaximize();
		sel.WindowFocus();
		selenium = sel;
	}
    #endregion

    #region Prime UI
    /// <summary>
    /// This test is called to Prime the UI, and no errors should be reported
    /// </summary>
    public void PrimeUI()
    {
      try
      {
        LoginMetraNet("Admin", "Admin123");
        string user = "Prime" + System.DateTime.Now.Ticks;
        CreateCoreSubscriber(user);
        ManageAccount(user);
      }
      catch (Exception exp)
      {
        Console.WriteLine("Error priming UI: ", exp.ToString());
      }
    }
    #endregion

    #region Create Accounts
    /// <summary>
    /// Creates a test CoreSubscriber account with the passed in username.
    /// </summary>
    /// <param name="username"></param>
    public void CreateCoreSubscriber(string username)
    {
      UserName = username;

      SelectMainMenu("AddAccountWorkflow");
      
      //Select "Account Type"
      Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "CoreSubscriber");
     // selenium.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "label=CoreSubscriber");

      //Click "Ok" button
      selenium.Click("ctl00_ContentPlaceHolder1_btnOK");
      Wait();

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
      selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "CoreSub@Metratech.com");

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

      //Language
      Select("ctl00_ContentPlaceHolder1_ddCountry", "Afghanistan");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddCountry", "label=Afghanistan");

      //Monthly
      Select("ctl00_ContentPlaceHolder1_billingcycles", "Monthly");
      //selenium.Select("ctl00_ContentPlaceHolder1_billingcycles", "label=Monthly");

      //Language
      Select("ctl00_ContentPlaceHolder1_ddLanguage", "US English");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddLanguage", "label=US English");

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

      //Click "Generate" button
      selenium.Click("//button[text()='Generate']");
      Thread.Sleep(5000);
      
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
      this.WaitForTextPresent("User Name OK");

      //Start Date
      selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", System.DateTime.Now.ToShortDateString());

      //Ancestor Account
      selenium.Type("ctl00_ContentPlaceHolder1_tbAncestorAccount", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAncestorAccount", "MetraTech");
      ClickInlineSearch("MetraTech");
      Thread.Sleep(5000);
      ClickButton("OK");
      Wait();

    }

    /// <summary>
    /// Creates a new CoreSubscriber by appending the passed in seed
    /// </summary>
    /// <param name="seed"></param>
    public void CreateCoreSubscriber(long seed)
    {
      UserName = "KevinTest" + seed.ToString();

      SelectMainMenu("AddAccountWorkflow");

      //Select "Account Type"      
      Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "CoreSubscriber");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "label=CoreSubscriber");

      //Click "Ok" button
      selenium.Click("ctl00_ContentPlaceHolder1_btnOK");
      selenium.WaitForPageToLoad("30000");
      selenium.SelectWindow("MainContentIframe");

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
      selenium.Type("ctl00_ContentPlaceHolder1_tbFirstName", "Core" + seed.ToString());

      //Middle Initial
      selenium.Type("ctl00_ContentPlaceHolder1_tbMiddleInitial", "S");

      //Last name
      selenium.Type("ctl00_ContentPlaceHolder1_tbLastName", "Subscriber" + seed.ToString());

      //Email
      selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "CoreSub@Metratech.com");

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
      Select("ctl00_ContentPlaceHolder1_ddCountry", "Afghanistan");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddCountry", "label=Afghanistan");

      // Billing Cycle
      Select("ctl00_ContentPlaceHolder1_billingcycles", "Monthly");
     // selenium.Select("ctl00_ContentPlaceHolder1_billingcycles", "label=Monthly");

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
      selenium.Type("ctl00_ContentPlaceHolder1_tbUserName", "KevinTest" + seed.ToString());

      //Click "Generate" button
      selenium.Click("//button[text()='Generate']");
      Thread.Sleep(5000);


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
      this.WaitForTextPresent("User Name OK");

      //Start Date
      selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", System.DateTime.Now.ToShortDateString());

      //Ancestor Account
      selenium.Type("ctl00_ContentPlaceHolder1_tbAncestorAccount", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAncestorAccount", "MetraTech");
      ClickInlineSearch("MetraTech");
      ClickButton("OK");
      Wait();

    }

    /// <summary>
    /// Create a new CoreSubscriber with the passed in parameters
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="firstName"></param>
    /// <param name="lastName"></param>
    /// <param name="companyName"></param>
    /// <param name="accountType"></param>
    /// <param name="startDate"></param>
    /// <param name="ancestorAccount"></param>
    /// <param name="payerID"></param>
    public void CreateCoreSubscriber(string userName, string firstName, string lastName, string companyName, 
        string accountType, DateTime startDate, string ancestorAccount, string payerID)
    {
      UserName = userName;

      SelectMainMenu("AddAccountWorkflow");

      //Select "Account Type"      
      Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "CoreSubscriber");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "label=CoreSubscriber");

      //Click "Ok" button
      selenium.Click("ctl00_ContentPlaceHolder1_btnOK");
     // Wait();
      //selenium.WaitForPageToLoad("30000");
      //selenium.SelectWindow("MainContentIframe");

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
      selenium.Type("ctl00_ContentPlaceHolder1_tbFirstName", firstName);

      //Middle Initial
      selenium.Type("ctl00_ContentPlaceHolder1_tbMiddleInitial", "S");

      //Last name
      selenium.Type("ctl00_ContentPlaceHolder1_tbLastName", lastName);

      //Email
      selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "CoreSub@Metratech.com");

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
      selenium.Type("ctl00_ContentPlaceHolder1_tbCompany", companyName);

      //Country
      Select("ctl00_ContentPlaceHolder1_ddCountry", "Afghanistan");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddCountry", "label=Afghanistan");

      // Billing Cycle
      Select("ctl00_ContentPlaceHolder1_billingcycles", "Monthly");
      //selenium.Select("ctl00_ContentPlaceHolder1_billingcycles", "label=Monthly");

      //Language
      Select("ctl00_ContentPlaceHolder1_ddLanguage", "US English");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddLanguage", "label=US English");

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
      selenium.Type("ctl00_ContentPlaceHolder1_tbUserName", userName);

      //Click "Generate" button
      selenium.Click("//button[text()='Generate']");
      Thread.Sleep(5000);
      
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
      this.WaitForTextPresent("User Name OK");

      //Start Date
      selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", startDate.ToShortDateString());

      //Ancestor Account
      selenium.Type("ctl00_ContentPlaceHolder1_tbAncestorAccount", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbAncestorAccount", ancestorAccount);
      ClickInlineSearch(ancestorAccount);

      //Payer Account
      selenium.Type("ctl00_ContentPlaceHolder1_tbPayer", "");
      selenium.TypeKeys("ctl00_ContentPlaceHolder1_tbPayer", payerID);
      ClickInlineSearch(payerID);

      ClickButton("OK");
      Wait();

    }

    /// <summary>
    /// Creates a test Corporate account with the passed in username.
    /// </summary>
    /// <param name="username"></param>
    public void CreateCorporateAccount(string username)
    {
      UserName = username;

      SelectMainMenu("AddAccountWorkflow");

      //Select "Account Type"
      Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "CorporateAccount");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddAccountTypes", "label=CorporateAccount");

      //Click "Ok" button
      selenium.Click("ctl00_ContentPlaceHolder1_btnOK");
      Wait();

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

      selenium.Type("ctl00_ContentPlaceHolder1_tbFirstName", "Corporate");

      //Middle Initial
      selenium.Type("ctl00_ContentPlaceHolder1_tbMiddleInitial", "C");

      //Last name
      selenium.Type("ctl00_ContentPlaceHolder1_tbLastName", "Account");

      //Email
      selenium.Type("ctl00_ContentPlaceHolder1_tbEmail", "CorpAcct@Metratech.com");

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

      //Language
      Select("ctl00_ContentPlaceHolder1_ddCountry", "Afghanistan");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddCountry", "label=Afghanistan");

      //Monthly
      Select("ctl00_ContentPlaceHolder1_billingcycles", "Daily");
      //selenium.Select("ctl00_ContentPlaceHolder1_billingcycles", "label=Daily");

      //Language
      Select("ctl00_ContentPlaceHolder1_ddLanguage", "US English");
      //selenium.Select("ctl00_ContentPlaceHolder1_ddLanguage", "label=US English");

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

      //Click "Generate" button
      selenium.Click("//button[text()='Generate']");
      Thread.Sleep(5000);

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
      this.WaitForTextPresent("User Name OK");

      //Start Date
      selenium.Type("ctl00_ContentPlaceHolder1_tbStartDate", System.DateTime.Now.ToShortDateString());

      Thread.Sleep(5000);
      ClickButton("OK");
      Wait();

    }



    #endregion

    #region Manage Account / Select Menu
    /// <summary>
    /// Finds and manages the account in MetraCare with the username provided.
    /// </summary>
    /// <param name="userName"></param>
    public void ManageAccount(string userName)
    {
      selenium.SelectFrame("relative=up");
      selenium.Type("search", "");
      selenium.TypeKeys("search", userName);
      ClickInlineSearch(userName);
      selenium.WaitForPageToLoad("30000");
      selenium.SelectFrame("MainContentIframe");
    }

    /// <summary>
    /// Selects an account menu in MetraCare.
    /// </summary>
    /// <param name="topMenu"></param>
    /// <param name="subMenu"></param>
    public void SelectMenu(string topMenu, string subMenu)
    {
      ClickButton(topMenu);
      ClickLink(subMenu);
    }

    public void SelectMenuItemOnSpan(string topMenu, string subMenu)
    {
      ClickButton(topMenu);
      ClickSpanWithText(subMenu);
    }
    #endregion

    #region Click Events
    /// <summary>
    /// Click a link <a></a> based on the text inside the link.
    /// </summary>
    /// <param name="linkText"></param>
    public void ClickLink(string linkText)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//a[text()='" + linkText + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//a[text()='" + linkText + "']");
    }

    /// <summary>
    /// Click a link <a></a> that contains the text inside the link.
    /// </summary>
    /// <param name="linkText"></param>
    public void ClickLinkContainsText(string linkText)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//a[contains(.,'" + linkText + "')]")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//a[contains(.,'" + linkText + "')]");
    }

    /// <summary>
    /// Click a <button></button> based on the button text.  This is good for Ext created buttons.
    /// </summary>
    /// <param name="buttonText"></param>
    public void ClickButton(string buttonText)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//button[text()='" + buttonText + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//button[text()='" + buttonText + "']");
    }

    /// <summary>
    /// Select dropdown value based on id of wrapper and select text.
    /// </summary>
    /// <param name="id"></param>
    /// <param name="selectText"></param>
    public void Select(string id, string selectText)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//div[@id='" + id + "_wrapper']/table/tbody/tr/td[2]/div/div/div/img")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }

      selenium.Click("//div[@id='" + id + "_wrapper']/table/tbody/tr/td[2]/div/div/div/img");
      WaitForTextPresent(selectText);
      Thread.Sleep(1000);
      selenium.Click("//div[text()='" + selectText + "']");
    }

    /// <summary>
    /// Click on any text on the screen that is in the value attribute of a node.
    /// </summary>
    /// <param name="text"></param>
    public void Click(string text)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//*[@value='" + text + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//*[@value='" + text + "']");
    }

    /// <summary>
    /// Click a div with the specified ID.
    /// </summary>
    /// <param name="divID"></param>
    public void ClickDiv(string divID)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//div[text()='" + divID + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//div[text()='" + divID + "']");
    }

    /// <summary>
    /// Click a div with the specified class name
    /// </summary>
    public void ClickDivWithClass(string css)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//div[@class='" + css + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//div[@class='" + css + "']");
    }

    /// <summary>
    /// Click any item with the specified ID.
    /// </summary>
    /// <param name="idText"></param>
    public void ClickID(string idText)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent(idText)) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click(idText);
    }

    /// <summary>
    /// Click any div with the specified ID.
    /// </summary>
    /// <param name="divID"></param>
    public void ClickDivID(string divID)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//div[@id='" + divID + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//div[@id='" + divID + "']");
    }

    /// <summary>
    /// Click any span with the specified ID.
    /// </summary>
    /// <param name="id"></param>
    public void ClickSpanID(string id)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//span[@id='" + id + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Click("//span[@id='" + id + "']");
    }

    /// <summary>
    /// Clicks on a span that contains the text specified in the parameter
    /// </summary>
    /// <param name="text"></param>
    public void ClickSpanWithText(string text)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//span[contains(.,'" + text + "')]")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }

      selenium.Click("//span[contains(.,'" + text + "')]");
    }

    /// <summary>
    /// Click DOM element with passed in xpath
    /// </summary>
    /// <param name="text"></param>
    public void ClickDOM(string text)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent(text)) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }

      selenium.Click(text);
    }

    /// <summary>
    /// Click an inline search result
    /// </summary>
    /// <param name="userName"></param>
    public void ClickInlineSearch(string userName)
    {
      ClickDOM(@"//div[@class=""x-combo-list-inner""]/div/h3[contains(.,'" + userName + "')]");
    }

    /// <summary>
    /// Select a grid row by index, the short grid name is passed in and the full control name is used when calling Ext script to select the grid row.
    /// </summary>
    /// <remarks>Rows start at zero.</remarks>
    /// <param name="gridID"></param>
    /// <param name="rowIndex"></param>
    public void SelectGridRow(string gridID, int rowIndex)
    {
      selenium.RunScript(GRID_PREFIX + gridID + ".getSelectionModel().selectRow(" + rowIndex.ToString() + ");");
    }

    public void ExpandGridRow(string gridID, int rowIndex)
    {
      selenium.RunScript(GRID_PREFIX + gridID + ".expandRow(" + rowIndex.ToString() + ");");
    }

    public int GetGridCount(string gridID)
    {
      //string script = "alert(this.browserbot.getCurrentWindow().document.Ext);";
      //string script = "alert(window.dataStore_ctl00_ContentPlaceHolder1_MyGrid1.getCount());";
      string script = "window."+ GRID_DATASTORE_PREFIX + gridID +".getCount();";
      //selenium.RunScript(GRID_DATASTORE_PREFIX + gridID + ".getCount()");
      //string result = selenium.GetEval("alert(this.browserbot);"); //.getCurrentWindow().document." + GRID_DATASTORE_PREFIX + gridID + ".getCount()");
      //string result = selenium.GetEval("alert(window.Ext.getCmp('" + GRID_DATASTORE_PREFIX + gridID + "'));"); //.getCurrentWindow().document." + GRID_DATASTORE_PREFIX + gridID + ".getCount()");
      string result = selenium.GetEval(script);

      int count = -1;
      if (int.TryParse(result, out count))
        return count;
      else
        return 0;
    }

    public int GetGridTotalCount(string gridID)
    {
      string script = "window." + GRID_DATASTORE_PREFIX + gridID + ".getTotalCount();";
      string result = selenium.GetEval(script);

      int count = -1;
      if (int.TryParse(result, out count))
        return count;
      else
        throw new ApplicationException(string.Format("Unable to get the TotalCount from the grid [{0}]; expression returned was '{1}'", gridID, result));
    }

    /// <summary>
    /// Fire any JavaScript event on a piece of text.
    /// </summary>
    /// <param name="eventName"></param>
    /// <param name="text"></param>
    public void FireEventOnText(string eventName, string text)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//*[text()='" + text + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.FireEvent("//*[text()='" + text + "']", eventName);
    }
    #endregion

    #region Wait
    /// <summary>
    /// Wait for page to load.  Times out after 30 seconds.
    /// </summary>
    public void Wait()
    {
      selenium.WaitForPageToLoad("30000");
    }

    /// <summary>
    /// Wait for text to appear on the screen.  Times out after a minute.
    /// </summary>
    /// <param name="txt"></param>
    public void WaitForTextPresent(string txt)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsTextPresent(txt)) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
    }

    /// <summary>
    /// Set text in a control.  Takes in the short ID form, and uses the full control ID.
    /// </summary>
    /// <param name="controlID"></param>
    /// <param name="txt"></param>
    public void SetText(string controlID, string txt)
    {
      selenium.Type(CONTROL_PREFIX + controlID, txt);
    }

    /// <summary>
    /// Set text in a control based on the control name.
    /// </summary>
    /// <param name="controlName"></param>
    /// <param name="txt"></param>
    public void SetTextByName(string controlName, string txt)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//input[@name='" + controlName + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.Type("//input[@name='" + controlName + "']", txt);
    }

    private IMTSessionContext LoginAsSU()
    {
      // sets the SU session context on the client
      IMTLoginContext loginContext = new MTLoginContextClass();
      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
      sa.Initialize();
      IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      string suName = accessData.UserName;
      string suPassword = accessData.Password;
      return loginContext.Login(suName, "system_user", suPassword);
    }

    /// <summary>
    /// Login to MetraNet
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="password"></param>
    public void LoginMetraNet(string userName, string password)
    {
      // now try to login
      object sessionContext = null;  // IMTSessionContext
      Auth auth = new Auth();
      auth.Initialize(userName, "system_user");
      LoginStatus status = auth.Login(password, null, ref sessionContext);
      if (status == LoginStatus.OKPasswordExpiringSoon)
      {
        // change password
        auth.ChangePassword(password, "123", LoginAsSU());
      }
      password = "123";

      selenium.Open("/MetraNet/Login.aspx");
      this.SetText("Login1_UserName", userName);
      this.SetText("Login1_Password", password);
      this.Click("Log In");
     // this.Wait();
      selenium.WaitForPageToLoad("60000");
    }

    /// <summary>
    /// Login to MetraView
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="password"></param>
    public void LoginMetraView(string userName, string password)
    {
      // now try to login
      object sessionContext = null;  // IMTSessionContext
      Auth auth = new Auth();
      auth.Initialize(userName, "mt");
      LoginStatus status = auth.Login(password, "MPS", ref sessionContext);
      if (status == LoginStatus.OKPasswordExpiringSoon)
      {
        // change password
        auth.ChangePassword(password, "123", LoginAsSU());
      }
      password = "123";

      selenium.Open("/MetraView/Login.aspx");
      this.SetText("Login1_UserName", userName);
      this.SetText("Login1_Password", password);
      this.Click("Login");
      selenium.WaitForPageToLoad("60000");
    }

		public void LogoutMetraNet()
		{
			// -- Logout from MetraNet
			//selenium.Open("/MetraNet/Default.aspx");
			selenium.SelectFrame("relative=up");
			selenium.SelectFrame("relative=up");
			selenium.Click("ext-gen32"); //press 'Logout' button
			Thread.Sleep(2000);
		}

		/// <summary>Log out of MetraView</summary>
		public void LogoutMetraView()
		{
				selenium.Open("/MetraView/Default.aspx"); // -- Logout from MetraView
				selenium.SelectFrame("relative=up");
				selenium.Click("//a[@id='linkLogout']");
				Thread.Sleep(1000);
		}

    /// <summary>
    /// Select Main Menu Option
    /// </summary>
    /// <param name="txt"></param>
    public void SelectMainMenu(string txt)
    {
      selenium.SelectFrame("relative=up");
     // this.ClickLink(txt);
     // this.Wait();
      ClickButton("Advanced Find");
      Thread.Sleep(1000);
      selenium.Click(txt);
      Thread.Sleep(1000);
      selenium.SelectFrame("MainContentIframe");
    }

    /// <summary>
    /// Select App Menu
    /// </summary>
    /// <param name="txt"></param>
    public void SelectAppMenu(string txt)
    {
      this.ClickSpanWithText(txt);
      Thread.Sleep(1000);
    }
  
    #endregion

    #region Special keys
    /// <summary>
    /// Sends ENTER key to a textbox specified by text
    /// </summary>
    /// <param name="text"></param>
    public void SendEnterKey(string text)
    {
      for (int second = 0; ; second++)
      {
        if (second >= 60) Assert.Fail("timeout");
        try
        {
          if (selenium.IsElementPresent("//input[@id='" + text + "']")) break;
        }
        catch (Exception)
        { }
        Thread.Sleep(1000);
      }
      selenium.KeyDown(text, "\\13");
    }
    #endregion

  }
}

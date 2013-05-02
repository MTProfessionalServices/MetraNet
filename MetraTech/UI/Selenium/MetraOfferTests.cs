using System;
using System.Text;
using System.Threading;
using NUnit.Framework;
using Selenium;

// nunit-console.exe /include:MetraOffer /fixture:MetraTech.UI.Test.Selenium /assembly:MetraTech.UI.Test.Selenium.dll
namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Subscription smoke test suite for MetraCare
  /// </summary>
  [TestFixture]
  public class MetraOfferTests
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

    #region MetraOffer Tests

    /// <summary>
    /// Clicks to make sure MetraOffer is up
    /// </summary>
    [Test]
    [Category("MetraOffer")]
    public void _01_MetraOfferTest()
    {
      SelectProductOfferings();

      try
      {
        Assert.IsTrue(selenium.IsTextPresent("Product Offerings"));        
      }
      catch (AssertionException e)
      {
        verificationErrors.Append(e.Message);
      }
    }
     
    private void SelectProductOfferings()
    {
      test.SelectAppMenu("MetraOffer");
      selenium.Click("id=MetraOfferGeneral");
      selenium.SelectFrame("MainContentIframe");
      test.Wait();
      selenium.SelectFrame("ticketFrame");
      selenium.SelectFrame("ProductOfferingMain");
    }

    /// <summary>
    /// SpecCharacteristics
    /// </summary>
    [Test]
    [Category("MetraOffer")]
    public void _200_MetraOfferTest_Shared_Properties_All_Types()
    {
      test.SelectAppMenu("MetraOffer");
      selenium.Click("id=SharedProperties");
      selenium.SelectFrame("MainContentIframe");
      test.Wait();
      
      AddPropertiesOfAllTypes();
    }

    private void AddPropertiesOfAllTypes()
    {
      var random = new Random();
      var index = random.Next(1000, 1000000);

      string[] types = {"String", "Int", "Decimal", "Boolean", "List", "Datetime"};
      var j = 0;
      for (var i = index; i < index + types.Length; i++)
      {
        test.ClickID("addNewProperty");
        test.Wait();
        selenium.Type("id=Category", "AllTypes");
        var name = types[j] + i;
        selenium.Type("id=Name", name);
        selenium.Type("id=Description", "unit test");

        selenium.Select("id=SpecType", types[j]);
        switch (types[j])
        {
          case "String":
            selenium.Type("id=StringValue", "hello");
            break;
          case "Int":
            selenium.Type("id=IntValue", "10");
            break;
          case "Decimal":
            selenium.Type("id=DecimalValue", "9.99");
            break;
          case "Boolean":
            selenium.Check("id=BooleanValue");
            break;
          case "List":
            selenium.Type("id=Choices", "a" + Environment.NewLine + "b" + Environment.NewLine + "c");
            break;
          case "Datetime":
            selenium.Type("id=DatetimeValue", DateTime.Now.ToShortDateString());
            break;
          default:
            break;
        }

        selenium.Check("id=IsUserVisible");
        selenium.Check("id=IsUserEditable");
        selenium.Check("id=IsRequired");

        selenium.Click("id=ok");
        test.Wait();

        try
        {
          Assert.IsTrue(selenium.IsTextPresent(name));
        }
        catch (AssertionException e)
        {
          verificationErrors.Append(e.Message);
        }
        j++;
      }
    }

    #endregion
  }
}

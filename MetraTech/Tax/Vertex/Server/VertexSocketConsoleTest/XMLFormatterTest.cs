using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace VertexSocketConsoleTest
{
    
    
    /// <summary>
    ///This is a test class for XMLFormatterTest and is intended
    ///to contain all XMLFormatterTest Unit Tests
    ///</summary>
  [TestClass()]
  public class XMLFormatterTest
  {


    private TestContext testContextInstance;

    /// <summary>
    ///Gets or sets the test context which provides
    ///information about and functionality for the current test run.
    ///</summary>
    public TestContext TestContext
    {
      get
      {
        return testContextInstance;
      }
      set
      {
        testContextInstance = value;
      }
    }

    #region Additional test attributes
    // 
    //You can use the following additional attributes as you write your tests:
    //
    //Use ClassInitialize to run code before running the first test in the class
    //[ClassInitialize()]
    //public static void MyClassInitialize(TestContext testContext)
    //{
    //}
    //
    //Use ClassCleanup to run code after all tests in a class have run
    //[ClassCleanup()]
    //public static void MyClassCleanup()
    //{
    //}
    //
    //Use TestInitialize to run code before running each test
    //[TestInitialize()]
    //public void MyTestInitialize()
    //{
    //}
    //
    //Use TestCleanup to run code after each test has run
    //[TestCleanup()]
    //public void MyTestCleanup()
    //{
    //}
    //
    #endregion


    /// <summary>
    ///A test for FormXMLStringForInputParams
    ///</summary>
    [TestMethod()]
    public void TestFormXMLStringForInputParamsForSuccessResult()
    {
      string returnCode = "0"; 
      string returnMessage = "Success";
      string expected = "<Return><ReturnCode>" + returnCode + "</ReturnCode><ReturnMessage>" + returnMessage + "</ReturnMessage></Return>";
      string actual = XMLFormatter.FormXMLStringForInputParams(returnCode, returnMessage);
      Assert.AreEqual(expected, actual);
    }

    /// <summary>
    ///A test for FormXMLStringForInputParams
    ///</summary>
    [TestMethod()]
    public void TestFormXMLStringForInputParamsForErrorResult()
    {
      string returnCode = "-1";
      string returnMessage = "Error";
      string expected = "<Return><ReturnCode>" + returnCode + "</ReturnCode><ReturnMessage>" + returnMessage + "</ReturnMessage></Return>";
      string actual = XMLFormatter.FormXMLStringForInputParams(returnCode, returnMessage);
      Assert.AreEqual(expected, actual);
    }

    /// <summary>
    ///A test for XMLFormatter Constructor
    ///</summary>
    [TestMethod()]
    public void XMLFormatterConstructorTest()
    {
      XMLFormatter target = new XMLFormatter();
      Assert.AreNotEqual(target, null);
    }
  }
}

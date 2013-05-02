using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace VertexSocketConsoleTest
{
    /// <summary>
    ///This is a test class for VertexTest and is intended
    ///to contain all VertexTest Unit Tests
    ///</summary>
  [TestClass()]
  public class VertexTest
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
    ///A test for Vertex Constructor
    ///</summary>
    [TestMethod()]
    public void VertexConstructorTest()
    {
      Vertex target = new Vertex();
      Assert.IsNotNull(target);
    }

    /// <summary>
    ///A test for CalculateTaxes
    ///</summary>
    [TestMethod()]
    public void CalculateTaxesTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      string xmlString = string.Empty; // TODO: Initialize to an appropriate value
      string expected = string.Empty; // TODO: Initialize to an appropriate value
      string actual;
      actual = target.CalculateTaxes(xmlString);
      Assert.AreEqual(expected, actual);
      Assert.Inconclusive("Verify the correctness of this test method.");
    }

    /// <summary>
    ///A test for InitializeVertex
    ///</summary>
    [TestMethod()]
    public void InitializeVertexTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      target.InitializeVertex();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for LoadVertexSettings
    ///</summary>
    [TestMethod()]
    public void LoadVertexSettingsTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      target.LoadVertexSettings();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for ReconnectVertex
    ///</summary>
    [TestMethod()]
    public void ReconnectVertexTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      target.ReconnectVertex();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for RefreshVertex
    ///</summary>
    [TestMethod()]
    public void RefreshVertexTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      target.RefreshVertex();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for ResetVertex
    ///</summary>
    [TestMethod()]
    public void ResetVertexTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      target.ResetVertex();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for Shutdown
    ///</summary>
    [TestMethod()]
    public void ShutdownTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      string expected = string.Empty; // TODO: Initialize to an appropriate value
      string actual;
      actual = target.Shutdown();
      Assert.AreEqual(expected, actual);
      Assert.Inconclusive("Verify the correctness of this test method.");
    }

    /// <summary>
    ///A test for IsVertexInitialized
    ///</summary>
    [TestMethod()]
    public void IsVertexInitializedTest()
    {
      Vertex target = new Vertex(); // TODO: Initialize to an appropriate value
      bool actual;
      actual = target.IsVertexInitialized;
      Assert.Inconclusive("Verify the correctness of this test method.");
    }
  }
}

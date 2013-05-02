using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
    /// <summary>
    ///This is a test class for MediatorTest and is intended
    ///to contain all MediatorTest Unit Tests
    ///</summary>
  [TestClass()]
  public class MediatorTest
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
    ///A test for Mediator Constructor
    ///</summary>
    [TestMethod()]
    public void MediatorConstructorTest()
    {
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      Mediator target = new Mediator(e);
      Assert.Inconclusive("TODO: Implement code to verify target");
    }

    /// <summary>
    ///A test for GiveBack
    ///</summary>
    [TestMethod()]
    public void GiveBackTest()
    {
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      Mediator target = new Mediator(e); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs expected = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs actual;
      actual = target.GiveBack();
      Assert.AreEqual(expected, actual);
      Assert.Inconclusive("Verify the correctness of this test method.");
    }

    /// <summary>
    ///A test for HandleData
    ///</summary>
    [TestMethod()]
    public void HandleDataTest()
    {
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      Mediator target = new Mediator(e); // TODO: Initialize to an appropriate value
      DataHolder incomingDataHolder = null; // TODO: Initialize to an appropriate value
      target.HandleData(incomingDataHolder);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for PrepareOutgoingData
    ///</summary>
    [TestMethod()]
    public void PrepareOutgoingDataTest()
    {
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      Mediator target = new Mediator(e); // TODO: Initialize to an appropriate value
      target.PrepareOutgoingData();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }
  }
}

using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
    
    
    /// <summary>
    ///This is a test class for MessageHandlerTest and is intended
    ///to contain all MessageHandlerTest Unit Tests
    ///</summary>
  [TestClass()]
  public class MessageHandlerTest
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
    ///A test for MessageHandler Constructor
    ///</summary>
    [TestMethod()]
    public void MessageHandlerConstructorTest()
    {
      MessageHandler target = new MessageHandler();
      Assert.Inconclusive("TODO: Implement code to verify target");
    }

    /// <summary>
    ///A test for HandleMessage
    ///</summary>
    [TestMethod()]
    public void HandleMessageTest()
    {
      MessageHandler target = new MessageHandler(); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs receiveSendEventArgs = null; // TODO: Initialize to an appropriate value
      DataHoldingUserToken receiveSendToken = null; // TODO: Initialize to an appropriate value
      int remainingBytesToProcess = 0; // TODO: Initialize to an appropriate value
      bool expected = false; // TODO: Initialize to an appropriate value
      bool actual;
      actual = target.HandleMessage(receiveSendEventArgs, receiveSendToken, remainingBytesToProcess);
      Assert.AreEqual(expected, actual);
      Assert.Inconclusive("Verify the correctness of this test method.");
    }
  }
}

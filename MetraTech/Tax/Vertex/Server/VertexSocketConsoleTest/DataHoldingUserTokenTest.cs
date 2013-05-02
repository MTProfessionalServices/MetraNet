using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
    
    
    /// <summary>
    ///This is a test class for DataHoldingUserTokenTest and is intended
    ///to contain all DataHoldingUserTokenTest Unit Tests
    ///</summary>
  [TestClass()]
  public class DataHoldingUserTokenTest
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
    ///A test for DataHoldingUserToken Constructor
    ///</summary>
    [TestMethod()]
    public void DataHoldingUserTokenConstructorTest()
    {
      SocketAsyncEventArgs e = new SocketAsyncEventArgs(); 
      int rOffset = 0; 
      int sOffset = 0; 
      DataHoldingUserToken target = new DataHoldingUserToken(e, rOffset, sOffset);
      Assert.AreEqual(target.receiveMessageOffset, 0);
      Assert.AreEqual(target.bufferOffsetSend, 0);
      Assert.AreEqual(target.bufferOffsetReceive, 0);
      Assert.AreNotEqual(target, null);
    }

    /// <summary>
    ///A test for CreateNewDataHolder
    ///</summary>
    [TestMethod()]
    public void CreateNewDataHolderTest()
    {
      SocketAsyncEventArgs e = new SocketAsyncEventArgs(); 
      int rOffset = 0; 
      int sOffset = 0; 
      DataHoldingUserToken target = new DataHoldingUserToken(e, rOffset, sOffset); 
      target.CreateNewDataHolder();
      Assert.AreNotEqual(null, target.theDataHolder);
    }

    /// <summary>
    ///A test for CreateSessionId
    ///</summary>
    [TestMethod()]
    public void CreateSessionIdTest()
    {
      SocketAsyncEventArgs e = new SocketAsyncEventArgs(); 
      int rOffset = 0; 
      int sOffset = 0; 
      DataHoldingUserToken target = new DataHoldingUserToken(e, rOffset, sOffset); 
      target.CreateSessionId();
      Assert.IsTrue(target.SessionId != 0);
    }

    /// <summary>
    ///A test for Reset
    ///</summary>
    [TestMethod()]
    public void ResetTest()
    {
      SocketAsyncEventArgs e = new SocketAsyncEventArgs();
      int rOffset = 0; 
      int sOffset = 0; 
      DataHoldingUserToken target = new DataHoldingUserToken(e, rOffset, sOffset); 
      target.Reset();
      Assert.AreEqual(target.receivedMessageBytesDoneCount, 0);
      Assert.AreEqual(target.receiveMessageOffset, target.permanentReceiveMessageOffset);
    }
  }
}

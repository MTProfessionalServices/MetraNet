using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net;

namespace VertexSocketConsoleTest
{


  /// <summary>
  ///This is a test class for SocketListenerSettingsTest and is intended
  ///to contain all SocketListenerSettingsTest Unit Tests
  ///</summary>
  [TestClass()]
  public class SocketListenerSettingsTest
  {


    private TestContext testContextInstance;

    /// <summary>
    ///Gets or sets the test context which provides
    ///information about and functionality for the current test run.
    ///</summary>
    public TestContext TestContext
    {
      get { return testContextInstance; }
      set { testContextInstance = value; }
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
    ///A test for SocketListenerSettings Constructor
    ///</summary>
    [TestMethod()]
    public void SocketListenerSettingsConstructorTest()
    {
      int maxConnections = 10;
      int excessSocketAsyncEventArgsObjectsInPool = 1;
      int backlog = 100;
      int maxSimultaneousAcceptOps = 10;
      int receiveBufferSize = 25000;
      int opsToPreAlloc = 2;
      IPEndPoint theLocalEndPoint = new IPEndPoint(IPAddress.Any, 5000);
      SocketListenerSettings target = new SocketListenerSettings(
        maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps, receiveBufferSize,
        opsToPreAlloc, theLocalEndPoint);

      Assert.AreNotEqual(null, target);
      Assert.AreEqual(target.Backlog, 100);
      Assert.AreEqual(target.MaxConnections, 10);
      Assert.AreEqual(target.BufferSize, 25000);
      Assert.AreEqual(target.OpsToPreAllocate, 2);
      Assert.AreEqual(target.MaxAcceptOps, 10);
      Assert.AreEqual(target.NumberOfSocketAsyncEventArgsForRecSend,
                      maxConnections + excessSocketAsyncEventArgsObjectsInPool);
      Assert.AreEqual(target.LocalEndPoint, theLocalEndPoint);
    }

    /// <summary>
    ///A test for SocketListenerSettings Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof (ArgumentException), "Invalid value for MaxConnections")]
    public void SocketListenerSettingsConstructorTestWithZeroValueForMaxConnections()
    {
      int maxConnections = 0; // Invalid value
      int excessSocketAsyncEventArgsObjectsInPool = 1;
      int backlog = 100;
      int maxSimultaneousAcceptOps = 10;
      int receiveBufferSize = 25000;
      int opsToPreAlloc = 2;
      IPEndPoint theLocalEndPoint = new IPEndPoint(IPAddress.Any, 5000);

      try
      {
        SocketListenerSettings target = new SocketListenerSettings(
          maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps, receiveBufferSize,
          opsToPreAlloc, theLocalEndPoint);

        Assert.AreEqual(null, target);
      }
      catch (ArgumentException argumentException)
      {
        throw argumentException;
      }
    }

    /// <summary>
    ///A test for SocketListenerSettings Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof (ArgumentException))]
    public void SocketListenerSettingsConstructorTestThatThrowsArgumentExceptionOnInvalidInput()
    {
        int maxConnections = 0;
        int excessSocketAsyncEventArgsObjectsInPool = 0;
        int backlog = 0;
        int maxSimultaneousAcceptOps = 0;
        int receiveBufferSize = 0;
        int opsToPreAlloc = 0;
        IPEndPoint theLocalEndPoint = null;
        SocketListenerSettings target = new SocketListenerSettings(
          maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps, receiveBufferSize,
          opsToPreAlloc, theLocalEndPoint);
    }

    /// <summary>
    ///A test for SocketListenerSettings Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentException), "Invalid value for EndPoint")]
    public void SocketListenerSettingsConstructorTestThatThrowsArgumentExceptionOnNullEndPoint()
    {
      int maxConnections = 10;
      int excessSocketAsyncEventArgsObjectsInPool = 2;
      int backlog = 100;
      int maxSimultaneousAcceptOps = 10;
      int receiveBufferSize = 2500;
      int opsToPreAlloc = 2;
      IPEndPoint theLocalEndPoint = null;
      SocketListenerSettings target = new SocketListenerSettings(
        maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps, receiveBufferSize,
        opsToPreAlloc, theLocalEndPoint);
    }

    /// <summary>
    ///A test for SocketListenerSettings Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentException), "Invalid value for OpsToPreAlloc")]
    public void SocketListenerSettingsConstructorTestThatThrowsArgumentExceptionOnNegativeOpsToPreAlloc()
    {
      int maxConnections = 10;
      int excessSocketAsyncEventArgsObjectsInPool = 2;
      int backlog = 100;
      int maxSimultaneousAcceptOps = 10;
      int receiveBufferSize = 2500;
      int opsToPreAlloc = -2;
      IPEndPoint theLocalEndPoint = new IPEndPoint(IPAddress.Any, 4444);
      SocketListenerSettings target = new SocketListenerSettings(
        maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps, receiveBufferSize,
        opsToPreAlloc, theLocalEndPoint);
    }

    /// <summary>
    ///A test for ValidateInput
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    [ExpectedException(typeof (ArgumentException))]
    public void ValidateInputTest()
    {
        int maxConnections = 100;
        int excessSocketAsyncEventArgsObjectsInPool = -1;
        int backlog = 0;
        int maxSimultaneousAcceptOps = 0;
        int receiveBufferSize = 0;
        int opsToPreAlloc = 0;
        IPEndPoint localEndPoint = null;
        SocketListenerSettings_Accessor.ValidateInput(maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog,
                                                      maxSimultaneousAcceptOps, receiveBufferSize, opsToPreAlloc,
                                                      localEndPoint);
    }
  }
}

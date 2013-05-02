using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
    
    
    /// <summary>
    ///This is a test class for SocketListenerTest and is intended
    ///to contain all SocketListenerTest Unit Tests
    ///</summary>
  [TestClass()]
  public class SocketListenerTest
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
    ///A test for SocketListener Constructor
    ///</summary>
    [TestMethod()]
    public void SocketListenerConstructorTest()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings);
      Assert.Inconclusive("TODO: Implement code to verify target");
    }

    /// <summary>
    ///A test for AcceptEventArg_Completed
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void AcceptEventArg_CompletedTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      object sender = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      target.AcceptEventArg_Completed(sender, e);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for CleanUpOnExit
    ///</summary>
    [TestMethod()]
    public void CleanUpOnExitTest()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings); // TODO: Initialize to an appropriate value
      target.CleanUpOnExit();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for CloseClientSocket
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void CloseClientSocketTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      target.CloseClientSocket(e);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for CreateNewSocketAsyncEventArgsForAccept
    ///</summary>
    [TestMethod()]
    public void CreateNewSocketAsyncEventArgsForAcceptTest()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgsPool pool = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs expected = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs actual;
      actual = target.CreateNewSocketAsyncEventArgsForAccept(pool);
      Assert.AreEqual(expected, actual);
      Assert.Inconclusive("Verify the correctness of this test method.");
    }

    /// <summary>
    ///A test for DisposeAllSaeaObjects
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void DisposeAllSaeaObjectsTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      target.DisposeAllSocketAsyncEventArgsObjects();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for HandleBadAccept
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void HandleBadAcceptTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs acceptEventArgs = null; // TODO: Initialize to an appropriate value
      target.HandleBadAccept(acceptEventArgs);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for IO_Completed
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void IO_CompletedTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      object sender = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs e = null; // TODO: Initialize to an appropriate value
      target.IO_Completed(sender, e);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for Init
    ///</summary>
    [TestMethod()]
    public void InitTest()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings); // TODO: Initialize to an appropriate value
      target.Init();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for ProcessAccept
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void ProcessAcceptTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs acceptEventArgs = null; // TODO: Initialize to an appropriate value
      target.ProcessAccept(acceptEventArgs);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for ProcessReceive
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void ProcessReceiveTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs receiveSendEventArgs = null; // TODO: Initialize to an appropriate value
      target.ProcessReceive(receiveSendEventArgs);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for ProcessSend
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void ProcessSendTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs receiveSendEventArgs = null; // TODO: Initialize to an appropriate value
      target.ProcessSend(receiveSendEventArgs);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for StartAccept
    ///</summary>
    [TestMethod()]
    public void StartAcceptTest()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings); // TODO: Initialize to an appropriate value
      target.StartAccept();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for StartListen
    ///</summary>
    [TestMethod()]
    public void StartListenTest()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings); // TODO: Initialize to an appropriate value
      target.StartListen();
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for StartReceive
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void StartReceiveTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs receiveSendEventArgs = null; // TODO: Initialize to an appropriate value
      target.StartReceive(receiveSendEventArgs);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for StartSend
    ///</summary>
    [TestMethod()]
    [DeploymentItem("VertexSocketService.exe")]
    public void StartSendTest()
    {
      PrivateObject param0 = null; // TODO: Initialize to an appropriate value
      SocketListener_Accessor target = new SocketListener_Accessor(param0); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs receiveSendEventArgs = null; // TODO: Initialize to an appropriate value
      target.StartSend(receiveSendEventArgs);
      Assert.Inconclusive("A method that does not return a value cannot be verified.");
    }

    /// <summary>
    ///A test for CreateNewSocketAsyncEventArgsForAccept
    ///</summary>
    [TestMethod()]
    public void CreateNewSocketAsyncEventArgsForAcceptTest1()
    {
      SocketListenerSettings theSocketListenerSettings = null; // TODO: Initialize to an appropriate value
      SocketListener target = new SocketListener(theSocketListenerSettings); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgsPool pool = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs expected = null; // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs actual;
      actual = target.CreateNewSocketAsyncEventArgsForAccept(pool);
      Assert.AreEqual(expected, actual);
      Assert.Inconclusive("Verify the correctness of this test method.");
    }
  }
}

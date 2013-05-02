using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
  /// <summary>
  ///This is a test class for SocketAsyncEventArgsPoolTest and is intended
  ///to contain all SocketAsyncEventArgsPoolTest Unit Tests
  ///</summary>
  [TestClass()]
  public class SocketAsyncEventArgsPoolTest
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
    ///A test for SocketAsyncEventArgsPool Constructor
    ///</summary>
    [TestMethod()]
    public void SocketAsyncEventArgsPoolConstructorTest()
    {
      const int capacity = 10;
      SocketAsyncEventArgsPool target = new SocketAsyncEventArgsPool(capacity);
      Assert.IsNotNull(target);
      Assert.IsTrue(target.Count == 0);
    }

    /// <summary>
    ///A test for Pop
    ///</summary>
    [TestMethod()]
    public void PopTest()
    {
      const int capacity = 10;
      SocketAsyncEventArgsPool target = new SocketAsyncEventArgsPool(capacity);
      SocketAsyncEventArgs actual = new SocketAsyncEventArgs { UserToken = "Sample user token" };
      target.Push(actual);
      SocketAsyncEventArgs expected = new SocketAsyncEventArgs { UserToken = "Sample user token" };
      actual = target.Pop();
      Assert.AreEqual(expected.UserToken, actual.UserToken);
    }

    /// <summary>
    ///A test for Pop
    ///</summary>
    [TestMethod()]
    public void PopTestWithInvalidResult()
    {
      const int capacity = 10;
      SocketAsyncEventArgsPool target = new SocketAsyncEventArgsPool(capacity);
      SocketAsyncEventArgs actual = new SocketAsyncEventArgs { UserToken = "Sample user token" };
      SocketAsyncEventArgs dummy = new SocketAsyncEventArgs { UserToken = "Dummy user token" };
      target.Push(actual);
      target.Push(dummy);
      SocketAsyncEventArgs expected = new SocketAsyncEventArgs { UserToken = "Sample user token" };
      actual = target.Pop();
      Assert.AreNotEqual(expected.UserToken, actual.UserToken);
    }

    /// <summary>
    ///A test for Push
    ///</summary>
    [TestMethod()]
    public void PushTest()
    {
      const int capacity = 10;
      SocketAsyncEventArgsPool target = new SocketAsyncEventArgsPool(capacity);
      SocketAsyncEventArgs actual = new SocketAsyncEventArgs { UserToken = "Sample user token" };
      SocketAsyncEventArgs dummy = new SocketAsyncEventArgs { UserToken = "Dummy user token" };
      target.Push(actual);
      target.Push(dummy);
      Assert.IsTrue(target.Count == 2);
      SocketAsyncEventArgs topResultFromStack = target.Pop();
      Assert.AreEqual(topResultFromStack.UserToken, dummy.UserToken);
      Assert.IsTrue(target.Count == 1);
    }

    /// <summary>
    ///A test for Push
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentNullException))]
    public void PushWithNullItemThrowsArgumentExceptionTest()
    {
      try
      {
        const int capacity = 10;
        SocketAsyncEventArgsPool target = new SocketAsyncEventArgsPool(capacity);
        target.Push(null);
      }
      catch(ArgumentNullException argEx)
      {
        throw argEx;
      }
    }

    /// <summary>
    ///A test for Count
    ///</summary>
    [TestMethod()]
    public void CountTest()
    {
      const int capacity = 10; 
      SocketAsyncEventArgsPool target = new SocketAsyncEventArgsPool(capacity);
      
      for (int i = 0; i < capacity; ++i)
      {
        SocketAsyncEventArgs newSocketAsyncEventArgs = new SocketAsyncEventArgs { UserToken = "UserToken id = " + i };
        target.Push(newSocketAsyncEventArgs);
      }
      Assert.IsTrue(target.Count == capacity);
    }

  }
}

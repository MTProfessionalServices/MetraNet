using System;
using System.Collections.Generic;
using System.Text;
using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
  /// <summary>
  ///This is a test class for BufferManagerTest and is intended
  ///to contain all BufferManagerTest Unit Tests
  ///</summary>
  [TestClass()]
  public class BufferManagerTest
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
    ///A test for SetBuffer
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentNullException), "args")]
    public void SetBufferTestWithNullSAEAThrowsException()
    {
      try
      {
        int totalBytes = 1000;
        int totalBufferBytesInEachSocketAsyncEventArgsObject = 10;
        BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
        SocketAsyncEventArgs args = null;

        bool actual;
        actual = target.SetBuffer(args);
      }
      catch (ArgumentNullException argsNull)
      {
        throw argsNull;
      }
    }

    /// <summary>
    ///A test for SetBuffer
    ///</summary>
    [TestMethod()]
    public void SetBufferTest()
    {
      const int totalBytes = 1000;
      const int totalBufferBytesInEachSocketAsyncEventArgsObject = 100;
      BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
      SocketAsyncEventArgs args = new SocketAsyncEventArgs();
      bool actual;
      target.InitBuffer();
      actual = target.SetBuffer(args);
      Assert.IsTrue(actual);
      Assert.IsTrue(args.Buffer.Length == totalBytes);
    }

    /// <summary>
    ///A test for SetBuffer
    ///</summary>
    [TestMethod()]
    public void SetBufferTestAfterCallingFreeBuffer()
    {
      const int totalBytes = 1000;
      const int totalBufferBytesInEachSocketAsyncEventArgsObject = 100;
      BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
      SocketAsyncEventArgs args = new SocketAsyncEventArgs();
      bool actual;
      target.InitBuffer();
      const string dummy = "Set Buffer Test After Calling Free Buffer";
      byte[] argsBuffer = Encoding.ASCII.GetBytes(dummy);
      args.SetBuffer(argsBuffer, 0, argsBuffer.Length);

      target.FreeBuffer(args);
      Assert.IsTrue(target._freeIndexPool.Count == 1);
      actual = target.SetBuffer(args);
      Assert.IsTrue(actual);
      Assert.IsTrue(args.Buffer.Length == totalBytes);
      Assert.IsTrue(target._freeIndexPool.Count == 0);
    }

    /// <summary>
    ///A test for FreeBuffer
    ///</summary>
    [TestMethod()]
    public void FreeBufferTest()
    {
      int bufferSize = 10000;
      int numberOfSocketAsyncEventArgsForRecSend = 10;
      int opsToPreAllocate = 1;
      int totalBytes = bufferSize * numberOfSocketAsyncEventArgsForRecSend * opsToPreAllocate;
      int totalBufferBytesInEachSocketAsyncEventArgsObject = bufferSize * opsToPreAllocate;
      BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
      SocketAsyncEventArgs args = new SocketAsyncEventArgs();

      target.FreeBuffer(args);
      Assert.IsTrue(target != null);
    }

    /// <summary>
    ///A test for BufferManager Constructor
    ///</summary>
    [TestMethod()]
    public void BufferManagerConstructorTest()
    {
      /*
            new BufferManager(
              this._socketListenerSettings.BufferSize * 
              this._socketListenerSettings.NumberOfSocketAsyncEventArgsForRecSend *
              this._socketListenerSettings.OpsToPreAllocate,
              this._socketListenerSettings.BufferSize * this._socketListenerSettings.OpsToPreAllocate);
       */
      int bufferSize = 10000;
      int numberOfSocketAsyncEventArgsForRecSend = 10;
      int opsToPreAllocate = 1;
      int totalBytes = bufferSize * numberOfSocketAsyncEventArgsForRecSend * opsToPreAllocate;
      int totalBufferBytesInEachSocketAsyncEventArgsObject = bufferSize * opsToPreAllocate;
      BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
      Assert.AreNotEqual(null, target);
    }

    /// <summary>
    ///A test for BufferManager Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentException))]
    public void BufferManagerConstructorTestThrowsExceptionOnZeroBytesForTotalBytes()
    {
      try
      {
        int totalBytes = 0;
        int totalBufferBytesInEachSocketAsyncEventArgsObject = 0;
        BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
        Assert.Fail();
      }
      catch (ArgumentException)
      {
        throw;
      }
    }

    /// <summary>
    ///A test for BufferManager Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentException))]
    public void BufferManagerConstructorTestThrowsExceptionOnNegativeBytesForTotalBytesInEachSocketAsyncObject()
    {
      try
      {
        int totalBytes = 1000;
        int totalBufferBytesInEachSocketAsyncEventArgsObject = -10;
        BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
        Assert.Fail();
      }
      catch (ArgumentException)
      {
        throw;
      }
    }

    /// <summary>
    ///A test for BufferManager Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentException))]
    public void BufferManagerConstructorTestThrowsExceptionOnZeroBytesForTotalBytesInEachSocketAsyncObject()
    {
      try
      {
        int totalBytes = 1000;
        int totalBufferBytesInEachSocketAsyncEventArgsObject = 0;
        BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
        Assert.Fail();
      }
      catch (ArgumentException)
      {
        throw;
      }
    }

    /// <summary>
    ///A test for BufferManager Constructor
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(ArgumentException))]
    public void BufferManagerConstructorTestThrowsExceptionOnNegativeBytesForTotalBytes()
    {
      try
      {
        int totalBytes = -100;
        int totalBufferBytesInEachSocketAsyncEventArgsObject = 10;
        BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
        Assert.Fail();
      }
      catch (ArgumentException)
      {
        throw;
      }
    }

    /// <summary>
    ///A test for FreeBuffer
    ///</summary>
    [TestMethod()]
    public void FreeBufferTestSetsArgsBufferToNull()
    {
      int totalBytes = 1000; // TODO: Initialize to an appropriate value
      int totalBufferBytesInEachSocketAsyncEventArgsObject = 100; // TODO: Initialize to an appropriate value
      BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject); // TODO: Initialize to an appropriate value
      SocketAsyncEventArgs args = new SocketAsyncEventArgs();
      target.FreeBuffer(args);
      Assert.IsNotNull(target);
      Assert.IsTrue(args.Buffer == null);
    }

    /// <summary>
    ///A test for InitBuffer
    ///</summary>
    [TestMethod()]
    public void InitBufferTest()
    {
      int totalBytes = 10000;
      int totalBufferBytesInEachSocketAsyncEventArgsObject = 200;
      BufferManager target = new BufferManager(totalBytes, totalBufferBytesInEachSocketAsyncEventArgsObject);
      target.InitBuffer();
      Assert.IsTrue(target._totalBytesInBufferBlock == totalBytes);
    }
  }
}

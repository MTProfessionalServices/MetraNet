using System.Globalization;
using System.Text;
using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Net.Sockets;

namespace VertexSocketConsoleTest
{
  /// <summary>
  ///This is a test class for OutgoingDataPreparerTest and is intended
  ///to contain all OutgoingDataPreparerTest Unit Tests
  ///</summary>
  [TestClass()]
  public class OutgoingDataPreparerTest
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
    ///A test for OutgoingDataPreparer Constructor
    ///</summary>
    [TestMethod()]
    public void OutgoingDataPreparerConstructorTest()
    {
      OutgoingDataPreparer target = new OutgoingDataPreparer();
      Assert.IsNotNull(target);
    }

    /// <summary>
    ///A test for PrepareOutgoingData
    ///</summary>
    [TestMethod()]
    [ExpectedException(typeof(InvalidCastException))]
    public void PrepareOutgoingDataTest()
    {
      OutgoingDataPreparer target = new OutgoingDataPreparer();
      SocketAsyncEventArgs e = new SocketAsyncEventArgs();
      e.UserToken = "Data To Send";
      DataHolder handledDataHolder = new DataHolder();
      handledDataHolder.dataMessageReceived = new byte[1000];
      string randomString = String.Empty;
      for (int i = 0; i < 1000; ++i)
      {
        Random random = new Random();
        randomString +=
          Convert.ToChar(Convert.ToInt32(Math.Floor(26 * random.NextDouble() + 65))).ToString(CultureInfo.InvariantCulture);
      }
      // Wrapping the byte[] into a string
      handledDataHolder.dataMessageReceived = Encoding.ASCII.GetBytes(randomString);

      int lengthofMessage = handledDataHolder.dataMessageReceived.Length;
      Assert.IsTrue(lengthofMessage == 1000);

      DataHoldingUserToken dataHoldingUserToken = (DataHoldingUserToken)e.UserToken;
      Assert.IsNotNull(dataHoldingUserToken);
      dataHoldingUserToken.dataToSend = new byte[lengthofMessage];

      target.PrepareOutgoingData(e, handledDataHolder);
    }

    /// <summary>
    /// Prepares the outgoing data test throws argument null exception on null token.
    /// </summary>
    [TestMethod]
    [ExpectedException(typeof(ArgumentNullException))]
    public void PrepareOutgoingDataTestThrowsArgumentNullExceptionOnNullToken()
    {
      OutgoingDataPreparer target = new OutgoingDataPreparer();
      SocketAsyncEventArgs e = new SocketAsyncEventArgs {UserToken = null};
      target.PrepareOutgoingData(e, new DataHolder());
    }
  }
}

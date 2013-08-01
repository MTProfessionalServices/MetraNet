using System.Diagnostics;
using MetraTech.Tax.Framework.VertexQ;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Tax.Freamework.Test.Properties;

namespace Tax.Freamework.Test
{
  /// <summary>
  ///This is a test class for VertexQSyncTaxManagerDBBatchTest and is intended
  ///to contain all VertexQSyncTaxManagerDBBatchTest Unit Tests
  ///</summary>
  [TestClass]
  [Ignore]
  public class VertexSyncTaxManagerTest
  {
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
    ///A test for InvokeRequest
    ///</summary>
    [TestMethod]
    public void InvokeRequestTest1()
    {
      var target = new VertexSyncTaxManager_Accessor();
      var actual = target.InvokeRequest(Resources.TestRequest1);
      Assert.AreEqual(Resources.TestResponse1, actual);
    }

    /// <summary>
    ///A test for InvokeRequest
    ///</summary>
    [TestMethod]
    public void InvokeRequestTest2()
    {
      var target = new VertexSyncTaxManager_Accessor();
      var st = new Stopwatch();
      st.Start();
      for (var i = 0; i < 5000; i++)
      {
        var actual = target.InvokeRequest(Resources.TestRequest2);
        Assert.AreEqual(Resources.TestResponse2, actual);
      }
      st.Stop();
      Assert.AreEqual(1000, st.ElapsedMilliseconds);
    }
  }
}
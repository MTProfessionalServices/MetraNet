using System.Linq;
using MetraTech.DataAccess;
using MetraTech.Domain.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Domain.Test
{
  /// <summary>
  ///This is a test class for MetraNetContextTest and is intended
  ///to contain all MetraNetContextTest Unit Tests
  ///</summary>
  [TestClass]
  public class MetraNetContextTest
  {
    /// <summary>
    ///Gets or sets the test context which provides
    ///information about and functionality for the current test run.
    ///</summary>
    public TestContext TestContext { get; set; }

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
    ///A test for Metadata DbSet.
    ///</summary>
    [TestMethod]
    public void MetadataTest()
    {
      var connectionInfo = new ConnectionInfo("NetMeter");
      using (var context = new MetraNetContext(ConnectionBase.GetDbConnection(connectionInfo, false)))
      {
        var metadata = context.Metadata.First();
        Assert.IsNotNull(metadata);
      }
    }
  }
}

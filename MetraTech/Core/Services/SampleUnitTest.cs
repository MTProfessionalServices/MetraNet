using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.UnitTests
{
  // To Run this fixture
  // nunit-console /fixture:MetraTech.Core.Services.UnitTests.SampleUnitTest /assembly:O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll
  [TestClass]
  public class SampleUnitTest
  {
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [ClassInitialize]
	  public static void InitTests(TestContext testContext)
    {
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [ClassCleanup]
    public static void Dispose()
    {
    }

    /// <summary>
    /// SampleTest - This is where an actual unit test would go.
    /// </summary>
    [TestMethod]
    [TestCategory("SampleTest")]
    public void SampleTest()
    {
      ProductOfferingServiceClient client =  new ProductOfferingServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      MTList<ProductOffering> pos = new MTList<ProductOffering>();
      client.GetProductOfferings(ref pos);

       // additional test logic
    }
  }
}

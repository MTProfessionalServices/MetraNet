#region

using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.MtBillSoft;
using Microsoft.VisualStudio.TestTools.UnitTesting;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.ProductMappingTest /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
  /// <summary>
  ///This is a test class for ProductMappingTest and is intended
  ///to contain all ProductMappingTest Unit Tests
  ///</summary>
  [TestClass]
  public class ProductMappingTest
  {
    /// <summary>
    ///A test for ProductMapping Constructor
    ///</summary>
    [TestMethod()]
    public void ProductMappingConstructorTest()
    {
      var target = new ProductMapping();
      Assert.IsNotNull(target);
    }

    /// <summary>
    ///A test for product_code
    ///</summary>
    [TestMethod()]
    public void product_codeTestAString()
    {
      var target = new ProductMapping();
      var expected = "ProductCodeString";
      target.product_code = expected;
      var actual = target.product_code;
      Assert.AreEqual(expected, actual);
    }

    /// <summary>
    ///A test for product_code
    ///</summary>
    [TestMethod()]
    public void product_codeTestNoString()
    {
      var target = new ProductMapping();
      var expected = string.Empty;
      target.product_code = expected;
      var actual = target.product_code;
      Assert.AreEqual(expected, actual);
    }

    /// <summary>
    ///A test for service_type
    ///</summary>
    [TestMethod()]
    public void service_typeTest0()
    {
      var target = new ProductMapping();
      var expected = 0;
      target.service_type = expected;
      var actual = target.service_type;
      Assert.AreEqual(expected, actual);
    }

    /// <summary>
    ///A test for service_type
    ///</summary>
    [TestMethod()]
    public void service_typeTest1()
    {
      var target = new ProductMapping();
      var expected = 1;
      target.service_type = expected;
      var actual = target.service_type;
      Assert.AreEqual(expected, actual);
    }

    /// <summary>
    ///A test for transaction_type
    ///</summary>
    [TestMethod()]
    public void transaction_typeTest()
    {
      var target = new ProductMapping();
      var expected = 1000;
      target.transaction_type = expected;
      var actual = target.transaction_type;
      Assert.AreEqual(expected, actual);
    }
  }
}
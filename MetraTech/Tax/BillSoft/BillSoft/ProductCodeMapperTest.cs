#region

using System;
using MetraTech.Tax.Framework.MtBillSoft;
using Microsoft.VisualStudio.TestTools.UnitTesting;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.ProductCodeMapperTest /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
  /// <summary>
  ///This is a test class for ProductCodeMapperTest and is intended
  ///to contain all ProductCodeMapperTest Unit Tests
  ///</summary>
  [TestClass]
  public class ProductCodeMapperTest
  {
#if false
    /// <summary>
    ///A test for GetMappingsByCatagoryAndServiceCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByCatagoryAndServiceCodeTestWithBadValues()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var catCode = 0;
      var serviceCode = 0;
      var list = target.GetMappingsByCatagoryAndServiceCode(catCode, serviceCode);
      Assert.IsEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByCatagoryAndServiceCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByCatagoryAndServiceCodeTestWithGoodValues()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var catCode = 13;
      var serviceCode = 6;
      var list = target.GetMappingsByCatagoryAndServiceCode(catCode, serviceCode);
      Assert.IsNotEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByCatagoryCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByCatagoryCodeTestWithBadValues()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var catCode = 0;
      var list = target.GetMappingsByCatagoryCode(catCode);
      Assert.IsEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByCatagoryCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByCatagoryCodeTestWithGoodValues()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var catCode = 13;
      var list = target.GetMappingsByCatagoryCode(catCode);
      Assert.IsNotEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByProductCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByProductCodeTestWithEmptyString()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var productCode = String.Empty;
      var list = target.GetMappingsByProductCode(productCode);
      Assert.IsEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByProductCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByProductCodeTestWithGoodString()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var productCode = "BSPC0001";
      var list = target.GetMappingsByProductCode(productCode);
      Assert.IsNotEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByProductCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByProductCodeTestWithInvalidString()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var productCode = "MissingProduct";
      var list = target.GetMappingsByProductCode(productCode);
      Assert.IsEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByServiceCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByServiceCodeTestWithGoodServiceCode()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var serviceCode = 6;
      var list = target.GetMappingsByServiceCode(serviceCode);
      Assert.IsNotEmpty(list);
    }

    /// <summary>
    ///A test for GetMappingsByServiceCode
    ///</summary>
    [TestMethod()]
    public void GetMappingsByServiceCodeTestWithInvalidServiceCode()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var serviceCode = 0;
      var list = target.GetMappingsByServiceCode(serviceCode);
      Assert.IsEmpty(list);
    }
#endif
    /// <summary>
    ///A test for GetProductCode
    ///</summary>
    [TestMethod()]
    public void GetProductCodeTestBadString()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var productCode = "MissingProductCode";
      target.PopulateMappingDictionary();
      var mapping = target.GetProductCode(productCode);
      Assert.IsNull(mapping);
    }

    /// <summary>
    ///A test for GetProductCode
    ///</summary>
    [TestMethod()]
    public void GetProductCodeTestEmptyString()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var productCode = string.Empty;
      target.PopulateMappingDictionary();
      var mapping = target.GetProductCode(productCode);
      Assert.IsNull(mapping);
    }

    /// <summary>
    ///A test for GetProductCode
    ///</summary>
    [TestMethod()]
    public void GetProductCodeTestGoodString()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      var productCode = "BSPC0001";
      target.PopulateMappingDictionary();
      var mapping = target.GetProductCode(productCode);
      Assert.IsNotNull(mapping);
    }

    /// <summary>
    ///A test for PopulateMappingDictionary
    ///</summary>
    [TestMethod()]
    public void PopulateMappingDictionaryTest()
    {
      DatabaseHelper.LoadProductCodeMappingsForTest();
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      target.PopulateMappingDictionary();
    }

    /// <summary>
    ///A test for PopulateMappingDictionary
    ///</summary>
    [TestMethod()]
    public void PopulateMappingDictionaryTestWithMissingTable()
    {
      DatabaseHelper.DropTable("t_tax_billsoft_pc_map");
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
      target.PopulateMappingDictionary();
    }

    /// <summary>
    ///A test for ProductCodeMapper Constructor
    ///</summary>
    //[TestMethod()]
    public void ProductCodeMapperConstructorTest()
    {
      var target = new ProductCodeMapper(@"Queries\Tax\BillSoft");
    }

    /// <summary>
    ///A test for ProductCodeMapper Constructor
    ///</summary>
    //[TestMethod()]
    public void ProductCodeMapperConstructorTestEmptyQueryPath()
    {
      try
      {
        var target = new ProductCodeMapper(string.Empty);
        throw new Exception("ProductCodeMapper must not accept empty query path");
      }
      catch
      {
      }
    }

    /// <summary>
    ///A test for ProductCodeMapper Constructor
    ///</summary>
    //[TestMethod()]
    public void ProductCodeMapperConstructorTestInvalidQueryPath()
    {
      try
      {
        var target = new ProductCodeMapper(@"this\is\a\bad\path");
        throw new Exception("ProductCodeMapper must not accept invalid query path");
      }
      catch
      {
      }
    }
  }
}
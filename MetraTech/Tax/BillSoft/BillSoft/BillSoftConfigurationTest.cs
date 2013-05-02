#region

using System;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.MtBillSoft;
using Microsoft.VisualStudio.TestTools.UnitTesting;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.BillSoftConfigurationTest /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
  /// <summary>
  ///This is a test class for BillSoftConfigurationTest and is intended
  ///to contain all BillSoftConfigurationTest Unit Tests
  ///</summary>
  [TestClass]
  public class BillSoftConfigurationTest
  {
    /// <summary>
    ///A test for BillSoftConfiguration Constructor
    ///</summary>
    [TestMethod()]
    public void BillSoftConfigurationConstructorTestEmptyConfigFile()
    {
      try
      {
        var file = @"u:\metratech\Tax\BillSoft\data\EmptyConfig.xml";
        var target = new BillSoftConfiguration(file);
        throw new Exception("Test failed. Should have caught an exception.");
      }
      catch
      {
      } // Expect exception
    }

    /// <summary>
    ///A test for BillSoftConfiguration Constructor
    ///</summary>
    [TestMethod()]
    public void BillSoftConfigurationConstructorTestEmtpyConfigString()
    {
      try
      {
        var target = new BillSoftConfiguration(string.Empty);
        throw new Exception("Test failed. Should have caught an exception.");
      }
      catch
      {
      } // Expect exception
    }

    /// <summary>
    ///A test for BillSoftConfiguration Constructor
    ///</summary>
    [TestMethod()]
    public void BillSoftConfigurationConstructorTestGoodConfigFile()
    {
      var file = @"r:\extensions\BillSoft\config\BillSoftPathFile.xml";
      var target = new BillSoftConfiguration(file);
    }

    /// <summary>
    ///A test for BillSoftConfiguration Constructor
    ///</summary>
    [TestMethod()]
    public void BillSoftConfigurationConstructorTestMissingBodyConfigFile()
    {
      try
      {
        var file = @"u:\metratech\Tax\BillSoft\data\MissingElements.xml";
        var target = new BillSoftConfiguration(file);
        throw new Exception("Test failed. Should have caught an exception.");
      }
      catch
      {
      } // Expect exception
    }

    /// <summary>
    ///A test for BillSoftConfiguration Constructor
    ///</summary>
    [TestMethod()]
    public void BillSoftConfigurationConstructorTestMissingConfigFile()
    {
      try
      {
        var file = @"c:\not\a\valid\path\to\missingconfig.xml";
        var target = new BillSoftConfiguration(file);
        throw new Exception("Test failed. Should have caught an exception.");
      }
      catch
      {
      } // Expect exception
    }

    /// <summary>
    ///A test for BillSoftConfiguration Constructor
    ///</summary>
    [TestMethod()]
    public void BillSoftConfigurationConstructorTestMissingSingleElementConfigFile()
    {
      try
      {
        var file = @"u:\metratech\Tax\BillSoft\data\MissingSingleElement.xml";
        var target = new BillSoftConfiguration(file);
        throw new Exception("Test failed. Should have caught an exception.");
      }
      catch
      {
      } // Expect exception
    }
  }
}
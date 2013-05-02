#region

using System;
using System.Diagnostics;
using System.Threading;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.DetailTableTests /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
  [TestClass]
  public class DetailTableTests
  {
    int glRunId = 100;
    /// <summary>
    /// 
    /// </summary>
    private static void create_table()
    {
      DatabaseHelper.RunQuery(@"Queries\DBInstall\Tax", "__CREATE_T_TAX_DETAILS__");
    }

    /// <summary>
    /// 
    /// </summary>
    private static void drop_table()
    {
      DatabaseHelper.DropTable("t_tax_details");
    }

    [TestMethod()]
    [TestCategory("TestAddDetailRowObjects")]
    public void TestAddDetailRowObjects()
    {
      drop_table();
      create_table();
      var writer = new TaxManagerBatchDbTableWriter("t_tax_details", 1000);
      var row = new TransactionIndividualTax
                  {
                    IdTaxRun = ++glRunId,
                    IdTaxCharge = 1,
                    IdTaxDetail = 2,
                    IsImplied = true,
                    TaxJurLevel = 3,
                    Rate = (decimal) (5.0),
                    DateOfCalc = DateTime.UtcNow,
                    TaxJurName = "FooBar Tax Jur",
                    TaxType = 4,
                    TaxTypeName = "FooBar Tax Type"
                  };

      writer.Add(row);
      writer.Commit();
      drop_table();
    }


    [TestMethod()]
    [TestCategory("TestAddManyDetailRowObjects")]
    public void TestAddManyDetailRowObjects()
    {
      drop_table();
      create_table();
      var writer = new TaxManagerBatchDbTableWriter("t_tax_details", 1000);
      var watch = new Stopwatch();
      watch.Start();
      for (var i = 0; i < 1000; i++) 
      {
        var row = new TransactionIndividualTax
                    {
                      IdTaxRun = ++glRunId,
                      IdTaxCharge = i,
                      IdTaxDetail = i,
                      IsImplied = true,
                      TaxJurLevel = 3,
                      Rate = (decimal) (5.0),
                      DateOfCalc = DateTime.UtcNow,
                      TaxJurName = "FooBar Tax Jur " + i,
                      TaxType = 4,
                      TaxTypeName = "FooBar Tax Type " + i
                    };
        writer.Add(row);
      }
      writer.Commit();
      watch.Stop();
      Console.WriteLine("\r\nAdding 1000 details took " + watch.Elapsed + " at 1000 per batch");

      drop_table();
    }

    [TestMethod()]
    [TestCategory("TestAddDuplicateInSingleWriter")]
    public void TestAddDuplicateInSingleWriter()
    {
      drop_table();
      create_table();
      var writer = new TaxManagerBatchDbTableWriter("t_tax_details", 1000);
      var row = new TransactionIndividualTax
                  {
                    IdTaxRun = ++glRunId,
                    IdTaxCharge = 1,
                    IdTaxDetail = 2,
                    IsImplied = true,
                    TaxJurLevel = 3,
                    TaxJurName = "FooBar Tax Jur",
                    TaxType = 4,
                    TaxTypeName = "FooBar Tax Type",
                    Rate = (decimal) (5.0),
                    DateOfCalc = DateTime.UtcNow
                  };

      writer.Add(row);
      try
      {
        writer.Add(row);
        drop_table();
        throw new Exception("Should not be able to add duplicate rows");
      }
      catch
      {
      } // Expected to fail
      drop_table();
    }

    [TestMethod()]
    [TestCategory("TestAddDuplicateInWriter")]
    public void TestAddDuplicateInWriter()
    {
      drop_table();
      create_table();
      var writer = new TaxManagerBatchDbTableWriter("t_tax_details", 1000);
      var row = new TransactionIndividualTax
                  {
                    IdTaxRun = ++glRunId,
                    IdTaxCharge = 1,
                    IdTaxDetail = 2,
                    IsImplied = true,
                    TaxJurLevel = 3,
                    TaxJurName = "FooBar Tax Jur",
                    TaxType = 4,
                    Rate = (decimal) (5.0),
                    DateOfCalc = DateTime.UtcNow,
                    TaxTypeName = "FooBar Tax Type"
                  };

      writer.Add(row);
      writer.Commit();
      var writer2 = new TaxManagerBatchDbTableWriter("t_tax_details", 1000);
      writer2.Add(row);
      try
      {
        writer2.Commit(); // This should fail
        drop_table();
        throw new Exception("Should not be able to add duplicate rows even in seperate writers");
      }
      catch
      {
      } // Expected to fail
      drop_table();
    }

    [TestMethod()]
    [TestCategory("TestCommitEmtpyTable")]
    public void TestCommitEmtpyTable()
    {
      drop_table();
      create_table();
      var writer = new TaxManagerBatchDbTableWriter("t_tax_details", 1000);
      var row = new TransactionIndividualTax();
      writer.Commit();
      drop_table();
    }
  }
}

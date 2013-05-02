#region

using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.OutputTableTests /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
  [TestClass]
  public class OutputTableTests
  {
    [TestMethod()]
    [TestCategory("TestAddManyRowToOutputTable")]
    public void TestAddManyRowToOutputTable()
    {
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter.CreateOutputTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter writer = new TaxManagerBatchDbTableWriter("t_tax_output_1", 1000);
      for (int i = 1; i < 100; i++)
      {
        TransactionTaxSummary row = new TransactionTaxSummary();
        row.IdTaxCharge = i;

        row.TaxFedAmount = (decimal) (100.123 + i);
        row.TaxFedName = "Federal Tax Value " + i;
        row.TaxFedRounded = i;

        row.TaxStateAmount = (decimal) (100.123 + i);
        row.TaxStateName = "State Tax Value " + i;
        row.TaxStateRounded = i;

        row.TaxCountyAmount = (decimal) (100.123 + i);
        row.TaxCountyName = "County Tax Value " + i;
        row.TaxCountyRounded = i;

        row.TaxLocalAmount = (decimal) (100.123 + i);
        row.TaxLocalName = "Local Tax Value " + i;
        row.TaxLocalRounded = i;

        row.TaxOtherAmount = (decimal) (100.123 + i);
        row.TaxOtherName = "Other Tax Value " + i;
        row.TaxOtherRounded = i;

        writer.Add(row);
      }
      writer.Commit();
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
    }

    [TestMethod()]
    [TestCategory("TestAddOutputTableObjects")]
    public void TestAddOutputTableObjects()
    {
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter.CreateOutputTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter writer = new TaxManagerBatchDbTableWriter("t_tax_output_1", 1000);
      TransactionTaxSummary row = new TransactionTaxSummary();
      row.IdTaxCharge = 1;
      row.TaxFedAmount = (decimal) 100.123;
      row.TaxFedName = "Federal Tax Value";
      row.TaxFedRounded = 1;

      row.TaxFedAmount = (decimal) 100.123;
      row.TaxFedName = "Federal Tax Value";
      row.TaxFedRounded = 1;

      row.TaxStateAmount = (decimal) 100.123;
      row.TaxStateName = "State Tax Value";
      row.TaxStateRounded = 1;

      row.TaxCountyAmount = (decimal) 100.123;
      row.TaxCountyName = "County Tax Value";
      row.TaxCountyRounded = 1;

      row.TaxLocalAmount = (decimal) 100.123;
      row.TaxLocalName = "Local Tax Value";
      row.TaxLocalRounded = 1;

      row.TaxOtherAmount = (decimal) 100.123;
      row.TaxOtherName = "Other Tax Value";
      row.TaxOtherRounded = 1;

      writer.Add(row);
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
    }

    [TestMethod()]
    [TestCategory("TestAddRowToOutputTable")]
    public void TestAddRowToOutputTable()
    {
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter.CreateOutputTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter writer = new TaxManagerBatchDbTableWriter("t_tax_output_1", 1000);
      TransactionTaxSummary row = new TransactionTaxSummary();
      row.IdTaxCharge = 1;
      row.TaxFedAmount = (decimal) 100.123;
      row.TaxFedName = "Federal Tax Value";
      row.TaxFedRounded = 1;

      row.TaxFedAmount = (decimal) 100.123;
      row.TaxFedName = "Federal Tax Value";
      row.TaxFedRounded = 1;

      row.TaxStateAmount = (decimal) 100.123;
      row.TaxStateName = "State Tax Value";
      row.TaxStateRounded = 1;

      row.TaxCountyAmount = (decimal) 100.123;
      row.TaxCountyName = "County Tax Value";
      row.TaxCountyRounded = 1;

      row.TaxLocalAmount = (decimal) 100.123;
      row.TaxLocalName = "Local Tax Value";
      row.TaxLocalRounded = 1;

      row.TaxOtherAmount = (decimal) 100.123;
      row.TaxOtherName = "Other Tax Value";
      row.TaxOtherRounded = 1;

      writer.Add(row);
      writer.Commit();
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
    }

    [TestMethod()]
    [TestCategory("TestCreateOutputTable")]
    public void TestCreateOutputTable()
    {
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter.CreateOutputTable("t_tax_output_1");
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
    }

    [TestMethod()]
    [TestCategory("TestCreateOutputTableObjects")]
    public void TestCreateOutputTableObjects()
    {
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter.CreateOutputTable("t_tax_output_1");
      TaxManagerBatchDbTableWriter writer = new TaxManagerBatchDbTableWriter("t_tax_output_1", 1000);
      TransactionTaxSummary row = new TransactionTaxSummary();
      DatabaseHelper.DropTable("t_tax_input_1");
      DatabaseHelper.DropTable("t_tax_output_1");
    }
  }
}

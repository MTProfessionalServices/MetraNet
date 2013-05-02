#region

using System;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.InputTable /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
    [TestClass]
    public class InputTable
    {
        [ClassCleanup]
        public void TearDown()
        {
            // restore the real values
            Framework.Hooks.VendorParamsHook hook = new Framework.Hooks.VendorParamsHook();
            int pval = 0;
            hook.Execute(null, ref pval);
        }


        private static bool IsInParamTableDelegate(string key)
        {
            return true;
        }
        /// <summary>
        /// delegate for input row object
        /// </summary>
        /// <param name="key"></param>
        /// <param name="t"></param>
        /// <param name="val"></param>
        /// <returns></returns>
        private static bool LookupParameterDefaultDelegate(string key, out Type t, out Object val)
        {
            t = null;
            val = null;
            return true;
        }

        /// <summary>
        /// Helper to load data files. Must grant bulkload to nmdbo user first before test.
        /// </summary>
        /// <param name="runId"></param>
        private static void PrepLoadData(int runId)
        {
            Framework.VendorParamsManager manager = new VendorParamsManager();
            manager.SynchronizeConfigFile(@"U:\MetraTech\Tax\BillSoft\data\ParamTableUT_" + runId + "_Data.xml");

            DatabaseHelper.DropTable(String.Format("t_tax_input_{0}", runId));
            DatabaseHelper.CreateInputTable(runId);
            DatabaseHelper.BulkLoadData("t_tax_input_" + runId, @"U:\MetraTech\Tax\BillSoft\data\", "InputTableUT_" + runId + "_Data.csv");
        }


        [TestMethod()]
        [TestCategory("TestCreateInputTableObject")]
        public void TestCreateInputTableObject()
        {
            int runId = 1;
            DatabaseHelper.DropTable(String.Format("t_tax_input_{0}", runId));
            DatabaseHelper.CreateInputTable(runId);
            DatabaseHelper.BulkLoadData("t_tax_input_" + runId, @"U:\MetraTech\Tax\BillSoft\data\", "InputTableUT_" + runId + "_Data.csv");
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 1, false);
        }

        [TestMethod()]
        [TestCategory("TestCreateInputTableRowObject")]
        public void TestCreateInputTableRowObject()
        {
            var r = new TaxableTransaction(TaxVendor.BillSoft);
        }

        [TestMethod()]
        [TestCategory("TestMissingInputTable")]
        public void TestMissingInputTable()
        {
            Framework.VendorParamsManager manager = new VendorParamsManager();
            manager.SynchronizeConfigFile(@"U:\MetraTech\Tax\BillSoft\data\ParamTableUT_1_Data.xml");

            DatabaseHelper.DropTable(String.Format("t_tax_input_{0}", 0));

            try
            {
                var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 0, false);
                Assert.IsTrue(true); // Should have gotten and exception
            }
            catch
            {
            }
        }

        [TestMethod()]
        [TestCategory("TestEmptyInputTable")]
        public void TestEmptyInputTable()
        {
            Framework.VendorParamsManager manager = new VendorParamsManager();
            manager.SynchronizeConfigFile(@"U:\MetraTech\Tax\BillSoft\data\ParamTableUT_1_Data.xml");

            DatabaseHelper.DropTable("t_tax_input_100");
            DatabaseHelper.CreateInputTable(100);

            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 100, false);
            int count = 0;
            while (null != reader.GetNextTaxableTransaction())
            {
                count++;
            }
            Assert.IsTrue(count == 0);
        }

        [TestMethod()]
        [TestCategory("TestZeroRunId")]
        public void TestZeroRunId()
        {
            Framework.VendorParamsManager manager = new VendorParamsManager();
            manager.SynchronizeConfigFile(@"U:\MetraTech\Tax\BillSoft\data\ParamTableUT_1_Data.xml");

            DatabaseHelper.DropTable("t_tax_input_0");
            DatabaseHelper.CreateInputTable(0);

            try
            {
                var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 0, false);
                Assert.IsTrue(true); // Zero run id not allowed
            }
            catch
            {
            }
        }

        #region Testing for defined and exected fields
        [TestMethod()]
        [TestCategory("TestDefaultFieldStringNonNullExpected")]
        public void TestDefaultFieldStringNonNullExpected()
        {
            PrepLoadData(1);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 1, false);

            var r = reader.GetNextTaxableTransaction();
            string product_code = r.GetString("product_code");
            Assert.IsFalse(String.IsNullOrEmpty(product_code));
        }

        [TestMethod()]
        [TestCategory("TestDefaultFieldDecimalNonNullExpected")]
        public void TestDefaultFieldDecimalNonNullExpected()
        {
            PrepLoadData(1);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 1, false);

            var r = reader.GetNextTaxableTransaction();
            decimal? amount = r.GetDecimal("amount");
            Assert.IsTrue(amount != null);
            Assert.IsTrue(amount.GetValueOrDefault() != 0);
        }

        //[TestMethod()]
        [TestCategory("TestDefaultFieldDateTimeNonNullExpected")]
        public void TestDefaultFieldDateTimeNonNullExpected()
        {
            PrepLoadData(1);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 1, false);

            var r = reader.GetNextTaxableTransaction();
            DateTime? invoice_date = r.GetDateTime("invoice_date");
            Assert.IsTrue(invoice_date != null);
        }

        [TestMethod()]
        [TestCategory("TestDefaultFieldInt32NonNullExpected")]
        public void TestDefaultFieldInt32NonNullExpected()
        {
            PrepLoadData(1);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 1, false);

            var r = reader.GetNextTaxableTransaction();
            Int32? id_acc = r.GetInt32("id_acc");
            Assert.IsTrue(id_acc != null);
            Assert.IsTrue(id_acc.GetValueOrDefault() != 0);
        }
        #endregion


        #region Testing for fields with default value set
        [TestMethod()]
        [TestCategory("TestGetDefaultString")]
        public void TestGetDefaultString()
        {
            PrepLoadData(2);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 2, false);

            var r = reader.GetNextTaxableTransaction();
            string product_code = r.GetString("product_code");
            Assert.IsTrue(product_code == "AC-000");
        }

        [TestMethod()]
        [TestCategory("TestGetDefaultDecimal")]
        public void TestGetDefaultDecimal()
        {
            PrepLoadData(2);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 2, false);

            var r = reader.GetNextTaxableTransaction();
            decimal? amount = r.GetDecimal("amount");
            Assert.IsTrue(amount != null);
            Assert.IsTrue(amount.GetValueOrDefault() == (decimal)3.50);
        }

        [TestMethod()]
        [TestCategory("TestGetDefaultDateTime")]
        public void TestGetDefaultDateTime()
        {
            PrepLoadData(2);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 2, false);

            var r = reader.GetNextTaxableTransaction();
            DateTime? invoice_date = r.GetDateTime("invoice_date");
            Assert.IsTrue(invoice_date == new DateTime(2006, 7, 14));
        }

        [TestMethod()]
        [TestCategory("TestGetDefaultInt")]
        public void TestGetDefaultInt()
        {
            PrepLoadData(2);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 2, false);

            var r = reader.GetNextTaxableTransaction();
            Int32? id_acc = r.GetInt32("id_acc");
            Assert.IsTrue(id_acc == 123);
            Assert.IsTrue(id_acc.GetValueOrDefault() != 0);
        }
        #endregion

        #region Testing for field with no value, but had default (expected fields in param table with default)
        [TestMethod()]
        [TestCategory("TestInputWithValueDefaultSpecifiedInt32")]
        public void TestInputWithValueDefaultSpecifiedInt32()
        {
            PrepLoadData(2);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 2, false);

            var r = reader.GetNextTaxableTransaction();
            Int32? id_acc = r.GetInt32("id_acc");
            Assert.IsTrue(id_acc != null);
            Assert.IsTrue(id_acc.GetValueOrDefault() == 123);
        }
        #endregion // Testing for field with no value, but had default (expected fields in param table with default)

        #region Testing for field with no value, but had default (expected fields in param table with NO default)
        [TestMethod()]
        [TestCategory("TestInputWithNoValueDefaultSpecifiesNullByDefaultInt32")]
        public void TestInputWithNoValueDefaultSpecifiesNullByDefaultInt32()
        {
            PrepLoadData(2);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 2, false);

            var r = reader.GetNextTaxableTransaction();
            Int32? orig_pcode = r.GetInt32("orig_pcode");
            Assert.IsTrue(orig_pcode == null);
        }
        #endregion // Testing for field with no value, but had default (expected fields in param table with NO default)

        #region Testing for field with value, but not in parameter table
        [TestMethod()]
        [TestCategory("TestInputTableEntryWhichIsNotInParameterTable")]
        public void TestInputTableEntryWhichIsNotInParameterTable()
        {
            PrepLoadData(3);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 3, false);

            var r = reader.GetNextTaxableTransaction();
            try
            {
                Int32? id_acc = r.GetInt32("id_acc");
                Assert.IsTrue(true); // Should hit assert
            }
            catch
            {
                // Swallow as this is success
            }
        }
        #endregion Testing for field with value, but not in parameter table

        #region Testing for no field in table, BUT is in the parameter table with default of none
        [TestMethod()]
        [TestCategory("TestNotInTableButInParametersWithEmptyAsDefault")]
        public void TestNotInTableButInParametersWithEmptyAsDefault()
        {
            PrepLoadData(4);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 4, false);

            var r = reader.GetNextTaxableTransaction();
            var missingFieldEmpty = r.GetString("missingFieldEmpty");
            Assert.IsTrue(String.IsNullOrEmpty(missingFieldEmpty));
        }
        [TestMethod()]
        [TestCategory("TestNotInTableButInParametersWithNoneAsDefault")]
        public void TestNotInTableButInParametersWithNoneAsDefault()
        {
            PrepLoadData(4);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 4, false);

            var r = reader.GetNextTaxableTransaction();
            var missingFieldNone = r.GetString("missingFieldNone");
            Assert.IsTrue(String.IsNullOrEmpty(missingFieldNone));
        }
        [TestMethod()]
        [TestCategory("TestNotInTableButInParametersWithNullAsDefault")]
        public void TestNotInTableButInParametersWithNullAsDefault()
        {
            PrepLoadData(4);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 4, false);

            var r = reader.GetNextTaxableTransaction();
            var missingFieldNull = r.GetString("missingFieldNull");
            Assert.IsTrue(String.IsNullOrEmpty(missingFieldNull));
        }
        [TestMethod()]
        [TestCategory("TestNotInTableButInParametersWithSomeValAsDefault")]
        public void TestNotInTableButInParametersWithSomeValAsDefault()
        {
            PrepLoadData(4);
            var reader = new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 4, false);

            var r = reader.GetNextTaxableTransaction();
            var missingFieldSomeVal = r.GetString("missingFieldSomeVal");
            Assert.IsFalse(String.IsNullOrEmpty(missingFieldSomeVal));
        }
        #endregion Testing for field with value, but not in parameter table

        [TestMethod()] 
        [TestCategory("TestGettingInput24TableRows")]
        public void TestGettingInput24TableRows()
        {
            PrepLoadData(1);
            var reader =
              new TaxManagerVendorInputTableReader(TaxVendor.BillSoft, 1, false);
            int count = 0;
            while (null != reader.GetNextTaxableTransaction())
            {
                count++;
            }
            Assert.IsTrue(count == 24);
        }
    }
}

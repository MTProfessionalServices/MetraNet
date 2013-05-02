#region

using System;
using System.IO;
using MetraTech.DataAccess;
using MetraTech.Tax.Framework.DataAccess;
using MetraTech.Tax.Framework.MtBillSoft;
using MetraTech.Tax.Framework;
using MetraTech.Tax.UnitTests.General;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;

#endregion

// Before running nunit-console the first time, you need to make sure that
// the test program has permission for bulk inserts.  You will get an error like 
// "this user does not have permission for bulk load", if this is not the case.
//
// Preparation:
//     1. Enable bulk inserts by startinh Microsoft SQL studio.  In a new query window type:
//        sp_addsrvrolemember 'nmdbo', 'bulkadmin'
//     2. Install Billsoft. Install available at: 
//        \\tiber\Services\Customer\Premiere\Professional Services\_Old Files_\OLD_STUFF\ThirdPartySoftware
//     3. Update PATH to include BillSoft DLL directory (C:\BillSoft\EZTax\Dll if you installed BillSoft in the default location)
//
// Running Test:
//     nunit-console /fixture:MetraTech.Tax.UnitTests.BillSoft /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll
// or
//     ncover.console //x c:/temp/ncover.xml nunit-console /fixture:MetraTech.Tax.UnitTests.BillSoft /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
    [TestClass]
    public class BillSoft
    {
        private string mPathToDataFiles = @"U:\MetraTech\Tax\BillSoft\data\";
        private string mPathToConfigFile = @"BillSoft\config\BillSoftPathFile.xml";

        private void import_exemptions()
        {
            try
            {
                DatabaseHelper.LoadDataFromSql(mPathToDataFiles, "exemptionTestData.csv");
            }
            catch
            {
            }
        }

        private void import_overrides()
        {
            try
            {
                DatabaseHelper.LoadDataFromSql(mPathToDataFiles, "overrideTestData.csv");
            }
            catch
            {
            }
        }

        /// <summary>
        /// 
        /// </summary>
        private static void drop_input_table(int runId)
        {
            DatabaseHelper.DropTable(String.Format("t_tax_input_{0}", runId));
        }

        /// <summary>
        /// 
        /// </summary>
        private static void drop_output_table(int runId)
        {
            DatabaseHelper.DropTable(String.Format("t_tax_output_{0}", runId));
        }

        /// <summary>
        /// 
        /// </summary>
        private void import_data_into_input_table(int runId)
        {
            DatabaseHelper.BulkLoadData("t_tax_input_" + runId, mPathToDataFiles, "UT" + runId + "_Data.csv");
        }

        /// <summary>
        /// 
        /// </summary>
        private void import_data_into_product_map()
        {
            DatabaseHelper.BulkLoadData("t_tax_billsoft_pc_map", mPathToDataFiles, "BillSoftTestProductCodemap.csv");
        }

        private int CountDetailRows()
        {
                return (int)TaxManagerVendorInputTableReader.CountRowsOnTable("t_tax_details");
        }

        private bool AreInputAndOutputRowsEqual(int runid)
        {
            string inTbl = "t_tax_input_" + runid;
            string outTbl = "t_tax_output_" + runid;
            if (TaxManagerVendorInputTableReader.CountRowsOnTable(inTbl) !=
                 TaxManagerVendorInputTableReader.CountRowsOnTable(outTbl))
                return false;
            return true;
        }

        /// <summary>
        /// 
        /// </summary>
        private void add_bulk_insert_role()
        {
            change_bulk_insert_role(true);
        }

        /// <summary>
        /// 
        /// </summary>
        private void drop_bulk_insert_role()
        {
            change_bulk_insert_role(false);
        }

        /// <summary>
        /// Add nddbo sql server login to the bulkadmin fixed server role under Security>Server roles.
        /// </summary>
        private void change_bulk_insert_role(bool isAdd)
        {
            try
            {
                var QueryStatement = String.Format(@"EXEC {0} 'nmdbo', 'bulkadmin'",
                                                   ((isAdd) ? "sp_addsrvrolemember" : "dropsrvrolemember"));
                using (var conn = ConnectionManager.CreateConnection())
                {
                    using (var stmt = conn.CreateAdapterStatement(QueryStatement))
                    {
                        stmt.ExecuteNonQuery();
                    }
                }
            }
            catch
            {
            } // Swallow
        }

        /// <summary>
        /// Helper to load data files. Must grant bulkload to nmdbo user first before test.
        /// </summary>
        /// <param name="runId"></param>
        private void PrepLoadData(int runId)
        {
            DatabaseHelper.DropTable("t_tax_details");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_DETAILS__");
            drop_output_table(runId);
            drop_input_table(runId);
            DatabaseHelper.CreateInputTable(runId);
            import_data_into_input_table(runId);
            DatabaseHelper.LoadProductCodeMappingsForTest();
        }

#if true
        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            // Start by making sure we have an empty exemptions and override table.
            DatabaseHelper.DropTable("t_tax_billsoft_exemptions");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_EXEMPTIONS__");

            DatabaseHelper.DropTable("t_tax_billsoft_override");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_Adjustments")]
        public void TestConstantConverterEZTaxType()
        {
            for (short i = 1; i < 180; i++)
            {
                if (i == 168 || i == 171) continue;  //Reserved by billsoft.

                if (BillSoftConstantConverter.GetEZTaxType(i).Length <= 0)
                {
                    Console.WriteLine("Failed to convert constant " + i + "to a tax type.");
                    throw new Exception("Failed to convert constant " + i + "to a tax type.");
                }
            }

            // Check conversion of an unknown code
            if (BillSoftConstantConverter.GetEZTaxType(11111).Length <= 0)
            {
                Console.WriteLine("Failed to convert constant " + 11111 + "to a tax type.");
                throw new Exception("Failed to convert constant " + 11111 + "to a tax type.");
            }
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftHelperObject_TEST_BASIC_POSITIVE_EMPTY_COMPLETE_TABLE")]
        public void CreateBillSoftHelperObject_TEST_BASIC_POSITIVE_EMPTY_TABLE()
        {
            int RUNID = 1;
            PrepLoadData(RUNID);
            var rcd = new Interop.RCD.MTRcd();
            var cfg = new BillSoftConfiguration(Path.Combine(rcd.ExtensionDir, mPathToConfigFile));

            var helper = new BillSoftHelper(cfg, RUNID, true, true, "t_tax_input_1", "t_tax_output_1", 5);
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftHelperObject_TEST_BASIC_POSITIVE_NONEMPTY_COMPLETE_TABLE")]
        public void CreateBillSoftHelperObject_TEST_BASIC_POSITIVE_NONEMPTY_COMPLETE_TABLE()
        {
            int RUNID = 2;
            PrepLoadData(RUNID);
            var rcd = new Interop.RCD.MTRcd();
            var cfg = new BillSoftConfiguration(Path.Combine(rcd.ExtensionDir, mPathToConfigFile));

            var helper = new BillSoftHelper(cfg, RUNID, true, true, "t_tax_input_2", "t_tax_output_2", 5);
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftHelperObject_TEST_BASIC_POSITIVE_NONEMPTY_MISSING_FIELD_TABLE")]
        public void CreateBillSoftHelperObject_TEST_BASIC_POSITIVE_NONEMPTY_MISSING_FIELD_TABLE()
        {
            int RUNID = 3;
            PrepLoadData(RUNID);
            var rcd = new Interop.RCD.MTRcd();
            var cfg = new BillSoftConfiguration(Path.Combine(rcd.ExtensionDir, mPathToConfigFile));

            var helper = new BillSoftHelper(cfg, RUNID, true, true, "t_tax_input_3", "t_tax_output_3", 5);
        }

        public void SynchronizeTaxVendorParams()
        {
            Framework.Hooks.VendorParamsHook hook = new Framework.Hooks.VendorParamsHook();
            int pval = 0;
            hook.Execute(null, ref pval);
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES()
        {
            int RUNID = 4;
            PrepLoadData(RUNID);

            DatabaseHelper.DropTable("t_tax_vendor_params");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_VENDOR_PARAMS__");
            SynchronizeTaxVendorParams();

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                                 {
                                     TaxRunId = RUNID,
                                     IsAuditingNeeded = true,
                                     TaxDetailsNeeded = true
                                 };
                billsoft.MaximumNumberOfErrors = 3;
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        [TestMethod()]
        [TestCategory("BillSoftPermitMultipleErrors")]
        public void BillSoftPermitMultipleErrors()
        {
            int RUNID = 9;
            PrepLoadData(RUNID);

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                {
                    TaxRunId = RUNID,
                    IsAuditingNeeded = true,
                    TaxDetailsNeeded = true
                };
                billsoft.MaximumNumberOfErrors = 3;
                billsoft.CalculateTaxes();
                throw new Exception("Should have exceeded 3 errors and thrown exception");
            }
            catch (Exception)
            {
                // input table has 10 rows
                // rows 3,5,7,9 contain errors
                // We expect the output table to contain results for rows 1,2,4,6,8
                long numRows = TaxManagerVendorInputTableReader.CountRowsOnTable(String.Format("t_tax_output_{0}", RUNID));

                Assert.AreEqual(5, numRows);
            }
        }

#endif
        [TestMethod()]
        [TestCategory("BillSoftZeroTax")]
        public void BillSoftZeroTax()
        {
            int RUNID = 10;
            PrepLoadData(RUNID);

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                {
                    TaxRunId = RUNID,
                    IsAuditingNeeded = true,
                    TaxDetailsNeeded = true
                };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID),
                    "When Billsoft doesn't return any taxes, t_tax_output_* should contain row with zeroes");
            }
            catch (Exception e)
            {
                throw e;
            }
        }

#if true
        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES_NO_AUDIT")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES_NO_AUDIT()
        {
            int RUNID = 4;
            PrepLoadData(RUNID);

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                                 {
                                     TaxRunId = RUNID,
                                     IsAuditingNeeded = false,
                                     TaxDetailsNeeded = true
                                 };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES_NO_AUDIT_OR_DETAILS")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES_NO_AUDIT_OR_DETAILS()
        {
            int RUNID = 4;
            PrepLoadData(RUNID);

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                                 {
                                     TaxRunId = RUNID,
                                     IsAuditingNeeded = false,
                                     TaxDetailsNeeded = false
                                 };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
                Assert.AreEqual(CountDetailRows(), 0);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES_NO_DETAILS")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES_NO_DETAILS()
        {
            int RUNID = 4;
            PrepLoadData(RUNID);

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                                 {
                                     TaxRunId = RUNID,
                                     IsAuditingNeeded = true,
                                     TaxDetailsNeeded = false
                                 };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
                Assert.AreEqual(CountDetailRows(), 0);
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES_WITH_EXEMPTIONS")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES_WITH_EXEMPTIONS()
        {
            DatabaseHelper.DropTable("t_tax_billsoft_exemptions");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_EXEMPTIONS__");
            import_exemptions();

            int RUNID = 4;
            PrepLoadData(RUNID);

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                                 {
                                     TaxRunId = RUNID,
                                     IsAuditingNeeded = true,
                                     TaxDetailsNeeded = true
                                 };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                DatabaseHelper.DropTable("t_tax_billsoft_exemptions");
                DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_EXEMPTIONS__");
            }
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES_WITH_NO_TAXRUNID_SET")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES_WITH_NO_TAXRUNID_SET()
        {
            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch();
                billsoft.CalculateTaxes();
                throw new Exception("Test failed, must have thrown and exception");
            }
            catch
            {
            } // Swallow exception, this is success.
        }

        [TestMethod()]
        [TestCategory("CreateConfigurationObject_TEST_BASIC_POSITIVE")]
        public void CreateConfigurationObject_TEST_BASIC_POSITIVE()
        {
            Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();

            var cfg = new BillSoftConfiguration(Path.Combine(rcd.ExtensionDir, mPathToConfigFile));
            //Assert.AreEqual(param1, param2, "Message");
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_CALC_TAXES_WITH_OVERRIDES")]
        public void CreateBillSoftObject_BILLSOFT_CALC_TAXES_WITH_OVERRIDES()
        {
            int RUNID = 5;
            PrepLoadData(RUNID);

            DatabaseHelper.DropTable("t_tax_billsoft_override");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
            import_overrides();

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                {
                    TaxRunId = RUNID,
                    IsAuditingNeeded = true,
                    TaxDetailsNeeded = true
                };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
                // Make sure we got changes to the tax output of the tables!
                Assert.IsFalse(DatabaseHelper.AreOutputTablesTheSame("t_tax_output_4", "t_tax_output_5"));
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception: " + e.Message + " InnerException: " + e.InnerException + "Stack: " + e.StackTrace);
                throw e;
            }
            finally
            {
                DatabaseHelper.DropTable("t_tax_billsoft_override");
                DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
            }
        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_BILLSOFT_COMMIT_AUDIT")]
        public void CreateBillSoftObject_BILLSOFT_COMMIT_AUDIT()
        {
            int RUNID = 5;
            PrepLoadData(RUNID);

            DatabaseHelper.DropTable("t_tax_billsoft_override");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
            import_overrides();

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                {
                    TaxRunId = RUNID,
                    IsAuditingNeeded = true,
                    TaxDetailsNeeded = true
                };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
                // Make sure we got changes to the tax output of the tables!
                Assert.IsFalse(DatabaseHelper.AreOutputTablesTheSame("t_tax_output_4", "t_tax_output_5"));

                //billsoft.CommitTaxRun();

            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                DatabaseHelper.DropTable("t_tax_billsoft_override");
                DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
            }
        }
#endif

#if true
        //[TestMethod()]
        // This tests currently doesn't work because the audit file
        // is still held by the BillSoft DLL.  The problem is with
        // the test rather than with the code.
        [TestCategory("CreateBillSoftObject_BILLSOFT_ROLLBACK")]
        public void CreateBillSoftObject_BILLSOFT_ROLLBACK()
        {
            int RUNID = 5;
            PrepLoadData(RUNID);
            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                {
                    TaxRunId = RUNID,
                    IsAuditingNeeded = true,
                    TaxDetailsNeeded = true
                };
                billsoft.CalculateTaxes(); // This ensures t_tax_detail is there

                billsoft.ReverseTaxRun();
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        [TestMethod()]
        [TestCategory("AddNullRowTest")]
        public void AddNullRowTest()
        {
            int runId = 100;
            var mOutTbl = "t_tax_output_" + runId;
            drop_output_table(runId);
            TaxManagerBatchDbTableWriter.CreateOutputTable(mOutTbl);
            var mOutputWriter = new TaxManagerBatchDbTableWriter(mOutTbl, 10);
            var row = new TransactionTaxSummary { IdTaxCharge = runId };
            mOutputWriter.Add(row);
            mOutputWriter.Commit();
        }

        [TestMethod()]
        [TestCategory("AddNullMidValue")]
        public void AddNullMidValue()
        {
            int runId = 100;
            var mOutTbl = "t_tax_output_" + runId;
            drop_output_table(runId);
            TaxManagerBatchDbTableWriter.CreateOutputTable(mOutTbl);
            var mOutputWriter = new TaxManagerBatchDbTableWriter(mOutTbl, 10);
            var row = new TransactionTaxSummary
                        {
                            IdTaxCharge = runId,
                            TaxCountyName = "Foo",
                            TaxLocalRounded = (decimal)0.123456789
                        };
            mOutputWriter.Add(row);
            mOutputWriter.Commit();

        }

        [TestMethod()]
        [TestCategory("CreateBillSoftObject_Adjustments")]
        public void CreateBillSoftObject_Adjustments()
        {
            // Test based on runid 4 but, all of the values are negative which makes them adjustments.
            // Thus sum up all of the amounts from both tables MUST be zero.
            int RUNID = 6;
            PrepLoadData(RUNID);

            DatabaseHelper.DropTable("t_tax_billsoft_override");
            DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
            import_overrides();

            try
            {
                var billsoft = new BillSoftSyncTaxManagerDBBatch
                {
                    TaxRunId = RUNID,
                    IsAuditingNeeded = true,
                    TaxDetailsNeeded = true
                };
                billsoft.CalculateTaxes();
                Assert.IsTrue(AreInputAndOutputRowsEqual(RUNID));
                // Make sure we got changes to the tax output of the tables!
                Assert.IsFalse(DatabaseHelper.AreOutputTablesTheSame("t_tax_output_4", "t_tax_output_6"));
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                DatabaseHelper.DropTable("t_tax_billsoft_override");
                DatabaseHelper.CreateTable("__CREATE_T_TAX_BILLSOFT_OVERRIDES__");
            }
        }

#endif

#if false
    [TestMethod()]
    [TestCategory("CreateBillSoftObject_USF_TESTS")]
    public void CreateBillSoftObject_USF_TESTS()
    {
      // Test based on runid 4 but, all of the values are negative which makes them adjustments.
      // Thus sum up all of the amounts from both tables MUST be zero.
      int RUNID = 7;
      PrepLoadData(RUNID);
      try
      {
        var billsoft = new BillSoftSyncTaxManagerDBBatch
        {
          TaxRunId = RUNID,
          IsAuditingNeeded = true,
          TaxDetailsNeeded = true
        };
        billsoft.CalculateTaxes();
      }
      catch (Exception e)
      {
        throw e;
      }
    }
    [TestMethod()]
    [TestCategory("CreateBillSoftObject_CANADA_PCODE")]
    public void CreateBillSoftObject_CANADA_PCODE()
    {
      // Test based on runid 4 but, all of the values are negative which makes them adjustments.
      // Thus sum up all of the amounts from both tables MUST be zero.
      int RUNID = 8;
      PrepLoadData(RUNID);
      try
      {
        var billsoft = new BillSoftSyncTaxManagerDBBatch
        {
          TaxRunId = RUNID,
          IsAuditingNeeded = true,
          TaxDetailsNeeded = true
        };
        billsoft.CalculateTaxes();
      }
      catch (Exception e)
      {
        throw e;
      }
    }
#endif
    }
}

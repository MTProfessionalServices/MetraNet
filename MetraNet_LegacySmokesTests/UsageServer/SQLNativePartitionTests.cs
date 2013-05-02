using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Runtime.InteropServices;
using System.IO;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.Test;
using MetraTech.Xml;
using MetraTech.Interop.MTHookHandler;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test
{
    [TestFixture]
    [Category("NoAutoRun")]
    [ComVisible(false)]
    public class SqlNativePartitionTests
    {
        private const string QueryPath = "Queries\\SmokeTest";
        private const string UsageServerConfigFile = @"UsageServer\usageserver.xml";

        private const string PvTableName = "t_pv_stocks";
        private const string AmpUsageTableName = "agg_usage_audit_trail";
        private const string AmpChangreTableName = "agg_charge_audit_trail";

        private readonly string _pvIdSessTableName = String.Format("##{0}_iserteddata", PvTableName);
        private readonly string _ampUsageIdSessTableName = String.Format("##{0}_iserteddata", AmpUsageTableName);
        private readonly string _ampChangreIdSessTableName = String.Format("##{0}_iserteddata", AmpChangreTableName);

        readonly IMTHookHandler _hookHandler = new MTHookHandlerClass();

        #region msixdef metadata for PV tables
        private readonly string _pathToPvFile = Path.Combine(MTXmlDocument.ExtensionDir,
                                                             @"SmokeTest\config\productview\metratech.com\stocks.msixdef");
        private readonly string _pathToPvFileBackup = Path.Combine(MTXmlDocument.ExtensionDir,
                                                             @"SmokeTest\config\productview\metratech.com\stocks.bak");
        #endregion msixdef metadata for PV tables

        #region msixdef metadata for SVC tables
        private static readonly string _pathToSvcFile= Path.Combine(MTXmlDocument.ExtensionDir,
                                                             @"SmokeTest\config\service\metratech.com\stocks.msixdef");
        private const string NewSvcName = "stocks_new_test";
        private static readonly string _newSvcExtension = String.Format(@"metratech.com/{0}", NewSvcName);
        private static readonly string _pathToNewSvcFile = Path.Combine(Path.GetDirectoryName(_pathToSvcFile)
                                                                         , String.Format("{0}{1}", NewSvcName, Path.GetExtension(_pathToSvcFile)));

        private static readonly string _newSvcTable = String.Format("t_svc_{0}", NewSvcName);
        #endregion msixdef metadata for SVC tables

        [TestFixtureSetUp]
        public void InitPartitionTest()
        {
            if (!IsPartitionSupportEnabled())
            {
                Assert.Ignore("'Sql Native Partition Tests' are running only when partitioning is enabled.");
            }

            using (var conn = ConnectionManager.CreateConnection())
            {
                if (!conn.ConnectionInfo.IsSqlServer)
                {
                    Assert.Ignore("'Sql Native Partition Tests' are running only on SQL server.");
                }
            }
        }

        #region Tests

        /// <summary>
        /// Test verifies that all expected tables are under UsagePartitionSchema.
        /// </summary>
        [Test]
        public void TestPartitioningAppliedOnPartitionTables()
        {
		    TestLibrary.Trace("\n--------------------------------------------\nStarting test that all expected tables under partition schema...");

            using (IMTConnection netMeterConn = ConnectionManager.CreateConnection())
            {
                Assert.IsTrue(UsagePartitionFunctionExists(netMeterConn), "Usage partition function wasn't created.");
                Assert.IsTrue(UsagePartitionSchemaExists(netMeterConn), "Usage partition schema wasn't created.");

                Assert.IsTrue(MeterPartitionFunctionExists(netMeterConn), "Meter partition function wasn't created.");
                Assert.IsTrue(MeterPartitionSchemaExists(netMeterConn), "Meter partition schema wasn't created.");

                var tablesUnderPartition = RetrieveAllTablesWithPartitioning(netMeterConn);
                TestLibrary.Trace("\n--------------------------------------------\n{0} tables are under UsagePartitionSchema.",
                                  tablesUnderPartition.Count);

			    TestLibrary.Trace("\n--------------------------------------------\nChecking that all expected tables are under partition schema...");
                var tablesMissedPartition = CheckExpectedTablesHavePartiton(tablesUnderPartition, netMeterConn);

                Assert.IsTrue(String.IsNullOrEmpty(tablesMissedPartition),
                              "Some expected tables wasn't under partition schema.\nTable Names:\n{0}", tablesMissedPartition);
            }
        }

        /// <summary>
        /// Test verifies that all filegroups were created for UsagePartitionSchema.
        /// </summary>
        [Test]
        public void TestPartitionFilegroups()
        {
            using (IMTConnection netMeterConn = ConnectionManager.CreateConnection())
            {
				TestLibrary.Trace("\n--------------------------------------------\nChecking that Usage filegroups are created for Usage Partition Schema...");
                Assert.IsTrue(CheckUsagePartitionFileGroups(netMeterConn), "Some Usage filegroups weren't created");

                int countMetreFileGroups = GetCountMeterPartitionFileGroups(netMeterConn);
                TestLibrary.Trace("\n--------------------------------------------\nChecking that Meter filegroup are created for Meter Partition Schema...");
                Assert.AreNotEqual(0, countMetreFileGroups,  "Meter filegroup wasn't created for the Meter Partition Scheme");
                Assert.True(countMetreFileGroups == 1, "Meter Partition Scheme contains more then One filegroups");
            }

        }

        /// <summary>
        /// Test verifies that 't_pv_stocks' distributes data between partitions correctly.
        /// Each test record suggests to be put in a sepparate partition.
        /// All partitions suggests to have 1 test record.
        /// </summary>
        [Test]
        public void TestPVDataDistributedCorrectlyBetweenPartitions()
        {
            TestLibrary.Trace("Starting test that data distributed correctly between partitions for '{0}' table...",
                              PvTableName);

            using (IMTConnection netMeterConn = ConnectionManager.CreateConnection())
            {
                try
                {
                    InsertTestDataToPVStocks(netMeterConn, _pvIdSessTableName);

                    var isDistributedCorrectly = CheckDataDistributed(netMeterConn, PvTableName, _pvIdSessTableName);
                	Assert.IsTrue(isDistributedCorrectly, "Data distributed incorrectly between partitions for '{0}' table", PvTableName);
                }
                finally
                {
                    DeleteTestData(netMeterConn, PvTableName, _pvIdSessTableName);
                }
            }
        }

        /// <summary>
        /// Test verifies that 'agg_usage_audit_trail' and 'agg_charge_audit_trail' distributes data between partitions correctly.
        /// Each test record suggests to be put in a sepparate table's partition.
        /// All partitions suggests to have 1 test record per table.
        /// </summary>
        [Test]
        public void TestAMPDataDistributedCorrectlyBetweenPartitions()
        {
            TestLibrary.Trace("Starting test that data distributed correctly between partitions for '{0}' and '{1}' tables...",
              AmpUsageTableName, AmpChangreTableName);

            using (IMTConnection netMeterConn = ConnectionManager.CreateConnection())
            {
                try
                {
                    InsertTestDataToAmpUsageTable(netMeterConn, _ampUsageIdSessTableName);
                    var isDistributedCorrectly = CheckDataDistributed(netMeterConn, AmpUsageTableName, _ampUsageIdSessTableName);
                    Assert.IsTrue(isDistributedCorrectly, "Data distributed incorrectly between partitions for '{0}' table", AmpUsageTableName);

                    InsertTestDataToAmpChargeTable(netMeterConn, _ampChangreIdSessTableName);
                    isDistributedCorrectly = CheckDataDistributed(netMeterConn, AmpChangreTableName, _ampChangreIdSessTableName);
                    Assert.IsTrue(isDistributedCorrectly, "Data distributed incorrectly between partitions for '{0}' table", AmpChangreTableName);
                }
                finally
                {
                    DeleteTestData(netMeterConn, AmpUsageTableName, _ampUsageIdSessTableName);
                    DeleteTestData(netMeterConn, AmpChangreTableName, _ampChangreIdSessTableName);
                }
            }
        }

        /// <summary>
        /// Tests that Unique Key tables approach works correctly.
        /// </summary>
        [Test]
        public void TestUniqueKeyTables()
        {
            const string testConstraintName = "testUniqueKey";
            string ukTableName = String.Format("t_uk_{0}", testConstraintName);

            //Backup PV file
            File.Copy(_pathToPvFile, _pathToPvFileBackup, true);
            bool isNewPvFileCreated = false;
            bool isNewPvTableCreated = false;
            try
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(_pathToPvFile);

                XmlNode rootNode = doc.SelectSingleNode("defineservice");
                Assert.IsNotNull(rootNode);

                RemoveExistingUniqueKeys(rootNode);

                // Testing UkTables on 'int', 'datetime', 'numeric' and 'nvarchar' data types
                var testUkNode = doc.CreateElement("uniquekey");
                testUkNode.InnerXml =
                  String.Format(
                    @"<name>{0}</name><col>{1}</col><col>{2}</col><col>{3}</col><col>{4}</col>",
                    testConstraintName, "quantity", "ordertime", "price", "broker");
                rootNode.AppendChild(testUkNode);
                doc.Save(_pathToPvFile);
                isNewPvFileCreated = true;

                RunPvHook();
                isNewPvTableCreated = true;

                Assert.IsTrue(IsUkTableExists(ukTableName), "Unique Key table '{0}' for constraint '{1}' wasn't created",
                              ukTableName, testConstraintName);

                const int testQuantity = 1;
                DateTime testOrderTime = DateTime.Now;
                const double testPrice = 999.999;
                const string testBrokerName = "TestBrokerName";

                bool exceptionThrown = false;

                using (var conn = ConnectionManager.CreateConnection())
                {
                    var insert = conn.CreateAdapterStatement(QueryPath, "__UK_TABLE_INSERT_DATA__");
                    insert.AddParam("%%UK_TABLE_NAME%%", ukTableName, true);
                    insert.AddParam("%%TEST_QUANTITY%%", testQuantity, true);
                    insert.AddParam("%%TEST_ORDER_TIME%%", testOrderTime, true);
                    insert.AddParam("%%TEST_PRICE%%", testPrice, true);
                    insert.AddParam("%%TEST_BROKER%%", testBrokerName, true);
                    insert.ExecuteNonQuery();
                    try
                    {
                        insert.ExecuteNonQuery();
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Message.Contains("Violation of UNIQUE KEY constraint"))
                            exceptionThrown = true;
                        else
                        {
                            throw;
                        }
                    }
                }

                Assert.IsTrue(exceptionThrown,
                              "Expected 'Violation of UNIQUE KEY constraint' SqlException wasn't thrown after inserting non-unique data.");
            }
            finally
            {
                if (isNewPvFileCreated)
                {
                    //Restore original PV
                    File.Copy(_pathToPvFileBackup, _pathToPvFile, true);
                    File.Delete(_pathToPvFileBackup);

                    if (isNewPvTableCreated)
                    {
                        RunPvHook();
                    }
                }
            }
        }


        /// <summary>
        /// Tests verifies that new created SVC table put under partitioning.
        /// </summary>
        [Test]
        public void TestNewlyCreatedSvcTableUnderPartition()
        {
            TestLibrary.Trace("\n--------------------------------------------\nStarting test that new created SVC table under partition...");
            bool isNewSvcTableCreatedAndUnderPartition = false;
            try
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(_pathToSvcFile);

                XmlNode nameNode = doc.SelectSingleNode("defineservice/name");
                Assert.IsNotNull(nameNode);

                nameNode.InnerText = _newSvcExtension;
                doc.Save(_pathToNewSvcFile);

                RunSvcHook();

                using (var conn = ConnectionManager.CreateConnection())
                {
                    var checkQuery = conn.CreateAdapterStatement(QueryPath, "__TABLE_EXISTS__");
                    checkQuery.AddParam("%%TABLE_NAME%%", _newSvcTable, true);
                    var rdr = checkQuery.ExecuteReader();
                    rdr.Read();
                    isNewSvcTableCreatedAndUnderPartition = rdr.GetBoolean("table_exists");
                    Assert.IsTrue(isNewSvcTableCreatedAndUnderPartition,
                        String.Format(@"New SVC table ""{0}"" was not created after execution Service Definisio Hook.\n
                                       New file with new SVC table definision was not removed and can be found in {1} for the test review"
                                       , _newSvcTable, _pathToNewSvcFile));
                }

                using (IMTConnection netMeterConn = ConnectionManager.CreateConnection())
                {
                    var tablesUnderPartition = RetrieveAllTablesWithPartitioning(netMeterConn);
                    isNewSvcTableCreatedAndUnderPartition = tablesUnderPartition.Contains(_newSvcTable);
                    Assert.IsTrue(isNewSvcTableCreatedAndUnderPartition,
                                    String.Format(@"New created SVC table ""{0}"" is not under partition and was not removed from DB for the test revie.\n
                                                    New file with new SVC table definision was not removed and can be found in {1} for the test review."
                                    , _newSvcTable, _pathToNewSvcFile));
                    
                }
            }
            finally
            {
                if (isNewSvcTableCreatedAndUnderPartition)
                {
                    File.Delete(_pathToNewSvcFile);
                    RunSvcHook();
                }
            }
        }

        #endregion

		#region Private methods for tests

        private List<string> RetrieveAllTablesWithPartitioning(IMTConnection netMeterConn)
        {
            var tablesUnderPartition = new List<string>();

			var actualPartitionTablesQuery = netMeterConn.CreateAdapterStatement(QueryPath, "__GET_ACTUAL_PARTITION_TABLE_NAMES__");
            var _rdr = actualPartitionTablesQuery.ExecuteReader();
            while (_rdr.Read())
            {
                string currentTableName;
                try
                {
                    currentTableName = Convert.ToString(_rdr.GetValue("table_name"));
                }
                catch (Exception ex)
                {
					throw new Exception("Could not retrieve 'table_name' parameter from query __GET_ACTUAL_PARTITION_TABLE_NAMES__", ex);
                }
                tablesUnderPartition.Add(currentTableName);
            }
            return tablesUnderPartition;
        }

        private string CheckExpectedTablesHavePartiton(List<string> tablesUnderPartition, IMTConnection netMeterConn)
        {
            var tablesMissedPartition = "";

			var expectedPartitionTablesQuery = netMeterConn.CreateAdapterStatement(QueryPath, "__GET_EXPECTED_PARTITION_TABLE_NAMES__");
            var rdr = expectedPartitionTablesQuery.ExecuteReader();
            while (rdr.Read())
            {
                string currentTableName;
                try
                {
                    currentTableName = Convert.ToString(rdr.GetValue("table_name"));
                }
                catch (Exception ex)
                {
					throw new Exception("Could not retrieve 'table_name' parameter from query __GET_EXPECTED_PARTITION_TABLE_NAMES__", ex);
                }

                if (!tablesUnderPartition.Contains(currentTableName))
                {
                    tablesMissedPartition = String.Format("{0}{1}\n", tablesMissedPartition, currentTableName);
                }
            }

            return tablesMissedPartition;
        }

        private bool UsagePartitionSchemaExists(IMTConnection netMeterConn)
        {
			var actualPartitionTablesQuery = netMeterConn.CreateAdapterStatement(QueryPath, "__SELECT_USAGE_PARTITION_SCHEMA__");
            var rdr = actualPartitionTablesQuery.ExecuteReader();
            return rdr.Read();
        }

        private bool UsagePartitionFunctionExists(IMTConnection netMeterConn)
        {
			var actualPartitionTablesQuery = netMeterConn.CreateAdapterStatement(QueryPath, "__SELECT_USAGE_PARTITION_FUNCTION__");
            var rdr = actualPartitionTablesQuery.ExecuteReader();
            return rdr.Read();
        }

        private bool IsPartitionSupportEnabled()
        {
            var doc = new MTXmlDocument();
            doc.LoadConfigFile(UsageServerConfigFile);
            var node = doc.SelectSingleNode("//Partitions/Enable");
            return String.Compare(node.InnerText, "true", StringComparison.OrdinalIgnoreCase) == 0;
        }

        private bool CheckUsagePartitionFileGroups(IMTConnection netMeterConn)
        {
            var filegroupsFromUsagePartitionTable = netMeterConn.CreateAdapterStatement(QueryPath, "__CHECK_USAGE_PARTITION_FILEGROUPS__");
            var rdr = filegroupsFromUsagePartitionTable.ExecuteReader();
            while (rdr.Read())
            {
                return rdr.GetBoolean("check_usage_filegroups");
            }
            return false;
        }

        /// <summary>
        /// Gets Meter Partition File groups for Meter Partition Scheme
        /// </summary>
        /// <param name="netMeterConn"></param>
        /// <returns></returns>
        private int GetCountMeterPartitionFileGroups(IMTConnection netMeterConn)
        {
            int countMeterFileGroupsForMeterPartitionScheme = 0;
			var filegroupsFromPartitionSheme = netMeterConn.CreateAdapterStatement(QueryPath, "__CHECK_METER_PARTITION_FILEGROUPS__");
            var rdr = filegroupsFromPartitionSheme.ExecuteReader();
            
            while (rdr.Read())
            {
                countMeterFileGroupsForMeterPartitionScheme++;
            }

            return countMeterFileGroupsForMeterPartitionScheme;
        }

        private void InsertTestDataToPVStocks(IMTConnection netMeterConn, string tempTabForIdSess)
        {
            var stmnt = netMeterConn.CreateAdapterStatement(QueryPath, "__INSERT_TEST_DATA_TO_PV_STOCKS_TABLE__");
            stmnt.AddParam("%%TABLE_WITH_TEST_IDSESS%%", tempTabForIdSess);
            stmnt.ExecuteNonQuery();
        }

        private void InsertTestDataToAmpUsageTable(IMTConnection netMeterConn, string tableWithTestIdSess)
        {
            var stmnt = netMeterConn.CreateAdapterStatement(QueryPath, "__INSERT_TEST_DATA_TO_AMP_USAGE_TABLE__");
            stmnt.AddParam("%%TABLE_WITH_TEST_IDSESS%%", tableWithTestIdSess);
            stmnt.ExecuteReader();
        }

        private void InsertTestDataToAmpChargeTable(IMTConnection netMeterConn, string tableWithTestIdSess)
        {
            var stmnt = netMeterConn.CreateAdapterStatement(QueryPath, "__INSERT_TEST_DATA_TO_AMP_CHARGE_TABLE__");
            stmnt.AddParam("%%TABLE_WITH_TEST_IDSESS%%", tableWithTestIdSess);
            stmnt.ExecuteReader();
        }

        private bool CheckDataDistributed(IMTConnection netMeterConn, string partitionTable, string tableWithTestIdSess)
        {
            var isDataDistributedCorrectly = false;

            var resultStatement = netMeterConn.CreateAdapterStatement(QueryPath, "__CHECK_DATA_DISTRIBUTED__");
            resultStatement.AddParam("%%PART_TABLE%%", partitionTable);
            resultStatement.AddParam("%%TABLE_WITH_TEST_IDSESS%%", tableWithTestIdSess);
            var rdr = resultStatement.ExecuteReader();
            if (rdr.Read())
            {
                isDataDistributedCorrectly = rdr.GetBoolean(0);
            }
            else
            {
                Assert.Fail(
                  "Unable to read @test_result from query '__CHECK_DATA_DISTRIBUTED__', that indicates whether data distributed correctly between partitions");
            }

            return isDataDistributedCorrectly;
        }

        private void DeleteTestData(IMTConnection netMeterConn, string partitionTable, string tableWithTestIdSess)
        {
            var stmnt = netMeterConn.CreateAdapterStatement(QueryPath, "__DELETE_TEST_DATA__");
            stmnt.AddParam("%%PART_TABLE%%", partitionTable);
            stmnt.AddParam("%%TABLE_WITH_TEST_IDSESS%%", tableWithTestIdSess);
            stmnt.ExecuteNonQuery();
        }

        private void RunPvHook()
        {
            int x = 0;
            _hookHandler.RunHookWithProgid("MetraHook.DeployProductView.1", null, ref x);
        }

        private void RunSvcHook()
        {
            int x = 0;
            _hookHandler.RunHookWithProgid("MetraTech.Product.Hooks.ServiceDefHook", null, ref x);
        }

        private bool IsUkTableExists(string ukTableName)
        {
            using (var conn = ConnectionManager.CreateConnection())
            {
                var checkQuery = conn.CreateAdapterStatement(QueryPath, "__TABLE_EXISTS__");
                checkQuery.AddParam("%%TABLE_NAME%%", ukTableName, true);
                var rdr = checkQuery.ExecuteReader();
                rdr.Read();
                return rdr.GetBoolean("table_exists");
            }
        }

        private void RemoveExistingUniqueKeys(XmlNode rootNode)
        {
            var existingUniqueKeys = rootNode.SelectNodes("uniquekey");
            if (existingUniqueKeys != null)
            {
                foreach (XmlNode existingUniqueKey in existingUniqueKeys)
                {
                    rootNode.RemoveChild(existingUniqueKey);
                }
            }
        }

        #region Private methods to test meter partition

        private bool MeterPartitionSchemaExists(IMTConnection netMeterConn)
        {
            var meterPartitionSchemaQuery = netMeterConn.CreateAdapterStatement(QueryPath,
                                                                                "__SELECT_METER_PARTITION_SCHEMA__");
            var rdr = meterPartitionSchemaQuery.ExecuteReader();
            return rdr.Read();
        }

        private bool MeterPartitionFunctionExists(IMTConnection netMeterConn)
        {
            var meterPartitionFunctionQuery = netMeterConn.CreateAdapterStatement(QueryPath,
                                                                                  "__SELECT_METER_PARTITION_FUNCTION__");
            var rdr = meterPartitionFunctionQuery.ExecuteReader();
            return rdr.Read();
        }

        #endregion

        #endregion
    }
}


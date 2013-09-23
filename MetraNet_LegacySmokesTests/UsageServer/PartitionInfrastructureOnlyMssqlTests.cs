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
    [ComVisible(false)]
    public class PartitionInfrastructureOnlyMssqlTests
    {
        private const string QueryPath = "Queries\\SmokeTest";
        private const string UsageServerConfigFile = @"UsageServer\usageserver.xml";
      

        readonly IMTHookHandler _hookHandler = new MTHookHandlerClass();

        #region msixdef metadata for PV tables
        private readonly string _pathToPvFile = Path.Combine(MTXmlDocument.ExtensionDir,
                                                             @"SmokeTest\config\productview\metratech.com\stocks.msixdef");
        private readonly string _pathToPvFileBackup = Path.Combine(MTXmlDocument.ExtensionDir,
                                                             @"SmokeTest\config\productview\metratech.com\stocks.bak");
        #endregion msixdef metadata for PV tables

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

        #endregion

		#region Private methods for tests

        private bool IsPartitionSupportEnabled()
        {
            var doc = new MTXmlDocument();
            doc.LoadConfigFile(UsageServerConfigFile);
            var node = doc.SelectSingleNode("//Partitions/Enable");
            return String.Compare(node.InnerText, "true", StringComparison.OrdinalIgnoreCase) == 0;
        }

        
        private void RunPvHook()
        {
            int x = 0;
            _hookHandler.RunHookWithProgid("MetraHook.DeployProductView.1", null, ref x);
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

        #endregion
    }
}


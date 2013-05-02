using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.Xml;
using NUnit.Framework;
using MetraTech.DataAccess;
using MetraTech.Test;
using MetraTech.Xml;

namespace MetraTech.UsageServer.Test
{
    [TestFixture]
    [Category("NoAutoRun")]
    [ComVisible(false)]
    class PartitionTypesTests
    {
        private const string TestDbName = "TestNetMeter";
        private const string TestDbStageName = "TestNetMeter_STAGE";
        private const string TestUserName = "TestUser";
        private const string QueryPath = "Queries\\SmokeTest";
        private const string PathToDbBakFolder = @"C:\PartitionTypesTestsBackup";
        private const string UsageServerConfigFile = @"UsageServer\usageserver.xml";
        private readonly string _pathToUsageServerFile = Path.Combine(MTXmlDocument.ConfigDir, @"UsageServer\usageserver.xml");
        private readonly string _pathToUsageServerFileBackup = Path.Combine(MTXmlDocument.ConfigDir, @"UsageServer\usageserver.bak");
        private readonly string _pathToServersFile = Path.Combine(MTXmlDocument.ConfigDir, @"ServerAccess\servers.xml");
        private readonly string _pathToServersFileBackup = Path.Combine(MTXmlDocument.ConfigDir, @"ServerAccess\servers.bak");
        private readonly string _pathToDbBakFile = Path.Combine(PathToDbBakFolder, String.Format("{0}.bak", TestDbName));
        // Use Dev or QA path
        private readonly string _pathToScriptsFolder =
            Directory.Exists(@"S:\Install\Scripts")
                ? @"S:\Install\Scripts"
                : Path.Combine(Environment.GetEnvironmentVariable("MTRMP"), @"Install\Scripts");

        /// <summary>
        /// Wait for non-pending status on starting or stopping services
        /// </summary>
        private readonly TimeSpan _changeServiceStatusTimeout = TimeSpan.FromMinutes(3);

        private readonly List<string> _affectedServices = new List<string>
            {
                "msmq",
                "pipeline",
                "activityservices",
                "iisadmin",
                "w3svc",
                "metrapay",
                "metratech.fileservice",
                "billingserver",
                "MetraTechDataExportService"
            };

        private readonly SqlNativePartitionTests _nativePartitionTests = new SqlNativePartitionTests();

#region Tests
        [TestFixtureSetUp]
        public void InitPartitionTypesTest()
        {
            // Stop All Services
            StopAllServices();

            // Backup servers.xml and usageserver.xml
            File.Copy(_pathToServersFile, _pathToServersFileBackup, true);
            File.Copy(_pathToUsageServerFile, _pathToUsageServerFileBackup, true);

            // Prepare usageserver.xml for partition tests
            var doc = new XmlDocument();
            doc.Load(_pathToUsageServerFile);
            doc.SelectSingleNode("//Partitions/Enable").InnerText = "False";
            doc.SelectSingleNode("//Intervals/AdvanceIntervalCreationDays").InnerText = "190";
            doc.Save(_pathToUsageServerFile);

            CreateTestDb();

            // Backup Test NetMeter
            if (!Directory.Exists(PathToDbBakFolder))
                Directory.CreateDirectory(PathToDbBakFolder);

            using (var conn = ConnectionManager.CreateConnection())
            {
                var backupDbQuery = conn.CreateAdapterStatement(QueryPath, "__BACKUP_DATABASE__");
                backupDbQuery.AddParam("%%DB_NAME%%", TestDbName);
                backupDbQuery.AddParam("%%PATH_TO_BAK_FILE%%", _pathToDbBakFile);
                backupDbQuery.ExecuteNonQuery();
            }
        }

        [Test]
        public void TestNonPartitionedToWeeklyPartitioned()
        {
            NonPartitionedToPartitioned(PartitionTypes.Weekly);
        }

        [Test]
        public void TestNonPartitionedToSemiMonthlyPartitioned()
        {
            NonPartitionedToPartitioned(PartitionTypes.SemiMonthly);
        }

        [Test]
        public void TestNonPartitionedToMonthlyPartitioned()
        {
            NonPartitionedToPartitioned(PartitionTypes.Monthly);   
        }

        [Test]
        public void TestNonPartitionedToQuaterlyPartitioned()
        {
            NonPartitionedToPartitioned(PartitionTypes.Quarterly);
        }
        
        [TearDown]
        public void CleanupTest()
        {
            // Restore NonPartitioned Test DB
            using (var conn = ConnectionManager.CreateConnection())
            {
                var backupDbQuery = conn.CreateAdapterStatement(QueryPath, "__RESTORE_DATABASE__");
                backupDbQuery.AddParam("%%DB_NAME%%", TestDbName);
                backupDbQuery.AddParam("%%PATH_TO_BAK_FILE%%", _pathToDbBakFile);
                backupDbQuery.ExecuteNonQuery();
            }
            SqlConnection.ClearAllPools();
        }

        [TestFixtureTearDown]
        public void UnInitPartitionTypesTest()
        {
            // Restore servers.xml and usageserver.xml
            File.Copy(_pathToServersFileBackup, _pathToServersFile, true);
            File.Copy(_pathToUsageServerFileBackup, _pathToUsageServerFile, true);

            StartAllServices();

            // Drop Test DBs
            using (var conn = ConnectionManager.CreateConnection())
            {
                var dropDbQuery = conn.CreateAdapterStatement(QueryPath, "__DROP_DATABASE__");
                dropDbQuery.AddParam("%%DB_NAME%%", TestDbName);
                dropDbQuery.ExecuteNonQuery();

                var dropStageDbQuery = conn.CreateAdapterStatement(QueryPath, "__DROP_DATABASE__");
                dropStageDbQuery.AddParam("%%DB_NAME%%", TestDbStageName);
                dropStageDbQuery.ExecuteNonQuery();
            }

            // Remove backup files and directory
            File.Delete(_pathToDbBakFile);
            File.Delete(_pathToUsageServerFileBackup);
            File.Delete(_pathToServersFileBackup);
            Directory.Delete(PathToDbBakFolder);
        }

        #endregion

#region Private methods for tests

        private void NonPartitionedToPartitioned(PartitionTypes partitionType)
        {
            //Update partition type in usageserver.xml for running usm.
            UpdateUsageServerConfig(partitionType);

            //Synchronize and run usm for creating NativePartitioned DB.
            RunUsm();

            //Test checks partition function and schema, checks that all product view tables under partitioning.
            _nativePartitionTests.TestPartitioningAppliedOnPartitionTables();

            //Test checks that partition filegroups are created correctly and match partition_names from t_partition table.
            _nativePartitionTests.TestPartitionFilegroups();

            //Test checks that data distributed to appropriate filegroups.
            _nativePartitionTests.TestPVDataDistributedCorrectlyBetweenPartitions();
            _nativePartitionTests.TestAMPDataDistributedCorrectlyBetweenPartitions();

            //Test checks that constraint Unique key tables are created correctly for product view tables. 
            _nativePartitionTests.TestUniqueKeyTables(); 
        }

        private void RunUsm()
        {
            var usm = new Client();
            
            TestLibrary.Trace("Running usm sync...");
            usm.Synchronize();

            TestLibrary.Trace("Running usm create...");
            usm.CreateUsageIntervals();
        }

        private void UpdateUsageServerConfig(PartitionTypes partitionType)
        {
            var usageserverconfig = new MTXmlDocument();
            usageserverconfig.LoadConfigFile(UsageServerConfigFile);

            TestLibrary.Trace("Change usage server config file for enabling partitioning");
            XmlNode enablepartitionnode = usageserverconfig.SelectSingleNode("//Partitions/Enable");
            MTXmlDocument.SetNodeValue(enablepartitionnode, "True");

            TestLibrary.Trace(String.Format("Changing partition type in usage server config file to {0}", partitionType.GetStringValue()));
            XmlNode partitiontypenode = usageserverconfig.SelectSingleNode("//Partitions/Type");
            MTXmlDocument.SetNodeValue(partitiontypenode, partitionType.GetStringValue());

            usageserverconfig.SaveConfigFile(UsageServerConfigFile);
        }

        public void StartAllServices()
        {
            foreach (var service in _affectedServices.Select(serviceName => new ServiceController(serviceName)))
            {
                if (service.Status == ServiceControllerStatus.Running) continue;

                try
                {
                    service.Start();
                    service.WaitForStatus(ServiceControllerStatus.Running, _changeServiceStatusTimeout);

                }
                catch (Exception ex)
                {
                    TestLibrary.Trace(String.Format("'{0}' service could not be started. Error message:\n{1}",
                                                    service.DisplayName, ex.Message));
                }
            }
        }

        public void StopAllServices()
        {
            foreach (var service in _affectedServices.Select(serviceName => new ServiceController(serviceName)))
            {
                if (service.CanStop)
                {
                    try
                    {
                        service.Stop();
                        service.WaitForStatus(ServiceControllerStatus.Stopped, _changeServiceStatusTimeout);
                    }
                    catch (Exception ex)
                    {
                        TestLibrary.Trace(String.Format("[ERROR] Attempt to stop '{0}' service. An exception occured:\n{1}",
                                                        service.DisplayName, ex.InnerException));
                        throw;
                    }
                }
            }
        }

        private void CreateTestDb()
        {
            var pathToDatabaseVbs = Path.Combine(_pathToScriptsFolder, "Database.vbs");
            var command = String.Format("{0} /dbname:{1} /stgdbname:{2} /userid:{3}",
                                        pathToDatabaseVbs, TestDbName, TestDbStageName, TestUserName);
            var installDbProc = new Process
            {
                StartInfo =
                    new ProcessStartInfo
                    {
                        WindowStyle = ProcessWindowStyle.Hidden,
                        FileName = "cscript.exe",
                        Arguments = command
                    }
            };

            installDbProc.Start();
            installDbProc.WaitForExit();
        }

#endregion

    }
}

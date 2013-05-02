using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
using System.ServiceProcess;
using System.Runtime.InteropServices;
using NUnit.Framework;

namespace MetraTech.UsageServer.Test
{
    using MetraTech;
    using MetraTech.Xml;
	using MetraTech.DataAccess;
	using MetraTech.Test;
	using MetraTech.Pipeline;
	using Auth = MetraTech.Interop.MTAuth;
	using MetraTech.Interop.COMMeter;
	using MetraTech.Interop.PipelineTransaction;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.UsageServer.Test.PartitionTests /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class PartitionTests
	{
    [DllImport("kernel32.dll")]
    extern static int QueryPerformanceCounter(out long x);
    [DllImport("kernel32.dll")]
    extern static int QueryPerformanceFrequency(out long x);

		// Set to true if restore partition test at startup is necessary.
		// Don't bother restoring during smoke tests...
		private bool mRestoreOnInit = false;

		/// <summary>
		/// Test Quaterly partition support
		/// </summary>
		[Test]
		public void TestNonPartitionedToQuaterlyPartitioned()
		{
			TestNonPartitionedToPartitioned(CycleType.QUATERLY, false);
		}

		/// <summary>
		/// Test Semi-Monthly partition support
		/// </summary>
		[Test]
		public void TestNonPartitionedToSemiMonthlyPartitioned()
		{
      TestNonPartitionedToPartitioned(CycleType.SEMIMONTHLY, false);
		}

		/// <summary>
		/// Test Monthly partition support
		/// </summary>
		[Test]
		public void TestNonPartitionedToMonthlyPartitioned()
		{
			TestNonPartitionedToPartitioned(CycleType.MONTHLY, false);
		}

		/// <summary>
		/// Test Weekly partition support
		/// </summary>
		[Test]
		public void TestNonPartitionedToWeeklyPartitioned()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Non partitioned to Weekly partitioned test is disabled...");
      return;

			// TestNonPartitionedToPartitioned(CycleType.WEEKLY, false);
		}

		/// <summary>
		/// Test Quaterly partition support wiht previous usage
		/// </summary>
		[Test]
		public void TestNonPartitionedToQuaterlyPartitionedWithUsage()
		{
			TestNonPartitionedWithUsageToPartitioned(CycleType.QUATERLY);
		}

		/// <summary>
		/// Test Semi-Monthly partition support wiht previous usage
		/// </summary>
		[Test]
		public void TestNonPartitionedToSemiMonthlyPartitionedWithUsage()
		{
      TestNonPartitionedWithUsageToPartitioned(CycleType.SEMIMONTHLY);
		}

		/// <summary>
		/// Test Monthly partition support wiht previous usage
		/// </summary>
		[Test]
		public void TestNonPartitionedToMonthlyPartitionedWithUsage()
		{
			TestNonPartitionedWithUsageToPartitioned(CycleType.MONTHLY);
		}

		/// <summary>
		/// Test Weekly partition support wiht previous usage
		/// </summary>
		[Test]
		public void TestNonPartitionedToWeeklyPartitionedWithUsage()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Non partitioned to Weekly partitioned with usage test is disabled...");
      return;

			// TestNonPartitionedWithUsageToPartitioned(CycleType.WEEKLY);
		}

		/// <summary>
		/// Test Quaterly to Monthly conversion test
		/// </summary>
		[Test]
		public void TestQuaterlyToMonthlyWithUsageConversion()
		{
			TestConversionWithUsage(CycleType.QUATERLY, CycleType.MONTHLY);
		}

		/// <summary>
		/// Test Quaterly to SemiMonthly conversion test
		/// </summary>
		[Test]
		public void TestQuaterlyToSemiMonthlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Quaterly to Semi Monthly with usage test is disabled...");
      return;
      
      // TestConversionWithUsage(CycleType.QUATERLY, CycleType.SEMIMONTHLY);
		}

		/// <summary>
		/// Test Quaterly to Weekly conversion test
		/// </summary>
		[Test]
		public void TestQuaterlyToWeeklyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Quaterly partitioned to Weekly partitioned with usage test is disabled...");
      return;

			// TestConversionWithUsage(CycleType.QUATERLY, CycleType.WEEKLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestMonthlyToQuaterlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Monthly to Quaterly with usage test is disabled...");
      return;
      
      // TestConversionWithUsage(CycleType.MONTHLY, CycleType.QUATERLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestMonthlyToSemiMonthlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Monthly to Semi Monthly with usage test is disabled...");
      return;
      
      // TestConversionWithUsage(CycleType.MONTHLY, CycleType.SEMIMONTHLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestMonthlyToWeeklyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Monthly partitioned to Weekly partitioned with usage test is disabled...");
      return;

			// TestConversionWithUsage(CycleType.MONTHLY, CycleType.WEEKLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestSemiMonthlyToQuaterlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Semi Monthly to Quaterly with usage test is disabled...");
      return;

			// TestConversionWithUsage(CycleType.SEMIMONTHLY, CycleType.QUATERLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestSemiMonthlyToMonthlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Semi Monthly to Monthly with usage test is disabled...");
      return;
      
      // TestConversionWithUsage(CycleType.SEMIMONTHLY, CycleType.MONTHLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestSemiMonthlyToWeeklyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Semi-monthly partitioned to Weekly partitioned with usage test is disabled...");
      return;

			// TestConversionWithUsage(CycleType.SEMIMONTHLY, CycleType.WEEKLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestWeeklyToQuaterlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Weekly partitioned to Quaterly partitioned with usage test is disabled...");
      return;

			// TestConversionWithUsage(CycleType.WEEKLY, CycleType.QUATERLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestWeeklyToMonthlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Weekly partitioned to Monthly partitioned with usage test is disabled...");
      return;
      
      // TestConversionWithUsage(CycleType.WEEKLY, CycleType.MONTHLY);
		}

		/// <summary>
		/// 
		/// </summary>
		[Test]
		public void TestWeeklyToSemiMonthlyWithUsageConversion()
		{
      TestLibrary.Trace("\n--------------------------------------------\n");
      TestLibrary.Trace("Weekly partitioned to Semi-monthly partitioned with usage test is disabled...");
      return;

			// TestConversionWithUsage(CycleType.WEEKLY, CycleType.SEMIMONTHLY);
		}

		// Constructor.
		public PartitionTests()
		{
			// Get netmeter database name.
			ConnectionInfo ciDb = new ConnectionInfo("NetMeter");
			mNetMeterName = ciDb.Catalog;

			// Remember current date and time.
			MetraTech.MetraTime.Reset();
			mCurrentDate = MetraTech.MetraTime.Now;

			// Determine if pipeline is running.
			PipelineManager pm = new PipelineManager();
			mPipelineWasRunning = pm.IsRunning;

      // Used for performance tracking.
 			QueryPerformanceFrequency(out mFrequency);
		}

		/// <summary>
		/// Save current state of affairs.
		/// </summary>
		[TestFixtureSetUp]
		public void InitTests()
		{
      /* Uncomment these line if you wish to run on weekend only
       * 
			 * Determine if we need to run the tests. By default, partition tests
			 * will only run on Staurday and Sunday.
			    DateTime dt = DateTime.Now;
			    if ((dt.DayOfWeek != DayOfWeek.Sunday && dt.DayOfWeek != DayOfWeek.Saturday))
			    {
				    TestLibrary.Trace("\n--------------------------------------------\nPartition tests are disabled Monday through Friday...");
				    return;
			    }	
       */

      // Check if running on Oracle.
      ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
      if (connInfo.DatabaseType == DBType.Oracle)
      {
          TestLibrary.Trace("\n--------------------------------------------\nPartition tests do not support Oracle...");
          return;
      }

      // Run the partition tests.
      TestLibrary.Trace("\n--------------------------------------------\nSetup Partition Tests...");

      // Need to restart SQL server to make sure nobody holds
      // any connection to the NetMeter database.
      TestLibrary.StopPipeline();
      TestLibrary.RestartWebServer();
      RestartSQLServer();

			// Restore configuration file
      if (mRestoreOnInit)
          RestoreUsageServerConfigurationFile();

			// Is partition support enabled?
			if (IsPartitionSupportEnabled())
        TestLibrary.Trace("Partitioning is already enabled.");

			// Determine where we can backup our files.
			XmlNodeList nodeList = GetPartitionPaths();
			if (nodeList.Count > 0)
			{
				// Make sure the path exists.
				string path = nodeList[0].InnerText;
				int index = path.IndexOf(':');
				if (index != -1)
					mBackupPath = String.Format(@"{0}:\{1}\", path.Substring(0, index), mBackupFolderName);
			}
			// else use hardcoded default.
			TestLibrary.Trace("Using '" + mBackupPath + "' backup folder.");

			// Restore database.
			if (mRestoreOnInit)
				RestoreNetMeterDatabase();

			// Backup configuration file
			BackupUsageServerConfigurationFile();

			// Backup database.
      System.Data.SqlClient.SqlConnection.ClearAllPools();
			BackupNetMeterDatabase();

			// Don't bother running other tests if this fails to initialize.
			// No sense in reporting that tests fails if the partition test framework
			// is not properly initialized.
			mInitialized = true;
		}
 
		/// <summary>
		/// Restore system to state prior the test run.
		/// </summary>
		[TestFixtureTearDown] 
		public void UninitTests()
		{
			if (!mInitialized)
				return;

			TestLibrary.Trace("Tear Down Partition Tests...");

			try
			{
				// Restore database.
				RestoreNetMeterDatabase();

				// Delete the backup path if preset.
				if (Directory.Exists(mBackupPath)) 
					Directory.Delete(mBackupPath, true);

				// Delete configuration file backup.
				MTXmlDocument doc = new MTXmlDocument();
				string backup = doc.GetConfigPath() + mBackedUpConfigFile;
				if (File.Exists(backup))
					File.Delete(backup);
			}
			finally
			{
				// Make sure the pipeline is in the mode we found it in.
				if (mPipelineWasRunning)
					TestLibrary.StartPipeline();
				// Error on side of caution. Do not want to stop pipeline if it was actually running.
				// else TestLibrary.StopPipeline();

        // Reset metratime to what it was before the tests started.
        MetraTech.MetraTime.Reset();
			}
		}

		//-----
		// Supporting Methods
		//-----

		//
		private void TestNonPartitionedToPartitioned(CycleType type, bool SkipTrace)
		{
			// Check if initialized
			if (!mInitialized)
				return;

			// Trace which test is running.
			if (!SkipTrace)
				TestLibrary.Trace("\n--------------------------------------------\nRunning " + CycleTypeToString(type) + " test...");

			// Restore database.
			RestoreNetMeterDatabase();

			// Enable partitioning for quaterly schedule.
			EnablePartitionSupport(type);

			// Move time forward by some to make things a little more interesting.
      if (type == CycleType.WEEKLY)
        ChangeMetraTimeAddMonths(2);
      else
    	  ChangeMetraTimeAddMonths(4);

			// Sync and Create partititons.
			UsmSyncAndCreate();

			// Validate partitions.
			TestLibrary.Trace("Validating partitions...");
			ValidatePartitionsForType(type);
		}

		private void TestNonPartitionedWithUsageToPartitioned(CycleType type)
		{
			// Check if initialized
			if (!mInitialized)
				return;

			// Trace which test is running.
			TestLibrary.Trace("\n--------------------------------------------\nRunning " + CycleTypeToString(type) + " with usage test...");

			// Restore database.
			RestoreNetMeterDatabase();

      // Move time forward, weekly is different because
      // if the number is two large we create too made databases.
      if (type == CycleType.WEEKLY)
          ChangeMetraTimeAddMonths(2);
      else
          ChangeMetraTimeAddMonths(6);

			// Sync and create new intervals.
			UsmSyncAndCreate();

			// Make sure the pipeline is running.
			TestLibrary.StartPipeline();

			// Meter some usage (audiconf)
			int NumberOfSessions = 1;
			TestLibrary.Trace("Metering Audio Conf usage...");
			string accountName = FindFirstAudioConfSubscribedAccount();
			Assert.IsTrue(accountName != null);
			string transactionId = MeterAudioConfUsageSynchronous(accountName, NumberOfSessions);

			// Enable partitioning for quaterly schedule.
			EnablePartitionSupport(type);

			// Sync and create new partititons.
			UsmSyncAndCreate();

			// Validate partitions.
			TestLibrary.Trace("Validating partitions...");
			ValidatePartitionsForType(type);

			// Validate usage made it to correct partitions.
			TestLibrary.Trace("Validating metered data...");
			ValidateAudioConfUsageData(NumberOfSessions, transactionId);
		}

		private void TestConversionWithUsage(CycleType fromType, CycleType toType)
		{
			// Check if initialized
			if (!mInitialized)
				return;

			// Trace which test is running.
			TestLibrary.Trace("\n--------------------------------------------\nRunning conversion from " + CycleTypeToString(fromType) + " to " + CycleTypeToString(toType) + " with usage test...");

			// First setup system with starting partition type.
			TestNonPartitionedToPartitioned(fromType, true);

			// Move time forward by some months.
      if (toType == CycleType.WEEKLY)
          ChangeMetraTimeAddMonths(4);
      else
			    ChangeMetraTimeAddMonths(8);

			// Sync and create new intervals.
			UsmSyncAndCreate();

			// Make sure the pipeline is running.
			TestLibrary.StartPipeline();

			// Meter usage before conversion.
			int NumberOfSessions = 10;	// Meter 10 different sessions
			TestLibrary.Trace("Metering Audio Conf usage before conversion...");
			string accountName = FindFirstAudioConfSubscribedAccount();
			Assert.IsTrue(accountName != null);
			string transactionId = MeterAudioConfUsageSynchronous(accountName, NumberOfSessions);

			// Enable partitioning for quaterly schedule.
			EnablePartitionSupport(toType);

			// Sync and create new partititons.
			UsmSyncAndCreate();

			// Meter usage after conversion
			int postNumberOfSessions = 15;
			TestLibrary.Trace("Metering Audio Conf usage after conversion...");
			string postTransactionId = MeterAudioConfUsageSynchronous(accountName, postNumberOfSessions);

			// Validate partitions.
			TestLibrary.Trace("Validating partitions...");
			ValidatePartitionsForType(toType);

			// Validate usage made it to correct partitions.
			TestLibrary.Trace("Validating data metered prior to conversion...");
			ValidateAudioConfUsageData(NumberOfSessions, transactionId);

			TestLibrary.Trace("Validating data metered after conversion...");
			ValidateAudioConfUsageData(postNumberOfSessions, postTransactionId);
		}

		// Backup and restore UsageServer configuration file.
		private void BackupUsageServerConfigurationFile()
		{
			MTXmlDocument doc = new MTXmlDocument();

			// Only create a backup if one does not exist.
			string backup = doc.GetConfigPath() + mBackedUpConfigFile;
			if (!File.Exists(backup))
			{
				doc.LoadConfigFile(mUsageServerConfigFile);
				doc.SaveConfigFile(mBackedUpConfigFile);
			}
		}
		private void RestoreUsageServerConfigurationFile()
		{
			TestLibrary.Trace("Restoring usage server configuration file...");

			MTXmlDocument doc = new MTXmlDocument();
			string backup = doc.GetConfigPath() + mBackedUpConfigFile;
			if (File.Exists(backup))
			{
				doc.LoadConfigFile(mBackedUpConfigFile);
				doc.SaveConfigFile(mUsageServerConfigFile);
			}
		}
		
		// Backup and restore the NetMeter database
		// For this we aqssume that we start with a non-patitioned database.
		private void BackupNetMeterDatabase()
		{
			TestLibrary.Trace("Backing up databases...");

			// Create the backup path if not preset.
			if (!Directory.Exists(mBackupPath))
				Directory.CreateDirectory(mBackupPath);

			// Run backup sql.
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				// Backup individial partitioned databases.
				string sqlBackupPartitions = String.Empty;
				ArrayList partitions = GetPartitionsList(conn);
				foreach (string name in partitions)
				{
					string PartitionBackupFile = mBackupPath + name + "_PT.bak";
					if (!File.Exists(PartitionBackupFile))
					{
						sqlBackupPartitions += "if exists (SELECT * FROM master..sysdatabases where name='" + name + "') BEGIN backup database " + name + " to disk='" +
							PartitionBackupFile + "' with init,skip END ";
					}
				}

				// Check if backup already exits.
				string sqlNetMeterBackup = String.Empty;
				string NetMeterBackupFile = mBackupPath + mNetMeterName + "_PT.bak";
				if (!File.Exists(NetMeterBackupFile))
				{
					TestLibrary.Trace("Backing up " + mNetMeterName + " database...");
					sqlNetMeterBackup = "backup database " + mNetMeterName + " to disk='" +
						NetMeterBackupFile + "' with init,skip";
				}
				else
					TestLibrary.Trace(mNetMeterName + " database backup already exists...");

				// Execute.
                if (sqlBackupPartitions.Length > 0 || sqlNetMeterBackup.Length > 0)
                {
                    if (sqlBackupPartitions.Length > 0)
                        TestLibrary.Trace("Backing up partition databases...");

                    string sqlExecute = "BEGIN " + sqlBackupPartitions + " " + sqlNetMeterBackup + " END";
                    using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(sqlExecute))
                    {
                        stmt.ExecuteNonQuery();
                    }
                }
			}
		}

		private ArrayList GetPartitionsList(IMTConnection conn)
		{
			// Get list of existing partition names.
			ArrayList partitions = new ArrayList();
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_PARTITION_LIST__"))
            {
                stmt.AddParam("%%DATABASE_NAME%%", mNetMeterName, true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    string name;
                    while (reader.Read())
                    {
                        name = reader.GetString("partition_name");
                        partitions.Add(name);
                    }
                }
            }

			return partitions;
		}

		private void RestoreNetMeterDatabase()
		{
      // Restore Netmeter backup.
			string NetMeterBackupFile = mBackupPath + mNetMeterName + "_PT.bak";
			if (!File.Exists(NetMeterBackupFile))
				return;

      // Reset metratime.
      MetraTech.MetraTime.Reset();

			// Stop pipeline...
      // Need to restart SQL server to make sure nobody holds
      // any connection to the NetMeter database.
      TestLibrary.StopPipeline();
      TestLibrary.RestartWebServer();
			RestartSQLServer();

			// Connect to master database.
			TestLibrary.Trace("Restoring databases...");
			ConnectionInfo ciMasterDb = ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");
			ciMasterDb.Catalog = "Master";
			ciMasterDb.UserName = "sa";
			ciMasterDb.Password = "MetraTech1"; // xxx don't like hardcoding passwords...
			using (IMTConnection conn = ConnectionManager.CreateConnection(ciMasterDb))
			{
				// Get list of existing partition names.
				ArrayList partitions = GetPartitionsList(conn);

				// Drop existing partion databases.
				string sqlDropPartitions = String.Empty;
				foreach (string name in partitions)
					sqlDropPartitions += "if EXISTS (SELECT * FROM master..sysdatabases where name='" + name + "') BEGIN drop database " + name + " END ";

				string RestoreNetMeter = "use master restore database " + mNetMeterName + " from disk='" + NetMeterBackupFile + "' with replace";

				// Execute the restore SQL.
				// Note we're changing the one of the database as well.
				TestLibrary.Trace("Restoring " + mNetMeterName + " database...");
				string sqlExecute = "BEGIN " + RestoreNetMeter + " use " + mNetMeterName + " exec sp_changedbowner 'nmdbo' " + sqlDropPartitions + " END";
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(sqlExecute))
                {
                    stmt.ExecuteNonQuery();
                }

				// Restore original partition databases.
				// Get partitions list from restored NetMeter database.
				partitions = GetPartitionsList(conn);
				if (partitions.Count > 0)
				{
					string sqlRestorePartitions = String.Empty;
					string sqlChangePartitionOwner = String.Empty;
					foreach (string name in partitions)
					{
						string PartitionBackupFile = mBackupPath + name + "_PT.bak";
						if (File.Exists(PartitionBackupFile))
						{
							sqlRestorePartitions += " restore database " + name + " from disk='" + PartitionBackupFile + "' with replace";
							sqlChangePartitionOwner += " use " + name + " exec sp_changedbowner 'nmdbo'";
						}
					}

					// Restore partitions.
					TestLibrary.Trace("Restoring partitions...");
          if (sqlRestorePartitions.Length > 0)
          {
              using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("BEGIN " + sqlRestorePartitions + " END"))
              {
                  stmt.ExecuteNonQuery();
              }

              // Set partition owner.
              TestLibrary.Trace("Changing owner for all partitions to 'nmdbo'...");
              using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("BEGIN " + sqlChangePartitionOwner + " END"))
              {
                  stmt.ExecuteNonQuery();
              }
          }
          else
              Assert.Fail("Failed to find partitions to restore...");
				}
			}

      // Restore the configuration file to make sure that usm create
      // keeps the database partitioned correctly.
      RestoreUsageServerConfigurationFile();

			// Reinitialize existing partition map.
			InitExistingPartitionLookupMap();
      //Alex. Attemt to eliminate subsequent failures.
      System.Data.SqlClient.SqlConnection.ClearAllPools();
		}

		// Determine if partition support is enabled.
		private bool IsPartitionSupportEnabled()
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.LoadConfigFile(mUsageServerConfigFile);
			XmlNode node = doc.SelectSingleNode("//Partitions/Enable");
			return String.Compare(node.InnerText, "true", true) == 0 ? true : false;
		}

		// Modify partition configuration file.
		// Storage paths must be configured manually.
		private void EnablePartitionSupport(CycleType type)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.LoadConfigFile(mUsageServerConfigFile);

			// Enable or disable partitioning.
			XmlNode node = doc.SelectSingleNode("//Partitions/Enable");
			MTXmlDocument.SetNodeValue(node, "True");

			// Set the partition cycle.
			string NewType = CycleTypeToString(type);
			node = doc.SelectSingleNode("//Partitions/Type");
			TestLibrary.Trace("Changing partition type from " + node.InnerText + " to " + NewType);
			MTXmlDocument.SetNodeValue(node, CycleTypeToString(type));

			// For testing purposes if enabled and storage is not specified, then specify.
			XmlNodeList nodeList;
			nodeList = doc.SelectNodes("//Partitions/StoragePaths/Path");
			if (nodeList.Count > 0)
			{
				// Make sure the path exists.
				foreach (XmlNode nodePath in nodeList)
				{
					string path = nodePath.InnerText;
					if (!Directory.Exists(path)) 
						Directory.CreateDirectory(path);
				}
			}
			else
			{
				// Add default path.
				node = doc.SelectSingleNode("//Partitions/StoragePaths");
				XmlNode nodePath = doc.CreateNode(XmlNodeType.Element, "Path", null);
				nodePath.InnerText= mDefaultPartitionPath;
				node.AppendChild(nodePath);

				// Create the path if not preset.
				if (!Directory.Exists(mDefaultPartitionPath)) 
					Directory.CreateDirectory(mDefaultPartitionPath);
			}

			// Save changes.
			doc.SaveConfigFile(mUsageServerConfigFile);
		}

		// Validate partitions for a specific type
		private void ValidatePartitionsForType(CycleType type)
		{
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				// 1. Entry modified correctly in t_usage_server
				ValidateUsageServerTable(conn, type);

				// 2. Correct entries added to t_partition and t_partition_interval_map tables
				ValidatePartitionTables(conn, type);

				// 3. N_default database is created and partition databses are
				// created for open usage intervals. This function assumes
				// that the t_partition table is already validated. Hence,
				// ValidatePartitionTables must be executed first.
				ValidateDatabaseCreation(conn, type);
			}
		}

        private void InitExistingPartitionLookupMap()
        {
            mPartitions.Clear();
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_PARTITION_DB_NAME_LIST__"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                            mPartitions.Add(reader.GetString("partition_name"), true);
                    }
                }
                // Special case: sometimes the first partion start date is the start date of the previous default partition
                // The previous default partition start date is passed in. This happens for partital partitions.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_PARTIAL_PARTITION_STARTDATE__"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            mPartialPartitionStartDate = reader.GetDateTime("dt_start");
                            TestLibrary.Trace("Default partition start date: " + mPartialPartitionStartDate);
                        }
                    }
                }
            }
        }

    // Calculate # of months between current date and MetraTime date.
    private int GetSessionsPerMonth(int NumberOfSessions)
    {
      DateTime now = MetraTech.MetraTime.Now;
      int months = now.Month - mCurrentDate.Month + (12 * (now.Year - mCurrentDate.Year)) + 1; // +1 for curent month.
      double dSessionsPerMonth = ((double)NumberOfSessions) / months;
      int SessionsPerMonth = (int)dSessionsPerMonth;
      if (dSessionsPerMonth > SessionsPerMonth)
        SessionsPerMonth += 1;

      return SessionsPerMonth;
    }

		// Validate that the metered audio conf usage data made it to the correct partition table.
		private void ValidateAudioConfUsageData(int NumberOfSessions, string TransactionID)
		{
			//
			// Loop through all the metered data and determine if it made it to correct database.
			//
		
			// Add audio conf calls to set.
      int SessionsPerMonth = GetSessionsPerMonth(NumberOfSessions);
      DateTime dtStart = mCurrentDate;
      for (int h = 0, SessionsRemaining = NumberOfSessions; h < NumberOfSessions;
           h += SessionsPerMonth, SessionsRemaining -= SessionsPerMonth)
			{
				// How many sessions were metered this month.
        int SessionsThisMonth = SessionsPerMonth;
        if (SessionsRemaining < SessionsPerMonth)
					SessionsThisMonth = SessionsRemaining;

				//
				using (IMTConnection conn = ConnectionManager.CreateConnection())
				{
					// Validate that the data is in the partitioned database.
					int ActualCount = CheckAudioConfUsageTable(conn, "t_pv_audioconfcall", "c_ScheduledStartTime", dtStart, "c_specialinfo", TransactionID);
					if (ActualCount == 0)
						Assert.Fail("Usage data is missing from t_pv_audioconfcall table after partitioning.");
					Assert.AreEqual(SessionsThisMonth, ActualCount, "Number of rows in t_pv_audioconfcall table does not match expected count.");

					ActualCount = CheckAudioConfUsageTable(conn, "t_pv_audioconfconnection", "c_ConnectTime", dtStart, "c_specialinfo", TransactionID);
					if (ActualCount == 0)
						Assert.Fail("Usage data is missing from t_pv_audioconfconnection table after partitioning.");
					Assert.AreEqual(SessionsThisMonth * mNumAudioConfConnectionSvc, ActualCount, "Number of rows in t_pv_audioconfconnection table does not match expected count.");
				
					ActualCount = CheckAudioConfUsageTable(conn, "t_pv_audioconffeature", "c_StartTime", dtStart, "c_transactionid", TransactionID);
					if (ActualCount == 0)
						Assert.Fail("Usage data is missing from t_pv_audioconffeature table after partitioning.");
					Assert.AreEqual(SessionsThisMonth * mNumAudioConfFeatureSvc, ActualCount, "Number of rows in t_pv_audioconffeature table does not match expected count.");

					//xxx Just checking expected counts ... should we check other attribs?
				}

				// Change the start date.
        dtStart = dtStart.AddMonths(1);
			}
		}

		private int CheckAudioConfUsageTable(IMTConnection conn, string pvTableName, string StartDateCol, DateTime dtStart, string TransactionIDCol,  string TransactionID)
		{
			// Validate the entries in t_partition table are correct.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_PARTITIONED_USAGE_COUNT__"))
            {
                stmt.AddParam("%%PV_TABLE_NAME%%", pvTableName, true);
                stmt.AddParam("%%DATA_DATE%%", dtStart, true);
                stmt.AddParam("%%TRANSACTION_ID_COLUMN%%", TransactionIDCol, true);
                stmt.AddParam("%%TRANSACTION_ID%%", TransactionID.Substring(0, mMaxTransactionColSize), true);
                stmt.AddParam("%%DATE_COL_NAME%%", StartDateCol, true);
                stmt.AddParam("%%START_DATE%%", MetraTime.FormatAsODBC(dtStart), false);

                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return reader.GetInt32("row_count");
                    }
                }
            }
			return 0;
		}

		// Convert cycle type to string.
		private string CycleTypeToString(CycleType type)
		{
			string cycletype = String.Empty;
			switch(type)
			{
				case CycleType.WEEKLY:
					cycletype = "Weekly";
					break;
				case CycleType.MONTHLY:
					cycletype = "Monthly";
					break;
				case CycleType.SEMIMONTHLY:
					cycletype = "Semi-Monthly";
					break;
				case CycleType.QUATERLY:
					cycletype = "Quarterly";
					break;
				default:
					Assert.Fail("Unknow cycle type");
					break;
			}
			return cycletype;
		}

		//
		private int GetCycle(IMTConnection conn, CycleType type)
		{
			int Cycle = 0;
			string CycleTypeName = CycleTypeToString(type);
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_PARTITION_CYCLE__"))
            {
                stmt.AddParam("%%CYCLE_TYPE_NAME%%", CycleTypeName, true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        // Determine expected cycle...
                        Cycle = reader.GetInt32("cycle");
                    }
                    else
                        Assert.Fail("Partition type '%s' not supported.", CycleTypeName);
                }
            }

			return Cycle;
		}

		// Entry modified in correctly in t_usage_server
        private void ValidateUsageServerTable(IMTConnection conn, CycleType type)
        {
            // Read partition info from databse.
            int ExpectedCycle = GetCycle(conn, type);

            // Read partition info from databse.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_USAGE_SERVER_TABLE_INFO__"))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        bool Enabled = reader.GetBoolean("b_partitioning_enabled");
                        if (!Enabled)
                            Assert.Fail("Failed to enable partitioning");

                        string PartitionType = reader.GetString("partition_type");
                        string strType = CycleTypeToString(type);
                        if (String.Compare(PartitionType, strType, true) != 0)
                            Assert.Fail("Failed to set partition type to '" + strType + "'");

                        int Cycle = reader.GetInt32("partition_cycle");
                        Assert.AreEqual(ExpectedCycle, Cycle, "Cycle value does not match expected value.");
                    }
                    else
                        Assert.Fail("No rows found in t_usage_server table!");
                }
            }
        }

		// Correct entries added to t_partition and t_partition_interval_map tables
        private void ValidatePartitionTables(IMTConnection conn, CycleType type)
        {
            // Read partition info from databse.
            int CycleId = GetCycle(conn, type);

            // Validate the entries in t_partition table are correct.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__VALIDATE_PARTITION_TABLE__"))
            {
                stmt.AddParam("%%CYCLE_ID%%", CycleId, true);
                stmt.AddParam("%%PARTIAL_PARTITION_START_DATE%%", mPartialPartitionStartDate, true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    int nDefaultPartitionCount = 0;
                    while (reader.Read())
                    {
                        string PartitionName = reader.GetString("partition_name");

                        // Check if extra record is the default partititon.
                        // Default partition is not checked by the query code, so it is the only 
                        // information that should be returned.
                        bool DefaultDatabase = reader.GetBoolean("b_default");
                        if (DefaultDatabase)
                        {
                            nDefaultPartitionCount++;
                            continue;
                        }

                        if (nDefaultPartitionCount > 1)
                        {
                            // Too many default partitions
                            Assert.Fail("Unexpected number of default partitions found, partition_name('" + PartitionName + "').");
                        }

                        // Check if partition is in the list of existing partitions.
                        // If it is then partition is expected, otherwise assert an error.
                        if (mPartitions.Contains(PartitionName))
                            continue;

                        // Dump all partitions in the existing partitions list.
                        string Partitions = String.Empty;
                        foreach (string name in mPartitions)
                            Partitions += "\n  " + name;
                        TestLibrary.Trace("Partitions from t_partition table:" + Partitions);

                        // Too many partition records.
                        Assert.Fail("Unexpected partition row found in t_partition table, partition_name('" + PartitionName + "').");
                    }
                }
            }

            // Validate that the entries in t_partition_interval_map table appear to be correct.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__VALIDATE_PARTITION_INTERVAL_MAP_TABLE__"))
            {
                stmt.ExecuteNonQuery();
            }
        }

		// Validate that correct databses exist for current cycle type
		// This function assumes that the t_partition table has already been validated.
        private void ValidateDatabaseCreation(IMTConnection conn, CycleType type)
        {
            // Read partition info from databse.
            // a. Check if correct number of databses is generated.
            // b. Check if the databse listed in table are created.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__VALIDATE_DATABASE_CREATION__"))
            {
                stmt.ExecuteNonQuery();
            }
        }

		// Return all the configured storage paths.
		private XmlNodeList GetPartitionPaths()
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.LoadConfigFile(mUsageServerConfigFile);
			return doc.SelectNodes("//Partitions/StoragePaths/Path");
		}

		// Execute USM sync and create.
		private void UsmSyncAndCreate()
		{
      long startCount, endCount;

      TestLibrary.Trace("Start usm sync and create...");

      // Get start time.
      QueryPerformanceCounter(out startCount);

      // Do work.
      Client usm = new Client();
			ArrayList addedEvents, removedEvents, modifiedEvents;

			TestLibrary.Trace("Running usm sync...");
			usm.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);

			TestLibrary.Trace("Running usm create...");
			usm.CreateUsageIntervals(false);

      // Get end time.
      QueryPerformanceCounter(out endCount);

      TestLibrary.Trace("Done usm sync and create...");
      TestLibrary.Trace("Usm sync and create execution time: {0} ms", (int)((1000.0 * (endCount - startCount)) / mFrequency));

      // Reinitialize existing partition map.
      InitExistingPartitionLookupMap();
		}

    // Add a number of months to current date (metratime).
    private void ChangeMetraTimeAddMonths(int number)
    {
      DateTime newDateTime = mCurrentDate.AddMonths(number);
      TestLibrary.Trace("Changed MetraTime from " + mCurrentDate.ToString() + " to " + newDateTime.ToString());
      MetraTime.Now = newDateTime;
    }

		// Stops and then starts SQL Server synchronously
		private void RestartSQLServer()
		{
			// Restarts the local SQL Server so that cached connections held by the listener are broken
			using (ServiceController service = new ServiceController("MSSQLServer"))
			{
				if (service.Status == ServiceControllerStatus.Running)
				{
					TestLibrary.Trace("Stopping database...");
					service.Stop();
					service.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromMinutes(1.0));
					Assert.IsTrue(service.Status == ServiceControllerStatus.Stopped, "Could not stop SQL Server!");
				}
						
				// for some reason, the service doesn't always restart the first time
				// loop until it starts
				for (int i = 0; i < 3; i++)
				{
					TestLibrary.Trace("Starting database...");
					service.Start();
					try
					{
						service.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromMinutes(1.0));
						break;
					}
					catch (Exception) { }
				}
				Assert.IsTrue(service.Status == ServiceControllerStatus.Running, "Could not start SQL Server!");
			}

			// For some reason the database is not entirely active at this point,
			// so let's give it some more time.
			System.Threading.Thread.Sleep(15000);
      System.Data.SqlClient.SqlConnection.ClearAllPools();
		}

		// Supported cycle types supported.
		enum CycleType
		{
			WEEKLY,
			MONTHLY,
			SEMIMONTHLY,
			QUATERLY
		};

		private string mNetMeterName;
		private const string mUsageServerConfigFile = @"UsageServer\usageserver.xml";
		private const string mBackedUpConfigFile = @"UsageServer\usageserver.bak";
		private const string mQueryPath = "Queries\\SmokeTest";
		private const string mBackupFolderName = "PartitionTestsBackup";
		private string mBackupPath = @"c:\"+mBackupFolderName+@"\"; // Must end with '\'
		private string mDefaultPartitionPath = @"c:\"+mBackupFolderName+@"\datafiles\01";
		private bool mPipelineWasRunning = false;
		private Hashtable mPartitions = new Hashtable();
		private DateTime mPartialPartitionStartDate;
		private DateTime mCurrentDate;
		private bool mInitialized = false;
    private long mFrequency = 0;

		//-----
		// Audio Conference Metering Helper Methods
		//-----

		private string FindFirstAudioConfSubscribedAccount()
		{
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_AUDIO_CONF_ACCOUNT__"))
                {
                    stmt.AddParam("%%OFFERING%%", "Audio Conferencing Product Offering%", true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                            return reader.GetString("name");
                    }
                }

				return null;
			}
		}

		private string MeterAudioConfUsageSynchronous(string accountName, int NumberOfSessions)
		{
			IMeter mMeterSdk = new Meter();
			mMeterSdk.Startup();
			mMeterSdk.AddServer(0, "localhost", PortNumber.DEFAULT_HTTP_PORT, 0, "", "");
      IBatch batch = null;

			try
			{
				// Create batch
				batch = mMeterSdk.CreateBatch();
				batch.NameSpace = "MT        ";
				batch.Name = "1";
				batch.ExpectedCount = 1;
				batch.SourceCreationDate = DateTime.Now;
				batch.SequenceNumber = DateTime.Now.ToFileTime().ToString();

				try 
				{
					batch.Save();
				}
				catch(Exception e) 
				{
					Assert.Fail(String.Format("Unexpected Batch.Save() failure message: {0}", 
						e.Message));
				}

				// Create session set.
				ISessionSet sessionSet = batch.CreateSessionSet();

				//-------------------------------
				// NOTE: SessionSet properties must be set before any of the set properties.
				//-------------------------------

				// Begin transaction.
        string transactionId = null;
				IMTTransaction transaction = new CMTTransaction();
				transaction.Begin("PartitionTests::MeteringAudioConfUsage", 600 * 1000);
        try
        {
				  // Get session context.
				  Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
				  Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();

				  // Get transaction id.
				  IMTWhereaboutsManager whereAboutsMan = new CMTWhereaboutsManager();
				  transactionId = transaction.Export(whereAboutsMan.GetLocalWhereabouts());

				  // Set session properties.
				  sessionSet.SetProperties(null, transactionId, sessionContext.ToXML(), null, null, null);

				  // Create and set compound session properties for audi conf.
				  CreateCompoundSession(sessionSet, accountName, NumberOfSessions, transactionId);

  				// Meter the session set and commit transaction.
					sessionSet.Close();
        
          // Commit the transaction.
          transaction.Commit();
        }
				catch(Exception e) 
				{
          TestLibrary.Trace("Failed to meter usage: " + e.Message);
          transaction.Rollback();
					Assert.Fail(String.Format("Unexpected MeterCompoundSession failure message: {0}", 
						e.Message));
				}

				// Shutdown the sdk.
				mMeterSdk.Shutdown();

				// Return transaction id
				return transactionId;
			}
			finally
			{
        if (batch != null)
          Marshal.ReleaseComObject(batch);
				Marshal.ReleaseComObject(mMeterSdk);
			}
		}

		// Populate session set with audio conf compound.
		private void CreateCompoundSession(ISessionSet sessionSet, string accountName, int NumberOfSessions, string TransactionID) 
		{
			// We're using transaction id as a unique identifier.
			// 1. We don't need the entire transaction ID.
			// 2. We store it in fields that cannot hold more than mMaxTransactionColSize bytes at this time.
			// So, truncate the transaction ID.
			TransactionID = TransactionID.Substring(0, mMaxTransactionColSize);

			// Spread all the session on a monthly schedule; add 1 month to each date.
      // Add audio conf calls to set.
      int SessionsPerMonth = GetSessionsPerMonth(NumberOfSessions);
      DateTime dtStart = mCurrentDate;
			int nSessionCounter = 0;
			for (int h = 0; h < NumberOfSessions; h++)
			{
				ISession session = sessionSet.CreateSession(audioConfCallSvc);
				session.RequestResponse = true; // Synchronous 
				InitializeSession(session, audioConfCallSvc, accountName, dtStart, TransactionID);

				for (int i = 0; i < mNumAudioConfConnectionSvc; i++)
				{
					ISession child = session.CreateChildSession(audioConfConnectionSvc);
					InitializeSession(child, audioConfConnectionSvc, accountName, dtStart, TransactionID);
				}

				for (int i = 0; i < mNumAudioConfFeatureSvc; i++)
				{
					ISession child = session.CreateChildSession(audioConfFeatureSvc);
					InitializeSession(child, audioConfFeatureSvc, accountName, dtStart, TransactionID);
				}

				// Change the start date.
				nSessionCounter++;
        if (nSessionCounter >= SessionsPerMonth)
				{
					nSessionCounter = 0;
          dtStart = dtStart.AddMonths(1);
				}
			}
		}

		private void InitializeSession(ISession session, string serviceName, string accountName, DateTime dtStart, string TransactionID) 
		{
			ArrayList propertyDataList = new ArrayList();
			PropertyData pd;

			string ScheduledStartTime = dtStart.ToString(strDateFormat);

			switch(serviceName) 
			{
				case (audioConfCallSvc) : 
				{
					pd = new PropertyData();
					pd.Name = "ConferenceID";
					pd.Value = "129418410328184";
					pd.Type = (int)DataType.MTC_DT_WCHAR;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "Payer";
					pd.Value = accountName;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "AccountingCode";
					pd.Value = "DM13";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ConferenceName";
					pd.Value = "test";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ConferenceSubject";
					pd.Value = "Tradeshow meeting with partners";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "OrganizationName";
					pd.Value = "MetraTech Corp.";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "SpecialInfo";
					pd.Value = TransactionID;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "SchedulerComments";
					pd.Value = "Second conference for tradeshow";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ScheduledConnections";
					pd.Value = "1";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ScheduledStartTime";
					pd.Value = ScheduledStartTime;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ScheduledTimeGMTOffset";
					pd.Value = "5";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ScheduledDuration";
					pd.Value = ScheduledDuration.ToString();
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "CancelledFlag";
					pd.Value = "N";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "CancellationTime";
					pd.Value = ScheduledStartTime;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ServiceLevel";
					pd.Value = "Standard";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "TerminationReason";
					pd.Value = "Normal";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "SystemName";
					pd.Value = "Bridge1";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "SalesPersonID";
					pd.Value = "Amy";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "OperatorID";
					pd.Value = "Philip";
					propertyDataList.Add(pd);

					session.CreateSessionStream
						(propertyDataList.ToArray(typeof(PropertyData)) as PropertyData[]);

					break;
				}
				case (audioConfConnectionSvc) : 
				{
					pd = new PropertyData();
					pd.Name = "ConferenceID";
					pd.Value = "129418410328184";
					pd.Type = (int)DataType.MTC_DT_WCHAR;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "Payer";
					pd.Value = accountName;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "UserBilled";
					pd.Value = "N";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "UserName";
					pd.Value = accountName;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "UserRole";
					pd.Value = "CSR";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "OrganizationName";
					pd.Value = "MetraTech Corp.";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "userphonenumber";
					pd.Value = "781 398 2242";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "specialinfo";
					pd.Value = TransactionID;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "CallType";
					pd.Value = "Dial-In";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "transport";
					pd.Value = "Toll";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "Mode";
					pd.Value = "Direct-Dialed";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ConnectTime";
					pd.Value = ScheduledStartTime;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "EnteredConferenceTime";
					pd.Value = ScheduledStartTime;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "DisconnectTime";
					pd.Value = EndTime(dtStart);
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ExitedConferenceTime";
					pd.Value = EndTime(dtStart);
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "Transferred";
					pd.Value = "N";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "TerminationReason";
					pd.Value = "Normal";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ISDNDisconnectCause";
					pd.Value = "0";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "TrunkNumber";
					pd.Value = "10";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "LineNumber";
					pd.Value = "35";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "DNISDigits";
					pd.Value = "781 398 2000";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "ANIDigits";
					pd.Value = "781 398 2242";
					propertyDataList.Add(pd);

					session.CreateSessionStream
						(propertyDataList.ToArray(typeof(PropertyData)) as PropertyData[]);

					break;
				}
				case (audioConfFeatureSvc) : 
				{
					pd = new PropertyData();
					pd.Name = "Payer";
					pd.Value = accountName;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "FeatureType";
					pd.Value = "QA";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "Metric";
					pd.Value = "33.556122";
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "StartTime";
					pd.Value = ScheduledStartTime;
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "EndTime";
					pd.Value = EndTime(dtStart);
					propertyDataList.Add(pd);

					pd = new PropertyData();
					pd.Name = "transactionid";
					pd.Value = TransactionID; // Unique value <= 40 chars
					propertyDataList.Add(pd);

					session.CreateSessionStream
						(propertyDataList.ToArray(typeof(PropertyData)) as PropertyData[]);

					break;
				}
				default:
				{
					break;
				}
			}
		}

		private string EndTime(DateTime dtStart)
		{
			Random mRandomGenerator = new Random(DateTime.Now.Millisecond);
			int nDuration = mRandomGenerator.Next(1, (ScheduledDuration + (ScheduledDuration / 2)));
			DateTime dtEnd = dtStart.AddMinutes(nDuration);
			return dtEnd.ToString(strDateFormat);
		}

		const string audioConfCallSvc = "metratech.com/audioconfcall";
		const string audioConfConnectionSvc = "metratech.com/audioconfconnection";
		const string audioConfFeatureSvc = "metratech.com/audioconffeature";
		const int mMaxTransactionColSize = 30;
		const int mNumAudioConfConnectionSvc = 20;
		const int mNumAudioConfFeatureSvc = 7;
		const int ScheduledDuration = 4;
		const string strDateFormat = "yyyy-MM-ddTHH:mm:ssZ";
	}
}
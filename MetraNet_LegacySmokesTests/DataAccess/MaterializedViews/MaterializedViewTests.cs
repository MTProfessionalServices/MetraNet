using System;
using System.Collections;
using System.Runtime.InteropServices;
using NUnit.Framework;

namespace MetraTech.DataAccess.MaterializedViews.Test
{
	using MetraTech.Pipeline;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.MaterializedViews;
	using MetraTech.Interop.COMMeter;
	using Auth = MetraTech.Interop.MTAuth;
	using MetraTech.Interop.PipelineTransaction;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.DataAccess.MaterializedViews.Test.MaterializedViewTests /assembly:O:\debug\bin\MetraTech.DataAccess.MaterializedViews.Test.dll
	//
  [Category("NoAutoRun")]
  [TestFixture]
	[ComVisible(false)]
	public class MaterializedViewTests 
	{
    [TestFixtureSetUp]
    public void InitTests()
    {
      //xxx TODO: make sure materialized views are enabled.
    }

    [TestFixtureTearDown]
    public void UninitTests()
    {
    }

		/// <summary>
		/// Tests to make sure full update works for a single materialized view.
		/// </summary>
		[Test]
    public void T01TestFullUpdateAllMaterializedViews()
		{
			PipelineManager pm = new PipelineManager();
			bool bPipelinePaused = false;
			try
			{
				Manager mvm = new Manager();
				mvm.Initialize();
				if (mvm.IsMetraViewSupportEnabled)
				{
					// Pause the pipeline.
					if (pm.IsRunning)
					{
						pm.PauseAllProcessing();
						bPipelinePaused = true;
					}

					// Run full update on a single out of the box materialized view.
					mvm.DoFullMaterializedViewUpdateAll();

					//xxx TODO: meter some usage and repeat test.
				
					// Unpause the pipeline.
					if (bPipelinePaused)
					{
						pm.ResumeAllProcessing();
						bPipelinePaused = false;
					}
				}
			}
			catch(Exception e)
			{
				if (bPipelinePaused)
					pm.ResumeAllProcessing();
					
				throw e;
			}
		}

		/// <summary>
		/// Tests to make sure full update works for a single materialized view.
		/// </summary>
		[Test]
    public void T02TestFullUpdateSingleMaterializedView()
		{
			PipelineManager pm = new PipelineManager();
			bool bPipelinePaused = false;
			try
			{
				Manager mvm = new Manager();
				mvm.Initialize();
				if (mvm.IsMetraViewSupportEnabled)
				{
					// Pause the pipeline.
					if (pm.IsRunning)
					{
						pm.PauseAllProcessing();
						bPipelinePaused = true;
					}

					// Run full update on a single out of the box materialized view.
					mvm.DoFullMaterializedViewUpdate("payer_interval");

					// Run full update on a single out of the box materialized view on
					// which other materialized views depend.
					mvm.DoFullMaterializedViewUpdate("payee_session");

					//xxx TODO: meter some usage and repeat test.

					// Unpause the pipeline.
					if (bPipelinePaused)
					{
						pm.ResumeAllProcessing();
						bPipelinePaused = false;
					}
				}
			}
			catch (Exception e)
			{
				if (bPipelinePaused)
					pm.ResumeAllProcessing();

				throw e;
			}
		}

		/// <summary>
		/// Test to make sure that deferred update work on all materialized views configured
		/// in deferred mode.
		/// </summary>
		[Test]
    public void T03TestUpdateAllDeferredMaterializedViews()
		{
			// Run deferred update on out of the box configuration.
			Manager mvm = new Manager();
			mvm.Initialize();
			if (mvm.IsMetraViewSupportEnabled)
				mvm.UpdateAllDeferredMaterializedViews();
		}

		/// <summary>
		/// Tests if we can get insert queries for all MV's given some trigger table names.
		/// </summary>
		[Test]
    public void T04TestInsertQuery()
		{
			Manager mvm = new Manager();
			mvm.Initialize();
			if (mvm.IsMetraViewSupportEnabled)
			{
				// Setup bindings.
				string TempTableName = "FakeTempTableName123";
				mvm.AddInsertBinding("t_acc_usage", TempTableName);
				mvm.AddInsertBinding("t_adjustment_transaction", TempTableName);
				mvm.AddInsertBinding("xyz_abc_123", TempTableName);

				// Prepare trigger list.
				string[] Triggers = new string[2];
				Triggers[0] = "t_acc_usage";
				Triggers[1] = "t_adjustment_transaction";
				string query = mvm.GetMaterializedViewInsertQuery(Triggers);
				Assert.IsTrue(query != null);

				// Check binding was used.
				Assert.IsTrue(query.IndexOf(TempTableName) != -1);

				// Test negavive case
				Triggers = new string[1];
				Triggers[0] = "xyz_abc_123";
				query = mvm.GetMaterializedViewInsertQuery(Triggers);
				Assert.IsTrue(query == null);
			}
		}

		/// <summary>
		/// Tests if we can get update queries for all MV's given some trigger table names.
		/// </summary>
		[Test]
    public void T05TestUpdateQuery()
		{
			Manager mvm = new Manager();
			mvm.Initialize();
			if (mvm.IsMetraViewSupportEnabled)
			{
				// Setup bindings.
				string TempTableName = "FakeTempTableName123";
				mvm.AddInsertBinding("t_acc_usage", TempTableName);
				mvm.AddInsertBinding("t_adjustment_transaction", TempTableName);
				mvm.AddInsertBinding("xyz_abc_123", TempTableName);
				mvm.AddDeleteBinding("t_acc_usage", TempTableName);
				mvm.AddDeleteBinding("t_adjustment_transaction", TempTableName);
				mvm.AddDeleteBinding("xyz_abc_123", TempTableName);

				// Prepare trigger list.
				string[] Triggers = new string[2];
				Triggers[0] = "t_acc_usage";
				Triggers[1] = "t_adjustment_transaction";
				string query = mvm.GetMaterializedViewUpdateQuery(Triggers);
				Assert.IsTrue(query != null);

				// Check binding was used.
				Assert.IsTrue(query.IndexOf(TempTableName) != -1);

				// Test negavive case
				Triggers = new string[1];
				Triggers[0] = "xyz_abc_123";
				query = mvm.GetMaterializedViewUpdateQuery(Triggers);
				Assert.IsTrue(query == null);
			}
		}

		/// <summary>
		/// Tests if we can get delete queries for all MV's given some trigger table names.
		/// </summary>
		[Test]
    public void T06TestBackoutQuery()
		{
			Manager mvm = new Manager();
			mvm.Initialize();
			if (mvm.IsMetraViewSupportEnabled)
			{
				// Setup bindings.
				string TempTableName = "FakeTempTableName123";
				mvm.AddDeleteBinding("t_acc_usage", TempTableName);
				mvm.AddDeleteBinding("t_adjustment_transaction", TempTableName);
				mvm.AddDeleteBinding("xyz_abc_123", TempTableName);

				// Prepare trigger list.
				string[] Triggers = new string[2];
				Triggers[0] = "t_acc_usage";
				Triggers[1] = "t_adjustment_transaction";
				string query = mvm.GetMaterializedViewBackoutQuery(Triggers);
				Assert.IsTrue(query != null);

				// Check binding was used.
				Assert.IsTrue(query.IndexOf(TempTableName) != -1);

				// Test negavive case
				Triggers = new string[1];
				Triggers[0] = "xyz_abc_123";
				query = mvm.GetMaterializedViewBackoutQuery(Triggers);
				Assert.IsTrue(query == null);
			}
		}

        /// <summary>
        /// Test executing MV insert query.
        /// </summary>
        [Test]
    public void T07TestExecuteInsertQuery()
        {
            Manager mvm = new Manager();
            mvm.Initialize();
            if (mvm.IsMetraViewSupportEnabled)
            {
                // Setup bindings.
                string TempTableName = "FakeTempTableName123";
                mvm.AddInsertBinding("t_acc_usage", TempTableName);
                mvm.AddInsertBinding("t_adjustment_transaction", TempTableName);

                // Prepare trigger list.
                string[] Triggers = new string[2];
                Triggers[0] = "t_acc_usage";
                Triggers[1] = "t_adjustment_transaction";
                string query = mvm.GetMaterializedViewInsertQuery(Triggers);
                Assert.IsTrue(query != null);

                // Check binding was used.
                Assert.IsTrue(query.IndexOf(TempTableName) != -1);

                // Execute query
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTStatement stmtNQ = conn.CreateStatement(query))
                    {
                        stmtNQ.ExecuteNonQuery();
                    }
                }
            }
        }

        /// <summary>
        /// Test executing MV update query.
        /// </summary>
        [Test]
        public void T08TestExecuteUpdateQuery()
        {
            Manager mvm = new Manager();
            mvm.Initialize();
            if (mvm.IsMetraViewSupportEnabled)
            {
                // Setup bindings.
                string TempTableName = "FakeTempTableName123";
                mvm.AddInsertBinding("t_acc_usage", TempTableName);
                mvm.AddInsertBinding("t_adjustment_transaction", TempTableName);
                mvm.AddDeleteBinding("t_acc_usage", TempTableName);
                mvm.AddDeleteBinding("t_adjustment_transaction", TempTableName);

                // Prepare trigger list.
                string[] Triggers = new string[2];
                Triggers[0] = "t_acc_usage";
                Triggers[1] = "t_adjustment_transaction";
                string query = mvm.GetMaterializedViewUpdateQuery(Triggers);
                Assert.IsTrue(query != null);

                // Check binding was used.
                Assert.IsTrue(query.IndexOf(TempTableName) != -1);

                // Execute query
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTStatement stmtNQ = conn.CreateStatement(query))
                    {
                        stmtNQ.ExecuteNonQuery();
                    }
                }
            }
        }

        /// <summary>
        /// Tests if we can get delete queries for all MV's given some trigger table names.
        /// Execute the backout query.
        /// </summary>
        [Test]
        public void T09TestExecuteBackoutQuery()
        {
            Manager mvm = new Manager();
            mvm.Initialize();
            if (mvm.IsMetraViewSupportEnabled)
            {
                // Setup bindings.
                string TempTableName = "FakeTempTableName123";
                mvm.AddDeleteBinding("t_acc_usage", TempTableName);
                mvm.AddDeleteBinding("t_adjustment_transaction", TempTableName);

                // Prepare trigger list.
                string[] Triggers = new string[2];
                Triggers[0] = "t_acc_usage";
                Triggers[1] = "t_adjustment_transaction";
                string query = mvm.GetMaterializedViewBackoutQuery(Triggers);
                Assert.IsTrue(query != null);

                // Check binding was used.
                Assert.IsTrue(query.IndexOf(TempTableName) != -1);

                // Execute query
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTStatement stmtNQ = conn.CreateStatement(query))
                    {
                        stmtNQ.ExecuteNonQuery();
                    }
                }
            }
        }

        /// <summary>
        /// Meter Audio Conference usage. This test will exercise all materialized 
        /// views that depend on either t_acc_usage or audi conf call. 
        /// Audio conf materialized view is OFF out of the box.
        /// </summary>
        [Test]
        [Ignore("Failing - Ignore Test")]
        public void T10TestAudioConfMaterializedViewTransactionally()
        {
            string accountName = FindFirstAudioConfSubscribedAccount();
            Assert.IsTrue(accountName != null);
            MeterAudioConfUsageSynchronous(accountName);
        }

		//-----
		// Audio Conference Metering Helper Methods
		//-----

		private string FindFirstAudioConfSubscribedAccount()
		{
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\SmokeTest", "__GET_AUDIO_CONF_ACCOUNT__"))
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

		// Meter Audio Conference usage.
		private void MeterAudioConfUsageSynchronous(string accountName)
		{
			// Initialize SDK.
			IMeter Sdk = new Meter();
      try
      {
        Sdk.Startup();
        Sdk.AddServer(0, "localhost", PortNumber.DEFAULT_HTTP_PORT, 0, "", "");

        // Create batch
        IBatch batch = Sdk.CreateBatch();
        batch.NameSpace = "MT        ";
        batch.Name = "1";
        batch.ExpectedCount = 1;
        batch.SourceCreationDate = DateTime.Now;
        batch.SequenceNumber = DateTime.Now.ToFileTime().ToString();

        try
        {
          batch.Save();
        }
        catch (Exception e)
        {
          Assert.Fail(String.Format("Unexpected Batch.Save() failure message: {0}", e.Message));
        }
        ISessionSet sessionSet = batch.CreateSessionSet();

        //-------------------------------
        // NOTE: SessionSet properties must be set before any of the set properties.
        //-------------------------------

        // Begin transaction.
        IMTTransaction transaction = new CMTTransaction();
        transaction.Begin("MaterializedViewTests::MeteringAudioConfUsage", 600 * 1000);
        try
        {
          // Get session context.
          Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
          Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();

          // Get transaction id.
          IMTWhereaboutsManager whereAboutsMan = new CMTWhereaboutsManager();
          string transactionId = transaction.Export(whereAboutsMan.GetLocalWhereabouts());

          // Set session properties.
          sessionSet.SetProperties(null, transactionId, sessionContext.ToXML(), null, null, null);

          // Create and set compound session properties for audi conf.
          CreateCompoundSession(sessionSet, accountName);

          // Meter the session set and commit transaction.
          sessionSet.Close();
          transaction.Commit();
        }
        catch (Exception e)
        {
          transaction.Rollback();
          Assert.Fail(String.Format("Unexpected MeterCompoundSession failure message: {0}", e.Message));
        }
      }
      finally
      {
        Marshal.ReleaseComObject(Sdk);
      }
		}

		// Populate session set with audio conf compound.
		private void CreateCompoundSession(ISessionSet sessionSet, string accountName) 
		{
			// Add audio conf calls to set.
			for (int h = 0; h < numAudioConfCallSvc; h++)
			{
				ISession session = sessionSet.CreateSession(audioConfCallSvc);
				session.RequestResponse = true; // Synchronous 
				InitializeSession(session, audioConfCallSvc, accountName);

				for (int i = 0; i < numAudioConfConnectionSvc; i++)
				{
					ISession child = session.CreateChildSession(audioConfConnectionSvc);
					InitializeSession(child, audioConfConnectionSvc, accountName);
				}

				for (int i = 0; i < numAudioConfFeatureSvc; i++)
				{
					ISession child = session.CreateChildSession(audioConfFeatureSvc);
					InitializeSession(child, audioConfFeatureSvc, accountName);
				}
			}
		}

		private void InitializeSession(ISession session, string serviceName, string accountName) 
		{
			ArrayList propertyDataList = new ArrayList();
			PropertyData pd;

			DateTime dtStart = MetraTech.MetraTime.Now;
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
					pd.Value = "Auto start";
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
					pd.Value = "Expo update";
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
					pd.Value = ScheduledStartTime; // Unique value <= 40 chars
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
		const int numAudioConfCallSvc = 1;
		const int numAudioConfConnectionSvc = 20;
		const int numAudioConfFeatureSvc = 7;
		const int ScheduledDuration = 4;
		const string strDateFormat = "yyyy-MM-ddTHH:mm:ssZ";
	}
}

// EOF

namespace MetraTech.Pipeline.Test
{
	using System;
	using System.Diagnostics;
	using System.Collections;

	using MetraTech.Test;

	using MetraTech.Interop.COMMeter;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.DMO;
	using MetraTech.Interop.MTProductCatalog;
	using MetraTech.Interop.MTAuth;
	using MetraTech.Interop.MTYAAC;
	using System.Runtime.InteropServices;

	// utility functions for testing aggregate rating
	[ComVisible(false)]
	public class AggregateLibrary
	{

		// setup -
		//  metratime = 06/01/2003 09:00:00
		//  mydbinstall
		//  backup
		//
		//  metratime = 06/01/2003 10:00:00
		//  create accounts
		//  metratime = 06/01/2003 10:30:00
		//  setup product catalog
		//  backup
		//
		//  metratime = 06/01/2003 11:00:00

		// create all monthly and weekly accounts
		public void CreateAccounts()
		{
			IMeter sdk = null;
      try
      {
		sdk = TestLibrary.InitSDK();
        string prefix = "a";
        // create all monthly accounts
        for (int i = 1; i <= 31; i++)
        {
             TestLibrary.CreateAccount(sdk,
                                       string.Format("{0}_monthly_{1}", prefix, i),
                                       "", "monthly", i);
        }

        // create all weekly accounts
        string[] days = { "sun", "mon", "tue", "wed",
												   "thu", "fri", "sat" };
        for (int i = 1; i <= 7; i++)
        {
          string day = days[i - 1];
          TestLibrary.CreateAccount(sdk,
                                     string.Format("{0}_weekly_{1}", prefix, day),
                                     "", "weekly", i);
        }

        sdk.Shutdown();
      }
      finally
      {
		if (sdk != null)
	       Marshal.ReleaseComObject(sdk);
      }
    }

		public void InitialSetup()
		{
			bool restore = true;
			if (restore)
			{
				// skip the first part
				RestoreDB("aggdbinstall");
			}
			else
			{
				SetupDB();
				TestLibrary.BackupDatabase("aggdbinstall");
			}

			SetupAccounts(false);

			SetupProductCatalog();

			TestLibrary.BackupDatabase("aggsetup");

			TestLibrary.Trace("Aggregate rate setup complete");
		}

		public void RestoreDB(string tag)
		{
			string saPassword = "metratech";
			string saName = "sa";
			TestLibrary.RestoreDatabase(tag, saName, saPassword);
		}

        public void CreateSubscriptions(string testID)
        {
            //  metratime = 06/01/2003 09:30:00
            MetraTech.MetraTime.Now = new DateTime(2003, 06, 01, 09, 30, 00);

            MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            sa.Initialize();

            MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
            accessData = sa.FindAndReturnObject("SuperUser");
            string suName = accessData.UserName;
            string suPassword = accessData.Password;

            IMTProductCatalog pc = new MTProductCatalog();
            IMTAccountCatalog ac = new MTAccountCatalog();
            IMTLoginContext login = new MTLoginContext();

            MetraTech.Interop.MTYAAC.IMTSessionContext ctx =
                (MetraTech.Interop.MTYAAC.IMTSessionContext)login.Login(suName, "system_user", suPassword);
            pc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)ctx);
            ac.Init(ctx);

            string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate-subs.csv";

            using (IMTFileConnection conn = ConnectionManager.CreateFileConnection(filename))
            {
                using (IMTStatement stmt = conn.CreateStatement(string.Format("select * from [{0}] where Test = '{1}'",
                                                                                                                             conn.Filename, testID)))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string test = reader.GetString("Test");
                            string nm_account = reader.GetString("nm_account");
                            DateTime dt = reader.GetDateTime("dt");
                            string nm_po = reader.GetString("nm_po");
                            string sub_unsub = reader.GetString("sub_unsub");

                            DateTime dtStart;
                            if (reader.IsDBNull("dt_start"))
                                dtStart = DateTime.MinValue;
                            else
                                dtStart = reader.GetDateTime("dt_start");

                            DateTime dtEnd;
                            if (reader.IsDBNull("dt_end"))
                                dtEnd = DateTime.MinValue;
                            else
                                dtEnd = reader.GetDateTime("dt_end");

                            IMTProductOffering po = pc.GetProductOfferingByName(nm_po);

                            // get the account ID
                            MetraTech.Interop.MTYAAC.IMTYAAC yaac = ac.GetAccountByName(nm_account, "mt", MetraTech.MetraTime.Now);

                            IMTPCAccount acct = pc.GetAccount(yaac.AccountID);

                            IMTPCTimeSpan timespan = new MTPCTimeSpan();
                            if (dtStart != DateTime.MinValue)
                            {
                                timespan.StartDate = dtStart;
                                timespan.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
                            }
                            else
                                timespan.SetStartDateNull();

                            if (dtEnd != DateTime.MaxValue)
                            {
                                timespan.EndDate = dtEnd;
                                timespan.EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
                            }
                            else
                                timespan.SetEndDateNull();

                            object modified;
                            TestLibrary.Trace("Subscribing {0} to {1}", nm_account, nm_po);
                            if (sub_unsub == "S")
                            {
                                acct.Subscribe(po.ID, (MTPCTimeSpan)timespan, out modified);
                            }
                            else if (sub_unsub == "U")
                            {
                                IMTSubscription sub = acct.GetSubscriptionByProductOffering(po.ID);
                                acct.Unsubscribe(sub.ID, timespan.EndDate, MTPCDateType.PCDATE_TYPE_ABSOLUTE);
                            }
                            else
                                throw new ApplicationException("Invalid subscribe/unsubscribe flag");
                        }
                    }
                }
            }
        }

	  public void RunTests()
		{
			ArrayList tests = new ArrayList();

			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			using(IMTFileConnection conn = ConnectionManager.CreateFileConnection(filename))
			{
				// count first to get a record count... not ideal...
                using (IMTStatement countStmt = conn.CreateStatement(string.Format("select distinct(Test) from {0} where Test is not null"
                                                                                                                                        + " and Test = 'CYC5'",
                                                                                                                                        conn.Filename)))
                {
                    using (IMTDataReader reader = countStmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string test = reader.GetString(0);
                            tests.Add(test);
                        }
                    }
                }
			}

			StartUsageStages();
			try
			{
				foreach (string testID in tests)
				{
					TestLibrary.Trace("Running test {0}", testID);
					//aggLib.CreateSubscriptions(testID);
					MeterUsage(testID);
					VerifyGather(testID);
					VerifyFindSequences(testID);
					VerifyGatherLate(testID);
					VerifyInitCounters(testID);
					VerifyOrder(testID);
				}
				TestLibrary.Trace("Tests completed");
			}
			finally
			{
				StopUsageStages();
			}
		}

	  private void StartUsageStages()
		{
			// start the stage
			Process process = new Process();
			process.StartInfo.FileName = "cmdstage.exe";
			process.StartInfo.Arguments = "movietickets_temp writeproductview -routefrom routingqueue";
			process.StartInfo.RedirectStandardOutput = false;
			process.StartInfo.UseShellExecute = false;
			process.Start();

			mProcess = process;
		}

	  private void StopUsageStages()
		{
			TestLibrary.StopStage("movietickets_temp");
			TestLibrary.StopStage("writeproductview");

			mProcess.WaitForExit();
		}


		public void MeterUsage(string testID)
		{
			//  metratime = 06/01/2003 10:00:00
			MetraTech.MetraTime.Now = new DateTime(2003, 06, 01, 10, 00, 00);

			string firstPassPVName = "t_pv_movietickets_temp";

			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			// start the stage
			bool startedStage = false;
			if (mProcess == null)
			{
				StartUsageStages();
				startedStage = true;
			}

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement(string.Format("truncate table {0}", firstPassPVName)))
                {
                    stmt.ExecuteNonQuery();
                }

                using (IMTStatement stmt = conn.CreateStatement("delete from t_acc_usage"))
                {
                    stmt.ExecuteNonQuery();
                }
            }

      IMeter sdk = null;
			try
			{
				sdk = TestLibrary.InitSDK();

			  // dt_crt
				DateTime systemTime = DateTime.MinValue;

				string batchID;
                using (IMTFileConnection conn = ConnectionManager.CreateFileConnection(filename))
                {
                    // count first to get a record count... not ideal...
                    int expectedCount;

                    using (IMTStatement countStmt = conn.CreateStatement(string.Format("select count(*) from {0} where Test = '{1}'", conn.Filename, testID)))
                    {
                        using (IMTDataReader reader = countStmt.ExecuteReader())
                        {
                            reader.Read();
                            expectedCount = reader.GetInt32(0);
                        }
                    }

                    IBatch batch = sdk.CreateBatch();
                    batch.Name = "Aggrate test " + testID;
                    batch.NameSpace = "Aggregate Rating";
                    batch.SequenceNumber = DateTime.Now.ToString();
                    batch.ExpectedCount = expectedCount;
                    batch.Save();

                    batchID = batch.UID;

                    ISessionSet sessionSet = batch.CreateSessionSet();

                    using (IMTStatement stmt = conn.CreateStatement(string.Format("select * from {0} where Test = '{1}' order by id_sess", conn.Filename, testID)))
                    {
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            int sessionsInSet = 0;
                            int setSize = 1;
                            while (reader.Read())
                            {
                                string test = reader.GetString("Test");
                                DateTime dtSession = reader.GetDateTime("dt_session");
                                DateTime dtCrt = reader.GetDateTime("dt_crt");
                                long idsess = reader.GetInt64("id_sess");
                                string viewname = reader.GetString("viewname");
                                string payee = reader.GetString("nm_payee");
                                decimal val1 = (decimal)reader.GetInt32("n_value1");
                                decimal val2 = (decimal)reader.GetInt32("n_value2");

                                if (sessionsInSet >= setSize
                                        || (sessionsInSet > 0 && dtCrt != systemTime))
                                {
                                    MetraTech.MetraTime.Now = systemTime;
                                    sessionSet.Close();
                                    sessionSet = batch.CreateSessionSet();
                                    sessionsInSet = 0;
                                }
                                systemTime = dtCrt;
                                MetraTech.MetraTime.Now = systemTime;

                                ISession session = sessionSet.CreateSession(viewname);
                                // meter synchronously for time synchronization purposes
                                session.RequestResponse = true;
                                session.InitProperty("ticketspurchased", val1);
                                session.InitProperty("popcorns", val2);
                                session.InitProperty("transactiontime", dtSession);
                                session.InitProperty("moviename", "Matrix Reloaded");
                                session.InitProperty("payer", payee);
                                session.InitProperty("transactionID", test + "-" + idsess);

                                sessionsInSet++;
                            }
                            if (sessionsInSet > 0)
                                sessionSet.Close();

                            batch.UpdateMeteredCount();
                        }
                    }
                }

				TestLibrary.WaitForBatchCompletion(sdk, batchID);
			}
			finally
			{
				if (startedStage)
					StopUsageStages();
        if (sdk != null)
          Marshal.ReleaseComObject(sdk);
			}
		}

		public void VerifyGather(string testID)
		{
			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			string sprocName = "AggGatherUsage_MovieTickets";
			//string tableName = "t_agg_movietickets_au";
			//string firstPassPVName = "t_pv_movietickets_temp";
			// TODO:
			DateTime dtStart = new DateTime(2003, 01, 01, 00, 00, 00);
			// TODO:
			DateTime dtEnd = new DateTime(2004, 01, 01, 00, 00, 00);

			// call the gather stored procedure
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
                {
                    stmt.AddParam("input_DT_START", MTParameterType.DateTime, dtStart);
                    stmt.AddParam("input_DT_END", MTParameterType.DateTime, dtEnd);
                    stmt.ExecuteNonQuery();
                }
            }
		}


		public void VerifyFindSequences(string testID)
		{
			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			string sprocName = "AggFindSequences_MovieTickets";
			//string tableName = "t_agg_movietickets_au";
			//string firstPassPVName = "t_pv_movietickets_temp";
			// TODO:
			DateTime dtStart = new DateTime(2003, 01, 01, 00, 00, 00);
			// TODO:
			DateTime dtEnd = new DateTime(2004, 01, 01, 00, 00, 00);

			// call the stored procedure
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
                {
                    stmt.AddParam("input_DT_START", MTParameterType.DateTime, dtStart);
                    stmt.AddParam("input_DT_END", MTParameterType.DateTime, dtEnd);
                    stmt.ExecuteNonQuery();

                }
            }
		}

		public void VerifyGatherLate(string testID)
		{
			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			string sprocName = "AggGatherLateUsage_MovieTickets";
			string tableName = "t_agg_movietickets_au";
			string firstPassPVName = "t_pv_movietickets_temp";
			// TODO:
			DateTime dtStart = new DateTime(2003, 01, 01, 00, 00, 00);
			// TODO:
			DateTime dtEnd = new DateTime(2004, 01, 01, 00, 00, 00);

			// call the gather stored procedure
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
                {
                    stmt.AddParam("input_DT_START", MTParameterType.DateTime, dtStart);
                    stmt.AddParam("input_DT_END", MTParameterType.DateTime, dtEnd);
                    stmt.ExecuteNonQuery();
                }

				// verify id_group, id_ag_interval
                using (IMTFileConnection csvConn = ConnectionManager.CreateFileConnection(filename))
                {
                    using (IMTStatement csvStmt = csvConn.CreateStatement(string.Format("select * from {0} where Test = '{1}' order by id_sess",
                                                                                                                                             csvConn.Filename, testID)))
                    {

                        string query = "select pv.c_transactionid, autemp.id_sess, id_payee, id_group, id_ag_interval, dt_session"
                            + " from " + tableName + " autemp "
                            + " left outer join " + firstPassPVName + " pv on pv.id_sess = autemp.id_sess"
                            + " order by c_transactionID";

                        using (IMTStatement gatherStmt = conn.CreateStatement(query))
                        {

                            using (IMTDataReader csvReader = csvStmt.ExecuteReader(),
                                         gatherReader = gatherStmt.ExecuteReader())
                            {
                                while (csvReader.Read() && gatherReader.Read())
                                {
                                    string inTest = csvReader.GetString("Test");
                                    DateTime inDtSession = csvReader.GetDateTime("dt_session");
                                    long inIDSess = csvReader.GetInt64("id_sess");
                                    string inViewname = csvReader.GetString("viewname");
                                    string inPayee = csvReader.GetString("nm_payee");
                                    int inID_ui = csvReader.GetInt32("id_ui");
                                    int inAgg_interval = csvReader.GetInt32("agg_interval");
                                    string inNmGroupAcc;
                                    if (csvReader.IsDBNull("nm_group_acc"))
                                        inNmGroupAcc = null;
                                    else
                                        inNmGroupAcc = csvReader.GetString("nm_group_acc");

                                    string outTxnID = gatherReader.GetString("c_transactionid");
                                    int outIDPayee;
                                    if (gatherReader.IsDBNull("id_payee"))
                                        outIDPayee = -1;
                                    else
                                        outIDPayee = gatherReader.GetInt32("id_payee");

                                    int outIDGroup;
                                    if (gatherReader.IsDBNull("id_group"))
                                        outIDGroup = -1;
                                    else
                                        outIDGroup = gatherReader.GetInt32("id_group");

                                    int outIDAgInterval = gatherReader.GetInt32("id_ag_interval");
                                    DateTime outDtSession = gatherReader.GetDateTime("dt_session");


                                    string txnID = testID + "-" + inIDSess;
                                    Match("TransactionID", txnID, outTxnID);
                                    Match("dt_session", inDtSession, outDtSession);
                                    Match("aggregate interval", inAgg_interval, outIDAgInterval);

                                    // TODO: actually verify group ID
                                    if (inNmGroupAcc != null && outIDGroup == -1
                                        || inNmGroupAcc == null && outIDGroup != -1)
                                        Fail(string.Format("Group account ID set incorrectly: {0}, {1}", inNmGroupAcc, outIDGroup));
                                }

                                if (csvReader.Read() || gatherReader.Read())
                                    Fail("row count mismatch");
                            }
                        }
                    }
                }
			}
		}

		public void VerifyInitCounters(string testID)
		{
			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			string sprocName = "AggInitCounters_MovieTickets";
			//string tableName = "t_agg_movietickets_au";
			//string firstPassPVName = "t_pv_movietickets_temp";
			// TODO:
			DateTime dtStart = new DateTime(2003, 01, 01, 00, 00, 00);
			// TODO:
			DateTime dtEnd = new DateTime(2004, 01, 01, 00, 00, 00);

			// call the stored procedure
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
                {
                    stmt.AddParam("input_DT_START", MTParameterType.DateTime, dtStart);
                    stmt.AddParam("input_DT_END", MTParameterType.DateTime, dtEnd);
                    stmt.ExecuteNonQuery();

                }
            }
		}

		public void VerifyOrder(string testID)
		{
			string filename = TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\aggrate.csv";

			string sprocName = "AggOrder_MovieTickets";
			string tableName = "t_agg_movietickets_order";
			string firstPassPVName = "t_pv_movietickets_temp";
			// TODO:
			DateTime dtStart = new DateTime(2003, 01, 01, 00, 00, 00);
			// TODO:
			DateTime dtEnd = new DateTime(2004, 01, 01, 00, 00, 00);

			// call the stored procedure
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
                {
                    stmt.AddParam("input_DT_START", MTParameterType.DateTime, dtStart);
                    stmt.AddParam("input_DT_END", MTParameterType.DateTime, dtEnd);
                    stmt.ExecuteNonQuery();
                }

				// verify id_group, id_ag_interval
                using (IMTFileConnection csvConn = ConnectionManager.CreateFileConnection(filename))
                {
                    using (IMTStatement csvStmt = csvConn.CreateStatement(string.Format("select * from {0} where Test = '{1}' order by id_order",
                                                                                                                                             csvConn.Filename, testID)))
                    {

                        string query = "select " + tableName + ".id_sess, pv.c_transactionid, id_order from " + tableName
                            + " inner join " + firstPassPVName + " pv on pv.id_sess = " + tableName + ".id_sess "
                            + " where is_usage = 1 order by id_order";

                        using (IMTStatement outputStmt = conn.CreateStatement(query))
                        {

                            using (IMTDataReader csvReader = csvStmt.ExecuteReader(),
                                         outputReader = outputStmt.ExecuteReader())
                            {
                                while (csvReader.Read() && outputReader.Read())
                                {
                                    string inTest = csvReader.GetString("Test");
                                    DateTime inDtSession = csvReader.GetDateTime("dt_session");
                                    long inIDSess = csvReader.GetInt64("id_sess");
                                    string inViewname = csvReader.GetString("viewname");
                                    string inPayee = csvReader.GetString("nm_payee");
                                    int inID_ui = csvReader.GetInt32("id_ui");
                                    int inAgg_interval = csvReader.GetInt32("agg_interval");
                                    string inNmGroupAcc;
                                    if (csvReader.IsDBNull("nm_group_acc"))
                                        inNmGroupAcc = null;
                                    else
                                        inNmGroupAcc = csvReader.GetString("nm_group_acc");

                                    string outTxnID = outputReader.GetString("c_transactionid");
                                    long idSess = outputReader.GetInt64("id_sess");
                                    int idOrder = outputReader.GetInt32("id_order");

                                    string txnID = testID + "-" + inIDSess;
                                    Match("TransactionID", txnID, outTxnID);

                                    // TODO: actually verify group ID
                                }

                                if (csvReader.Read() || outputReader.Read())
                                    Fail("row count mismatch");
                            }
                        }
                    }
                }
			}
		}


   	private void Match(string message, object val1, object val2)
		{
			if (!val1.Equals(val2))
				Fail(string.Format("{0} mismatch: {1} != {2}", message, val1, val2));
		}

	  private void Fail(string message)
		{
			TestLibrary.Trace(message);
		}

	  private void SetupAccounts(bool restore)
		{
			if (restore)
				RestoreDB("aggdbinstall");

			//  metratime = 06/01/2003 10:00:00
			MetraTech.MetraTime.Now = new DateTime(2003, 06, 01, 10, 00, 00);

			Process process = new Process();
			process.StartInfo.FileName = "cmdstage.exe";
			process.StartInfo.Arguments = "accountcreation -routefrom routingqueue";
			process.StartInfo.RedirectStandardOutput = true;
			process.StartInfo.UseShellExecute = false;
			process.Start();

			try
			{
				CreateAccounts();
			}
			finally
			{
				TestLibrary.StopStage("accountcreation");

				process.WaitForExit();
			}
		}

	  private void SetupProductCatalog()
		{
			//  metratime = 06/01/2003 10:30:00
			MetraTech.MetraTime.Now = new DateTime(2003, 06, 01, 10, 30, 00);

			TestLibrary.ImportPO(TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\PO-AggMovie.xml");
			TestLibrary.ImportPO(TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\PO-AggMovieWeekly.xml");
		}

	  private void SetupDB()
		{
			//string saName = "sa";
			string saPassword = "metratech";

			// move metratime to a known starting point
			MetraTech.MetraTime.Now = new DateTime(2003, 06, 01, 09, 00, 00);

			TestLibrary.CreateDatabase(saPassword, true);
		}

	  private Process mProcess;
	}
}

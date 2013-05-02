namespace MetraTech.Test
{
	using System;
	using System.Diagnostics;
	using System.Messaging;
	using System.Collections;
	using System.IO;
	using System.ServiceProcess;

  using MetraTech;
	using MetraTech.Interop.COMMeter;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.DMO;
  using MetraTech.Interop.RCD;
	using MetraTech.Utils;
	using MetraTech.Pipeline;
	using GenericCollection = MetraTech.Interop.GenericCollection;

	public class TestLibrary
	{
		static MetraTech.COMObjectInstance mTestAPI = new MetraTech.COMObjectInstance("MTTestAPI.TestAPI");
		static bool mTestHarnessMode;
    static Logger mLogger;

		static TestLibrary()
		{
			mTestHarnessMode = (bool) mTestAPI.GetProperty("TestHarnessMode");
      mLogger = new Logger("Logging\\TestLibrary", "[TestLibrary]");
		}

		// this is a static class - no instances are needed
		private TestLibrary() {}

		//
		// simple test harness wrappers
		//
		public static void Trace(string str)
		{
			if (mTestHarnessMode)
			{
				if (!(bool) mTestAPI.ExecuteMethod("Trace", str))
					throw new ApplicationException("test harness Trace method fails");
				Console.WriteLine(str);
        mLogger.LogDebug(str);
			}
			else
				Console.WriteLine(str);
        mLogger.LogDebug(str);
		}

		public static void Trace(string format, params object[] args)
		{
			Trace(string.Format(format, args));
		}


		public static void Trace()
		{
			Trace("");
		}

		public static void SetOperation(string operation)
		{
			Trace("Operation: {0}", operation);
		}

		public static string TestDatabaseFolder
		{
			get
			{
				return System.Environment.GetEnvironmentVariable("METRATECHTESTDATABASE");
			}
		}

		public static string TestDatabaseTempFolder
		{
			get
			{
				string temp = System.Environment.GetEnvironmentVariable("METRATECHTESTDATABASETEMP");
				if (temp == "")
					throw new ApplicationException("METRATECHTESTDATABASETEMP is not set");
				return temp;
			}
		}

		public static void SubmitSessions(IBatch batch,
																			int sessionSets, int sessionsPerSet,
																			int errorsPerSet)
		{
			for (int i = 0; i < sessionSets; i++)
			{
				ISessionSet sessionSet = batch.CreateSessionSet();
				for (int j = 0; j < sessionsPerSet - errorsPerSet; j++)
				{
					ISession session = sessionSet.CreateSession("metratech.com/testservice");
					TestLibrary.InitializeSession(session, false, null);
				}
				for (int j = 0; j < errorsPerSet; j++)
				{
					ISession session = sessionSet.CreateSession("metratech.com/testservice");
					InitializeSession(session, true, null);
				}

				sessionSet.Close();

				Trace("Closing session set of {0} sessions", sessionsPerSet);
			}
		}

		public static void SubmitSessions(IMeter meter, string collectionID,
																			int sessionSets, int sessionsPerSet,
																			int errorsPerSet)
		{
			for (int i = 0; i < sessionSets; i++)
			{
				ISessionSet sessionSet = meter.CreateSessionSet();
				for (int j = 0; j < sessionsPerSet - errorsPerSet; j++)
				{
					ISession session = sessionSet.CreateSession("metratech.com/testservice");
					InitializeSession(session, false, collectionID);
				}
				for (int j = 0; j < errorsPerSet; j++)
				{
					ISession session = sessionSet.CreateSession("metratech.com/testservice");
					InitializeSession(session, true, collectionID);
				}

				sessionSet.Close();

				Trace("Closing session set of {0} sessions", sessionsPerSet);
			}
		}

    /// <summary>
    ///    Create one session set.
    ///    Create a number of testservice sessions specified by the 
    ///    given numberOfSessions.
    ///    Set the pipeline time and the account name on each session.
    ///    Submit the sessions.
    /// </summary>
    /// <param name="meter"></param>
    /// <param name="numberOfSessions"></param>
    /// <param name="intervalId"></param>
    /// <param name="accountName"></param>
    /// <param name="intervalId">will not be used if it's -1</param>
    public static IBatch CreateAndSubmitSessions(IMeter meter,
                                                 int numberOfSessions,
                                                 DateTime pipelineTime,
                                                 string accountName,
                                                 int intervalId,
                                                 DateTime dateTimeProperty)
    {
      IBatch batch = TestLibrary.CreateBatch(meter, 
                                             "Billing Group Test",
                                             numberOfSessions);

      ISessionSet sessionSet = batch.CreateSessionSet();
      for (int i = 0; i < numberOfSessions; i++) 
      {
        ISession session = 
          sessionSet.CreateSession("metratech.com/testservice");
        InitializeSession(session, accountName, pipelineTime, intervalId, dateTimeProperty);
      }

      sessionSet.Close();

      TestLibrary.WaitForBatchCompletion(meter, batch.UID);

      Trace("Closed session set of {0} sessions", numberOfSessions);

      return batch;
    }

    /// <summary>
    ///    Create one session set.
    ///    Create a number of testservice sessions specified by the 
    ///    given numberOfSessions.
    ///    Set the pipeline time and the account name on each session.
    ///    Submit the sessions.
    /// </summary>
    /// <param name="meter"></param>
    /// <param name="numberOfSessions"></param>
    /// <param name="intervalId"></param>
    /// <param name="accountName"></param>
    /// <param name="intervalId">will not be used if it's -1</param>
    public static IBatch CreateAndSubmitTestPISessions(IMeter meter,
                                                       int numberOfSessions,
                                                       string accountName,
                                                       int intervalId,
                                                       DateTime dateTimeProperty)
    {
      IBatch batch = 
        TestLibrary.CreateBatch(meter, "Billing Group Test", numberOfSessions);

      ISessionSet sessionSet = batch.CreateSessionSet();
      for (int i = 0; i < numberOfSessions; i++) 
      {
        ISession session = 
          sessionSet.CreateSession("metratech.com/testpi");
        InitializeTestPISession(session, accountName, intervalId, dateTimeProperty);
      }

      sessionSet.Close();

      TestLibrary.WaitForBatchCompletion(meter, batch.UID);

      Trace("Closed session set of {0} sessions", numberOfSessions);

      return batch;
    }

 		public static string GenerateBatchUID(IMeter sdk, string name, int expected)
		{
			IBatch batch = sdk.CreateBatch();
			batch.Name = name;
			batch.NameSpace = "Unit Test";
      batch.Source = "Test";
			batch.SequenceNumber = DateTime.Now.ToString();
			batch.ExpectedCount = expected;
			batch.Save();
			
			return batch.UID;
		}

    public static IBatch CreateBatch(IMeter sdk, string name, int expected)
    {
      IBatch batch = sdk.CreateBatch();
      batch.Name = name;
      batch.NameSpace = "Unit Test";
      batch.SequenceNumber = DateTime.Now.ToString();
      batch.ExpectedCount = expected;
      batch.Save();
			
      return batch;
    }

		public static int GetBatchCompletedCount(IMeter sdk, string batchID)
		{
			IBatch batch = sdk.OpenBatchByUID(batchID);
			return batch.CompletedCount;
		}

		public static void WaitForBatchCompletion(IMeter sdk, string batchID)
		{
			Trace("Waiting for batch '{0}' to complete...", batchID);
			IBatch batch = sdk.OpenBatchByUID(batchID);

			int count = 0;
			while (batch.Status != "C" && count < 30)
			{
				System.Threading.Thread.Sleep(5 * 1000);
				// TODO: this should call Refresh()!
				batch = sdk.OpenBatchByUID(batchID);
				//batch.Refresh();
				string status = batch.Status;
				Trace("   status = {0} completed count = {1}, failure count = {2}",
																 batch.Status, batch.CompletedCount, batch.FailureCount);
				count++;
			}
			Trace("Batch is complete with {0} errors", batch.FailureCount);
		}

		public static void WaitForSessionCompletion(string sessionID)
		{
			int count = 0;
			bool completed;
			do
			{
				completed = FindCompletedSession(sessionID);
				if (completed)
					break;

				Trace("waiting...");
				System.Threading.Thread.Sleep(5 * 1000);
				count++;
			} while (count < 30);

			if (!completed)
				throw new ApplicationException("Session " + sessionID + " not completed");
		}

		public static bool FindCompletedSession(string sessionID)
		{
			byte [] uidBytes = MSIXUtils.DecodeUID(sessionID);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("select count(*) from t_acc_usage where tx_uid = ?"))
                {
                    stmt.AddParam(MTParameterType.Binary, uidBytes);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();
                        if (reader.GetInt32(0) == 1)
                            return true; // found
                        else
                            return false; // not found
                    }
                }
            }
		}

		public static void InitializeSession(ISession session, 
                                         bool error,
																	       string collectionID)
		{
			session.InitProperty("description", "batch/rerun test");
			session.InitProperty("time", MetraTech.MetraTime.Now);
			session.InitProperty("decprop2", 123.88m);
			session.InitProperty("decprop1", 99m);
			session.InitProperty("units", 10);
			if (error)
				session.InitProperty("accountname", "demoERROR");
			else
				session.InitProperty("accountname", "demo");
			if (collectionID != null)
				session.InitProperty("_CollectionID", collectionID);
		}

    /// <summary>
    ///   If intervalID is -1, it will not be used. 
    ///   If dateTimeProperty is DateTime.MinValue it will not be used.
    /// </summary>
    /// <param name="session"></param>
    /// <param name="accountName"></param>
    /// <param name="pipelineTime"></param>
    /// <param name="intervalID">metered as the special _IntervalID property</param>
    public static void InitializeSession(ISession session, 
                                         string accountName,
                                         DateTime pipelineTime,
                                         int intervalID,
                                         DateTime dateTimeProperty)
    {
      session.InitProperty("description", "batch/rerun test");
      if (dateTimeProperty == DateTime.MinValue) 
      {
        session.InitProperty("time", MetraTech.MetraTime.Now);
      }
      else 
      {
        session.InitProperty("time", dateTimeProperty);
      }
      session.InitProperty("decprop2", 123.88m);
      session.InitProperty("decprop1", 99m);
      session.InitProperty("units", 10);
      session.InitProperty("accountname", accountName);
      session.InitProperty("pipelineTime", pipelineTime);
      if (intervalID != -1)
      {
        session.InitProperty("_IntervalID", intervalID);
      }
    }

    /// <summary>
    ///   If intervalID is -1, it will not be used. 
    ///   If dateTimeProperty is DateTime.MinValue it will not be used.
    /// </summary>
    /// <param name="session"></param>
    /// <param name="accountName"></param>
    /// <param name="pipelineTime"></param>
    /// <param name="intervalID">metered as the special _IntervalID property</param>
    public static void InitializeTestPISession(ISession session, 
                                               string accountName,
                                               int intervalID,
                                               DateTime dateTimeProperty)
    {
      session.InitProperty("accountname", accountName);
      session.InitProperty("description", "test pi session");
      session.InitProperty("units", 10);
      session.InitProperty("duration", 100);
      if (dateTimeProperty == DateTime.MinValue) 
      {
        session.InitProperty("time", MetraTech.MetraTime.Now);
      }
      else 
      {
        session.InitProperty("time", dateTimeProperty);
      }
      session.InitProperty("decprop1", 11.20);
      session.InitProperty("decprop2", 12.20);
      session.InitProperty("decprop3", 13.20);
      
      if (intervalID != -1)
      {
        session.InitProperty("_IntervalID", intervalID);
      }
    }

		public static int CountCompletedSessions(string batchID)
		{
			byte [] uidBytes = MSIXUtils.DecodeUID(batchID);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("select count(*) from t_acc_usage where tx_batch = ?"))
                {
                    stmt.AddParam(MTParameterType.Binary, uidBytes);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();
                        return reader.GetInt32(0);
                    }
                }
            }
		}

		public static int CountFailedSessions(string batchID)
		{
			byte [] uidBytes = MSIXUtils.DecodeUID(batchID);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("select count(*) from t_failed_transaction where tx_batch = ? and state = 'N'"))
                {
                    stmt.AddParam(MTParameterType.Binary, uidBytes);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();
                        return reader.GetInt32(0);
                    }
                }
            }
		}

		public static IMeter InitSDK()
		{
			Trace("Initializing SDK");
			IMeter sdk = new Meter();
			sdk.Startup();
			sdk.AddServer(0, "localhost", PortNumber.DEFAULT_HTTP_PORT, 0, "", "");
			return sdk;
		}

		public static string CreateAndMeterBatch(IMeter sdk, int sessionSets,
																						 int sessionsPerSet, int errorsPerSet)
		{
			System.Random rnd = new System.Random();

			Trace("Creating batch");
			int expectedCount = sessionsPerSet * sessionSets;
			IBatch batch = sdk.CreateBatch();
			batch.NameSpace = "PipelineTest";
			batch.Name = String.Format("Batch: {0}.{1}.{2}", DateTime.Now.ToString(),
																 DateTime.Now.Millisecond,
																 rnd.Next());
			batch.ExpectedCount = expectedCount;
			batch.Source = "SmokeTest";
			batch.SequenceNumber = "1";
			batch.SourceCreationDate = MetraTech.MetraTime.Now;

			batch.Save();

			string batchID = batch.UID;

			Trace("Submitting sessions");
			SubmitSessions(batch, sessionSets, sessionsPerSet, errorsPerSet);

			Trace("Waiting for batch to complete");
			WaitForBatchCompletion(sdk, batchID);

			int completed = CountCompletedSessions(batchID);

			int failed = CountFailedSessions(batchID);

			if (completed != (sessionsPerSet - errorsPerSet) * sessionSets
					|| failed != errorsPerSet * sessionSets)
				throw new ApplicationException(
					string.Format("Only {0} sessions completed (there should be {1})",
												completed, sessionsPerSet * sessionSets));
			Trace("{0} sessions completed", completed);

			return batchID;
		}

		// creates an account synchronously
		public static void CreateAccount(IMeter sdk, string username, string priceList, string cycleType, int day)
		{
			CreateAccount(sdk, username, priceList, cycleType, day, true);
		}

		// creates an account synchronously
		public static void CreateGSMAccount(IMeter sdk, string username)
		{
			CreateGSMAccount(sdk, username, true);
		}

		// creates an account synchronously
		public static void CreateSystemAccount(IMeter sdk, string username)
		{
			CreateSystemAccount(sdk, username, true);
		}

		public static void CreateSystemAccount(IMeter sdk, string username, bool synchronous)
		{
			Trace("Creating System account {0}", username);
			MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();

			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;

			ISessionSet sessionSet = sdk.CreateSessionSet();
			sessionSet.SessionContextUserName = suName;
			sessionSet.SessionContextPassword = suPassword;
			sessionSet.SessionContextNamespace = "system_user";

			ISession session = sessionSet.CreateSession("metratech.com/SystemAccountcreation");
			session.InitProperty("loginapplication", "CSR");
			session.InitProperty("usagecycletype", "Monthly");
			session.InitProperty("dayofmonth", "1");
			session.InitProperty("accounttype", "SYSTEMACCOUNT");
			session.InitProperty("actiontype", "both");	// account/contact/both
			session.InitProperty("operation", "Add");
			session.InitProperty("username", username);
			session.InitProperty("password_", "123");
			session.InitProperty("name_space", "system_user");
			session.InitProperty("language", "US");
			session.InitProperty("currency", "USD");
			session.InitProperty("timezoneID", 18);

			session.InitProperty("accountstartdate", "2005-12-2T14:20:07Z");
			session.InitProperty("accountenddate", "2020-12-2T14:20:07Z");
			session.InitProperty("accountstatus", "AC");
			session.InitProperty("statusreason", "0");
			session.InitProperty("applyaccounttemplate", "T");
			session.InitProperty("ApplyDefaultSecurityPolicy", "T");

			session.RequestResponse = synchronous;

			sessionSet.Close();
		}


		public static void CreateGSMAccount(IMeter sdk, string username, bool synchronous)
		{
			Trace("Creating GSM account {0}", username);
			MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();

			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;

			ISessionSet sessionSet = sdk.CreateSessionSet();
			sessionSet.SessionContextUserName = suName;
			sessionSet.SessionContextPassword = suPassword;
			sessionSet.SessionContextNamespace = "system_user";

			ISession session = sessionSet.CreateSession("metratech.com/GSMCreate");
			session.InitProperty("accounttype", "GSMServiceAccount");
			session.InitProperty("actiontype", "both");	// account/contact/both
			session.InitProperty("operation", "Add");
			session.InitProperty("username", username);
			session.InitProperty("password_", "123");
			session.InitProperty("name_space", "MT");
			session.InitProperty("language", "US");
			session.InitProperty("currency", "USD");
			session.InitProperty("timezoneID", 18);
	
			session.InitProperty("accountstartdate", "2005-12-2T14:20:07Z");
			session.InitProperty("accountstatus", "AC");
			session.InitProperty("applyaccounttemplate", "T");
			session.InitProperty("ApplyDefaultSecurityPolicy", "T");

			session.RequestResponse = synchronous;

			sessionSet.Close();
		}


		public static void CreateAccount(IMeter sdk, string username, string priceList, string cycleType, int day, bool synchronous)
		{
			Trace("Creating account {0}", username);
      MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();

			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;

			ISessionSet sessionSet = sdk.CreateSessionSet();
			sessionSet.SessionContextUserName = suName;
			sessionSet.SessionContextPassword = suPassword;
			sessionSet.SessionContextNamespace = "system_user";

			ISession session = sessionSet.CreateSession("metratech.com/accountcreation");
			if (priceList != "")
				session.InitProperty("pricelist", priceList);
			session.InitProperty("actiontype", "both");	// account/contact/both
			session.InitProperty("password_", "test");
			session.InitProperty("_Accountid", 0);
			session.InitProperty("username", username);
			session.InitProperty("operation", "Add");
			session.InitProperty("name_space", "MT");
			session.InitProperty("language", "US");
			session.InitProperty("currency", "USD");

			session.InitProperty("usagecycletype", cycleType);
			switch (cycleType)
			{
			case "weekly":
				session.InitProperty("dayofweek", day);
				break;
			case "monthly":
				session.InitProperty("dayofmonth", day);
				break;
			default:
				throw new ApplicationException("only monthly and weekly cycles supported");
			}

			session.InitProperty("timezoneID", 18);
			session.InitProperty("taxexempt", false);
			session.InitProperty("city", "Waltham");
			session.InitProperty("state", "MA");
			session.InitProperty("zip", "02451");
			session.InitProperty("accounttype", "IndependentAccount");
			session.InitProperty("contacttype", "Bill-To");
			session.InitProperty("paymentmethod", "CashOrCheck");
			session.InitProperty("firstname", "Test");
			session.InitProperty("lastname", "User");
			session.InitProperty("email", "x@hotmail.com");
			session.InitProperty("phonenumber", "555-5555");
			session.InitProperty("company", "MetraTech");
			session.InitProperty("address1", "300 Bear Hill Road.");
			session.InitProperty("address2", "");
			session.InitProperty("address3", "");
			session.InitProperty("country", "USA");
			session.InitProperty("facsimiletelephonenumber", "");
			session.InitProperty("middleinitial", "L");

			session.InitProperty("accountstatus", "Active");

      //session.InitProperty("accountstartdate", now+100);

			session.InitProperty("statusreason", "0");
			session.InitProperty("billable", true);
			session.InitProperty("folder", false);

			//session.InitProperty("payerID", PayerAccountID)
			//session.InitProperty("ancestorAccountID", AncestorID)
			//session.InitProperty("ancestorAccount", AncestorAccount)
			//session.InitProperty("ancestorAccountNS", AncestorAccountNS)
			//session.InitProperty("PayerAccount", payerLogin)
			//session.InitProperty("PayerAccountNS", PayerNamespace)

			session.RequestResponse = synchronous;

			sessionSet.Close();
		}

		public static void CreateDatabase(string saPassword, bool restart)
		{
			SQLManager manager = new SQLManager();
			if (restart)
			{
				Trace("Restarting SQL Server");
				manager.Restart("sa", saPassword);
			}

			ConnectionInfo info = ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");
			string dbName = info.Catalog;

			Trace("Creating database {0}", dbName);

      IMTRcd rcd = (IMTRcd) new MTRcd();
			string installDir = rcd.InstallDir;

			Process process = new Process();
			process.StartInfo.FileName = "cscript.exe";
			process.StartInfo.Arguments = string.Format("{0}\\Database\\mydbinstall.vbs -DBName {1} -SAPassword {2}",
																									installDir, dbName, saPassword);
			process.StartInfo.RedirectStandardOutput = true;
			process.StartInfo.UseShellExecute = false;
			process.Start();
			string line = process.StandardOutput.ReadToEnd();
			process.WaitForExit();

			Trace("process finished");

			if (line.IndexOf("SUCCEED") == -1)
			{
   			Trace(line);
        throw new DataAccessException("Database install failed");
      }

			Trace(line);
			Trace("Database installed", dbName);
		}

		public static void BackupDatabase(string name)
		{
			SQLManager sqlManager = new SQLManager();
			string temp = TestDatabaseTempFolder;

			Trace("Backing up database to " + temp);
			sqlManager.BackupNetMeter(temp, name);
		}

		public static void RestoreDatabase(string name, string saName, string saPassword)
		{
			SQLManager sqlManager = new SQLManager();
			string temp = TestDatabaseTempFolder;

			Trace("Restoring database from " + temp);

			sqlManager.RestoreNetMeter(saName, saPassword,
																 temp, name,
																 true);	// restart before restoring
		}

	  public static void StopStage(string stageName)
		{
			Trace("Stopping stage " + stageName);
			string queueName = stageName + "Queue";
			MessageQueue queue = PipelineConfig.OpenPrivateQueue(null, queueName, false);

			Message message = new Message();
			message.Recoverable = false;

			// create a PipelineSysCommand message where the command is EXIT
			byte [] bodyBytes = BitConverter.GetBytes(1);	// EXIT
			Debug.Assert(bodyBytes.Length == 4);
			//message.Body = bodyBytes;
			message.BodyStream.Write(bodyBytes, 0, bodyBytes.Length);
			message.AppSpecific = 9;	// system command
			message.Priority = MessagePriority.VeryHigh;
			queue.Send(message);
		}

	  public static void ImportPO(string filename)
		{
			// pcimportexport.exe -ipo -file c:\dyoung\test\aggregate\PO-AggMovie.xml -username "su" -password "su123" -namespace "system_user"

      MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();

			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;

      string args = string.Format("-ipo -file \"{0}\" -username {1} -password {2} -namespace system_user -SkipIntegrity",
																	filename, suName, suPassword);
			Trace("Importing product offering from file " + filename);
			PCImportExport(args);
		}

	  public static void PCImportExport(string arguments)
		{
			Trace("Running pcimportexport.exe " + arguments);
			//      MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			//			sa.Initialize();

			//			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			//			accessData = sa.FindAndReturnObject("SuperUser");
			//			string suName = accessData.UserName;
			//			string suPassword = accessData.Password;

			Process process = new Process();
			process.StartInfo.FileName = "pcimportexport.exe";
			process.StartInfo.Arguments = arguments;
			process.StartInfo.RedirectStandardOutput = false;
			process.StartInfo.UseShellExecute = false;
			process.StartInfo.CreateNoWindow = true;
			process.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
			process.Start();
			//string line = process.StandardOutput.ReadToEnd();
			process.WaitForExit();

			// read the output code from the return code file
			string returnCodeFile = TestDatabaseTempFolder + "\\PCImportExport.ExitCode.Txt";
			int retCode;
			using (StreamReader reader = new StreamReader(returnCodeFile))
			{
        string line = reader.ReadLine();   
        retCode = Int32.Parse(line);
      }

			if (retCode != 0)
				// not very informative
				throw new ApplicationException("PCImportExport failed");

			Trace("PCImportExport complete");
		}

		public static void MyTest(int input, out int output, out int output2)
		{
			output = 123;
			output2 = 456;
		}

		// since we needed to abandon using client generated session UIDs,
		// internally there is no easy way to link up the results of the session with 
		// the SDK session. for now, we'll associate a batch with each session
		// and derive the internal UID from that. given the batch UID we'll
		// be able to return the session UID used by the pipeline.
		// NOTE: this assumes a batch size of 1 session
		public static string GetSessionUIDFromBatch(string batchUID)
		{
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{

				// retrieves root session ID from t_failed_transaction in failure case
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
                    "SELECT tx_FailureCompoundID_encoded FROM t_failed_transaction WHERE tx_batch_encoded = ? "))
                {
                    stmt.AddParam(MTParameterType.String, batchUID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            return reader.GetString(0);
                        }
                    }
                }

				// retrieves the session ID for a successful session
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
                    "SELECT s.id_source_sess FROM t_acc_usage au " +
                    "INNER JOIN t_session s ON s.id_source_sess = au.tx_uid " +
                    "INNER JOIN t_batch b ON b.tx_batch = au.tx_batch " +
                    "WHERE b.tx_batch_encoded = ? "))
                {
                    stmt.AddParam(MTParameterType.String, batchUID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            byte[] rawUID = reader.GetBytes(0);
                            return MSIXUtils.EncodeUID(rawUID);
                        }
                    }
                }

				throw new ApplicationException("No session found based on batch UID given!");
			}
		}


		public static GenericCollection.IMTCollection GetChildrenSessionUIDsFromParent(string childSvcTableName,
																																									 string parentSessionUID)
		{
			GenericCollection.IMTCollection children = new GenericCollection.MTCollection();

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
                    "SELECT id_source_sess FROM " + childSvcTableName + " WHERE id_parent_source_sess = ? "))
                {
                    stmt.AddParam(MTParameterType.Binary, MSIXUtils.DecodeUID(parentSessionUID));
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            children.Add(MSIXUtils.EncodeUID(reader.GetBytes(0)));
                        }
                    }
                }
            }

			return children;
		}


		// <summary>
		// Starts the specified service if it isn't already running. Blocks until it is fully started.
		// </summary>
		private static void StartService(string serviceName)
		{
			Trace("Starting service: {0}", serviceName);
			using (ServiceController service = new ServiceController(serviceName))
			{
				if (service.Status == ServiceControllerStatus.Stopped)
				{
					service.Start();
					service.WaitForStatus(ServiceControllerStatus.Running);
				}
			}
			Trace("Service successfully started: {0}", serviceName);
		}

		// <summary>
		// Stops the specified service if it isn't already stopped. Blocks until it is fully stopped.
		// </summary>
		private static void StopService(string serviceName)
		{
			Trace("Stopping service: {0}", serviceName);
			using (ServiceController service = new ServiceController(serviceName))
			{
				if (service.Status == ServiceControllerStatus.Running)
				{
					service.Stop();
					service.WaitForStatus(ServiceControllerStatus.Stopped);
				}
			}
			Trace("Service successfully stopped: {0}", serviceName);
		}

    // <summary>
    // Get service status.
    // </summary>
    private static ServiceControllerStatus GetServiceStatus(string serviceName)
    {
      Trace("Get service status: {0}", serviceName);
      ServiceControllerStatus status = ServiceControllerStatus.Stopped;
      using (ServiceController service = new ServiceController(serviceName))
      {
        status = service.Status;
      }
      Trace("Retrieved {0} service status: {1} ", serviceName, status);
      return status;
    }
		
		//
		// Starts, stops, or restarts the pipeline service
		//
		public static void StartPipeline()
		{
			StartService("pipeline");
		}
		public static void StopPipeline()
		{
			StopService("pipeline");
		}
		public static void RestartPipeline()
		{
			StopPipeline();
			StartPipeline();
		}

		//
		// Starts, stops, or restarts the W3SVC web server service
		//
		public static void StartWebServer()
		{
			StartService("w3svc");
		}
		public static void StopWebServer()
		{
			StopService("w3svc");
		}
		public static void RestartWebServer()
		{
			StopWebServer();
			StartWebServer();
		}
  
    //
    // Starts, stops, or restarts the ActivityServices web server service
    //
    public static void StartActivityServices()
    {
      StartService("ActivityServices");
    }
    public static void StopActivityServices()
    {
      StopService("ActivityServices");
    }
    public static void RestartActivityServices()
    {
      StartActivityServices();
      StopActivityServices();
    }
    public static bool IsActivityServicesrunning()
    {
      ServiceControllerStatus status = GetServiceStatus("ActivityServices");
      if (status == ServiceControllerStatus.Running)
        return true;

      return false;
    }
  }
}

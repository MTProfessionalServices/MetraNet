using System.Runtime.InteropServices;

namespace MetraTech.Pipeline.Test
{
	using System;
	using System.Collections;
	using System.Threading;

	using NUnit.Framework;
	using MetraTech.Test;

	using MetraTech.Pipeline.ReRun;
	using MetraTech.DataAccess;

	using MetraTech.Interop.PipelineControl;
	using MetraTech.Interop.COMMeter;
	using MetraTech.Interop.PropSet;
	using MetraTech.Interop.NameID;
	using MetraTech.Interop.GenericCollection;
	using Auth = MetraTech.Interop.MTAuth;

	// ______________________
	//
	// Tests to add:
	//   - pass in external transaction to abandon, resubmit and make sure they join into it
	//   - compound failures
	//   - check for shared memory leaks
	//
	//


	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Pipeline.Test.FailedTransactionTests /assembly:O:\debug\bin\MetraTech.Pipeline.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class FailedTransactionTests
	{
    [TestFixtureTearDown]
    public void TearDown()
    {
      if (mSdk != null)
        Marshal.ReleaseComObject(mSdk);
    }
		
		// Tests that metering a successful session works
		[Test]
    public void T01TestSuccessfulSession()
    {
			// determines the initial failure count
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			// initializes the session with accountname set to "demo"
			ISession session = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);
			TestLibrary.Trace("Metering successful session...");
			session.RequestResponse = true;
			session.Close();

			// validates feedback
			ISession response = session.ResultSession;
			string accountName = (string) response.GetProperty("accountname", DataType.MTC_DT_CHAR);
			Assert.AreEqual("demo", accountName, "Account name mismatch in response!");
			TestLibrary.Trace("Response successfully received");

			// validates there were no new failures
			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);
			Assert.AreEqual(failedCount, newFailedCount, "Failure count should not have changed!");
    }
		
		// Tests that metering a bad session fails correctly
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T02TestFailureSession()
        {
			// determines the initial failure count
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "FailedTransaction.TestFailureSession", 1);

			// initializes the session with accountname set to "demoERROR"
			ISession session = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, true, batchUID);

			TestLibrary.Trace("Metering failure session...");
			session.Close();
			TestLibrary.WaitForBatchCompletion(Sdk, batchUID);

			// gets the server's UID for the failure
			mFailureUID = TestLibrary.GetSessionUIDFromBatch(batchUID);

			// validates there was 1 new failure
			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);
			Assert.AreEqual(failedCount + 1, newFailedCount, "Failure count should have increased by 1!");
		}

		
		// Tests that metering a session set with partial failures autoresubmits
		//   - successful session is resubmitted and eventually completed (t_acc_usage)
		//   - failure session is recorded in t_failed_transaction
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T03TestAsynchronousAutoResubmit()
    {
			// determines the initial failure count
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "FailedTransaction.TestAsynchronousAutoResubmit", 2);

			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession goodSession = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(goodSession, false, batchUID);

			ISession badSession = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(badSession, true, batchUID);

			TestLibrary.Trace("Metering mixed failure session set asynchronously...");
			// must be sent asynchronously for autoresubmit to be used.
			goodSession.RequestResponse = false;
			badSession.RequestResponse = false;
			sessionSet.Close();

			// waits for the session to complete
			TestLibrary.Trace("Waiting for failure sessions to be processed (10 sec)...");
			Thread.Sleep(10000); // TODO: make this wait more precise

			// validates there was 1 new failure
			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);
			Assert.AreEqual(failedCount + 1, newFailedCount, "Failure count should have increased by 1!");

			// validates the good session was ultimately committed
			TestLibrary.Trace("Checking completion of successful session...");
			TestLibrary.WaitForBatchCompletion(Sdk, batchUID);
			TestLibrary.Trace("Successful session found completed");
		}


		// Tests that metering a session set synchronously with partial failures
		// does not autoresubmit. Both sessions should end up in t_failed_transactions
		[Test]
    public void T04TestSynchronousAutoResubmit()
    {
			TestLibrary.Trace();

			// determines the initial failure count
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession goodSession = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(goodSession, false, null);

			ISession badSession = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(badSession, true, null);

			TestLibrary.Trace("Metering mixed failure session set synchronously (autoresubmit should be disabled)...");
			// sending synchronously should disable autoresubmit for this message
			goodSession.RequestResponse = true;
			badSession.RequestResponse = true;

			try
			{
				sessionSet.Close();
				Assert.Fail("Expected exception not generated!");
			}
			catch (Exception e)
			{
				// NOTE: the SDK returns the last session error from the feedback message.
				// since the order of processing in a set is not defined
				// it can be either message: the one that really failed, or the one that couldn't
				// continue because autoresubmit is disabled in sycnhronous mode

				// checks for either possible exception
				if (!e.Message.Equals("Unable to resolve accountname: demoERROR, namespace: mt (request #1)") &&
						!e.Message.Equals("Sessions within the session set have failed"))
					Assert.Fail(String.Format("Unexpected SessionSet.Close() failure message: {0}", e.Message));
			}

			// just in case there is a bug wait a bit for sessions to complete
			TestLibrary.Trace("Waiting just in case there is a bug and something is actually processing (5 sec)...");
			Thread.Sleep(5000); 

			// validates there were no new failures
			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);
			Assert.AreEqual(failedCount, newFailedCount,"Failure count should not have changed!");

			// validates the good session was not completed
			bool goodSessionCompleted = TestLibrary.FindCompletedSession(goodSession.SessionID + "==");
			Assert.IsTrue(!goodSessionCompleted, "Good session should not have been completed!");
		}


		// Tests that looking up a particular failure (mFailureUID) works
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T05TestSessionErrorLookup()
    {
			IMTSessionError error = GetSessionError(mFailureUID);
			Assert.IsNotNull(error);

			//
			// validates fields with known values
			//

			// root session ID should be the session ID since this is an atomic failure
			Assert.AreEqual(mFailureUID, error.RootSessionID, "Root session ID mismatch!");
			Assert.AreEqual(0xE1200024, error.ErrorCode, "Error code mismatch!"); // PIPE_ERR_ACCOUNT_RESOLUTION
			Assert.AreEqual(-1, error.LineNumber, "Line number mismatch!");
			Assert.AreEqual("Unable to resolve accountname: demoERROR, namespace: mt (request #0)",
														 error.ErrorMessage, "Error message mismatch!");
			Assert.AreEqual("Test", error.StageName, "Stage name mismatch!");
			Assert.AreEqual("AccountResolution", error.PlugInName, "Plug-in name mismatch!");

			TestLibrary.Trace("Failure time : {0}", error.FailureTime);
			TestLibrary.Trace("Metered time : {0}", error.MeteredTime);
			Assert.IsTrue(error.FailureTime >= error.MeteredTime, "Failure time should be no earlier than metered time!");

			// TODO: check batch ID

			// exercises fields that are difficult to validate
			TestLibrary.Trace("IP Address   : {0}", error.IPAddress);
			TestLibrary.Trace("Procedure    : {0}", error.ProcedureName);
			TestLibrary.Trace("Line number  : {0}", error.LineNumber);
			TestLibrary.Trace("Module       : {0}", error.ModuleName);
		}

		// Tests that exporting a failed transaction generates parseable XML
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T06TestFailureExport()
    {
			IMTSessionError error = GetSessionError(mFailureUID);
			Assert.IsNotNull(error);

			string buffer = error.XMLMessage;
			TestLibrary.Trace("XMLMessage: {0}", buffer);
			
			// makes sure it can be parsed
			IMTConfig config = new MTConfigClass();
			bool checksumMatched;
			IMTConfigPropSet propset = config.ReadConfigurationFromString(buffer, out checksumMatched);
			Assert.IsNotNull(propset);

			// examines a property to make sure it's what we expect
			IMTPipeline pipeline = new MTPipelineClass();
			IMTSession session = null;
			try
			{
				session = pipeline.ExamineSession(buffer);
				Assert.IsNotNull(session);
				Assert.AreEqual(mFailureUID, session.UIDAsString, "Session UID mismatch!");
				
				// TODO: for some reason the MTSessionError.Session getter doesn't work through managed code
				// it will return a non-null __ComObject but any calls on it will raise a NullReferenceException
				// controlpipeline does the same exact thing through native code and it works - strange...
				//
				//    PipelineControl.IMTSession session = error.session;
				
				IMTNameID nameID = new MTNameID();
				int accountNameID = nameID.GetNameID("AccountName");
				string accountName = session.GetStringProperty(accountNameID);
				Assert.IsNotNull(accountName);
				Assert.AreEqual("demoERROR", accountName, "Account name mismatch!");
				
				// exports the failure as an autosdk file
				buffer = pipeline.ExportSession(session);
				
				// makes sure it can be parsed
				propset = config.ReadConfigurationFromString(buffer, out checksumMatched);
				Assert.IsNotNull(propset);
			}
			finally
			{
				// cleans up shared memory (otherwise we will leak!!) 
				if (session != null)
					Marshal.ReleaseComObject(session);
			}
		}

		// Tests resubmitting a failed transaction
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T07TestResubmitFailure()
    {
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			TestLibrary.Trace("Resubmitting unedited failed transaction (it should fail again)...");
			Failures.ResubmitSession(mFailureUID);

			// since the error wasn't corrected, it should appear again after some wait time
			TestLibrary.Trace("Waiting for pipeline to process resubmission... (10 sec)");
			Thread.Sleep(10000); // TODO: make this more precise

			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);

			Assert.AreEqual(failedCount, newFailedCount, "Failure count should not have changed!");
		}
		

		// Tests resubmitting a failed transaction via the asynchronous API designed for MetraControl
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T08TestAsyncResubmitFailure()
    {
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			TestLibrary.Trace("Asynchronously resubmitting unedited failed transaction (it should fail again)...");
			MetraTech.Interop.PipelineControl.IMTCollection failureCollection =
				(MetraTech.Interop.PipelineControl.IMTCollection) new MTCollection();
			failureCollection.Add(mFailureUID);
			IBulkFailedTransactions bulkFailures = new BulkFailedTransactions();
			int rerunID = bulkFailures.ResubmitCollectionAsync(failureCollection);
			
			MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();

			// logging in is required before using the IsComplete method
			Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
			Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext) sessionContext);

			rerun.ID = rerunID;
			rerun.Synchronous = false;
			while(!rerun.IsComplete()) 
			{
				TestLibrary.Trace("   waiting for async resubmission to complete...");
				Thread.Sleep(1000); 
			}

			// since the error wasn't corrected, it should appear again after some wait time
			TestLibrary.Trace("Waiting for pipeline to process resubmission... (10 sec)");
			Thread.Sleep(10000); // TODO: make this more precise

			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);

			Assert.AreEqual(failedCount, newFailedCount, "Failure count should not have changed!");
		}

		// Tests abandoning a failed transaction
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T09TestAbandonFailure()
    {
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);

			TestLibrary.Trace("Abandoning failed transaction...");
			Failures.AbandonSession(mFailureUID, Type.Missing);

			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);

			Assert.AreEqual(failedCount - 1, newFailedCount, "One less failure expected!");
		}

		// Tests loading, editing, saving and resubmitting a failed transaction
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T10TestSaveMSIX()
		{
			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "FailedTransaction.TestSaveMSIX", 1);

			// meters a fresh failure
			ISession session = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, true, batchUID);
			session.InitProperty("stringproperty", "findme");
			session.Close();
			TestLibrary.WaitForBatchCompletion(Sdk, batchUID);

			// retrieves (generates) the failure's MSIX from the DB
			string sessionID = TestLibrary.GetSessionUIDFromBatch(batchUID);
			IMTSessionError error = GetSessionError(sessionID);
			string xml = error.XMLMessage;

			// edits the account name, saves and reloads
			if (xml.IndexOf("demoERROR") <= 0)
				Assert.Fail("Failure account name not found!");
			xml = xml.Replace("demoERROR", "demoBAD");
			error.SaveXMLMessage(xml, null);
			xml = error.XMLMessage;
			Assert.IsTrue(xml.IndexOf("demoBAD") > 0, "Could not find 'demoBAD'!");

			// corrects the account name, saves and reloads
			xml = xml.Replace("demoBAD", "demo");
			error.SaveXMLMessage(xml, null);
			xml = error.XMLMessage;
			Assert.IsTrue(xml.IndexOf(">demo<") > 0, "Could not find '>demo<'!");

			// adds in some single quotes, saves and reloads
			xml = xml.Replace("findme", "O'Reilly");
			error.SaveXMLMessage(xml, null);
			xml = error.XMLMessage;
			Assert.IsTrue(xml.IndexOf(">O'Reilly<") > 0, "Single quote save failure!");

			// adds in some double quotes, saves and reloads (this shouldn't be a problem)
			xml = xml.Replace("O'Reilly", "I am a \"quoted string\"!");
			error.SaveXMLMessage(xml, null);
			xml = error.XMLMessage;
			Assert.IsTrue(xml.IndexOf(">I am a \"quoted string\"!<") > 0, "Double quote save failure!");

			// adds in some japanese text, saves and reloads
			MetraTech.Localization.IEncodingHelper encoder = new MetraTech.Localization.EncodingHelper();
			string japaneseUTF8 = encoder.GetUTF8EncodedString("調整金�?");
			xml = xml.Replace("I am a \"quoted string\"!", japaneseUTF8);
			error.SaveXMLMessage(xml, null);
			xml = error.XMLMessage;
			Assert.IsTrue(xml.IndexOf(japaneseUTF8) > 0, "Multibyte save failed!");

			// resubmits the corrected failure
			BulkFailedTransactions bulkFailed = new BulkFailedTransactions();
			ConsoleProgress consProgress = new ConsoleProgress();

			MetraTech.Interop.PipelineControl.IMTCollection set =
				(MetraTech.Interop.PipelineControl.IMTCollection)
				new MetraTech.Interop.GenericCollection.MTCollection();
			set.Add(sessionID);
			MetraTech.Interop.Rowset.IMTSQLRowset exceptions = bulkFailed.ResubmitCollection(set, consProgress);

			while (!System.Convert.ToBoolean(exceptions.EOF))
			{
				string uid = (string) exceptions.get_Value("tx_uid_encoded");
				string exception = (string) exceptions.get_Value("exception");
				TestLibrary.Trace("{0}: {1}\n", uid, exception);
				exceptions.MoveNext();
			}

			TestLibrary.Trace("Waiting for corrected failure to complete processing...");
			TestLibrary.WaitForSessionCompletion(sessionID);
		}

		// Tests saving a failed transaction with a child deletion
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T11TestSaveMSIXWithChildDeletion()
		{
			int failedCount = GetFailureCount();

			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "FailedTransaction.TestSaveMSIXWithChildDeletion", 1);

			// meters a fresh compound failure
			TestLibrary.Trace("Metering bad compound...");
			ISession session = Sdk.CreateSession("metratech.com/testparent");
			session.InitProperty("description", "TestSaveMSIXWithChildDeletion");
			session.InitProperty("time", MetraTech.MetraTime.Now);
			session.InitProperty("accountname", "demo");
			session.InitProperty("_CollectionID", batchUID);

			ISession child1 = session.CreateChildSession("metratech.com/testservice");
			TestLibrary.InitializeSession(child1, true, null);

			ISession child2 = session.CreateChildSession("metratech.com/testservice");
			TestLibrary.InitializeSession(child2, false, null);

			ISession child3 = session.CreateChildSession("metratech.com/testservice");
			TestLibrary.InitializeSession(child3, true, null);

			session.Close();
			TestLibrary.WaitForBatchCompletion(Sdk, batchUID);


			// retrieves (generates) the failure's MSIX from the DB
			string rootSessionID = TestLibrary.GetSessionUIDFromBatch(batchUID);
			IMTSessionError error = GetSessionError(rootSessionID);
			Assert.AreEqual(rootSessionID, error.RootSessionID, "IMTSessionError root session ID mismatch!");

			string xml = error.XMLMessage;
			if (xml.IndexOf("demoERROR") <= 0)
				Assert.Fail("Failure account name not found!");
			
			MetraTech.Interop.GenericCollection.IMTCollection childrenToDelete;
			childrenToDelete = TestLibrary.GetChildrenSessionUIDsFromParent("t_svc_testservice", rootSessionID);

			TestLibrary.Trace("Saving edited XML and deleting all children");
			error.SaveXMLMessage(xml, (MetraTech.Interop.PipelineControl.IMTCollection) childrenToDelete);


			// resubmits the corrected failure
			TestLibrary.Trace("Resubmitting corrected compound...");
			MetraTech.Interop.PipelineControl.IMTCollection set =
				(MetraTech.Interop.PipelineControl.IMTCollection)
				new MetraTech.Interop.GenericCollection.MTCollection();
			set.Add(error.sessionID);

			BulkFailedTransactions bulkFailed = new BulkFailedTransactions();
			ConsoleProgress consProgress = new ConsoleProgress();
			bulkFailed.ResubmitCollection(set, null);

			TestLibrary.Trace("Waiting for corrected failure to complete processing...");
			TestLibrary.WaitForSessionCompletion(error.RootSessionID);

			// validates there were no new failures
			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);
			Assert.AreEqual(failedCount, newFailedCount, "Failure count should not have changed!");
		}
		
		// Tests that a resubmitted failure arrives with necessary
		// security context.
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T12TestResubmitFailureWithSecurityContext()
    {
			// meters the account creation failure (duplicate account name)
			int failedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} pre-existing failed transactions", failedCount);
			TestLibrary.Trace("Metering a failed account creation...", failedCount);
			TestLibrary.CreateAccount(Sdk, "demo", "", "monthly", 31, false); // asynchronous

			// waits for the failure to complete
 			TestLibrary.Trace("Waiting for failure to be processed... (20 sec)");
			Thread.Sleep(20000); // TODO: make this more precise
			int newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);
			Assert.AreEqual(failedCount + 1, newFailedCount, "Failure count should have increased by 1!");
				
			// retrieves (generates) the failure's MSIX from the DB
			IMTSessionError error = GetLastSessionError();
			string xml = error.XMLMessage;

			// edits the failure, changing the account name to a new unique name
			if (xml.IndexOf("demo") <= 0)
				Assert.Fail("Failure account name not found!");
			xml = xml.Replace("demo", String.Format("FailureUnitTest-{0}", DateTime.Now.ToString("s")));
			error.SaveXMLMessage(xml, null);

			// authenticates with the bulk failure object
			// this session context will be sent with the resubmitted message (via Billing Rerun)
			Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
			Auth.IMTSessionContext sessionContext = loginContext.Login("su", "system_user", "su123");
			IBulkFailedTransactions bulkFailures = new BulkFailedTransactions();
			bulkFailures.SessionContext = sessionContext;

			// resubmits the transaction asynchronously (since this is how MetraControl does it)
			TestLibrary.Trace("Asynchronously resubmitting failed account creation (should succeed)...");
			MetraTech.Interop.PipelineControl.IMTCollection failureCollection =
				(MetraTech.Interop.PipelineControl.IMTCollection) new MTCollection();
			failureCollection.Add(error.RootSessionID);
			int rerunID = bulkFailures.ResubmitCollectionAsync(failureCollection);
			
			// polls until resubmission completes
			MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();
			rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext) sessionContext);
			rerun.ID = rerunID;
			rerun.Synchronous = false;
			while(!rerun.IsComplete()) 
			{
				TestLibrary.Trace("   waiting for async resubmission to complete...");
				Thread.Sleep(100); 
			}

			// the error was corrected so we shouldn't see it again!
			TestLibrary.Trace("Waiting for pipeline to process resubmission... (10 sec)");
			Thread.Sleep(10000); // TODO: make this more precise
			newFailedCount = GetFailureCount();
			TestLibrary.Trace("Found {0} failed transactions after processing", newFailedCount);

			Assert.AreEqual(failedCount, newFailedCount, "Failure count should not have changed!");
		}

		// Tests that a sequence of autoresubmitted session sets and successful session sets
		// do not result in application deadlock (see CR12601 for more detail)
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T13TestAutoresubmitAndSuccessSynchronization()
    {
			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "FailedTransaction.TestResubmitSuccessSynchronization", 400);

			TestLibrary.Trace("Metering pairs of partial failures and complete success session sets...");
			for (int i = 0; i < 100; i++)
			{
				// a partial bad set
				ISessionSet sessionSetA = Sdk.CreateSessionSet();
				ISession goodSession = sessionSetA.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(goodSession, false, batchUID);
				ISession badSession = sessionSetA.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(badSession, true, batchUID);

				// a good set
				ISessionSet sessionSetB = Sdk.CreateSessionSet();
				ISession session1 = sessionSetB.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session1, false, batchUID);
				ISession session2 = sessionSetB.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session2, false, batchUID);

				sessionSetA.Close();
				sessionSetB.Close();
			}
			TestLibrary.Trace("Session sets successfully metered");

			// validates that all work has been committed (that we aren't deadlocked)
			TestLibrary.Trace("Checking completion of batch...");
			TestLibrary.WaitForBatchCompletion(Sdk, batchUID);
			TestLibrary.Trace("Batch was Successfully completed");
		}

		private int GetFailureCount()
		{
			Failures.Refresh();
			return Failures.Count;
		}

		private IMTSessionError GetSessionError(string uid)
		{
			return (IMTSessionError) Failures[uid];
		}

		private IMTSessionError GetLastSessionError()
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                // retrieves the last session ID from t_failed_transaction
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
                        (!isOracle ?
                        "SELECT TOP 1 tx_FailureID_encoded FROM t_failed_transaction ORDER BY id_failed_transaction DESC" :
                        "select tx_FailureID_encoded from (select tx_FailureID_encoded from t_failed_transaction order by id_failed_transaction desc) where rownum <= 1")))
                {

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();
                        string uid = reader.GetString(0);
                        return (IMTSessionError)Failures[uid];
                    }
                }
            }
		}

		private IMeter Sdk
		{
			get
			{
				if (mSdk == null)
					mSdk = TestLibrary.InitSDK();

				return mSdk;
			}
		}

		private IMTSessionFailures Failures
		{
			get
			{
				if (mFailures == null)
					mFailures = new MTSessionFailuresClass();

				return mFailures;
			}
		}

		// meters a sesison set and validates that an expected exception was generated
		private void MeterAndAssertException(ISessionSet sessionSet, string expectedExceptionMessage)
		{
			try
			{
				sessionSet.Close();
			}
			catch (Exception e)
			{
				Assert.AreEqual(expectedExceptionMessage, e.Message);
				return;
			}
			Assert.Fail("Expected exception not generated!");
		}

		private bool isOracle 
		{
			get { return mConnInfo.DatabaseType == DBType.Oracle; }
		}

		IMeter mSdk = null;
		IMTSessionFailures mFailures;
		string mFailureUID;
		public FailedTransactionTests()
		{
			mConnInfo = new ConnectionInfo("NetMeter");
		}
		ConnectionInfo mConnInfo;
	}
}

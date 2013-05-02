
//NUnit-Console.exe /assembly:MetraTech.Pipeline.ReRun.TestDBQueue.dll

using System.Runtime.InteropServices;
using System.EnterpriseServices;

//[assembly: System.EnterpriseServices.ApplicationName("MetraNet")]


[assembly: GuidAttribute("c4de4160-3380-4c36-96a9-bce9e2108567")]
[assembly: ComVisible(false)]

namespace MetraTech.Pipeline.ReRun.TestDBQueue
{
	using System;
	using System.Text;
	using System.Text.RegularExpressions;
	using System.Diagnostics;

	using NUnit.Framework;
	using MetraTech.Test;

	using MetraTech.DataAccess;
	using MetraTech.Interop.COMMeter;
	using MetraTech.Interop.MTBillingReRun;
	using MetraTech.Interop.MTAuth;
	using MetraTech.Interop.PipelineTransaction;
	using MetraTech.Pipeline.ReRun;
	using MetraTech.Pipeline.Messages;

	[TestFixture]
	public class ReRunSmokeTestDBQueue
	{

		[Test]
		public void TestBackoutAndDeleteSession()
		{
			TestLibrary.Trace("Executing: TestBackoutAndDeleteSession");
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        string batchUID = TestLibrary.GenerateBatchUID(sdk, "ReRunSmokeTestDBQueue.TestBackoutAndDeleteSession", 1);

        ISession session = sdk.CreateSession("metratech.com/testservice");

        // intialize a session that will succeed
        TestLibrary.InitializeSession(session, false, batchUID);
        session.RequestResponse = false;
        session.Close();
        TestLibrary.WaitForBatchCompletion(sdk, batchUID);
        string sessionID = TestLibrary.GetSessionUIDFromBatch(batchUID);

        TestLibrary.Trace("Setting up billing rerun task");

        MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();

        MetraTech.Interop.MTBillingReRun.IMTSessionContext context = Login();
        rerun.Login(context);

        rerun.Setup("smoke test of backout");
        int rerunID = rerun.ID;

        IMTIdentificationFilter filter = rerun.CreateFilter();

        filter.AddSessionID(sessionID);
        TestLibrary.Trace("rerun {0} created", rerun.ID);

        TestLibrary.Trace("...identifying and analyzing");
        rerun.IdentifyAndAnalyze(filter, "IdentiyAndAnalyze sessionid filter");

        string tableName = rerun.TableName;
        TestLibrary.Trace("the table name is : {0}", tableName);
        int identified = CountIdentifiedSessions(tableName);
        Assert.AreEqual(1, identified, "incorrect number of sessions identified");

        TestLibrary.Trace("...backing out and deleting");
        rerun.BackoutDelete("Backout and delete for session id filter");

        //check the result
        /*int sessionsLeftBehind = -1;
        using(IMTConnection conn = ConnectionManager.CreateConnection())
        {
          StringBuilder query = new StringBuilder();
          query.Append("select count(*) from t_acc_usage where tx_uid = ");
          query.Append(sessionID);
          using(IMTStatement stmt = conn.CreateStatement(query.ToString()))
          {
  				
          using(IMTDataReader reader = stmt.ExecuteReader())
          {
            reader.Read();
  						
            sessionsLeftBehind = reader.GetInt32(0);
          }
          }
        }
        if (sessionsLeftBehind != 0)
          Assert.Fail("Backout Delete of a particular sessionID failed");*/

        TestLibrary.Trace("Done");
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		[Test]
		public void TestBackoutAndDeleteBatchWithNoErrors()
		{
			TestLibrary.Trace("Executing: TestBackoutAndDeleteBatchWithNoErrors");

			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        int sessionsPerSet = 2;
        int sessionSets = 5;
        int errors = 0;

        string batchID = TestLibrary.CreateAndMeterBatch(sdk, sessionSets, sessionsPerSet, errors);
        TestLibrary.WaitForBatchCompletion(sdk, batchID);
        sdk.Shutdown();

        int rerunID = BackOutAndDeleteBatch(batchID);

        int completed = TestLibrary.CountCompletedSessions(batchID);
        int failed = TestLibrary.CountFailedSessions(batchID);

        if (completed != 0 || failed != 0)
          Assert.Fail(string.Format("Not all sessions backed out - {0} successes and {1} failures remain)",
            completed, failed));

        TestLibrary.Trace("Done");
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		[Test]
		public void TestBackoutAndDeleteBatchWithErrors()
		{
			TestLibrary.Trace("Executing: TestBackoutAndDeleteBatchWithErrors");
			
			IMeter sdk = null;
      try
      {
              sdk = TestLibrary.InitSDK();
			  int sessionsPerSet = 3;
			  int sessionSets = 5;
			  int errors = 1;

			  string batchID = TestLibrary.CreateAndMeterBatch(sdk, sessionSets, sessionsPerSet, errors);
			  TestLibrary.WaitForBatchCompletion(sdk, batchID);
			  sdk.Shutdown();

			  int rerunID = BackOutAndDeleteBatch(batchID);

			  int completed = TestLibrary.CountCompletedSessions(batchID);

			  int failed = TestLibrary.CountFailedSessions(batchID);

			  if (completed != 0 || failed != 0)
				  Assert.Fail(string.Format("Not all sessions backed out - {0} successes and {1} failures remain)",
																		   completed, failed));

			  TestLibrary.Trace("Done");
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		[Test]
    
		public void TestBackoutAndResubmitBatchWithErrors()
		{
			TestLibrary.Trace("Executing: TestBackoutAndResubmitBatchWithErrors");

			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
			  int sessionsPerSet = 3;
			  int sessionSets = 5;
			  int errors = 1;

			  string batchID = TestLibrary.CreateAndMeterBatch(sdk, sessionSets, sessionsPerSet, errors);
			  TestLibrary.WaitForBatchCompletion(sdk, batchID);
			  sdk.Shutdown();

			  int rerunID = BackoutAndRerunBatch(batchID);

			  System.Threading.Thread.Sleep(30 * 1000);

			  int completed = TestLibrary.CountCompletedSessions(batchID);
			  int failed = TestLibrary.CountFailedSessions(batchID);

			  if (completed != 10 || failed != 5)
				  Assert.Fail("Not all sessions successfully resubmitted");

			  TestLibrary.Trace("Done");
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		[Test]
		public void TestBackoutAndResubmitBatchWithNoErrors()
		{
			TestLibrary.Trace("Executing: TestBackoutAndResubmitBatchWithNoErrors");

			IMeter sdk = TestLibrary.InitSDK();
      try
      {
			  int sessionsPerSet = 3;
			  int sessionSets = 5;
			  int errors = 0;

			  string batchID = TestLibrary.CreateAndMeterBatch(sdk, sessionSets, sessionsPerSet, errors);
			  TestLibrary.WaitForBatchCompletion(sdk, batchID);
			  sdk.Shutdown();

			  int rerunID = BackoutAndRerunBatch(batchID);

			  System.Threading.Thread.Sleep(30 * 1000);

			  int completed = TestLibrary.CountCompletedSessions(batchID);
			  int failed = TestLibrary.CountFailedSessions(batchID);

			  if (completed != 15 || failed != 0)
				  Assert.Fail("Not all sessions successfully resubmitted");

			  TestLibrary.Trace("Done");
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		public static MetraTech.Interop.MTBillingReRun.IMTSessionContext Login()
		{
			IMTLoginContext login = new MTLoginContext();
			MetraTech.Interop.MTBillingReRun.IMTSessionContext context =
				(MetraTech.Interop.MTBillingReRun.IMTSessionContext) login.Login("su", "system_user", "su123");
			return context;
		}

		private int BackOutAndDeleteBatch(string batchID)
		{
			TestLibrary.Trace("Setting up billing rerun task");
			MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();

			MetraTech.Interop.MTBillingReRun.IMTSessionContext context = Login();
			rerun.Login(context);

			rerun.Setup("backout and delete by batchid");

			IMTIdentificationFilter filter = rerun.CreateFilter();

			filter.BatchID = batchID;
			TestLibrary.Trace("rerun {0} created", rerun.ID);

			TestLibrary.Trace("...identifying and analyzing");
			rerun.IdentifyAndAnalyze(filter, "Filter is batchID");

			TestLibrary.Trace("...backing out and deleting");
			rerun.BackoutDelete("Backout and Delete with batch id as the filter");
			
			return rerun.ID;
		}

		private int BackoutAndRerunBatch(string batchID)
		{
			TestLibrary.Trace("Setting up billing rerun task");
			MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();

			MetraTech.Interop.MTBillingReRun.IMTSessionContext context = Login();
			rerun.Login(context);

			rerun.Setup("backout and delete by batchid");

			IMTIdentificationFilter filter = rerun.CreateFilter();

			filter.BatchID = batchID;
			TestLibrary.Trace("rerun {0} created", rerun.ID);

			TestLibrary.Trace("...identifying and analyzing");
			rerun.IdentifyAndAnalyze(filter, "Filter is batchID");

			TestLibrary.Trace("...backing out and resubmitting");
			rerun.BackoutResubmit("Backout and Resubmit with batch id as the filter");
			
			return rerun.ID;
		}

		private int CountIdentifiedSessions(string tableName)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                StringBuilder query = new StringBuilder();
                query.Append("select count(*) from ");
                query.Append(tableName);
                query.Append(" where tx_state = 'E' or tx_state = 'A'");
                using (IMTStatement stmt = conn.CreateStatement(query.ToString()))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();

                        return reader.GetInt32(0);
                    }
                }
            }
		}
	}

  [TestFixture]
  //Run this fixture after 
  public class TestIdentifyDBQueue
  {
    [Test]
    public void TestServiceDefFilter()
    {
      // get a count of number of records in t_svc_testservice
      //meter test service to demo account 5 sessions with description 'TestServiceDefFilter'
      //do a identify on testservice
      //
      int initialCount;  //jnot a good measure... the counts will be off if there are suspended transactions
      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
        StringBuilder query = new StringBuilder();
        query.Append("select count(*) from t_svc_testservice");
        using (IMTStatement stmt = conn.CreateStatement(query.ToString()))
        {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                reader.Read();

                initialCount = reader.GetInt32(0);
            }
        }
      }

      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        int sessionsPerSet = 2;
        int sessionSets = 5;
        int errors = 1;

        string batchID = TestLibrary.CreateAndMeterBatch(sdk, sessionSets, sessionsPerSet, errors);
        TestLibrary.WaitForBatchCompletion(sdk, batchID);
        sdk.Shutdown();
        // added 10 more new sessions

        MetraTech.Pipeline.ReRun.Client rerun = SetupRerun();
        IMTIdentificationFilter filter = rerun.CreateFilter();
   
        filter.AddServiceDefinition("metratech.com/testservice");
        int id = RunIdentify(rerun, filter, "filter is servicedef name");
        string tableName = rerun.TableName;
        
        int finalCount = CountIdentifiedSessions(tableName);
        Assert.AreEqual(10, finalCount-initialCount, "incorrect number of sessions identified");
        TestLibrary.Trace("Done: TestServiceDefFilter");
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }

    //[Ignore("ignore")]
    [Test]
    public void TestServicePropFilter()
    {
    }
    //[Ignore("ignore")]
    [Test]
    public void TestProductViewFilter()
    {
    }
    //[Ignore("ignore")]
    [Test]
    public void TestProductViewPropFilter()
    {
    }
    //[Ignore("ignore")]
    [Test]
    public void TestAccountIDFilter()
    {
      //get account id for beancounter001
    }
    //[Ignore("ignore")]
    [Test]
    public void TestAccountViewPropFilter()
    {
    }
    //[Ignore("ignore")]
    [Test]
    public void TestIntervalIDFilter()
    {
    }
    //[Ignore("ignore")]
    [Test]
    public void TestDateTimeFilter()
    {
    }

    private int RunIdentify(MetraTech.Pipeline.ReRun.Client rerun, MetraTech.Interop.MTBillingReRun.IMTIdentificationFilter filter, string filterName)
    {
      TestLibrary.Trace("...identifying");
      rerun.Identify(filter, filterName);

      return rerun.ID;
    }

    private MetraTech.Pipeline.ReRun.Client SetupRerun()
    {
      MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();
      MetraTech.Interop.MTBillingReRun.IMTSessionContext context = Login();
      rerun.Login(context);

      rerun.Setup("Running Identify Tests.");

      return rerun;
    }
 
   public static MetraTech.Interop.MTBillingReRun.IMTSessionContext Login()
    {
      IMTLoginContext login = new MTLoginContext();
      MetraTech.Interop.MTBillingReRun.IMTSessionContext context =
        (MetraTech.Interop.MTBillingReRun.IMTSessionContext) login.Login("su", "system_user", "su123");
      return context;
    }

    private int CountIdentifiedSessions(string tableName)
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            StringBuilder query = new StringBuilder();
            query.Append("select count(*) from ");
            query.Append(tableName);
            using (IMTStatement stmt = conn.CreateStatement(query.ToString()))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();

                    return reader.GetInt32(0);
                }
            }
        }
    }
  }
}
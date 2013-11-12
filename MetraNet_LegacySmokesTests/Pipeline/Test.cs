using System.Runtime.InteropServices;

namespace MetraTech.Pipeline.Test
{
	using System;
	using System.Collections;

	using NUnit.Framework;
	using MetraTech.Test;

	using MetraTech.DataAccess;
	using MetraTech.Pipeline.Messages;
	using MetraTech.Pipeline.ReRun;

	using MetraTech.Interop.MTProductCatalog;
	using MetraTech.Interop.PipelineTransaction;
	using MetraTech.Interop.PipelineControl;
	using MetraTech.Interop.COMMeter;
	using MetraTech.Interop.MTDecimalOps;
	using MetraTech.Interop.Rowset;

  [TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class SmokeTest
	{

		[Test]
		public void T01TestSuspended()
		{
			// TODO: figure out a way to test correctness!
			SuspendedTxnManager txnManager = new SuspendedTxnManager();
			txnManager.FindAndResubmit();
			txnManager.FindAndResubmit();
		}


		[Test]
    [Ignore("DBLock isn't used anywhere but in this test.")]
    public void T02TestDBLock()
		{
			// NOTE: this really doesn't prove the lock is working
			using (DBLock appLock = new DBLock("MTTestLock"))
			{
				TestLibrary.Trace("Lock acquired.");
			}
			TestLibrary.Trace("Lock released.");
		}


		[Test]
    public void T03TestMTDec()
		{
			MTDecimalOps ops = new MTDecimalOps();


			// simulate divide by zero
			bool gotError = false;
			try
			{
				object decVal = ops.Create("123.456");
				object decVal2 = ops.Create("0.0");
				object devVal3 = ops.Divide(decVal, decVal2);
			}
			catch (DivideByZeroException err)
			{
				gotError = true;
				TestLibrary.Trace("received expected error: {0}", err.ToString());
			}
			if (!gotError)
				Assert.Fail("expected error not received");
		}


		[Test]
    public void T04TestPipelineConfig()
		{
			PipelineConfig config = new PipelineConfig();

			foreach (MetraTech.PipelineInterop.PipelineQueue queue in config.PipelineQueues)
			{
				TestLibrary.Trace("queue = {0}, machine = {1}", queue.Name, queue.MachineName);
			}

		}


		[Test]
    [Ignore("This test breaks NUNIT. Disabling for now")]
    public void T05TestEncode()
		{
			MessageUtils utils = new MessageUtils();
			string message = "<msix><timestamp>2002-10-07T21:08:01Z</timestamp><version>2.0</version><uid>wKgB2fgKwZ4pE/ZYw3cvPQ==</uid><entity>192.168.1.217</entity><beginsession><dn>metratech.com/TestService</dn><uid>wKgB2aj8vZ6D1vsgwncvPQ==</uid><commit>Y</commit><insert>Y</insert><properties><property><dn>Units</dn><value>1.000000000000000e+002</value></property><property><dn>Time</dn><value>1998-10-13T18:54:39Z</value></property><property><dn>Description</dn><value>Test Service4</value></property><property><dn>AccountName</dn><value>demo</value></property></properties></beginsession></msix>";
			string uid = "wKgB2fgKwZ4pE/ZYw3cvPQ==";

			string encoded = utils.EncodeMessage(message, uid, true, true);


			string sourceUid;
			string sourceMessageUid;
			string decoded = utils.DecodeMessage(encoded, out sourceUid,
																					 out sourceMessageUid);

			TestLibrary.Trace("-- originalLength: " + message.Length);
			TestLibrary.Trace("-- original: " + message);
			TestLibrary.Trace("-- encoded: " + encoded);
			TestLibrary.Trace("-- decoded: " + decoded);
			TestLibrary.Trace("-- uid: " + sourceUid);
			TestLibrary.Trace("-- message uid: " + sourceMessageUid);
			Assert.AreEqual(message, decoded);
		}


		[Test]
    [Ignore("This test breaks NUNIT. Disabling for now")]
    public void T06TestEncrypt()
		{
			MetraTech.PipelineInterop.DataUtils dataUtils = new MetraTech.PipelineInterop.DataUtils();
			byte [] dataBytes = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 };

			for (int i = 0; i < dataBytes.Length; i++)
				System.Console.Write("{0} ", dataBytes[i]);
			TestLibrary.Trace();

			byte [] encryptedBytes = dataUtils.Encrypt(dataBytes);

			for (int i = 0; i < encryptedBytes.Length; i++)
				System.Console.Write("{0} ", encryptedBytes[i]);
			TestLibrary.Trace();

			int clearLength;
			dataUtils.Decrypt(encryptedBytes, out clearLength);

			for (int i = 0; i < clearLength; i++)
				System.Console.Write("{0} ", encryptedBytes[i]);
			TestLibrary.Trace();

			for (int i = 0; i < clearLength; i++)
				Assert.AreEqual(encryptedBytes[i], dataBytes[i]);
		}


		[Test]
    public void T07TestCompress()
		{
			MetraTech.PipelineInterop.DataUtils dataUtils = new MetraTech.PipelineInterop.DataUtils();
			byte [] dataBytes = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 10 };

			int originalLength = dataBytes.Length;

			for (int i = 0; i < dataBytes.Length; i++)
				Console.Write("{0} ", dataBytes[i]);
			TestLibrary.Trace();

			int compressedLen;
			byte [] compressedBytes = dataUtils.Compress(dataBytes, out compressedLen);

			for (int i = 0; i < compressedLen; i++)
				System.Console.Write("{0} ", compressedBytes[i]);
			TestLibrary.Trace();

			byte [] compressedBuffer = new byte[compressedLen];
			Array.Copy(compressedBytes, compressedBuffer, compressedLen);
			byte [] decompressed = dataUtils.Decompress(compressedBuffer, out originalLength);

			for (int i = 0; i < originalLength; i++)
				System.Console.Write("{0} ", decompressed[i]);
			TestLibrary.Trace();

			for (int i = 0; i < originalLength; i++)
				Assert.AreEqual(dataBytes[i], decompressed[i]);
		}


		[Test]
    public void T08TestReadMSIXDef()
		{
			ServiceDefinitionCollection collection = new ServiceDefinitionCollection();
			IServiceDefinition serviceDef = collection.GetServiceDefinition("metratech.com/audioconfcall");

			TestLibrary.Trace("name = {0}, desc = {1}",
															 serviceDef.Name,
															 serviceDef.Description);

			foreach (IMTPropertyMetaData propMeta in serviceDef.Values)
			{
				TestLibrary.Trace("name = {0}, type = {1}, length = {2}, required = {3}, defaultValue = {4}",
																 propMeta.Name, propMeta.DataType, propMeta.Length, propMeta.Required, propMeta.DefaultValue);

				IMTAttributes attributes = propMeta.Attributes;
				foreach (IMTAttribute attr in attributes)
				{
					TestLibrary.Trace("  {0} = {1}", attr.Name, attr.Value);
				}
			}

			TestLibrary.Trace("Account identifiers:");
			IEnumerable accountIdentifiers = serviceDef.AccountIdentifiers;
			foreach (AccountIdentifier accountID in accountIdentifiers)
			{
				TestLibrary.Trace("  {0}", accountID.MSIXProperty.Name);
			}
		}


		[Test]
		// always ignore!
		[Ignore("ignore")]
    public void T09TestResubmitAll()
		{
			PipelineConfig pipeConfig = new PipelineConfig();

			IMTSessionFailures failures =
				(IMTSessionFailures) new MTSessionFailures();

			failures.Refresh();

			BulkFailedTransactions bulkFailed = new BulkFailedTransactions();
			ConsoleProgress consProgress = new ConsoleProgress();


			MetraTech.Interop.PipelineControl.IMTCollection set =
				(MetraTech.Interop.PipelineControl.IMTCollection)
				new MetraTech.Interop.GenericCollection.MTCollection();

			int count = 0;
			foreach (IMTSessionError error in failures)
			{
				set.Add(error.sessionID);
				TestLibrary.Trace(error.sessionID);
				count++;
			}

			DateTime before = DateTime.Now;
			bulkFailed.ResubmitCollection(set, consProgress);
			DateTime after = DateTime.Now;

			TestLibrary.Trace("{0} sessions resubmitted in {1}", count, (after - before));
		}

		[Test]
    public void T10TestMultipleErrors()
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISessionSet sessionSet = sdk.CreateSessionSet();

        ISession session1 = sessionSet.CreateSession("metratech.com/testservice");
        TestLibrary.InitializeSession(session1, false, null);
        session1.InitProperty("extraprop", "abcd");

        ISession session2 = sessionSet.CreateSession("metratech.com/testservice");
        TestLibrary.InitializeSession(session2, false, null);
        session2.InitProperty("badprop2", "abcd");

        ISession session3 = sessionSet.CreateSession("metratech.com/testservice");
        TestLibrary.InitializeSession(session3, false, null);

        try
        {
          sessionSet.Close();
        }
        catch (COMException err)
        {
          TestLibrary.Trace(err.ToString());
        }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		[Test]
    [Ignore]
    public void T11TestTxnPlugIn()
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
			  ISessionSet sessionSet = sdk.CreateSessionSet();

			  ISession session = sessionSet.CreateSession("metratech.com/testpi");
			  session.InitProperty("Duration", 100);
			  // intialize a session that will succeed
			  TestLibrary.InitializeSession(session, false, null);

			  MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
				  new MetraTech.Interop.PipelineTransaction.CMTTransaction();
        try
        {
			    transaction.Begin("PlugIn transaction test", 600 * 1000);

			    MetraTech.Interop.PipelineTransaction.IMTWhereaboutsManager whereAboutsMan =
				    new CMTWhereaboutsManager();

			    string transactionID = transaction.Export(whereAboutsMan.GetLocalWhereabouts());
			    sessionSet.TransactionID = transactionID;
			    session.RequestResponse = true;
				  sessionSet.Close();
          transaction.Commit();
        }
			  catch (Exception err)
			  {
				  TestLibrary.Trace("failure: " + err.ToString());
				  transaction.Rollback();
				  Assert.Fail();
				  return;
			  }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		[Test]
    public void T12TestTxnPlugInCompound()
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
			  ISessionSet sessionSet = sdk.CreateSessionSet();

			  ISession session = sessionSet.CreateSession("metratech.com/testparent");
			  //session.InitProperty("Duration", 100);
			  // intialize a session that will succeed

			  session.InitProperty("description", "batch/rerun test");
			  session.InitProperty("time", MetraTech.MetraTime.Now);
			  session.InitProperty("accountname", "demo");

			  //TestLibrary.InitializeSession(session, false, null);


			  ISession child = session.CreateChildSession("metratech.com/testservice");

			  TestLibrary.InitializeSession(child, false, null);

			  ISession child2 = session.CreateChildSession("metratech.com/testservice");

			  TestLibrary.InitializeSession(child2, false, null);

			  MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
				  new MetraTech.Interop.PipelineTransaction.CMTTransaction();

			  transaction.Begin("PlugIn transaction test", 600 * 1000);
        try
        {
			    MetraTech.Interop.PipelineTransaction.IMTWhereaboutsManager whereAboutsMan =
				    new CMTWhereaboutsManager();

			    string transactionID = transaction.Export(whereAboutsMan.GetLocalWhereabouts());
			    sessionSet.TransactionID = transactionID;
			    session.RequestResponse = true;
				  sessionSet.Close();
          transaction.Commit();
        }
			  catch (Exception err)
			  {
				  TestLibrary.Trace("failure: " + err.ToString());
				  transaction.Rollback();
				  Assert.Fail();
				  return;
			  }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }

		[Test]
		[Ignore("ignore")]
    public void T13TestTxnPlugInAudioConf()
		{
			IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
			  ISessionSet sessionSet = sdk.CreateSessionSet();

			  ISession session = sessionSet.CreateSession("metratech.com/audioconfcall");

			  session.InitProperty("ConferenceID", "199903195095819");
			  session.InitProperty("Payer", "demo");
			  session.InitProperty("AccountingCode", "GL99A");
			  session.InitProperty("ConferenceName", "Expo Meeting");
			  session.InitProperty("ConferenceSubject", "Tradeshow meeting with partners");
			  session.InitProperty("OrganizationName", "MetraTech Corp.");
			  session.InitProperty("SpecialInfo", "Auto start");
			  session.InitProperty("SchedulerComments", "Second conference for tradeshow");
			  session.InitProperty("ScheduledConnections", 1);
			  session.InitProperty("ScheduledStartTime", "2004-01-16T05:00:00Z");
			  session.InitProperty("ScheduledTimeGMTOffset", 5);
			  session.InitProperty("ScheduledDuration", 4);
			  session.InitProperty("CancelledFlag", false);
			  session.InitProperty("CancellationTime", "2004-01-16T05:01:00Z");
			  session.InitProperty("ServiceLevel", "Standard");
			  session.InitProperty("TerminationReason", "Normal");
			  session.InitProperty("SystemName", "Bridge1");
			  session.InitProperty("SalesPersonID", "Amy");
			  session.InitProperty("OperatorID", "Philip");

			  //session.InitProperty("Duration", 100);
			  // intialize a session that will succeed

			  //TestLibrary.InitializeSession(session, false, null);

			  for (int i = 0; i < 20; i++)
			  {
				  ISession child = session.CreateChildSession("metratech.com/audioconfconnection");

				  child.InitProperty("ConferenceID", "199903195095819");
				  child.InitProperty("Payer", "demo");
				  child.InitProperty("UserBilled", "N");
				  child.InitProperty("UserName", "pkenny");
				  child.InitProperty("UserRole", "CSR");
				  child.InitProperty("OrganizationName", "MetraTech Corp.");
				  child.InitProperty("userphonenumber", "781 398 2242");
				  child.InitProperty("specialinfo", "Expo update");
				  child.InitProperty("CallType", "Dial-In");
				  child.InitProperty("transport", "Toll");
				  child.InitProperty("Mode", "Direct-Dialed");
				  child.InitProperty("ConnectTime", "2004-01-16T05:02:03Z");
				  child.InitProperty("EnteredConferenceTime", "2004-01-16T05:02:03Z");
				  child.InitProperty("ExitedConferenceTime", "2004-01-16T05:20:07Z");
				  child.InitProperty("DisconnectTime", "2004-01-16T05:32:03Z");
				  child.InitProperty("Transferred", "N");
				  child.InitProperty("TerminationReason", "Normal");
				  child.InitProperty("ISDNDisconnectCause", 0);
				  child.InitProperty("TrunkNumber", 10);
				  child.InitProperty("LineNumber", 35);
				  child.InitProperty("DNISDigits", "781 398 2000");
				  child.InitProperty("ANIDigits", "781 398 2242");
			  }

			  for (int i = 0; i < 7; i++)
			  {
				  ISession child = session.CreateChildSession("metratech.com/audioconffeature");
				  child.InitProperty("Payer", "demo");
				  child.InitProperty("FeatureType", "QA");
				  child.InitProperty("Metric", "33.556122");
				  child.InitProperty("StartTime", "2004-01-16T05:00:00Z");
				  child.InitProperty("EndTime", "2004-01-16T05:11:00Z");
				  child.InitProperty("transactionid", "2004-01-16T05:11:00Z");
			  }

			  MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
				  new MetraTech.Interop.PipelineTransaction.CMTTransaction();

			  transaction.Begin("PlugIn transaction test", 600 * 1000);
        try
        {
			    MetraTech.Interop.PipelineTransaction.IMTWhereaboutsManager whereAboutsMan = new CMTWhereaboutsManager();
			    string transactionID = transaction.Export(whereAboutsMan.GetLocalWhereabouts());
			    sessionSet.TransactionID = transactionID;
			    session.RequestResponse = true;
				  sessionSet.Close();
          transaction.Commit();
        }
			  catch (Exception err)
			  {
				  TestLibrary.Trace("failure: " + err.ToString());
				  transaction.Rollback();
				  Assert.Fail();
				  return;
			  }
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
    }
    
		[Test]
    public void T14TestXMLEscaping()
		{
      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK(); 
        ISession session = sdk.CreateSession("metratech.com/testservice");
			  // intialize a session that will succeed
			  TestLibrary.InitializeSession(session, false, null);

			  session.SetProperty("description", "this < is a test");

			  session.RequestResponse = true;

			  session.Close();
      }
      finally
      {
        Marshal.ReleaseComObject(sdk);
      }
    }

		[Test]
		//[Ignore("ignore")]
    [Category("TestOverrideUID")]
    public void T15TestOverrideUID()
		{
      IMeter sdk = null;
      try
      {
        sdk = TestLibrary.InitSDK();
        ISession session = sdk.CreateSession("metratech.com/testparent");
        // intialize a session that will succeed
        TestLibrary.InitializeSession(session, false, null);

        string setid = MetraTech.Utils.MSIXUtils.CreateUID();
        string sessionid = MetraTech.Utils.MSIXUtils.CreateUID();
        string childid = MetraTech.Utils.MSIXUtils.CreateUID();
        session._ID = sessionid;
        session._SetID = setid;


        ISession child = session.CreateChildSession("metratech.com/testservice");
        TestLibrary.InitializeSession(child, false, null);
        child._ID = childid;

        TestLibrary.Trace("new session set ID " + setid);
        TestLibrary.Trace("new session ID " + sessionid);
        TestLibrary.Trace("new child session ID " + childid);

        //session.Close();
        string xml = session.ToXML();
        TestLibrary.Trace(xml);

        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
        session = null;

        ISessionSet sessionSet = sdk.CreateSessionSet();
        session = sessionSet.CreateSession("metratech.com/testparent");
        TestLibrary.InitializeSession(session, false, null);

        sessionSet._SetID = setid;
        session._ID = sessionid;

        xml = sessionSet.ToXML();
        TestLibrary.Trace(xml);
      }
      catch (Exception e)
      {
        Assert.Fail("TestOverrideUID failed with the following exception: " + e.Message);
      }
      finally
      {
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
	}

		[Test]
    public void T16TestDateFilter()
		{
			MetraTech.Interop.Rowset.IMTSQLRowset rowset = new MetraTech.Interop.Rowset.MTSQLRowset();
			rowset.Init("queries\\database");
			//rowset.SetQueryString("select 0 as foo, '2003-01-15 22:47:03' as mydate");
			rowset.SetQueryString("select id_entitytype as EntityType, dt_crt as Time from t_audit");
			rowset.ExecuteDisconnected();
			MetraTech.Interop.Rowset.IMTDataFilter dataFilter = new MetraTech.Interop.Rowset.MTDataFilter();
			dataFilter.Add("Time", "=", DateTime.Parse("2003-01-16 19:46:24.050"));
			dataFilter.Add("EntityType", "=", 2);

			dataFilter.IsWhereClause = false;
			TestLibrary.Trace(dataFilter.FilterString);
			// TODO: why is this cast necessary?
			rowset.Filter = (MetraTech.Interop.Rowset.MTDataFilter) dataFilter;

			TestLibrary.Trace("rows:");
			while (!System.Convert.ToBoolean(rowset.EOF))
			{
				TestLibrary.Trace("{0}", (int) rowset.get_Value("foo"));
				rowset.MoveNext();
			}
		}


		// Tests the managed implementation (MSIXDef.cs) of the table name truncation algorithm
		[Test]
    [Ignore("TableName truncation not used anymore.")]
    public void T17TestTableNameTruncation()
		{
      // pass this test if running under sqlserver.  Service Def table names
      // are only hashed under Oracle
      if (new ConnectionInfo("NetMeter").IsSqlServer)
        return;

			ServiceDefinitionCollection serviceDefs = new ServiceDefinitionCollection();

			// tests no hashing
			IServiceDefinition testDef = serviceDefs.GetServiceDefinition("metratech.com/testservice");
			Assert.AreEqual("testservice", testDef.TableName);

      // tests hashing
			IServiceDefinition archiveAuthDef = serviceDefs.GetServiceDefinition("metratech.com/ps_ach_findbyaccountidroutingnumberlast4type");
      Assert.IsTrue(archiveAuthDef.TableName.StartsWith("ps_ach_findbyaccounti_"));
      Assert.IsTrue(archiveAuthDef.TableName.Length == 30);
		}
	}

	[TestFixture]
  [Category("NoAutoRun")]
  [Ignore("")]
	[ComVisible(false)]
	public class SetupTests
	{
		[Test]
		public void TestCreateAccounts()
		{
			AggregateLibrary aggLib = new AggregateLibrary();
			aggLib.CreateAccounts();
		}
	}

	[ComVisible(false)]
	public class ConsoleProgress : MetraTech.Interop.MTProgressExec.IMTProgress
	{
		private string mProgressString;

		public void SetProgress(int aCurrentPos, int aMaxPos)
		{
			TestLibrary.Trace("progress: {0}/{1}: {2}%",
															 aCurrentPos, aMaxPos,
															 ((double) aCurrentPos / (double) aMaxPos) * 100.0);
		}

		public string ProgressString
		{
			get
			{
				return mProgressString;
			}
			set
			{
				TestLibrary.Trace("Progress string: {0}", value);
				mProgressString = value;
			}
		}

		public void Reset()
		{
			TestLibrary.Trace("Reset");
		}
	}
}
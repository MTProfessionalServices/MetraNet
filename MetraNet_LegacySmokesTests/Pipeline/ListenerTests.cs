using System.Runtime.InteropServices;

[assembly: GuidAttribute ("f884ed26-105c-4603-8951-0e3b2c5412c4")]

namespace MetraTech.Pipeline.Test
{
	using System;
	using System.Collections;
	using System.Threading;
	using System.ServiceProcess;

	using NUnit.Framework;
	using MetraTech.Test;

	using MetraTech.DataAccess;
	using MetraTech.Pipeline.Messages;
	using MetraTech.Interop.MTProductCatalog;
	using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
	using MetraTech.Interop.PipelineControl;
	using MetraTech.Interop.COMMeter;
	using MetraTech.Interop.MTDecimalOps;
	using MetraTech.Interop.Rowset;
	using System.EnterpriseServices;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Pipeline.Test.ListenerTests /assembly:O:\debug\bin\MetraTech.Pipeline.Test.dll
	//
	// NOTE: this test requires that the pipeline be started and running.

  
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class ListenerTests
	{
		[TestFixtureTearDown]
		public void CleanupTestData()
		{
			Setup.CleanupTestData();

      if (mSdk != null)
      {
        Marshal.ReleaseComObject(mSdk);
        mSdk = null;
      }
    }

		[TestFixtureSetUp]
		public void SetupTestData()
		{
			Setup.SetupTestData();
		}

		// Tests that metering to a bogus service definition fails
		[Test]
    public void T01TestUnknownServiceDefFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/i_dont_exist");

			session.InitProperty("Duration", 100);  // doesn't matter
			MeterAndAssertException(sessionSet, "Unable to find service definition named MetraTech.com/i_dont_exist");
    }


		// Tests that metering a heterogenous compound fails
		[Test]
    public void T02TestHeterogenousCompoundFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession sessionA = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(sessionA, false, null);
			ISession sessionB = sessionSet.CreateSession("metratech.com/testparent");
			MeterAndAssertException(sessionSet, "Session set contains more than one type of top-level session!");
    }


		// Tests that metering a session with missing required properties fails
		[Test]
    public void T03TestMissingRequiredPropertiesFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			MeterAndAssertException(sessionSet, 
															"Session of type 'MetraTech.com/TestService' is missing the following " + 
															"required properties: accountname; description; time; units");
    }


		// Tests that metering a session with extra properties fails
		[Test]
    public void T04TestExtraPropertyFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("ExtraProperty", "negative_test");

			MeterAndAssertException(sessionSet, "Session has an unknown property: ExtraProperty");
    }



		//
		// Integer property tests
		//

		// Tests that metering a session with an invalid integer value fails
		[Test]
    public void T05TestInvalidIntegerPropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("IntegerProperty", "negative_test");

			MeterAndAssertException(sessionSet, 
															"Property IntegerProperty (value=negative_test) could not be converted to the specified type");
		}

		// Tests that metering a session with overflowed integer value fails
		[Test]
    public void T06TestIntegerPropertyOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("IntegerProperty", "2147483648");  // 2^31

			MeterAndAssertException(sessionSet, 
															"Property IntegerProperty (value=2147483648) could not be converted to the specified type");
		}

		// Tests that metering a session with underflowed integer value fails
		[Test]
    public void T07TestIntegerPropertyNegativeOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("IntegerProperty", "-2147483649");  // -(2^31) - 1

			MeterAndAssertException(sessionSet, 
															"Property IntegerProperty (value=-2147483649) could not be " +
															"converted to the specified type");
		}

		// Tests that metering a session with a fractional integer value fails
		[Test]
    public void T08TestFractionalIntegerPropertyFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("IntegerProperty", "3.14159"); 

			MeterAndAssertException(sessionSet, 
															"Property IntegerProperty (value=3.14159) could not be " +
															"converted to the specified type");
		}

		// Tests that metering a blank integer property works
		[Test]
    public void T09TestBlankIntegerPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("IntegerProperty", ""); 

			sessionSet.Close();
			// TODO: shouldn't this fail?
		}


		
		//
		// Integer64 property tests
		//

		// Tests that metering a session with an invalid integer value fails
		[Test]
    public void T10TestInvalidInteger64PropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("Integer64Property", "negative_test");

			MeterAndAssertException(sessionSet, 
															"Property Integer64Property (value=negative_test) could not be converted to the specified type");
		}

		// Tests that metering a session with overflowed integer value fails
		[Test]
    public void T11TestInteger64PropertyOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("Integer64Property", "9223372036854775807");  // 2^63 - 1

			MeterAndAssertException(sessionSet, 
															"Property Integer64Property (value=9223372036854775807) could not be converted to the specified type");
		}

		// Tests that metering a session with underflowed integer value fails
		[Test]
    public void T12TestInteger64PropertyNegativeOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("Integer64Property", "-9223372036854775808");  // -2^63 + 1

			MeterAndAssertException(sessionSet, 
															"Property Integer64Property (value=-9223372036854775808) could not be " +
															"converted to the specified type");
		}

		// Tests that metering a session with a fractional integer value fails
		[Test]
    public void T13TestFractionalInteger64PropertyFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("Integer64Property", "3.14159"); 

			MeterAndAssertException(sessionSet, 
															"Property Integer64Property (value=3.14159) could not be " +
															"converted to the specified type");
		}

		// Tests that metering a blank int64 property works
		[Test]
    public void T14TestBlankInteger64PropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("Integer64Property", ""); 

			sessionSet.Close();
			// TODO: shouldn't this fail?
		}


		//
		// Decimal property tests
		//

		// Tests that metering a session with an invalid decimal value fails
		[Test]
    public void T15TestInvalidDecimalPropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("DecimalProperty", "negative_test");

			MeterAndAssertException(sessionSet, 
															"Property DecimalProperty (value=negative_test) could not be " +
															"converted to the specified type");
		}

		// Tests that metering a session with an overflowed decimal value fails
		[Test]
    public void T16TestDecimalPropertyOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			// maximum MT decimal value is 999,999,999,999.9999999999 (limited by numeric(22,10))
			// so adding 0.0000000001 should fail
			session.InitProperty("DecimalProperty", "1000000000000.0000000000");

			MeterAndAssertException(sessionSet, 
															"Property DecimalProperty (value=1000000000000.0000000000) could " +
															"not be converted to the specified type");
		}

		// Tests that metering a session with an underflowed decimal value fails
		[Test]
    public void T17TestDecimalPropertyNegativeOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			// minimum MT decimal value is -999,999,999,999.9999999999 (limited by numeric(22,10))
			// so adding -0.0000000001 should fail
			session.InitProperty("DecimalProperty", "-1000000000000.0000000000");

			MeterAndAssertException(sessionSet, 
															"Property DecimalProperty (value=-1000000000000.0000000000) could " + 
															"not be converted to the specified type");
		}

		// NOTE:  Decimal values with over 10 digits of scale will be rounded to
		// 10 digits of scale.  No validation error will be raised.  This is identical
		// to how WriteProductView handles this case.

		// Tests that metering a blank decimal property fails 
		// NOTE: yes, this is inconsistent with other blank test cases
		[Test]
    public void T18TestBlankDecimalPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("DecimalProperty", ""); 

			MeterAndAssertException(sessionSet, 
															"Property DecimalProperty (value=) could not be converted to the specified type");
		}



		//
		// Double property tests
		//

		// Tests that metering a session with an invalid double value fails
		[Test]
    public void T19TestInvalidDoublePropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("DoubleProperty", "negative_test");

			MeterAndAssertException(sessionSet,
															"Property DoubleProperty (value=negative_test) could not be " + 
															"converted to the specified type");
		}

		// Tests that metering a session with an overflowed decimal value fails
		[Test]
    public void T20TestDoublePropertyOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			// maximum double value is 999,999,999,999.999 (precision of 15)
			// so adding 0.001 should fail
  		session.InitProperty("DoubleProperty", "1000000000000.000");

			MeterAndAssertException(sessionSet, 
															"Property DoubleProperty (value=1000000000000.000) could " +
															"not be converted to the specified type");
		}

		// Tests that metering a session with an underflowed decimal value fails
		[Test]
    public void T21TestDoublePropertyNegativeOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

      // minimum MT double value is -999,999,999,999.999 (precision of 15)
			// so adding -0.001 should fail
  		session.InitProperty("DoubleProperty", "-1000000000000.000");

			MeterAndAssertException(sessionSet, 
															"Property DoubleProperty (value=-1000000000000.000) could " + 
															"not be converted to the specified type");
		}

		// Tests that metering a blank double property works
		[Test]
    public void T22TestBlankDoublePropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("DoubleProperty", ""); 

			sessionSet.Close();
			// TODO: shouldn't this fail?
		}



		
		//
		// Boolean property tests
		//

		// Tests that metering a session with an invalid boolean value fails
		[Test]
    public void T23TestInvalidBooleanPropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("BooleanProperty", "negative_test");

			MeterAndAssertException(sessionSet,
																					"Property BooleanProperty (value=negative_test) could not be " +
																					"converted to the specified type");
		}

		// Tests that metering a blank boolean property fails 
		// NOTE: yes, this is inconsistent with other blank test cases
		[Test]
    public void T24TestBlankBooleanPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("BooleanProperty", ""); 

			MeterAndAssertException(sessionSet,
																					"Property BooleanProperty (value=) could not be " +
																					"converted to the specified type");
		}

		

		//
		// Enum property tests
		//

		// Tests that metering a session with an invalid enum value fails
		[Test]
    public void T25TestInvalidEnumPropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("EnumProperty", "negative_test");

			MeterAndAssertException(sessionSet, 
																					"Property EnumProperty (value=negative_test) could not be " + 
																					"converted to the specified type");
		}

		// Tests that metering a blank enum property fails 
		// NOTE: yes, this is inconsistent with other blank test cases
		[Test]
    public void T26TestBlankEnumPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("EnumProperty", ""); 

			MeterAndAssertException(sessionSet,
																					"Property EnumProperty (value=) could not be " +
																					"converted to the specified type");
		}

		

		//
		// Timestamp property tests
		//

		// Tests that metering a session with an invalid timestamp value fails
		[Test]
    public void T27TestInvalidTimestampPropertyValueFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("TimestampProperty", "negative_test");

			MeterAndAssertException(sessionSet,
																					"Property TimestampProperty (value=negative_test) could not be " + 
																					"converted to the specified type");
		}

		// Tests that metering a session with an overflowed timestamp value fails
		[Test]
    public void T28TestTimestampPropertyOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("TimestampProperty", "3001-01-18T22:14:08Z");

			MeterAndAssertException(sessionSet, 
															"Property TimestampProperty (value=3001-01-18T22:14:08Z) could " + 
															"not be converted to the specified type");
		}

		// Tests that metering a session with an underflowed timestamp value fails
		[Test]
    public void T29TestTimestampPropertyNegativeOverflowFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("TimestampProperty", "1969-12-31T23:59:59Z");  // Jan 1, 1970 - 1 second

			MeterAndAssertException(sessionSet, 
															"Property TimestampProperty (value=1969-12-31T23:59:59Z) could " + 
															"not be converted to the specified type");
		}

		// Tests that metering a blank timestamp property fails 
		// NOTE: yes, this is inconsistent with other blank test cases
		[Test]
    public void T30TestBlankTimestampPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("TimestampProperty", ""); 

			MeterAndAssertException(sessionSet,
															"Property TimestampProperty (value=) could not be " +
															"converted to the specified type");
		}


		
		//
		// String property tests
		//

		// Tests that metering a session with too long of a string fails
		[Test]
    public void T31TestStringPropertyOverrunFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("StringProperty", 
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + 
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" +
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + 
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"); // 256

			MeterAndAssertException(sessionSet, "Property StringProperty is longer than the maximum string length.");
		}

		// Tests that metering a blank string property works 
		[Test]
    public void T32TTestBlankStringPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("StringProperty", ""); 
			
			sessionSet.Close();
		}
		
		// Tests that metering a session with too long of an encrypted string fails
		[Test]
    public void T34TestEncryptedStringPropertyOverrunFailure()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("EncryptedStringProperty_", 
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + 
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" +
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + 
													 "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"); // 256

			MeterAndAssertException(sessionSet, "Property EncryptedStringProperty_ is longer than the maximum string length.");
		}

		// Tests that metering a blank encrypted string property fails
		[Test]
    public void T35TestBlankEncryptedStringPropertyValue()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession session = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(session, false, null);

			session.InitProperty("EncryptedStringProperty_", ""); 
			
			MeterAndAssertException(sessionSet, 
															"Property EncryptedStringProperty_ (value=) could not be converted " + 
															"to the specified type");
		}



		//
		// Transactional send tests (ListenerTransactionID)
		//

		// Tests that sending a session set based on an external DTC transaction commits
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T36TestListenerTransactionIDCommit()
    {
			// creates a DTC transaction
      string batchUID = null;
			PipelineTransaction.IMTTransaction transaction = new PipelineTransaction.CMTTransaction();
			transaction.Begin("Unit test: TestListenerTransactionIDCommit", 1000 * 600);
      try
      {
			  PipelineTransaction.IMTWhereaboutsManager whereAbouts = new PipelineTransaction.CMTWhereaboutsManager();
			  string transactionID = transaction.Export(whereAbouts.GetLocalWhereabouts());

			  batchUID = TestLibrary.GenerateBatchUID(Sdk, "TestListenerTransactionIDCommit", 10);
			  ISessionSet sessionSet = Sdk.CreateSessionSet();

			  // specifies that the Listener should use this external transaction
			  // to perform its routing inserts for this session set
			  sessionSet.ListenerTransactionID = transactionID;

			  // meters a session set of 10 sessions
			  for (int i = 0; i < 10; i++)
			  {
				  ISession session = sessionSet.CreateSession("metratech.com/testservice");
				  TestLibrary.InitializeSession(session, false, batchUID);
			  }
			  sessionSet.Close();

			  // make sure nothing commits prematurely
			  Thread.Sleep(10000);
			  Assert.AreEqual( 0, TestLibrary.GetBatchCompletedCount(Sdk, batchUID),"No sessions should have completed because the listenter " +
														   "transaction hasn't yet committed!");

			  transaction.Commit();
      }
      catch (Exception e)
      {
        transaction.Rollback();
        Assert.Fail(String.Format("Unexpected TransactionIDCommit failure message: {0}", e.Message));
      }

		  TestLibrary.WaitForBatchCompletion(Sdk, batchUID);

			// meters a successful session to make sure nothing
			// is blocking it from completing
			ISession nonTxnSession = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(nonTxnSession, false, null);
			nonTxnSession.RequestResponse = true;
			nonTxnSession.Close();
		}

		// Tests that sending a session set based on an external DTC transaction rollbacks
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T37TestListenerTransactionIDRollback()
    {
			// creates a DTC transaction
      string batchUID = null;
			PipelineTransaction.IMTTransaction transaction = new PipelineTransaction.CMTTransaction();
			transaction.Begin("Unit test: TestListenerTransactionIDRollback", 1000 * 600);
      try
      {
        PipelineTransaction.IMTWhereaboutsManager whereAbouts = new PipelineTransaction.CMTWhereaboutsManager();
        string transactionID = transaction.Export(whereAbouts.GetLocalWhereabouts());

        batchUID = TestLibrary.GenerateBatchUID(Sdk, "TestListenerTransactionIDRollback", 10);
        ISessionSet sessionSet = Sdk.CreateSessionSet();

        // specifies that the Listener should use this external transaction
        // to perform its routing inserts for this session set
        sessionSet.ListenerTransactionID = transactionID;

        // meters a session set of 10 sessions
        for (int i = 0; i < 10; i++)
        {
          ISession session = sessionSet.CreateSession("metratech.com/testservice");
          TestLibrary.InitializeSession(session, false, batchUID);
        }
        sessionSet.Close();

        // make sure nothing commits prematurely
        Thread.Sleep(10000);
        Assert.AreEqual(0, TestLibrary.GetBatchCompletedCount(Sdk, batchUID), "No sessions should have completed because the listenter " +
                               "transaction hasn't yet committed!");
      }
      catch (Exception e)
      {
        transaction.Rollback();
        Assert.Fail(String.Format("Unexpected TransactionIDRollback failure message: {0}", e.Message));
      }
      finally
      {
        transaction.Rollback();
      }

			Assert.AreEqual(0, TestLibrary.GetBatchCompletedCount(Sdk, batchUID),
                      "No sessions should have completed because the listenter " +
											"transaction has rolled back!");

			// meters a successful session to make sure nothing
			// is blocking it from completing
			ISession nonTxnSession = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(nonTxnSession, false, null);
			nonTxnSession.RequestResponse = true;
			nonTxnSession.Close();
		}

		// Tests that sending a session set based on an external DTC transaction commits via Com Plus [AutoComplete]
		[Test]
    [Ignore("Failing - Ignore Test")]
		[Category("ComPlus")]
    public void T38TestListenerTransactionIDComPlusCommit()
		{
			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "TestListenerTransactionIDRollback", 10);
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			
			new ListenerComPlusTest().MeterAndCommit(sessionSet, batchUID);
			Thread.Sleep(10000);

			Assert.AreEqual(10, TestLibrary.GetBatchCompletedCount(Sdk, batchUID), "10 sessions should have completed because the listener " +
														 "transaction commited via COM+");

			// meters a successful session to make sure nothing
			// is blocking it from completing
			ISession nonTxnSession = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(nonTxnSession, false, null);
			nonTxnSession.RequestResponse = true;
			nonTxnSession.Close();
		}

		// Tests that sending a session set based on an external DTC transaction rollbacks via Com Plus mechanism
		[Test]
    [Ignore("Failing - Ignore Test")]
		[Category("ComPlus")]
    public void T39TestListenerTransactionIDComPlusRollback()
		{
			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "TestListenerTransactionIDComPlusRollback", 10);
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			try
			{
				new ListenerComPlusTest().MeterAndRollbackByComPlus(sessionSet, batchUID);
			}
			catch (ApplicationException)
			{
			}

			Thread.Sleep(10000);

			Assert.AreEqual(0, TestLibrary.GetBatchCompletedCount(Sdk, batchUID), "No sessions should have completed because the listener " +
														 "transaction has rolled back!");

			// meters a successful session to make sure nothing
			// is blocking it from completing
			ISession nonTxnSession = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(nonTxnSession, false, null);
			nonTxnSession.RequestResponse = true;
			nonTxnSession.Close();
		}

		[Test]
    [Ignore("Failing - Ignore Test")]
		[Category("ComPlus")]
    public void T40TestListenerTransactionIDValidationErrorRollback()
		{
			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "TestListenerTransactionIDRollback", 10);
			ISessionSet sessionSet = Sdk.CreateSessionSet();

			try 
			{
				new ListenerComPlusTest().MeterAndRollbackByListener(sessionSet, batchUID);
				Assert.Fail("Expected exception not generated!");

			}
			catch (Exception e)
			{
				Assert.AreEqual("The root transaction wanted to commit, but transaction aborted (Exception from HRESULT: 0x8004E002)", e.Message);
			}

			//Check that all inserts done in COM+ transaction were rolled back
			int count = 0;
			using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
			{
                using (IMTStatement stmt = conn.CreateStatement("select count(*) as count_rec from t_listener_test"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();
                        count = Convert.ToInt32(reader.GetValue("count_rec"));
                    }
                }
			}

			Assert.AreEqual(0, count, "No records should exist in the t_listener_test because the listener " +
											"transaction has rolled back!");


			// meters a successful session to make sure nothing
			// is blocking it from completing
			ISession nonTxnSession = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(nonTxnSession, false, null);
			nonTxnSession.RequestResponse = true;
			nonTxnSession.Close();
		}



		// Tests that sending one session set after another (both based on the same external DTC transaction)
		// commits successfully, and that no application deadlock occurs (DB blocking)
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T41TestListenerTransactionIDMultiSetCommit()
    {
			// creates a DTC transaction
      string batchUID = null;
			PipelineTransaction.IMTTransaction transaction = new PipelineTransaction.CMTTransaction();
			transaction.Begin("Unit test: TestListenerTransactionIDMultiSetCommit", 1000 * 600);
      try
      {
        PipelineTransaction.IMTWhereaboutsManager whereAbouts = new PipelineTransaction.CMTWhereaboutsManager();
        string transactionID = transaction.Export(whereAbouts.GetLocalWhereabouts());

        batchUID = TestLibrary.GenerateBatchUID(Sdk, "TestListenerTransactionIDMultiSetCommit", 20);
        ISessionSet sessionSetA = Sdk.CreateSessionSet();

        // specifies that the Listener should use this external transaction
        // to perform its routing inserts for this session set
        sessionSetA.ListenerTransactionID = transactionID;

        // meters a session set of 10 sessions
        for (int i = 0; i < 10; i++)
        {
          ISession session = sessionSetA.CreateSession("metratech.com/testservice");
          TestLibrary.InitializeSession(session, false, batchUID);
        }
        sessionSetA.Close();

        // meters a second session set before committing the transaction
        ISessionSet sessionSetB = Sdk.CreateSessionSet();

        // specifies that the Listener should use this external transaction
        // to perform its routing inserts for this session set
        sessionSetB.ListenerTransactionID = transactionID;

        // meters a session set of 10 sessions
        for (int i = 0; i < 10; i++)
        {
          ISession session = sessionSetB.CreateSession("metratech.com/testservice");
          TestLibrary.InitializeSession(session, false, batchUID);
        }

        // NOTE: this is where we'd block if someone is not using READCOMMITTED hints
        sessionSetB.Close();

        // make sure nothing commits prematurely
        Thread.Sleep(10000);
        Assert.AreEqual(0, TestLibrary.GetBatchCompletedCount(Sdk, batchUID), "No sessions should have completed because the listener " +
                               "transaction hasn't yet committed!");

        // Commit it! yeah baby, yeah!!
        transaction.Commit();
      }
      catch (Exception e)
      {
        transaction.Rollback();
        Assert.Fail(String.Format("Unexpected TransactionIDMultiSetCommit failure message: {0}", e.Message));
      }

      TestLibrary.WaitForBatchCompletion(Sdk, batchUID);

			// meters a successful session to make sure nothing
			// is blocking it from completing
			ISession nonTxnSession = Sdk.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(nonTxnSession, false, null);
			nonTxnSession.RequestResponse = true;
			nonTxnSession.Close();
		}

		//
		// Robustness tests
		//

		// Tests asynchronously metering a hundreds of concurrent sessions doesn't fail
		[Test]
    [Ignore("Failing - Ignore Test")]
		[Category("Concurrency")]
    public void T42TestConcurrentAsynchronousMetering()
    {
			string batchUID = TestLibrary.GenerateBatchUID(Sdk, "ListenerTests.TestConcurrentAsynchronousMetering", 5050);
			MeterConcurrently(100, false, batchUID);
			TestLibrary.WaitForBatchCompletion(Sdk, batchUID);
		}


		// Tests synchronously metering a hundreds of concurrent sessions doesn't fail
		[Test]
    [Category("Concurrency")]
    [Ignore("Ignoring TestConcurrentSynchronousMetering")]
    public void T43TestConcurrentSynchronousMetering()
    {
			MeterConcurrently(100, true, null);
		}

		// Tests that the listener (and pipeline) successfully recover when the DB goes down
		[Test]
		[Category("DatabaseConnectivityRecovery")]
		[Ignore("Ignoring the TestDatabaseConnectivityRecovery for SqlServer till Accountcredit can be succesfully metered")]
    public void T44TestDatabaseConnectivityRecovery()
    {
			if (isOracle)
			{
				TestLibrary.Trace("Database Connectivity Recovery tests have not been implemented for oracle yet!");
			}
			else
			{
				// synchronously meters a successful session to make sure everything is kosher
				TestLibrary.Trace("Metering good session before database restart");
				ISession sessionA = Sdk.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(sessionA, false, null);
				sessionA.RequestResponse = true;
				sessionA.Close();
				TestLibrary.Trace("Processed successfully");

				try
				{
					RestartSQLServer();
      
					// we need to "prime" the pipeline after restart to get passed a
					// certain amount of failures and/or suspended transactions caused
					// by the connectivity loss. these are "normal" and are part of the
					// recovery process. each of the following Prime methods below meters
					// until it can validate that what it sent was successfully processed
					// NOTE: priming ensures that tests run after this test won't fail
					Thread.Sleep(5000);

					PrimeRouterAndWPV();
					PrimeFailureWriter();
					PrimeAccountCreation();
					PrimeGSMAccountCreation();
					PrimeSystemAccountCreation();
					PrimeAccountCredit();
					PrimeAccountMapping();
					PrimeAddCharge();
				
					// resubmits any suspended transactions this test may have created
					// this is a great oppurtunity to test autorestart functionallity
					// sessions may fail upon resubmission but we don't really care
					TestLibrary.Trace("Resubmitting any suspended transactions that were generated");
					SuspendedTxnManager txnManager = new SuspendedTxnManager();
					int resubmitted = txnManager.FindAndResubmit(0); // consider anything not complete suspended!
					TestLibrary.Trace("  {0} messages resubmitted", resubmitted);
					if (resubmitted > 0)
					{
						// be a good nunit citizen and wait for your asynchronous work to complete
						TestLibrary.Trace("  waiting 5 sec for them to process");
						Thread.Sleep(5000);
					}

				} 
				catch (Exception)
				{
					// always restart pipeline and W3SVC after a failure
					// to eliminate DB failures due to lack of priming in subsequent smoketests
					TestLibrary.RestartPipeline();
					TestLibrary.RestartWebServer();

					throw;
				}
			}
			
		}



		//
		// Auth-auth tests
		//

		// Tests that the listener (and router) handle long session contexts
		[Test]
    [Category("TestLongSerializedSessionContext")]
    public void T45TestLongSerializedSessionContext()
    {
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			ISession sessionA = sessionSet.CreateSession("metratech.com/testservice");
			TestLibrary.InitializeSession(sessionA, false, null);

			// this doesn't test much except that sending an
			// extra large security context doesn't blatantly fail
			// the context is never inspected because the testservice
			// pipeline contains no secured plugins.
			sessionA.RequestResponse = true;
			sessionSet.SessionContext = String.Empty.PadRight(10000, 'x');
			
			sessionSet.Close();
		}
    		


		// Tests that resending a message after a synchronous feedback timeout
		// eventually returns the original message's feedback.
		// TODO: validate idempotency
		[Test]
    public void T46TestSynchronousFeedbackRetry()
    {
			PipelineManager pipeline = new PipelineManager();
			try
			{
				// pause the pipelines so we can force a synchronous feedback timeout
				pipeline.PauseAllProcessing();

				// meters a session
				ISessionSet sessionSet = Sdk.CreateSessionSet();
				ISession sessionA = sessionSet.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(sessionA, false, null);
				sessionA.RequestResponse = true;

				// this should timeout
				MeterAndAssertException(sessionSet, "feedback timeout");

				pipeline.ResumeAllProcessing();

				// one of these retries should eventually succeed
				// which one depends on how fast the pipeline can process
				// the previously paused message
				Exception last = null; 
				int i = 0;
				for (i = 0; i < 10; i++)
				{
					try 
					{
						sessionSet.Close();
						break;
					}
					catch (Exception e)
					{
						last = e;
					}
				}
				if (i == 10) // no luck after 10 tries, so fail!
					throw last;

			}
			finally
			{
				pipeline.ResumeAllProcessing();
			}
		}


		// Stops and then starts SQL Server synchronously
		private void RestartSQLServer()
		{
			// restarts the local SQL Server so that cached connections held by the listener are broken
			using (ServiceController service = new ServiceController("MSSQLServer"))
			{
				Assert.IsTrue(service.Status == ServiceControllerStatus.Running, "MSSQLServer is not running!");
				
				TestLibrary.Trace("Stopping database...");
				service.Stop();
				service.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromMinutes(1.0));
				Assert.IsTrue(service.Status == ServiceControllerStatus.Stopped, "Couldn't stop SQL Server!");
						
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
				Assert.IsTrue(service.Status == ServiceControllerStatus.Running, "Couldn't start SQL Server!");

			}
		}
		
		// Meters good usage sessions until they are processed successfully
		// A session should validate fine but will fail in either the router 
		// (suspended - doesn't always occur) and WPV (always fails) 
		private void PrimeRouterAndWPV()
		{
			TestLibrary.Trace("Metering good session after database restart (fails in router or WPV)");
			Exception lastException = null;
			for (int i = 0; i < 10; i++)
			{
				ISession session = Sdk.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session, false, null);
				session.RequestResponse = true;

				try
				{
					session.Close();
					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 5 attempts to prime the router/WPV: {0}", lastException.Message);
		}
		
		// Meters sessions that will fail in the pipeline and checks
		// to make sure they were properly recorded
		void PrimeFailureWriter()
		{
			int oldFailedCount = GetFailureCount();

			// it currently takes 3 failed session sets for the failure writer to fully recover
			// TODO: is this a bug?
			TestLibrary.Trace("Metering bad session after database restart (fails in failure writer)");
			for (int i = 0; i < 10; i++)
			{
				ISession session = Sdk.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session, true, null);
				// NOTE: must meter asynchronously to excercise failure writer
				session.Close();
				Thread.Sleep(5000); // TODO: make this wait more precise

				int newFailedCount = GetFailureCount();
				if (newFailedCount > oldFailedCount)
					return;
				
				TestLibrary.Trace("  failure failed");
			}
			Assert.Fail("Giving up after 10 attempts to prime the failure writer");
		}

		// Meters accounts until an account is created successfully
		void PrimeAccountCreation()
		{
			TestLibrary.Trace("Metering good account after database restart (fails in plugins)");
			Exception lastException = null;
			for (int i = 0; i < 10; i++)
			{
				string suffix = DateTime.Now.ToString("s");
				try
				{
					TestLibrary.CreateAccount(Sdk, string.Format("Test-{0}-{1}", suffix, i), "", "monthly", 31);
					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 10 attempts to prime account creation: {0}", lastException.Message);
		}

		// Meters accounts until an account is created successfully
		void PrimeGSMAccountCreation()
		{
			TestLibrary.Trace("Metering good GSM account after database restart (fails in plugins)");
			Exception lastException = null;
			for (int i = 0; i < 10; i++)
			{
				string suffix = DateTime.Now.ToString("s");
				try
				{
					TestLibrary.CreateGSMAccount(Sdk, string.Format("Test-{0}-{1}", suffix, i));
					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 10 attempts to prime GSM account creation: {0}", lastException.Message);
		}

		// Meters accounts until an account is created successfully
		void PrimeSystemAccountCreation()
		{
			TestLibrary.Trace("Metering good system account after database restart (fails in plugins)");
			Exception lastException = null;
			for (int i = 0; i < 10; i++)
			{
				string suffix = DateTime.Now.ToString("s");
				try
				{
					TestLibrary.CreateSystemAccount(Sdk, string.Format("Test-{0}-{1}", suffix, i));
					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 10 attempts to prime system account creation: {0}", lastException.Message);
		}

		// Meters account credit requests until a credit is requested successfully
		// currently the stage contains one plugin that needs to be reinitialized: audit
		void PrimeAccountCredit()
		{
			TestLibrary.Trace("Metering good account credit after database restart (fails in plugins)");
			Exception lastException = null;
			for (int i = 0; i < 10; i++)
			{
				try
				{
					ISessionSet sessionSet = Sdk.CreateSessionSet();
					ISession session = sessionSet.CreateSession("metratech.com/accountcredit");

					session.InitProperty("CreditTime", MetraTime.Now);
					session.InitProperty("Status", "APPROVED");	
					session.InitProperty("RequestID", -1); // stand-alone credit
					session.InitProperty("ContentionSessionID", "");
					session.InitProperty("_AccountID", 123);
					session.InitProperty("_Amount", 0.99);
					session.InitProperty("_Currency", "USD");
					session.InitProperty("Issuer", "123");
					session.InitProperty("Reason", "DroppedCall");
					session.InitProperty("ReturnCode", 0);
					session.InitProperty("RequestAmount", 0);
					session.InitProperty("CreditAmount", 0.99);
					session.RequestResponse = true;

					sessionSet.Close();
					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 10 attempts to prime account credit: {0}", lastException.Message);
		}

		// Meters to account mapping until one is successfully created
		// currently the stage contains one plugin that needs to be reinitialized: audit
		void PrimeAccountMapping()
		{
			TestLibrary.Trace("Metering good account mapping after database restart (fails in plugins)");
			Exception lastException = null;
			string suffix = DateTime.Now.ToString("s");
			for (int i = 0; i < 10; i++)
			{
				try
				{
					ISessionSet sessionSet = Sdk.CreateSessionSet();
					ISession session = sessionSet.CreateSession("metratech.com/accountmapping");

					// NOTE: there is debate around whether creating two mappings in one namespace
					// is legal. For the time being, this test has been changed to create an additional
					// mapping in a different namespace (rather than in "mt"). See CR12568 for more.
					session.InitProperty("operation", "Add");
					session.InitProperty("LoginName", "demo");	
					session.InitProperty("NameSpace", "mt");
					session.InitProperty("NewLoginName", string.Format("ListenerTest-{0}-{1}", suffix, i));
					session.InitProperty("NewNameSpace", "rate");
					session.RequestResponse = true;

					sessionSet.Close();
					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 10 attempts to prime account mapping: {0}", lastException.Message);
		}

		// Meters to addcharge until one is successfully added
		// currently the stage contains one plugin that needs to be reinitialized: audit
		void PrimeAddCharge()
		{
			TestLibrary.Trace("Metering good add charge after database restart (fails in plugins)");
			Exception lastException = null;
			for (int i = 0; i < 10; i++)
			{
				try
				{
					ISessionSet sessionSet = Sdk.CreateSessionSet();
					ISession session = sessionSet.CreateSession("metratech.com/addcharge");

					session.InitProperty("_accountid", 123);
					session.InitProperty("chargetype", "other");
					session.InitProperty("chargedate", MetraTime.Now);
					session.InitProperty("otherchargetypecomment", "moredescription");
					session.InitProperty("_amount", 5.0);
					session.InitProperty("_currency", "USD");
					session.InitProperty("taxtype", "3");
					session.InitProperty("issuer", "csrid");
					session.InitProperty("relatetopreviouscharge", "somelinkinginfo");
					session.InitProperty("invoicecomment", "infooncustomerstatement");
					session.InitProperty("internalcomment", "repetitivecomplainer");
					session.InitProperty("Payer", "demo");
					session.InitProperty("Namespace", "MT");
					session.InitProperty("ResolveWithAccountIDFlag", false);

					session.RequestResponse = true;
					sessionSet.Close();

					return;
				}
				catch (Exception e)
				{
					lastException = e;
					TestLibrary.Trace("  got exception");
				}
			}
			Assert.Fail("Giving up after 10 attempts to prime charge account: {0}", lastException.Message);
		}

		// Tests asynchronously metering a hundreds of concurrent sessions doesn't fail
		private void MeterConcurrently(int sets, bool synchronous, string batchUID)
		{
			ArrayList delegates = new ArrayList();
			ArrayList results = new ArrayList();


			int i = 0;
			try
			{
				for (i = 1; i <= sets; i++)
				{
					TestLibrary.Trace("Thread {0} metering...", i);

					MeteringDelegate meteringClient = new MeteringDelegate(MeterSessionSet);
					delegates.Add(meteringClient);
					results.Add(meteringClient.BeginInvoke(i, synchronous, batchUID, null, null));
				}

				TestLibrary.Trace("All threads have been started");
			}
			// CR13163 - always wait for threads to finish before moving on
			finally
			{
				int max;
				if (i > sets) // if the for loop ended naturually we'll have a 'sets' worth of delegates
					max = sets;
				else 
					max = i; // if there was an exception, we'll only have an i's worth

				for (int j = 1; j <= max; j++)
				{
					TestLibrary.Trace("Waiting for results of thread {0}...", j);
					MeteringDelegate meteringClient = (MeteringDelegate) delegates[j - 1];
					IAsyncResult result = (IAsyncResult) results[j - 1];
					meteringClient.EndInvoke(result);
				}
			}
		}

		private delegate void MeteringDelegate(int sessionsInSet, bool synchronous, string batchUID);

    void MeterSessionSet(int sessionsInSet, bool synchronous, string batchUID)
		{
			ISessionSet sessionSet = Sdk.CreateSessionSet();
			for (int i = 0; i < sessionsInSet; i++)
			{
				ISession session = sessionSet.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session, false, batchUID);
				session.RequestResponse = synchronous;
			}
			sessionSet.Close();
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

		// meters a sesison set and validates that an expected exception was generated
		public static void MeterAndAssertException(ISessionSet sessionSet, string expectedExceptionMessage)
		{
			try
			{
				sessionSet.Close();
				Assert.Fail("Expected exception not generated!");
			}
			catch (Exception e)
			{
				Assert.AreEqual(expectedExceptionMessage.ToLower(), e.Message.ToLower());
			}
		}

		public static string MeterAndReturnException(ISessionSet sessionSet)
		{
			try
			{
				sessionSet.Close();
				Assert.Fail("Expected exception not generated!");
				return null;
			}
			catch (Exception e)
			{
				return e.Message;
			}
		}

		// meters a sesison set and validates that an expected exception starts
		// with the given text
		public static void MeterAndAssertExceptionStartsWith(ISessionSet sessionSet, string expectedExceptionMessage)
		{
			try
			{
				sessionSet.Close();
			}
			catch (Exception e)
			{
				AssertStartsWith(expectedExceptionMessage.ToLower(), e.Message.ToLower());
				return;
			}
			Assert.Fail("Expected exception not generated!");
		}

		public static void AssertStartsWith(string expected, string actual)
		{
			if (!actual.StartsWith(expected))
				Assert.Fail(String.Format("String <{0}> does not begin with prefix <{1}>!", actual, expected));
		}

		private int GetFailureCount()
		{
			Failures.Refresh();
			return Failures.Count;
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

		private bool isOracle 
		{
			get { return mConnInfo.DatabaseType == DBType.Oracle; }
		}
		// TODO:
		// - long string test
		// - encrypted string test
		// - validation errors on session object test
		// - feedback test

		IMeter mSdk = null;
		IMTSessionFailures mFailures;
		ConnectionInfo mConnInfo;
		public ListenerTests()
		{
			mConnInfo = new ConnectionInfo("NetMeter");
		}
	}

	[Guid("f4f0f8d8-0a8c-4471-bba2-172c2d962eab")]
	public interface IListenerComPlusTest
	{
		void MeterAndRollbackByListener(ISessionSet sessionSet, string batchUID);
		void MeterAndRollbackByComPlus(ISessionSet sessionSet, string batchUID);
		void MeterAndCommit(ISessionSet sessionSet, string batchUID);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.Required, Isolation = TransactionIsolationLevel.Any)]
	[Guid("e3adf20c-054d-42e2-b821-1a605876dbcf")]
	public class ListenerComPlusTest : ServicedComponent, IListenerComPlusTest
	{
		[AutoComplete]
    public void MeterAndCommit(ISessionSet sessionSet, string batchUID)
		{
			PipelineTransaction.IMTWhereaboutsManager whereaboutsmgr = new PipelineTransaction.CMTWhereaboutsManagerClass();
			string cookie = whereaboutsmgr.GetWhereaboutsForServer("AdjustmentsServer");


			ITransaction oTransaction = (ITransaction)ContextUtil.Transaction;
			PipelineTransaction.IMTTransaction oMTTransaction = new PipelineTransaction.CMTTransactionClass();
			/*false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed*/
			oMTTransaction.SetTransaction(oTransaction, false);
			string encodedCookie = oMTTransaction.Export(cookie);
			// specifies that the Listener should use this external transaction
			// to perform its routing inserts for this session set
			sessionSet.ListenerTransactionID = encodedCookie;

			// meters a session set of 10 sessions
			for (int i = 0; i < 10; i++)
			{
				ISession session = sessionSet.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session, false, batchUID);
				session.RequestResponse = false;
			}
			sessionSet.Close();
		}

		[AutoComplete]
		public void MeterAndRollbackByComPlus(ISessionSet sessionSet, string batchUID)
		{
			PipelineTransaction.IMTWhereaboutsManager whereaboutsmgr = new PipelineTransaction.CMTWhereaboutsManagerClass();
			string cookie = whereaboutsmgr.GetWhereaboutsForServer("AdjustmentsServer");


			ITransaction oTransaction = (ITransaction)ContextUtil.Transaction;
			PipelineTransaction.IMTTransaction oMTTransaction = new PipelineTransaction.CMTTransactionClass();
			/*false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed*/
			oMTTransaction.SetTransaction(oTransaction, false);
			string encodedCookie = oMTTransaction.Export(cookie);
			// specifies that the Listener should use this external transaction
			// to perform its routing inserts for this session set
			sessionSet.ListenerTransactionID = encodedCookie;

			// meters a session set of 10 sessions
			for (int i = 0; i < 10; i++)
			{
				ISession session = sessionSet.CreateSession("metratech.com/testservice");
				TestLibrary.InitializeSession(session, false, batchUID);
				session.RequestResponse = false;
			}
			sessionSet.Close();
			throw new ApplicationException("This is expected.");
		}

		[AutoComplete]
		public void MeterAndRollbackByListener(ISessionSet sessionSet, string batchUID)
		{
			PipelineTransaction.IMTWhereaboutsManager whereaboutsmgr = new PipelineTransaction.CMTWhereaboutsManagerClass();
			string cookie = whereaboutsmgr.GetWhereaboutsForServer("AdjustmentsServer");
			ITransaction oTransaction = (ITransaction)ContextUtil.Transaction;
			PipelineTransaction.IMTTransaction oMTTransaction = new PipelineTransaction.CMTTransactionClass();
			/*false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed*/
			oMTTransaction.SetTransaction(oTransaction, false);
			string encodedCookie = oMTTransaction.Export(cookie);
			// specifies that the Listener should use this external transaction
			// to perform its routing inserts for this session set
			sessionSet.ListenerTransactionID = encodedCookie;

			//insert some data into t_listener_test on managed connection.
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
            {
                using (IMTStatement stmt = conn.CreateStatement("insert into t_listener_test values(1, 2)"))
                {
                    stmt.ExecuteNonQuery();
                }
            }

			// meters a session set of 10 sessions
			for (int i = 0; i < 10; i++)
			{
				ISession session = sessionSet.CreateSession("metratech.com/testservice");
				session.InitProperty("description", "batch/rerun test");
				session.InitProperty("time", MetraTech.MetraTime.Now);
				session.InitProperty("decprop2", 123.88m);
				session.InitProperty("decprop1", 99m);
				//malform some data, so that listener throws
				session.InitProperty("units", "10deliberate_corruption");
				session.InitProperty("_CollectionID", batchUID);
				session.InitProperty("accountname", "demo");
				session.RequestResponse = false;
			}

			try
			{
				sessionSet.Close();
			} catch (Exception) { }
		}
	}
}

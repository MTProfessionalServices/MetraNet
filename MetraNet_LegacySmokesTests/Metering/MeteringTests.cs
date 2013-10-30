using System.Runtime.InteropServices;
using System.Diagnostics;
using System;
using System.Collections;
using System.Text.RegularExpressions;
using System.Globalization;

using NUnit.Framework;
using MetraTech.Test;
using MetraTech.DataAccess;
using MetraTech.Interop.COMMeter;
using MetraTech.Interop.PipelineTransaction;
using MetraTech.Metering.DatabaseMetering;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.COMDBObjects;
using MetraTech.UsageServer.Test;
using MetraTech.Interop.MTProductCatalog;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Accounts.Type.Test;

namespace MetraTech.Metering.Test
{
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Metering.Test.MeteringTests /assembly:O:\debug\bin\MetraTech.Metering.Test.dll
	//
  [Category("NoAutoRun")]
  [TestFixture]
  [Ignore]
	public class MeteringTests
	{			
    #region Fixture Setup
    /// <summary>
    ///    Performed once prior to executing any of the tests in the fixture.
    /// </summary>
    [TestFixtureSetUp] 
    public void Init()
    { 
      ClearNetMeterClient();
    }

    #endregion

    #region FastSDK
    // Test that a session set with one session can be metered synchronously
    // and processed by the pipeline
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestSingleSessionSynchronous")]
    public void T01TestSingleSessionSynchronous() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);
      // Create a testservice
      ISession session = sessionSet.CreateSession("metratech.com/testservice");
      // Synchronous
      session.RequestResponse = true;
      // Initialize the session
      InitializeTestService(session, null, null);
      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testservice", batchUid, 1);
    }

    // Test that a session set with one session can be metered asynchronously
    // and processed by the pipeline
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestSingleSessionASynchronous")]
    public void T02TestSingleSessionASynchronous() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);
      // Create a testservice
      ISession session = sessionSet.CreateSession("metratech.com/testservice");
      // Synchronous
      session.RequestResponse = false;
      // Initialize the session
      InitializeTestService(session, null, null);
      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testservice", batchUid, 1);
    }

    // Test that an error is thrown when the session is initialized before setting session set properties.
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestSettingSessionPropertiesBeforeSessionSetProperties")]
    public void T03TestSettingSessionPropertiesBeforeSessionSetProperties() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			
      // Create a testservice
      ISession session = sessionSet.CreateSession("metratech.com/testservice");
      // Synchronous
      session.RequestResponse = false;
      try 
      {
        // Initialize the session - this should fail because session set properties have not been set
        InitializeTestService(session, null, null);
        Assert.Fail("Expected exception not generated!");
      }
      catch (Exception e) 
      {
        string errorMessage = 
          "In the FastSDK mode, the session set properties must be initialized before setting session properties.";
        Assert.AreEqual(errorMessage, e.Message, "Mismatch in error messages");
      }
    }

    // Test that a session set with a compound session (one parent, two children)
    // can be metered synchronously and processed by the pipeline
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("FastSDK")]
    public void T04TestCompoundSessionSynchronous() 
    {
      int numChildServices = 2;

      string batchUid;
      ISession parentSession;
      ISession childSession;
      // Create the session set and retrieve the batchUid
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1 + numChildServices);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);
      // Create a testparent
      parentSession = sessionSet.CreateSession("metratech.com/testparent");
      // Synchronous
      parentSession.RequestResponse = true;
      // Initialize the parent session
      InitializeTestParent(parentSession);

      for (int i = 0; i < numChildServices; i++) 
      {
        // Create the first child testservice
        childSession = parentSession.CreateChildSession("metratech.com/testservice");
        // Initialize the child session
        InitializeTestService(childSession, null, batchUid);
      }

      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testparent", batchUid, 1);
      CheckServiceCounts("t_svc_testservice", batchUid, numChildServices);
    }



    // Test that a session set with a compound session (one parent, two children)
    // can be metered asynchronously and processed by the pipeline
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("FastSDK")]
    public void T05TestCompoundSessionASynchronous() 
    {
      int numChildServices = 2;

      string batchUid;
      ISession parentSession;
      ISession childSession;
      // Create the session set and retrieve the batchUid
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1 + numChildServices);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);
      // Create a testparent
      parentSession = sessionSet.CreateSession("metratech.com/testparent");
      // Synchronous
      parentSession.RequestResponse = false;
      // Initialize the parent session
      InitializeTestParent(parentSession);

      for (int i = 0; i < numChildServices; i++) 
      {
        // Create the first child testservice
        childSession = parentSession.CreateChildSession("metratech.com/testservice");
        // Initialize the child session
        InitializeTestService(childSession, null, batchUid);
      }

      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testparent", batchUid, 1);
      CheckServiceCounts("t_svc_testservice", batchUid, numChildServices);
    }

    // Test that invalid XML characters (<,>,&) are handled correctly
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("FastSDK")]
    public void T06TestInvalidXml() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
    		
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);
      // Create a testservice
      ISession session = sessionSet.CreateSession("metratech.com/testservice");
      // Synchronous
      session.RequestResponse = true;
      // Initialize the session
      //string badString = "<>";
      string stringProperty = "<<>>&&!~@#$%^&*()_-+=|}{]['\";:?/.,\\~`";
      string escapedString = EscapeXMLCharacters(stringProperty);
      InitializeTestService(session, escapedString, null);
      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testservice", batchUid, 1);

      CheckStringProperty("t_svc_testservice", 
                          "c_StringProperty", 
                          batchUid, 
                          stringProperty);
    }

    // Test that unicode strings are handled correctly
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestUnicodeString")]
    public void T07TestUnicodeString() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
    		
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);
      // Create a testservice
      ISession session = sessionSet.CreateSession("metratech.com/testservice");
      // Synchronous
      session.RequestResponse = true;
      // Initialize the session
      InitializeTestService(session, unicodeString, null);
      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testservice", batchUid, 1);

      CheckStringProperty("t_svc_testservice", 
                          "c_StringProperty", 
                          batchUid, 
                          unicodeString);
    }

    // Test that the ISessionSet.SetProperties method works
    // correctly for username, password, namespace combination
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("FastSDK")]
    public void T08TestSetPropertiesWithUsername() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set username, password and namespace
      sessionSet.SetProperties(null, 
                               null, 
                               null,
                               "test user",
                               "test password",
                               "test namespace");
      // Create a testservice
      ISession session = sessionSet.CreateSession("metratech.com/testservice");
      // Synchronous
      session.RequestResponse = true;
      // Initialize the session
      InitializeTestService(session, null, null);
      // Meter the session set
      try 
      {
        sessionSet.Close();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testservice", batchUid, 1);
    }

    // Test that a session set with one session can be
    // metered and processed with an external transaction
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("FastSDK")]
    public void T09TestTransaction() 
    {
      // Create the session set and retrieve the batchUid
      string batchUid;
      ISessionSet sessionSet = CreateSessionSet(out batchUid, 1);
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();

      // Create a transaction
      MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
        new MetraTech.Interop.PipelineTransaction.CMTTransaction();

      transaction.Begin("MeteringTests::TestTransaction", 600 * 1000);
      try
      {
        MetraTech.Interop.PipelineTransaction.IMTWhereaboutsManager whereAboutsMan =
          new CMTWhereaboutsManager();

        string transactionID = transaction.Export(whereAboutsMan.GetLocalWhereabouts());
  			
        sessionSet.SetProperties(null, 
                                 transactionID, 
                                 sessionContext.ToXML(),
                                 null,
                                 null,
                                 null);
        // Create a testservice
        ISession session = sessionSet.CreateSession("metratech.com/testservice");
        // Synchronous
        session.RequestResponse = true;
        // Initialize the session
        InitializeTestService(session, null, null);
        // Meter the session set

        sessionSet.Close();
        transaction.Commit();
        TestLibrary.WaitForBatchCompletion(Sdk, batchUid);
      }
      catch (Exception e) 
      {
        transaction.Rollback();
        TestLibrary.Trace("failure: " + e.ToString());
        Assert.Fail();
      }

      CheckServiceCounts("t_svc_testservice", batchUid, 1);
    }
    #endregion

    #region MetraConnect
    /// <summary>
    ///   1) Insert audioconfcall record with c_ScheduledStartTime date 
    ///      earlier than 1/1/1970
    ///   2) Expect the record to fail with a status of 'Failed' and a
    ///      specific error message.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("MetraConnect")]
    public void T10TestInvalidDateLowerBound() 
    {
      string method = "TestInvalidDateLowerBound";
      Log("Running " + method);

      TestDate(new DateTime(1969, 12, 31), true, method);

      Log("Finished " + method);
    }

    /// <summary>
    ///   1) Insert audioconfcall record with c_ScheduledStartTime date 
    ///      later than 1/20/2038
    ///   2) Expect the record to fail with a status of 'Failed' and a
    ///      specific error message.
    ///    
    ///   For 32 bit.
    ///   The maximum number of seconds that can be stored in a 
    ///   signed long is 2,147,483,647. Because the time- related 
    ///   functions use 00:00:00 (midnight), January 1, 1970 as their base, 
    ///   the maximum time and date that can be represented with a 
    ///   time_t type is January 19, 2038, 3:14:07 A.M. 
    /// 
    ///   For 64 bit. max time = December 31, 3000, 23:59:59.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestInvalidDateUpperBound")]
    public void T11TestInvalidDateUpperBound() 
    {
      string method = "TestInvalidDateUpperBound";
      Log("Running " + method);

      TestDate(new DateTime(3001, 1, 1), true, method);

      Log("Finished " + method);
    }

    /// <summary>
    ///   1) Insert audioconfcall record with c_ScheduledStartTime date 
    ///      of 1/1/1970
    ///   2) Expect the record to be sent with a status of 'Sent' and no
    ///      error message.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestValidDateLowerBound")]
    public void T12TestValidDateLowerBound() 
    {
      string method = "TestValidDateLowerBound";
      Log("Running " + method);

      TestDate(new DateTime(1970, 1, 1), false, method);
      
      Log("Finished " + method);
    }

    /// <summary>
    ///   1) Insert audioconfcall record with c_ScheduledStartTime date 
    ///      of 1/18/2038
    ///   2) Expect the record to be sent with a status of 'Sent' and no
    ///      error message.
    ///      
    ///   The maximum number of seconds that can be stored in a 
    ///   signed long is 2,147,483,647. Because the time- related 
    ///   functions use 00:00:00 (midnight), January 1, 1970 as their base, 
    ///   the maximum time and date that can be represented with a 
    ///   time_t type is January 19, 2038, 3:14:07 A.M. 
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestValidDateUpperBound")]
    public void T13TestValidDateUpperBound() 
    {
      string method = "TestValidDateUpperBound";
      Log("Running " + method);

      TestDate(new DateTime(2038, 1, 18), false, method);
      
      Log("Finished " + method);
    }

    /// <summary>
    ///   1) Create one audio conf call
    ///   2) Create audio conf connections 
    ///   3) Create audio conf features 
    ///   4) Meter
    ///   5) Check that the compound was sent by verifying its status and lack of error message 
    ///   6) Check that the corresponding t_svc.. tables did not acquire any new rows.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestValidCompound")]
    public void T14TestValidCompound() 
    {
      string method = "TestValidCompound";
      Log("Running " + method);

      // Clear data. Otherwise MetraConnect will try to send the failed sessions again.
      ClearNetMeterClient();

      int numConferences = 5;
      int numFeatures = 5;

      string userName = "Brushes001";

      // Insert audioconfcall data
      InsertAudioConfCallData(++conferenceId, DateTime.Now, method, userName);

      // Insert audio conf connection data 
      for (int i = 0; i < numConferences; i++)
      {
        InsertAudioConfConnectionData(conferenceId, DateTime.Now, method, userName);
      }
      
      // Insert audio conf feature data 
      for (int i = 0; i < numFeatures; i++)
      {
        InsertAudioConfFeatureData(conferenceId, DateTime.Now, method, userName);
      }
      
      int confCallRowCount = GetRowCount(MeteringTests.audioConfCallTableName);
      int confConnectionRowCount = GetRowCount(MeteringTests.audioConfConnectionTableName);
      int confFeatureRowCount = GetRowCount(MeteringTests.audioConfFeatureTableName);

      // Meter
      Meter();

      string expectedStatus = "Sent";
     
      CheckConferenceStatus(conferenceId, expectedStatus, null);

      // Check number of rows in t_svc_audioconfcall have changed
      Assert.AreEqual(confCallRowCount + 1, GetRowCount(MeteringTests.audioConfCallTableName),
                      String.Format("Mismatched number of rows in {0}!", 
                                    MeteringTests.audioConfCallTableName));
      // Check number of rows in t_svc_audioconfconnection have changed
      Assert.AreEqual(confConnectionRowCount + numConferences, 
                      GetRowCount(MeteringTests.audioConfConnectionTableName),
                      String.Format("Mismatched number of rows in {0}!", 
                                    MeteringTests.audioConfConnectionTableName));
      // Check number of rows in t_svc_audioconffeature have changed
      Assert.AreEqual(confFeatureRowCount + numFeatures, 
                      GetRowCount(MeteringTests.audioConfFeatureTableName),
                      String.Format("Mismatched number of rows in {0}!", 
                                    MeteringTests.audioConfFeatureTableName));

      Log("Finished " + method);

    }

    /// <summary>
    ///   1) Create one audio conf call
    ///   2) Create audio conf connections with bad dates
    ///   3) Create audio conf features with bad dates
    ///   4) Meter
    ///   5) Check that the audio conf call failed to be transmitted by verifying its
    ///      status and error message 
    ///   6) Check that the corresponding t_svc.. tables did not acquire any new rows.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestInvalidChild")]
    public void T15TestInvalidChild() 
    {
      string method = "TestInvalidChild";
      Log("Running " + method);

      // Clear data. Otherwise MetraConnect will try to send the failed sessions again.
      ClearNetMeterClient();

      int numFailedConferences = 5;
      int numFailedFeatures = 5;

      string userName = "Brushes001";

      // Insert audioconfcall data
      InsertAudioConfCallData(++conferenceId, DateTime.Now, method, userName);

      // Insert audio conf connection data 
      for (int i = 0; i < numFailedConferences; i++)
      {
        InsertAudioConfConnectionData(conferenceId, new DateTime(1965, 1, 1), method, userName);
      }
      
      // Insert audio conf feature data 
      for (int i = 0; i < numFailedFeatures; i++)
      {
        InsertAudioConfFeatureData(conferenceId, new DateTime(1965, 1, 1), method, userName);
      }
      
      int confCallRowCount = GetRowCount(MeteringTests.audioConfCallTableName);
      int confConnectionRowCount = GetRowCount(MeteringTests.audioConfConnectionTableName);
      int confFeatureRowCount = GetRowCount(MeteringTests.audioConfFeatureTableName);

      // Meter
      Meter();

      string expectedStatus = "Failed";
     
      // Check failed status and error message
      ErrorProperty[] errorPropertyList = 
        new ErrorProperty[] {new ErrorProperty("ConnectTime", numFailedConferences),
                             new ErrorProperty("StartTime", numFailedFeatures)};

      CheckConferenceStatus(conferenceId, expectedStatus, errorPropertyList);

      // Check rows in t_svc_audioconfcall have not changed
      Assert.AreEqual(confCallRowCount, GetRowCount(MeteringTests.audioConfCallTableName),
                      String.Format("Mismatched number of rows in {0}!", 
                                    MeteringTests.audioConfCallTableName));
      // Check rows in t_svc_audioconfconnection have not changed
      Assert.AreEqual(confConnectionRowCount, GetRowCount(MeteringTests.audioConfConnectionTableName),
                      String.Format("Mismatched number of rows in {0}!", 
                                    MeteringTests.audioConfConnectionTableName));
      // Check rows in t_svc_audioconffeature have not changed
      Assert.AreEqual(confFeatureRowCount, GetRowCount(MeteringTests.audioConfFeatureTableName),
                      String.Format("Mismatched number of rows in {0}!", 
                                    MeteringTests.audioConfFeatureTableName));

      Log("Finished " + method);
    }

    /// <summary>
    ///   Test Australian daylight saving time extension for the Commonwealth games.
    ///   1) Move machine time forward to Mar 28
    ///   2) Set config <localTimeZone>AUS Eastern Standard Time</localTimeZone>
    ///   3) Meter audio conf call with current time
    ///   4) Check time in t_svc
    ///   
    ///   5) Set config <localTimeZone>AUS Eastern Standard Time (Commonwealth Games 2006)</localTimeZone>    
    ///   6) Meter audio conf call with current time
    ///   7) Check time in t_svc. 
    ///      This time must be an hour earlier than the previous time.
    ///   
    ///   
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("MetraConnect1")]
    public void T16TestAustralianDaylightSavingsTime() 
    {
      string method = "TestAustralianDaylightSavingsTime";
      Log("Running " + method);

      // Clear data. Otherwise MetraConnect will try to send the failed sessions again.
      ClearNetMeterClient();
      
      InsertAudioConfCallData(++conferenceId, DateTime.Now, method, "Brushes001");
      Meter();

      Log("Finished " + method);
    }

    /// <summary>
    ///   1) Exercise the core date time routine
    ///   2) Remember Australians move their clocks forward in October and backwards
    ///      in March unlike the US. Hence they are GMT+10 between March and October and
    ///      GMT+11 (DST) between October and March.
    ///   3) NOTE! If the daylightSavings flag is passed as 'false' ie. do not use daylight
    ///      savings time, there is a discrepancy during 
    ///      the daylight savings time period (Oct - Mar). 
    ///      The results are GMT+9 instead of GMT+10.
    ///      The regular period (Mar - Oct) is fine with GMT+10.
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    [Category("TestAustralianDaylightSavingsTime2")]
    public void T17TestAustralianDaylightSavingsTime2() 
    {
      COMDataAccessor dataAccessor = new COMDataAccessorClass();
      dataAccessor.AccountID = 459;
      dataAccessor.LanguageCode = "US";
      COMLocaleTranslator localeTranslator = 
        (COMLocaleTranslator)dataAccessor.GetLocaleTranslator();

      // DateTime dateTime = DateTime.Now;
      DateTime dateTime = new DateTime(2006, 3, 1, 12, 0, 0);

      int timeZoneSydney = 42;
      // int timeZoneNewYork = 18;
      bool daylightSavingsFlag = true;
      const string dateFormat = "yyyy-MM-ddTHH:mm:ssZ";
      DateTime time = 
         DateTime.FromOADate(
           (double)localeTranslator.GetDateTime(dateTime.ToString(dateFormat), 
                                                timeZoneSydney, 
                                                daylightSavingsFlag));

      Log(time.ToString());
    }

//    public DateTime Time_T2DateTime(uint time_t) 
//    {
//      long win32FileTime = 10000000*(long)time_t + 116444736000000000;
//      return DateTime.FromFileTimeUtc(win32FileTime);
//    }

    #endregion

    #region Private methods
    private void Log(string message) 
    {
      TestLibrary.Trace(message);
      logger.LogDebug(message);
    }

    private ISessionSet CreateSessionSet(out string batchUid, int numSessions) 
    {
      ISessionSet sessionSet = null;
      batchUid = "";

      IBatch batch = CreateBatch(numSessions);
      batchUid = batch.UID;

      // Create and initialize a session set
      sessionSet = batch.CreateSessionSet();

      return sessionSet;
    }

    private IBatch CreateBatch(int numSessions) 
    {
      IBatch batch = Sdk.CreateBatch();

      batch.NameSpace = "MT        ";
      batch.Name = "1";
      batch.ExpectedCount = numSessions;
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

      return batch;
    }
		
    private void InitializeTestService(ISession session, 
                                       string stringProperty,
                                       string batchUid) 
    {
      ArrayList propertyDataList = new ArrayList();
      PropertyData propertyData;

      propertyData = new PropertyData();
      propertyData.Name = "description";
      propertyData.Value = "Test Description";
      propertyData.Type = (int)DataType.MTC_DT_WCHAR;
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "time";
      propertyData.Value = MetraTech.MetraTime.Now.ToString(strDateFormat);
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "units";
      propertyData.Value = "1.10";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "AccountName";
      propertyData.Value = "demo";
      propertyData.Type = (int)DataType.MTC_DT_WCHAR;
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "DecProp1";
      propertyData.Value = "1.11";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "DecProp2";
      propertyData.Value = "1.12";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "DecProp3";
      propertyData.Value = "1.13";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "IntegerProperty";
      propertyData.Value = "1";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "StringProperty";
      if (stringProperty != null) 
      {
        propertyData.Value = stringProperty;
      }
      else 
      {
        propertyData.Value = "Dummy String Property";
      }
      propertyData.Type = (int)DataType.MTC_DT_WCHAR;
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "DecimalProperty";
      propertyData.Value = "1.23";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "DoubleProperty";
      propertyData.Value = "1.23";
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "BooleanProperty";
      propertyData.Value = "F";
      propertyDataList.Add(propertyData);

      if (batchUid != null) 
      {
        propertyData = new PropertyData();
        propertyData.Name = "_CollectionID";
        propertyData.Value = batchUid;
        propertyData.Type = (int)DataType.MTC_DT_WCHAR;
        propertyDataList.Add(propertyData);
      }

      // !TODO Testing ES 2033 - Remove after testing
//      propertyData = new PropertyData();
//      propertyData.Name = "testmb";
//      propertyData.Value = "Annulée";
//      propertyDataList.Add(propertyData);
      

      session.CreateSessionStream
        (propertyDataList.ToArray(typeof(PropertyData)) as PropertyData[]);

    }

    private void InitializeTestParent(ISession session) 
    {
      ArrayList propertyDataList = new ArrayList();
      PropertyData propertyData;

      propertyData = new PropertyData();
      propertyData.Name = "description";
      propertyData.Value = "dumy description";
      propertyData.Type = (int)DataType.MTC_DT_WCHAR;
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "time";
      propertyData.Value = MetraTech.MetraTime.Now.ToString(strDateFormat);
      propertyDataList.Add(propertyData);

      propertyData = new PropertyData();
      propertyData.Name = "accountName";
      propertyData.Value = "demo";
      propertyData.Type = (int)DataType.MTC_DT_WCHAR;
      propertyDataList.Add(propertyData);

      session.CreateSessionStream
        (propertyDataList.ToArray(typeof(PropertyData)) as PropertyData[]);
    }

    private void CheckServiceCounts(string serviceTableName, 
                                    string batchUid,
                                    int numExpected) 
    {
      int numFound = 0;

      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement
            (
              // select count(*) from t_svc_testservice t
              // inner join t_batch b on b.tx_batch = t.c__CollectionID
              // where b.tx_batch_encoded = 'wKgBW168DErR/fAhBfB99A=='
              "select count(*) from " +
              serviceTableName +
              " t inner join t_batch b on b.tx_batch = t.c__CollectionID " +
              "where b.tx_batch_encoded = '" +
              batchUid +
              "'"
            ))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      numFound = reader.GetInt32(0);
                      break;
                  }
              }
          }
      }

      Assert.AreEqual
        (numExpected, numFound,
				"Number of services metered [" + 
         numExpected + 
          "] do not match number of services found [" + 
         numFound + 
         "]!");

    }

    private void CheckStringProperty(string serviceTableName, 
                                     string columnName,
                                     string batchUid,
                                     string expectedString) 
    {
      string foundString = null;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement
            (
              // select columnName from t_svc_testservice t
              // inner join t_batch b on b.tx_batch = t.c__CollectionID
              // where b.tx_batch_encoded = 'wKgBW168DErR/fAhBfB99A=='
            "select " +
            columnName +
            " from " +
            serviceTableName +
            " t inner join t_batch b on b.tx_batch = t.c__CollectionID " +
            "where b.tx_batch_encoded = '" +
            batchUid +
            "'"
            ))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      foundString = reader.GetString(0);
                      break;
                  }
              }
          }
      }

      Assert.AreEqual(expectedString, foundString, "Strings don't match!");

    }

    /// <summary>
    ///   Insert one audio conference call record with the 
    ///   given conference id 
    /// </summary>
    /// <returns>conference id</returns>
    private void InsertAudioConfCallData(int conferenceId, 
                                         DateTime startTime, 
                                         string testName,
                                         string userName) 
    {
      using(IMTConnection conn = ConnectionManager.CreateConnection(clientQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(clientQueryPath, "__INSERT_AUDIO_CONF_CALL_DATA__"))
          {

              stmt.AddParam("%%CONFERENCE_ID%%", Convert.ToString(conferenceId));
              stmt.AddParam("%%ACCOUNT_NAME%%", userName);
              stmt.AddParam("%%SCHEDULED_START_TIME%%", GetDBDateString(startTime, conn.ConnectionInfo.DatabaseType), true);
              stmt.AddParam("%%TEST_NAME%%", testName);
              logger.LogDebug(stmt.Query);
              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///   Insert one audio conference connection record with the 
    ///   given conference id 
    /// </summary>
    /// <returns>conference id</returns>
    private void InsertAudioConfConnectionData(int conferenceId, 
                                               DateTime connectTime, 
                                               string testName,
                                               string userName) 
    {
      using(IMTConnection conn = ConnectionManager.CreateConnection(clientQueryPath))
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
              (clientQueryPath, "__INSERT_AUDIO_CONF_CONNECTION_DATA__"))
          {

              stmt.AddParam("%%CONFERENCE_ID%%", conferenceId);
              stmt.AddParam("%%ACCOUNT_NAME%%", userName);
              stmt.AddParam("%%CONNECT_TIME%%", GetDBDateString(connectTime, conn.ConnectionInfo.DatabaseType), true);
              stmt.AddParam("%%TEST_NAME%%", testName);

              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///   Insert one audio conference feature record with the 
    ///   given conference id 
    /// </summary>
    /// <returns>conference id</returns>
    private void InsertAudioConfFeatureData(int conferenceId, 
                                            DateTime startTime,
                                            string testName,
                                            string userName) 
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection(clientQueryPath))
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
              (clientQueryPath, "__INSERT_AUDIO_CONF_FEATURE_DATA__"))
            {

                stmt.AddParam("%%CONFERENCE_ID%%", conferenceId);
                stmt.AddParam("%%ACCOUNT_NAME%%", userName);
                stmt.AddParam("%%START_TIME%%", GetDBDateString(startTime, conn.ConnectionInfo.DatabaseType), true);
                stmt.AddParam("%%TEST_NAME%%", testName);

                stmt.ExecuteNonQuery();
            }
        }
    }

    /// <summary>
    ///   Clear data from 
    ///    - mt_audioconfcall 
    ///    - mt_audioconfconnection
    ///    - mt_audioconffeature
    ///    - mt_audioconfcall_Status
    /// </summary>
    private void ClearNetMeterClient() 
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection(clientQueryPath))
        {
            using (IMTAdapterStatement stmt =
              conn.CreateAdapterStatement(clientQueryPath, "__CLEAR_CLIENT_DATA__"))
            {

                stmt.ExecuteNonQuery();
            }
        }
    }

    /// <summary>
    ///   Clear data from 
    ///   - t_svc_audioconfcall
    ///   - t_svc_audioconfconnection
    ///   - t_svc_audioconffeature
    /// </summary>
    private void ClearAudioConfSvcData() 
    {
        using (IMTConnection conn = ConnectionManager.CreateConnection(serverQueryPath))
        {
            using (IMTAdapterStatement stmt =
              conn.CreateAdapterStatement(serverQueryPath, "__CLEAR_AUDIO_CONF_SVC_DATA__"))
            {

                stmt.ExecuteNonQuery();
            }
        }
    }

    /// <summary>
    ///   1) Create a row in mt_audioconfcall with the given date
    ///      as ScheduledStartTime
    ///   2) Meter the row
    ///   3) Expect a status of 'Failed' and a specified error message
    ///      if expectFailure is true.
    ///      Otherwise check that the status is 'Sent' and that there
    ///      is no error message.
    /// </summary>
    /// <param name="date"></param>
    private void TestDate(DateTime date, bool expectFailure, string testName) 
    {
      // Clear data. Otherwise MetraConnect will try to send
      // the failed sessions again.
      ClearNetMeterClient();

      // string userName = CreateAndSubscribeAccount(date.AddSeconds(-1));

      // Insert audioconfcall data
      InsertAudioConfCallData(++conferenceId, date, testName, "Brushes001");

      // Get the number of rows in t_svc_audioconfcall
      int confCallCount = GetRowCount(MeteringTests.audioConfCallTableName);

      // Meter
      MeterHelper meterHelper = new MeterHelper();
      meterHelper.Meter(new string[] {ConfigFile});

      string expectedStatus = String.Empty;
      ErrorProperty[] errorPropertyList = null;
      if (expectFailure) 
      {
        expectedStatus = "Failed";
        errorPropertyList = new ErrorProperty[] {new ErrorProperty("ScheduledStartTime", 1)};
      }
      else 
      {
        expectedStatus = "Sent";
      }
     
      // Check the status and error message in NetMeterClient
      CheckConferenceStatus(conferenceId, expectedStatus, errorPropertyList);

      // Check that the number of rows in t_svc_audioconfcall is consistent
      if (expectFailure) 
      {
        Assert.AreEqual(confCallCount,
                        GetRowCount(MeteringTests.audioConfCallTableName),
                        "Mismatched rows in NetMeterClient and t_svc_audioconfcall!");
      }
      else 
      {
        Assert.AreEqual(confCallCount + 1,
                        GetRowCount(MeteringTests.audioConfCallTableName),
                        "Expected an additional row in t_svc_audioconfcall!");
      }
    }

    /// <summary>
    ///   Meter the data
    /// </summary>
    private void Meter() 
    {
      // Meter
      MeterHelper meterHelper = new MeterHelper();
      meterHelper.Meter(new string[] {ConfigFile});
    }

    /// <summary>
    ///   Check that the conference with the given id has the specified
    ///   expected status and the specified expected error message
    /// </summary>
    /// <param name="conferenceId"></param>
    /// <param name="expectedStatus"></param>
    /// <param name="expectedErrorMessage"></param>
    private void CheckConferenceStatus(int conferenceId, 
                                       string expectedStatus, 
                                       ErrorProperty[] errorPropertyList) 
    {
      string status = String.Empty;
      string errorMessage = String.Empty;
      string statusColumn = "c_MeteringStatus";
      string errorColumn = "c_MTErrorMesg";

      using (IMTConnection conn = ConnectionManager.CreateConnection(clientQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(clientQueryPath, "__GET_CONFERENCE_STATUS__"))
          {

              stmt.AddParam("%%CONFERENCE_ID%%", conferenceId);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int rowCount = 0;

                  // Expect one row back
                  while (reader.Read())
                  {
                      rowCount++;

                      Assert.AreEqual
                        (1,
                         rowCount,
                         String.Format("Found more than one row for conference id: {0}", conferenceId));

                      // Retrieve the status
                      if (!reader.IsDBNull(statusColumn))
                      {
                          status = reader.GetString(statusColumn);
                      }
                      // Retrieve the error message
                      if (!reader.IsDBNull(errorColumn))
                      {
                          errorMessage = reader.GetString(errorColumn);
                      }
                  }
              }
          }
      }

      // Check status
      Assert.AreEqual(expectedStatus.ToLower(), 
                      status.ToLower(), 
                      "Mismatched metering status!");
      // Check error message
      CheckError(errorMessage, errorPropertyList);
    }

    /// <summary>
    ///   Expect one row in t_svc_audioconfcall for the given conferenceId.
    /// </summary>
    /// <param name="conferenceId"></param>
    /// <param name="expectedStatus"></param>
    /// <param name="expectedErrorMessage"></param>
    private void CheckAudioConfCallSvc(int conferenceId) 
    {
      int count = 0;
      using (IMTConnection conn = ConnectionManager.CreateConnection(serverQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(serverQueryPath, "__GET_AUDIO_CONF_CALL_SVC_COUNT__"))
          {

              stmt.AddParam("%%CONFERENCE_ID%%", conferenceId);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  count = reader.GetInt32("ConfCount");
              }
          }
      }

      Assert.AreEqual(1, count, 
                      String.Format("Expected to find one row for conference id: {0} in " +
                                    "t_svc_audioconfcall!", conferenceId));
    }

    /// <summary>
    ///   Expect to find 'expectedRows' number of rows in
    ///   in t_svc_audioconfconnection for the given conferenceId.
    /// </summary>
    /// <param name="conferenceId"></param>
    /// <param name="expectedStatus"></param>
    /// <param name="expectedErrorMessage"></param>
    private void CheckAudioConfConnectionSvc(int conferenceId, int expectedRows) 
    {
      int count = 0;
      using (IMTConnection conn = ConnectionManager.CreateConnection(serverQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(serverQueryPath, "__GET_AUDIO_CONF_CONNECTION_SVC_COUNT__"))
          {

              stmt.AddParam("%%CONFERENCE_ID%%", conferenceId);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  count = reader.GetInt32("ConfCount");
              }
          }
      }

      Assert.AreEqual(expectedRows, count, 
        String.Format("Expected to find {0} rows for conference id: {1} in " +
                      "t_svc_audioconfconnection!", expectedRows, conferenceId));
    }

    /// <summary>
    ///   Expect to find 'expectedRows' number of rows in
    ///   in t_svc_audioconffeature for the given conferenceId.
    /// </summary>
    /// <param name="conferenceId"></param>
    /// <param name="expectedStatus"></param>
    /// <param name="expectedErrorMessage"></param>
    private void CheckAudioConfFeatureSvc(int conferenceId, int expectedRows) 
    {
      int count = 0;
      using (IMTConnection conn = ConnectionManager.CreateConnection(serverQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(serverQueryPath, "__GET_AUDIO_CONF_FEATURE_SVC_COUNT__"))
          {

              stmt.AddParam("%%CONFERENCE_ID%%", conferenceId);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  count = reader.GetInt32("ConfCount");
              }
          }
      }

      Assert.AreEqual(expectedRows, count, 
        String.Format("Expected to find {0} rows for conference id: {1} in " +
                      "t_svc_audioconffeature!", expectedRows, conferenceId));
    }

    /// <summary>
    ///   Return the number of rows in the given table
    /// </summary>
    /// <param name="tableName"></param>
    /// <returns></returns>
    private int GetRowCount(string tableName) 
    {
      int count = 0;
      using (IMTConnection conn = ConnectionManager.CreateConnection(serverQueryPath))
      {
          using (IMTAdapterStatement stmt =
            conn.CreateAdapterStatement(serverQueryPath, "__GET_COUNT__"))
          {

              stmt.AddParam("%%TABLE_NAME%%", tableName);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  count = reader.GetInt32(0);
              }
          }
      }

      return count;
    }

    /// <summary>
    ///   For a given error message string of the following type - the line breaks are artificial
    ///     "Property ConnectTime (value=1965-01-01T05:00:00Z) "
    ///     "could not be converted to the specified type::" +
    ///     "Property StartTime (value=1965-01-01T05:00:00Z) " +
    ///     "could not be converted to the specified type::"
    ///     
    ///   Make sure the names specified in propertyDataList are each present a
    ///   specified number of times in the error message.
    /// </summary>
    /// <param name="errorMessage"></param>
    /// <param name="propertyDataList">ArrayList of ErrorProperty</param>
    private void CheckError(string errorMessage, ErrorProperty[] errorPropertyList) 
    {
      if (errorPropertyList != null) 
      {
        foreach(ErrorProperty errorProperty in errorPropertyList) 
        {
          int count = SubStringCount(errorMessage, errorProperty.name);
          // Very weak. But we may not find the property name in the message
          // because the message is truncated to 255 characters in the NetMeterClient db.
          Assert.IsTrue(count >= 0, 
                        String.Format("Expected to find {0} {1} number of times in error message!", 
                                      errorProperty.name, errorProperty.failureCount));
        }
      }
    }

    /// <summary>
    ///   Count the number of occurrences of a substring in a given string.
    /// </summary>
    /// <param name="strSource"></param>
    /// <param name="strToCount"></param>
    /// <returns></returns>
    public int SubStringCount(string original, string subString)
    {
      int count = 0;
      int pos = original.IndexOf(subString);
      while(pos != -1)
      {
        count++;
        original = original.Substring(pos + 1);
        pos = original.IndexOf(subString);
      }
      return count;
    }

    private string EscapeXMLCharacters(string originalValue) 
    {
      return regex.Replace(originalValue, new MatchEvaluator(this.ReplaceText));
    }

    private string ReplaceText(Match match) 
    {
      string result = "";
      string matchString = match.ToString();
      switch(matchString[0]) 
      {
        case '<' : 
        {
          result = "&lt;";
          break;
        }
        case '>' : 
        {
          result = "&gt;";
          break;
        }
        case '&' :
        {
          result = "&amp;";
          break;
        }
        default : 
        {
          throw new ApplicationException("Unexpected character '" + 
            matchString + 
            "' found");
        }
      }

      return result;
    }

    private string GetDBDateString(DateTime date, DBType dbType)
    {
      string dateString = date.ToString("yyyy'-'MM'-'dd");

      if (dbType == DBType.Oracle)
      {
        dateString = "to_date('" + dateString + "', 'YYYY-MM-DD')";
      }
      else 
      {
        dateString = "'" + dateString + "'";
      }

      return dateString;
    }

    /// <summary>
    ///   Dummy method for CR 13326
    /// </summary>
    private void TestDates()
    {
      // DateTime dt = new DateTime(1422, 1,1, new HijriCalendar());
      System.Globalization.DateTimeFormatInfo dtfi;
      dtfi = new System.Globalization.CultureInfo("en-US", false).DateTimeFormat;
      dtfi.Calendar = new System.Globalization.GregorianCalendar();
      DateTime dt = DateTime.Now;
      Console.WriteLine(dt.ToString("yyyy-MM-dd HH:mm:ss", dtfi));
      Console.WriteLine(dt.Date.ToString());
    }


    private string CreateAndSubscribeAccount(DateTime startDate)
    {
      string userName =  
        "FastSDKAccount_" + 
        ++accountCounter + "_" + 
        DateTime.Now.ToString("s", DateTimeFormatInfo.InvariantInfo);

      // Create the account
      TestCreateUpdateAccounts createUpdateAccounts = new TestCreateUpdateAccounts();
        
      createUpdateAccounts.YetAnotherCreateAccount(userName, 
                                                   "USD", 
                                                   "monthly", 
                                                   "CorporateAccount", 
                                                   userName,
                                                   true, 
                                                   "", 
                                                   "", 
                                                   @"metratech.com/accountcreation", 
                                                   31,
                                                   startDate, 
                                                   "USA", 
                                                   -1, 
                                                   null, 
                                                   false);

      int accountId = createUpdateAccounts.GetAccountID(userName);
      
      // Create the product offering if it doesn't exist
      if (!MetraTech.UsageServer.Test.Util.CheckProductOfferingExists(productOfferingName))
      {
        System.Diagnostics.ProcessStartInfo processStartInfo =
          new System.Diagnostics.ProcessStartInfo("pcimportexport");
        processStartInfo.Arguments = pcimportexportArgs;
        // processStartInfo.RedirectStandardOutput = true; 
        // processStartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden; 
        // processStartInfo.UseShellExecute = false; 
        System.Diagnostics.Process pcImportExport = System.Diagnostics.Process.Start(processStartInfo);

        //Wait for the window to finish loading.
        pcImportExport.WaitForInputIdle();
        //Wait for the process to end.
        pcImportExport.WaitForExit(90000); // 1.5 minute

        //Check to see if the process is still running.
        if (pcImportExport.HasExited == false)
        {
          //Process is still running.
          //Test to see if the process is hung up.
          if (pcImportExport.Responding)
          {
            //Process was responding; close the main window.
            pcImportExport.CloseMainWindow();
          }
          else
          {
            //Process was not responding; force the process to close.
            pcImportExport.Kill();
          }

          Assert.Fail("Product offering import timed out.");
        }
      }

      // (1) Create Session Context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      YAAC.IMTSessionContext sessionContext =
        (YAAC.IMTSessionContext)loginContext.Login("su", "system_user", "su123");

      // (2) Create the ProductCatalog
      IMTProductCatalog productCatalog = new MTProductCatalog();
      productCatalog.SetSessionContext
        ((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

      // Get the ProductOffering
      IMTProductOffering productOffering = productCatalog.GetProductOfferingByName(productOfferingName);
      Debug.Assert(productOffering != null);
 
      // (3) Get MTPCAccount
      IMTPCAccount pcAccount = productCatalog.GetAccount(accountId);

      // Create the timespan for the subscription. 
      // From now to infinity (and beyond)
      IMTPCTimeSpan timespan = new MTPCTimeSpan();
      timespan.StartDate = DateTime.UtcNow;
      timespan.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      timespan.SetEndDateNull();

      // Subscribe 
      object modified;
      MTSubscription subscription = 
        pcAccount.Subscribe(productOffering.ID, (MTPCTimeSpan)timespan, out modified);

      return userName;
    }

    #endregion

    #region Public methods

    #endregion

    #region Properties
    private IMeter Sdk
		{
			get
			{
				if (mSdk == null)
					mSdk = TestLibrary.InitSDK();

				return mSdk;
			}
		}

    private string ConfigFile
    {
      get
      {
        string configFile = sqlServerConfigFile;

        using (IMTConnection conn = ConnectionManager.CreateConnection(clientQueryPath))
        {
          if (conn.ConnectionInfo.DatabaseType == DBType.Oracle)
          {
            configFile = oracleConfigFile;
          }
        }

        return configFile;
      }
    }
    #endregion

    #region Data
		IMeter mSdk = null;
    Logger logger = new Logger("[MetraConnectTests]");
    int accountCounter = 0;
    const string audioConfCallSvc = "metratech.com/audioconfcall";
    const string audioConfConnectionSvc = "metratech.com/audioconfconnection";
    const string audioConfFeatureSvc = "metratech.com/audioconffeature";
    const int numAudioConfCallSvc = 1;
    const int numAudioConfConnectionSvc = 20;
    const int numAudioConfFeatureSvc = 7;
    const int numServices = 3;
    const int timeOutErrorCode = -516947931;
    const string unicodeString = "йцукенгшщзхїфівапролджєячсмитьБЮбю";
    // const string unicodeString = "Annulée";
    // format db date string to msix date
    const string strDateFormat = "yyyy-MM-ddTHH:mm:ssZ";
    Regex regex = new Regex("[<>&]");

    private int conferenceId = 0;
    private const string clientQueryPath = @"..\extensions\SmokeTest\config\queries\metering";
    private const string serverQueryPath = @"..\extensions\SmokeTest\config\queries\metering\Server";
    private const string sqlServerConfigFile = @"T:\Development\Metering\sdkconfig_fastSdk.xml";
    private const string oracleConfigFile = @"T:\Development\Metering\sdkconfig_fastSdk_oracle.xml";
    private const string audioConfCallTableName = "t_svc_audioConfCall";
    private const string audioConfConnectionTableName = "t_svc_audioConfConnection";
    private const string audioConfFeatureTableName = "t_svc_audioConfFeature";

    private const string audioConfProductOfferingFile = @"T:\Development\UI\Application Tests\MetraView\AudioConferencingPO.xml";
    // private const string audioConfProductOfferingFile = @"T:\QA\SharedLibraries\ProductCatalog\AccountType Restricted Product Offerings and Default Pricelists\DepartmentAccount Discount USD.xml";
    // private const string productOfferingName = "DepartmentAccount AudioConference USD"
    private const string productOfferingName = "AudioConference_MetraConnectTest";

    private const string pcimportexportArgs = 
      @"-ipo -file """ +
      @"T:\Development\Metering\AudioConferencePO.xml" +
      @""" -username su -password su123 -namespace system_user -skipintegrity";
    #endregion

    #region Private Classes
    private class ErrorProperty 
    {
      public ErrorProperty(string name, int failureCount) 
      {
        this.name = name;
        this.failureCount = failureCount;
      }
      public string name;
      public int failureCount;
    }
    #endregion
	}
}

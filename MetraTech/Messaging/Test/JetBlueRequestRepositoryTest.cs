using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MetraTech.Messaging.Framework.Messages;
using MetraTech.Messaging.Framework.Persistence;
using MetraTech.Messaging.Framework.Configurations;

namespace MetraTech.Messaging.Test
{
  //
  // To run the this test fixture:
  // S:\Thirdparty\NUnit260\bin\nunit-console-x86.exe o:\debug\Bin\MetraTech.Messaging.Test.dll /run:MetraTech.Messaging.Test.JetBlueRequestRepositoryTest
  //

  [TestClass]
  [ComVisible(false)]
  public class JetBlueRequestRepositoryTest
  {
    static Configuration cfg;
    string path = @"c:\temp\jet";

    [ClassInitialize]
	public static void InitTests(TestContext testContext)
    {
      string ConfigFileName = @"R:\config\Messaging\MessagingService.xml";
      cfg = ConfigurationManager.ReadFromXml(ConfigFileName);

    	MetraTech.Messaging.Test.JetBlueRequestRepositoryTest jbt =
    		new JetBlueRequestRepositoryTest();
      jbt.RecreateJetBlueDatabase();
    }

    private void RecreateJetBlueDatabase()
    {
      System.IO.Directory.CreateDirectory(path);

      JetBlueDatabase db = new JetBlueDatabase();
      db.DeleteDatabase(path);
      db.CreateDatabase(path);
    }

    [TestMethod()]
    public void TestGetRequest()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        Request msg = CreateTestRequest(1);
        repo.StoreRequest(msg);
        Request msg2 = repo.GetRequest(msg.CorrelationId) as Request;
        Assert.IsNotNull(msg2, "message not found in the database");
        Assert.AreEqual(msg.CorrelationId, msg2.CorrelationId, "Guid Comparison");
        Assert.AreEqual(msg.MessageBody, msg2.MessageBody, "body");
        // Do not compare dates, as some ticks were lost when stored in the database
        Assert.AreEqual(msg.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Create Date");
        Assert.AreEqual(msg.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Timeout Date");
        Assert.AreEqual(msg.IsTimeoutNeeded, msg2.IsTimeoutNeeded, "IsTimeoutNeeded");
        Assert.AreEqual(msg.ReplyToAddress, msg2.ReplyToAddress, "ReplyToAddress");
      }
    }

    [TestMethod()]
    public void TestDeleteRequest()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        Request msg = CreateTestRequest(2);
        repo.StoreRequest(msg);
        repo.DeleteRequest(msg.CorrelationId);
        Request msg2 = repo.GetRequest(msg.CorrelationId) as Request;
        Assert.IsNull(msg2, "Deleted message should not be in the database");
      }
    }

    [TestMethod()]
    public void TestCancelTimout()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        Request msg = CreateTestRequest(2);
        repo.StoreRequest(msg);
        repo.CancelTimeout(msg.CorrelationId);
        Request msg2 = repo.GetRequest(msg.CorrelationId) as Request;
        Assert.IsNotNull(msg2, "Cancel message should not be in the database");
        Assert.IsFalse(msg2.IsTimeoutNeeded, "Timeout is no longer needed");
      }
    }


    [TestMethod()]
    public void TestTimeouts()
    {
      //Recreate database so we can have a clean test
      RecreateJetBlueDatabase();
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        Dictionary<Guid, Request> requests = new Dictionary<Guid, Request>();
        for (int i = 0; i < 5; i++)
        {
          Request msg = CreateTestRequest(i);
          repo.StoreRequest(msg);
          requests.Add(msg.CorrelationId, msg);
        }
        Dictionary<Guid, Request> timeouts;

        timeouts = repo.GetTimeouts(DateTime.Now);
        Assert.AreEqual(0, timeouts.Count, "No requests should time out");

        // everything times out in 30 seconds, so 40 seconds will do
        timeouts = repo.GetTimeouts(DateTime.Now.AddSeconds(40));
        Assert.AreEqual(5, timeouts.Count, "All requests must time out");

        repo.CancelTimeout(requests.Keys.First<Guid>());
        timeouts = repo.GetTimeouts(DateTime.Now.AddSeconds(40));
        Assert.AreEqual(4, timeouts.Count, "only 4 must time out");

        // timeout everything
        repo.CancelTimeout(DateTime.Now.AddSeconds(40));
        timeouts = repo.GetTimeouts(DateTime.Now.AddSeconds(40));
        Assert.AreEqual(0, timeouts.Count, "No requests should time out");
      }
    }

    [TestMethod()]
    public void TestArchive()
    {
      int numberOfMessages = 10000;

      //Recreate database so we can have a clean test
      RecreateJetBlueDatabase();

      DateTime timeFirstMessageGenerated = DateTime.Now;

      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        Dictionary<Guid, Request> requests = new Dictionary<Guid, Request>();
        for (int i = 0; i < numberOfMessages; i++)
        {
          Request msg = CreateTestRequest(i);
          repo.StoreRequest(msg);
          requests.Add(msg.CorrelationId, msg);
        }
        Dictionary<Guid, Request> timeouts;

        //Single DateTime.Now after messages have been generated
        DateTime timelastMessageGenerated = DateTime.Now;

        // everything times out in 30 seconds, so 40 seconds will do
        timeouts = repo.GetTimeouts(timelastMessageGenerated.AddSeconds(40));
        Assert.AreEqual(numberOfMessages, timeouts.Count, "All requests must time out");

        repo.ArchiveOldRequests(timeFirstMessageGenerated.AddSeconds(-40)); //this should delete nothing.
        timeouts = repo.GetTimeouts(timelastMessageGenerated.AddSeconds(40));
        Assert.AreEqual(numberOfMessages, timeouts.Count, "All requests must still time out");

        repo.ArchiveOldRequests(timelastMessageGenerated.AddSeconds(60)); //this should delete everything.
        timeouts = repo.GetTimeouts(timelastMessageGenerated.AddSeconds(40));
        Assert.AreEqual(0, timeouts.Count, "No requests should exist and hence none should timeout");

        Assert.IsNull(repo.GetRequest(requests.Keys.First<Guid>()), "Must be deleted");

      }
    }



    [TestMethod()]
    [Ignore] // Only need to run this for performance testing
    public void TestPerformance()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        for (int i = 0; i++ < 1000; )
        {
          Request msg = CreateTestRequest(i);
          repo.StoreRequest(msg);
          if (i % 1000 == 0) repo.Flush();

          Request msg2 = repo.GetRequest(msg.CorrelationId);
          Assert.IsNotNull(msg2);
          Assert.AreEqual(msg.CorrelationId, msg2.CorrelationId, "Guid Comparison");
          Assert.AreEqual(msg.MessageBody, msg2.MessageBody, "body");
          // Do not compare dates, as some ticks were lost when stored in the database
          Assert.AreEqual(msg.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Create Date");
          Assert.AreEqual(msg.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Timeout Date");
          Assert.AreEqual(msg.IsTimeoutNeeded, msg2.IsTimeoutNeeded, "IsTimeoutNeeded");
          Assert.AreEqual(msg.ReplyToAddress, msg2.ReplyToAddress, "ReplyToAddress");
        }
      }
    }

    [TestMethod()]
    [Ignore] // Only need to run this for performance testing
    public void TestFlushOverflow()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        for (int i = 0; i<1000; i++)
          repo.Flush();
      }
    }

    [TestMethod()]
    [Ignore] // Only need to run this for performance testing
    public void TestFlushAdvanced()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        for (int i = 0; i++ < 1000; )
        {
          Request msg = CreateTestRequest(i);
          repo.StoreRequest(msg);
          if (i % 10 == 0) repo.Flush();

          Request msg2 = repo.GetRequest(msg.CorrelationId);
          Assert.IsNotNull(msg2);
          Assert.AreEqual(msg.CorrelationId, msg2.CorrelationId, "Guid Comparison");
          Assert.AreEqual(msg.MessageBody, msg2.MessageBody, "body");
          // Do not compare dates, as some ticks were lost when stored in the database
          Assert.AreEqual(msg.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Create Date");
          Assert.AreEqual(msg.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Timeout Date");
          Assert.AreEqual(msg.IsTimeoutNeeded, msg2.IsTimeoutNeeded, "IsTimeoutNeeded");
          Assert.AreEqual(msg.ReplyToAddress, msg2.ReplyToAddress, "ReplyToAddress");
        }
      }
    }

    [TestMethod()]
    [Ignore] // Only need to run this for performance testing
    [TestCategory("Performance")]
    [TestCategory("TestStoreRequestPerformance")]
    public void TestStoreRequestPerformance()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        repo.Flush();

        DateTime testStart = DateTime.Now;

        int msgCount = 0;
        for (int i = 0; i++ < 2000; )
        {
          Request msg = CreateTestRequest(i);
          repo.StoreRequest(msg);
          msgCount++;
        }
        repo.Flush();
        DateTime testEnd = DateTime.Now;

        double msgsPerSecond = (msgCount / (testEnd - testStart).TotalSeconds);
        Console.WriteLine("TestStoreRequestPerformance: Stored {0} in {1} ({2:0}/second)", msgCount, (testEnd - testStart).TotalSeconds, msgsPerSecond);

      	Assert.IsTrue(msgsPerSecond >= 500);
      }
    }

    [TestMethod()]
    public void TestFlushSimple()
    {
      using (JetBlueRequestRepository repo = new JetBlueRequestRepository(path))
      {
        repo.Flush();
        for (int i = 0; i++ < 3; )
        {
          Request msg = CreateTestRequest(i);
          repo.StoreRequest(msg);
          repo.Flush();

          Request msg2 = repo.GetRequest(msg.CorrelationId);
          Assert.IsNotNull(msg2);
          Assert.AreEqual(msg.CorrelationId, msg2.CorrelationId, "Guid Comparison");
          Assert.AreEqual(msg.MessageBody, msg2.MessageBody, "body");
          // Do not compare dates, as some ticks were lost when stored in the database
          Assert.AreEqual(msg.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.CreateDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Create Date");
          Assert.AreEqual(msg.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), msg2.TimeoutDate.ToString("yyyy-MM-dd HH:mm:ss.fff"), "Timeout Date");
          Assert.AreEqual(msg.IsTimeoutNeeded, msg2.IsTimeoutNeeded, "IsTimeoutNeeded");
          Assert.AreEqual(msg.ReplyToAddress, msg2.ReplyToAddress, "ReplyToAddress");
        }
      }
    }

    private static Request CreateTestRequest(int i)
    {
      Request msg = new Request();
      msg.CorrelationId = Guid.NewGuid();
      msg.CreateDate = DateTime.Now;
      msg.TimeoutDate = DateTime.Now.AddSeconds(30);
      msg.SetRequestBodyAsXml(string.Format("<root>{0}</root>", i));
      msg.IsTimeoutNeeded = true;
      msg.ReplyToAddress = "MyQueue";
      return msg;
    }

  }

}

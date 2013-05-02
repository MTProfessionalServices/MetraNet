using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UsageServer;
using MetraTech.DataAccess;


//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.ScheduleAdapterServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//

namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
  public class ScheduleAdapterServiceTests
  {
    [Test]
    [Category("GetRecurrencePatternTest")]
    public void GetRecurrencePatternTest()
    {
      Hashtable schedules;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        RecurringEventManager manager = new RecurringEventManager();
        schedules = manager.ReadDBSchedulesScheduled(conn);
      }
      ScheduleAdapterServiceClient client = new ScheduleAdapterServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      foreach (int eventId in schedules.Keys)
      {
        ArrayList scheduleList = (ArrayList)schedules[eventId];
        RecurringEventSchedule schedule = (RecurringEventSchedule)scheduleList[0];
        BaseRecurrencePattern pattern1 = schedule.Pattern;
        BaseRecurrencePattern pattern2;
        client.GetRecurrencePattern(eventId, out pattern2);
        Assert.AreEqual(pattern1.ToString(), pattern2.ToString(), "patterns missmatch for event id "+eventId.ToString());
      }
    }
    const string mTestDir = "t:\\Development\\Core\\UsageServer\\";

    [Test]
    [Category("UpdateAccountIntervalsTest")]
    public void UpdateRecurrencePatternTest()
    {
      Hashtable schedules;
      RecurringEventManager manager = new RecurringEventManager();
      ArrayList addedEvents, removedEvents, modifiedEvents;
      //
      // reads in a mock configuration file
      //
      manager.Synchronize(mTestDir + "recurring_events_test15.xml", out addedEvents, out removedEvents, out modifiedEvents);

      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        schedules = manager.ReadDBSchedulesScheduled(conn);
      }
      ScheduleAdapterServiceClient client = new ScheduleAdapterServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      foreach (int eventId in schedules.Keys)
      {
        ArrayList scheduleList = (ArrayList)schedules[eventId];
        RecurringEventSchedule schedule = (RecurringEventSchedule)scheduleList[0];
        BaseRecurrencePattern pattern1 = schedule.Pattern;
        pattern1.IsSkipOne = true;
        client.UpdateRecurrencePattern(eventId, pattern1);
        BaseRecurrencePattern pattern2;
        client.GetRecurrencePattern(eventId, out pattern2);
        Assert.IsTrue(pattern2.IsSkipOne);
        Assert.AreEqual(pattern1.ToString(), pattern2.ToString(), "patterns missmatch for event id " + eventId.ToString());
      }

      manager.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
    }

  }
}

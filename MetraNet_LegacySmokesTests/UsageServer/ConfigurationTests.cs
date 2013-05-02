namespace MetraTech.UsageServer.Test
{
	using System;
	using System.Runtime.InteropServices;
	using System.Collections;
  using System.Collections.Generic;
  using System.IO;

	using NUnit.Framework;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.UsageServer.Test.ConfigurationTests /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class ConfigurationTests 
	{
		const string mTestDir = "t:\\Development\\Core\\UsageServer\\";

		/// <summary>
		/// Tests that the system disallows scheduled events from depending on EOP events
		/// </summary>
		[Test]
    [ExpectedException(typeof(IncompatibleEventTypeDependencyException))]
    public void T01TestScheduledEventDependingOnEOPEventFailure()
		{
			SynchronizeEvents("recurring_events_test1.xml");
		}

		/// <summary>
		/// Tests that the system disallows EOP events from depending on other EOP events
		/// with different recurrence patterns
		/// </summary>
		[Test]
    [ExpectedException(typeof(IncompatibleUsageCycleTypeDependencyException))]
    public void T02TestRecurrencePatternMismatchFailure()
		{
			SynchronizeEvents("recurring_events_test2.xml");
		}

		/// <summary>
		/// Tests that the system disallows a set of EOP events with at least one 'All' usage cycle type
		/// and at least one non-all event. In order to use 'All', all events must use it.
		/// </summary>
		[Test]
		[ExpectedException(typeof(NonExclusiveUsageCycleTypeException))]
    public void T03TestNonExclusiveAllCycleTypeFailure()
		{
			SynchronizeEvents("recurring_events_test3.xml");
		}

		/// <summary>
		/// Tests that a recurring event cannot have the same name as another event
		/// </summary>
		[Test]
		[ExpectedException(typeof(DuplicateRecurringEventNameException))]
    public void T04TestDuplicateEventNameFailure()
		{
			SynchronizeEvents("recurring_events_test6.xml");
		}

		/// <summary>
		/// Tests that a non-integer value is rejected for the 
		/// IntervalInMinutes scheduled adapter setting.
		/// </summary>
		[Test]
		[ExpectedException(typeof(BadXmlException))]
    public void T05TestNonIntegerIntervalInMinutesValueFailure()
		{
			SynchronizeEvents("recurring_events_test12.xml");
		}


		//
		// dependency test cases
		//
			
		/// <summary>
		/// Tests that a recurring events cannot have circular dependencies
		/// </summary>
		[Test]
		[ExpectedException(typeof(CircularDependencyException))]
    public void T06TestCircularDependencyFailure()
		{
			SynchronizeEvents("recurring_events_test7.xml");
		}

		/// <summary>
		/// Tests that a recurring event cannot depend on a non-existent event 
		/// </summary>
		[Test]
		[ExpectedException(typeof(RecurringEventNotFoundException))]
    public void T07TestMissingDependentEventFailure()
		{
			SynchronizeEvents("recurring_events_test4.xml");
		}
			
		/// <summary>
		/// Tests that a recurring event cannot make a non-existent event depend on itself
		/// </summary>
		[Test]
		[ExpectedException(typeof(RecurringEventNotFoundException))]
    public void T08TestMissingDependsOnMeEventFailure()
		{
			SynchronizeEvents("recurring_events_test5.xml");
		}


		//
		// adapter tests
		//
		
		/// <summary>
		/// Tests that an adapter with a bogus class name will fail to be created
		/// </summary>
		[Test]
		[ExpectedException(typeof(AdapterCreationException))]
    public void T09TestAdapterCreationFailure()
		{
			SynchronizeEvents("recurring_events_test8.xml");
		}

		/// <summary>
		/// Tests adapter initialization failure
		/// </summary>
		[Test]
		[ExpectedException(typeof(AdapterInitializationException))]
    public void T10TestAdapterInitializationFailure()
		{
			SynchronizeEvents("recurring_events_test9.xml");
		}

		/// <summary>
		/// Tests adapter shutdown failure
		/// </summary>
		[Test]
		[ExpectedException(typeof(AdapterShutdownException))]
    public void T11TestAdapterShutdownFailure()
		{
			SynchronizeEvents("recurring_events_test10.xml");
		}

		/// <summary>
		/// Tests that an adapter which has a valid class name but
		/// does not implement the adapter interface will fail
		/// </summary>
		[Test]
		[ExpectedException(typeof(AdapterCreationException))]
    public void T12TestAdapterNotImplementedFailure()
		{
			SynchronizeEvents("recurring_events_test11.xml");
		}


		//
		// interval configuration tests
		//

		/// <summary>
		/// Tests that the advance interval creation days setting cannot be negative 
		/// </summary>
		[Test]
		[ExpectedException(typeof(NegativeValueException))]
    public void T13TestNegativeAdvanceIntervalCreationDaysFailure()
		{
			SynchronizeIntervals("usageserver_test1.xml");
		}

		/// <summary>
		/// Tests that an interval grace peirod setting cannot be negative
		/// </summary>
		[Test]
		[ExpectedException(typeof(NegativeValueException))]
    public void T14TestNegativeGracePeriodFailure()
		{
			SynchronizeIntervals("usageserver_test2.xml");
		}

		/// <summary>
		/// Tests that a missing 'enabled' attribute on a grace period setting will fail
		/// </summary>
		[Test]
		[ExpectedException(typeof(InvalidConfigurationException))]
    public void T15TestMissingEnabledAttributeGracePeriodFailure()
		{
			SynchronizeIntervals("usageserver_test3.xml");
		}

		/// <summary>
		/// Tests that a missing cycle type grace period setting fails
		/// </summary>
		[Test]
		[ExpectedException(typeof(InvalidConfigurationException))]
    public void T16TestMissingCycleTypeGracePeriodFailure()
		{
			SynchronizeIntervals("usageserver_test4.xml");
		}

		/// <summary>
		/// Tests that an old version of the config file fails to load
		/// </summary>
		[Test]
		[ExpectedException(typeof(ConfigFileVersionMismatchException))]
    public void T17TestUsageServerXMLVersionMismatchFailure()
		{
			SynchronizeIntervals("usageserver_test5.xml");
		}

		/// <summary>
		/// Tests that the interval settings are being correctly updated
		/// </summary>
		[Test]
    public void T18TestUsageServerXMLSynchronize()
		{
			SynchronizeIntervals("usageserver_test6.xml");
			Client client = new Client();
			Assert.AreEqual(25, client.AdvanceIntervalCreationDays);
			Assert.AreEqual(1, client.GetSoftCloseGracePeriod(CycleType.Daily));
			Assert.AreEqual(2, client.GetSoftCloseGracePeriod(CycleType.Weekly));
			Assert.AreEqual(3, client.GetSoftCloseGracePeriod(CycleType.BiWeekly));
			Assert.AreEqual(4, client.GetSoftCloseGracePeriod(CycleType.SemiMonthly));
			Assert.AreEqual(false, client.IsSoftCloseGracePeriodEnabled(CycleType.Monthly));
			Assert.AreEqual(6, client.GetSoftCloseGracePeriod(CycleType.Quarterly));
			Assert.AreEqual(7, client.GetSoftCloseGracePeriod(CycleType.Annual));

			// syncs with a different file and validate updates
			SynchronizeIntervals("usageserver_test7.xml");
			Assert.AreEqual(7, client.AdvanceIntervalCreationDays);
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.Daily));
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.Weekly));
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.BiWeekly));
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.SemiMonthly));
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.Monthly));
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.Quarterly));
			Assert.AreEqual(0, client.GetSoftCloseGracePeriod(CycleType.Annual));

			// syncs with the first file again - results should be the same as the first sync
			SynchronizeIntervals("usageserver_test6.xml");
			Assert.AreEqual(25, client.AdvanceIntervalCreationDays);
			Assert.AreEqual(1, client.GetSoftCloseGracePeriod(CycleType.Daily));
			Assert.AreEqual(2, client.GetSoftCloseGracePeriod(CycleType.Weekly));
			Assert.AreEqual(3, client.GetSoftCloseGracePeriod(CycleType.BiWeekly));
			Assert.AreEqual(4, client.GetSoftCloseGracePeriod(CycleType.SemiMonthly));
			Assert.AreEqual(false, client.IsSoftCloseGracePeriodEnabled(CycleType.Monthly));
			Assert.AreEqual(6, client.GetSoftCloseGracePeriod(CycleType.Quarterly));
			Assert.AreEqual(7, client.GetSoftCloseGracePeriod(CycleType.Annual));
		}

		/// <summary>
		/// Reads events in from config file, stores in database, retrieves from database, and compares
		/// results to the original.
		/// </summary>
		[Test]
    public void T19TestEventSynchronization()
		{
			// reads an event config file with no events - effectively deactivating all events
			// This gets us to a known point for further event synchronization tests. 
 			RecurringEventManager manager = new RecurringEventManager();
			ArrayList addedEvents, removedEvents, modifiedEvents;
			manager.Synchronize(mTestDir + "recurring_events_test_empty.xml", out addedEvents, out removedEvents, out modifiedEvents);

			Assert.AreEqual(0, addedEvents.Count, "Added count mismatch");
			Assert.AreEqual(0, modifiedEvents.Count, "Modified count mismatch");
			// a verifiable count for removedEvents.Count is difficult since we don't know 
			// what events were previously in the database

			Hashtable dbEvents   = manager.LoadEventsFromDB();
			Hashtable fileEvents = manager.LoadEventsFromFile(mTestDir + "recurring_events_test_empty.xml");

			// only the internal start and end root events should now exist
			Assert.AreEqual(2, dbEvents.Count, "<> 2 database events found!");
			Assert.AreEqual(2, fileEvents.Count, "<> 2 file events found!");
			foreach (RecurringEvent recurringEvent in dbEvents.Values)
				if ((recurringEvent.Name != "_StartRoot") && (recurringEvent.Name != "_EndRoot"))
					Assert.Fail("Unexpected event name found: " + recurringEvent.Name);
			foreach (RecurringEvent recurringEvent in fileEvents.Values)
				if ((recurringEvent.Name != "_StartRoot") && (recurringEvent.Name != "_EndRoot"))
					Assert.Fail("Unexpected event name found: " + recurringEvent.Name);


			//
			// reads in a mock configuration file
			//
			manager.Synchronize(mTestDir + "recurring_events_test13.xml", out addedEvents, out removedEvents, out modifiedEvents);

			// asserts that the sync counts are correct
			Assert.AreEqual(11, addedEvents.Count, "Added count mismatch");
			Assert.AreEqual(0, modifiedEvents.Count, "Modified count mismatch");
			Assert.AreEqual(0, removedEvents.Count, "Removed count mismatch");

			// compares events from DB and from config file to make sure they match
			dbEvents   = manager.LoadEventsFromDB();
			fileEvents = manager.LoadEventsFromFile(mTestDir + "recurring_events_test13.xml");
			foreach (RecurringEvent dbEvent in dbEvents.Values)
				if (!dbEvent.Equals((RecurringEvent) fileEvents[dbEvent.Name]))
					Assert.Fail("Database event and file event do not match: " + dbEvent.Name);

			// validates _EndRoot dependencies 
			RecurringEvent endRoot = (RecurringEvent) dbEvents["_EndRoot"];
			Assert.AreEqual(1, endRoot.Dependencies.Count, "_EndRoot has more than 1 dependency!");
			Assert.AreEqual(true, ContainsEvent(endRoot.Dependencies, "Work"), "Missing 'Work' dependency!");

			// validates extra dependencies were successfully pruned
			RecurringEvent leaveHouseCheckpoint = (RecurringEvent) dbEvents["LeaveHouseCheckpoint"];
			Assert.AreEqual(1, leaveHouseCheckpoint.Dependencies.Count, "LeaveHouseCheckpoint has more than 1 dependency!");
			Assert.AreEqual(true, ContainsEvent(leaveHouseCheckpoint.Dependencies, "EatBreakfast"), "Missing 'EatBreakfast' dependency!");

			// validates special 'AllEOP' dependency was handled correctly
			RecurringEvent work = (RecurringEvent) dbEvents["Work"];
			Assert.AreEqual(2, work.Dependencies.Count, "Work event has more than 2 dependencies!");
			Assert.AreEqual(true, ContainsEvent(work.Dependencies, "DriveToWork"), "Missing 'DriveToWork' dependency!");
			Assert.AreEqual(true, ContainsEvent(work.Dependencies, "CheckNews"), "Missing 'CheckNews' dependency!");


			//
			// syncs again with no change made to config file - nothing should happen
			//
			manager.Synchronize(mTestDir + "recurring_events_test13.xml", out addedEvents, out removedEvents, out modifiedEvents);
			Assert.AreEqual(0, addedEvents.Count + removedEvents.Count + modifiedEvents.Count, "Change should not have been detected!");


			//
			// syncs with a slightly modified config file - HasFood was removed
			//
			manager.Synchronize(mTestDir + "recurring_events_test14.xml", out addedEvents, out removedEvents, out modifiedEvents);
			Assert.AreEqual(0, addedEvents.Count, "Added count mismatch");
			Assert.AreEqual(2, modifiedEvents.Count, "Modified count mismatch");
			Assert.AreEqual(1, removedEvents.Count, "Removed count mismatch");

			Assert.AreEqual(true, ContainsEvent(removedEvents, "HasFood"), "HasFood event wasn't removed");
			Assert.AreEqual(true, ContainsEvent(modifiedEvents, "EatBreakfast"), "EatBreakfast event wasn't modified");

			// compares events from DB and from config file to make sure they match
			dbEvents   = manager.LoadEventsFromDB();
			fileEvents = manager.LoadEventsFromFile(mTestDir + "recurring_events_test14.xml");
			foreach (RecurringEvent dbEvent in dbEvents.Values)
				if (!dbEvent.Equals((RecurringEvent) fileEvents[dbEvent.Name]))
					Assert.Fail("Database event and file event do not match: " + dbEvent.Name);

			// validates _EndRoot dependencies - shouldn't have changed 
			endRoot = (RecurringEvent) dbEvents["_EndRoot"];
			Assert.AreEqual(1, endRoot.Dependencies.Count, "_EndRoot has more than 1 dependency!");
			Assert.AreEqual(true, ContainsEvent(endRoot.Dependencies, "Work"), "Missing 'Work' dependency!");

			// validates special 'AllEOP' dependency was handled correctly - shouldn't have changed
			work = (RecurringEvent) dbEvents["Work"];
			Assert.AreEqual(2, work.Dependencies.Count, "Work event has more than 2 dependencies!");
			Assert.AreEqual(true,
														 ContainsEvent(work.Dependencies, "DriveToWork"), "Missing 'DriveToWork' dependency!");
			Assert.AreEqual(true,
														 ContainsEvent(work.Dependencies, "CheckNews"), "Missing 'CheckNews' dependency!");

			// validates that the 'HasFood' dependency was actually removed
			RecurringEvent eatBreakfast = (RecurringEvent) dbEvents["EatBreakfast"];
			Assert.AreEqual(1, eatBreakfast.Dependencies.Count, "Should only have 1 dependency!");
			Assert.AreEqual(false,
														 ContainsEvent(eatBreakfast.Dependencies, "HasFood"), "'HasFood' dependency shouldn't exist!");


			//
			// returns the system to the original state (reads in extension based recurring_events.xml files)
			//
			manager.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
			Assert.AreEqual(10, removedEvents.Count, "10 events should have been removed!");
		}

    /// <summary>
    /// For new recurrency pattern
    /// Reads events in from config file, stores in database, retrieves from database, and compares
    /// results to the original.
    /// </summary>
    [Test]
    public void T20TestRecurrencyPatternSynchronization()
    {
      RecurringEventManager manager = new RecurringEventManager();
      ArrayList addedEvents, removedEvents, modifiedEvents;
      //
      // reads in a mock configuration file
      //
      manager.Synchronize(mTestDir + "recurring_events_test15.xml", out addedEvents, out removedEvents, out modifiedEvents);

      // asserts that the sync counts are correct
      Assert.AreEqual(6, addedEvents.Count, "Added count mismatch");
      Assert.AreEqual(0, modifiedEvents.Count, "Modified count mismatch");
      //Assert.AreEqual(0, removedEvents.Count, "Removed count mismatch");

      // compares events from DB and from config file to make sure they match
      Hashtable dbEvents = manager.LoadEventsFromDB();
      Hashtable fileEvents = manager.LoadEventsFromFile(mTestDir + "recurring_events_test15.xml");
      foreach (RecurringEvent dbEvent in dbEvents.Values)
        if (!dbEvent.Equals((RecurringEvent)fileEvents[dbEvent.Name]))
          Assert.Fail("Database event and file event do not match: " + dbEvent.Name);

      //
      // returns the system to the original state (reads in extension based recurring_events.xml files)
      //
      manager.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
    }

    /// <summary>
    /// For new recurrency pattern
    /// Reads events in from config file, stores in database, retrieves from database, and compares
    /// results to the original.
    /// </summary>
    [Test]
    public void T21TestRecurrencyPatternSynchronizationInFile()
    {
      RecurringEventManager manager = new RecurringEventManager();
      ArrayList addedEvents, removedEvents, modifiedEvents;
      List<RecurringEvent> modifiedEventsFile;
      //
      // reads in a mock configuration file
      //
      manager.Synchronize(mTestDir + "recurring_events_test15.xml", out addedEvents, out removedEvents, out modifiedEvents);
      File.Copy(mTestDir + "recurring_events_test16.xml", mTestDir + "recurring_events_temp.xml", true);
      manager.SynchronizeFile(mTestDir + "recurring_events_temp.xml", out modifiedEventsFile);
      Assert.AreEqual(5, modifiedEventsFile.Count);

      Hashtable fileEvents1 = manager.LoadEventsFromFile(mTestDir + "recurring_events_test15.xml");
      Hashtable fileEvents2 = manager.LoadEventsFromFile(mTestDir + "recurring_events_temp.xml");
      //TODO: compare events
      foreach (string name in fileEvents1.Keys)
      {
        RecurringEvent event1 = (RecurringEvent)fileEvents1[name];
        RecurringEvent event2 = (RecurringEvent)fileEvents2[name];
        Assert.AreEqual(event1.Schedules[0], event2.Schedules[0], name + " - event schedules do not match");
      }

      //
      // returns the system to the original state (reads in extension based recurring_events.xml files)
      //
      manager.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
    }


		private bool ContainsEvent(ArrayList list, string name)
		{
			foreach (RecurringEvent recurringEvent in list)
				if (recurringEvent.Name == name)
					return true;

			return false;
		}

		private void SynchronizeEvents(string filename)
		{
 			RecurringEventManager manager = new RecurringEventManager();
			ArrayList addedEvents, removedEvents, modifiedEvents;
			manager.Synchronize(mTestDir + filename, out addedEvents, out removedEvents, out modifiedEvents);
		}

		private void SynchronizeIntervals(string filename)
		{
			UsageIntervalManager manager = new UsageIntervalManager();
			manager.Synchronize(mTestDir + filename);
		}

	}
}

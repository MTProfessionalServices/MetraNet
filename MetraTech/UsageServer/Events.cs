
namespace MetraTech.UsageServer
{
	using System;
	using System.Collections;
	using System.Collections.Specialized;
  using System.Data;
  using System.Diagnostics;
	using System.Xml;
	using System.Text;
	using System.Runtime.InteropServices;
	using System.Threading;
  using System.Collections.Concurrent;
  using System.Collections.Generic;
  using System.Threading.Tasks;

  using MetraTech;
  using MetraTech.DataAccess;
  using MetraTech.Interop.MTAuth;
	using MetraTech.Xml;

	using RCD = MetraTech.Interop.RCD;
	using DataExporter = MetraTech.Interop.MTDataExporter;
	using Rowset = MetraTech.Interop.Rowset;
	using QueryAdapter = MetraTech.Interop.QueryAdapter;
	using Auth = MetraTech.Interop.MTAuth;
  using System.IO;

	/// <summary>
	/// Type of event
	/// </summary>
	[Guid("772C2F7A-9C3F-31C4-853B-36B7E23016ED")]
	public enum RecurringEventType
	{
		/// <summary>
		/// the root event (internal use only)
		/// </summary>
		Root,

		/// <summary>
		/// scheduled event
		/// </summary>
		Scheduled,

		/// <summary>
		/// usage interval closure event
		/// </summary>
		EndOfPeriod,

		/// <summary>
		/// checkpoint event.
		/// </summary>
		Checkpoint,
	}


	/// <summary>
	/// Type of a schedule
	/// </summary>
	[Guid("8EE10F2F-71CA-3610-91FF-32C953B78920")]
	public enum RecurringEventScheduleType
	{
		CycleType,
		Cycle,
		RecurrencePattern,
	}

  /// <summary>
	/// Description of a recurring event cycle
	/// </summary>
	[Guid("01796e7e-d558-45cc-bed0-7f4acbc37fe2")]
	public interface IRecurringEventSchedule
	{
		/// <summary>
		/// If true, run on each cycle of the given type.  Otherwise
		/// run only at the end of a specific cycle.
		/// </summary>
		RecurringEventScheduleType Type
		{ get; set; }

		/// <summary>
		/// Cycle type.  Event will be run at the end of any cycle of this type
		/// </summary>
		CycleType CycleType
		{ get; set; }

		/// <summary>
		/// Cycle ID.  Event will be run at at the end of a specific cycle
		/// </summary>
		int CycleID
		{ get; set; }

		/// <summary>
		/// Event will be run based on the recurrence pattern. Scheduled events only
		/// </summary>
		BaseRecurrencePattern Pattern
		{get; set;}
	}


	/// <summary>
	/// Meta-data describing recurring event
	/// </summary>
	[Guid("620f3974-75e6-4c7e-a1a9-fd561212fa98")]
	public interface IRecurringEvent
	{
		/// <summary>
		/// unique ID of this event, if known.
		/// </summary>
		int EventID
		{ get; set; }

		/// <summary>
		/// Type of recurring event
		/// </summary>
		RecurringEventType Type
		{ get; set; }

		/// <summary>
		/// Extension name where this event is configured.  Used
		/// to locate configuration file.
		/// </summary>
		string ExtensionName
		{ get; set; }

		/// <summary>
		/// Event name.  Used to configure dependencies between events.
		/// </summary>
		string Name
		{ get; set; }

		/// <summary>
		/// Event name.  Used to configure dependencies between events.
		/// </summary>
		string DisplayName
		{ get; set; }

		/// <summary>
		/// Class name of event.
		/// </summary>
		string ClassName
		{ get; set; }

		/// <summary>
		/// Config file passed to event
		/// </summary>
		string ConfigFileName
		{ get; set; }

		/// <summary>
		/// Description of the event
		/// </summary>
		string Description
		{ get; set; }

		/// <summary>
		/// ability to reverse event.
		/// </summary>
		ReverseMode Reversibility
		{ get; set; }

		/// <summary>
		/// allows the system to run multiple instances of the adapter concurrently
		/// </summary>
		bool AllowMultipleInstances
		{ get; set; }

    /// <summary>
    ///   Billing group support by adapter
    /// </summary>
    BillingGroupSupportType BillingGroupSupport
      { get; set; }
	}

	/// <summary>
	/// Status of an event instance
	/// </summary>
	[Guid("D42CF893-800D-3D77-90E5-04CCC2616C90")]
	public enum RecurringEventInstanceStatus
	{
		NotYetRun,
		ReadyToRun,
		Running,
		Succeeded,
		Failed,
		ReadyToReverse,
		Reversing
	}

	/// <summary>
	/// Actions that an event can perform
	/// </summary>
	[Guid("C8056E8E-905A-3D8F-80B8-7AEAD57D8921")]
	public enum RecurringEventAction
	{
		Execute,
		Reverse
	}

	/// <summary>
	/// Type of a dependency
	/// </summary>
	[Guid("8C95CB93-1CA9-3061-BDBD-F3C43E104339")]
	public enum RecurringEventDependencyType
	{
		Execution,
		Reversal
	}

	/// <summary>
	/// Status of a dependency
	/// </summary>
	[Guid("E722F4E2-E816-3629-8D2C-71FBC249D94F")]
	public enum RecurringEventDependencyStatus
	{
		Satisfied,
		Unsatisfied,
		All,
	}

	/// <summary>
	/// The status of an event run
	/// </summary>
	[Guid("EF31D192-15BC-3EA3-ABF6-6264055CF35E")]
	public enum RecurringEventRunStatus
	{
		InProgress,
		Succeeded,
		Failed
	}

	/// <summary>
	/// A collection-based filter for describing multiple event instances
	/// </summary>
	[Guid("c574b6e7-5ccf-4c77-bda9-4318021762ce")]
	public interface IRecurringEventFilter : IEnumerable 
	{
		int EventID 
		{get; set;}

		string Name
		{ get; set; }

		void AddTypeCriteria(RecurringEventType type);

		void ClearCriteria();
	}

	/// <summary>
	/// A collection-based filter for describing multiple event instances
	/// </summary>
	[Guid("ab3259d8-ae47-4da7-b24a-5e7baef544c4")]
	public interface IRecurringEventInstanceFilter : IEnumerable 
	{
		void AddStatusCriteria(RecurringEventInstanceStatus status);
		ArrayList GetStatusCriteria();

		void AddEventTypeCriteria(RecurringEventType type);
		
		void AddInstanceCriteria(int intstanceID);
		ArrayList GetInstanceCriteria();

		int UsageIntervalID 
		{ get; set; }

    int BillingGroupID 
    { get; set; }

		string EventName
		{ get; set; }

		DateTime StartDate
    { get; set; }

		DateTime EndDate
		{ get; set; }

		void ClearCriteria();

		/// <summary>
		/// Applies the given filter criteria and populates the internal collection of instance IDs
		/// </summary>
		/// <returns>Number of instances added to the collection</returns>
		int Apply();

		/// <summary>
		/// Determines if the filter criteria have been applied or not.
		/// NOTE: adding additional criteria after calling Apply will cause this to return false
		/// </summary>
		bool Applied
		{ get; }

		/// <summary>
		/// The number of instance IDs that matched the filter criteria
		/// </summary>
		int Count
		{ get; } 

		/// <summary>
		/// Returns a string of comma separated instance IDs that matched the filter criteria 
		/// </summary>
		string ToCSVString();

		/// <summary>
		/// Clear the current results from the last call to Apply.
		/// </summary>
		void ClearResults();

		Rowset.IMTSQLRowset GetEndOfPeriodRowset(bool includeEndOfPeriod, bool includeCheckpoint);
    Rowset.IMTSQLRowset GetEndOfPeriodRowset(bool includeEndOfPeriod, bool includeCheckpoint, bool includeRoot);
		Rowset.IMTSQLRowset GetScheduledRowset();
	}


	/// <summary>
	/// A filter for describing a subset of event runs
	/// </summary>
	[Guid("63fc29be-bbfb-4e4b-8f2c-4dd7405d92dd")]
	public interface IRecurringEventRunFilter
	{
		int InstanceID 
		{get; set;}

		RecurringEventRunStatus Status 
		{get; set;}

		RecurringEventAction Action
		{get; set;}

		DateTime BeforeDate
    { get; set; }

		Rowset.IMTSQLRowset GetRowset();
		void ClearCriteria();
	}

	/// <summary>
	/// Called in ProcessEvents to determine whether more
	/// processing can be done. Used by the Billing Server service
	/// to bring the system down quickly.
	/// NOTE: located here because of circular build reference issues
	/// </summary>
	[ComVisible(false)]
	public class HaltProcessingCallback 
	{
		public HaltProcessingCallback()
		{
			mIsShuttingDown = false;
			mIsAbortable = false;
		}

		// determines whether the process is currently shutting down.
		// used to safely breaking out of deep loops inside of the
		// RecurringEventManager.ProcessEvents method
		// NOTE: should only be set by Processor
		public bool IsShuttingDown
		{
			set 
			{
				lock (this)
				{
					mIsShuttingDown = value;
				}
			}
			get { return mIsShuttingDown; }
		}

		public bool IsAbortable
		{
			set
			{
				lock (this)
				{
					mIsAbortable = value;
				}
			}
			get	{	return mIsAbortable; }
		}
		
		bool mIsAbortable;
		bool mIsShuttingDown;
	}


	/// <summary>
	/// Manages recurring events
	/// </summary>
	[ComVisible(false)]
  public class RecurringEventManager
  {
    /// <summary>
    /// constructor
    /// </summary>
    public RecurringEventManager()
    {
      RecurringEventManagerBaseConstructor();
    }

    /// <summary>
    /// For testing purposes, allow the machineIdentifier to be overwridden during
    /// the creation of the RecurringEventManager
    /// </summary>
    /// <param name="machineIdentifier"></param>
    public RecurringEventManager(string machineIdentifier)
    {
      //For testing purposes, allow the machineIdentifier to be overwridden
      this.mMachineIdentifier = machineIdentifier;

      RecurringEventManagerBaseConstructor();
    }

    /// <summary>
    /// Shared code between the different constructors
    /// </summary>
    private void RecurringEventManagerBaseConstructor()
    {
      mLogger = new Logger("[UsageServer]");

      if (mRcd == null)
        mRcd = (RCD.IMTRcd)new RCD.MTRcd();
    }


	  public void Synchronize(out ArrayList addedEvents,
														out ArrayList removedEvents,
														out ArrayList modifiedEvents)
		{
			SynchronizeDatabase(LoadEventsFromFile(), out addedEvents, out removedEvents, out modifiedEvents);
		}

	  public void Synchronize(string configFile,
														out ArrayList addedEvents, 
														out ArrayList removedEvents,
														out ArrayList modifiedEvents)
		{
			SynchronizeDatabase(LoadEventsFromFile(configFile), out addedEvents, out removedEvents, out modifiedEvents);
		}

    public void SynchronizeFile(string configFile, out List<RecurringEvent> modifiedEvents)
    {
      List<string> configFiles = new List<string>();
      configFiles.Add(configFile);
      SynchronizeFile(configFiles, out modifiedEvents);
    }

    public void SynchronizeFile(out List<RecurringEvent> modifiedEvents)
    {
      RCD.IMTRcdFileList fileList = mRcd.RunQuery("config\\UsageServer\\recurring_events.xml", true);

      List<string> configFiles = new List<string>();
      foreach (string fileName in fileList)
      {
        configFiles.Add(fileName);
        //ReadEventsFromFile(fileName, true, events, dependencies, ref allCycleTypeUsed);
      }
      SynchronizeFile(configFiles, out modifiedEvents);

    }

    private void SynchronizeFile(List<string> configFiles, out List<RecurringEvent> modifiedEvents)
    {
      modifiedEvents = new List<RecurringEvent>();
      Hashtable dbEvents = LoadEventsFromDB();
      foreach (string fileName in configFiles)
      {
        UpdateConfigFile(fileName, dbEvents, modifiedEvents);
      }
    }

    private void UpdateConfigFile(string fileName, Hashtable dbEvents, List<RecurringEvent> modifiedEvents)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(fileName);
      Boolean docChanged = false;

      mLogger.LogDebug("Looking for updates to config file {0}", fileName);
      Hashtable fileEvents = LoadEventsFromFileNoDependencies(fileName);
      foreach(RecurringEvent fileEvent in fileEvents.Values) {
        RecurringEventSchedule fileSchedule = (RecurringEventSchedule)fileEvent.Schedules[0];
        if (fileSchedule.Type == RecurringEventScheduleType.RecurrencePattern)
        {
          BaseRecurrencePattern filePattern = fileSchedule.Pattern;
          if (dbEvents.ContainsKey(fileEvent.Name))
          {
            RecurringEvent dbEvent = (RecurringEvent)dbEvents[fileEvent.Name];
            RecurringEventSchedule dbSchedule = (RecurringEventSchedule)dbEvent.Schedules[0];
            if (fileSchedule.Type == RecurringEventScheduleType.RecurrencePattern)
            {
              BaseRecurrencePattern dbPattern = dbSchedule.Pattern;
              if (!dbPattern.PatternEquals(filePattern)) // this should ignore overrides
              {
                // need to update the pattern in the config file.
                UpdateEventPatternInXmlDoc(doc, fileEvent.Name, dbPattern);
                modifiedEvents.Add(fileEvent);
                docChanged = true;
              }
            }
            else
            {
              mLogger.LogWarning("Event missmatch. Scheduled event in the config file is eop event in the db. Event name {0}", fileEvent.Name);
            }
          }
        }
      }
      if (docChanged)
      {
        mLogger.LogInfo("Updating config file {0} with new recurrence pattern for scheduled events from the database", fileName);
        doc.Save(fileName);
      }
    }

    private void UpdateEventPatternInXmlDoc(MTXmlDocument doc, string eventName, BaseRecurrencePattern newPattern) {
      mLogger.LogDebug("modifying event {0} to new pattern {1}", eventName, newPattern.ToString());
      XmlNode scheduledNode = doc.SelectSingleNode("/xmlconfig/ScheduledAdapters/Adapter[Name='" + eventName + "']");
      if (scheduledNode == null)
        throw new UsageServerException(string.Format("Unable to update xml, adapter {0} not found", eventName));
      XmlNode patternNode = scheduledNode.SelectSingleNode("RecurrencePattern");
      patternNode.InnerXml = RecurrencePatternToXml(newPattern);
    }

    private string RecurrencePatternToXml(BaseRecurrencePattern newPattern)
    {
      string xmlstr = string.Format(@"
        <!-- Recurrence Pattern was updated from the database at {0} UTC -->", MetraTime.Now.ToString())
        + RecurrencePatternFactory.RecurrencePatternToXml(newPattern);
      return xmlstr;
    }


    /// <summary>
    /// For use from UpdateFile
    /// </summary>
    /// <param name="configFile"></param>
    /// <returns></returns>
    private Hashtable LoadEventsFromFileNoDependencies(string configFile)
    {
      // first map event name -> event object
      Hashtable events = CollectionsUtil.CreateCaseInsensitiveHashtable();

      // event name -> ArrayList(event name)
      Hashtable dependencies = CollectionsUtil.CreateCaseInsensitiveHashtable();


      // find all recurring_events.xml files across all extensions
      bool allCycleTypeUsed = false;
      // only loads the specific recurring_events.xml (useful for testing)
      ReadEventsFromFile(configFile, false, events, dependencies, ref allCycleTypeUsed);

      return events;
    }

		/// <summary>
		/// Reads events in from all recurring_events.xml config files througout the extension folders
		/// INTERNAL USE ONLY (supports unit tests)
		/// </summary>
		public Hashtable LoadEventsFromFile()
		{ return LoadEventsFromFile(null); }

		/// <summary>
		/// Reads events in from the specified configuration file.
		/// INTERNAL USE ONLY (supports unit tests)
		/// </summary>
		public Hashtable LoadEventsFromFile(string configFile)
    {
			// first map event name -> event object
			Hashtable events = CollectionsUtil.CreateCaseInsensitiveHashtable();

			// event name -> ArrayList(event name)
			Hashtable dependencies = CollectionsUtil.CreateCaseInsensitiveHashtable();


			// find all recurring_events.xml files across all extensions
			bool allCycleTypeUsed = false;
			if (configFile == null)
			{
				RCD.IMTRcdFileList fileList = mRcd.RunQuery("config\\UsageServer\\recurring_events.xml", true);

				foreach (string fileName in fileList)
					ReadEventsFromFile(fileName, true, events, dependencies, ref allCycleTypeUsed);
			}
			else
				// only loads the specific recurring_events.xml (useful for testing)
				ReadEventsFromFile(configFile, false, events, dependencies, ref allCycleTypeUsed);

			// adds in the end root event - used for safely hard closing the interval
			AddEndRootEvent(events, dependencies);
			
			//
			// verify and resolve the dependencies
			//
      foreach (DictionaryEntry depEntry in dependencies)
			{
				string eventName = (string) depEntry.Key;
				RecurringEvent recurringEvent = (RecurringEvent) events[eventName];
				if (recurringEvent == null)
					throw new RecurringEventNotFoundException(eventName, "Perhaps a <DependsOnMe> tag is wrong?");

				ArrayList dependsOn = (ArrayList) depEntry.Value;
				foreach (string depName in dependsOn)
				{
					switch (depName.ToLower())
					{

					// adds all events except for itself (and end root) as dependencies
					case "all":
						foreach (RecurringEvent depEvent in events.Values)
							if ((depEvent.Name != recurringEvent.Name) && (depEvent.Type != RecurringEventType.Root))
								recurringEvent.AddDependency(depEvent);

						recurringEvent.DependsOnAll = true;
						break;

					// adds all end-of-period events except for itself (and end root) as dependencies
					case "alleop":
						foreach (RecurringEvent depEvent in events.Values)
							if ((depEvent.Name != recurringEvent.Name) && 
									((depEvent.Type == RecurringEventType.EndOfPeriod) ||
									 (depEvent.Type == RecurringEventType.Checkpoint)))
								recurringEvent.AddDependency(depEvent);

						recurringEvent.DependsOnAll = true;
						break;

					// the normal case - just adds the specified dependency
					default:
					{
						RecurringEvent depEvent = (RecurringEvent) events[depName];
						if (depEvent == null)
							throw new RecurringEventNotFoundException(depName, "Perhaps a <DependsOn> tag is wrong?");

						recurringEvent.AddDependency(depEvent);
						break;
					}
					}
				}
			}

			//
			// look for circular dependencies
			//
			Hashtable verified = CollectionsUtil.CreateCaseInsensitiveHashtable();
			foreach (RecurringEvent recurringEvent in events.Values)
			{
				Hashtable visited = CollectionsUtil.CreateCaseInsensitiveHashtable();
				VisitDependencies(recurringEvent, visited, verified);
			}

			//
			// prunes unnecessary dependencies
			//
			foreach (RecurringEvent recurringEvent in events.Values)
				recurringEvent.PruneDependencies();


			// adds in the start root event
			// NOTE: this must occur after dependency resolution and verification
			AddStartRootEvent(events);

			//
			// validates adapter creation and retrieves runtime metadata
			//
			IMTSessionContext sessionContext = AdapterManager.GetSuperUserContext();
			foreach (RecurringEvent recurringEvent in events.Values)
				GetAdapterRuntimeMetadata(recurringEvent, sessionContext);
			
			return events;
		}

		/// <summary>
		/// Returns a hashtable of Recurring Event objects persisted in the database.
		/// The hashtable is keyed on event name.
		/// INTERNAL USE ONLY (supports unit tests)
		/// </summary>
		public Hashtable LoadEventsFromDB(IMTConnection conn)
		{
			Hashtable eventsByName = CollectionsUtil.CreateCaseInsensitiveHashtable();
			Hashtable eventsByID = new Hashtable();

			//
			// reads in a list of active events
			//
            using (IMTStatement stmt =
                conn.CreateStatement(
                    "select id_event, tx_name, tx_type, tx_reverse_mode, b_multiinstance, "
          + "tx_billgroup_support, b_has_billgroup_constraints, "
                    + "tx_class_name, tx_extension_name, tx_config_file, dt_activated, tx_display_name, tx_desc "
                    + "from t_recevent where dt_deactivated is null")) // TODO: fix current event logic
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        RecurringEvent recurringEvent = RecurringEvent.CreateEventFromRow(reader);
                        eventsByName.Add(recurringEvent.Name, recurringEvent);
                        eventsByID.Add(recurringEvent.EventID, recurringEvent);
                    }
                }
            }

			// fills in event schedule information
			Hashtable dbSchedules = ReadDBSchedules(conn);
			foreach (RecurringEvent recurringEvent in eventsByName.Values)
				recurringEvent.SetSchedules(((ArrayList) dbSchedules[recurringEvent.EventID]));
			
			// fills in event dependency information
			Hashtable dbDependencies = ReadDBDependencies(conn);
			foreach (RecurringEvent recurringEvent in eventsByName.Values)
			{
				ArrayList depList = (ArrayList) dbDependencies[recurringEvent.EventID];
				if (depList != null)
					foreach (int depEventID in depList)
						recurringEvent.AddDependency((RecurringEvent) eventsByID[depEventID]);
			}

      // fills in machine rule information
      MachineRules machineRules = MachineRuleManager.ReadMachineRulesFromDatabase(conn);
      foreach (RecurringEvent recurringEvent in eventsByName.Values)
      {
        recurringEvent.SetMachineRules(machineRules.GetMachineRulesAsArrayListForEvent(recurringEvent.Name));
      }

			return eventsByName;
		}

		public Hashtable LoadEventsFromDB()
		{
			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
			{
				return LoadEventsFromDB(conn);
			}
		}


		/// <summary>
		/// Synchronize events read from the config files with
		/// the events already in the database.
		/// </summary>
		/// <returns>the number of events affected</returns>
		public void SynchronizeDatabase(Hashtable fileEvents, 
																		out ArrayList added,
																		out ArrayList removed,
																		out ArrayList modified)
		{
			mLogger.LogInfo("Synchronizing recurring event metadata...");

			using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection(@"Queries\UsageServer"))
			{
				Hashtable dbEvents = LoadEventsFromDB(conn);


				//
				// detects events that were added/modified in config files
				//
				Hashtable newEvents = CollectionsUtil.CreateCaseInsensitiveHashtable();
				Hashtable modifiedEvents = CollectionsUtil.CreateCaseInsensitiveHashtable();
				ArrayList unmodifiedEvents = new ArrayList();
				Hashtable indirectlyModifiedEvents = CollectionsUtil.CreateCaseInsensitiveHashtable();

				foreach (RecurringEvent fileEvent in fileEvents.Values)
				{
					RecurringEvent dbEvent = (RecurringEvent) dbEvents[fileEvent.Name];
					if (dbEvent == null)
					{
						// event from file was not found in database - adds it to the new list
						newEvents[fileEvent.Name] = fileEvent;
						continue;
					}

					// associates the file event with the db event's ID
					fileEvent.EventID = dbEvent.EventID;

					bool changed = !fileEvent.Equals(dbEvent);
					
					// checks if the activation date has changed only if it was
					// explicitly given in the recurring_events.xml file (CR10266)
					// NOTE: This check does not detect when an explicit activation date
					// was used and then removed from a config file. This is not supported.
					if ((fileEvent.ActivationDate != DateTime.MinValue) &&
							(fileEvent.ActivationDate != dbEvent.ActivationDate))
						changed = true;
					
					if (changed)
					{
						// keeps modifications to roots in a seperate list so that 
						// the user can see exactly what they modified
						if ((fileEvent.Name == "_StartRoot") || (fileEvent.Name == "_EndRoot"))
							indirectlyModifiedEvents.Add(fileEvent.Name, fileEvent);
						else
							modifiedEvents.Add(fileEvent.Name, fileEvent);

					}
					else
						unmodifiedEvents.Add(fileEvent);
				}
				
				
				//
				// propagates modifications through events that depend on modified events
				//
				
				// iterates over unmodified events, checking each one's implicit dependencies to see if they
				// were modified. if so, the unmodified event is also considered modified.
				
				// clones (shallow) the ArrayList so that we can modify it while iterating over it
				foreach (RecurringEvent unmodifiedEvent in (ArrayList) unmodifiedEvents.Clone())
				{
					Hashtable deps = unmodifiedEvent.FullDependencies;
					foreach (RecurringEventDependency dep in deps.Values)
						if (modifiedEvents.Contains(dep.Event.Name))
						{
							indirectlyModifiedEvents[unmodifiedEvent.Name] = unmodifiedEvent;
							unmodifiedEvents.Remove(unmodifiedEvent);
						}
				}

				//
				// detects events that were removed from the config files
				//
				ArrayList removedEvents = new ArrayList();
				foreach (RecurringEvent dbEvent in dbEvents.Values)
					if (!fileEvents.Contains(dbEvent.Name))
						// event from database is not found in config files - adds it to the remove list
						removedEvents.Add(dbEvent);
				

				//
				// deactivates and adds events to the database
				//
				ArrayList allRemovedEvents = new ArrayList();
				allRemovedEvents.AddRange(removedEvents);
				allRemovedEvents.AddRange(modifiedEvents.Values);
				allRemovedEvents.AddRange(indirectlyModifiedEvents.Values);
				DeactivateEvents(conn, allRemovedEvents);

				ArrayList allNewEvents = new ArrayList();
				allNewEvents.AddRange(newEvents.Values);
				allNewEvents.AddRange(modifiedEvents.Values);
				allNewEvents.AddRange(indirectlyModifiedEvents.Values);
				AddEvents(conn, allNewEvents);

        //Updates adapter concurrency rules; done independently of events since they are 'global' or 'cross event/extension'
        ConcurrencyRules rules = new ConcurrencyRules();
        string pathConcurrencyRules = mRcd.ConfigDir + @"\UsageServer\recurring_events_ConcurrencyRules.xml";
        if (File.Exists(pathConcurrencyRules))
          rules.ReadConcurrencyRulesFromFile(pathConcurrencyRules);
        else
          mLogger.LogInfo("Adapter Concurrency Rules file not found at {0}. Adapters will not be run concurrently.", pathConcurrencyRules);

        ConcurrencyRulesManager.SetConcurrencyRulesInDatabase(conn, rules, mLogger);

				// touches up "live" soft closed instances to point to the new events
				ArrayList allModifiedEvents = new ArrayList(modifiedEvents.Values);
				allModifiedEvents.AddRange(indirectlyModifiedEvents.Values);
				SynchronizeSoftClosedInstances(conn, allModifiedEvents);

				conn.CommitTransaction();


				//
				// sends back feedback on what was done
				//

				// filters out internal events
				if (newEvents.Contains("_StartRoot"))
					newEvents.Remove("_StartRoot");
				if (newEvents.Contains("_EndRoot"))
					newEvents.Remove("_EndRoot");

				added = new ArrayList(newEvents.Values);
				modified = new ArrayList(modifiedEvents.Values);
				removed = removedEvents;

				mLogger.LogInfo(String.Format("Synchronization of recurring event metadata complete: {0} added, {1} modified, {2} removed",
																			added.Count, modified.Count, removed.Count));
			}
		}

		/// <summary>
		/// Touches up "live" soft closed instances to point to the new events.
		/// This prevents soft closed instances from disappearing after synchronizing
		/// but should be used with caution since new dependencies can be inadvertantly
		/// violated.
		/// </summary>
		private void SynchronizeSoftClosedInstances(IMTConnection conn, ArrayList modifiedEvents)
		{
			if (modifiedEvents.Count == 0)
				return;

            foreach (RecurringEvent recurringEvent in modifiedEvents)
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                                                                             "__SYNCHRONIZE_SOFT_CLOSED_INSTANCES__"))
                {
                    stmt.AddParam("%%NEW_EVENT_ID%%", recurringEvent.EventID);
                    stmt.AddParam("%%OLD_EVENT_ID%%", recurringEvent.PreviousEventID);
                    stmt.ExecuteNonQuery();
                }
            }

		}

		/// <summary>
		/// Creates an adapter test event and instance
		/// </summary>
		public int CreateAdapterTest(RecurringEvent recurringEvent, RecurringEventRunContext context)
		{
			// the event name must be unique for sync to work properly so a timestamp is added (CR13624)
			recurringEvent.Name = String.Format("Test-{0}-{1}", recurringEvent.ClassName, MetraTime.Now);
			recurringEvent.DisplayName = "Test of adapter " + recurringEvent.ClassName;

			// adds the _StartRoot event as the sole dependency
			recurringEvent.ClearDependencies();
			Hashtable dbEvents = LoadEventsFromDB();
			RecurringEvent startRoot = (RecurringEvent) dbEvents["_StartRoot"];
			recurringEvent.AddDependency(startRoot);

            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                // creates the adapter to get runtime metadata (i.e., reverse mode)
                GetAdapterRuntimeMetadata(recurringEvent);

                // adds the event
                ArrayList events = new ArrayList();
                events.Add(recurringEvent);
                AddEvents(conn, events);

                // adds the run
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateTestRecurEventInst"))
                {
                    stmt.AddParam("id_event", MTParameterType.Integer, recurringEvent.EventID);
                    if (recurringEvent.Type == RecurringEventType.EndOfPeriod)
                    {
                        stmt.AddParam("id_arg_interval", MTParameterType.Integer, context.UsageIntervalID);
                        stmt.AddParam("id_arg_billgroup", MTParameterType.Integer, context.BillingGroupID);
                        stmt.AddParam("dt_arg_start", MTParameterType.DateTime, null);
                        stmt.AddParam("dt_arg_end", MTParameterType.DateTime, null);
                    }
                    else
                    {
                        stmt.AddParam("id_arg_interval", MTParameterType.Integer, null);
                        stmt.AddParam("id_arg_billgroup", MTParameterType.Integer, null);
                        stmt.AddParam("dt_arg_start", MTParameterType.DateTime, context.StartDate);
                        stmt.AddParam("dt_arg_end", MTParameterType.DateTime, context.EndDate);
                    }
                    stmt.AddOutputParam("id_instance", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();

                    return (int)stmt.GetOutputValue("id_instance"); ;
                }
            }
		}

		/// <summary>
		/// Creates a scheduled event instance
		/// </summary>
		/// <returns>ID of the new instance</returns>
		public int InstantiateScheduledEvent(int eventID, DateTime endDate)
		{
			mLogger.LogDebug("Instantiating scheduled event {0}...", eventID);
			
			if (endDate == DateTime.MinValue)
				endDate = MetraTime.Now;

            int instanceID = -1;
            int status = -1;
			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("InstantiateScheduledEvent"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddParam("id_event", MTParameterType.Integer, eventID);
                    stmt.AddParam("dt_end", MTParameterType.DateTime, endDate);
                    stmt.AddOutputParam("id_instance", MTParameterType.Integer);
                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();
                    instanceID = (int)stmt.GetOutputValue("id_instance");
                    status = (int)stmt.GetOutputValue("status");
                }
	
				// the instance could not be upserted
				switch (status)
				{
				case 0: 
					mLogger.LogDebug("Event instance {0} for scheduled event {1} created/updated.", instanceID, eventID);
					return instanceID;

				case -1:
					throw new InstantiateScheduledEventException(eventID, "Event not found!");

				case -2:
					throw new InstantiateScheduledEventException(eventID, "Type of event is not scheduled!");

				case -3:
					throw new InstantiateScheduledEventException(eventID, "Last instance's end date has not yet occurred!");

				default:
					throw new InstantiateScheduledEventException(eventID, "Unknown failure!");
				}
			}
		}

		/// <summary>
		/// Creates instances for all scheduled events
		/// </summary>
		public int InstantiateScheduledEvents(DateTime endDate)
		{
			int count = 0;

            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                // gets a list of active scheduled event names
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                                "__GET_SCHEDULED_EVENTS__"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int eventID = reader.GetInt32("EventID");

                            // creates/updates the run
                            int instanceID = InstantiateScheduledEvent(eventID, endDate);
                            if (instanceID != -1)
                                count++;
                        }
                    }
                }
            }
			
			return count;
		}

  	/// <summary>
		/// Processes submitted events
		/// </summary>
	  public void ProcessEvents(out int executions, out int executionFailures,
															out int reversals,  out int reversalFailures)
		{
			ProcessEvents(null,
										out executions, out executionFailures,
										out reversals, out reversalFailures);
		}

    /// <summary>
		/// Processes submitted events with a callback which determines when to stop
		/// </summary>
	  public void ProcessEvents(HaltProcessingCallback haltProcessing,
															out int executions, out int executionFailures,
															out int reversals,  out int reversalFailures)
		{
			executions = 0; executionFailures = 0;
			reversals = 0; reversalFailures = 0;

			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
			{
				bool reevaluate;

				do 
				{
					reevaluate = false;

					//
					// executes events
					//
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("DetermineExecutableEvents"))
                    {
                        stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                        // looks at all ReadyToRun instances
                        stmt.AddParam("id_instances", MTParameterType.Integer, null);
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            int successes, failures;
                            if (InvokeEvents(RecurringEventAction.Execute, reader, haltProcessing,
                                                             out successes, out failures))
                                reevaluate = true;

                            executions += successes;
                            executionFailures += failures;
                        }
                    }

					if ((haltProcessing != null) && (haltProcessing.IsShuttingDown))
						break;

					//
					// reverses events
					//
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement("DetermineReversibleEvents"))
                    {
                        stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                        // looks at all ReadyToReverse instances
                        stmt.AddParam("id_instances", MTParameterType.Integer, null);
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            int successes, failures;
                            if (InvokeEvents(RecurringEventAction.Reverse, reader, haltProcessing,
                                                             out successes, out failures))
                                reevaluate = true;

                            reversals += successes;
                            reversalFailures += failures;
                        }
                    }

					if ((haltProcessing != null) && (haltProcessing.IsShuttingDown))
						break;

				} while (reevaluate);
			}
			
			if (executions > 0)
				mLogger.LogInfo("{0} recurring events executed successfully.", executions);
			if (executionFailures > 0)
				mLogger.LogError("{0} recurring events failed while executing!", executionFailures);
			if (reversals > 0)
				mLogger.LogInfo("{0} recurring events reversed successfully.", reversals);
			if (reversalFailures > 0)
				mLogger.LogError("{0} recurring events failed while reversing!", reversalFailures);

			if (executions + executionFailures + reversals + reversalFailures == 0)
				mLogger.LogDebug("No recurring events were able to be processed at this point in time.");
		}

    private RunnableEvent ReadEventFromDataReader(RecurringEventAction action,
                                 IMTDataReader reader)
    {
      RunnableEvent newEvent = new RunnableEvent();

      newEvent.InstanceID = reader.GetInt32("InstanceID");
      newEvent.EventName = reader.GetString("EventName");

      if (reader.IsDBNull("ClassName"))
        newEvent.ClassName = null;
      else
        newEvent.ClassName = reader.GetString("ClassName");

      if (reader.IsDBNull("ConfigFile"))
        newEvent.ConfigFile = null;
      else
        newEvent.ConfigFile = reader.GetString("ConfigFile");

      if (reader.IsDBNull("Extension"))
        newEvent.Extension = null;
      else
        newEvent.Extension = reader.GetString("Extension");

      if (reader.IsDBNull("EventMachineTag"))
      {
        //Machine tag should be set on event but if it is not, then assume any machine can run it
        newEvent.MachineTag = MachineRule.ALL_SPECIFIER;
      }
      else
        newEvent.MachineTag = reader.GetString("EventMachineTag");

      // gets the context parameters
      RecurringEventRunContext context = new RecurringEventRunContext();

      //Action is passed in; if we have a single stored procedure for returning both
      //executable and reversible events, we could read it from the rowset/dataset
      newEvent.Action = action;

      context.EventType = (RecurringEventType)Enum.Parse(typeof(RecurringEventType),
                                                          reader.GetString("EventType"));
      switch (context.EventType)
      {
        case RecurringEventType.EndOfPeriod:
        case RecurringEventType.Root:
          context.UsageIntervalID = reader.GetInt32("ArgInterval");
          if (!reader.IsDBNull("ArgBillingGroup"))
          {
            context.BillingGroupID = reader.GetInt32("ArgBillingGroup");
          }
          else
          {
            context.BillingGroupID = -1;
          }
          break;
        case RecurringEventType.Scheduled:
          context.StartDate = reader.GetDateTime("ArgStartDate");
          context.EndDate = reader.GetDateTime("ArgEndDate");
          break;
      }
      newEvent.Context = context;

      // handles reverse specific parameters
      newEvent.ReverseMode = ReverseMode.NotImplemented;
      if (action == RecurringEventAction.Reverse)
      {
        context.RunIDToReverse = reader.GetInt32("RunIDToReverse");
        newEvent.ReverseMode = (ReverseMode)Enum.Parse(typeof(ReverseMode),
                                               reader.GetString("ReverseMode"));
      }

      return newEvent;
    }

    public class RunnableEvent
    {
      public RecurringEventAction Action { get; set; }
      public int InstanceID { get; set; }
      public string EventName { get; set; }
      public string ClassName { get; set; }
      public string ConfigFile { get; set; }
      public string Extension { get; set; }
      public string MachineTag { get; set; }

      public RecurringEventRunContext Context { get; set; }

      public ReverseMode ReverseMode { get; set; }

      public override string ToString()
      {
        return string.Format("EventToExecute(Name=[{0}], Action=[{1}], InstanceId=[{2}], MachineTag=[{3}])", EventName, Action, InstanceID, MachineTag);
      }
    }

    private BlockingCollection<RunnableEvent> WorkQueue = new BlockingCollection<RunnableEvent>();
    private object mRefreshWorkQueueLock = new object();
    private bool mWorkQueueShouldBeRefreshed = false;
    private void RequestRefreshOfWorkQueue(WorkerIdleCoordination workerCoordination)
    {
      lock (mRefreshWorkQueueLock)
      {
        mWorkQueueShouldBeRefreshed = true;
      }

      if (workerCoordination != null)
      {
        workerCoordination.SignalThereMightBeWorkForOne();
      }
    }

    private void IndicateWorkQueueHasBeenRefreshed()
    {
      lock (mRefreshWorkQueueLock)
      {
        mWorkQueueShouldBeRefreshed = false;
      }
    }

    // Add Events To Queue
    private int AddEventsToQueue(RecurringEventAction action,
                                  IMTDataReader reader,
                                  HaltProcessingCallback haltCallback)
    {
      int itemCount = 0;
      while (reader.Read())
      {
        if ((haltCallback != null) && (haltCallback.IsShuttingDown))
        {
          mLogger.LogDebug("Halting recurring event processing (AddEventsToQueue) upon request");
          return itemCount;
        }

        RunnableEvent newEvent = ReadEventFromDataReader(action, reader);
        if (FilterEventForThisMachine(newEvent))
        {
          WorkQueue.Add(newEvent);
          itemCount++;
        }
        else
        {
          mLogger.LogDebug("Skipping event since it is not processable by this machine [{0}]: Event:[{1}]", MachineIdentifier, newEvent);
        }
      }

      if (itemCount>0)
        mLogger.LogDebug("Added {0} {1} events to the usage server work queue", itemCount, action.ToString());

      return itemCount;
    }
    
    private bool CheckAndPopulateWorkQueueIfNeeded()
    {
      //Check if the work queue should be refreshed
      WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] is determining if work queue needs to be refreshed", Task.CurrentId);
      bool refreshWorkQueue = false;
      lock (mRefreshWorkQueueLock)
      {
        refreshWorkQueue = mWorkQueueShouldBeRefreshed;
      }
      if (refreshWorkQueue)
      {
        WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] is refreshing work queue", Task.CurrentId);
        int countItemsAddedToWorkQueue = PopulateQueueWithProcessableEvents();
        if (countItemsAddedToWorkQueue > 0)
          return true; //Items were added to the work queue
      }
      else
      {
        WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] is not refreshing work queue", Task.CurrentId);
      }

      return false; //No items were added to the work queue
    }

    private int PopulateQueueWithProcessableEvents()
    {
      IndicateWorkQueueHasBeenRefreshed(); //By indicating the queue is refreshed before refreshing, we will not miss any requests
                                           //although we may refresh without acquiring additional new events

      int eventsAddedToQueue = 0;
      Stopwatch timer = new Stopwatch();
 
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("DetermineExecutableEvents"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("id_instances", MTParameterType.Integer, null); // looks at all ReadyToRun instances
          timer.Start();
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            timer.Stop();
            mLogger.LogDebug("PopulateQueueWithProcessableEvents:DetermineExecutableEvents stored procedure took {0} to execute", timer.ToPrettyString());
            eventsAddedToQueue += AddEventsToQueue(RecurringEventAction.Execute, reader, null);
          }
        }

        using (IMTCallableStatement stmt = conn.CreateCallableStatement("DetermineReversibleEvents"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          // looks at all ReadyToReverse instances
          stmt.AddParam("id_instances", MTParameterType.Integer, null);
          timer.Restart();
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            timer.Stop();
            mLogger.LogDebug("PopulateQueueWithProcessableEvents:DetermineReversibleEvents stored procedure took {0} to execute", timer.ToPrettyString());
            eventsAddedToQueue += AddEventsToQueue(RecurringEventAction.Reverse, reader, null);
          }
        }
      }

      return eventsAddedToQueue;
    }

    //public void ProcessEventsConcurrently(HaltProcessingCallback haltProcessing,
    //                       int maximumNumberOfEventsToProcessConcurrently,
    //                       out int executions, out int executionFailures,
    //                       out int reversals, out int reversalFailures)
    //{
    public void ProcessEventsConcurrently(HaltProcessingCallback haltProcessing,
                       ProcessingConfig processingConfiguration,
                       out int executions, out int executionFailures,
                       out int reversals, out int reversalFailures)
    {
  
      executions = 0; executionFailures = 0;
      reversals = 0; reversalFailures = 0;

      //Refresh our processing configuration
      RefreshInternalProcessingConfiguration(processingConfiguration);

      WorkResults processingResultsTotal = new WorkResults();

      if (PopulateQueueWithProcessableEvents() > 0)
      {
        WorkResults processingResults = new WorkResults();
        InvokeMultipleEventsFromQueue(haltProcessing, mProcessingConfiguration.MaximumNumberOfEventsToProcessConcurrently, out processingResults);

        processingResultsTotal += processingResults;
      }

      //Update the return values and log
      executions = processingResultsTotal.Executions;
      executionFailures = processingResultsTotal.ExecutionFailures;
      reversals = processingResultsTotal.Reversals;
      reversalFailures = processingResultsTotal.ReversalFailures;

      if ((processingResultsTotal.Executions + processingResultsTotal.Reversals) > 0)
        WriteConsoleAndLogFile(LogLevel.Info, "Processing Recurring Events ended with: {0}", processingResultsTotal);
      else
        WriteConsoleAndLogFile(LogLevel.Info, "Processing Recurring Events ended: No recurring events were able to be processed at this point in time.");

    }

 
    private bool InvokeMultipleEventsFromQueue(
                                  HaltProcessingCallback haltCallback,
                                  int maximumNumberOfEventsToProcessConcurrently,
                                  out WorkResults processingResults)
    {
      int tasksNeeded = maximumNumberOfEventsToProcessConcurrently;

      WorkerIdleCoordination workerCoordination = new WorkerIdleCoordination(tasksNeeded);

      //Create tasks to read from the queue and execute adapters
      Task<WorkResults>[] tasksServicingWorkQueue = new Task<WorkResults>[tasksNeeded];
      for (int i = 0; i < tasksNeeded; i++)
      {
        tasksServicingWorkQueue[i] = Task.Factory.StartNew(() => ProcessWorkQueue(haltCallback, workerCoordination))
                                                 .ContinueWith(t =>
          {
            //try catch from a fatal error in ProcessWorkQueue or do not throw from ProcessWorkQueue
            //Exceptions will potentially show up here if thrown from ProcessWorkQueue
            try
            {
              if ((t.Result != null) && ((t.Result.Executions + t.Result.Reversals) > 0))
                WriteConsoleAndLogFile(LogLevel.Info, "Adapter Execution Task [{0}] has ended with {1} (ContinueWith)", Task.CurrentId, t.Result);
              else
                WriteConsoleAndLogFile(LogLevel.Debug, "Adapter Execution Task [{0}] has ended with {1} (ContinueWith)", Task.CurrentId, t.Result);
            }
            catch (Exception ex)
            {
              WriteConsoleAndLogFile(LogLevel.Error, "Adapter Execution Task [{0}]: Unhandled exception returned to ContinueWith: [{1}]", Task.CurrentId, ex.Message);
            }
            finally
            {
              //Shouldn't be necessary but logging a warning if a task has ended without a shutdown being triggered
              if (!workerCoordination.ShuttingDown)
              {
                WriteConsoleAndLogFile(LogLevel.Warning, "Task [{0}] has completed, however other tasks were not indicated to shutdown.. Triggering shutdown of other tasks.", Task.CurrentId);
              }

              //As a safety, make sure if one task has ended, all other tasks get the message/signal
              workerCoordination.SignalTasksToShutdown();
            }

            return t.Result;
          }
            );
      }

      //Wait for all tasks to complete
      Task.WaitAll(tasksServicingWorkQueue);

      //Update the result counts returned from the tasks; previous implementation returns the counts
      WorkResults result = new WorkResults();
      for (int i = 0; i < tasksNeeded; i++)
      {
        result += tasksServicingWorkQueue[i].Result;
      }

      processingResults = result;

      //WriteConsoleAndLogFile(LogLevel.Debug, "Processing Recurring Events ended with: {0}", processingResults);

      return (processingResults.Successes > 0);
    }

    private WorkResults ProcessWorkQueue(HaltProcessingCallback haltCallback, WorkerIdleCoordination workerCoordination)
    {
      try
      {
        WriteConsoleAndLogFile(LogLevel.Debug, "Adapter Execution Task [{0}] Started", Task.CurrentId);
        WorkResults workResults = new WorkResults();

        bool shuttingDown = false;
        while (!shuttingDown)
        {
          RunnableEvent executeEvent;
          while (WorkQueue.TryTake(out executeEvent) == true)
          {
            //Check for outside request to shutdown
            if ((haltCallback != null) && (haltCallback.IsShuttingDown))
            {
              WriteConsoleAndLogFile(LogLevel.Debug, "Halting recurring event processing (ProcessWorkQueue) upon request (HaltProcessingCallback.IsShuttingDown is true)");
              workerCoordination.SignalTasksToShutdown(); //Wake the others so they get the message sooner
              return workResults;
            }

            WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] starting InvokeEvent for [{1}]", Task.CurrentId, executeEvent);
            WorkResults result = InvokeEvent(executeEvent, haltCallback);
            WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] completed InvokeEvent for [{1}]", Task.CurrentId, executeEvent);
            if (result.Successes > 0)
            {
              RequestRefreshOfWorkQueue(workerCoordination);
            }

            //Because other tasks may have went idle because an incompatible event was running,
            //signal that there might be more work to do, just because another adapter is no
            //longer running.
            workerCoordination.SignalThereMightBeWork();

            workResults += result;
          }

          //Done processing existing items in work queue
          //Wait until work queue needs to be refreshed or until everyone is finished

          //Check if the work queue should be refreshed
          if (CheckAndPopulateWorkQueueIfNeeded())
          {
            //Continue since we may have more work
            continue;
          }

          WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] is idle (no events in work queue)", Task.CurrentId);

          //Indicate we are idle
          workerCoordination.SignalTaskIsIdle();

          //Is everyone idle?
          //Made more efficient by waiting until everyone is finished and there is no chance of more work
          //When we wake up, determine if there is more work or if everything is complete for now
          bool shutdownBecauseWeAreDone = workerCoordination.WaitForWork();
          workerCoordination.SignalTaskIsNotIdle();

          if (shutdownBecauseWeAreDone)
          {
            //Shutting down
            WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] WaitForWork indicated that everyone is idle. Shutting down.", Task.CurrentId);
            shuttingDown = true;
            break;
          }
          if ((haltCallback != null) && (haltCallback.IsShuttingDown))
          {
            //Shutdown requested from outside
            //Make sure to wake the others if they didn't get the message yet
            workerCoordination.SignalTasksToShutdown();

            WriteConsoleAndLogFile(LogLevel.Debug, "Task [{0}] has been requested to shutdown", Task.CurrentId);
            shuttingDown = true;
            break;
          }

          //Otherwise, either there is more work in the queue or we need to refresh
          //so just continue
        }


        WriteConsoleAndLogFile(LogLevel.Debug, "Adapter Execution Task [{0}] shutting down after: {1}", Task.CurrentId, workResults);
        return workResults;
      }
      catch (Exception ex)
      {
        string msg = string.Format("Unhandled exception in ProcessWorkQueue for Task [{0}]: {1}", Task.CurrentId, ex.Message);
        msg+= "Stack Trace:" + ex.StackTrace;
        Exception exInner = ex.InnerException;
        while (exInner != null)
        {
          msg += "Inner Exception:" + exInner.Message;
          exInner = exInner.InnerException;
        }
        WriteConsoleAndLogFile(LogLevel.Fatal, msg);

        throw ex;
      }
    }

    /// <summary>
    /// For troubleshooting/debugging, it is useful to have information written to the console
    /// This helper method writes both to the console and to the log file
    /// </summary>
    /// <param name="logLevel"></param>
    /// <param name="messageFormat"></param>
    /// <param name="args"></param>
    private void WriteConsoleAndLogFile(LogLevel logLevel, string messageFormat, params object[] args)
    {
      if (args == null)
        args = new object[0];


      string message = String.Format(messageFormat, args);

      Console.WriteLine("[{0}] {1}", logLevel, message);

      switch (logLevel)
      {
        case LogLevel.Fatal:
          mLogger.LogFatal(message);
          break;
        case LogLevel.Error:
          mLogger.LogError(message);
          break;
        case LogLevel.Warning:
          mLogger.LogWarning(message);
          break;
        case LogLevel.Info:
          mLogger.LogInfo(message);
          break;
        case LogLevel.Debug:
          mLogger.LogDebug(message);
          break;
        default:
          mLogger.LogDebug(message);
          break;
      }
    }
    private void WriteConsoleAndLogFile(LogLevel logLevel, string message)
    {
      WriteConsoleAndLogFile(logLevel, message, null);
    }

    public WorkResults InvokeEvent(RunnableEvent executeEvent, HaltProcessingCallback haltCallback)
    {
      WorkResults result = new WorkResults();

      //Acquire the instance (i.e. make sure a) it is still valid to execute b) no other machine or task has taken it and c) get a run id
      // attempts to acquire the instance so that no other Usage Server can process it. also creates the run ID
      executeEvent.Context.RunID = AcquireInstance(executeEvent.InstanceID, executeEvent.Action, executeEvent.Context.RunIDToReverse);

      if (executeEvent.Context.RunID < 0)
      {
        switch (executeEvent.Context.RunID)
        {
          case -1:
            WriteConsoleAndLogFile(LogLevel.Debug,
                                   "Recurring event instance {0} of {1}[{2}] was acquired by a different server. Skipping.",
                                   executeEvent.InstanceID, executeEvent.EventName, executeEvent.Action);
            break;
          case -2:
            WriteConsoleAndLogFile(LogLevel.Debug,
                                   "Recurring event instance {0} of {1}[{2}] was not acquired because other incompatible adapters are currently running. Skipping.",
                                   executeEvent.InstanceID, executeEvent.EventName, executeEvent.Action);
            break;
          case -3:
            mLogger.LogInfo("Recurring event instance {0} of {1}[{2}] was not acquired because another adapter of the same class ({3}) is currently running and MultiInstance for the class is set to false. Skipping.",
                            executeEvent.InstanceID, executeEvent.EventName, executeEvent.Action, executeEvent.ClassName);
            break;
          default:
            WriteConsoleAndLogFile(LogLevel.Debug,
                        "Recurring event instance {0} of {1}[{2}] was acquired. Unknown return code {3}. Skipping.",
                        executeEvent.InstanceID, executeEvent.EventName, executeEvent.Action, executeEvent.Context.RunID);
            break;
        }

        //This is not a failure, just that the final check to acquire the instance for ourselves was unsuccessful; skip it for now by returning
        return result;
      }

      //RecurringEventAction action = executeEvent.Action;
      string detail = null;
      // TODO: clean this condition up!
      if (((executeEvent.Action == RecurringEventAction.Execute) ||
           ((executeEvent.Action == RecurringEventAction.Reverse) && ((executeEvent.ReverseMode == ReverseMode.Custom) || (executeEvent.ReverseMode == ReverseMode.Auto)))) &&
          ((executeEvent.Context.EventType == RecurringEventType.Scheduled) || (executeEvent.Context.EventType == RecurringEventType.EndOfPeriod)))
      {

        // additonal try for safe handling of ThreadAbortException
        // in the case of an unmanaged adapter failure
        try
        {
          try
          {
            // creates an instance of the adapter
            WriteConsoleAndLogFile(LogLevel.Debug,
                             "Invoking Event: Task [{2}] Creating instance of the '{0}' adapter with class name '{1}': Details[{3}]",
                             executeEvent.EventName, executeEvent.ClassName, Task.CurrentId, executeEvent);
            bool isLegacyAdapter;
            IRecurringEventAdapter2 adapter =
              AdapterManager.CreateAdapterInstance(executeEvent.ClassName, out isLegacyAdapter);

            // builds the absolute file name to the adapter's config file
            executeEvent.ConfigFile = AdapterManager.GetAbsoluteConfigFile(executeEvent.Extension, executeEvent.ConfigFile, isLegacyAdapter);

            // enables the service to abort the adapter
            if (haltCallback != null)
              haltCallback.IsAbortable = true;

            // additonal try for safe disabling of IsAbortable
            try
            {
              // initalizes the adapter
              mLogger.LogDebug("Task [{2}] Initializing the '{0}' adapter with configuration file '{1}'", executeEvent.EventName, executeEvent.ConfigFile, Task.CurrentId);
              adapter.Initialize(executeEvent.EventName, executeEvent.ConfigFile, AdapterManager.GetSuperUserContext(), false);

              if (executeEvent.Action == RecurringEventAction.Execute)
              {
                // executes the adapter
                mLogger.LogInfo("Executing the '{0}' adapter with the following parameters:\n\t{1}",
                                executeEvent.EventName, executeEvent.Context);
                detail = adapter.Execute(executeEvent.Context);
              }
              else
              {
                // reverses the adapter
                mLogger.LogInfo("Reversing the '{0}' adapter with the following parameters:\n\t{1}",
                                executeEvent.EventName, executeEvent.Context);
                detail = adapter.Reverse(executeEvent.Context);
              }
            }
            catch (AdapterExecutionException e)
            {
              result.RecordFailure(executeEvent.Action);
              ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Failed);
              MarkRunAsFailed(executeEvent.Context.RunID, e.InnerException.Message);
              return result;
            }
            catch (AdapterReversalException e)
            {
              result.RecordFailure(executeEvent.Action);
              ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Failed);
              MarkRunAsFailed(executeEvent.Context.RunID, e.InnerException.Message);
              return result;
            }
            catch (AdapterInitializationException e)
            {
              result.RecordFailure(executeEvent.Action);
              ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Failed);
              MarkRunAsFailed(executeEvent.Context.RunID, e.InnerException.Message);
              return result;
            }
            catch (Exception e)
            {
              result.RecordFailure(executeEvent.Action);
              mLogger.LogError("The '{0}' adapter failed!! {1}", executeEvent.EventName, e);

              ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Failed);
              MarkRunAsFailed(executeEvent.Context.RunID, e.Message);
              return result;
            }
            finally
            {
              // shuts down the adapter no matter what 
              mLogger.LogDebug("Task [{1}] Shutting down the '{0}' adapter", executeEvent.EventName, Task.CurrentId);
              adapter.Shutdown();

              // NOTE: it is very important that abortable be set to false immediately
              // after the adapter has completed. to protect the following catch
              // blocks from being aborted, this extra try/finally block has been added.
              if (haltCallback != null)
                haltCallback.IsAbortable = false;
            }
          }
          catch (ThreadAbortException)
          {
            result.RecordFailure(executeEvent.Action);
            string msg = String.Format("The '{0}' adapter has been killed upon request! InstanceID = {1}, RunID = {2}",
                                     executeEvent.EventName, executeEvent.InstanceID, executeEvent.Context.RunID);
            mLogger.LogInfo(msg);

            ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Failed);
            MarkRunAsFailed(executeEvent.Context.RunID, "Killed by request");

            // don't actually abort the thread
            // the flow of execution has been obtained from the offending recurring event
            // it is enough to mark the instance and run as failed, and continue
            Thread.ResetAbort();

            return result;
          }
          catch (Exception e)
          {
            result.RecordFailure(executeEvent.Action);
            mLogger.LogError("Task [{3}]: The '{0}' adapter failed! {1} during {2}", executeEvent.EventName, e, executeEvent.Action, Task.CurrentId);

            ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Failed);
            MarkRunAsFailed(executeEvent.Context.RunID, e.Message);
            return result;
          }
        }
        catch (ThreadAbortException)
        {
          // if abort is called during unmanaged adapter code execution, the abort is queued until
          // the next time managed code is entered. in a completely unmanaged adapter which has failed
          // for some other reason, that next time will be in the above catch statements. at the end of
          // one of those catches, the runtime will raise the ThreadAbortException. this catch block
          // handles that case.

          // since the adapter has already failed on its own accord, just supress the abort
          Thread.ResetAbort();
          return result;
        }
      }

      // marks the run as succeeded
      result.RecordSuccess(executeEvent.Action);
      MarkRunAsSucceeded(executeEvent.Context.RunID, detail);


      // change the instance's status
      if (executeEvent.Action == RecurringEventAction.Execute)
      {
        ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.Succeeded);

        // executing the end root event signifies that this interval should 
        // be hard closed, since all its dependencies have been satisfied
        // and the root event depends on everything.
        if (executeEvent.Context.EventType == RecurringEventType.Root)
        {
          //successes--; // this is an internal event, so it shouldn't be counted
          BillingGroupManager manager = new BillingGroupManager();
          manager.HardCloseBillingGroup(executeEvent.Context.BillingGroupID);
          // UsageIntervalManager manager = new UsageIntervalManager();
          // manager.HardCloseUsageInterval(executeEvent.Context.UsageIntervalID);
        }
      }
      else
        ChangeInstanceStatus(executeEvent.InstanceID, RecurringEventInstanceStatus.NotYetRun);

      return result;
    }
    
    // invokes the actual event adapter
    // returns whether to reevaluate if there are any executable/reversable instances
    private bool InvokeEvents(RecurringEventAction action,
                              IMTDataReader reader,
                              HaltProcessingCallback haltCallback,
                              out int successes,
                              out int failures)
    {
      successes = 0; failures = 0;

      // iterates over each runnable instance
      while (reader.Read())
      {
        if ((haltCallback != null) && (haltCallback.IsShuttingDown))
        {
          mLogger.LogDebug("Halting recurring event processing upon request");
          return false;
        }

        int instanceID = reader.GetInt32("InstanceID");
        string eventName = reader.GetString("EventName");

        string className;
        if (reader.IsDBNull("ClassName"))
          className = null;
        else
          className = reader.GetString("ClassName");

        string configFile;
        if (reader.IsDBNull("ConfigFile"))
          configFile = null;
        else
          configFile = reader.GetString("ConfigFile");

        string extension;
        if (reader.IsDBNull("Extension"))
          extension = null;
        else
          extension = reader.GetString("Extension");


        // gets the context parameters
        RecurringEventRunContext context = new RecurringEventRunContext();
        context.EventType = (RecurringEventType)Enum.Parse(typeof(RecurringEventType),
                                                            reader.GetString("EventType"));
        switch (context.EventType)
        {
          case RecurringEventType.EndOfPeriod:
          case RecurringEventType.Root:
            context.UsageIntervalID = reader.GetInt32("ArgInterval");
            if (!reader.IsDBNull("ArgBillingGroup"))
            {
              context.BillingGroupID = reader.GetInt32("ArgBillingGroup");
            }
            else
            {
              context.BillingGroupID = -1;
            }
            break;
          case RecurringEventType.Scheduled:
            context.StartDate = reader.GetDateTime("ArgStartDate");
            context.EndDate = reader.GetDateTime("ArgEndDate");
            break;
        }

        // handles reverse specific parameters
        ReverseMode reverseMode = ReverseMode.NotImplemented;
        if (action == RecurringEventAction.Reverse)
        {
          context.RunIDToReverse = reader.GetInt32("RunIDToReverse");
          reverseMode = (ReverseMode)Enum.Parse(typeof(ReverseMode),
                                                 reader.GetString("ReverseMode"));
          if (reverseMode == ReverseMode.NotImplemented)
            throw new UsageServerException("Cannot reverse an adapter that does not support reversing!");
        }

        // attempts to acquire the instance so that no other
        // Usage Server can process it. also creates the run ID
        context.RunID = AcquireInstance(instanceID, action, context.RunIDToReverse);
        if (context.RunID < 0)
        {
          switch (context.RunID)
          {
            case -1:
              mLogger.LogInfo("Recurring event instance {0} of {1}[{2}] was acquired by a different server. Skipping.",
                              instanceID, eventName, action);
              break;
            case -2:
              mLogger.LogInfo("Recurring event instance {0} of {1}[{2}] was not acquired because other incompatible adapters are currently running. Skipping.",
                              instanceID, eventName, action);
              break;
            case -3:
              mLogger.LogInfo("Recurring event instance {0} of {1}[{2}] was not acquired because another adapter of the same class is currently running and MultiInstance for the class is set to false. Skipping.",
                              instanceID, eventName, action);
              break;
            default:
              mLogger.LogInfo("Recurring event instance {0} of {1}[{2}] was acquired. Unknown return code {3}. Skipping.",
                              instanceID, eventName, action, context.RunID);
              break;

          }

          // ESR-2885 let the while loop continue instead of returning true
          // return true;
          continue;
        }

        string detail = null;
        // TODO: clean this condition up!
        if (((action == RecurringEventAction.Execute) ||
             ((action == RecurringEventAction.Reverse) && ((reverseMode == ReverseMode.Custom) || (reverseMode == ReverseMode.Auto)))) &&
            ((context.EventType == RecurringEventType.Scheduled) || (context.EventType == RecurringEventType.EndOfPeriod)))
        {

          // additonal try for safe handling of ThreadAbortException
          // in the case of an unmanaged adapter failure
          try
          {
            try
            {
              // creates an instance of the adapter
              mLogger.LogDebug("Creating instance of the '{0}' adapter with class name '{1}'",
                               eventName, className);
              bool isLegacyAdapter;
              IRecurringEventAdapter2 adapter =
                AdapterManager.CreateAdapterInstance(className, out isLegacyAdapter);

              // builds the absolute file name to the adapter's config file
              configFile = AdapterManager.GetAbsoluteConfigFile(extension, configFile, isLegacyAdapter);

              // enables the service to abort the adapter
              if (haltCallback != null)
                haltCallback.IsAbortable = true;

              // additonal try for safe disabling of IsAbortable
              try
              {
                // initalizes the adapter
                mLogger.LogDebug("Initializing the '{0}' adapter with configuration file '{1}'", eventName, configFile);
                adapter.Initialize(eventName, configFile, AdapterManager.GetSuperUserContext(), false);

                if (action == RecurringEventAction.Execute)
                {
                  // executes the adapter
                  mLogger.LogInfo("Executing the '{0}' adapter with the following parameters:\n\t{1}",
                                  eventName, context);
                  detail = adapter.Execute(context);
                }
                else
                {
                  // reverses the adapter
                  mLogger.LogInfo("Reversing the '{0}' adapter with the following parameters:\n\t{1}",
                                  eventName, context);
                  detail = adapter.Reverse(context);
                }
              }
              catch (AdapterExecutionException e)
              {
                failures++;
                ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Failed);
                MarkRunAsFailed(context.RunID, e.InnerException.Message);
                continue;
              }
              catch (AdapterReversalException e)
              {
                failures++;
                ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Failed);
                MarkRunAsFailed(context.RunID, e.InnerException.Message);
                continue;
              }
              catch (AdapterInitializationException e)
              {
                failures++;
                ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Failed);
                MarkRunAsFailed(context.RunID, e.InnerException.Message);
                continue;
              }
              catch (Exception e)
              {
                failures++;
                mLogger.LogError("The '{0}' adapter failed!! {1}", eventName, e);

                ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Failed);
                MarkRunAsFailed(context.RunID, e.Message);
                continue;
              }
              finally
              {
                // shuts down the adapter no matter what 
                mLogger.LogDebug("Shutting down the '{0}' adapter", eventName);
                adapter.Shutdown();

                // NOTE: it is very important that abortable be set to false immediately
                // after the adapter has completed. to protect the following catch
                // blocks from being aborted, this extra try/finally block has been added.
                if (haltCallback != null)
                  haltCallback.IsAbortable = false;
              }
            }
            catch (ThreadAbortException)
            {
              failures++;
              string msg = String.Format("The '{0}' adapter has been killed upon request! InstanceID = {1}, RunID = {2}",
                                       eventName, instanceID, context.RunID);
              mLogger.LogInfo(msg);

              ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Failed);
              MarkRunAsFailed(context.RunID, "Killed by request");

              // don't actually abort the thread
              // the flow of execution has been obtained from the offending recurring event
              // it is enough to mark the instance and run as failed, and continue
              Thread.ResetAbort();

              continue;
            }
            catch (Exception e)
            {
              failures++;
              mLogger.LogError("The '{0}' adapter failed! {1}", eventName, e);

              ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Failed);
              MarkRunAsFailed(context.RunID, e.Message);
              continue;
            }
          }
          catch (ThreadAbortException)
          {
            // if abort is called during unmanaged adapter code execution, the abort is queued until
            // the next time managed code is entered. in a completely unmanaged adapter which has failed
            // for some other reason, that next time will be in the above catch statements. at the end of
            // one of those catches, the runtime will raise the ThreadAbortException. this catch block
            // handles that case.

            // since the adapter has already failed on its own accord, just supress the abort
            Thread.ResetAbort();
            continue;
          }
        }

        // marks the run as succeeded
        successes++;
        MarkRunAsSucceeded(context.RunID, detail);

        // change the instance's status
        if (action == RecurringEventAction.Execute)
        {
          ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.Succeeded);

          // executing the end root event signifies that this interval should 
          // be hard closed, since all its dependencies have been satisfied
          // and the root event depends on everything.
          if (context.EventType == RecurringEventType.Root)
          {
            successes--; // this is an internal event, so it shouldn't be counted
            BillingGroupManager manager = new BillingGroupManager();
            manager.HardCloseBillingGroup(context.BillingGroupID);
            // UsageIntervalManager manager = new UsageIntervalManager();
            // manager.HardCloseUsageInterval(context.UsageIntervalID);
          }
        }
        else
          ChangeInstanceStatus(instanceID, RecurringEventInstanceStatus.NotYetRun);
      }

      // if any work was done, perform a reevaluation
      // because of the work that was done another instance may have freed up
      if (successes + failures > 0)
        return true;

      return false;
    }


    protected ProcessingConfig mProcessingConfiguration = new ProcessingConfig();
    protected Object mProcessingConfigurationLock = new Object();
    public ProcessingConfig ProcessingConfiguration
    {
      get
      {
        lock (mProcessingConfigurationLock)
        {
          return mProcessingConfiguration;
        }
      }
    }

    protected void RefreshInternalProcessingConfiguration(ProcessingConfig processingConfiguration)
    {
      lock (mProcessingConfigurationLock)
      {
        if (processingConfiguration == null)
          mProcessingConfiguration = ProcessingConfigManager.LoadFromFile();
        else
          mProcessingConfiguration = processingConfiguration;

        mMachineTagsProcessableByThisMachine = new HashSet<string>();

        //Can always process events assigned to our machine name
        mMachineTagsProcessableByThisMachine.Add(MachineIdentifier);

        //Can process any roles explicitly set in our config file (should eventually update somewhere in the database if this option is kept
        foreach (string machineRole in mProcessingConfiguration.MachineRolesToConsiderForProcessing)
          mMachineTagsProcessableByThisMachine.Add(machineRole);

        //Can process any roles set in the database
        foreach (string machineRole in GetMachineRolesForMachineFromDatabase(MachineIdentifier))
          mMachineTagsProcessableByThisMachine.Add(machineRole);

        //Determine if we should process adapters that are not specifically assigned to a machine or machine role
        if (!mProcessingConfiguration.OnlyRunAdaptersExplicitlyAssignedToThisMachine)
          mMachineTagsProcessableByThisMachine.Add(MachineRule.ALL_SPECIFIER);

        //Log the results
        string machineTags = "";
        foreach(string machineTag in mMachineTagsProcessableByThisMachine)
          machineTags += string.Format("[{0}], ", machineTag);

        if (!string.IsNullOrEmpty(machineTags))
          machineTags = machineTags.Remove(machineTags.Length - 2); //Remove last separator
       
        WriteConsoleAndLogFile(LogLevel.Debug, "This billing server can run adapters with the following machine tags in t_recevent_machine: " + machineTags);
      }
    }

    protected HashSet<string> mMachineTagsProcessableByThisMachine;
    public HashSet<string> MachineTagsProcessableByThisMachine
    {
      get
      {
        lock (mProcessingConfigurationLock)
        {
          return mMachineTagsProcessableByThisMachine;
        }
      }
    }

    /// <summary>
    /// For the given machine identifier, retrieves a list of the machine roles the machine
    /// participates in by querying the BME entries in the database.
    /// </summary>
    /// <param name="machineIdentifier"></param>
    /// <returns></returns>
    private IEnumerable<string> GetMachineRolesForMachineFromDatabase(string machineIdentifier)
    {

      List<string> machineRolesForMachine = new List<string>();

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
        {
          // gets a list of active scheduled event names
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                        "__GET_MACHINEROLES_FOR_MACHINE__"))
          {
            stmt.AddParam("%%TX_MACHINE%%", machineIdentifier, true);
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                string machineRoleName = reader.GetString("MachineRole");
                WriteConsoleAndLogFile(LogLevel.Debug, "This machine {0} is part of the machine role {1}", machineIdentifier, machineRoleName);
                machineRolesForMachine.Add(machineRoleName);
              }
            }
          }
        }
      }
      catch (Exception ex)
      {
        mLogger.LogException("GetMachineRolesForMachineFromDatabase error reading from database", ex);
        Console.WriteLine("GetMachineRolesForMachineFromDatabase error reading from database: " + ex.Message);
      }

      return machineRolesForMachine;
    }

    private bool FilterEventForThisMachine(RunnableEvent newEvent)
    {
      return MachineTagsProcessableByThisMachine.Contains(newEvent.MachineTag);
    }


		// acquires an recurring event instance and creates a new run, returns the run ID
		public int AcquireInstance(int instanceID, RecurringEventAction action, int runIDToReverse)
		{
			string currentStatus;
			string newStatus;

			mLogger.LogDebug("Attempting to acquire recurring event instance {0}", instanceID);
			switch (action)
			{
			case RecurringEventAction.Execute:
				currentStatus = "ReadyToRun";
				newStatus = "Running";
				break;
			case RecurringEventAction.Reverse:
				currentStatus = "ReadyToReverse";
				newStatus = "Reversing";
				break;
			default:
				throw new UsageServerException("Unknown action type");
			}

			if (mRunIDGenerator == null)
				mRunIDGenerator = new IdGenerator("receventrun", 100);
			int runID = mRunIDGenerator.NextId;

			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
			{
				
                // ESR-2885 use a stored procedure instead of sql block 
                // create stored proc 
                int status = -1;
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("AcquireRecurringEventInstance"))
                {

                    // params needed for acquiring the instance
                    stmt.AddParam("ID_INSTANCE", MTParameterType.Integer, instanceID);
                    stmt.AddParam("CURRENT_STATUS", MTParameterType.String, currentStatus);
                    stmt.AddParam("NEW_STATUS", MTParameterType.String, newStatus);

                    // params needed for creating the run
                    stmt.AddParam("ID_RUN", MTParameterType.Integer, runID);
                    stmt.AddParam("TX_TYPE", MTParameterType.String, action.ToString());

                    if (action == RecurringEventAction.Execute)
                    {
                        stmt.AddParam("REVERSED_RUN", MTParameterType.Integer, null);
                    }
                    else
                    {
                        stmt.AddParam("REVERSED_RUN", MTParameterType.Integer, runIDToReverse);
                    }

                    stmt.AddParam("TX_MACHINE", MTParameterType.String, System.Windows.Forms.SystemInformation.ComputerName);
                    // use the metratime instead of sysdate/getdate in the stored procedure
                    stmt.AddParam("DT_START", MTParameterType.DateTime, MetraTech.MetraTime.Now);

                    stmt.AddOutputParam("status", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();


                    status = (int)stmt.GetOutputValue("status");
                }

                if (status < 0)
				        {
                  switch (status)
                  {
                    case -1:
                      mLogger.LogDebug("Acquisition was unsuccessful. A different server has acquried recurring event instance {0}.", instanceID);
                      break;
                    case -2:
                      mLogger.LogDebug("Acquisition was unsuccessful. The instance {0} is no longer compatible with other currently running events.", instanceID);
                      break;
                    case -3:
                      mLogger.LogDebug("Acquisition was unsuccessful. Another instance {0} of the same adapter class is currently running and the class has MultiInstance set to False", instanceID);
                      break;
                    default:
                      mLogger.LogDebug("Acquisition failed. AcquireRecurringEventInstance returned an unknown error code of {0} for instance {1}", status, instanceID);
                      break;
                  }
					        return status;
				        }
			}

			mLogger.LogDebug("Successfully acquired recurring event instance {0}: run {1} created", instanceID, runID);
			return runID;
		}


	  public void SubmitEvent(RecurringEventAction action, 
														int instanceID, bool ignoreDeps, DateTime effDate,
														Auth.IMTSessionContext sessionContext, string comment)
		{
			string noun = "";
			string sprocName = "";
			switch (action)
			{
			case RecurringEventAction.Execute:
				noun = "execution";
				sprocName = "SubmitEventForExecution";
				break;

			case RecurringEventAction.Reverse:
				noun = "reversal";
				sprocName = "SubmitEventForReversal";
				break;
			}
			
			// logs an informative message
			string effDateStr = "";
			if (effDate != DateTime.MinValue)
				effDateStr = String.Format(" no earlier than {0}", effDate.ToString());
			string ignoreDepsStr = "";
			if (ignoreDeps)
				ignoreDepsStr = " (ignoring dependencies)";
			mLogger.LogDebug("Submitting event instance {0} for {1}{2}{3}...",
											 instanceID, noun, effDateStr, ignoreDepsStr);

			// submits the instance
			int status;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instance", MTParameterType.Integer, instanceID);
                    stmt.AddParam("b_ignore_deps", MTParameterType.Boolean, ignoreDeps);
                    if (effDate != DateTime.MinValue)
                        stmt.AddParam("dt_effective", MTParameterType.DateTime, effDate);
                    else
                        stmt.AddParam("dt_effective", MTParameterType.DateTime, null);
                    stmt.AddParam("id_acc", MTParameterType.Integer, sessionContext.AccountID);
                    stmt.AddParam("tx_detail", MTParameterType.WideString, comment);

                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    status = (int)stmt.GetOutputValue("status");
                }
            }
				
			switch (status)
			{
			case 0:
				mLogger.LogDebug("Event instance {0} was successfully submitted for {1}.", instanceID, noun);
				break;

			case -1:
				throw new RecurringEventInstanceNotFoundException(instanceID);

			case -2:
				if (action == RecurringEventAction.Execute)
					throw new SubmitEventForExecutionInvalidStateException(instanceID);
				else
					throw new SubmitEventForReversalInvalidStateException(instanceID);

			case -3:
				throw new RecurringEventNotReversibleException(instanceID);

			case -4:
				throw new UnsatisfiedCheckpointDependenciesException(instanceID);

			case -5:
				throw new InvalidBillingGroupStateException(BillingGroupStatus.SoftClosed.ToString());
				
			default:
				throw new UsageServerException(String.Format("Event instance {0} could not be submitted for {1} for an unknown reason!",
																										 instanceID, noun), true);
			}
		}

	  public void CancelSubmittedEvent(int instanceID, Auth.IMTSessionContext sessionContext, string comment)
		{
			mLogger.LogDebug("Cancelling event instance {0}...", instanceID);

			// cancels the instance
			int status;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CancelSubmittedEvent"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instance", MTParameterType.Integer, instanceID);
                    stmt.AddParam("id_acc", MTParameterType.Integer, sessionContext.AccountID);
                    stmt.AddParam("tx_detail", MTParameterType.WideString, comment);

                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    status = (int)stmt.GetOutputValue("status");
                }
            }
				
			switch (status)
			{
			// success	
			case 0:
				mLogger.LogDebug("Event instance {0} was successfully cancelled.", instanceID);
				return;

			case -1:
				string msg = String.Format("Event instance {0} could not be cancelled. Instance does not exist!", instanceID);
				throw new UsageServerException(msg);

			case -2:
				msg = String.Format("Event instance {0} is in a state which cannot be cancelled!", instanceID);
				throw new UsageServerException(msg);
				
			default:
				msg = String.Format("Event instance {0} could not be cancelled for an unknown reason!", instanceID);
				throw new UsageServerException(msg);
			}
		}

	  public void MarkEventAsSucceeded(int instanceID, Auth.IMTSessionContext sessionContext, string comment)
		{
			mLogger.LogDebug("Explicitly changing event instance {0} to 'Succeeded'...", instanceID);

			// marks the instance as successful
			int status;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("MarkEventAsSucceeded"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instance", MTParameterType.Integer, instanceID);
                    stmt.AddParam("id_acc", MTParameterType.Integer, sessionContext.AccountID);
                    stmt.AddParam("tx_detail", MTParameterType.WideString, comment);
                    stmt.AddParam("tx_machine", MTParameterType.String, System.Windows.Forms.SystemInformation.ComputerName);

                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    status = (int)stmt.GetOutputValue("status");
                }
            }
				
			switch (status)
			{
			// success	
			case 0:
				mLogger.LogDebug("Event instance {0} was successfully marked as succeeded.", instanceID);
				return;

			case -1:
				string msg = String.Format("Event instance {0} could not be marked as succeeded. Instance does not exist!", instanceID);
				throw new UsageServerException(msg);

			case -2:
				msg = String.Format("Event instance {0} must be in the failed state!", instanceID);
				throw new UsageServerException(msg);
				
			default:
				msg = String.Format("Event instance {0} could not be marked as succeeded for an unknown reason!", instanceID);
				throw new UsageServerException(msg);
			}
		}

	  public void MarkEventAsFailed(int instanceID, Auth.IMTSessionContext sessionContext, string comment)
		{
			mLogger.LogDebug("Explicitly changing event instance {0} to 'Failed'...", instanceID);

			// marks the instance as failed
			int status;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("MarkEventAsFailed"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instance", MTParameterType.Integer, instanceID);
                    stmt.AddParam("id_acc", MTParameterType.Integer, sessionContext.AccountID);
                    stmt.AddParam("tx_detail", MTParameterType.WideString, comment);
                    stmt.AddParam("tx_machine", MTParameterType.String, System.Windows.Forms.SystemInformation.ComputerName);

                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    status = (int)stmt.GetOutputValue("status");
                }
            }
				
			switch (status)
			{
			// success	
			case 0:
				mLogger.LogDebug("Event instance {0} was successfully marked as failed.", instanceID);
				return;

			case -1:
				string msg = String.Format("Event instance {0} could not be marked as failed. Instance does not exist!", instanceID);
				mLogger.LogWarning(msg);
				throw new UsageServerException(msg);

			case -2:
				msg = String.Format("Event instance {0} must be in the succeeded state!", instanceID);
				mLogger.LogWarning(msg);
				throw new UsageServerException(msg);
				
			default:
				msg = String.Format("Event instance {0} could not be marked as failed for an unknown reason!", instanceID);
				mLogger.LogWarning(msg);
				throw new UsageServerException(msg);
			}
		}

	  public void MarkEventAsNotYetRun(int instanceID, Auth.IMTSessionContext sessionContext, string comment)
		{
			mLogger.LogDebug("Explicitly changing event instance {0} to 'NotYetRun'...", instanceID);

			// marks the instance as NotYetRun
			int status;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("MarkEventAsNotYetRun"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instance", MTParameterType.Integer, instanceID);
                    stmt.AddParam("id_acc", MTParameterType.Integer, sessionContext.AccountID);
                    stmt.AddParam("tx_detail", MTParameterType.WideString, comment);
                    stmt.AddParam("tx_machine", MTParameterType.String, System.Windows.Forms.SystemInformation.ComputerName);

                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    status = (int)stmt.GetOutputValue("status");
                }
            }
				
			switch (status)
			{
			// success	
			case 0:
				mLogger.LogDebug("Event instance {0} was successfully marked as NotYetRun.", instanceID);
				return;

			case -1:
				string msg = String.Format("Event instance {0} could not be marked as NotYetRun. Instance does not exist!", instanceID);
				mLogger.LogWarning(msg);
				throw new UsageServerException(msg);

			case -2:
				msg = String.Format("Event instance {0} must be in the failed state!", instanceID);
				mLogger.LogWarning(msg);
				throw new UsageServerException(msg);
				
			default:
				msg = String.Format("Event instance {0} could not be marked as NotYetRun for an unknown reason!", instanceID);
				mLogger.LogWarning(msg);
				throw new UsageServerException(msg);
			}
		}
	
		public Rowset.IMTSQLRowset GetDependenciesByInstanceRowset(IRecurringEventInstanceFilter instances,
																															 RecurringEventDependencyType depType,
																															 RecurringEventDependencyStatus depStatus)
    {
      Rowset.IMTSQLRowset rs = new Rowset.MTSQLRowset();

      rs.Init(@"Queries\UsageServer");
      rs.InitializeForStoredProc("GetRecurringEventDepsByInst");
    
      rs.AddInputParameterToStoredProc("dep_type", (int)Rowset.RSParameterType.RS_VARCHAR, 
        (int)Rowset.RSParameterDirection.RS_INPUT_PARAM, depType.ToString()) ;
      rs.AddInputParameterToStoredProc("dt_now", (int)Rowset.RSParameterType.RS_DATE, 
        (int)Rowset.RSParameterDirection.RS_INPUT_PARAM, MetraTime.Now) ;
      rs.AddInputParameterToStoredProc("id_instances", (int)Rowset.RSParameterType.RS_VARCHAR, 
        (int)Rowset.RSParameterDirection.RS_INPUT_PARAM, instances.ToCSVString()) ;

      string statusFilter = "";
      if (depStatus != RecurringEventDependencyStatus.All)
      {
        string satisfiedStatus;

        switch (depType)
        {
          case RecurringEventDependencyType.Execution:
            satisfiedStatus = RecurringEventInstanceStatus.Succeeded.ToString();
            break;
          case RecurringEventDependencyType.Reversal:
            satisfiedStatus = RecurringEventInstanceStatus.NotYetRun.ToString();
            break;
          default:
            throw new UsageServerException(String.Format("Unknown dependency type {0}!", depType)); 
        }

        string op = "";
        switch (depStatus)
        {
          case RecurringEventDependencyStatus.Satisfied:
            op = "=";
            break;
          case RecurringEventDependencyStatus.Unsatisfied:
            op = "<>";
            break;
          default:
            throw new UsageServerException(String.Format("Unknown dependency status {0}!", depStatus)); 
        }
        statusFilter = String.Format(" AND deps.tx_status {0} '{1}'", op, satisfiedStatus);
      }

      rs.AddInputParameterToStoredProc("status_filter", (int)Rowset.RSParameterType.RS_VARCHAR, 
        (int)Rowset.RSParameterDirection.RS_INPUT_PARAM, statusFilter) ;

      // execute the stored procedure ...
      rs.ExecuteStoredProc() ;

      return rs;
    }

		/// <summary>
		/// Generates a representation of the dependency relationship between all recurring events
		/// in the system. Representation is encoded in the Graphviv DOT format.
		/// For mor information on Graphviv, see: http://www.research.att.com/sw/tools/graphviz/
		/// </summary>
		public string GenerateDOTOutput(bool includeRootEvents)
		{
			StringBuilder dotCode = new StringBuilder();

			// outputs the self-instructing header
			dotCode.Append("//------------------------------------------------------------------\r\n");
			dotCode.Append("// Generated by MetraTech Usage Server Maintenance: usm ldeps /dot\r\n");
			dotCode.AppendFormat("// Generated on {0}\r\n", MetraTime.Now);
			dotCode.Append("//-----------------------------------------------------------------\r\n\r\n");
			dotCode.Append("// To tranform this file to an image, download GraphViz:\r\n");
			dotCode.Append("//    http://www.research.att.com/sw/tools/graphviz\r\n\r\n");
			dotCode.Append("// For example, to generate a PNG image using DOT:\r\n");
			dotCode.Append("//    usm ldeps /dot | dot -Tpng -o recurring_events.png\r\n\r\n");

			// begins the digraph block
			dotCode.Append("digraph \"");
			dotCode.AppendFormat("Recurring Event Dependencies as of {0}", MetraTime.Now);
			dotCode.Append("\"\r\n{\r\n");

			dotCode.Append("\t//\r\n");
			dotCode.Append("\t// page layout attributes\r\n");
			dotCode.Append("\t//\r\n");
			dotCode.Append("\tratio = fill\r\n");
			dotCode.Append("\tpage = \"8.5, 11\"\r\n");
			dotCode.Append("\tsize = \"7, 10\"    // comment for landscape layout\r\n");
			dotCode.Append("\t// size = \"10, 7\" // uncomment for landscape layout\r\n");
			dotCode.Append("\t// rotate = 90    // uncomment for landscape layout\r\n\r\n");

			//
			// generates the node shape attributes based on event type
			//
			dotCode.Append("\t//\r\n");
			dotCode.Append("\t// node shape attributes\r\n");
			dotCode.Append("\t//\r\n");
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_RECURRING_EVENT_TYPES__"))
                {
                    if (includeRootEvents)
                        stmt.AddParam("%%EXCLUDE_ROOT_EVENTS%%", "");
                    else
                        stmt.AddParam("%%EXCLUDE_ROOT_EVENTS%%", "  tx_type <> 'Root' AND ", true);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string eventName = reader.GetString("Event");
                            RecurringEventType eventType =
                                (RecurringEventType)Enum.Parse(typeof(RecurringEventType), reader.GetString("EventType"));

                            string shape;
                            switch (eventType)
                            {
                                case RecurringEventType.EndOfPeriod:
                                    shape = "[shape = ellipse]";
                                    break;
                                case RecurringEventType.Scheduled:
                                    shape = "[shape = box]";
                                    break;
                                case RecurringEventType.Checkpoint:
                                    shape = "[shape = diamond]";
                                    break;
                                case RecurringEventType.Root:
                                    shape = "[shape = doublecircle]";
                                    break;
                                default:
                                    throw new UsageServerException(String.Format("Unknown recurring event type! {0}", eventType), true);
                            }

                            dotCode.AppendFormat("\t\"{0}\" {1}\r\n", eventName, shape);
                        }
                    }
                }
                dotCode.Append("\r\n");

                //
                // generates the actual nodes based on event dependency information
                //
                dotCode.Append("\t//\r\n");
                dotCode.Append("\t// recurring event relationships\r\n");
                dotCode.Append("\t//\r\n");
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_RECURRING_EVENT_DEPENDENCIES__"))
                {
                    if (includeRootEvents)
                    {
                        stmt.AddParam("%%EXCLUDE_ROOT_EVENTS%%", "");
                        stmt.AddParam("%%EXCLUDE_DEPS_ON_ROOT_EVENTS%%", "");
                    }
                    else
                    {
                        stmt.AddParam("%%EXCLUDE_ROOT_EVENTS%%", "  evt.tx_type <> 'Root' AND ", true);
                        stmt.AddParam("%%EXCLUDE_DEPS_ON_ROOT_EVENTS%%", "  depevt.tx_type <> 'Root' AND ", true);
                    }

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string eventName = reader.GetString("Event");
                            string depName = reader.GetString("DependsOn");

                            dotCode.AppendFormat("\t\"{0}\" -> \"{1}\"\r\n", eventName, depName);
                        }
                    }
                }
            }

			// closes the digraph block
			dotCode.Append("}");
			
			return dotCode.ToString();
		}


		public Rowset.IMTSQLRowset GetCanExecuteEventRowset(IRecurringEventInstanceFilter instances)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CanExecuteEvents"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instances", MTParameterType.String, instances.ToCSVString());
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        // argh! MTSQLRowset doesn't support returning a rowset from a sproc
                        // TODO: make a general IMTDataReader -> IMTSQLRowset converter
                        return CreateGUIRowset(reader);
                    }
                }
            }
		}

		public Rowset.IMTSQLRowset GetCanReverseEventRowset(IRecurringEventInstanceFilter instances)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CanReverseEvents"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instances", MTParameterType.String, instances.ToCSVString());
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        // argh! MTSQLRowset doesn't support returning a rowset from a sproc
                        // TODO: make a general IMTDataReader -> IMTSQLRowset converter
                        return CreateGUIRowset(reader);
                    }
                }
            }
		}

		private Rowset.IMTSQLRowset CreateGUIRowset(IMTDataReader reader)
		{
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      
      // initializes the rowset
      rowset.InitDisconnected();
      rowset.AddColumnDefinition("InstanceID","int32", 6);
      rowset.AddColumnDefinition("EventDisplayName","string", 255);
      rowset.AddColumnDefinition("Reason","string", 80);
      rowset.OpenDisconnected();

			while (reader.Read())
			{
				rowset.AddRow();
				rowset.AddColumnData("InstanceID", reader.GetInt32("InstanceID"));
				rowset.AddColumnData("EventDisplayName", reader.GetString("EventDisplayName"));
				rowset.AddColumnData("Reason", reader.GetString("Reason"));
			}
			return rowset;
		}

		public Rowset.IMTSQLRowset GetCanExecuteEventDepsRowset(IRecurringEventInstanceFilter instances)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CanExecuteEventDeps"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instances", MTParameterType.String, instances.ToCSVString());
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        return DBUtil.RowsetFromReader(reader);
                    }
                }
            }
		}

		public Rowset.IMTSQLRowset GetCanReverseEventDepsRowset(IRecurringEventInstanceFilter instances)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CanReverseEventDeps"))
                {
                    stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                    stmt.AddParam("id_instances", MTParameterType.String, instances.ToCSVString());
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        return DBUtil.RowsetFromReader(reader);
                    }
                }
            }
		}

		public RecurringEventInstanceFilter DetermineExecutableEvents()
		{
			return DetermineProcessableEvents("DetermineExecutableEvents");
		}

		public RecurringEventInstanceFilter DetermineReversibleEvents()
		{
			return DetermineProcessableEvents("DetermineReversibleEvents");
		}

		/// <summary>
		/// Fails zombie recurring events for the machine that this method is called on.
		/// Zombies arise when a machine crashes as recurring events are being processed. 
		/// They can be detected and failed the next time the BillingServer service starts up.
		/// </summary>

    public int FailZombieEvents()
    {
      return FailZombieEvents(this.MachineIdentifier, mLogger);
    }

    /// <summary>
    /// Fails any events for the machine specified. This is specifically called for a
    /// different machine (specified machine) when it is detected that it has gone
    /// offline.
    /// </summary>
    /// <returns></returns>
    public static int FailZombieEvents(string machineIdentifier)
    {
      Logger logger = new Logger("[UsageServer]");
      return FailZombieEvents(machineIdentifier, logger);
    }

		public static int FailZombieEvents(string machineIdentifier, ILogger logger)
		{
			logger.LogDebug("Checking for zombie recurring events for machine {0}", machineIdentifier);
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("FailZombieRecurringEvents"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("tx_machine", MTParameterType.String, machineIdentifier);
          stmt.AddOutputParam("count", MTParameterType.Integer);
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            while (reader.Read())
            {
              int instanceID = reader.GetInt32("InstanceID");
              int runID = reader.GetInt32("RunID");
              logger.LogWarning("Zombie recurring event detected and marked as failed! InstanceID={0}, RunID={1}, Machine={2}",
                                                    instanceID, runID, machineIdentifier);
            }
          }
          return (int)stmt.GetOutputValue("count");
        }
      }
		}


		/// <summary>
		/// Determines if any instance of the named event is currently running.
		/// </summary>
		public bool IsAdapterRunning(string eventName)
		{
			int count = 0;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                // gets a list of active scheduled event names
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                              "__IS_ADAPTER_RUNNING__"))
                {
                    stmt.AddParam("%%EVENT_NAME%%", eventName);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            count = reader.GetInt32("Total");
                        }
                    }
                }
            }

			if (count > 0)
				return true;

			return false;
		}
		
		private RecurringEventInstanceFilter DetermineProcessableEvents(string sprocName)
		{
			RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement(sprocName))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          // looks at all ReadyToReverse instances
          stmt.AddParam("id_instances", MTParameterType.Integer, null);
          Stopwatch timer = new Stopwatch();
          timer.Start();
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            timer.Stop();
            mLogger.LogDebug("DetermineProcessableEvents({0}) stored procedure took {1} seconds to execute", sprocName, (timer.ElapsedMilliseconds / 1000));
            while (reader.Read())
            {
              int instanceID = reader.GetInt32("InstanceID");
              instances.AddInstanceCriteria(instanceID);
            }
          }
        }
      }

			return instances;
		}

	  private void ChangeInstanceStatus(int instanceID, RecurringEventInstanceStatus status)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                              "__CHANGE_RECURRING_EVENT_INSTANCE_STATUS__"))
                {
                    stmt.AddParam("%%NEW_STATUS%%", status.ToString());
                    stmt.AddParam("%%ID_INSTANCE%%", instanceID);
                    stmt.ExecuteNonQuery();
                }
            }
		}

	  private void MarkRunAsSucceeded(int runID, string detail)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                             "__CHANGE_RECURRING_EVENT_RUN_STATUS__"))
                {
                    stmt.AddParam("%%ID_RUN%%", runID);
                    stmt.AddParam("%%TX_STATUS%%", "Succeeded");

                    detail = detail == null ? "NULL" : detail;
                    string tx_detail = DBUtil.ToDBString(detail.Length > 2000 ? detail.Substring(0, 2000) : detail);
                    stmt.AddParam("%%TX_DETAIL%%", String.Format("N'{0}'", tx_detail), true);

                    stmt.ExecuteNonQuery();
                }
            }
		}

	  private void MarkRunAsFailed(int runID, string detail)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                             "__CHANGE_RECURRING_EVENT_RUN_STATUS__"))
                {
                    stmt.AddParam("%%ID_RUN%%", runID);
                    stmt.AddParam("%%TX_STATUS%%", "Failed");

                    detail = detail == null ? "NULL" : detail;
                    string tx_detail = DBUtil.ToDBString(detail.Length > 2000 ? detail.Substring(0, 2000) : detail);
                    stmt.AddParam("%%TX_DETAIL%%", String.Format("N'{0}'", tx_detail), true);

                    stmt.ExecuteNonQuery();
                }
            }
		}

		// the end root event depends on all other EOP events.
		// it is used to safely and automatically hard close usage intervals
		private void AddEndRootEvent(Hashtable events, Hashtable dependencies)
		{
			RecurringEvent root = new RecurringEvent();
			root.Name = "_EndRoot";
			root.DisplayName = "End root of all end-of-period events";
			root.Type = RecurringEventType.Root;
			root.Reversibility = ReverseMode.NotImplemented;
      root.BillingGroupSupport = BillingGroupSupportType.Account;
			root.AllowMultipleInstances = true;

			// dependencies
			ArrayList deps = new ArrayList();
			deps.Add("AllEOP");
			dependencies[root.Name] = deps;
			
			// schedule
			RecurringEventSchedule schedule = new RecurringEventSchedule();
			schedule.Type = RecurringEventScheduleType.CycleType;
			schedule.CycleType = CycleType.All;
			root.AddSchedule(schedule);

			events[root.Name] = root;
		}

		// the start root event has no dependencies. all other EOP events depend on it.
		// it is used to safely re-open usage intervals
		// NOTE: this must run after dependencies have been resolved and verified
		private void AddStartRootEvent(Hashtable events)
		{
			RecurringEvent root = new RecurringEvent();
			root.Name = "_StartRoot";
			root.DisplayName = "Start root of all end-of-period events";
			root.Type = RecurringEventType.Root;
			root.Reversibility = ReverseMode.NotImplemented;
      root.BillingGroupSupport = BillingGroupSupportType.Account;
			root.AllowMultipleInstances = true;

			// schedule
			RecurringEventSchedule schedule = new RecurringEventSchedule();
			schedule.Type = RecurringEventScheduleType.CycleType;
			schedule.CycleType = CycleType.All;
			root.AddSchedule(schedule);

			// adds the start root as a dependency to all EOP events with no dependencies
			// this effectively inserts the start root event before all other EOP events
      foreach (DictionaryEntry eventEntry in events)
			{
				RecurringEvent recurringEvent = (RecurringEvent) eventEntry.Value;

				if ((recurringEvent.Type == RecurringEventType.EndOfPeriod) &&
						(recurringEvent.Dependencies.Count == 0))
					recurringEvent.AddDependency(root);
			}

			events[root.Name] = root;
		}

		private void ReadEventsFromFile(string fileName,
																		bool useExtension,
																		Hashtable events,       // event name -> event object
																		Hashtable dependencies, // event name -> list of event names
																		ref bool allCycleTypeUsed)

		{
			try 
			{
				MTXmlDocument doc = new MTXmlDocument();
				doc.Load(fileName);

				string extension = null;
				if (useExtension)
					extension = mRcd.GetExtensionFromPath(fileName);

        // Read in the machine rules all at once
        MachineRules machineRules = MachineRules.GetDefaultMachineRules();
        FileInfo fi = new FileInfo(fileName);
        string machineRulesFilePath = fi.DirectoryName + @"\" + Path.GetFileNameWithoutExtension(fi.Name) + "_MachineRules.xml";
        if (File.Exists(machineRulesFilePath))
        {
          machineRules.ReadMachineRulesFromFile(machineRulesFilePath);
          mLogger.LogDebug("Loaded adapter machine rules from {0}: There are {1} machine specific rules", machineRulesFilePath, machineRules.Count);
        }
        else
        {
          mLogger.LogDebug("Machine rules not specified in file {0}: Using defaults.", machineRulesFilePath);
        }

				//
				// reads in scheduled events
				//
				foreach (XmlNode scheduledNode in doc.SelectNodes("/xmlconfig/ScheduledAdapters/Adapter"))
				{
					RecurringEvent scheduledEvent = ReadScheduledEvent(doc, scheduledNode, dependencies);
          scheduledEvent.SetMachineRules(machineRules.GetMachineRulesAsArrayListForEvent(scheduledEvent.Name));
					ValidateAndAddEvent(events, extension, scheduledEvent, ref allCycleTypeUsed);
				}
				
				//
				// reads in end of period events (and checkpoints)
				//
				foreach (XmlNode eopNode in doc.SelectNodes("/xmlconfig/EndOfPeriodAdapters/Adapter"))
				{
					RecurringEvent eopEvent = ReadEndOfPeriodEvent(doc, eopNode, dependencies);
          eopEvent.SetMachineRules(machineRules.GetMachineRulesAsArrayListForEvent(eopEvent.Name));

					ValidateAndAddEvent(events, extension, eopEvent, ref allCycleTypeUsed);
				}
				
				foreach (XmlNode checkpointNode in doc.SelectNodes("/xmlconfig/EndOfPeriodAdapters/Checkpoint"))
				{
					RecurringEvent checkpoint = ReadCheckpointEvent(doc, checkpointNode, dependencies);
					checkpoint.Reversibility = ReverseMode.Custom;
					checkpoint.AllowMultipleInstances = true;
          

					ValidateAndAddEvent(events, extension, checkpoint, ref allCycleTypeUsed);
				}

        //SetMachineRulesForEvents(events, machineRules);
      }
      catch (MTXmlException e)
      {
        throw new BadXmlException(fileName, e);
      }
    }

    /// <summary>
    /// Sets the machine rules on each event in a given set of events
    /// </summary>
    /// <param name="events"></param>
    /// <param name="machineRules"></param>
    private void SetMachineRulesForEvents(Hashtable events, MachineRules machineRules)
    {
      foreach (RecurringEvent recurringEvent in events.Values)
      {
        //recurringEvent.SetMachineRules(machineRules.GetMachineRulesAsArrayListForEvent(recurringEvent.Name));
        SetMachineRulesForEvent(recurringEvent, machineRules);
      }
    }

    private void SetMachineRulesForEvent(RecurringEvent recurringEvent, MachineRules machineRules)
    {
      recurringEvent.SetMachineRules(machineRules.GetMachineRulesAsArrayListForEvent(recurringEvent.Name));
    }
		
		private void ValidateAndAddEvent(Hashtable events, string extension, RecurringEvent recurringEvent, ref bool allCycleTypeUsed)
		{
			string name = recurringEvent.Name.ToLower();

			// requires an event name
			if (name.Length == 0)
				throw new MissingRecurringEventNameException(recurringEvent.ToString());
				
			// checks for reserved event names
			if ((name == "_startroot") || (name == "_endroot") || (name == "all") || (name == "alleop"))
				throw new ReservedRecurringEventNameException(name);

			// checks for duplicate events
			if (events.ContainsKey(name))
			{
				string otherExtension = ((RecurringEvent) events[name]).ExtensionName;
				throw new DuplicateRecurringEventNameException(name, extension, otherExtension);
			}


			// enforces that if an event used the 'All' usage cycle type then all other events use it too
			Debug.Assert(recurringEvent.Schedules.Count == 1);
			RecurringEventSchedule schedule = (RecurringEventSchedule) recurringEvent.Schedules[0];
			if ((schedule.Type == RecurringEventScheduleType.CycleType) &&
					(schedule.CycleType != CycleType.All) && allCycleTypeUsed)
				throw new NonExclusiveUsageCycleTypeException(recurringEvent.Name);

			if (schedule.CycleType == CycleType.All)
				allCycleTypeUsed = true;

			// adds the event
			recurringEvent.ExtensionName = extension;
			events[name] = recurringEvent;
		}

		private RecurringEvent ReadScheduledEvent(MTXmlDocument doc, XmlNode eventNode, Hashtable dependencies)
		{
			RecurringEvent recurringEvent = new RecurringEvent();
			recurringEvent.Type = RecurringEventType.Scheduled;

			//
			// reads in required nodes
			//
			recurringEvent.Name = MTXmlDocument.GetNodeValueAsString(eventNode, "Name");
			recurringEvent.DisplayName = MTXmlDocument.GetNodeValueAsString(eventNode, "DisplayName");
			recurringEvent.ClassName = eventNode.SelectSingleNode("ClassID").InnerText;

      ReadSchedule(doc, eventNode, recurringEvent);

			ReadDependencies(doc, eventNode, recurringEvent, dependencies);


			//
			// reads in optional nodes
			//
			recurringEvent.ConfigFileName = MTXmlDocument.GetNodeValueAsString(eventNode, "ConfigFile", null);
			if (recurringEvent.ConfigFileName == "")
				recurringEvent.ConfigFileName = null;

			recurringEvent.Description = MTXmlDocument.GetNodeValueAsString(eventNode, "Description", null);
			if (recurringEvent.Description == "")
				recurringEvent.Description = null;

			recurringEvent.ActivationDate = MTXmlDocument.GetNodeValueAsDateTime(eventNode, "ActivationDate", DateTime.MinValue);


			// 
			// user friendly error prevention
			//

			// explicitly disallow this EOP only tag
			if (eventNode.SelectNodes("RecurrencePattern/UsageCycleType").Count > 0)
				throw new 
					InvalidConfigurationException(
						String.Format("The <UsageCycleType> tag cannot be used with scheduled event '{0}'!", recurringEvent.Name));

			return recurringEvent;
		}

    private void ReadSchedule(MTXmlDocument doc, XmlNode eventNode, RecurringEvent recurringEvent)
    {
      //foreach (XmlNode cycle in eventNode.SelectNodes("RecurrencePattern/SystemCycle"))
      //  recurringEvent.AddSchedule(ReadSystemCycleSchedule(cycle));

      //foreach (XmlNode cycle in eventNode.SelectNodes("RecurrencePattern/IntervalInMinutes"))
      //  recurringEvent.AddSchedule(ReadIntervalInMinutesSchedule(cycle));

      try
      {
        RecurringEventSchedule schedule = new RecurringEventSchedule();
        schedule.Type = RecurringEventScheduleType.RecurrencePattern;
        BaseRecurrencePattern pattern = RecurrencePatternFactory.ReadRecurrencePattern(eventNode);
        schedule.Pattern = pattern;
        recurringEvent.AddSchedule(schedule);

      }
      catch (Exception ex)
      {
        mLogger.LogException("error reading scheduled adapter schedule", ex);
        throw new MTXmlException(
                String.Format("Unable to parse recurrency pattern for scheduled event '{0}'!", recurringEvent.Name), ex);
      }
    }

		private RecurringEvent ReadEndOfPeriodEvent(MTXmlDocument doc, XmlNode eventNode, Hashtable dependencies)
		{
			RecurringEvent recurringEvent = new RecurringEvent();
			recurringEvent.Type = RecurringEventType.EndOfPeriod;

			//
			// reads in required nodes
			//
			recurringEvent.Name = MTXmlDocument.GetNodeValueAsString(eventNode, "Name");
			recurringEvent.DisplayName = MTXmlDocument.GetNodeValueAsString(eventNode, "DisplayName");
			recurringEvent.ClassName = eventNode.SelectSingleNode("ClassID").InnerText;

			XmlNode cycleNode = MTXmlDocument.SelectOnlyNode(eventNode, "RecurrencePattern/UsageCycleType");
			recurringEvent.AddSchedule(ReadUsageCycleSchedule(cycleNode));

			ReadDependencies(doc, eventNode, recurringEvent, dependencies);

			//
			// reads in optional nodes
			//
			recurringEvent.ConfigFileName = MTXmlDocument.GetNodeValueAsString(eventNode, "ConfigFile", null);
			if (recurringEvent.ConfigFileName == "")
				recurringEvent.ConfigFileName = null;

			recurringEvent.Description = MTXmlDocument.GetNodeValueAsString(eventNode, "Description", null);
			if (recurringEvent.Description == "")
				recurringEvent.Description = null;

			recurringEvent.ActivationDate = MTXmlDocument.GetNodeValueAsDateTime(eventNode, "ActivationDate", DateTime.MinValue);

			// allows a legacy adapters to override runtime metadata about reversibility
			if (MTXmlDocument.GetNodeValueAsBool(eventNode, "ReverseNotNeeded", false))
				recurringEvent.Reversibility = ReverseMode.NotNeeded;
					
			// allows a legacy adapters to override runtime metadata about multi-instance
			recurringEvent.AllowMultipleInstances = MTXmlDocument.GetNodeValueAsBool(eventNode, "AllowMultipleInstances", false);


			// 
			// user friendly error prevention
			//

			// disallows the scheduled only tag - SystemCycle
			if (eventNode.SelectNodes("RecurrencePattern/SystemCycle").Count > 0)
				throw new 
					InvalidConfigurationException(
						String.Format("The <SystemCycle> tag cannot be used with EOP event '{0}'!", recurringEvent.Name));
			
			// disallows the scheduled only tag - IntervalInMinutes
			if (eventNode.SelectNodes("RecurrencePattern/IntervalInMinutes").Count > 0)
				throw new InvalidConfigurationException(
					String.Format("The <IntervalInMinutes> tag cannot be used with EOP event '{0}'!", recurringEvent.Name));

			return recurringEvent;
		}

		private RecurringEvent ReadCheckpointEvent(MTXmlDocument doc, XmlNode eventNode, Hashtable dependencies)
		{
			RecurringEvent recurringEvent = new RecurringEvent();
			recurringEvent.Type = RecurringEventType.Checkpoint;
      recurringEvent.BillingGroupSupport = BillingGroupSupportType.Account;

			//
			// reads in required nodes
			//
			recurringEvent.Name = MTXmlDocument.GetNodeValueAsString(eventNode, "Name");
			recurringEvent.DisplayName = MTXmlDocument.GetNodeValueAsString(eventNode, "DisplayName");

			XmlNode cycleNode = MTXmlDocument.SelectOnlyNode(eventNode, "RecurrencePattern/UsageCycleType");
			recurringEvent.AddSchedule(ReadUsageCycleSchedule(cycleNode));

			ReadDependencies(doc, eventNode, recurringEvent, dependencies);

			//
			// reads in optional nodes
			//
			recurringEvent.Description = MTXmlDocument.GetNodeValueAsString(eventNode, "Description", null);
			if (recurringEvent.Description == "")
				recurringEvent.Description = null;

			recurringEvent.ActivationDate = MTXmlDocument.GetNodeValueAsDateTime(eventNode, "ActivationDate", DateTime.MinValue);

			// 
			// user friendly error prevention
			//
			// disallows the scheduled only tag - SystemCycle
			if (eventNode.SelectNodes("RecurrencePattern/SystemCycle").Count > 0)
				throw new InvalidConfigurationException(
					String.Format("The <SystemCycle> tag cannot be used with EOP event '{0}'!", recurringEvent.Name));
			
			// disallows the scheduled only tag - IntervalInMinutes
			if (eventNode.SelectNodes("RecurrencePattern/IntervalInMinutes").Count > 0)
				throw new InvalidConfigurationException(
					String.Format("The <IntervalInMinutes> tag cannot be used with EOP event '{0}'!", recurringEvent.Name));

			return recurringEvent;
		}

		private void ReadDependencies(MTXmlDocument doc,
																	XmlNode eventNode,
																	RecurringEvent recurringEvent,
																	Hashtable dependencies)
		{
			//
			// reads 'DependsOn' dependencies
			//
			XmlNodeList dependencyNodes = eventNode.SelectNodes("Dependencies/DependsOn");
			if (dependencyNodes.Count > 0)
			{
				foreach (XmlNode dependsOnNode in dependencyNodes)
				{
					ArrayList dependencyList = (ArrayList) dependencies[recurringEvent.Name];
					if (dependencyList == null)
					{
						dependencyList = new ArrayList();
						dependencies[recurringEvent.Name] = dependencyList;
					}

					if (dependencyList.Contains(dependsOnNode.InnerText))
					{
						mLogger.LogWarning("Event '{0}' depends on '{1}' more than once.",
															 recurringEvent.Name, dependsOnNode.InnerText);
					}
					else
						dependencyList.Add(dependsOnNode.InnerText);
				}
			}

			//
			// reads 'DependsOnMe' dependencies
			//
			dependencyNodes = eventNode.SelectNodes("Dependencies/DependsOnMe");
			if (dependencyNodes.Count > 0)
			{
				foreach (XmlNode dependsOnMeNode in dependencyNodes)
				{
					string parent = dependsOnMeNode.InnerText;
					ArrayList dependencyList = (ArrayList) dependencies[parent];
					if (dependencyList == null)
					{
						dependencyList = new ArrayList();
						dependencies[parent] = dependencyList;
					}

					if (dependencyList.Contains(recurringEvent.Name))
					{
						mLogger.LogWarning("Event '{0}' depends on '{1}' more than once.",
															 parent, recurringEvent.Name);
					}
					else
						dependencyList.Add(recurringEvent.Name);
				}
			}
		}

		private RecurringEventSchedule ReadUsageCycleSchedule(XmlNode node)
		{
			// <RecurrencePattern>
			//   <UsageCycleType>Monthly</UsageCycleType>
			// </RecurrencePattern>

			RecurringEventSchedule schedule = new RecurringEventSchedule();
			schedule.Type = RecurringEventScheduleType.CycleType;

			string strValue = node.InnerText;
			schedule.CycleType = CycleUtils.ParseCycleType(strValue);

			return schedule;
		}
		
		private void VisitDependencies(RecurringEvent recurringEvent, Hashtable visited, Hashtable verified)
		{
			// skips this event if it has already been verified
			if (verified.Contains(recurringEvent.Name))
				return;

			if (visited.Contains(recurringEvent.Name))
				throw new CircularDependencyException(recurringEvent.Name);

			// indicate that we've visited this event.  If we see it again
			// then there's a circular reference.
			// only the key matters - we use the hashtable like a set
			visited.Add(recurringEvent.Name, null);

			// visit all children
			foreach (RecurringEvent dependency in recurringEvent.Dependencies)
				VisitDependencies(dependency, visited, verified);

			verified.Add(recurringEvent.Name, null);
		}

		private void AddEvents(IMTConnection conn, ArrayList newEvents)
		{
			if (newEvents.Count == 0)
			{
				mLogger.LogDebug("No new/modified recurring events");
				return;
			}


			if (mEventIDGenerator == null)
				mEventIDGenerator = new IdGenerator("recevent", 100);

			string insertEventQuery = "insert into t_recevent "
				+ "(id_event, tx_name, tx_type, tx_reverse_mode, b_multiinstance, " 
        + "tx_billgroup_support, b_has_billgroup_constraints, "
				+	"tx_class_name, tx_extension_name, tx_config_file, dt_activated, dt_deactivated, "
				+	"tx_display_name, tx_desc) values " 
				+ "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, null, ?, ?)";


            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(insertEventQuery))
            {

                // activation time
                DateTime now = MetraTech.MetraTime.Now;

                foreach (RecurringEvent recurringEvent in newEvents)
                {
                    mLogger.LogDebug("Adding recurring event {0}", recurringEvent.Name);
                    stmt.ClearParams();

                    // generate a new ID for this event
                    recurringEvent.PreviousEventID = recurringEvent.EventID;
                    recurringEvent.EventID = mEventIDGenerator.NextId;

                    stmt.AddParam(MTParameterType.Integer, recurringEvent.EventID);
                    stmt.AddParam(MTParameterType.WideString, recurringEvent.Name);
                    stmt.AddParam(MTParameterType.String, recurringEvent.Type.ToString());
                    stmt.AddParam(MTParameterType.String, recurringEvent.Reversibility.ToString());
                    stmt.AddParam(MTParameterType.String, recurringEvent.AllowMultipleInstances == true ? "Y" : "N");
                    stmt.AddParam(MTParameterType.String, recurringEvent.BillingGroupSupport.ToString());
                    if (recurringEvent.BillingGroupSupport != BillingGroupSupportType.Interval)
                    {
                        stmt.AddParam(MTParameterType.String, recurringEvent.HasBillgroupConstraints == true ? "Y" : "N");
                    }
                    else
                    {
                        stmt.AddParam(MTParameterType.String, null);
                    }

                    stmt.AddParam(MTParameterType.String, recurringEvent.ClassName);
                    stmt.AddParam(MTParameterType.String, recurringEvent.ExtensionName);
                    stmt.AddParam(MTParameterType.String, recurringEvent.ConfigFileName);

                    if (recurringEvent.ActivationDate == DateTime.MinValue)
                        stmt.AddParam(MTParameterType.DateTime, now);
                    else
                        stmt.AddParam(MTParameterType.DateTime, recurringEvent.ActivationDate);

                    stmt.AddParam(MTParameterType.WideString, recurringEvent.DisplayName);
                    stmt.AddParam(MTParameterType.WideString, recurringEvent.Description);

                    stmt.ExecuteNonQuery();
                }
            }

			// add all the dependencies
			AddDependencies(conn, newEvents);

			// add all the schedules
			AddSchedules(conn, newEvents);

      // Add the machine rules
      AddMachineRules(conn, newEvents);

		}

        private void DeactivateEvents(IMTConnection conn, ArrayList events)
        {
            if (events.Count == 0)
            {
                mLogger.LogDebug("No recurring events to deactivate");
                return;
            }

            string deactivateEventQuery = "update t_recevent set dt_deactivated=? where id_event=?";

            // deactivation time
            DateTime now = MetraTech.MetraTime.Now;

            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(deactivateEventQuery))
            {
                foreach (RecurringEvent recurringEvent in events)
                {
                    mLogger.LogDebug("Deactivating recurring event with ID {0}", recurringEvent.EventID);
                    stmt.ClearParams();
                    stmt.AddParam(MTParameterType.DateTime, now);
                    stmt.AddParam(MTParameterType.Integer, recurringEvent.EventID);
                    stmt.ExecuteNonQuery();


                }

            }
        }


        private void AddDependencies(IMTConnection conn, ArrayList newEvents)
        {
            string insertDepQuery = "insert into t_recevent_dep "
                + " (id_event, id_dependent_on_event, n_distance) values (?, ?, ?)";

            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(insertDepQuery))
            {

                // iterates over each event to be added
                foreach (RecurringEvent recurringEvent in newEvents)
                {
                    AddDependency(stmt, recurringEvent, recurringEvent, 0);

                    // iterates over each dependency of the event to be added
                    foreach (RecurringEventDependency dep in recurringEvent.FullDependencies.Values)
                        AddDependency(stmt, recurringEvent, dep.Event, dep.Distance);
                }
            }
        }

	  private void AddDependency(IMTPreparedStatement stmt, RecurringEvent recurringEvent,
															 RecurringEvent dep, int distance)
		{
			stmt.ClearParams();
			stmt.AddParam(MTParameterType.Integer, recurringEvent.EventID);
			stmt.AddParam(MTParameterType.Integer, dep.EventID);
			stmt.AddParam(MTParameterType.Integer, distance);
			
			stmt.ExecuteNonQuery();
		}

    private void AddMachineRules(IMTConnection conn, ArrayList newEvents)
    {
      MachineRuleManager.AddMachineRulesToDatabase(conn, newEvents);
    }

    private void AddEopSchedule(IMTConnection conn, RecurringEvent recurringEvent)
    {
      string insertQuery = "insert into t_recevent_eop "
          + " (id_event, id_cycle_type, id_cycle) values (?, ?, ?)";

      using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(insertQuery))
      {
        //should it really be looping? Just one schedule is supported
        foreach (RecurringEventSchedule schedule in recurringEvent.Schedules) 
        {
          stmt.ClearParams();
          stmt.AddParam(MTParameterType.Integer, recurringEvent.EventID);

          switch (schedule.Type)
          {
            case RecurringEventScheduleType.CycleType:
              if (schedule.CycleType == CycleType.All)
                stmt.AddParam(MTParameterType.Integer, null);
              else
                stmt.AddParam(MTParameterType.Integer, (int)schedule.CycleType);
              stmt.AddParam(MTParameterType.Integer, null);
              break;

            case RecurringEventScheduleType.Cycle:
              stmt.AddParam(MTParameterType.Integer, GetCycleTypeID(conn, schedule.CycleID));
              stmt.AddParam(MTParameterType.Integer, schedule.CycleID);
              break;

            case RecurringEventScheduleType.RecurrencePattern:
              string msg = string.Format("Recurrence Pattern can not be used with EOP event, event id: {0}", recurringEvent.EventID);
              throw new UsageServerException(msg);
          }

          stmt.ExecuteNonQuery();
        }
      }
    }

    private void AddScheduledSchedule(IMTConnection conn, RecurringEvent recurringEvent)
    {
      string insertQuery = "insert into t_recevent_scheduled "
          + " (id_event, interval_type, interval, start_date, execution_times, "
          + "  days_of_week, days_of_month, is_paused, override_date, update_date) "
          + " values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

      using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(insertQuery))
      {
        //should it really be looping? Just one schedule is supported
        foreach (RecurringEventSchedule schedule in recurringEvent.Schedules)
        {
          stmt.ClearParams();

          if (schedule.Type != RecurringEventScheduleType.RecurrencePattern)
          {
            string msg = string.Format("Only Recurrence Pattern can not be used with Scheduled event, event id: {0}", recurringEvent.EventID);
            throw new UsageServerException(msg);
          }

          BaseRecurrencePattern pattern = schedule.Pattern;

          string intervalType;
          int interval = 0;
          DateTime startDate = pattern.StartDate;
          string executionTimes = null;
          string daysOfWeek = null;
          string daysOfMonth = null;
          bool isPaused = pattern.IsPaused;
          DateTime OverrideDate = pattern.OverrideDate; ;
          DateTime UpdateDate = MetraTime.Now;

          if (pattern is MinutelyRecurrencePattern)
          {
            MinutelyRecurrencePattern minutely = (MinutelyRecurrencePattern)pattern;
            intervalType = "Minutely";
            interval = minutely.IntervalInMinutes;
          }
          else if (pattern is DailyRecurrencePattern)
          {
            DailyRecurrencePattern daily = (DailyRecurrencePattern)pattern;
            intervalType = "Daily";
            interval = daily.IntervalInDays;
            executionTimes = daily.ExecutionTimes.ToString();
          }
          else if (pattern is WeeklyRecurrencePattern)
          {
            WeeklyRecurrencePattern weekly = (WeeklyRecurrencePattern)pattern;
            intervalType = "Weekly";
            interval = weekly.IntervalInWeeks;
            executionTimes = weekly.ExecutionTimes.ToString();
            daysOfWeek = weekly.DaysOfWeek.ToString();
          }
          else if (pattern is MonthlyRecurrencePattern)
          {
            MonthlyRecurrencePattern monthly = (MonthlyRecurrencePattern)pattern;
            intervalType = "Monthly";
            interval = monthly.IntervalInMonth;
            executionTimes = monthly.ExecutionTimes.ToString();
            daysOfMonth = monthly.DaysOfMonth.ToString();
          }
          else if (pattern is ManualRecurrencePattern)
          {
            intervalType = "Manual";
          }
          else throw new UsageServerException(string.Format("Unknown interval type {0}", pattern.GetType().ToString()));

          //+ " (id_event, interval_type, interval, start_date, execution_times, "
          //+ "  days_of_week, days_of_month, is_paused, override_date, update_date) "
          stmt.AddParam(MTParameterType.Integer, recurringEvent.EventID);
          stmt.AddParam(MTParameterType.String, intervalType);
          // for a manual it will be still uninitialized
          if (interval == 0) stmt.AddParam(MTParameterType.Integer, null);
          else stmt.AddParam(MTParameterType.Integer, interval);
          stmt.AddParam(MTParameterType.DateTime, startDate);
          stmt.AddParam(MTParameterType.String, executionTimes);
          stmt.AddParam(MTParameterType.String, daysOfWeek);
          stmt.AddParam(MTParameterType.String, daysOfMonth);
          stmt.AddParam(MTParameterType.String, isPaused == true ? "Y" : "N");
          if (OverrideDate == MetraTime.Min) stmt.AddParam(MTParameterType.DateTime, null);
          else stmt.AddParam(MTParameterType.DateTime, OverrideDate);
          stmt.AddParam(MTParameterType.DateTime, UpdateDate);

          stmt.ExecuteNonQuery();
        }
      }
    }

    private void AddSchedules(IMTConnection conn, ArrayList newEvents)
    {
      foreach (RecurringEvent recurringEvent in newEvents)
      {
        if (recurringEvent.Type == RecurringEventType.Scheduled)
        {
          AddScheduledSchedule(conn, recurringEvent);
        }
        else
        {
          AddEopSchedule(conn, recurringEvent);
        }
      }
    }

		// TODO: move this into Cycles.cs?
      private int GetCycleTypeID(IMTConnection conn, int cycleID)
      {
          // small optimization - cycle ID 2 is daily.  This is the most common
          // request for recurring event schedules.
          if (cycleID == 2)
              return (int)CycleType.Daily;

          string query = String.Format("select id_cycle_type from t_usage_cycle where id_usage_cycle = {0}", cycleID);
          using (IMTStatement stmt =
              conn.CreateStatement(query))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (!reader.Read())
                      throw new UsageServerException(String.Format("Unable to find usage cycle type for cycle ID {0}", cycleID));

                  int cycleType = reader.GetInt32(0);

                  if (reader.Read())
                      throw new UsageServerException(String.Format("Ambiguous cycle type returned for cycle ID {0}", cycleID));

                  return cycleType;
              }
          }
      }


      private Hashtable ReadDBDependencies(IMTConnection conn)
      {
          //
          // read the dependencies that the database currently knows about.
          //
          string query = @"select dep.id_event, dep.id_dependent_on_event 
from t_recevent_dep dep 
  inner join t_recevent e on e.id_event = dep.id_event
  inner join t_recevent ed on ed.id_event = dep.id_dependent_on_event
where e.dt_deactivated is null and ed.dt_deactivated is null and dep.n_distance = 1 ";
          using (IMTStatement stmt =
              conn.CreateStatement(query))
          {

              Hashtable dbDependencies = new Hashtable();
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      int eventID = reader.GetInt32(0);
                      int dependentOnID = reader.GetInt32(1);

                      ArrayList depList;
                      if (!dbDependencies.Contains(eventID))
                      {
                          depList = new ArrayList();
                          dbDependencies.Add(eventID, depList);
                      }
                      else
                          depList = (ArrayList)dbDependencies[eventID];

                      depList.Add(dependentOnID);
                  }
              }
              return dbDependencies;
          }
      }

      private Hashtable ReadDBSchedules(IMTConnection conn)
      {
        Hashtable dbSchedulesEOP = ReadDBSchedulesEOP(conn);
        Hashtable dbSchedulesScheduled = ReadDBSchedulesScheduled(conn);
        foreach (int eventId in dbSchedulesEOP.Keys) {
          dbSchedulesScheduled.Add(eventId,dbSchedulesEOP[eventId]);
        }
        //TODO: switch to generic collections
        return dbSchedulesScheduled;
      }

      public BaseRecurrencePattern ReadRecurrencePatternFromReader(IMTDataReader reader)
      {
        BaseRecurrencePattern pattern = null;

        int eventID = reader.GetInt32("id_event");
        string IntervalType = reader.GetString("interval_type");
        string executionTimes;

        try
        {
          switch (IntervalType)
          {
            case "Minutely":
              if (reader.IsDBNull("interval")) throw new Exception("interval can not be null for minutely interval");
              int intervalInMinutes = reader.GetInt32("interval");
              pattern = new MinutelyRecurrencePattern(intervalInMinutes);
              break;
            case "Daily":
              if (reader.IsDBNull("interval")) throw new Exception("interval can not be null for daily interval");
              int intervalInDays = reader.GetInt32("interval");
              if (reader.IsDBNull("execution_times"))
                throw new UsageServerException("execution_times can not be NULL for Daily interval");
              executionTimes = reader.GetString("execution_times");
              pattern = new DailyRecurrencePattern(intervalInDays, executionTimes);
              break;
            case "Weekly":
              if (reader.IsDBNull("interval")) throw new Exception("interval can not be null for weekly interval");
              int intervalInWeeks = reader.GetInt32("interval");
              if (reader.IsDBNull("execution_times"))
                throw new UsageServerException("execution_times can not be NULL for Weekly interval");
              executionTimes = reader.GetString("execution_times");
              if (reader.IsDBNull("days_of_week"))
                throw new UsageServerException("days_of_week can not be NULL for Weekly interval");
              string daysOfWeek = reader.GetString("days_of_week");
              pattern = new WeeklyRecurrencePattern(intervalInWeeks, executionTimes, daysOfWeek);
              break;
            case "Monthly":
              if (reader.IsDBNull("interval")) throw new Exception("interval can not be null for monthly interval");
              int intervalInMonth = reader.GetInt32("interval");
              if (reader.IsDBNull("execution_times"))
                throw new UsageServerException("execution_times can not be NULL for Monthly interval");
              executionTimes = reader.GetString("execution_times");
              if (reader.IsDBNull("days_of_month"))
                throw new UsageServerException("days_of_month can not be NULL for Monthly interval");
              string daysOfMonth = reader.GetString("days_of_month");
              pattern = new MonthlyRecurrencePattern(intervalInMonth, executionTimes, daysOfMonth);
              break;
            case "Manual":
              pattern = new ManualRecurrencePattern();
              break;
            default:
              throw new UsageServerException(
                string.Format("Unsupported interval type: {0} found for event {1}", IntervalType, eventID));
          }
          // read properties common to all patterns
          if (!reader.IsDBNull("start_date"))
            pattern.StartDate = reader.GetDateTime("start_date");
          if (!reader.IsDBNull("override_date"))
            pattern.OverrideDate = reader.GetDateTime("override_date");
          if (!reader.IsDBNull("is_paused"))
            pattern.IsPaused = reader.GetBoolean("is_paused");
        }
        catch (Exception ex)
        {
          string msg = string.Format("Error reading db schedules for event {0} from db", eventID);
          throw new UsageServerException(msg, ex);
        }
        return pattern;
      }

      public Hashtable ReadDBSchedulesScheduled(IMTConnection conn)
      {
        //
        // read the active schedules that the database currently knows about.
        //
        using (IMTStatement stmt =
            conn.CreateStatement(
                "select sch.id_event, sch.interval_type, sch.interval, sch.start_date, sch.execution_times, "
                + " sch.days_of_week, sch.days_of_month, sch.is_paused, sch.override_date "
                + " from t_recevent_scheduled sch "
                + " inner join t_recevent on t_recevent.id_event = sch.id_event "
                + " where t_recevent.dt_deactivated is null"))
        {

          // int -> ArrayList(RecurringEventSchedule)
          Hashtable dbSchedules = new Hashtable();

          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            while (reader.Read())
            {
              int eventID = reader.GetInt32("id_event");
              BaseRecurrencePattern pattern = ReadRecurrencePatternFromReader(reader);

              RecurringEventSchedule schedule = new RecurringEventSchedule();
              schedule.Type = RecurringEventScheduleType.RecurrencePattern;
              schedule.Pattern = pattern;

              ArrayList schList;
              if (!dbSchedules.Contains(eventID))
              {
                schList = new ArrayList();
                dbSchedules[eventID] = schList;
              }
              else
                schList = (ArrayList)dbSchedules[eventID];

              schList.Add(schedule);
            }
          }

          return dbSchedules;
        }
      }

      private Hashtable ReadDBSchedulesEOP(IMTConnection conn)
      {
          //
          // read the active schedules that the database currently knows about.
          //
          using (IMTStatement stmt =
              conn.CreateStatement(
                  "select sch.id_event, sch.id_cycle_type, sch.id_cycle from t_recevent_eop sch "
                  + " inner join t_recevent on t_recevent.id_event = sch.id_event "
                  + " where t_recevent.dt_deactivated is null"))
          {

              // int -> ArrayList(RecurringEventSchedule)
              Hashtable dbSchedules = new Hashtable();

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      RecurringEventSchedule schedule = new RecurringEventSchedule();

                      // is cycle type non-null?
                      if (!reader.IsDBNull(1))
                      {
                          // is cycle ID non-null?
                          if (!reader.IsDBNull(2))
                          {
                              // reads the cycle
                              schedule.Type = RecurringEventScheduleType.Cycle;
                              schedule.CycleID = reader.GetInt32(2);
                          }
                          else
                          {
                              // reads the cycle type
                              schedule.Type = RecurringEventScheduleType.CycleType;
                              int cycleTypeID = reader.GetInt32(1);
                              Debug.Assert(CycleUtils.IsSupportedCycleType(cycleTypeID));
                              schedule.CycleType = (CycleType)cycleTypeID;
                          }

                      }
                      else
                      {
                              // all columns are null - all cycle types
                              schedule.Type = RecurringEventScheduleType.CycleType;
                              schedule.CycleType = CycleType.All;
                      }

                      ArrayList schList;
                      int eventID = reader.GetInt32(0);
                      if (!dbSchedules.Contains(eventID))
                      {
                          schList = new ArrayList();
                          dbSchedules[eventID] = schList;
                      }
                      else
                          schList = (ArrayList)dbSchedules[eventID];

                      schList.Add(schedule);
                  }
              }

              return dbSchedules;
          }
      }

		private void GetAdapterRuntimeMetadata(RecurringEvent recurringEvent)
		{
			GetAdapterRuntimeMetadata(recurringEvent, AdapterManager.GetSuperUserContext());
		}

		private void GetAdapterRuntimeMetadata(RecurringEvent recurringEvent, IMTSessionContext sessionContext)
		{
			// root events and checkpoints don't have any adapter metadata
			if ((recurringEvent.Type == RecurringEventType.Root) ||
					(recurringEvent.Type == RecurringEventType.Checkpoint))
				return;

			// creates the adapter instance
			mLogger.LogDebug("Creating instance of the '{0}' adapter with class name '{1}'",
											 recurringEvent.Name, recurringEvent.ClassName);
			bool isLegacyAdapter;
			IRecurringEventAdapter2 adapter = 
				AdapterManager.CreateAdapterInstance(recurringEvent.ClassName, out isLegacyAdapter);

			// gets the absolute file name to the adapter's config file
			string configFile = AdapterManager.GetAbsoluteConfigFile(recurringEvent.ExtensionName,
																															 recurringEvent.ConfigFileName,
																															 isLegacyAdapter);
			// initalizes the adapter
			mLogger.LogDebug("Initializing (limited) the '{0}' adapter with configuration file '{1}'",
											 recurringEvent.Name, configFile);
			adapter.Initialize(recurringEvent.Name, configFile, sessionContext, true);

			// runtime metadata does not exist for legacy adapters
			// if (isLegacyAdapter)
			//  	return;

			// validates the adapter supports the requested event type
			if ((recurringEvent.Type == RecurringEventType.EndOfPeriod) && !adapter.SupportsEndOfPeriodEvents)
				throw new NoEndOfPeriodSupportException(recurringEvent);

			if ((recurringEvent.Type == RecurringEventType.Scheduled) && !adapter.SupportsScheduledEvents)
				throw new NoScheduledSupportException(recurringEvent);
				
			recurringEvent.Reversibility = adapter.Reversibility;
			recurringEvent.AllowMultipleInstances = adapter.AllowMultipleInstances;

      if ((recurringEvent.Type == RecurringEventType.EndOfPeriod))
      {
        recurringEvent.BillingGroupSupport = adapter.BillingGroupSupport;
        if (adapter.BillingGroupSupport != BillingGroupSupportType.Interval) 
        {
          recurringEvent.HasBillgroupConstraints = adapter.HasBillingGroupConstraints;
        }
      }

			adapter.Shutdown();
		}

    /// <summary>
    /// Returns the machine identifier currently being used
    /// Typically this is the machine name from the operating system
    /// but for testing can be set when the recurring event manager is 
    /// created
    /// </summary>
    public string MachineIdentifier
    {
      get
      {
        //Set the machine identifier if it hasn't been set/passed
        if (string.IsNullOrEmpty(mMachineIdentifier))
          mMachineIdentifier = System.Environment.MachineName;

        return mMachineIdentifier;

      }
    }

    private string mMachineIdentifier = null;

		private IdGenerator mEventIDGenerator;
		private IdGenerator mRunIDGenerator;
		private Logger mLogger;
		private static RCD.IMTRcd mRcd;
	}


	/// <summary>
	/// Implementation of IRecurringEvent
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("ae411b48-16d9-496f-8e26-3a340b43b5b3")]
  public class RecurringEvent : IRecurringEvent
	{
		/// <summary>
		/// constructor
		/// </summary>
		public RecurringEvent()
		{
			mLogger = new Logger("[UsageServer]");

			mEventID = -1;
			mPreviousEventID = -1;
			mDependencies = new ArrayList();
      mMachineRules = new ArrayList();
			mSchedules = new ArrayList();
			mReversibility = ReverseMode.NotImplemented;
		}

		/// <summary>
		/// unique ID of this event, if known.
		/// </summary>
		public int EventID
		{
			get
			{ return mEventID; }
			
			set
			{ mEventID = value; }
		}

		/// <summary>
		/// unique ID of this event, if known.
		/// </summary>
		internal int PreviousEventID
		{
			get
			{ return mPreviousEventID; }
			
			set
			{ mPreviousEventID = value; }
		}

		/// <summary>
		/// Type of recurring event
		/// </summary>
		public RecurringEventType Type
		{
			get
			{ return mType; }
			set
			{ mType = value; }
		}

		/// <summary>
		/// Extension name where this event is configured.  Used
		/// to ensure Name uniqueness.
		/// </summary>
		public string ExtensionName
		{
			get
			{ return mExtensionName; }
			set
			{ mExtensionName = value; }
		}

		/// <summary>
		/// Event name.  Used to configure dependencies between events.
		/// </summary>
		public string Name
		{
			get
			{ return mName; }
			set
			{ mName = value; }
		}

		/// <summary>
		/// Event name.  Used to configure dependencies between events.
		/// </summary>
		public string DisplayName
		{
			get
			{ return mDisplayName; }
			set
			{ mDisplayName = value; }
		}

		/// <summary>
		/// Class name of event.
		/// </summary>
		public string ClassName
		{
			get
			{ return mClassName; }
			set
			{ mClassName = value; }
		}

		/// <summary>
		/// Config file passed to event
		/// </summary>
		public string ConfigFileName
		{
			get
			{ return mConfigFileName; }
			set
			{ mConfigFileName = value; }
		}

		/// <summary>
		/// Description of the event
		/// </summary>
		public string Description
		{
			get
			{ return mDescription; }
			set
			{ mDescription = value; }
		}

		/// <summary>
		/// ability to reverse event.
		/// </summary>
		public ReverseMode Reversibility
		{
			get
			{ return mReversibility; }
			set
			{ mReversibility = value; }
		}

		/// <summary>
		/// whether the event can support multiple instances of the adapter
		/// running concurrently.
		/// </summary>
		public bool AllowMultipleInstances
		{
			get
			{ return mAllowMulipleInstances; }
			set
			{ mAllowMulipleInstances = value; }
		}

    /// <summary>
    /// whether the event supports billing groups
    /// </summary>
    public BillingGroupSupportType BillingGroupSupport
    {
      get
      { return mBillingGroupSupport; }
      set
      { mBillingGroupSupport = value; }
    }

    /// <summary>
    /// whether the event has billing group constraints
    /// </summary>
    public bool HasBillgroupConstraints
    {
      get
      { return mHasBillgroupConstraints; }
      set
      { mHasBillgroupConstraints = value; }
    }

		/// <summary>
		/// Returns a list of of events this event depends on
		/// </summary>
		public ArrayList Dependencies
		{
			get
			{ return ArrayList.ReadOnly(mDependencies); }
		}

    /// <summary>
    /// Returns a list of machine rules (which machine or machine roles can run this adapter)
    /// </summary>
    public ArrayList MachineRules
    {
      get
      { return ArrayList.ReadOnly(mMachineRules); }
    }

    /// <summary>
    /// Sets the machine rules (which machines the event can run on) for this event
    /// </summary>
    /// <param name="machineRules"></param>
    internal void SetMachineRules(ArrayList machineRules)
    {
      mMachineRules = machineRules;
    }

		/// <summary>
		/// List of cycle types and/or cycles on which this event will be fired.
		/// </summary>
		public ArrayList Schedules
		{
			get
			{ return ArrayList.ReadOnly(mSchedules); }
		}

		internal void AddSchedule(RecurringEventSchedule schedule)
		{
			mSchedules.Add(schedule);
		}

		internal void SetSchedules(ArrayList schedules)
		{
			mSchedules = schedules;
		}

		/// <summary>
		/// The time the event is to be activated. NOTE: DateTime.MinValue means now.
		/// </summary>
		internal DateTime ActivationDate
		{
			get
			{ return mActivationDate; }
			set
			{ mActivationDate = value; }
		}

		/// <summary>
		/// Provides an equality function for RecurringEvent objects.
		/// Does not check dynamic properties such as EventID, 
		/// ActivationDate, and DeactivationDate.
		/// WARNING: overriding Object.Equals will cause ArrayLists
		/// </summary>
		public new bool Equals(object o)
		{
			RecurringEvent recurringEvent = o as RecurringEvent;
			if (recurringEvent == null)
				return false; // not a compatible type 
			
			// checks for core property mismatches
			if ((Type != recurringEvent.Type) ||
					(Reversibility != recurringEvent.Reversibility) ||
					(AllowMultipleInstances != recurringEvent.AllowMultipleInstances) ||
          (BillingGroupSupport != recurringEvent.BillingGroupSupport) ||
          (HasBillgroupConstraints != recurringEvent.HasBillgroupConstraints) ||
					(DisplayName != recurringEvent.DisplayName) ||
					(ClassName != recurringEvent.ClassName) ||
					(ConfigFileName != recurringEvent.ConfigFileName) ||
					(ExtensionName != recurringEvent.ExtensionName) ||
					(Description != recurringEvent.Description))
				return false;

			// checks for schedule mismatches
			if (!SchedulesMatch(recurringEvent))
				return false;

			// checks for dependency mismatches
			if (!DependenciesMatch(recurringEvent))
				return false;

      // checks for machine rule mismatches
      if (!MachineRulesMatch(recurringEvent))
        return false;

			return true;
		}

		public override string ToString()
		{
			return mName;
		}

		private bool SchedulesMatch(RecurringEvent recurringEvent)
		{
      Debug.Assert(recurringEvent.mSchedules != null, "schedules are null", "Schedule can not be null for recurring event {0}", recurringEvent.Name);
      Debug.Assert(recurringEvent.Schedules != null);

			if (Schedules.Count != recurringEvent.Schedules.Count)
				return false;

			foreach (RecurringEventSchedule schedule2 in recurringEvent.Schedules)
			{
				bool found = false;
				foreach (RecurringEventSchedule schedule in Schedules)
				{
					if (schedule.Equals(schedule2))
					{
						found = true;
						break;
					}
				}

				if (!found)
					return false;
			}
			return true;
		}

		private bool DependenciesMatch(RecurringEvent recurringEvent)
		{
			Debug.Assert(recurringEvent.Dependencies != null);

			if (Dependencies.Count != recurringEvent.Dependencies.Count)
				return false;

			foreach (RecurringEvent dep2 in recurringEvent.Dependencies)
			{
				bool found = false;
				foreach (RecurringEvent dep in Dependencies)
				{
					if (dep2.Name == dep.Name)
					{
						found = true;
						break;
					}
				}
				if (!found)
					return false;
			}
			return true;
		}


    private bool MachineRulesMatch(RecurringEvent recurringEvent)
    {
      Debug.Assert(recurringEvent.MachineRules != null);

      if (MachineRules.Count != recurringEvent.MachineRules.Count)
        return false;

      foreach (MachineRule machineRule in recurringEvent.MachineRules)
      {
        bool found = false;
        foreach (MachineRule machineRule2 in MachineRules)
        {
          if (machineRule2 == machineRule)
          {
            found = true;
            break;
          }
        }
        if (!found)
          return false;
      }

      return true;
    }

		/// <summary>
		/// A unique list of all dependencies (both explicit and implicit)
		/// </summary>
		internal Hashtable FullDependencies
		{
			get
			{
				// gets the implicit dependencies
				Hashtable fullDeps = new Hashtable();
				fullDeps = ImplicitDependencies;

				// adds in any remaining explicit dependencies
				foreach (RecurringEvent dep in mDependencies)
					fullDeps.Add(dep.Name, new RecurringEventDependency(dep, 1)); // explicit deps are at a distance of 1

				return fullDeps;
			}
		}

		/// <summary>
		/// A unique list of dependencies implied by the explicit dependencies (but not including them)
		/// </summary>
		internal Hashtable ImplicitDependencies
		{
			get
			{
				Hashtable implicitDeps = new Hashtable();
				
				foreach (RecurringEvent dep in mDependencies)
					// dep is at distance 1
					// dep's immediate children are at distance 2
					GenerateImplicitDependencies(dep, implicitDeps, 2);

				return implicitDeps;
			}
		}

		bool mDependsOnAll = false;
		internal bool DependsOnAll
		{
			get
			{ return mDependsOnAll; }
			set
			{ mDependsOnAll = value; }
		}

		/// <summary>
		/// Adds a dependency to the recurring event while validating several conditions
		/// </summary>
		internal void AddDependency(RecurringEvent depEvent)
		{
			Debug.Assert(depEvent != null);

			// enforces that a scheduled event cannot depend on an end-of-period event
			if ((mType == RecurringEventType.Scheduled) &&
					((depEvent.Type == RecurringEventType.EndOfPeriod) ||
					 (depEvent.Type == RecurringEventType.Checkpoint)))
				throw new IncompatibleEventTypeDependencyException(mName, depEvent.Name);
			
			// validates that the usage cycle types are compatible
			if ((mType != RecurringEventType.Root) &&
					((depEvent.Type == RecurringEventType.EndOfPeriod) ||
					 (depEvent.Type == RecurringEventType.Checkpoint)))
			{
				Debug.Assert(mSchedules.Count == 1);
				Debug.Assert(depEvent.Schedules.Count == 1);
				
				if (!((RecurringEventSchedule) mSchedules[0]).Equals((RecurringEventSchedule) depEvent.Schedules[0]))
					throw new IncompatibleUsageCycleTypeDependencyException(mName,
																																	(RecurringEventSchedule) mSchedules[0],
																																	depEvent.Name,
																																	(RecurringEventSchedule) depEvent.Schedules[0]);
			}
			
			if (!mDependencies.Contains(depEvent))
				mDependencies.Add(depEvent);
			else
				// doesn't add the dependency since it already exists
				// caused from using 'all' with other explicit dependencies given
				mLogger.LogWarning("Removing unnecessary dependency '{0}' from event '{1}'",
													 depEvent.Name, mName);
		}

    /// <summary>
    /// Adds a dependency to the recurring event while validating several conditions
    /// </summary>
    internal void AddMachineRule(MachineRule rule)
    {
      if (!mMachineRules.Contains(rule))
        mMachineRules.Add(rule);
      else
        // doesn't add the rule since it already exists
        mLogger.LogWarning("Removing unnecessary machine rule '{0}' from event '{1}'",
                            rule, mName);
    }

		/// <summary>
		/// Prunes unnecessary explicit dependencies from the event.
		/// A dependency is considered unnecessary if it is explicitly specified
		/// and also implicitly derived.
		/// </summary>
		internal void PruneDependencies()
		{
			Hashtable implicitDeps = ImplicitDependencies;
			
			// iterates through the explicit dependencies
			// and looks for events that are already implied
			ArrayList removeExplicitDeps = new ArrayList();
			foreach (RecurringEvent explicitDep in mDependencies)
				if (implicitDeps.Contains(explicitDep.Name))
					removeExplicitDeps.Add(explicitDep);
			
			// removes the duplicates
			foreach (RecurringEvent explicitDep in removeExplicitDeps)
			{
				// warn if there are unnecessary dependencies
				// except if they were added by us as part of 'all' expansion
				if (!mDependsOnAll)
					mLogger.LogWarning("Removing unnecessary dependency '{0}' from event '{1}'",
														 explicitDep.Name, mName);
				mDependencies.Remove(explicitDep);
			}
		}

		/// <summary>
		/// Removes all explicit dependencies for an event
		/// </summary>
		internal void ClearDependencies()
		{
			mDependencies.Clear();
		}

		/// <summary>
		/// Creates a new recurring event object based on a row from t_recevent
		/// </summary>
		internal static RecurringEvent CreateEventFromRow(IMTDataReader reader)
		{
			RecurringEvent recurringEvent = new RecurringEvent();

			recurringEvent.EventID = reader.GetInt32("id_event");
			recurringEvent.Name = reader.GetString("tx_name");
			recurringEvent.DisplayName = reader.GetString("tx_display_name");
			recurringEvent.Type = (RecurringEventType) Enum.Parse(typeof(RecurringEventType), reader.GetString("tx_type"));
			recurringEvent.Reversibility = (ReverseMode) Enum.Parse(typeof(ReverseMode), reader.GetString("tx_reverse_mode"));
			recurringEvent.AllowMultipleInstances = reader.GetBoolean("b_multiinstance");
      recurringEvent.BillingGroupSupport = 
        (BillingGroupSupportType) Enum.Parse(typeof(BillingGroupSupportType), 
                                             reader.GetString("tx_billgroup_support"));
      if (!reader.IsDBNull("b_has_billgroup_constraints")) 
      {
        recurringEvent.HasBillgroupConstraints = reader.GetBoolean("b_has_billgroup_constraints");
      }
      recurringEvent.ActivationDate = reader.GetDateTime("dt_activated");
			
			// class name - assembly/type combo or ProgID for COM-based adapters.
			//              this value is null for checkpoints
			string className;
			if (reader.IsDBNull("tx_class_name"))
				className = null;
			else
				className = reader.GetString("tx_class_name");
			recurringEvent.ClassName = className;

			// extension name - not used for legacy adatpers
			string extensionName;
			if (reader.IsDBNull("tx_extension_name"))
				extensionName = null;
			else
				extensionName = reader.GetString("tx_extension_name");
			recurringEvent.ExtensionName = extensionName;
			
			// config file - optional
			string configFile;
			if (reader.IsDBNull("tx_config_file"))
				configFile = null;
			else
				configFile = reader.GetString("tx_config_file");
			recurringEvent.ConfigFileName = configFile;
			
			// description - optional
			string description;
			if (reader.IsDBNull("tx_desc"))
				description = null;
			else
				description = reader.GetString("tx_desc");
			recurringEvent.Description = description;

			return recurringEvent;
		}

		/// <summary>
		/// Generates implicit dependencies of the event passed in.
		/// The distance param specifies how far away the recurringEvent's immediate
		/// dependencies are from the original event.
		/// </summary>
		private void GenerateImplicitDependencies(RecurringEvent recurringEvent,
																							Hashtable implicitDeps,
																							int distance)
		{
			foreach (RecurringEvent dep in recurringEvent.Dependencies)
			{
				// NOTE: it is possible to have multiple paths to the same implicit dependency
				// this is okay so far because nothing looks at distance beyond == 0, == 1, > 1
				// style comparisons
				implicitDeps[dep.Name] = new RecurringEventDependency(dep, distance);

				GenerateImplicitDependencies(dep, implicitDeps, distance + 1);
			}
		}

		private int mEventID;
		private int mPreviousEventID;
		private RecurringEventType mType;
		private string mExtensionName;
		private string mName;
		private string mDisplayName;
		private string mClassName;
		private string mConfigFileName;
		private string mDescription;
		private ReverseMode mReversibility;
		private bool mAllowMulipleInstances;
    private BillingGroupSupportType mBillingGroupSupport;
    private bool mHasBillgroupConstraints;
		private ArrayList mDependencies;
    private ArrayList mMachineRules;
		private ArrayList mSchedules;
		private DateTime mActivationDate;

		private Logger mLogger;
	}

	internal struct RecurringEventDependency
	{
		public RecurringEventDependency(RecurringEvent recurringEvent, int distance)
		{
			Event = recurringEvent;
			Distance = distance;
		}

		public RecurringEvent Event;
		public int Distance;
	}


	/// <summary>
	/// Description of a recurring event cycle
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("3c77002b-a05a-48ee-876f-24fdd15bddc5")]
	public class RecurringEventSchedule : IRecurringEventSchedule
	{
		/// <summary>
		/// Schedule's type
		/// </summary>
		public RecurringEventScheduleType Type
		{
			get
			{ return mType; }
			set
			{ mType = value; }
		}

		/// <summary>
		/// Cycle type.  Event will be run at the end of any cycle of this type
		/// </summary>
		public CycleType CycleType
		{
			get
			{ return mCycleType; }
			set
			{ mCycleType = value; }
		}

		/// <summary>
		/// Cycle ID.  Event will be run at at the end of a specific cycle
		/// </summary>
		public int CycleID
		{
			get
			{ return mCycleID; }
			set
			{ mCycleID = value; }
		}

		/// <summary>
		/// The freqeuncy, in minutes, that the event will be run at
		/// </summary>
		public BaseRecurrencePattern Pattern
		{
			get
			{ return mPattern; }
			set
			{ mPattern = value; }
		}

		/// <summary>
		/// Convert schedule to string
		/// </summary>
		public override string ToString()
		{
			switch (mType)
			{
			case RecurringEventScheduleType.CycleType:
				return "CycleType=" + mCycleType;
			case RecurringEventScheduleType.Cycle:
				return "CycleID=" + mCycleID;
			case RecurringEventScheduleType.RecurrencePattern:
				return "RecurrencePattern=" + Pattern.ToString();
			default:
				throw new UsageServerException("Unknown schedule type!");
			}
		}

		/// <summary>
		/// Return true if both schedules are equal.
		/// </summary>
		public override bool Equals(object other)
		{
			if (!(other is RecurringEventSchedule))
				return false;

			RecurringEventSchedule otherSchedule = (RecurringEventSchedule) other;
			if (Type != otherSchedule.Type)
				return false;

			switch (mType)
			{
			case RecurringEventScheduleType.CycleType:
				return mCycleType == otherSchedule.CycleType;
			case RecurringEventScheduleType.Cycle:
				return mCycleID == otherSchedule.CycleID;
			case RecurringEventScheduleType.RecurrencePattern:
        // Why not Equals? Equals would check for Override date/IsPaused flag and we don't care about them.
				return mPattern.PatternEquals(otherSchedule.Pattern);
			default:
				throw new UsageServerException("Unknown schedule type!");
			}
		}

		/// <summary>
		/// Generate a decent hash code.
		/// </summary>
		public override int GetHashCode()
		{
			return mCycleID + ((int) Type * 10000) + (int) mCycleType;
		}

		private RecurringEventScheduleType mType;
		private int mCycleID;
		private CycleType mCycleType;
		private BaseRecurrencePattern mPattern;

  }


	/// <summary>
	/// A collection-based filter for describing multiple event instances
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("615fedb4-18ab-4797-acf4-2c742b0aecef")]
	public class RecurringEventInstanceFilter : IRecurringEventInstanceFilter 
	{
		public RecurringEventInstanceFilter()
		{
			mInstances = new ArrayList();
			mStatus = new ArrayList();
			mInstanceCriteria = new ArrayList();
			ClearCriteria();
		}

		public void AddInstanceCriteria(int instanceID)
		{
			mInstanceCriteria.Add(instanceID);
			mApplied = false;
		}

		public ArrayList GetInstanceCriteria()
		{
			return mInstanceCriteria;
		}

		public void AddStatusCriteria(RecurringEventInstanceStatus status)
		{
			mStatus.Add(status);
			mApplied = false;
			mOnlyInstanceIDs = false;
		}

		public ArrayList GetStatusCriteria()
		{
			return mStatus;
		}

		public void AddEventTypeCriteria(RecurringEventType type)
		{
			// if this method is never called, all event types are implicitly included.
			// once it is called, only those types that have been explicitly
			// added will be used.
			if (!mEventTypeSet)
			{
				mIncludeScheduled = false;
				mIncludeEOP = false;
				mIncludeCheckpoint = false;
				mEventTypeSet = true;
			}

			switch (type)
			{
			case RecurringEventType.Scheduled:
				mIncludeScheduled = true;
				break;
			case RecurringEventType.EndOfPeriod:
				mIncludeEOP = true;
				break;
			case RecurringEventType.Checkpoint:
				mIncludeCheckpoint = true;
				break;
			default:
				throw new
					UsageServerException(String.Format("Illegal event type criteria: {0}!", type.ToString())); 
			}

			mApplied = false;
			mOnlyInstanceIDs = false;
		}

		public string EventName 
		{
			get
			{ return mEventName; }
			set
			{ 
				mEventName = value; 
				mApplied = false;
				mOnlyInstanceIDs = false;
			}
		}

    public string BillingGroupSupport
    {
      get
      { return mBillingGroupSupport; }
      set
      { 
        if (((string)value).ToUpper() != "ACCOUNT" ||
            ((string)value).ToUpper() != "INTERVAL" || 
            ((string)value).ToUpper() != "BILLINGGROUP")
        {
          throw new
            UsageServerException
              (String.Format("Illegal billing group support criteria: {0}!", 
                              mBillingGroupSupport.ToString())); 
        }

        if (mBillingGroupID != 0)
        {
          throw new 
            UsageServerException("BillingGroupSupport filter criteria cannot be used in " +
                                 "conjunction with BillingGroupID criteria!");
        }

        if ((mStartDate != DateTime.MinValue) || (mEndDate != DateTime.MinValue))
        {
          throw new 
            UsageServerException("BillingGroupSupport filter criteria cannot be used in " +
                                 "conjunction with StartDate/EndDate criteria!");
        }

        mBillingGroupSupport = value; 
        mApplied = false;
        mOnlyInstanceIDs = false;
      }
    }

		public int UsageIntervalID 
		{
			get
			{ return mIntervalID; }
			set
			{ 
				if ((mStartDate != DateTime.MinValue) || (mEndDate != DateTime.MinValue))
					throw new 
						UsageServerException("UsageIntervalID filter criteria cannot be used in " +
																 "conjunction with StartDate/EndDate criteria!");
				mIntervalID = value;
				mApplied = false;
				mOnlyInstanceIDs = false;
			}
		}

    public int BillingGroupID 
    {
      get
      { return mBillingGroupID; }
      set
      { 
        if ((mStartDate != DateTime.MinValue) || (mEndDate != DateTime.MinValue))
        {
          throw new 
            UsageServerException("BillingGroupID filter criteria cannot be used in " +
                                 "conjunction with StartDate/EndDate criteria!");
        }

        if (mBillingGroupSupport != null)
        {
          throw new 
            UsageServerException("BillingGroupID filter criteria cannot be used in " +
                                 "conjunction with BillingGroupSupport criteria!");
        }

        mBillingGroupID = value;
        mApplied = false;
        mOnlyInstanceIDs = false;
      }
    }
		
		public DateTime StartDate
		{
			get
			{ return mStartDate; }
			set
			{ 
				if (mIntervalID != 0 && mBillingGroupID != 0  && mBillingGroupSupport != null)
					throw new 
						UsageServerException("StartDate/EndDate filter criteria cannot be used in " +
																 "conjunction with UsageIntervalID/BillingGroupID/BillingGroupSupport criteria!");
				mStartDate = value;
				mApplied = false;
				mOnlyInstanceIDs = false;
			}
		}

		public DateTime EndDate
		{
			get
			{ return mEndDate; }
			set
			{ 
				if (mIntervalID != 0 && mBillingGroupID != 0 && mBillingGroupSupport != null)
					throw new 
						UsageServerException("StartDate/EndDate filter criteria cannot be used in " +
																 "conjunction with UsageIntervalID/BillingGroupID/BillingGroupSupport criteria!");
				mEndDate = value; 
				mApplied = false;
				mOnlyInstanceIDs = false;
			}
		}

		public int Apply()
		{
			// if only instance IDs are given as criteria then going to the 
			// database is unnecesary - just adds them to the result collection
			if (mOnlyInstanceIDs)
			{
				mInstances.AddRange(mInstanceCriteria);
				return mInstanceCriteria.Count;
			}

			// adds in the scheduled instances
			int count = 0;
			if (mIncludeScheduled) 
				count = AddInstances(CreateScheduledQuery(false));

			// adds in the end-of-period and checkpoint instances
			if (mIncludeEOP || mIncludeCheckpoint)
      {
				count += AddInstances(CreateEndOfPeriodQuery(false, mIncludeEOP, mIncludeCheckpoint, false));
      }

			mApplied = true;

			return count;
		}

		public bool Applied
		{
			get
			{
				return mApplied;
			}
		}

		public string ToCSVString()
		{
			StringBuilder list = new StringBuilder();
			bool firstTime = true;

			foreach (int instanceID in mInstances)
			{
				if (!firstTime)
					list.Append(",");
				else
					firstTime = false;

				list.Append(instanceID);
			}

			return list.ToString();
		}

		public Rowset.IMTSQLRowset GetScheduledRowset()
		{
			Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
			rowset.Init(@"Queries\UsageServer");
			rowset.SetQueryString(CreateScheduledQuery(true));
			rowset.Execute();

			return rowset;
		}

		public Rowset.IMTSQLRowset GetEndOfPeriodRowset(bool includeEOP,
																										bool includeCheckpoint)
		{
			Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
			rowset.Init(@"Queries\UsageServer");
			rowset.SetQueryString(CreateEndOfPeriodQuery(true, includeEOP, includeCheckpoint, false));
			rowset.Execute();

			return rowset;
		}

    public Rowset.IMTSQLRowset GetEndOfPeriodRowset(bool includeEOP,
                                                    bool includeCheckpoint,
                                                    bool includeRoot)
    {
      Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
      rowset.Init(@"Queries\UsageServer");
      rowset.SetQueryString(CreateEndOfPeriodQuery(true, includeEOP, includeCheckpoint, includeRoot));
      rowset.Execute();

      return rowset;
    }

		public int Count
		{
			get
			{ 
				return mInstances.Count; 
			}
		}

		public void ClearCriteria()
		{
			mInstanceCriteria.Clear();
			mStatus.Clear();

			mEventName = null;
      mBillingGroupSupport = null;
			mIntervalID = 0;
      mBillingGroupID = 0;
			mStartDate = DateTime.MinValue;
			mEndDate = DateTime.MinValue;

			mEventTypeSet = false;
			mIncludeScheduled = true;
			mIncludeEOP = true;
			mIncludeCheckpoint = false;

			mApplied = false;
			mOnlyInstanceIDs = true;
		}

		public void ClearResults()
		{
			mInstances.Clear();
			mApplied = false;
		}

		public IEnumerator GetEnumerator()
		{
			return new Enumerator(mInstances);
		}

		private int AddInstances(string query)
		{
			int count = 0;
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTStatement stmt = conn.CreateStatement(query))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            count++;
                            int instanceID = reader.GetInt32("id_instance");
                            mInstances.Add(instanceID);
                        }
                    }
                }
            }

			return count;
		}

    private void PopulateTmpBillingGroupStatus()
    {
      int status = 0;

      // mLogger.LogDebug("Populating temporary billing group status table...");

      using(IMTConnection conn = 
              ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
          using (IMTCallableStatement stmt =
            conn.CreateCallableStatement("CreatePopTmpBillGroupStatus"))
          {

              stmt.AddParam("tx_tableName", MTParameterType.String, RecurringEventInstanceFilter.tmpBillingGroupStatusTableName);
              if (mIntervalID != 0)
              {
                  stmt.AddParam("id_interval", MTParameterType.Integer, mIntervalID);
              }
              else
              {
                  stmt.AddParam("id_interval", MTParameterType.Integer, null);
              }
              stmt.AddOutputParam("status", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              status = (int)stmt.GetOutputValue("status");
          }

        switch(status) 
        {
          case 0: 
          {
            // mLogger.LogDebug
            //  ("Successfully populated temporary billing group status table...");
    
            break;
          }
          default: 
          {
            throw new UsageServerException
              (String.Format("Populating temporary billing group status " +
                             "table failed with an unknown error"), true);
          }
        }
      }
    }

		private string CreateScheduledQuery(bool extraInfo)
		{
			QueryAdapter.IMTQueryAdapter query = new QueryAdapter.MTQueryAdapter();
			query.Init(@"Queries\UsageServer");

			string queryTag;
			if (extraInfo)
				queryTag = "__GET_SCHEDULED_EVENT_INSTANCES_FOR_DISPLAY__";
			else
				queryTag = "__GET_SCHEDULED_EVENT_INSTANCES__";
			query.SetQueryTag(queryTag);

			// event name filter
			string nameFilter = "";
			if (mEventName != null)
				nameFilter = String.Format("	AND evt.tx_name = '{0}'", mEventName); 
			query.AddParam("%%NAME_FILTER%%", nameFilter, true);

			// instance filter
			string instanceFilter = GenerateInstanceFilter();
			query.AddParam("%%INSTANCE_FILTER%%", instanceFilter, true);

			// instance status filter
			string statusFilter = GenerateStatusFilter();
			query.AddParam("%%STATUS_FILTER%%", statusFilter, true);

			// usage interval filter
			string intervalFilter = "";
			if (mIntervalID != 0)
			{
				QueryAdapter.IMTQueryAdapter subQuery = new QueryAdapter.MTQueryAdapter();
				subQuery.Init(@"Queries\UsageServer");
				subQuery.SetQueryTag("__GET_SCHEDULED_EVENT_INSTANCES_INTERVAL_JOIN__");
				subQuery.AddParam("%%ID_INTERVAL%%", mIntervalID, false);
				intervalFilter = subQuery.GetQuery();
			}
			query.AddParam("%%INTERVAL_JOIN%%", intervalFilter, false);

			// start date filter
			string startDateFilter = "";
      if (mStartDate != DateTime.MinValue)
      {
        bool isOracle = query.IsOracle();
        // CR 15362 - 'Select Top 1' is invalid SQL for Oracle - use 'rownum' instead.
        if (isOracle)
        {
          startDateFilter =
          String.Format
            (" AND EXISTS(SELECT id_instance FROM t_recevent_run tr " +
             " WHERE tr.id_instance = inst.id_instance AND tr.dt_end >= {0} AND rownum = 1)",
             DBUtil.ToDBString(mStartDate));
        }
        else
        {
          startDateFilter =
            String.Format(" AND EXISTS(SELECT TOP 1 id_instance FROM t_recevent_run tr " +
                          " WHERE tr.id_instance = inst.id_instance AND tr.dt_end >= {0})",
                          DBUtil.ToDBString(mStartDate));
        }
      }
      query.AddParam("%%START_DATE_FILTER%%", startDateFilter, true);

			// end date filter
			string endDateFilter = "";
      if (mEndDate != DateTime.MinValue)
        endDateFilter = String.Format(" AND inst.dt_arg_end <= {0}",
          DBUtil.ToDBString(mEndDate));
			query.AddParam("%%END_DATE_FILTER%%", endDateFilter, true);

			return query.GetQuery();
		}

		private string CreateEndOfPeriodQuery(bool extraInfo, 
																					bool includeEOP,
																					bool includeCheckpoint,
                                          bool includeRoot)
		{
			QueryAdapter.IMTQueryAdapter query = new QueryAdapter.MTQueryAdapter();
			query.Init(@"Queries\UsageServer");
			
			string queryTag;
			if (extraInfo)
				queryTag = "__GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__";
			else
				queryTag = "__GET_EOP_EVENT_INSTANCES__";
			query.SetQueryTag(queryTag);

			// event type filter
			string typeFilter;
			if (includeEOP && includeCheckpoint && includeRoot)
				typeFilter = String.Format("'{0}', '{1}', '{2}'",
																	 RecurringEventType.EndOfPeriod.ToString(),
																	 RecurringEventType.Checkpoint.ToString(),
                                   RecurringEventType.Root.ToString());
      else if (includeEOP && includeCheckpoint)
        typeFilter = String.Format("'{0}', '{1}'",
                                    RecurringEventType.EndOfPeriod.ToString(),
                                    RecurringEventType.Checkpoint.ToString());
			else if (includeEOP)
				typeFilter = String.Format("'{0}'", RecurringEventType.EndOfPeriod.ToString());
			else if (includeCheckpoint)
				typeFilter = String.Format("'{0}'", RecurringEventType.Checkpoint.ToString());
			else
				throw new UsageServerException("No event type specified on recurring event instance filter!");
			query.AddParam("%%TYPE_FILTER%%", typeFilter, true);
			
			// event name filter
			string nameFilter = "";
			if (mEventName != null)
				nameFilter = String.Format("	AND evt.tx_name = '{0}'", mEventName); 
			query.AddParam("%%NAME_FILTER%%", nameFilter, true);

      // billing group support type filter
      string billingGroupSupportFilter = "";
      if (mBillingGroupSupport != null)
        billingGroupSupportFilter = 
          String.Format("	AND evt.tx_billgroup_support = '{0}'", mBillingGroupSupport); 
      query.AddParam("%%BILLING_GROUP_SUPPORT_FILTER%%", billingGroupSupportFilter, true);

			// instance filter
			string instanceFilter = GenerateInstanceFilter();
			query.AddParam("%%INSTANCE_FILTER%%", instanceFilter, true);

			// instance status filter
			string statusFilter = GenerateStatusFilter();
			query.AddParam("%%STATUS_FILTER%%", statusFilter, true);

			// usage interval filter
			string intervalFilter = "";
			if (mIntervalID != 0)
      {
				intervalFilter = " AND inst.id_arg_interval = " + mIntervalID;
      }
			query.AddParam("%%INTERVAL_FILTER%%", intervalFilter, false);

      if (queryTag.Equals("__GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__"))
      {
        PopulateTmpBillingGroupStatus();
        query.AddParam("%%TMP_BILLGROUP_TABLE%%", RecurringEventInstanceFilter.tmpBillingGroupStatusTableName, false);
      }

      // billing group filter
      string billingGroupFilter = "";
      if (mBillingGroupID != 0)
      {
         billingGroupFilter = 
           String.Format(" AND " +
                         // -- restricts the rows in t_billgroup to the specified billing group 
                         // " (bg.id_billgroup = {0} OR bg.id_billgroup IS NULL) AND " +
                         " ( " +
                         "   inst.id_arg_billgroup = {0} OR " +
                         "   inst.id_arg_billgroup IS NULL " + // OR " +
                         // "   ( " +
                         //      -- include the BillingGroup adapter from the root billing group 
                         //      -- into pull lists.  
                         // "     inst.id_arg_root_billgroup = bg.id_parent_billgroup AND " +
                         // "     evt.tx_billgroup_support = 'BillingGroup' AND " +
                         // "     inst.id_arg_root_billgroup = dbo.GetBillingGroupAncestor({0}) " +
                         // "   ) " +
                         " ) ", mBillingGroupID);
      }
      query.AddParam("%%BILLING_GROUP_FILTER%%", billingGroupFilter, true);

			// start date filter
			string startDateFilter = "";
			if (mStartDate != DateTime.MinValue)
				startDateFilter = String.Format(" AND ui.dt_start >= {0}", 
          DBUtil.ToDBString(mStartDate));
			query.AddParam("%%START_DATE_FILTER%%", startDateFilter, false);

			// end date filter
			string endDateFilter = "";
			if (mEndDate != DateTime.MinValue)
				endDateFilter = String.Format(" AND ui.dt_end <= {0}", 
          DBUtil.ToDBString(mEndDate));
			query.AddParam("%%END_DATE_FILTER%%", endDateFilter, false);

			return query.GetQuery();
		}

		private string GenerateInstanceFilter()
		{
			StringBuilder list = new StringBuilder();

			foreach (int instanceID in mInstanceCriteria)
			{
				if (list.Length > 0)
					list.Append(", ");
				list.Append(instanceID);
			}

			if (list.Length == 0)
				return "";

			return String.Format(" AND inst.id_instance IN ({0})", list);
		}

		private string GenerateStatusFilter()
		{
			StringBuilder statusList = new StringBuilder();

			foreach (RecurringEventInstanceStatus status in mStatus)
			{
				if (statusList.Length > 0)
					statusList.Append(", ");
				statusList.Append(String.Format("'{0}'", status.ToString()));
			}

			if (statusList.Length == 0)
				return "";

			return String.Format(" AND inst.tx_status IN ({0})", statusList);
		}


    #region Data
    private const string tmpBillingGroupStatusTableName = "tmp_BillingGroupStatus";
    #endregion

		// a simple reference-based enumerator
		private class Enumerator : IEnumerator 
		{
			public Enumerator(ArrayList instances)
			{
				mInstances = instances;
			}
			
			public bool MoveNext()
			{
				return (++index < mInstances.Count);
			}
			
			public object Current 
			{
				get
				{
					if (index == -1) 
						throw new InvalidOperationException("Use MoveNext before calling Current!");

					if (index > mInstances.Count)
						throw new InvalidOperationException("Index is out of range!");

					return mInstances[index];
				}
			}
			
      public void Reset()
			{
				index = -1;
			}
			
			private int index = -1;
			private ArrayList mInstances;
		}


		// criteria variables
		private ArrayList mInstanceCriteria;
		private string mEventName;
    private string mBillingGroupSupport;
		private ArrayList mStatus;
		private int mIntervalID;
    private int mBillingGroupID;
		private DateTime mStartDate;
		private DateTime mEndDate;

		private bool mEventTypeSet;
		private bool mIncludeScheduled;
		private bool mIncludeEOP;
		private bool mIncludeCheckpoint;
		
		private bool mApplied;
		private bool mOnlyInstanceIDs;

		private ArrayList mInstances;
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("b10644df-736f-4506-bfd4-9eda93e903dc")]
	public class RecurringEventRunFilter : IRecurringEventRunFilter 
	{
		public RecurringEventRunFilter()
		{
			ClearCriteria();
		}

		public void ClearCriteria()
		{
			mInstanceID = 0;
			mUseStatus = false;
			mUseAction = false;
			mBeforeDate = DateTime.MinValue;
		}

		public int InstanceID
		{
			get
			{ return mInstanceID; }
			set
			{ mInstanceID = value; }
		}

		public RecurringEventRunStatus Status
		{
			get
			{ return mStatus; }
			set
			{ 
				mUseStatus = true;
				mStatus = value; 
			}
		}

		public RecurringEventAction Action
		{
			get
			{ return mAction; }
			set
			{ 
				mUseAction = true;
				mAction = value; 
			}
		}

		public DateTime BeforeDate
		{
			get
			{ return mBeforeDate; }
			set
			{ mBeforeDate = value; }
		}

		public Rowset.IMTSQLRowset GetRowset()
		{
			Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
			rowset.Init(@"Queries\UsageServer");
			rowset.SetQueryTag("__GET_RECURRING_EVENT_RUNS__");

			// instance ID
			string whereClause = "";
			if (mInstanceID != 0)
			{
				whereClause += "WHERE ";
				whereClause += String.Format("run.id_instance = {0}", mInstanceID);
			}

			// status
			if (mUseStatus)
			{
				if (whereClause.Length == 0)
					whereClause += "WHERE ";
				else
					whereClause += " AND ";

				whereClause += String.Format("run.tx_status = '{0}'", mStatus.ToString());
			}

			if (mUseAction)
			{
				if (whereClause.Length == 0)
					whereClause += "WHERE ";
				else
					whereClause += " AND ";

				whereClause += String.Format("run.tx_type = '{0}'", mAction.ToString());
			}

			if (mBeforeDate != DateTime.MinValue)
			{
				if (whereClause.Length == 0)
					whereClause += "WHERE ";
				else
					whereClause += " AND ";

				whereClause += String.Format("run.dt_end < {0}", DBUtil.ToDBString(mBeforeDate));
			}

			rowset.AddParam("%%OPTIONAL_WHERE_CLAUSE%%", whereClause, true);
			rowset.Execute();

			return rowset;
		}

		int mInstanceID;

		bool mUseStatus;
		RecurringEventRunStatus mStatus;

		bool mUseAction;
		RecurringEventAction mAction;

		private DateTime mBeforeDate;
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("0d1dadbf-3f58-4933-bcbc-fed6da7c4675")]
	public class RecurringEventFilter : IRecurringEventFilter 
	{
		public RecurringEventFilter()
		{
			mTypes = new ArrayList();
			mInstances = new ArrayList();
			ClearCriteria();
		}

		public void ClearCriteria()
		{
			mEventID = 0;
			mName = null;
			mTypes.Clear();
			mInstances.Clear();
		}

		public int EventID
		{
			get
			{ return mEventID; }
			set
			{ mEventID = value; }
		}

		public string Name
		{
			get
			{ return mName; }
			set
			{ mName = value; }
		}

		public void AddInstanceID(int instanceID)
		{
			mInstances.Add(instanceID);
		}

		public void AddTypeCriteria(RecurringEventType eventType)
		{
			mTypes.Add(eventType);
		}

		public IEnumerator GetEnumerator()
		{
			ArrayList events = new ArrayList();

			string query = CreateQuery();
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTStatement stmt = conn.CreateStatement(query))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                            events.Add(ReadEventFromDB(reader));
                    }
                }
            }

			return new Enumerator(events);
		}

		private string CreateQuery()
		{
			QueryAdapter.IMTQueryAdapter query = new QueryAdapter.MTQueryAdapter();
			query.Init(@"Queries\UsageServer");
			query.SetQueryTag("__GET_RECURRING_EVENT_INFO__");
			string filter = "";

			// event name filter
			if (mName != null)
				filter += String.Format("	AND evt.tx_name = '{0}'", DBUtil.ToDBString(mName)); 

			// event ID filter
			if (mEventID != 0)
				filter += String.Format("	AND evt.id_event = {0}", mEventID); 
			
			// event type filter
			filter += GenerateTypeFilter();

			// instance ID filter
			if (mInstances.Count > 0)
			{
				filter += GenerateInstanceFilter();
				query.AddParam("%%INSTANCE_JOIN%%", "INNER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event", false);
			}
			else
				query.AddParam("%%INSTANCE_JOIN%%", "", false);
				

			query.AddParam("%%FILTER%%", filter, true);

			return query.GetQuery();
		}

		private string GenerateTypeFilter()
		{
			StringBuilder typeList = new StringBuilder();

			foreach (RecurringEventType eventType in mTypes)
			{
				if (typeList.Length > 0)
					typeList.Append(", ");
				typeList.Append(String.Format("'{0}'", eventType.ToString()));
			}

			if (typeList.Length == 0)
				return "";

			return String.Format(" AND evt.tx_type IN ({0})", typeList);
		}

		private string GenerateInstanceFilter()
		{
			StringBuilder instanceList = new StringBuilder();

			foreach (int instanceID in mInstances)
			{
				if (instanceList.Length > 0)
					instanceList.Append(", ");
				instanceList.Append(String.Format("{0}", instanceID));
			}

			if (instanceList.Length == 0)
				return "";

			return String.Format(" AND inst.id_instance IN ({0})", instanceList);
		}

		private IRecurringEvent ReadEventFromDB(IMTDataReader reader)
		{
			RecurringEvent recurringEvent = new RecurringEvent();
			
			recurringEvent.EventID = reader.GetInt32("id_event");
			recurringEvent.Name = reader.GetString("tx_name");

			string rawEventType = reader.GetString("tx_type");
			recurringEvent.Type = (RecurringEventType) Enum.Parse(typeof(RecurringEventType), rawEventType);
			
			string rawReversibility = reader.GetString("tx_reverse_mode");
			recurringEvent.Reversibility = 
				(ReverseMode) Enum.Parse(typeof(ReverseMode), rawReversibility);
			
			recurringEvent.AllowMultipleInstances = reader.GetBoolean("b_multiinstance");
			
			// omitted if the event is a checkpoint or root
			if (!reader.IsDBNull("tx_class_name"))
				recurringEvent.ClassName = reader.GetString("tx_class_name");
			
			// extension name - not used for legacy adatpers
			if (!reader.IsDBNull("tx_extension_name"))
				recurringEvent.ExtensionName = reader.GetString("tx_extension_name");
			
			// config file - optional
			if (!reader.IsDBNull("tx_config_file"))
				recurringEvent.ConfigFileName = reader.GetString("tx_config_file");
			
			// TODO: is this optional?
			recurringEvent.DisplayName = reader.GetString("tx_display_name");
			
			// description - optional
			if (!reader.IsDBNull("tx_desc"))
				recurringEvent.Description = reader.GetString("tx_desc");

			return recurringEvent;
		}

		// a simple reference-based enumerator
		private class Enumerator : IEnumerator 
		{
			public Enumerator(ArrayList events)
			{
				mEvents = events;
			}
			
			public bool MoveNext()
			{
				return (++index < mEvents.Count);
			}
			
			public object Current 
			{
				get
				{
					if (index == -1) 
						throw new InvalidOperationException("Use MoveNext before calling Current!");

					if (index > mEvents.Count)
						throw new InvalidOperationException("Index is out of range!");

					return mEvents[index];
				}
			}
			
      public void Reset()
			{
				index = -1;
			}
			
			private int index = -1;
			private ArrayList mEvents;
		}


		int mEventID;
		string mName;

		ArrayList mTypes;
		ArrayList mInstances;
	}

  public class ProcessingConfig
  {
    public int MaximumNumberOfEventsToProcessConcurrently { get; set; }
    public string MachineIdentifierToUse { get; set; }
    public bool OnlyRunAdaptersExplicitlyAssignedToThisMachine { get; set; }
    public HashSet<string> MachineRolesToConsiderForProcessing { get; set; }
  }

  public class ProcessingConfigManager
  {
    public static ProcessingConfig LoadFromFile()
    {
      Logger logger = new Logger("[UsageServer]");

      ProcessingConfig newProcessingConfiguration = new ProcessingConfig();
      newProcessingConfiguration.OnlyRunAdaptersExplicitlyAssignedToThisMachine = false;
      newProcessingConfiguration.MachineRolesToConsiderForProcessing = new HashSet<string>();

      try
      {
        MTXmlDocument doc = new MTXmlDocument();
        doc.LoadConfigFile(UsageServerCommon.UsageServerConfigFile);

        try
        {
          newProcessingConfiguration.OnlyRunAdaptersExplicitlyAssignedToThisMachine = doc.GetNodeValueAsBool("/xmlconfig/Service/OnlyRunAdaptersExplicitlyAssignedToThisMachine");
        }
        catch (Exception)
        {
          logger.LogInfo("OnlyRunAdaptersExplicitlyAssignedToThisMachine not specified in config; using default of {0}",
                          newProcessingConfiguration.OnlyRunAdaptersExplicitlyAssignedToThisMachine);
        }

        //<AdditionalMachineRolesToProcess>
        //  <MachineRole>Primary BillingServer</MachineRole>
        //  <MachineRole>Exporting Server</MachineRole>
        //</AdditionalMachineRolesToProcess>
        try
        {
          foreach(System.Xml.XmlNode node in doc.SelectNodes("/xmlconfig/Service/AdditionalMachineRolesToProcess/MachineRole"))
          {
            newProcessingConfiguration.MachineRolesToConsiderForProcessing.Add(node.InnerText);
          }
        }
        catch(Exception ex)
        {
          throw new Exception(string.Format("Unable to read AdditionalMachineRolesToProcess tags from Service tag:{0}", ex.Message), ex);
        }


        newProcessingConfiguration.MaximumNumberOfEventsToProcessConcurrently = 1;
        //<MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine>3</MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine>
        try
        {
          newProcessingConfiguration.MaximumNumberOfEventsToProcessConcurrently = doc.GetNodeValueAsInt("/xmlconfig/Service/MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine");
        }
        catch (Exception)
        {
          logger.LogDebug(string.Format(
              "MaximumNumberOfAdaptersToRunConcurrentlyOnThisMachine not specified in config; using default of {0}",
              newProcessingConfiguration.MaximumNumberOfEventsToProcessConcurrently));
        }
      }
      catch (Exception ex)
      {
          string msg = string.Format("Unable to load processing configuration from Service tag in file {1}:{0}", ex.Message, "usageserver.xml");
          logger.LogError(msg);
          throw new Exception(msg, ex);
      }


      return newProcessingConfiguration;
    }
  }

  /// <summary>
  /// Simple class to store the result totals from worker tasks
  /// Current API and logging return/log these various totals,
  /// requiring them to be kept and returned
  /// </summary>
  public class WorkResults
  {
    #region Data Properties
    public int ExecutionSuccesses { get; set; }
    public int ExecutionFailures { get; set; }
    public int ReversalSuccesses { get; set; }
    public int ReversalFailures { get; set; }
    #endregion

    #region Read Only Summary Properties
    public int Executions
    {
      get { return ExecutionSuccesses + ExecutionFailures; }
    }

    public int Reversals
    {
      get { return ReversalSuccesses + ReversalFailures; }
    }

    public int Successes
    {
      get { return ExecutionSuccesses + ReversalSuccesses; }
    }

    public int Failures
    {
      get { return ExecutionFailures + ReversalFailures; }
    }
    #endregion

    public WorkResults()
    {
      ExecutionSuccesses = 0;
      ExecutionFailures = 0;
      ReversalSuccesses = 0;
      ReversalFailures = 0;
    }

    public WorkResults(int executionSuccesses, int executionFailures, int reversalSuccesses, int reversalFailures)
    {
      ExecutionSuccesses = executionSuccesses;
      ExecutionFailures = executionFailures;
      ReversalSuccesses = reversalSuccesses;
      ReversalFailures = reversalFailures;
    }

    public static WorkResults operator +(WorkResults c1, WorkResults c2)
    {
      return new WorkResults(c1.ExecutionSuccesses + c2.ExecutionSuccesses,
                             c1.ExecutionFailures + c2.ExecutionFailures,
                             c1.ReversalSuccesses + c2.ReversalSuccesses,
                             c1.ReversalFailures + c2.ReversalFailures);
    }

    public override string ToString()
    {
      return string.Format("{0} Successes, {1} Failures: (Details: {2} Executions with {3} Failures, {4} Reversals with {5} Failures)",
        this.Successes,
        this.Failures,
        this.Executions, this.ExecutionFailures,
        this.Reversals, this.ReversalFailures);
    }

    /// <summary>
    /// Helper method to record a failure (avoids putting the same if code in the caller)
    /// </summary>
    /// <param name="recurringEventAction"></param>
    public void RecordFailure(RecurringEventAction recurringEventAction)
    {
      if (recurringEventAction == RecurringEventAction.Execute)
        ExecutionFailures++;
      else
        ReversalFailures++;
    }

    /// <summary>
    /// Helper method to record a success (avoids putting the same if code in the caller)
    /// </summary>
    /// <param name="recurringEventAction"></param>
    public void RecordSuccess(RecurringEventAction recurringEventAction)
    {
      if (recurringEventAction == RecurringEventAction.Execute)
        ExecutionSuccesses++;
      else
        ReversalSuccesses++;
    }
  }

  /// <summary>
  /// Unfortunately the client API has a distinct call to process sessions that
  /// needs to return when processing is complete for the moment (all that could
  /// be processed has been processed). While the service/server could be
  /// re-implemented to not use a call that returns only when processing is
  /// complete, the command line usm.exe and smoketests would rely on the existing
  /// functionality/behavior. For this reason, this class is used to determine
  /// all the workers have gone idle.
  /// Note also that because the work list changes only after an execution is
  /// complete and because the Determine*Events stored procedures does not filter
  /// existing items, an idle worker is used to refresh the work queue when 
  /// needed instead of another process dedicated to this task in a more
  /// traditional producer/consumer pattern.
  /// </summary>
  public class WorkerIdleCoordination
  {
    private readonly object mIdlelocker = new object();
    private int mIdleCountIndicatingWeAreDone = 0;
    private int mIdleCount = 0;
    private bool mShutdown = false;
    private Logger mLogger;

    private WorkerIdleCoordination()
    {
      mLogger = new Logger("[UsageServer]");
    }

    public WorkerIdleCoordination(int totalWorkerCount): this()
    {
      Initialize(totalWorkerCount);
    }

    private void Initialize(int totalWorkerCount)
    {
      mIdleCount = 0;
      mIdleCountIndicatingWeAreDone = totalWorkerCount;
      mShutdown = false;
    }

    public bool ShuttingDown { get { return mShutdown;}}

    
    /// <summary>
    /// Indicate that this task is idle (up the idle count)
    /// If the count equals the total count of tasks, the
    /// tasks are signaled to shutdown
    /// </summary>
    public void SignalTaskIsIdle()
    {
      lock (mIdlelocker)
      {
        mIdleCount++;
        Console.WriteLine("WorkerIdleCoordination: Task [{0}] SignalTaskIsIdle (idle count is now {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] SignalTaskIsIdle (idle count is now {1})", Task.CurrentId, mIdleCount);
        if (mIdleCount == mIdleCountIndicatingWeAreDone)
          SignalTasksToShutdown();
      }
    }

    /// <summary>
    /// Indicate that the calling task is no longer idle.
    /// Must be called after indicating the task is idle
    /// after waiting and the thread is returning to work.
    /// </summary>
    /// <returns>Value indicating if the caller can/should
    /// return to work. False indicates that the caller
    /// should shut down.</returns>
    public bool SignalTaskIsNotIdle()
    {
      bool shouldProceedWithWork = true;
      lock (mIdlelocker)
      {
        if (mShutdown)
          shouldProceedWithWork = false;
        mIdleCount--;
        Console.WriteLine("WorkerIdleCoordination: Task [{0}] SignalTaskIs NOT Idle (idle count is now {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] SignalTaskIs NOT Idle (idle count is now {1})", Task.CurrentId, mIdleCount);
      }
      return shouldProceedWithWork;
    }

    /// <summary>
    /// Signals that there may be additional work available
    /// </summary>
    public void SignalThereMightBeWork()
    {
      lock (mIdlelocker)
      {
        Console.WriteLine("WorkerIdleCoordination: Task [{0}] SignalThereMightBeWork (idle count is {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] SignalThereMightBeWork (idle count is {1})", Task.CurrentId, mIdleCount);
        Monitor.PulseAll(mIdlelocker);
      }
    }

    /// <summary>
    /// Signals that there may be additional work available
    /// </summary>
    public void SignalThereMightBeWorkForOne()
    {
      lock (mIdlelocker)
      {
        Console.WriteLine("WorkerIdleCoordination: Task [{0}] SignalThereMightBeWorkForOne (idle count is {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] SignalThereMightBeWorkForOne (idle count is {1})", Task.CurrentId, mIdleCount);
        Monitor.Pulse(mIdlelocker);
      }
    }
    /// <summary>
    /// Signals that the tasks should shutdown
    /// </summary>
    public void SignalTasksToShutdown()
    {
      lock (mIdlelocker)
      {
        mShutdown = true;
        Console.WriteLine("WorkerIdleCoordination: Task [{0}] SignalTasksToShutdown (idle count is {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] SignalTasksToShutdown (idle count is {1})", Task.CurrentId, mIdleCount);
        Monitor.PulseAll(mIdlelocker);
      }
    }

    /// <summary>
    /// Blocking call that returns when there is additional work or when the
    /// task should shutdown
    /// </summary>
    /// <returns>Returns true indicating the task should shutdown, false indicating it should look for more work</returns>
    public bool WaitForWork()
    {
      Console.WriteLine("WorkerIdleCoordination: Task [{0}] WaitForWork called", Task.CurrentId, mIdleCount);
      mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] WaitForWork called", Task.CurrentId, mIdleCount);
      if (mShutdown)
        return true; //Shutdown

      //Wait for either 1)everyone to be idle (everyone is done), 2) for processing to be canceled (shutdown) or 3) a request to refresh the work queue
      lock (this.mIdlelocker)
      {
        //An extra safety check now that we have obtained the lock but before we enter the Wait
        if (mShutdown)
          return true; //Shutdown

        Console.WriteLine("WorkerIdleCoordination: Task [{0}] WaitForWork: About to call Monitor.Wait (idle count is {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] WaitForWork: About to call Monitor.Wait (idle count is {1})", Task.CurrentId, mIdleCount);
        Monitor.Wait(mIdlelocker);
        Console.WriteLine("WorkerIdleCoordination: Task [{0}] WaitForWork: Woken from Monitor.Wait (idle count is {1})", Task.CurrentId, mIdleCount);
        mLogger.LogDebug("WorkerIdleCoordination: Task [{0}] WaitForWork: Woken from Monitor.Wait (idle count is {1})", Task.CurrentId, mIdleCount);
      }

      return mShutdown;
    }
  }

  public static class StopwatchExtension
  {
    // This is the extension method.
    // The first parameter takes the "this" modifier
    // and specifies the type for which the method is defined.
    public static string ToPrettyString(this Stopwatch stopWatch)
    {
      long ms = stopWatch.ElapsedMilliseconds;
      if (ms < 500)
        return ms.ToString() + " milliseconds";
      else
      {
        decimal seconds = ms / 1000M;
        if (seconds < 120)
        {
          return string.Format("{0:F2} seconds", seconds);
        }
        else
        {
          long minutes = (long) Decimal.Floor(seconds / 60.0M);
          decimal remainder = seconds - (minutes * 60M);
          return string.Format("{0} minutes {1:F2} seconds", minutes, remainder);
        }
      }
    }
  }
}

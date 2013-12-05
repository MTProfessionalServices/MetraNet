namespace MetraTech.UsageServer
{
	using System;
	using System.Threading;
	using System.Collections;
	using System.Collections.Generic;
	using System.Runtime.InteropServices;
	using System.ServiceProcess;

	using Auth = MetraTech.Interop.MTAuth;
	using Rowset = MetraTech.Interop.Rowset;
  using Coll = MetraTech.Interop.GenericCollection;
	using MetraTech;
	using MetraTech.Xml;
	
	/// <summary>
	/// The main interface to the Usage Server
	/// </summary>
	[Guid("756ae460-3ee3-4dea-aae8-13e9be8bbf73")]
	public interface IClient
	{

		//
		// configuration
		//
		
		/// <summary>
		/// SessionContext used to secure certain methods, set this first
		/// </summary>
		Auth.IMTSessionContext SessionContext { set; }

    /// <summary>
    /// Machine name/identifier being used
    /// Setting of the machine identifier is meant only for testing (impersonating a different machine)
    /// </summary>
    string MachineIdentifier { get; } //Note: Setting of machine identifier is only for testing (impersonating a different machine)

		/// <summary>
		/// Synchronizes the database with the event configuration files (recurring_events.xml)
		/// </summary>
		/// <returns> Number of events affected </returns>
		int Synchronize();

		/// <summary>
		/// Synchronizes the database with the event configuration files (recurring_events.xml)
		/// </summary>
		void Synchronize(out int addedEvents, out int removedEvents);

		/// <summary>
		/// Synchronizes the database with the event configuration files (recurring_events.xml)
		/// Returns lists of events that were added, removed, and/or modified. 
		/// </summary>
		void Synchronize(out ArrayList addedEvents, out ArrayList removedEvents, out ArrayList modifiedEvents);


		//
		// interval management
		//

		/// <summary>
		/// Creates any needed usage intervals (and by extension reference intervals)
		/// </summary>
		/// <returns> Number of usage intervals created </returns>
		int CreateUsageIntervals();

		/// <summary>
		/// Creates any needed usage intervals (and by extension reference intervals)
		/// If pretend is true, then no usage intervals are actually created but instead
		/// they are just returned. 
		/// </summary>
		/// <returns> A list of intervals created (UsageInterval objects) </returns>
		ArrayList CreateUsageIntervals(bool pretend);

		//
		// Partition management

		/// <summary>
		/// Creates partitions for unassigned usage intervals.
		/// </summary>
		/// <returns></returns>
		void CreateUsagePartitions();

		/// <summary>
		/// Soft closes any applicable usage intervals (based on the configured grace periods)
		/// </summary>
		/// <returns> Number of usage intervals soft closed </returns>
		int SoftCloseUsageIntervals();

    /// <summary>
		/// Soft closes any needed usage intervals.
		/// If pretend is true, then no usage intervals are actually closed but instead are just returned. 
		/// </summary>
		/// <returns> A list of intervals soft closed (UsageInterval objects) </returns>
		ArrayList SoftCloseUsageIntervals(bool pretend);

    /// <summary>
    /// Soft closes any needed billing groups.
    /// If pretend is true, then no billing groups are actually closed 
    /// but instead are just returned. 
    /// </summary>
    /// <returns>A list of billing groups soft closed (IBillingGroup objects)</returns>
    ArrayList SoftCloseBillingGroups(bool pretend);

		/// <summary>
		/// Manually soft closes the given usage interval.
		/// The interval must be in the 'Open' status.
		/// </summary>
		/// <returns> True if successfully closed </returns>
		bool SoftCloseUsageInterval(int intervalID);

    /// <summary>
    ///    Manually soft closes the given billing group. 
    ///    The billing group must be in the 'Open' status.
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>True if successfully closed</returns>
    bool SoftCloseBillingGroup(int billingGroupID);

		/// <summary>
		/// Manually re-opens as many billing groups as possible for the given usage interval.
		/// The billing groups must be in the soft-closed (C) status.
		/// 
		/// Returns the number of billing groups successfully opened.
		/// </summary>
		int OpenUsageInterval(int intervalID);
		int OpenUsageInterval(int intervalID, bool ignoreDeps);

    /// <summary>
    /// Manually re-opens a given billing group.
    /// The billing group must be in the soft-closed (C) status.
    /// </summary>
    bool OpenBillingGroup(int billingGroupID);
    bool OpenBillingGroup(int billingGroupID, bool ignoreDeps);

    /// <summary>
    /// Determines whether the interval can successfully be opened.
    /// </summary>
    bool CanOpenUsageInterval(int intervalID);

		/// <summary>
		/// Determines whether the billing group can successfully be opened.
		/// </summary>
		bool CanOpenBillingGroup(int billingGroupID);

		/// <summary>
    /// Manually hard closes as many billing groups as possible for the given usage interval.
    /// The billing groups must not already be hard closed.
		/// No recurring event information is taken into account.
    /// 
    /// If, ignoreBillingGroups is true, will update the status of accounts in
    /// t_acc_usage_interval to 'H' and set the interval status in t_usage_interval to 'H'.
		/// </summary>
		/// <returns> True if successfully closed </returns>
    bool HardCloseUsageInterval(int intervalID, bool ignoreBillingGroups);

    /// <summary>
    /// Hard close all intervals which have an end date before the given dateTime.
    /// 
    /// Update the status of accounts in t_acc_usage_interval to 'H' and 
    /// set the interval status in t_usage_interval to 'H'.
    /// </summary>
    /// <returns>The count of intervals that are hard closed.</returns>
    int HardCloseUsageIntervals(DateTime dateTime);

    /// <summary>
    /// Manually hard closes as many billing groups as possible for the given usage interval.
    /// The billing groups must not already be hard closed.
    /// No recurring event information is taken into account.
    /// 
    /// If, ignoreBillingGroups is true, will update the status of accounts in
    /// t_acc_usage_interval to 'H' and set the interval status in t_usage_interval to 'H'.
    /// </summary>
    /// <returns> Number of billing groups hard closed </returns>
    void HardCloseUsageInterval(int intervalID, bool ignoreBillingGroups, out int numBillingGroupsHardClosed);

    /// <summary>
    /// Manually hard closes the given billing group.
    /// The billing group to be closed must be in either 'Open' or 'SoftClosed' status.
    /// No recurring event information is taken into account.
    /// </summary>
    /// <returns> True if successfully closed </returns>
    bool HardCloseBillingGroup(int billingGroupID);

		/// <summary>
		/// Gets usage interval information
		/// </summary>
		void GetUsageIntervalInfo(int intervalID, out DateTime startDate,
															out DateTime endDate, out string status); 

		/// <summary>
		/// Determines whether a soft close grace period for a particular cycle type
		/// is enabled. This should be called before GetSoftCloseGracePeriod.
		/// </summary>
		bool IsSoftCloseGracePeriodEnabled(CycleType cycleType);

		/// <summary>
		/// Gets the number of days the system waits to soft close an interval
		/// NOTE: if the grace period is disabled, then this method will throw
		/// </summary>
		int GetSoftCloseGracePeriod(CycleType cycleType);

		/// <summary>
		/// The number of days to create intervals in advance
		/// </summary>
		int AdvanceIntervalCreationDays
		{ get; }

		/// <summary>
		/// The last date that interval creation occurred on
		/// NOTE: if interval creation never occurred, then DateTime.MinValue is returned
		/// </summary>
		DateTime LastIntervalCreationDate
		{ get; }

		//
		// submitting events
		//

		/// <summary>
		/// Submits an event, given by instance ID, for execution.
		/// If the instance is in the 'NotYetRun' status it will become 'ReadyToRun'.
		/// If the isntance is already 'ReadyToRun', an update will occur if any of
		/// arguments (ignoreDeps, effDate) are different from the previous submission's.
		/// </summary>
		void SubmitEventForExecution(int instanceID, string comment);
		void SubmitEventForExecution(int instanceID, bool ignoreDeps, string comment);
		void SubmitEventForExecution(int instanceID, bool ignoreDeps, DateTime effDate, string comment);

		/// <summary>
		/// Submits an event, given by instance ID, for reversal.
		/// If the instance is in the 'Succeeded' or 'Failed' status it will become 'ReadyToReverse'.
		/// If the isntance is already 'ReadyToReverse', an update will occur if any of
		/// arguments (ignoreDeps, effDate) are different from the previous submission's.
		/// </summary>
		void SubmitEventForReversal(int instanceID, string comment);
		void SubmitEventForReversal(int instanceID, bool ignoreDeps, string comment);
		void SubmitEventForReversal(int instanceID, bool ignoreDeps, DateTime effDate, string comment);

		void SubmitEvent(RecurringEventAction action, int instanceID, bool ignoreDeps, DateTime effDate, string comment);

		void NotifyServiceOfSubmittedEvents();
		void NotifyServiceOfConfigChange();
		void KillCurrentlyProcessingRecurringEvent();

		// 
		// cancel submitted events
		// 

		/// <summary>
		/// Cancels an event, given by instance ID, that had been previously submitted for
		/// execution or reversal. The instance's status must be either 'ReadyToRun' or
		/// 'ReadyToReverse'. The status will revert to the instance's previous status. 
		/// </summary>
		void CancelSubmittedEvent(int instanceID, string comment);
		void CancelSubmittedEvents(IRecurringEventInstanceFilter instances, string comment);

		// 
		// manually change an event's status
		// 

		/// <summary>
		/// Manually marks an event, given by instance ID, as 'Succeeded'.
		/// The status must currently be 'Failed' for this to work.
		/// </summary>
		void MarkEventAsSucceeded(int instanceID, string comment);

		/// <summary>
		/// Manually marks an event, given by instance ID, as 'Failed'.
		/// The status must currently be 'Succeeded' for this to work.
		/// </summary>
		void MarkEventAsFailed(int instanceID, string comment);

		/// <summary>
		/// Manually marks an event, given by instance ID, as 'NotYetRun'.
		/// The status must currently be either 'Succeeded' or 'Failed'.
		/// </summary>
		void MarkEventAsNotYetRun(int instanceID, string comment);
		

		//
		// instantiating scheduled events
		//

		/// <summary>
		/// Instantiates all scheduled events with a start date argument as the
		/// instance's last end date argument plus one second and an end date
		/// argument as now.
		/// </summary>
		/// <returns> the number of events instantiated </returns>
		int InstantiateScheduledEvents();

		/// <summary>
		/// Instantiates all scheduled events with a start date argument as the
		/// instance's last end date argument plus one second and an end date
		/// argument as endDate.
		/// NOTE: this method should only be used when the instance will
		/// be submitted for execution at later time (using the same time).
		/// </summary>
		/// <returns> the number of events instantiated </returns>
		int InstantiateScheduledEvents(DateTime endDate);

		/// <summary>
		/// Instantiates the given scheduled event with a start date argument as the
		/// instance's last end date argument plus one second and an end date
		/// argument as endDate.
		/// </summary>
		/// <returns> the newly formed instance ID </returns>
		int InstantiateScheduledEvent(int eventID);

		/// <summary>
		/// Instantiates the given scheduled event with a start date argument as the
		/// instance's last end date argument plus one second and an end date
		/// argument as endDate.
		/// NOTE: this method should only be used when the instance will
		/// be submitted for execution at later time (using the same time).
		/// </summary>
		/// <returns>  the newly formed instance ID  </returns>
		int InstantiateScheduledEvent(int eventID, DateTime endDate);


		//
		// event info
		//

		/// <summary>
		/// Gets the recurring event by event name
		/// </summary>
		IRecurringEvent GetEventByName(string eventName);


		/// <summary>
		/// Gets the recurring event by ID
		/// </summary>
		IRecurringEvent GetEventByID(int eventID);

		/// <summary>
		/// Gets the recurring event by instance
		/// </summary>
		IRecurringEvent GetEventByInstance(int instanceID);



		//
		// rowset methods
		// 

		/// <summary>
		/// Gets a rowset containing all usage intervals
		/// </summary>
		/// <returns> 
		/// A rowset containing the following columns:
		///   IntervalID - int not null
		///   StartDate - datetime not null
		///   EndDate - datetime not null
		///   Status - string not null (O, C, H)
		///   DisplayStatus - string not null (Open, Soft Closed, Hard Closed)
		///   IsExpired - string not null (Y, N)
		///   CycleID - int not null
		///   CycleTypeID - int not null
		///   CycleTypeName - string not null (Daily, Monthly, Weekly, Bi-weekly, Semi-monthly, Quarterly, SemiAnnually, Annually)
		///   SucceededInstances - int not null
		///   FailedInstances - int not null
		///   TotalInstances - int not null
		/// </returns>
		/// 
    /// !NOTE Deprecated. 
		Rowset.IMTSQLRowset GetUsageIntervalsRowset();

		/// <summary>
		/// Gets a rowset containing all events
		/// </summary>
		Rowset.IMTSQLRowset GetEventsRowset();

		/// <summary>
		/// Gets a rowset containing all events of the given type
		/// </summary>
		Rowset.IMTSQLRowset GetEventsRowset(RecurringEventType eventType);

		/// <summary>
		/// Gets a rowset containing scheduled instances for the given event
		/// </summary>
		Rowset.IMTSQLRowset GetScheduledInstancesRowset(string eventName);

		/// <summary>
		/// Gets a rowset containing dependencies for the given instance and dependency type
		/// </summary>
		Rowset.IMTSQLRowset GetDependenciesByInstanceRowset(IRecurringEventInstanceFilter instances,
																												RecurringEventDependencyType depType,
																												RecurringEventDependencyStatus depStatus);

		/// <summary>
		/// Generates a representation of the dependency relationship between all recurring events
		/// in the system. Representation is encoded in the Graphviv DOT format.
		/// For mor information on Graphviv, see: http://www.research.att.com/sw/tools/graphviz/
		/// </summary>
		string GenerateDOTOutput(bool includeRootEvents);

		/// <summary>
		/// Gets a rowset containing whether instances can be executed or not
		/// </summary>
		Rowset.IMTSQLRowset GetCanExecuteEventRowset(IRecurringEventInstanceFilter instances);

		/// <summary>
		/// Gets a rowset containing unsatisfied, unique, non-ReadyToRun dependencies of the
		/// given instances to be executed
		/// </summary>
		Rowset.IMTSQLRowset GetCanExecuteEventDepsRowset(IRecurringEventInstanceFilter instances);

		/// <summary>
		/// Gets a rowset containing whether instances can be reversed or not
		/// </summary>
		Rowset.IMTSQLRowset GetCanReverseEventRowset(IRecurringEventInstanceFilter instances);

		/// <summary>
		/// Gets a rowset containing unsatisfied, unique, non-ReadyToReverse dependencies of the
		/// given instances to be reversed
		/// </summary>
		Rowset.IMTSQLRowset GetCanReverseEventDepsRowset(IRecurringEventInstanceFilter instances);

		/// <summary>
		/// Determines which events can be executed right now
		// (instances that have satisfied all of their execution dependencies)
		/// </summary>
		IRecurringEventInstanceFilter DetermineExecutableEvents();

		/// <summary>
		/// Determines which events can be executed right now
		// (instances that have satisfied all of their execution dependencies)
		/// </summary>
		IRecurringEventInstanceFilter DetermineReversibleEvents();

		/// <summary>
		/// Gets a rowset containing a specific instance's associated runs
		/// </summary>
		/// <returns> 
		/// A rowset containing the following columns:
		///   RunID - int not null
		///   InstanceID - int not null
		///   Action - string not null (Execute, Reverse)
		///   ReversedRunID - int null
		///   StartDate - datetime not null
		///   EndDate - datetime null
		///   Status - string not null (InProgress, Succeeded, Failed)
		///   Result - string null (user defined)
		///   HasDetails - string not null (Y, N)
		///   Batches - int not null
		/// </returns>
		Rowset.IMTSQLRowset GetRunsRowset(int instanceID);

		/// <summary>
		/// Gets a rowset containing a specific run's details
		/// </summary>
		Rowset.IMTSQLRowset GetRunDetailsRowset(int runID);

		// TODO: where will auditing info come from?
		
		//
		// execution and reversal
		//
	  void ProcessEvents(out int executions, out int executionFailures,
											 out int reversals,  out int reversalFailures);

		//
		// testing
		//
		int CreateAdapterTest(RecurringEvent recurringEvent, RecurringEventRunContext context);

		//
		// wait methods
		//
		bool Wait(int timeout);

		/// <summary>
		/// Implements a sleep in managed code. This is used to keep aborts responsive
		/// on MeterRowset based adapters.
		/// INTERNAL USE ONLY
		/// </summary>
		void ManagedSleep(int millisecondsTimeout);


		/// <summary>
		/// Determines if any instance of the named event is currently running.
		/// </summary>
		bool IsAdapterRunning(string eventName);

    /// <summary>
    /// Gets a rowset containing all usage intervals with the given status
    /// </summary>
    Rowset.IMTSQLRowset GetUsageIntervalsRowset(UsageIntervalStatus status);

    /// <summary>
    /// Gets a rowset containing end-of-period instances for the given interval
    /// </summary>
    Rowset.IMTSQLRowset GetEndOfPeriodInstancesRowset(int intervalID);

#region Billing Groups

    /// <summary>
    ///   Gets a rowset containing all usage intervals with the given status
    /// </summary>
    /// <returns>
    ///   IntervalID
    ///   CycleType
    ///   StartDate
    ///   EndDate
    ///   TotalGroupCount
    ///   OpenGroupCount
    ///   SoftClosedGroupCount
    ///   HardClosedGroupCount
    ///   UnassignedAccountsCount
    ///   Progress:  0 - 100
    ///   
    ///   Progress is defined as the weighted average of the
    ///   successful adapter executions for each billing group for an interval.
	  /// 
    ///   Hence, for a given interval with 100 accounts, let's say there are 
    ///   two billing groups: B1 with 25 accounts and B2 with 75 accounts.
    ///            
    ///   Also assume there are 20 adapters which are valid for this interval.
    ///   
    ///   Total Progress = Progress for billing group adapters + Progress for interval-only adapters
    ///
    ///   If B1 has 5 successful adapter executions out of 15 and if
    ///   B2 has 10 successful adapter executions out of 15, then progress is :
	  ///   0.583 x % billing group adapters  
	  ///   (The number 0.583 is derived from the calculation below)
    ///   0.25 x (5/15) + 0.75 x  (10/15) = 0.583
    ///     |               |
    ///   (B1 weight)     (B2 weight)
    ///
    ///   The percentage of billing group adapters = 15/20 = 0.75
    ///   Hence progress for billing group adapters = 0.583 x 0.75 = 0.437
	  /// 
    ///   Progress for interval-only adapters is calculated as follows:
    ///   2/5 x % of interval only adapters = 2/5 x (5/20) = 0.1
    ///
    ///   Hence, the total progress = 0.437 + 0.1 = 0.537
    ///    
    ///   Default sort:  EndDate DESC
    /// </returns>  
    Rowset.IMTSQLRowset GetUsageIntervalsRowset(UsageIntervalFilter filter);
    Rowset.IMTSQLRowset GetUsageIntervalsRowsetRedux(UsageIntervalFilter filter);

    /// <summary>
    ///   Gets the usage interval object representing the interval.
    /// </summary>
    /// <param name="intervalID"></param>
    /// <returns>IUsageInterval</returns>
    IUsageInterval GetUsageInterval(int intervalID);

    /// <summary>
    ///   Runs the full materialization of Billing Groups for the interval.
    /// </summary>
    /// <returns>a materialization ID</returns>
    int MaterializeBillingGroups(int intervalID);

    /// <summary>
    ///   Runs the materialization of Billing Groups for the interval.
    ///   Precondition: Full materialization has already been run for this interval.
    ///   
    ///   Rematerialization does the following:
    ///   1) Attempts to move unassigned accounts in the interval
    ///      to new or open billing groups.
    ///   2) Records account movement into and out of Soft Closed/Hard Closed
    ///      billing groups - without actually making the moves.
    /// </summary>
    /// <returns>a materialization ID</returns>
    int ReMaterializeBillingGroups(int intervalID);

    /// <summary>
    /// Call this method to see if there were reassignment warnings on the last full materialization
    /// </summary>
    /// <param name="intervalID"></param>
    /// <returns>returns materialization id or -1 if none</returns>
    int GetLastMaterializationIDWithReassignmentWarnings(int intervalID);
    
    /// <summary>
    ///   Returns a rowset with reassignment failures found during a rematerialization.
    /// </summary>
    /// <returns>a rowset to be defined</returns>
    Rowset.IMTSQLRowset GetMaterializationReassignmentWarnings(int materializationID);

    /// <summary>
    ///   Find the billing group id for the given username/namespace and
    ///   the given interval. 
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="nameSpace"></param>/// 
    /// <returns>BillingGroupID or -1 if none found.</returns>
    int FindBillingGroupIDByMember(string userName, string nameSpace, int intervalId);
    
    /// <summary>
    ///   Find the billing group id for the given account and
    ///   given interval. 
    /// </summary>
    /// <param name="accountID"></param>
    /// <returns>BillingGroupID or -1 if none found.</returns>
    int FindBillingGroupIDByMember(int accountID, int intervalID);

    /// <summary>
    ///   Gets the list of Billing Groups for the interval.
    /// </summary>
    /// <param name="usageIntervalID"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>  
    Rowset.IMTSQLRowset GetBillingGroupsRowset(int usageIntervalID, bool isFlattened);

    /// <summary>
    ///   Gets the list of Billing Groups for the given filter.
    /// </summary>
    /// <param name="usageIntervalID"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>  
    Rowset.IMTSQLRowset GetBillingGroupsRowset(IBillingGroupFilter filter);

    /// <summary>
    ///   Gets the Billing Group list that has been created from the parent group.
    /// </summary>
    /// <param name="parentBillingGroupID"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   ParentBillingGroupID
    ///   ParentBillingGroupName
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>  
    Rowset.IMTSQLRowset GetDescendantBillingGroupsRowset(int parentBillingGroupID);

    /// <summary>
    ///   Gets the Billing Group object
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>IBillingGroup</returns>
    IBillingGroup GetBillingGroup(int billingGroupID);

    /// <summary>
    ///   Return the member accounts for the given billingGroupId.
    /// </summary>
    /// <param name="filter"></param>
    /// <returns>
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   AccountID
    ///
    ///   Sort on:  DisplayName ASC
    ///</returns>
    Rowset.IMTSQLRowset GetBillingGroupMembersRowset(int billingGroupID, Rowset.IMTDataFilter filter);

    /// <summary>
    ///   Gets a rowset containing end-of-period instances for the given interval.
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>
    ///   evt.id_event EventID,
    ///   evt.tx_name EventName,
    ///   evt.tx_display_name EventDisplayName,
    ///   evt.tx_type EventType,
    ///   evt.tx_reverse_mode ReverseMode,
    ///   evt.tx_class_name ClassName,
    ///   evt.tx_config_file ConfigFile,
    ///   evt.tx_desc EventDescription,
    ///   inst.id_instance InstanceID,
    ///   inst.id_arg_interval ArgIntervalID,
    ///   inst.b_ignore_deps IgnoreDeps,
    ///   inst.dt_effective EffectiveDate,    
    ///   inst.tx_status Status,           --- "ReadyToRun", "ReadyToReverse", "NotYetRun", "Failed", "Succeeded"
    ///   run.id_run LastRunID,
    ///   run.tx_type LastRunAction,
    ///   run.dt_start LastRunStart,
    ///   run.dt_end LastRunEnd,
    ///   run.tx_status LastRunStatus,
    ///   run.tx_detail LastRunDetail,
    ///   ISNULL(batch.total, 0) LastRunBatches,
    ///   COUNT(dep.id_event) TotalDeps,
    ///   ISNULL(warnings.total, 0) LastRunWarnings
    ///   IsGlobalAdapter
    ///   GetEndOfPeriodInstancesRowset
    /// </returns>
    Rowset.IMTSQLRowset GetEndOfPeriodInstancesRowset2(int billingGroupID);
    
	/// <summary>
	/// Cas the event completed successfully for a given billing group
	/// </summary>
	/// <param name="EventID"></param>
	/// <param name="billingGroupID"></param>
	/// <returns></returns>
	bool HasEventSucceeded(string aEventName, int aBillingGroupID);

    /// <summary>
    ///   Returns the list of accounts that had failures durring the run.
    /// </summary>
    /// <param name="runID"></param>
    /// <returns>
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   AccountID
    ///   AdapterName
    ///   
    ///   Sort on:  DisplayName ASC
    /// </returns>
    Rowset.IMTSQLRowset GetFailureAccountsRowset(int runID, Rowset.IMTDataFilter filter);

    
    int CreateUserDefinedBillingGroupFromAllUnassignedAccounts(int intervalID, string name, string description);
    int CreateUserDefinedBillingGroupFromAccounts(int intervalID, string name, string description, string accounts);
    int CreateUserDefinedBillingGroupFromFile(int intervalID, string name, string description, string fileName);
        

    /// <summary>
    ///   The start of creating a Pull List automatically from the 
    ///   failure accounts reported by a run
    /// </summary>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="parentBillingGroupID"></param>
    /// <param name="accounts"></param>
    /// <param name="needsExtraAccounts"></param>
    /// <returns>Materialization ID</returns>
    int StartChildGroupCreationFromFailedRunID(string name, 
                                               string description, 
                                               int runID, 
                                               out bool needsExtraAccounts);
    
    /// <summary>
    ///    The first of a three-step pull list creation process. The three steps are:
    ///    
    ///    1) StartChildGroupCreation (this method)
    ///         a) Creates the pull list in the temporary tables.
    ///         b) Allows adapters to pull in additional accounts from
    ///            the parent billing group.
    ///         c) Ensures that the adapters pull in accounts that belong
    ///            to the parent billing group only.
    ///         d) Ensures that the parent billing group does not become empty.
    ///            
    ///    2) GetNecessaryChildGroupAccounts
    ///         a) Returns the list of new accounts that got added to the
    ///            billing group due to adapter constraints (Step 1b)
    ///    
    ///    ----------------------------------------------------------------------------
    ///    User approval (From UI): 
    ///    
    ///    If there are any accounts returned in Step (2) then
    ///    the user must manually approve (or abort - UI calls AbortChildGroupCreation)
    ///    the accounts before proceeding to the next step. 
    ///    
    ///    If there are no accounts returned in Step(2), the UI automatically
    ///    calls Step(3).
    ///    ----------------------------------------------------------------------------
    ///    
    ///    3) FinishChildGroupCreation
    ///       a) Copy data from temporary billing group tables to 
    ///          permanent billing group tables.
    ///       b) Fix up data for parent billing group.
    ///       c) Deep copy all the adapter instance data for the parent billing group
    ///          to the child billing group.
    ///       d) Call 'SplitReverseState' on adapters to touch up any 
    ///          internal reversal state they kept track of to aid in a custom reverse. 
    ///          This is only done on Succeeded or Failed instances that 
    ///          are associated with an adapter that implements a custom reverse mode
    ///            
    /// </summary>
    /// <param name="name">name of the new billing group</param>
    /// <param name="description">description for the new billing group</param>
    /// <param name="parentBillingGroupID">the billing group from which the 
    ///                                    new one is being created</param>
    /// <param name="accounts">comma separated list of account identifiers</param>
    /// <param name="needsExtraAccounts">true, if additional accounts need to be 
    ///                                  moved from the parent billing group to 
    ///                                  the new billing group</param>
    /// <returns>materialization id</returns>
    int StartChildGroupCreationFromAccounts(string name, 
                                string description, 
                                int parentBillingGroupID, 
                                string accounts, 
                                out bool needsExtraAccounts);

    /// <summary>
    ///   The start of a Pull List.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="parentBillingGroupID"></param>
    /// <param name="fileName"></param>
    /// <param name="needsExtraAccounts"></param>
    /// <returns>Materialization ID</returns>
    int StartChildGroupCreationFromFile(string name, 
      string description, 
      int parentBillingGroupID, 
      string fileName, 
      out bool needsExtraAccounts);

    /// <summary>
    ///   Returns the list of additional accounts which are required by adapters to
    ///   complete this billing goup.
    /// </summary>
    /// <param name="materializationID"></param>
    /// <returns>
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   AccountID
    ///   AdapterName
    ///   
    ///   Sort on:  DisplayName ASC
    /// </returns>
    Rowset.IMTSQLRowset GetNecessaryChildGroupAccounts(int materializationID);

    /// <summary>
    ///   Aborts the creation of the child group associated with the given
    ///   materializationID
    /// </summary>
    /// <param name="materializationID"></param>
    void AbortChildGroupCreation(int materializationID);

    /// <summary>
    ///  a) Copy data from temporary billing group tables to 
    ///      permanent billing group tables.
    ///  b) Fix up data for parent billing group.
    ///  c) Deep copy all the adapter instance data for the parent billing group
    ///     to the child billing group.
    ///  d) Call 'SplitReverseState' on adapters to touch up any 
    ///     internal reversal state they kept track of to aid in a custom reverse. 
    ///     This is only done on Succeeded or Failed instances that 
    ///     are associated with an adapter that implements a custom reverse mode
    /// </summary>
    /// <param name="materializationID"></param>
    /// <returns>BillingGroupID</returns>
    int FinishChildGroupCreation(int materializationID);

    /// <summary>
    /// Returns the unassigned accounts for the given interval.
    /// 
    /// If 'Status' is not specified on the given filter, 
    /// all unassigned accounts for the interval will be retrieved. 
    /// </summary>
    /// <param name="intervalId"></param>
    /// <param name="filter"></param>
    /// <returns>
    /// AccountId, 
    /// DisplayName,
    /// nm_space,
    /// nm_login, 
    /// status
    /// 
    /// Sorted by:  DisplayName ASC
    /// </returns>
    Rowset.IMTSQLRowset GetUnassignedAccountsForIntervalAsRowset
      (IUnassignedAccountsFilter filter);


    /// <summary>
    /// 
    /// </summary>
    /// <param name="accounts">a collection of int's</param>
    /// <param name="intervalId"></param>
    /// <param name="backoutAndResubmitUsage"></param>
    /// <returns></returns>
    Rowset.IMTSQLRowset 
      SetAccountStatusToHardClosedForInterval(Coll.IMTCollection accounts, 
                                              int intervalId, 
                                              bool backoutAndResubmitUsage);

    /// <summary>
    ///   Once this method is called, no interval mappings will be created
    ///   for new accounts for this interval.
    /// </summary>
    /// <param name="intervalId"></param>
    void SetIntervalAsBlockedForNewAccounts(int intervalId);

    /// <summary>
    ///    Set the tx_interval_status of all expired intervals to 'B'.
    /// </summary>
    /// <returns>number of intervals blocked</returns>
    int BlockExpiredIntervals();

    /// <summary>
    ///    Hard close those intervals which don't have paying accounts. 
    ///    
    ///    This is required during automatic processing of intervals. If there
    ///    are no paying accounts in the interval then no billing groups are
    ///    created and hence the framework cannot transition the interval to 
    ///    hard closed.
    /// </summary>
    /// <returns>number of intervals hard closed</returns>
    int HardCloseExpiredIntervalsWithNoPayingAccounts();

    /// <summary>
    ///   Return the value of <BillingGroups>\<AllowPullList> in usageserver.xml 
    /// </summary>
    /// <returns></returns>
    bool AllowPullLists();

    /// <summary>
    ///   Return true if billing groups have been created for the given interval. 
    /// </summary>
    /// <returns></returns>
    bool HasBeenFullyMaterialized(int intervalId);

    /// <summary>
    ///   Set the ignoredeps status of the EndRoot event (in t_recevent_inst) for the given billingGroupId to 'Y'.
    /// </summary>
    /// <param name="billingGroupId"></param>
    void IgnoreEndRootDependenciesForBillingGroup(int billingGroupId);
   
    /// <summary>
    ///   Set the ignoredeps status of all the EndRoot events (in t_recevent_inst) for the given intervalId to 'Y'.
    /// </summary>
    /// <param name="intervalId"></param>
    void IgnoreEndRootDependenciesForInterval(int intervalId);
   

#endregion


	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("0f7a6e85-6987-423a-bc6f-7c504f24144f")]
	public class Client : IClient
	{

		RecurringEventManager mEventManager;
		UsageIntervalManager mIntervalManager;
		UsageCycleManager mCycleManager;
		UsagePartitionManager mPartitionManager;
    BillingGroupManager mBillingGroupManager;

		public Client() : this(null)
		{
		}

    public Client(string machineIdentifier)
    {
      mMachineIdentifier = machineIdentifier;
      mEventManager = new RecurringEventManager(MachineIdentifier);
      mIntervalManager = new UsageIntervalManager();
      mCycleManager = new UsageCycleManager();
      mPartitionManager = new UsagePartitionManager();
      mBillingGroupManager = new BillingGroupManager();
    }

		//
		// configuration
		//
		public int Synchronize()
		{
			int addedEvents, removedEvents;
			Synchronize(out addedEvents, out removedEvents);

			return addedEvents + removedEvents;
		}

		public void Synchronize(out int addedCount, out int removedCount)
		{
			ArrayList addedEvents, removedEvents, modifiedEvents;
			Synchronize(out addedEvents, out removedEvents, out modifiedEvents);

			addedCount = addedEvents.Count;
			removedCount = removedEvents.Count;
		}

		public void Synchronize(out ArrayList addedEvents, out ArrayList removedEvents, out ArrayList modifiedEvents)
		{
      ConfigCrossServerManager.Synchronize();
			mIntervalManager.Synchronize();
			mEventManager.Synchronize(out addedEvents, out removedEvents, out modifiedEvents);
			mPartitionManager.Synchronize();

			// notifies the service that it should refresh its config info
			NotifyServiceOfConfigChange();
		}

		// NOTE: For unit-testing only!
		public void Synchronize(string eventConfigFile, 
														out ArrayList addedEvents,
														out ArrayList removedEvents,
														out ArrayList modifiedEvents)
		{
			mIntervalManager.Synchronize();
			mEventManager.Synchronize(eventConfigFile, out addedEvents, out removedEvents, out modifiedEvents);
			mPartitionManager.Synchronize();

			// notifies the service that it should refresh its config info
			NotifyServiceOfConfigChange();
		}

    /// <summary>
    /// Update the configuration files with data from the database
    /// For example if user updated recurrence pattern for scheduled adapter via MetraControl
    /// this method will update recurring_events.xml with this pattern for an adapterA.
    /// </summary>
    /// <returns></returns>
    public int SynchronizeConfigFile()
    {
      List<RecurringEvent> modifiedEvents;
      mEventManager.SynchronizeFile(out modifiedEvents);
      return modifiedEvents.Count;
    }

    public void SynchronizeConfigFile(out List<RecurringEvent> modifiedEvents)
    {
      mEventManager.SynchronizeFile(out modifiedEvents);
    }

    // NOTE: For unit-testing only!
    public void SynchronizeConfigFile(string eventConfigFile, out List<RecurringEvent> modifiedEvents)
    {
      mEventManager.SynchronizeFile(eventConfigFile, out modifiedEvents);
    }

		public Auth.IMTSessionContext SessionContext
		{
			set 
			{
				if (value == null)
					throw new ApplicationException(MISSING_SESSION_CONTEXT);

				mSessionContext = value;
			}
		}

    /// <summary>
    /// Machine name/identifier being used
    /// Setting of the machine identifier is meant only for testing (impersonating a different machine)
    /// </summary>
    public string MachineIdentifier
    {
      get
      {
        //Set the machine identifier
        if (string.IsNullOrEmpty(mMachineIdentifier))
          mMachineIdentifier = System.Environment.MachineName;

        return mMachineIdentifier;

      }
      //set
      //{
      //  mMachineIdentifier = value;
      //}
    } 

		//
		// interval management
	  //
		public void CreateUsageCycles()
		{
			mCycleManager.AddUsageCycles();
		}
		
	  public int CreateReferenceIntervals()
		{
			mIntervalManager.CreateReferenceIntervals();
			// TODO: get the actual count
			return 0;
		}

	  public int CreateUsageIntervals()
		{
		  mIntervalManager.CreateReferenceIntervals();
		  int numIntervals = mIntervalManager.CreateUsageIntervals();
		  CreateUsagePartitions();
		  return numIntervals;
		}

	  public ArrayList CreateUsageIntervals(bool pretend)
		{
		  mIntervalManager.CreateReferenceIntervals();
		  ArrayList intervals = mIntervalManager.CreateUsageIntervals(pretend);
		  if (!pretend)
			  CreateUsagePartitions();
		  return intervals;
		}

		public void CreateUsagePartitions()
		{
			mPartitionManager.CreateUsagePartitions();
			mPartitionManager.DeployAllPartitionedTables();
		}

		public int SoftCloseUsageIntervals()
		{
      return mBillingGroupManager.SoftCloseBillingGroups(false).Count;
			// return mIntervalManager.SoftCloseUsageIntervals();
		}

		public ArrayList SoftCloseUsageIntervals(bool pretend)
		{
      return mBillingGroupManager.SoftCloseBillingGroups(pretend);
			// return mIntervalManager.SoftCloseUsageIntervals(pretend);
		}

		public bool SoftCloseUsageInterval(int intervalID)
		{
			// return mIntervalManager.SoftCloseUsageInterval(intervalID);
      return mBillingGroupManager.SoftCloseBillingGroups(intervalID);
		}

    public bool SoftCloseBillingGroup(int billingGroupID)
    {
      return mBillingGroupManager.SoftCloseBillingGroup(billingGroupID);
    }

    public ArrayList SoftCloseBillingGroups(bool pretend)
    {
      return mBillingGroupManager.SoftCloseBillingGroups(pretend);
    }

		public int OpenUsageInterval(int intervalID)
		{
      int numBillingGroups;
      int numBillingGroupsOpened; 

      mBillingGroupManager.OpenUsageInterval(intervalID, 
                                             false, 
                                             false, 
                                             out numBillingGroups,
                                             out numBillingGroupsOpened);

      return numBillingGroupsOpened;
			// mIntervalManager.OpenUsageInterval(intervalID, false, false);
		}

    public bool OpenBillingGroup(int billingGroupID)
    {
      bool opened = true;
      // just pretend
      try 
      {
        mBillingGroupManager.OpenBillingGroup(billingGroupID, false, false);
      }
      catch(Exception) 
      {
        opened = false;
      }

      return opened;
    }

		public int OpenUsageInterval(int intervalID, bool ignoreDeps)
		{
      int numBillingGroups;
      int numBillingGroupsOpened; 

      mBillingGroupManager.OpenUsageInterval(intervalID, 
                                             ignoreDeps, 
                                             false, 
                                             out numBillingGroups,
                                             out numBillingGroupsOpened);

      return numBillingGroupsOpened;
			// mIntervalManager.OpenUsageInterval(intervalID, ignoreDeps, false);
		}

    public bool OpenBillingGroup(int billingGroupID, bool ignoreDeps)
    {
      bool opened = true;

      try 
      {
        mBillingGroupManager.OpenBillingGroup(billingGroupID, ignoreDeps, false);
      }
      catch(Exception) 
      {
        opened = false;
      }

      return opened;
    }

    public bool CanOpenUsageInterval(int intervalID)
		{
      bool canOpen = false;

			// just pretend
      int numBillingGroups;
      int numBillingGroupsOpened; 

      mBillingGroupManager.OpenUsageInterval(intervalID, 
                                             false, 
                                             true,
                                             out numBillingGroups,
                                             out numBillingGroupsOpened);

      if (numBillingGroups == numBillingGroupsOpened) 
      {
        canOpen = true;
      }

      return canOpen;
			// return mIntervalManager.OpenUsageInterval(intervalID, false, true);
		}

    public bool CanOpenBillingGroup(int billingGroupID)
    {
      return mBillingGroupManager.OpenBillingGroup(billingGroupID, false, true, false);
    }

		public bool HardCloseUsageInterval(int intervalID, bool ignoreBillingGroups)
		{
      int numBillingGroups;
      int numBillingGroupsHardClosed; 

      mBillingGroupManager.HardCloseUsageInterval(intervalID,
                                                  ignoreBillingGroups,
                                                  out numBillingGroups,
                                                  out numBillingGroupsHardClosed);

      if (ignoreBillingGroups == false)
      {
        if (numBillingGroups == numBillingGroupsHardClosed)
        {
          return true;
        }
      }
      
      return false;
			// return mIntervalManager.HardCloseUsageInterval(intervalID);
		}

    public void HardCloseUsageInterval(int intervalID, bool ignoreBillingGroups, out int numBillingGroupsHardClosed)
    {
      int numBillingGroups;

      mBillingGroupManager.HardCloseUsageInterval(intervalID,
                                                  ignoreBillingGroups,
                                                  out numBillingGroups,
                                                  out numBillingGroupsHardClosed);

    }

    public int HardCloseUsageIntervals(DateTime dateTime)
    {
      return mBillingGroupManager.HardCloseUsageIntervals(dateTime);
    }

    public bool HardCloseBillingGroup(int billingGroupID)
    {
      bool hardClosed = true;

      try 
      {
        mBillingGroupManager.HardCloseBillingGroup(billingGroupID);
      }
      catch(Exception) 
      {
        hardClosed = false;

        throw;
      }

      return hardClosed;
    }

		public bool IsSoftCloseGracePeriodEnabled(CycleType cycleType)
		{
			return mIntervalManager.IsSoftCloseGracePeriodEnabled(cycleType);
		}

		public int GetSoftCloseGracePeriod(CycleType cycleType)
		{
			return mIntervalManager.GetSoftCloseGracePeriod(cycleType);
		}

		public int AdvanceIntervalCreationDays
		{
			get
			{
				return mIntervalManager.AdvanceIntervalCreationDays;
			}
		}

		public DateTime LastIntervalCreationDate
		{
			get
			{
				return mIntervalManager.LastIntervalCreationDate;
			}
		}

		//
		// submitting events
		//
		public void SubmitEvent(RecurringEventAction action, int instanceID, bool ignoreDeps, DateTime effDate, string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(action,
																instanceID, ignoreDeps, DateTime.MinValue,
																mSessionContext, comment);
		}

		public void SubmitEventForExecution(int instanceID, string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(RecurringEventAction.Execute,
																instanceID, false, DateTime.MinValue,
																mSessionContext, comment);
		}

		public void SubmitEventForExecution(int instanceID, bool ignoreDeps, string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(RecurringEventAction.Execute,
																instanceID, ignoreDeps,
																DateTime.MinValue, mSessionContext, comment);
		}

		public void SubmitEventForExecution(int instanceID, bool ignoreDeps, DateTime effDate,
																				string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(RecurringEventAction.Execute,
																instanceID, ignoreDeps, effDate,
																mSessionContext, comment);
		}


		//
		// submitting events for reversal
		//
		public void SubmitEventForReversal(int instanceID, string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(RecurringEventAction.Reverse,
																instanceID, false, DateTime.MinValue,
																mSessionContext, comment);
		}

		public void SubmitEventForReversal(int instanceID, bool ignoreDeps, string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(RecurringEventAction.Reverse,
																instanceID, ignoreDeps,
																DateTime.MinValue, mSessionContext, comment);
		}

		public void SubmitEventForReversal(int instanceID, bool ignoreDeps, DateTime effDate,
																			 string comment)
		{
			if (mSessionContext == null)
				throw new ApplicationException(MISSING_SESSION_CONTEXT);

			mEventManager.SubmitEvent(RecurringEventAction.Reverse,
																instanceID, ignoreDeps, effDate,
																mSessionContext, comment);
		}


		// 
		// cancel submitted events
		// 
		public void CancelSubmittedEvent(int instanceID, string comment)
		{
			mEventManager.CancelSubmittedEvent(instanceID, mSessionContext, comment);
		}
		
		public void CancelSubmittedEvents(IRecurringEventInstanceFilter instances, string comment)
		{
			// cancels each instance individually
			foreach (int instanceID in instances)
				mEventManager.CancelSubmittedEvent(instanceID, mSessionContext, comment);
		}


		// 
		// manually change an event's status
		// 
		public void MarkEventAsSucceeded(int instanceID, string comment)
		{
			mEventManager.MarkEventAsSucceeded(instanceID, mSessionContext, comment);
		}

		public void MarkEventAsFailed(int instanceID, string comment) 
		{
			mEventManager.MarkEventAsFailed(instanceID, mSessionContext, comment);
		}
		public void MarkEventAsNotYetRun(int instanceID, string comment) 
		{
			mEventManager.MarkEventAsNotYetRun(instanceID, mSessionContext, comment);
		}


		//
		// instantiating scheduled events
		//
		public int InstantiateScheduledEvents()
		{
			return InstantiateScheduledEvents(MetraTime.Now);
		}

		public int InstantiateScheduledEvents(DateTime endDate)
		{
			return mEventManager.InstantiateScheduledEvents(endDate);
		}

		public int InstantiateScheduledEvent(int eventID)
		{
			return InstantiateScheduledEvent(eventID, MetraTime.Now);
		}

		public int InstantiateScheduledEvent(int eventID, DateTime endDate)
		{
			return mEventManager.InstantiateScheduledEvent(eventID, endDate);
		}


    /// <returns>
    /// IntervalID, 
    /// CycleType,
    /// StartDate,
    /// EndDate,
    /// TotalGroupCount,
    /// OpenGroupCount,
    /// SoftClosedGroupCount,
    /// HardClosedGroupCount,
    /// UnassignedAccountsCount,
    /// Progress,
    /// TotalIntervalOnlyAdapterCount,
    /// TotalBillingGroupAdapterCount,
    /// SucceededAdapterCount,
    /// FailedAdapterCount,
    /// CycleID,
    /// HasBeenMaterialized
    /// 
    /// Sort on:  EndDate ASC
    /// </returns>
		public Rowset.IMTSQLRowset GetUsageIntervalsRowset()
		{
      throw new NotSupportedException("This method is deprecated - use GetUsageIntervalsRowsetRedux instead");
		}

		public Rowset.IMTSQLRowset GetEventsRowset()
		{
			// TODO: implement me!
			return null;
		}

		public Rowset.IMTSQLRowset GetEventsRowset(RecurringEventType eventType)
		{
			// TODO: implement me!
			return null;
		}

		public Rowset.IMTSQLRowset GetScheduledInstancesRowset(string eventName) // or eventID???
		{
			RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
			instances.EventName = eventName;
			return instances.GetScheduledRowset();
		}

		public Rowset.IMTSQLRowset GetDependenciesByInstanceRowset(IRecurringEventInstanceFilter instances,
																															 RecurringEventDependencyType depType,
																															 RecurringEventDependencyStatus depStatus)
		{
			return mEventManager.GetDependenciesByInstanceRowset(instances, depType, depStatus);
		}

		public string GenerateDOTOutput(bool includeRootEvents)
		{
			return mEventManager.GenerateDOTOutput(includeRootEvents);
		}

		public Rowset.IMTSQLRowset GetCanExecuteEventRowset(IRecurringEventInstanceFilter instances)
		{
			return mEventManager.GetCanExecuteEventRowset(instances);
		}

		public Rowset.IMTSQLRowset GetCanReverseEventRowset(IRecurringEventInstanceFilter instances)
		{
			return mEventManager.GetCanReverseEventRowset(instances);
		}

		public Rowset.IMTSQLRowset GetCanExecuteEventDepsRowset(IRecurringEventInstanceFilter instances)
		{
			return mEventManager.GetCanExecuteEventDepsRowset(instances);
		}

		public Rowset.IMTSQLRowset GetCanReverseEventDepsRowset(IRecurringEventInstanceFilter instances)
		{
			return mEventManager.GetCanReverseEventDepsRowset(instances);
		}

		public IRecurringEventInstanceFilter DetermineExecutableEvents()
		{
			return mEventManager.DetermineExecutableEvents();
		}

		public IRecurringEventInstanceFilter DetermineReversibleEvents()
		{
			return mEventManager.DetermineReversibleEvents();
		}

		public Rowset.IMTSQLRowset GetRunsRowset(int instanceID)
		{
			RecurringEventRunFilter runs = new RecurringEventRunFilter();
			runs.InstanceID = instanceID;
			return runs.GetRowset();
		}

		public Rowset.IMTSQLRowset GetRunDetailsRowset(int runID)
		{
			// TODO: implement me!
			return null;
		}


		public int CreateAdapterTest(RecurringEvent recurringEvent, RecurringEventRunContext context)
		{
			return mEventManager.CreateAdapterTest(recurringEvent, context);
		}

    public void ProcessEvents(out int executions, out int executionFailures,
															out int reversals,  out int reversalFailures)
		{
			mEventManager.ProcessEvents(out executions, out executionFailures,
																	out reversals, out reversalFailures);
		}

	  public void ProcessEvents(HaltProcessingCallback callback,
															out int executions, out int executionFailures,
															out int reversals,  out int reversalFailures)
		{
			mEventManager.ProcessEvents(callback,
																	out executions, out executionFailures,
																	out reversals, out reversalFailures);
		}

    public void ProcessEvents(HaltProcessingCallback callback,                      
                      ProcessingConfig processingConfiguration,
                      out int executions, out int executionFailures,
                      out int reversals, out int reversalFailures)
    {
      //if (processingConfiguration != null && processingConfiguration.MaximumNumberOfEventsToProcessConcurrently > 0)
      //{
        mEventManager.ProcessEventsConcurrently(callback, processingConfiguration,
                                    out executions, out executionFailures,
                                    out reversals, out reversalFailures);
      //}
      //else
      //{
      //  mEventManager.ProcessEvents(callback,
      //                      out executions, out executionFailures,
      //                      out reversals, out reversalFailures);
      //}
    }
		public IRecurringEvent GetEventByName(string eventName)
		{
			RecurringEventFilter filter = new RecurringEventFilter();
			filter.Name = eventName;

			// TODO: clean this up
			// there should be only one recurring event
			foreach(RecurringEvent recurringEvent in filter)
				return recurringEvent;

			throw new UsageServerException(String.Format("Unable to find event with the name of '{0}'!", eventName));
		}

		public IRecurringEvent GetEventByID(int eventID)
		{
			RecurringEventFilter filter = new RecurringEventFilter();
			filter.EventID = eventID;

			// there should be only one recurring event
			foreach(RecurringEvent recurringEvent in filter)
				return recurringEvent;
		
			throw new UsageServerException(String.Format("Unable to find event with ID {0}!", eventID));
		}

		public IRecurringEvent GetEventByInstance(int instanceID)
		{
			RecurringEventFilter filter = new RecurringEventFilter();
			filter.AddInstanceID(instanceID);

			// there should be only one recurring event
			foreach(RecurringEvent recurringEvent in filter)
				return recurringEvent;
		
			throw new UsageServerException(String.Format("Unable to find event related to instance {0}!", instanceID));
		}

		public void GetUsageIntervalInfo(int intervalID, out DateTime startDate,
																		 out DateTime endDate, out string status)
		{
			mIntervalManager.GetUsageIntervalInfo(intervalID, out startDate, out endDate, out status);
		}


		public void Bootstrap()
		{
			CreateUsageCycles();
			CreateReferenceIntervals();
		}

		/// <summary>
		/// Notifies the BillingServer service that there are potential recurring events to process
		/// </summary>
		public void NotifyServiceOfSubmittedEvents()
		{
      try
      {
        Signaller.GetInstance.Send(Signaller.SignallerMessage.ProcessRecurringEvents);
      }
      catch (Exception e)
      {
        throw new UsageServerException("Error occured while notifying the BillingServer service of submitted events!", e);
      }
		}

		/// <summary>
		/// Notifies the BillingServer service that configuration information
		/// has changed.
		/// </summary>
		public void NotifyServiceOfConfigChange()
		{
			try
			{
        Signaller.GetInstance.Send(Signaller.SignallerMessage.ConfigChanged);
			}
			catch (Exception e)
			{
        ILogger logger = new Logger("[UsageServer]");
        logger.LogWarning("Billing Server service could not be informed of the configuration change. " +
                          "It will need to be restarted manually to reflect configuration changes (if any were made).");

				throw new UsageServerException("Error occured while notifying the BillingServer service of a config refresh!", e);
			}
		}

		// TODO: move impl somewhere else
		public bool Wait(int timeout)
		{
			ILogger logger = new Logger("[UsageServer]");
			int sleepPeriod = 1 * 30 * 1000; // sleep 30s before rechecking

      // Read the cross-server configuration values that we need.
      ConfigCrossServer config = ConfigCrossServerManager.GetConfig();
      bool softClose = config.isAutoSoftCloseBillGroupsEnabled;
      bool submitEvents = config.isAutoRunEopOnSoftCloseEnabled;

			// Read local (usagesever.xml) configuration values that we need.
			MTXmlDocument doc = new MTXmlDocument();
			doc.LoadConfigFile(UsageServerCommon.UsageServerConfigFile);
			bool submitCheckpoints = doc.GetNodeValueAsBool("/xmlconfig/Service/SubmitCheckpointsForExecution");

			// calculates the point in time at which we will give up waiting
			DateTime stopTime;
			if (timeout > 0)
				stopTime = DateTime.Now.AddSeconds(timeout);
			else
				stopTime = DateTime.MaxValue;


			if (softClose)
			{

				//
				// waits for all relevant intervals to be materialized
				//
				while (true)
				{
					logger.LogInfo("Waiting for billing groups to materialize...");
					int intervals =  MaterializeBillingGroups(true);
					if (intervals == 0) 	// all intervals have been materialized
						break;

					if (DateTime.Now > stopTime)
						return false;

					System.Threading.Thread.Sleep(sleepPeriod);
				}
				logger.LogInfo("All billing groups have now been materialized");


				//
				// waits for all billing groups to be soft-closed
				//
				while (true)
				{
					logger.LogInfo("Waiting for billing groups to soft close...");
					ArrayList intervals = SoftCloseUsageIntervals(true);  // pretends to close
					if (intervals.Count == 0) // no intervals need to be closed anymore
						break;

					if (DateTime.Now > stopTime)
						return false;

					System.Threading.Thread.Sleep(sleepPeriod);
				}
				logger.LogInfo("All billing groups have now been soft closed");

			}

			//
			// waits for all instances to be submitted
			//
			if (submitEvents)
			{
				while (true)
				{
					logger.LogInfo("Waiting for all recurring event instances to be submitted for execution...");
					RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
					instances.AddStatusCriteria(RecurringEventInstanceStatus.NotYetRun);
					instances.AddEventTypeCriteria(RecurringEventType.Scheduled);
					instances.AddEventTypeCriteria(RecurringEventType.EndOfPeriod);
			
					// select checkpoints only if explicitly requested
					if (submitCheckpoints)
						instances.AddEventTypeCriteria(RecurringEventType.Checkpoint);
			
					instances.Apply();
					if (instances.Count == 0)
						break;

					if (DateTime.Now > stopTime)
						return false;

					System.Threading.Thread.Sleep(sleepPeriod);
				}
				logger.LogInfo("All recurring event instances have now been submitted for execution");
			}

			//
			// wait for all instances to complete processing
			//
			while (true)
			{
				logger.LogInfo("Waiting for all recurring event instances to complete processing...");
				RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
				instances.AddStatusCriteria(RecurringEventInstanceStatus.ReadyToRun);
				instances.AddStatusCriteria(RecurringEventInstanceStatus.Running);
				instances.AddEventTypeCriteria(RecurringEventType.Scheduled);
				instances.AddEventTypeCriteria(RecurringEventType.EndOfPeriod);
				
				// select checkpoints only if explicitly requested
				if (submitCheckpoints)
					instances.AddEventTypeCriteria(RecurringEventType.Checkpoint);
				
				instances.Apply();
				if (instances.Count == 0)
					break;
				
				if (DateTime.Now > stopTime)
					return false;
				
				System.Threading.Thread.Sleep(sleepPeriod);
			}
			logger.LogInfo("All recurring event instances have now completed processing");

			return true;
		}

		/// <summary>
		/// Notifies the BillingServer service to kill the currently processing recurring event
		/// in a safe manner.
		/// </summary>
		public void KillCurrentlyProcessingRecurringEvent()
		{
			try
			{
        Signaller.GetInstance.Send(Signaller.SignallerMessage.KillRecurringEvent);
      }
			catch (Exception e)
			{
				throw new UsageServerException("Error occured while killing the recurring event currently being processed!", e);
			}
		}

		/// <summary>
		/// Implements a sleep in managed code. 
		/// Used to keep aborts responsive on MeterRowset based adapters.
		/// INTERNAL USE ONLY
		/// </summary>
		public void ManagedSleep(int millisecondsTimeout)
		{
			System.Threading.Thread.Sleep(millisecondsTimeout);
		}

		/// <summary>
		/// Determines if any instance of the named event is currently running.
		/// </summary>
		public bool IsAdapterRunning(string eventName)
		{
			return mEventManager.IsAdapterRunning(eventName);
		}

    /// <summary>
    ///   No longer supported! Use intervals.GetIntervals() instead.
    /// </summary>
    /// <param name="status"></param>
    /// <returns></returns>
    public Rowset.IMTSQLRowset GetUsageIntervalsRowset(UsageIntervalStatus status)
    {
      UsageIntervalFilter intervals = new UsageIntervalFilter();
      intervals.Status = status;
      return intervals.GetRowset();
    }

    public Rowset.IMTSQLRowset GetEndOfPeriodInstancesRowset(int intervalID)
    {
      RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
      instances.UsageIntervalID = intervalID;
      return instances.GetEndOfPeriodRowset(true, true);
    }
    
#region Billing Groups
    
    /// <summary>
    ///   No longer supported!. Use filter.GetIntervals instead.
    /// </summary>
    /// <param name="filter"></param>
    /// <returns></returns>
    public Rowset.IMTSQLRowset GetUsageIntervalsRowset(UsageIntervalFilter filter)
    {
      return filter.GetRowset();
    }

    public Rowset.IMTSQLRowset GetUsageIntervalsRowsetRedux(UsageIntervalFilter filter)
    {
      return filter.GetRowsetRedux();
    }

    public IUsageInterval GetUsageInterval(int intervalID)
    {
      return mIntervalManager.GetUsageInterval(intervalID);
    }

    public int MaterializeBillingGroups()
    {
      if (mSessionContext == null)
      {
        throw new ApplicationException(MISSING_SESSION_CONTEXT);
      }

      return mBillingGroupManager.MaterializeBillingGroups(mSessionContext.AccountID);
    }

    public int MaterializeBillingGroups(bool pretend)
    {
      return mBillingGroupManager.MaterializeBillingGroups(mSessionContext.AccountID, pretend);
    }

    public int MaterializeBillingGroups(int intervalID)
    {

     if (mSessionContext == null)
     {
       throw new ApplicationException(MISSING_SESSION_CONTEXT);
     }

      return mBillingGroupManager.MaterializeBillingGroups(intervalID, mSessionContext.AccountID);
                                                         
    }

    public int ReMaterializeBillingGroups(int intervalID)
    {
      if (mSessionContext == null)
      {
        throw new ApplicationException(MISSING_SESSION_CONTEXT);
      }

      return mBillingGroupManager.MaterializeBillingGroups(intervalID, mSessionContext.AccountID);
    }

    public int GetLastMaterializationIDWithReassignmentWarnings(int intervalID)
    {
      return mBillingGroupManager.GetLastMaterializationIDWithReassignmentWarnings(intervalID);
    }

    public Rowset.IMTSQLRowset GetMaterializationReassignmentWarnings(int materializationID)
    {
      return mBillingGroupManager.GetMaterializationReassignmentWarnings(materializationID);
    }

    public int FindBillingGroupIDByMember(string userName, string nameSpace, int intervalId)
    {
      return mBillingGroupManager.FindBillingGroupIDByMember(userName, nameSpace, intervalId);
    }
    
    public int FindBillingGroupIDByMember(int accountId, int intervalId)
    {
      return mBillingGroupManager.FindBillingGroupIDByMember(accountId, intervalId);
    }

    public Rowset.IMTSQLRowset GetBillingGroupsRowset(int usageIntervalID, 
                                                      bool isFlattened)
    {
      return mBillingGroupManager.
              GetBillingGroupsRowset(usageIntervalID, isFlattened);
    }

    public Rowset.IMTSQLRowset GetBillingGroupsRowset(IBillingGroupFilter filter)
    {
      return mBillingGroupManager.GetBillingGroupsRowset(filter);
    }

    /// <summary>
    ///   Gets the Billing Group object
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>IBillingGroup</returns>
    public IBillingGroup GetBillingGroup(int billingGroupID)
    {
      return mBillingGroupManager.GetBillingGroup(billingGroupID);
    }

    /// <summary>
    ///   Gets the Billing Group list that has been created from the parent group.
    /// </summary>
    /// <param name="parentBillingGroupID"></param>
    /// <returns>
    ///   BillingGroupID
    ///   Name
    ///   Description
    ///   Status
    ///   MemberCount
    ///   AdapterCount
    ///   AdapterSucceededCount
    ///   AdapterFailedCount
    ///   HasChildren
    ///   ParentBillingGroupID
    ///   ParentBillingGroupName
    ///   
    ///   Sorted by:  Name ASC
    /// </returns>  
    public Rowset.IMTSQLRowset GetDescendantBillingGroupsRowset(int parentBillingGroupID)
    {
      return mBillingGroupManager.GetDescendantBillingGroupsRowset(parentBillingGroupID);
    }

    public Rowset.IMTSQLRowset GetBillingGroupMembersRowset(int billingGroupID, Rowset.IMTDataFilter filter)
    {
      return mBillingGroupManager.GetBillingGroupMembersRowset(billingGroupID, filter);
    }

    /// <summary>
    ///   Gets a rowset containing end-of-period instances for the given interval.
    /// </summary>
    /// <param name="billingGroupID"></param>
    /// <returns>
    ///   evt.id_event EventID,
    ///   evt.tx_name EventName,
    ///   evt.tx_display_name EventDisplayName,
    ///   evt.tx_type EventType,
    ///   evt.tx_reverse_mode ReverseMode,
    ///   evt.tx_class_name ClassName,
    ///   evt.tx_config_file ConfigFile,
    ///   evt.tx_desc EventDescription,
    ///   inst.id_instance InstanceID,
    ///   inst.id_arg_interval ArgIntervalID,
    ///   inst.b_ignore_deps IgnoreDeps,
    ///   inst.dt_effective EffectiveDate,    
    ///   inst.tx_status Status,           --- "ReadyToRun", "ReadyToReverse", "NotYetRun", "Failed"
    ///   run.id_run LastRunID,
    ///   run.tx_type LastRunAction,
    ///   run.dt_start LastRunStart,
    ///   run.dt_end LastRunEnd,
    ///   run.tx_status LastRunStatus,
    ///   run.tx_detail LastRunDetail,
    ///   ISNULL(batch.total, 0) LastRunBatches,
    ///   COUNT(dep.id_event) TotalDeps,
    ///   ISNULL(warnings.total, 0) LastRunWarnings
    ///   IsGlobalAdapter
    /// </returns>
    public Rowset.IMTSQLRowset GetEndOfPeriodInstancesRowset2(int billingGroupID)
    {
      return null;
    }

	public bool HasEventSucceeded(string aEventName, int aBillingGroupID)
	{
		RecurringEventInstanceFilter instances = new RecurringEventInstanceFilter();
		instances.BillingGroupID = aBillingGroupID;
		instances.EventName = aEventName;
		Rowset.IMTSQLRowset rowset = instances.GetEndOfPeriodRowset(true, true);
		// should return rowset of one.

		// Check that the status is 'success'
		while (!System.Convert.ToBoolean(rowset.EOF))
		{
			string status = (string) rowset.get_Value("Status");
			if (String.Compare(status, "Succeeded", true) == 0)
				return true;

			rowset.MoveNext();
		}

		return false;
	}

    /// <summary>
    ///   Returns the list of accounts that had failures durring the run.
    /// </summary>
    /// <param name="runID"></param>
    /// <returns>
    ///   DisplayName
    ///   UserName
    ///   Namespace
    ///   AccountID
    ///   AdapterName
    ///   
    ///   Sort on:  DisplayName ASC
    /// </returns>
    public Rowset.IMTSQLRowset GetFailureAccountsRowset(int runID, Rowset.IMTDataFilter filter)
    {
      return null;
    }
    
    public int CreateUserDefinedBillingGroupFromAllUnassignedAccounts(int intervalID, string name, string description)
    {
      
      if (mSessionContext == null)
      {
        throw new ApplicationException(MISSING_SESSION_CONTEXT);
      }

      return mBillingGroupManager.
        CreateUserDefinedBillingGroupFromAllUnassignedAccounts
          (intervalID, mSessionContext.AccountID, name, description);
    }

    public int CreateUserDefinedBillingGroupFromAccounts(int intervalID, string name, string description, string accounts)
    {
      if (mSessionContext == null)
      {
        throw new ApplicationException(MISSING_SESSION_CONTEXT);
      }

      return mBillingGroupManager.
        CreateUserDefinedBillingGroupFromAccounts(intervalID, 
                                                  mSessionContext.AccountID, 
                                                  name, 
                                                  description, 
                                                  accounts);
    }

    public int CreateUserDefinedBillingGroupFromFile(int intervalID, string name, string description, string fileName)
    {
      return -1;
    }

    /// <summary>
    ///   The start of creating a Pull List automatically from the 
    ///   failure accounts reported by a run
    /// </summary>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="parentBillingGroupID"></param>
    /// <param name="accounts"></param>
    /// <param name="needsExtraAccounts"></param>
    /// <returns>Materialization ID</returns>
    public int StartChildGroupCreationFromFailedRunID(string name, 
      string description, 
      int runID, 
      out bool needsExtraAccounts)
    {
      needsExtraAccounts = false;
      return -1;
    }
    
    /// <summary>
    ///   The start of a Pull List.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="parentBillingGroupID"></param>
    /// <param name="accounts">comma separated list of account identifiers</param>
    /// <param name="needsExtraAccounts"></param>
    /// <returns>Materialization ID</returns>
    public int StartChildGroupCreationFromAccounts(string name, 
                                                   string description, 
                                                   int parentBillingGroupID, 
                                                   string accounts, 
                                                   out bool needsExtraAccounts)
    {
      
      if (mSessionContext == null)
      {
        throw new ApplicationException(MISSING_SESSION_CONTEXT);
      }

      return mBillingGroupManager.
        StartChildGroupCreationFromAccounts(name,
                                            description,
                                            parentBillingGroupID,
                                            accounts,
                                            out needsExtraAccounts,
                                            mSessionContext.AccountID); 
    }

    /// <summary>
    ///   The start of a Pull List.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="parentBillingGroupID"></param>
    /// <param name="fileName"></param>
    /// <param name="needsExtraAccounts"></param>
    /// <returns>Materialization ID</returns>
    public int StartChildGroupCreationFromFile(string name, 
      string description, 
      int parentBillingGroupID, 
      string fileName, 
      out bool needsExtraAccounts)
    {
      needsExtraAccounts = false;
      return -1;
    }
    
    public Rowset.IMTSQLRowset GetNecessaryChildGroupAccounts(int materializationID)
    {
      return mBillingGroupManager.GetNecessaryChildGroupAccounts(materializationID);
    }

    /// <summary>
    ///   Aborts the creation of the child group associated with the given
    ///   materializationID
    /// </summary>
    /// <param name="materializationID"></param>
    public void AbortChildGroupCreation(int materializationID)
    {
      mBillingGroupManager.AbortChildGroupCreation(materializationID);
    }

    public int FinishChildGroupCreation(int materializationID)
    {
      return mBillingGroupManager.FinishChildGroupCreation(materializationID);
    }

    public Rowset.IMTSQLRowset GetUnassignedAccountsForIntervalAsRowset(IUnassignedAccountsFilter filter)
    {
      return mBillingGroupManager.GetUnassignedAccountsForIntervalAsRowset(filter);
    }

    public Rowset.IMTSQLRowset 
      SetAccountStatusToHardClosedForInterval(Coll.IMTCollection accounts, 
                                              int intervalId, 
                                              bool backoutAndResubmitUsage)
    {
      // !TODO The session context cannot be null
      if (mSessionContext == null) 
      {
        Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
        mSessionContext = loginContext.Login("su", "system_user", "su123");
      }

      return 
        mBillingGroupManager.
          SetAccountStatusToHardClosedForInterval(accounts,
                                                  intervalId,
                                                  backoutAndResubmitUsage,
                                                  this.mSessionContext);
    }

    public void SetIntervalAsBlockedForNewAccounts(int intervalId)
    {
      mBillingGroupManager.SetIntervalAsBlockedForNewAccounts(intervalId);
    }

    public int BlockExpiredIntervals() 
    {
      return mBillingGroupManager.BlockExpiredIntervals();
    }

    public int HardCloseExpiredIntervalsWithNoPayingAccounts()
    {
      return mBillingGroupManager.HardCloseExpiredIntervalsWithNoPayingAccounts();
    }

    /// <summary>
    ///   Return the value of <BillingGroups>\<AllowPullList> in usageserver.xml 
    /// </summary>
    /// <returns></returns>
    public bool AllowPullLists()
    {
      return mBillingGroupManager.AllowPullLists();
    }

    public bool HasBeenFullyMaterialized(int intervalId)
    {
      return mBillingGroupManager.HasBeenFullyMaterialized(intervalId);
    }

    /// <summary>
    ///   Set the ignoredeps status of the EndRoot event (in t_recevent_inst) for the given billingGroupId to 'Y'.
    /// </summary>
    /// <param name="billingGroupId"></param>
    public void IgnoreEndRootDependenciesForBillingGroup(int billingGroupId)
    {
      mBillingGroupManager.IgnoreEndRootDependenciesForBillingGroup(billingGroupId);
    }

    /// <summary>
    ///   Set the ignoredeps status of all the EndRoot events (in t_recevent_inst) for the given intervalId to 'Y'.
    /// </summary>
    /// <param name="intervalId"></param>
    public void IgnoreEndRootDependenciesForInterval(int intervalId)
    {
      mBillingGroupManager.IgnoreEndRootDependenciesForInterval(intervalId);
    }

#endregion

    private string mMachineIdentifier = null;

		private Auth.IMTSessionContext mSessionContext = null;

		private const string MISSING_SESSION_CONTEXT = 
			"Caller must first set a valid session context before calling this method!";

	}
}

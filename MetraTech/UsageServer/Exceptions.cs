namespace MetraTech.UsageServer
{
	using System;
	using System.Diagnostics;
	using System.Xml;
	using System.Text;
	using System.Runtime.InteropServices;


	/// <summary>
	/// The base class of all Usage Server exceptions
	/// </summary>
	[ComVisible(false)]
	public class UsageServerException : ApplicationException 
	{ 

		protected Logger mLogger;

		// logs the message only
		public UsageServerException(string message)
			: base(message)
		{
			mLogger = new Logger("[UsageServer]");
			mLogger.LogError(message);
		}

    // logs the message only
    public UsageServerException(string message, LogLevel logLevel)
      : base(message)
    {
      mLogger = new Logger("[UsageServer]");
      switch(logLevel) 
      {
        case LogLevel.Fatal:
        {
          mLogger.LogFatal(message);
          break;
        }
        case LogLevel.Error:
        {
          mLogger.LogError(message);
          break;
        }
        case LogLevel.Warning:
        {
          mLogger.LogWarning(message);
          break;
        }
        case LogLevel.Info:
        {
          mLogger.LogInfo(message);
          break;
        }
        case LogLevel.Debug:
        {
          mLogger.LogDebug(message);
          break;
        }
        default :
        {
          throw new UsageServerException("Invalid log level specified: " + logLevel.ToString());
        }
      }
    }

		// logs the message and a rough stack trace
		public UsageServerException(string message, bool logStackTrace)
			: base(message)
		{
			mLogger = new Logger("[UsageServer]");
			mLogger.LogError(message);

			// the stack trace is set in an exception just before it is thrown
			// since this is construction time, the exception's stack trace is null.
			// because of this, the environment stack trace is used which will have a
			// couple of extra layers on it (i.e., this ctor)
			if (logStackTrace)
				mLogger.LogError(Environment.StackTrace);
		}

		// logs the message only, sets the source exception as the inner exception
		public UsageServerException(string message, UsageServerException source)
			: base(message, source)
		{
			mLogger = new Logger("[UsageServer]");
			mLogger.LogError(message);
			// doesn't log the source exception since it has already been logged
		}

		// logs the message and full source exception
		public UsageServerException(string message, Exception source)
			: base(message, source)
		{
			mLogger = new Logger("[UsageServer]");
			mLogger.LogError(message);
			mLogger.LogError(source.ToString());
		}
	}

  /// <summary>
  ///   Enum for log levels
  /// </summary>
  [ComVisible(false)]
  public enum LogLevel
  {
    Fatal = 1,
    Error = 2,
    Warning = 3,
    Info = 4,
    Debug = 5
  }

	/// <summary>
	/// An exception thrown when an invalid configuration is attempted
	/// (occurring either in usageserver.xml or recurring_events.xml)
	/// This is a general exception used when no specific exception exists
	/// for configuration related exceptions.
	/// </summary>
	[ComVisible(false)]
	public class InvalidConfigurationException : UsageServerException 
	{ 
		public InvalidConfigurationException(string message)
			: base(message)
		{ }

		public InvalidConfigurationException(string message, Exception e)
			: base(message, e)
		{ }
	}

	/// <summary>
	/// An exception representing an event which could not be found
	/// </summary>
	[ComVisible(false)]
	public class RecurringEventNotFoundException : UsageServerException
	{ 
		const string msg = "The recurring event '{0}' was not found!";

		public RecurringEventNotFoundException(string eventName)
			: base(String.Format(msg, eventName))
		{ }

		public RecurringEventNotFoundException(string eventName, string hint)
			: base(String.Format(msg + " {1}", eventName, hint))
		{ }
	}

	/// <summary>
	/// An exception representing an event whose name conflicts with another event
	/// </summary>
	[ComVisible(false)]
	public class DuplicateRecurringEventNameException : UsageServerException
	{ 
		const string msg = "Duplicate recurring events named '{0}' found in extensions '{1}' and '{2}'!";

		public DuplicateRecurringEventNameException(string eventName, string extension, string otherExtension)
			: base(String.Format(msg, eventName, extension, otherExtension))
		{ }
	}

	/// <summary>
	/// An exception representing an event whose name conflicts with reserved system keyword
	/// </summary>
	[ComVisible(false)]
	public class ReservedRecurringEventNameException : UsageServerException
	{ 
		const string msg = "The recurring event name '{0}' is reserved for system use!";

		public ReservedRecurringEventNameException(string eventName)
			: base(String.Format(msg, eventName))
		{ }
	}

	/// <summary>
	/// An exception representing an event whose name is missing
	/// </summary>
	[ComVisible(false)]
	public class MissingRecurringEventNameException : UsageServerException
	{ 
		const string msg = "The recurring event must have a non-empty name!";

		public MissingRecurringEventNameException()
			: base(msg)
		{ }

		public MissingRecurringEventNameException(string details)
			: base(String.Format(msg + " {0}", details))
		{ }
	}

	/// <summary>
	/// An exception representing when a recurring event uses a normal
	/// usage cycle type when at least one other event is using the
	/// special 'All' cycle type.
	/// </summary>
	[ComVisible(false)]
	public class NonExclusiveUsageCycleTypeException : UsageServerException
	{ 
		const string msg = 
			"Recurring event '{0}' must use the usage cycle type 'All' " +
			"since at least one other event uses 'All'.";

		public NonExclusiveUsageCycleTypeException(string eventName)
			: base(String.Format(msg, eventName))
		{ }
	}

	/// <summary>
	/// An exception representing a circular dependency
	/// </summary>
	[ComVisible(false)]
	public class CircularDependencyException : UsageServerException
	{ 
		const string msg = "Circular dependency detected on recurring event '{0}'!";

		public CircularDependencyException(string eventName)
			: base(String.Format(msg, eventName))
		{ }
	}

	/// <summary>
	/// An exception representing a scheduled event depending on an end-of-period event
	/// </summary>
	[ComVisible(false)]
	public class IncompatibleEventTypeDependencyException : UsageServerException
	{ 
		const string msg = 
			"Recurring event '{0}' cannot depend on event '{1}' " +
			"because a scheduled event cannot depend on an end-of-period event!";

		public IncompatibleEventTypeDependencyException(string eventName, string depEventName)
			: base(String.Format(msg, eventName, depEventName))
		{ }
	}

	/// <summary>
	/// An exception representing a EOP event depending on another EOP event
	/// with an incompatible usage cycle type
	/// </summary>
	[ComVisible(false)]
	public class IncompatibleUsageCycleTypeDependencyException : UsageServerException
	{ 
		const string msg = 
			"Recurring event '{0}' with recurrence pattern '{1}' " +
			"cannot depend on event '{2}' with incompatible recurrence pattern '{3}'!";

		public IncompatibleUsageCycleTypeDependencyException(string eventName,
																												 RecurringEventSchedule eventSchedule,
																												 string depEventName,
																												 RecurringEventSchedule depSchedule)
			: base(String.Format(msg, eventName, eventSchedule, depEventName, depSchedule))
		{ }
	}

	/// <summary>
	/// An exception representing an event configured as EOP but 
	/// points to an adapter with no EOP support
	/// </summary>
	[ComVisible(false)]
	public class NoEndOfPeriodSupportException : UsageServerException
	{ 
		const string msg = 
			"Recurring event '{0}' is in the <EndOfPeriodAdapters> group but " +
			"the adapter '{1}' does not contain end-of-period support!"; 

		public NoEndOfPeriodSupportException(RecurringEvent recurringEvent)
			: base(String.Format(msg, recurringEvent.Name, recurringEvent.ClassName))
		{ }
	}

	/// <summary>
	/// An exception representing an event configured as EOP but 
	/// points to an adapter with no EOP support
	/// </summary>
	[ComVisible(false)]
	public class NoScheduledSupportException : UsageServerException
	{ 
		const string msg = 
			"Recurring event '{0}' is in the <ScheduledAdapters> block but " +
			"the adapter ('{1}') does not support scheduled events!";

		public NoScheduledSupportException(RecurringEvent recurringEvent)
			: base(String.Format(msg, recurringEvent.Name, recurringEvent.ClassName))
		{ }
	}

	/// <summary>
	/// An exception representing a failed creation of an adapter object
	/// </summary>
	[ComVisible(false)]
	public class AdapterCreationException : UsageServerException
	{ 
		const string msg = "Could not create instance of adapter class '{0}'!";

		public AdapterCreationException(string className, string bindingLog)
			: base(String.Format(msg, className))
		{
			mLogger.LogError("Binding log:\n{0}", bindingLog);
		}
	}

	/// <summary>
	/// An exception representing a failed initialization of an adapter
	/// </summary>
	[ComVisible(false)]
	public class AdapterInitializationException : UsageServerException
	{ 
		const string msg = "Initialization of adapter '{0}' failed! limited = {1}";

		public AdapterInitializationException(string eventName, bool limitedInit, Exception source)
			: base(String.Format(msg, eventName, limitedInit), source)
		{ }
	}

	/// <summary>
	/// An exception representing a failed execution of an adapter
	/// </summary>
	[ComVisible(false)]
	public class AdapterExecutionException : UsageServerException
	{ 
		const string msg = "Execution of adapter '{0}' failed!";

		public AdapterExecutionException(string eventName, Exception source)
			: base(String.Format(msg, eventName), source)
		{ }
	}

	/// <summary>
	/// An exception representing a failed reversal of an adapter
	/// </summary>
	[ComVisible(false)]
	public class AdapterReversalException : UsageServerException
	{ 
		const string msg = "Reversal of adapter '{0}' failed!";

		public AdapterReversalException(string eventName, Exception source)
			: base(String.Format(msg, eventName), source)
		{ }
	}

	/// <summary>
	/// An exception representing a failed shutdown of an adapter
	/// </summary>
	[ComVisible(false)]
	public class AdapterShutdownException : UsageServerException
	{ 
		const string msg = "Shutdown of adapter '{0}' failed!";

		public AdapterShutdownException(string eventName, Exception source)
			: base(String.Format(msg, eventName), source)
		{ }
	}

	/// <summary>
	/// An exception representing a negative value for a configuration setting
	/// </summary>
	[ComVisible(false)]
	public class NegativeValueException : UsageServerException
	{ 
		const string msg = "The {0} setting must be non-negative! value = {1}";

		public NegativeValueException(string name, int badValue)
			: base(String.Format(msg, name, badValue))
		{ }
	}

	/// <summary>
	/// An exception representing an incorrect version of a config file
	/// </summary>
	[ComVisible(false)]
	public class ConfigFileVersionMismatchException : UsageServerException
	{ 
		const string msg = "The configuration file '{0}' is version {1} but version {2} is required. Please upgrade!";

		public ConfigFileVersionMismatchException(string filename, int oldVersion, int requiredVersion)
			: base(String.Format(msg, filename, oldVersion, requiredVersion))
		{ }
	}

	/// <summary>
	/// An exception representing an attempt to read the day value of a
	/// grace period setting which is disabled
	/// </summary>
	[ComVisible(false)]
	public class SoftCloseGracePeriodDisabledException : UsageServerException
	{ 
		const string msg = "Cannot use this method to access the {0} grace period value because it is disabled!";

		public SoftCloseGracePeriodDisabledException(CycleType cycleType)
			: base(String.Format(msg, cycleType))
		{ }
	}


	/// <summary>
	/// An exception representing an attempt to perform some action on
	/// a non-existent recurring event instance
	/// </summary>
	[ComVisible(false)]
	public class RecurringEventInstanceNotFoundException : UsageServerException
	{ 
		const string msg = "Recurring event instance {0} was not found!";

		public RecurringEventInstanceNotFoundException(int instanceID)
			: base(String.Format(msg, instanceID))
		{ }
	}


	/// <summary>
	/// An exception representing an attempt to submit a recurring event
	/// for reversal but the instance is in an invalid state.
	/// </summary>
	[ComVisible(false)]
	public class SubmitEventForReversalInvalidStateException : UsageServerException
	{ 
		const string msg = 
			"Recurring event instance {0} must be in the state of 'Succeeded' " +
			"or 'Failed' in order to be submitted for reversal!";

		public SubmitEventForReversalInvalidStateException(int instanceID)
			: base(String.Format(msg, instanceID))
		{ }
	}

	/// <summary>
	/// An exception representing an attempt to submit a recurring event
	/// for execution but the instance is in an invalid state.
	/// </summary>
	[ComVisible(false)]
	public class SubmitEventForExecutionInvalidStateException : UsageServerException
	{ 
		const string msg = 
			"Recurring event instance {0} must be in the state of 'NotYetRun' in order to be submitted for execution!";

		public SubmitEventForExecutionInvalidStateException(int instanceID)
			: base(String.Format(msg, instanceID))
		{ }
	}

	/// <summary>
	/// An exception representing an attempt to submit a recurring event
	/// for reversal but the event is not reversible.
	/// </summary>
	[ComVisible(false)]
	public class RecurringEventNotReversibleException : UsageServerException
	{ 
		const string msg = "Recurring event related to instance {0} is not reversible!";

		public RecurringEventNotReversibleException(int instanceID)
			: base(String.Format(msg, instanceID))
		{ }
	}

	/// <summary>
	/// An exception representing an unsuccessful attempt to instantiate
	/// a scheduled event.
	/// </summary>
	[ComVisible(false)]
	public class InstantiateScheduledEventException : UsageServerException
	{ 
		const string msg = "Scheduled event {0} could not be instantiated: {1}";

		public InstantiateScheduledEventException(int instanceID, string details)
			: base(String.Format(msg, instanceID, details))
		{ }
	}

	/// <summary>
	/// An exception representing a failed attempt to (un)acknowledge a checkpoint
	/// due to unsatisfied depedencies.
	/// </summary>
	[ComVisible(false)]
	public class UnsatisfiedCheckpointDependenciesException : UsageServerException
	{ 
		const string msg = "Cannot acknowledge/unacknowledge checkpoint instance {0} due to unsatisfied dependencies!";

		public UnsatisfiedCheckpointDependenciesException(int instanceID)
			: base(String.Format(msg, instanceID))
		{ }
	}

	/// <summary>
	/// An exception representing bad XML data in a configuration file.
	/// </summary>
	[ComVisible(false)]
	public class BadXmlException : UsageServerException
	{ 
		const string msg = "Could not parse file '{0}' due to the following: {1}";

		public BadXmlException(string fileName, Exception e)
			: base(String.Format(msg, fileName, e.Message))
		{ }
	}

	/// <summary>
	/// An exception representing a usage interval that could not be found.
	/// </summary>
	[ComVisible(false)]
	public class UsageIntervalNotFoundException : UsageServerException
	{ 
		const string msg = "Usage interval {0} was not found!";

		public UsageIntervalNotFoundException(int intervalID)
			: base(String.Format(msg, intervalID))
		{ }
	}

	/// <summary>
	/// An exception representing a usage interval in an invalid state for the operation.
	/// </summary>
	[ComVisible(false)]
	public class InvalidUsageIntervalStateException : UsageServerException
	{ 
		public InvalidUsageIntervalStateException(string state)
			: base(String.Format("Operation cannot be performed because the associated usage interval is not in the {0} state!", state))
		{ }

		public InvalidUsageIntervalStateException(int intervalID, string state)
			: base(String.Format("Usage interval {0} must be in the {1} state!", intervalID, state))
		{ }
	}

  /// <summary>
  /// An exception representing a usage interval in an invalid state for the operation.
  /// </summary>
  [ComVisible(false)]
  public class InvalidBillingGroupStateException : UsageServerException
  { 
    public InvalidBillingGroupStateException(string state)
      : base(String.Format("Operation cannot be performed because the associated billing group is not in the {0} state!", state))
    { }

    public InvalidBillingGroupStateException(int billingGroupID, string state)
      : base(String.Format("Billing group {0} must be in the {1} state!", billingGroupID, state))
    { }
  }

	/// <summary>
	/// An exception representing an attempt to re-open a usage interval
	/// which still has instances that have not been reversed.
	/// </summary>
	[ComVisible(false)]
	public class NotAllEventsHaveBeenReversedException : UsageServerException
	{ 
		const string msg = "Not all relavent recurring event instances have been reversed for usage interval {0}!";

		public NotAllEventsHaveBeenReversedException(int intervalID)
			: base(String.Format(msg, intervalID))
		{ }
	}

  /// <summary>
  /// The adapter could not satisfy billing group constraints.
  /// </summary>
  [ComVisible(false)]
  public class CreateBillingGroupConstraintsException : UsageServerException
  { 
    const string msg = "Adapter '{0}' could not create billing group constraints!";

    public CreateBillingGroupConstraintsException(string eventName, Exception source)
      : base(String.Format(msg, eventName), source)
    { }
  }

  /// <summary>
  /// An exception occurred while attempting to split the reversal state.
  /// </summary>
  [ComVisible(false)]
  public class SplitReverseStateException : UsageServerException
  { 
    const string msg = "Adapter '{0}' could not split reversal state!";

    public SplitReverseStateException(string eventName, Exception source)
      : base(String.Format(msg, eventName), source)
    { }
  }

  /// <summary>
  /// An exception occurred while attempting to split the reversal state.
  /// </summary>
  [ComVisible(false)]
  public class InvalidUsageIntervalFilterOptionException : UsageServerException
  { 
    const string msg = "The '{0}' filter option is not supported on a Usage Interval!";

    public InvalidUsageIntervalFilterOptionException(string filterOption)
      : base(String.Format(msg, filterOption))
    { }
  }

  /// <summary>
  /// Attempting to materialize while a materialization is in progress for the
  /// same interval.
  /// </summary>
  [ComVisible(false)]
  public class MaterializationInProgressException : UsageServerException
  { 
    const string msg = "Billing group creation is already in progress " +
                       " for the interval '{0}'!";

    public MaterializationInProgressException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  /// <summary>
  /// Attempting to do full materialize on an interval which has
  /// already been fully materialized 
  /// </summary>
  [ComVisible(false)]
  public class RepeatFullMaterializationException : UsageServerException
  { 
    const string msg = "Cannot repeat billing group creation for the interval '{0}'!";

    public RepeatFullMaterializationException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  /// <summary>
  /// Could not complete the materialization process.
  /// </summary>
  [ComVisible(false)]
  public class CompleteMaterializationException : UsageServerException
  { 
    const string msg = "Error while trying to create billing groups " +
                       " for interval '{0}'! ";

    public CompleteMaterializationException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  /// <summary>
  /// Could not complete the materialization process.
  /// </summary>
  [ComVisible(false)]
  public class CompleteReMaterializationException : UsageServerException
  { 
    const string msg = "Error while trying to recreate billing groups" +
                       " for interval '{1}'! ";

    public CompleteReMaterializationException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  /// <summary>
  /// An exception occurred while attempting to validate adapter constraints.
  /// </summary>
  [ComVisible(false)]
  public class AdapterConstraintFailedException : UsageServerException
  { 
    const string msg = "One or more adapters could not satisfy billing group " +
                       "constraints!";
    
    public AdapterConstraintFailedException(Exception e)
      : base(msg, e)
    { }
  }
  
  /// <summary>
  /// An exception occurred while attempting to validate billing group assignments.
  /// </summary>
  [ComVisible(false)]
  public class BillingGroupAssignmentValidationFailedException : UsageServerException
  { 
    public BillingGroupAssignmentValidationFailedException(string msg)
      : base(String.Format(msg))
    { }
  }

  /// <summary>
  /// An exception occurred while trying to execute the billing group
  /// assignment or description query.
  /// </summary>
  [ComVisible(false)]
  public class BillingGroupAssignmentException : UsageServerException
  { 
    const string msg = 
      "The billing group assignment query " +
      "failed due to the following: {0}";

    public BillingGroupAssignmentException(Exception e)
      : base(String.Format(msg, e.Message))
    { }
  }

  /// <summary>
  /// An invalid account identifier.
  /// </summary>
  [ComVisible(false)]
  public class InvalidAccountIdException : UsageServerException
  { 
    const string msg = 
      "Could not convert an account to integer with the following error: '{0}'!";
     

    public InvalidAccountIdException(Exception e)
      : base(String.Format(msg, e.Message))
    { }
  }

  /// <summary>
  /// 
  /// </summary>
  [ComVisible(false)]
  public class MaterializingIntervalWithoutPayersException : UsageServerException
  { 
    const string msg = 
      "Cannot create billing groups for the interval '{0}' because " + 
      "it has no paying accounts!";

    public MaterializingIntervalWithoutPayersException(int intervalId, LogLevel logLevel)
      : base(String.Format(msg, intervalId), logLevel)
    { }
  }

  [ComVisible(false)]
  public class MaterializingHardClosedIntervalException : UsageServerException
  { 
    const string msg = 
      "Cannot create billing groups for the interval '{0}' because " + 
      "it is hard closed!";

    public MaterializingHardClosedIntervalException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class MaterializingWhileAdapterProcessingException : UsageServerException
  { 
    const string msg = 
      "Billing groups cannot be created for interval '{0}' because one or more " +
      "end-of-period adapters are running or reversing!";

    public MaterializingWhileAdapterProcessingException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class DuplicateAccountsInBillgroupSourceAccException : UsageServerException
  { 
    const string msg = 
      "Billing groups could not be created for interval {0} " +
      "because there are duplicate accounts in the driver table";

    public DuplicateAccountsInBillgroupSourceAccException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class DuplicateAccountsInConstraintGroupsException : UsageServerException
  { 
    const string msg = 
      "Billing group constraints cannot be created for interval {0} " +
      "because there are duplicate accounts in the constraint groups.";

    public DuplicateAccountsInConstraintGroupsException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class NonPayerAccountsInConstraintGroupsException : UsageServerException
  { 
    const string msg = 
      "Billing group constraints cannot be created for interval {0} " +
      "because there are non-payer accounts in the constraint groups.";

    public NonPayerAccountsInConstraintGroupsException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class IncorrectConstraintGroupIdException : UsageServerException
  { 
    const string msg = 
      "Billing group constraints cannot be created for interval {0} " +
      "because one or more constraint group id's don't match the " +
      "account id's in the group.";

    public IncorrectConstraintGroupIdException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class DuplicateAccountsInBillgroupMemberTmpException : UsageServerException
  { 
    const string msg = 
      "Billing groups could not be created for interval {0} " +
      "because there are duplicate accounts in the temporary billing groups table";

    public DuplicateAccountsInBillgroupMemberTmpException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class MissingAccountsFromBillgroupMemberTmpException : UsageServerException
  { 
    const string msg = 
      "Billing groups could not be created for interval {0} " +
      "because paying accounts are missing from the temporary billing groups table";

    public MissingAccountsFromBillgroupMemberTmpException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class EmptyBillingGroupInTmpException : UsageServerException
  { 
    const string msg = 
      "Billing groups could not be created for interval {0} " +
      "because one ore more billing groups in the temporary table have no accounts";

    public EmptyBillingGroupInTmpException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class DuplicateBillingGroupNamesInBillGroupTmpException : UsageServerException
  { 
    const string msg = 
      "Billing groups could not be created for interval {0} " +
      "because one ore more billing groups have the same name";

    public DuplicateBillingGroupNamesInBillGroupTmpException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class ParentBillingGroupNotSoftClosedException : UsageServerException
  { 
    const string msg = 
      "The pull list could not be created for interval {0} " +
      "because the parent billing group is not soft closed";

    public ParentBillingGroupNotSoftClosedException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  [ComVisible(false)]
  public class CreatingPullListsWithNoAccountsException : UsageServerException
  { 
    const string msg = 
      "The pull list {0} could not be created " +
      "because no accounts have been specified";

    public CreatingPullListsWithNoAccountsException(string pullListName, LogLevel logLevel)
      : base(String.Format(msg, pullListName), logLevel)
    { }
  }

  [ComVisible(false)]
  public class CreatingPullListWithAllParentMembersException : UsageServerException
  { 
    const string msg = 
      "The pull list {0} could not be created " +
      "because all of the parent billing group members have been specified";

    public CreatingPullListWithAllParentMembersException(string pullListName, LogLevel logLevel)
      : base(String.Format(msg, pullListName), logLevel)
    { }
  }

  [ComVisible(false)]
  public class CreatingPullListWithNonParentMembersException : UsageServerException
  { 
    const string msg = 
      "The pull list {0} could not be created " +
      "because one or more of the accounts do not belong to the parent billing group";

    public CreatingPullListWithNonParentMembersException(string pullListName, LogLevel logLevel)
      : base(String.Format(msg, pullListName), logLevel)
    { }
  }

  [ComVisible(false)]
  public class CreatingPullListWithDuplicateAccountsException : UsageServerException
  { 
    const string msg = 
      "Duplicate account id's specified for pull list {0}";

    public CreatingPullListWithDuplicateAccountsException(string pullListName, LogLevel logLevel)
      : base(String.Format(msg, pullListName), logLevel)
    { }
  }

  [ComVisible(false)]
  public class UnableToParseAccountsException : UsageServerException
  { 
    const string msg = 
      "No accounts could be parsed from the given data '{0}'";

    public UnableToParseAccountsException(string data)
      : base(String.Format(msg, data))
    { }
  }

  [ComVisible(false)]
  public class UnableToHardCloseIntervalException : UsageServerException
  { 
    const string msg = 
      "Cannot hard close interval {0} " +
      "because not all payer accounts are hard closed!";

    public UnableToHardCloseIntervalException(int intervalId)
      : base(String.Format(msg, intervalId))
    { }
  }

  
  
    
}

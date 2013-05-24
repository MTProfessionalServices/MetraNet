using System.Runtime.InteropServices;
[assembly: GuidAttribute("b6ad949f-25d4-4cd5-b765-3f6199ecc51c")]

namespace MetraTech.UsageServer
{
	using System;
	using System.Runtime.InteropServices;
	using System.Collections;
	using System.Diagnostics;
	using System.Threading;
  using System.Reflection;
  using System.IO;
    using System.Transactions;

	using MetraTech.DataAccess;
	using MetraTech.Xml;
  using MetraTech.Interop.MTAuth;
	using MetraTech.Pipeline;

	using RCD = MetraTech.Interop.RCD;
	using Auth = MetraTech.Interop.MTAuth;
	using DataExporter = MetraTech.Interop.MTDataExporter;
	using BillingReRun = MetraTech.Interop.MTBillingReRun;
	using BillingReRunClient = MetraTech.Pipeline.ReRun;
	using ServerAccess = MetraTech.Interop.MTServerAccess;

	/// <summary>
	/// Enumerates the different reverse modes available
	/// to an adapter to implement.
	/// </summary>
	[GuidAttribute("E3083484-899B-350B-AD63-9DA854AC3DEC")]
	public enum ReverseMode
	{
		/// <summary>
		/// Reverse functionallity is not implemented. Adapters based
		/// on the IMTDataExportAdapter2 interface will assume this mode.
		/// </summary>
		NotImplemented,

		/// <summary>
		/// Reverse functionallity is not needed. This mode should be used 
		/// for adapters that do not create any effects which need to be reversed.
		/// </summary>
		NotNeeded,

		/// <summary>
		/// Reverse functionallity is automatically provided by the infrastructure.
		/// This mode should be used by pure metering adapters. The adapter must
		/// meter usage in batches and associate its batches with its run ID.
		/// </summary>
  	Auto,

		/// <summary>
		/// Custom reverse functionallity is provided by the adapter.
		/// This mode should be used when Auto cannot. If this mode is
		/// used then <see cref="MetraTech.UsageServer.IRecurringEventAdapter.Reverse"/>
		/// must be implemented non-trivially.
		/// </summary>
		Custom
	}
	
  /// <summary>
  /// Type of Billing Group Support
  /// </summary>
  [Guid("A425B64E-6C98-4a9e-A6E6-F58B973DD1EF")]
  public enum BillingGroupSupportType
  {
		/// <summary>
		/// This adapter can only be run on the entire set of paying accounts on 
    /// a usage interval.
		/// </summary>
    Interval,
		/// <summary>
    /// This adapter may be run on the set of accounts in a billing group but does
    /// not support pull lists.
		/// </summary>
    BillingGroup,
		/// <summary>
    /// This adapter may be run on the set of accounts in a billing group and supports
    /// the creation of pull lists.
		/// </summary>
    Account
  }

	/// <summary>
	/// The base interface for all Usage Server adapters.
	/// </summary>
	[Guid("F3052EDE-BF2A-3879-B221-CED05C6E8E27")]
	public interface IRecurringEventAdapter
	{
		/// <summary>
		/// Initalizes the adapter. This method should always be called first before
		/// any other method. 
		/// </summary>
		/// <param name ="configFile">Optional adapter-defined configuration file</param>
		/// <param name ="context">The super user security context</param>
		/// <param name ="limitedInit">This signals the adapter to initialize
		/// in a limited manner. Only enough of the adapter should be initialized
		/// so that metadata can be returned to the system. If this is true, it is
		/// guaranteed that the adapter's Execute and Shutdown will never be called.</param>
		void Initialize(string eventName, string configFile,
										Auth.IMTSessionContext context, bool limitedInit);

		/// <summary>
		/// Executes the adapter.
		/// Returns a string consisting of the "detail" information
		/// </summary>
		/// <param name="context">The run context.</param>
		string Execute(IRecurringEventRunContext context);

		/// <summary>
		/// Reverses the adapter.
		/// Returns a string consisting of the "detail" information
		/// </summary>
		/// <param name="context">The run context.</param>
		string Reverse(IRecurringEventRunContext context);

		/// <summary>
		/// Shuts down the adapter.
		/// </summary>
		void Shutdown();
	
		/// <summary>
		/// Specifies whether the adapter can be triggered on scheduled events.
		/// </summary>
		/// <returns>True if supported, false otherwise</returns> 
		bool SupportsScheduledEvents 
		{ get; }

		/// <summary>
		/// Specifies whether the adapter can be triggered on end-of-period events.
		/// </summary>
		/// <returns>True if supported, false otherwise</returns> 
		bool SupportsEndOfPeriodEvents 
		{ get; }

		/// <summary>
		/// Specifies the adapter's level of reversibility.
		/// </summary>
		/// <returns> <see cref="MetraTech.UsageServer.ReverseMode"/> </returns>
		ReverseMode Reversibility
		{ get; }

		/// <summary>
		/// Determines whether an instance of the adapter can be run in parallel
		/// with other instances of the same adapter.
		/// </summary>
		/// <returns>True if allowed, false otherwise</returns> 
		bool AllowMultipleInstances
		{ get; }
	}

  /// <summary>
  /// All Usage Server adapters which need to support Billing Groups
  /// must derive from this interface.
  /// </summary>
  [Guid("D99B8308-04B9-489c-8BAE-9B3598D80B16")]
  public interface IRecurringEventAdapter2
  {
    /// <summary>
    /// Initalizes the adapter. This method should always be called first before
    /// any other method. 
    /// </summary>
    /// <param name ="configFile">Optional adapter-defined configuration file</param>
    /// <param name ="context">The super user security context</param>
    /// <param name ="limitedInit">This signals the adapter to initialize
    /// in a limited manner. Only enough of the adapter should be initialized
    /// so that metadata can be returned to the system. If this is true, it is
    /// guaranteed that the adapter's Execute and Shutdown will never be called.</param>
    void Initialize(string eventName, string configFile,
      Auth.IMTSessionContext context, bool limitedInit);

    /// <summary>
    /// Executes the adapter.
    /// Returns a string consisting of the "detail" information
    /// </summary>
    /// <param name="context">The run context.</param>
    string Execute(IRecurringEventRunContext context);

    /// <summary>
    /// Reverses the adapter.
    /// Returns a string consisting of the "detail" information
    /// </summary>
    /// <param name="context">The run context.</param>
    string Reverse(IRecurringEventRunContext context);

    /// <summary>
    /// Shuts down the adapter.
    /// </summary>
    void Shutdown();

    /// <summary>
    /// Adds additional accounts to the materialziation to satisfy any
    /// billing group constraints this adapter may have.
    /// </summary>
    /// <param name="materializationID">The ID of the current in-progress
    /// materialization</param>
    /// <param name="recurringEvent">The recurring event ID</param>
    /// <returns>True if any accounts were added, false otherwise</returns> 
    void CreateBillingGroupConstraints(int intervalID, int materializationID);


    /// <summary>
    /// Splits any custom reverse state during pull list materialization to 
    /// satisfy any billing group constraints this adapter may have.
    /// </summary>
    void SplitReverseState(int parentRunID, 
                           int parentBillingGroupID,
                           int childRunID, 
                           int childBillingGroupID);

	
    /// <summary>
    /// Specifies whether the adapter can be triggered on scheduled events.
    /// </summary>
    /// <returns>True if supported, false otherwise</returns> 
    bool SupportsScheduledEvents 
    { get; }

    /// <summary>
    /// Specifies whether the adapter can be triggered on end-of-period events.
    /// </summary>
    /// <returns>True if supported, false otherwise</returns> 
    bool SupportsEndOfPeriodEvents 
    { get; }

    /// <summary>
    /// Specifies the adapter's level of reversibility.
    /// </summary>
    /// <returns> <see cref="MetraTech.UsageServer.ReverseMode"/> </returns>
    ReverseMode Reversibility
    { get; }

    /// <summary>
    /// Determines whether an instance of the adapter can be run in parallel
    /// with other instances of the same adapter.
    /// </summary>
    /// <returns>True if allowed, false otherwise</returns> 
    bool AllowMultipleInstances
    { get; }

    /// <summary>
    /// Specifies whether the adapter can process billing groups as a group
    /// of accounts, as individual accounts or if it cannot process billing groups at all.
    /// This setting is only valid for end-of-period adapters.
    /// </summary>
    /// <returns>BillingGroupSupportType</returns> 
    BillingGroupSupportType BillingGroupSupport
    { get; }

    /// <summary>
    /// Specifies whether this adapter has special constraints on the membership
    /// of a billing group. 
    /// This setting is only valid for adapters that support billing groups.
    /// </summary>
    /// <returns>True if constraints exist, false otherwise</returns> 
    bool HasBillingGroupConstraints
    { get; }
  }

	/// <summary>
	/// The run context of the invoked adapter.
	/// </summary>
	[Guid("53E24365-02EC-34AD-BE01-3A383D49B4C4")]
	public interface IRecurringEventRunContext
	{

		/// <summary>
		/// The type of event that triggered the execution.
		/// </summary>
		RecurringEventType EventType
		{ get; }

		/// <summary>
		/// The recurring event run ID.
		/// </summary>
		int RunID
		{ get; }

		/// <summary>
		/// The recurring event run ID to be reversed.
		/// </summary>
		int RunIDToReverse
		{ get; }

		/// <summary>
		/// The usage interval ID an end-of-period adapter is to be invoked on.
		/// </summary>
		int UsageIntervalID
		{ get; }

		/// <summary>
		/// The start date a scheduled adapter is to be invoked on.
		/// </summary>
		DateTime StartDate
		{ get; }

		/// <summary>
		/// The end date a scheduled adapter is to be invoked on.
		/// </summary>
		DateTime EndDate
		{ get; }

    /// <summary>
    /// The billing group ID an end-of-period adapter is to be invoked on.
    /// </summary>
    int BillingGroupID
    { get; }

  	/// <summary>
		/// Records an information message in the adapter run's history
		/// </summary>
		void RecordInfo(string detail);

		/// <summary>
		/// Records a warning message in the adapter run's history
		/// </summary>
		void RecordWarning(string detail);

		/// <summary>
		/// Automatically backs out any associated batches with the RunIDToReverse
		/// Returns a string consisting of the "detail" information
		/// </summary>
		string AutoReverse();

		/// <summary>
		/// Creates a derived end-of-period context from the current context with the given 
		/// usage interval ID. The run ID of the derived context is inherited from the original
		/// context. This method is helpful when encapsulating a recurring event adapter
		/// inside of another recurring event adapter.
		/// </summary>
		IRecurringEventRunContext CreateDerivedEndOfPeriodContext(int usageIntervalID);

		/// <summary>
		/// Creates a derived scheduled context from the current context with the given 
		/// start date and end date. The run ID of the derived context is inherited
		/// from the original context. This method is helpful when encapsulating a
		/// recurring event adapter inside of another recurring event adapter.
		/// </summary>
		IRecurringEventRunContext CreateDerivedScheduledContext(DateTime startDate, DateTime endDate);

		/// <summary>
		/// Records a batch of information messages in one shot using
		/// ArrayBulkInsert interfaces. The first column in details parameter
		/// rowset is expected to have a string message
		/// </summary>
		void RecordInfoBatch(MetraTech.Interop.Rowset.IMTRowSet detail);

		/// <summary>
		/// Records a batch of warning messages in one shot using
		/// ArrayBulkInsert interfaces. The first column in details parameter
		/// rowset is expected to have a string message
		/// </summary>
		void RecordWarningBatch(MetraTech.Interop.Rowset.IMTRowSet detail);

    /// <summary>
    /// Records the account that is at least partially responsible for this
    /// runs failure. This information can be used later to create child groups
    /// containing accounts responsible for the failure of the run, if desired.
    /// Accounts passed in can be either payers or payees. 
    /// </summary>
    void RecordFailureAccount(int accountID);

    /// <summary>
    /// Records all accounts implicated in pipeline processing failures 
    /// (failed transactions) associated with this run.  Batches must be associated
    /// with the run via MeterRowset::CreateAdapterBatch method.
    /// This information can be used later to automatically create child groups
    /// containing accounts responsible for the failure of the run, if desired.
    ///
    /// NOTE: processing of all metered data must be completed before this method
    ///       is called.
    /// </summary>
    void RecordFailureAccountsFromFailedTransactions();

	}

	
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("B1B82C6C-C8DA-3625-9583-19BBC91021AB")]
  [Serializable]
	public class RecurringEventRunContext : IRecurringEventRunContext
	{
		
		int mRunID;
		public int RunID
		{ 
			get
			{
				return mRunID;
			}
			set
			{
				mRunID = value;
			}
		}

		int mRunIDToReverse;
		public int RunIDToReverse
		{ 
			get
			{
				return mRunIDToReverse;
			}
			set
			{
				mRunIDToReverse = value;
			}
		}

		RecurringEventType mEventType;
		public RecurringEventType EventType
		{ 
			get
			{
				return mEventType;
			}
			set
			{
				mEventType = value;
			}
		}

		int mIntervalID;
		public int UsageIntervalID
		{ 
			get
			{
				return mIntervalID;
			}
			set
			{
				mIntervalID = value;
			}
		}

		DateTime mStartDate;
		public DateTime StartDate
		{ 
			get
			{
				return mStartDate;
			}
			set 
			{
				mStartDate = value;
			}
		}

		DateTime mEndDate;
		public DateTime EndDate
		{ 
			get
			{
				return mEndDate;
			}
			set
			{
				mEndDate = value;
			}
		}

    int mBillingGroupID;
    public int BillingGroupID
    { 
      get
      {
        return mBillingGroupID;
      }
      set
      {
        mBillingGroupID = value;
      }
    }

		public void RecordInfo(string details)
		{
			RecordDetail("Info", details);
		}

		public void RecordWarning(string details)
		{
			RecordDetail("Warning", details);
		}

		public void RecordInfoBatch(MetraTech.Interop.Rowset.IMTRowSet details)
		{
			RecordDetailBatch("Info", details);
		}

		public void RecordWarningBatch(MetraTech.Interop.Rowset.IMTRowSet details)
		{
			RecordDetailBatch("Warning", details);
		}

    public void RecordFailureAccount(int accountID) 
    {
      throw new NotImplementedException("RecordFailureAccount has not been implemented");
    }

    public void RecordFailureAccountsFromFailedTransactions()
    {
      throw new NotImplementedException("RecordFailureAccountsFromFailedTransactions has not been implemented");
    }

		public string AutoReverse()
		{
			return AdapterManager.Reverse(this);
		}

		public IRecurringEventRunContext CreateDerivedEndOfPeriodContext(int usageIntervalID)
		{
			RecurringEventRunContext derivedContext = new RecurringEventRunContext();

			// the Run IDs are inherited from the original context
			// this allows the infrastructure to link the original and derived contexts as one run
			derivedContext.RunID = mRunID;
			derivedContext.RunIDToReverse = mRunIDToReverse;

			derivedContext.EventType = RecurringEventType.EndOfPeriod;
			derivedContext.UsageIntervalID = usageIntervalID;
			
			return derivedContext;
		}

		public IRecurringEventRunContext CreateDerivedScheduledContext(DateTime startDate, DateTime endDate)
		{
			RecurringEventRunContext derivedContext = new RecurringEventRunContext();

			// the Run IDs are inherited from the original context
			// this allows the infrastructure to link the original and derived contexts as one run
			derivedContext.RunID = mRunID;
			derivedContext.RunIDToReverse = mRunIDToReverse;

			derivedContext.EventType = RecurringEventType.Scheduled;
			derivedContext.StartDate = startDate;
			derivedContext.EndDate = endDate;
			
			return derivedContext;
		}

		private const int NVARCHAR_MAX = 4000;

		private void RecordDetail(string type, string details)
		{

			// detail length must be less than 4000 characters because of NVARCHAR limitations
			if (details.Length <= NVARCHAR_MAX)
				InsertDetail(type, details);
			else
			{
				// recursively breaks the detail string up into multiple bite-sized records
				InsertDetail(type, details.Substring(0, NVARCHAR_MAX));
				RecordDetail(type, details.Substring(NVARCHAR_MAX));
			}
		}

		private void InsertDetail(string type, string details)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                                                                             "__RECORD_RECURRING_EVENT_RUN_DETAIL__"))
                {
                    stmt.AddParam("%%ID_RUN%%", mRunID);
                    stmt.AddParam("%%TX_TYPE%%", type);
                    stmt.AddParam("%%TX_DETAIL%%", details);

                    stmt.ExecuteNonQuery();
                }
            }
		}

		private void RecordDetailBatch(string type, MetraTech.Interop.Rowset.IMTRowSet aDetails)
		{
			IBulkInsert bulkInsert = BulkInsertManager.CreateBulkInsert("NetMeter");
			using (bulkInsert)
			{
				bulkInsert.PrepareForInsert("t_recevent_run_details", 1000);
				if(aDetails.RecordCount > 0)
				{
					aDetails.MoveFirst();
					while(!Convert.ToBoolean(aDetails.EOF))
					{
						bulkInsert.SetValue(2, MTParameterType.Integer, mRunID);
						bulkInsert.SetValue(3, MTParameterType.String, type);

						string details = (string) aDetails.get_Value(0);
						// truncates detail string if it is too long
						if (details.Length > NVARCHAR_MAX)
							details = details.Substring(0, NVARCHAR_MAX);
						bulkInsert.SetValue(4, MTParameterType.WideString, details);

						bulkInsert.SetValue(5, MTParameterType.DateTime, MetraTech.MetraTime.Now);
						bulkInsert.AddBatch();
						aDetails.MoveNext();
					}
					bulkInsert.ExecuteBatch();
				}
				
			}

		}

		public override string ToString()
		{
			if (mEventType == RecurringEventType.EndOfPeriod)
				return String.Format("RunID={0}, EventType={1}, RunIDToReverse={2}, UsageIntervalID={3}, BillingGroupID={4}",
														 mRunID, mEventType, mRunIDToReverse, mIntervalID, mBillingGroupID);
			else
				return String.Format("RunID={0}, EventType={1}, RunIDToReverse={2}, StartDate={3}, EndDate={4}",
														 mRunID, mEventType, mRunIDToReverse, mStartDate, mEndDate);
		}
	}


	internal class LegacyAdapterWrapper : IRecurringEventAdapter2
	{
		string mProgID;
	  IRecurringEventAdapter mAdapter;
		// ReverseMode mReverseMode = ReverseMode.NotImplemented;

    public LegacyAdapterWrapper(string progID, IRecurringEventAdapter adapter)
		{
			mProgID = progID;
			mAdapter = adapter;
		}
	
	  public void Initialize(string eventName, string configFile,
													 Auth.IMTSessionContext context, bool limitedInit)
		{
			mAdapter.Initialize(eventName, configFile, context, limitedInit);
		}

    public string Execute(IRecurringEventRunContext context)
		{
			return mAdapter.Execute(context);
		}

		public string Reverse(IRecurringEventRunContext context)
		{
      return mAdapter.Reverse(context);
		}

		public void Shutdown()
		{
			mAdapter.Shutdown();

			// eagerly releases the legacy COM adapter
      if (Marshal.IsComObject(mAdapter)) 
      {
        Marshal.ReleaseComObject(mAdapter);
      }
		}
	
    public void CreateBillingGroupConstraints(int intervalID, int materializationID)  
    {
      string msg = 
        String.Format("The '{0}' legacy adapter does not support " + 
                      "billing groups! It cannot be used.", mProgID);
      throw new UsageServerException(msg);
    }

    public void SplitReverseState(int parentRunID, 
                           int parentBillingGroupID,
                           int childRunID, 
                           int childBillingGroupID)
    {
      string msg = 
        String.Format("The '{0}' legacy adapter does not support " + 
                      "billing groups! It cannot be used.", mProgID);
      throw new UsageServerException(msg);
    }

		public bool SupportsScheduledEvents    
    { 
      get 
      { 
        return mAdapter.SupportsScheduledEvents; 
      } 
    }
		public bool SupportsEndOfPeriodEvents  
    { 
      get 
      { 
        return mAdapter.SupportsEndOfPeriodEvents; 
      } 
    }

		public ReverseMode Reversibility       
    { 
      get 
      { 
        return mAdapter.Reversibility; 
      } 
    }
		
    public bool AllowMultipleInstances     
    { 
      get 
      { 
        return mAdapter.AllowMultipleInstances; 
      } 
    }

    public BillingGroupSupportType BillingGroupSupport 
    {
      get 
      {
        return BillingGroupSupportType.Interval; 
      }
    }

    public bool HasBillingGroupConstraints 
    { 
      get 
      {
        string msg = 
          String.Format("The '{0}' legacy adapter does not support " + 
                        "billing groups! It cannot be used.", mProgID);
        throw new UsageServerException(msg);
      }
    }
  }

	/// <summary>
	/// Adapter wrapper which converts any adapter generated exceptions
	/// to specialized UsageServer exceptions. 	The original exception is
	/// preserved as the inner exception. Also, takes care of the auto-
	/// reverse functionality.
	/// </summary>
	internal class AdapterWrapper : IRecurringEventAdapter2
	{
	  IRecurringEventAdapter2 mAdapter;
		string mEventName;

    public AdapterWrapper(IRecurringEventAdapter2 adapter)
		{
			mAdapter = adapter;
		}
	
	  public void Initialize(string eventName, string configFile,
													 Auth.IMTSessionContext context, bool limitedInit)
		{
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                      new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
                try
                {
                    mEventName = eventName;
                    mAdapter.Initialize(eventName, configFile, context, limitedInit);
                }
                catch (ThreadAbortException)
                { throw; }
                catch (Exception e)
                { throw new AdapterInitializationException(eventName, limitedInit, e); }
            }
		}

    public string Execute(IRecurringEventRunContext context)
		{
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                          new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
                try
                {
                    return (mAdapter.Execute(context));
                }
                catch (ThreadAbortException)
                { throw; }
                catch (Exception e)
                {
                    throw new AdapterExecutionException(mEventName, e);
                }
            }
		}

		public string Reverse(IRecurringEventRunContext context)
		{
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                      new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
                try
                {
                    switch (mAdapter.Reversibility)
                    {
                        case ReverseMode.Custom:
                            return (mAdapter.Reverse(context));

                        case ReverseMode.Auto:
                            return (AdapterManager.Reverse(context));

                        default:
                            Debug.Assert(false, "Adapter's reverse mode does not allow it to be reversed!");
                            throw new UsageServerException("Adapter's reverse mode does not allow it to be reversed!");
                    }
                }
                catch (ThreadAbortException)
                { throw; }
                catch (Exception e)
                {
                    throw new AdapterReversalException(mEventName, e);
                }
            }
		}

		public void Shutdown()
		{
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                      new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
                try
                {
                    mAdapter.Shutdown();

                    // eagerly releases non-legacy COM adapters
                    if (Marshal.IsComObject(mAdapter))
                        Marshal.ReleaseComObject(mAdapter);
                }
                catch (ThreadAbortException)
                { throw; }
                catch (Exception e)
                { throw new AdapterShutdownException(mEventName, e); }
            }
		}

    public void CreateBillingGroupConstraints(int intervalID, int materializationID) 
    {
      try 
      {
        mAdapter.CreateBillingGroupConstraints(intervalID, materializationID);
      }
      catch (ThreadAbortException)
      { throw; }
      catch (Exception e)
      { 
        throw new CreateBillingGroupConstraintsException(mEventName, e); 
      }
    }

    public void SplitReverseState(int parentRunID, 
                                  int parentBillingGroupID,
                                  int childRunID, 
                                  int childBillingGroupID)
    {
      try 
      {
        mAdapter.SplitReverseState(parentRunID, 
                                   parentBillingGroupID,
                                   childRunID, 
                                   childBillingGroupID);
      }
      catch (ThreadAbortException)
      { throw; }
      catch (Exception e)
      { 
        throw new SplitReverseStateException(mEventName, e); 
      }
    }
	
		public bool SupportsScheduledEvents    { get { return mAdapter.SupportsScheduledEvents; } }
		public bool SupportsEndOfPeriodEvents  { get { return mAdapter.SupportsEndOfPeriodEvents; } }
		public ReverseMode Reversibility       { get { return mAdapter.Reversibility; } }
		public bool AllowMultipleInstances     { get { return mAdapter.AllowMultipleInstances; } }
    public BillingGroupSupportType BillingGroupSupport { get { return mAdapter.BillingGroupSupport; } }
    public bool HasBillingGroupConstraints { get { return mAdapter.HasBillingGroupConstraints; } }
	}

	// Auto reverse functionality is provided to COM clients by way of the instance
	// Reverse method. Managed adapters should use the static Reverse method.
	[Guid("6e98d394-fce0-4409-b79c-7b88b3f6dddc")]
	public interface IAdapterManager
	{
	  string Reverse(IRecurringEventRunContext context);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("c09d4373-fec1-4067-9c05-8cb801734e8b")]
	public class AdapterManager : IAdapterManager
	{
		public AdapterManager()
		{ }

		static AdapterManager()
		{
			mLogger = new Logger("[UsageServer]");

			if (mRCD == null)
				mRCD = (RCD.IMTRcd) new RCD.MTRcd();

      AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(ResolveAssembly);
		}

		/// <summary>
		/// Creates an instance of an adapter
		/// </summary>
	  public static IRecurringEventAdapter2 CreateAdapterInstance(string className, out bool isLegacyAdapter)
		{
			string bindingLog = "";
			
			Type adapterType = null;
			object adapter = null;
      AdapterWrapper adapterWrapper = null;
      isLegacyAdapter = false;

			// attempts to create the adapter's type given the .NET class name
			try
			{
				mLogger.LogDebug("Attempting to create a managed instance of adapter...");

				adapterType = Type.GetType(className, true);
        adapter = Activator.CreateInstance(adapterType);

        adapterWrapper = 
          CreateAdapterWrapper(adapter, className, out isLegacyAdapter);
      
        if (isLegacyAdapter) 
        {
          mLogger.LogDebug("Managed legacy adapter successfuly instantiated");
        }
        else 
        {
          mLogger.LogDebug("Managed adapter successfuly instantiated");
        }
			}
			catch (Exception e)
			{
				string msg = 
          String.Format("Could not create managed instance: '{0}'", e.Message);
				bindingLog += String.Format("   {0}", msg);
				mLogger.LogDebug(msg);
			}
			
      if (adapterWrapper == null) 
      {
        // class name didn't work, try to create using ProgID
        try 
        {
          mLogger.LogDebug("Attempting to create a COM instance of adapter...");

          adapterType = Type.GetTypeFromProgID(className, true);
          adapter = Activator.CreateInstance(adapterType);
          adapterWrapper = 
            CreateAdapterWrapper(adapter, className, out isLegacyAdapter);

          if (isLegacyAdapter) 
          {
            mLogger.LogDebug("COM legacy adapter successfuly instantiated");
          }
          else 
          {
            mLogger.LogDebug("COM adapter successfuly instantiated");
          }
        }
        catch (Exception e)
        { 
          string msg = String.Format("Could not create COM instance: '{0}'", e.Message);
          if (bindingLog.Length != 0)
          {
            bindingLog += "\n";
          }
          bindingLog += String.Format("   {0}", msg);
          throw new AdapterCreationException(className, bindingLog); 	
        }
      }

      return adapterWrapper;
    }
 
		/// <summary>
		/// Gets the absolute file name to the adapter's configuration file
		/// </summary>
	  public static string GetAbsoluteConfigFile(string extension, string filename, bool isLegacyAdapter)
		{
			if ((filename == null) || (filename.Length == 0))
				return "";

			string fullPath;
			if (/* isLegacyAdapter || */ extension == null)
				// legacy adapters must prepend the MT config directory themselves.
				// it is also standard that the config file entry in the old
				// recurring_event.xml file is prefixed with 'UsageServer\Adapters\'
				fullPath = filename;
			else
				// new adapters expect their config file to be relative
				// to the extension in which the event was configured from.
				fullPath = String.Format(@"{0}\{1}\config\UsageServer\{2}",
																 mRCD.ExtensionDir, extension, filename);

			return fullPath;
		}

		/// <summary>
		/// Reverses a run by backing out any associated batches (aka autoreverse)
		/// </summary>
	  public static string Reverse(IRecurringEventRunContext context)
		{

			ArrayList batches = GetAssociatedBatches(context.RunIDToReverse);
			mLogger.LogDebug(String.Format("Autoreversing {0} batches associated with this run", batches.Count));
			context.RecordInfo(String.Format("Autoreversing {0} batches associated with this run", batches.Count));

			BillingReRun.IMTBillingReRun rerun = new BillingReRunClient.Client();
			Auth.IMTSessionContext sessionContext = AdapterManager.GetSuperUserContext(); // log in as super user
			rerun.Login((BillingReRun.IMTSessionContext) sessionContext);
			string comment = String.Format("Adapter autoreverse: recurring event runID={0}", context.RunID);
			rerun.Setup(comment);
			context.RecordInfo(String.Format("Rerun ID = {0}", rerun.ID));

			PipelineManager pipeline = new PipelineManager();
			try
		{
				// pauses all pipelines so identify isn't chasing a moving target
				pipeline.PauseAllProcessing();

				// identify all batches (ideally we could do this in one call to Identify)
				// instead of doing individual billing reruns per batch (CR12581)
				foreach (string batchID in batches)
		{
					context.RecordInfo(String.Format("Starting billing rerun identify phase for batch '{0}'", batchID));
      
			BillingReRun.IMTIdentificationFilter filter = rerun.CreateFilter();
			filter.BatchID = batchID;

			// filters on the billing group ID if the billing group ID is set on the context
			// NOTE: it won't be set for scheduled or EOP interval-only adapters)
			if (context.BillingGroupID > 0)
				filter.BillingGroupID = context.BillingGroupID;

			// filters on the interval ID if the interval ID is set on the context
			// NOTE: it won't be set for scheduled adapters).  This is important for
      // performance when partitioning is enabled.
			if (context.UsageIntervalID > 0)
				filter.IntervalID = context.UsageIntervalID;

      filter.IsIdentifySuspendedTransactions = true;
      filter.IsIdentifyPendingTransactions = true;
      filter.SuspendedInterval = 0;  

					rerun.Identify(filter, comment);
					context.RecordInfo(String.Format("Identify phase completed successfully for batch '{0}'", batchID));
				}

				context.RecordInfo("Starting billing rerun analyze phase");
				rerun.Analyze(comment);
				context.RecordInfo("Analyze phase completed successfully");
				// TODO: make sure initial count of sessions is equal to analyzed count 

				context.RecordInfo("Starting billing rerun BackoutDelete phase");
				rerun.BackoutDelete(comment);
				context.RecordInfo("BackoutDelete phase completed successfully");

				context.RecordInfo("Starting billing rerun abandon phase");
				rerun.Abandon(comment);
				context.RecordInfo("Billing rerun abandon phase completed successfully");
			}
			finally
			{
				// always resume processing no matter what!
				pipeline.ResumeAllProcessing();
			}

			return String.Format("All {0} batches were successfully backed out", batches.Count);
		}

		/// <summary>
		/// Reverses a run by backing out any associated batches (accessible to COM clients)
		/// </summary>
		// NOTE: this method will only be invoked by using the IAdapterManager interface
		string IAdapterManager.Reverse(IRecurringEventRunContext context)
		{
			return AdapterManager.Reverse(context);
		}

		/// <summary>
		/// Gets a collection of batch IDs associated with given recurring event run
		/// </summary>
		private static ArrayList GetAssociatedBatches(int runID)
		{
			ArrayList batches = new ArrayList();

            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                                                                             "__GET_RUNS_ASSOCIATED_BATCHES__"))
                {
                    stmt.AddParam("%%ID_RUN%%", runID);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string batchID = reader.GetString("tx_batch_encoded");
                            batches.Add(batchID);
                        }
                    }
                }
            }

			return batches;
		}

		/// <summary>
		/// Conveniently log in as su.
		/// </summary>
		public static IMTSessionContext GetSuperUserContext()
		{
			IMTLoginContext loginCtx = new MTLoginContextClass();
			
			ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();
			ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;
			
			return loginCtx.Login(suName, "system_user", suPassword);
		}

    private static AdapterWrapper CreateAdapterWrapper(object adapter, 
                                                       string className,
                                                       out bool isLegacyAdapter) 
    {
      AdapterWrapper adapterWrapper = null;
      isLegacyAdapter = false;

      if (adapter is IRecurringEventAdapter2) 
      {
        adapterWrapper = new AdapterWrapper((IRecurringEventAdapter2)adapter);
      }
      else if (adapter is IRecurringEventAdapter) 
      {
        isLegacyAdapter = true;
        adapterWrapper = 
          new AdapterWrapper
            (new LegacyAdapterWrapper(className, (IRecurringEventAdapter)adapter));
      }
      else 
      {
        string msg = 
          String.Format("Adapter '{0}' does not implement 'IRecurringEventAdapter' " +
                        "or 'IRecurringEventAdapter2'", 
                        className);

        throw new AdapterCreationException(className, msg);
      }

      return adapterWrapper;
    }

    public static Assembly ResolveAssembly(object sender, ResolveEventArgs args)
    {
      Assembly retval = null;

      string assemblyName = args.Name;

      string searchName = assemblyName.Substring(0, (assemblyName.IndexOf(',') == -1 ? assemblyName.Length : assemblyName.IndexOf(','))).ToUpper();

      if (!searchName.Contains(".DLL"))
      {
        searchName += ".DLL";
      }

      try
      {
        AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
        retval = Assembly.Load(nm);
      }
      catch (Exception)
      {
        try
        {
          retval = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), searchName));
        }
        catch (Exception)
        {
          RCD.IMTRcdFileList fileList = mRCD.RunQuery(string.Format("Bin\\{0}", searchName), false);

          if (fileList.Count > 0)
          {
            AssemblyName nm2 = AssemblyName.GetAssemblyName(((string)fileList[0]));
            retval = Assembly.Load(nm2);
          }
        }
      }

      return retval;
    }

		private static Logger mLogger;
		private static RCD.IMTRcd mRCD;
	}


	/// <summary>
	/// An helper class used to read in common metering configuration settings
	/// for an adapter using MeterRowset or equivalent functionality 
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("040cc008-f5ba-43af-a7d5-b783bcd01904")]
	public class MeteringConfig : IMeteringConfig
	{

		public MeteringConfig()
		{
			mLogger = new Logger("[MeteringConfig]");
		}

		/// <summary>
		/// Loads the given config file and parses the <Metering> element.
		/// If any or all of the settings are not found, the given defaults are used.
		/// </summary>
		public void Load(string configFile, 
										 int defaultSessionSetSize, int defaultCommitTimeout, bool defaultFailImmediately)
		{
			if (System.IO.File.Exists(configFile))
			{
				mLogger.LogDebug("Loading metering configuration settings from file '{0}'", configFile); 

				MTXmlDocument doc = new MTXmlDocument();
				doc.Load(configFile);

				mSessionSetSize = doc.GetNodeValueAsInt("/xmlconfig/Metering/SessionSetSize", defaultSessionSetSize);
				mCommitTimeout = doc.GetNodeValueAsInt("/xmlconfig/Metering/CommitTimeout", defaultCommitTimeout);
				mFailImmediately = doc.GetNodeValueAsBool("/xmlconfig/Metering/FailImmediately", defaultFailImmediately);
			}
			else
			{
				mLogger.LogWarning("No metering configuration settings found (file not found: {0}). Using default settings.", configFile); 

				mSessionSetSize = defaultSessionSetSize;
				mCommitTimeout = defaultCommitTimeout;
				mFailImmediately = defaultFailImmediately;
			}

			mLogger.LogDebug("Session set size : {0}", mSessionSetSize);
			mLogger.LogDebug("Commit timeout   : {0}", mCommitTimeout);
			mLogger.LogDebug("Fail immediately : {0}", mFailImmediately);

			mLoaded = true;
		}


		/// <summary>
		/// The maximum number of sessions to be packed into a session set.
		/// </summary>
		public int SessionSetSize
		{ 
			get 
			{ 
				if (!mLoaded)
					throw new ApplicationException("MeterConfig.Load() method must be called first!");

				return mSessionSetSize; 
			}
		}


		/// <summary>
		/// The amount of seconds to wait for a batch to commit.
    /// A commit is having every session either in a product view or in the
		/// failed transaction table.
		/// </summary>
		public int CommitTimeout
		{ 
			get
			{
				if (!mLoaded)
					throw new ApplicationException("MeterConfig.Load() method must be called first!");

				return mCommitTimeout; 
			}
		}


		/// <summary>
		/// If true, indicates that the adapter should fail as soon as a failed
		/// transaction is detected. Otherwise, indicates that the adapter should
		/// fail if a failed transaction has occurred but only after all sessions
		/// have been metered and committed.
		/// </summary>
		public bool FailImmediately
		{ 
			get
			{
				if (!mLoaded)
					throw new ApplicationException("MeterConfig::Load method must be called first!");

				return mFailImmediately; 
			}
		}

		Logger mLogger;
		bool mLoaded = false;

		int mSessionSetSize;
		int mCommitTimeout;
		bool mFailImmediately;
	}


	[Guid("17becba0-4491-41fc-be84-dd2813f256c1")]
	public interface IMeteringConfig
	{
		void Load(string configFile,
							int defaultSessionSetSize, int defaultCmmitTimeout, bool defaultFailImmediately);
		int SessionSetSize
		{ get; }
		int CommitTimeout
		{ get; }
		bool FailImmediately
		{ get; }
	}

  [Guid("f36c0336-9bde-4af0-a227-4cfaef27c290")]
  public interface IMetraFlowPartitionList
  {
    string Name
    { get; }
    int NumPartitions 
    { get; }
    int GetPartition(int idx);
  }

	[Guid("7175ee95-c14e-4c96-b01b-62a83bb29498")]
	public interface IMetraFlowConfig
	{
		void Load(string configFile);
		bool RunRemote
		{ get; }
    int NumHosts
    { get; }
    string GetHost(int idx);
    int NumPartitionLists
    { get; }
    IMetraFlowPartitionList GetPartitionList(int idx);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("f2baec1f-bc2f-4d48-88ea-6f271972582c")]
	public class MetraFlowPartitionList : IMetraFlowPartitionList
  {
    private string mName;
    public string Name
    {
      get { return mName; }
      set { mName = value; }
    }


    private System.Collections.Generic.List<int> mPartitions;
    public int NumPartitions
    {
      get { return mPartitions.Count; }
    }

    public int GetPartition(int idx)
    {
      return mPartitions[idx];
    }

    public void AddPartition(int partition)
    {
      mPartitions.Add(partition);
    }

    public MetraFlowPartitionList()
    {
      mName = "";
      mPartitions = new System.Collections.Generic.List<int>();
    }
  }

	/// <summary>
	/// An helper class used to read in MetraFlow configuration information
  /// for adapters.
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("cffd5921-7705-40be-967a-9ffb4bbb261c")]
	public class MetraFlowConfig : IMetraFlowConfig
	{

		public MetraFlowConfig()
		{
			mLogger = new Logger("[MetraFlowConfig]");
		}

		/// <summary>
		/// Loads the given config file and parses the <Metering> element.
		/// If any or all of the settings are not found, the given defaults are used.
		/// </summary>
		public void Load(string configFile)
    {
			if (System.IO.File.Exists(configFile))
			{
				mLogger.LogDebug("Loading MetraFlow configuration settings from file '{0}'", configFile); 

				MTXmlDocument doc = new MTXmlDocument();
				doc.Load(configFile);

        if (doc.SingleNodeExists("/xmlconfig/MetraFlow") == null)
        {
          // Check usageserver.xml for a default
          mLogger.LogDebug("No MetraFlow configuration found in adapter configuration file '{0}', looking for default configuration in usageserver.xml", configFile); 
          doc = new MTXmlDocument();
          doc.LoadConfigFile(UsageServerCommon.UsageServerConfigFile);
        }
        foreach(System.Xml.XmlNode node in doc.SelectNodes("/xmlconfig/MetraFlow/Hostname"))
        {
	  if (node.InnerText.ToUpper() != "LOCALHOST")
            mRunRemote = true;
          mHosts.Add(node.InnerText);
        }
        foreach(System.Xml.XmlNode node in doc.SelectNodes("/xmlconfig/MetraFlow/PartitionList"))
        {
          MetraFlowPartitionList list = new MetraFlowPartitionList();
          list.Name = MetraTech.Xml.MTXmlDocument.GetNodeValueAsString(node, "Name");
          foreach(System.Xml.XmlNode partitionNode in node.SelectNodes("Partition"))
          {
            list.AddPartition(MetraTech.Xml.MTXmlDocument.GetNodeValueAsInt(partitionNode));
          }
          mPartitionListDefinitions.Add(list);
        }
			}
			else
			{
				mLogger.LogWarning("No MetraFlow configuration settings found (file not found: {0}). Using localhost.", configFile); 
        mRunRemote = false;
			}

			mLoaded = true;
		}


		/// <summary>
		/// The number of configured hosts in the file.
		/// </summary>
		public int NumHosts
		{ 
			get 
			{ 
				if (!mLoaded)
					throw new ApplicationException("MetraFlowConfig.Load() method must be called first!");

				return mHosts.Count; 
			}
		}


		/// <summary>
		/// Return a host name.  Zero-based index.
		/// </summary>
		public string GetHost(int i)
		{ 
      if (!mLoaded)
        throw new ApplicationException("MeterConfig.Load() method must be called first!");
      
      return mHosts[i]; 
		}


		/// <summary>
		/// Return whether MetraFlow should use remote/MPI execution.  Must be true if one of the
    /// hosts is not localhost.
		/// </summary>
		public bool RunRemote
		{ 
			get
			{
				if (!mLoaded)
					throw new ApplicationException("MeterConfig::Load method must be called first!");

				return mRunRemote; 
			}
		}

    public int NumPartitionLists
    { 
      get { return mPartitionListDefinitions.Count; }
    }

    public IMetraFlowPartitionList GetPartitionList(int idx)
    {
      return mPartitionListDefinitions[idx]; 
    }

		Logger mLogger;
		bool mLoaded = false;
    bool mRunRemote = false;
    System.Collections.Generic.List<string> mHosts = new System.Collections.Generic.List<string>();
    System.Collections.Generic.List<MetraFlowPartitionList> mPartitionListDefinitions = 
    new System.Collections.Generic.List<MetraFlowPartitionList> ();
	}

  
  [ComVisible(false)]
  public class MetraFlowScriptPort
  {
    private string mName;
    public string Name
    {
      get { return mName; }
    }

    private string mAlias;
    public string Alias
    {
      get { return mAlias; }
    }

    public MetraFlowScriptPort(string name, string alias)
    {
      mName = name;
      mAlias = alias;
    }
  }

  [ComVisible(false)]
  public class MetraFlowScriptArrow
  {
    private string mSource;
    public string Source
    {
      get { return mSource; }
    }

    private string mTarget;
    public string Target
    {
      get { return mTarget; }
    }

    public MetraFlowScriptArrow(string source, string target)
    {
      mSource = source;
      mTarget = target;
    }
  }

  [ComVisible(false)]
  public class MetraFlowScript
  {
    private string mRawProgram;
    private string mProgram;

    private System.Collections.Generic.Dictionary<string, MetraFlowScriptPort> mInputPorts;
    private System.Collections.Generic.Dictionary<string, MetraFlowScriptPort> mOutputPorts;

    private string DecorateParameter(string parameterName)
    {
      string tmp = parameterName;
      if (tmp.Length < 3 || false == tmp.StartsWith("%%"))
        tmp = "%%" + tmp;
      if (tmp.Length < 3 || false == tmp.EndsWith("%%"))
        tmp = tmp + "%%";
      return tmp;
    }

    public static MetraFlowScript GetCoreScript(string subjectArea, string name)
    {
      MetraTech.Xml.MTXmlDocument doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadConfigFile(string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                       "MetraFlow/{0}/Scripts/{1}.xml", subjectArea, name));
      return new MetraFlowScript(doc);
    }

    public static MetraFlowScript GetExtensionScript(string extension, string name)
    {
      MetraTech.Xml.MTXmlDocument doc = new MetraTech.Xml.MTXmlDocument();
      doc.LoadExtensionConfigFile(extension, 
                                  string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                                "config/MetraFlow/Scripts/{0}.xml", 
                                                name));
      return new MetraFlowScript(doc);
    }

    private MetraFlowScript(MetraTech.Xml.MTXmlDocument doc)
    {
      mInputPorts = new System.Collections.Generic.Dictionary<string, MetraFlowScriptPort>();
      mOutputPorts = new System.Collections.Generic.Dictionary<string, MetraFlowScriptPort>();        
      mRawProgram = doc.GetNodeValueAsString("MetraFlowScript/Script");
      mProgram = mRawProgram;
      foreach(System.Xml.XmlNode input in doc.SelectNodes("MetraFlowScript/Ports/InputPort"))
      {
        mInputPorts.Add(MTXmlDocument.GetNodeValueAsString(input, "Alias"),
                        new MetraFlowScriptPort(MTXmlDocument.GetNodeValueAsString(input, "Name"),
                                                MTXmlDocument.GetNodeValueAsString(input, "Alias")));
      }
      foreach(System.Xml.XmlNode output in doc.SelectNodes("MetraFlowScript/Ports/OutputPort"))
      {
        mOutputPorts.Add(MTXmlDocument.GetNodeValueAsString(output, "Alias"),
                         new MetraFlowScriptPort(MTXmlDocument.GetNodeValueAsString(output, "Name"),
                                                 MTXmlDocument.GetNodeValueAsString(output, "Alias")));
      }
    }

    private void AddArrows(MetraFlowScript a, 
                           MetraFlowScript b, 
                           MetraFlowScriptArrow [] arrows,
                           System.Collections.Generic.Dictionary<string,MetraFlowScriptPort> referencedA,
                           System.Collections.Generic.Dictionary<string,MetraFlowScriptPort> referencedB)
    {
      for(int i=0; i<arrows.Length; i++)
      {
        if (!a.mOutputPorts.ContainsKey(arrows[i].Source)) throw new UsageServerException("Missing port");
        if (!b.mInputPorts.ContainsKey(arrows[i].Target)) throw new UsageServerException("Missing port");
        mRawProgram += string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                     "{0} -> {1};\n", a.mOutputPorts[arrows[i].Source].Name, 
                                     b.mInputPorts[arrows[i].Target].Name);
        mProgram += string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                  "{0} -> {1};\n", a.mOutputPorts[arrows[i].Source].Name, 
                                  b.mInputPorts[arrows[i].Target].Name);
        referencedA.Add(arrows[i].Source, a.mOutputPorts[arrows[i].Source]);
        referencedB.Add(arrows[i].Target, b.mInputPorts[arrows[i].Target]);
      }
      mInputPorts = new System.Collections.Generic.Dictionary<string, MetraFlowScriptPort>();
      mOutputPorts = new System.Collections.Generic.Dictionary<string, MetraFlowScriptPort>();
    }

    public MetraFlowScript(MetraFlowScript a, 
                           MetraFlowScript b, 
                           MetraFlowScriptArrow [] arrowsAB, 
                           MetraFlowScriptArrow [] arrowsBA)
    {
      mRawProgram = a.mRawProgram + "\n" + b.mRawProgram + "\n";
      mProgram = a.mProgram + "\n" + b.mProgram + "\n";
      System.Collections.Generic.Dictionary<string,MetraFlowScriptPort> referencedInputA = new System.Collections.Generic.Dictionary<string,MetraFlowScriptPort>();
      System.Collections.Generic.Dictionary<string,MetraFlowScriptPort> referencedInputB = new System.Collections.Generic.Dictionary<string,MetraFlowScriptPort>();
      System.Collections.Generic.Dictionary<string,MetraFlowScriptPort> referencedOutputA = new System.Collections.Generic.Dictionary<string,MetraFlowScriptPort>();
      System.Collections.Generic.Dictionary<string,MetraFlowScriptPort> referencedOutputB = new System.Collections.Generic.Dictionary<string,MetraFlowScriptPort>();
      AddArrows(a, b, arrowsAB, referencedOutputA, referencedInputB);
      AddArrows(b, a, arrowsBA, referencedOutputB, referencedInputA);
      // Take the union of arrows that aren't glued together.  Make sure we don't have port alias collisions.
      foreach(System.Collections.Generic.KeyValuePair<string, MetraFlowScriptPort> kvp in a.mInputPorts)
      {
        if (!referencedInputA.ContainsKey(kvp.Key))
        {
          if (mInputPorts.ContainsKey(kvp.Key)) throw new UsageServerException("Duplicate port");
          mInputPorts.Add(kvp.Key, kvp.Value);
        }
      }
      foreach(System.Collections.Generic.KeyValuePair<string, MetraFlowScriptPort> kvp in a.mOutputPorts)
      {
        if (!referencedOutputA.ContainsKey(kvp.Key))
        {
          if (mOutputPorts.ContainsKey(kvp.Key)) throw new UsageServerException("Duplicate port");
          mOutputPorts.Add(kvp.Key, kvp.Value);
        }
      }
      foreach(System.Collections.Generic.KeyValuePair<string, MetraFlowScriptPort> kvp in b.mInputPorts)
      {
        if (!referencedInputB.ContainsKey(kvp.Key))
        {
          if (mInputPorts.ContainsKey(kvp.Key)) throw new UsageServerException("Duplicate port");
          mInputPorts.Add(kvp.Key, kvp.Value);
        }
      }
      foreach(System.Collections.Generic.KeyValuePair<string, MetraFlowScriptPort> kvp in b.mOutputPorts)
      {
        if (!referencedOutputB.ContainsKey(kvp.Key))
        {
          if (mOutputPorts.ContainsKey(kvp.Key)) throw new UsageServerException("Duplicate port");
          mOutputPorts.Add(kvp.Key, kvp.Value);
        }
      }
    }

    public MetraFlowScript SetString(string parameterName, string value)
    {
      mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, 
                                                              DecorateParameter(parameterName),
                                                              value);
      return this;
    }
    public MetraFlowScript SetInt32(string parameterName, int value)
    {
      mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, 
                                                              DecorateParameter(parameterName), 
                                                              value.ToString(System.Globalization.CultureInfo.InvariantCulture));
      return this;
    }
    public MetraFlowScript SetDateTime(string parameterName, System.DateTime value)
    {
      mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, 
                                                              DecorateParameter(parameterName), 
                                                              value.ToString("yyyy-MM-dd HH:mm:ss"));
      return this;
    }
    public MetraFlowScript SetBinary(string parameterName, string value)
    {
      string usethis = MetraTech.Utils.MSIXUtils.DecodeUIDAsString(value);
      usethis = "0x" + usethis;
      mProgram = System.Text.RegularExpressions.Regex.Replace(mProgram, 
                                                              DecorateParameter(parameterName), 
                                                              usethis);
      return this;
    }

    public void Run(string loggerTag, IRecurringEventRunContext param, MetraFlowConfig metraFlowConfig)
    {
      MetraFlowRun r = new MetraFlowRun();
      Logger logger = new Logger("[" + loggerTag + "]");
      logger.LogInfo(mProgram);
      int ret = r.Run(mProgram, loggerTag, metraFlowConfig);
      if (ret != 0)
      {
        throw new UsageServerException("Adapter failure: check log for details");
      }
    }
  }

	[Guid("9b83822c-1ece-44c5-9578-7807f13d8fb1")]
	public interface IMetraFlowRun
	{
    int Run(string metraFlowProgram, string loggerTag, IMetraFlowConfig metraFlowConfig);
	}

	/// <summary>
	/// An helper class used to read in MetraFlow configuration information
  /// for adapters.
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("45dd4018-1266-4d22-b085-91f2ec2c8a4c")]
	public class MetraFlowRun : IMetraFlowRun
	{
    private Logger mLogger;
    private System.Diagnostics.Process mProcess;

    private void PumpStderr()
    {
      while(!mProcess.StandardError.EndOfStream)
      {
        mLogger.LogError(mProcess.StandardError.ReadLine());
      }
    }

    private void PumpStdout()
    {
      while(!mProcess.StandardOutput.EndOfStream)
      {
        mLogger.LogInfo(mProcess.StandardOutput.ReadLine());
      }
    }

    private void HandleStderr(object sendingProcess, System.Diagnostics.DataReceivedEventArgs outLine)
    {
      if (!String.IsNullOrEmpty(outLine.Data))
      {
        mLogger.LogError(outLine.Data);
      }
    }

    private void HandleStdout(object sendingProcess, System.Diagnostics.DataReceivedEventArgs outLine)
    {
      if (!String.IsNullOrEmpty(outLine.Data))
      {
        mLogger.LogInfo(outLine.Data);
      }
    }

		public MetraFlowRun()
		{
		}

    public int Run(string metraFlowProgram, string loggerTag, IMetraFlowConfig metraFlowConfig)
    {
      mLogger = new Logger(loggerTag);
      string pwdFile = System.IO.Path.GetTempFileName();

      try
      {
        // Write the program to a temporary file.
        string tempFile = System.IO.Path.GetTempFileName();
        using (System.IO.StreamWriter writer = new System.IO.StreamWriter(tempFile))
        {
          writer.Write(metraFlowProgram);
        }

        mProcess = new System.Diagnostics.Process();
        System.Text.StringBuilder partitionListParameters = new System.Text.StringBuilder();
        System.Collections.Generic.Dictionary<string, int> hosts = new System.Collections.Generic.Dictionary<string,int>();
        if (metraFlowConfig != null)
        {
          for(int i=0; i<metraFlowConfig.NumHosts; i++)
          {
            // Hostnames are case insensitive so conver to upper case.
            string upperHost = metraFlowConfig.GetHost(i).ToUpper();
            if (hosts.ContainsKey(upperHost))
              hosts[upperHost] = hosts[upperHost]+1;
            else
              hosts.Add(upperHost, 1);
          }

          for(int j=0; j<metraFlowConfig.NumPartitionLists; j++)
          {
            IMetraFlowPartitionList plist = metraFlowConfig.GetPartitionList(j);
            System.Text.StringBuilder listBuilder = new System.Text.StringBuilder();
            for(int k=0; k<plist.NumPartitions; k++)
            {
              if (listBuilder.Length > 0) 
                listBuilder.Append(",");
              listBuilder.Append(plist.GetPartition(k).ToString());
            }
            partitionListParameters.AppendFormat(" --partition-list \"{0}[{1}]\" ", plist.Name, listBuilder.ToString());
          }
        }

        string upperMachineName = System.Environment.MachineName.ToUpper();

        if (hosts.Count == 0)
        {
          mProcess.StartInfo.FileName = "MetraFlowShell.exe";
          mProcess.StartInfo.Arguments = string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                                       "--partitions 1 {1} \"{0}\" --encoding utf-8", 
                                                       tempFile, 
                                                       partitionListParameters.ToString());
        }
        else
        {
          // Cons up the mpiexec string, make sure local machine name appears and is the first
          // process so we can pass it the program as a file.
          if (!hosts.ContainsKey(upperMachineName))
          {
            mLogger.LogWarning("MetraFlow configuration does not contain Billing Server machine name.  Adding to configuration and continuing");
            hosts.Add(upperMachineName, 1);
          }

          // Check for existence of a MetraFlow username and password.
          // When running as a service we really have to use these since
          // LocalSystem won't have credentials to run.
          string pwdOption="";
          ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
          sa.Initialize();
          ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObjectIfExists("MetraFlowUser");
          if (accessData != null)
          {
            using (System.IO.StreamWriter writer = new System.IO.StreamWriter(pwdFile))
            {
              writer.WriteLine(accessData.UserName);
              writer.WriteLine(accessData.Password);
            }

            pwdOption = string.Format(System.Globalization.CultureInfo.InvariantCulture,
                                      "-pwdfile \"{0}\"", pwdFile);
          }

          mProcess.StartInfo.FileName = "mpiexec.exe";
          System.Text.StringBuilder sb = new System.Text.StringBuilder();
          sb.AppendFormat("-noprompt {3} -channel mt -n {0} -host {1} MetraFlowShell.exe {4} \"{2}\" --encoding utf-8", 
                          hosts[upperMachineName], 
                          upperMachineName, 
                          tempFile, 
                          pwdOption,
                          partitionListParameters.ToString());

          foreach(System.Collections.Generic.KeyValuePair<string, int> kvp in hosts)
          {
            if (kvp.Key != upperMachineName)
              sb.AppendFormat(" : -n {0} -host {1} MetraFlowShell.exe", kvp.Value, kvp.Key);
          }
          mProcess.StartInfo.Arguments = sb.ToString();
        }
        mProcess.StartInfo.RedirectStandardError = true;
        mProcess.StartInfo.RedirectStandardOutput = true;
        mProcess.StartInfo.RedirectStandardInput = true;
        mProcess.StartInfo.ErrorDialog = false;
        mProcess.StartInfo.CreateNoWindow = true;
        mProcess.StartInfo.UseShellExecute = false;
 
        // Set up async handlers to write stdout and stderr to log file.
        mProcess.OutputDataReceived += new System.Diagnostics.DataReceivedEventHandler(HandleStdout);
        mProcess.ErrorDataReceived += new System.Diagnostics.DataReceivedEventHandler(HandleStderr);

        // Send command line to log.
        mLogger.LogDebug(mProcess.StartInfo.FileName + " " + mProcess.StartInfo.Arguments);
     
        mProcess.Start();

        mProcess.BeginOutputReadLine();
        mProcess.BeginErrorReadLine();

        if (hosts.Count == 0)
        {
          mProcess.StandardInput.Write(metraFlowProgram);
        }
        mProcess.StandardInput.Close();


//         // Set up threads to process std out and std err
//         System.Threading.Thread stdOutThread = new System.Threading.Thread(new System.Threading.ThreadStart(this.PumpStdout));
//         System.Threading.Thread stdErrThread = new System.Threading.Thread(new System.Threading.ThreadStart(this.PumpStderr));
//         stdOutThread.Start();
//         stdErrThread.Start();

        mProcess.WaitForExit();
        int exitCode = mProcess.ExitCode;
        mProcess.Close();

//         stdOutThread.Join();
//         stdErrThread.Join();

        System.IO.File.Delete(tempFile);

        return exitCode;
      }
      catch(System.Exception e)
      {
        mLogger.LogError(e.StackTrace);
        return -1;
      }
      finally
      {
        // Never leave this puppy around!
        System.IO.File.Delete(pwdFile);
      }
    }
  }
}

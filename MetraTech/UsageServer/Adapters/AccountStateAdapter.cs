using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTAccountStates;

namespace MetraTech.UsageServer.Adapters
{
	/// <summary>
	/// AccountStateAdapter, responsible for 3 state transitions
	/// 1. From PendingFinalBill to Closed
	///    -------------------------------
	///    This is interval based. 
	/// 2. From Closed to PendingFinalBill
	///    -------------------------------
	///    This happens when a determination is made that a Closed account
	///    received usage the previous day.  If it does, then the account
	///    should go from Closed to PendingFinalBill state.
	/// 3. From Closed to Archived
	///    -----------------------
	///    Once an account has been in the Closed state for some configurable
	///    amount of time, it should transition to Archived state
	/// </summary>
	public class AccountStateAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
		private Logger mLogger = new Logger ("[AccountStateAdapter]");
		private string mConfigFile;
		
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return true; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}
		public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
		public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
		public bool HasBillingGroupConstraints { get { return false; } }

		private MetraTech.Interop.MTAccountStates.IMTAccountStateManager mAccStateMgr;
		private MetraTech.Interop.MTAccountStates.IMTAccountStateInterface mClosedState;
		private MetraTech.Interop.MTAccountStates.IMTAccountStateInterface mPFBState;
		const string CLOSED = "CL";
		const string ARCHIVED = "AR";
		const string PENDING_FINAL_BILL = "PF";

		public AccountStateAdapter()
		{
		}

		public void SplitReverseState(int parentRunID, 
									  int parentBillingGroupID,
									  int childRunID, 
									  int childBillingGroupID)
		{
			mLogger.LogDebug("Splitting reverse state of Account State Adapter");
		}

		public void Initialize(string eventName, 
							   string configFile, 
							   MetraTech.Interop.MTAuth.IMTSessionContext context, 
							   bool limitedInit)
		{
			mLogger.LogDebug("Initializing Change Account State");
			mLogger.LogDebug("Using config file: {0}", configFile);
			mConfigFile = configFile;
			mLogger.LogDebug (mConfigFile);
			
			mAccStateMgr = null;

			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			return;
		}

		public string Execute(IRecurringEventRunContext param)
		{
			string detail;

			mLogger.LogDebug("Executing Change Account State");

			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
			mLogger.LogDebug("Billing group ID = {0}", param.BillingGroupID);
			mLogger.LogDebug("Start Date = {0}", param.StartDate);
			mLogger.LogDebug("End Date = {0}", param.EndDate);

			// initialize a CLOSED state object
			RecurringEventType reType = param.EventType;
			if (reType == RecurringEventType.Scheduled)
			{
				mClosedState = CreateStateObject(CLOSED);
				mPFBState = null;

				// change from closed to pending final bill
				mClosedState.ChangeState (null, 
										  null, 
										  -1, 
										  -1,
										  PENDING_FINAL_BILL, 
										  param.StartDate,
										  param.EndDate);

				// change from closed to archived 
				mClosedState.ChangeState (null, 
										  null, 
										  -1, 
										  -1, 
										  ARCHIVED, 
										  param.StartDate,
										  param.EndDate);
				detail = "Closed changed to Pending Final Bill & Closed changed to Archived";
			}
			else if (reType == RecurringEventType.EndOfPeriod)
			{
				mClosedState = null;
				mPFBState = CreateStateObject(PENDING_FINAL_BILL);

				// change from pending final bill to closed
				// the end date will be ignored here since its interval based
				mPFBState.ChangeState(null, null, -1, 
									  param.BillingGroupID,
									  CLOSED, 
									  MetraTime.Now,
									  DateTime.MinValue);
				detail = "Pending Final Bill changed to Closed";
			}
			else // dont do anything
			{
				detail = "Unknown recurring event type";
				mLogger.LogError("Unknown Recurring Event Type");
			}

			return detail;
		}

		public string Reverse(IRecurringEventRunContext param)
		{
			string detail;

			mLogger.LogDebug("Reversing Account State Scheduled Adapters");
			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
			mLogger.LogDebug("Billing group ID = {0}", param.BillingGroupID);
			mLogger.LogDebug("Start Date = {0}", param.StartDate);
			mLogger.LogDebug("End Date = {0}", param.EndDate);

			RecurringEventType reType = param.EventType;

			// reverse CL to AR and CL to PF here	
			// call reverse CL to PF sp first
			if (reType == RecurringEventType.Scheduled)
			{
				mClosedState = CreateStateObject(CLOSED);
				mPFBState = null;

				// change from closed to pending final bill
				mClosedState.ReverseState(null, 
										  null, 
										  -1, 
										  -1, 
										  PENDING_FINAL_BILL, 
										  param.StartDate,
										  param.EndDate);

				// change from closed to archived 
				mClosedState.ReverseState(null, 
										  null, 
										  -1, 
										  -1, 
										  ARCHIVED, 
										  param.StartDate,
										  param.EndDate);
				detail = "Closed reversed to Pending Final Bill & Closed Reversed to Archived";
			}
			// reverse PF to CL here, so call reverse PF->CL  sp
			else if (reType == RecurringEventType.EndOfPeriod)
			{
				mClosedState = null;
				mPFBState = CreateStateObject(PENDING_FINAL_BILL);

				// change from pending final bill to closed
				// the end date will be ignored here since its interval based
				mPFBState.ReverseState(null, null, -1, 
									   param.BillingGroupID,
									   CLOSED, 
									   MetraTime.Now,
									   DateTime.MinValue);
				detail = "Pending Final Bill reversed to Closed";
			}
			else // do nothing
			{
				detail = "Unknown recurring event type";
				mLogger.LogError("Unknown Recurring Event Type");
			}
	
			return detail;
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down Account State Adapter");
			return;
		}
	
		MetraTech.Interop.MTAccountStates.IMTAccountStateInterface CreateStateObject(string state)
		{
			mAccStateMgr = new MTAccountStateManager();
  			mAccStateMgr.Initialize(-1, state);
  			return(mAccStateMgr.GetStateObject());	
		}
	}
}
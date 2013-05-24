using System;
using System.Xml;
using System.Collections;

namespace MetraTech.UsageServer.Adapters
{
	using MetraTech;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.MaterializedViews;
	using MetraTech.Interop.MTAuth;

	/// <summary>
	/// Materialized View Adapter used to populate materialized view (summary) tables
	/// which are configured in DEFERRED mode.
	/// </summary>
	public class MaterializedViewAdapter : MetraTech.UsageServer.IRecurringEventAdapter
	{
		// Materialized View manager object.
		private Manager mMaterializedViewMgr;

		// Data Members
		private Logger mLogger = new Logger ("[MaterializedViewAdapter]");
		
		// Adapter capabilities
		public bool SupportsScheduledEvents { get { return true; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}
		
		public MaterializedViewAdapter()
		{
			mMaterializedViewMgr = new Manager();
			mMaterializedViewMgr.Initialize();
		}

	    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			mLogger.LogDebug("Initializing Materialized View Adapter");
			mLogger.LogDebug("Using config file: {0}", configFile);
			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");
		}

		public string Execute(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Executing Materialized View Adapter");

			if (!mMaterializedViewMgr.IsMetraViewSupportEnabled)
			{
				mLogger.LogDebug("No deferred processing, Materialized View support is disabled.");
				return ("Materialized View support is disabled");
			}

			param.RecordInfo("Populating materialized view tables ... ");

			try
			{
				mMaterializedViewMgr.UpdateAllDeferredMaterializedViews();
			}
			catch (Exception e)
			{
				mLogger.LogError("Unable to execute DEFERRED update for materialized views, exceptions: " + e.ToString());
				throw e;
			}

			return ("Materialized View Adapter completed");
		}

		public string Reverse(IRecurringEventRunContext param)
		{
			string detail = "Materialized View Adapter Reverse Completed (nothing todo)";
			return detail;
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down Materialized View Adapter");
		}
	}
}

// EOF
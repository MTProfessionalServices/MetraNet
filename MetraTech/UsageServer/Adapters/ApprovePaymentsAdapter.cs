using System;
using System.Xml;
using System.Diagnostics;
using System.Runtime.InteropServices;

using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.COMMeter;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.UsageServer.Adapters
{
	using MetraTech.Interop.MeterRowset;
	using IMTSQLRowset = MetraTech.Interop.MeterRowset.IMTSQLRowset;

	/// <summary>
	/// ApprovePaymentsAdapter, used to flip a flag (enum) in the 
	/// t_pv_ps_paymentscheduler from PendingApproval to Pending  
  /// 
  /// This adapte is superceded by the PaymentAuthorizationAdapter in 6.0.1 
	/// </summary>
	internal class ApprovePaymentsAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return false; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.NotImplemented; }}
		public bool AllowMultipleInstances { get { return false; }}
		public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
		public BillingGroupSupportType BillingGroupSupport { get	{ return BillingGroupSupportType.Account; } }
		public bool HasBillingGroupConstraints { get { return false; } }

		public void Initialize(string eventName, 
    						   string configFile, 
    						   IMTSessionContext context, 
    						   bool limitedInit)
		{
			mLogger.LogDebug("Initializing {0}", mTag);
			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			ReadConfig(configFile);
			return;
		}

		public string Execute(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Executing {0}", mTag);

			// Get the list of account in billing group.
			IMTSQLRowset rowset = GetAccountsForBillingGroup("__GET_LIST_FOR_APPROVALS__", param);

			// Meter if not empty.
			if (!System.Convert.ToBoolean(rowset.EOF))
			{
				// meter data to pipeline to flip from "PendingApproval" to "Pending"
				param.RecordInfo("Starting the process of scheduling the records");
				MeterRowset(rowset, mService, param);
				param.RecordInfo("Done with process of scheduling the records");

				return "All payments approved";
			}
			else
				return "No items found that need to be approved";
		}

		public string Reverse(IRecurringEventRunContext param)
		{
			return "This adapter is not reversible";
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down ApprovePayments Adapter");
			return;
		}

		public void SplitReverseState(int parentRunID, 
								      int parentBillingGroupID,
									  int childRunID, 
									  int childBillingGroupID)
		{
			mLogger.LogDebug("Splitting reverse state of PaymentBilling Adapter");
		}

		private void ReadConfig(string configFile)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);

			mTag = doc.GetNodeValueAsString("/xmlconfig/tag", "ApprovePaymentsAdapter");

			mServer = doc.GetNodeValueAsString("/xmlconfig/server", mServer);
			mService = doc.GetNodeValueAsString("/xmlconfig/service", mService);
			mSessionSetSize = doc.GetNodeValueAsInt("/xmlconfig/sessionsetsize", 100);
			mWaitForCommitTimeout = doc.GetNodeValueAsInt("/xmlconfig/waitforcommittimeout", 60);
		}

		private IMTSQLRowset GetAccountsForBillingGroup(string QueryTag, IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
			mLogger.LogDebug("Billing group ID = {0}", param.BillingGroupID);
			mLogger.LogDebug("Start Date = {0}", param.StartDate);
			mLogger.LogDebug("End Date = {0}", param.EndDate);
			param.RecordInfo("Getting list of records that need to be scheduled");

			IMTSQLRowset rowset = (IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

			// The config path isn't actually used but it has to be valid
			rowset.Init("Queries\\UsageServer\\Adapters\\PaymentBillingAdapter");
			rowset.SetQueryTag(QueryTag);
			rowset.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID, false);
			rowset.AddParam("%%ID_BILLGROUP%%", param.BillingGroupID, false);

			mLogger.LogDebug("{0}: query: {1}", mTag, rowset.GetQueryString());

			rowset.Execute();
			return rowset;
		}

		private void MeterRowset(IMTSQLRowset rowset, string Service, IRecurringEventRunContext param)
		{
			IMeterRowset meterRowset = new MeterRowset();
			try
			{
				meterRowset.InitSDK(mServer);
				meterRowset.InitForService(Service);
				meterRowset.CreateAdapterBatchEx(param.RunID, mTag, "1");
				meterRowset.SessionSetSize = mSessionSetSize;
				meterRowset.AddCommonProperty("_intervalID", DataType.MTC_DT_INT, param.UsageIntervalID);
				meterRowset.MeterRowset(rowset);
				meterRowset.WaitForCommitEx(meterRowset.MeteredCount, mWaitForCommitTimeout,
										    param.RunID.ToString(), mTag, "1");

				if (meterRowset.MeterErrorCount > 0)
				{
					string msg = meterRowset.MeterErrorCount.ToString() + " sessions faild to meter!";
					mLogger.LogError(msg);
					param.RecordInfo(msg);
					throw new Exception(msg);
				}
			}
			finally
			{
				// Releases precious wininet connections held by the SDK
				Marshal.ReleaseComObject(meterRowset);
			}
		}

		// data
		private Logger mLogger = new Logger ("[ApprovePaymentsAdapter]");
		private IMeter mSDK = new Meter();

		// configuration
		private string mTag;
		private string mServer;
		private string mService;
		private int mSessionSetSize;
		private int mWaitForCommitTimeout;
	}
}

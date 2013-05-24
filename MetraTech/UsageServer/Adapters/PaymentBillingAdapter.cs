using System;
using System.Xml;
using System.Diagnostics;
using System.Runtime.InteropServices;

using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTEnumConfig;
using MetraTech.Interop.COMMeter;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.UsageServer.Adapters
{
	using MetraTech.Interop.MeterRowset;
	using IMTSQLRowset = MetraTech.Interop.MeterRowset.IMTSQLRowset;

	/// <summary>
	/// This adapter is depricated and is superceded by the PaymentSubmission Adapter
	/// in 6.0.1 
	/// </summary>
	internal class PaymentBillingAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// Adapter capabilities
		public bool SupportsScheduledEvents { get { return false; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}
		public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
		public BillingGroupSupportType BillingGroupSupport { get	{ return BillingGroupSupportType.Account; } }
		public bool HasBillingGroupConstraints { get { return false; } }

		public void Initialize(string eventName, 
			string configFile, 
			IMTSessionContext context, 
			bool limitedInit)
		{
			mLogger.LogDebug("Initializing Payment Billing Adapter");
			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			mEnumConfig = new MetraTech.Interop.MTEnumConfig.EnumConfigClass();

			ReadConfig(configFile);
			return;
		}

		public string Execute(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Executing Payment Billing Adapter");
			mLogger.LogDebug("Executing {0}", mTag);

			// Get the list of account in billing group.
			// Execute the query to get back the stuff to meter. query will look
			// only at those accounts for a specific interval in the t_invoice
			// table that have payment method "creditcard" or "creditorach"  
			IMTSQLRowset rowset = GetAccountsForBillingGroup("__GET_LIST_FOR_PAYMENTS__", null, param);

			// Meter if not empty.
			if (!System.Convert.ToBoolean(rowset.EOF))
			{
				param.RecordInfo("Starting the process of scheduling the records");
				MeterRowset(rowset, mService, param, false);
				param.RecordInfo("Done with process of scheduling the records");

				return "Done processing the records of payments to the payment scheduler";
			}
			else
				return "No rows found that need to be scheduled";
		}

		public string Reverse(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Executing Reverse Payment Billing Adapter");
			mLogger.LogDebug("Reversing {0}", mTag);

			// Get the list of account in billing group.
			IMTSQLRowset rowset = GetAccountsForBillingGroup("__GET_LIST_OF_PAYMENTS_TO_REVERSE__",
															 "metratech.com/paymentserver/PaymentStatus/PendingApproval",
															 param);

			// Meter if not empty.
			if (!System.Convert.ToBoolean(rowset.EOF))
			{
				param.RecordInfo("Starting the process of scheduling the records for reversal");
				MeterRowset(rowset, "metratech.com/ps_ReversePayments",	param, true);
				param.RecordInfo("Done with process of scheduling the records for reversal");

				return "All payments reversed";
			}
			else
				return "No rows found that need to be reversed";
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down PaymentBilling Adapter");
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

			mTag = doc.GetNodeValueAsString("/xmlconfig/tag", "PaymentBillingAdapter");

			mSessionCount = doc.GetNodeValueAsInt("/xmlconfig/sessioncount", 100);
			mSessionSetSize = doc.GetNodeValueAsInt("/xmlconfig/sessionsetsize", 100);
			mWaitForCommitTimeout = doc.GetNodeValueAsInt("/xmlconfig/waitforcommittimeout", 60);
			mServer = doc.GetNodeValueAsString("/xmlconfig/server");
			mService = doc.GetNodeValueAsString("/xmlconfig/service");
			mEnumSpace = doc.GetNodeValueAsString("/xmlconfig/enumspace");
			mEnumName = doc.GetNodeValueAsString("/xmlconfig/enumname");
			mEnumValue = doc.GetNodeValueAsString("/xmlconfig/enumvalue");
		}

		private IMTSQLRowset GetAccountsForBillingGroup(string QueryTag, string Status, IRecurringEventRunContext param)
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

			if (Status != null)
				rowset.AddParam("%%PAYMENT_STATUS%%", Status, false);

			int enumID = mEnumConfig.GetID(mEnumSpace, mEnumName, mEnumValue);
			rowset.AddParam("%%ENUM_ID%%", enumID, false);

			mLogger.LogDebug("{0}: query: {1}", mTag, rowset.GetQueryString());

			rowset.Execute();
			return rowset;
		}

		private void MeterRowset(IMTSQLRowset rowset, string Service, IRecurringEventRunContext param, bool bAddIntervalID)
		{
			IMeterRowset meterRowset = new MeterRowset();
			try
			{
				meterRowset.InitSDK(mServer);
				meterRowset.InitForService(Service);
				meterRowset.CreateAdapterBatchEx(param.RunID, mTag, "1");
				meterRowset.SessionSetSize = mSessionSetSize;

				if (bAddIntervalID)
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
		private Logger mLogger = new Logger ("[PaymentBillingAdapter]");
  		private IEnumConfig mEnumConfig;
		private IMeter mSDK = new Meter();

		// configuration
		private int mSessionCount;
		private int mSessionSetSize;
		private int mWaitForCommitTimeout;
		private string mTag;
		private string mService;
		private string mServer;
		private string mEnumSpace;
		private string mEnumName;
		private string mEnumValue;
	}
}

// EOF
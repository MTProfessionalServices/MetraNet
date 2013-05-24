using System.Reflection;
using System.Runtime.InteropServices;


// <xmlconfig>
//   <batchcount>10</batchcount>
//   <sessioncount>10</sessioncount>
//   <errorcount>10</errorcount>
//   <sessionsetsize>10</sessionsetsize>
//   <extradelay>0</extradelay>
//   <reversemode> </reversemode>
//   <scheduled>true</scheduled>
//   <endofperiod>true</endofperiod>
//   <multiinstance>true</multiinstance>
//   <failinitialize> </failinitialize>
//   <failexecute> </failexecute>
//   <failreverse> </failreverse>
//   <failshutdown> </failshutdown>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]

namespace MetraTech.UsageServer.Adapters
{
	using MetraTech.UsageServer;
	using MetraTech;
	using MetraTech.Xml;
	using MetraTech.Interop.MTAuth;
	using MetraTech.Interop.MeterRowset;

	using System.Diagnostics;
	using System;

	/// <summary>
	/// Basic adapter used only for testing.
	/// </summary>
	public class TestAdapter : IRecurringEventAdapter2
	{

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			mLogger.LogDebug("Initializing test adapter (config file = {0})",
											 configFile);

			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			mSessionContext = context;
			ReadConfig(configFile);

			if (mFailInitialize)
				throw new ApplicationException(string.Format("{0}: Initialize configured to fail", mTag));

			mLogger.LogDebug("{0}: Initialized", mTag);
		}

		public string Execute(IRecurringEventRunContext runContext)
		{
			string detail;

      runContext.RecordInfo("Test Adapter starting... ");

			mLogger.LogDebug("{0}: Executing test adapter", mTag);

			mLogger.LogDebug("{0}: Event type = {1}", mTag, runContext.EventType);
			mLogger.LogDebug("{0}: Run ID = {1}", mTag, runContext.RunID);
			mLogger.LogDebug("{0}: Usage interval ID = {1}", mTag, runContext.UsageIntervalID);
      mLogger.LogDebug("{0}: Billing Group ID = {1}", mTag, runContext.BillingGroupID);
			mLogger.LogDebug("{0}: Start Date = {1}", mTag, runContext.StartDate);
			mLogger.LogDebug("{0}: End Date = {1}", mTag, runContext.EndDate);

			// tests derived contexts
			mLogger.LogDebug("{0}: Dervied EOP context : {1}", mTag, runContext.CreateDerivedEndOfPeriodContext(999));
			mLogger.LogDebug("{0}: Dervied SCH context : {1}", mTag,
											 runContext.CreateDerivedScheduledContext(new DateTime(2003, 1, 1), new DateTime(2003, 12, 31)));

      if (mFailExecute)
      {
        runContext.RecordInfo("Configured to fail while executing... so I'm going to fail now");
        throw new System.ApplicationException(string.Format("{0}: Execute configured to fail", mTag));
      }

      if (mMeterSessions)
      {
        runContext.RecordInfo("Metering sessions");

        for (int i = 0; i < mBatchCount; i++)
        {
          IMeterRowset meterRowset = new MeterRowset();
          meterRowset.InitSDK("RecurringChargeServer");
          meterRowset.InitForService(mService);

          MetraTech.Interop.MeterRowset.IMTSQLRowset
            rowset = (MetraTech.Interop.MeterRowset.IMTSQLRowset)new MetraTech.Interop.Rowset.MTSQLRowset();

          // the config path isn't actually used but it has to be valid
          rowset.Init("config\\Queries\\UsageServer");

          rowset.SetQueryString(mQuery);
          rowset.AddParam("%%ERROR_COUNT%%", mErrorCount, false);
          rowset.AddParam("%%SUCCESS_COUNT%%", mSessionCount - mErrorCount, false);

          mLogger.LogDebug("{0}: query: {1}", mTag, rowset.GetQueryString());

          rowset.Execute();

          meterRowset.CreateAdapterBatch(runContext.RunID, mTag, i.ToString());
          meterRowset.SessionSetSize = mSessionSetSize;

          // places the usage in the correct interval (required since the interval is soft closed)
          meterRowset.AddCommonProperty("_IntervalId", DataType.MTC_DT_INT, runContext.UsageIntervalID);

          meterRowset.MeterRowset(rowset);

          // frees precious metering resources
          Marshal.ReleaseComObject(meterRowset);
        }
      }

      if (mExtraDelay > 0)
        Sleep(mExtraDelay, runContext);

			detail = string.Format("{0}: execute complete", mTag);

			return detail;
		}

		public string Reverse(IRecurringEventRunContext param)
		{
			string detail;

			mLogger.LogDebug("{0}: Reversing test adapter", mTag);

			Debug.Assert(mReverseMode == ReverseMode.Custom);

			mLogger.LogDebug("{0}: Event type = {1}", mTag, param.EventType);
			mLogger.LogDebug("{0}: Run ID = {1}", mTag, param.RunID);
			mLogger.LogDebug("{0}: Usage interval ID = {1}", mTag, param.UsageIntervalID);
			mLogger.LogDebug("{0}: Start Date = {1}", mTag, param.StartDate);
			mLogger.LogDebug("{0}: End Date = {1}", mTag, param.EndDate);

      if (mExtraReverseDelay > 0)
        Sleep(mExtraReverseDelay, param);

      if (mFailReverse)
      {
        param.RecordInfo("Configured to fail while reversing... so I'm going to fail now");
        throw new System.ApplicationException(String.Format("{0}: Reverse configured to fail", mTag));
      }

			detail = string.Format("{0}: reverse complete", mTag);
			
			return detail;
		}

		public void Shutdown()
		{
			mLogger.LogDebug("{0}: Shutting down test adapter", mTag);

			if (mFailShutdown)
				throw new System.ApplicationException(String.Format("{0}: Shutdown configured to fail", mTag));
		}
	
    public void CreateBillingGroupConstraints(int intervalID, int materializationID)  
    {
      throw new NotImplementedException("CreateBillingGroupConstraints has not been implemented");
    }

    public void SplitReverseState(int parentRunID, 
                                  int parentBillingGroupID,
                                  int childRunID, 
                                  int childBillingGroupID)
    {
    }

		public bool SupportsScheduledEvents
		{
			get
			{ return mScheduled; }
		}

		public bool SupportsEndOfPeriodEvents
		{
			get
			{ return mEndOfPeriod; }
		}

		public ReverseMode Reversibility
		{
			get
			{ return mReverseMode; }
		}

		public bool AllowMultipleInstances
		{
			get
			{ return mMultiInstance; }
		}

    public BillingGroupSupportType BillingGroupSupport 
    { 
      get	
      { 
        return mBillingGroupSupportType; 
      } 
    }

    public bool HasBillingGroupConstraints 
    { 
      get 
      {
        return mHasBillingGroupConstraints;
      }
    }
    		
    private void ReadConfig(string configFile)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);

			mSessionCount = doc.GetNodeValueAsInt("/xmlconfig/sessioncount", 100);
			mBatchCount = doc.GetNodeValueAsInt("/xmlconfig/batchcount", 1);
			mSessionSetSize = doc.GetNodeValueAsInt("/xmlconfig/sessionsetsize", mSessionCount);
			mErrorCount = doc.GetNodeValueAsInt("/xmlconfig/errorcount", 0);
			mReverseMode = (ReverseMode) doc.GetNodeValueAsEnum(typeof(ReverseMode), "/xmlconfig/reversemode", ReverseMode.Custom);
			mScheduled = doc.GetNodeValueAsBool("/xmlconfig/scheduled", false);
			mEndOfPeriod = doc.GetNodeValueAsBool("/xmlconfig/endofperiod", true);
			mMultiInstance = doc.GetNodeValueAsBool("/xmlconfig/multiinstance", true);
			mFailInitialize = doc.GetNodeValueAsBool("/xmlconfig/failinitialize", false);
			mFailExecute = doc.GetNodeValueAsBool("/xmlconfig/failexecute", false);
			mFailReverse = doc.GetNodeValueAsBool("/xmlconfig/failreverse", false);
			mFailShutdown = doc.GetNodeValueAsBool("/xmlconfig/failshutdown", false);
			mExtraDelay = doc.GetNodeValueAsInt("/xmlconfig/extradelay", 0);
			mTag = doc.GetNodeValueAsString("/xmlconfig/tag", "TestAdapter");
      mBillingGroupSupportType = 
        (BillingGroupSupportType) 
          Enum.Parse(typeof(BillingGroupSupportType), 
                     doc.GetNodeValueAsString("/xmlconfig/billingGroupSupportType", 
                                              BillingGroupSupportType.Interval.ToString()));
     
			if (mSessionCount > 0)
			{
				mService = doc.GetNodeValueAsString("/xmlconfig/service");
				mQuery = doc.GetNodeValueAsString("/xmlconfig/query");
			}

      //New settings for v6.5
      mExtraReverseDelay = doc.GetNodeValueAsInt("/xmlconfig/extrareversedelay", 0);
      mMeterSessions = doc.GetNodeValueAsBool("/xmlconfig/metersessions", mMeterSessions);

		}

    private void Sleep(int seconds, IRecurringEventRunContext param)
    {
      string msg = string.Format("Sleeping for {0} seconds...", seconds);
      param.RecordInfo(msg);
      mLogger.LogDebug(msg);

      System.Threading.Thread.Sleep(seconds * 1000);

      msg = "Done sleeping";

      param.RecordInfo(msg);
      mLogger.LogDebug(msg);
    }

		// helper classes
		private Logger mLogger = new Logger("[TestAdapter]");
		private IMTSessionContext mSessionContext;

		// configuration
    private bool mMeterSessions = true;
		private int mSessionCount;
		private int mBatchCount;
		private int mErrorCount;
		private int mSessionSetSize;
		private int mExtraDelay;
    private int mExtraReverseDelay;
		private ReverseMode mReverseMode;
		private bool mScheduled;
		private bool mEndOfPeriod;
		private bool mMultiInstance;
		private bool mFailInitialize;
		private bool mFailExecute;
		private bool mFailReverse;
		private bool mFailShutdown;
    private BillingGroupSupportType mBillingGroupSupportType;
    private bool mHasBillingGroupConstraints = false;
		private string mTag;
		private string mService;
		private string mQuery;
	}

}

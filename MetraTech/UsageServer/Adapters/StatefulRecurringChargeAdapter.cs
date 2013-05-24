using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;



// <xmlconfig>
//	<Program>
//  MetraFlowScript goes here
//	</Program>
//  <Parameter>Valid parameters are ID_INTERVAL, ID_BILLGROUP, ID_BATCH, DT_START, DT_END</Parameters>
//	<MetraFlow>
//  <Hostname>A list of hostnames for configuring cluster execution</Hostname>
//  </MetraFlow>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]  //ask

namespace MetraTech.UsageServer.Adapters
{
    /// <summary>
    /// StatefulRecurringChargeAdapter Adapter.
    /// </summary>
    public class StatefulRecurringChargeAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
    {
        // data
        private Logger mLogger = new Logger("[StatefulRecurringChargeAdapter]");
        private int mCommitTimeout;
        private int mSessionSetSize;
        private string mConfigFile;
        private bool mFailImmediately;

        //adapter capabilities
        public bool SupportsScheduledEvents { get { return false; } }
        public bool SupportsEndOfPeriodEvents { get { return true; } }
        public ReverseMode Reversibility { get { return ReverseMode.Auto; } }
        public bool AllowMultipleInstances { get { return false; } }
        public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
        public bool HasBillingGroupConstraints { get { return false; } }

        public StatefulRecurringChargeAdapter()
        {
            mCommitTimeout = 3600;
            mSessionSetSize = 1000;
            mFailImmediately = false;
        }

        public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
        {
            bool status;

            mLogger.LogDebug("Initializing StatefulRecurringCharge Adapter");
            mLogger.LogDebug("Using config file: {0}", configFile);
            mConfigFile = configFile;
            mLogger.LogDebug(mConfigFile);
            if (limitedInit)
                mLogger.LogDebug("Limited initialization requested");
            else
                mLogger.LogDebug("Full initialization requested");

            status = ReadConfigFile(configFile);
            if (status)
                mLogger.LogDebug("Initialize successful");
            else
                mLogger.LogError("Initialize failed, Could not read config file");


        }

        public string Execute(IRecurringEventRunContext context)
        {
            mLogger.LogDebug("Executing StatefulRecurringCharge Adapter");

            mLogger.LogDebug("Event type = {0}", context.EventType);
            mLogger.LogDebug("Run ID = {0}", context.RunID);
            mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
            mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

            // We support both rating through a pipeline and rating with MetraFlow.
            // In all cases we need a batch id for the adapter.
            MetraTech.Interop.MeterRowset.MeterRowset meterrs = new MetraTech.Interop.MeterRowset.MeterRowsetClass();
            meterrs.InitSDK("DiscountServer");
            string batchid = "";
            if (context != null)
            {
                MetraTech.Interop.MeterRowset.IBatch batch = meterrs.CreateAdapterBatch(context.RunID,
                                                                                        "StatefulRecurringChargeAdapter",
                                                                                        "StatefulRecurringChargeAdapter");
                batchid = batch.UID;
            }
            else
            {
                batchid = meterrs.GenerateBatchID();
            }

            mLogger.LogDebug("Batch ID = {0}", batchid);

            var meteredRecords = 0;

            // TODO: rerate on-demand recurring charges for this interval/billgroup

            // call stored procedure to generate charges
            using (var conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateCallableStatement("mtsp_generate_stateful_rcs"))
                {
                    stmt.AddParam("v_id_interval", MTParameterType.Integer, context.UsageIntervalID);
                    stmt.AddParam("v_id_billgroup", MTParameterType.Integer, context.BillingGroupID);
                    stmt.AddParam("v_id_run", MTParameterType.Integer, context.RunID);
                    stmt.AddParam("v_id_batch", MTParameterType.String, batchid);
                    stmt.AddParam("v_n_batch_size", MTParameterType.Integer, mSessionSetSize);
                    stmt.AddParam("v_run_date", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddOutputParam("p_count", MTParameterType.Integer);
                    var res = stmt.ExecuteNonQuery();
                    meteredRecords = (int)stmt.GetOutputValue("p_count");
                }
            }

            //
            // waits until all sessions commit
            //
            context.RecordInfo(string.Format("Waiting for sessions to commit (timeout = {0} seconds)", mCommitTimeout));
            meterrs.WaitForCommit(meteredRecords, mCommitTimeout);
            //
            // check for error during pipeline processing
            //
            if (meterrs.CommittedErrorCount > 0)
            {
                throw new ApplicationException(String.Format("{0} sessions failed during pipeline processing.", meterrs.CommittedErrorCount));
            }

            context.RecordInfo("StatefulRecurringChargeAdapter completed...");

            return "";
        }

        public string Reverse(IRecurringEventRunContext context)
        {
            // We are auto reverse so don't bother implementing
            mLogger.LogDebug("AutoReversing StatefulRecurringChargeAdapter");
            return "";
        }

        public void Shutdown()
        {
            mLogger.LogDebug("Shutting down StatefulRecurringChargeAdapter");
        }

        public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }

        public void SplitReverseState(int parentRunID,
                                      int parentBillingGroupID,
                                      int childRunID,
                                      int childBillingGroupID)
        {
            mLogger.LogDebug("Splitting reverse state of StatefulRecurringChargeAdapter");
        }

        private bool ReadConfigFile(string configFile)
        {
            MTXmlDocument doc = new MTXmlDocument();
            doc.Load(configFile);
            mSessionSetSize = doc.GetNodeValueAsInt("xmlconfig/SessionSetSize", 1000);
            mCommitTimeout = doc.GetNodeValueAsInt("xmlconfig/CommitTimeout", 3600);
            mFailImmediately = doc.GetNodeValueAsBool("xmlconfig/FailImmediately", false);

            return (true);
        }
    }
}

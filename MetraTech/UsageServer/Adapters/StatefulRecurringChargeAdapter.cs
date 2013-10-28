using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Interop.MTBillingReRun;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using IMTSessionContext = MetraTech.Interop.MTAuth.IMTSessionContext;
using BillingReRun = MetraTech.Interop.MTBillingReRun;
using BillingReRunClient = MetraTech.Pipeline.ReRun;

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
        private const string mUsageServerQueryPath = @"Queries\UsageServer";

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
                batchid = MetraTech.Utils.MSIXUtils.DecodeUIDAsString(batch.UID);
            }
            else
            {
                batchid = meterrs.GenerateBatchID();
            }

            mLogger.LogDebug("Batch ID = {0}", batchid);

            var meteredRecords = 0;

            // TODO: rerate on-demand recurring charges for this interval/billgroup
            BackoutResubmitUsage(context);

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
            // Waits until all sessions commit
            //
            context.RecordInfo(string.Format("Waiting for sessions to commit (timeout = {0} seconds)", mCommitTimeout));
            meterrs.WaitForCommit(meteredRecords, mCommitTimeout);
            //
            // Check for error during pipeline processing
            //
            if (meterrs.CommittedErrorCount > 0)
            {
                throw new ApplicationException(String.Format("{0} sessions failed during pipeline processing.", meterrs.CommittedErrorCount));
            }

            context.RecordInfo("StatefulRecurringChargeAdapter completed...");

            return "";
        }

        private void BackoutResubmitUsage(IRecurringEventRunContext context)
        {
            IMTBillingReRun rerun = new BillingReRunClient.Client();
            IMTSessionContext sessionContext = AdapterManager.GetSuperUserContext(); // log in as super user
            rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext)sessionContext);
            string comment = String.Format("Backing out recurring charges, in case rates have changed.");
            rerun.Setup(comment);

            const string joinClause =
                "inner join t_billgroup_member bgm on au.id_acc = bgm.id_acc " +
                "inner join t_billgroup bg on bg.id_usage_interval = au.id_usage_interval and bg.id_billgroup = bgm.id_billgroup " +
                "inner join t_enum_data ted on ted.id_enum_data = au.id_view";

            string whereClause =
            " and au.id_usage_interval = " + context.UsageIntervalID +
            " and bg.id_billgroup = " + context.BillingGroupID +
            " and ted.nm_enum_data in ('metratech.com/flatrecurringcharge','metratech.com/udrecurringcharge')";

            using (IMTConnection conn = ConnectionManager.CreateConnection("queries\\BillingRerun"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "_IDENTIFY_ACC_USAGE2_"))
                {
                    stmt.AddParam("%%STATE%%", "I");
                    stmt.AddParam("%%TABLE_NAME%%", rerun.TableName, true);
                    stmt.AddParam("%%JOIN_CLAUSE%%", joinClause, true);
                    stmt.AddParam("%%WHERE_CLAUSE%%", whereClause, true);
                    int rc = stmt.ExecuteNonQuery();
                }
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection(mUsageServerQueryPath))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mUsageServerQueryPath, "_DELETE_TEMP_ACCOUNTS_TABLE_FOR_BILLING_RERUN_"))
                {
                    stmt.ExecuteNonQuery();
                }
            }

            // Analyze
            rerun.Analyze(comment);
            // Backout and Resubmit
            rerun.BackoutResubmit(comment);
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

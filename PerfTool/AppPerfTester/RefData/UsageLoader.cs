using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Data;
using System.Data.Linq;
using System.Data.SqlClient;
using System.IO;
using System.Runtime.Serialization;
using System.Xml;

using NetMeterObj;
using MetraTech.DomainModel.ProductCatalog;
using log4net;
using BaselineGUI;

namespace AppRefData
{
    public class UsageLoader
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(UsageLoader));
        Progressable progress;
        private static Random rand = new Random();

        public ProductOffering targetPO = null;
        public int usagePerAccount = 0;
        private int m_numUsageRecordsBeforeFlushToDb = 10000;

        public UsageLoader()
        {
            progress = ProgressableFactory.find("Usage Loader");
        }

        public void loadUsage(SqlConnection conn)
        {
            log.Info("Starting load usage");

            Stopwatch watch = new Stopwatch();
            Stopwatch stopWatch = new Stopwatch();

            Random random = new Random();

            int targetAcctType = NetMeter.AccountTypeBy_name["CustomerAccount"].id_type;
            ProdView theProductView = null;
            foreach (var pvd in NetMeter.ProdViewList)
            {
                if (pvd.nm_name == "metratech.com/ldperfSimplePV")
                    theProductView = pvd;
            }
            log.InfoFormat("id_view: {0}", theProductView.id_view);

            log.InfoFormat("po.DisplayName: {0}", targetPO.DisplayName);
            log.InfoFormat("po.ProductOfferingId: {0}", targetPO.ProductOfferingId);
            foreach (var pi in targetPO.PriceableItems)
            {
                log.InfoFormat("pi.ID: {0}", pi.ID);
                log.InfoFormat("pi.PITemplate: {0}", pi.PITemplate);
            }


            #region Get the interval
            ////AccUsageCycle accUsageCycle = NetMeter.AccUsageCycleBy_id_acc[id_acc];
            ////List<UsageInterval> usageIntervals = NetMeter.UsageIntervalBy_id_usage_cycle[accUsageCycle.id_usage_cycle];
            //// looks like we can use any interval type to determine the partion
            //List<UsageInterval> usageIntervalsTmp = NetMeter.UsageIntervalBy_id_usage_cycle[3];

            //UsageInterval theUsageIntervalTmp = null;
            //foreach (UsageInterval ui in usageIntervalsTmp)
            //{
            //    if (ui.tx_interval_status != "O")
            //        continue;
            //    if (ui.dt_start > DateTime.Now)
            //        continue;
            //    if (ui.dt_end < DateTime.Now)
            //        continue;
            //    theUsageIntervalTmp = ui;
            //    break;
            //}

            //#endregion

            //#region // get the partion for this interval
            ////Partition partition = NetMeter.findPartition(DateTime.Now);
            //Partition partition = NetMeter.findPartition(theUsageIntervalTmp.id_interval);
            //log.InfoFormat("Using partition {0}", partition.partition_name);

            //FCDatabaseServer fcDatabase = FrameworkComponentFactory.find<FCDatabaseServer>();
            //conn = fcDatabase.getConnection(partition.partition_name);

            //// Bit of hack to get these to the right DB
            //AccUsage.adapterWidget.build(conn);
            //PvLdperfSimplePV.adapterWidget.build(conn);
            #endregion

            watch.Restart();
            int numPvs = usagePerAccount;
            int totalPvs = 0;

            if (usagePerAccount > 0)
            {
                // Create a list of AccountUsageCounter objects.  These will keep track of how many
                // usage records have been created for each account.  When a specific account reaches
                // the desired limit, it's entry will be removed from the list.
                List<AccountUsageCounter> accountUsageCounters = new List<AccountUsageCounter>();
                foreach (Account acct1 in NetMeter.AccountList)
                {
                    if (acct1.id_type != targetAcctType)
                        continue;
                   
                    AccountUsageCounter accountUsageCounter = new AccountUsageCounter();
                    accountUsageCounter.IdAcc = acct1.id_acc;
                    accountUsageCounter.CurrentCount = 0;
                    accountUsageCounters.Add(accountUsageCounter);
                }
                log.DebugFormat("initially accountUsageCounters.Count={0}", accountUsageCounters.Count);

                // Set up the progress reporting
                progress.Minimum = 0;
                progress.Value = totalPvs;
                progress.Maximum = usagePerAccount * accountUsageCounters.Count;
                progress.isRunning = true;
                ProgressableFactory.active = progress;

                // loop through adding usage and removing entries from accountUsageCounters until done
                while (true)
                {
                    // get a random index from the account that are left
                    int accIndex = rInt(accountUsageCounters.Count);

                    // get the account id which is also the key to the dictionary
                    int id_acc = accountUsageCounters[accIndex].IdAcc;

                    #region doing the usage addition
                    #region Get the interval
                    AccUsageCycle accUsageCycle = NetMeter.AccUsageCycleBy_id_acc[id_acc];
                    List<UsageInterval> usageIntervals = NetMeter.UsageIntervalBy_id_usage_cycle[accUsageCycle.id_usage_cycle];

                    UsageInterval theUsageInterval = null;
                    foreach (UsageInterval ui in usageIntervals)
                    {
                        if (ui.tx_interval_status != "O")
                            continue;
                        if (ui.dt_start > DateTime.Now)
                            continue;
                        if (ui.dt_end < DateTime.Now)
                            continue;
                        theUsageInterval = ui;
                        break;
                    }

                    if (theUsageInterval == null)
                        continue;
                    #endregion

                    #region fill the table rows
                    //for (int ix = 0; ix < numPvs; ix++)
                    //{
                    long idSess = NetMeter.getID64("id_sess");

                    System.Random randomAmount = new Random(int.MaxValue);
                    AccUsage au = new AccUsage();

                    au.id_sess = idSess;

                    Guid guid = Guid.NewGuid();
                    au.tx_UID = guid.ToByteArray();
                    au.id_acc = id_acc;
                    au.id_payee = id_acc;
                    au.id_view = theProductView.id_view;
                    au.id_usage_interval = theUsageInterval.id_interval;
                    au.id_parent_sess = null;
                    au.id_prod = null;
                    au.id_svc = (int)targetPO.ProductOfferingId;
                    au.dt_session = DateTime.Now;
                    au.amount = (decimal)randomAmount.Next(0, 10000);
                    au.am_currency = "USD";
                    au.dt_crt = DateTime.Now;
                    au.tx_batch = new byte[16];
                    au.tax_federal = null;
                    au.tax_state = null;
                    au.tax_county = null;
                    au.tax_local = null;
                    au.tax_other = null;
                    au.id_pi_instance = null;
                    au.id_pi_template = null;
                    au.id_se = id_acc;
                    au.div_currency = null;
                    au.div_amount = null;

                    PvLdperfSimplePV pv = new PvLdperfSimplePV();
                    pv.id_sess = idSess;
                    pv.id_usage_interval = theUsageInterval.id_interval;
                    pv.c_Notes = "N/A";

                    au.insert();
                    pv.insert();
                    totalPvs++;
                    //}
                    #endregion

                    if (AccUsage.adapterWidget.insertTable.Rows.Count >= m_numUsageRecordsBeforeFlushToDb)
                    {
                        progress.Value = totalPvs;
                        stopWatch.Restart();
                        AccUsage.adapterWidget.flush();
                        PvLdperfSimplePV.adapterWidget.flush();
                        stopWatch.Stop();
                        log.DebugFormat("Timing: flush {0}={1}ms", m_numUsageRecordsBeforeFlushToDb,
                            stopWatch.ElapsedMilliseconds);
                    }
                    #endregion

                    // add 1 to the number of times we metered to this account
                    accountUsageCounters[accIndex].CurrentCount++;
                    
                    // see if we've metered enough to this account and remove it if we did
                    if (accountUsageCounters[accIndex].CurrentCount == usagePerAccount)
                        accountUsageCounters.RemoveAt(accIndex);

                    // if we've metered enough to all the accounts we'll stop
                    if (accountUsageCounters.Count < 1)
                        break;
                }


                AccUsage.adapterWidget.flush();
                PvLdperfSimplePV.adapterWidget.flush();
            }

            watch.Stop();
            progress.isRunning = false;

            log.DebugFormat("Inserts took {0} milliseconds", watch.ElapsedMilliseconds);
            double rate = (totalPvs * 1000.0) / (double)watch.ElapsedMilliseconds;
            log.DebugFormat("PVs/second {0}", rate);
        }

        private static int rInt(int exclUB, int incLB = 0)
        {
            int t = rand.Next(incLB, exclUB);
            return t;
        }
    }

    public class AccountUsageCounter
    {
        public int IdAcc;
        public int CurrentCount;
    }
}

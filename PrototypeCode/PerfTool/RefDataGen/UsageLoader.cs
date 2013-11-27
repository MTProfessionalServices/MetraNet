using System;
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


namespace AppRefData
{
    public class UsageLoader
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(UsageLoader));

        public ProductOffering targetPO = null;
        public int usagePerAccount = 0;

        public UsageLoader()
        {
        }



        public void loadUsage(SqlConnection conn)
        {
            log.Info("Starting load usage");

            Stopwatch watch = new Stopwatch();

            Random random = new Random();

            int targetAcctType = NetMeter.AccountTypeBy_name["CustomerAccount"].id_type;
            ProdView theProductView = null;
            foreach (var pvd in NetMeter.ProdViewList)
            {
                if (pvd.nm_name == "metratech.com/ldperfSimplePV")
                    theProductView = pvd;
            }
            log.InfoFormat("id_view: {0}", theProductView.id_view);

            // Bit of hack to get these to the right DB
            //AccUsage.adapterWidget.conn = conn;
            //PvLdperfSimplePV.adapterWidget.conn = conn;


            log.InfoFormat("po.DisplayName: {0}", targetPO.DisplayName);
            log.InfoFormat("po.ProductOfferingId: {0}", targetPO.ProductOfferingId);
            foreach (var pi in targetPO.PriceableItems)
            {
                log.InfoFormat("pi.ID: {0}", pi.ID);
                log.InfoFormat("pi.PITemplate: {0}", pi.PITemplate);
            }


            Partition partition = NetMeter.findPartition(DateTime.Now);
            log.InfoFormat("Using partition {0}", partition.partition_name);

  

            watch.Restart();
            int numPvs = usagePerAccount;
            int totalPvs = 0;
            int numAccounts = 0;

            if (usagePerAccount > 0)
            {
                foreach (Account acct in NetMeter.AccountList)
                {
                    int id_acc = acct.id_acc;

                    if (acct.id_type != targetAcctType)
                        continue;

                    //if (numAccounts <= 0)
                    //    break;
                    numAccounts++;
                    if ((numAccounts % 1000) == 0)
                        Console.WriteLine("At {0} accounts", numAccounts);

                    // Console.WriteLine("Adding usage for {0}", am.nm_login);

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

                    for (int ix = 0; ix < numPvs; ix++)
                    {
                        long idSess = NetMeter.getID64("id_sess");

 
                        AccUsage au = new AccUsage();

                        au.id_sess = idSess;
                        au.tx_UID = new byte[16];
                        au.id_acc = id_acc;
                        au.id_payee = id_acc;
                        au.id_view = theProductView.id_view;
                        au.id_usage_interval = theUsageInterval.id_interval;
                        au.id_parent_sess = null;
                        au.id_prod = null;
                        au.id_svc = (int)targetPO.ProductOfferingId;
                        au.dt_session = DateTime.Now;
                        au.amount = 0.10M;
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
                    }

                    if (AccUsage.adapterWidget.insertTable.Rows.Count >= 10000)
                    {
                        AccUsage.adapterWidget.flush();
                        PvLdperfSimplePV.adapterWidget.flush();
                    }
                }

                AccUsage.adapterWidget.flush();
                PvLdperfSimplePV.adapterWidget.flush();
            }

            watch.Stop();

            Console.WriteLine("Inserts took {0} milliseconds", watch.ElapsedMilliseconds);
            double rate = (totalPvs * 1000.0) / (double)watch.ElapsedMilliseconds;
            Console.WriteLine("PVs/second {0}", rate);
        }

    }
}

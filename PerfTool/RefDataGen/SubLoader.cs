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

namespace AppRefData
{
    public class SubLoader
    {
        public SubLoader()
        {
        }

        public void addSubscriptions(SqlConnection conn)
        {
            Stopwatch watch = new Stopwatch();

            int targetAcctType = NetMeter.AccountTypeBy_name["CustomerAccount"].id_type;

            watch.Restart();
            int totalSubs = 0;
            int numAccounts = 0;
            int id_po = 116;

            Sub newSub = new Sub();
            newSub.id_sub_ext = new byte[16];
            SubHistory newSubHistory = new SubHistory();
            newSubHistory.id_sub_ext = new byte[16];

            DateTime yesterday = DateTime.Parse("2012-12-05 00:00:00");
            DateTime endOfTime = DateTime.Parse("2038-12-31 00:00:00");

            foreach (var am in NetMeter.AccountMapperList)
            {
                numAccounts++;
                if ((numAccounts % 1000) == 0)
                    Console.WriteLine("At {0} accounts", numAccounts);

                int id_acc = am.id_acc;
                Account acct = NetMeter.AccountBy_id_acc[id_acc];

                if (acct.id_type != targetAcctType)
                    continue;

                if (NetMeter.SubBy_id_acc.ContainsKey(id_acc))
                {
                    List<Sub> subList = NetMeter.SubBy_id_acc[id_acc];
                    bool found = false;
                    foreach (Sub s in subList)
                    {
                        if (s.id_po == id_po)
                        {
                            found = true;
                            break;
                        }

                    }
                    if (found)
                        continue;
                }


                int id_sub = NetMeter.getMashedID32("id_subscription");

                newSub.id_group = null;
                newSub.id_acc = id_acc;
                newSub.dt_crt = yesterday;
                newSub.id_po = id_po;
                newSub.vt_start = yesterday;
                newSub.vt_end = endOfTime;

                newSubHistory.dt_crt = yesterday;
                newSubHistory.id_acc = id_acc;
                newSubHistory.id_group = null;
                newSubHistory.id_po = id_po;
                newSubHistory.id_sub = id_sub;
                // newSubHistory.id_sub_ext
                newSubHistory.tt_start = yesterday;
                newSubHistory.tt_end = endOfTime;
                newSubHistory.vt_start = yesterday;
                newSubHistory.vt_end = endOfTime;

                newSub.insert();
                newSubHistory.insert();
                totalSubs++;

                if (Sub.adapterWidget.insertTable.Rows.Count >= 10000)
                {
                    Sub.adapterWidget.flush();
                    SubHistory.adapterWidget.flush();
                }

            }

            Sub.adapterWidget.flush();
            SubHistory.adapterWidget.flush();

            watch.Stop();

            Console.WriteLine("Inserts took {0} milliseconds", watch.ElapsedMilliseconds);
            double rate = (totalSubs * 1000.0) / (double)watch.ElapsedMilliseconds;
            Console.WriteLine("Subs/second {0}", rate);
        }

    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data.SqlClient;
using System.Threading;
using System.Data;
using NetMeterObj;
//using MetraTech.DomainModel.AccountTypes;
//using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Diagnostics;


namespace AppRefData
{
    class Program
    {
        public static Tuple<string, string> StringPair(string a, string b)
        {
            return new Tuple<string, string>(a, b);
        }

        static void Main(string[] args)
        {
            string s = string.Format("server=perf10;user id=sa;password=123;database=NetMeter");
            SqlConnection conn = new SqlConnection(s);
            conn.Open();

            Console.WriteLine("Starting load");
            NetMeter netMeter = new NetMeterObj.NetMeter();
            netMeter.init(conn);
            AdapterWidgetFactory.buildWidgets(conn);


            foreach (var kvp in AdapterWidgetFactory.widgets)
            {
                AdapterWidget aw = kvp.Value;
                Console.WriteLine("Table {0} ({3}) hasIdentity:{1} hasForeign:{2}", kvp.Key, aw.hasIdentity, aw.hasForeign, aw.objectId);
                foreach(Int32 fo in aw.foreignObjects)
                {
                    Console.WriteLine("    foreign:{0}", fo);
                }
            }

            Stopwatch watch = new Stopwatch();
            Random random = new Random();

            s = string.Format("server=perf10;user id=sa;password=123;database=N_20121001_20121231");
            SqlConnection uconn = new SqlConnection(s);
            uconn.Open();

            if (false)
            {
                UsageLoader usageLoader = new UsageLoader();
                usageLoader.loadUsage(uconn);
                return;
            }


            SubLoader subLoader = new SubLoader();
            subLoader.addSubscriptions(conn);
            return;




            Console.WriteLine("Hit any key to exit");
            Console.ReadKey();
        }








    }
}

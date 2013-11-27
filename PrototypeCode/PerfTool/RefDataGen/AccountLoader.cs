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
    public class AccountLoader
    {
        // What to do
        public int numToLoad = 0;

        public void loadAccounts( SqlConnection conn)
        {
            Stopwatch watch = new Stopwatch();
            Random random = new Random();

            SortedSet<int> allParents = new SortedSet<int>();

            int innerCount = Math.Min( 10000, numToLoad);
            int outerCount = 0;

            int acctNum = 0;
            while( acctNum < numToLoad)
            {
                watch.Restart();
                int ix;
                for (ix = 0; ix < 10000 && acctNum < numToLoad; ix++)
                {
                    CustomerAccount acct = new CustomerAccount();
                    int cx = random.Next(100);
                    string name = string.Format("Corp{0:D3}", cx);

                    acct.id_parent = NetMeter.AccountMapperBy_nm_login_nm_space[new Tuple<string, string>(name, "mt")].id_acc;
                    if (!allParents.Contains(acct.id_parent))
                        allParents.Add(acct.id_parent);

                    acct.initIDs();
                    acct.populate();
                    acct.pushAttributes();

                    acct.insertIntoDB();
                    acctNum++;
                }

                flushToDB();

                updateHasChildren(conn, allParents);

                watch.Stop();
                double aps = 1000.0 * (double)ix / (double)watch.ElapsedMilliseconds;
                Console.WriteLine("[{0}] Account Insert took {1}msec - {2} Accounts/sec", acctNum, watch.ElapsedMilliseconds, aps);
                outerCount++;
            }
        }


        public void updateHasChildren(SqlConnection conn, SortedSet<int> allParents)
        {
            string sql = "update t_account_ancestor set b_children='Y' where id_descendent=@X";
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = sql;
            cmd.CommandType = CommandType.Text;
            foreach (int id in allParents)
            {
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@X", id);
                cmd.ExecuteNonQuery();
            }
            allParents.Clear();
        }


        public static Tuple<string, string> StringPair(string a, string b)
        {
            return new Tuple<string, string>(a, b);
        }

        private void flushToDB()
        {
            for (int pass = 0; pass < 4; pass++)
            {
                foreach (var kvp in AdapterWidgetFactory.widgets)
                {
                    AdapterWidget aw = kvp.Value;
                    // Console.WriteLine("Flushing {0}", aw.tableName);
                    aw.flush();
                }
            }
        }

    }
}

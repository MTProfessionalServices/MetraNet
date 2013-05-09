using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using System.Data.SqlClient;
using System.Threading;
using System.Windows.Forms;
using System.IO;
using System.Data;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Xml;

using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;


namespace BaselineGUI
{
    public class AMGetAccountListQuery : AppMethodBase, AppMethodI
    {
        Statistic statistic;

        public AMGetAccountListQuery()
        {
            group = "account";
            name = "getAccountListQuery";
            fullName = "Get Account List (Quick Find)";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
        }

        public void teardown()
        {
        }

        public void dispose()
        {          
        }

        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            SqlConnection conn;

            try
            {
                FCDatabaseServer database = FrameworkComponentFactory.find<FCDatabaseServer>();
                conn = database.getConnection();
            }
            catch
            {
                return;
            }

            DataContext dc = new DataContext(conn);
            Random rnd = new Random();

            while (true)
            {
                if (stopFlag)
                    break;

                //int a = customerAccount.id_acc;
                int id_acc = Framework.netMeter.pickReadableAccountID();
                NetMeterObj.AccountMapper am = NetMeterObj.NetMeter.AccountMapperBy_id_acc[id_acc][0];

                //string sql = string.Format("select top 20 * from t_account_mapper where nm_login = {0} and nm_space={1}", am.nm_login, am.nm_space);
                string sql = "select top 20 * from t_account_mapper where nm_login >= {0} and nm_login < {1} and nm_space={2}";

                int length = rnd.Next(am.nm_login.Length-3) + 4;
                string n1 = am.nm_login.Substring(0, length);                
                string n2 = n1.Substring(0, n1.Length-1);
                char last = n1[n1.Length - 1];
                last++;
                n2 += last;
               
                watch.Restart();
                dc.ExecuteQuery<NetMeterObj.AccountMapper>(sql, n1, n2, am.nm_space);
                watch.Stop();
                statistic.addSample(watch.ElapsedMilliseconds);
            }

        }

    }
}

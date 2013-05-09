using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using AppRefData;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;


namespace BaselineGUI
{
    public class AMGetAccountListPartialUserName : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetAccountListPartialUserName));
        AccountServiceClient client = null;

        public AMGetAccountListPartialUserName()
        {
            group = "account";

            name = "getAccountListPartialUserName";
            fullName = "Get Account List Partial User Name";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            acquireClient(out client);
        }

        public void teardown()
        {
            releaseClient(client);
            client = null;
        }

        public void dispose()
        {
            disposeClient(client);
            client = null;
        }

        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            //int a = customerAccount.id_acc;
            int id_acc = Framework.netMeter.pickReadableAccountID();
            NetMeterObj.AccountMapper am = NetMeterObj.NetMeter.AccountMapperBy_id_acc[id_acc][0];

            DateTime timeStamp = DateTime.Now;
            MTList<Account> accounts = new MTList<Account>();
            accounts.PageSize = 10;
            accounts.CurrentPage = 1;
            MTFilterElement fe;

            string partialUserName = "";
            try
            {
                partialUserName = am.nm_login.Substring(0, 6) + "%";
            }
            catch (Exception)
            {
                partialUserName = am.nm_login;
            }
            log.DebugFormat("partialUserName={0}", partialUserName);
	    
            fe = new MTFilterElement("username", MTFilterElement.OperationType.Like, partialUserName);
            accounts.Filters.Add(fe);
            

            watch.Restart();
            client.GetAccountList(DateTime.Now, ref accounts, false);
            watch.Stop();
            int numRetrievedAccounts = accounts.Items.Count;
            statistic.addSample(watch.ElapsedMilliseconds, string.Format("Retrieved {0} accounts", numRetrievedAccounts));

            if (numRetrievedAccounts < 1)
            {
                throw new InvalidOperationException(
                    String.Format("Expected to retrieve 1 or more accounts, but retrieved {0} instead", numRetrievedAccounts));
            }
        }

    }
}

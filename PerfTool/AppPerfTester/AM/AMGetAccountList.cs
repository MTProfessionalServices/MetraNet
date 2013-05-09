using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;


namespace BaselineGUI
{
    public class AMGetAccountList : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        AccountServiceClient client = null;

        public AMGetAccountList()
        {
            group = "account";

            name = "getAccountList";
            fullName = "Get Account List";
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

            int id_acc = Framework.netMeter.pickReadableAccountID();
            NetMeterObj.AccountMapper am = NetMeterObj.NetMeter.AccountMapperBy_id_acc[id_acc][0];

            DateTime timeStamp = DateTime.Now;
            MTList<Account> accounts = new MTList<Account>();
            accounts.PageSize = 10;
            accounts.CurrentPage = 1;
            accounts.Filters.Add(new MTFilterElement("username", MTFilterElement.OperationType.Like, am.nm_login));

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

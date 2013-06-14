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
    public class AMLoadAccount : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        AccountServiceClient client = null;

        public AMLoadAccount()
        {
            group = "account";
            name = "loadAccount";
            fullName = "Load Account";
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

            DateTime timeStamp = DateTime.Now;

            Account acct;
            watch.Restart();
            client.LoadAccount(new AccountIdentifier(id_acc), timeStamp, out acct);
            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds);

            if (acct.UserName.Length < 1)
            {
                throw new InvalidOperationException(
                    String.Format("expected acct.UserName.Length >= 1, but got {0}",
                    acct.UserName.Length));
            }
        }

    }
}

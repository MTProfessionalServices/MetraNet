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
    public class AMGetInterval : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        UsageHistoryServiceClient client = null;

        public AMGetInterval()
        {
            group = "usage";
            name = "getInterval";
            fullName = "Get Account Intervals";
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
            //int a = customerAccount.id_acc;

            List<MetraTech.DomainModel.Billing.Interval> acctIntervals = new List<MetraTech.DomainModel.Billing.Interval>();
            watch.Restart();
            client.GetAccountIntervals(new AccountIdentifier(id_acc), out acctIntervals);
            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds,
                                String.Format("Retrieved {0} intervals for acct {1}", acctIntervals.Count, id_acc));

            if (acctIntervals.Count < 1)
            {
                throw new InvalidOperationException(string.Format("expected 1 or more interval, but got {0}", acctIntervals.Count));
            }
        }

    }
}

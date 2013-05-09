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
    public class AMGetSubscriptions : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        SubscriptionServiceClient client = null;

        public AMGetSubscriptions()
        {
            group = "subscription";
            name = "getSubscriptions";
            fullName = "Get Subscriptions";
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
            MTList<Subscription> subscriptions = new MTList<Subscription>();
            subscriptions.PageSize = 10;
            subscriptions.CurrentPage = 1;
	    

            status1 = string.Format("Account ({0})", id_acc);
            watch.Restart();
            client.GetSubscriptions(new AccountIdentifier(id_acc), ref subscriptions);
            watch.Stop();

            if (subscriptions.Items.Count < 1)
            {
                throw new InvalidOperationException(
                    String.Format("expected 1 or more subscriptions, but got {0}",
                    subscriptions.Items.Count));
            }
            statistic.addSample(watch.ElapsedMilliseconds);
        }

    }
}

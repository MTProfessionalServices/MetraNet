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
   public  class AMGetSubscriptionDetails : AppMethodBase, AppMethodI
      {
        Statistic statistic;
        SubscriptionServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetSubscriptionDetails));

        public AMGetSubscriptionDetails()
        {
            group = "subscription";
            name = "getSubscriptionsdetails";
            fullName = "Get Subscriptions Details";
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
            Subscription sub = new Subscription();
            MTList<Subscription> subs = new MTList<Subscription>();
            client.GetSubscriptions(new AccountIdentifier(id_acc), ref subs);
            status1 = string.Format("Account ({0})", id_acc);
            
            System.Random random = new Random();
            int subscriptionId = (int)subs.Items[random.Next(0, subs.Items.Count)].SubscriptionId;
            log.Info(String.Format("Getting subscription details for subid {0} for account {1}", subscriptionId, id_acc));
            watch.Restart();
            client.GetSubscriptionDetail(new AccountIdentifier(id_acc), subscriptionId, out sub); 
            watch.Stop();

            if (sub.GetProperties().Count < 5)
            {
                throw new InvalidOperationException(
                    String.Format("expected sub.GetProperties().Count to be > 5, but got {0}",
                    sub.GetProperties().Count));
            }
            statistic.addSample(watch.ElapsedMilliseconds);
        }

    }
}
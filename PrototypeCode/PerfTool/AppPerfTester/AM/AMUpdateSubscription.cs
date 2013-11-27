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
    class AMUpdateSubscription : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        SubscriptionServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMUpdateSubscription));

        public AMUpdateSubscription()
        {
            group = "subscription";
            name = "updateSubscription";
            fullName = "Update Subscriptions";
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
            try
            {
                Stopwatch watch = new Stopwatch();
                MTList<Subscription> subscriptions = new MTList<Subscription>();
                Subscription sub = new Subscription();
                MTList<Subscription> subs = new MTList<Subscription>();

                int id_acc = Framework.netMeter.pickReadableAccountID();
                client.GetSubscriptions(new AccountIdentifier(id_acc), ref subs);
                status1 = string.Format("Account ({0})", id_acc);

                if (subs.Items.Count == 0)
                    return;

                System.Random random = new Random();
                sub = subs.Items[random.Next(0, subs.Items.Count)];
                // Got a random subscription that the account is subscribed to
                // Apply updates
                log.Info(String.Format("Updating subscriptionid {0}. Old StartDate : {1}. Old EndDate : {2}",
                                       sub.SubscriptionId, sub.SubscriptionSpan.StartDate, sub.SubscriptionSpan.EndDate));

                sub.SubscriptionSpan = new ProdCatTimeSpan();
                ProdCatTimeSpan span = new ProdCatTimeSpan();
                DateTime start = new DateTime();
                start = new DateTime(2012, 12, 17);
                DateTime end = new DateTime(2038, 1, 1);

                // Ideally start date would subscription available date
                span.StartDate = RandomDay(start, DateTime.UtcNow);
                span.EndDate = RandomDay(start, end);
                sub.SubscriptionSpan = span;

                log.Info(String.Format("Updating subscriptionid {0}. New StartDate : {1}. New EndDate : {2}",
                                       sub.SubscriptionId, span.StartDate, span.EndDate));
                watch.Restart();
                client.UpdateSubscription(new AccountIdentifier(id_acc), sub);
                watch.Stop();
                statistic.addSample(watch.ElapsedMilliseconds);

            }
            catch (Exception ex)
            {
                log.Error(String.Format("Caught exception when trying to update subscription {0}", ex.Message));
                return;
            }
        }

        private DateTime RandomDay(DateTime start, DateTime end)
        {
            //DateTime start = new DateTime(1995, 1, 1);
            Random gen = new Random();

            int range = (end - start).Days;
            return start.AddDays(gen.Next(range));
        }

    }
}


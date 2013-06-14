using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.ServiceModel;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using log4net;

namespace BaselineGUI
{
    class AMSubscriptionAddSlim : AppMethodBase, AppMethodI
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(AMSubscriptionAddSlim));
        private Statistic statisticAddSlim;
        private FCProductOffers allPOs = Framework.productOffers;
        SubscriptionServiceClient client = null;

        public AMSubscriptionAddSlim()
        {
            group = "subscription";
            name = "subscriptionAddSlim";
            fullName = "Add Subscriptions Slim";
            commands.Add("go", goAdd);

            statisticAddSlim = useStatistic("subscriptionAddSlim");
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

        public void goAdd()
        {
            int id_acc = Framework.netMeter.pickModifiableAccountID();
            log.DebugFormat("id_acc={0}", id_acc);

            try
            {
                Stopwatch watch = new Stopwatch();
                MTList<Subscription> subs = new MTList<Subscription>();
                System.Random random = new Random();
                List<Subscription> subList = new List<Subscription>();
                Subscription sub;

                watch.Restart();
                client.GetSubscriptions(new AccountIdentifier(id_acc), ref subs);
                watch.Stop();

                subList = subs.Items;
                log.DebugFormat("Total subs on account {0}={1}", id_acc, subs.TotalRows);

                if (subs.TotalRows == 0)
                {
                    // There were 0 subscriptions for this account, so add one
                    sub = new Subscription();
                    sub.ProductOfferingId = (int)allPOs.productOfferings[random.Next(0, allPOs.productOfferings.Count)].ProductOfferingId;
                    sub.SubscriptionSpan = new ProdCatTimeSpan();
                    sub.SubscriptionSpan.StartDate = DateTime.Now;

                    log.DebugFormat("Found zero subscriptions, so adding {0} to id_acc={1}",
                                   (allPOs.productOfferings.Find(p => p.ProductOfferingId == sub.ProductOfferingId).
                                       Name), id_acc);

                    watch.Restart();
                    client.AddSubscription(new AccountIdentifier(id_acc), ref sub);
                    watch.Stop();

                    statisticAddSlim.addSample(watch.ElapsedMilliseconds);
                   
                }
                else
                {
                    List<ProductOffering> availablePOs = allPOs.productOfferings;

                    foreach (Subscription subscrip in subList)
                        availablePOs.Remove(subscrip.ProductOffering);

                    if (availablePOs.Count == 0)
                    {
                        // TODO : logic to handle case where all available pos already exist on the account
                        // delete the po and add back
                    }
                    else
                    {
                        Subscription newSubscription = new Subscription();
                        int val;
                        val = random.Next(0, availablePOs.Count);
                        newSubscription.ProductOfferingId = (int)availablePOs[val].ProductOfferingId;
                        newSubscription.SubscriptionSpan = new ProdCatTimeSpan();
                        newSubscription.SubscriptionSpan.StartDate = DateTime.Now;

                        log.Info(String.Format("Subscribing to {0}",
                                               (availablePOs.Find(
                                                   p => p.ProductOfferingId == newSubscription.ProductOfferingId)).Name));
                        watch.Restart();
                        client.AddSubscription(new AccountIdentifier(id_acc), ref newSubscription);
                        watch.Stop();
                        statisticAddSlim.addSample(watch.ElapsedMilliseconds);
                    }
                }
            }
            catch (FaultException<MASBasicFaultDetail> ex)
            {
                statisticAddSlim.addErr();
                log.Error(ProcessMASErrorDetail(ex));
            }
            catch (Exception ex)
            {
                statisticAddSlim.addErr();
                log.Error(ex.Message);
            }
        }
    }
}


using System;
using System.Diagnostics;
using System.ServiceModel;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;

namespace BaselineGUI
{
    public class AMSubscriptionDel : AppMethodBase, AppMethodI
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(AMSubscriptionDel));

        Statistic statisticDel;
        Statistic statisticGet;
        Statistic statisticUpdate;
        SubscriptionServiceClient client = null;

        public AMSubscriptionDel()
        {
            group = "subscription";
            name = "subscriptionDel";
            fullName = "Delete Subscriptions";

            commands.Add("del", goDelete);

            statisticDel = useStatistic("subscriptionDel");
            statisticGet = useStatistic("subscriptionGet");
            statisticUpdate = useStatistic("subscriptionUpdate");
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

        public void goDelete()
        {
            Stopwatch watch = new Stopwatch();

            stopFlag = false;

            int id_acc = Framework.netMeter.pickModifiableAccountID();

            MTList<Subscription> subscriptions = new MTList<Subscription>();
            {
                watch.Restart();
                client.GetSubscriptions(new AccountIdentifier(id_acc), ref subscriptions);
                watch.Stop();
                statisticGet.addSample(watch.ElapsedMilliseconds);
            }
            var foo = subscriptions.Items;

            foreach (var sub in foo)
            {

                {
                    log.DebugFormat("Updating start date for sub {0}", sub.SubscriptionId);
                    sub.SubscriptionSpan.StartDate = DateTime.Now.AddHours(30);
                    watch.Restart();
                    client.UpdateSubscription(new AccountIdentifier(id_acc), sub);
                    watch.Stop();
                    statisticUpdate.addSample(watch.ElapsedMilliseconds);
                }

                try
                {
                    status1 = string.Format("Deleting {0}", sub.SubscriptionId);
                    int id_po = sub.ProductOfferingId;
                    watch.Restart();
                    client.DeleteSubscription(new AccountIdentifier(id_acc), (int)sub.SubscriptionId);
                    watch.Stop();
                    NetMeterObj.NetMeter.delSub(id_acc, id_po);
                    statisticDel.addSample(watch.ElapsedMilliseconds);
                }
                catch (FaultException<MASBasicFaultDetail> e)
                {
                    log.DebugFormat("Caught {0}", e.Message);
                    foreach (var m in e.Detail.ErrorMessages)
                    {
                        log.DebugFormat("   MAS Fault {0}", m);
                    }
                    statisticDel.addErr();
                }
                catch (Exception e)
                {
                    log.DebugFormat("Caught {0}", e.Message);
                    //client.Abort();
                    statisticDel.addErr();
                }

            }
        }


    }
}

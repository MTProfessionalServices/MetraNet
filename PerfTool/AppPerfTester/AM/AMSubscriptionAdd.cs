using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.ServiceModel;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;

namespace BaselineGUI
{
  public class AMSubscriptionAdd : AppMethodBase, AppMethodI
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(AMSubscriptionAdd));

    private Statistic statisticGet;
    private Statistic statisticAdd;
    private Statistic statisticUpdate;
    private Statistic statisticDelete;
    SubscriptionServiceClient client = null;

    // If an account currently has zero subscriptions, we will need to add one
    // for this test.  During setup, we will determine the productOfferingId
    // using the productOfferingName shown below.  This assumes that we pcimportexport
    // the product offerings contained in extension ldperf.
    private int m_productOfferingIdToAdd = -1;
    private string m_productOfferingName = "12H4GB";

    public AMSubscriptionAdd()
    {
      group = "subscription";
      name = "subscriptionAdd";
      fullName = "Add Subscriptions";
      commands.Add("go", goAdd);

      statisticGet = useStatistic("subscriptionGet");
      statisticAdd = useStatistic("subscriptionAdd");
      statisticUpdate = useStatistic("subscriptionUpdate");
      statisticDelete = useStatistic("subscriptionDelete");
    }

    public void setup()
    {
      acquireClient(out client);
      
      ProductOffering productOffering = Framework.productOffers.findPO(m_productOfferingName);
      if (productOffering == null)
      {
        log.ErrorFormat("failed to find {0} product offering, subscription tests will fail",
          m_productOfferingName);
      }
      else if (productOffering.ProductOfferingId.HasValue)
      {
        m_productOfferingIdToAdd = productOffering.ProductOfferingId.Value;
        log.DebugFormat("productOfferingIdToAdd = {0}", m_productOfferingIdToAdd);
      }
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

        watch.Restart();
        client.GetSubscriptions(new AccountIdentifier(id_acc), ref subs);
        watch.Stop();
        statisticGet.addSample(watch.ElapsedMilliseconds);

        Subscription sub;
        bool foundValidSubscriptionToDelete = false;
        int productOfferingIdToDelete;
        log.DebugFormat("subs.TotalRows={0}", subs.TotalRows);

        if (subs.TotalRows == 0)
        {
          // There were 0 subscriptions for this account, so add one
          sub = new Subscription();
          sub.ProductOfferingId = m_productOfferingIdToAdd;
          sub.SubscriptionSpan = new ProdCatTimeSpan();
          sub.SubscriptionSpan.StartDate = DateTime.Now;

          watch.Restart();
          client.AddSubscription(new AccountIdentifier(id_acc), ref sub);
          watch.Stop();

          statisticAdd.addSample(watch.ElapsedMilliseconds);
          log.DebugFormat("found zero subscriptions, so added one to id_acc={0}", id_acc);
          productOfferingIdToDelete = m_productOfferingIdToAdd;
          foundValidSubscriptionToDelete = true;
        }
        else
        {
#if true
          List<Subscription> subList = subs.Items;

          sub = subList[0];
          productOfferingIdToDelete = sub.ProductOfferingId;
          for (int i = 0; i < subs.TotalRows; i++)
          {
            Random rand = new Random();
            int subscriptionIndexToDelete = rand.Next(subList.Count - 1);
            log.DebugFormat("subscriptionIndexToDelete={0}", subscriptionIndexToDelete);

            sub = subList[subscriptionIndexToDelete];
            log.DebugFormat(
                "DisplayName={0}, StartDate={1}, AvailableTimeSpan.StartDate={2}, canUserSubscribe={3}",
                sub.ProductOffering.DisplayName, sub.SubscriptionSpan.StartDate,
                sub.ProductOffering.AvailableTimeSpan.StartDate,
                sub.ProductOffering.CanUserSubscribe);

            productOfferingIdToDelete = sub.ProductOfferingId;
            log.DebugFormat("productOfferingIdToDelete={0}", productOfferingIdToDelete);

            // TBD FIX THIS
            if ((sub.ProductOffering.DisplayName != "11 timer / 1 GB") &&
                (sub.ProductOffering.DisplayName != "20 timer / 10 GB") &&
                (sub.ProductOffering.DisplayName != "3 timer / 500 MB") &&
                (sub.ProductOffering.DisplayName != "500 timer / 10 GB") &&
                (sub.ProductOffering.DisplayName != "2 timer / 1 GB") &&
                (sub.ProductOffering.DisplayName != "5 timer / 3 GB") &&
                (sub.ProductOffering.DisplayName != "6 timer / 1 GB") &&
                (!sub.ProductOffering.DisplayName.StartsWith("Mobilt Bredb") &&
                 (!sub.ProductOffering.DisplayName.EndsWith(" Budget"))))
            {
              foundValidSubscriptionToDelete = true;
              break;
            }
          }
#endif
        }

#if true
        if (foundValidSubscriptionToDelete)
        {
          // move the start date of the subscription into the future
          DateTime futureDate = DateTime.Now.AddHours(1.0);
          sub.SubscriptionSpan.StartDate = futureDate;
          log.DebugFormat("updating subscription for id_acc={0}, id_po={1}, StartDate={2}",
              id_acc, productOfferingIdToDelete, futureDate);
          watch.Restart();
          client.UpdateSubscription(new AccountIdentifier(id_acc), sub);
          watch.Stop();
          statisticUpdate.addSample(watch.ElapsedMilliseconds);

          log.DebugFormat("After UpdateSubscription");
          log.DebugFormat("deleting subscriptionId={0} from id_acc={1}",
              sub.SubscriptionId.Value, id_acc);
          watch.Restart();
          client.DeleteSubscription(new AccountIdentifier(id_acc), sub.SubscriptionId.Value);
          watch.Stop();
          statisticDelete.addSample(watch.ElapsedMilliseconds);

          log.DebugFormat("After DeleteSubscription");

          // now add back the subscription
          Subscription newSubscription = new Subscription();
          newSubscription.ProductOfferingId = (int)productOfferingIdToDelete;
          newSubscription.SubscriptionSpan = new ProdCatTimeSpan();
          newSubscription.SubscriptionSpan.StartDate = DateTime.Now;

          watch.Restart();
          client.AddSubscription(new AccountIdentifier(id_acc), ref newSubscription);
          watch.Stop();
          statisticAdd.addSample(watch.ElapsedMilliseconds);
        }
        else
        {
          log.ErrorFormat("did not find valid subscription to delete for id_acc={0}", id_acc);
        }
#endif
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        statisticAdd.addErr();
        log.Error(ProcessMASErrorDetail(ex));
      }
      catch (Exception ex)
      {
        statisticAdd.addErr();
        log.Error(ex.Message);
      }


    }
  }
}

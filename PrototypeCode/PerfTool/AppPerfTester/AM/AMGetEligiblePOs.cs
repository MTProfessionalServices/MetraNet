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
using log4net.Core;
using log4net.Repository.Hierarchy;


namespace BaselineGUI
{
    public class AMGetEligiblePOs : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        SubscriptionServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetEligiblePOs));

        public AMGetEligiblePOs()
        {
            group = "subscription";
            name = "getEligiblePOs";
            fullName = "Get Eligible PO's";
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
            DateTime effectiveDt = DateTime.Now;
            MTList<ProductOffering> prodOfferings = new MTList<ProductOffering>();

            log.Info(String.Format("Getting eligiblePOs for accountID {0}", id_acc));

            watch.Restart();
            client.GetEligiblePOsForSubscription(new AccountIdentifier(id_acc), effectiveDt, ref prodOfferings);
            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds, 
                string.Format("Retrieved {0} product offerrings", prodOfferings.Items.Count));

            if (prodOfferings.TotalRows < 10)
            {
                throw new InvalidOperationException(String.Format("expected 10 or more product offerings, but got {0}",
                    prodOfferings.TotalRows));
            }
        }

    }
}

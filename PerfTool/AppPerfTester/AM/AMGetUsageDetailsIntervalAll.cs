using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global;

namespace BaselineGUI
{
    public class AMGetUsageDetailsIntervalAll : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        UsageHistoryServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetUsageDetailsIntervalAll));

        public AMGetUsageDetailsIntervalAll()
        {
            group = "usage";
            name = "getUsageDetailsIntervalAll";
            fullName = "Get Usage Details IntervalAll";
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

        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            while (true)
            {

                // determine the account where we will search for usage
                int id_acc = Framework.netMeter.pickReadableAccountID();
                log.DebugFormat("id_acc={0}", id_acc);

                // find an open interval
                List<MetraTech.DomainModel.Billing.Interval> acctIntervals =
                    new List<MetraTech.DomainModel.Billing.Interval>();
                MetraTech.DomainModel.Billing.Interval openInterval = null;
                client.GetAccountIntervals(new AccountIdentifier(id_acc), out acctIntervals);
                foreach (var intervalCandidate in acctIntervals)
                {
                    if (intervalCandidate.Status == IntervalStatusCode.Open)
                    {
                        openInterval = intervalCandidate;
                        break;
                    }
                }

                UsageIntervalSlice usageIntervalSlice = new UsageIntervalSlice();
                usageIntervalSlice.UsageInterval = openInterval.ID;

                DateRangeSlice dr = new DateRangeSlice();
                DateTime now = DateTime.Now;
                dr.Begin = new DateTime(now.Year, now.Month, 01);
                dr.End = new DateTime(now.Year, now.Month, 01).AddMonths(1).AddDays(-1);
                TimeSlice timeSlice = dr;

                ReportParameters repParams = new ReportParameters();
                repParams.ReportView = ReportViewType.OnlineBill;
                repParams.InlineAdjustments = false;
                repParams.InlineVATTaxes = false;
                repParams.Language = LanguageCode.US;
                repParams.DateRange = usageIntervalSlice;
                //repParams.DateRange = timeSlice;

                ProductViewSlice pvSlice = new ProductViewSlice();
                pvSlice.ViewID = new PCIdentifier("metratech.com/ldperfSimplePV");
                SingleProductSlice productSlice = pvSlice;

                PayerAccountSlice paslice = new PayerAccountSlice();
                paslice.PayerID = new AccountIdentifier(id_acc);
                AccountSlice accountSlice = paslice;

                List<BaseProductView> list = new List<BaseProductView>();

                watch.Restart();
                client.GetUsageDetailsAll(repParams, productSlice, accountSlice, false, ref list);
                watch.Stop();
                
                if (list.Count < 5)
                {
                    log.ErrorFormat("expected 5 or more usage records, but got {0}",
                                    list.Count);
                }
                else
                {
                    statistic.addSample(watch.ElapsedMilliseconds,
                                    String.Format("list.Count={0}", list.Count));
                    break;
                }
            }
        }

        public void dispose()
        {
            disposeClient(client);
            client = null;
        }
    }
}

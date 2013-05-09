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
    public class AMGetUsageDetailsFirstTen : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        UsageHistoryServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetUsageDetailsFirstTen));

        public AMGetUsageDetailsFirstTen()
        {
            group = "usage";
            name = "getUsageDetailsFirstTen";
            fullName = "Get Usage Details First Ten";
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

                DateRangeSlice dr = new DateRangeSlice();
                DateTime now = DateTime.Now;
                dr.Begin = new DateTime(now.Year, now.Month, 01).AddMonths(-1);
                dr.End = new DateTime(now.Year, now.Month, 01).AddMonths(1).AddDays(-1);
                TimeSlice timeSlice = dr;

                ReportParameters repParams = new ReportParameters();
                repParams.ReportView = ReportViewType.OnlineBill;
                repParams.InlineAdjustments = false;
                repParams.InlineVATTaxes = false;
                repParams.Language = LanguageCode.US;
                repParams.DateRange = timeSlice;

                ProductViewSlice pvSlice = new ProductViewSlice();
                pvSlice.ViewID = new PCIdentifier("metratech.com/ldperfSimplePV");
                SingleProductSlice productSlice = pvSlice;

                int id_acc = Framework.netMeter.pickModifiableAccountID();
                PayerAccountSlice paslice = new PayerAccountSlice();
                paslice.PayerID = new AccountIdentifier(id_acc);
                AccountSlice accountSlice = paslice;

                MTList<BaseProductView> list = new MTList<BaseProductView>();
                list.PageSize = 10;
                list.CurrentPage = 1;

                watch.Restart();
                client.GetUsageDetails(repParams, productSlice, accountSlice, ref list);
                watch.Stop();
                
                if (list.Items.Count < 5)
                {
                    log.ErrorFormat("expected 5 or more usage records, but got {0}",
                                    list.Items.Count);
                }
                else
                {
                    statistic.addSample(watch.ElapsedMilliseconds,
                                    String.Format("list.TotalRows={0}, list.Items.Count={1}",
                                                  list.TotalRows, list.Items.Count));
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

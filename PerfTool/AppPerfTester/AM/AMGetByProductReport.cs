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
    public class AMGetByProductReport : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        UsageHistoryServiceClient client = null;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMGetByProductReport));

        public AMGetByProductReport()
        {
            group = "usage";

            name = "getByProductReport";
            fullName = "Get by Product Report";
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

            DateRangeSlice dr = new DateRangeSlice();
            DateTime now = DateTime.Now;

            // construct a date range that goes from [1st day of previous month, last day of the current month]
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

            int id_acc = Framework.netMeter.pickReadableAccountID();
            PayerAccountSlice paslice = new PayerAccountSlice();
            AccountIdentifier PayerID = new AccountIdentifier(id_acc);
            ReportLevel reportData;

            watch.Restart();
            client.GetByProductReport(PayerID, repParams, out reportData);
            watch.Stop();
            statistic.addSample(watch.ElapsedMilliseconds);
            if (reportData == null)
            {
                log.DebugFormat("id_acc={0}, reportData is NULL", id_acc);
            }
            else if (reportData.Charges == null)
            {
                log.DebugFormat("id_acc={0}, reportData.Charges is NULL", id_acc);
            }
            else
            {
                log.DebugFormat("id_acc={0}, Charges.Count={1}, Charges[0]={2}, DisplayAmount={3}. ", id_acc, 
                    reportData.Charges.Count, reportData.Charges[0], reportData.DisplayAmount);
            }
                
        }
    }
}

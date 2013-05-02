using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;


//
// To run the this test fixture:
//  First, meter usage for audioConf subscriber Kevin
// nunit-console /fixture:MetraTech.Core.Services.Test.UsageHistoryServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
    public class UsageHistoryServiceTest
    {
        private Logger m_Logger = new Logger("[UsageHistoryServiceLogger]");

        [Test]
        [Category("GetAccountIntervals")]
        public void GetAccountIntervals()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            List<Interval> acctIntervals; // = new List<Interval>();
            AccountIdentifier identifier = new AccountIdentifier("kevin", "mt");

            client.GetAccountIntervals(identifier, out acctIntervals);

            Assert.IsNotNull(acctIntervals);
        

        }

        [Test]
        [Category("GetUsageDetails")]
        public void GetUsageDetails()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";
            DateRangeSlice dr = new DateRangeSlice();
            dr.Begin = new DateTime(2000, 01, 01);
            dr.End = new DateTime(2010, 12, 31);
            TimeSlice timeSlice = dr;

            /*
            PriceableItemTemplateSlice piSlice = new PriceableItemTemplateSlice();
            piSlice.PITemplateID = new PCIdentifier(399);
            piSlice.ViewID = new PCIdentifier(614);
            -- piinstance = 808
            SingleProductSlice productSlice = piSlice;
            */

            /*ProductViewAllUsageSlice piSlice = new ProductViewAllUsageSlice();
            piSlice.ViewID = new PCIdentifier("metratech.com/audioconfcall");*/

            PriceableItemInstanceSlice piSlice = new PriceableItemInstanceSlice();
            piSlice.PIInstanceID = new PCIdentifier("AudioConfCall");
            piSlice.POInstanceID = new PCIdentifier("Audio Conferencing Product Offering 3/16/2010 8:45:01 AM");
            piSlice.ViewID = new PCIdentifier("metratech.com/audioconfcall");

            SingleProductSlice productSlice = piSlice;

            PayerAccountSlice paslice = new PayerAccountSlice();
            paslice.PayerID = new AccountIdentifier("kevin", "mt");

            AccountSlice accountSlice = paslice;


            MTList<BaseProductView> list = new MTList<BaseProductView>();
            /*
            list.PageSize = 10;
            list.CurrentPage = 1;
            list.SortDirection = SortType.Descending;
            list.SortProperty = "Amount";
            MTFilterElement filter = new MTFilterElement("Amount", MTFilterElement.OperationType.Equal, "120");
            */

            ReportParameters repParams = new ReportParameters();
            repParams.ReportView = ReportViewType.OnlineBill;
            repParams.InlineAdjustments = true;
            repParams.InlineVATTaxes = true;
            repParams.Language = LanguageCode.US;
            repParams.DateRange = timeSlice;

            client.GetUsageDetails(repParams, productSlice, accountSlice, ref list);

            Assert.Greater(list.Items.Count, 0);
        }

        [Test]
        [Category("GetBillingHistory")]
        public void GetBillingHistory()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            List<Interval> intervals; // = new List<Interval>();
            AccountIdentifier identifier = new AccountIdentifier("mark", "mt");

            client.GetBillingHistory(identifier, LanguageCode.US, out intervals);

            Assert.Greater(intervals.Count, 0);

        }

        [Test]
        [Category("GetInvoiceReport")]
        public void GetInvoiceReport()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            //AccountIdentifier identifier = new AccountIdentifier("mark", "mt");
            AccountIdentifier identifier = new AccountIdentifier("demo", "mt");

            InvoiceReport report;

            //client.GetInvoiceReport(identifier, 961347587, LanguageCode.US, out report);
            client.GetInvoiceReport(identifier, 963313694, LanguageCode.US,  true, out report);

            Assert.IsNotNull(report.InvoiceHeader);

        }

        [Test]
        [Category("GetByProductReport")]
        public void GetByProductReport()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier identifier = new AccountIdentifier("mark", "mt");

            ReportLevel reportData;
            ReportParameters rp = new ReportParameters();
            DateRangeSlice dr = new DateRangeSlice();
            dr.Begin = new DateTime(2000, 01, 01);
            dr.End = new DateTime(2020, 12, 31);
            rp.DateRange = dr;
            
            
            client.GetByProductReport(identifier, rp, out reportData);

            Assert.IsNotNull(reportData);



        }

        [Test]
        [Category("GetByFolderReportLevel_OnlineBill")]
        public void GetByFolderReportLevel_OnlineBill()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier identifier = new AccountIdentifier("Kevin", "mt");
            //AccountIdentifier folder = new AccountIdentifier("Kevin", "mt");
            AccountIdentifier folder = null;

            ReportLevel reportData;
            ReportParameters rp = new ReportParameters();
            DateRangeSlice drs = new DateRangeSlice();
            drs.Begin = new DateTime(2000, 01, 01);
            drs.End = new DateTime(2020, 12, 31);
            rp.DateRange = drs;
            rp.ReportView = ReportViewType.OnlineBill;

            client.GetByFolderReportLevel(identifier, folder, rp, out reportData);

            Assert.IsNotNull(reportData);

        }


        [Test]
        [Category("GetByFolderReportLevelChildrenn_OnlineBill")]
        public void GetByFolderReportLevelChildren_OnlineBill()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier identifier = new AccountIdentifier("UI", "mt");
            AccountIdentifier folder = new AccountIdentifier("UI", "mt");

            MTList<ReportLevel> children = new MTList<ReportLevel>(); ;

            ReportParameters rp = new ReportParameters();
            DateRangeSlice drs = new DateRangeSlice();
            drs.Begin = new DateTime(2000, 01, 01);
            drs.End = new DateTime(2020, 12, 31);
            rp.DateRange = drs;
            rp.ReportView = ReportViewType.OnlineBill;

            //while (true)
            //{
                client.GetByFolderReportLevelChildren(identifier, folder, null, rp, ref children);
            //}

            Assert.IsNotNull(children);
            Assert.Greater(children.Items.Count, 0);


        }

        [Test]
        [Category("GetByFolderReportLevel_Interactive")]
        public void GetByFolderReportLevel_Interactive()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier identifier = new AccountIdentifier("Kevin", "mt");
            AccountIdentifier folder = new AccountIdentifier("Kevin", "mt");

            ReportLevel reportData;
            ReportParameters rp = new ReportParameters();
            DateRangeSlice drs = new DateRangeSlice();
            drs.Begin = new DateTime(2000, 01, 01);
            drs.End = new DateTime(2020, 12, 31);
            rp.DateRange = drs;
            rp.ReportView = ReportViewType.Interactive;

            client.GetByFolderReportLevel(identifier, folder, rp, out reportData);

            Assert.IsNotNull(reportData);

        }


        [Test]
        [Category("GetByFolderReportLevelChildrenn_Interactive")]
        public void GetByFolderReportLevelChildren_Interactive()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier identifier = new AccountIdentifier("UI", "mt");
            AccountIdentifier folder = new AccountIdentifier("UI", "mt");

            MTList<ReportLevel> children = new MTList<ReportLevel>(); ;

            ReportParameters rp = new ReportParameters();
            DateRangeSlice drs = new DateRangeSlice();
            drs.Begin = new DateTime(2000, 01, 01);
            drs.End = new DateTime(2020, 12, 31);
            rp.DateRange = drs;
            rp.ReportView = ReportViewType.Interactive;

            client.GetByFolderReportLevelChildren(identifier, folder, null, rp, ref children);

            Assert.IsNotNull(children);
            Assert.Greater(children.Items.Count, 0);


        }

        [Test]
        [Category("GetPaymentHistory")]
        public void GetPaymentHistory()
        {
            UsageHistoryServiceClient client = new UsageHistoryServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            MTList<Payment> list = new MTList<Payment>();
            list.PageSize = 10;
            list.CurrentPage = 1;
            AccountIdentifier identifier = new AccountIdentifier(123);
            //AccountIdentifier identifier = new AccountIdentifier(247880927);
            list.Filters.Add(new MTFilterElement("PaymentMethod", MTFilterElement.OperationType.Equal, "0"));
            list.SortCriteria.Add(new SortCriteria("ReasonCode", SortType.Descending));
            client.GetPaymentHistory(identifier, LanguageCode.US, ref list);

            Assert.Greater(list.Items.Count, 0);
            m_Logger.LogInfo("paymentmethod value " + list.Items[0].PaymentMethod.ToString());

        }

        [Test]
        [Category("GetPaymentInfo")]
        public void GetPaymentInfo()
        {
          UsageHistoryServiceClient client = new UsageHistoryServiceClient();
          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";

          PaymentInfo paymentInfo = new PaymentInfo();
          AccountIdentifier identifier = new AccountIdentifier(123);

          client.GetPaymentInfo(identifier, LanguageCode.US, ref paymentInfo);

          Assert.AreEqual(paymentInfo.LastPaymentDate, new DateTime(1900,1,1));

        }

    }
}

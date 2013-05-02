
using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
using MetraTech.Tax.Adapters;
using MetraTech.Test.Common;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.UsageServer;
using MetraTech.DataAccess;


namespace MetraTech.Tax.Framework.Test
{
    //
    // To run the this test fixture:
    // nunit-console /fixture:MetraTech.Tax.Framework.Test.FrameworkTests /assembly:O:\debug\bin\MetraTech.Tax.Framework.Test.dll
    //
    [TestClass]
    //[ComVisible(false)]
    public class FrameworkTests
    {
        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
        }

        [TestMethod]
        public void TestConstructors()
        {
            // The method below is implemented as a stub.  So this is a test of a stub.
            AsyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(0);

            DuplicatedContextException e1 = new DuplicatedContextException("Hello.");

            DuplicatedContextException e2 = new DuplicatedContextException("Hello.", new Exception("Hi."));

            InvalidConfigurationException e3 = new InvalidConfigurationException("Hello.");

            InvalidConfigurationException e4 = new InvalidConfigurationException("Hello.", new Exception("Hi."));

            InvalidTaxVendorParamException e5 = new InvalidTaxVendorParamException("Hello.");

            InvalidTaxVendorParamException e6 = new InvalidTaxVendorParamException("Hello.", new Exception("Hi."));

        }

        [TestMethod]
        public void TestTaxInputAdapter()
        {
            TaxInputAdapter adapter = new TaxInputAdapter();

            Interop.MTAuth.IMTSessionContext authContext = Utils.LoginAsSU();
            adapter.Initialize("TestingEvent", @"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml", authContext, true);

            MockContext context = new MockContext();
            context.UsageIntervalID = 1;
            context.BillingGroupID = 1;
            context.EventType = RecurringEventType.EndOfPeriod;

            adapter.Reverse(context);
            adapter.Execute(context);

            // The following functions have stub implementations
            adapter.SplitReverseState(0,0,0,0);
            adapter.Shutdown();
            bool result = adapter.SupportsScheduledEvents;
            result = adapter.SupportsEndOfPeriodEvents;
            ReverseMode mode = adapter.Reversibility;
            result = adapter.AllowMultipleInstances;
            BillingGroupSupportType suppot = adapter.BillingGroupSupport;
            result = adapter.HasBillingGroupConstraints;
            adapter.CreateBillingGroupConstraints(0, 0);
        }

        [TestMethod]
        public void TestTaxCalculateAdapter()
        {
            TaxCalculateAdapter adapter = new TaxCalculateAdapter();

            Interop.MTAuth.IMTSessionContext authContext = Utils.LoginAsSU();
            adapter.Initialize("TestingEvent", @"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml", authContext, true);

            // The following functions have stub implementations
            adapter.SplitReverseState(0, 0, 0, 0);
            adapter.Shutdown();
            bool result = adapter.SupportsScheduledEvents;
            result = adapter.SupportsEndOfPeriodEvents;
            ReverseMode mode = adapter.Reversibility;
            result = adapter.AllowMultipleInstances;
            BillingGroupSupportType suppot = adapter.BillingGroupSupport;
            result = adapter.HasBillingGroupConstraints;
            adapter.CreateBillingGroupConstraints(0, 0);
            // End of stub implementations

            MockContext context = new MockContext();
            context.UsageIntervalID = 1;
            context.BillingGroupID = 1;
            context.EventType = RecurringEventType.EndOfPeriod;

            adapter.Reverse(context);
            adapter.Execute(context);

        }

        [TestMethod]
        public void TestTaxOutputAdapter()
        {
            TaxOutputAdapter adapter = new TaxOutputAdapter();

            Interop.MTAuth.IMTSessionContext authContext = Utils.LoginAsSU();
            adapter.Initialize("TestingEvent", @"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml", authContext, true);

            // The following functions have stub implementations
            adapter.SplitReverseState(0, 0, 0, 0);
            adapter.Shutdown();
            bool result = adapter.SupportsScheduledEvents;
            result = adapter.SupportsEndOfPeriodEvents;
            ReverseMode mode = adapter.Reversibility;
            result = adapter.AllowMultipleInstances;
            BillingGroupSupportType suppot = adapter.BillingGroupSupport;
            result = adapter.HasBillingGroupConstraints;
            adapter.CreateBillingGroupConstraints(0, 0);
            // End of stub implementations

            MockContext context = new MockContext();
            context.UsageIntervalID = 1;
            context.BillingGroupID = 1;
            context.EventType = RecurringEventType.EndOfPeriod;

            adapter.Reverse(context);
            adapter.Execute(context);
        }


        [TestMethod]
        public void TestTaxScheduledAdapter()
        {
            TaxScheduledAdapter adapter = new TaxScheduledAdapter();

            Interop.MTAuth.IMTSessionContext authContext = Utils.LoginAsSU();
            adapter.Initialize("TestingEvent", @"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml", authContext, true);

            // The following functions have stub implementations
            adapter.Shutdown();
            bool result = adapter.SupportsScheduledEvents;
            result = adapter.SupportsEndOfPeriodEvents;
            ReverseMode mode = adapter.Reversibility;
            result = adapter.AllowMultipleInstances;
            result = adapter.HasBillingGroupConstraints;
            // End of stub implementations

            MockContext context = new MockContext();
            context.UsageIntervalID = 1;
            context.BillingGroupID = 1;
            context.EventType = RecurringEventType.EndOfPeriod;

            adapter.Reverse(context);
            adapter.Execute(context);

        }

    }
}

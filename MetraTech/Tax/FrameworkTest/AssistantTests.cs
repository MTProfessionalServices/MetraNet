using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
//using System.ServiceProcess;
//using System.Runtime.InteropServices;
using MetraTech.Tax.Adapters;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MetraTech.UsageServer;
//using MetraTech;
//using MetraTech.Xml;
using MetraTech.DataAccess;
//using MetraTech.Test;
//using MetraTech.Pipeline;
//using Auth = MetraTech.Interop.MTAuth;
//using MetraTech.Interop.COMMeter;
//using MetraTech.Interop.PipelineTransaction;

namespace MetraTech.Tax.Framework.Test
{
    //
    // To run the this test fixture:
    // nunit-console /fixture:MetraTech.Tax.Framework.Test.AssistantTests /assembly:O:\debug\bin\MetraTech.Tax.Framework.Test.dll
    //
    [TestClass]
    //[ComVisible(false)]
    public class AssistantTests
    {

        const string mTestDir = "t:\\Development\\Core\\Tax\\";

        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            Console.WriteLine("deleting tax runs so test can rerun without sideffects");
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateAdapterStatement("delete from t_tax_run"))
                {
                    //stmt.AddParam("%%ID_INTERVAL%%", UsageIntervalId);
                    stmt.ExecuteNonQuery();
                }
            }
        }
        
        /// <summary>
        /// Test negative condition - no config file
        /// </summary>
        [TestMethod]
        public void TestConfigFileNotSpecified()
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            try
            {
                assistant.ReadConfigFile(@"");
            }
            catch (InvalidConfigurationException)
            {
                return;
            }
            //Assert.AreEqual(false, minutely.IsOverride, "Should not be override now");
        }

        /// <summary>
        /// Test MetraTax config file
        /// </summary>
        [TestMethod]
        public void TestMetraTaxAssistant()
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(@"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml");
            Assert.AreEqual(MetraTech.DomainModel.Enums.Tax.Metratech_com_tax.TaxVendor.MetraTax, assistant.vendor);
            Assert.AreEqual(false, assistant.TaxDetailsNeeded);

            RecurringEventRunContext context = new RecurringEventRunContext();
            context.UsageIntervalID = 1;
            context.BillingGroupID = 1;
            context.EventType = RecurringEventType.EndOfPeriod;

            assistant.SetAdapterContext(context);
            assistant.GenerateTaxRunForContext();
            assistant.CreateTaxInputTable();
            assistant.PopulateTaxInputTableWithCharges();
            assistant.CreateTaxInputIndexes();
        }

        [TestMethod]
        public void TestTaxRunPersistenceEOP()
        {
            RecurringEventRunContext context = new RecurringEventRunContext();
            context.UsageIntervalID = 200;
            context.BillingGroupID = 100;
            context.EventType = RecurringEventType.EndOfPeriod;
            int taxRunId = GenerateTaxRun(context);
            Assert.AreNotEqual(-1, taxRunId, "some id must be generated");
            int taxRunId2 = LoadTaxRun(context);
            Assert.AreEqual(taxRunId, taxRunId2, "eop context not picked up");

            try
            {
                GenerateTaxRun(context);//should get an error here as tax run already have been generated

            }
            catch (DuplicatedContextException)
            {
                return;
            }
        }

        //[TestMethod]
        [ExpectedException(typeof(DuplicatedContextException))]
        public void TestTaxRunPersistenceScheduled()
        {
            RecurringEventRunContext context = new RecurringEventRunContext();
            context.StartDate = DateTime.Now.AddDays(-10);
            context.EndDate = DateTime.Now.AddDays(-5);
            context.EventType = RecurringEventType.Scheduled;
            int taxRunId = GenerateTaxRun(context);
            Assert.AreNotEqual(-1, taxRunId, "some id must be generated");
            int taxRunId2 = LoadTaxRun(context);
            Assert.AreEqual(taxRunId, taxRunId2, "scheduled context not picked up");
            GenerateTaxRun(context);//should get an error here as tax run already have been generated
        }

        private int GenerateTaxRun(RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(@"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml");

            assistant.SetAdapterContext(context);

            if (assistant.LoadTaxRunIdForContext() == -1)
                assistant.GenerateTaxRunForContext();//generate tax run id
            return assistant.TaxRunId;
        }

        private int LoadTaxRun(RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(@"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml");

            assistant.SetAdapterContext(context);
            assistant.LoadTaxRunForContext();//generate tax run id
            return assistant.TaxRunId;
        }

        private void DeleteTaxRun(RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(@"R:\extensions\MetraTax\config\UsageServer\MetraTaxAdapter.xml");

            assistant.SetAdapterContext(context);
            assistant.DeleteTaxRunForContext();
        }

        [TestMethod]
        public void TestTaxRunDeleteEOP()
        {
            RecurringEventRunContext context = new RecurringEventRunContext();
            context.UsageIntervalID = 200;
            context.BillingGroupID = 101;
            context.EventType = RecurringEventType.EndOfPeriod;
            int taxRun1 = GenerateTaxRun(context);
            DeleteTaxRun(context);
            int taxRun2 = GenerateTaxRun(context);
            Assert.AreNotEqual(taxRun1, taxRun2, "Different tax run id must be generated once deleting original tax run");
        }

        [TestMethod]
        public void TestTaxRunDeleteScheduled()
        {
            RecurringEventRunContext context = new RecurringEventRunContext();
            context.StartDate = DateTime.Now.AddDays(-10);
            context.EndDate = DateTime.Now.AddDays(-6);
            context.EventType = RecurringEventType.Scheduled;
            int taxRun1 = GenerateTaxRun(context);
            DeleteTaxRun(context);
            int taxRun2 = GenerateTaxRun(context);
            Assert.AreNotEqual(taxRun1, taxRun2, "Different tax run id must be generated once deleting original tax run");
        }

        //[TestMethod]
        public void TestMetraTax()
        {
            TestConfiguration("MetraTaxAdapter.xml");
        }

        //[TestMethod]
        public void TestBillSoft()
        {
            TestConfiguration("BillSoftAdapter.xml");
        }

        //[TestMethod]
        public void TestTaxWare()
        {
            TestConfiguration("TaxWareAdapter.xml");
        }


        private int mBillingGroup = 1;

        private void TestConfiguration(string configFileName)
        {
            RecurringEventRunContext context = new RecurringEventRunContext();
            context.UsageIntervalID = 1009188897;
            context.BillingGroupID = mBillingGroup++; //want unique billing groups
            context.EventType = RecurringEventType.EndOfPeriod;

            InputAdapterExecute(configFileName, context);
            CalculateAdapterExecute(configFileName, context);
            OutputAdapterExecute(configFileName, context);
        }

        private void InputAdapterExecute(string configFileName, RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(mTestDir + configFileName);

            assistant.SetAdapterContext(context);
            assistant.GenerateTaxRunForContext();
            assistant.CreateTaxInputTable();
            assistant.PopulateTaxInputTableWithCharges();
            assistant.CreateTaxInputIndexes();
        }

        private void InputAdapterReverse(string configFileName, RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(mTestDir + configFileName);

            assistant.SetAdapterContext(context);
            assistant.LoadTaxRunForContext();
            assistant.DropInputTable();
            assistant.DeleteTaxRunForContext();
        }

        private void CalculateAdapterExecute(string configFileName, RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(mTestDir + configFileName);

            assistant.SetAdapterContext(context);
            assistant.LoadTaxRunForContext();
            assistant.CalculateTaxes();

        }

        private void CalculateAdapterReverse(string configFileName, RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(mTestDir + configFileName);

            assistant.SetAdapterContext(context);
            assistant.LoadTaxRunForContext();
            assistant.ReverseTaxRun();
        }

        private void OutputAdapterExecute(string configFileName, RecurringEventRunContext context)
        {
            TaxAdapterAssistant assistant = new TaxAdapterAssistant();
            assistant.ReadConfigFile(mTestDir + configFileName);

            assistant.SetAdapterContext(context);
            assistant.LoadTaxRunForContext();
            assistant.FetchTaxResultsFromTaxOutputTable();
        }

    }
}

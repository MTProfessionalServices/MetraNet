using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
//using System.ServiceProcess;
//using System.Runtime.InteropServices;
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
    // nunit-console /fixture:MetraTech.Tax.Framework.Test.VendorParamsManagerTests /assembly:O:\debug\bin\MetraTech.Tax.Framework.Test.dll
    //
    [TestClass]
    //[ComVisible(false)]
    public class VendorParamsManagerTests
    {

        const string mTestDir = "t:\\Development\\Core\\Tax\\";

        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
        }

        [ClassCleanup]
        public static void TearDown()
        {
			MetraTech.Tax.Framework.Test.VendorParamsManagerTests vp
				= new VendorParamsManagerTests();
            // restore the real values
            vp.TestCallHookDirectly();
        }

        /// <summary>
        /// Test negative condition - no config file
        /// </summary>
        [TestMethod]
        public void TestConfigFileNotSpecified()
        {
            try
            {
                VendorParamsManager manager = new VendorParamsManager();
                manager.SynchronizeConfigFile(@"");
            }
            catch (FileNotFoundException)
            {

                return;
            }

            // We shouldn't reach this point.
            Exception e = new Exception("TestConfigFileNotSpecified failed.");
            throw e;
        }


        /// <summary>
        /// TEST Duplicated field
        /// </summary>
        [TestMethod]
        public void TestDuplicatedParam()
        {
            try
            {
                TestSynchConfiguration("vendor_params_duplicated_param.xml");
            }
            catch (InvalidConfigurationException)
            {

                return;
            }

            // We shouldn't reach this point.
            Exception e = new Exception("TestDuplicatedParam failed.");
            throw e;
        }

        /// <summary>
        /// TEST Duplicated field
        /// </summary>
        [TestMethod]
        public void TestDuplicatedVendor()
        {
            try
            {
                TestSynchConfiguration("vendor_params_duplicated_vendor.xml");
            }
            catch (InvalidConfigurationException)
            {
                return;
            }

            // We shouldn't reach this point.
            Exception e = new Exception("TestDuplicatedParam failed.");
            throw e;
        }


        [TestMethod]
        public void TestInvalidVendor()
        {
            try
            {
                TestSynchConfiguration("vendor_params_invalid_vendor.xml");
            }
            catch (InvalidConfigurationException)
            {
                return;
            }

            // We shouldn't reach this point.
            Exception e = new Exception("TestDuplicatedParam failed.");
            throw e;
        }

        [TestMethod]
        public void TestAllTypes()
        {
            TestSynchConfiguration("vendor_params_all_types.xml");
        }

        [TestMethod]
        public void TestInvalidTypes()
        {
            try
            {
                TestSynchConfiguration("vendor_params_invalid_types.xml");
            }
            catch (InvalidConfigurationException)
            {
                return;
            }

            // We shouldn't reach this point.
            Exception e = new Exception("TestDuplicatedParam failed.");
            throw e;
        }

        [TestMethod]
        public void TestInvalidDefault()
        {
            try
            {
                TestSynchConfiguration("vendor_params_invalid_default.xml");
            }
            catch (InvalidConfigurationException)
            {
                return;
            }

            // We shouldn't reach this point.
            Exception e = new Exception("TestDuplicatedParam failed.");
            throw e;
        }

        [TestMethod]
        public void TestCallHookDirectly()
        {
            Hooks.VendorParamsHook hook = new Hooks.VendorParamsHook();
            int pval = 0;
            hook.Execute(null, ref pval);
        }

        private void TestSynchConfiguration(string configFileName)
        {
            VendorParamsManager manager = new VendorParamsManager();
            manager.SynchronizeConfigFile(mTestDir + configFileName);
        }

        private void TestReadConfiguration(string configFileName)
        {
            VendorParamsManager manager = new VendorParamsManager();
            manager.ReadVendorParamsFromFile(mTestDir + configFileName);
        }

    }
}

using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.SecurityFramework;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Summary description for SubsystemPropertiesTest
    /// </summary>
    [TestClass]
    public class SubsystemPropertiesTest
    {
        public SubsystemPropertiesTest()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void SecurityKernelInitialize(TestContext testContext)
        //{
            
        //}

        // Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void SecurityKernelClassCleanup()
        {
            UnitTestUtility.CleanupFrameworkConfiguration();
        }

        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void SecurityKernelAllTetsInitialize()
        {
            UnitTestUtility.CleanupFrameworkConfiguration();
            UnitTestUtility.InitFrameworkConfiguration(TestContext, "MtSfConfigurationLoaderNoApi.xml");
            Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
        }

        // Use TestCleanup to run code after each test has run
        [TestCleanup()]
        public void MyTestCleanup()
        {
            UnitTestUtility.CleanupFrameworkConfiguration();
            UnitTestUtility.InitFrameworkConfiguration(TestContext);
        }
        
        #endregion

        #region IsRuntimeApiPublic tests

        /// <summary>
        /// Test for the IsRuntimeApiPublic property = true
        /// </summary>
        [TestMethod]
        public void IsRuntimeApiPublicTest_Positive()
        {
            ISubsystemApi actual = SecurityKernel.Decoder.Api;
            Assert.IsNotNull(actual, "Object reference expected but null found.");
        }

        /// <summary>
        /// Test for the IsRuntimeApiPublic property = false
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(SubsystemApiAccessException))]
        public void IsRuntimeApiPublicTest_Negative()
        {
            ISubsystemApi actual = SecurityKernel.Detector.Api;
        }

        #endregion

        #region IsControlApiPublic tests

        /// <summary>
        /// Test for the IsControlApiPublic property = true
        /// </summary>
        [TestMethod]
        public void IsControlApiPublic_Positive()
        {
            ISubsystemControlApi actual = SecurityKernel.Decoder.ControlApi;
            Assert.IsNotNull(actual, "Object reference expected but null found.");
        }

        /// <summary>
        /// Test for the IsControlApiPublic property = true
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(SubsystemApiAccessException))]
        public void IsControlApiPublic_Negative()
        {
            ISubsystemControlApi actual = SecurityKernel.Detector.ControlApi;
        }

        #endregion
    }
}

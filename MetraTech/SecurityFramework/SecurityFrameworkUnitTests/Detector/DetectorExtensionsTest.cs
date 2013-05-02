using System;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Detector;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests.Detector
{
    
    
    /// <summary>
    ///This is a test class for DetectorExtensionsTest and is intended
    ///to contain all DetectorExtensionsTest Unit Tests
    ///</summary>
    [TestClass()]
    public class DetectorExtensionsTest
    {


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
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void SecurityKernelInitialize(TestContext testContext)
        {
            UnitTestUtility.InitFrameworkConfiguration(testContext);
        }

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
            Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
        }
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        #region DetectSql tests

        /// <summary>
        ///A test for DetectSql with SQL in input.
        ///</summary>
        [TestMethod()]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectSqlTest_Positive()
        {
            string str = "select 1 from dual";
            DetectorExtensions.DetectSql(str);
        }

        /// <summary>
        ///A test for DetectSql with no SQL in input.
        ///</summary>
        [TestMethod()]
        public void DetectSqlTest_Negative()
        {
            string str = "Some neitral text.";
            DetectorExtensions.DetectSql(str);
        }

        #endregion

        #region DetectXss tests

        /// <summary>
        ///A test for DetectXss with JavaScript in input.
        ///</summary>
        [TestMethod()]
        [ExpectedException(typeof(DetectorInputDataException))]
        public void DetectXssTest_Positive()
        {
            string str = "<script></script>";
            DetectorExtensions.DetectXss(str);
        }

        /// <summary>
        ///A test for DetectXss with no JavaScript in input.
        ///</summary>
        [TestMethod()]
        public void DetectXssTest_Negative()
        {
            string str = "Some neitral text.";
            DetectorExtensions.DetectXss(str);
        }

        #endregion
    }
}

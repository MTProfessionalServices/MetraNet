using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests.Sanitizer
{
    [TestClass]
    public class SanitizerExtensionsTest
    {
        #region Initialization tests

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

        #endregion

        [TestMethod]
        public void SanitizeNullCharactersTest()
        {
            string str = "\\123\\0\012";
            string expected = "\\123\\012";

            string actual = SanitizerExtensions.SanitizeNullCharacters(str);
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }
    }
}

using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Test for Encoder
    /// </summary>
    [TestClass]
    public class EncoderTest
    {
        public EncoderTest()
        {
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
        //
        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void SecurityKernelAllTetsInitialize()
        {
            Assert.IsTrue(SecurityKernel.IsInitialized(), "SecurityKernel is not Initialized.");
        }
        //
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        public void VbScriptTest()
        {
            string testInputParam = "<script>alert('hi')</script>";
            
            ApiOutput output = SecurityKernel.Encoder.Api.Execute(EncoderEngineCategory.VbScript + ".Default", testInputParam);
            Assert.IsFalse(String.IsNullOrEmpty(output.ToString()));
        }

        public void HtmEncoderCompareHtmlAttributeEncoderTest(string inputHtmTxt)
        {
            string resultHtmlAttributeEncoder = SecurityKernel.Encoder.Api.Execute(EncoderEngineCategory.HtmlAttribute + ".Default", inputHtmTxt);
            string resultHtmEncoder = SecurityKernel.Encoder.Api.Execute(EncoderEngineCategory.Html + ".Default", inputHtmTxt);

            Console.WriteLine(String.Format("Result of HTML atribute encode    : '{0}'", resultHtmlAttributeEncoder));
            Console.WriteLine(String.Format("Result of HTML               encode    : '{0}'", resultHtmEncoder));
            Console.WriteLine();
        }

        [TestMethod]
        public void HtmEncoderCompareHtmlAttributeEncoderTest()
        {
            HtmEncoderCompareHtmlAttributeEncoderTest("<a href=\"http://www.w3schools.com\">Visit W3Schools.com!</a>");
            HtmEncoderCompareHtmlAttributeEncoderTest("<a href=\"http://www.w3schools.com\">Привет!</a>");

            HtmEncoderCompareHtmlAttributeEncoderTest("<a href=\"http://www.w3schools.com\" tst=\" что-то test. ; @ &^ \'\"\">Привет!</a>");
        }
    }
}

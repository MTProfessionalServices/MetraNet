using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests.Decoder
{
    [TestClass]
    public class JavaScriptDecoderTest
    {
        #region Initialization tests
        public JavaScriptDecoderTest()
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

        #endregion Initialization tests

        #region Is not null and not empty? 

		/// <summary>
		/// Test for the JavaScript decoder with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void JavaScriptTest_NullInput()
		{
			string input = null;
			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
		}

		/// <summary>
		/// Test for the JavaScript decoder with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void JavaScriptTest_EmptyInput()
		{
			string input = string.Empty;
			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
		}

        #endregion Is not null and not empty?

		[TestMethod]
        public void JavaScriptTest()
        {
            string expectedStr = "Test-%, ,~,!,@,#,$,^,&,*,(,),{,},[,],=,:,/,,,;,?,+,',\\,\"end22";
            string actualStr = Microsoft.Security.Application.Encoder.JavaScriptEncode(expectedStr);
            // removed the single quotes in the begin and in the end of string
            actualStr = actualStr.Substring(1, actualStr.Length - 2);
           
            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        public void JavaScriptTest2()
        {
            string expectedStr = "+XSS привет/. <script+ >";
            string actualStr = "+XSS\\x20\\u043F\\u0440\\u0438\\u0432\\u0435\\u0442/.\\x20\\x3Cscript+\\x20\\x3E";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        public void JavaScriptTest3()
        {
            string expectedStr = "+XSS привет/. <script+ >";
            string actualStr = "+XSS\\x20\\u043F\\u0440\\u0438\\u0432\\u0435\\u0442/.\\x20\\x3Cscript+\\x20\\x3E";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        #region For Unicode tests

        [TestMethod]
        public void JavaScriptTest4()
        {
            // Unicode code \uF900
            string expectedStr = "豈";
            string actualStr = "\\uF900";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        public void JavaScriptTest5()
        {
            // Unicode code \u20010
            string expectedStr = "𠀐";
            string actualStr = "\\u20010";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        public void JavaScriptTest6()
        {
            string expectedStr = "<script>alert(\" Привет! +\");";
            string actualStr = "\\x3Cscript\\x3Ealert\\x28\\x22\\x20\\u041F\\u0440\\u0438\\u0432\\u0435\\u0442\\x21\\x20\\x2B\\x22\\x29\\x3B";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        #endregion For Unicode tests
    }
}

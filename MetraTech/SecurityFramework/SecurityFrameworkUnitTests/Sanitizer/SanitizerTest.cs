using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{
    [TestClass]
    public class SanitizerTest
    {
        #region Initialization tests

        public SanitizerTest()
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
		
		#endregion

		#endregion Initialization tests

        /// <summary>
        /// Test for the Sanitizer with null input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void NullCharacterSanitizerTest_NullInput()
        {
            string input = null;
            SecurityKernel.Sanitizer.Api.Execute(SanitizerEngineCategory.NullCharacterSanitizer + ".V1", input);
        }

        /// <summary>
        /// Test for the NullCharacterSanitizer.
        /// </summary>
        [TestMethod]
        public void NullCharacterSanitizerTest_Positive1()
        {
            string input = "01\\2\03";
            string expected = "01\\23";
            string actual = SecurityKernel.Sanitizer.Api.Execute(SanitizerEngineCategory.NullCharacterSanitizer + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for the NullCharacterSanitizer.
        /// </summary>
        [TestMethod]
        public void NullCharacterSanitizerTest_Positive2()
        {
            string input = "\\01\02";
            string expected = "\\012";
            string actual = SecurityKernel.Sanitizer.Api.Execute(SanitizerEngineCategory.NullCharacterSanitizer + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for the NullCharacterSanitizer.
        /// </summary>
        [TestMethod]
        public void NullCharacterSanitizerTest_Negative()
        {
            string input = "\\012\\0";
            string expected = "\\012\\0";
            string actual = SecurityKernel.Sanitizer.Api.Execute(SanitizerEngineCategory.NullCharacterSanitizer + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        ///  Pyton test id: 78: real attacks with base64 coding is not detected
        /// </summary>
        /// <remarks>Bug-182</remarks>
        [TestMethod]
        public void SanitizerBase64Test()
        {
            string inputStr = "data:text/html;base64,PHNjcmlwdD5hbGVydChkb2N1bWVudC5jb29raWUpPC9zY3JpcHQ+";
            string expected = "data:text/html<script>alert(document.cookie)</script>";
            string actual = SecurityKernel.Sanitizer.Api.Execute(SanitizerEngineCategory.Base64Sanitizer + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        ///  Pyton test id: 78: real attacks with base64 coding is not detected
        /// </summary>
        /// <remarks>Bug-182</remarks>
        [TestMethod]
        public void SanitizerBase64Test2()
        {
            string inputStr = "data:text/html;base64,PHNjcmlwdD5hbGVydChkb2N1bWVudC5jb29raWUpPC9zY3JpcHQ+ data:text/html;base64,PHNjcmlwdD5hbGVydChkb2N1bWVudC5jb29raWUpPC9zY3JpcHQ+";
            string expected = "data:text/html<script>alert(document.cookie)</script> data:text/html<script>alert(document.cookie)</script>";
            string actual = SecurityKernel.Sanitizer.Api.Execute(SanitizerEngineCategory.Base64Sanitizer + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }
    }
}

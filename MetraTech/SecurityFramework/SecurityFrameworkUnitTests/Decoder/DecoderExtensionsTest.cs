using System;
using System.Text;
using MetraTech.SecurityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    ///This is a test class for DecoderExtensionsTest and is intended
    ///to contain all DecoderExtensionsTest Unit Tests
    ///</summary>
    [TestClass()]
    public class DecoderExtensionsTest
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

		#region Decode tests

		/// <summary>
		/// Test for Decome with encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeTest_Positive()
		{
			string input = "&lt;br/&gt;";
			string expected = "<br/>";

			string actual = input.DecodeWithEngine(DecoderEngineCategory.Html + ".V1");
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// Test for Decome with invalid engine ID.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(SubsystemInputParamException))]
		public void DecodeTest_InvalidEngineId()
		{
			string input = "&lt;br/&gt;";
			
			input.DecodeWithEngine(DecoderEngineCategory.Html + Guid.NewGuid().ToString());
		}

		#endregion

		#region DecodeFromUrl tests

		/// <summary>
        ///A test for DecodeFromUrl with encoded input.
        ///</summary>
        [TestMethod()]
        public void DecodeFromUrlTest_Positive()
        {
            string input = "%20str%20";
            string expected = " str ";

			string actual = input.DecodeFromUrl();
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for DecodeFromUrl with non-encoded input.
        ///</summary>
        [TestMethod()]
        public void DecodeFromUrlTest_Negative()
        {
			string input = "YYYstrMMM";
			string expected = input;

			string actual = input.DecodeFromUrl();
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region DecodeFromHtml tests

        /// <summary>
        ///A test for DecodeFromHtml with encoded input.
        ///</summary>
        [TestMethod()]
        public void DecodeFromHtmlTest_Positive()
        {
            string input = "&lt;br/&gt;";
            string expected = "<br/>";

			string actual = input.DecodeFromHtml();
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for DecodeFromHtml with non-encoded input.
        ///</summary>
        [TestMethod()]
        public void DecodeFromHtmlTest_Negative()
        {
			string input = "<br/>";
			string expected = input;

			string actual = input.DecodeFromHtml();
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

		#region DecodeFromHtmlAttribute tests

		/// <summary>
		/// A test for DecodeFromHtmlAttribute with encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromHtmlAttributeTest_Positive()
		{
			string input = "&lt;hr size=&#34;2&#34/&gt;";
			string expected = "<hr size=\"2\"/>";

			string actual = input.DecodeFromHtmlAttribute();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// A test for DecodeFromHtmlAttribute with non-encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromHtmlAttributeTest_Negative()
		{
			string input = "<hr size=\"2\"/>";
			string expected = input;

			string actual = input.DecodeFromHtmlAttribute();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		#endregion

        #region DecodeFromJavaScript tests

        /// <summary>
        /// A test for DecodeFromJavaScript with encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromJavaScriptTest_Positive()
		{
            string str = "\\x3Cscript\\x3Ealert\\x28\\x22\\x20\\u041F\\u0440\\u0438\\u0432\\u0435\\u0442\\x21\\x20\\x2B\\x22\\x29\\x3B";
			string expected = "<script>alert(\" Привет! +\");";

			string actual = DecoderExtensions.DecodeFromJavaScript(str);
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
        /// A test for DecodeFromJavaScript with encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromJavaScriptTest_Negative()
		{
			string str = "script t = a";
			string expected = str;

            string actual = DecoderExtensions.DecodeFromJavaScript(str);
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		#endregion

        #region DecodeFromVBScript tests

        /// <summary>
        /// A test for DecodeFromVbScript with encoded input.
        /// </summary>
        [TestMethod]
        public void DecodeFromVbScriptTest_Positive()
        {
            string str = "alert\"&chrw(40)&chrw(39)&\"XSS атака\"&chrw(33)&chrw(39)&chrw(41)&chrw(59)&\" .,-_";
            string expected = "alert('XSS атака!'); .,-_";

            string actual = DecoderExtensions.DecodeFromVbScript(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        /// A test for DecodeFromVbScript with encoded input.
        /// </summary>
        [TestMethod]
        public void DecodeFromVbScriptTest_Negative()
        {
            string str = "script t = a";
            string expected = str;

            string actual = DecoderExtensions.DecodeFromVbScript(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

		#region DecodeFromXml tests

		/// <summary>
		/// A test for DecodeFromXml with encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromXmlTest_Positive()
		{
			string input = "&lt;hr size=&#34;2&#x22;/&gt;";
			string expected = "<hr size=\"2\"/>";

			string actual = input.DecodeFromXml();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// A test for DecodeFromXml with encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromXmlTest_Negative()
		{
			string input = "<hr size=\"2\"/>&Sigma;";
			string expected = input;

			string actual = input.DecodeFromXml();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		#endregion

		#region DecodeFromXmlAttribute tests

		/// <summary>
		/// A test fro DecodeFromXmlAttribute with encoded data.
		/// </summary>
		[TestMethod]
		public void DecodeFromXmlAttributeTest_Positive()
		{
			string input = "&lt;hr size=&#34;2&#x22;/&gt;";
			string expected = "<hr size=\"2\"/>";

			string actual = input.DecodeFromXmlAttribute();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		/// <summary>
		/// A test for DecodeFromXmlAttribute with non-encoded data.
		/// </summary>
		[TestMethod]
		public void DecodeFromXmlAttributeTest_Negative()
		{
			string input = "<hr size=\"2\"/>&Sigma;";
			string expected = input;

			string actual = input.DecodeFromXmlAttribute();
			Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
		}

		#endregion

		#region DecodeFromCss tests

		/// <summary>
		/// Test for the CSS decoder with non-encoded input.
		/// </summary>
		[TestMethod]
		public void DecodeFromCssTest_PositiveNonEncoded()
		{
			string expected = "\abcdfghijklmnopqrstuvwxyz ABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_";
			string input = expected;

			string actual = input.DecodeFromCss();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CSS decoder with encoded input.
		/// </summary>
		[TestMethod]
		public void CssDecoderTest_PositiveEncoded()
		{
			string input = @"\9 \3c span\20 style\03d \0022 font\0002d family\00003a\20 LU beck\22 \3e \2e \2e \2e \3c \2f span\00003e1";
			string expected = "\t<span style=\"font-family: LU beck\">...</span>1";

			string actual = input.DecodeFromCss();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		#endregion

		#region DecodeFromGZip tests

		/// <summary>
		/// A test for DecodeFromGZip with proper data.
		/// </summary>
		[TestMethod]
		public void DecodeFromGZipTest_Positive()
		{
			byte[] expected = Encoding.UTF8.GetBytes(UnitTestUtility.DecompressedText);
			byte[] actual;

			actual = UnitTestUtility.CompressedText.DecodeFromGZip();
			CollectionAssert.AreEqual(expected, actual);
		}

		/// <summary>
		/// A test for DecodeFromGZip with incorrectly encoded string.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(DecoderInputDataException))]
		public void DecodeFromGZipTest_Negative()
		{
			UnitTestUtility.CompressedText.Substring(1).DecodeFromGZip();
		}

		#endregion

		#region DecodeFromLdap tests

		/// <summary>
		/// Test for DecodeFromLdap with encoded value.
		/// </summary>
		[TestMethod]
		public void DecodeFromLdapTest_Positive()
		{
			string input = "abcd\\2A\\28\\29\\2F\\5c111";
			string expected = "abcd*()/\\111";
			string actual;

			actual = input.DecodeFromLdap();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DecodeFromLdap with encoded value - SECFRM-207.
		/// </summary>
		[TestMethod]
		public void DecodeFromLdapTest_Positive2()
		{
			string input = "\\d0\\a1\\D1\\85\\D0\\B5\\d0\\bc\\d0\\b0";
			string expected = "Схема";
			string actual;

			actual = input.DecodeFromLdap();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for DecodeFromLdap with non-encoded value.
		/// </summary>
		[TestMethod]
		public void DecodeFromLdapTest_Negative()
		{
			string input = "abcd\\aA\\\\k29\\2kF\\85c111";
			string expected = input;
			string actual;

			actual = input.DecodeFromLdap();
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		#endregion
	}
}

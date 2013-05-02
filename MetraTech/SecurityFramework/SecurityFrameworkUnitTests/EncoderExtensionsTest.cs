using MetraTech.SecurityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace MetraTech.SecurityFrameworkUnitTests
{
    
    
    /// <summary>
    ///This is a test class for EncoderExtensionsTest and is intended
    ///to contain all EncoderExtensionsTest Unit Tests
    ///</summary>
    [TestClass()]
    public class EncoderExtensionsTest
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

        #region EncodeForUrl tests

        /// <summary>
        ///A test for EncodeForUrl with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForUrlTest_Positive()
        {
            string str = "<br/>";
            string expected = "%3cbr%2f%3e";

            string actual = EncoderExtensions.EncodeForUrl(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for EncodeForUrl with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForUrlTest_Negative()
        {
            string str = "111br222";
            string expected = str;

            string actual = EncoderExtensions.EncodeForUrl(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForCss tests

        /// <summary>
        ///A test for EncodeForCss with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForCssTest_Positive()
        {
            string str = "<script>";
			      string expected = "\\00003Cscript\\00003E";

            string actual = EncoderExtensions.EncodeForCss(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for EncodeForCss with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForCssTest_Negative()
        {
            string str = "111scriptDDD";
            string expected = str;

            string actual = EncoderExtensions.EncodeForCss(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForHtml tests

        /// <summary>
        ///A test for EncodeForHtml with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForHtmlTest_Positive()
        {
            string str = "<script>";
            // Expected from old microsoft library
			string expected = "&#60;script&#62;";
            // Expected from new microsoft library
            string expected2 = "&lt;script&gt;";

            string actual = str.EncodeForHtml();
			// Check that results are correct for old and new microsoft library
            Assert.IsFalse(!actual.Equals(expected,StringComparison.InvariantCultureIgnoreCase) && !actual.Equals(expected2,StringComparison.InvariantCultureIgnoreCase),"\"{0}\" or \"{2}\" expected but \"{1}\" found.", expected, actual, expected2);
        }

        /// <summary>
        ///A test for EncodeForHtml with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForHtmlTest_Negative()
        {
            string str = "111scriptDDD";
            string expected = str;

            string actual = EncoderExtensions.EncodeForHtml(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForHtmlAttribute tests

        /// <summary>
        ///A test for EncodeForHtmlAttribute with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForHtmlAttributeTest_Positive()
        {
            string str = "<br/>";
            // Expected from old microsoft library
			string expected = "&#60;br&#47;&#62;";
			// Expected from new microsoft library
            string expected2 = "&lt;br/&gt;";

            string actual = str.EncodeForHtmlAttribute();
			// Check that results are correct for old and new microsoft library
            Assert.IsFalse(!actual.Equals(expected, StringComparison.InvariantCultureIgnoreCase) && !actual.Equals(expected2, StringComparison.InvariantCultureIgnoreCase), "\"{0}\" or \"{2}\" expected but \"{1}\" found.", expected, actual, expected2);
        }

        /// <summary>
        ///A test for EncodeForHtmlAttribute with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForHtmlAttributeTest_Negative()
        {
            string str = "111brDDD";
            string expected = str;

            string actual = EncoderExtensions.EncodeForHtmlAttribute(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForJavaScript tests

        /// <summary>
        ///A test for EncodeForJavaScript with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForJavaScriptTest_Positive()
        {
            string str = "<script>";
            string expected = "\\x3cscript\\x3e";

            string actual = EncoderExtensions.EncodeForJavaScript(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for EncodeForJavaScript with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForJavaScriptTest_Negative()
        {
            string str = "--";
            string expected = "--";

            string actual = EncoderExtensions.EncodeForJavaScript(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForLdap tests

        /// <summary>
        ///A test for EncodeForLdap with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForLdapTest_Positive()
        {
            string str = "<script>";
            string expected = "<script>";

            string actual = EncoderExtensions.EncodeForLdap(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for EncodeForLdap with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForLdapTest_Negative()
        {
            string str = "--";
            string expected = str;

            string actual = EncoderExtensions.EncodeForLdap(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForVbScript tests

        /// <summary>
        ///A test for EncodeForVbScript with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForVbScriptTest_Positive()
        {
            string str = "<script>";
            string expected = "chrw(60)&\"script\"&chrw(62)";

            string actual = EncoderExtensions.EncodeForVbScript(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        /// <summary>
        ///A test for EncodeForVbScript with value that need nod encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForVbScriptTest_Negative()
        {
            string str = "a5";
            string expected = "\"a5\"";

            string actual = EncoderExtensions.EncodeForVbScript(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForXml tests

        /// <summary>
        ///A test for EncodeForXml with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForXmlTest_Positive()
        {
            string str = "<script>";
            // Expected from old microsoft library
			string expected = "&#60;script&#62;";
			// Expected from new microsoft library
            string expected2 = "&lt;script&gt;";

            string actual = str.EncodeForXml();
			// Check that results are correct for old and new microsoft library
            Assert.IsFalse(!actual.Equals(expected, StringComparison.InvariantCultureIgnoreCase) && !actual.Equals(expected2, StringComparison.InvariantCultureIgnoreCase), "\"{0}\" or \"{2}\" expected but \"{1}\" found.", expected, actual, expected2);
        }

        /// <summary>
        ///A test for EncodeForXml with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForXmlTest_Negative()
        {
            string str = "--";
            string expected = "--";

            string actual = EncoderExtensions.EncodeForXml(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion

        #region EncodeForXmlAttribute tests

        /// <summary>
        ///A test for EncodeForXmlAttribute with value that need encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForXmlAttributeTest_Positive()
        {
            string str = "<script>";
			// Expected from old microsoft library
            string expected = "&#60;script&#62;";
			// Expected from new microsoft library
            string expected2 = "&lt;script&gt;";

            string actual = str.EncodeForXmlAttribute();
			// Check that results are correct for old and new microsoft library
            Assert.IsFalse(!actual.Equals(expected, StringComparison.InvariantCultureIgnoreCase) && !actual.Equals(expected2, StringComparison.InvariantCultureIgnoreCase), "\"{0}\" or \"{2}\" expected but \"{1}\" found.", expected, actual, expected2);
        }

        /// <summary>
        ///A test for EncodeForXmlAttribute with value that need not encoding.
        ///</summary>
        [TestMethod()]
        public void EncodeForXmlAttributeTest_Negative()
        {
            string str = "--";
            string expected = str;

            string actual = EncoderExtensions.EncodeForXmlAttribute(str);
            Assert.AreEqual(expected, actual, "\"{0}\" expected but \"{1}\" found.", expected, actual);
        }

        #endregion
    }
}

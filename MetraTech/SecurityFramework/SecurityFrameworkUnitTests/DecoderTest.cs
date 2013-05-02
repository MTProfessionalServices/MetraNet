using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Common.Serialization;
using MetraTech.SecurityFramework.Core.Decoder;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.SecurityFramework.Core.Detector;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Summary description for DecoderTest
    /// </summary>
    [TestClass]
    public class DecoderTest
    {
        #region Initialization tests
        public DecoderTest()
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

        #region HTML decoder tests

        /// <summary>
        /// Test for the HTML decoder with non-encoded input.
        /// </summary>
        [TestMethod]
        public void HtmlDecoderTest_Positive_NonEncoded()
        {
            string input;
            string expected;
            input = expected = "\abcdfghijklmnopqrstuvwxyz ABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_+ абвгдеёжзийклмнопрстуфхцчшщЪыьэюя";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for the HTML decoder with all of named HTML entities coding printable characters.
        /// </summary>
        [TestMethod]
        public void HtmlDecoderTest_Positive_NamedEntityPrintable()
        {
            string input = "&iuml&eth;&ntilde&ograve;&oacute&ocirc;&otilde&ouml;&divide&oslash;&ugrave&uacute;&ucirc&uuml;&yacute&thorn;&yuml&OElig;&oelig&Scaron;&scaron&Yuml;&fnof&circ;&tilde&Alpha;&Beta&Gamma;&Delta&Epsilon;&Zeta&Eta;&Theta&Iota;&Kappa&Lambda;&Mu&Nu;&Xi&Omicron;&Pi&Rho;&Sigma&Tau;&Upsilon&Phi;&Chi&Psi;&Omega&alpha;&beta&gamma;&delta&epsilon;&zeta&eta;&theta&iota;&kappa&lambda;&mu&nu;&xi&omicron;&pi&rho;&sigmaf&sigma;&tau&upsilon;&phi&chi;&psi&omega;&thetasym&upsih;&piv&ndash&mdash;&lsquo&rsquo;&sbquo&ldquo;&rdquo&bdquo;&dagger&Dagger;&bull&hellip;&permil&prime;&Prime&lsaquo;&rsaquo&oline;&frasl&euro;&image&weierp;&real&trade;&alefsym&larr;&uarr&rarr;&darr&harr;&crarr&lArr;&uArr&rArr;&dArr&hArr;&forall&part;&exist&empty;&nabla&isin;&notin&ni;&prod&sum;&minus&lowast;&radic&prop;&infin&ang;&and&or;&cap&cup;&int&there4;&sim&cong;&asymp&ne;&equiv&le;&ge&sub;&sup&nsub;&sube&supe;&oplus&otimes;&perp&sdot;&lceil&rceil;&lfloor&rfloor;&lang&rang;&loz&spades;&clubs&hearts;&diams&quot;&amp&apos;&lpar&rpar;&lt&gt;&nbsp&iexcl;&cent&pound;&curren&yen;&brvbar&sect;&uml&copy;&ordf&laquo;&not&reg&macr;&deg&plusmn;&sup2&sup3;&acute&micro;&para&middot;&cedil&sup1;&ordm&raquo;&frac14&frac12;&frac34&iquest;&Agrave&Aacute;&Acirc&Atilde;&Auml&Aring;&AElig&Ccedil;&Egrave&Eacute;&Ecirc&Euml;&Igrave&Iacute;&Icirc&Iuml;&ETH&Ntilde;&Ograve&Oacute;&Ocirc&Otilde;&Ouml&times;&Oslash&Ugrave;&Uacute&Ucirc;&Uuml&Yacute;&THORN&szlig;&agrave&aacute;&acirc&atilde;&auml&aring;&aelig&ccedil;&egrave&eacute;&ecirc&euml;&igrave&iacute;&icirc";
            string expected = @"ïðñòóôõö÷øùúûüýþÿŒœŠšŸƒˆ˜ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρςστυφχψωϑϒϖ–—‘’‚“”„†‡•…‰′″‹›‾⁄€ℑ℘ℜ™ℵ←↑→↓↔↵⇐⇑⇒⇓⇔∀∂∃∅∇∈∉∋∏∑−∗√∝∞∠∧∨∩∪∫∴∼≅≈≠≡≤≥⊂⊃⊄⊆⊇⊕⊗⊥⋅⌈⌉⌊⌋〈〉◊♠♣♥♦""&'()<> ¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíî";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for the HTML decoder with all of named HTML entities coding non-printable characters.
        /// </summary>
        [TestMethod]
        public void HtmlDecoderTest_Positive_NamedEntityNonProntable()
        {
            string input = "&shy;&ensp;&emsp;&thinsp;&zwnj;&zwj;&lrm;&rlm;";
            string expected = "\xad\x2002\x2003\x2009\x200c\x200d\x200e\x200f";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for HTML decoder with decimal numeric entities.
        /// </summary>
        [TestMethod]
        public void HtmlDecoderTest_Positive_DecimalEntity()
        {
            string input = "&#32ab&#032ab&#0000032ab&#32;ab&#032;ab&#0000032;ab&#1041";
            string expected = " ab ab ab ab ab abБ";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for HTML decoder with hexadecimal numeric entities.
        /// </summary>
        [TestMethod]
        public void HtmlDecoderTest_Positive_HexEntity()
        {
            string input = "&#x20vb&#x020vb&#x0000020vb&#x20;ab&#x020;ab&#x0000020;ab&#x411&#xnn&#x3E&#x3e;e";
            string expected = " vb vb vb ab ab abБ&#xnn>>e";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for HTML decoders with null input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void HtmlDecoderTest_NullInput()
        {
            ApiInput input = null;

            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
        }

        /// <summary>
        /// Test for HTML decoders with empty input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void HtmlDecoderTest_EmptyInput()
        {
            string input = string.Empty;

            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
        }

        #endregion

        #region XML decoder tests

        /// <summary>
        /// Test for XML decoder with non-encoded input.
        /// </summary>
        [TestMethod]
        public void XmlDecoderTest_Positive_NonEncoded()
        {
            string input;
            string expected;
            input = expected = "\abcdfghijklmnopqrstuvwxyz ABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_+ абвгдеёжзийклмнопрстуфхцч<>шщЪыьэюя&lt";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Xml + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for XML decoder with named XML entities.
        /// </summary>
        [TestMethod]
        public void XmlDecoderTest_Positive_NamedEntities()
        {
            string input = "&quot;&amp;&apos;&lt;&gt;&quot&amp&apos&lt&gt";
            string expected = "\"&'<>&quot&amp&apos&lt&gt";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Xml + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for XML decoder with decimal numeric entities.
        /// </summary>
        [TestMethod]
        public void XmlDecoderTest_Positive_DecimalEntity()
        {
            string input = "&#32ab&#032ab&#0000032ab&#32;ab&#032;ab&#0000032;ab&#1041;";
            string expected = "&#32ab&#032ab&#0000032ab ab ab abБ";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Xml + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for XML decoder with hexadecimal numeric entities.
        /// </summary>
        [TestMethod]
        public void XmlDecoderTest_Positive_HexEntity()
        {
            string input = "&#x20vb&#x020vb&#x0000020vb&#x20;ab&#x020;ab&#x0000020;ab&#x411;&#xnn&#x3E;&#x3e;e";
            string expected = "&#x20vb&#x020vb&#x0000020vb ab ab abБ&#xnn>>e";

            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Xml + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Test for XML decoder with null input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void XmlDecoderTest_NullInput()
        {
            ApiInput input = null;

            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Xml + ".V1", input);
        }

        /// <summary>
        /// Test for XML decoder with empty input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void XmlDecoderTest_EmptyInput()
        {
            string input = string.Empty;

            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Xml + ".V1", input);
        }

        #endregion

		#region URL decoder tests

		/// <summary>
		/// Test for the URL decoder with non-encoded input.
		/// </summary>
		[TestMethod]
		public void UrlDecoderTest_Positive_NonEncoded()
		{
			string expected = "abcdfghijklmnopqrstuvwxyz ABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_";
			ApiInput input = new ApiInput(expected);

			string actual = SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Url.ToString(), input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

        /// <summary>
        /// Test for the URL decoder. Unicide decoding
        /// </summary>
        [TestMethod]
        public void UrlDecoderUnicodeSequenceTest()
        {
            string inputStr = "%u0410";
            // Cirilyc A
            string expected = "А";

            ApiInput input = new ApiInput(inputStr);

            string actual = SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Url.ToString(), input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

		/// <summary>
		/// Test for the URL decoder with non-encoded input.
		/// </summary>
		[TestMethod]
		public void UrlDecoderTest_Positive_Encoded()
		{
			string expected = "abcdfghijklmnopqrstuvwxyzABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_ абвгдеёжзийклмнопрстуфхцчшщЪыьэюя";
			ApiInput input = new ApiInput("%61bcdfghijklmnopqrstuvwxyzABCDFGHIJKLMNOPQRSTUVWXYZ+01234567890-=%20!@#$%25^&*()_+%d0%b0%d0%b1%d0%b2%d0%b3%d0%b4%d0%b5%d1%91%d0%b6%d0%b7%d0%b8%d0%b9%d0%ba%d0%bb%d0%bc%d0%bd%d0%be%d0%bf%d1%80%d1%81%d1%82%d1%83%d1%84%d1%85%d1%86%d1%87%d1%88%d1%89%d0%aa%d1%8b%d1%8c%d1%8d%d1%8e%d1%8f");

			string actual = SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Url.ToString(), input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the URL decoder with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void UrlDecoderTest_NullInput()
		{
			ApiInput input = null;
			SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Url.ToString(), input);
		}

		/// <summary>
		/// Test for the URL decoder with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void UrlDecoderTest_EmptyInput()
		{
			ApiInput input = new ApiInput(string.Empty);
			SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Url.ToString(), input);
		}

		#endregion

        #region JavaScript decoder tests

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

        #endregion JavaScript decoder tests

        #region VBScript decoder test

        #region Is not null and not empty?

        /// <summary>
        /// Test for the JavaScript decoder with null input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void VbScriptTest_NullInput()
        {
            string input = null;
            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
        }

        /// <summary>
        /// Test for the JavaScript decoder with empty input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void VbScriptTest_EmptyInput()
        {
            string input = string.Empty;
            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
        }

        #endregion Is not null and not empty?

        [TestMethod]
        public void VbScriptTest()
        {
            string expectedStr = "%%, ,~,!,&,wedw&&=\"test\"t\"\"\"&&&4$#&&&&";
            string actualStr = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expectedStr);

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        public void VbScriptTest2()
        {
            string expectedStr = "Test-%, ,~,!,@,#,$,^,&,*,(,),{,},[,],=,:,/,,,;,?,+,',\\,\"end22";
            string actualStr = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expectedStr);

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        public void VbScriptTest3()
        {
            string expectedStr = "alert('XSS атака!'); .,-_";
            string actualStr = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expectedStr);

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", actualStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        #endregion VBScript decoder test

        #region CSS decoder tests

        /// <summary>
		/// Test for the CSS decoder with non-encoded input.
		/// </summary>
		[TestMethod]
		public void CssDecoderTest_Positive_NonEncoded()
		{
			string expected = "\abcdfghijklmnopqrstuvwxyz ABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_";
			ApiInput input = new ApiInput(expected);

			string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Css + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CSS decoder with encoded input.
		/// </summary>
		[TestMethod]
		public void CssDecoderTest_Positive_Encoded()
		{
			string input = @"\9 \3c span\20 style\03d \0022 font\0002d family\00003a\20 LU beck\22 \3e \2e \2e \2e \3c \2f span\00003e1";
			string expected = "\t<span style=\"font-family: LU beck\">...</span>1";

			string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Css + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CSS decoder with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void CssDecoderTest_NullInput()
		{
			ApiInput input = null;

			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Css + ".V1", input);
		}

		/// <summary>
		/// Test for the CSS decoder with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void CssDecoderTest_EmptyInput()
		{
			ApiInput input = new ApiInput(string.Empty);

			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Css + ".V1", input);
		}

		#endregion

        #region Base64 group decoder tests

        #region Is not null and not empty?

        /// <summary>
        /// Test for the JavaScript decoder with null input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void Base64Test_NullInput()
        {
            string input = null;
            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".Standart", input);
        }

        /// <summary>
        /// Test for the JavaScript decoder with empty input.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(NullInputDataException))]
        public void Base64Test_EmptyInput()
        {
            string input = string.Empty;
            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".Standart", input);
        }

        #endregion Is not null and not empty?

        #region Standart Base64 decoder tests

        [TestMethod]
        public void StandartBase64Test_Positive()
        {
            string inputStr = "SGVsbG8gd29yZCE=";
            string expectedStr = "Hello word!";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".Standart", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        [TestMethod]
        [ExpectedException(typeof(DecoderInputDataException))]
        public void StandartBase64Test_Negative()
        {
            string inputStr = "fgd fgd fdgdfgdf";
            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".Standart", inputStr);
        }

        #endregion Standart Base64 decoder tests

        /// <summary>
        /// Modified Base64 for filenames (non standard); char62 = '+'; char63 = '-'
        /// </summary>
        [TestMethod]
        public void ModifiedForFilenamestBase64Test_Positive()
        {
            string inputStr = "all+";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForFilenames", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al-=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForFilenames", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        /// <summary>
        /// Modified Base64 for URL applications; char62 = '-'; char63 = '_'
        /// </summary>
        [TestMethod]
        public void ModifiedForURLBase64Test_Positive()
        {
            string inputStr = "all-";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForURL", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al_=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForURL", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        /// <summary>
        /// Modified Base64 for XML name tokens (Nmtoken); char62 = '.'; char63 = '-'
        /// </summary>
        [TestMethod]
        public void ModifiedForXmlNmtokenBase64Test_Positive()
        {
            string inputStr = "all.";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForXmlNmtoken", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al-=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForXmlNmtoken", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        /// <summary>
        /// Modified Base64 for XML identifiers (Name); char62 = '_'; char63 = ':'
        /// </summary>
        [TestMethod]
        public void ModifiedForXmlNameBase64Test_Positive()
        {
            string inputStr = "all_";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForXmlName", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al:=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForXmlName", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        /// <summary>
        /// Modified Base64 for Program identifiers(variant 1, non standard); char62 = '_'; char63 = '-'
        /// </summary>
        [TestMethod]
        public void ModifiedForProgramIdentifiersV1Base64Test_Positive()
        {
            string inputStr = "all_";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV1", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al-=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV1", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        #region Modified Base64 for Program identifiers

        /// <summary>
        /// Modified Base64 for Program identifiers(variant 2, non standard); char62 = '.'; char63 = '_'
        /// </summary>
        [TestMethod]
        public void ModifiedForProgramIdentifiersV2Base64Test_Positive()
        {
            string inputStr = "all.";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al_=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV1", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }

        /// <summary>
        /// Modified Base64 for Program identifiers(variant 2, non standard); char62 = '.'; char63 = '_'
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DecoderInputDataException))]
        public void ModifiedForProgramIdentifiersV2Base64Test_NegativeBadSecChar62()
        {
            string inputStr = "all+";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2", inputStr);
            Assert.Fail("Must be occur Exception");
        }

        /// <summary>
        /// Modified Base64 for Program identifiers(variant 2, non standard); char62 = '.'; char63 = '_'
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DecoderInputDataException))]
        public void ModifiedForProgramIdentifiersV2Base64Test_NegativeBadSecChar63()
        {
            string inputStr = "al/=";
            string expectedStr = "j_";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2", inputStr);
            Assert.Fail("Must be occur Exception");
        }

        #endregion Modified Base64 for Program identifiers

        /// <summary>
        ///Modified Base64 for Regular expressions(non standard); char62 = '!'; char63 = '-'
        /// </summary>
        [TestMethod]
        public void ModifiedForRegularExpressionsBase64Test_Positive()
        {
            string inputStr = "all!";
            string expectedStr = "jY~";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForRegularExpressions", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());

            inputStr = "al-=";
            expectedStr = "j_";

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForRegularExpressions", inputStr);
            Assert.IsTrue(expectedStr == output.ToString());
        }
        
        #endregion Base64 group decoder tests

    }
}

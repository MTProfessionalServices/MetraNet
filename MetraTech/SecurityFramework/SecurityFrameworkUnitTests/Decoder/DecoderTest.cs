using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Core.Decoder;
using Microsoft.VisualStudio.TestTools.UnitTesting;

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
		
		#endregion

		#endregion Initialization tests

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
			const string expected = "Test-%, ,~,!,@,#,$,^,&,*,(,),{,},[,],=,:,/,,,;,?,+,',\\,\"end22";
			string input = Microsoft.Security.Application.Encoder.JavaScriptEncode(expected);
			// removed the single quotes in the begin and in the end of string
			input = input.Substring(1, input.Length - 2);

			ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
		}

		[TestMethod]
		public void JavaScriptTest2()
		{
			const string input = "+XSS\\x20\\u043F\\u0440\\u0438\\u0432\\u0435\\u0442/.\\x20\\x3Cscript+\\x20\\x3E";
            const string expected = "+XSS привет/. <script+ >";

			ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
			Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
		}

		[TestMethod]
		public void JavaScriptTest3()
		{
            const string input = "+XSS\\x20\\u043F\\u0440\\u0438\\u0432\\u0435\\u0442/.\\x20\\x3Cscript+\\x20\\x3E";
            const string expected = "+XSS привет/. <script+ >";
			
			ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
		}

        [TestMethod]
        public void JavaScriptSpecialSymbol1Test()
        {
            const string input = "\\'6\\'78*#$&3#";
            const string expected = "'6'78*#$&3#";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        [TestMethod]
        public void JavaScriptSpecialSymbol2Test()
        {
            const string input = "\\\"678*#$&3#";
            const string expected = "\"678*#$&3#";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        [TestMethod]
        public void JavaScriptSpecialSymbol3Test()
        {
            const string input = "\\&678*#$&3#";
            const string expected = "&678*#$&3#";
            

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        [TestMethod]
        public void JavaScriptSpecialSymbolAndOctalCodeTest()
        {
            const string input = "\\\\718*#$&3#";
            const string expected = "98*#$&3#";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        /// <summary>
        /// Bug-221 : JavaScript decoder have errors if character "&" was put in data string
        /// </summary>
        [TestMethod]
        public void JavaScriptTest1_Negative()
        {
            const string input = "&678*#$&3#";
            const string expected = "&678*#$&3#";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        /// <summary>
        /// Bug-230 :   JavaScript decoder have errors if character "&" was put in data string
        /// </summary>
        [TestMethod]
        public void JavaScriptBSTest_Positive()
        {
            const string input = "\\b 1 \\t 2 \\n 3 \\v 4 \\f 5 \\r 6 ";
            const string expected = "\x08 1 \x09 2 \x0a 3 \x0b 4 \x0c 5 \x0d 6 ";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        /// <summary>
        /// Bug-230 :   JavaScript decoder have errors if character "&" was put in data string
        /// </summary>
        [TestMethod]
        public void JavaScriptBS2Test_Positive()
        {
            const string input = "\\b1\\t2\\n3\\v4\\f5\\r6";
            const string expected = "\x08\x31\x09\x32\x0a\x33\x0b\x34\x0c\x35\x0d\x36";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        /// <summary>
        /// Bug-229 :   Javascript decoder: Octal sequences \ddd are not processed.
        /// </summary>
        [TestMethod]
        public void JavaScriptOctalCodeTest_Positive()
        {
            const string input = "\\41";
            const string expected = "!";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

        /// <summary>
        /// Bug-229 :   Javascript decoder: Octal sequences \ddd are not processed.
        /// </summary>
        [TestMethod]
        public void JavaScriptOctalCodeTest2_Positive()
        {
            const string input = "\\717";
            const string expected = "97";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
        }

		#region For Unicode tests

		[TestMethod]
		public void JavaScriptTest4()
		{
            string input = "\\uF900";
            // Unicode code \uF900
			string expected = "豈";
			
			ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
		}

        /// <summary>
        /// Negative test, besause cheks only 4-th hex digits
        /// </summary>
		[TestMethod]
		public void JavaScriptTest5_Negative()
		{
            string input = "\\u20010";
			// Unicode code \u20010
            //string expected = "𠀐";
            string expected = " 0";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
		}

		[TestMethod]
		public void JavaScriptTest6()
		{
            string input = "\\x3Cscript\\x3Ealert\\x28\\x22\\x20\\u041F\\u0440\\u0438\\u0432\\u0435\\u0442\\x21\\x20\\x2B\\x22\\x29\\x3B";
            string expected = "<script>alert(\" Привет! +\");";
			
			ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
		}

        /// <summary>
        /// Bug-232 :   javascript: Unicode sequences represented in following format \uHHHH should have exactly 4 hexdecimal digits.
        /// </summary>
        [TestMethod]
        public void JavaScriptTest7()
        {
            string input = "\\u00311\\xA0\\u00322\\xA0\\u00333";
            string expected = "11 22 33";

            ApiOutput output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.JavaScript + ".V1", input);
            Assert.AreEqual(expected, output, "Expected \"{0}\" but found \"{1}\"", expected, output);
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
			string expected = "%%, ,~,!,&,wedw&&=\"test & test\"t\"\"\"&&&4$#&&&&";
			string input = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expected);

			ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		[TestMethod]
		public void VbScriptTest2()
		{
			string expected = "Test-%, ,~,!,@,#,$,^,&,*,(,),{,},[,],=,:,/,,,;,?,+,',\\,\"end22";
			string input = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expected);

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		[TestMethod]
		public void VbScriptTest3()
		{
			string expected = "alert('XSS атака!'); .,-_";
			string input = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expected);

			ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

        [TestMethod]
        public void VbScriptTest4()
        {
            string input = "alert\"&chrw(40)&chrw(39)&\"XSS\"&chrw(32)&chrw(1072)&chrw(1090)&chrw(1072)&chrw(1082)&chrw(1072)&chrw(33)&chrw(39)&chrw(41)&chrw(59)&chrw(32)&\".,\"&chrw(45)&\"_";
            string expected = "alert('XSS атака!'); .,-_";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// Hexadecimal characters in any encoding. 
        /// </summary>
        /// <remarks>Bug-210</remarks>
        [TestMethod]
        public void VbScriptTest5()
        {
            string inputStr = "chr(&h21)";
            string expected = "!";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// VBScript decoder: spaces between string's parts should processed correctly.
        /// </summary>
        /// <remarks>Bug-235</remarks>
        [TestMethod]
        public void VbScripDecoderSpacesBetweenStringTest()
        {
            string inputStr = "chr(34) & \"App.exe \"";
            string expected = "\"App.exe ";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// VBScript decoder: spaces between string's parts should processed correctly.
        /// </summary>
        /// <remarks>Bug-235</remarks>
        [TestMethod]
        public void VbScripDecoderSpacesBetweenStringTest2()
        {
            string inputStr = "chr(34) & \"App.exe \" ";
            string expected = "\"App.exe ";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// VBScript decoder: spaces between string's parts should processed correctly.
        /// </summary>
        /// <remarks>Bug-239</remarks>
        [TestMethod]
        public void VbScripDecoder4QuotersTest()
        {
            string inputStr = "\"\"\"\"";
            string expected = "\"";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// VBScript decoder: spaces between string's parts should processed correctly.
        /// </summary>
        /// <remarks>Bug-239</remarks>
        [TestMethod]
        public void VbScripDecoder4QuotersTest2()
        {
            string expected = "\"";
            string input = Microsoft.Security.Application.Encoder.VisualBasicScriptEncode(expected);;

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// VBScript decoder: spaces between string's parts should processed correctly.
        /// </summary>
        /// <remarks>Bug-239</remarks>
        [TestMethod]
        public void VbScripDecoder4QuotersTest3()
        {
            string expected = "\"\"";
            string input = "\"\"\"\"   &  \"\"\"\"";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", input);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        /// <summary>
        /// VBScript decoder: between parts of string symbol & is neccesary
        /// </summary>
        /// <remarks>Bug-238</remarks>
        [TestMethod]
        public void VbScripDecoderBetweenPartsOfStrsymbolAMPNeccesaryTest()
        {
            string inputStr = "\"App.exe\" chr(34) \"App.exe\"" ;
            string expected = "\"App.exe\" chr(34) \"App.exe\"";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        [TestMethod]
        public void VbScripDecoderRemoveDoubleQuotesTest()
        {
            string inputStr = "\"Shakespeare\"& chr(&h2C)&\" \"&chr(34)&\"The Divine Comedy\"   &chr(34)";
            string expected = "Shakespeare, \"The Divine Comedy\"";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        [TestMethod]
        public void VbScripDecoderRemoveDoubleQuotesTest2()
        {
            string inputStr = "\"Shakespeare, \"\"The Divine Comedy\"\"\"";
            string expected = "Shakespeare, \"The Divine Comedy\"";

            ApiOutput actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.VbScript + ".V1", inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
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
		/// Test for the CSS decoder with encoded input - SECFRM-224.
		/// </summary>
		[TestMethod]
		public void CssDecoderTest_Positive_Encoded2()
		{
			string input = "\\0021 \\0022\n\\0021 \\0022";
			string expected = "!\"\n!\"";

			string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Css + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CSS decoder with encoded input - SECFRM-225.
		/// </summary>
		[TestMethod]
		public void CssDecoderTest_Positive_Encoded3()
		{
			string input = "\\21\\021\\0021\\00021\\000021";
			string expected = "!!!!!";

			string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Css + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the CSS decoder with encoded input - SECFRM-226.
		/// </summary>
		[TestMethod]
		public void CssDecoderTest_Positive_Encoded4()
		{
			string input = "\\000027 \\35 \\34";
			string expected = "'54";

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
			string input = "&iuml&eth;&ntilde&ograve;&oacute&ocirc;&otilde&ouml;&divide&oslash;&ugrave&uacute;&ucirc&uuml;&yacute&thorn;&yuml&OElig;&oelig&Scaron;&scaron&Yuml;&fnof&circ;&tilde&Alpha;&Beta&Gamma;&Delta&Epsilon;&Zeta&Eta;&Theta&Iota;&Kappa&Lambda;&Mu&Nu;&Xi&Omicron;&Pi&Rho;&Sigma&Tau;&Upsilon&Phi;&Chi&Psi;&Omega&alpha;&beta&gamma;&delta&epsilon;&zeta&eta;&theta&iota;&kappa&lambda;&mu&nu;&xi&omicron;&pi&rho;&sigmaf&sigma;&tau&upsilon;&phi&chi;&psi&omega;&thetasym&upsih;&piv&ndash&mdash;&lsquo&rsquo;&sbquo&ldquo;&rdquo&bdquo;&dagger&Dagger;&bull&hellip;&permil&prime;&Prime&lsaquo;&rsaquo&oline;&frasl&euro;&image&weierp;&real&trade;&alefsym&larr;&uarr&rarr;&darr&harr;&crarr&lArr;&uArr&rArr;&dArr&hArr;&forall&part;&exist&empty;&nabla&isin;&notin&ni;&prod&sum;&minus&lowast;&radic&prop;&infin&ang;&and&or;&cap&cup;&int&there4;&sim&cong;&asymp&ne;&equiv&le;&ge&sub;&sup&nsub;&sube&supe;&oplus&otimes;&perp&sdot;&lceil&rceil;&lfloor&rfloor;&lang&rang;&loz&spades;&clubs&hearts;&diams&quot;&amp&apos;&lpar&rpar;&lt&gt;&nbsp&iexcl;&cent&pound;&curren&yen;&brvbar&sect;&uml&copy;&ordf&laquo;&not&reg&macr;&deg&plusmn;&sup2&sup3;&acute&micro;&para&middot;&cedil&sup1;&ordm&raquo;&frac14&frac12;&frac34&iquest;&Agrave&Aacute;&Acirc&Atilde;&Auml&Aring;&AElig&Ccedil;&Egrave&Eacute;&Ecirc&Euml;&Igrave&Iacute;&Icirc&Iuml;&ETH&Ntilde;&Ograve&Oacute;&Ocirc&Otilde;&Ouml&times;&Oslash&Ugrave;&Uacute&Ucirc;&Uuml&Yacute;&THORN&szlig;&agrave&aacute;&acirc&atilde;&auml&aring;&aelig&ccedil;&egrave&eacute;&ecirc&euml;&igrave&iacute;&icirc&plus;&sol;&ast;&hyphen;&lcub;&rcub;&equals;&commat;&semi;&colon;&num;&quest;&excl;&period;";
			string expected = @"ïðñòóôõö÷øùúûüýþÿŒœŠšŸƒˆ˜ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρςστυφχψωϑϒϖ–—‘’‚“”„†‡•…‰′″‹›‾⁄€ℑ℘ℜ™ℵ←↑→↓↔↵⇐⇑⇒⇓⇔∀∂∃∅∇∈∉∋∏∑−∗√∝∞∠∧∨∩∪∫∴∼≅≈≠≡≤≥⊂⊃⊄⊆⊇⊕⊗⊥⋅⌈⌉⌊⌋〈〉◊♠♣♥♦""&'()<> ¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíî+/*-{}=@;:#?!.";

			string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
			Assert.AreEqual(expected, actual, string.Format("Expected \"{0}\" but found \"{1}\"", expected, actual));
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
		/// Test for the HTML decoder with case-insensitive named HTML entities.
		/// </summary>
		[TestMethod]
		public void HtmlDecoderTest_Positive_NamedEntityCaseInsensitive()
		{
			string input = "&QUOT;&AMP;&LT;&GT;&COPY;&REG;";
			string expected = "\"&<>©®";

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
			string input = "&#x20vb&#x020vb&#x0000020vb&#x20;ab&#x020;ab&#x0000020;ab&#x411&#xnn&#x3E&#X3e;e";
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

		/// <summary>
		/// Test for the HTML decoder with case-insensitive named HTML entities (wrong).
		/// </summary>
		[TestMethod]
		public void HtmlDecoderTest_Negative_NamedEntityCaseInsensitive()
		{
			string input = "&QUOt;&AMp;&Lt;&gT;&cOPY;&ReG;";
			string expected = input;

			string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

        [TestMethod]
        public void HtmlDecoderTestNull1_Positive()
        {
            string input = "&#x31&#00&#x32";
            // null char
            string expected = "1\02";
            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);

            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        [TestMethod]
        public void HtmlDecoderTestNull2_Positive()
        {
            string input = "&#x5c&#x30";
            // null char
            string expected = "\\0";
            string actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Html + ".V1", input);

            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
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
			input = expected = "\abcdfghijklmnopqrstuvwxyz ABCDFGHIJKLMNOPQRSTUVWXYZ 01234567890-= !@#$%^&*()_+ абвгдеёжзийклмнопрстуфхцч<>шщЪыьэюя&lt&#X3C";

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

		#region GZIP decoder tests

		/// <summary>
		/// Test for the GZIP decoder with a true base 64 encoded compressed input.
		/// </summary>
		[TestMethod]
		public void GZipDecoderTest_PositiveBase64String()
		{
			byte[] expected = Encoding.UTF8.GetBytes(UnitTestUtility.DecompressedText);
			byte[] actual;

			actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", UnitTestUtility.CompressedText).Value as byte[];
			CollectionAssert.AreEqual(expected, actual);
		}

		/// <summary>
		/// Test for the GZIP decoder with a compressed input as a byte array.
		/// </summary>
		[TestMethod]
		public void GZipDecoderTest_PositiveByteArray()
		{
			byte[] expected = Encoding.UTF8.GetBytes(UnitTestUtility.DecompressedText);
			byte[] actual;
			ApiInput input = new ApiInput(Convert.FromBase64String(UnitTestUtility.CompressedText));

			actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", input).Value as byte[];
			CollectionAssert.AreEqual(expected, actual);
		}

		/// <summary>
		/// Test for the GZIP decoder with a compressed input as a stream.
		/// </summary>
		[TestMethod]
		public void GZipDecoderTest_PositiveStream()
		{
			byte[] expected = Encoding.UTF8.GetBytes(UnitTestUtility.DecompressedText);
			byte[] actual;

			using (System.IO.MemoryStream stream = new System.IO.MemoryStream(Convert.FromBase64String(UnitTestUtility.CompressedText)))
			{
				ApiInput input = new ApiInput(stream);
				actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", input).Value as byte[];
			}

			CollectionAssert.AreEqual(expected, actual);
		}

		/// <summary>
		/// Test for the GZIP decoder with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void GZipDecoderTest_NullInput()
		{
			ApiInput input = null;
			
			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", input);
		}

		/// <summary>
		/// Test for the GZIP decoder with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void GZipDecoderTest_EmptyInput()
		{
			string input = string.Empty;
			
			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", input);
		}

		/// <summary>
		/// Test for the GZIP decoder with incorrectly encoded string.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(DecoderInputDataException))]
		public void GZipDecoderTest_Base64Invalid()
		{
			string input = UnitTestUtility.CompressedText.Substring(1);
			
			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", input);
		}

		/// <summary>
		/// Test for the GZIP decoder with compressed data corruption.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(DecoderInputDataException))]
		public void GZipDecoderTest_CorruptedCompression()
		{
			byte[] input = Convert.FromBase64String(UnitTestUtility.CompressedText);
			input[0] = 0;

			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", new ApiInput(input));
		}

		/// <summary>
		/// Test for the GZIP decoder with a unsupported input type.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(SubsystemInputParamException))]
		public void GZipDecoderTest_UnsupportedInputType()
		{
			ApiInput input = new ApiInput(UnitTestUtility.CompressedText.ToCharArray());

			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.GZip + ".V1", input);
		}

		#endregion

		#region LDAP decoder tests

		/// <summary>
		/// Test for the LDAP decoder with an encoded input.
		/// </summary>
		[TestMethod]
		public void LdapDecoderTest_PositiveEncoded()
		{
			string input = "abcd\\2A\\28\\29\\2F\\5c111";
			string expected = "abcd*()/\\111";
			string actual;

			actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Ldap + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the LDAP decoder with an non-encoded input.
		/// </summary>
		[TestMethod]
		public void LdapDecoderTest_PositiveNonEncoded()
		{
			string input = "abcd\\AA\\\\k29\\2kF\\85c111";
			string expected = input;
			string actual;

			actual = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Ldap + ".V1", input);
			Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
		}

		/// <summary>
		/// Test for the LDAP decoder with null input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void LdapDecoderTest_NullInput()
		{
			ApiInput input = null;

			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Ldap + ".V1", input);
		}

		/// <summary>
		/// Test for the LDAP decoder with empty input.
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(NullInputDataException))]
		public void LdapDecoderTest_EmptyInput()
		{
			ApiInput input = string.Empty;

			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Ldap + ".V1", input);
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

            output = SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2", inputStr);
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
			SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2", inputStr);
		}

		/// <summary>
		/// Modified Base64 for Program identifiers(variant 2, non standard); char62 = '.'; char63 = '_'
		/// </summary>
		[TestMethod]
		[ExpectedException(typeof(DecoderInputDataException))]
		public void ModifiedForProgramIdentifiersV2Base64Test_NegativeBadSecChar63()
		{
			string inputStr = "al/=";
            SecurityKernel.Decoder.Api.Execute(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2", inputStr);
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

        #region Complex Base64 decoder

        private IEngine GetComplexBase64Engine()
        {
            return SecurityKernel.Decoder.Api.GetEngine("Base64.ComplexDecoder");
        }

	    /// <summary>
        /// Standard 'Base64' encoding for RFC 3548or RFC 4648; char62 = '+'; char63 = '/'
        /// </summary>
        [TestMethod]
        public void SelectBase64StandartTest()
        {
            string inputStr = "all+";
            string expected = "jY~";
            
            ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

            inputStr = "al/=";
            expected = "j_";

            actual = GetComplexBase64Engine().Execute(inputStr);
            Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        }

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for filenames (non standard); char62 = '+'; char63 = '-' 
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForFilenamesTest()
        //{
        //    string inputStr = "all+";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al-=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for URL applications; char62 = '-'; char63 = '_'
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForURLTest()
        //{
        //    string inputStr = "all-";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al_=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for XML name tokens (Nmtoken); char62 = '.'; char63 = '-'
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForXmlNmtokenTest()
        //{
        //    string inputStr = "all.";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al-=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for XML identifiers (Name); char62 = '_'; char63 = ':'
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForXmlNameTest()
        //{
        //    string inputStr = "all_";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al:=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for Program identifiers(variant 1, non standard); char62 = '_'; char63 = '-'
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForProgramIdentofiersV1Test()
        //{
        //    string inputStr = "all_";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al-=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for Program identifiers(variant 1, non standard); char62 = '_'; char63 = '-'
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForProgramIdentofiersV2Test()
        //{
        //    string inputStr = "all_";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al-=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        //TODO: Code is commented out, because impossible to determine exactly Base64 version
        ///// <summary>
        ///// Modified Base64 for Regular expressions(non standard); char62 = '!'; char63 = '-'
        ///// </summary>
        //[TestMethod]
        //public void SelectBase64ModifiedForRegularExpressionsTest()
        //{
        //    string inputStr = "all!";
        //    string expected = "jY~";

        //    ApiOutput actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);

        //    inputStr = "al-=";
        //    expected = "j_";

        //    actual = GetComplexBase64Engine().Execute(inputStr);
        //    Assert.AreEqual(expected, actual, "Expected \"{0}\" but found \"{1}\"", expected, actual);
        //}

        #endregion Complex Base64 decoder
    }
}

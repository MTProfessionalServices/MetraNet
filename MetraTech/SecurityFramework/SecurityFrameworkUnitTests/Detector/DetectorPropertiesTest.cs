//#define INIT_PROPERTIES_FROM_CONFIG_FILE
using System;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.SecurityFramework.Core.Detector.Engine;

namespace MetraTech.SecurityFrameworkUnitTests.Detector
{
    [TestClass]
    public class DetectorPropertiesTest
    {
        private static SimpleXssDetectorPropertiesAdapted _xssDetectorParam = null;
        private static PatternWeightRegex _onePaternEvent = null;

        [ClassInitialize()]
        public static void DetectorInitialize(TestContext testContext)
        {
            
            #if INIT_PROPERTIES_FROM_CONFIG_FILE
                    InitFromConfigFile(testContext);
            #else
                    InitFromClass();
            #endif
        }

        private static void InitFromClass()
        {
            var xssDetector = new SimpleXssDetectorPropertiesConfigured();
            _xssDetectorParam = new SimpleXssDetectorPropertiesAdapted(xssDetector.DetectionParams);
            _onePaternEvent = CreateONERegexFromHtmlEventNames(xssDetector.DetectionParams.HtmlEventNames);
        }

        private static PatternWeightRegex CreateONERegexFromHtmlEventNames(IEnumerable<PatternWeight> eventNames)
        {
            PatternWeightRegex result = null;
            string pattern = "";

            if (eventNames != null)
            {
                foreach (PatternWeight patternWeight in eventNames)
                {
                    pattern += patternWeight.Pattern + '|';
                }
                pattern = pattern.Substring(0, pattern.Length - 1);
                result = new PatternWeightRegex
                {
                    Pattern =
                        new Regex(
                        String.Format(
                            @"(?i:\<\s*(\b.+?\b).*?\b(?:{0})\s*=\s*[\""\'].+?[\""\'].*?(?:/\s*\>|\>.*?\<\s*/\s*\1\s*\>))"
                            , pattern), RegexOptions.Compiled),
                    Weight = 100
                };
            }
            else
            {
                result = new PatternWeightRegex();
            }
            return result;
        }

        private static int AlgorithmIsMatch(string input, PatternWeightRegex pattern)
        {
            int result = 0;
            if (pattern.Pattern.IsMatch(input))
                    result += pattern.Weight;
            return result;
        }

        /// <summary>
        /// Test of detections of Javascript expressions
        /// </summary>
        [TestMethod]
        public void JavaScriptExpessionsTest()
        {
            // a.	decodeURI(string);
            Assert.IsTrue(AlgorithmIsMatch("var tst = \"sts\" + decodeURI  (  string + uuu + \"ewer\" + 'tyu'  );", _xssDetectorParam.JavaScriptElementPatterns[0]) > 0);

            // b.	decodeURIComponent(string);
            Assert.IsTrue(AlgorithmIsMatch("decodeURIComponent(string)", _xssDetectorParam.JavaScriptElementPatterns[1]) > 0);

            // c.	encodeURI(string);
            Assert.IsTrue(AlgorithmIsMatch("encodeURI(string)", _xssDetectorParam.JavaScriptElementPatterns[2]) > 0);

            // d.	encodeURIComponent(string);
            Assert.IsTrue(AlgorithmIsMatch("encodeURIComponent(string)", _xssDetectorParam.JavaScriptElementPatterns[3]) > 0);

            // e.	escape(string);
            Assert.IsTrue(AlgorithmIsMatch("escape(string)", _xssDetectorParam.JavaScriptElementPatterns[4]) > 0);

            // f.	eval(string);
            Assert.IsTrue(AlgorithmIsMatch("eval(string)", _xssDetectorParam.JavaScriptElementPatterns[5]) > 0);

            // g.	isFinite(value);
            Assert.IsTrue(AlgorithmIsMatch("isFinite(value);", _xssDetectorParam.JavaScriptElementPatterns[6]) > 0);

            // h.	isNaN(value);
            Assert.IsTrue(AlgorithmIsMatch("isNaN(value)", _xssDetectorParam.JavaScriptElementPatterns[7]) > 0);

            // i.	Number(object);
            Assert.IsTrue(AlgorithmIsMatch("Number(object)", _xssDetectorParam.JavaScriptElementPatterns[8]) > 0);

            // j.	 parseFloat(string);
            Assert.IsTrue(AlgorithmIsMatch("parseFloat(string)", _xssDetectorParam.JavaScriptElementPatterns[9]) > 0);

            // k.	parseInt(string, radix);
            Assert.IsTrue(AlgorithmIsMatch("parseInt(string, radix)", _xssDetectorParam.JavaScriptElementPatterns[10]) > 0);

            // l.	String(object);
            Assert.IsTrue(AlgorithmIsMatch("String(object);", _xssDetectorParam.JavaScriptElementPatterns[11]) > 0);

            // m.	unescape(string)
            Assert.IsTrue(AlgorithmIsMatch("unescape(string)", _xssDetectorParam.JavaScriptElementPatterns[12]) > 0);
        }

        /// <summary>
        /// Test of detections of DOM expressions
        /// </summary>
        [TestMethod]
        public void DomExpessionsTest()
        {
            // a)	document.write(document.links[0].id);
            // b)	document.write(document.domain);
            Assert.IsTrue(AlgorithmIsMatch(" document.   write(   document.links[0].id);", _xssDetectorParam.DomElementPatterns[0]) > 0);

            // c)	var doc=document.open("text/html","replace"); 
            Assert.IsTrue(AlgorithmIsMatch("var doc=document . open (\"text/html\",\"replace\"); ", _xssDetectorParam.DomElementPatterns[1]) > 0);

            // d)	alert(x.innerHTML);
            Assert.IsTrue(AlgorithmIsMatch("var t =alert   (   x.innerHTML);", _xssDetectorParam.DomElementPatterns[2]) > 0);

            // e)	getElementById("htmldom").href;
            Assert.IsTrue(AlgorithmIsMatch("getElementById('htmldom').href;", _xssDetectorParam.DomElementPatterns[3]) > 0);

            // f)	var p=window.createPopup();var pbody=p.document.body;
            Assert.IsTrue(AlgorithmIsMatch("var p=window.createPopup();var pbody=p.document.body;", _xssDetectorParam.DomElementPatterns[4]) > 0);

            // g)	window.scrollBy(100,100);
            Assert.IsTrue(AlgorithmIsMatch("window.   scrollBy    (100,100);", _xssDetectorParam.DomElementPatterns[5]) > 0);

            // h)	window.location.assign("www.w3schools.com")
            Assert.IsTrue(AlgorithmIsMatch("location   .   assign(\"www.w3schools.com\")", _xssDetectorParam.DomElementPatterns[6]) > 0);
        }

        /// <summary>
        /// Test of detections of HTML tags
        /// </summary>
        [TestMethod]
        public void HtmlTagsTest()
        {
            // -	Comments (<!--    );
            Assert.IsTrue(AlgorithmIsMatch("<p>Tsts<\\p><!--<b><\\b>-->", _xssDetectorParam.HtmlElementPatterns[0]) > 0);

            // -	<a>...</a>
            Assert.IsTrue(AlgorithmIsMatch("<a href=\"www.w3schools.com\">Visit W3Schools.com!</a>", _xssDetectorParam.HtmlElementPatterns[1]) > 0);

            // -	<aplet>...</aplet>
            Assert.IsTrue(AlgorithmIsMatch("The <applet >tet</applet> tag is not supported in HTML 5. Use the <object> tag instead.", _xssDetectorParam.HtmlElementPatterns[2]) > 0);

            // -	<area />
            Assert.IsTrue(AlgorithmIsMatch("<area shape=\"rect\" coords=\"0,0,82,126\" href=\"sun.htm\" alt=\"Sun\" />", _xssDetectorParam.HtmlElementPatterns[3]) > 0);
            // -	<area>...</area> (part2)
            Assert.IsTrue(AlgorithmIsMatch("<area shape=\"rect\" coords=\"0,0,82,126\" href=\"sun.htm\" alt=\"Sun\" ></area>", _xssDetectorParam.HtmlElementPatterns[3]) > 0);

            // -	<audio>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p><!--<audio>gug</audio>-->", _xssDetectorParam.HtmlElementPatterns[4]) > 0);

            // -	<base>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p> <base></base>", _xssDetectorParam.HtmlElementPatterns[5]) > 0);

            // -	<blockquote>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p> <blockquote> </blockquote> ", _xssDetectorParam.HtmlElementPatterns[6]) > 0);

            // -	<body>;  
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p> <body> </body> ", _xssDetectorParam.HtmlElementPatterns[7]) > 0);

            // -	<button>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p><button></button>", _xssDetectorParam.HtmlElementPatterns[8]) > 0);

            // -	<command>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</command>  <command></command> ", _xssDetectorParam.HtmlElementPatterns[9]) > 0);

            // -	<embed>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</embed>  <embed></embed> ", _xssDetectorParam.HtmlElementPatterns[10]) > 0);

            // -	<form>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</form>  <form></form> ", _xssDetectorParam.HtmlElementPatterns[11]) > 0);

            // -	<html>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</html>  <html>DFGDG</html> ", _xssDetectorParam.HtmlElementPatterns[12]) > 0);

            // -	<iframe>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</iframe>  <iframe></iframe> ", _xssDetectorParam.HtmlElementPatterns[13]) > 0);

            // -	<img>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <img></img> ", _xssDetectorParam.HtmlElementPatterns[14]) > 0);

            // -	<input>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <input></input> ", _xssDetectorParam.HtmlElementPatterns[15]) > 0);

            // -	<keygen>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <keygen></keygen> ", _xssDetectorParam.HtmlElementPatterns[16]) > 0);

            // -	<link>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <link></link> ", _xssDetectorParam.HtmlElementPatterns[17]) > 0);

            // -	<meta>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <meta></meta> ", _xssDetectorParam.HtmlElementPatterns[18]) > 0);

            // -	<object>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <object></object> ", _xssDetectorParam.HtmlElementPatterns[19]) > 0);

            // -	<script>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <script></script> ", _xssDetectorParam.HtmlElementPatterns[20]) > 0);

            // -	<source>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <source></source> ", _xssDetectorParam.HtmlElementPatterns[21]) > 0);

            // -	<video>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <video></video> ", _xssDetectorParam.HtmlElementPatterns[22]) > 0);
        }

         /// <summary>
        /// Test of detections of HTML events
        /// </summary>
        [TestMethod]
        public void HtmlEventsTest()
         {
             // 1.	Form events attributes:
             // -	onblur
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onblur = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[0]) > 0);
             // -	onchange
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onchange = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[1]) > 0);
             // -	oncontextmenu
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj oncontextmenu = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[2]) > 0);
             // -	onfocus
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onfocus = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[3]) > 0);
             // -	onformchange
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onformchange = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[4]) > 0);
             // -	onforminput
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onforminput = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[5]) > 0);
             // -	oninput
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj oninput = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[6]) > 0);
             // -	oninvalid
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj oninvalid = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[7]) > 0);
             // -	onreset
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onreset = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[8]) > 0);
             // -	onselect
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onselect = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[9]) > 0);
             // -	onsubmit
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onsubmit = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[10]) > 0);

             // 2.	Keyboard events attributes:
             // -	onkeydown
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onkeydown = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[11]) > 0);
             // -	onkeypress
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onkeypress = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[12]) > 0);
             // -	onkeyup
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onkeyup = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[13]) > 0);

             // 3.	Mouse events:
             // -	onclick
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onclick = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[14]) > 0);
             // -	ondblclick
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondblclick = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[15]) > 0);
             // -	ondrag
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondrag = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[16]) > 0);
             // -	ondragend
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragend = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[17]) > 0);
             // -	ondragenter
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragenter = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[18]) > 0);
             // -	ondragleave
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragleave = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[19]) > 0);
             // -	ondragover
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragover = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[20]) > 0);
             // -	ondragstart
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragstart = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[21]) > 0);
             // -	ondrop
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondrop = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[22]) > 0);
             // -	onmousedown
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmousedown = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[23]) > 0);
             // -	onmousemove
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmousemove = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[24]) > 0);
             // -	onmouseout
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmouseout = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[25]) > 0);
             // -	onmouseover
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmouseover = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[26]) > 0);
             // -	onmouseup
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmouseup = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[27]) > 0);
             // -	onmousewheel
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmousewheel = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[28]) > 0);
             // -	onscroll
             Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onscroll = 'efdfssd' hjkyujy><b>Tsts</b></p>", _xssDetectorParam.HtmlEventNames[29]) > 0);
         }

        /// <summary>
        /// Test of detections of VBScript expressions (Positive)
        /// </summary>
        [TestMethod]
        public void VBScriptExpessionsTest_Positive()
        {
            // a.	function myFunction()..... end function
            Assert.IsTrue(AlgorithmIsMatch("Function myFunction()fname=1 End Function", _xssDetectorParam.VbScriptPatterns[0]) > 0);

            // b.1-1	CreateObject|GetObject|GetRef(...);
            Assert.IsTrue(AlgorithmIsMatch("CreateObject(string)", _xssDetectorParam.VbScriptPatterns[1]) > 0);

            // b.1-2	CreateObject|GetObject|GetRef(...);
            Assert.IsTrue(AlgorithmIsMatch("GetObject(string)", _xssDetectorParam.VbScriptPatterns[1]) > 0);

            // b.1-3	CreateObject|GetObject|GetRef(...);
            Assert.IsTrue(AlgorithmIsMatch("GetRef(string)", _xssDetectorParam.VbScriptPatterns[1]) > 0);

            // b.2	CreateObject(...);
            Assert.IsTrue(AlgorithmIsMatch("CreateObject(\"q1\")", _xssDetectorParam.VbScriptPatterns[1]) > 0);

            // c.1-1	eval|TypeName|VarType(...);
            Assert.IsTrue(AlgorithmIsMatch("eval(string)", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // c.1-2	eval|TypeName|VarType(...);
            Assert.IsTrue(AlgorithmIsMatch("TypeName(string)", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // c.1-3	eval|TypeName|VarType(...);
            Assert.IsTrue(AlgorithmIsMatch("VarType(string)", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // c.2	eval(...);
            Assert.IsTrue(AlgorithmIsMatch("eval(\"t\")", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // d.1-1	InputBox|LoadPicture|MsgBox(...);
            Assert.IsTrue(AlgorithmIsMatch("InputBox(string)", _xssDetectorParam.VbScriptPatterns[3]) > 0);

            // d.1-2	InputBox|LoadPicture|MsgBox(...);
            Assert.IsTrue(AlgorithmIsMatch("LoadPicture(string)", _xssDetectorParam.VbScriptPatterns[3]) > 0);

            // d.1-3	InputBox|LoadPicture|MsgBox(...);
            Assert.IsTrue(AlgorithmIsMatch("MsgBox(string)", _xssDetectorParam.VbScriptPatterns[3]) > 0);

            // e.1-1	ScriptEngine|ScriptEngineBuildVersion|ScriptEngineMajorVersion|ScriptEngineMinorVersion
            Assert.IsTrue(AlgorithmIsMatch("t = ScriptEngine", _xssDetectorParam.VbScriptPatterns[4]) > 0);

            // e.1-2	ScriptEngine|ScriptEngineBuildVersion|ScriptEngineMajorVersion|ScriptEngineMinorVersion
            Assert.IsTrue(AlgorithmIsMatch("t = ScriptEngineBuildVersion", _xssDetectorParam.VbScriptPatterns[4]) > 0);

            // e.1-3	ScriptEngine|ScriptEngineBuildVersion|ScriptEngineMajorVersion|ScriptEngineMinorVersion
            Assert.IsTrue(AlgorithmIsMatch("t = ScriptEngineMajorVersion", _xssDetectorParam.VbScriptPatterns[4]) > 0);

            // e.1-4	ScriptEngine|ScriptEngineBuildVersion|ScriptEngineMajorVersion|ScriptEngineMinorVersion
            Assert.IsTrue(AlgorithmIsMatch("t = ScriptEngineMinorVersion", _xssDetectorParam.VbScriptPatterns[4]) > 0);
        }

        /// <summary>
        /// Test of detections of VBScript expressions (Negative)
        /// </summary>
        [TestMethod]
        public void VBScriptExpessionsTest_Negative()
        {
            // a.	function myFunction()..... end function
            Assert.IsFalse(AlgorithmIsMatch("Function myFunction()fname=1 End", _xssDetectorParam.VbScriptPatterns[0]) > 0);

            // b.1	CreateObject(...);
            Assert.IsFalse(AlgorithmIsMatch("CreateObject(\"rt')", _xssDetectorParam.VbScriptPatterns[1]) > 0);

            // b.2	CreateObject(...);
            Assert.IsFalse(AlgorithmIsMatch("CreateObject(\"\")", _xssDetectorParam.VbScriptPatterns[1]) > 0);

            // c.1	eval(...);
            Assert.IsFalse(AlgorithmIsMatch("eval(\"ii')", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // c.2	eval(...);
            Assert.IsFalse(AlgorithmIsMatch("eval(\"\")", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // c.	GetObject(...);
            Assert.IsFalse(AlgorithmIsMatch("GetObject('ii')", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // c.	GetRef(...);
            Assert.IsFalse(AlgorithmIsMatch("GetRef(\"ny)", _xssDetectorParam.VbScriptPatterns[2]) > 0);

            // d	InputBox(...);
            Assert.IsFalse(AlgorithmIsMatch("InputBox(\"ii\')", _xssDetectorParam.VbScriptPatterns[3]) > 0);
        }

        private static string inputStr =
            "fhgkjfdhglfhljfjgjkkdhfgjkb dfhg dhg d gjhgklg 436857 der6 bdfsdf hgdjj 5436895 e erhigjiojghiof 435 84964 ekgjhf  546890564   terikgrthj   56849065 9 egge jro her < yitgyui > yuoiuyuoyoiuyuioy 93842-5843 gkj ;gdjfsb09hrtp0w94giobjicuj gwu8jgbifdu 4893q5tugbio jioup0u <p rjhjhj onscroll = 'efdfssd' hjkyujy><b>Tsts</b></p>";

        [TestMethod]
        public void HtmlEventsTest_ComparePerformance()
        {
            DateTime[] timeArrayRegex = new DateTime[2];
            DateTime[] timeOneRegex = new DateTime[2];

            // FIRST TEST
            bool find = false;
            timeArrayRegex[0] = DateTime.Now;
            Console.WriteLine("Start array paterns event : " + timeArrayRegex[0].ToString("hh:mm:ss.ffff"));
            foreach (var pair in _xssDetectorParam.HtmlEventNames)
            {
                if (AlgorithmIsMatch(inputStr, pair) > 0)
                 {
                     find = true;
                     break;
                 }
            }
            Assert.IsTrue(find);
            timeArrayRegex[1] = DateTime.Now;
            Console.WriteLine("Stop : " + timeArrayRegex[1].ToString("hh:mm:ss.ffff"));

            // SECOND TEST
            timeOneRegex[0] = DateTime.Now;
            Console.WriteLine("Start ONE patern event : " + timeOneRegex[0].ToString("hh:mm:ss.ffff"));
            Assert.IsTrue(AlgorithmIsMatch(inputStr, _onePaternEvent) > 0);
            timeOneRegex[1] = DateTime.Now;
            Console.WriteLine("Stop : " + timeOneRegex[1].ToString("hh:mm:ss.ffff"));


            // Summery testing info
            Console.WriteLine("Time difference for array of patterns : " + (timeArrayRegex[1] - timeArrayRegex[0]));
            Console.WriteLine("Time difference for ONE pattern : " + (timeOneRegex[1] - timeOneRegex[0]));
            Console.WriteLine("TOTAL Time difference : " + ((timeArrayRegex[1] - timeArrayRegex[0]).TotalMilliseconds / (timeOneRegex[1] - timeOneRegex[0]).TotalMilliseconds));

        }

        
    }
}

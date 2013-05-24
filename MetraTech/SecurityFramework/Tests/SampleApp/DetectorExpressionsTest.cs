using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Detector.Engine;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SampleApp
{
    public class DetectorExpressionsTest
    {
        private SimpleXssDetectorPropertiesAdapted xssDetectorParam = null;

        public DetectorExpressionsTest()
        {
            var xssDetector = new SimpleXssDetectorPropertiesConfigured();
			xssDetectorParam = null;// new SimpleXssDetectorPropertiesAdapted(xssDetector.XssEngineParams);
        }

        private static int AlgorithmIsMatch(string input, PatternWeightRegex pattern)
        {
            int result = 0;
            if (pattern.Pattern.IsMatch(input))
                result += pattern.Weight;
            return result;
        }

        public void HtmlTagsTest()
        {
            // -	Comments (<!--    );
            Assert.IsTrue(AlgorithmIsMatch("<p>Tsts<\\p><!--<b><\\b>-->", xssDetectorParam.HtmlElementPatterns[0]) > 0);

            // -	<a>...</a>
            Assert.IsTrue(AlgorithmIsMatch("<a href=\"www.w3schools.com\">Visit W3Schools.com!</a>", xssDetectorParam.HtmlElementPatterns[1]) > 0);

            // -	<aplet>...</aplet>
            Assert.IsTrue(AlgorithmIsMatch("The <applet >tet</applet> tag is not supported in HTML 5. Use the <object> tag instead.", xssDetectorParam.HtmlElementPatterns[2]) > 0);

            // -	<area />
            Assert.IsTrue(AlgorithmIsMatch("<area shape=\"rect\" coords=\"0,0,82,126\" href=\"sun.htm\" alt=\"Sun\" />", xssDetectorParam.HtmlElementPatterns[3]) > 0);
            // -	<area>...</area> (part2)
            Assert.IsTrue(AlgorithmIsMatch("<area shape=\"rect\" coords=\"0,0,82,126\" href=\"sun.htm\" alt=\"Sun\" ></area>", xssDetectorParam.HtmlElementPatterns[3]) > 0);

            // -	<audio>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p><!--<audio>gug</audio>-->", xssDetectorParam.HtmlElementPatterns[4]) > 0);

            // -	<base>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p> <base></base>", xssDetectorParam.HtmlElementPatterns[5]) > 0);

            // -	<blockquote>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p> <blockquote> </blockquote> ", xssDetectorParam.HtmlElementPatterns[6]) > 0);

            // -	<body>;  
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p> <body> </body> ", xssDetectorParam.HtmlElementPatterns[7]) > 0);

            // -	<button>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p><button></button>", xssDetectorParam.HtmlElementPatterns[8]) > 0);

            // -	<command>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</command>  <command></command> ", xssDetectorParam.HtmlElementPatterns[9]) > 0);

            // -	<embed>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</embed>  <embed></embed> ", xssDetectorParam.HtmlElementPatterns[10]) > 0);

            // -	<form>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</form>  <form></form> ", xssDetectorParam.HtmlElementPatterns[11]) > 0);

            // -	<html>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</html>  <html>DFGDG</html> ", xssDetectorParam.HtmlElementPatterns[12]) > 0);

            // -	<iframe>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</iframe>  <iframe></iframe> ", xssDetectorParam.HtmlElementPatterns[13]) > 0);

            // -	<img>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <img></img> ", xssDetectorParam.HtmlElementPatterns[14]) > 0);

            // -	<input>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <input></input> ", xssDetectorParam.HtmlElementPatterns[15]) > 0);

            // -	<keygen>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <keygen></keygen> ", xssDetectorParam.HtmlElementPatterns[16]) > 0);

            // -	<link>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <link></link> ", xssDetectorParam.HtmlElementPatterns[17]) > 0);

            // -	<meta>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <meta></meta> ", xssDetectorParam.HtmlElementPatterns[18]) > 0);

            // -	<object>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <object></object> ", xssDetectorParam.HtmlElementPatterns[19]) > 0);

            // -	<script>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <script></script> ", xssDetectorParam.HtmlElementPatterns[20]) > 0);

            // -	<source>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <source></source> ", xssDetectorParam.HtmlElementPatterns[21]) > 0);

            // -	<video>;
            Assert.IsTrue(AlgorithmIsMatch(@"<p>Tsts</p>  <video></video> ", xssDetectorParam.HtmlElementPatterns[22]) > 0);
        }

        public void HtmlEventsTest()
        {
            // 1.	Form events attributes:
            // -	onblur
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onblur = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[0]) > 0);
            // -	onchange
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onchange = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[1]) > 0);
            // -	oncontextmenu
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj oncontextmenu = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[2]) > 0);
            // -	onfocus
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onfocus = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[3]) > 0);
            // -	onformchange
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onformchange = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[4]) > 0);
            // -	onforminput
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onforminput = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[5]) > 0);
            // -	oninput
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj oninput = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[6]) > 0);
            // -	oninvalid
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj oninvalid = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[7]) > 0);
            // -	onreset
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onreset = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[8]) > 0);
            // -	onselect
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onselect = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[9]) > 0);
            // -	onsubmit
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onsubmit = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[10]) > 0);

            // 2.	Keyboard events attributes:
            // -	onkeydown
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onkeydown = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[11]) > 0);
            // -	onkeypress
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onkeypress = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[12]) > 0);
            // -	onkeyup
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onkeyup = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[13]) > 0);

            // 3.	Mouse events:
            // -	onclick
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onclick = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[14]) > 0);
            // -	ondblclick
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondblclick = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[15]) > 0);
            // -	ondrag
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondrag = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[16]) > 0);
            // -	ondragend
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragend = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[17]) > 0);
            // -	ondragenter
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragenter = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[18]) > 0);
            // -	ondragleave
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragleave = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[19]) > 0);
            // -	ondragover
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragover = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[20]) > 0);
            // -	ondragstart
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondragstart = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[21]) > 0);
            // -	ondrop
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj ondrop = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[22]) > 0);
            // -	onmousedown
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmousedown = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[23]) > 0);
            // -	onmousemove
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmousemove = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[24]) > 0);
            // -	onmouseout
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmouseout = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[25]) > 0);
            // -	onmouseover
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmouseover = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[26]) > 0);
            // -	onmouseup
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmouseup = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[27]) > 0);
            // -	onmousewheel
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onmousewheel = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[28]) > 0);
            // -	onscroll
            Assert.IsTrue(AlgorithmIsMatch("<p rjhjhj onscroll = 'efdfssd' hjkyujy><b>Tsts</b></p>", xssDetectorParam.HtmlEventNames[29]) > 0);
        }
    }
}

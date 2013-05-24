/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Detector;


namespace MetraTech.SecurityFramework
{
    internal sealed class DefaultXssDetectorEngine : DetectorEngineBase
    {
        private long mScoreThreshod = 3;
        private long mTotalScore = 0; 
        private StringMatcher mScreener = new StringMatcher();
        private StringMatcher mPhaseOneMatcher = new StringMatcher();
        private PatternMatcher mMatcher = new PatternMatcher();

        public DefaultXssDetectorEngine()
            : base(DetectorEngineCategory.Xss)
		{
		}

        public override void Initialize()
        {
            //Initial version uses a hardcoded list if strings
            //Future versions will load the list from the engine properties file

            string[] keywords = 
            { 
                "<script>alert()</script>",
                "<script>alert(0)</script>",
                "<script>alert(document.cookie)</script>",
                "<script>alert('xss')</script>",
                "<<SCRIPT>alert(\"XSS\");//<</SCRIPT>",
                "<SCRIPT>alert(/XSS/.source)</SCRIPT>",
                "<script>prompt()</script>",
                "<script>prompt(0)</script>",
                "<script>prompt(document.cookie)</script>",
                "<script>prompt('xss')</script>",
                "<<SCRIPT>prompt(\"XSS\");//<</SCRIPT>",
                "<SCRIPT>prompt(/XSS/.source)</SCRIPT>",
                "'';!--\"<XSS>=&{()}", 
                "<IMG SRC=\"javascript:alert('XSS');\">", 
                "<IMG SRC=javascript:alert('XSS')>", 
                "<IMG SRC=javascript:alert(&quot;XSS&quot;)>",
                "<IMG \"\"\"><SCRIPT>alert(\"XSS\")</SCRIPT>\">",
                "<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>",
                "<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>",
                "<IMG SRC=\"jav&#x09;ascript:alert('XSS');\">",
                "<IMG SRC=\"jav&#x0A;ascript:alert('XSS');\">",
                "<IMG SRC=\"jav&#x0D;ascript:alert('XSS');\">",
                "';alert(String.fromCharCode(88,83,83))//\\';alert(String.fromCharCode(88,83,83))//\";alert(String.fromCharCode(88,83,83))//\\\";alert(String.fromCharCode(88,83,83))//--></SCRIPT>\">'><SCRIPT>alert(String.fromCharCode(88,83,83))</SCRIPT>",
                "<IMG SRC=&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041>",
                "<IMG SRC=&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>",            
                "<IMG SRC=jav\tascript:alert('XSS');>",
                "<IMG\nSRC\n=\n\"\nj\na\nv\na\ns\nc\nr\ni\np\nt\n:\na\nl\ne\nr\nt\n(\n'\nX\nS\nS\n'\n)\n\"\n>",
                "<IMG SRC=java\0script:alert(\"XSS\")>",
                "<SCR\0IPT>alert(\"XSS\")</SCR\0IPT>",
                "<IMG SRC=\" &#14;  javascript:alert('XSS');\">",
                "<BODY onload!#$%&()*~+-_.,:;?@[/|\\]^`=alert(\"XSS\")>",
                "<IMG SRC=\"javascript:alert('XSS')\"",
                "<INPUT TYPE=\"IMAGE\" SRC=\"javascript:alert('XSS');\">",
                "<BODY BACKGROUND=\"javascript:alert('XSS')\">",
                "<BODY ONLOAD=alert('XSS')>",
                "<IMG DYNSRC=\"javascript:alert('XSS')\"",
                "<IMG LOWSRC=\"javascript:alert('XSS')\">",
                "<BGSOUND SRC=\"javascript:alert('XSS');\">",
                "<BR SIZE=\"&{alert('XSS')}\">",
                "<LINK REL=\"stylesheet\" HREF=\"javascript:alert('XSS');\">",
                "<XSS STYLE=\"behavior: url(xss.htc);\">",
                "<STYLE>li {list-style-image: url(\"javascript:alert('XSS')\");}</STYLE><UL><LI>",
                "<IMG SRC='vbscript:msgbox(\"XSS\")'>",
                "žscriptualert(EXSSE)ž/scriptu",
                "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0;url=javascript:alert('XSS');\">",
                "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0;url=data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K\">",
                "<META HTTP-EQUIV=\"refresh\" CONTENT=\"0; URL=http://;URL=javascript:alert('XSS');\">",
                "<IFRAME SRC=\"javascript:alert('XSS');\"></IFRAME>",
                "<FRAMESET><FRAME SRC=\"javascript:alert('XSS');\"></FRAMESET>",
                "<TABLE BACKGROUND=\"javascript:alert('XSS')\">",
                "<TABLE><TD BACKGROUND=\"javascript:alert('XSS')\">",
                "<DIV STYLE=\"background-image: url(javascript:alert('XSS'))\">",
                "<DIV STYLE=\"background-image:\0075\0072\006C\0028'\006a\0061\0076\0061\0073\0063\0072\0069\0070\0074\003a\0061\006c\0065\0072\0074\0028.1027\0058.1053\0053\0027\0029'\0029\">",
                "<DIV STYLE=\"background-image: url(&#1;javascript:alert('XSS'))\">",
                "<DIV STYLE=\"width: expression(alert('XSS'));\">",
                "<STYLE>@im\\port'\\ja\\vasc\\ript:alert(\"XSS\")';</STYLE>",
                "<IMG STYLE=\"xss:expr/*XSS*/ession(alert('XSS'))\">",
                "<XSS STYLE=\"xss:expression(alert('XSS'))\">",
                "<STYLE TYPE=\"text/javascript\">alert('XSS');</STYLE>",
                "<STYLE>.XSS{background-image:url(\"javascript:alert('XSS')\");}</STYLE><A CLASS=XSS></A>",
                "<STYLE type=\"text/css\">BODY{background:url(\"javascript:alert('XSS')\")}</STYLE>",
                "<BASE HREF=\"javascript:alert('XSS');//\">",
                "<OBJECT classid=clsid:ae24fdae-03c6-11d1-8b76-0080c744f389><param name=url value=javascript:alert('XSS')></OBJECT>",
                "<META HTTP-EQUIV=\"Set-Cookie\" Content=\"USERID=&lt;SCRIPT&gt;alert('XSS')&lt;/SCRIPT&gt;\">",
                "<HEAD><META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=UTF-7\"> </HEAD>+ADw-SCRIPT+AD4-alert('XSS');+ADw-/SCRIPT+AD4-"
            };

            mScreener.Keywords = keywords;

            string[] p1mKeywords = 
            { 
            "jscript",
            "onsubmit",
            "copyparentfolder",
            "javascript",
            "meta",
            "onchange",
            "onmove",
            "onkeydown",
            "onkeyup",
            "activexobject",
            "onerror",
            "onmouseup",
            "ecmascript",
            "bexpression",
            "onmouseover",
            "vbscript:",
            "<![cdata[ http:",
            ".innerhtml",
            "settimeout",
            "shell:",
            "onabort",
            "asfunction:",
            "onkeypress",
            "onmousedown",
            "onclick",
            ".fromcharcode",
            "background-image:",
            ".cookie",
            "x-javascript",
            "ondragdrop",
            "onblur",
            "mocha:",
            "javascript:",
            "onfocus",
            "lowsrc",
            "getparentfolder",
            "onresize",
            "@import",
            "alert",
            "script",
            "onselect",
            "onmouseout",
            "application",
            "onmousemove",
            "background",
            ".execscript",
            "livescript:",
            "vbscript",
            "getspecialfolder",
            ".addimport",
            "iframe",
            "onunload",
            "createtextrange",
            "<input onload"
            };

            mPhaseOneMatcher.Keywords = p1mKeywords;

            Dictionary<string, string> patterns = new Dictionary<string, string>();

            patterns.Add("1",
                "(?:\\b(?:(?:type\\b\\W*?\\b(?:text\\b\\W*?\\b(?:j(?:ava)?|ecma|vb)|application\\b\\W*?\\bx-(?:java|vb))script|c(?:opyparentfolder|reatetextrange)|get(?:special|parent)folder|iframe\\b.{0,100}?\\bsrc)\\b|on(?:(?:mo(?:use(?:o(?:ver|ut)|down|move|up)|ve)|key(?:press|down|up)|c(?:hange|lick)|s(?:elec|ubmi)t|(?:un)?load|dragdrop|resize|focus|blur)\\b\\W*?=|abort\\b)|(?:l(?:owsrc\\b\\W*?\\b(?:(?:java|vb)script|shell|http)|ivescript)|(?:href|url)\\b\\W*?\\b(?:(?:java|vb)script|shell)|background-image|mocha):|s(?:(?:tyle\\b\\W*=.*\\bexpression\\b\\W*|ettimeout\\b\\W*?)\\(|rc\\b\\W*?\\b(?:(?:java|vb)script|shell|http):)|a(?:ctivexobject\\b|lert\\b\\W*?\\(|sfunction:))|<(?:(?:body\\b.*?\\b(?:backgroun|onloa)d|input\\b.*?\\btype\\b\\W*?\\bimage)\\b| ?(?:(?:script|meta)\\b|iframe)|!\\[cdata\\[)|(?:\\.(?:(?:execscrip|addimpor)t|(?:fromcharcod|cooki)e|innerhtml)|\\@import)\b)"
                );

            patterns.Add("2",
            "<(a|abbr|acronym|address|applet|area|audioscope|b|base|basefront|bdo|bgsound|big|blackface|blink|blockquote|body|bq|br|button|caption|center|cite|code|col|colgroup|comment|dd|del|dfn|dir|div|dl|dt|em|embed|fieldset|fn|font|form|frame|frameset|h1|head|hr|html|i|iframe|ilayer|img|input|ins|isindex|kdb|keygen|label|layer|legend|li|limittext|link|listing|map|marquee|menu|meta|multicol|nobr|noembed|noframes|noscript|nosmartquotes|object|ol|optgroup|option|p|param|plaintext|pre|q|rt|ruby|s|samp|script|select|server|shadow|sidebar|small|spacer|span|strike|strong|style|sub|sup|table|tbody|td|textarea|tfoot|th|thead|title|tr|tt|u|ul|var|wbr|xml|xmp)\\W"
            );

            patterns.Add("3",
            "\\bon(abort|blur|change|click|dblclick|dragdrop|error|focus|keydown|keypress|keyup|load|mousedown|mousemove|mouseout|mouseover|mouseup|move|readystatechange|reset|resize|select|submit|unload)\\b\\W*?="
            );

            patterns.Add("4",
            "application/x-shockwave-flash|image/svg\\+xml|text/(css|html|ecmascript|javascript|vbscript|x-(javascript|scriptlet|vbscript))"
            );

            patterns.Add("5", "(fromcharcode|alert|eval)\\s*\\(");

            patterns.Add("6",
            "background\\b\\W*?:\\W*?url|background-image\\b\\W*?:|behavior\\b\\W*?:\\W*?url|-moz-binding\\b|@import\\b|expression\\b\\W*?\\("
            );

            patterns.Add("7", "(88,83,83)");

            patterns.Add("8", "'';!--\"<xss>=&{()}");

            patterns.Add("9",
            "(?i:<style.*?>.*?((@[i\\\\])|(([:=]|(&[#\\(\\)=]x?0*((58)|(3A)|(61)|(3D));?)).*?([(\\\\\\\\]|(&[#()=]x?0*((40)|(28)|(92)|(5C));?)))))"
            );

            patterns.Add("10",
            "(?i:[ /+\\t\\\"\\'`]style[ /+\\t]*?=.*?([:=]|(&[#()=]x?0*((58)|(3A)|(61)|(3D));?)).*?([(\\\\\\\\]|(&[#()=]x?0*((40)|(28)|(92)|(5C));?)))"
            );

            patterns.Add("11", "(?i:<object[ /+\\t].*?((type)|(codetype)|(classid)|(code)|(data))[ /+\\t]*=)");

            patterns.Add("12", "(?i:<applet[ /+\\t].*?code[ /+\t]*=)");

            patterns.Add("13", "(?i:[ /+\\t\\\"\\'`]datasrc[ +\\t]*?=.)");

            patterns.Add("14", "(?i:<base[ /+\\t].*?href[ /+\\t]*=)");

            patterns.Add("15", "(?i:<link[ /+\\t].*?href[ /+\\t]*=)");

            patterns.Add("16", "(?i:<meta[ /+\\t].*?http-equiv[ /+\\t]*=)");

            patterns.Add("17", "(?i:<\\?import[ /+\\t].*?implementation[ /+\\t]*=)");

            patterns.Add("18", "(?i:<embed[ /+\\t].*?SRC.*?=)");

            patterns.Add("20", "(?i:<.*[:]vmlframe.*?[ /+\\t]*?src[ /+\\t]*=)");

            patterns.Add("21", "(?i:<[i]?frame.*?[ /+\\t]*?src[ /+\\t]*=)");

            patterns.Add("22", "(?i:<isindex[ /+\\t>])");

            patterns.Add("23", "(?i:<form.*?>)");

            patterns.Add("24", "(?i:<script.*?[ /+\\t]*?src[ /+\\t]*=)");

            patterns.Add("25", "(?i:<script.*?>)");

            patterns.Add("26",
                "(?i:[\\\"\'][ ]*(([^a-z0-9~_:\\'\\\" ])|(in)).*?(((l|(\\\\\\\\u006C))(o|(\\\\\\\\u006F))(c|(\\\\\\\\u0063))(a|(\\\\\\\\u0061))(t|(\\\\\\\\u0074))(i|(\\\\\\\\u0069))(o|(\\\\\\\\u006F))(n|(\\\\\\\\u006E)))|((n|(\\\\\\\\u006E))(a|(\\\\\\\\u0061))(m|(\\\\\\\\u006D))(e|(\\\\\\\\u0065)))).*?=)"
                );

            patterns.Add("27", "(?i:[\\\"\\'][ ]*(([^a-z0-9~_:\\'\\\" ])|(in)).+?(([.].+?)|([\\[].*?[\\]].*?))=)");

            patterns.Add("28", "(?i:[\\\"\\'].*?\\[ ]*(([^a-z0-9~_:\\'\\\" ])|(in)).+?\\()");

            patterns.Add("29", "(?i:[\\\"\\'][ ]*(([^a-z0-9~_:\\'\\\" ])|(in)).+?\\(.*?\\))");

            mMatcher.SetSearchPatterns(patterns);

            mMatcher.Load();

			base.Initialize();

        }

        /// <summary>
        /// Detects XSS injections.
        /// </summary>
        /// <param name="input">A data to be checked for XSS injections.</param>
        /// <returns>Execution result.</returns>
        protected override ApiOutput DetectInternal(ApiInput input)
        {
            mTotalScore = 0;
            
            try
            {
                if (ScreenInput(input.ToString()))
                    throw new DetectorInputDataException(ExceptionId.Detector.General, Category, "XSS injection detect.");

                DetectEvasions(input.ToString(), false);

                string normalized = NormalizeInput(input.ToString());

                DetectEvasions(normalized, true);

                AnalyzeInput(normalized, input.ToString());

                if (FoundXss())
                    throw new DetectorInputDataException(ExceptionId.Detector.General, Category, "XSS injection detect.");
            }
            catch (DetectorInputDataException x)
            {
                throw x;
            }
            catch (Exception x)
            {
                string xmsg = x.Message;
            }

            ApiOutput result = new ApiOutput(input);
            return result;
        }

        private bool FoundXss()
        {
            if (mTotalScore >= mScoreThreshod)
                return true;

            return false;
        }

        private bool ScreenInput(string input)
        {
            if (mScreener.ContainsAny(input))
                return true;

            return false;
        }

        private void AnalyzeInput(string normalizedInput, string rawInput)
        {
            if (mPhaseOneMatcher.ContainsAny(normalizedInput))
            {
                mTotalScore++; 

                PatternMatchResult[] pmResults = mMatcher.MatchAll(normalizedInput);
                foreach (PatternMatchResult pmr in pmResults)
                {
                    mTotalScore += 1;
                }
            }
        }

        private string NormalizeInput(string input)
        {
            return input.ToLower();
        }

        private void DetectEvasions(string input,bool isNormalized)
        {
        }
    }
}

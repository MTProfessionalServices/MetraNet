using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Detector.Engine;

namespace MetraTech.SecurityFramework.Core.Detector.Engine
{
    /// <summary>
    /// This class used only for creating configuration for XSS Detector. 
    /// </summary>
    /// <remarks>Warning! All new expressions should be adede to end of list. 
    ///         Otherwise the tests will work with the errors!
    /// </remarks>
    public class SimpleXssDetectorPropertiesConfigured
    {
        public SimpleXssDetectorPropertiesConfigured()
        {
            UpperLimitDetection = 100;
			DetectionParams = new GenericSimpleXssDetectorProperties<PatternWeight>();
			

            InitJavaScriptElementPatterns();
            InitDomElementPatterns();
            InitHtmlElementPatterns();
            InitHtmlElementPatterns();
            InitHtmlEventPatterns();
            InitSignsPatterns();
            InitVbScriptElementPatterns();
            ObfuscationCodepatterns();
        }

		public int UpperLimitDetection { get; private set; }

		public GenericSimpleXssDetectorProperties<PatternWeight> DetectionParams { get; private set; }

        private void InitJavaScriptElementPatterns()
        {
            DetectionParams.JavaScriptElementPatterns = new PatternWeight[]
                                                         {
                                                             new PatternWeight{Pattern = @"\bdecodeURI\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bdecodeURIComponent\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bencodeURI\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bencodeURIComponent\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bescape\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\beval\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bisFinite\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bisNaN\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bNumber\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bparseFloat\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bparseInt\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bString\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                             , new PatternWeight{Pattern = @"\bunescape\s*\(\s*[\w\""\'](?:.+?)\s*\)", Weight = 100}
                                                         };
        }

        private void InitDomElementPatterns()
        {
            DetectionParams.DomElementPatterns = new PatternWeight[]
                                                  {
                                                      new PatternWeight{Pattern = @"(?i:\bdocument\s*\.\s*write\s*\(\s*[\w\""\'](?:.+?)\s*\))", Weight = 100}
                                                    , new PatternWeight{Pattern = @"(?i:\bdocument\s*\.\s*open\s*\(\s*[\w\""\'](?:.+?)\s*\))", Weight = 100}
                                                    , new PatternWeight{Pattern = @"(?i:\balert\s*\(\s*(?:.+?)\s*\))", Weight = 100}
                                                    , new PatternWeight{Pattern = @"(?i:\bgetElementById\s*\(\s*[\w\""\'](?:.+?)\s*\))", Weight = 100}
                                                    , new PatternWeight{Pattern = @"(?i:\bcreatePopup\s*\(\s*\))", Weight = 100}
                                                    , new PatternWeight{Pattern = @"(?i:\bscrollBy\s*\(\s*[\w\""\'](?:.+?)\s*,\s*[\w\""\'](?:.+?)\s*\))", Weight = 100}
                                                    , new PatternWeight{Pattern = @"(?i:\blocation\s*\.\s*assign\s*\(\s*[\w\""\'](?:.+?)\s*\))", Weight = 100}
                                                  };
        }

        private void InitHtmlElementPatterns()
        {
           DetectionParams.HtmlElementPatterns = new PatternWeight[]
                                                   {
                                                       new PatternWeight{Pattern = @"\<!--", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*a\b\s*.+?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*applet\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*area\b\s*.*\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*audio\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*base\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*blockquote\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*body\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*button\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*command\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*embed\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*form\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*html\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*iframe\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*img\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*input\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*keygen\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*link\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*meta\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*object\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*script\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*source\b\s*.*?\s*\>)", Weight = 100}
                                                     , new PatternWeight{Pattern = @"(?i:\<\s*video\b\s*.*?\s*\>)", Weight = 100}
                                                     ,  new PatternWeight{Pattern = @"\<%", Weight = 100}
                                                     //, new PatternWeight{Pattern = @"(?i:\<\s*{}\b\s*.*?(?:/\s*\>|\>.*?\<\s*/\s*{}\s*\>))", Weight = 100}
                                                     //, new PatternWeight{Pattern = @"(?i:\<\s*{}\b\s*.*?\>.+?\<\s*/\s*{}\s*\>)", Weight = 100}
                                                   };
        }

        private void InitHtmlEventPatterns()
        {
           DetectionParams.HtmlEventNames = new PatternWeight[]
                                                 {
                                                     new PatternWeight{Pattern = @"onblur", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onchange", Weight = 100}
                                                     , new PatternWeight{Pattern = @"oncontextmenu", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onfocus", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onformchange", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onforminput", Weight = 100}
                                                     , new PatternWeight{Pattern = @"oninput", Weight = 100}
                                                     , new PatternWeight{Pattern = @"oninvalid", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onreset", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onselect", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onsubmit", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onkeydown", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onkeypress", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onkeyup", Weight = 100}
                                                     // 3.	Mouse events:
                                                     , new PatternWeight{Pattern = @"onclick", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondblclick", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondrag", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondragend", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondragenter", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondragleave", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondragover", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondragstart", Weight = 100}
                                                     , new PatternWeight{Pattern = @"ondrop", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onmousedown", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onmousemove", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onmouseout", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onmouseover", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onmouseup", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onmousewheel", Weight = 100}
                                                     , new PatternWeight{Pattern = @"onscroll", Weight = 100}};
        }

        private void InitSignsPatterns()
        {
           DetectionParams.SignsPatterns = new PatternWeight[] { };
        }

        private void InitVbScriptElementPatterns()
        {
            DetectionParams.VbScriptPatterns = new PatternWeight[]
                                                                {
                                                                    new PatternWeight{Pattern = @"(?i:\b(function|sub)\s*?\b[a-z][a-z0-9]*\b\s*?\(.*?\).+?\bend\b\s*?\1\b)", Weight = 100},
                                                                    new PatternWeight{Pattern = @"(?i:\b(?:CreateObject|GetObject|GetRef)\s*?\(\s*("")?\s*[a-z].*?(?(1)\1)\s*\))", Weight = 100},
                                                                    new PatternWeight{Pattern = @"(?i:\b(?:Eval|TypeName|VarType)\b\s*?\(\s*("")?\s*[a-z].*?(?(1)\1)\s*\))", Weight = 100},
                                                                    new PatternWeight{Pattern = @"(?i:\b(?:InputBox|LoadPicture|MsgBox)\s*?\(\s*("")?\s*[^""].*?(?(1)\1).*?\))", Weight = 100},
                                                                    new PatternWeight{Pattern = @"(?i:\bScriptEngine\b|\bScriptEngineBuildVersion\b|\bScriptEngineMajorVersion\b|\bScriptEngineMinorVersion\b)", Weight = 100},
                                                                       
                                                                };
        }

        #region Obfuscation code

        private void ObfuscationCodepatterns()
        {
            DetectionParams.ObfuscationPatterns = new PatternWeight[]
                                                      {
                                                          // x>=y?true:false
                                                          ShortExpressionIfThenElsePattern(),

                                                          // if( tt >= 2) y = 7; else y = 10
                                                          StandartExpressIfThenElse(),

                                                          // if( tt >= 2) y = 7;
                                                          StandartExpressIfThen(),

                                                          // x1=10
                                                          AssignmentOperator(),

                                                          new PatternWeight{Pattern = @"(?i:\bfunction\b\s*\(.+?\)\s*{.+?})", Weight = 10}, 
                                                      };
        }

        /// <summary>
        /// pattern witch found following expression 'x>=y?true:false'
        /// </summary>
        /// <returns></returns>
        private  static PatternWeight ShortExpressionIfThenElsePattern()
        {
            const string varName = "[A-Za-z0-9_.]+";
            const string operation = "[-+/*]";

            string varNameWord = String.Format(@"\s*\(*\s*[""']?\s*{0}\s*[""']?\s*\)*\s*", varName);
            string orVarNameWord = String.Format(@"{0}\s*\(*\s*[""']?\s*{1}\s*[""']?\s*\)*\s*", operation, varName);
            string regexPattern = String.Format(@"\({0}(?:{1})*\s*[<>]=?{0}(?:{1})*\?{0}(?:{1})*:{0}(?:{1})*\)", varNameWord, orVarNameWord);
            
            return new PatternWeight { Pattern = regexPattern, Weight = 100 };
        }

        /// <summary>
        /// pattern witch found following expression 'if( tt >= 2) y = 7; else y = 10'
        /// </summary>
        /// <returns></returns>
        private static PatternWeight StandartExpressIfThenElse()
        {
            const string varName = "[A-Za-z0-9_.]+";
            const string operation = "[-+/*]";

            string varNameWord = String.Format(@"\s*\(*\s*[""']?\s*{0}\s*[""']?\s*\)*\s*", varName);
            string orVarNameWord = String.Format(@"{0}\s*\(*\s*[""']?\s*{1}\s*[""']?\s*\)*\s*", operation, varName);

            string regexPattern = String.Format(@"(?im:(?:^|;|{{|}})\s*if\s*\(\s*{0}(?:{1})*\s*(:?[<>]=?\s*{0}(?:{1})*\s*)?\)\s*.+?\s*\belse\b\s*.+?)", varNameWord, orVarNameWord);

            return new PatternWeight { Pattern = regexPattern, Weight = 45 };
        }

        /// <summary>
        /// pattern witch found following expression 'if( tt >= 2) y = 7;'
        /// </summary>
        /// <returns></returns>
        private PatternWeight StandartExpressIfThen()
        {
            const string varName = "[A-Za-z0-9_.]+";
            const string operation = "[-+/*]";
            string varNameWord = String.Format(@"\s*\(*\s*[""']?\s*{0}\s*[""']?\s*\)*\s*", varName);
            string orVarNameWord = String.Format(@"{0}\s*\(*\s*[""']?\s*{1}\s*[""']?\s*\)*\s*", operation, varName);

            string regexPattern = String.Format(@"(?im:(?:^|;|{{|}})\s*if\s*\(\s*{0}(?:{1})*\s*(:?[<>]=?\s*{0}(?:{1})*\s*)?\)\s*.*?)", varNameWord, orVarNameWord);
            
            return new PatternWeight { Pattern = regexPattern, Weight = 35 };
        }

        /// <summary>
        /// pattern witch found following expression 'x1 = 10;'
        /// </summary>
        /// <returns></returns>
        private static PatternWeight AssignmentOperator()
        {
            const string varName = "[A-Za-z0-9_.]+";

            string varNameWord = String.Format(@"\s*\(*\s*[""']?\s*{0}\s*[""']?\s*\)*\s*", varName);
            string regexPattern = String.Format(@"(?m:(?:^|;|{{|}})\s*{0}\s*[-+/*]?=\s*\(*{1})", varName, varNameWord);

            return new PatternWeight { Pattern = regexPattern, Weight = 15 };
        }

        #endregion Obfuscation code
    }
}

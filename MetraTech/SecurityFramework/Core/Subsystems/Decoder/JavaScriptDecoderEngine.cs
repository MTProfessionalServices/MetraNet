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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.Decoder
{
    /// <summary>
    /// Provides decoder of javascript encoding sequence.
    /// </summary>
    internal sealed class JavaScriptDecoderEngine : DecoderTranslatorEngineBase
    {
        #region Constants

        /// <summary>
        /// Detections of Unicode code
        /// </summary>
        private const string RegexPattern = @"(?im:(?:\\(?<octal>[0-7]{1,3}))|(?<asciiOrUnicode>(?:\\u(?:\d|[ABCDEF]){2,4})|(?:\\x(?:\d|[ABCDEF]){2})))";
        //private const string RegexPattern = @"(?im:(?:(?:\\u(?<asciiOrUnicode>\d|[ABCDEF]){2,4})|(?:\\x(?<asciiOrUnicode>\d|[ABCDEF]){2})))";
        private const string AsciiOrUnicodeCodeGroupName = "asciiOrUnicode";
        private const string OctalCodeGroupName = "octal";

        #endregion

        #region Private fields

        private readonly Dictionary<string, string> _escapingSymbols = new Dictionary<string, string>()
                                                                           {
                                                                               {"\\\\", "\\"},
                                                                               {"\\'", "'"},
                                                                               {"\\\"", "\""},
                                                                               {"\\&", "&"},
                                                                               {"\\b", "\x08"},
                                                                               {"\\t", "\x09"},
                                                                               {"\\n", "\x0A"},
                                                                               {"\\v", "\x0B"},
                                                                               {"\\f", "\x0C"},
                                                                               {"\\r", "\x0D"},
                                                                           };
        #endregion Private fields

        #region Protected properties
        #endregion Protected properties

        #region Public properties
        #endregion Public properties

        #region Constructors

        /// <summary>
        /// Creates an instance of the <see cref="JavaScriptDecoderEngine"/> class.
        /// Sets an engine category to <see cref="DecoderEngineCategory"/>.JavaScript.
        /// </summary>
        public JavaScriptDecoderEngine()
            : base(DecoderEngineCategory.JavaScript)
        {}

        #endregion Constructors

        #region Public methods
        protected override ApiOutput DecodeInternal(ApiInput input)
        {
            string inputStr = input.ToString();
            foreach (KeyValuePair<string, string> escapingSymbol in _escapingSymbols)
            {
                inputStr = inputStr.Replace(escapingSymbol.Key, escapingSymbol.Value);
            }
            return base.DecodeInternal(inputStr);
        }

        #endregion Public methods

        #region Protected methods

        /// <summary>
        /// Gets a regular expression finding characters to translate.
        /// </summary>
        protected override string Expression
        {
            get
            {
                return RegexPattern;
            }
        }

        /// <summary>
        /// Translates a found special simbol or hex code to a corresponding character.
        /// </summary>
        /// <param name="token">A found entity.</param>
        /// <returns>A translated character.</returns>
        protected override string TranslateToken(Match token)
        {
            string result;            
            try
            {
                Group g = token.Groups[OctalCodeGroupName];

                if (g.Success)
                {
                    int decimalVal = Convert.ToInt32(g.Value, 8);

                    if (decimalVal > 127)
                    {
                        // remove one symbol from string in the right
                        decimalVal = Convert.ToInt32(g.Value.Substring(0, g.Value.Length - 1), 8);

                        result = GetUnicodeFromCode(decimalVal) + g.Value[g.Value.Length - 1];
                    }
                    else
                    {
                        result = GetUnicodeFromCode(decimalVal);
                    }

                    
                }
                else if ((g = token.Groups[AsciiOrUnicodeCodeGroupName]).Success)
                {
                    result = GetUnicodeFromCode(GetHexFromString(g.Value));
                    //result = GetUnicodeFromCode(Convert.ToInt32(g.Value, 16));
                }
                else
                {
                    throw new SubsystemInternalException(String.Format(
                            "{0} category: Regex pattern was success, but this coincidence was not proccessed. Regex is '{1}' ",
                            CategoryName, token));
                }
               
            }
            catch (OverflowException)
            {
                // Some codes don't correspond to any characters.
                result = token.Value;
            }

            return result;
        }
        #endregion Protected methods

        #region Private methods
        #endregion Private methods
    }
   
}

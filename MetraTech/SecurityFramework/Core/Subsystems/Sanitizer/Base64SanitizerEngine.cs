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


namespace MetraTech.SecurityFramework.Core.Sanitizer
{
    /// <summary>
    /// Try to detect Base64 sequences and decode it to string
    /// </summary>
    /// <remarks>Can decode input data of the form http://example.com/mail?redirect-after-login=data%3Atext/html%3Bbase64%2CPHNjcmlwdD4KYWxlcnQoJ1hTUycpOwo8L3NjcmlwdD4%3D
    /// The document about format of hidine base64 sequence could be read <see cref="http://en.wikipedia.org/wiki/Data_URI_scheme"/> or RFC document <see cref="http://tools.ietf.org/html/rfc2397"/></remarks>
    internal class Base64SanitizerEngine : SanitizerEngineBase
    {
        #region Constants

        #region Gets base64 chars from input data
        // permit chars for all versions of base64 encoding
        private const string Base64AlphabetCharsRegex = "[A-Za-z0-9+/_:\\-.!]{2,}={0,2}";
        private Regex _base64Regex = new Regex(String.Format("(?i:[;:](?<base64>\\s*\\bbase64,(?<base64Chars>{0})))", Base64AlphabetCharsRegex),
                                                RegexOptions.Compiled);

        private string Base64GroupName = "base64";
        private string Base64CharsGroupName = "base64Chars";
        #endregion Gets base64 chars from input data

        #endregion Constants

        private bool _isInitEngine = false;
        private IEngine _complexBase64 = null;

        public Base64SanitizerEngine()
            : base(SanitizerEngineCategory.Base64Sanitizer)
        { }

        /// <summary>
        /// Used in regex as minimum lengt of input string for BASE64 detection
        /// </summary>
        public string MinLengthBase64Sequence { get; set; }

        protected override ApiOutput SanitizeInternal(ApiInput input)
        {
            if (!_isInitEngine)
                Init();

            string replacedString = _base64Regex.Replace(input.ToString(), TranslateToken);
            return new ApiOutput(replacedString, input.Exceptions);
        }

        /// <summary>
        /// Translates a found Base64 sequence to a corresponding character.
        /// </summary>
        /// <param name="token">A found entity.</param>
        /// <returns>A translated character.</returns>
        protected string TranslateToken(Match token)
        {
            string result = null;

            try
            {
                if (token.Groups[Base64GroupName].Success)
                {
                    string base64Sequence = token.Groups[Base64CharsGroupName].Value;

                    try
                    {
                        result = _complexBase64.Execute(base64Sequence);
                    }
                    catch (Exception)
                    {
                        // TODO: loging need
                        result = token.Value;
                    }
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

        /// <summary>
        /// initialize engine
        /// </summary>
        protected void Init()
        {
            _complexBase64 = SecurityKernel.Decoder.Api.GetEngine("Base64.ComplexDecoder");
            _isInitEngine = true;
        }
    }
}

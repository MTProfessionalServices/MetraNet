using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace MetraTech.SecurityFramework.Core.Detector.Engine
{
    /// <summary>
    /// Try to detect Base64 encoding in input string.
    /// </summary>
    public class Base64Detector
    {
        /// <summary>
        /// Pattern for Base64 encoding.
        /// Fo more information <see cref="http://en.wikipedia.org/wiki/Base64"/>
        /// </summary>
        /// <remarks>This patterb shoul be cathed folowing encodings:
        ///     - MIME's Base64 last characters are = or ==
        ///     - IRCu last characters are 0 or 00
        ///     - Radix-64' encoding for OpenPGP (RFC 4880) last characters are + or +/
        ///     - Modified Base64 for filenames (non standard) last characters are + or +-
        ///     - Modified Base64 for URL applications ('base64url' encoding) last characters are - or -_
        ///     - Modified Base64 for XML name tokens (Nmtoken) last characters are . or .-
        ///     - Modified Base64 for XML identifiers (Name) last characters are _ or _:
        ///     - Modified Base64 for Program identifiers (variant 1, non standard) last characters are _ or _-
        ///     - Modified Base64 for Program identifiers (variant 2, non standard) last characters are . or ._
        ///     - Modified Base64 for Regular expressions (non standard) last characters are ! or !-
        /// </remarks>
        private const string Base64PatternBegin = "^[A-Za-z0-9+/_:\\-\\.!]{2,}={0,2}$";
       

        #region Check base64 chars for index 62 and for index 63
        private const string LastChars62and63Pattern = "(\\+)|(/)|(_)|(:)|(\\\\)|(-)|(\\.)|(!)";
        private Regex _regexCountCharsForLastIndexes = new Regex(LastChars62and63Pattern, RegexOptions.Compiled);
        #endregion Check base64 chars for index 62 and for index 63

        public Base64Detector()
        {
            Base64RegexPatternn = new Regex(Base64PatternBegin, RegexOptions.Multiline | RegexOptions.Compiled);
        }

        /// <summary>
        /// Gets regex for find Base64 sequence.
        /// </summary>
        public Regex Base64RegexPatternn { get; private set; }

        /// <summary>
        /// Enum type of Base64 versions 
        /// </summary>
        public enum Base64Version
        {
            NonBase64,
            Standart,  //Standard 'Base64' encoding for RFC 3548or RFC 4648; char62 = '+'; char63 = '/'
            ModifiedForFilenames, // Modified Base64 for filenames (non standard); char62 = '+'; char63 = '-' 
            ModifiedForURL, // Modified Base64 for URL applications; char62 = '-'; char63 = '_'
            ModifiedForXmlNmtoken, // Modified Base64 for XML name tokens (Nmtoken); char62 = '.'; char63 = '-'
            ModifiedForXmlName, // Modified Base64 for XML identifiers (Name); char62 = '_'; char63 = ':'
            ModifiedForProgramIdentifiersV1, // Modified Base64 for Program identifiers(variant 1, non standard); char62 = '_'; char63 = '-'
            ModifiedForProgramIdentifiersV2, // Modified Base64 for Program identifiers(variant 1, non standard); char62 = '.'; char63 = '_'
            ModifiedForRegularExpressions, // Modified Base64 for Regular expressions(non standard); char62 = '!'; char63 = '-'
        }

        /// <summary>
        /// Checks whether input data is Base64 encoding sequence or not.
        /// </summary>
        /// <param name="base64Sequence">A input string represented as Base64 sequence</param>
        /// <returns>true if input string is Base64</returns>
        public bool IsBase64(string base64Sequence)
        {
            IList<string> charsForLastIndexes;
            return IsBase64(base64Sequence, out charsForLastIndexes);
        }


        /// <summary>
        /// Get version of Base64 encoding sequence 
        /// </summary>
        /// <param name="base64Sequence">A input string represented as Base64 sequence</param>
        /// <returns>return enum <see cref="Base64Version"/></returns>
        public Base64Version GetBase64Version(string base64Sequence)
        {
            Base64Version result = Base64Version.NonBase64;

            IList<string> charsForLastIndexes;
            if(IsBase64(base64Sequence, out charsForLastIndexes))
            {
                // count using chars for 62 and 63 indexes
                switch (charsForLastIndexes.Count)
                {
                    case 0:
                        result = Base64Version.Standart;
                        break;
                    case 1:
                        if (charsForLastIndexes.Contains("+") || charsForLastIndexes.Contains("/"))
                            // but it may be ModifiedForFilenames Base64 version
                            result = Base64Version.Standart;

                        //TODO: Code is commented out, because impossible to determine exactly Base64 version
                        //else if (charsForLastIndexes.Contains("-"))
                        //    // but it may be ModifiedForFilenames Base64 version
                        //    // or ModifiedForURL Base64 version
                        //    // or ModifiedForXmlNmtoken Base64 version
                        //    // or ModifiedForProgramIdentofiersV1 Base64 version
                        //    // or ModifiedForRegularExpressions Base64 version
                        //    result = Base64Version.ModifiedForURL;

                        //TODO: Code is commented out, because impossible to determine exactly Base64 version
                        //else if (charsForLastIndexes.Contains("_"))
                        //    // but it may be ModifiedForXmlName Base64 version
                        //    // or ModifiedForProgramIdentofiersV1 Base64 version
                        //    // or ModifiedForProgramIdentofiersV2 Base64 version
                        //    result = Base64Version.ModifiedForURL;

                        else if (charsForLastIndexes.Contains(":"))
                            result = Base64Version.ModifiedForXmlName;

                        //TODO: Code is commented out, because impossible to determine exactly Base64 version
                        //else if (charsForLastIndexes.Contains("."))
                        //    // but it may be ModifiedForProgramIdentofiersV2 Base64 version
                        //    result = Base64Version.ModifiedForXmlNmtoken;

                        else if (charsForLastIndexes.Contains("!"))
                            result = Base64Version.ModifiedForRegularExpressions;
                        break;
                    case 2:
                        if (charsForLastIndexes.Contains("+") && charsForLastIndexes.Contains("/"))
                            result = Base64Version.Standart;

                        else if (charsForLastIndexes.Contains("+") && charsForLastIndexes.Contains("-"))
                            result = Base64Version.ModifiedForFilenames;

                        //TODO: Code is commented out, because impossible to determine exactly Base64 version
                        //else if (charsForLastIndexes.Contains("-") && charsForLastIndexes.Contains("_"))
                        //    result = Base64Version.ModifiedForURL;

                        else if (charsForLastIndexes.Contains(".") && charsForLastIndexes.Contains("-"))
                            result = Base64Version.ModifiedForXmlNmtoken;

                        else if (charsForLastIndexes.Contains("_") && charsForLastIndexes.Contains(":"))
                            result = Base64Version.ModifiedForXmlName;

                        //TODO: Code is commented out, because impossible to determine exactly Base64 version
                        //else if (charsForLastIndexes.Contains("_") && charsForLastIndexes.Contains("-"))
                        //    result = Base64Version.ModifiedForProgramIdentifiersV1;

                        else if (charsForLastIndexes.Contains(".") && charsForLastIndexes.Contains("_"))
                            result = Base64Version.ModifiedForProgramIdentifiersV2;

                        else if (charsForLastIndexes.Contains("!") && charsForLastIndexes.Contains("-"))
                            result = Base64Version.ModifiedForRegularExpressions;
                        break;
                }

               
            }

            return result;
        }

        private bool IsBase64(string base64Sequence, out IList<string> charsForLastIndexes)
        {
            bool result = false;
            charsForLastIndexes = new List<string>();

            if (base64Sequence.Length % 4 == 0 && Base64RegexPatternn.IsMatch(base64Sequence))
            {
                result = true;
                foreach (Match m in _regexCountCharsForLastIndexes.Matches(base64Sequence))
                {
                    if (m.Success && !charsForLastIndexes.Contains(m.Groups[0].Value))
                    {
                        charsForLastIndexes.Add(m.Groups[0].Value);
                        if (charsForLastIndexes.Count > 2)
                        {
                            result = false;
                            break;
                        }
                    }
                }
            }
            return result;
        }
    }
}

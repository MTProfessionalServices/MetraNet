using System;
using System.Text.RegularExpressions;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Collections;

namespace MetraTech.DomainModel.Common
{
    public class StringUtils
    {
        public static string UpperCaseFirst(string input)
        {
            if (String.IsNullOrEmpty(input))
            {
                return input;
            }

            Char[] letters = input.ToCharArray();
            letters[0] = Char.ToUpper(letters[0]);
            return new string(letters);
        }

        public static string LowerCaseFirst(string input)
        {
            if (String.IsNullOrEmpty(input))
            {
                return input;
            }

            Char[] letters = input.ToCharArray();
            letters[0] = Char.ToLower(letters[0]);
            return new string(letters);
        }

        /// <summary>
        ///   (1) Replace all non alpha-numeric characters from the input string with underscore.
        ///   (2) If the first letter is a digit, prefix with underscore. 
        ///       Otherwise, capitalize the first letter.
        /// 
        ///   Return the modified string.
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public static string MakeAlphaNumeric(string input)
        {
            string output = Regex.Replace(input, "[^A-Za-z0-9_]", "_");

            if (output.Length > 0)
            {
                // If first letter is a digit, prefix with _
                if (Char.IsDigit(output[0]))
                {
                    output = "_" + output;
                }
                else
                {
                    // capitalize first letter
                    output = UpperCaseFirst(output);
                }
            }

            return output;
        }

        public static bool ConvertToBoolean(string input)
        {
            if (String.IsNullOrEmpty(input))
            {
                throw new ArgumentException("A null or empty string cannot be converted to a boolean value.");
            }

            bool bResult = false;
            if (!booleanStrings.TryGetValue(input.Trim(), out bResult))
            {
                throw new ApplicationException(String.Format("Unable to convert the value '{0}' to a boolean", input));
            }

            return bResult;
        }

        public static bool TryConvertToBoolean(string input, out bool bResult)
        {
            bResult = false;

            if (String.IsNullOrEmpty(input))
            {
                return false;
            }

            return booleanStrings.TryGetValue(input.Trim(), out bResult);
        }

        public static string ConvertFromBoolean(bool value, string True, string False)
        {
            return (value == true ? True.Trim() : False.Trim());
        }

        public static string ConvertFromBoolean(bool value)
        {
            return (value == true ? "true" : "false");
        }

        static SortedList<string, bool> booleanStrings;
        static StringUtils()
        {
            booleanStrings = new SortedList<string, bool>(StringComparer.InvariantCultureIgnoreCase);
            booleanStrings.Add("0", false);
            booleanStrings.Add("false", false);
            booleanStrings.Add("f", false);
            booleanStrings.Add("no", false);
            booleanStrings.Add("n", false);

            booleanStrings.Add("1", true);
            booleanStrings.Add("true", true);
            booleanStrings.Add("t", true);
            booleanStrings.Add("yes", true);
            booleanStrings.Add("y", true);
        }

    }
}
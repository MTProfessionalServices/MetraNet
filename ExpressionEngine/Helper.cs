using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace MetraTech.ExpressionEngine
{
    public static class Helper
    {
        public static string CleanUpWhiteSpace(string strValue)
        {
            if (string.IsNullOrEmpty(strValue))
                return strValue;

            strValue = strValue.Trim();
            strValue = Regex.Replace(strValue, "[\t\r\n]", "");
            strValue = Regex.Replace(strValue, "[ ]+", " ");
            return strValue;
        }

        //
        //Deterimines if the parameter is even
        //
        public static bool IsEven(int num)
        {
            return (num % 2 == 0);
        }

        public static bool? ParseBool(string value)
        {
            if (string.IsNullOrEmpty(value))
                return null;

            value = value.ToLower();

            if (value.Equals("f") || value.Equals("false") || value.Equals("0") || value.Equals("no") || value.Equals("n"))
                return false;
            else if (value.Equals("t") || value.Equals("true") || value.Equals("1") || value.Equals("yes") || value.Equals("y"))
                return true;

            return null;
        }


        //
        //Convert the MANY variants of boolean strings in the metadata to bool
        //
        public static bool GetBool(string theString)
        {
            if (theString == null)
                throw new Exception("Null value passed to GetBool");

            theString = theString.ToUpper();

            if (theString == "Y" || theString == "YES" || theString == "T" || theString == "TRUE" || theString == "1")
                return true;
            else if (theString == "N" || theString == "NO" || theString == "F" || theString == "FALSE" || theString == "0")
                return false;
            else if (string.IsNullOrEmpty(theString))
                throw new ArgumentException("A boolean value must be specified");
            else
                throw new ArgumentException("Invalid boolean string [" + theString + "]");
        }

        //
        //Returns a random string of the specified length
        //
        public static string GetRandomString(Random random, int min, int max, bool lowerCase)
        {
            var size = random.Next(min, max);

            var builder = new StringBuilder();
            char ch;
            for (int i = 0; i < size; i++)
            {
                ch = Convert.ToChar(Convert.ToInt32(Math.Floor(26 * random.NextDouble() + 65)));
                builder.Append(ch);
            }

            if (lowerCase)
                return builder.ToString().ToLower();
            return builder.ToString();
        }

    }
}

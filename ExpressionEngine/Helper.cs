using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    public static class Helper
    {
        public static string CleanUpWhiteSpace(string value)
        {
            if (string.IsNullOrEmpty(value))
                return value;

            value = value.Trim();
            value = Regex.Replace(value, "[\t\r\n]", "");
            value = Regex.Replace(value, "[ ]+", " ");
            return value;
        }

        //
        //Deterimines if the parameter is even
        //
        public static bool IsEven(int number)
        {
            return (number % 2 == 0);
        }

        public static bool? ParseBool(string value)
        {
            if (string.IsNullOrEmpty(value))
                return null;

            value = value.ToLower(CultureInfo.InvariantCulture);

            if (value.Equals("f") || value.Equals("false") || value.Equals("0") || value.Equals("no") || value.Equals("n"))
                return false;
            else if (value.Equals("t") || value.Equals("true") || value.Equals("1") || value.Equals("yes") || value.Equals("y"))
                return true;

            return null;
        }


        //
        //Convert the MANY variants of boolean strings in the metadata to bool
        //
        public static bool GetBoolean(string value)
        {
            if (value == null)
                throw new ArgumentNullException("value");

            value = value.ToUpper(CultureInfo.InvariantCulture);

            if (value == "Y" || value == "YES" || value == "T" || value == "TRUE" || value == "1")
                return true;
            else if (value == "N" || value == "NO" || value == "F" || value == "FALSE" || value == "0")
                return false;
            else if (string.IsNullOrEmpty(value))
                throw new ArgumentException("A boolean value must be specified");
            else
                throw new ArgumentException("Invalid boolean string [" + value + "]");
        }

        //
        //Returns a random string of the specified length
        //
        public static string GetRandomString(Random random, int min, int max, bool lowercase)
        {
            if (random == null)
                throw new ArgumentNullException("random");

            var size = random.Next(min, max);

            var builder = new StringBuilder();
            char ch;
            for (int i = 0; i < size; i++)
            {
                ch = Convert.ToChar(Convert.ToInt32(Math.Floor(26 * random.NextDouble() + 65)));
                builder.Append(ch);
            }

            if (lowercase)
                return builder.ToString().ToLower(CultureInfo.InvariantCulture);
            return builder.ToString();
        }

    }
}

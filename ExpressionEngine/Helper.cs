using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;
using System.IO;

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


        //
        //Returns a random string of the specified length
        //
        public static string GetRandomString(Random random, int min, int max, bool lowercase)
        {
            if (random == null)
                throw new ArgumentNullException("random");

            var size = random.Next(min, max);

            var builder = new StringBuilder();
            for (int i = 0; i < size; i++)
            {
                var ch = Convert.ToChar(Convert.ToInt32(Math.Floor(26 * random.NextDouble() + 65)));
                builder.Append(ch);
            }

            if (lowercase)
                return builder.ToString().ToLower(CultureInfo.InvariantCulture);
            return builder.ToString();
        }



    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public static class EnumHelper
    {
        #region Methods
        public static bool NameSpaceExists(string _namespace)
        {
            return true;
        }

        public static bool TypeExists(string _namespace, string type)
        {
            return true;
        }
        public static bool ValueExists(string _namespace, string type, string value)
        {
            return true;
        }
        public static List<string> GetValues(string _namespace, string type)
        {
            return new List<string>();
        }

        public static bool IsValidValue(string _namespace, string type, string value)
        {
            return true;
        }

        public static string ConvertEnumRuntimeIntegerToEnumName(int enumValue)
        {
            throw new NotImplementedException();
        }

        public static string GetMetraNetEnumString(Int32 enumInt)
        {
            throw new NotImplementedException();
        }

        public static int GetMetraNetIntValue(DataTypeInfo dtInfo, string value)
        {
            return 555;
        }
        #endregion
    }
}

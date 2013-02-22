using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine
{
    public static class EnumHelper
    {
        #region Methods
        public static bool NamespaceExists(string enumSpace)
        {
            throw new NotImplementedException();
        }

        public static bool TypeExists(string enumSpace, string type)
        {
            throw new NotImplementedException();
        }
        public static bool ValueExists(string enumSpace, string type, string value)
        {
            throw new NotImplementedException();
        }
        public static Collection<string> GetValues(string enumSpace, string type)
        {
            throw new NotImplementedException();
        }

        public static bool IsValidValue(string enumSpace, string type, string value)
        {
            throw new NotImplementedException();
        }

        public static string ConvertEnumRuntimeIntegerToEnumName(int enumValue)
        {
            throw new NotImplementedException();
        }

        public static string GetMetraNetEnumString(Int32 enumId)
        {
            throw new NotImplementedException();
        }

        public static int GetMetraNetId(MtType type, string value)
        {
            throw new NotImplementedException(); 
        }
        #endregion
    }
}

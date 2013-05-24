//////////////////////////////////////////////////////////////////////////////
// This file was automatically generated using ICE.
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.Custom.Plugins.Subscription
{
    public static class Utility
    {
        public static string GetFQMethodName()
        {
            string @class = "ClassNotFound";
            string method = "MethodNotFound";

            try
            {
                System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace();
                System.Diagnostics.StackFrame sf = st.GetFrame(1);
                @class = sf.GetMethod().DeclaringType.Name;
                method = sf.GetMethod().Name;
            }
            catch (Exception)
            { }

            return @class + "." + method;
        }
    }
    public class Constants
    {
        public const int E_FAIL = -2147467259;
        public const int E_NOTIMPL = -2147467263;
    }
}

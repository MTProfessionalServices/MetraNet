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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System.Collections.Generic;

namespace MetraTech.SecurityFramework
{
    public static class ProcessorExtensions
    {
        public static object ProcessAsInput(this string str, string selectorId)
        {
            return null;
        }

        public static object ProcessAsInput(this string str, string selectorId, Dictionary<string, object> extraParams)
        {
            return null;
        }

        public static string ProcessAsInputString(this string str, string selectorId)
        {
            return string.Empty;
        }

        public static int ProcessAsInputInt(this string str, string selectorId)
        {
            return 0;
        }

        public static string ProcessAsOutput(this string str, string selectorId)
        {
            return string.Empty;
        }

        public static string ProcessAsOutput(this string str, string selectorId, Dictionary<string, object> extraParams)
        {
            return string.Empty;
        }

        public static object ProcessAsInputWithEngine(this string str, string engineId)
        {
            return null;
        }

        public static object ProcessAsInputWithEngine(this string str, string engineId, Dictionary<string, object> extraParams)
        {
            return null;
        }

        public static string ProcessAsInputStringWithEngine(this string str, string engineId)
        {
            return string.Empty;
        }

        public static int ProcessAsInputIntWithEngine(this string str, string engineId)
        {
            return 0;
        }

        public static string ProcessAsOutputWithEngine(this string str, string engineId)
        {
            return string.Empty;
        }

        public static string ProcessAsOutputWithEngine(this string str, string engineId, Dictionary<string, object> extraParams)
        {
            return string.Empty;
        }
    }
}


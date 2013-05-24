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

namespace MetraTech.SecurityFramework
{
    public static class DetectorExtensions
    {
        public static string Detect(this string str, string selectorId)
        {
            return string.Empty;
        }

        public static void DetectWithEngine(this string str, string engineId)
        {
        }

        public static void DetectSql(this string str)
        {
            SecurityKernel.Detector.Api.ExecuteDefaultByCategory(DetectorEngineCategory.Sql.ToString(), str); 
        }

        public static void DetectXss(this string str)
        {
            SecurityKernel.Detector.Api.ExecuteDefaultByCategory(DetectorEngineCategory.Xss.ToString(), str);
        }

        public static void DetectOsShellCmd(this string str)
        {
        }

        public static void DetectOsShellOutput(this string str)
        {
        }

        public static void DetectOsShellcode(this string str)
        {
        }

        public static string DetectEncoding(this string str)
        {
            return string.Empty;
        }

        public static string DetectAll(this string str)
        {
            return string.Empty;
        }

        public static void DetectBad(this string str)
        {
            //KCQ:
            //HARDCODED TO DO SQL DETECTION, SO CORE DEV CAN USE THIS MORE GENERIC API
            DetectSql(str);
            DetectXss(str);
        }
    }
}


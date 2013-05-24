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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace MetraTech.SecurityFramework
{
    public static class RandomObjectGeneratorExtensions
    {
        public static string Random(this string str, int size, string charset, int seed)
        {
            return string.Empty;
        }

        public static string GuidString(this string str)
        {
            return string.Empty;
        }

        public static byte[] RandomBytes(this object obj, int size, int seed)
        {
            return null;
        }

        public static int Random(this int obj, int min, int max)
        {
            return 0;
        }

        public static long Random(this long obj, long min, long max)
        {
            return 0;
        }

        public static double Random(this double obj, double min, double max)
        {
            return 0.0;
        }
    }
}

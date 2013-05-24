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
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Contains utility methods to work with text data.
    /// </summary>
    internal static class StringHelper
    {
        /// <summary>
        /// Removes starting and ending quotes if any.
        /// </summary>
        /// <param name="value">The data to remove the quotes from</param>
        /// <param name="quotChar">Indicates the quote character to look for.</param>
        /// <returns>Dequoted text if quotes were found at the start and end of it and the initial <paramref name="value"/> otherwise.</returns>
        internal static string DequotString(string value, string quotChar)
        {
            if (string.IsNullOrEmpty(quotChar))
            {
                throw new ArgumentNullException("quotChar");
            }

            int quotLength = quotChar.Length;
            int quotLength2 = quotLength*2;
            if (!string.IsNullOrEmpty(value) &&
                value.Length >= quotLength2 &&
                value.StartsWith(quotChar) &&
                value.EndsWith(quotChar))
            {
                value = value.Substring(quotLength, value.Length - quotLength2);
            }

            return value;
        }
    }
}

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
    public static class SanitizerExtensions
    {
        /// <summary>
        /// Sanitize an input data using a specified sanitizer engine.
        /// </summary>
        /// <param name="str">A data to sanitize.</param>
        /// <param name="engineId">An ID of the engine to sanitize the data with.</param>
        /// <returns>A sanitized value.</returns>
        public static string Sanitize(this string str, string engineId)
        {
            return SecurityKernel.Sanitizer.Api.Execute(engineId, str);
        }

        /// <summary>
        /// Remove null simbols (sanitize) in input data.
        /// </summary>
        /// <param name="str">A data to sanitize.</param>
        /// <returns>A data to sanitize.</returns>
        public static string SanitizeNullCharacters(this string str)
        {
            return SecurityKernel.Sanitizer.Api.ExecuteDefaultByCategory(SanitizerEngineCategory.NullCharacterSanitizer.ToString(), str);
        }
    }
}

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
using System.Web;
using MetraTech.SecurityFramework.Core.Decoder;


namespace MetraTech.SecurityFramework
{
    internal sealed class DefaultUrlDecoderEngine : DecoderEngineBase
    {
        public DefaultUrlDecoderEngine() 
            : base(DecoderEngineCategory.Url)
        {}

        /// <summary>
        /// Converts a string that has been encoded for transmission in a URL into a decoded string.
        /// </summary>
        /// <param name="input">The string to decode.</param>
        /// <returns>A decoded string.</returns>
        protected override ApiOutput DecodeInternal(ApiInput input)
        {
            return new ApiOutput(HttpUtility.UrlDecode(input.ToString()), input.Exceptions);
        }
    }
}

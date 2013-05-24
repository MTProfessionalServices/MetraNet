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
using MetraTech.SecurityFramework.Core.Encoder;

namespace MetraTech.SecurityFramework
{
    internal sealed class DefaultCssEncoderEngine : EncoderEngineBase
    {
		public DefaultCssEncoderEngine():base(EncoderEngineCategory.Css)
		{}

        protected override ApiOutput ExecuteInternal(ApiInput input)
        {
            if (input == null || string.IsNullOrEmpty(input.ToString()))
                throw new NullInputDataException(this.SubsystemName, this.CategoryName, SecurityEventType.OutputDataProcessingEventType);

            return new ApiOutput(Microsoft.Security.Application.Encoder.CssEncode(input.ToString()));
        }
    }
}


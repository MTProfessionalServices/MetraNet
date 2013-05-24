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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/
using System;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Provides a base for exceptions caused by a potentially danger data.
    /// </summary>
    public class SanitizerInputDataException: BadInputDataException
    {
        /// <summary>
        /// Creates an instance of the <see cref="SanitizerInputDataException"/> class.
        /// </summary>
        /// <param name="id">Security problem Id</param> 
        /// <param name="category">Specifies a name of the sanitizer category a source engine belongs to.</param>
        /// <param name="message">A message describing the exception.</param>
        public SanitizerInputDataException(ExceptionId.Sanitizer id, SanitizerEngineCategory category, string message)
            : base(id.ToInt(), typeof(SecurityFramework.Sanitizer).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType)
        { }

        /// <summary>
        /// Creates an instance of the <see cref="SanitizerInputDataException"/> class.
        /// </summary>
        /// <param name="id">Security problem Id</param> 
        /// <param name="category">Specifies a name of the sanitizer category a source engine belongs to.</param>
        /// <param name="message">A message describing the exception.</param>
        /// <param name="inner">Inner exception</param>
        public SanitizerInputDataException(ExceptionId.Sanitizer id, SanitizerEngineCategory category, string message, Exception inner)
            : base(id.ToInt(), typeof(SecurityFramework.Sanitizer).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType, inner)
        {}

        /// <summary>
        /// Creates an instance of the <see cref="SanitizerInputDataException"/> class.
        /// </summary>
        /// <param name="id">Security problem Id</param> 
        /// <param name="category">Specifies a name of the sanitizer category a source engine belongs to.</param>
        /// <param name="message">A message describing the exception.</param>
        /// <param name="inputData">Specifies a input data whith processed an engine.</param>
        /// <param name="reason">Specifies a reason of the current exception.</param>
        public SanitizerInputDataException(ExceptionId.Sanitizer id, SanitizerEngineCategory category, string message, string inputData, string reason)
            : base(id.ToInt(), typeof(SecurityFramework.Sanitizer).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType, inputData, reason)
        {}

        /// <summary>
        /// Creates an instance of the <see cref="SanitizerInputDataException"/> class.
        /// </summary>
        /// <param name="id">Security problem Id</param> 
        /// <param name="category">Specifies a name of the sanitizer category a source engine belongs to.</param>
        /// <param name="message">A message describing the exception.</param>
        /// <param name="inputData">Specifies a input data whith processed an engine.</param>
        /// <param name="reason">Specifies a reason of the current exception.</param>
        /// <param name="inner">Inner exception</param>
        public SanitizerInputDataException(ExceptionId.Sanitizer id, SanitizerEngineCategory category, string message, string inputData, string reason, Exception inner)
            : base(id.ToInt(), typeof(SecurityFramework.Sanitizer).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType, inputData, reason, inner)
        { }
    }
}

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
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
    // TODO: The suimilar expressions as typeof(SecurityFramework.Detector).Name should be move to constants
    public class DetectorInputDataException : BadInputDataException
    {
        public DetectorInputDataException(ExceptionId.Detector id, DetectorEngineCategory category,  string message)
            : base(id.ToInt(), typeof(SecurityFramework.Detector).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType)
        { }

        public DetectorInputDataException(ExceptionId.Detector id, DetectorEngineCategory category,  string message, Exception inner)
            : base(id.ToInt(), typeof(SecurityFramework.Detector).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType, inner)
        {}

        public DetectorInputDataException(ExceptionId.Detector id, DetectorEngineCategory category, string message, string inputData, string reason)
            : base(id.ToInt(), typeof(MetraTech.SecurityFramework.Detector).Name, Convert.ToString(category)
                    , message, SecurityEventType.InputDataProcessingEventType, inputData, reason)
        {}
    }
}

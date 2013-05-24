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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Detector
{
    /// <summary>
    /// Provides a base class for all engines in the Detector subsystem.
    /// </summary>
    public abstract class DetectorEngineBase : EngineBase
    {
         protected DetectorEngineBase(DetectorEngineCategory category)
        {
            Category = category;
            this.CategoryName = Convert.ToString(Category);
        }
        /// <summary>
        /// Gets a type of the subsystem the engine belongs to.
        /// </summary>
        protected override Type SubsystemType
        {
            get
            {
                return typeof(MetraTech.SecurityFramework.Detector);
            }
        }

        /// <summary>
        /// validator category enum
        /// </summary>
		protected DetectorEngineCategory Category
		{
			get;
			private set;
		}

        /// <summary>
        /// Checks whether input data is null or empty string and stops execution if it is.
        /// Otherwise calls ExecuteInternal method.
        /// </summary>
        /// <param name="input">A data to be checked.</param>
        /// <returns>Execution result.</returns>
        protected override ApiOutput ExecuteInternal(ApiInput input)
        {
            string inputValue;
            if (input == null || (inputValue = input.ToString()) == null)
            {
                throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
            }

            ApiOutput result = null;

            if (String.IsNullOrEmpty(inputValue))
            {
                result = new ApiOutput(String.Empty);
            }
            else
            {
                result = DetectInternal(input);
            }

            return result;
        }

        /// <summary>
        /// Detects security issues.
        /// </summary>
        /// <param name="input">A data to be checked for security issues.</param>
        /// <returns>Execution result.</returns>
        protected abstract ApiOutput DetectInternal(ApiInput input);
    }
}

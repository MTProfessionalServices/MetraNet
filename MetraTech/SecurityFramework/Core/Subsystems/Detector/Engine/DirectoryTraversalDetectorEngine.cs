/**************************************************************************
* Copyright 1997-2012 by MetraTech
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
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.Detector
{
    /// <summary>
    /// Provides fuctionality to detect directory traversal attacks.
    /// </summary>
    public class DirectoryTraversalDetectorEngine : DetectorEngineBase
    {
        #region Constants

        private static readonly string[] _directoryTraversalMarkers = new string[] { "../", "..\\", "/..", "\\..", "./.", ".\\.", "..", };

        #endregion

        #region Constructor

        public DirectoryTraversalDetectorEngine() : base(DetectorEngineCategory.DirectoryTraversal) { }

        #endregion

        #region Protected methods

        /// <summary>
        /// Detects directory traversal in the input string.
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        protected override ApiOutput DetectInternal(ApiInput input)
        {
            string strValue = input.ToString();
            if (_directoryTraversalMarkers.Any(p => strValue.Contains(p)))
            {
                throw new DetectorInputDataException(ExceptionId.Detector.DetectDirectoryTraversal, this.Category, string.Format("Directory Traversal found in \"{0}\"", strValue));
            }

            return new ApiOutput(input.Value);
        }

        #endregion
    }
}

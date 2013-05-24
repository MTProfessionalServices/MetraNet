
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
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Detector.Engine
{
    /// <summary>
    /// Try to detect Base64 encoding in input string.
    /// </summary>
    internal class Base64DetectorEngine : DetectorEngineBase
    {
        private bool _isInitEngine = false;
        private int _minLengthString = -1;
        private Base64Detector _base64Detector = null;


        public Base64DetectorEngine()
            : base(DetectorEngineCategory.Xss)
        {}

        /// <summary>
        /// Used in regex as minimum lengt of input string for BASE64 detection
        /// </summary>
		[SerializePropertyAttribute]
        public string MinLengthBase64Sequence { get; set; }
        public string MinLengthString { get; set; }
        
        protected override ApiOutput DetectInternal(ApiInput input)
        {
            if (!_isInitEngine)
                Init();

            if (input.ToString().Length >= _minLengthString && _base64Detector.IsBase64(input.ToString()))
                    throw new DetectorInputDataException(
						ExceptionId.Detector.DetectObfuscation,
                        Category,
                        "XSS injection detected.",
						input.ToString(),
                        String.Format("Base64 encoding was detected, pattern is '{0}' and length of inpit string is a multiple of four",
                                        _base64Detector.Base64RegexPatternn));
           
            return new ApiOutput(input, input.Exceptions);
        }

        /// <summary>
        /// Initialize engine
        /// </summary>
        private void Init()
        {
            try
            {
                _minLengthString = Convert.ToInt32(MinLengthBase64Sequence);
            }
            catch (Exception)
            {
                throw new SubsystemInputParamException(string.Format("fault configuration for {0}. couldn't convert param {1} to int"
                                                                    , typeof(Base64DetectorEngine).Name
                                                                    , "MinLengthBase64Sequence"));
            }
            _base64Detector = new Base64Detector();
            _isInitEngine = true;
        }
    }
}

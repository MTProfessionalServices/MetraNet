using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Detector.Engine
{
    /// <summary>
    /// <see cref="DetectorInputDataException"/> throw with set Message and Reason.  
    /// </summary>
    /// <remarks>For internal use: Used in the rules processor</remarks>
    internal class ThrowExceptionEngineDetectObfuscation : DetectorEngineBase
    {
        /// <summary>
        /// Message for exception
        /// </summary>
		[SerializePropertyAttribute]
        public string Message { get; set; }

        /// <summary>
        /// Reason for exception
		/// </summary>
		[SerializePropertyAttribute]
        public string Reason { get; set; }

        public ThrowExceptionEngineDetectObfuscation()
            : base(DetectorEngineCategory.Xss)
        {}

        /// <summary>
        /// <see cref="DetectorInputDataException"/> will throw.
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        protected override ApiOutput DetectInternal(ApiInput input)
        {
            throw new DetectorInputDataException(ExceptionId.Detector.DetectObfuscation, Category, Message, input.ToString(), Reason);
        }
    }

    
}

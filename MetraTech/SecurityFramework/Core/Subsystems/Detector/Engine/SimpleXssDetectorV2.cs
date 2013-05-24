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
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Serialization;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Detector;
using MetraTech.SecurityFramework.Core.Detector.Engine;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Detector.Engine
{
    /// <summary>
    /// XSS Detector (ver. 2)
    /// </summary>
    internal sealed class SimpleXssDetectorV2 : DetectorEngineBase
    {
        #region Private Fields
        /// <summary>
        /// Contains compiled <see cref="Regex"/> experssions
        /// </summary>
        private SimpleXssDetectorPropertiesAdapted _adaptedDetectProps;
        private string _logDetection = String.Empty;
        private string _inputData = String.Empty;

        #endregion Private Fields

        #region Public props
		
		[SerializePropertyAttribute]
		public int UpperLimitDetection { get; set; }

		[SerializePropertyAttribute(DefaultType = typeof(GenericSimpleXssDetectorProperties<PatternWeight>))]
		public GenericSimpleXssDetectorProperties<PatternWeight> DetectionParams { get; set; }

        #endregion Public props

        #region Constructors

        public SimpleXssDetectorV2():base(DetectorEngineCategory.Xss)
        {}

        #endregion Constructors

        #region Public methods

        public override void  Initialize()
		{
			_adaptedDetectProps = new SimpleXssDetectorPropertiesAdapted(DetectionParams);
			base.Initialize();
		}

        #endregion Public methods

        #region Protected methods

        // TODO: This method must be thread safe
        protected override ApiOutput DetectInternal(ApiInput input)
        {
            int totalWeight = 0;
            _logDetection = String.Empty;
            _inputData = input.ToString();
            // detect java script
            DetectJavaScriptElement(ref totalWeight);

            // detect DOM elemen
            DetectDomElement(ref totalWeight);

            // detect HTML element
            DetectHtmlElement(ref totalWeight);

            // detect HTML event
            DetectHtmlEvent(ref totalWeight);

            // detect sign element
            DetectSignElement(ref totalWeight);

            // detect VB script
            DetectVbScriptElement(ref totalWeight);

            // detect obfuscation element
            DetectObfuscation(ref totalWeight);

            return new ApiOutput(input.Value);
        }

        #endregion Protected methods

        #region Private methods
        /// <summary>
        /// Log actions
        /// </summary>
        /// <param name="idException"></param>
        /// <param name="detectionExpression"></param>
        /// <param name="weight"></param>
        private void WriteToLogDetection(ExceptionId.Detector idException, string detectionExpression, int weight)
        {
            _logDetection += String.Format("\tId={0} : \t\"{1}\" : \tWeight={2};\n", idException, detectionExpression, weight);
        }

        private int AlgorithmIsMatch(ExceptionId.Detector idException, PatternWeightRegex[] paternCollections)
        {
            int result = 0;
            foreach (PatternWeightRegex pattern in paternCollections)
            {
                MatchCollection ms = pattern.Pattern.Matches(_inputData);
                if (ms.Count > 0)
                {
                    result += pattern.Weight * ms.Count;
                    WriteToLogDetection(idException, pattern.Pattern.ToString(), pattern.Weight);
                }
            }
            return result;
        }

        private void CheckXssAttack(ExceptionId.Detector idException, int currentWeight)
        {
            if (currentWeight >= UpperLimitDetection)
                throw new DetectorInputDataException(
					idException,
					Category,
					"XSS injection detected.",
					_inputData,
					_logDetection + String.Format("Total Weight = {0};", currentWeight));
        }

        #region Detection methods
        
        private void DetectJavaScriptElement(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectJavaScript, _adaptedDetectProps.JavaScriptElementPatterns);
            CheckXssAttack(ExceptionId.Detector.DetectJavaScript, currentWeight);
        }

        private void DetectDomElement(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectDomElement, _adaptedDetectProps.DomElementPatterns);
            CheckXssAttack(ExceptionId.Detector.DetectDomElement, currentWeight);
        }

        private void DetectHtmlElement(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectHtmlTag, _adaptedDetectProps.HtmlElementPatterns);
            CheckXssAttack(ExceptionId.Detector.DetectHtmlTag, currentWeight);
        }

        private void DetectHtmlEvent(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectHtmlEvent, _adaptedDetectProps.HtmlEventNames);
            CheckXssAttack(ExceptionId.Detector.DetectHtmlEvent, currentWeight);
        }

        private void DetectSignElement(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectSignElement, _adaptedDetectProps.SignsPatterns);
            CheckXssAttack(ExceptionId.Detector.DetectSignElement, currentWeight);
        }

        private void DetectVbScriptElement(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectVbScriptElement, _adaptedDetectProps.VbScriptPatterns);
            CheckXssAttack(ExceptionId.Detector.DetectVbScriptElement, currentWeight);
        }

        private void DetectObfuscation(ref int currentWeight)
        {
            currentWeight += AlgorithmIsMatch(ExceptionId.Detector.DetectObfuscation, _adaptedDetectProps.ObfuscationPatterns);
            CheckXssAttack(ExceptionId.Detector.DetectObfuscation, currentWeight);
        }
        

        #endregion Detection methods

        #endregion Private methods
    }
}

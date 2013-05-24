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
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Detector.Engine;


namespace MetraTech.SecurityFramework.Core.Decoder
{
    /// <summary>
    /// This implementation of Base64 decoder can distinguish deferent version of Base64 encoding
    /// </summary>
    internal class ComplexBase64Decoder : DecoderEngineBase
    {
        private bool _isInitEngine = false;
        private Base64Detector _base64Detector = null;
        private Dictionary<Base64Detector.Base64Version, IEngine> _dicBase64Engines = new Dictionary<Base64Detector.Base64Version, IEngine>();

        public ComplexBase64Decoder()
            : base(DecoderEngineCategory.Base64)
        {}

        /// <summary>
        /// Try decode base64 sequence to string.
        /// </summary>
        /// <param name="input">An input value.</param>
        /// <returns>A decoded value.</returns>
        /// <exception cref="DecoderInputDataException"></exception>
        protected override ApiOutput DecodeInternal(ApiInput input)
        {
            ApiOutput result = null;
            if (!_isInitEngine)
                Init();

            Base64Detector.Base64Version base64Version = _base64Detector.GetBase64Version(input.ToString());

            if (_dicBase64Engines.ContainsKey(base64Version))
            {
                result = _dicBase64Engines[base64Version].Execute(input);
            }
            else
            {
                throw new DecoderInputDataException(
					ExceptionId.Decoder.Base64InvalidFormat, Category, "Input sequence is not in base64 format.", input.ToString(), "Input sequence is not in base64 format.");
            }
            
            return result;
        }
        
        private void Init()
        {
            _base64Detector = new Base64Detector();
            InitBase64Engines();

            _isInitEngine = true;
        }

        private void InitBase64Engines()
        {
            _dicBase64Engines.Add(Base64Detector.Base64Version.Standart,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".Standart"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForFilenames,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForFilenames"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForURL,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForURL"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForXmlNmtoken,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForXmlNmtoken"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForXmlName,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForXmlName"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForProgramIdentifiersV1,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV1"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForProgramIdentifiersV2,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForProgramIdentifiersV2"));

            _dicBase64Engines.Add(Base64Detector.Base64Version.ModifiedForRegularExpressions,
                SecurityKernel.Decoder.Api.GetEngine(DecoderEngineCategory.Base64 + ".ModifiedForRegularExpressions"));
        }
    }
}

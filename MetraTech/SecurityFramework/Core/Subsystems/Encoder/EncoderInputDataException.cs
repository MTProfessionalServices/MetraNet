using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
    public class EncoderInputDataException : BadInputDataException
    {
        public EncoderInputDataException(ExceptionId.Encoder id, EncoderEngineCategory category, string message)
            : base(id.ToInt(), typeof(SecurityFramework.Encoder).Name
                    , Convert.ToString(category), message, SecurityEventType.InputDataProcessingEventType)
        { }

        public EncoderInputDataException(ExceptionId.Encoder id, EncoderEngineCategory category, string message, Exception inner)
            : base(id.ToInt(), typeof(SecurityFramework.Encoder).Name, Convert.ToString(category)
                    , message , SecurityEventType.InputDataProcessingEventType, inner)
        {}

        public EncoderInputDataException(ExceptionId.Encoder id, EncoderEngineCategory category, string message
                                            , string inputData, string reason)
            : base(id.ToInt(), typeof(SecurityFramework.Encoder).Name
                    , Convert.ToString(category), message, SecurityEventType.InputDataProcessingEventType
                    , inputData, reason)
        {}
    }
}

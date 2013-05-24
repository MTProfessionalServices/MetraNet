using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
    public class ProcessorException : BadInputDataException
    {
        public IEnumerable<Exception> Errors { get; private set; }

        #region Constructors

        public ProcessorException(ProcessorEngineCategory category, string message, IEnumerable<Exception> errors)
            : base(ExceptionId.Processor.General.ToInt(), typeof(Processor).Name
                    , Convert.ToString(category)
                    , message, SecurityEventType.Unknown)
        {
            Errors = errors;
        }

        /// <summary>
        /// Creates an instance of the <see cref="ProcessorException"/> class and sets a source category, message, erors data, input data and reason.
        /// </summary>
        /// <param name="category">A source engine's category.</param>
        /// <param name="message">An error message.</param>
        /// <param name="errors">A list of errors heppende during engine execution.</param>
        /// <param name="inputData">An input data.</param>
        /// <param name="reason">An exception reason.</param>
        public ProcessorException(ProcessorEngineCategory category, string message, IEnumerable<Exception> errors, string inputData, string reason)
            : base(ExceptionId.Processor.General.ToInt(), typeof(Processor).Name
            , Convert.ToString(category)
            , message, SecurityEventType.Unknown
            , inputData
            , reason)
        {
            Errors = errors;
        }

        #endregion
    }
}

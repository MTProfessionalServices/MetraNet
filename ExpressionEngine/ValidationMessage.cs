using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class ValidationMessage
    {
        #region Enums
        public enum SeverityType { Error, Warn, Info };
        #endregion

        #region Properties

        /// <summary>
        /// The severity of the message
        /// </summary>
        public SeverityType Severity { get; set; }

        /// <summary>
        /// The message to be presented to the user. It is assumed that it is already localized by the time that it reaches this point
        /// </summary>
        public string Message { get; set; }

        public int LineNumber { get; set; }

        public int ColumnNumber { get; set; }

        #endregion

        #region Constructors
        public ValidationMessage(SeverityType severity, string message)
        {
            Severity = severity;
            Message = message;
        }
        public ValidationMessage(SeverityType severity, string message, int lineNumber, int columnNumber):this(severity, message)
        {
            LineNumber = lineNumber;
            ColumnNumber = columnNumber;
        }
        #endregion
    }
}

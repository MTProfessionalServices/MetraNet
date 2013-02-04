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

        #endregion

        #region Constructor
        public ValidationMessage(SeverityType severity, string message)
        {
            Severity = severity;
            Message = message;
        }
        #endregion
    }
}

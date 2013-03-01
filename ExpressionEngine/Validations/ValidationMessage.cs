using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Validations.Enumerations;

namespace MetraTech.ExpressionEngine.Validations
{
    [DataContract(Namespace = "MetraTech")]
    public class ValidationMessage
    {
        #region Properties

        /// <summary>
        /// The severity of the message
        /// </summary>
        [DataMember]
        public SeverityType Severity { get; set; }

        /// <summary>
        /// The message to be presented to the user. It is assumed that it is already localized by the time that it reaches this point
        /// TODO this should be replaced with an ID
        /// </summary>
        [DataMember]
        public string Message { get; set; }

        [DataMember]
        public int LineNumber { get; set; }

        [DataMember]
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

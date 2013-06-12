using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Text;
using System.Globalization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.Validations.Enumerations;

namespace MetraTech.ExpressionEngine.Validations
{
    [DataContract(Namespace = "MetraTech")]
    public class ValidationMessageCollection : IEnumerable<ValidationMessage>
    {
        #region Constants
        public const int NoPosition = -1;
        #endregion

        #region Properties

        /// <summary>
        /// The number of errors
        /// </summary>
        [DataMember]
        public int ErrorCount { get; private set; }

        /// <summary>
        /// The number of warnings
        /// </summary>
        [DataMember]
        public int WarningCount { get; private set; }

        /// <summary>
        /// The number of informational messages
        /// </summary>
        [DataMember]
        public int InfoCount { get; private set; }
        public int Count { get { return Messages.Count; } }
        public SeverityType HighestSeverity
        {
            get
            {
                if (ErrorCount > 0)
                    return SeverityType.Error;
                if (WarningCount > 0)
                    return SeverityType.Warn;
                return SeverityType.Info;
            }
        }

        [DataMember]
        private List<ValidationMessage> Messages = new List<ValidationMessage>();
        #endregion

        #region Methods

        public void Add(ValidationMessage message)
        {
            if (message == null)
                throw new ArgumentNullException("message");
            switch (message.Severity)
            {
                case SeverityType.Error:
                    ErrorCount++;
                    break;
                case SeverityType.Info:
                    InfoCount++;
                    break;
                case SeverityType.Warn:
                    WarningCount++;
                    break;
            }
            Messages.Add(message);
        }

        public void Add(IComponent component, SeverityType severityType, string formatTemplate, object[] args)
        {
            if (component == null)
                throw new ArgumentException("component is null");

            var prefix = string.Format(CultureInfo.CurrentUICulture, Localization.ComponentValidationMessagePrefix, ComponentHelper.GetUserName(component.ComponentType), component.FullName);
            var message = prefix + string.Format(CultureInfo.CurrentUICulture, formatTemplate, args);
            Add(severityType, message);
        }
        public void Add(SeverityType severity, string message, params object[] args)
        {
            Add(severity, NoPosition, NoPosition, message, args);
        }
        public void Add(SeverityType severity, int lineNumber, int columnNumber, string message, params object[] args)
        {
            var valMsg = new ValidationMessage(severity, message, lineNumber, columnNumber);
            Add(valMsg);
        }

        public void Error(string message, params object[] args)
        {
            Add(SeverityType.Error, NoPosition, NoPosition, message, args);
        }
        public void Error(IComponent component, string formatTemplate, params object[] args)
        {
            Add(component, SeverityType.Error, formatTemplate, args);
        }
        public void Error(string message, int lineNumber, int columnNumber)
        {
            Add(SeverityType.Error, lineNumber, columnNumber, message);
        }

        public void Error(Exception exception, string message, params object[] args)
        {
            if (exception == null)
                throw new ArgumentException("excpetion is null");

            var msg = string.Format(CultureInfo.CurrentUICulture, Localization.ExceptionMessage, message, exception.Message, args);
            var valMessage = new ValidationMessage(SeverityType.Error, msg);
            valMessage.Exception = exception;
            Add(valMessage);
        }

        public void Warn(string message, params object[] args)
        {
            Add(SeverityType.Warn, message, args);
        }
        public void Warn(IComponent component, string formatTemplate, params object[] args)
        {
            Add(component, SeverityType.Warn, formatTemplate, args);
        }
        public void Info(string message, params object[] args)
        {
            Add(SeverityType.Info, message, args);
        }
        public void Info(IComponent component, string formatTemplate, params object[] args)
        {
            Add(component, SeverityType.Info, formatTemplate, args);
        }
        public void AddRange(ValidationMessageCollection messages)
        {
            Messages.AddRange(messages);
        }

        /// <summary>
        /// Returns a string with a message per line
        /// </summary>
        /// <returns></returns>
        public string GetSummary(bool getBody)
        {
            var sb = new StringBuilder();
            sb.AppendLine("NumErrors:   " + ErrorCount);
            sb.AppendLine("NumWarnings: " + WarningCount);
            sb.AppendLine("NumInfos:    " + InfoCount);

            if (getBody)
            {
                foreach (var message in Messages)
                {
                    sb.AppendLine(message.ToString());
                }
            }
            return sb.ToString();
        }

        #endregion

        #region IEnumerable Methods
        IEnumerator<ValidationMessage> IEnumerable<ValidationMessage>.GetEnumerator()
        {
            return Messages.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}

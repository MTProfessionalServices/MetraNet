using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    public class ValidationMessageCollection : IEnumerable<ValidationMessage>
    {
        #region Constants
        public const int NoPostion = -1;
        #endregion

        #region Properties
        public int ErrorCount { get; private set; }
        public int WarningCount { get; private set; }
        public int InfoCount { get; private set; }
        public int Count { get { return Messages.Count; } }
        public ValidationMessage.SeverityType HighestSeverity
        {
            get
            {
                if (ErrorCount > 0)
                    return ValidationMessage.SeverityType.Error;
                if (WarningCount > 0)
                    return ValidationMessage.SeverityType.Warn;
                return ValidationMessage.SeverityType.Info;
            }
        }
        private List<ValidationMessage> Messages = new List<ValidationMessage>();
        #endregion

        #region Methods

        public void Add(ValidationMessage valMsg)
        {
            if (valMsg == null)
                throw new ArgumentNullException("valMsg");
            switch (valMsg.Severity)
            {
                case ValidationMessage.SeverityType.Error:
                    ErrorCount++;
                    break;
                case ValidationMessage.SeverityType.Info:
                    InfoCount++;
                    break;
                case ValidationMessage.SeverityType.Warn:
                    WarningCount++;
                    break;
            }
            Messages.Add(valMsg);
        }

        public void Add(ValidationMessage.SeverityType severity, string message)
        {
            Add(severity, message, NoPostion, NoPostion);
        }
        public void Add(ValidationMessage.SeverityType severity, string message, int lineNumber, int columnNumber)
        {
            var valMsg = new ValidationMessage(severity, message, lineNumber, columnNumber);
            Add(valMsg);
        }

        public void Error(string message)
        {
            Add(ValidationMessage.SeverityType.Error, message, NoPostion, NoPostion);
        }
        public void Error(string message, int lineNumber, int columnNumber)
        {
            Add(ValidationMessage.SeverityType.Error, message, lineNumber, columnNumber);
        }

        public void Warn(string message)
        {
            Add(ValidationMessage.SeverityType.Warn, message);
        }

        public void Info(string message)
        {
            Add(ValidationMessage.SeverityType.Info, message);
        }
            
        /// <summary>
        /// Returns a string with a message per line
        /// </summary>
        /// <returns></returns>
        public string GetSummary()
        {
            var sb = new StringBuilder();
            foreach (var message in Messages)
            {
                sb.Append(string.Format(CultureInfo.CurrentUICulture, "[{0}] {1}", message.Severity, message.Message));
                if (message.LineNumber != NoPostion)
                    sb.AppendLine(string.Format(CultureInfo.CurrentUICulture, "Line {0} Column {1}", message.LineNumber, message.ColumnNumber));
                else
                    sb.AppendLine();
            }
            return sb.ToString();
        }

        #endregion

        #region IEnumerable Methods
        IEnumerator<ValidationMessage> IEnumerable<ValidationMessage>.GetEnumerator()
        {
            throw new NotImplementedException();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}

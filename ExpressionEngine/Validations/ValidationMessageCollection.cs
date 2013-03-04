using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Text;
using System.Globalization;
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
        [DataMember]
        public int ErrorCount { get; private set; }

        [DataMember]
        public int WarningCount { get; private set; }

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

        public void Add(SeverityType severity, string message)
        {
            Add(severity, message, NoPosition, NoPosition);
        }
        public void Add(SeverityType severity, string message, int lineNumber, int columnNumber)
        {
            var valMsg = new ValidationMessage(severity, message, lineNumber, columnNumber);
            Add(valMsg);
        }

        public void Error(string message)
        {
            Add(SeverityType.Error, message, NoPosition, NoPosition);
        }
        public void Error(string message, int lineNumber, int columnNumber)
        {
            Add(SeverityType.Error, message, lineNumber, columnNumber);
        }

        public void Warn(string message)
        {
            Add(SeverityType.Warn, message);
        }

        public void Info(string message)
        {
            Add(SeverityType.Info, message);
        }
            
        /// <summary>
        /// Returns a string with a message per line
        /// </summary>
        /// <returns></returns>
        public string GetSummary(bool getBody)
        {
            var sb = new StringBuilder();
            sb.AppendLine("NumErrors:   " + ErrorCount.ToString());
            sb.AppendLine("NumWarnings: " + WarningCount.ToString());
            sb.AppendLine("NumInfos:    " + InfoCount.ToString());

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

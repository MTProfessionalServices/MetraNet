using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class ValidationMessageCollection : IEnumerable<ValidationMessage>
    {
        #region Properties
        public int NumErrors { get; private set; }
        public int NumWarnings { get; private set; }
        public int NumInfos { get; private set; }
        private List<ValidationMessage> Messages = new List<ValidationMessage>();
        #endregion

        #region Methods
        public void Add(ValidationMessage valMsg)
        {
            switch (valMsg.Severity)
            {
                case ValidationMessage.SeverityType.Error:
                    NumErrors++;
                    break;
                case ValidationMessage.SeverityType.Info:
                    NumInfos++;
                    break;
                case ValidationMessage.SeverityType.Warn:
                    NumWarnings++;
                    break;
            }
            Messages.Add(valMsg);
        }

        public void Add(ValidationMessage.SeverityType severity, string message)
        {
            var valMsg = new ValidationMessage(severity, message);
            Add(valMsg);
        }

        public void Error(string message)
        {
            Add(ValidationMessage.SeverityType.Error, message);
        }

        public void Warn(string message)
        {
            Add(ValidationMessage.SeverityType.Warn, message);
        }

        public void Info(string message)
        {
            Add(ValidationMessage.SeverityType.Info, message);
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

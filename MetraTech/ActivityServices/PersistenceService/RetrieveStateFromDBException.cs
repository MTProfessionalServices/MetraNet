using System;
using System.Runtime.Serialization;

namespace MetraTech.ActivityServices.PersistenceService
{
    [Serializable]
    public class RetrieveStateFromDBException : Exception
    {
        public RetrieveStateFromDBException()
            : base()
        {
        }

        public RetrieveStateFromDBException(string message)
            : base(message)
        {
        }

        public RetrieveStateFromDBException(string message, Exception innerException)
            : base(message, innerException)
        {
        }

        protected RetrieveStateFromDBException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }
    }
}
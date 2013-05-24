//////////////////////////////////////////////////////////////////////////////
// This file was automatically generated using ICE.
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace MetraTech.Tax.Plugins
{
    /// <summary>
    /// Thrown when a value is set to null
    /// </summary>
    [Serializable]
    public class InvalidValueException : COMException
    {
        private const int HRESULT = Constants.E_FAIL;
        public InvalidValueException() 
        {
            this.HResult = HRESULT;
        }
        public InvalidValueException(string message) : base(message) 
        {
            this.HResult = HRESULT;
        }
        public InvalidValueException(string message, Exception inner) : base(message, inner) 
        {
            this.HResult = HRESULT;
        }
        protected InvalidValueException(
          System.Runtime.Serialization.SerializationInfo info,
          System.Runtime.Serialization.StreamingContext context)
            : base(info, context) 
        {
            this.HResult = HRESULT;
        }
    }

    /// <summary>
    /// thrown when there's an unreadable enum attribute found while parsing enums
    /// </summary>
    [Serializable]
    public class InvalidEnumAttributeException : COMException
    {
        private const int HRESULT = Constants.E_FAIL;
        public InvalidEnumAttributeException()
        {
            this.HResult = HRESULT;
        }
        public InvalidEnumAttributeException(string message)
            : base(message)
        {
            this.HResult = HRESULT;
        }
        public InvalidEnumAttributeException(string message, Exception inner)
            : base(message, inner)
        {
            this.HResult = HRESULT;
        }
        public InvalidEnumAttributeException(string message, int errorCode)
            : base(message, errorCode)
        {
            this.HResult = HRESULT;
        }
        protected InvalidEnumAttributeException(
          System.Runtime.Serialization.SerializationInfo info,
          System.Runtime.Serialization.StreamingContext context)
            : base(info, context)
        {
            this.HResult = HRESULT;
        }
    }
}
